From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/20] netfilter: nf_tables: support optional userdata for set elements
Date: Thu,  9 Apr 2015 13:35:04 +0200
Message-ID: <1428579304-5520-21-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Add an userdata set extension and allow the user to attach arbitrary
data to set elements. This is intended to hold TLV encoded data like
comments or DNS annotations that have no meaning to the kernel.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |    7 ++++++
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c            |   34 ++++++++++++++++++++++++++++++
 3 files changed, 43 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 38c3496..63c44bdf 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -350,6 +350,7 @@ void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
  *	@NFT_SET_EXT_FLAGS: element flags
  *	@NFT_SET_EXT_TIMEOUT: element timeout
  *	@NFT_SET_EXT_EXPIRATION: element expiration time
+ *	@NFT_SET_EXT_USERDATA: user data associated with the element
  *	@NFT_SET_EXT_NUM: number of extension types
  */
 enum nft_set_extensions {
@@ -358,6 +359,7 @@ enum nft_set_extensions {
 	NFT_SET_EXT_FLAGS,
 	NFT_SET_EXT_TIMEOUT,
 	NFT_SET_EXT_EXPIRATION,
+	NFT_SET_EXT_USERDATA,
 	NFT_SET_EXT_NUM
 };
 
@@ -464,6 +466,11 @@ static inline unsigned long *nft_set_ext_expiration(const struct nft_set_ext *ex
 	return nft_set_ext(ext, NFT_SET_EXT_EXPIRATION);
 }
 
+static inline struct nft_userdata *nft_set_ext_userdata(const struct nft_set_ext *ext)
+{
+	return nft_set_ext(ext, NFT_SET_EXT_USERDATA);
+}
+
 static inline bool nft_set_elem_expired(const struct nft_set_ext *ext)
 {
 	return nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION) &&
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 0b87b2f..05ee1e0 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -292,6 +292,7 @@ enum nft_set_elem_flags {
  * @NFTA_SET_ELEM_FLAGS: bitmask of nft_set_elem_flags (NLA_U32)
  * @NFTA_SET_ELEM_TIMEOUT: timeout value (NLA_U64)
  * @NFTA_SET_ELEM_EXPIRATION: expiration time (NLA_U64)
+ * @NFTA_SET_ELEM_USERDATA: user data (NLA_BINARY)
  */
 enum nft_set_elem_attributes {
 	NFTA_SET_ELEM_UNSPEC,
@@ -300,6 +301,7 @@ enum nft_set_elem_attributes {
 	NFTA_SET_ELEM_FLAGS,
 	NFTA_SET_ELEM_TIMEOUT,
 	NFTA_SET_ELEM_EXPIRATION,
+	NFTA_SET_ELEM_USERDATA,
 	__NFTA_SET_ELEM_MAX
 };
 #define NFTA_SET_ELEM_MAX	(__NFTA_SET_ELEM_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 598e53e..0b96fa0 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2872,6 +2872,10 @@ const struct nft_set_ext_type nft_set_ext_types[] = {
 		.len	= sizeof(unsigned long),
 		.align	= __alignof__(unsigned long),
 	},
+	[NFT_SET_EXT_USERDATA]		= {
+		.len	= sizeof(struct nft_userdata),
+		.align	= __alignof__(struct nft_userdata),
+	},
 };
 EXPORT_SYMBOL_GPL(nft_set_ext_types);
 
@@ -2884,6 +2888,8 @@ static const struct nla_policy nft_set_elem_policy[NFTA_SET_ELEM_MAX + 1] = {
 	[NFTA_SET_ELEM_DATA]		= { .type = NLA_NESTED },
 	[NFTA_SET_ELEM_FLAGS]		= { .type = NLA_U32 },
 	[NFTA_SET_ELEM_TIMEOUT]		= { .type = NLA_U64 },
+	[NFTA_SET_ELEM_USERDATA]	= { .type = NLA_BINARY,
+					    .len = NFT_USERDATA_MAXLEN },
 };
 
 static const struct nla_policy nft_set_elem_list_policy[NFTA_SET_ELEM_LIST_MAX + 1] = {
@@ -2964,6 +2970,15 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 			goto nla_put_failure;
 	}
 
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_USERDATA)) {
+		struct nft_userdata *udata;
+
+		udata = nft_set_ext_userdata(ext);
+		if (nla_put(skb, NFTA_SET_ELEM_USERDATA,
+			    udata->len + 1, udata->data))
+			goto nla_put_failure;
+	}
+
 	nla_nest_end(skb, nest);
 	return 0;
 
@@ -3232,11 +3247,13 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	struct nft_set_ext *ext;
 	struct nft_set_elem elem;
 	struct nft_set_binding *binding;
+	struct nft_userdata *udata;
 	struct nft_data data;
 	enum nft_registers dreg;
 	struct nft_trans *trans;
 	u64 timeout;
 	u32 flags;
+	u8 ulen;
 	int err;
 
 	err = nla_parse_nested(nla, NFTA_SET_ELEM_MAX, attr,
@@ -3325,6 +3342,18 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		nft_set_ext_add(&tmpl, NFT_SET_EXT_DATA);
 	}
 
+	/* The full maximum length of userdata can exceed the maximum
+	 * offset value (U8_MAX) for following extensions, therefor it
+	 * must be the last extension added.
+	 */
+	ulen = 0;
+	if (nla[NFTA_SET_ELEM_USERDATA] != NULL) {
+		ulen = nla_len(nla[NFTA_SET_ELEM_USERDATA]);
+		if (ulen > 0)
+			nft_set_ext_add_length(&tmpl, NFT_SET_EXT_USERDATA,
+					       ulen);
+	}
+
 	err = -ENOMEM;
 	elem.priv = nft_set_elem_init(set, &tmpl, &elem.key, &data,
 				      timeout, GFP_KERNEL);
@@ -3334,6 +3363,11 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	ext = nft_set_elem_ext(set, elem.priv);
 	if (flags)
 		*nft_set_ext_flags(ext) = flags;
+	if (ulen > 0) {
+		udata = nft_set_ext_userdata(ext);
+		udata->len = ulen - 1;
+		nla_memcpy(&udata->data, nla[NFTA_SET_ELEM_USERDATA], ulen);
+	}
 
 	trans = nft_trans_elem_alloc(ctx, NFT_MSG_NEWSETELEM, set);
 	if (trans == NULL)
-- 
1.7.10.4

