From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 6/9] netfilter: nf_tables: add set timeout support
Date: Fri, 30 Jan 2015 07:46:31 +0000
Message-ID: <1422603994-5836-7-git-send-email-kaber@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34132 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817AbbA3Hqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 02:46:53 -0500
In-Reply-To: <1422603994-5836-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_tables.h        |  9 ++++++
 include/uapi/linux/netfilter/nf_tables.h |  6 ++++
 net/netfilter/nf_tables_api.c            | 51 ++++++++++++++++++++++++++++++--
 3 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 60846da..735a59d 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -125,12 +125,14 @@ int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
  *	@NFT_SET_EXT_KEY: element key
  *	@NFT_SET_EXT_DATA: mapping data
  *	@NFT_SET_EXT_FLAGS: element flags
+ *	@NFT_SET_EXT_TIMEOUT: element timeout
  *	@NFT_SET_EXT_NUM: number of extension types
  */
 enum nft_set_extensions {
 	NFT_SET_EXT_KEY,
 	NFT_SET_EXT_DATA,
 	NFT_SET_EXT_FLAGS,
+	NFT_SET_EXT_TIMEOUT,
 	NFT_SET_EXT_NUM
 };
 
@@ -228,6 +230,11 @@ static inline u8 *nft_set_ext_flags(const struct nft_set_ext *ext)
 	return nft_set_ext(ext, NFT_SET_EXT_FLAGS);
 }
 
+static inline unsigned long *nft_set_ext_timeout(const struct nft_set_ext *ext)
+{
+	return nft_set_ext(ext, NFT_SET_EXT_TIMEOUT);
+}
+
 /**
  *	struct nft_set_elem - generic representation of set elements
  *
@@ -350,6 +357,7 @@ void nft_unregister_set(struct nft_set_ops *ops);
  * 	@dtype: data type (verdict or numeric type defined by userspace)
  * 	@size: maximum set size
  * 	@nelems: number of elements
+ * 	@timeout: default timeout value
  *	@policy: set parameterization (see enum nft_set_policies)
  * 	@ops: set ops
  * 	@flags: set flags
@@ -365,6 +373,7 @@ struct nft_set {
 	u32				dtype;
 	u32				size;
 	u32				nelems;
+	u32				timeout;
 	u16				policy;
 	/* runtime data below here */
 	const struct nft_set_ops	*ops ____cacheline_aligned;
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 832bc46..144d8fe 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -207,12 +207,14 @@ enum nft_rule_compat_attributes {
  * @NFT_SET_CONSTANT: set contents may not change while bound
  * @NFT_SET_INTERVAL: set contains intervals
  * @NFT_SET_MAP: set is used as a dictionary
+ * @NFT_SET_TIMEOUT: set uses timeouts
  */
 enum nft_set_flags {
 	NFT_SET_ANONYMOUS		= 0x1,
 	NFT_SET_CONSTANT		= 0x2,
 	NFT_SET_INTERVAL		= 0x4,
 	NFT_SET_MAP			= 0x8,
+	NFT_SET_TIMEOUT			= 0x16,
 };
 
 /**
@@ -251,6 +253,7 @@ enum nft_set_desc_attributes {
  * @NFTA_SET_POLICY: selection policy (NLA_U32)
  * @NFTA_SET_DESC: set description (NLA_NESTED)
  * @NFTA_SET_ID: uniquely identifies a set in a transaction (NLA_U32)
+ * @NFTA_SET_TIMEOUT: timeout default value (NLA_U32)
  */
 enum nft_set_attributes {
 	NFTA_SET_UNSPEC,
@@ -264,6 +267,7 @@ enum nft_set_attributes {
 	NFTA_SET_POLICY,
 	NFTA_SET_DESC,
 	NFTA_SET_ID,
+	NFTA_SET_TIMEOUT,
 	__NFTA_SET_MAX
 };
 #define NFTA_SET_MAX		(__NFTA_SET_MAX - 1)
@@ -283,12 +287,14 @@ enum nft_set_elem_flags {
  * @NFTA_SET_ELEM_KEY: key value (NLA_NESTED: nft_data)
  * @NFTA_SET_ELEM_DATA: data value of mapping (NLA_NESTED: nft_data_attributes)
  * @NFTA_SET_ELEM_FLAGS: bitmask of nft_set_elem_flags (NLA_U32)
+ * @NFTA_SET_ELEM_TIMEOUT: timeout value (NLA_U32)
  */
 enum nft_set_elem_attributes {
 	NFTA_SET_ELEM_UNSPEC,
 	NFTA_SET_ELEM_KEY,
 	NFTA_SET_ELEM_DATA,
 	NFTA_SET_ELEM_FLAGS,
+	NFTA_SET_ELEM_TIMEOUT,
 	__NFTA_SET_ELEM_MAX
 };
 #define NFTA_SET_ELEM_MAX	(__NFTA_SET_ELEM_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index cad0184..95234a3 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2194,6 +2194,7 @@ static const struct nla_policy nft_set_policy[NFTA_SET_MAX + 1] = {
 	[NFTA_SET_POLICY]		= { .type = NLA_U32 },
 	[NFTA_SET_DESC]			= { .type = NLA_NESTED },
 	[NFTA_SET_ID]			= { .type = NLA_U32 },
+	[NFTA_SET_TIMEOUT]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy nft_set_desc_policy[NFTA_SET_DESC_MAX + 1] = {
@@ -2344,6 +2345,10 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 			goto nla_put_failure;
 	}
 
+	if (set->timeout &&
+	    nla_put_be32(skb, NFTA_SET_TIMEOUT, htonl(set->timeout / HZ)))
+		goto nla_put_failure;
+
 	if (set->policy != NFT_SET_POL_PERFORMANCE) {
 		if (nla_put_be32(skb, NFTA_SET_POLICY, htonl(set->policy)))
 			goto nla_put_failure;
@@ -2557,6 +2562,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	bool create;
 	u32 ktype, dtype, flags, policy;
 	struct nft_set_desc desc;
+	unsigned int timeout;
 	int err;
 
 	if (nla[NFTA_SET_TABLE] == NULL ||
@@ -2582,7 +2588,8 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	if (nla[NFTA_SET_FLAGS] != NULL) {
 		flags = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
 		if (flags & ~(NFT_SET_ANONYMOUS | NFT_SET_CONSTANT |
-			      NFT_SET_INTERVAL | NFT_SET_MAP))
+			      NFT_SET_INTERVAL | NFT_SET_MAP |
+			      NFT_SET_TIMEOUT))
 			return -EINVAL;
 	}
 
@@ -2608,6 +2615,13 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	} else if (flags & NFT_SET_MAP)
 		return -EINVAL;
 
+	timeout = 0;
+	if (nla[NFTA_SET_TIMEOUT] != NULL) {
+		if (!(flags & NFT_SET_TIMEOUT))
+			return -EINVAL;
+		timeout = ntohl(nla_get_be32(nla[NFTA_SET_TIMEOUT])) * HZ;
+	}
+
 	policy = NFT_SET_POL_PERFORMANCE;
 	if (nla[NFTA_SET_POLICY] != NULL)
 		policy = ntohl(nla_get_be32(nla[NFTA_SET_POLICY]));
@@ -2675,6 +2689,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	set->flags = flags;
 	set->size  = desc.size;
 	set->policy = policy;
+	set->timeout = timeout;
 
 	err = ops->init(set, &desc, nla);
 	if (err < 0)
@@ -2813,6 +2828,10 @@ const struct nft_set_ext_type nft_set_ext_types[] = {
 		.len	= sizeof(u8),
 		.align	= __alignof__(u8),
 	},
+	[NFT_SET_EXT_TIMEOUT]		= {
+		.len	= sizeof(unsigned long),
+		.align	= __alignof__(unsigned long),
+	},
 };
 EXPORT_SYMBOL_GPL(nft_set_ext_types);
 
@@ -2824,6 +2843,7 @@ static const struct nla_policy nft_set_elem_policy[NFTA_SET_ELEM_MAX + 1] = {
 	[NFTA_SET_ELEM_KEY]		= { .type = NLA_NESTED },
 	[NFTA_SET_ELEM_DATA]		= { .type = NLA_NESTED },
 	[NFTA_SET_ELEM_FLAGS]		= { .type = NLA_U32 },
+	[NFTA_SET_ELEM_TIMEOUT]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy nft_set_elem_list_policy[NFTA_SET_ELEM_LIST_MAX + 1] = {
@@ -2885,6 +2905,20 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 		         htonl(*nft_set_ext_flags(ext))))
 		goto nla_put_failure;
 
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_TIMEOUT)) {
+		unsigned long timeout;
+
+		timeout = *nft_set_ext_timeout(ext);
+		if (timeout > jiffies)
+			timeout = (timeout - jiffies) / HZ;
+		else
+			timeout = 0;
+
+		if (timeout &&
+		    nla_put_be32(skb, NFTA_SET_ELEM_TIMEOUT, htonl(timeout)))
+			goto nla_put_failure;
+	}
+
 	nla_nest_end(skb, nest);
 	return 0;
 
