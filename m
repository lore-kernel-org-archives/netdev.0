From: Scot Doyle <lkml@scotdoyle.com>
Subject: Re: [PATCH] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 08:34:17 -0500
Message-ID: <4DA6F7D9.8060701@scotdoyle.com>
References: <4DA522B2.90200@scotdoyle.com>	<4DA5BCF7.9020606@scotdoyle.com>	<1302708487.3725.0.camel@edumazet-laptop>	<20110413.144812.116375845.davem@davemloft.net>	<1302748276.3549.20.camel@edumazet-laptop>	<20110413195424.1d2393c6@s6510>	<1302750214.3549.34.camel@edumazet-laptop>	<20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>	<1302752263.3549.41.camel@edumazet-laptop> <20110414131552.1822142f.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:50132 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431Ab1DNNeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 09:34:19 -0400
In-Reply-To: <20110414131552.1822142f.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tested the three patches linked below, plus the two patches previously 
accepted by David in this thread, with 2.6.39-rc3 commit 
85f2e689a5c8fb6ed8fdbee00109e7f6e5fefcb6. No panics :-)

http://article.gmane.org/gmane.linux.network/192293
http://article.gmane.org/gmane.linux.network/192299
http://article.gmane.org/gmane.linux.network/192301

------------

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 008ff6c..10ac127 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -249,11 +249,9 @@ static int br_parse_ip_options(struct sk_buff *skb)
                 goto drop;
         }

-       /* Zero out the CB buffer if no options present */
-       if (iph->ihl == 5) {
-               memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+       memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+       if (iph->ihl == 5)
                 return 0;
-       }

         opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
         if (ip_options_compile(dev_net(dev), opt, skb))
@@ -265,7 +263,7 @@ static int br_parse_ip_options(struct sk_buff *skb)
                 if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
                         goto drop;

-               if (ip_options_rcv_srr(skb))
+               if (skb_rtable(skb) && ip_options_rcv_srr(skb))
                         goto drop;
         }

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index dd1b20e..9df4e63 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -354,7 +354,8 @@ static void inetpeer_free_rcu(struct rcu_head *head)
  }

  /* May be called with local BH enabled. */
-static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base 
*base)
+static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base 
*base,
+                            struct inet_peer __rcu **stack[PEER_MAXDEPTH])
  {
         int do_free;

@@ -368,7 +369,6 @@ static void unlink_from_pool(struct inet_peer *p, 
struct inet_peer_base *base)
          * We use refcnt=-1 to alert lockless readers this entry is 
deleted.
          */
         if (atomic_cmpxchg(&p->refcnt, 1, -1) == 1) {
-               struct inet_peer __rcu **stack[PEER_MAXDEPTH];
                 struct inet_peer __rcu ***stackptr, ***delp;
                 if (lookup(&p->daddr, stack, base) != p)
                         BUG();
@@ -422,7 +422,7 @@ static struct inet_peer_base *peer_to_base(struct 
inet_peer *p)
  }

  /* May be called with local BH enabled. */
-static int cleanup_once(unsigned long ttl)
+static int cleanup_once(unsigned long ttl, struct inet_peer __rcu 
**stack[PEER_MAXDEPTH])
  {
         struct inet_peer *p = NULL;

@@ -454,7 +454,7 @@ static int cleanup_once(unsigned long ttl)
                  * happen because of entry limits in route cache. */
                 return -1;

-       unlink_from_pool(p, peer_to_base(p));
+       unlink_from_pool(p, peer_to_base(p), stack);
         return 0;
  }

@@ -524,7 +524,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr 
*daddr, int create)

         if (base->total >= inet_peer_threshold)
                 /* Remove one less-recently-used entry. */
-               cleanup_once(0);
+               cleanup_once(0, stack);

         return p;
  }
@@ -540,6 +540,7 @@ static void peer_check_expire(unsigned long dummy)
  {
         unsigned long now = jiffies;
         int ttl, total;
+       struct inet_peer __rcu **stack[PEER_MAXDEPTH];

         total = compute_total();
         if (total >= inet_peer_threshold)
@@ -548,7 +549,7 @@ static void peer_check_expire(unsigned long dummy)
                 ttl = inet_peer_maxttl
                                 - (inet_peer_maxttl - inet_peer_minttl) 
/ HZ *
                                         total / inet_peer_threshold * HZ;
-       while (!cleanup_once(ttl)) {
+       while (!cleanup_once(ttl, stack)) {
                 if (jiffies != now)
                         break;
         }
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 28a736f..546dd02 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -329,7 +329,7 @@ int ip_options_compile(struct net *net,
                                         pp_ptr = optptr + 2;
                                         goto error;
                                 }
-                               if (skb) {
+                               if (rt) {
                                         memcpy(&optptr[optptr[2]-1], 
&rt->rt_spec_dst, 4);
                                         opt->is_changed = 1;
                                 }
@@ -371,7 +371,7 @@ int ip_options_compile(struct net *net,
                                                 goto error;
                                         }
                                         opt->ts = optptr - iph;
-                                       if (skb) {
+                                       if (rt) {
                                                 
memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
                                                 timeptr = 
(__be32*)&optptr[optptr[2]+3];
                                         }
@@ -606,7 +606,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
         if (!opt->srr)
                 return 0;

-       if (skb->pkt_type != PACKET_HOST)
+       if (skb->pkt_type != PACKET_HOST || !rt)
                 return -EINVAL;
         if (rt->rt_type == RTN_UNICAST) {
                 if (!opt->is_strictroute)
