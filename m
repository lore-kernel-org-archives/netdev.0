From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] ipv4: remove ip_rt_secret timer
Date: Thu, 6 May 2010 13:16:39 -0400
Message-ID: <20100506171639.GA5063@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:32951 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab0EFRQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 13:16:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A while back there was a discussion regarding the rt_secret_interval timer.
Given that we've had the ability to do emergency route cache rebuilds for awhile
now, based on a statistical analysis of the various hash chain lengths in the
cache, the use of the flush timer is somewhat redundant.  This patch removes the
rt_secret_interval sysctl, allowing us to rely solely on the statistical
analysis mechanism to determine the need for route cache flushes.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/net/netns/ipv4.h |    1 
 net/ipv4/route.c         |  108 -----------------------------------------------
 2 files changed, 2 insertions(+), 107 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index ae07fee..d68c3f1 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -55,7 +55,6 @@ struct netns_ipv4 {
 	int sysctl_rt_cache_rebuild_count;
 	int current_rt_cache_rebuild_count;
 
-	struct timer_list rt_secret_timer;
 	atomic_t rt_genid;
 
 #ifdef CONFIG_IP_MROUTE
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a947428..ffd3da1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -129,7 +129,6 @@ static int ip_rt_gc_elasticity __read_mostly	= 8;
 static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
-static int ip_rt_secret_interval __read_mostly	= 10 * 60 * HZ;
 static int rt_chain_length_max __read_mostly	= 20;
 
 static struct delayed_work expires_work;
@@ -918,32 +917,11 @@ void rt_cache_flush_batch(void)
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
@@ -3101,48 +3079,6 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
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
@@ -3251,13 +3187,6 @@ static ctl_table ipv4_route_table[] = {
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
 
@@ -3337,36 +3266,6 @@ static __net_initdata struct pernet_operations sysctl_route_ops = {
 #endif
 
 
-static __net_init int rt_secret_timer_init(struct net *net)
-{
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
-	return 0;
-}
-
-static __net_exit void rt_secret_timer_exit(struct net *net)
-{
-	del_timer_sync(&net->ipv4.rt_secret_timer);
-}
-
-static __net_initdata struct pernet_operations rt_secret_timer_ops = {
-	.init = rt_secret_timer_init,
-	.exit = rt_secret_timer_exit,
-};
-
-
 #ifdef CONFIG_NET_CLS_ROUTE
 struct ip_rt_acct __percpu *ip_rt_acct __read_mostly;
 #endif /* CONFIG_NET_CLS_ROUTE */
@@ -3424,9 +3323,6 @@ int __init ip_rt_init(void)
 	schedule_delayed_work(&expires_work,
 		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
 
-	if (register_pernet_subsys(&rt_secret_timer_ops))
-		printk(KERN_ERR "Unable to setup rt_secret_timer\n");
-
 	if (ip_rt_proc_init())
 		printk(KERN_ERR "Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
