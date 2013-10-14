From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/17] netfilter: nf_tables: add netlink set API
Date: Mon, 14 Oct 2013 18:38:45 +0200
Message-ID: <1381768738-17739-5-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34770 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757271Ab3JNQjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:21 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

This patch adds the new netlink API for maintaining nf_tables sets
independently of the ruleset. The API supports the following operations:

- creation of sets
- deletion of sets
- querying of specific sets
- dumping of all sets

- addition of set elements
- removal of set elements
- dumping of all set elements

Sets are identified by name, each table defines an individual namespace.
The name of a set may be allocated automatically, this is mostly useful
in combination with the NFT_SET_ANONYMOUS flag, which destroys a set
automatically once the last reference has been released.

Sets can be marked constant, meaning they're not allowed to change while
linked to a rule. This allows to perform lockless operation for set
types that would otherwise require locking.

Additionally, if the implementation supports it, sets can (as before) be
used as maps, associating a data value with each key (or range), by
specifying the NFT_SET_MAP flag and can be used for interval queries by
specifying the NFT_SET_INTERVAL flag.

Set elements are added and removed incrementally. All element operations
support batching, reducing netlink message and set lookup overhead.

The old "set" and "hash" expressions are replaced by a generic "lookup"
expression, which binds to the specified set. Userspace is not aware
of the actual set implementation used by the kernel anymore, all
configuration options are generic.

Currently the implementation selection logic is largely missing and the
kernel will simply use the first registered implementation supporting the
requested operation. Eventually, the plan is to have userspace supply a
description of the data characteristics and select the implementation
based on expected performance and memory use.

This patch includes the new 'lookup' expression to look up for element
matching in the set.

This patch includes kernel-doc descriptions for this set API and it
also includes the following fixes.

>From Patrick McHardy:
* netfilter: nf_tables: fix set element data type in dumps
* netfilter: nf_tables: fix indentation of struct nft_set_elem comments
* netfilter: nf_tables: fix oops in nft_validate_data_load()
* netfilter: nf_tables: fix oops while listing sets of built-in tables
* netfilter: nf_tables: destroy anonymous sets immediately if binding fails
* netfilter: nf_tables: propagate context to set iter callback
* netfilter: nf_tables: add loop detection

>From Pablo Neira Ayuso:
* netfilter: nf_tables: allow to dump all existing sets
* netfilter: nf_tables: fix wrong type for flags variable in newelem

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |  149 ++++-
 include/uapi/linux/netfilter/nf_tables.h |  191 ++++--
 net/netfilter/Kconfig                    |    6 +-
 net/netfilter/Makefile                   |    2 +-
 net/netfilter/nf_tables_api.c            | 1078 +++++++++++++++++++++++++++++-
 net/netfilter/nf_tables_core.c           |    2 -
 net/netfilter/nft_hash.c                 |  329 +++------
 net/netfilter/nft_immediate.c            |   11 +
 net/netfilter/nft_lookup.c               |  135 ++++
 net/netfilter/nft_rbtree.c               |  247 +++++++
 net/netfilter/nft_set.c                  |  381 -----------
 11 files changed, 1854 insertions(+), 677 deletions(-)
 create mode 100644 net/netfilter/nft_lookup.c
 create mode 100644 net/netfilter/nft_rbtree.c
 delete mode 100644 net/netfilter/nft_set.c

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index d26dfa3..677dd79 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -6,6 +6,8 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netlink.h>
 
+#define NFT_JUMP_STACK_SIZE	16
+
 struct nft_pktinfo {
 	struct sk_buff			*skb;
 	const struct net_device		*in;
@@ -48,23 +50,22 @@ static inline void nft_data_debug(const struct nft_data *data)
 }
 
 /**
- *	struct nft_ctx - nf_tables rule context
+ *	struct nft_ctx - nf_tables rule/set context
  *
+ * 	@skb: netlink skb
+ * 	@nlh: netlink message header
  * 	@afi: address family info
  * 	@table: the table the chain is contained in
  * 	@chain: the chain the rule is contained in
  */
 struct nft_ctx {
+	const struct sk_buff		*skb;
+	const struct nlmsghdr		*nlh;
 	const struct nft_af_info	*afi;
 	const struct nft_table		*table;
 	const struct nft_chain		*chain;
 };
 
-enum nft_data_types {
-	NFT_DATA_VALUE,
-	NFT_DATA_VERDICT,
-};
-
 struct nft_data_desc {
 	enum nft_data_types		type;
 	unsigned int			len;
@@ -83,6 +84,11 @@ static inline enum nft_data_types nft_dreg_to_type(enum nft_registers reg)
 	return reg == NFT_REG_VERDICT ? NFT_DATA_VERDICT : NFT_DATA_VALUE;
 }
 
