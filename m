From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipsec: ipcomp - Decompress into frags if necessary
Date: Fri, 25 Jul 2008 15:43:28 +0800
Message-ID: <20080725074328.GB16747@gondor.apana.org.au>
References: <20080723.234556.98132946.davem@davemloft.net> <E1KM0Wl-0001zC-00@gondolin.me.apana.org.au> <20080725074109.GA16747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46947 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750927AbYGYHny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 03:43:54 -0400
Content-Disposition: inline
In-Reply-To: <20080725074109.GA16747@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 03:41:09PM +0800, Herbert Xu wrote:
>
> Here is the first part:

And finally:

ipsec: ipcomp - Decompress into frags if necessary

When decompressing extremely large packets allocating them through
kmalloc is prone to failure.  Therefore it's better to use page
frags instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>


diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index b51e804..800f669 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -17,6 +17,7 @@
 
 #include <linux/crypto.h>
 #include <linux/err.h>
+#include <linux/gfp.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
@@ -49,6 +50,7 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
 	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
 	int err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
+	int len;
 
 	if (err)
 		goto out;
@@ -58,13 +60,47 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 		goto out;
 	}
 
-	err = pskb_expand_head(skb, 0, dlen - plen, GFP_ATOMIC);
-	if (err)
-		goto out;
+	len = dlen - plen;
+	if (len > skb_tailroom(skb))
+		len = skb_tailroom(skb);
+
+	skb->truesize += len;
+	__skb_put(skb, len);
+
+	len += plen;
+	skb_copy_to_linear_data(skb, scratch, len);
+
+	while ((scratch += len, dlen -= len) > 0) {
+		skb_frag_t *frag;
+
+		err = -EMSGSIZE;
+		if (WARN_ON(skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS))
+			goto out;
+
+		frag = skb_shinfo(skb)->frags + skb_shinfo(skb)->nr_frags;
+		frag->page = alloc_page(GFP_ATOMIC);
+
+		err = -ENOMEM;
+		if (!frag->page)
+			goto out;
+
+		len = PAGE_SIZE;
+		if (dlen < len)
+			len = dlen;
+
+		memcpy(page_address(frag->page), scratch, len);
+
+		frag->page_offset = 0;
+		frag->size = len;
+		skb->truesize += len;
+		skb->data_len += len;
+		skb->len += len;
+
+		skb_shinfo(skb)->nr_frags++;
+	}
+
+	err = 0;
 
-	skb->truesize += dlen - plen;
-	__skb_put(skb, dlen - plen);
-	skb_copy_to_linear_data(skb, scratch, dlen);
 out:
 	put_cpu();
 	return err;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
