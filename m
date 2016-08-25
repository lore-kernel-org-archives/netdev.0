From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH nf-next,v2 2/2] netfilter: nf_tables: honor NLM_F_EXCL flag in set element insertion
Date: Thu, 25 Aug 2016 16:41:27 +0200
Message-ID: <1472136087-1338-2-git-send-email-pablo@netfilter.org>
References: <1472136087-1338-1-git-send-email-pablo@netfilter.org>
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56778 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756774AbcHYOnS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 10:43:18 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id DE2BB1022B1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 16:43:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D9201114D6C
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 16:43:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 971ED114D68
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 16:43:06 +0200 (CEST)
In-Reply-To: <1472136087-1338-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the NLM_F_EXCL flag is set, then new elements that clash with an
existing one return EEXIST. In case you try to add an element whose
data area differs from what we have, then this returns EBUSY. If no
flag is specified at all, then this returns success to userspace.

This patch also update the set insert operation so we can fetch the
existing element that clashes with the one you want to add, we need
this to make sure the element data doesn't differ.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
v2: Adapt this patch to semantics changes in rhashtable_lookup_get_insert_key()
    proposed by Herbert.

 include/net/netfilter/nf_tables.h |  3 ++-
 net/netfilter/nf_tables_api.c     | 20 +++++++++++++++-----
 net/netfilter/nft_set_hash.c      | 17 +++++++++++++----
 net/netfilter/nft_set_rbtree.c    | 12 ++++++++----
 4 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f2f1339..8972468 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -251,7 +251,8 @@ struct nft_set_ops {
 
 	int				(*insert)(const struct net *net,
 						  const struct nft_set *set,
-						  const struct nft_set_elem *elem);
+						  const struct nft_set_elem *elem,
+						  struct nft_set_ext **ext);
 	void				(*activate)(const struct net *net,
 						    const struct nft_set *set,
 						    const struct nft_set_elem *elem);
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 221d27f..bd9715e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3483,12 +3483,12 @@ static int nft_setelem_parse_flags(const struct nft_set *set,
 }
 
 static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
-			    const struct nlattr *attr)
+			    const struct nlattr *attr, u32 nlmsg_flags)
 {
 	struct nlattr *nla[NFTA_SET_ELEM_MAX + 1];
 	struct nft_data_desc d1, d2;
 	struct nft_set_ext_tmpl tmpl;
-	struct nft_set_ext *ext;
+	struct nft_set_ext *ext, *ext2;
 	struct nft_set_elem elem;
 	struct nft_set_binding *binding;
 	struct nft_userdata *udata;
@@ -3615,9 +3615,19 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err4;
 
 	ext->genmask = nft_genmask_cur(ctx->net) | NFT_SET_ELEM_BUSY_MASK;
-	err = set->ops->insert(ctx->net, set, &elem);
-	if (err < 0)
+	err = set->ops->insert(ctx->net, set, &elem, &ext2);
+	if (err) {
+		if (err == -EEXIST) {
+			if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA) &&
+			    nft_set_ext_exists(ext2, NFT_SET_EXT_DATA) &&
+			    memcmp(nft_set_ext_data(ext),
+				   nft_set_ext_data(ext2), set->dlen) != 0)
+				err = -EBUSY;
+			else if (!(nlmsg_flags & NLM_F_EXCL))
+				err = 0;
+		}
 		goto err5;
+	}
 
 	nft_trans_elem(trans) = elem;
 	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
@@ -3673,7 +3683,7 @@ static int nf_tables_newsetelem(struct net *net, struct sock *nlsk,
 		    !atomic_add_unless(&set->nelems, 1, set->size + set->ndeact))
 			return -ENFILE;
 
-		err = nft_add_set_elem(&ctx, set, attr);
+		err = nft_add_set_elem(&ctx, set, attr, nlh->nlmsg_flags);
 		if (err < 0) {
 			atomic_dec(&set->nelems);
 			break;
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 564fa79..3794cb2 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -126,7 +126,8 @@ err1:
 }
 
 static int nft_hash_insert(const struct net *net, const struct nft_set *set,
-			   const struct nft_set_elem *elem)
+			   const struct nft_set_elem *elem,
+			   struct nft_set_ext **ext)
 {
 	struct nft_hash *priv = nft_set_priv(set);
 	struct nft_hash_elem *he = elem->priv;
@@ -135,9 +136,17 @@ static int nft_hash_insert(const struct net *net, const struct nft_set *set,
 		.set	 = set,
 		.key	 = elem->key.val.data,
 	};
-
-	return rhashtable_lookup_insert_key(&priv->ht, &arg, &he->node,
-					    nft_hash_params);
+	struct nft_hash_elem *prev;
+
+	prev = rhashtable_lookup_get_insert_key(&priv->ht, &arg, &he->node,
+					       nft_hash_params);
+	if (IS_ERR(prev))
+		return PTR_ERR(prev);
+	if (prev) {
+		*ext = &prev->ext;
+		return -EEXIST;
+	}
+	return 0;
 }
 
 static void nft_hash_activate(const struct net *net, const struct nft_set *set,
diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index 6473936..038682d 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -94,7 +94,8 @@ out:
 }
 
 static int __nft_rbtree_insert(const struct net *net, const struct nft_set *set,
-			       struct nft_rbtree_elem *new)
+			       struct nft_rbtree_elem *new,
+			       struct nft_set_ext **ext)
 {
 	struct nft_rbtree *priv = nft_set_priv(set);
 	u8 genmask = nft_genmask_next(net);
@@ -122,8 +123,10 @@ static int __nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 				else if (!nft_rbtree_interval_end(rbe) &&
 					 nft_rbtree_interval_end(new))
 					p = &parent->rb_right;
-				else
+				else {
+					*ext = &rbe->ext;
 					return -EEXIST;
+				}
 			}
 		}
 	}
@@ -133,13 +136,14 @@ static int __nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 }
 
 static int nft_rbtree_insert(const struct net *net, const struct nft_set *set,
-			     const struct nft_set_elem *elem)
+			     const struct nft_set_elem *elem,
+			     struct nft_set_ext **ext)
 {
 	struct nft_rbtree_elem *rbe = elem->priv;
 	int err;
 
 	spin_lock_bh(&nft_rbtree_lock);
-	err = __nft_rbtree_insert(net, set, rbe);
+	err = __nft_rbtree_insert(net, set, rbe, ext);
 	spin_unlock_bh(&nft_rbtree_lock);
 
 	return err;
-- 
2.1.4