+static inline enum nft_registers nft_type_to_reg(enum nft_data_types type)
+{
+	return type == NFT_DATA_VERDICT ? NFT_REG_VERDICT : NFT_REG_1;
+}
+
 extern int nft_validate_input_register(enum nft_registers reg);
 extern int nft_validate_output_register(enum nft_registers reg);
 extern int nft_validate_data_load(const struct nft_ctx *ctx,
@@ -91,6 +97,132 @@ extern int nft_validate_data_load(const struct nft_ctx *ctx,
 				  enum nft_data_types type);
 
 /**
+ *	struct nft_set_elem - generic representation of set elements
+ *
+ *	@cookie: implementation specific element cookie
+ *	@key: element key
+ *	@data: element data (maps only)
+ *	@flags: element flags (end of interval)
+ *
+ *	The cookie can be used to store a handle to the element for subsequent
+ *	removal.
+ */
+struct nft_set_elem {
+	void			*cookie;
+	struct nft_data		key;
+	struct nft_data		data;
+	u32			flags;
+};
+
+struct nft_set;
+struct nft_set_iter {
+	unsigned int	count;
+	unsigned int	skip;
+	int		err;
+	int		(*fn)(const struct nft_ctx *ctx,
+			      const struct nft_set *set,
+			      const struct nft_set_iter *iter,
+			      const struct nft_set_elem *elem);
+};
+
+/**
+ *	struct nft_set_ops - nf_tables set operations
+ *
+ *	@lookup: look up an element within the set
+ *	@insert: insert new element into set
+ *	@remove: remove element from set
+ *	@walk: iterate over all set elemeennts
+ *	@privsize: function to return size of set private data
+ *	@init: initialize private data of new set instance
+ *	@destroy: destroy private data of set instance
+ *	@list: nf_tables_set_ops list node
+ *	@owner: module reference
+ *	@features: features supported by the implementation
+ */
+struct nft_set_ops {
+	bool				(*lookup)(const struct nft_set *set,
+						  const struct nft_data *key,
+						  struct nft_data *data);
+	int				(*get)(const struct nft_set *set,
+					       struct nft_set_elem *elem);
+	int				(*insert)(const struct nft_set *set,
+						  const struct nft_set_elem *elem);
+	void				(*remove)(const struct nft_set *set,
+						  const struct nft_set_elem *elem);
+	void				(*walk)(const struct nft_ctx *ctx,
+						const struct nft_set *set,
+						struct nft_set_iter *iter);
+
+	unsigned int			(*privsize)(const struct nlattr * const nla[]);
+	int				(*init)(const struct nft_set *set,
+						const struct nlattr * const nla[]);
+	void				(*destroy)(const struct nft_set *set);
+
+	struct list_head		list;
+	struct module			*owner;
+	u32				features;
+};
+
+extern int nft_register_set(struct nft_set_ops *ops);
+extern void nft_unregister_set(struct nft_set_ops *ops);
+
+/**
+ * 	struct nft_set - nf_tables set instance
+ *
+ *	@list: table set list node
+ *	@bindings: list of set bindings
+ * 	@name: name of the set
+ * 	@ktype: key type (numeric type defined by userspace, not used in the kernel)
+ * 	@dtype: data type (verdict or numeric type defined by userspace)
+ * 	@ops: set ops
+ * 	@flags: set flags
+ * 	@klen: key length
+ * 	@dlen: data length
+ * 	@data: private set data
+ */
+struct nft_set {
+	struct list_head		list;
+	struct list_head		bindings;
+	char				name[IFNAMSIZ];
+	u32				ktype;
+	u32				dtype;
+	/* runtime data below here */
+	const struct nft_set_ops	*ops ____cacheline_aligned;
+	u16				flags;
+	u8				klen;
+	u8				dlen;
+	unsigned char			data[]
+		__attribute__((aligned(__alignof__(u64))));
+};
+
+static inline void *nft_set_priv(const struct nft_set *set)
+{
+	return (void *)set->data;
+}
+
+extern struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
+					    const struct nlattr *nla);
+
+/**
+ *	struct nft_set_binding - nf_tables set binding
+ *
+ *	@list: set bindings list node
+ *	@chain: chain containing the rule bound to the set
+ *
+ *	A set binding contains all information necessary for validation
+ *	of new elements added to a bound set.
+ */
+struct nft_set_binding {
+	struct list_head		list;
+	const struct nft_chain		*chain;
+};
+
+extern int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
+			      struct nft_set_binding *binding);
+extern void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
+				 struct nft_set_binding *binding);
+
+/**
  *	struct nft_expr_ops - nf_tables expression operations
  *
  *	@eval: Expression evaluation function
@@ -115,7 +247,7 @@ struct nft_expr_ops {
 	void				(*destroy)(const struct nft_expr *expr);
 	int				(*dump)(struct sk_buff *skb,
 						const struct nft_expr *expr);
-
+	const struct nft_data *		(*get_verdict)(const struct nft_expr *expr);
 	struct list_head		list;
 	const char			*name;
 	struct module			*owner;
@@ -298,4 +430,7 @@ extern void nft_unregister_expr(struct nft_expr_ops *);
 #define MODULE_ALIAS_NFT_EXPR(name) \
 	MODULE_ALIAS("nft-expr-" name)
 
+#define MODULE_ALIAS_NFT_SET() \
+	MODULE_ALIAS("nft-set")
+
 #endif /* _NET_NF_TABLES_H */
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index ec6d84a..9e92401 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -44,6 +44,12 @@ enum nft_verdicts {
  * @NFT_MSG_NEWRULE: create a new rule (enum nft_rule_attributes)
  * @NFT_MSG_GETRULE: get a rule (enum nft_rule_attributes)
  * @NFT_MSG_DELRULE: delete a rule (enum nft_rule_attributes)
+ * @NFT_MSG_NEWSET: create a new set (enum nft_set_attributes)
+ * @NFT_MSG_GETSET: get a set (enum nft_set_attributes)
+ * @NFT_MSG_DELSET: delete a set (enum nft_set_attributes)
+ * @NFT_MSG_NEWSETELEM: create a new set element (enum nft_set_elem_attributes)
+ * @NFT_MSG_GETSETELEM: get a set element (enum nft_set_elem_attributes)
+ * @NFT_MSG_DELSETELEM: delete a set element (enum nft_set_elem_attributes)
  */
 enum nf_tables_msg_types {
 	NFT_MSG_NEWTABLE,
@@ -55,9 +61,20 @@ enum nf_tables_msg_types {
 	NFT_MSG_NEWRULE,
 	NFT_MSG_GETRULE,
 	NFT_MSG_DELRULE,
+	NFT_MSG_NEWSET,
+	NFT_MSG_GETSET,
+	NFT_MSG_DELSET,
+	NFT_MSG_NEWSETELEM,
+	NFT_MSG_GETSETELEM,
+	NFT_MSG_DELSETELEM,
 	NFT_MSG_MAX,
 };
 
+/**
+ * enum nft_list_attributes - nf_tables generic list netlink attributes
+ *
+ * @NFTA_LIST_ELEM: list element (NLA_NESTED)
+ */
 enum nft_list_attributes {
 	NFTA_LIST_UNPEC,
 	NFTA_LIST_ELEM,
@@ -127,6 +144,113 @@ enum nft_rule_attributes {
 };
 #define NFTA_RULE_MAX		(__NFTA_RULE_MAX - 1)
 
+/**
+ * enum nft_set_flags - nf_tables set flags
+ *
+ * @NFT_SET_ANONYMOUS: name allocation, automatic cleanup on unlink
+ * @NFT_SET_CONSTANT: set contents may not change while bound
+ * @NFT_SET_INTERVAL: set contains intervals
+ * @NFT_SET_MAP: set is used as a dictionary
+ */
+enum nft_set_flags {
+	NFT_SET_ANONYMOUS		= 0x1,
+	NFT_SET_CONSTANT		= 0x2,
+	NFT_SET_INTERVAL		= 0x4,
+	NFT_SET_MAP			= 0x8,
+};
+
+/**
+ * enum nft_set_attributes - nf_tables set netlink attributes
+ *
+ * @NFTA_SET_TABLE: table name (NLA_STRING)
+ * @NFTA_SET_NAME: set name (NLA_STRING)
+ * @NFTA_SET_FLAGS: bitmask of enum nft_set_flags (NLA_U32)
+ * @NFTA_SET_KEY_TYPE: key data type, informational purpose only (NLA_U32)
+ * @NFTA_SET_KEY_LEN: key data length (NLA_U32)
+ * @NFTA_SET_DATA_TYPE: mapping data type (NLA_U32)
+ * @NFTA_SET_DATA_LEN: mapping data length (NLA_U32)
+ */
+enum nft_set_attributes {
+	NFTA_SET_UNSPEC,
+	NFTA_SET_TABLE,
+	NFTA_SET_NAME,
+	NFTA_SET_FLAGS,
+	NFTA_SET_KEY_TYPE,
+	NFTA_SET_KEY_LEN,
+	NFTA_SET_DATA_TYPE,
+	NFTA_SET_DATA_LEN,
+	__NFTA_SET_MAX
+};
+#define NFTA_SET_MAX		(__NFTA_SET_MAX - 1)
+
+/**
+ * enum nft_set_elem_flags - nf_tables set element flags
+ *
+ * @NFT_SET_ELEM_INTERVAL_END: element ends the previous interval
+ */
+enum nft_set_elem_flags {
+	NFT_SET_ELEM_INTERVAL_END	= 0x1,
+};
+
+/**
+ * enum nft_set_elem_attributes - nf_tables set element netlink attributes
+ *
+ * @NFTA_SET_ELEM_KEY: key value (NLA_NESTED: nft_data)
+ * @NFTA_SET_ELEM_DATA: data value of mapping (NLA_NESTED: nft_data_attributes)
+ * @NFTA_SET_ELEM_FLAGS: bitmask of nft_set_elem_flags (NLA_U32)
+ */
+enum nft_set_elem_attributes {
+	NFTA_SET_ELEM_UNSPEC,
+	NFTA_SET_ELEM_KEY,
+	NFTA_SET_ELEM_DATA,
+	NFTA_SET_ELEM_FLAGS,
+	__NFTA_SET_ELEM_MAX
+};
+#define NFTA_SET_ELEM_MAX	(__NFTA_SET_ELEM_MAX - 1)
+
+/**
+ * enum nft_set_elem_list_attributes - nf_tables set element list netlink attributes
+ *
+ * @NFTA_SET_ELEM_LIST_TABLE: table of the set to be changed (NLA_STRING)
+ * @NFTA_SET_ELEM_LIST_SET: name of the set to be changed (NLA_STRING)
+ * @NFTA_SET_ELEM_LIST_ELEMENTS: list of set elements (NLA_NESTED: nft_set_elem_attributes)
+ */
+enum nft_set_elem_list_attributes {
+	NFTA_SET_ELEM_LIST_UNSPEC,
+	NFTA_SET_ELEM_LIST_TABLE,
+	NFTA_SET_ELEM_LIST_SET,
+	NFTA_SET_ELEM_LIST_ELEMENTS,
+	__NFTA_SET_ELEM_LIST_MAX
+};
+#define NFTA_SET_ELEM_LIST_MAX	(__NFTA_SET_ELEM_LIST_MAX - 1)
+
+/**
+ * enum nft_data_types - nf_tables data types
+ *
+ * @NFT_DATA_VALUE: generic data
+ * @NFT_DATA_VERDICT: netfilter verdict
+ *
+ * The type of data is usually determined by the kernel directly and is not
+ * explicitly specified by userspace. The only difference are sets, where
+ * userspace specifies the key and mapping data types.
+ *
+ * The values 0xffffff00-0xffffffff are reserved for internally used types.
+ * The remaining range can be freely used by userspace to encode types, all
+ * values are equivalent to NFT_DATA_VALUE.
+ */
+enum nft_data_types {
+	NFT_DATA_VALUE,
+	NFT_DATA_VERDICT	= 0xffffff00U,
+};
+
+#define NFT_DATA_RESERVED_MASK	0xffffff00U
+
+/**
+ * enum nft_data_attributes - nf_tables data netlink attributes
+ *
+ * @NFTA_DATA_VALUE: generic data (NLA_BINARY)
+ * @NFTA_DATA_VERDICT: nf_tables verdict (NLA_NESTED: nft_verdict_attributes)
+ */
 enum nft_data_attributes {
 	NFTA_DATA_UNSPEC,
 	NFTA_DATA_VALUE,
@@ -275,58 +399,21 @@ enum nft_cmp_attributes {
 };
 #define NFTA_CMP_MAX		(__NFTA_CMP_MAX - 1)
 
-enum nft_set_elem_flags {
-	NFT_SE_INTERVAL_END	= 0x1,
-};
-
-enum nft_set_elem_attributes {
-	NFTA_SE_UNSPEC,
-	NFTA_SE_KEY,
-	NFTA_SE_DATA,
-	NFTA_SE_FLAGS,
-	__NFTA_SE_MAX
-};
-#define NFTA_SE_MAX		(__NFTA_SE_MAX - 1)
-
-enum nft_set_flags {
-	NFT_SET_INTERVAL	= 0x1,
-	NFT_SET_MAP		= 0x2,
-};
-
-enum nft_set_attributes {
-	NFTA_SET_UNSPEC,
-	NFTA_SET_FLAGS,
-	NFTA_SET_SREG,
-	NFTA_SET_DREG,
-	NFTA_SET_KLEN,
-	NFTA_SET_DLEN,
-	NFTA_SET_ELEMENTS,
-	__NFTA_SET_MAX
-};
-#define NFTA_SET_MAX		(__NFTA_SET_MAX - 1)
-
-enum nft_hash_flags {
-	NFT_HASH_MAP		= 0x1,
-};
-
-enum nft_hash_elem_attributes {
-	NFTA_HE_UNSPEC,
-	NFTA_HE_KEY,
-	NFTA_HE_DATA,
-	__NFTA_HE_MAX
-};
-#define NFTA_HE_MAX		(__NFTA_HE_MAX - 1)
-
-enum nft_hash_attributes {
-	NFTA_HASH_UNSPEC,
-	NFTA_HASH_FLAGS,
-	NFTA_HASH_SREG,
-	NFTA_HASH_DREG,
-	NFTA_HASH_KLEN,
-	NFTA_HASH_ELEMENTS,
-	__NFTA_HASH_MAX
-};
-#define NFTA_HASH_MAX		(__NFTA_HASH_MAX - 1)
+/**
+ * enum nft_lookup_attributes - nf_tables set lookup expression netlink attributes
+ *
+ * @NFTA_LOOKUP_SET: name of the set where to look for (NLA_STRING)
+ * @NFTA_LOOKUP_SREG: source register of the data to look for (NLA_U32: nft_registers)
+ * @NFTA_LOOKUP_DREG: destination register (NLA_U32: nft_registers)
+ */
+enum nft_lookup_attributes {
+	NFTA_LOOKUP_UNSPEC,
+	NFTA_LOOKUP_SET,
+	NFTA_LOOKUP_SREG,
+	NFTA_LOOKUP_DREG,
+	__NFTA_LOOKUP_MAX
+};
+#define NFTA_LOOKUP_MAX		(__NFTA_LOOKUP_MAX - 1)
 
 /**
  * enum nft_payload_bases - nf_tables payload expression offset bases
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c271e1a..aa184a46 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -430,13 +430,13 @@ config NFT_CT
 	depends on NF_CONNTRACK
 	tristate "Netfilter nf_tables conntrack module"
 
-config NFT_SET
+config NFT_RBTREE
 	depends on NF_TABLES
-	tristate "Netfilter nf_tables set module"
+	tristate "Netfilter nf_tables rbtree set module"
 
 config NFT_HASH
 	depends on NF_TABLES
-	tristate "Netfilter nf_tables hash module"
+	tristate "Netfilter nf_tables hash set module"
 
 config NFT_COUNTER
 	depends on NF_TABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 1ca3f39..b6b7875 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -75,7 +75,7 @@ obj-$(CONFIG_NFT_META)		+= nft_meta.o
 obj-$(CONFIG_NFT_CT)		+= nft_ct.o
 obj-$(CONFIG_NFT_LIMIT)		+= nft_limit.o
 #nf_tables-objs			+= nft_meta_target.o
-obj-$(CONFIG_NFT_SET)		+= nft_set.o
+obj-$(CONFIG_NFT_RBTREE)	+= nft_rbtree.o
 obj-$(CONFIG_NFT_HASH)		+= nft_hash.o
 obj-$(CONFIG_NFT_COUNTER)	+= nft_counter.o
 obj-$(CONFIG_NFT_LOG)		+= nft_log.o
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7d59c89..5092c81 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007, 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2007-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -315,6 +315,7 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 
 	nla_strlcpy(table->name, name, nla_len(name));
 	INIT_LIST_HEAD(&table->chains);
+	INIT_LIST_HEAD(&table->sets);
 
 	list_add_tail(&table->list, &afi->tables);
 	nf_tables_table_notify(skb, nlh, table, NFT_MSG_NEWTABLE, family);
@@ -409,6 +410,7 @@ again:
 	}
 
 	table->flags |= NFT_TABLE_BUILTIN;
+	INIT_LIST_HEAD(&table->sets);
 	list_add_tail(&table->list, &afi->tables);
 	nf_tables_table_notify(NULL, NULL, table, NFT_MSG_NEWTABLE, family);
 	list_for_each_entry(chain, &table->chains, list)
@@ -820,10 +822,14 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 }
 
 static void nft_ctx_init(struct nft_ctx *ctx,
+			 const struct sk_buff *skb,
+			 const struct nlmsghdr *nlh,
 			 const struct nft_af_info *afi,
 			 const struct nft_table *table,
 			 const struct nft_chain *chain)
 {
+	ctx->skb   = skb;
+	ctx->nlh   = nlh;
 	ctx->afi   = afi;
 	ctx->table = table;
 	ctx->chain = chain;
@@ -1301,7 +1307,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	rule->handle = handle;
 	rule->dlen   = size;
 
-	nft_ctx_init(&ctx, afi, table, chain);
+	nft_ctx_init(&ctx, skb, nlh, afi, table, chain);
 	expr = nft_expr_first(rule);
 	for (i = 0; i < n; i++) {
 		err = nf_tables_newexpr(&ctx, &info[i], expr);
@@ -1392,6 +1398,939 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 	return 0;
 }
 
+/*
+ * Sets
+ */
+
+static LIST_HEAD(nf_tables_set_ops);
+
+int nft_register_set(struct nft_set_ops *ops)
+{
+	nfnl_lock(NFNL_SUBSYS_NFTABLES);
+	list_add_tail(&ops->list, &nf_tables_set_ops);
+	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nft_register_set);
+
+void nft_unregister_set(struct nft_set_ops *ops)
+{
+	nfnl_lock(NFNL_SUBSYS_NFTABLES);
+	list_del(&ops->list);
+	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
+}
+EXPORT_SYMBOL_GPL(nft_unregister_set);
+
+static const struct nft_set_ops *nft_select_set_ops(const struct nlattr * const nla[])
+{
+	const struct nft_set_ops *ops;
+	u32 features;
+
+#ifdef CONFIG_MODULES
+	if (list_empty(&nf_tables_set_ops)) {
+		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
+		request_module("nft-set");
+		nfnl_lock(NFNL_SUBSYS_NFTABLES);
+		if (!list_empty(&nf_tables_set_ops))
+			return ERR_PTR(-EAGAIN);
+	}
+#endif
+	features = 0;
+	if (nla[NFTA_SET_FLAGS] != NULL) {
+		features = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
+		features &= NFT_SET_INTERVAL | NFT_SET_MAP;
+	}
+
+	// FIXME: implement selection properly
+	list_for_each_entry(ops, &nf_tables_set_ops, list) {
+		if ((ops->features & features) != features)
+			continue;
+		if (!try_module_get(ops->owner))
+			continue;
+		return ops;
+	}
+
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static const struct nla_policy nft_set_policy[NFTA_SET_MAX + 1] = {
+	[NFTA_SET_TABLE]		= { .type = NLA_STRING },
+	[NFTA_SET_NAME]			= { .type = NLA_STRING },
+	[NFTA_SET_FLAGS]		= { .type = NLA_U32 },
+	[NFTA_SET_KEY_TYPE]		= { .type = NLA_U32 },
+	[NFTA_SET_KEY_LEN]		= { .type = NLA_U32 },
+	[NFTA_SET_DATA_TYPE]		= { .type = NLA_U32 },
+	[NFTA_SET_DATA_LEN]		= { .type = NLA_U32 },
+};
+
+static int nft_ctx_init_from_setattr(struct nft_ctx *ctx,
+				     const struct sk_buff *skb,
+				     const struct nlmsghdr *nlh,
+				     const struct nlattr * const nla[])
+{
+	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
+	const struct nft_af_info *afi;
+	const struct nft_table *table = NULL;
+
+	afi = nf_tables_afinfo_lookup(nfmsg->nfgen_family, false);
+	if (IS_ERR(afi))
+		return PTR_ERR(afi);
+
+	if (nla[NFTA_SET_TABLE] != NULL) {
+		table = nf_tables_table_lookup(afi, nla[NFTA_SET_TABLE], false);
+		if (IS_ERR(table))
+			return PTR_ERR(table);
+	}
+
+	nft_ctx_init(ctx, skb, nlh, afi, table, NULL);
+	return 0;
+}
+
+struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
+				     const struct nlattr *nla)
+{
+	struct nft_set *set;
+
+	if (nla == NULL)
+		return ERR_PTR(-EINVAL);
+
+	list_for_each_entry(set, &table->sets, list) {
+		if (!nla_strcmp(nla, set->name))
+			return set;
+	}
+	return ERR_PTR(-ENOENT);
+}
+
+static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
+				    const char *name)
+{
+	const struct nft_set *i;
+	const char *p;
+	unsigned long *inuse;
+	unsigned int n = 0;
+
+	p = strnchr(name, IFNAMSIZ, '%');
+	if (p != NULL) {
+		if (p[1] != 'd' || strchr(p + 2, '%'))
+			return -EINVAL;
+
+		inuse = (unsigned long *)get_zeroed_page(GFP_KERNEL);
+		if (inuse == NULL)
+			return -ENOMEM;
+
+		list_for_each_entry(i, &ctx->table->sets, list) {
+			if (!sscanf(i->name, name, &n))
+				continue;
+			if (n < 0 || n > BITS_PER_LONG * PAGE_SIZE)
+				continue;
+			set_bit(n, inuse);
+		}
+
+		n = find_first_zero_bit(inuse, BITS_PER_LONG * PAGE_SIZE);
+		free_page((unsigned long)inuse);
+	}
+
+	snprintf(set->name, sizeof(set->name), name, n);
+	list_for_each_entry(i, &ctx->table->sets, list) {
+		if (!strcmp(set->name, i->name))
+			return -ENFILE;
+	}
+	return 0;
+}
+
+static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
+			      const struct nft_set *set, u16 event, u16 flags)
+{
+	struct nfgenmsg *nfmsg;
+	struct nlmsghdr *nlh;
+	u32 portid = NETLINK_CB(ctx->skb).portid;
+	u32 seq = ctx->nlh->nlmsg_seq;
+
+	event |= NFNL_SUBSYS_NFTABLES << 8;
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg),
+			flags);
+	if (nlh == NULL)
+		goto nla_put_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family	= ctx->afi->family;
+	nfmsg->version		= NFNETLINK_V0;
+	nfmsg->res_id		= 0;
+
+	if (nla_put_string(skb, NFTA_SET_TABLE, ctx->table->name))
+		goto nla_put_failure;
+	if (nla_put_string(skb, NFTA_SET_NAME, set->name))
+		goto nla_put_failure;
+	if (set->flags != 0)
+		if (nla_put_be32(skb, NFTA_SET_FLAGS, htonl(set->flags)))
+			goto nla_put_failure;
+
+	if (nla_put_be32(skb, NFTA_SET_KEY_TYPE, htonl(set->ktype)))
+		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_SET_KEY_LEN, htonl(set->klen)))
+		goto nla_put_failure;
+	if (set->flags & NFT_SET_MAP) {
+		if (nla_put_be32(skb, NFTA_SET_DATA_TYPE, htonl(set->dtype)))
+			goto nla_put_failure;
+		if (nla_put_be32(skb, NFTA_SET_DATA_LEN, htonl(set->dlen)))
+			goto nla_put_failure;
+	}
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_trim(skb, nlh);
+	return -1;
+}
+
+static int nf_tables_set_notify(const struct nft_ctx *ctx,
+				const struct nft_set *set,
+				int event)
+{
+	struct sk_buff *skb;
+	u32 portid = NETLINK_CB(ctx->skb).portid;
+	struct net *net = sock_net(ctx->skb->sk);
+	bool report;
+	int err;
+
+	report = nlmsg_report(ctx->nlh);
+	if (!report && !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
+		return 0;
+
+	err = -ENOBUFS;
+	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb == NULL)
+		goto err;
+
+	err = nf_tables_fill_set(skb, ctx, set, event, 0);
+	if (err < 0) {
+		kfree_skb(skb);
+		goto err;
+	}
+
+	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, report,
+			     GFP_KERNEL);
+err:
+	if (err < 0)
+		nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, err);
+	return err;
+}
+
+static int nf_tables_dump_sets_table(struct nft_ctx *ctx, struct sk_buff *skb,
+				     struct netlink_callback *cb)
+{
+	const struct nft_set *set;
+	unsigned int idx = 0, s_idx = cb->args[0];
+
+	if (cb->args[1])
+		return skb->len;
+
+	list_for_each_entry(set, &ctx->table->sets, list) {
+		if (idx < s_idx)
+			goto cont;
+		if (nf_tables_fill_set(skb, ctx, set, NFT_MSG_NEWSET,
+				       NLM_F_MULTI) < 0) {
+			cb->args[0] = idx;
+			goto done;
+		}
+cont:
+		idx++;
+	}
+	cb->args[1] = 1;
+done:
+	return skb->len;
+}
+
+static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff *skb,
+				   struct netlink_callback *cb)
+{
+	const struct nft_set *set;
+	unsigned int idx = 0, s_idx = cb->args[0];
+	struct nft_table *table, *cur_table = (struct nft_table *)cb->args[2];
+
+	if (cb->args[1])
+		return skb->len;
+
+	list_for_each_entry(table, &ctx->afi->tables, list) {
+		if (cur_table && cur_table != table)
+			continue;
+
+		ctx->table = table;
+		list_for_each_entry(set, &ctx->table->sets, list) {
+			if (idx < s_idx)
+				goto cont;
+			if (nf_tables_fill_set(skb, ctx, set, NFT_MSG_NEWSET,
+					       NLM_F_MULTI) < 0) {
+				cb->args[0] = idx;
+				cb->args[2] = (unsigned long) table;
+				goto done;
+			}
+cont:
+			idx++;
+		}
+	}
+	cb->args[1] = 1;
+done:
+	return skb->len;
+}
+
+static int nf_tables_dump_sets(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	const struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
+	struct nlattr *nla[NFTA_SET_MAX + 1];
+	struct nft_ctx ctx;
+	int err, ret;
+
+	err = nlmsg_parse(cb->nlh, sizeof(*nfmsg), nla, NFTA_SET_MAX,
+			  nft_set_policy);
+	if (err < 0)
+		return err;
+
+	err = nft_ctx_init_from_setattr(&ctx, cb->skb, cb->nlh, (void *)nla);
+	if (err < 0)
+		return err;
+
+	if (ctx.table == NULL)
+		ret = nf_tables_dump_sets_all(&ctx, skb, cb);
+	else
+		ret = nf_tables_dump_sets_table(&ctx, skb, cb);
+
+	return ret;
+}
+
+static int nf_tables_getset(struct sock *nlsk, struct sk_buff *skb,
+			    const struct nlmsghdr *nlh,
+			    const struct nlattr * const nla[])
+{
+	const struct nft_set *set;
+	struct nft_ctx ctx;
+	struct sk_buff *skb2;
+	int err;
+
+	/* Verify existance before starting dump */
+	err = nft_ctx_init_from_setattr(&ctx, skb, nlh, nla);
+	if (err < 0)
+		return err;
+
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = nf_tables_dump_sets,
+		};
+		return netlink_dump_start(nlsk, skb, nlh, &c);
+	}
+
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME]);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
+
+	skb2 = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb2 == NULL)
+		return -ENOMEM;
+
+	err = nf_tables_fill_set(skb2, &ctx, set, NFT_MSG_NEWSET, 0);
+	if (err < 0)
+		goto err;
+
+	return nlmsg_unicast(nlsk, skb2, NETLINK_CB(skb).portid);
+
+err:
+	kfree_skb(skb2);
+	return err;
+}
+
+static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
+			    const struct nlmsghdr *nlh,
+			    const struct nlattr * const nla[])
+{
+	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
+	const struct nft_set_ops *ops;
+	const struct nft_af_info *afi;
+	struct nft_table *table;
+	struct nft_set *set;
+	struct nft_ctx ctx;
+	char name[IFNAMSIZ];
+	unsigned int size;
+	bool create;
+	u32 ktype, klen, dlen, dtype, flags;
+	int err;
+
+	if (nla[NFTA_SET_TABLE] == NULL ||
+	    nla[NFTA_SET_NAME] == NULL ||
+	    nla[NFTA_SET_KEY_LEN] == NULL)
+		return -EINVAL;
+
+	ktype = NFT_DATA_VALUE;
+	if (nla[NFTA_SET_KEY_TYPE] != NULL) {
+		ktype = ntohl(nla_get_be32(nla[NFTA_SET_KEY_TYPE]));
+		if ((ktype & NFT_DATA_RESERVED_MASK) == NFT_DATA_RESERVED_MASK)
+			return -EINVAL;
+	}
+
+	klen = ntohl(nla_get_be32(nla[NFTA_SET_KEY_LEN]));
+	if (klen == 0 || klen > FIELD_SIZEOF(struct nft_data, data))
+		return -EINVAL;
+
+	flags = 0;
+	if (nla[NFTA_SET_FLAGS] != NULL) {
+		flags = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
+		if (flags & ~(NFT_SET_ANONYMOUS | NFT_SET_CONSTANT |
+			      NFT_SET_INTERVAL | NFT_SET_MAP))
+			return -EINVAL;
+	}
+
+	dtype = 0;
+	dlen  = 0;
+	if (nla[NFTA_SET_DATA_TYPE] != NULL) {
+		if (!(flags & NFT_SET_MAP))
+			return -EINVAL;
+
+		dtype = ntohl(nla_get_be32(nla[NFTA_SET_DATA_TYPE]));
+		if ((dtype & NFT_DATA_RESERVED_MASK) == NFT_DATA_RESERVED_MASK &&
+		    dtype != NFT_DATA_VERDICT)
+			return -EINVAL;
+
+		if (dtype != NFT_DATA_VERDICT) {
+			if (nla[NFTA_SET_DATA_LEN] == NULL)
+				return -EINVAL;
+			dlen = ntohl(nla_get_be32(nla[NFTA_SET_DATA_LEN]));
+			if (dlen == 0 ||
+			    dlen > FIELD_SIZEOF(struct nft_data, data))
+				return -EINVAL;
+		} else
+			dlen = sizeof(struct nft_data);
+	} else if (flags & NFT_SET_MAP)
+		return -EINVAL;
+
+	create = nlh->nlmsg_flags & NLM_F_CREATE ? true : false;
+
+	afi = nf_tables_afinfo_lookup(nfmsg->nfgen_family, create);
+	if (IS_ERR(afi))
+		return PTR_ERR(afi);
+
+	table = nf_tables_table_lookup(afi, nla[NFTA_SET_TABLE], create);
+	if (IS_ERR(table))
+		return PTR_ERR(table);
+
+	nft_ctx_init(&ctx, skb, nlh, afi, table, NULL);
+
+	set = nf_tables_set_lookup(table, nla[NFTA_SET_NAME]);
+	if (IS_ERR(set)) {
+		if (PTR_ERR(set) != -ENOENT)
+			return PTR_ERR(set);
+		set = NULL;
+	}
+
+	if (set != NULL) {
+		if (nlh->nlmsg_flags & NLM_F_EXCL)
+			return -EEXIST;
+		if (nlh->nlmsg_flags & NLM_F_REPLACE)
+			return -EOPNOTSUPP;
+		return 0;
+	}
+
+	if (!(nlh->nlmsg_flags & NLM_F_CREATE))
+		return -ENOENT;
+
+	ops = nft_select_set_ops(nla);
+	if (IS_ERR(ops))
+		return PTR_ERR(ops);
+
+	size = 0;
+	if (ops->privsize != NULL)
+		size = ops->privsize(nla);
+
+	err = -ENOMEM;
+	set = kzalloc(sizeof(*set) + size, GFP_KERNEL);
+	if (set == NULL)
+		goto err1;
+
+	nla_strlcpy(name, nla[NFTA_SET_NAME], sizeof(set->name));
+	err = nf_tables_set_alloc_name(&ctx, set, name);
+	if (err < 0)
+		goto err2;
+
+	INIT_LIST_HEAD(&set->bindings);
+	set->ops   = ops;
+	set->ktype = ktype;
+	set->klen  = klen;
+	set->dtype = dtype;
+	set->dlen  = dlen;
+	set->flags = flags;
+
+	err = ops->init(set, nla);
+	if (err < 0)
+		goto err2;
+
+	list_add_tail(&set->list, &table->sets);
+	nf_tables_set_notify(&ctx, set, NFT_MSG_NEWSET);
+	return 0;
+
+err2:
+	kfree(set);
+err1:
+	module_put(ops->owner);
+	return err;
+}
+
+static void nf_tables_set_destroy(const struct nft_ctx *ctx, struct nft_set *set)
+{
+	list_del(&set->list);
+	if (!(set->flags & NFT_SET_ANONYMOUS))
+		nf_tables_set_notify(ctx, set, NFT_MSG_DELSET);
+
+	set->ops->destroy(set);
+	module_put(set->ops->owner);
+	kfree(set);
+}
+
+static int nf_tables_delset(struct sock *nlsk, struct sk_buff *skb,
+			    const struct nlmsghdr *nlh,
+			    const struct nlattr * const nla[])
+{
+	struct nft_set *set;
+	struct nft_ctx ctx;
+	int err;
+
+	if (nla[NFTA_SET_TABLE] == NULL)
+		return -EINVAL;
+
+	err = nft_ctx_init_from_setattr(&ctx, skb, nlh, nla);
+	if (err < 0)
+		return err;
+
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME]);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
+	if (!list_empty(&set->bindings))
+		return -EBUSY;
+
+	nf_tables_set_destroy(&ctx, set);
+	return 0;
+}
+
+static int nf_tables_bind_check_setelem(const struct nft_ctx *ctx,
+					const struct nft_set *set,
+					const struct nft_set_iter *iter,
+					const struct nft_set_elem *elem)
+{
+	enum nft_registers dreg;
+
+	dreg = nft_type_to_reg(set->dtype);
+	return nft_validate_data_load(ctx, dreg, &elem->data, set->dtype);
+}
+
+int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
+		       struct nft_set_binding *binding)
+{
+	struct nft_set_binding *i;
+	struct nft_set_iter iter;
+
+	if (!list_empty(&set->bindings) && set->flags & NFT_SET_ANONYMOUS)
+		return -EBUSY;
+
+	if (set->flags & NFT_SET_MAP) {
+		/* If the set is already bound to the same chain all
+		 * jumps are already validated for that chain.
+		 */
+		list_for_each_entry(i, &set->bindings, list) {
+			if (i->chain == binding->chain)
+				goto bind;
+		}
+
+		iter.skip 	= 0;
+		iter.count	= 0;
+		iter.err	= 0;
+		iter.fn		= nf_tables_bind_check_setelem;
+
+		set->ops->walk(ctx, set, &iter);
+		if (iter.err < 0) {
+			/* Destroy anonymous sets if binding fails */
+			if (set->flags & NFT_SET_ANONYMOUS)
+				nf_tables_set_destroy(ctx, set);
+
+			return iter.err;
+		}
+	}
+bind:
+	binding->chain = ctx->chain;
+	list_add_tail(&binding->list, &set->bindings);
+	return 0;
+}
+
+void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
+			  struct nft_set_binding *binding)
+{
+	list_del(&binding->list);
+
+	if (list_empty(&set->bindings) && set->flags & NFT_SET_ANONYMOUS)
+		nf_tables_set_destroy(ctx, set);
+}
+
+/*
+ * Set elements
+ */
+
+static const struct nla_policy nft_set_elem_policy[NFTA_SET_ELEM_MAX + 1] = {
+	[NFTA_SET_ELEM_KEY]		= { .type = NLA_NESTED },
+	[NFTA_SET_ELEM_DATA]		= { .type = NLA_NESTED },
+	[NFTA_SET_ELEM_FLAGS]		= { .type = NLA_U32 },
+};
+
+static const struct nla_policy nft_set_elem_list_policy[NFTA_SET_ELEM_LIST_MAX + 1] = {
+	[NFTA_SET_ELEM_LIST_TABLE]	= { .type = NLA_STRING },
+	[NFTA_SET_ELEM_LIST_SET]	= { .type = NLA_STRING },
+	[NFTA_SET_ELEM_LIST_ELEMENTS]	= { .type = NLA_NESTED },
+};
+
+static int nft_ctx_init_from_elemattr(struct nft_ctx *ctx,
+				      const struct sk_buff *skb,
+				      const struct nlmsghdr *nlh,
+				      const struct nlattr * const nla[])
+{
+	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
+	const struct nft_af_info *afi;
+	const struct nft_table *table;
+
+	afi = nf_tables_afinfo_lookup(nfmsg->nfgen_family, false);
+	if (IS_ERR(afi))
+		return PTR_ERR(afi);
+
+	table = nf_tables_table_lookup(afi, nla[NFTA_SET_ELEM_LIST_TABLE], false);
+	if (IS_ERR(table))
+		return PTR_ERR(table);
+
+	nft_ctx_init(ctx, skb, nlh, afi, table, NULL);
+	return 0;
+}
+
+static int nf_tables_fill_setelem(struct sk_buff *skb,
+				  const struct nft_set *set,
+				  const struct nft_set_elem *elem)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, NFTA_LIST_ELEM);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	if (nft_data_dump(skb, NFTA_SET_ELEM_KEY, &elem->key, NFT_DATA_VALUE,
+			  set->klen) < 0)
+		goto nla_put_failure;
+
+	if (set->flags & NFT_SET_MAP &&
+	    !(elem->flags & NFT_SET_ELEM_INTERVAL_END) &&
+	    nft_data_dump(skb, NFTA_SET_ELEM_DATA, &elem->data,
+			  set->dtype == NFT_DATA_VERDICT ? NFT_DATA_VERDICT : NFT_DATA_VALUE,
+			  set->dlen) < 0)
+		goto nla_put_failure;
+
+	if (elem->flags != 0)
+		if (nla_put_be32(skb, NFTA_SET_ELEM_FLAGS, htonl(elem->flags)))
+			goto nla_put_failure;
+
+	nla_nest_end(skb, nest);
+	return 0;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -EMSGSIZE;
+}
+
+struct nft_set_dump_args {
+	const struct netlink_callback	*cb;
+	struct nft_set_iter		iter;
+	struct sk_buff			*skb;
+};
+
+static int nf_tables_dump_setelem(const struct nft_ctx *ctx,
+				  const struct nft_set *set,
+				  const struct nft_set_iter *iter,
+				  const struct nft_set_elem *elem)
+{
+	struct nft_set_dump_args *args;
+
+	args = container_of(iter, struct nft_set_dump_args, iter);
+	return nf_tables_fill_setelem(args->skb, set, elem);
+}
+
+static int nf_tables_dump_set(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	const struct nft_set *set;
+	struct nft_set_dump_args args;
+	struct nft_ctx ctx;
+	struct nlattr *nla[NFTA_SET_ELEM_LIST_MAX + 1];
+	struct nfgenmsg *nfmsg;
+	struct nlmsghdr *nlh;
+	struct nlattr *nest;
+	u32 portid, seq;
+	int event, err;
+
+	nfmsg = nlmsg_data(cb->nlh);
+	err = nlmsg_parse(cb->nlh, sizeof(*nfmsg), nla, NFTA_SET_ELEM_LIST_MAX,
+			  nft_set_elem_list_policy);
+	if (err < 0)
+		return err;
+
+	err = nft_ctx_init_from_elemattr(&ctx, cb->skb, cb->nlh, (void *)nla);
+	if (err < 0)
+		return err;
+
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET]);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
+
+	event  = NFT_MSG_NEWSETELEM;
+	event |= NFNL_SUBSYS_NFTABLES << 8;
+	portid = NETLINK_CB(cb->skb).portid;
+	seq    = cb->nlh->nlmsg_seq;
+
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg),
+			NLM_F_MULTI);
+	if (nlh == NULL)
+		goto nla_put_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = NFPROTO_UNSPEC;
+	nfmsg->version      = NFNETLINK_V0;
+	nfmsg->res_id       = 0;
+
+	if (nla_put_string(skb, NFTA_SET_ELEM_LIST_TABLE, ctx.table->name))
+		goto nla_put_failure;
+	if (nla_put_string(skb, NFTA_SET_ELEM_LIST_SET, set->name))
+		goto nla_put_failure;
+
+	nest = nla_nest_start(skb, NFTA_SET_ELEM_LIST_ELEMENTS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	args.cb		= cb;
+	args.skb	= skb;
+	args.iter.skip	= cb->args[0];
+	args.iter.count	= 0;
+	args.iter.err   = 0;
+	args.iter.fn	= nf_tables_dump_setelem;
+	set->ops->walk(&ctx, set, &args.iter);
+
+	nla_nest_end(skb, nest);
+	nlmsg_end(skb, nlh);
+
+	if (args.iter.err && args.iter.err != -EMSGSIZE)
+		return args.iter.err;
+	if (args.iter.count == cb->args[0])
+		return 0;
+
+	cb->args[0] = args.iter.count;
+	return skb->len;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static int nf_tables_getsetelem(struct sock *nlsk, struct sk_buff *skb,
+				const struct nlmsghdr *nlh,
+				const struct nlattr * const nla[])
+{
+	const struct nft_set *set;
+	struct nft_ctx ctx;
+	int err;
+
+	err = nft_ctx_init_from_elemattr(&ctx, skb, nlh, nla);
+	if (err < 0)
+		return err;
+
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET]);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
+
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = nf_tables_dump_set,
+		};
+		return netlink_dump_start(nlsk, skb, nlh, &c);
+	}
+	return -EOPNOTSUPP;
+}
+
+static int nft_add_set_elem(const struct nft_ctx *ctx, struct nft_set *set,
+			    const struct nlattr *attr)
+{
+	struct nlattr *nla[NFTA_SET_ELEM_MAX + 1];
+	struct nft_data_desc d1, d2;
+	struct nft_set_elem elem;
+	struct nft_set_binding *binding;
+	enum nft_registers dreg;
+	int err;
+
+	err = nla_parse_nested(nla, NFTA_SET_ELEM_MAX, attr,
+			       nft_set_elem_policy);
+	if (err < 0)
+		return err;
+
+	if (nla[NFTA_SET_ELEM_KEY] == NULL)
+		return -EINVAL;
+
+	elem.flags = 0;
+	if (nla[NFTA_SET_ELEM_FLAGS] != NULL) {
+		elem.flags = ntohl(nla_get_be32(nla[NFTA_SET_ELEM_FLAGS]));
+		if (elem.flags & ~NFT_SET_ELEM_INTERVAL_END)
+			return -EINVAL;
+	}
+
+	if (set->flags & NFT_SET_MAP) {
+		if (nla[NFTA_SET_ELEM_DATA] == NULL &&
+		    !(elem.flags & NFT_SET_ELEM_INTERVAL_END))
+			return -EINVAL;
+	} else {
+		if (nla[NFTA_SET_ELEM_DATA] != NULL)
+			return -EINVAL;
+	}
+
+	err = nft_data_init(ctx, &elem.key, &d1, nla[NFTA_SET_ELEM_KEY]);
+	if (err < 0)
+		goto err1;
+	err = -EINVAL;
+	if (d1.type != NFT_DATA_VALUE || d1.len != set->klen)
+		goto err2;
+
+	err = -EEXIST;
+	if (set->ops->get(set, &elem) == 0)
+		goto err2;
+
+	if (nla[NFTA_SET_ELEM_DATA] != NULL) {
+		err = nft_data_init(ctx, &elem.data, &d2, nla[NFTA_SET_ELEM_DATA]);
+		if (err < 0)
+			goto err2;
+
+		err = -EINVAL;
+		if (set->dtype != NFT_DATA_VERDICT && d2.len != set->dlen)
+			goto err3;
+
+		dreg = nft_type_to_reg(set->dtype);
+		list_for_each_entry(binding, &set->bindings, list) {
+			struct nft_ctx bind_ctx = {
+				.afi	= ctx->afi,
+				.table	= ctx->table,
+				.chain	= binding->chain,
+			};
+
+			err = nft_validate_data_load(&bind_ctx, dreg,
+						     &elem.data, d2.type);
+			if (err < 0)
+				goto err3;
+		}
+	}
+
+	err = set->ops->insert(set, &elem);
+	if (err < 0)
+		goto err3;
+
+	return 0;
+
+err3:
+	if (nla[NFTA_SET_ELEM_DATA] != NULL)
+		nft_data_uninit(&elem.data, d2.type);
+err2:
+	nft_data_uninit(&elem.key, d1.type);
+err1:
+	return err;
+}
+
+static int nf_tables_newsetelem(struct sock *nlsk, struct sk_buff *skb,
+				const struct nlmsghdr *nlh,
+				const struct nlattr * const nla[])
+{
+	const struct nlattr *attr;
+	struct nft_set *set;
+	struct nft_ctx ctx;
+	int rem, err;
+
+	err = nft_ctx_init_from_elemattr(&ctx, skb, nlh, nla);
+	if (err < 0)
+		return err;
+
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET]);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
+	if (!list_empty(&set->bindings) && set->flags & NFT_SET_CONSTANT)
+		return -EBUSY;
+
+	nla_for_each_nested(attr, nla[NFTA_SET_ELEM_LIST_ELEMENTS], rem) {
+		err = nft_add_set_elem(&ctx, set, attr);
+		if (err < 0)
+			return err;
+	}
+	return 0;
+}
+
+static int nft_del_setelem(const struct nft_ctx *ctx, struct nft_set *set,
+			   const struct nlattr *attr)
+{
+	struct nlattr *nla[NFTA_SET_ELEM_MAX + 1];
+	struct nft_data_desc desc;
+	struct nft_set_elem elem;
+	int err;
+
+	err = nla_parse_nested(nla, NFTA_SET_ELEM_MAX, attr,
+			       nft_set_elem_policy);
+	if (err < 0)
+		goto err1;
+
+	err = -EINVAL;
+	if (nla[NFTA_SET_ELEM_KEY] == NULL)
+		goto err1;
+
+	err = nft_data_init(ctx, &elem.key, &desc, nla[NFTA_SET_ELEM_KEY]);
+	if (err < 0)
+		goto err1;
+
+	err = -EINVAL;
+	if (desc.type != NFT_DATA_VALUE || desc.len != set->klen)
+		goto err2;
+
+	err = set->ops->get(set, &elem);
+	if (err < 0)
+		goto err2;
+
+	set->ops->remove(set, &elem);
+
+	nft_data_uninit(&elem.key, NFT_DATA_VALUE);
+	if (set->flags & NFT_SET_MAP)
+		nft_data_uninit(&elem.data, set->dtype);
+
+err2:
+	nft_data_uninit(&elem.key, desc.type);
+err1:
+	return err;
+}
+
+static int nf_tables_delsetelem(struct sock *nlsk, struct sk_buff *skb,
+				const struct nlmsghdr *nlh,
+				const struct nlattr * const nla[])
+{
+	const struct nlattr *attr;
+	struct nft_set *set;
+	struct nft_ctx ctx;
+	int rem, err;
+
+	err = nft_ctx_init_from_elemattr(&ctx, skb, nlh, nla);
+	if (err < 0)
+		return err;
+
+	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_ELEM_LIST_SET]);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
+	if (!list_empty(&set->bindings) && set->flags & NFT_SET_CONSTANT)
+		return -EBUSY;
+
+	nla_for_each_nested(attr, nla[NFTA_SET_ELEM_LIST_ELEMENTS], rem) {
+		err = nft_del_setelem(&ctx, set, attr);
+		if (err < 0)
+			return err;
+	}
+	return 0;
+}
+
 static const struct nfnl_callback nf_tables_cb[NFT_MSG_MAX] = {
 	[NFT_MSG_NEWTABLE] = {
 		.call		= nf_tables_newtable,
@@ -1438,6 +2377,36 @@ static const struct nfnl_callback nf_tables_cb[NFT_MSG_MAX] = {
 		.attr_count	= NFTA_RULE_MAX,
 		.policy		= nft_rule_policy,
 	},
+	[NFT_MSG_NEWSET] = {
+		.call		= nf_tables_newset,
+		.attr_count	= NFTA_SET_MAX,
+		.policy		= nft_set_policy,
+	},
+	[NFT_MSG_GETSET] = {
+		.call		= nf_tables_getset,
+		.attr_count	= NFTA_SET_MAX,
+		.policy		= nft_set_policy,
+	},
+	[NFT_MSG_DELSET] = {
+		.call		= nf_tables_delset,
+		.attr_count	= NFTA_SET_MAX,
+		.policy		= nft_set_policy,
+	},
+	[NFT_MSG_NEWSETELEM] = {
+		.call		= nf_tables_newsetelem,
+		.attr_count	= NFTA_SET_ELEM_LIST_MAX,
+		.policy		= nft_set_elem_list_policy,
+	},
+	[NFT_MSG_GETSETELEM] = {
+		.call		= nf_tables_getsetelem,
+		.attr_count	= NFTA_SET_ELEM_LIST_MAX,
+		.policy		= nft_set_elem_list_policy,
+	},
+	[NFT_MSG_DELSETELEM] = {
+		.call		= nf_tables_delsetelem,
+		.attr_count	= NFTA_SET_ELEM_LIST_MAX,
+		.policy		= nft_set_elem_list_policy,
+	},
 };
 
 static const struct nfnetlink_subsystem nf_tables_subsys = {
@@ -1447,6 +2416,90 @@ static const struct nfnetlink_subsystem nf_tables_subsys = {
 	.cb		= nf_tables_cb,
 };
 
+/*
+ * Loop detection - walk through the ruleset beginning at the destination chain
+ * of a new jump until either the source chain is reached (loop) or all
+ * reachable chains have been traversed.
+ *
+ * The loop check is performed whenever a new jump verdict is added to an
+ * expression or verdict map or a verdict map is bound to a new chain.
+ */
+
+static int nf_tables_check_loops(const struct nft_ctx *ctx,
+				 const struct nft_chain *chain);
+
+static int nf_tables_loop_check_setelem(const struct nft_ctx *ctx,
+					const struct nft_set *set,
+					const struct nft_set_iter *iter,
+					const struct nft_set_elem *elem)
+{
+	switch (elem->data.verdict) {
+	case NFT_JUMP:
+	case NFT_GOTO:
+		return nf_tables_check_loops(ctx, elem->data.chain);
+	default:
+		return 0;
+	}
+}
+
+static int nf_tables_check_loops(const struct nft_ctx *ctx,
+				 const struct nft_chain *chain)
+{
+	const struct nft_rule *rule;
+	const struct nft_expr *expr, *last;
+	const struct nft_data *data;
+	const struct nft_set *set;
+	struct nft_set_binding *binding;
+	struct nft_set_iter iter;
+	int err;
+
+	if (ctx->chain == chain)
+		return -ELOOP;
+
+	list_for_each_entry(rule, &chain->rules, list) {
+		nft_rule_for_each_expr(expr, last, rule) {
+			if (!expr->ops->get_verdict)
+				continue;
+
+			data = expr->ops->get_verdict(expr);
+			if (data == NULL)
+				break;
+
+			switch (data->verdict) {
+			case NFT_JUMP:
+			case NFT_GOTO:
+				err = nf_tables_check_loops(ctx, data->chain);
+				if (err < 0)
+					return err;
+			default:
+				break;
+			}
+		}
+	}
+
+	list_for_each_entry(set, &ctx->table->sets, list) {
+		if (!(set->flags & NFT_SET_MAP) ||
+		    set->dtype != NFT_DATA_VERDICT)
+			continue;
+
+		list_for_each_entry(binding, &set->bindings, list) {
+			if (binding->chain != chain)
+				continue;
+
+			iter.skip 	= 0;
+			iter.count	= 0;
+			iter.err	= 0;
+			iter.fn		= nf_tables_loop_check_setelem;
+
+			set->ops->walk(ctx, set, &iter);
+			if (iter.err < 0)
+				return iter.err;
+		}
+	}
+
+	return 0;
+}
+
 /**
  *	nft_validate_input_register - validate an expressions' input register
  *
@@ -1500,11 +2553,25 @@ int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
 			   const struct nft_data *data,
 			   enum nft_data_types type)
 {
+	int err;
+
 	switch (reg) {
 	case NFT_REG_VERDICT:
 		if (data == NULL || type != NFT_DATA_VERDICT)
 			return -EINVAL;
-		// FIXME: do loop detection
+
+		if (data->verdict == NFT_GOTO || data->verdict == NFT_JUMP) {
+			err = nf_tables_check_loops(ctx, data->chain);
+			if (err < 0)
+				return err;
+
+			if (ctx->chain->level + 1 > data->chain->level) {
+				if (ctx->chain->level + 1 == NFT_JUMP_STACK_SIZE)
+					return -EMLINK;
+				data->chain->level = ctx->chain->level + 1;
+			}
+		}
+
 		return 0;
 	default:
 		if (data != NULL && type != NFT_DATA_VALUE)
@@ -1555,11 +2622,6 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 		if (chain->flags & NFT_BASE_CHAIN)
 			return -EOPNOTSUPP;
 
-		if (ctx->chain->level + 1 > chain->level) {
-			if (ctx->chain->level + 1 == 16)
-				return -EMLINK;
-			chain->level = ctx->chain->level + 1;
-		}
 		chain->use++;
 		data->chain = chain;
 		desc->len = sizeof(data);
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index bc7fb85..fd0ecd3 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -20,8 +20,6 @@
 #include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nf_tables.h>
 
-#define NFT_JUMP_STACK_SIZE	16
-
 unsigned int nft_do_chain(const struct nf_hook_ops *ops,
 			  struct sk_buff *skb,
 			  const struct net_device *in,
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 67cc502..3d3f8fc 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -21,11 +21,6 @@
 struct nft_hash {
 	struct hlist_head	*hash;
 	unsigned int		hsize;
-	enum nft_registers	sreg:8;
-	enum nft_registers	dreg:8;
-	u8			klen;
-	u8			dlen;
-	u16			flags;
 };
 
 struct nft_hash_elem {
@@ -42,213 +37,140 @@ static unsigned int nft_hash_data(const struct nft_data *data,
 {
 	unsigned int h;
 
-	// FIXME: can we reasonably guarantee the upper bits are fixed?
-	h = jhash2(data->data, len >> 2, nft_hash_rnd);
+	h = jhash(data->data, len, nft_hash_rnd);
 	return ((u64)h * hsize) >> 32;
 }
 
-static void nft_hash_eval(const struct nft_expr *expr,
-			  struct nft_data data[NFT_REG_MAX + 1],
-			  const struct nft_pktinfo *pkt)
+static bool nft_hash_lookup(const struct nft_set *set,
+			    const struct nft_data *key,
+			    struct nft_data *data)
 {
-	const struct nft_hash *priv = nft_expr_priv(expr);
-	const struct nft_hash_elem *elem;
-	const struct nft_data *key = &data[priv->sreg];
+	const struct nft_hash *priv = nft_set_priv(set);
+	const struct nft_hash_elem *he;
 	unsigned int h;
 
-	h = nft_hash_data(key, priv->hsize, priv->klen);
-	hlist_for_each_entry(elem, &priv->hash[h], hnode) {
-		if (nft_data_cmp(&elem->key, key, priv->klen))
+	h = nft_hash_data(key, priv->hsize, set->klen);
+	hlist_for_each_entry(he, &priv->hash[h], hnode) {
+		if (nft_data_cmp(&he->key, key, set->klen))
 			continue;
-		if (priv->flags & NFT_HASH_MAP)
-			nft_data_copy(&data[priv->dreg], elem->data);
-		return;
+		if (set->flags & NFT_SET_MAP)
+			nft_data_copy(data, he->data);
+		return true;
 	}
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	return false;
 }
 
-static void nft_hash_elem_destroy(const struct nft_expr *expr,
-				  struct nft_hash_elem *elem)
+static void nft_hash_elem_destroy(const struct nft_set *set,
+				  struct nft_hash_elem *he)
 {
-	const struct nft_hash *priv = nft_expr_priv(expr);
-
-	nft_data_uninit(&elem->key, NFT_DATA_VALUE);
-	if (priv->flags & NFT_HASH_MAP)
-		nft_data_uninit(elem->data, nft_dreg_to_type(priv->dreg));
-	kfree(elem);
+	nft_data_uninit(&he->key, NFT_DATA_VALUE);
+	if (set->flags & NFT_SET_MAP)
+		nft_data_uninit(he->data, set->dtype);
+	kfree(he);
 }
 
-static const struct nla_policy nft_he_policy[NFTA_HE_MAX + 1] = {
-	[NFTA_HE_KEY]		= { .type = NLA_NESTED },
-	[NFTA_HE_DATA]		= { .type = NLA_NESTED },
-};
-
-static int nft_hash_elem_init(const struct nft_ctx *ctx,
-			      const struct nft_expr *expr,
-			      const struct nlattr *nla,
-			      struct nft_hash_elem **new)
+static int nft_hash_insert(const struct nft_set *set,
+			   const struct nft_set_elem *elem)
 {
-	struct nft_hash *priv = nft_expr_priv(expr);
-	struct nlattr *tb[NFTA_HE_MAX + 1];
-	struct nft_hash_elem *elem;
-	struct nft_data_desc d1, d2;
-	unsigned int size;
-	int err;
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he;
+	unsigned int size, h;
 
-	err = nla_parse_nested(tb, NFTA_HE_MAX, nla, nft_he_policy);
-	if (err < 0)
-		return err;
-
-	if (tb[NFTA_HE_KEY] == NULL)
+	if (elem->flags != 0)
 		return -EINVAL;
-	size = sizeof(*elem);
-
-	if (priv->flags & NFT_HASH_MAP) {
-		if (tb[NFTA_HE_DATA] == NULL)
-			return -EINVAL;
-		size += sizeof(elem->data[0]);
-	} else {
-		if (tb[NFTA_HE_DATA] != NULL)
-			return -EINVAL;
-	}
 
-	elem = kzalloc(size, GFP_KERNEL);
-	if (elem == NULL)
+	size = sizeof(*he);
+	if (set->flags & NFT_SET_MAP)
+		size += sizeof(he->data[0]);
+
+	he = kzalloc(size, GFP_KERNEL);
+	if (he == NULL)
 		return -ENOMEM;
 
-	err = nft_data_init(ctx, &elem->key, &d1, tb[NFTA_HE_KEY]);
-	if (err < 0)
-		goto err1;
-	err = -EINVAL;
-	if (d1.type != NFT_DATA_VALUE || d1.len != priv->klen)
-		goto err2;
-
-	if (tb[NFTA_HE_DATA] != NULL) {
-		err = nft_data_init(ctx, elem->data, &d2, tb[NFTA_HE_DATA]);
-		if (err < 0)
-			goto err2;
-		err = nft_validate_data_load(ctx, priv->dreg, elem->data, d2.type);
-		if (err < 0)
-			goto err3;
-	}
+	nft_data_copy(&he->key, &elem->key);
+	if (set->flags & NFT_SET_MAP)
+		nft_data_copy(he->data, &elem->data);
 
-	*new = elem;
+	h = nft_hash_data(&he->key, priv->hsize, set->klen);
+	hlist_add_head_rcu(&he->hnode, &priv->hash[h]);
 	return 0;
-
-err3:
-	nft_data_uninit(elem->data, d2.type);
-err2:
-	nft_data_uninit(&elem->key, d1.type);
-err1:
-	kfree(elem);
-	return err;
 }
 
-static int nft_hash_elem_dump(struct sk_buff *skb, const struct nft_expr *expr,
-			      const struct nft_hash_elem *elem)
-
+static void nft_hash_remove(const struct nft_set *set,
+			    const struct nft_set_elem *elem)
 {
-	const struct nft_hash *priv = nft_expr_priv(expr);
-	struct nlattr *nest;
+	struct nft_hash_elem *he = elem->cookie;
 
-	nest = nla_nest_start(skb, NFTA_LIST_ELEM);
-	if (nest == NULL)
-		goto nla_put_failure;
-
-	if (nft_data_dump(skb, NFTA_HE_KEY, &elem->key,
-			  NFT_DATA_VALUE, priv->klen) < 0)
-		goto nla_put_failure;
+	hlist_del_rcu(&he->hnode);
+	kfree(he);
+}
 
-	if (priv->flags & NFT_HASH_MAP) {
-		if (nft_data_dump(skb, NFTA_HE_DATA, elem->data,
-				  NFT_DATA_VALUE, priv->dlen) < 0)
-			goto nla_put_failure;
-	}
+static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
+{
+	const struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he;
+	unsigned int h;
 
-	nla_nest_end(skb, nest);
-	return 0;
+	h = nft_hash_data(&elem->key, priv->hsize, set->klen);
+	hlist_for_each_entry(he, &priv->hash[h], hnode) {
+		if (nft_data_cmp(&he->key, &elem->key, set->klen))
+			continue;
 
-nla_put_failure:
-	return -1;
+		elem->cookie = he;
+		elem->flags  = 0;
+		if (set->flags & NFT_SET_MAP)
+			nft_data_copy(&elem->data, he->data);
+		return 0;
+	}
+	return -ENOENT;
 }
 
-static void nft_hash_destroy(const struct nft_ctx *ctx,
-			     const struct nft_expr *expr)
+static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
+			  struct nft_set_iter *iter)
 {
-	const struct nft_hash *priv = nft_expr_priv(expr);
-	const struct hlist_node *next;
-	struct nft_hash_elem *elem;
+	const struct nft_hash *priv = nft_set_priv(set);
+	const struct nft_hash_elem *he;
+	struct nft_set_elem elem;
 	unsigned int i;
 
 	for (i = 0; i < priv->hsize; i++) {
-		hlist_for_each_entry_safe(elem, next, &priv->hash[i], hnode) {
-			hlist_del(&elem->hnode);
-			nft_hash_elem_destroy(expr, elem);
+		hlist_for_each_entry(he, &priv->hash[i], hnode) {
+			if (iter->count < iter->skip)
+				goto cont;
+
+			memcpy(&elem.key, &he->key, sizeof(elem.key));
+			if (set->flags & NFT_SET_MAP)
+				memcpy(&elem.data, he->data, sizeof(elem.data));
+			elem.flags = 0;
+
+			iter->err = iter->fn(ctx, set, iter, &elem);
+			if (iter->err < 0)
+				return;
+cont:
+			iter->count++;
 		}
 	}
-	kfree(priv->hash);
 }
 
-static const struct nla_policy nft_hash_policy[NFTA_HASH_MAX + 1] = {
-	[NFTA_HASH_FLAGS]	= { .type = NLA_U32 },
-	[NFTA_HASH_SREG]	= { .type = NLA_U32 },
-	[NFTA_HASH_DREG]	= { .type = NLA_U32 },
-	[NFTA_HASH_KLEN]	= { .type = NLA_U32 },
-	[NFTA_HASH_ELEMENTS]	= { .type = NLA_NESTED },
-};
+static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
+{
+	return sizeof(struct nft_hash);
+}
 
-static int nft_hash_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+static int nft_hash_init(const struct nft_set *set,
 			 const struct nlattr * const tb[])
 {
-	struct nft_hash *priv = nft_expr_priv(expr);
-	struct nft_hash_elem *elem, *uninitialized_var(new);
-	const struct nlattr *nla;
+	struct nft_hash *priv = nft_set_priv(set);
 	unsigned int cnt, i;
-	unsigned int h;
-	int err, rem;
 
 	if (unlikely(!nft_hash_rnd_initted)) {
 		get_random_bytes(&nft_hash_rnd, 4);
 		nft_hash_rnd_initted = true;
 	}
 
-	if (tb[NFTA_HASH_SREG] == NULL ||
-	    tb[NFTA_HASH_KLEN] == NULL ||
-	    tb[NFTA_HASH_ELEMENTS] == NULL)
-		return -EINVAL;
-
-	if (tb[NFTA_HASH_FLAGS] != NULL) {
-		priv->flags = ntohl(nla_get_be32(tb[NFTA_HASH_FLAGS]));
-		if (priv->flags & ~NFT_HASH_MAP)
-			return -EINVAL;
-	}
-
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_HASH_SREG]));
-	err = nft_validate_input_register(priv->sreg);
-	if (err < 0)
-		return err;
-
-	if (tb[NFTA_HASH_DREG] != NULL) {
-		if (!(priv->flags & NFT_HASH_MAP))
-			return -EINVAL;
-		priv->dreg = ntohl(nla_get_be32(tb[NFTA_HASH_DREG]));
-		err = nft_validate_output_register(priv->dreg);
-		if (err < 0)
-			return err;
-	}
-
-	priv->klen = ntohl(nla_get_be32(tb[NFTA_HASH_KLEN]));
-	if (priv->klen == 0)
-		return -EINVAL;
-
-	cnt = 0;
-	nla_for_each_nested(nla, tb[NFTA_HASH_ELEMENTS], rem) {
-		if (nla_type(nla) != NFTA_LIST_ELEM)
-			return -EINVAL;
-		cnt++;
-	}
-
 	/* Aim for a load factor of 0.75 */
+	// FIXME: temporarily broken until we have set descriptions
+	cnt = 100;
 	cnt = cnt * 4 / 3;
 
 	priv->hash = kcalloc(cnt, sizeof(struct hlist_head), GFP_KERNEL);
@@ -259,85 +181,46 @@ static int nft_hash_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	for (i = 0; i < cnt; i++)
 		INIT_HLIST_HEAD(&priv->hash[i]);
 
-	err = -ENOMEM;
-	nla_for_each_nested(nla, tb[NFTA_HASH_ELEMENTS], rem) {
-		err = nft_hash_elem_init(ctx, expr, nla, &new);
-		if (err < 0)
-			goto err1;
-
-		h = nft_hash_data(&new->key, priv->hsize, priv->klen);
-		hlist_for_each_entry(elem, &priv->hash[h], hnode) {
-			if (nft_data_cmp(&elem->key, &new->key, priv->klen))
-				continue;
-			nft_hash_elem_destroy(expr, new);
-			err = -EEXIST;
-			goto err1;
-		}
-		hlist_add_head(&new->hnode, &priv->hash[h]);
-	}
 	return 0;
-
-err1:
-	nft_hash_destroy(ctx, expr);
-	return err;
 }
 
-static int nft_hash_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static void nft_hash_destroy(const struct nft_set *set)
 {
-	const struct nft_hash *priv = nft_expr_priv(expr);
-	const struct nft_hash_elem *elem;
-	struct nlattr *list;
+	const struct nft_hash *priv = nft_set_priv(set);
+	const struct hlist_node *next;
+	struct nft_hash_elem *elem;
 	unsigned int i;
 
-	if (priv->flags)
-		if (nla_put_be32(skb, NFTA_HASH_FLAGS, htonl(priv->flags)))
-			goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_HASH_SREG, htonl(priv->sreg)))
-		goto nla_put_failure;
-	if (priv->flags & NFT_HASH_MAP)
-		if (nla_put_be32(skb, NFTA_HASH_DREG, htonl(priv->dreg)))
-			goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_HASH_KLEN, htonl(priv->klen)))
-		goto nla_put_failure;
-
-	list = nla_nest_start(skb, NFTA_HASH_ELEMENTS);
-	if (list == NULL)
-		goto nla_put_failure;
-
 	for (i = 0; i < priv->hsize; i++) {
-		hlist_for_each_entry(elem, &priv->hash[i], hnode) {
-			if (nft_hash_elem_dump(skb, expr, elem) < 0)
-				goto nla_put_failure;
+		hlist_for_each_entry_safe(elem, next, &priv->hash[i], hnode) {
+			hlist_del(&elem->hnode);
+			nft_hash_elem_destroy(set, elem);
 		}
 	}
-
-	nla_nest_end(skb, list);
-	return 0;
-
-nla_put_failure:
-	return -1;
+	kfree(priv->hash);
 }
 
