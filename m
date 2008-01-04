From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 8/9][NETNS][IPV6] make sysctls route per namespace
Date: Fri, 04 Jan 2008 12:12:34 +0100
Message-ID: <20080104111446.121740535@localhost.localdomain>
References: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:54795 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbYADLXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:23:40 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m04BNdGT477978
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:39 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BNdKR5058592
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:39 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BNMBX019204
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:22 GMT
Content-Disposition: inline; filename=sysctl/move-sysctl-route-to-netns.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the sysctl concerning the routes are moved to the network namespace
structure. A helper function is called to initialize the variables.

Because the ipv6 protocol is not yet per namespace, the variables are
accessed relatively from the network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ip6_route.h    |    2 -
 include/net/netns/ipv6.h   |    8 ++++++
 net/ipv6/ip6_fib.c         |   14 ++++++----
 net/ipv6/route.c           |   58 ++++++++++++++++++++++-----------------------
 net/ipv6/sysctl_net_ipv6.c |    9 ++++++
 5 files changed, 55 insertions(+), 36 deletions(-)

Index: net-2.6.25/include/net/netns/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/netns/ipv6.h
+++ net-2.6.25/include/net/netns/ipv6.h
@@ -13,6 +13,14 @@ struct netns_sysctl_ipv6 {
 	struct ctl_table_header *table;
    	struct inet_frags_ctl frags;
  	int bindv6only;
+  	int flush_delay;
+  	int ip6_rt_max_size;
+  	int ip6_rt_gc_min_interval;
+  	int ip6_rt_gc_timeout;
+  	int ip6_rt_gc_interval;
+  	int ip6_rt_gc_elasticity;
+  	int ip6_rt_mtu_expires;
+  	int ip6_rt_min_advmss;
 };
 
 struct netns_ipv6 {
Index: net-2.6.25/net/ipv6/route.c
===================================================================
--- net-2.6.25.orig/net/ipv6/route.c
+++ net-2.6.25/net/ipv6/route.c
@@ -73,14 +73,6 @@
 
 #define CLONE_OFFLINK_ROUTE 0
 
-static int ip6_rt_max_size = 4096;
-static int ip6_rt_gc_min_interval = HZ / 2;
-static int ip6_rt_gc_timeout = 60*HZ;
-int ip6_rt_gc_interval = 30*HZ;
-static int ip6_rt_gc_elasticity = 9;
-static int ip6_rt_mtu_expires = 10*60*HZ;
-static int ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
-
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cookie);
 static struct dst_entry *ip6_negative_advice(struct dst_entry *);
