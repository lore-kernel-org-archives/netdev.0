From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 7/9] sysctl: ipv4: share ipv4_net_table between nets
Date: Fri, 25 Feb 2011 20:52:39 +0200
Message-ID: <1298659961-23863-8-git-send-email-lucian.grijincu@gmail.com>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>, netdev@vger.kernel.org,
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/sysctl_net_ipv4.c |   53 +++++++------------------------------------
 1 files changed, 9 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1a45665..6fd3279 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -636,49 +636,49 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_icmp_echo_ignore_all,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{
 		.procname	= "icmp_echo_ignore_broadcasts",
 		.data		= &init_net.ipv4.sysctl_icmp_echo_ignore_broadcasts,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{
 		.procname	= "icmp_ignore_bogus_error_responses",
 		.data		= &init_net.ipv4.sysctl_icmp_ignore_bogus_error_responses,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{
 		.procname	= "icmp_errors_use_inbound_ifaddr",
 		.data		= &init_net.ipv4.sysctl_icmp_errors_use_inbound_ifaddr,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{
 		.procname	= "icmp_ratelimit",
 		.data		= &init_net.ipv4.sysctl_icmp_ratelimit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_ms_jiffies,
+		.proc_handler	= (proc_handler *) netns_proc_dointvec_ms_jiffies,
 	},
 	{
 		.procname	= "icmp_ratemask",
 		.data		= &init_net.ipv4.sysctl_icmp_ratemask,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{
 		.procname	= "rt_cache_rebuild_count",
 		.data		= &init_net.ipv4.sysctl_rt_cache_rebuild_count,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{ }
 };
@@ -692,53 +692,18 @@ EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
 
 static __net_init int ipv4_sysctl_init_net(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = ipv4_net_table;
-	if (!net_eq(net, &init_net)) {
-		table = kmemdup(table, sizeof(ipv4_net_table), GFP_KERNEL);
-		if (table == NULL)
-			goto err_alloc;
-
-		table[0].data =
-			&net->ipv4.sysctl_icmp_echo_ignore_all;
-		table[1].data =
-			&net->ipv4.sysctl_icmp_echo_ignore_broadcasts;
-		table[2].data =
-			&net->ipv4.sysctl_icmp_ignore_bogus_error_responses;
-		table[3].data =
-			&net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr;
-		table[4].data =
-			&net->ipv4.sysctl_icmp_ratelimit;
-		table[5].data =
-			&net->ipv4.sysctl_icmp_ratemask;
-		table[6].data =
-			&net->ipv4.sysctl_rt_cache_rebuild_count;
-	}
-
 	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
 
 	net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
-			net_ipv4_ctl_path, table);
+			net_ipv4_ctl_path, ipv4_net_table);
 	if (net->ipv4.ipv4_hdr == NULL)
-		goto err_reg;
-
+		return -ENOMEM;
 	return 0;
-
-err_reg:
-	if (!net_eq(net, &init_net))
-		kfree(table);
-err_alloc:
-	return -ENOMEM;
 }
 
 static __net_exit void ipv4_sysctl_exit_net(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = net->ipv4.ipv4_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv4.ipv4_hdr);
-	kfree(table);
 }
 
 static __net_initdata struct pernet_operations ipv4_sysctl_ops = {
-- 
1.7.4.rc1.7.g2cf08.dirty
