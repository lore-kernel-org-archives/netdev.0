From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 09/17] netfilter: add namespace support for l3proto_ipv4
Date: Fri, 27 Apr 2012 17:37:56 +0800
Message-ID: <1335519484-6089-10-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add pernet_operations ipv4_net_ops and register it when
module nf_conntrack_ipv4 is loaded.

move the l4proto_register and l3proto_register from module_init
function to ipv4_net_ops.init.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  126 ++++++++++++++++--------
 1 files changed, 86 insertions(+), 40 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 91747d4..bfe3a7c 100644
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
@@ -351,6 +346,24 @@ static struct nf_sockopt_ops so_getorigdst = {
 	.owner		= THIS_MODULE,
 };
 
+static int ipv4_init_net(struct net *net)
+{
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	struct nf_ip_net *in = &net->ct.proto;
+	in->ctl_table = kmemdup(ip_ct_sysctl_table,
+				sizeof(ip_ct_sysctl_table),
+				GFP_KERNEL);
+	if (!in->ctl_table)
+		return -ENOMEM;
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
@@ -368,6 +381,7 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.ctl_table_path  = "net/ipv4/netfilter",
 	.ctl_table	 = ip_ct_sysctl_table,
 #endif
+	.init_net	= ipv4_init_net,
 	.me		 = THIS_MODULE,
 };
 
@@ -378,48 +392,89 @@ MODULE_ALIAS("nf_conntrack-" __stringify(AF_INET));
 MODULE_ALIAS("ip_conntrack");
 MODULE_LICENSE("GPL");
 
-static int __init nf_conntrack_l3proto_ipv4_init(void)
+static int ipv4_net_init(struct net *net)
 {
 	int ret = 0;
 
-	need_conntrack();
-	nf_defrag_ipv4_enable();
-
-	ret = nf_register_sockopt(&so_getorigdst);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_tcp4);
 	if (ret < 0) {
-		printk(KERN_ERR "Unable to register netfilter socket option\n");
-		return ret;
+		pr_err("nf_conntrack_l4proto_tcp4 :protocol register failed\n");
+		goto out_tcp;
 	}
-
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp4);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_udp4);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register tcp.\n");
-		goto cleanup_sockopt;
+		pr_err("nf_conntrack_l4proto_udp4 :protocol register failed\n");
+		goto out_udp;
 	}
-
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp4);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_icmp);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register udp.\n");
-		goto cleanup_tcp;
+		pr_err("nf_conntrack_l4proto_icmp4 :protocol register failed\n");
+		goto out_icmp;
 	}
-
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmp);
+	ret = nf_conntrack_l3proto_register(net,
+					    &nf_conntrack_l3proto_ipv4);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register icmp.\n");
-		goto cleanup_udp;
+		pr_err("nf_conntrack_l3proto_ipv4 :protocol register failed\n");
+		goto out_ipv4;
 	}
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
+static int __init nf_conntrack_l3proto_ipv4_init(void)
+{
+	int ret = 0;
 
-	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv4);
+	need_conntrack();
+	nf_defrag_ipv4_enable();
+
+	ret = nf_register_sockopt(&so_getorigdst);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register ipv4\n");
-		goto cleanup_icmp;
+		printk(KERN_ERR "Unable to register netfilter socket option\n");
+		return ret;
+	}
+
+	ret = register_pernet_subsys(&ipv4_net_ops);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv4: can't register pernet ops\n");
+		goto cleanup_sockopt;
 	}
 
 	ret = nf_register_hooks(ipv4_conntrack_ops,
 				ARRAY_SIZE(ipv4_conntrack_ops));
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register hooks.\n");
-		goto cleanup_ipv4;
+		goto cleanup_pernet;
 	}
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	ret = nf_conntrack_ipv4_compat_init();
@@ -431,14 +486,8 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
  cleanup_hooks:
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 #endif
- cleanup_ipv4:
-	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
- cleanup_icmp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
- cleanup_udp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
- cleanup_tcp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
+ cleanup_pernet:
+	unregister_pernet_subsys(&ipv4_net_ops);
  cleanup_sockopt:
 	nf_unregister_sockopt(&so_getorigdst);
 	return ret;
@@ -451,10 +500,7 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 	nf_conntrack_ipv4_compat_fini();
 #endif
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
-	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
+	unregister_pernet_subsys(&ipv4_net_ops);
 	nf_unregister_sockopt(&so_getorigdst);
 }
 
-- 
1.7.7.6

