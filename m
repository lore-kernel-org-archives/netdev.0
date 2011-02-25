From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 9/9] sysctl: ipv6: share ip6_ctl_table, ipv6_icmp_table and ipv6_route_table between nets
Date: Fri, 25 Feb 2011 20:52:41 +0200
Message-ID: <1298659961-23863-10-git-send-email-lucian.grijincu@gmail.com>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>, netdev@vger.kernel.org,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36182 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932502Ab1BYSxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 13:53:30 -0500
In-Reply-To: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch includes another implementation of the patch from [1]. This
patch will not apply cleanly if that one has been applied.

[1] http://thread.gmane.org/gmane.linux.network/187273

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/ipv6.h         |    6 +---
 net/ipv6/icmp.c            |   17 +-----------
 net/ipv6/route.c           |   54 +++++++++++----------------------------
 net/ipv6/sysctl_net_ipv6.c |   61 ++++++--------------------------------------
 4 files changed, 27 insertions(+), 111 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 96e50e0..1526ed6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -652,11 +652,9 @@ static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
 #endif
 
 #ifdef CONFIG_SYSCTL
-extern ctl_table ipv6_route_table_template[];
-extern ctl_table ipv6_icmp_table_template[];
+extern ctl_table ipv6_route_table[];
+extern ctl_table ipv6_icmp_table[];
 
-extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
-extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
 extern int ipv6_sysctl_register(void);
 extern void ipv6_sysctl_unregister(void);
 extern int ipv6_static_sysctl_register(void);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 03e62f9..924cb36 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -938,29 +938,16 @@ int icmpv6_err_convert(u8 type, u8 code, int *err)
 EXPORT_SYMBOL(icmpv6_err_convert);
 
 #ifdef CONFIG_SYSCTL
