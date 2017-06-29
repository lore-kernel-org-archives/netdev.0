From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/29] netfilter: nft_set_hash: add non-resizable hashtable implementation
Date: Fri, 30 Jun 2017 00:53:15 +0200
Message-ID: <1498776807-11124-18-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57604 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752232AbdF2Wxu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:50 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 241DABDF60
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 07216DA812
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B5C6CD1D96
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:36 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a simple non-resizable hashtable implementation. If the
user specifies the set size, then this new faster hashtable flavour is
selected.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_hash.c | 210 +++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 202 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 466cb7092dfa..b2eab94362d6 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -371,14 +371,181 @@ static u32 nft_hash_buckets(u32 size)
 static bool nft_rhash_estimate(const struct nft_set_desc *desc, u32 features,
 			       struct nft_set_estimate *est)
 {
-	if (desc->size)
-		est->size = sizeof(struct nft_rhash) +
-			    nft_hash_buckets(desc->size) *
-			    sizeof(struct nft_rhash_elem *) +
-			    desc->size * sizeof(struct nft_rhash_elem);
-	else
-		est->size = ~0;
+	est->size   = ~0;
+	est->lookup = NFT_SET_CLASS_O_1;
+	est->space  = NFT_SET_CLASS_O_N;
+
+	return true;
+}
+
+struct nft_hash {
+	u32				seed;
+	u32				buckets;
+	struct hlist_head		table[];
+};
+
+struct nft_hash_elem {
+	struct hlist_node		node;
+	struct nft_set_ext		ext;
+};
+
+static bool nft_hash_lookup(const struct net *net, const struct nft_set *set,
+			    const u32 *key, const struct nft_set_ext **ext)
+{
+	struct nft_hash *priv = nft_set_priv(set);
+	u8 genmask = nft_genmask_cur(net);
+	const struct nft_hash_elem *he;
+	u32 hash;
+
+	hash = jhash(key, set->klen, priv->seed);
+	hash = reciprocal_scale(hash, priv->buckets);
+	hlist_for_each_entry_rcu(he, &priv->table[hash], node) {
+		if (!memcmp(nft_set_ext_key(&he->ext), key, set->klen) &&
+		    nft_set_elem_active(&he->ext, genmask)) {
+			*ext = &he->ext;
+			return true;
+		}
+	}
+	return false;
+}
+
+static int nft_hash_insert(const struct net *net, const struct nft_set *set,
+			   const struct nft_set_elem *elem,
+			   struct nft_set_ext **ext)
+{
+	struct nft_hash_elem *this = elem->priv, *he;
+	struct nft_hash *priv = nft_set_priv(set);
+	u8 genmask = nft_genmask_next(net);
+	u32 hash;
+
+	hash = jhash(nft_set_ext_key(&this->ext), set->klen, priv->seed);
+	hash = reciprocal_scale(hash, priv->buckets);
+	hlist_for_each_entry(he, &priv->table[hash], node) {
+		if (!memcmp(nft_set_ext_key(&this->ext),
+			    nft_set_ext_key(&he->ext), set->klen) &&
+		    nft_set_elem_active(&he->ext, genmask)) {
+			*ext = &he->ext;
+			return -EEXIST;
+		}
+	}
+	hlist_add_head_rcu(&this->node, &priv->table[hash]);
+	return 0;
+}
+
+static void nft_hash_activate(const struct net *net, const struct nft_set *set,
+			      const struct nft_set_elem *elem)
+{
+	struct nft_hash_elem *he = elem->priv;
+
+	nft_set_elem_change_active(net, set, &he->ext);
+}
+
+static bool nft_hash_flush(const struct net *net,
+			   const struct nft_set *set, void *priv)
+{
+	struct nft_hash_elem *he = priv;
+
+	nft_set_elem_change_active(net, set, &he->ext);
+	return true;
+}
+
+static void *nft_hash_deactivate(const struct net *net,
+				 const struct nft_set *set,
+				 const struct nft_set_elem *elem)
+{
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *this = elem->priv, *he;
+	u8 genmask = nft_genmask_next(net);
+	u32 hash;
+
+	hash = jhash(nft_set_ext_key(&this->ext), set->klen, priv->seed);
+	hash = reciprocal_scale(hash, priv->buckets);
+	hlist_for_each_entry(he, &priv->table[hash], node) {
+		if (!memcmp(nft_set_ext_key(&this->ext), &elem->key.val,
+			    set->klen) ||
+		    nft_set_elem_active(&he->ext, genmask)) {
+			nft_set_elem_change_active(net, set, &he->ext);
+			return he;
+		}
+	}
+	return NULL;
+}
+
+static void nft_hash_remove(const struct net *net,
+			    const struct nft_set *set,
+			    const struct nft_set_elem *elem)
+{
+	struct nft_hash_elem *he = elem->priv;
+
+	hlist_del_rcu(&he->node);
+}
+
+static void nft_hash_walk(const struct nft_ctx *ctx, struct nft_set *set,
+			  struct nft_set_iter *iter)
+{
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he;
+	struct nft_set_elem elem;
+	int i;
+
+	for (i = 0; i < priv->buckets; i++) {
+		hlist_for_each_entry_rcu(he, &priv->table[i], node) {
+			if (iter->count < iter->skip)
+				goto cont;
+			if (!nft_set_elem_active(&he->ext, iter->genmask))
+				goto cont;
+
+			elem.priv = he;
+
+			iter->err = iter->fn(ctx, set, iter, &elem);
+			if (iter->err < 0)
+				return;
+cont:
+			iter->count++;
+		}
+	}
+}
+
+static unsigned int nft_hash_privsize(const struct nlattr * const nla[],
+				      const struct nft_set_desc *desc)
+{
+	return sizeof(struct nft_hash) +
+	       nft_hash_buckets(desc->size) * sizeof(struct hlist_head);
+}
+
+static int nft_hash_init(const struct nft_set *set,
+			 const struct nft_set_desc *desc,
+			 const struct nlattr * const tb[])
+{
+	struct nft_hash *priv = nft_set_priv(set);
+
+	priv->buckets = nft_hash_buckets(desc->size);
+	get_random_bytes(&priv->seed, sizeof(priv->seed));
+
+	return 0;
+}
+
+static void nft_hash_destroy(const struct nft_set *set)
+{
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he;
+	struct hlist_node *next;
+	int i;
+
+	for (i = 0; i < priv->buckets; i++) {
+		hlist_for_each_entry_safe(he, next, &priv->table[i], node) {
+			hlist_del_rcu(&he->node);
+			nft_set_elem_destroy(set, he, true);
+		}
+	}
+}
 
