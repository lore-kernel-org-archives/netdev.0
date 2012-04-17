From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 08/12] netfilter: ipv4 sysctl support for net namespace
Date: Tue, 17 Apr 2012 10:56:19 +0800
Message-ID: <1334631383-12326-9-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

delete the ctl_table_header, ctl_table_path, ctl_table
from struct nf_conntrack_l3proto,
delete the ctl_table_header, ctl_table, ctl_table_users,
ctl_compat_table_header, ctl_compat_table from struct
nf_conntract_l4proto.
we have removed these field to the struct netns_ct_proto.

register pernet_operations nf_conntrack_net_proto_ipv4_ops
when loading nf_conntrack_ipv4 module,and unregister it when
removing.

nf_conntrack_l4proto.h exports the init,fini functions of l4proto.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l3proto.h   |    6 --
 include/net/netfilter/nf_conntrack_l4proto.h   |   38 +++++++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   96 ++++++++++++++++++++++-
 3 files changed, 119 insertions(+), 21 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index e8010f4..cf14b99 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -63,12 +63,6 @@ struct nf_conntrack_l3proto {
 
 	size_t nla_size;
 
-#ifdef CONFIG_SYSCTL
-	struct ctl_table_header	*ctl_table_header;
-	struct ctl_path		*ctl_table_path;
-	struct ctl_table	*ctl_table;
-#endif /* CONFIG_SYSCTL */
-
 	/* Module (if any) which this is connected to. */
 	struct module *me;
 };
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 3b572bb..167d9c2 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -93,16 +93,6 @@ struct nf_conntrack_l4proto {
 		const struct nla_policy *nla_policy;
 	} ctnl_timeout;
 #endif
-
-#ifdef CONFIG_SYSCTL
-	struct ctl_table_header	**ctl_table_header;
-	struct ctl_table	*ctl_table;
-	unsigned int		*ctl_table_users;
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	struct ctl_table_header	*ctl_compat_table_header;
-	struct ctl_table	*ctl_compat_table;
-#endif
-#endif
 	/* Protocol name */
 	const char *name;
 
@@ -134,6 +124,34 @@ extern int nf_ct_port_nlattr_to_tuple(struct nlattr *tb[],
 extern int nf_ct_port_nlattr_tuple_size(void);
 extern const struct nla_policy nf_ct_port_nla_policy[];
 
+extern int nf_ct_register_net_sysctl(struct net *net,
+				     struct ctl_table_header **header,
+				     struct ctl_path *path,
+				     struct ctl_table *table,
+				     unsigned int *users);
+
+extern void nf_ct_unregister_net_sysctl(struct ctl_table_header **header,
+					struct ctl_table *table,
+					unsigned int *users);
+
+extern int nf_conntrack_proto_ipv4_tcp_init(struct net *net);
+extern void nf_conntrack_proto_ipv4_tcp_fini(struct net *net);
+
+extern int nf_conntrack_proto_ipv6_tcp_init(struct net *net);
+extern void nf_conntrack_proto_ipv6_tcp_fini(struct net *net);
+
+extern int nf_conntrack_proto_ipv4_udp_init(struct net *net);
+extern void nf_conntrack_proto_ipv4_udp_fini(struct net *net);
+
+extern int nf_conntrack_proto_ipv6_udp_init(struct net *net);
+extern void nf_conntrack_proto_ipv6_udp_fini(struct net *net);
+
+extern int nf_conntrack_proto_ipv4_icmp_init(struct net *net);
+extern void nf_conntrack_proto_ipv4_icmp_fini(struct net *net);
+
+extern int nf_conntrack_proto_icmpv6_net_init(struct net *net);
+extern void nf_conntrack_proto_icmpv6_net_fini(struct net *net);
+
 #ifdef CONFIG_SYSCTL
 #ifdef DEBUG_INVALID_PACKETS
 #define LOG_INVALID(net, proto)				\
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index de9da21..234ff9a 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -355,10 +355,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.nlattr_to_tuple = ipv4_nlattr_to_tuple,
 	.nla_policy	 = ipv4_nla_policy,
 #endif
-#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	.ctl_table_path  = nf_net_ipv4_netfilter_sysctl_path,
-	.ctl_table	 = ip_ct_sysctl_table,
-#endif
 	.me		 = THIS_MODULE,
 };
 
