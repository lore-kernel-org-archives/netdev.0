From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer (v3)
Date: Fri, 7 May 2010 15:55:28 -0400
Message-ID: <20100507195528.GA3752@hmsreliant.think-freely.org>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51556 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755414Ab0EGTzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 15:55:38 -0400
Content-Disposition: inline
In-Reply-To: <20100506171639.GA5063@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
	Sorry for the delay, but I got interested in Erics suggestion of
changing how we update rt_genid, and had a few thoughts.  Heres version 3 of
this patch:

Change Notes:

1) Removed the secret_interval binary interface entry in the list (forgot to do
that before)

2) Took Erics Suggestion to change the update for net->ipv4.rt_genid.  Now
instead of doing a small incremental change, we simply grab 32 new random bits.

3) The change in (2) got me thinking that part of the reason we used the Jenkins
hash in rt_genid was to ensure non-repetion of id's in a short time period
(which is important, so as not to inadvertently reuse route cache entries that
should be getting expired).  While extra randomness makes it harder for
attackers to guess the secret, it makes it possible to return to previously
guessed values as well (if they're lucky).  As such, I created a configurable
option, CONFIG_GENID_DUPCHECK.  With this option on, the low order 8 bits of the
genid are replaced with a rolling counter, that increments on each new genid.
This creates in effect, a 256 deep list of previously used genid values.  In
rt_drop we compare the genids for duplicates.  If we find that 2 genid values
have different indexes, but idential remaining bits, they are noted as a repeat
genid, and we call rt_cache_invalidate to generate a new genid and avoid the
duplication problem.


I've done some testing with this patch here, and it seems to work well.

Summary

A while back there was a discussion regarding the rt_secret_interval timer.
Given that we've had the ability to do emergency route cache rebuilds for awhile
now, based on a statistical analysis of the various hash chain lengths in the
cache, the use of the flush timer is somewhat redundant.  This patch removes the
rt_secret_interval sysctl, allowing us to rely solely on the statistical
analysis mechanism to determine the need for route cache flushes.


Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/net/netns/ipv4.h |    5 -
 kernel/sysctl_binary.c   |    1 
 net/ipv4/Kconfig         |   10 ++
 net/ipv4/route.c         |  164 ++++++++++++++++-------------------------------
 4 files changed, 69 insertions(+), 111 deletions(-)


diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index ae07fee..fb53b3c 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -55,9 +55,10 @@ struct netns_ipv4 {
 	int sysctl_rt_cache_rebuild_count;
 	int current_rt_cache_rebuild_count;
 
-	struct timer_list rt_secret_timer;
 	atomic_t rt_genid;
-
+#ifdef CONFIG_GENID_DUPCHECK
+	atomic_t rt_genidx;
+#endif
 #ifdef CONFIG_IP_MROUTE
 #ifndef CONFIG_IP_MROUTE_MULTIPLE_TABLES
 	struct mr_table		*mrt;
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 5903057..937d31d 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -224,7 +224,6 @@ static const struct bin_table bin_net_ipv4_route_table[] = {
 	{ CTL_INT,	NET_IPV4_ROUTE_MTU_EXPIRES,		"mtu_expires" },
 	{ CTL_INT,	NET_IPV4_ROUTE_MIN_PMTU,		"min_pmtu" },
 	{ CTL_INT,	NET_IPV4_ROUTE_MIN_ADVMSS,		"min_adv_mss" },
-	{ CTL_INT,	NET_IPV4_ROUTE_SECRET_INTERVAL,		"secret_interval" },
 	{}
 };
 
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 8e3a1fd..ad934a9 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -98,6 +98,16 @@ config IP_FIB_TRIE_STATS
 	  Keep track of statistics on structure of FIB TRIE table.
 	  Useful for testing and measuring TRIE performance.
 
+config GENID_DUPCHECK
+	bool "Duplicate generation id checking in the route cache"
+	---help---
+	  Add checks to the route cache to detect duplicate route cache
+	  generation id.  Duplicate id's can lead to inappropriate reuse of
+	  route caches entries, which can degrate performance.  This check
+	  adds an index count of 8 bits to the genid which can determine if
+	  the same genid is reused within the last 256 iterations.  Turn this
+	  on
+
 config IP_MULTIPLE_TABLES
 	bool "IP: policy routing"
 	depends on IP_ADVANCED_ROUTER
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a947428..57e51d4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,6 +112,10 @@
 #define RT_FL_TOS(oldflp) \
     ((u32)(oldflp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
 
+#ifdef CONFIG_GENID_DUPCHECK
+#define GENID_IDX_MASK 0xffffff00
+#endif
+
 #define IP_MAX_MTU	0xFFF0
 
 #define RT_GC_TIMEOUT (300*HZ)
@@ -129,7 +133,6 @@ static int ip_rt_gc_elasticity __read_mostly	= 8;
 static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
-static int ip_rt_secret_interval __read_mostly	= 10 * 60 * HZ;
 static int rt_chain_length_max __read_mostly	= 20;
 
 static struct delayed_work expires_work;
@@ -147,7 +150,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(struct dst_ops *ops);
-
+static void rt_cache_invalidate(struct net *net);
 
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
@@ -270,6 +273,34 @@ static inline int rt_genid(struct net *net)
 	return atomic_read(&net->ipv4.rt_genid);
 }
 
+#ifdef CONFIG_GENID_DUPCHECK
+static inline int rt_genid_dup(int genid1, int genid2)
+{
+	int idx1, idx2;
+	int rid1, rid2;
+
+	idx1 = genid1 & ~GENID_IDX_MASK;
+	idx2 = genid2 & ~GENID_IDX_MASK;
+
+	rid1 = genid1 & GENID_IDX_MASK;
+	rid2 = genid2 & GENID_IDX_MASK;
+
+	/*
+	 * Duplicate genids are ids in which
+	 * the idx value is different, but the
+	 * remainder of the genid is identical
+	 */
+	if ((idx1 != idx2) && (rid1 == rid2))
+		return 1;
+	return 0;
+}
+#else
+static inline int rt_genid_dup(genid1, int genid2)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
 	struct seq_net_private p;
@@ -615,6 +646,10 @@ static inline void rt_free(struct rtable *rt)
 
 static inline void rt_drop(struct rtable *rt)
 {
+	if (rt_genid_dup(rt->rt_genid, rt_genid(dev_net(rt->u.dst.dev)))) {
+		printk(KERN_WARNING "Duplicate route genid found!\n");
+		rt_cache_invalidate(dev_net(rt->u.dst.dev));
+	}
 	ip_rt_put(rt);
 	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
 }
@@ -888,17 +923,18 @@ static void rt_worker_func(struct work_struct *work)
 }
 
 /*
- * Pertubation of rt_genid by a small quantity [1..256]
- * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
- * many times (2^24) without giving recent rt_genid.
- * Jenkins hash is strong enough that litle changes of rt_genid are OK.
+ * invalidate the cache by making a new rt_genid.
  */
 static void rt_cache_invalidate(struct net *net)
 {
-	unsigned char shuffle;
+	unsigned int new;
 
-	get_random_bytes(&shuffle, sizeof(shuffle));
-	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
+	get_random_bytes(&new, sizeof(new));
+#ifdef CONFIG_GENID_DUPCHECK
+	new &= GENID_IDX_MASK;
+	new |= (atomic_inc_return(&net->ipv4.rt_genidx) & ~GENID_IDX_MASK);
+#endif
+	atomic_set(&net->ipv4.rt_genid, new);
 }
 
 /*
@@ -918,32 +954,11 @@ void rt_cache_flush_batch(void)
 	rt_do_flush(!in_softirq());
 }
 
-/*
- * We change rt_genid and let gc do the cleanup
- */
-static void rt_secret_rebuild(unsigned long __net)
-{
-	struct net *net = (struct net *)__net;
-	rt_cache_invalidate(net);
-	mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interval);
-}
-
-static void rt_secret_rebuild_oneshot(struct net *net)
-{
-	del_timer_sync(&net->ipv4.rt_secret_timer);
-	rt_cache_invalidate(net);
-	if (ip_rt_secret_interval)
-		mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interval);
-}
-
 static void rt_emergency_hash_rebuild(struct net *net)
 {
-	if (net_ratelimit()) {
+	if (net_ratelimit())
 		printk(KERN_WARNING "Route hash chain too long!\n");
-		printk(KERN_WARNING "Adjust your secret_interval!\n");
-	}
-
-	rt_secret_rebuild_oneshot(net);
+	rt_cache_invalidate(net);
 }
 
 /*
@@ -3101,48 +3116,6 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 	return -EINVAL;
 }
 
-static void rt_secret_reschedule(int old)
-{
-	struct net *net;
-	int new = ip_rt_secret_interval;
-	int diff = new - old;
-
-	if (!diff)
-		return;
-
-	rtnl_lock();
-	for_each_net(net) {
-		int deleted = del_timer_sync(&net->ipv4.rt_secret_timer);
-		long time;
-
-		if (!new)
-			continue;
-
-		if (deleted) {
-			time = net->ipv4.rt_secret_timer.expires - jiffies;
-
-			if (time <= 0 || (time += diff) <= 0)
-				time = 0;
-		} else
-			time = new;
-
-		mod_timer(&net->ipv4.rt_secret_timer, jiffies + time);
-	}
-	rtnl_unlock();
-}
-
-static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
-					  void __user *buffer, size_t *lenp,
-					  loff_t *ppos)
-{
-	int old = ip_rt_secret_interval;
-	int ret = proc_dointvec_jiffies(ctl, write, buffer, lenp, ppos);
-
-	rt_secret_reschedule(old);
-
-	return ret;
-}
-
 static ctl_table ipv4_route_table[] = {
 	{
 		.procname	= "gc_thresh",
@@ -3251,13 +3224,6 @@ static ctl_table ipv4_route_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{
-		.procname	= "secret_interval",
-		.data		= &ip_rt_secret_interval,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= ipv4_sysctl_rt_secret_interval,
-	},
 	{ }
 };
 
@@ -3336,34 +3302,18 @@ static __net_initdata struct pernet_operations sysctl_route_ops = {
 };
 #endif
 
-
-static __net_init int rt_secret_timer_init(struct net *net)
+static __net_init int rt_genid_init(struct net *net)
 {
-	atomic_set(&net->ipv4.rt_genid,
-			(int) ((num_physpages ^ (num_physpages>>8)) ^
-			(jiffies ^ (jiffies >> 7))));
-
-	net->ipv4.rt_secret_timer.function = rt_secret_rebuild;
-	net->ipv4.rt_secret_timer.data = (unsigned long)net;
-	init_timer_deferrable(&net->ipv4.rt_secret_timer);
-
-	if (ip_rt_secret_interval) {
-		net->ipv4.rt_secret_timer.expires =
-			jiffies + net_random() % ip_rt_secret_interval +
-			ip_rt_secret_interval;
-		add_timer(&net->ipv4.rt_secret_timer);
-	}
+	/*
+	 * This just serves to start off each new net namespace
+	 * with a non-zero rt_genid value, making it harder to guess
+	 */
+	rt_cache_invalidate(net);
 	return 0;
 }
 
-static __net_exit void rt_secret_timer_exit(struct net *net)
-{
-	del_timer_sync(&net->ipv4.rt_secret_timer);
-}
-
-static __net_initdata struct pernet_operations rt_secret_timer_ops = {
-	.init = rt_secret_timer_init,
-	.exit = rt_secret_timer_exit,
+static __net_initdata struct pernet_operations rt_genid_ops = {
+	.init = rt_genid_init,
 };
 
 
@@ -3424,9 +3374,6 @@ int __init ip_rt_init(void)
 	schedule_delayed_work(&expires_work,
 		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
 
-	if (register_pernet_subsys(&rt_secret_timer_ops))
-		printk(KERN_ERR "Unable to setup rt_secret_timer\n");
-
 	if (ip_rt_proc_init())
 		printk(KERN_ERR "Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
@@ -3438,6 +3385,7 @@ int __init ip_rt_init(void)
 #ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&sysctl_route_ops);
 #endif
+	register_pernet_subsys(&rt_genid_ops);
 	return rc;
 }
 
