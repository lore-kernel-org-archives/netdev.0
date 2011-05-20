From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 1/1] igmp: call ip_mc_clear_src() only when we have no
 users of ip_mc_list
Date: Fri, 20 May 2011 18:27:09 +0200
Message-ID: <20110520162709.GA3497@darkmag.usersys.redhat.com>
References: <20110515165945.GA20024@darkmag.usersys.redhat.com>
 <20110516.140359.111037536766782557.davem@davemloft.net>
 <OF948388D5.90B3F5A7-ON88257892.006C3228-88257892.0071B9D5@us.ibm.com>
 <20110517133801.GC30366@darkmag.usersys.redhat.com>
 <20110517143756.GE30366@darkmag.usersys.redhat.com>
 <OF11F57B2A.6B43B7E6-ON88257893.005490B0-88257893.00615176@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	kaber@trash.net, kuznet@ms2.inr.ac.ru,
	linux-kernel@vger.kernel.org, mmarek@suse.cz,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF11F57B2A.6B43B7E6-ON88257893.005490B0-88257893.00615176@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2011 at 10:42:59AM -0700, David Stevens wrote:
> Veaceslav,
>         It looks to me like this will leak the source filters if we are 
> called from ip_mc_destroy_dev(),
> Even with your previous patch, you're assuming that we don't free the 
> ip_mc_list and so we have the
> same one when we up the device, but if there are no timers running, it 
> looks like refcnt canl go to 0 and free
> it. If we can ever free the ip_mc_list when users != 0 (or going to 0 
> immediately after the drop), we
> have to do the ip_mc_clear_src() or leak the list. I haven't looked at 
> this code in years, so I'll need
> to refresh my memory.
>         So, I'll look at that a bit more; at a minimum, I think you need 
> to do the clear_src
> also in the destroy case. We could lose the filters and set the exclude 
> count to users, instead
> of 1; but I like the idea of keeping the source filters across a down/up, 
> if we can be sure there
> are no cases where we free the ip_mc_list without first freeing all the 
> filters.
> 
>                                                                 +-DLS

Yes, you are completely right, we can leak the sources on
ip_mc_destroy_dev() when we've ip_ma_put() it inside all the timers. Also,
I've seen that we called igmp_group_dropped() for every mc in dev->mc_list,
however we've done it already in ip_mc_down() before, which wouldn't lead
to anything (cause the device is already ->dead, and all timers are
stopped), but just would be a waste of time.

So, does this patch seem ok? If yes, I'll send it with the changelog.

---
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 1fd3d9c..57ca93a 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1169,20 +1169,18 @@ static void igmp_group_dropped(struct ip_mc_list *im)
 
 	if (!in_dev->dead) {
 		if (IGMP_V1_SEEN(in_dev))
-			goto done;
+			return;
 		if (IGMP_V2_SEEN(in_dev)) {
 			if (reporter)
 				igmp_send_report(in_dev, im, IGMP_HOST_LEAVE_MESSAGE);
-			goto done;
+			return;
 		}
 		/* IGMPv3 */
 		igmpv3_add_delrec(in_dev, im);
 
 		igmp_ifc_event(in_dev);
 	}
-done:
 #endif
-	ip_mc_clear_src(im);
 }
 
 static void igmp_group_added(struct ip_mc_list *im)
@@ -1319,6 +1317,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 				*ip = i->next_rcu;
 				in_dev->mc_count--;
 				igmp_group_dropped(i);
+				ip_mc_clear_src(i);
 
 				if (!in_dev->dead)
 					ip_rt_multicast_event(in_dev);
@@ -1428,7 +1427,8 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 		in_dev->mc_list = i->next_rcu;
 		in_dev->mc_count--;
 
-		igmp_group_dropped(i);
+		/* We've dropped the groups in ip_mc_down already */
+		ip_mc_clear_src(i);
 		ip_ma_put(i);
 	}
 }
