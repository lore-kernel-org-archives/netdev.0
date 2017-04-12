From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 08/14] esp6: Reorganize esp_output
Date: Wed, 12 Apr 2017 08:26:47 +0200
Message-ID: <1491978413-5700-9-git-send-email-steffen.klassert@secunet.com>
References: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57604 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751260AbdDLG3g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:29:36 -0400
In-Reply-To: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need a fallback for ESP at layer 2, so split esp6_output
into generic functions that can be used at layer 3 and layer 2
and use them in esp_output. We also add esp6_xmit which is
used for the layer 2 fallback.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/esp.h       |   3 +
 net/ipv6/esp6.c         | 264 +++++++++++++++++++++++++-----------------------
 net/ipv6/esp6_offload.c | 103 +++++++++++++++++++
 3 files changed, 246 insertions(+), 124 deletions(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index 411a499..c41994d 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -26,4 +26,7 @@ struct esp_info {
 int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp);
 int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp);
 int esp_input_done2(struct sk_buff *skb, int err);
+int esp6_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp);
+int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp);
+int esp6_input_done2(struct sk_buff *skb, int err);
 #endif
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 5bd1dcc..cc654a7 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -170,11 +170,10 @@ static void esp_output_restore_header(struct sk_buff *skb)
 }
 
 static struct ip_esp_hdr *esp_output_set_esn(struct sk_buff *skb,
+					     struct xfrm_state *x,
 					     struct ip_esp_hdr *esph,
 					     __be32 *seqhi)
 {
-	struct xfrm_state *x = skb_dst(skb)->xfrm;
-
 	/* For ESN we move the header forward by 4 bytes to
 	 * accomodate the high bits.  We will move it back after
 	 * encryption.
@@ -214,59 +213,15 @@ static void esp_output_fill_trailer(u8 *tail, int tfclen, int plen, __u8 proto)
 	tail[plen - 1] = proto;
 }
 
-static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
+int esp6_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp)
 {
-	int err;
-	struct ip_esp_hdr *esph;
-	struct crypto_aead *aead;
-	struct aead_request *req;
-	struct scatterlist *sg, *dsg;
-	struct sk_buff *trailer;
-	struct page *page;
-	void *tmp;
-	int blksize;
-	int clen;
-	int alen;
-	int plen;
-	int ivlen;
-	int tfclen;
-	int nfrags;
-	int assoclen;
-	int seqhilen;
-	int tailen;
-	u8 *iv;
 	u8 *tail;
 	u8 *vaddr;
-	__be32 *seqhi;
-	__be64 seqno;
-	__u8 proto = *skb_mac_header(skb);
-
-	/* skb is pure payload to encrypt */
-	aead = x->data;
-	alen = crypto_aead_authsize(aead);
-	ivlen = crypto_aead_ivsize(aead);
-
-	tfclen = 0;
-	if (x->tfcpad) {
-		struct xfrm_dst *dst = (struct xfrm_dst *)skb_dst(skb);
-		u32 padto;
-
-		padto = min(x->tfcpad, esp6_get_mtu(x, dst->child_mtu_cached));
-		if (skb->len < padto)
-			tfclen = padto - skb->len;
-	}
-	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
-	clen = ALIGN(skb->len + 2 + tfclen, blksize);
-	plen = clen - skb->len - tfclen;
-	tailen = tfclen + plen + alen;
-
-	assoclen = sizeof(*esph);
-	seqhilen = 0;
-
-	if (x->props.flags & XFRM_STATE_ESN) {
-		seqhilen += sizeof(__be32);
-		assoclen += seqhilen;
-	}
+	int nfrags;
+	struct page *page;
+	struct ip_esp_hdr *esph;
+	struct sk_buff *trailer;
+	int tailen = esp->tailen;
 
 	*skb_mac_header(skb) = IPPROTO_ESP;
 	esph = ip_esp_hdr(skb);
@@ -284,6 +239,8 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 			struct sock *sk = skb->sk;
 			struct page_frag *pfrag = &x->xfrag;
 
+			esp->inplace = false;
+
 			allocsize = ALIGN(tailen, L1_CACHE_BYTES);
 
 			spin_lock_bh(&x->lock);
@@ -300,10 +257,12 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 			tail = vaddr + pfrag->offset;
 
-			esp_output_fill_trailer(tail, tfclen, plen, proto);
+			esp_output_fill_trailer(tail, esp->tfclen, esp->plen, esp->proto);
 
 			kunmap_atomic(vaddr);
 
+			spin_unlock_bh(&x->lock);
+
 			nfrags = skb_shinfo(skb)->nr_frags;
 
 			__skb_fill_page_desc(skb, nfrags, page, pfrag->offset,
@@ -319,77 +278,56 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 			if (sk)
 				atomic_add(tailen, &sk->sk_wmem_alloc);
 
-			skb_push(skb, -skb_network_offset(skb));
-
-			esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
-			esph->spi = x->id.spi;
-
-			tmp = esp_alloc_tmp(aead, nfrags + 2, seqhilen);
-			if (!tmp) {
-				spin_unlock_bh(&x->lock);
-				err = -ENOMEM;
-				goto error;
-			}
-			seqhi = esp_tmp_seqhi(tmp);
-			iv = esp_tmp_iv(aead, tmp, seqhilen);
-			req = esp_tmp_req(aead, iv);
-			sg = esp_req_sg(aead, req);
-			dsg = &sg[nfrags];
-
-			esph = esp_output_set_esn(skb, esph, seqhi);
-
-			sg_init_table(sg, nfrags);
-			skb_to_sgvec(skb, sg,
-				     (unsigned char *)esph - skb->data,
-				     assoclen + ivlen + clen + alen);
-
-			allocsize = ALIGN(skb->data_len, L1_CACHE_BYTES);
-
-			if (unlikely(!skb_page_frag_refill(allocsize, pfrag, GFP_ATOMIC))) {
-				spin_unlock_bh(&x->lock);
-				err = -ENOMEM;
-				goto error;
-			}
-
-			skb_shinfo(skb)->nr_frags = 1;
-
-			page = pfrag->page;
-			get_page(page);
-			/* replace page frags in skb with new page */
-			__skb_fill_page_desc(skb, 0, page, pfrag->offset, skb->data_len);
-			pfrag->offset = pfrag->offset + allocsize;
-
-			sg_init_table(dsg, skb_shinfo(skb)->nr_frags + 1);
-			skb_to_sgvec(skb, dsg,
-				     (unsigned char *)esph - skb->data,
-				     assoclen + ivlen + clen + alen);
-
-			spin_unlock_bh(&x->lock);
-
-			goto skip_cow2;
+			goto out;
 		}
 	}
 
 cow:
