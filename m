From: "Andrew Dickinson" <whydna@whydna.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity is exceeded
Date: Sat, 4 Oct 2008 21:45:27 -0700
Message-ID: <c3ca0c0f0810042145q35a451a7u706bc64fb43723fa@mail.gmail.com>
References: <20080930.070804.26007839.davem@davemloft.net>
	 <E1KmKGd-000393-UD@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:9107 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbYJEEp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 00:45:29 -0400
Received: by yx-out-2324.google.com with SMTP id 8so352662yxm.1
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2008 21:45:27 -0700 (PDT)
In-Reply-To: <E1KmKGd-000393-UD@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's the patch that Herbert's referring to.  The basic idea is that
we have a flag which indicates whether or not we need to invalidate
the route cache.  If any chain exceeds gc_elasticity, we set the flag
and reschedule the timer.  In the worst-case, we'll invalidate the
route cache once every secret_interval; in the best-case, we never
invalidate the cache.

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index a6ed838..82baf68 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -48,6 +48,7 @@ struct netns_ipv4 {
        int sysctl_icmp_errors_use_inbound_ifaddr;

        struct timer_list rt_secret_timer;
+       int rt_secret_flag;
        atomic_t rt_genid;
 };
 #endif
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e91bafe..83a1b43 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -837,13 +837,49 @@ void rt_cache_flush(struct net *net, int delay)
 }

 /*
- * We change rt_genid and let gc do the cleanup
+ * We set rt_secret_flag indicating that we can invalidate the cache if needed.
  */
 static void rt_secret_rebuild(unsigned long __net)
 {
        struct net *net = (struct net *)__net;
-       rt_cache_invalidate(net);
-       mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interval);
+       net->ipv4.rt_secret_flag = 1;
+}
+
+static void rt_secret_reschedule(int old)
+{
+       struct net *net;
+       int new = ip_rt_secret_interval;
+       int diff = new - old;
+
+       if (!diff)
+               return;
+
+       rtnl_lock();
+       for_each_net(net) {
+               int deleted = del_timer_sync(&net->ipv4.rt_secret_timer);
+
+               if (!new) {
+                       net->ipv4.rt_secret_flag = 0;
+                       continue;
+               }
+
+               if(net->ipv4.rt_secret_flag)
+                       continue;
+
+               if (old && deleted) {
+                       long time = net->ipv4.rt_secret_timer.expires - jiffies;
+
+                       if (time <= 0 || (time += diff) <= 0)
+                               time = 0;
+
+                       net->ipv4.rt_secret_timer.expires = time;
+               } else
+                       net->ipv4.rt_secret_timer.expires = new;
+
+               net->ipv4.rt_secret_timer.expires += jiffies;
+               add_timer(&net->ipv4.rt_secret_timer);
+       }
+       rtnl_unlock();
 }

 /*
@@ -1045,17 +1081,19 @@ restart:
                rthp = &rth->u.dst.rt_next;
        }

-       if (cand) {
-               /* ip_rt_gc_elasticity used to be average length of chain
-                * length, when exceeded gc becomes really aggressive.
-                *
-                * The second limit is less certain. At the moment it allows
-                * only 2 entries per bucket. We will see.
-                */
-               if (chain_length > ip_rt_gc_elasticity) {
+       if (chain_length > ip_rt_gc_elasticity) {
+               struct net *net = dev_net(rth->u.dst.dev);
+
+               if (cand) {
                        *candp = cand->u.dst.rt_next;
                        rt_free(cand);
                }
+
+               if (net->ipv4.rt_secret_flag &&
+                   xchg(&net->ipv4.rt_secret_flag, 0)) {
+                       rt_cache_invalidate(net);
+                       rt_secret_reschedule(0);
+               }
        }

        /* Try to bind route to arp only if it is output
@@ -2914,38 +2952,6 @@ static int
ipv4_sysctl_rtcache_flush_strategy(ctl_table *table,
        return 0;
 }

-static void rt_secret_reschedule(int old)
-{
-       struct net *net;
-       int new = ip_rt_secret_interval;
-       int diff = new - old;
-
-       if (!diff)
-               return;
-
-       rtnl_lock();
-       for_each_net(net) {
-               int deleted = del_timer_sync(&net->ipv4.rt_secret_timer);
-
-               if (!new)
-                       continue;
-
-               if (deleted) {
-                       long time = net->ipv4.rt_secret_timer.expires - jiffies;
-
-                       if (time <= 0 || (time += diff) <= 0)
-                               time = 0;
-
-                       net->ipv4.rt_secret_timer.expires = time;
-               } else
-                       net->ipv4.rt_secret_timer.expires = new;
-
-               net->ipv4.rt_secret_timer.expires += jiffies;
-               add_timer(&net->ipv4.rt_secret_timer);
-       }
-       rtnl_unlock();
-}
-
 static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
                                          struct file *filp,
                                          void __user *buffer, size_t *lenp,
@@ -3200,6 +3206,8 @@ static __net_init int
rt_secret_timer_init(struct net *net)
                        (int) ((num_physpages ^ (num_physpages>>8)) ^
                        (jiffies ^ (jiffies >> 7))));

+       net->ipv4.rt_secret_flag = 0;
+
        net->ipv4.rt_secret_timer.function = rt_secret_rebuild;
        net->ipv4.rt_secret_timer.data = (unsigned long)net;
        init_timer_deferrable(&net->ipv4.rt_secret_timer);









On Sat, Oct 4, 2008 at 8:26 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> David Miller <davem@davemloft.net> wrote:
>>
>> The idea is that we can by default not rebuild the secret
>> at all.
>
> Actually Andrew Dickson <whydna@whydna.net> came up with this idea
> quite a while ago: Keep the rehash interval but do nothing until
> some chain hits a specified length.  This is quite similar to
> what is being discussed here.
>
> Andrew, could you post the patch please?
>
> In addition to this, we should probably enforce that limit as
> well by simply not adding the newly created entry or deleting
> one forcibly.
>
> Thanks,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
