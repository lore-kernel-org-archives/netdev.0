From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/25] netfilter: nft_hash: use set global element counter instead of private one
Date: Wed, 21 May 2014 11:43:03 +0200
Message-ID: <1400665402-5835-6-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55943 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056AbaEUJnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 05:43:39 -0400
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Now that nf_tables performs global accounting of set elements, it is not
needed in the hash type anymore.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 01884b3..1dfeb67 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -28,7 +28,6 @@ struct nft_hash {
 
 struct nft_hash_table {
 	unsigned int			size;
-	unsigned int			elements;
 	struct nft_hash_elem __rcu	*buckets[];
 };
 
@@ -167,7 +166,6 @@ static int nft_hash_tbl_expand(const struct nft_set *set, struct nft_hash *priv)
 			break;
 		}
 	}
-	ntbl->elements = tbl->elements;
 
 	/* Publish new table */
 	rcu_assign_pointer(priv->tbl, ntbl);
@@ -207,7 +205,6 @@ static int nft_hash_tbl_shrink(const struct nft_set *set, struct nft_hash *priv)
 			;
 		RCU_INIT_POINTER(*pprev, tbl->buckets[i + ntbl->size]);
 	}
-	ntbl->elements = tbl->elements;
 
 	/* Publish new table */
 	rcu_assign_pointer(priv->tbl, ntbl);
@@ -243,10 +240,9 @@ static int nft_hash_insert(const struct nft_set *set,
 	h = nft_hash_data(&he->key, tbl->size, set->klen);
 	RCU_INIT_POINTER(he->next, tbl->buckets[h]);
 	rcu_assign_pointer(tbl->buckets[h], he);
-	tbl->elements++;
 
 	/* Expand table when exceeding 75% load */
-	if (tbl->elements > tbl->size / 4 * 3)
+	if (set->nelems + 1 > tbl->size / 4 * 3)
 		nft_hash_tbl_expand(set, priv);
 
 	return 0;
@@ -274,10 +270,9 @@ static void nft_hash_remove(const struct nft_set *set,
 	RCU_INIT_POINTER(*pprev, he->next);
 	synchronize_rcu();
 	kfree(he);
-	tbl->elements--;
 
 	/* Shrink table beneath 30% load */
-	if (tbl->elements < tbl->size * 3 / 10 &&
+	if (set->nelems - 1 < tbl->size * 3 / 10 &&
 	    tbl->size > NFT_HASH_MIN_SIZE)
 		nft_hash_tbl_shrink(set, priv);
 }
-- 
1.7.10.4