-	err = skb_cow_data(skb, tailen, &trailer);
-	if (err < 0)
-		goto error;
-	nfrags = err;
-
+	nfrags = skb_cow_data(skb, tailen, &trailer);
+	if (nfrags < 0)
+		goto out;
 	tail = skb_tail_pointer(trailer);
-	esph = ip_esp_hdr(skb);
 
 skip_cow:
-	esp_output_fill_trailer(tail, tfclen, plen, proto);
+	esp_output_fill_trailer(tail, esp->tfclen, esp->plen, esp->proto);
+	pskb_put(skb, trailer, tailen);
 
-	pskb_put(skb, trailer, clen - skb->len + alen);
-	skb_push(skb, -skb_network_offset(skb));
+out:
+	return nfrags;
+}
+EXPORT_SYMBOL_GPL(esp6_output_head);
 
-	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
-	esph->spi = x->id.spi;
+int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp)
+{
+	u8 *iv;
+	int alen;
+	void *tmp;
+	int ivlen;
+	int assoclen;
+	int seqhilen;
+	__be32 *seqhi;
+	struct page *page;
+	struct ip_esp_hdr *esph;
+	struct aead_request *req;
+	struct crypto_aead *aead;
+	struct scatterlist *sg, *dsg;
+	int err = -ENOMEM;
 
-	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
+	assoclen = sizeof(struct ip_esp_hdr);
+	seqhilen = 0;
+
+	if (x->props.flags & XFRM_STATE_ESN) {
+		seqhilen += sizeof(__be32);
+		assoclen += sizeof(__be32);
+	}
+
+	aead = x->data;
+	alen = crypto_aead_authsize(aead);
+	ivlen = crypto_aead_ivsize(aead);
+
+	tmp = esp_alloc_tmp(aead, esp->nfrags + 2, seqhilen);
 	if (!tmp) {
+		spin_unlock_bh(&x->lock);
 		err = -ENOMEM;
 		goto error;
 	}
@@ -398,29 +336,57 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	iv = esp_tmp_iv(aead, tmp, seqhilen);
 	req = esp_tmp_req(aead, iv);
 	sg = esp_req_sg(aead, req);
-	dsg = sg;
 
-	esph = esp_output_set_esn(skb, esph, seqhi);
+	if (esp->inplace)
+		dsg = sg;
+	else
+		dsg = &sg[esp->nfrags];
 
-	sg_init_table(sg, nfrags);
+	esph = esp_output_set_esn(skb, x, ip_esp_hdr(skb), seqhi);
+
+	sg_init_table(sg, esp->nfrags);
 	skb_to_sgvec(skb, sg,
 		     (unsigned char *)esph - skb->data,
-		     assoclen + ivlen + clen + alen);
+		     assoclen + ivlen + esp->clen + alen);
+
+	if (!esp->inplace) {
+		int allocsize;
+		struct page_frag *pfrag = &x->xfrag;
+
+		allocsize = ALIGN(skb->data_len, L1_CACHE_BYTES);
+
+		spin_lock_bh(&x->lock);
+		if (unlikely(!skb_page_frag_refill(allocsize, pfrag, GFP_ATOMIC))) {
+			spin_unlock_bh(&x->lock);
+			err = -ENOMEM;
+			goto error;
+		}
+
+		skb_shinfo(skb)->nr_frags = 1;
+
+		page = pfrag->page;
+		get_page(page);
+		/* replace page frags in skb with new page */
+		__skb_fill_page_desc(skb, 0, page, pfrag->offset, skb->data_len);
+		pfrag->offset = pfrag->offset + allocsize;
+		spin_unlock_bh(&x->lock);
+
+		sg_init_table(dsg, skb_shinfo(skb)->nr_frags + 1);
+		skb_to_sgvec(skb, dsg,
+			     (unsigned char *)esph - skb->data,
+			     assoclen + ivlen + esp->clen + alen);
+	}
 
