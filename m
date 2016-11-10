From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/14] netfilter: nf_tables: fix *leak* when expr clone fail
Date: Thu, 10 Nov 2016 01:23:35 +0100
Message-ID: <1478737427-1574-3-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37726 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753161AbcKJAYD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:03 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 18D559620E
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0229EDA803
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E61ECDA80B
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:23:58 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

When nft_expr_clone failed, a series of problems will happen:

1. module refcnt will leak, we call __module_get at the beginning but
   we forget to put it back if ops->clone returns fail
2. memory will be leaked, if clone fail, we just return NULL and forget
   to free the alloced element
3. set->nelems will become incorrect when set->size is specified. If
   clone fail, we should decrease the set->nelems

Now this patch fixes these problems. And fortunately, clone fail will
only happen on counter expression when memory is exhausted.

Fixes: 086f332167d6 ("netfilter: nf_tables: add clone interface to expression operations")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  6 ++++--
 net/netfilter/nf_tables_api.c     | 11 ++++++-----
 net/netfilter/nft_dynset.c        | 16 ++++++++++------
 net/netfilter/nft_set_hash.c      |  4 ++--
 net/netfilter/nft_set_rbtree.c    |  2 +-
 5 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 5031e072567b..741dcded5b4f 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -542,7 +542,8 @@ void *nft_set_elem_init(const struct nft_set *set,
 			const struct nft_set_ext_tmpl *tmpl,
 			const u32 *key, const u32 *data,
 			u64 timeout, gfp_t gfp);
-void nft_set_elem_destroy(const struct nft_set *set, void *elem);
+void nft_set_elem_destroy(const struct nft_set *set, void *elem,
+			  bool destroy_expr);
 
 /**
  *	struct nft_set_gc_batch_head - nf_tables set garbage collection batch
@@ -693,7 +694,6 @@ static inline int nft_expr_clone(struct nft_expr *dst, struct nft_expr *src)
 {
 	int err;
 
-	__module_get(src->ops->type->owner);
 	if (src->ops->clone) {
 		dst->ops = src->ops;
 		err = src->ops->clone(dst, src);
@@ -702,6 +702,8 @@ static inline int nft_expr_clone(struct nft_expr *dst, struct nft_expr *src)
 	} else {
 		memcpy(dst, src, src->ops->size);
 	}
+
+	__module_get(src->ops->type->owner);
 	return 0;
 }
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 24db22257586..86e48aeb20be 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3452,14 +3452,15 @@ void *nft_set_elem_init(const struct nft_set *set,
 	return elem;
 }
 
-void nft_set_elem_destroy(const struct nft_set *set, void *elem)
+void nft_set_elem_destroy(const struct nft_set *set, void *elem,
+			  bool destroy_expr)
 {
 	struct nft_set_ext *ext = nft_set_elem_ext(set, elem);
 
 	nft_data_uninit(nft_set_ext_key(ext), NFT_DATA_VALUE);
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
 		nft_data_uninit(nft_set_ext_data(ext), set->dtype);
-	if (nft_set_ext_exists(ext, NFT_SET_EXT_EXPR))
+	if (destroy_expr && nft_set_ext_exists(ext, NFT_SET_EXT_EXPR))
 		nf_tables_expr_destroy(NULL, nft_set_ext_expr(ext));
 
 	kfree(elem);
@@ -3812,7 +3813,7 @@ void nft_set_gc_batch_release(struct rcu_head *rcu)
 
 	gcb = container_of(rcu, struct nft_set_gc_batch, head.rcu);
 	for (i = 0; i < gcb->head.cnt; i++)
-		nft_set_elem_destroy(gcb->head.set, gcb->elems[i]);
+		nft_set_elem_destroy(gcb->head.set, gcb->elems[i], true);
 	kfree(gcb);
 }
 EXPORT_SYMBOL_GPL(nft_set_gc_batch_release);
@@ -4030,7 +4031,7 @@ static void nf_tables_commit_release(struct nft_trans *trans)
 		break;
 	case NFT_MSG_DELSETELEM:
 		nft_set_elem_destroy(nft_trans_elem_set(trans),
-				     nft_trans_elem(trans).priv);
+				     nft_trans_elem(trans).priv, true);
 		break;
 	}
 	kfree(trans);
@@ -4171,7 +4172,7 @@ static void nf_tables_abort_release(struct nft_trans *trans)
 		break;
 	case NFT_MSG_NEWSETELEM:
 		nft_set_elem_destroy(nft_trans_elem_set(trans),
-				     nft_trans_elem(trans).priv);
+				     nft_trans_elem(trans).priv, true);
 		break;
 	}
 	kfree(trans);
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index bfdb689664b0..31ca94793aa9 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -44,18 +44,22 @@ static void *nft_dynset_new(struct nft_set *set, const struct nft_expr *expr,
 				 &regs->data[priv->sreg_key],
 				 &regs->data[priv->sreg_data],
 				 timeout, GFP_ATOMIC);
-	if (elem == NULL) {
-		if (set->size)
-			atomic_dec(&set->nelems);
-		return NULL;
-	}
+	if (elem == NULL)
+		goto err1;
 
 	ext = nft_set_elem_ext(set, elem);
 	if (priv->expr != NULL &&
 	    nft_expr_clone(nft_set_ext_expr(ext), priv->expr) < 0)
-		return NULL;
+		goto err2;
 
 	return elem;
+
+err2:
+	nft_set_elem_destroy(set, elem, false);
+err1:
+	if (set->size)
+		atomic_dec(&set->nelems);
+	return NULL;
 }
 
 static void nft_dynset_eval(const struct nft_expr *expr,
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 3794cb2fc788..88d9fc8343e7 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -120,7 +120,7 @@ static bool nft_hash_update(struct nft_set *set, const u32 *key,
 	return true;
 
 err2:
-	nft_set_elem_destroy(set, he);
+	nft_set_elem_destroy(set, he, true);
 err1:
 	return false;
 }
@@ -332,7 +332,7 @@ static int nft_hash_init(const struct nft_set *set,
 
 static void nft_hash_elem_destroy(void *ptr, void *arg)
 {
-	nft_set_elem_destroy((const struct nft_set *)arg, ptr);
+	nft_set_elem_destroy((const struct nft_set *)arg, ptr, true);
 }
 
 static void nft_hash_destroy(const struct nft_set *set)
diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index 38b5bda242f8..36493a7cae88 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -266,7 +266,7 @@ static void nft_rbtree_destroy(const struct nft_set *set)
 	while ((node = priv->root.rb_node) != NULL) {
 		rb_erase(node, &priv->root);
 		rbe = rb_entry(node, struct nft_rbtree_elem, node);
-		nft_set_elem_destroy(set, rbe);
+		nft_set_elem_destroy(set, rbe, true);
 	}
 }
 
-- 
2.1.4
