From: pablo@netfilter.org
Subject: [PATCH 02/21] netfilter: add connlabel conntrack extension
Date: Fri, 25 Jan 2013 14:54:34 +0100
Message-ID: <1359122093-3404-3-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

similar to connmarks, except labels are bit-based; i.e.
all labels may be attached to a flow at the same time.

Up to 128 labels are supported.  Supporting more labels
is possible, but requires increasing the ct offset delta
from u8 to u16 type due to increased extension sizes.

Mapping of bit-identifier to label name is done in userspace.

The extension is enabled at run-time once "-m connlabel" netfilter
rules are added.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_extend.h |    4 ++
 include/net/netfilter/nf_conntrack_labels.h |   55 +++++++++++++++
 include/net/netns/conntrack.h               |    4 ++
 include/uapi/linux/netfilter/xt_connlabel.h |   12 ++++
 net/netfilter/Kconfig                       |   18 +++++
 net/netfilter/Makefile                      |    2 +
 net/netfilter/nf_conntrack_core.c           |   12 ++++
 net/netfilter/nf_conntrack_labels.c         |   72 +++++++++++++++++++
 net/netfilter/nf_conntrack_netlink.c        |    3 +
 net/netfilter/xt_connlabel.c                |   99 +++++++++++++++++++++++++++
 10 files changed, 281 insertions(+)
 create mode 100644 include/net/netfilter/nf_conntrack_labels.h
 create mode 100644 include/uapi/linux/netfilter/xt_connlabel.h
 create mode 100644 net/netfilter/nf_conntrack_labels.c
 create mode 100644 net/netfilter/xt_connlabel.c

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 8b4d1fc2..977bc8a 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -23,6 +23,9 @@ enum nf_ct_ext_id {
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	NF_CT_EXT_TIMEOUT,
 #endif
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	NF_CT_EXT_LABELS,
+#endif
 	NF_CT_EXT_NUM,
 };
 
