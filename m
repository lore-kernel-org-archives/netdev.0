From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/21] netfilter: nf_tables: variable sized set element keys / data
Date: Mon, 13 Apr 2015 21:29:53 +0200
Message-ID: <1428953401-4838-15-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39709 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572AbbDMT0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:26:01 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

This patch changes sets to support variable sized set element keys / data
up to 64 bytes each by using variable sized set extensions. This allows
to use concatenations with bigger data items suchs as IPv6 addresses.

As a side effect, small keys/data now don't require the full 16 bytes
of struct nft_data anymore but just the space they need.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |    5 ++++-
 include/uapi/linux/netfilter/nf_tables.h |    3 +++
 net/netfilter/nf_tables_api.c            |   27 ++++++++++++---------------
 net/netfilter/nft_hash.c                 |    4 ++--
 net/netfilter/nft_rbtree.c               |    3 ++-
 5 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 160577b..cb42da1 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -158,7 +158,10 @@ struct nft_userdata {
  *	@priv: element private data and extensions
  */
 struct nft_set_elem {
-	struct nft_data		key;
+	union {
+		u32		buf[NFT_DATA_VALUE_MAXLEN / sizeof(u32)];
+		struct nft_data	val;
+	} key;
 	void			*priv;
 };
 
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 4221a6c..be8584c 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -388,6 +388,9 @@ enum nft_data_attributes {
 };
 #define NFTA_DATA_MAX		(__NFTA_DATA_MAX - 1)
 
+/* Maximum length of a value */
+#define NFT_DATA_VALUE_MAXLEN	64
+
 /**
  * enum nft_verdict_attributes - nf_tables verdict netlink attributes
  *
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2b3f88f..ed0e70e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2608,7 +2608,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	}
 
 	desc.klen = ntohl(nla_get_be32(nla[NFTA_SET_KEY_LEN]));
-	if (desc.klen == 0 || desc.klen > FIELD_SIZEOF(struct nft_data, data))
+	if (desc.klen == 0 || desc.klen > NFT_DATA_VALUE_MAXLEN)
 		return -EINVAL;
 
 	flags = 0;
@@ -2634,11 +2634,10 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 			if (nla[NFTA_SET_DATA_LEN] == NULL)
 				return -EINVAL;
 			desc.dlen = ntohl(nla_get_be32(nla[NFTA_SET_DATA_LEN]));
-			if (desc.dlen == 0 ||
-			    desc.dlen > FIELD_SIZEOF(struct nft_data, data))
+			if (desc.dlen == 0 || desc.dlen > NFT_DATA_VALUE_MAXLEN)
 				return -EINVAL;
 		} else
-			desc.dlen = sizeof(struct nft_data);
+			desc.dlen = sizeof(struct nft_verdict);
 	} else if (flags & NFT_SET_MAP)
 		return -EINVAL;
 
@@ -2854,12 +2853,10 @@ void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
 
 const struct nft_set_ext_type nft_set_ext_types[] = {
 	[NFT_SET_EXT_KEY]		= {
-		.len	= sizeof(struct nft_data),
-		.align	= __alignof__(struct nft_data),
+		.align	= __alignof__(u32),
 	},
 	[NFT_SET_EXT_DATA]		= {
-		.len	= sizeof(struct nft_data),
-		.align	= __alignof__(struct nft_data),
+		.align	= __alignof__(u32),
 	},
 	[NFT_SET_EXT_FLAGS]		= {
 		.len	= sizeof(u8),
@@ -3299,7 +3296,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		timeout = set->timeout;
 	}
 
-	err = nft_data_init(ctx, &elem.key, sizeof(elem.key), &d1,
+	err = nft_data_init(ctx, &elem.key.val, sizeof(elem.key), &d1,
 			    nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
 		goto err1;
@@ -3307,7 +3304,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	if (d1.type != NFT_DATA_VALUE || d1.len != set->klen)
 		goto err2;
 
-	nft_set_ext_add(&tmpl, NFT_SET_EXT_KEY);
+	nft_set_ext_add_length(&tmpl, NFT_SET_EXT_KEY, d1.len);
 	if (timeout > 0) {
 		nft_set_ext_add(&tmpl, NFT_SET_EXT_EXPIRATION);
 		if (timeout != set->timeout)
@@ -3342,7 +3339,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 				goto err3;
 		}
 
-		nft_set_ext_add(&tmpl, NFT_SET_EXT_DATA);
+		nft_set_ext_add_length(&tmpl, NFT_SET_EXT_DATA, d2.len);
 	}
 
 	/* The full maximum length of userdata can exceed the maximum
@@ -3358,7 +3355,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	}
 
 	err = -ENOMEM;
-	elem.priv = nft_set_elem_init(set, &tmpl, elem.key.data, data.data,
+	elem.priv = nft_set_elem_init(set, &tmpl, elem.key.val.data, data.data,
 				      timeout, GFP_KERNEL);
 	if (elem.priv == NULL)
 		goto err3;
@@ -3393,7 +3390,7 @@ err3:
 	if (nla[NFTA_SET_ELEM_DATA] != NULL)
 		nft_data_uninit(&data, d2.type);
 err2:
-	nft_data_uninit(&elem.key, d1.type);
+	nft_data_uninit(&elem.key.val, d1.type);
 err1:
 	return err;
 }
@@ -3460,7 +3457,7 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 	if (nla[NFTA_SET_ELEM_KEY] == NULL)
 		goto err1;
 
-	err = nft_data_init(ctx, &elem.key, sizeof(elem.key), &desc,
+	err = nft_data_init(ctx, &elem.key.val, sizeof(elem.key), &desc,
 			    nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
 		goto err1;
@@ -3488,7 +3485,7 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 err3:
 	kfree(trans);
 err2:
-	nft_data_uninit(&elem.key, desc.type);
+	nft_data_uninit(&elem.key.val, desc.type);
 err1:
 	return err;
 }
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 767df41..3f9d45d 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -133,7 +133,7 @@ static int nft_hash_insert(const struct nft_set *set,
 	struct nft_hash_cmp_arg arg = {
 		.genmask = nft_genmask_next(read_pnet(&set->pnet)),
 		.set	 = set,
-		.key	 = elem->key.data,
+		.key	 = elem->key.val.data,
 	};
 
 	return rhashtable_lookup_insert_key(&priv->ht, &arg, &he->node,
@@ -157,7 +157,7 @@ static void *nft_hash_deactivate(const struct nft_set *set,
 	struct nft_hash_cmp_arg arg = {
 		.genmask = nft_genmask_next(read_pnet(&set->pnet)),
 		.set	 = set,
-		.key	 = elem->key.data,
+		.key	 = elem->key.val.data,
 	};
 
 	rcu_read_lock();
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index b888e0c..1c30f41 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -152,7 +152,8 @@ static void *nft_rbtree_deactivate(const struct nft_set *set,
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
-		d = memcmp(nft_set_ext_key(&rbe->ext), &elem->key, set->klen);
+		d = memcmp(nft_set_ext_key(&rbe->ext), &elem->key.val,
+					   set->klen);
 		if (d < 0)
 			parent = parent->rb_left;
 		else if (d > 0)
-- 
1.7.10.4
