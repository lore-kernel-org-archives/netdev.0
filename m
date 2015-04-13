From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/21] netfilter: nf_tables: prepare for expressions associated to set elements
Date: Mon, 13 Apr 2015 21:29:56 +0200
Message-ID: <1428953401-4838-18-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Preparation to attach expressions to set elements: add a set extension
type to hold an expression and dump the expression information with the
set element.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |    7 +++++++
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c            |    9 +++++++++
 3 files changed, 18 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index e21623c..d45a871 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -371,6 +371,7 @@ void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
  *	@NFT_SET_EXT_TIMEOUT: element timeout
  *	@NFT_SET_EXT_EXPIRATION: element expiration time
  *	@NFT_SET_EXT_USERDATA: user data associated with the element
+ *	@NFT_SET_EXT_EXPR: expression assiociated with the element
  *	@NFT_SET_EXT_NUM: number of extension types
  */
 enum nft_set_extensions {
@@ -380,6 +381,7 @@ enum nft_set_extensions {
 	NFT_SET_EXT_TIMEOUT,
 	NFT_SET_EXT_EXPIRATION,
 	NFT_SET_EXT_USERDATA,
+	NFT_SET_EXT_EXPR,
 	NFT_SET_EXT_NUM
 };
 
@@ -491,6 +493,11 @@ static inline struct nft_userdata *nft_set_ext_userdata(const struct nft_set_ext
 	return nft_set_ext(ext, NFT_SET_EXT_USERDATA);
 }
 
+static inline struct nft_expr *nft_set_ext_expr(const struct nft_set_ext *ext)
+{
+	return nft_set_ext(ext, NFT_SET_EXT_EXPR);
+}
+
 static inline bool nft_set_elem_expired(const struct nft_set_ext *ext)
 {
 	return nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION) &&
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index be8584c..f9c5af2 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -322,6 +322,7 @@ enum nft_set_elem_flags {
  * @NFTA_SET_ELEM_TIMEOUT: timeout value (NLA_U64)
  * @NFTA_SET_ELEM_EXPIRATION: expiration time (NLA_U64)
  * @NFTA_SET_ELEM_USERDATA: user data (NLA_BINARY)
+ * @NFTA_SET_ELEM_EXPR: expression (NLA_NESTED: nft_expr_attributes)
  */
 enum nft_set_elem_attributes {
 	NFTA_SET_ELEM_UNSPEC,
@@ -331,6 +332,7 @@ enum nft_set_elem_attributes {
 	NFTA_SET_ELEM_TIMEOUT,
 	NFTA_SET_ELEM_EXPIRATION,
 	NFTA_SET_ELEM_USERDATA,
+	NFTA_SET_ELEM_EXPR,
 	__NFTA_SET_ELEM_MAX
 };
 #define NFTA_SET_ELEM_MAX	(__NFTA_SET_ELEM_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index e97bee5..8830811 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2904,6 +2904,9 @@ const struct nft_set_ext_type nft_set_ext_types[] = {
 	[NFT_SET_EXT_DATA]		= {
 		.align	= __alignof__(u32),
 	},
+	[NFT_SET_EXT_EXPR]		= {
+		.align	= __alignof__(struct nft_expr),
+	},
 	[NFT_SET_EXT_FLAGS]		= {
 		.len	= sizeof(u8),
 		.align	= __alignof__(u8),
@@ -2990,6 +2993,10 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 			  set->dlen) < 0)
 		goto nla_put_failure;
 
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_EXPR) &&
+	    nft_expr_dump(skb, NFTA_SET_ELEM_EXPR, nft_set_ext_expr(ext)) < 0)
+		goto nla_put_failure;
+
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_FLAGS) &&
 	    nla_put_be32(skb, NFTA_SET_ELEM_FLAGS,
 		         htonl(*nft_set_ext_flags(ext))))
@@ -3276,6 +3283,8 @@ void nft_set_elem_destroy(const struct nft_set *set, void *elem)
 	nft_data_uninit(nft_set_ext_key(ext), NFT_DATA_VALUE);
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
 		nft_data_uninit(nft_set_ext_data(ext), set->dtype);
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_EXPR))
+		nf_tables_expr_destroy(NULL, nft_set_ext_expr(ext));
 
 	kfree(elem);
 }
-- 
1.7.10.4

