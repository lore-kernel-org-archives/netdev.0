From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 10/24] sysctl: cookie: share ip6_ctl_table, ipv6_icmp_table and ipv6_route_table between nets
Date: Sat,  2 Apr 2011 04:53:24 +0200
Message-ID: <ab42da50fb1cdb10a37af77905c65ee2848fd06d.1301711868.git.lucian.grijincu__13237.3402281248$1301713135$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32917 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab1DBCyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:33 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/ipv6.h         |    6 +---
 net/ipv6/icmp.c            |   17 +-----------
 net/ipv6/route.c           |   58 +++++++++++------------------------------
 net/ipv6/sysctl_net_ipv6.c |   61 ++++++--------------------------------------
 4 files changed, 28 insertions(+), 114 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 34200f9..bd73439 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -656,11 +656,9 @@ static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
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
index 83cb4f9..26cdb9b 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -954,29 +954,16 @@ int icmpv6_err_convert(u8 type, u8 code, int *err)
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
+		.proc_handler	= netns_proc_dointvec_ms_jiffies,
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
index 48ec0b7..a110204 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2592,120 +2592,94 @@ static const struct file_operations rt6_stats_seq_fops = {
 
 #ifdef CONFIG_SYSCTL
 
-static
-int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write, void __user *buffer,
-			      size_t *lenp, loff_t *ppos, void *cookie)
+static int netns_ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
+					   void __user *buffer, size_t *lenp,
+					   loff_t *ppos, void *cookie)
 {
-	struct net *net;
-	int delay;
+	struct net *net = (struct net *) cookie;
+	int delay = net->ipv6.sysctl.flush_delay;
 	if (!write)
 		return -EINVAL;
 
-	net = (struct net *)ctl->extra1;
-	delay = net->ipv6.sysctl.flush_delay;
 	proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 	fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay, net);
 	return 0;
 }
 
-ctl_table ipv6_route_table_template[] = {
+ctl_table ipv6_route_table[] = {
 	{
 		.procname	=	"flush",
 		.data		=	&init_net.ipv6.sysctl.flush_delay,
 		.maxlen		=	sizeof(int),
 		.mode		=	0200,
-		.proc_handler	=	ipv6_sysctl_rtcache_flush
+		.proc_handler	=	netns_ipv6_sysctl_rtcache_flush,
 	},
 	{
 		.procname	=	"gc_thresh",
 		.data		=	&ip6_dst_ops_template.gc_thresh,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	netns_proc_dointvec,
 	},
 	{
 		.procname	=	"max_size",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	netns_proc_dointvec,
 	},
 	{
 		.procname	=	"gc_min_interval",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	netns_proc_dointvec_jiffies,
 	},
 	{
 		.procname	=	"gc_timeout",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_timeout,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	netns_proc_dointvec_jiffies,
 	},
 	{
 		.procname	=	"gc_interval",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	netns_proc_dointvec_jiffies,
 	},
 	{
 		.procname	=	"gc_elasticity",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_elasticity,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	netns_proc_dointvec,
 	},
 	{
 		.procname	=	"mtu_expires",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_mtu_expires,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	netns_proc_dointvec_jiffies,
 	},
 	{
 		.procname	=	"min_adv_mss",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_min_advmss,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	netns_proc_dointvec,
 	},
 	{
 		.procname	=	"gc_min_interval_ms",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_ms_jiffies,
+		.proc_handler	=	netns_proc_dointvec_ms_jiffies,
 	},
 	{ }
 };
 
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
-		table[0].extra1 = net;
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
index 6dcf5e7..1b6f6fd 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -27,25 +27,25 @@ static ctl_table ipv6_static_skeleton[] = {
 	{ }
 };
 
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
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{ }
 };
@@ -70,62 +70,17 @@ EXPORT_SYMBOL_GPL(net_ipv6_ctl_path);
 
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
1.7.5.rc0

