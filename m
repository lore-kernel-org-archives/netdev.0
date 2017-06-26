From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH net-next] netfilter: conntrack: add a new NF_CT_EXT_EXPAND extension
Date: Mon, 26 Jun 2017 14:10:46 +0800
Message-ID: <1498457446-30135-1-git-send-email-xiaolou4617@gmail.com>
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        Lin Zhang <xiaolou4617@gmail.com>
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  In the current conntrack extend code, if we want to add a new
extension, we must be add a new extension id and recompile kernel.
I think that is not be convenient for users, so i add a new extension named
NF_CT_EXT_EXPAND for supporting dynamic register/unregister expansion
in runtime that means if kernel support NF_CT_EXT_EXPAND extension,
user could call nf_ct_expand_area_add() to register a new expansion
but not need to predefine an id in enum nf_ct_ext_id.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
 include/net/netfilter/nf_conntrack_expand.h |  26 ++
 include/net/netfilter/nf_conntrack_extend.h |   4 +
 net/netfilter/Kconfig                       |   7 +
 net/netfilter/Makefile                      |   2 +
 net/netfilter/nf_conntrack_expand.c         | 354 ++++++++++++++++++++++++++++
 5 files changed, 393 insertions(+)
 create mode 100644 include/net/netfilter/nf_conntrack_expand.h
 create mode 100644 net/netfilter/nf_conntrack_expand.c

diff --git a/include/net/netfilter/nf_conntrack_expand.h b/include/net/netfilter/nf_conntrack_expand.h
new file mode 100644
index 0000000..a065d89
--- /dev/null
+++ b/include/net/netfilter/nf_conntrack_expand.h
@@ -0,0 +1,26 @@
+#ifndef _NF_CONNTRACK_EXPAND_H
+#define _NF_CONNTRACK_EXPAND_H
+
+#include <linux/types.h>
+#include <net/netfilter/nf_conntrack.h>
+
+#define NF_EXPAND_NAMSIZ 16
+
+/* expansion type */
+struct nf_ct_expand_type {
+	struct hlist_node node;	/* private */
+	/* Destroys relationships (can be NULL) */
+	void (*destroy)(void *data);
+	/* unique name, not more than NF_EXPAND_NAMSIZ */
+	const char *name;
+	int len;
+	int align;
+};
+
+
+int nf_ct_expand_type_register(struct nf_ct_expand_type *type);
+int nf_ct_expand_type_unregister(struct nf_ct_expand_type *type);
+void *nf_ct_expand_area_find(struct nf_conn *ct, const char *name);
+void *nf_ct_expand_area_add(struct nf_conn *ct, const char *name, gfp_t gfp);
+
+#endif /* _NF_CONNTRACK_EXPAND_H */
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 4944bc9..6bd56fd 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -27,6 +27,9 @@ enum nf_ct_ext_id {
 #if IS_ENABLED(CONFIG_NETFILTER_SYNPROXY)
 	NF_CT_EXT_SYNPROXY,
 #endif
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_EXPAND)
+	NF_CT_EXT_EXPAND,
+#endif
 	NF_CT_EXT_NUM,
 };
 
