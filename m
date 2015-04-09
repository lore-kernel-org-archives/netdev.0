From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/20] netfilter: nf_tables: add set element timeout support
Date: Thu,  9 Apr 2015 13:34:46 +0200
Message-ID: <1428579304-5520-3-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33026 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932867AbbDILbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:05 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add API support for set element timeouts. Elements can have a individual
timeout value specified, overriding the sets' default.

Two new extension types are used for timeouts - the timeout value and
the expiration time. The timeout value only exists if it differs from
the default value.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |   20 +++++++++++
 include/uapi/linux/netfilter/nf_tables.h |    4 +++
 net/netfilter/nf_tables_api.c            |   53 ++++++++++++++++++++++++++++--
 3 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 8936803..f2726c5 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -329,12 +329,16 @@ void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
  *	@NFT_SET_EXT_KEY: element key
  *	@NFT_SET_EXT_DATA: mapping data
  *	@NFT_SET_EXT_FLAGS: element flags
+ *	@NFT_SET_EXT_TIMEOUT: element timeout
+ *	@NFT_SET_EXT_EXPIRATION: element expiration time
  *	@NFT_SET_EXT_NUM: number of extension types
  */
 enum nft_set_extensions {
 	NFT_SET_EXT_KEY,
 	NFT_SET_EXT_DATA,
 	NFT_SET_EXT_FLAGS,
+	NFT_SET_EXT_TIMEOUT,
+	NFT_SET_EXT_EXPIRATION,
 	NFT_SET_EXT_NUM
 };
 
@@ -431,6 +435,22 @@ static inline u8 *nft_set_ext_flags(const struct nft_set_ext *ext)
 	return nft_set_ext(ext, NFT_SET_EXT_FLAGS);
 }
 
+static inline u64 *nft_set_ext_timeout(const struct nft_set_ext *ext)
+{
+	return nft_set_ext(ext, NFT_SET_EXT_TIMEOUT);
+}
+
+static inline unsigned long *nft_set_ext_expiration(const struct nft_set_ext *ext)
+{
+	return nft_set_ext(ext, NFT_SET_EXT_EXPIRATION);
+}
+
+static inline bool nft_set_elem_expired(const struct nft_set_ext *ext)
+{
+	return nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION) &&
+	       time_is_before_eq_jiffies(*nft_set_ext_expiration(ext));
+}
+
 static inline struct nft_set_ext *nft_set_elem_ext(const struct nft_set *set,
 						   void *elem)
 {
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 971d245..83441cc 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -290,12 +290,16 @@ enum nft_set_elem_flags {
  * @NFTA_SET_ELEM_KEY: key value (NLA_NESTED: nft_data)
  * @NFTA_SET_ELEM_DATA: data value of mapping (NLA_NESTED: nft_data_attributes)
  * @NFTA_SET_ELEM_FLAGS: bitmask of nft_set_elem_flags (NLA_U32)
+ * @NFTA_SET_ELEM_TIMEOUT: timeout value (NLA_U64)
+ * @NFTA_SET_ELEM_EXPIRATION: expiration time (NLA_U64)
  */
 enum nft_set_elem_attributes {
 	NFTA_SET_ELEM_UNSPEC,
 	NFTA_SET_ELEM_KEY,
 	NFTA_SET_ELEM_DATA,
 	NFTA_SET_ELEM_FLAGS,
+	NFTA_SET_ELEM_TIMEOUT,
+	NFTA_SET_ELEM_EXPIRATION,
 	__NFTA_SET_ELEM_MAX
 };
 #define NFTA_SET_ELEM_MAX	(__NFTA_SET_ELEM_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 6320b64..9e032db 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2863,6 +2863,14 @@ const struct nft_set_ext_type nft_set_ext_types[] = {
 		.len	= sizeof(u8),
 		.align	= __alignof__(u8),
 	},
+	[NFT_SET_EXT_TIMEOUT]		= {
+		.len	= sizeof(u64),
+		.align	= __alignof__(u64),
+	},
+	[NFT_SET_EXT_EXPIRATION]	= {
+		.len	= sizeof(unsigned long),
+		.align	= __alignof__(unsigned long),
+	},
 };
 EXPORT_SYMBOL_GPL(nft_set_ext_types);
 
