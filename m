From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/2] tun: fallback if skb_alloc() fails on big packets
Date: Tue, 12 Aug 2008 16:25:53 +1000
Message-ID: <200808121625.53703.rusty@rustcorp.com.au>
References: <200808121624.56948.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56474 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347AbYHLG0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 02:26:08 -0400
In-Reply-To: <200808121624.56948.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_alloc produces linear packets (using kmalloc()).  That can fail,
so should we fall back to making paged skbs.

My original version of this patch always allocate paged skbs for big
packets.  But that made performance drop from 8.4 seconds to 8.8
seconds on 1G lguest->Host TCP xmit.  So now we only do that as a
fallback.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r ffcd4a3f63a8 drivers/net/tun.c
--- a/drivers/net/tun.c	Wed Aug 06 16:19:36 2008 +1000
+++ b/drivers/net/tun.c	Thu Aug 07 06:56:19 2008 +1000
@@ -358,6 +358,66 @@ static unsigned int tun_chr_poll(struct 
 	return mask;
 }
 
+/* prepad is the amount to reserve at front.  len is length after that.
+ * linear is a hint as to how much to copy (usually headers). */
+static struct sk_buff *tun_alloc_skb(size_t prepad, size_t len, size_t linear,
+				     gfp_t gfp)
+{
+	struct sk_buff *skb;
+	unsigned int i;
+
+	skb = alloc_skb(prepad + len, gfp|__GFP_NOWARN);
+	if (skb) {
+		skb_reserve(skb, prepad);
+		skb_put(skb, len); 
+		return skb;
+	}
+
+	/* Under a page?  Don't bother with paged skb. */
+	if (prepad + len < PAGE_SIZE)
+		return NULL;
+
+	/* Start with a normal skb, and add pages. */
+	skb = alloc_skb(prepad + linear, gfp);
+	if (!skb)
+		return NULL;
+
+	skb_reserve(skb, prepad);
+	skb_put(skb, linear); 
+
+	len -= linear;
+
+	for (i = 0; i < MAX_SKB_FRAGS; i++) {
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+
+		f->page = alloc_page(gfp|__GFP_ZERO);
+		if (!f->page)
+			break;
+
+		f->page_offset = 0;
+		f->size = PAGE_SIZE;
+
+		skb->data_len += PAGE_SIZE;
+		skb->len += PAGE_SIZE;
+		skb->truesize += PAGE_SIZE;
+		skb_shinfo(skb)->nr_frags++;
+
+		if (len < PAGE_SIZE) {
+			len = 0;
+			break;
+		}
+		len -= PAGE_SIZE;
+	}
+
+	/* Too large, or alloc fail? */
+	if (unlikely(len)) {
+		kfree_skb(skb);
+		skb = NULL;
+	}
+
+	return skb;
+}
+
 /* Get packet from user space buffer */
 static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t count)
 {
@@ -391,14 +451,12 @@ static __inline__ ssize_t tun_get_user(s
 			return -EINVAL;
 	}
 
-	if (!(skb = alloc_skb(len + align, GFP_KERNEL))) {
+	if (!(skb = tun_alloc_skb(align, len, gso.hdr_len, GFP_KERNEL))) {
 		tun->dev->stats.rx_dropped++;
 		return -ENOMEM;
 	}
 
-	if (align)
-		skb_reserve(skb, align);
-	if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
+	if (skb_copy_datagram_from_iovec(skb, 0, iv, len)) {
 		tun->dev->stats.rx_dropped++;
 		kfree_skb(skb);
 		return -EFAULT;