@@ -889,8 +881,8 @@ static inline unsigned int ipv6_advmss(u
 {
 	mtu -= sizeof(struct ipv6hdr) + sizeof(struct tcphdr);
 
-	if (mtu < ip6_rt_min_advmss)
-		mtu = ip6_rt_min_advmss;
+	if (mtu < init_net.ipv6.sysctl.ip6_rt_min_advmss)
+		mtu = init_net.ipv6.sysctl.ip6_rt_min_advmss;
 
 	/*
 	 * Maximal non-jumbo IPv6 payload is IPV6_MAXPLEN and
@@ -990,19 +982,19 @@ static int ip6_dst_gc(void)
 	static unsigned long last_gc;
 	unsigned long now = jiffies;
 
-	if (time_after(last_gc + ip6_rt_gc_min_interval, now) &&
-	    atomic_read(&ip6_dst_ops.entries) <= ip6_rt_max_size)
+	if (time_after(last_gc + init_net.ipv6.sysctl.ip6_rt_gc_min_interval, now) &&
+	    atomic_read(&ip6_dst_ops.entries) <= init_net.ipv6.sysctl.ip6_rt_max_size)
 		goto out;
 
 	expire++;
 	fib6_run_gc(expire);
 	last_gc = now;
 	if (atomic_read(&ip6_dst_ops.entries) < ip6_dst_ops.gc_thresh)
-		expire = ip6_rt_gc_timeout>>1;
+		expire = init_net.ipv6.sysctl.ip6_rt_gc_timeout>>1;
 
 out:
-	expire -= expire>>ip6_rt_gc_elasticity;
-	return (atomic_read(&ip6_dst_ops.entries) > ip6_rt_max_size);
+	expire -= expire>>init_net.ipv6.sysctl.ip6_rt_gc_elasticity;
+	return (atomic_read(&ip6_dst_ops.entries) > init_net.ipv6.sysctl.ip6_rt_max_size);
 }
 
 /* Clean host part of a prefix. Not necessary in radix tree,
@@ -1508,7 +1500,7 @@ void rt6_pmtu_discovery(struct in6_addr 
 		rt->u.dst.metrics[RTAX_MTU-1] = pmtu;
 		if (allfrag)
 			rt->u.dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
-		dst_set_expires(&rt->u.dst, ip6_rt_mtu_expires);
+		dst_set_expires(&rt->u.dst, init_net.ipv6.sysctl.ip6_rt_mtu_expires);
 		rt->rt6i_flags |= RTF_MODIFIED|RTF_EXPIRES;
 		goto out;
 	}
@@ -1534,7 +1526,7 @@ void rt6_pmtu_discovery(struct in6_addr 
 		 * which is 10 mins. After 10 mins the decreased pmtu is expired
 		 * and detecting PMTU increase will be automatically happened.
 		 */
-		dst_set_expires(&nrt->u.dst, ip6_rt_mtu_expires);
+		dst_set_expires(&nrt->u.dst, init_net.ipv6.sysctl.ip6_rt_mtu_expires);
 		nrt->rt6i_flags |= RTF_DYNAMIC|RTF_EXPIRES;
 
 		ip6_ins_rt(nrt);
@@ -2390,15 +2382,14 @@ static inline void ipv6_route_proc_fini(
 
 #ifdef CONFIG_SYSCTL
 
-static int flush_delay;
-
 static
 int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write, struct file * filp,
 			      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
+	int delay = init_net.ipv6.sysctl.flush_delay;
 	if (write) {
 		proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
-		fib6_run_gc(flush_delay <= 0 ? ~0UL : (unsigned long)flush_delay);
+		fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay);
 		return 0;
 	} else
 		return -EINVAL;
@@ -2407,7 +2398,7 @@ int ipv6_sysctl_rtcache_flush(ctl_table 
 ctl_table ipv6_route_table_template[] = {
 	{
 		.procname	=	"flush",
-		.data		=	&flush_delay,
+		.data		=	&init_net.ipv6.sysctl.flush_delay,
 		.maxlen		=	sizeof(int),
 		.mode		=	0200,
 		.proc_handler	=	&ipv6_sysctl_rtcache_flush
@@ -2423,7 +2414,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_MAX_SIZE,
 		.procname	=	"max_size",
-		.data		=	&ip6_rt_max_size,
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec,
@@ -2431,7 +2422,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
 		.procname	=	"gc_min_interval",
-		.data		=	&ip6_rt_gc_min_interval,
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec_jiffies,
@@ -2440,7 +2431,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_TIMEOUT,
 		.procname	=	"gc_timeout",
-		.data		=	&ip6_rt_gc_timeout,
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_timeout,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec_jiffies,
@@ -2449,7 +2440,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_INTERVAL,
 		.procname	=	"gc_interval",
-		.data		=	&ip6_rt_gc_interval,
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec_jiffies,
@@ -2458,7 +2449,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_ELASTICITY,
 		.procname	=	"gc_elasticity",
-		.data		=	&ip6_rt_gc_elasticity,
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_elasticity,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec_jiffies,
@@ -2467,7 +2458,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_MTU_EXPIRES,
 		.procname	=	"mtu_expires",
-		.data		=	&ip6_rt_mtu_expires,
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_mtu_expires,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec_jiffies,
@@ -2476,7 +2467,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_MIN_ADVMSS,
 		.procname	=	"min_adv_mss",
-		.data		=	&ip6_rt_min_advmss,
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_min_advmss,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec_jiffies,
@@ -2485,7 +2476,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL_MS,
 		.procname	=	"gc_min_interval_ms",
-		.data		=	&ip6_rt_gc_min_interval,
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec_ms_jiffies,
@@ -2498,6 +2489,15 @@ struct ctl_table *ipv6_route_sysctl_init
 {
 	struct ctl_table *table;
 
+	net->ipv6.sysctl.flush_delay = 0;
+	net->ipv6.sysctl.ip6_rt_max_size = 4096;
+	net->ipv6.sysctl.ip6_rt_gc_min_interval = HZ / 2;
+	net->ipv6.sysctl.ip6_rt_gc_timeout = 60*HZ;
+	net->ipv6.sysctl.ip6_rt_gc_interval = 30*HZ;
+	net->ipv6.sysctl.ip6_rt_gc_elasticity = 9;
+	net->ipv6.sysctl.ip6_rt_mtu_expires = 10*60*HZ;
+	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
+
    	table = kmemdup(ipv6_route_table_template,
 			sizeof(ipv6_route_table_template),
 			GFP_KERNEL);
Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -113,7 +113,16 @@ static int ipv6_sysctl_net_init(struct n
    	if (!ipv6_icmp_table)
    		goto out_ipv6_route_table;
 
+   	ipv6_route_table[0].data = &net->ipv6.sysctl.flush_delay;
+   	ipv6_route_table[2].data = &net->ipv6.sysctl.ip6_rt_max_size;
+   	ipv6_route_table[3].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
+   	ipv6_route_table[4].data = &net->ipv6.sysctl.ip6_rt_gc_timeout;
+   	ipv6_route_table[5].data = &net->ipv6.sysctl.ip6_rt_gc_interval;
+   	ipv6_route_table[6].data = &net->ipv6.sysctl.ip6_rt_gc_elasticity;
+   	ipv6_route_table[7].data = &net->ipv6.sysctl.ip6_rt_mtu_expires;
+   	ipv6_route_table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
    	ipv6_table[0].child = ipv6_route_table;
+
    	ipv6_table[1].child = ipv6_icmp_table;
 
   	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;
Index: net-2.6.25/include/net/ip6_route.h
===================================================================
--- net-2.6.25.orig/include/net/ip6_route.h
+++ net-2.6.25/include/net/ip6_route.h
@@ -43,8 +43,6 @@ extern struct rt6_info	ip6_prohibit_entr
 extern struct rt6_info	ip6_blk_hole_entry;
 #endif
 
-extern int ip6_rt_gc_interval;
-
 extern void			ip6_route_input(struct sk_buff *skb);
 
 extern struct dst_entry *	ip6_route_output(struct sock *sk,
Index: net-2.6.25/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ip6_fib.c
+++ net-2.6.25/net/ipv6/ip6_fib.c
@@ -681,13 +681,15 @@ static __inline__ void fib6_start_gc(str
 {
 	if (ip6_fib_timer.expires == 0 &&
 	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
-		mod_timer(&ip6_fib_timer, jiffies + ip6_rt_gc_interval);
+		mod_timer(&ip6_fib_timer, jiffies +
+			  init_net.ipv6.sysctl.ip6_rt_gc_interval);
 }
 
 void fib6_force_start_gc(void)
 {
 	if (ip6_fib_timer.expires == 0)
-		mod_timer(&ip6_fib_timer, jiffies + ip6_rt_gc_interval);
+		mod_timer(&ip6_fib_timer, jiffies +
+			  init_net.ipv6.sysctl.ip6_rt_gc_interval);
 }
 
 /*
@@ -1447,7 +1449,8 @@ void fib6_run_gc(unsigned long dummy)
 {
 	if (dummy != ~0UL) {
 		spin_lock_bh(&fib6_gc_lock);
-		gc_args.timeout = dummy ? (int)dummy : ip6_rt_gc_interval;
+		gc_args.timeout = dummy ? (int)dummy :
+			init_net.ipv6.sysctl.ip6_rt_gc_interval;
 	} else {
 		local_bh_disable();
 		if (!spin_trylock(&fib6_gc_lock)) {
@@ -1455,7 +1458,7 @@ void fib6_run_gc(unsigned long dummy)
 			local_bh_enable();
 			return;
 		}
-		gc_args.timeout = ip6_rt_gc_interval;
+		gc_args.timeout = init_net.ipv6.sysctl.ip6_rt_gc_interval;
 	}
 	gc_args.more = 0;
 
@@ -1463,7 +1466,8 @@ void fib6_run_gc(unsigned long dummy)
 	fib6_clean_all(fib6_age, 0, NULL);
 
 	if (gc_args.more)
-		mod_timer(&ip6_fib_timer, jiffies + ip6_rt_gc_interval);
+		mod_timer(&ip6_fib_timer, jiffies +
+			  init_net.ipv6.sysctl.ip6_rt_gc_interval);
 	else {
 		del_timer(&ip6_fib_timer);
 		ip6_fib_timer.expires = 0;

-- 
