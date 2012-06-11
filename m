From: pablo@netfilter.org
Subject: [PATCH 11/25] netfilter: nf_ct_ipv4: add namespace support
Date: Mon, 11 Jun 2012 16:43:47 +0200
Message-ID: <1339425841-24171-12-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch adds namespace support for IPv4 protocol tracker.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  123 ++++++++++++++++--------
 1 file changed, 85 insertions(+), 38 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 0c0fb90..5c66203 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -207,35 +207,30 @@ static int log_invalid_proto_max = 255;
 static ctl_table ip_ct_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_max",
-		.data		= &nf_conntrack_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "ip_conntrack_count",
-		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "ip_conntrack_buckets",
-		.data		= &init_net.ct.htable_size,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0444,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "ip_conntrack_checksum",
-		.data		= &init_net.ct.sysctl_checksum,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "ip_conntrack_log_invalid",
-		.data		= &init_net.ct.sysctl_log_invalid,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
@@ -351,6 +346,25 @@ static struct nf_sockopt_ops so_getorigdst = {
 	.owner		= THIS_MODULE,
 };
 
+static int ipv4_init_net(struct net *net)
+{
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	struct nf_ip_net *in = &net->ct.nf_ct_proto;
+	in->ctl_table = kmemdup(ip_ct_sysctl_table,
+				sizeof(ip_ct_sysctl_table),
+				GFP_KERNEL);
+	if (!in->ctl_table)
+		return -ENOMEM;
+
+	in->ctl_table[0].data = &nf_conntrack_max;
+	in->ctl_table[1].data = &net->ct.count;
+	in->ctl_table[2].data = &net->ct.htable_size;
+	in->ctl_table[3].data = &net->ct.sysctl_checksum;
+	in->ctl_table[4].data = &net->ct.sysctl_log_invalid;
+#endif
+	return 0;
+}
+
 struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.l3proto	 = PF_INET,
 	.name		 = "ipv4",
@@ -368,6 +382,7 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.ctl_table_path  = "net/ipv4/netfilter",
 	.ctl_table	 = ip_ct_sysctl_table,
 #endif
+	.init_net	 = ipv4_init_net,
 	.me		 = THIS_MODULE,
 };
 
@@ -378,6 +393,65 @@ MODULE_ALIAS("nf_conntrack-" __stringify(AF_INET));
 MODULE_ALIAS("ip_conntrack");
 MODULE_LICENSE("GPL");
 
+static int ipv4_net_init(struct net *net)
+{
+	int ret = 0;
+
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_tcp4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_tcp4 :protocol register failed\n");
+		goto out_tcp;
+	}
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_udp4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_udp4 :protocol register failed\n");
+		goto out_udp;
+	}
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_icmp);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_icmp4 :protocol register failed\n");
+		goto out_icmp;
+	}
+	ret = nf_conntrack_l3proto_register(net,
+					    &nf_conntrack_l3proto_ipv4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l3proto_ipv4 :protocol register failed\n");
+		goto out_ipv4;
+	}
+	return 0;
+out_ipv4:
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_icmp);
+out_icmp:
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_udp4);
+out_udp:
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_tcp4);
+out_tcp:
+	return ret;
+}
+
+static void ipv4_net_exit(struct net *net)
+{
+	nf_conntrack_l3proto_unregister(net,
+					&nf_conntrack_l3proto_ipv4);
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_icmp);
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_udp4);
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_tcp4);
+}
+
+static struct pernet_operations ipv4_net_ops = {
+	.init = ipv4_net_init,
+	.exit = ipv4_net_exit,
+};
+
 static int __init nf_conntrack_l3proto_ipv4_init(void)
 {
 	int ret = 0;
@@ -391,35 +465,17 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		return ret;
 	}
 
-	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_tcp4);
+	ret = register_pernet_subsys(&ipv4_net_ops);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register tcp.\n");
+		pr_err("nf_conntrack_ipv4: can't register pernet ops\n");
 		goto cleanup_sockopt;
 	}
 
-	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udp4);
-	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register udp.\n");
-		goto cleanup_tcp;
-	}
-
-	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_icmp);
-	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register icmp.\n");
-		goto cleanup_udp;
-	}
-
-	ret = nf_conntrack_l3proto_register(&init_net, &nf_conntrack_l3proto_ipv4);
-	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register ipv4\n");
-		goto cleanup_icmp;
-	}
-
 	ret = nf_register_hooks(ipv4_conntrack_ops,
 				ARRAY_SIZE(ipv4_conntrack_ops));
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register hooks.\n");
-		goto cleanup_ipv4;
+		goto cleanup_pernet;
 	}
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	ret = nf_conntrack_ipv4_compat_init();
@@ -431,14 +487,8 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
  cleanup_hooks:
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 #endif
- cleanup_ipv4:
-	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv4);
- cleanup_icmp:
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
- cleanup_udp:
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp4);
- cleanup_tcp:
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp4);
+ cleanup_pernet:
+	unregister_pernet_subsys(&ipv4_net_ops);
  cleanup_sockopt:
 	nf_unregister_sockopt(&so_getorigdst);
 	return ret;
@@ -451,10 +501,7 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 	nf_conntrack_ipv4_compat_fini();
 #endif
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
-	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv4);
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp4);
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp4);
+	unregister_pernet_subsys(&ipv4_net_ops);
 	nf_unregister_sockopt(&so_getorigdst);
 }
 
-- 
1.7.10