@@ -33,6 +36,7 @@ enum nf_ct_ext_id {
 #define NF_CT_EXT_ZONE_TYPE struct nf_conntrack_zone
 #define NF_CT_EXT_TSTAMP_TYPE struct nf_conn_tstamp
 #define NF_CT_EXT_TIMEOUT_TYPE struct nf_conn_timeout
+#define NF_CT_EXT_LABELS_TYPE struct nf_conn_labels
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/include/net/netfilter/nf_conntrack_labels.h b/include/net/netfilter/nf_conntrack_labels.h
new file mode 100644
index 0000000..b94fe31
--- /dev/null
+++ b/include/net/netfilter/nf_conntrack_labels.h
@@ -0,0 +1,55 @@
+#include <linux/types.h>
+#include <net/net_namespace.h>
+#include <linux/netfilter/nf_conntrack_common.h>
+#include <linux/netfilter/nf_conntrack_tuple_common.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+
+#include <uapi/linux/netfilter/xt_connlabel.h>
+
+struct nf_conn_labels {
+	u8 words;
+	unsigned long bits[];
+};
+
+static inline struct nf_conn_labels *nf_ct_labels_find(const struct nf_conn *ct)
+{
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	return nf_ct_ext_find(ct, NF_CT_EXT_LABELS);
+#else
+	return NULL;
+#endif
+}
+
+static inline struct nf_conn_labels *nf_ct_labels_ext_add(struct nf_conn *ct)
+{
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	struct nf_conn_labels *cl_ext;
+	struct net *net = nf_ct_net(ct);
+	u8 words;
+
+	words = ACCESS_ONCE(net->ct.label_words);
+	if (words == 0 || WARN_ON_ONCE(words > 8))
+		return NULL;
+
+	cl_ext = nf_ct_ext_add_length(ct, NF_CT_EXT_LABELS,
+				      words * sizeof(long), GFP_ATOMIC);
+	if (cl_ext != NULL)
+		cl_ext->words = words;
+
+	return cl_ext;
+#else
+	return NULL;
+#endif
+}
+
+bool nf_connlabel_match(const struct nf_conn *ct, u16 bit);
+int nf_connlabel_set(struct nf_conn *ct, u16 bit);
+
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+int nf_conntrack_labels_init(struct net *net);
+void nf_conntrack_labels_fini(struct net *net);
+#else
+static inline int nf_conntrack_labels_init(struct net *n) { return 0; }
+static inline void nf_conntrack_labels_fini(struct net *net) {}
+#endif
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 923cb20..c9c0c53 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -84,6 +84,10 @@ struct netns_ct {
 	int			sysctl_auto_assign_helper;
 	bool			auto_assign_helper_warned;
 	struct nf_ip_net	nf_ct_proto;
+#if defined(CONFIG_NF_CONNTRACK_LABELS)
+	unsigned int		labels_used;
+	u8			label_words;
+#endif
 #ifdef CONFIG_NF_NAT_NEEDED
 	struct hlist_head	*nat_bysource;
 	unsigned int		nat_htable_size;
diff --git a/include/uapi/linux/netfilter/xt_connlabel.h b/include/uapi/linux/netfilter/xt_connlabel.h
new file mode 100644
index 0000000..c4bc9ee
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_connlabel.h
@@ -0,0 +1,12 @@
+#include <linux/types.h>
+
+#define XT_CONNLABEL_MAXBIT 127
+enum xt_connlabel_mtopts {
+	XT_CONNLABEL_OP_INVERT = 1 << 0,
+	XT_CONNLABEL_OP_SET    = 1 << 1,
+};
+
+struct xt_connlabel_mtinfo {
+	__u16 bit;
+	__u16 options;
+};
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 49e96df..bb48607 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -124,6 +124,12 @@ config NF_CONNTRACK_TIMESTAMP
 
 	  If unsure, say `N'.
 
+config NF_CONNTRACK_LABELS
+	bool
+	help
+	  This option enables support for assigning user-defined flag bits
+	  to connection tracking entries.  It selected by the connlabel match.
+
 config NF_CT_PROTO_DCCP
 	tristate 'DCCP protocol connection tracking support (EXPERIMENTAL)'
 	depends on EXPERIMENTAL
@@ -842,6 +848,18 @@ config NETFILTER_XT_MATCH_CONNBYTES
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_MATCH_CONNLABEL
+	tristate '"connlabel" match support'
+	select NF_CONNTRACK_LABELS
+	depends on NETFILTER_ADVANCED
+	---help---
+	  This match allows you to test and assign userspace-defined labels names
+	  to a connection.  The kernel only stores bit values - mapping
+	  names to bits is done by userspace.
+
+	  Unlike connmark, more than 32 flag bits may be assigned to a
+	  connection simultaneously.
+
 config NETFILTER_XT_MATCH_CONNLIMIT
 	tristate '"connlimit" match support"'
 	depends on NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 3259697..b3bbda6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -4,6 +4,7 @@ nf_conntrack-y	:= nf_conntrack_core.o nf_conntrack_standalone.o nf_conntrack_exp
 nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMEOUT) += nf_conntrack_timeout.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMESTAMP) += nf_conntrack_timestamp.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
+nf_conntrack-$(CONFIG_NF_CONNTRACK_LABELS) += nf_conntrack_labels.o
 
 obj-$(CONFIG_NETFILTER) = netfilter.o
 
@@ -101,6 +102,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_ADDRTYPE) += xt_addrtype.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) += xt_connbytes.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CONNLABEL) += xt_connlabel.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNLIMIT) += xt_connlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNTRACK) += xt_conntrack.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CPU) += xt_cpu.o
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e4a0c4f..85aa4b7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -45,6 +45,7 @@
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/nf_conntrack_timestamp.h>
 #include <net/netfilter/nf_conntrack_timeout.h>
+#include <net/netfilter/nf_conntrack_labels.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
 
@@ -763,6 +764,7 @@ void nf_conntrack_free(struct nf_conn *ct)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_free);
 
+
 /* Allocate a new conntrack: we return -ENOMEM if classification
    failed due to stress.  Otherwise it really is unclassifiable. */
 static struct nf_conntrack_tuple_hash *
@@ -809,6 +811,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
 	nf_ct_tstamp_ext_add(ct, GFP_ATOMIC);
+	nf_ct_labels_ext_add(ct);
 
 	ecache = tmpl ? nf_ct_ecache_find(tmpl) : NULL;
 	nf_ct_ecache_ext_add(ct, ecache ? ecache->ctmask : 0,
@@ -1352,6 +1355,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
+	nf_conntrack_labels_fini(net);
 	nf_conntrack_helper_fini(net);
 	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
@@ -1583,7 +1587,15 @@ static int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_helper_init(net);
 	if (ret < 0)
 		goto err_helper;
+
+	ret = nf_conntrack_labels_init(net);
+	if (ret < 0)
+		goto err_labels;
+
 	return 0;
+
+err_labels:
+	nf_conntrack_helper_fini(net);
 err_helper:
 	nf_conntrack_timeout_fini(net);
 err_timeout:
diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
new file mode 100644
index 0000000..0c542f4
--- /dev/null
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -0,0 +1,72 @@
+/*
+ * test/set flag bits stored in conntrack extension area.
+ *
+ * (C) 2013 Astaro GmbH & Co KG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/ctype.h>
+#include <linux/export.h>
+#include <linux/jhash.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+
+#include <net/netfilter/nf_conntrack_ecache.h>
+#include <net/netfilter/nf_conntrack_labels.h>
+
+static unsigned int label_bits(const struct nf_conn_labels *l)
+{
+	unsigned int longs = l->words;
+	return longs * BITS_PER_LONG;
+}
+
+bool nf_connlabel_match(const struct nf_conn *ct, u16 bit)
+{
+	struct nf_conn_labels *labels = nf_ct_labels_find(ct);
+
+	if (!labels)
+		return false;
+
+	return bit < label_bits(labels) && test_bit(bit, labels->bits);
+}
+EXPORT_SYMBOL_GPL(nf_connlabel_match);
+
+int nf_connlabel_set(struct nf_conn *ct, u16 bit)
+{
+	struct nf_conn_labels *labels = nf_ct_labels_find(ct);
+
+	if (!labels || bit >= label_bits(labels))
+		return -ENOSPC;
+
+	if (test_bit(bit, labels->bits))
+		return 0;
+
+	if (test_and_set_bit(bit, labels->bits))
+		return 0;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nf_connlabel_set);
+
+static struct nf_ct_ext_type labels_extend __read_mostly = {
+	.len    = sizeof(struct nf_conn_labels),
+	.align  = __alignof__(struct nf_conn_labels),
+	.id     = NF_CT_EXT_LABELS,
+};
+
+int nf_conntrack_labels_init(struct net *net)
+{
+	if (net_eq(net, &init_net))
+		return nf_ct_extend_register(&labels_extend);
+	return 0;
+}
+
+void nf_conntrack_labels_fini(struct net *net)
+{
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&labels_extend);
+}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 627b0e5..e0b10ee 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -43,6 +43,7 @@
 #include <net/netfilter/nf_conntrack_acct.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/nf_conntrack_timestamp.h>
+#include <net/netfilter/nf_conntrack_labels.h>
 #ifdef CONFIG_NF_NAT_NEEDED
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_nat_l4proto.h>
@@ -1598,6 +1599,8 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
 	nf_ct_tstamp_ext_add(ct, GFP_ATOMIC);
 	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
+	nf_ct_labels_ext_add(ct);
+
 	/* we must add conntrack extensions before confirmation. */
 	ct->status |= IPS_CONFIRMED;
 
diff --git a/net/netfilter/xt_connlabel.c b/net/netfilter/xt_connlabel.c
new file mode 100644
index 0000000..9f8719d
--- /dev/null
+++ b/net/netfilter/xt_connlabel.c
@@ -0,0 +1,99 @@
+/*
+ * (C) 2013 Astaro GmbH & Co KG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_labels.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_DESCRIPTION("Xtables: add/match connection trackling labels");
+MODULE_ALIAS("ipt_connlabel");
+MODULE_ALIAS("ip6t_connlabel");
+
+static bool
+connlabel_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_connlabel_mtinfo *info = par->matchinfo;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	bool invert = info->options & XT_CONNLABEL_OP_INVERT;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct == NULL || nf_ct_is_untracked(ct))
+		return invert;
+
+	if (info->options & XT_CONNLABEL_OP_SET)
+		return (nf_connlabel_set(ct, info->bit) == 0) ^ invert;
+
+	return nf_connlabel_match(ct, info->bit) ^ invert;
+}
+
+static int connlabel_mt_check(const struct xt_mtchk_param *par)
+{
+	const int options = XT_CONNLABEL_OP_INVERT |
+			    XT_CONNLABEL_OP_SET;
+	struct xt_connlabel_mtinfo *info = par->matchinfo;
+	int ret;
+	size_t words;
+
+	if (info->bit > XT_CONNLABEL_MAXBIT)
+		return -ERANGE;
+
+	if (info->options & ~options) {
+		pr_err("Unknown options in mask %x\n", info->options);
+		return -EINVAL;
+	}
+
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
+		pr_info("cannot load conntrack support for proto=%u\n",
+							par->family);
+		return ret;
+	}
+
+	par->net->ct.labels_used++;
+	words = BITS_TO_LONGS(info->bit+1);
+	if (words > par->net->ct.label_words)
+		par->net->ct.label_words = words;
+
+	return ret;
+}
+
+static void connlabel_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	par->net->ct.labels_used--;
+	if (par->net->ct.labels_used == 0)
+		par->net->ct.label_words = 0;
+	nf_ct_l3proto_module_put(par->family);
+}
+
+static struct xt_match connlabels_mt_reg __read_mostly = {
+	.name           = "connlabel",
+	.family         = NFPROTO_UNSPEC,
+	.checkentry     = connlabel_mt_check,
+	.match          = connlabel_mt,
+	.matchsize      = sizeof(struct xt_connlabel_mtinfo),
+	.destroy        = connlabel_mt_destroy,
+	.me             = THIS_MODULE,
+};
+
+static int __init connlabel_mt_init(void)
+{
+	return xt_register_match(&connlabels_mt_reg);
+}
+
+static void __exit connlabel_mt_exit(void)
+{
+	xt_unregister_match(&connlabels_mt_reg);
+}
+
+module_init(connlabel_mt_init);
+module_exit(connlabel_mt_exit);
-- 
1.7.10.4

