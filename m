From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/20] netfilter: nf_tables: prepare set element accounting for async updates
Date: Thu,  9 Apr 2015 13:35:01 +0200
Message-ID: <1428579304-5520-18-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33180 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933092AbbDILb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:26 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Use atomic operations for the element count to avoid races with async
updates.

To properly handle the transactional semantics during netlink updates,
deleted but not yet committed elements are accounted for seperately and
are treated as being already removed. This means for the duration of
a netlink transaction, the limit might be exceeded by the amount of
elements deleted. Set implementations must be prepared to handle this.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    4 +++-
 net/netfilter/nf_tables_api.c     |   21 ++++++++++++---------
 net/netfilter/nft_hash.c          |    3 ++-
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index a785699..7464233 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -258,6 +258,7 @@ void nft_unregister_set(struct nft_set_ops *ops);
  * 	@dtype: data type (verdict or numeric type defined by userspace)
  * 	@size: maximum set size
  * 	@nelems: number of elements
+ * 	@ndeact: number of deactivated elements queued for removal
  * 	@timeout: default timeout value in msecs
  * 	@gc_int: garbage collection interval in msecs
  *	@policy: set parameterization (see enum nft_set_policies)
@@ -275,7 +276,8 @@ struct nft_set {
 	u32				ktype;
 	u32				dtype;
 	u32				size;
-	u32				nelems;
+	atomic_t			nelems;
+	u32				ndeact;
 	u64				timeout;
 	u32				gc_int;
 	u16				policy;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0dab872..27d1bf5 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3238,9 +3238,6 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	u32 flags;
 	int err;
 
-	if (set->size && set->nelems == set->size)
-		return -ENFILE;
-
 	err = nla_parse_nested(nla, NFTA_SET_ELEM_MAX, attr,
 			       nft_set_elem_policy);
 	if (err < 0)
@@ -3391,11 +3388,15 @@ static int nf_tables_newsetelem(struct sock *nlsk, struct sk_buff *skb,
 		return -EBUSY;
 
 	nla_for_each_nested(attr, nla[NFTA_SET_ELEM_LIST_ELEMENTS], rem) {
+		if (set->size &&
+		    !atomic_add_unless(&set->nelems, 1, set->size + set->ndeact))
+			return -ENFILE;
+
 		err = nft_add_set_elem(&ctx, set, attr);
-		if (err < 0)
+		if (err < 0) {
+			atomic_dec(&set->nelems);
 			break;
-
-		set->nelems++;
+		}
 	}
 	return err;
 }
@@ -3477,7 +3478,7 @@ static int nf_tables_delsetelem(struct sock *nlsk, struct sk_buff *skb,
 		if (err < 0)
 			break;
 
-		set->nelems--;
+		set->ndeact++;
 	}
 	return err;
 }
@@ -3810,6 +3811,8 @@ static int nf_tables_commit(struct sk_buff *skb)
 						 &te->elem,
 						 NFT_MSG_DELSETELEM, 0);
 			te->set->ops->remove(te->set, &te->elem);
+			atomic_dec(&te->set->nelems);
+			te->set->ndeact--;
 			break;
 		}
 	}
@@ -3913,16 +3916,16 @@ static int nf_tables_abort(struct sk_buff *skb)
 			nft_trans_destroy(trans);
 			break;
 		case NFT_MSG_NEWSETELEM:
-			nft_trans_elem_set(trans)->nelems--;
 			te = (struct nft_trans_elem *)trans->data;
 
 			te->set->ops->remove(te->set, &te->elem);
+			atomic_dec(&te->set->nelems);
 			break;
 		case NFT_MSG_DELSETELEM:
 			te = (struct nft_trans_elem *)trans->data;
 
-			nft_trans_elem_set(trans)->nelems++;
 			te->set->ops->activate(te->set, &te->elem);
+			te->set->ndeact--;
 
 			nft_trans_destroy(trans);
 			break;
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 5923ec5..c74e2bf 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -203,7 +203,7 @@ out:
 
 static void nft_hash_gc(struct work_struct *work)
 {
-	const struct nft_set *set;
+	struct nft_set *set;
 	struct nft_hash_elem *he;
 	struct nft_hash *priv;
 	struct nft_set_gc_batch *gcb = NULL;
@@ -237,6 +237,7 @@ static void nft_hash_gc(struct work_struct *work)
 		if (gcb == NULL)
 			goto out;
 		rhashtable_remove_fast(&priv->ht, &he->node, nft_hash_params);
+		atomic_dec(&set->nelems);
 		nft_set_gc_batch_add(gcb, he);
 	}
 out:
-- 
1.7.10.4
