From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v2 6/6] netns ct: per-netns conntrack accounting
Date: Sat, 13 Sep 2008 14:55:09 +0400
Message-ID: <20080913105509.GG7440@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48C62B1C.7070104@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_acct.h |   10 +--
 include/net/netns/conntrack.h             |    2 
 net/netfilter/nf_conntrack_acct.c         |  100 +++++++++++++++++++++---------
 net/netfilter/nf_conntrack_core.c         |    4 -
 4 files changed, 81 insertions(+), 35 deletions(-)

--- a/include/net/netfilter/nf_conntrack_acct.h
+++ b/include/net/netfilter/nf_conntrack_acct.h
@@ -8,6 +8,7 @@
 
 #ifndef _NF_CONNTRACK_ACCT_H
 #define _NF_CONNTRACK_ACCT_H
+#include <net/net_namespace.h>
 #include <linux/netfilter/nf_conntrack_common.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
 #include <net/netfilter/nf_conntrack.h>
@@ -18,8 +19,6 @@ struct nf_conn_counter {
 	u_int64_t bytes;
 };
 
-extern int nf_ct_acct;
-
 static inline
 struct nf_conn_counter *nf_conn_acct_find(const struct nf_conn *ct)
 {
@@ -29,9 +28,10 @@ struct nf_conn_counter *nf_conn_acct_find(const struct nf_conn *ct)
 static inline
 struct nf_conn_counter *nf_ct_acct_ext_add(struct nf_conn *ct, gfp_t gfp)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conn_counter *acct;
 
-	if (!nf_ct_acct)
+	if (!net->ct.sysctl_acct)
 		return NULL;
 
 	acct = nf_ct_ext_add(ct, NF_CT_EXT_ACCT, gfp);
@@ -45,7 +45,7 @@ struct nf_conn_counter *nf_ct_acct_ext_add(struct nf_conn *ct, gfp_t gfp)
 extern unsigned int
 seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir);
 
-extern int nf_conntrack_acct_init(void);
-extern void nf_conntrack_acct_fini(void);
+extern int nf_conntrack_acct_init(struct net *net);
+extern void nf_conntrack_acct_fini(struct net *net);
 
 #endif /* _NF_CONNTRACK_ACCT_H */
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -17,10 +17,12 @@ struct netns_ct {
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	struct nf_conntrack_ecache *ecache;
 #endif
+	int			sysctl_acct;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
+	struct ctl_table_header	*acct_sysctl_header;
 #endif
 	int			hash_vmalloc;
 	int			expect_vmalloc;
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -22,19 +22,17 @@
 #define NF_CT_ACCT_DEFAULT 0
 #endif
 
-int nf_ct_acct __read_mostly = NF_CT_ACCT_DEFAULT;
-EXPORT_SYMBOL_GPL(nf_ct_acct);
+static int nf_ct_acct __read_mostly = NF_CT_ACCT_DEFAULT;
 
 module_param_named(acct, nf_ct_acct, bool, 0644);
 MODULE_PARM_DESC(acct, "Enable connection tracking flow accounting.");
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_table_header *acct_sysctl_header;
 static struct ctl_table acct_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_acct",
-		.data		= &nf_ct_acct,
+		.data		= &init_net.ct.sysctl_acct,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
@@ -64,41 +62,87 @@ static struct nf_ct_ext_type acct_extend __read_mostly = {
 	.id	= NF_CT_EXT_ACCT,
 };
 
-int nf_conntrack_acct_init(void)
+#ifdef CONFIG_SYSCTL
+static int nf_conntrack_acct_init_sysctl(struct net *net)
 {
-	int ret;
+	struct ctl_table *table;
 
-#ifdef CONFIG_NF_CT_ACCT
-	printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Plase use\n");
-	printk(KERN_WARNING "nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack module option or\n");
-	printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
-#endif
+	table = kmemdup(acct_sysctl_table, sizeof(acct_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		goto out;
+
+	table[0].data = &net->ct.sysctl_acct;
 
-	ret = nf_ct_extend_register(&acct_extend);
-	if (ret < 0) {
-		printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
-		return ret;
+	net->ct.acct_sysctl_header = register_net_sysctl_table(net,
+			nf_net_netfilter_sysctl_path, table);
+	if (!net->ct.acct_sysctl_header) {
+		printk(KERN_ERR "nf_conntrack_acct: can't register to sysctl.\n");
+		goto out_register;
 	}
+	return 0;
 
-#ifdef CONFIG_SYSCTL
-	acct_sysctl_header = register_sysctl_paths(nf_net_netfilter_sysctl_path,
-				acct_sysctl_table);
+out_register:
+	kfree(table);
+out:
+	return -ENOMEM;
+}
 
-	if (!acct_sysctl_header) {
-		nf_ct_extend_unregister(&acct_extend);
+static void nf_conntrack_acct_fini_sysctl(struct net *net)
+{
+	struct ctl_table *table;
 
-		printk(KERN_ERR "nf_conntrack_acct: can't register to sysctl.\n");
-		return -ENOMEM;
-	}
+	table = net->ct.acct_sysctl_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->ct.acct_sysctl_header);
+	kfree(table);
+}
+#else
+static int nf_conntrack_acct_init_sysctl(struct net *net)
+{
+	return 0;
+}
+
+static void nf_conntrack_acct_fini_sysctl(struct net *net)
+{
+}
+#endif
+
+int nf_conntrack_acct_init(struct net *net)
+{
+	int ret;
+
+	net->ct.sysctl_acct = nf_ct_acct;
+
+	if (net_eq(net, &init_net)) {
+#ifdef CONFIG_NF_CT_ACCT
+		printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Plase use\n");
+		printk(KERN_WARNING "nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack module option or\n");
+		printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
 #endif
 
+		ret = nf_ct_extend_register(&acct_extend);
+		if (ret < 0) {
+			printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
+			goto out_extend_register;
+		}
+	}
+
+	ret = nf_conntrack_acct_init_sysctl(net);
+	if (ret < 0)
+		goto out_sysctl;
+
 	return 0;
+
+out_sysctl:
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&acct_extend);
+out_extend_register:
+	return ret;
 }
 
-void nf_conntrack_acct_fini(void)
+void nf_conntrack_acct_fini(struct net *net)
 {
-#ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(acct_sysctl_header);
-#endif
-	nf_ct_extend_unregister(&acct_extend);
+	nf_conntrack_acct_fini_sysctl(net);
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&acct_extend);
 }
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1039,7 +1039,7 @@ void nf_conntrack_cleanup(struct net *net)
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 
-	nf_conntrack_acct_fini();
+	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
 	free_percpu(net->ct.stat);
 	nf_conntrack_helper_fini();
@@ -1191,7 +1191,7 @@ int nf_conntrack_init(struct net *net)
 	if (ret < 0)
 		goto out_fini_expect;
 
-	ret = nf_conntrack_acct_init();
+	ret = nf_conntrack_acct_init(net);
 	if (ret < 0)
 		goto out_fini_helper;
 