+static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
+			      struct nft_set_estimate *est)
+{
+	est->size   = sizeof(struct nft_hash) +
+		      nft_hash_buckets(desc->size) * sizeof(struct hlist_head) +
+		      desc->size * sizeof(struct nft_hash_elem);
 	est->lookup = NFT_SET_CLASS_O_1;
 	est->space  = NFT_SET_CLASS_O_N;
 
@@ -404,8 +571,35 @@ static struct nft_set_ops nft_rhash_ops __read_mostly = {
 	.features	= NFT_SET_MAP | NFT_SET_OBJECT | NFT_SET_TIMEOUT,
 };
 
+static struct nft_set_ops nft_hash_ops __read_mostly = {
+	.type		= &nft_hash_type,
+	.privsize       = nft_hash_privsize,
+	.elemsize	= offsetof(struct nft_hash_elem, ext),
+	.estimate	= nft_hash_estimate,
+	.init		= nft_hash_init,
+	.destroy	= nft_hash_destroy,
+	.insert		= nft_hash_insert,
+	.activate	= nft_hash_activate,
+	.deactivate	= nft_hash_deactivate,
+	.flush		= nft_hash_flush,
+	.remove		= nft_hash_remove,
+	.lookup		= nft_hash_lookup,
+	.walk		= nft_hash_walk,
+	.features	= NFT_SET_MAP | NFT_SET_OBJECT,
+};
+
+static const struct nft_set_ops *
+nft_hash_select_ops(const struct nft_ctx *ctx, const struct nft_set_desc *desc,
+		    u32 flags)
+{
+	if (desc->size)
+		return &nft_hash_ops;
+
+	return &nft_rhash_ops;
+}
+
 static struct nft_set_type nft_hash_type __read_mostly = {
-	.ops		= &nft_rhash_ops,
+	.select_ops	= nft_hash_select_ops,
 	.owner		= THIS_MODULE,
 };
 
-- 
2.1.4