-skip_cow2:
 	if ((x->props.flags & XFRM_STATE_ESN))
 		aead_request_set_callback(req, 0, esp_output_done_esn, skb);
 	else
 		aead_request_set_callback(req, 0, esp_output_done, skb);
 
-	aead_request_set_crypt(req, sg, dsg, ivlen + clen, iv);
+	aead_request_set_crypt(req, sg, dsg, ivlen + esp->clen, iv);
 	aead_request_set_ad(req, assoclen);
 
-	seqno = cpu_to_be64(XFRM_SKB_CB(skb)->seq.output.low +
-			    ((u64)XFRM_SKB_CB(skb)->seq.output.hi << 32));
-
 	memset(iv, 0, ivlen);
-	memcpy(iv + ivlen - min(ivlen, 8), (u8 *)&seqno + 8 - min(ivlen, 8),
+	memcpy(iv + ivlen - min(ivlen, 8), (u8 *)&esp->seqno + 8 - min(ivlen, 8),
 	       min(ivlen, 8));
 
 	ESP_SKB_CB(skb)->tmp = tmp;
@@ -446,8 +412,57 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 error:
 	return err;
 }
+EXPORT_SYMBOL_GPL(esp6_output_tail);
+
+static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int alen;
+	int blksize;
+	struct ip_esp_hdr *esph;
+	struct crypto_aead *aead;
+	struct esp_info esp;
+
+	esp.inplace = true;
+
+	esp.proto = *skb_mac_header(skb);
+	*skb_mac_header(skb) = IPPROTO_ESP;
+
+	/* skb is pure payload to encrypt */
+
+	aead = x->data;
+	alen = crypto_aead_authsize(aead);
+
+	esp.tfclen = 0;
+	if (x->tfcpad) {
+		struct xfrm_dst *dst = (struct xfrm_dst *)skb_dst(skb);
+		u32 padto;
+
+		padto = min(x->tfcpad, esp6_get_mtu(x, dst->child_mtu_cached));
+		if (skb->len < padto)
+			esp.tfclen = padto - skb->len;
+	}
+	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
+	esp.clen = ALIGN(skb->len + 2 + esp.tfclen, blksize);
+	esp.plen = esp.clen - skb->len - esp.tfclen;
+	esp.tailen = esp.tfclen + esp.plen + alen;
+
+	esp.nfrags = esp6_output_head(x, skb, &esp);
+	if (esp.nfrags < 0)
+		return esp.nfrags;
+
+	esph = ip_esp_hdr(skb);
+	esph->spi = x->id.spi;
+
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
+	esp.seqno = cpu_to_be64(XFRM_SKB_CB(skb)->seq.output.low +
+			    ((u64)XFRM_SKB_CB(skb)->seq.output.hi << 32));
+
+	skb_push(skb, -skb_network_offset(skb));
+
+	return esp6_output_tail(x, skb, &esp);
+}
 
