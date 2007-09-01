From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [SKBUFF]: Fix up csum_start when head room changes
Date: Sat, 1 Sep 2007 09:13:33 +0800
Message-ID: <20070901011333.GA5223@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4019 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751323AbXIABNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 21:13:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[SKBUFF]: Fix up csum_start when head room changes

Thanks for noticing the bug where csum_start is not updated
when the head room changes.

This patch fixes that.  It also moves the csum/ip_summed
copying into copy_skb_header so that skb_copy_expand gets
it too.  I've checked its callers and no one should be upset
by this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 35021eb..944189d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -472,6 +472,9 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #ifdef CONFIG_INET
 	new->sp		= secpath_get(old->sp);
 #endif
+	new->csum_start = old->csum_start;
+	new->csum_offset = old->csum_offset;
+	new->ip_summed = old->ip_summed;
 	new->transport_header = old->transport_header;
 	new->network_header   = old->network_header;
 	new->mac_header	      = old->mac_header;
@@ -545,8 +548,6 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 	skb_reserve(n, headerlen);
 	/* Set the tail pointer and length */
 	skb_put(n, skb->len);
-	n->csum	     = skb->csum;
-	n->ip_summed = skb->ip_summed;
 
 	if (skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len))
 		BUG();
@@ -589,8 +590,6 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 	skb_put(n, skb_headlen(skb));
 	/* Copy the bytes */
 	skb_copy_from_linear_data(skb, n->data, n->len);
-	n->csum	     = skb->csum;
-	n->ip_summed = skb->ip_summed;
 
 	n->truesize += skb->data_len;
 	n->data_len  = skb->data_len;
@@ -686,6 +685,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->transport_header += off;
 	skb->network_header   += off;
 	skb->mac_header	      += off;
+	skb->csum_start       += off;
 	skb->cloned   = 0;
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
@@ -734,9 +734,6 @@ struct sk_buff *skb_realloc_headroom(struct sk_buff *skb, unsigned int headroom)
  *
  *	You must pass %GFP_ATOMIC as the allocation priority if this function
  *	is called from an interrupt.
- *
- *	BUG ALERT: ip_summed is not copied. Why does this work? Is it used
- *	only by netfilter in the cases when checksum is recalculated? --ANK
  */
 struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 				int newheadroom, int newtailroom,
@@ -749,7 +746,7 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 				      gfp_mask);
 	int oldheadroom = skb_headroom(skb);
 	int head_copy_len, head_copy_off;
-	int off = 0;
+	int off;
 
 	if (!n)
 		return NULL;
@@ -773,12 +770,13 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 
 	copy_skb_header(n, skb);
 
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
 	off                  = newheadroom - oldheadroom;
-#endif
+	n->csum_start       += off;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
 	n->transport_header += off;
 	n->network_header   += off;
 	n->mac_header	    += off;
+#endif
 
 	return n;
 }