-ctl_table ipv6_icmp_table_template[] = {
+ctl_table ipv6_icmp_table[] = {
 	{
 		.procname	= "ratelimit",
 		.data		= &init_net.ipv6.sysctl.icmpv6_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_ms_jiffies,
+		.proc_handler	= (proc_handler *) netns_proc_dointvec_ms_jiffies,
 	},
 	{ },
 };
 
-struct ctl_table * __net_init ipv6_icmp_sysctl_init(struct net *net)
-{
-	struct ctl_table *table;
-
-	table = kmemdup(ipv6_icmp_table_template,
-			sizeof(ipv6_icmp_table_template),
-			GFP_KERNEL);
-
-	if (table)
-		table[0].data = &net->ipv6.sysctl.icmpv6_time;
-
-	return table;
-}
 #endif
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a998db6..29e05ca 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2553,11 +2553,11 @@ static const struct file_operations rt6_stats_seq_fops = {
 
 #ifdef CONFIG_SYSCTL
 
-static
-int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
-			      void __user *buffer, size_t *lenp, loff_t *ppos)
+static int netns_ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
+					   void __user *buffer, size_t *lenp,
+					   loff_t *ppos, void *cookie)
 {
-	struct net *net = current->nsproxy->net_ns;
+	struct net *net = (struct net *) cookie;
 	int delay = net->ipv6.sysctl.flush_delay;
 	if (write) {
 		proc_dointvec(ctl, write, buffer, lenp, ppos);
@@ -2567,103 +2567,79 @@ int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
 		return -EINVAL;
 }
 
-ctl_table ipv6_route_table_template[] = {
+ctl_table ipv6_route_table[] = {
 	{
 		.procname	=	"flush",
 		.data		=	&init_net.ipv6.sysctl.flush_delay,
 		.maxlen		=	sizeof(int),
 		.mode		=	0200,
-		.proc_handler	=	ipv6_sysctl_rtcache_flush
+		.proc_handler	=	(proc_handler *) netns_ipv6_sysctl_rtcache_flush
 	},
 	{
 		.procname	=	"gc_thresh",
 		.data		=	&ip6_dst_ops_template.gc_thresh,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec,
 	},
 	{
 		.procname	=	"max_size",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec,
 	},
 	{
 		.procname	=	"gc_min_interval",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec_jiffies,
 	},
 	{
 		.procname	=	"gc_timeout",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_timeout,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec_jiffies,
 	},
 	{
 		.procname	=	"gc_interval",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec_jiffies,
 	},
 	{
 		.procname	=	"gc_elasticity",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_elasticity,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec,
 	},
 	{
 		.procname	=	"mtu_expires",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_mtu_expires,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec_jiffies,
 	},
 	{
 		.procname	=	"min_adv_mss",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_min_advmss,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec,
 	},
 	{
 		.procname	=	"gc_min_interval_ms",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_ms_jiffies,
+		.proc_handler	=	(proc_handler *) netns_proc_dointvec_ms_jiffies,
 	},
 	{ }
 };
-
-struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
-{
-	struct ctl_table *table;
-
-	table = kmemdup(ipv6_route_table_template,
-			sizeof(ipv6_route_table_template),
-			GFP_KERNEL);
-
-	if (table) {
-		table[0].data = &net->ipv6.sysctl.flush_delay;
-		table[1].data = &net->ipv6.ip6_dst_ops.gc_thresh;
-		table[2].data = &net->ipv6.sysctl.ip6_rt_max_size;
-		table[3].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
-		table[4].data = &net->ipv6.sysctl.ip6_rt_gc_timeout;
-		table[5].data = &net->ipv6.sysctl.ip6_rt_gc_interval;
-		table[6].data = &net->ipv6.sysctl.ip6_rt_gc_elasticity;
-		table[7].data = &net->ipv6.sysctl.ip6_rt_mtu_expires;
-		table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
-		table[9].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
-	}
-
-	return table;
-}
 #endif
 
 static int __net_init ip6_route_net_init(struct net *net)
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7cb65ef..cd15483 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -17,25 +17,25 @@
 
 static struct ctl_table empty[1];
 
-static ctl_table ipv6_table_template[] = {
+static ctl_table ipv6_table[] = {
 	{
 		.procname	= "route",
 		.maxlen		= 0,
 		.mode		= 0555,
-		.child		= ipv6_route_table_template
+		.child		= ipv6_route_table
 	},
 	{
 		.procname	= "icmp",
 		.maxlen		= 0,
 		.mode		= 0555,
-		.child		= ipv6_icmp_table_template
+		.child		= ipv6_icmp_table
 	},
 	{
 		.procname	= "bindv6only",
 		.data		= &init_net.ipv6.sysctl.bindv6only,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{
 		.procname	= "neigh",
@@ -66,62 +66,17 @@ EXPORT_SYMBOL_GPL(net_ipv6_ctl_path);
 
 static int __net_init ipv6_sysctl_net_init(struct net *net)
 {
-	struct ctl_table *ipv6_table;
-	struct ctl_table *ipv6_route_table;
-	struct ctl_table *ipv6_icmp_table;
-	int err;
-
-	err = -ENOMEM;
-	ipv6_table = kmemdup(ipv6_table_template, sizeof(ipv6_table_template),
-			     GFP_KERNEL);
-	if (!ipv6_table)
-		goto out;
-
-	ipv6_route_table = ipv6_route_sysctl_init(net);
-	if (!ipv6_route_table)
-		goto out_ipv6_table;
-	ipv6_table[0].child = ipv6_route_table;
-
-	ipv6_icmp_table = ipv6_icmp_sysctl_init(net);
-	if (!ipv6_icmp_table)
-		goto out_ipv6_route_table;
-	ipv6_table[1].child = ipv6_icmp_table;
-
-	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;
-
-	net->ipv6.sysctl.table = register_net_sysctl_table(net, net_ipv6_ctl_path,
-							   ipv6_table);
+	net->ipv6.sysctl.table = register_net_sysctl_table(net,
+				   net_ipv6_ctl_path, ipv6_table);
 	if (!net->ipv6.sysctl.table)
-		goto out_ipv6_icmp_table;
-
-	err = 0;
-out:
-	return err;
+		return -ENOMEM;
 
-out_ipv6_icmp_table:
-	kfree(ipv6_icmp_table);
-out_ipv6_route_table:
-	kfree(ipv6_route_table);
-out_ipv6_table:
-	kfree(ipv6_table);
-	goto out;
+	return 0;
 }
 
 static void __net_exit ipv6_sysctl_net_exit(struct net *net)
 {
-	struct ctl_table *ipv6_table;
-	struct ctl_table *ipv6_route_table;
-	struct ctl_table *ipv6_icmp_table;
-
-	ipv6_table = net->ipv6.sysctl.table->ctl_table_arg;
-	ipv6_route_table = ipv6_table[0].child;
-	ipv6_icmp_table = ipv6_table[1].child;
-
 	unregister_net_sysctl_table(net->ipv6.sysctl.table);
-
-	kfree(ipv6_table);
-	kfree(ipv6_route_table);
-	kfree(ipv6_icmp_table);
 }
 
 static struct pernet_operations ipv6_sysctl_net_ops = {
-- 
1.7.4.rc1.7.g2cf08.dirty