-static int esp6_input_done2(struct sk_buff *skb, int err)
+int esp6_input_done2(struct sk_buff *skb, int err)
 {
 	struct xfrm_state *x = xfrm_input_state(skb);
 	struct xfrm_offload *xo = xfrm_offload(skb);
@@ -494,6 +509,7 @@ static int esp6_input_done2(struct sk_buff *skb, int err)
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(esp6_input_done2);
 
 static void esp_input_done(struct crypto_async_request *base, int err)
 {
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index d914eb9..5dd20c0 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -86,19 +86,122 @@ static struct sk_buff **esp6_gro_receive(struct sk_buff **head,
 	return NULL;
 }
 
+static int esp6_input_tail(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct crypto_aead *aead = x->data;
+
+	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead)))
+		return -EINVAL;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return esp6_input_done2(skb, 0);
+}
+
+static int esp6_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features_t features)
+{
+	int err;
+	int alen;
+	int blksize;
+	struct xfrm_offload *xo;
+	struct ip_esp_hdr *esph;
+	struct crypto_aead *aead;
+	struct esp_info esp;
+	bool hw_offload = true;
+
+	esp.inplace = true;
+
+	xo = xfrm_offload(skb);
+
+	if (!xo)
+		return -EINVAL;
+
+	if (!(features & NETIF_F_HW_ESP) ||
+	    (x->xso.offload_handle &&  x->xso.dev != skb->dev)) {
+		xo->flags |= CRYPTO_FALLBACK;
+	}
+
+	esp.proto = xo->proto;
+
+	/* skb is pure payload to encrypt */
+
+	aead = x->data;
+	alen = crypto_aead_authsize(aead);
+
+	esp.tfclen = 0;
+	/* XXX: Add support for tfc padding here. */
+
+	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
+	esp.clen = ALIGN(skb->len + 2 + esp.tfclen, blksize);
+	esp.plen = esp.clen - skb->len - esp.tfclen;
+	esp.tailen = esp.tfclen + esp.plen + alen;
+
+	if (!hw_offload || (hw_offload && !skb_is_gso(skb))) {
+		esp.nfrags = esp6_output_head(x, skb, &esp);
+		if (esp.nfrags < 0)
+			return esp.nfrags;
+	}
+
+	esph = ip_esp_hdr(skb);
+	esph->spi = x->id.spi;
+
+	skb_push(skb, -skb_network_offset(skb));
+
+	if (xo->flags & XFRM_GSO_SEGMENT) {
+		esph->seq_no = htonl(xo->seq.low);
+	} else {
+		int len;
+
+		len = skb->len - sizeof(struct ipv6hdr);
+		if (len > IPV6_MAXPLEN)
+			len = 0;
+
+		ipv6_hdr(skb)->payload_len = htons(len);
+	}
+
+	if (x->xso.offload_handle && !(xo->flags & CRYPTO_FALLBACK))
+		return 0;
+
+	esp.seqno = cpu_to_be64(xo->seq.low + ((u64)xo->seq.hi << 32));
+
+	err = esp6_output_tail(x, skb, &esp);
+	if (err < 0)
+		return err;
+
+	secpath_reset(skb);
+
+	return 0;
+}
+
 static const struct net_offload esp6_offload = {
 	.callbacks = {
 		.gro_receive = esp6_gro_receive,
 	},
 };
 
+static const struct xfrm_type_offload esp6_type_offload = {
+	.description	= "ESP6 OFFLOAD",
+	.owner		= THIS_MODULE,
+	.proto	     	= IPPROTO_ESP,
+	.input_tail	= esp6_input_tail,
+	.xmit		= esp6_xmit,
+};
+
 static int __init esp6_offload_init(void)
 {
+	if (xfrm_register_type_offload(&esp6_type_offload, AF_INET6) < 0) {
+		pr_info("%s: can't add xfrm type offload\n", __func__);
+		return -EAGAIN;
+	}
+
 	return inet6_add_offload(&esp6_offload, IPPROTO_ESP);
 }
 
 static void __exit esp6_offload_exit(void)
 {
+	if (xfrm_unregister_type_offload(&esp6_type_offload, AF_INET6) < 0)
+		pr_info("%s: can't remove xfrm type offload\n", __func__);
+
 	inet6_del_offload(&esp6_offload, IPPROTO_ESP);
 }
 
-- 
2.7.4