@@ -369,6 +365,86 @@ MODULE_ALIAS("nf_conntrack-" __stringify(AF_INET));
 MODULE_ALIAS("ip_conntrack");
 MODULE_LICENSE("GPL");
 
+static int nf_conntrack_proto_ipv4_net_init(struct net *net)
+{
+	int ret = 0;
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *table;
+	table = kmemdup(ip_ct_sysctl_table,
+			sizeof(ip_ct_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+	table[1].data = &net->ct.count;
+	table[2].data = &net->ct.htable_size;
+	table[3].data = &net->ct.sysctl_checksum;
+	table[4].data = &net->ct.sysctl_log_invalid;
+	net->ct.proto.ipv4_compat_header =
+		register_net_sysctl_table(net,
+					  nf_net_ipv4_netfilter_sysctl_path,
+					  table);
+	if (!net->ct.proto.ipv4_compat_header)
+		goto out_register;
+	return 0;
+out_register:
+	kfree(table);
+#endif
+#endif
+	return ret;
+}
+
+static void nf_conntrack_proto_ipv4_net_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *table;
+	table = net->ct.proto.ipv4_compat_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->ct.proto.ipv4_compat_header);
+	kfree(table);
+#endif
+#endif
+}
+
+static int nf_conntrack_net_proto_ipv4_init(struct net *net)
+{
+	int ret;
+	
+	ret = nf_conntrack_proto_ipv4_net_init(net);
+	if (ret < 0)
+		return ret;
+	ret = nf_conntrack_proto_ipv4_tcp_init(net);
+	if (ret < 0)
+		goto cleanup_ipv4;
+	ret = nf_conntrack_proto_ipv4_udp_init(net);
+	if (ret < 0)
+		goto cleanup_tcp;
+	ret = nf_conntrack_proto_ipv4_icmp_init(net);
+	if (ret < 0)
+		goto cleanup_udp;
+	return 0;
+ cleanup_udp:
+	nf_conntrack_proto_ipv4_udp_fini(net);
+ cleanup_tcp:
+	nf_conntrack_proto_ipv4_tcp_fini(net);
+ cleanup_ipv4:
+	nf_conntrack_proto_ipv4_net_fini(net);
+	return ret;
+}
+
+static void nf_conntrack_net_proto_ipv4_fini(struct net *net)
+{
+	nf_conntrack_proto_ipv4_icmp_fini(net);
+	nf_conntrack_proto_ipv4_udp_fini(net);
+	nf_conntrack_proto_ipv4_tcp_fini(net);
+	nf_conntrack_proto_ipv4_net_fini(net);
+}
+
+static struct pernet_operations nf_conntrack_net_proto_ipv4_ops = {
+	.init = nf_conntrack_net_proto_ipv4_init,
+	.exit = nf_conntrack_net_proto_ipv4_fini,
+};
+
 static int __init nf_conntrack_l3proto_ipv4_init(void)
 {
 	int ret = 0;
@@ -417,11 +493,20 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 	if (ret < 0)
 		goto cleanup_hooks;
 #endif
+	ret = register_pernet_subsys(&nf_conntrack_net_proto_ipv4_ops);
+	if (ret < 0)
+		goto cleanup_compat;
+
 	return ret;
+
+ cleanup_compat:
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	nf_conntrack_ipv4_compat_fini();
+
  cleanup_hooks:
-	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 #endif
+	nf_unregister_hooks(ipv4_conntrack_ops,
+			    ARRAY_SIZE(ipv4_conntrack_ops));
  cleanup_ipv4:
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
  cleanup_icmp:
@@ -438,6 +523,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 {
 	synchronize_net();
+	unregister_pernet_subsys(&nf_conntrack_net_proto_ipv4_ops);
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	nf_conntrack_ipv4_compat_fini();
 #endif
-- 
1.7.7.6