-static struct nft_expr_ops nft_hash_ops __read_mostly = {
-	.name		= "hash",
-	.size		= NFT_EXPR_SIZE(sizeof(struct nft_hash)),
-	.owner		= THIS_MODULE,
-	.eval		= nft_hash_eval,
+static struct nft_set_ops nft_hash_ops __read_mostly = {
+	.privsize       = nft_hash_privsize,
 	.init		= nft_hash_init,
 	.destroy	= nft_hash_destroy,
-	.dump		= nft_hash_dump,
-	.policy		= nft_hash_policy,
-	.maxattr	= NFTA_HASH_MAX,
+	.get		= nft_hash_get,
+	.insert		= nft_hash_insert,
+	.remove		= nft_hash_remove,
+	.lookup		= nft_hash_lookup,
+	.walk		= nft_hash_walk,
+	.features	= NFT_SET_MAP,
+	.owner		= THIS_MODULE,
 };
 
 static int __init nft_hash_module_init(void)
 {
-	return nft_register_expr(&nft_hash_ops);
+	return nft_register_set(&nft_hash_ops);
 }
 
 static void __exit nft_hash_module_exit(void)
 {
-	nft_unregister_expr(&nft_hash_ops);
+	nft_unregister_set(&nft_hash_ops);
 }
 
 module_init(nft_hash_module_init);
@@ -345,4 +228,4 @@ module_exit(nft_hash_module_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_ALIAS_NFT_EXPR("hash");
+MODULE_ALIAS_NFT_SET();
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 3bf42c3..78334bf 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -90,6 +90,16 @@ nla_put_failure:
 	return -1;
 }
 
+static const struct nft_data *nft_immediate_get_verdict(const struct nft_expr *expr)
+{
+	const struct nft_immediate_expr *priv = nft_expr_priv(expr);
+
+	if (priv->dreg == NFT_REG_VERDICT)
+		return &priv->data;
+	else
+		return NULL;
+}
+
 static struct nft_expr_ops nft_imm_ops __read_mostly = {
 	.name		= "immediate",
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_immediate_expr)),
@@ -98,6 +108,7 @@ static struct nft_expr_ops nft_imm_ops __read_mostly = {
 	.init		= nft_immediate_init,
 	.destroy	= nft_immediate_destroy,
 	.dump		= nft_immediate_dump,
+	.get_verdict	= nft_immediate_get_verdict,
 	.policy		= nft_immediate_policy,
 	.maxattr	= NFTA_IMMEDIATE_MAX,
 };
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
new file mode 100644
index 0000000..4962d21
--- /dev/null
+++ b/net/netfilter/nft_lookup.c
@@ -0,0 +1,135 @@
+/*
+ * Copyright (c) 2009 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/rbtree.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+
+struct nft_lookup {
+	struct nft_set			*set;
+	enum nft_registers		sreg:8;
+	enum nft_registers		dreg:8;
+	struct nft_set_binding		binding;
+};
+
+static void nft_lookup_eval(const struct nft_expr *expr,
+			    struct nft_data data[NFT_REG_MAX + 1],
+			    const struct nft_pktinfo *pkt)
+{
+	const struct nft_lookup *priv = nft_expr_priv(expr);
+	const struct nft_set *set = priv->set;
+
+	if (set->ops->lookup(set, &data[priv->sreg], &data[priv->dreg]))
+		return;
+	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+}
+
+static const struct nla_policy nft_lookup_policy[NFTA_LOOKUP_MAX + 1] = {
+	[NFTA_LOOKUP_SET]	= { .type = NLA_STRING },
+	[NFTA_LOOKUP_SREG]	= { .type = NLA_U32 },
+	[NFTA_LOOKUP_DREG]	= { .type = NLA_U32 },
+};
+
+static int nft_lookup_init(const struct nft_ctx *ctx,
+			   const struct nft_expr *expr,
+			   const struct nlattr * const tb[])
+{
+	struct nft_lookup *priv = nft_expr_priv(expr);
+	struct nft_set *set;
+	int err;
+
+	if (tb[NFTA_LOOKUP_SET] == NULL ||
+	    tb[NFTA_LOOKUP_SREG] == NULL)
+		return -EINVAL;
+
+	set = nf_tables_set_lookup(ctx->table, tb[NFTA_LOOKUP_SET]);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
+
+	priv->sreg = ntohl(nla_get_be32(tb[NFTA_LOOKUP_SREG]));
+	err = nft_validate_input_register(priv->sreg);
+	if (err < 0)
+		return err;
+
+	if (tb[NFTA_LOOKUP_DREG] != NULL) {
+		if (!(set->flags & NFT_SET_MAP))
+			return -EINVAL;
+
+		priv->dreg = ntohl(nla_get_be32(tb[NFTA_LOOKUP_DREG]));
+		err = nft_validate_output_register(priv->dreg);
+		if (err < 0)
+			return err;
+
+		if (priv->dreg == NFT_REG_VERDICT) {
+			if (set->dtype != NFT_DATA_VERDICT)
+				return -EINVAL;
+		} else if (set->dtype == NFT_DATA_VERDICT)
+			return -EINVAL;
+	} else if (set->flags & NFT_SET_MAP)
+		return -EINVAL;
+
+	err = nf_tables_bind_set(ctx, set, &priv->binding);
+	if (err < 0)
+		return err;
+
+	priv->set = set;
+	return 0;
+}
+
+static void nft_lookup_destroy(const struct nft_expr *expr)
+{
+	struct nft_lookup *priv = nft_expr_priv(expr);
+
+	nf_tables_unbind_set(NULL, priv->set, &priv->binding);
+}
+
+static int nft_lookup_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_lookup *priv = nft_expr_priv(expr);
+
+	if (nla_put_string(skb, NFTA_LOOKUP_SET, priv->set->name))
+		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_LOOKUP_SREG, htonl(priv->sreg)))
+		goto nla_put_failure;
+	if (priv->set->flags & NFT_SET_MAP)
+		if (nla_put_be32(skb, NFTA_LOOKUP_DREG, htonl(priv->dreg)))
+			goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_ops nft_lookup_ops __read_mostly = {
+	.name		= "lookup",
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_lookup)),
+	.owner		= THIS_MODULE,
+	.eval		= nft_lookup_eval,
+	.init		= nft_lookup_init,
+	.destroy	= nft_lookup_destroy,
+	.dump		= nft_lookup_dump,
+	.policy		= nft_lookup_policy,
+	.maxattr	= NFTA_LOOKUP_MAX,
+};
+
+int __init nft_lookup_module_init(void)
+{
+	return nft_register_expr(&nft_lookup_ops);
+}
+
+void nft_lookup_module_exit(void)
+{
+	nft_unregister_expr(&nft_lookup_ops);
+}
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
new file mode 100644
index 0000000..ca0c1b2
--- /dev/null
+++ b/net/netfilter/nft_rbtree.c
@@ -0,0 +1,247 @@
+/*
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/rbtree.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+
+struct nft_rbtree {
+	struct rb_root		root;
+};
+
+struct nft_rbtree_elem {
+	struct rb_node		node;
+	u16			flags;
+	struct nft_data		key;
+	struct nft_data		data[];
+};
+
+static bool nft_rbtree_lookup(const struct nft_set *set,
+			      const struct nft_data *key,
+			      struct nft_data *data)
+{
+	const struct nft_rbtree *priv = nft_set_priv(set);
+	const struct nft_rbtree_elem *rbe, *interval = NULL;
+	const struct rb_node *parent = priv->root.rb_node;
+	int d;
+
+	while (parent != NULL) {
+		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
+
+		d = nft_data_cmp(&rbe->key, key, set->klen);
+		if (d < 0) {
+			parent = parent->rb_left;
+			interval = rbe;
+		} else if (d > 0)
+			parent = parent->rb_right;
+		else {
+found:
+			if (rbe->flags & NFT_SET_ELEM_INTERVAL_END)
+				goto out;
+			if (set->flags & NFT_SET_MAP)
+				nft_data_copy(data, rbe->data);
+			return true;
+		}
+	}
+
+	if (set->flags & NFT_SET_INTERVAL && interval != NULL) {
+		rbe = interval;
+		goto found;
+	}
+out:
+	return false;
+}
+
+static void nft_rbtree_elem_destroy(const struct nft_set *set,
+				    struct nft_rbtree_elem *rbe)
+{
+	nft_data_uninit(&rbe->key, NFT_DATA_VALUE);
+	if (set->flags & NFT_SET_MAP)
+		nft_data_uninit(rbe->data, set->dtype);
+	kfree(rbe);
+}
+
+static int __nft_rbtree_insert(const struct nft_set *set,
+			       struct nft_rbtree_elem *new)
+{
+	struct nft_rbtree *priv = nft_set_priv(set);
+	struct nft_rbtree_elem *rbe;
+	struct rb_node *parent, **p;
+	int d;
+
+	parent = NULL;
+	p = &priv->root.rb_node;
+	while (*p != NULL) {
+		parent = *p;
+		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
+		d = nft_data_cmp(&rbe->key, &new->key, set->klen);
+		if (d < 0)
+			p = &parent->rb_left;
+		else if (d > 0)
+			p = &parent->rb_right;
+		else
+			return -EEXIST;
+	}
+	rb_link_node(&new->node, parent, p);
+	rb_insert_color(&new->node, &priv->root);
+	return 0;
+}
+
+static int nft_rbtree_insert(const struct nft_set *set,
+			     const struct nft_set_elem *elem)
+{
+	struct nft_rbtree_elem *rbe;
+	unsigned int size;
+	int err;
+
+	size = sizeof(*rbe);
+	if (set->flags & NFT_SET_MAP)
+		size += sizeof(rbe->data[0]);
+
+	rbe = kzalloc(size, GFP_KERNEL);
+	if (rbe == NULL)
+		return -ENOMEM;
+
+	rbe->flags = elem->flags;
+	nft_data_copy(&rbe->key, &elem->key);
+	if (set->flags & NFT_SET_MAP)
+		nft_data_copy(rbe->data, &elem->data);
+
+	err = __nft_rbtree_insert(set, rbe);
+	if (err < 0)
+		kfree(rbe);
+	return err;
+}
+
+static void nft_rbtree_remove(const struct nft_set *set,
+			      const struct nft_set_elem *elem)
+{
+	struct nft_rbtree *priv = nft_set_priv(set);
+	struct nft_rbtree_elem *rbe = elem->cookie;
+
+	rb_erase(&rbe->node, &priv->root);
+	kfree(rbe);
+}
+
+static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
+{
+	const struct nft_rbtree *priv = nft_set_priv(set);
+	const struct rb_node *parent = priv->root.rb_node;
+	struct nft_rbtree_elem *rbe;
+	int d;
+
+	while (parent != NULL) {
+		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
+
+		d = nft_data_cmp(&rbe->key, &elem->key, set->klen);
+		if (d < 0)
+			parent = parent->rb_left;
+		else if (d > 0)
+			parent = parent->rb_right;
+		else {
+			elem->cookie = rbe;
+			if (set->flags & NFT_SET_MAP)
+				nft_data_copy(&elem->data, rbe->data);
+			elem->flags = rbe->flags;
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
+static void nft_rbtree_walk(const struct nft_ctx *ctx,
+			    const struct nft_set *set,
+			    struct nft_set_iter *iter)
+{
+	const struct nft_rbtree *priv = nft_set_priv(set);
+	const struct nft_rbtree_elem *rbe;
+	struct nft_set_elem elem;
+	struct rb_node *node;
+
+	for (node = rb_first(&priv->root); node != NULL; node = rb_next(node)) {
+		if (iter->count < iter->skip)
+			goto cont;
+
+		rbe = rb_entry(node, struct nft_rbtree_elem, node);
+		nft_data_copy(&elem.key, &rbe->key);
+		if (set->flags & NFT_SET_MAP)
+			nft_data_copy(&elem.data, rbe->data);
+		elem.flags = rbe->flags;
+
+		iter->err = iter->fn(ctx, set, iter, &elem);
+		if (iter->err < 0)
+			return;
+cont:
+		iter->count++;
+	}
+}
+
+static unsigned int nft_rbtree_privsize(const struct nlattr * const nla[])
+{
+	return sizeof(struct nft_rbtree);
+}
+
+static int nft_rbtree_init(const struct nft_set *set,
+			   const struct nlattr * const nla[])
+{
+	struct nft_rbtree *priv = nft_set_priv(set);
+
+	priv->root = RB_ROOT;
+	return 0;
+}
+
+static void nft_rbtree_destroy(const struct nft_set *set)
+{
+	struct nft_rbtree *priv = nft_set_priv(set);
+	struct nft_rbtree_elem *rbe;
+	struct rb_node *node;
+
+	while ((node = priv->root.rb_node) != NULL) {
+		rb_erase(node, &priv->root);
+		rbe = rb_entry(node, struct nft_rbtree_elem, node);
+		nft_rbtree_elem_destroy(set, rbe);
+	}
+}
+
+static struct nft_set_ops nft_rbtree_ops __read_mostly = {
+	.privsize	= nft_rbtree_privsize,
+	.init		= nft_rbtree_init,
+	.destroy	= nft_rbtree_destroy,
+	.insert		= nft_rbtree_insert,
+	.remove		= nft_rbtree_remove,
+	.get		= nft_rbtree_get,
+	.lookup		= nft_rbtree_lookup,
+	.walk		= nft_rbtree_walk,
+	.features	= NFT_SET_INTERVAL | NFT_SET_MAP,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_rbtree_module_init(void)
+{
+	return nft_register_set(&nft_rbtree_ops);
+}
+
+static void __exit nft_rbtree_module_exit(void)
+{
+	nft_unregister_set(&nft_rbtree_ops);
+}
+
+module_init(nft_rbtree_module_init);
+module_exit(nft_rbtree_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_ALIAS_NFT_SET();
diff --git a/net/netfilter/nft_set.c b/net/netfilter/nft_set.c
deleted file mode 100644
index 7b7c835..0000000
--- a/net/netfilter/nft_set.c
+++ /dev/null
@@ -1,381 +0,0 @@
-/*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * Development of this code funded by Astaro AG (http://www.astaro.com/)
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/list.h>
-#include <linux/rbtree.h>
-#include <linux/netlink.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter/nf_tables.h>
-#include <net/netfilter/nf_tables.h>
-
-struct nft_set {
-	struct rb_root		root;
-	enum nft_registers	sreg:8;
-	enum nft_registers	dreg:8;
-	u8			klen;
-	u8			dlen;
-	u16			flags;
-};
-
-struct nft_set_elem {
-	struct rb_node		node;
-	enum nft_set_elem_flags	flags;
-	struct nft_data		key;
-	struct nft_data		data[];
-};
-
-static void nft_set_eval(const struct nft_expr *expr,
-			 struct nft_data data[NFT_REG_MAX + 1],
-			 const struct nft_pktinfo *pkt)
-{
-	const struct nft_set *priv = nft_expr_priv(expr);
-	const struct rb_node *parent = priv->root.rb_node;
-	const struct nft_set_elem *elem, *interval = NULL;
-	const struct nft_data *key = &data[priv->sreg];
-	int d;
-
-	while (parent != NULL) {
-		elem = rb_entry(parent, struct nft_set_elem, node);
-
-		d = nft_data_cmp(&elem->key, key, priv->klen);
-		if (d < 0) {
-			parent = parent->rb_left;
-			interval = elem;
-		} else if (d > 0)
-			parent = parent->rb_right;
-		else {
-found:
-			if (elem->flags & NFT_SE_INTERVAL_END)
-				goto out;
-			if (priv->flags & NFT_SET_MAP)
-				nft_data_copy(&data[priv->dreg], elem->data);
-			return;
-		}
-	}
-
-	if (priv->flags & NFT_SET_INTERVAL && interval != NULL) {
-		elem = interval;
-		goto found;
-	}
-out:
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
-}
-
-static void nft_set_elem_destroy(const struct nft_expr *expr,
-				 struct nft_set_elem *elem)
-{
-	const struct nft_set *priv = nft_expr_priv(expr);
-
-	nft_data_uninit(&elem->key, NFT_DATA_VALUE);
-	if (priv->flags & NFT_SET_MAP)
-		nft_data_uninit(elem->data, nft_dreg_to_type(priv->dreg));
-	kfree(elem);
-}
-
-static const struct nla_policy nft_se_policy[NFTA_SE_MAX + 1] = {
-	[NFTA_SE_KEY]		= { .type = NLA_NESTED },
-	[NFTA_SE_DATA]		= { .type = NLA_NESTED },
-	[NFTA_SE_FLAGS]		= { .type = NLA_U32 },
-};
-
-static int nft_set_elem_init(const struct nft_ctx *ctx,
-			     const struct nft_expr *expr,
-			     const struct nlattr *nla,
-			     struct nft_set_elem **new)
-{
-	struct nft_set *priv = nft_expr_priv(expr);
-	struct nlattr *tb[NFTA_SE_MAX + 1];
-	struct nft_set_elem *elem;
-	struct nft_data_desc d1, d2;
-	enum nft_set_elem_flags flags = 0;
-	unsigned int size;
-	int err;
-
-	err = nla_parse_nested(tb, NFTA_SE_MAX, nla, nft_se_policy);
-	if (err < 0)
-		return err;
-
-	if (tb[NFTA_SE_KEY] == NULL)
-		return -EINVAL;
-
-	if (tb[NFTA_SE_FLAGS] != NULL) {
-		flags = ntohl(nla_get_be32(tb[NFTA_SE_FLAGS]));
-		if (flags & ~NFT_SE_INTERVAL_END)
-			return -EINVAL;
-	}
-
-	size = sizeof(*elem);
-	if (priv->flags & NFT_SET_MAP) {
-		if (tb[NFTA_SE_DATA] == NULL && !(flags & NFT_SE_INTERVAL_END))
-			return -EINVAL;
-		size += sizeof(elem->data[0]);
-	} else {
-		if (tb[NFTA_SE_DATA] != NULL)
-			return -EINVAL;
-	}
-
-	elem = kzalloc(size, GFP_KERNEL);
-	if (elem == NULL)
-		return -ENOMEM;
-	elem->flags = flags;
-
-	err = nft_data_init(ctx, &elem->key, &d1, tb[NFTA_SE_KEY]);
-	if (err < 0)
-		goto err1;
-	err = -EINVAL;
-	if (d1.type != NFT_DATA_VALUE || d1.len != priv->klen)
-		goto err2;
-
-	if (tb[NFTA_SE_DATA] != NULL) {
-		err = nft_data_init(ctx, elem->data, &d2, tb[NFTA_SE_DATA]);
-		if (err < 0)
-			goto err2;
-		err = -EINVAL;
-		if (priv->dreg != NFT_REG_VERDICT && d2.len != priv->dlen)
-			goto err2;
-		err = nft_validate_data_load(ctx, priv->dreg, elem->data, d2.type);
-		if (err < 0)
-			goto err3;
-	}
-
-	*new = elem;
-	return 0;
-
-err3:
-	nft_data_uninit(elem->data, d2.type);
-err2:
-	nft_data_uninit(&elem->key, d1.type);
-err1:
-	kfree(elem);
-	return err;
-}
-
-static int nft_set_elem_dump(struct sk_buff *skb, const struct nft_expr *expr,
-			     const struct nft_set_elem *elem)
-
-{
-	const struct nft_set *priv = nft_expr_priv(expr);
-	struct nlattr *nest;
-
-	nest = nla_nest_start(skb, NFTA_LIST_ELEM);
-	if (nest == NULL)
-		goto nla_put_failure;
-
-	if (nft_data_dump(skb, NFTA_SE_KEY, &elem->key,
-			  NFT_DATA_VALUE, priv->klen) < 0)
-		goto nla_put_failure;
-
-	if (priv->flags & NFT_SET_MAP && !(elem->flags & NFT_SE_INTERVAL_END)) {
-		if (nft_data_dump(skb, NFTA_SE_DATA, elem->data,
-				  nft_dreg_to_type(priv->dreg), priv->dlen) < 0)
-			goto nla_put_failure;
-	}
-
-	if (elem->flags){
-		if (nla_put_be32(skb, NFTA_SE_FLAGS, htonl(elem->flags)))
-			goto nla_put_failure;
-	}
-
-	nla_nest_end(skb, nest);
-	return 0;
-
-nla_put_failure:
-	return -1;
-}
-
-static void nft_set_destroy(const struct nft_expr *expr)
-{
-	struct nft_set *priv = nft_expr_priv(expr);
-	struct nft_set_elem *elem;
-	struct rb_node *node;
-
-	while ((node = priv->root.rb_node) != NULL) {
-		rb_erase(node, &priv->root);
-		elem = rb_entry(node, struct nft_set_elem, node);
-		nft_set_elem_destroy(expr, elem);
-	}
-}
-
-static const struct nla_policy nft_set_policy[NFTA_SET_MAX + 1] = {
-	[NFTA_SET_FLAGS]	= { .type = NLA_U32 },
-	[NFTA_SET_SREG]		= { .type = NLA_U32 },
-	[NFTA_SET_DREG]		= { .type = NLA_U32 },
-	[NFTA_SET_KLEN]		= { .type = NLA_U32 },
-	[NFTA_SET_DLEN]		= { .type = NLA_U32 },
-	[NFTA_SET_ELEMENTS]	= { .type = NLA_NESTED },
-};
-
-static int nft_set_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
-			const struct nlattr * const tb[])
-{
-	struct nft_set *priv = nft_expr_priv(expr);
-	struct nft_set_elem *elem, *uninitialized_var(new);
-	struct rb_node *parent, **p;
-	const struct nlattr *nla;
-	int err, rem, d;
-
-	if (tb[NFTA_SET_SREG] == NULL ||
-	    tb[NFTA_SET_KLEN] == NULL ||
-	    tb[NFTA_SET_ELEMENTS] == NULL)
-		return -EINVAL;
-
-	priv->root = RB_ROOT;
-
-	if (tb[NFTA_SET_FLAGS] != NULL) {
-		priv->flags = ntohl(nla_get_be32(tb[NFTA_SET_FLAGS]));
-		if (priv->flags & ~(NFT_SET_INTERVAL | NFT_SET_MAP))
-			return -EINVAL;
-	}
-
-	priv->sreg = ntohl(nla_get_be32(tb[NFTA_SET_SREG]));
-	err = nft_validate_input_register(priv->sreg);
-	if (err < 0)
-		return err;
-
-	if (tb[NFTA_SET_DREG] != NULL) {
-		if (!(priv->flags & NFT_SET_MAP))
-			return -EINVAL;
-		if (tb[NFTA_SET_DLEN] == NULL)
-			return -EINVAL;
-
-		priv->dreg = ntohl(nla_get_be32(tb[NFTA_SET_DREG]));
-		err = nft_validate_output_register(priv->dreg);
-		if (err < 0)
-			return err;
-
-		if (priv->dreg == NFT_REG_VERDICT)
-			priv->dlen = FIELD_SIZEOF(struct nft_data, data);
-		else {
-			priv->dlen = ntohl(nla_get_be32(tb[NFTA_SET_DLEN]));
-			if (priv->dlen == 0 ||
-			    priv->dlen > FIELD_SIZEOF(struct nft_data, data))
-				return -EINVAL;
-		}
-	} else {
-		if (priv->flags & NFT_SET_MAP)
-			return -EINVAL;
-		if (tb[NFTA_SET_DLEN] != NULL)
-			return -EINVAL;
-	}
-
-	priv->klen = ntohl(nla_get_be32(tb[NFTA_SET_KLEN]));
-	if (priv->klen == 0 ||
-	    priv->klen > FIELD_SIZEOF(struct nft_data, data))
-		return -EINVAL;
-
-	nla_for_each_nested(nla, tb[NFTA_SET_ELEMENTS], rem) {
-		err = -EINVAL;
-		if (nla_type(nla) != NFTA_LIST_ELEM)
-			goto err1;
-
-		err = nft_set_elem_init(ctx, expr, nla, &new);
-		if (err < 0)
-			goto err1;
-
-		parent = NULL;
-		p = &priv->root.rb_node;
-		while (*p != NULL) {
-			parent = *p;
-			elem = rb_entry(parent, struct nft_set_elem, node);
-			d = nft_data_cmp(&elem->key, &new->key, priv->klen);
-			if (d < 0)
-				p = &parent->rb_left;
-			else if (d > 0)
-				p = &parent->rb_right;
-			else {
-				err = -EEXIST;
-				goto err2;
-			}
-		}
-		rb_link_node(&new->node, parent, p);
-		rb_insert_color(&new->node, &priv->root);
-	}
-
-	return 0;
-
-err2:
-	nft_set_elem_destroy(expr, new);
-err1:
-	nft_set_destroy(expr);
-	return err;
-}
-
-static int nft_set_dump(struct sk_buff *skb, const struct nft_expr *expr)
-{
-	struct nft_set *priv = nft_expr_priv(expr);
-	const struct nft_set_elem *elem;
-	struct rb_node *node;
-	struct nlattr *list;
-
-	if (priv->flags) {
-		if (nla_put_be32(skb, NFTA_SET_FLAGS, htonl(priv->flags)))
-			goto nla_put_failure;
-	}
-
-	if (nla_put_be32(skb, NFTA_SET_SREG, htonl(priv->sreg)))
-		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_SET_KLEN, htonl(priv->klen)))
-		goto nla_put_failure;
-
-	if (priv->flags & NFT_SET_MAP) {
-		if (nla_put_be32(skb, NFTA_SET_DREG, htonl(priv->dreg)))
-			goto nla_put_failure;
-		if (nla_put_be32(skb, NFTA_SET_DLEN, htonl(priv->dlen)))
-			goto nla_put_failure;
-	}
-
-	list = nla_nest_start(skb, NFTA_SET_ELEMENTS);
-	if (list == NULL)
-		goto nla_put_failure;
-
-	for (node = rb_first(&priv->root); node; node = rb_next(node)) {
-		elem = rb_entry(node, struct nft_set_elem, node);
-		if (nft_set_elem_dump(skb, expr, elem) < 0)
-			goto nla_put_failure;
-	}
-
-	nla_nest_end(skb, list);
-	return 0;
-
-nla_put_failure:
-	return -1;
-}
-
-static struct nft_expr_ops nft_set_ops __read_mostly = {
-	.name		= "set",
-	.size		= NFT_EXPR_SIZE(sizeof(struct nft_set)),
-	.owner		= THIS_MODULE,
-	.eval		= nft_set_eval,
-	.init		= nft_set_init,
-	.destroy	= nft_set_destroy,
-	.dump		= nft_set_dump,
-	.policy		= nft_set_policy,
-	.maxattr	= NFTA_SET_MAX,
-};
-
-static int __init nft_set_module_init(void)
-{
-	return nft_register_expr(&nft_set_ops);
-}
-
-static void __exit nft_set_module_exit(void)
-{
-	nft_unregister_expr(&nft_set_ops);
-}
-
-module_init(nft_set_module_init);
-module_exit(nft_set_module_exit);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_ALIAS_NFT_EXPR("set");
-- 
1.7.10.4
