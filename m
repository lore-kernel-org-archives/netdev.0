From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 7/7] xfrm: remove skb_icv_walk
Date: Thu, 16 Jul 2009 13:21:13 +0200
Message-ID: <20090716112113.GW20288@secunet.com>
References: <20090716111548.GP20288@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090716111548.GP20288@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The last users of skb_icv_walk are converted to ahash now,
so skb_icv_walk is unused and can be removed.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h   |    3 --
 net/xfrm/xfrm_algo.c |   78 --------------------------------------------------
 2 files changed, 0 insertions(+), 81 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9e3a3f4..8181541 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1500,9 +1500,6 @@ struct scatterlist;
 typedef int (icv_update_fn_t)(struct hash_desc *, struct scatterlist *,
 			      unsigned int);
 
-extern int skb_icv_walk(const struct sk_buff *skb, struct hash_desc *tfm,
-			int offset, int len, icv_update_fn_t icv_update);
-
 static inline int xfrm_addr_cmp(xfrm_address_t *a, xfrm_address_t *b,
 				int family)
 {
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index faf54c6..b393410 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -689,84 +689,6 @@ int xfrm_count_enc_supported(void)
 }
 EXPORT_SYMBOL_GPL(xfrm_count_enc_supported);
 
-/* Move to common area: it is shared with AH. */
-
-int skb_icv_walk(const struct sk_buff *skb, struct hash_desc *desc,
-		 int offset, int len, icv_update_fn_t icv_update)
-{
-	int start = skb_headlen(skb);
-	int i, copy = start - offset;
-	struct sk_buff *frag_iter;
-	struct scatterlist sg;
-	int err;
-
-	/* Checksum header. */
-	if (copy > 0) {
-		if (copy > len)
-			copy = len;
-
-		sg_init_one(&sg, skb->data + offset, copy);
-
-		err = icv_update(desc, &sg, copy);
-		if (unlikely(err))
-			return err;
-
-		if ((len -= copy) == 0)
-			return 0;
-		offset += copy;
-	}
-
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		int end;
-
-		WARN_ON(start > offset + len);
-
-		end = start + skb_shinfo(skb)->frags[i].size;
-		if ((copy = end - offset) > 0) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-
-			if (copy > len)
-				copy = len;
-
-			sg_init_table(&sg, 1);
-			sg_set_page(&sg, frag->page, copy,
-				    frag->page_offset + offset-start);
-
-			err = icv_update(desc, &sg, copy);
-			if (unlikely(err))
-				return err;
-
-			if (!(len -= copy))
-				return 0;
-			offset += copy;
-		}
-		start = end;
-	}
-
-	skb_walk_frags(skb, frag_iter) {
-		int end;
-
-		WARN_ON(start > offset + len);
-
-		end = start + frag_iter->len;
-		if ((copy = end - offset) > 0) {
-			if (copy > len)
-				copy = len;
-			err = skb_icv_walk(frag_iter, desc, offset-start,
-					   copy, icv_update);
-			if (unlikely(err))
-				return err;
-			if ((len -= copy) == 0)
-				return 0;
-			offset += copy;
-		}
-		start = end;
-	}
-	BUG_ON(len);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(skb_icv_walk);
