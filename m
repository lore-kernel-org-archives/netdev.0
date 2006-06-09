From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/3] [NET]: Clean up skb_linearize
Date: Fri, 9 Jun 2006 17:42:34 +1000
Message-ID: <20060609074234.GA17580@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34577 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751420AbWFIHmr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:42:47 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

The following patches are based on net-2.6.18.

[NET]: Clean up skb_linearize

The linearisation operation doesn't need to be super-optimised.  So we can
replace __skb_linearize with __pskb_pull_tail which does the same thing but
is more general.

Also, most users of skb_linearize end up testing whether the skb is linear
or not so it helps to make skb_linearize do just that.

Some callers of skb_linearize also use it to copy cloned data, so it's
useful to have a new function skb_linearize_cow to copy the data if it's
either non-linear or cloned.

Last but not least, I've removed the gfp argument since nobody uses it
anymore.  If it's ever needed we can easily add it back.

Misc bugs fixed by this patch:

* via-velocity error handling (also, no SG => no frags)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p1.patch"

diff --git a/drivers/block/aoe/aoenet.c b/drivers/block/aoe/aoenet.c
--- a/drivers/block/aoe/aoenet.c
+++ b/drivers/block/aoe/aoenet.c
@@ -116,8 +116,7 @@ aoenet_rcv(struct sk_buff *skb, struct n
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (skb == NULL)
 		return 0;
-	if (skb_is_nonlinear(skb))
-	if (skb_linearize(skb, GFP_ATOMIC) < 0)
+	if (skb_linearize(skb))
 		goto exit;
 	if (!is_aoe_netif(ifp))
 		goto exit;
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1200,7 +1200,7 @@ static int mv643xx_eth_start_xmit(struct
 	}
 
 	if (has_tiny_unaligned_frags(skb)) {
-		if ((skb_linearize(skb, GFP_ATOMIC) != 0)) {
+		if (__skb_linearize(skb)) {
 			stats->tx_dropped++;
 			printk(KERN_DEBUG "%s: failed to linearize tiny "
 					"unaligned fragment\n", dev->name);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1899,6 +1899,13 @@ static int velocity_xmit(struct sk_buff 
 
 	int pktlen = skb->len;
 
+#ifdef VELOCITY_ZERO_COPY_SUPPORT
+	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
+		kfree_skb(skb);
+		return 0;
+	}
+#endif
+
 	spin_lock_irqsave(&vptr->lock, flags);
 
 	index = vptr->td_curr[qnum];
@@ -1914,8 +1921,6 @@ static int velocity_xmit(struct sk_buff 
 	 */
 	if (pktlen < ETH_ZLEN) {
 		/* Cannot occur until ZC support */
-		if(skb_linearize(skb, GFP_ATOMIC))
-			return 0; 
 		pktlen = ETH_ZLEN;
 		memcpy(tdinfo->buf, skb->data, skb->len);
 		memset(tdinfo->buf + skb->len, 0, ETH_ZLEN - skb->len);
@@ -1933,7 +1938,6 @@ static int velocity_xmit(struct sk_buff 
 		int nfrags = skb_shinfo(skb)->nr_frags;
 		tdinfo->skb = skb;
 		if (nfrags > 6) {
-			skb_linearize(skb, GFP_ATOMIC);
 			memcpy(tdinfo->buf, skb->data, skb->len);
 			tdinfo->skb_dma[0] = tdinfo->buf_dma;
 			td_ptr->tdesc0.pktsize = 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1165,18 +1165,34 @@ static inline int skb_can_coalesce(struc
 	return 0;
 }
 
+static inline int __skb_linearize(struct sk_buff *skb)
+{
+	return __pskb_pull_tail(skb, skb->data_len) ? 0 : -ENOMEM;
+}
+
 /**
  *	skb_linearize - convert paged skb to linear one
  *	@skb: buffer to linarize
- *	@gfp: allocation mode
  *
  *	If there is no free memory -ENOMEM is returned, otherwise zero
  *	is returned and the old skb data released.
  */
-extern int __skb_linearize(struct sk_buff *skb, gfp_t gfp);
-static inline int skb_linearize(struct sk_buff *skb, gfp_t gfp)
+static inline int skb_linearize(struct sk_buff *skb)
+{
+	return skb_is_nonlinear(skb) ? __skb_linearize(skb) : 0;
+}
+
+/**
+ *	skb_linearize_cow - make sure skb is linear and writable
+ *	@skb: buffer to process
+ *
+ *	If there is no free memory -ENOMEM is returned, otherwise zero
+ *	is returned and the old skb data released.
+ */
+static inline int skb_linearize_cow(struct sk_buff *skb)
 {
-	return __skb_linearize(skb, gfp);
+	return skb_is_nonlinear(skb) || skb_cloned(skb) ?
+	       __skb_linearize(skb) : 0;
 }
 
 /**
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1220,64 +1220,6 @@ static inline int illegal_highdma(struct
 #define illegal_highdma(dev, skb)	(0)
 #endif
 
-/* Keep head the same: replace data */
-int __skb_linearize(struct sk_buff *skb, gfp_t gfp_mask)
-{
-	unsigned int size;
-	u8 *data;
-	long offset;
-	struct skb_shared_info *ninfo;
-	int headerlen = skb->data - skb->head;
-	int expand = (skb->tail + skb->data_len) - skb->end;
-
-	if (skb_shared(skb))
-		BUG();
-
-	if (expand <= 0)
-		expand = 0;
-
-	size = skb->end - skb->head + expand;
-	size = SKB_DATA_ALIGN(size);
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
-	if (!data)
-		return -ENOMEM;
-
-	/* Copy entire thing */
-	if (skb_copy_bits(skb, -headerlen, data, headerlen + skb->len))
-		BUG();
-
-	/* Set up shinfo */
-	ninfo = (struct skb_shared_info*)(data + size);
-	atomic_set(&ninfo->dataref, 1);
-	ninfo->tso_size = skb_shinfo(skb)->tso_size;
-	ninfo->tso_segs = skb_shinfo(skb)->tso_segs;
-	ninfo->nr_frags = 0;
-	ninfo->frag_list = NULL;
-
-	/* Offset between the two in bytes */
-	offset = data - skb->head;
-
-	/* Free old data. */
-	skb_release_data(skb);
-
-	skb->head = data;
-	skb->end  = data + size;
-
-	/* Set up new pointers */
-	skb->h.raw   += offset;
-	skb->nh.raw  += offset;
-	skb->mac.raw += offset;
-	skb->tail    += offset;
-	skb->data    += offset;
-
-	/* We are no longer a clone, even if we were. */
-	skb->cloned    = 0;
-
-	skb->tail     += skb->data_len;
-	skb->data_len  = 0;
-	return 0;
-}
-
 #define HARD_TX_LOCK(dev, cpu) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		spin_lock(&dev->xmit_lock);		\
@@ -1326,7 +1268,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 	if (skb_shinfo(skb)->frag_list &&
 	    !(dev->features & NETIF_F_FRAGLIST) &&
-	    __skb_linearize(skb, GFP_ATOMIC))
+	    __skb_linearize(skb))
 		goto out_kfree_skb;
 
 	/* Fragmented skb is linearized if device does not support SG,
@@ -1335,7 +1277,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	 */
 	if (skb_shinfo(skb)->nr_frags &&
 	    (!(dev->features & NETIF_F_SG) || illegal_highdma(dev, skb)) &&
-	    __skb_linearize(skb, GFP_ATOMIC))
+	    __skb_linearize(skb))
 		goto out_kfree_skb;
 
 	/* If packet is not checksummed and device does not support
@@ -3473,7 +3415,6 @@ subsys_initcall(net_dev_init);
 EXPORT_SYMBOL(__dev_get_by_index);
 EXPORT_SYMBOL(__dev_get_by_name);
 EXPORT_SYMBOL(__dev_remove_pack);
-EXPORT_SYMBOL(__skb_linearize);
 EXPORT_SYMBOL(dev_valid_name);
 EXPORT_SYMBOL(dev_add_pack);
 EXPORT_SYMBOL(dev_alloc_name);
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -801,8 +801,7 @@ got_it:
 		 * We linearize everything except data segments here.
 		 */
 		if (cb->nsp_flags & ~0x60) {
-			if (unlikely(skb_is_nonlinear(skb)) &&
-			    skb_linearize(skb, GFP_ATOMIC) != 0)
+			if (unlikely(skb_linearize(skb)))
 				goto free_out;
 		}
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -629,8 +629,7 @@ int dn_route_rcv(struct sk_buff *skb, st
 			padlen);
 
         if (flags & DN_RT_PKT_CNTL) {
-		if (unlikely(skb_is_nonlinear(skb)) &&
-		    skb_linearize(skb, GFP_ATOMIC) != 0)
+		if (unlikely(skb_linearize(skb)))
 			goto dump_it;
 
                 switch(flags & DN_RT_CNTL_MSK) {
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -80,15 +80,12 @@ out:	
 
 static int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	int err = 0;
+	int err = -ENOMEM;
 	struct iphdr *iph;
 	struct ip_comp_hdr *ipch;
 
-	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
-	    skb_linearize(skb, GFP_ATOMIC) != 0) {
-	    	err = -ENOMEM;
+	if (skb_linearize_cow(skb))
 	    	goto out;
-	}
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -158,10 +155,8 @@ static int ipcomp_output(struct xfrm_sta
 		goto out_ok;
 	}
 
-	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
-	    skb_linearize(skb, GFP_ATOMIC) != 0) {
+	if (skb_linearize_cow(skb))
 		goto out_ok;
-	}
 	
 	err = ipcomp_compress(x, skb);
 	iph = skb->nh.iph;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -65,7 +65,7 @@ static LIST_HEAD(ipcomp6_tfms_list);
 
 static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	int err = 0;
+	int err = -ENOMEM;
 	struct ipv6hdr *iph;
 	struct ipv6_comp_hdr *ipch;
 	int plen, dlen;
@@ -74,11 +74,8 @@ static int ipcomp6_input(struct xfrm_sta
 	struct crypto_tfm *tfm;
 	int cpu;
 
-	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
-		skb_linearize(skb, GFP_ATOMIC) != 0) {
-		err = -ENOMEM;
+	if (skb_linearize_cow(skb))
 		goto out;
-	}
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -142,10 +139,8 @@ static int ipcomp6_output(struct xfrm_st
 		goto out_ok;
 	}
 
-	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
-		skb_linearize(skb, GFP_ATOMIC) != 0) {
+	if (skb_linearize_cow(skb))
 		goto out_ok;
-	}
 
 	/* compression */
 	plen = skb->len - hdr_len;

--y0ulUmNC+osPPQO6--