@@ -39,6 +42,7 @@ enum nf_ct_ext_id {
 #define NF_CT_EXT_TIMEOUT_TYPE struct nf_conn_timeout
 #define NF_CT_EXT_LABELS_TYPE struct nf_conn_labels
 #define NF_CT_EXT_SYNPROXY_TYPE struct nf_conn_synproxy
+#define NF_CT_EXT_EXPAND_TYPE struct nf_conn_expand
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 9b28864..7cdd25c 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -145,6 +145,13 @@ config NF_CONNTRACK_LABELS
 	  This option enables support for assigning user-defined flag bits
 	  to connection tracking entries.  It selected by the connlabel match.
 
+config NF_CONNTRACK_EXPAND
+	tristate  'Connection tracking expand'
+	default y
+	help
+	  This option enables support for dynamic adding new extensions in runtime but
+	  not need to predefine an id in enum nf_ct_ext_id.
+
 config NF_CT_PROTO_DCCP
 	bool 'DCCP protocol connection tracking support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index c9b78e7..b9202a1 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -8,6 +8,8 @@ nf_conntrack-$(CONFIG_NF_CONNTRACK_LABELS) += nf_conntrack_labels.o
 nf_conntrack-$(CONFIG_NF_CT_PROTO_DCCP) += nf_conntrack_proto_dccp.o
 nf_conntrack-$(CONFIG_NF_CT_PROTO_SCTP) += nf_conntrack_proto_sctp.o
 
+obj-$(CONFIG_NF_CONNTRACK_EXPAND) += nf_conntrack_expand.o
+
 obj-$(CONFIG_NETFILTER) = netfilter.o
 
 obj-$(CONFIG_NETFILTER_NETLINK) += nfnetlink.o
diff --git a/net/netfilter/nf_conntrack_expand.c b/net/netfilter/nf_conntrack_expand.c
new file mode 100644
index 0000000..4c58658
--- /dev/null
+++ b/net/netfilter/nf_conntrack_expand.c
@@ -0,0 +1,354 @@
+/*	structure dynamic expansion infrastructure based on conntrack extension
+ *	Copyright (C) 2017 Lin Zhang <xiaolou4617@gmail.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/types.h>
+#include <linux/netfilter.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/rculist.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/jhash.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+#include <net/netfilter/nf_conntrack_expand.h>
+
+#define NF_EXP_TBL_HASH_SIZE 16
+#define NF_EXP_TBL_HASH_MASK (NF_EXP_TBL_HASH_SIZE - 1)
+
+#define NF_EXP_TYPE_HASH_SIZE 16
+#define NF_EXP_TYPE_HASH_MASK (NF_EXP_TYPE_HASH_SIZE - 1)
+
+#if defined(CONFIG_MODULE_UNLOAD) && defined(CONFIG_NF_CONNTRACK_EXPAND_MODULE)
+#define NF_EXPAND_ENABLE_UNLOAD
+#endif
+
+#ifdef NF_EXPAND_ENABLE_UNLOAD
+/* trace all NF_CT_EXT_EXPAND expands */
+static LIST_HEAD(expand_list);
+static DEFINE_SPINLOCK(expand_lock);
+#endif
+
+static DEFINE_MUTEX(nf_ct_exp_type_mutex);
+static struct hlist_head nf_expand_type_hash[NF_EXP_TYPE_HASH_SIZE];
+
+struct nf_conn_expand;
+
+struct nf_conn_expand_table {
+	#ifdef NF_EXPAND_ENABLE_UNLOAD
+	struct nf_conn_expand *exp;
+	struct list_head list;	/* linked to global expand_list */
+	#endif
+	struct hlist_head hash[NF_EXP_TBL_HASH_SIZE];
+};
+
+struct nf_conn_expand {
+	struct nf_conn_expand_table *tbl;
+};
+
+struct nf_ct_expand_area {
+	/* these four elements for internal use */
+	struct rcu_head rcu;
+	struct hlist_node node;
+	char name[NF_EXPAND_NAMSIZ];
+	/* user data off */
+	int off;
+	/* user data */
+};
+
+static inline u32 nf_ct_expand_name_hash(const char *name)
+{
+	return jhash(name, strlen(name), 0);
+}
+
+/* This MUST be called in process context. */
+int nf_ct_expand_type_register(struct nf_ct_expand_type *type)
+{
+	struct nf_ct_expand_type *exp_type;
+	int ret = 0;
+	u32 hash;
+
+	if (strlen(type->name) + 1 > NF_EXPAND_NAMSIZ)
+		return -EINVAL;
+
+	hash = nf_ct_expand_name_hash(type->name) & NF_EXP_TYPE_HASH_MASK;
+	mutex_lock(&nf_ct_exp_type_mutex);
+	hlist_for_each_entry(exp_type, &nf_expand_type_hash[hash], node) {
+		if (!strcmp(exp_type->name, type->name)) {
+			ret = -EEXIST;
+			goto out;
+		}
+	}
+	hlist_add_head_rcu(&type->node, &nf_expand_type_hash[hash]);
+out:
+	mutex_unlock(&nf_ct_exp_type_mutex);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nf_ct_expand_type_register);
+
+int nf_ct_expand_type_unregister(struct nf_ct_expand_type *type)
+{
+	struct nf_ct_expand_type *exp_type;
+	int ret = -ENOENT;
+	u32 hash = nf_ct_expand_name_hash(type->name) & NF_EXP_TYPE_HASH_MASK;
+
+	mutex_lock(&nf_ct_exp_type_mutex);
+	hlist_for_each_entry(exp_type, &nf_expand_type_hash[hash], node) {
+		if (!strcmp(exp_type->name, type->name)) {
+			WARN_ON(exp_type != type);
+			hlist_del_rcu(&exp_type->node);
+			ret = 0;
+			break;
+		}
+	}
+	mutex_unlock(&nf_ct_exp_type_mutex);
+	if (!ret)
+		synchronize_rcu();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nf_ct_expand_type_unregister);
+
+static struct nf_ct_expand_type *
+nf_ct_get_expand_type_rcu(const char *name)
+{
+	struct nf_ct_expand_type *type;
+	u32 hash = nf_ct_expand_name_hash(name) & NF_EXP_TYPE_HASH_MASK;
+
+	hlist_for_each_entry_rcu(type, &nf_expand_type_hash[hash], node) {
+		if (!strcmp(type->name, name))
+			return type;
+	}
+	return NULL;
+}
+
+static struct nf_ct_expand_area *
+nf_ct_get_expand_area(struct nf_conn_expand_table *tbl, const char *name)
+{
+	struct nf_ct_expand_area *area;
+	u32 hash = nf_ct_expand_name_hash(name) & NF_EXP_TBL_HASH_MASK;
+
+	hlist_for_each_entry(area, &tbl->hash[hash], node) {
+		if (!strcmp(area->name, name))
+			return area;
+	}
+	return NULL;
+}
+
+static void nf_ct_expand_table_destroy(struct nf_conn_expand_table *tbl)
+{
+	int i;
+	struct nf_ct_expand_area *area;
+	struct nf_ct_expand_type *type;
+	struct hlist_node *n;
+
+	for (i = 0; i < NF_EXP_TBL_HASH_SIZE; i++) {
+		hlist_for_each_entry_safe(area, n, &tbl->hash[i], node) {
+			hlist_del(&area->node);
+			rcu_read_lock();
+			type = nf_ct_get_expand_type_rcu(area->name);
+			if (type && type->destroy)
+				type->destroy((void *)area + area->off);
+			rcu_read_unlock();
+			kfree_rcu(area, rcu);
+		}
+	}
+	kfree(tbl);
+}
+
+static void nf_ct_expand_destroy(struct nf_conn *ct)
+{
+	struct nf_conn_expand *exp;
+	struct nf_conn_expand_table *tbl;
+
+	exp = nf_ct_ext_find(ct, NF_CT_EXT_EXPAND);
+	if (!exp)
+		return;
+
+	tbl = READ_ONCE(exp->tbl);
+	if (!tbl)
+		return;
+
+	#ifdef NF_EXPAND_ENABLE_UNLOAD
+	spin_lock_bh(&expand_lock);
+	/* if expand_list is empty, module exit function
+	 * will do resource cleanup
+	 */
+	if (list_empty(&expand_list)) {
+		spin_unlock_bh(&expand_lock);
+		return;
+	}
+	list_del(&tbl->list);
+	spin_unlock_bh(&expand_lock);
+	#endif
+
+	WRITE_ONCE(exp->tbl, NULL);
+
+	nf_ct_expand_table_destroy(tbl);
+}
+
+#ifdef NF_EXPAND_ENABLE_UNLOAD
+static void nf_ct_cleanup_expand(void)
+{
+	struct nf_conn_expand_table *tbl, *tbl_n;
+	LIST_HEAD(exp_list);
+
+	/* rcu locked avoid nf_ct_ext_free free extend areas in advance */
+	rcu_read_lock();
+
+	spin_lock_bh(&expand_lock);
+	list_splice_init(&expand_list, &exp_list);
+	spin_unlock_bh(&expand_lock);
+
+	list_for_each_entry_safe(tbl, tbl_n, &exp_list, list) {
+		WRITE_ONCE(tbl->exp->tbl, NULL);
+		list_del(&tbl->list);
+		nf_ct_expand_table_destroy(tbl);
+	}
+
+	rcu_read_unlock();
+}
+#else
+static inline void nf_ct_cleanup_expand(void)
+{}
+#endif
+
+static struct nf_conn_expand *
+__nf_ct_expand_add(struct nf_conn *ct, gfp_t gfp)
+{
+	int i;
+	struct nf_conn_expand *exp;
+	struct nf_conn_expand_table *tbl;
+
+	if (nf_ct_is_confirmed(ct))
+		return NULL;
+
+	exp = nf_ct_ext_add(ct, NF_CT_EXT_EXPAND, gfp);
+	if (!exp)
+		return NULL;
+
+	tbl = kmalloc(sizeof(*tbl), gfp);
+	if (!tbl)
+		return NULL;
+
+	for (i = 0; i < NF_EXP_TBL_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&tbl->hash[i]);
+	WRITE_ONCE(exp->tbl, tbl);
+
+	#ifdef NF_EXPAND_ENABLE_UNLOAD
+	tbl->exp = exp;
+	spin_lock_bh(&expand_lock);
+	list_add(&tbl->list, &expand_list);
+	spin_unlock_bh(&expand_lock);
+	#endif
+
+	return exp;
+}
+
+void *nf_ct_expand_area_find(struct nf_conn *ct, const char *name)
+{
+	struct nf_conn_expand *exp;
+	struct nf_conn_expand_table *tbl;
+	struct nf_ct_expand_area *area;
+
+	exp = nf_ct_ext_find(ct, NF_CT_EXT_EXPAND);
+	if (!exp)
+		return NULL;
+
+	tbl = READ_ONCE(exp->tbl);
+	if (!tbl)
+		return NULL;
+
+	area = nf_ct_get_expand_area(tbl, name);
+	return area ? (void *)area + area->off : NULL;
+}
+EXPORT_SYMBOL_GPL(nf_ct_expand_area_find);
+
+/* Add a new data area to nf_conn_expand */
+void *nf_ct_expand_area_add(struct nf_conn *ct, const char *name, gfp_t gfp)
+{
+	int len, off;
+	u32 hash;
+	struct nf_conn_expand *exp;
+	struct nf_conn_expand_table *tbl;
+	struct nf_ct_expand_type *type;
+	struct nf_ct_expand_area *area;
+	bool new_expand = false;
+
+	exp = nf_ct_ext_find(ct, NF_CT_EXT_EXPAND);
+	if (!exp) {
+		exp = __nf_ct_expand_add(ct, gfp);
+		if (!exp)
+			return NULL;
+		new_expand = true;
+	}
+
+	tbl = READ_ONCE(exp->tbl);
+	if (!tbl)
+		return NULL;
+
+	if (!new_expand) {
+		area = nf_ct_get_expand_area(tbl, name);
+		if (area)
+			return NULL;
+	}
+
+	rcu_read_lock();
+	type = nf_ct_get_expand_type_rcu(name);
+	if (!type) {
+		rcu_read_unlock();
+		return NULL;
+	}
+	off = ALIGN(sizeof(*area), type->align);
+	WARN_ON(off < sizeof(*area));
+	len = type->len;
+	rcu_read_unlock();
+
+	/* conntrack must not be confirmed to
+	 * avoid races on operating the hash table
+	 */
+	if (nf_ct_is_confirmed(ct))
+		return NULL;
+
+	area = kmalloc(off + len, gfp);
+	if (!area)
+		return NULL;
+	strlcpy(area->name, name, NF_EXPAND_NAMSIZ);
+	area->off = off;
+	hash = nf_ct_expand_name_hash(name) & NF_EXP_TBL_HASH_MASK;
+	hlist_add_head(&area->node, &tbl->hash[hash]);
+
+	return (void *)area + area->off;
+}
+EXPORT_SYMBOL_GPL(nf_ct_expand_area_add);
+
+static const struct nf_ct_ext_type nf_ext_expand = {
+	.destroy = nf_ct_expand_destroy,
+	.len = sizeof(struct nf_conn_expand),
+	.align = __alignof__(struct nf_conn_expand),
+	.id = NF_CT_EXT_EXPAND,
+};
+
+static int __init nf_ct_expand_init(void)
+{
+	return nf_ct_extend_register(&nf_ext_expand);
+}
+
+static void __exit nf_ct_expand_exit(void)
+{
+	nf_ct_cleanup_expand();
+	nf_ct_extend_unregister(&nf_ext_expand);
+}
+
+module_init(nf_ct_expand_init);
+module_exit(nf_ct_expand_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Lin Zhang <xiaolou4617@gmail.com>");
-- 
1.8.3.1