@@ -3115,7 +3149,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	struct nft_data data;
 	enum nft_registers dreg;
 	struct nft_trans *trans;
-	u32 flags;
+	u32 flags, timeout;
 	int err;
 
 	if (set->size && set->nelems == set->size)
@@ -3155,6 +3189,15 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 			return -EINVAL;
 	}
 
+	timeout = 0;
+	if (nla[NFTA_SET_ELEM_TIMEOUT] != NULL) {
+		if (!(set->flags & NFT_SET_TIMEOUT))
+			return -EINVAL;
+		timeout = nla_get_be32(nla[NFTA_SET_ELEM_TIMEOUT]) * HZ;
+	} else if (set->flags & NFT_SET_TIMEOUT) {
+		timeout = set->timeout;
+	}
+
 	err = nft_data_init(ctx, &elem.key, &d1, nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
 		goto err1;
@@ -3167,6 +3210,8 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err2;
 
 	nft_set_ext_add(&tmpl, NFT_SET_EXT_KEY);
+	if (timeout > 0)
+		nft_set_ext_add(&tmpl, NFT_SET_EXT_TIMEOUT);
 
 	if (nla[NFTA_SET_ELEM_DATA] != NULL) {
 		err = nft_data_init(ctx, &data, &d2, nla[NFTA_SET_ELEM_DATA]);
@@ -3204,6 +3249,8 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	nft_data_copy(nft_set_ext_key(ext), &elem.key);
 	if (flags != 0)
 		*nft_set_ext_flags(ext) = flags;
+	if (timeout > 0)
+		*nft_set_ext_timeout(ext) = jiffies + timeout;
 	if (nla[NFTA_SET_ELEM_DATA] != NULL)
 		nft_data_copy(nft_set_ext_data(ext), &data);
 
-- 
2.1.0