@@ -2874,6 +2882,7 @@ static const struct nla_policy nft_set_elem_policy[NFTA_SET_ELEM_MAX + 1] = {
 	[NFTA_SET_ELEM_KEY]		= { .type = NLA_NESTED },
 	[NFTA_SET_ELEM_DATA]		= { .type = NLA_NESTED },
 	[NFTA_SET_ELEM_FLAGS]		= { .type = NLA_U32 },
+	[NFTA_SET_ELEM_TIMEOUT]		= { .type = NLA_U64 },
 };
 
 static const struct nla_policy nft_set_elem_list_policy[NFTA_SET_ELEM_LIST_MAX + 1] = {
@@ -2935,6 +2944,25 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 		         htonl(*nft_set_ext_flags(ext))))
 		goto nla_put_failure;
 
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_TIMEOUT) &&
+	    nla_put_be64(skb, NFTA_SET_ELEM_TIMEOUT,
+			 cpu_to_be64(*nft_set_ext_timeout(ext))))
+		goto nla_put_failure;
+
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION)) {
+		unsigned long expires, now = jiffies;
+
+		expires = *nft_set_ext_expiration(ext);
+		if (time_before(now, expires))
+			expires -= now;
+		else
+			expires = 0;
+
+		if (nla_put_be64(skb, NFTA_SET_ELEM_EXPIRATION,
+				 cpu_to_be64(jiffies_to_msecs(expires))))
+			goto nla_put_failure;
+	}
+
 	nla_nest_end(skb, nest);
 	return 0;
 
@@ -3158,7 +3186,7 @@ static void *nft_set_elem_init(const struct nft_set *set,
 			       const struct nft_set_ext_tmpl *tmpl,
 			       const struct nft_data *key,
 			       const struct nft_data *data,
-			       gfp_t gfp)
+			       u64 timeout, gfp_t gfp)
 {
 	struct nft_set_ext *ext;
 	void *elem;
@@ -3173,6 +3201,11 @@ static void *nft_set_elem_init(const struct nft_set *set,
 	memcpy(nft_set_ext_key(ext), key, set->klen);
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
 		memcpy(nft_set_ext_data(ext), data, set->dlen);
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION))
+		*nft_set_ext_expiration(ext) =
+			jiffies + msecs_to_jiffies(timeout);
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_TIMEOUT))
+		*nft_set_ext_timeout(ext) = timeout;
 
 	return elem;
 }
@@ -3201,6 +3234,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	struct nft_data data;
 	enum nft_registers dreg;
 	struct nft_trans *trans;
+	u64 timeout;
 	u32 flags;
 	int err;
 
@@ -3241,6 +3275,15 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 			return -EINVAL;
 	}
 
+	timeout = 0;
+	if (nla[NFTA_SET_ELEM_TIMEOUT] != NULL) {
+		if (!(set->flags & NFT_SET_TIMEOUT))
+			return -EINVAL;
+		timeout = be64_to_cpu(nla_get_be64(nla[NFTA_SET_ELEM_TIMEOUT]));
+	} else if (set->flags & NFT_SET_TIMEOUT) {
+		timeout = set->timeout;
+	}
+
 	err = nft_data_init(ctx, &elem.key, &d1, nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
 		goto err1;
@@ -3249,6 +3292,11 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err2;
 
 	nft_set_ext_add(&tmpl, NFT_SET_EXT_KEY);
+	if (timeout > 0) {
+		nft_set_ext_add(&tmpl, NFT_SET_EXT_EXPIRATION);
+		if (timeout != set->timeout)
+			nft_set_ext_add(&tmpl, NFT_SET_EXT_TIMEOUT);
+	}
 
 	if (nla[NFTA_SET_ELEM_DATA] != NULL) {
 		err = nft_data_init(ctx, &data, &d2, nla[NFTA_SET_ELEM_DATA]);
@@ -3277,7 +3325,8 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	}
 
 	err = -ENOMEM;
-	elem.priv = nft_set_elem_init(set, &tmpl, &elem.key, &data, GFP_KERNEL);
+	elem.priv = nft_set_elem_init(set, &tmpl, &elem.key, &data,
+				      timeout, GFP_KERNEL);
 	if (elem.priv == NULL)
 		goto err3;
 
-- 
1.7.10.4
