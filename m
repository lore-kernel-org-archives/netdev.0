From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 07/14] esp4: Reorganize esp_output
Date: Wed, 12 Apr 2017 08:26:46 +0200
Message-ID: <1491978413-5700-8-git-send-email-steffen.klassert@secunet.com>
References: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57598 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751260AbdDLG31 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:29:27 -0400
In-Reply-To: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need a fallback for ESP at layer 2, so split esp_output
into generic functions that can be used at layer 3 and layer 2
and use them in esp_output. We also add esp_xmit which is
used for the layer 2 fallback.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/esp.h       |  16 +++
 net/ipv4/esp4.c         | 341 ++++++++++++++++++++++++++----------------------
 net/ipv4/esp4_offload.c | 102 +++++++++++++++
 3 files changed, 301 insertions(+), 158 deletions(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index a43be85..411a499 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -10,4 +10,20 @@ static inline struct ip_esp_hdr *ip_esp_hdr(const struct sk_buff *skb)
 	return (struct ip_esp_hdr *)skb_transport_header(skb);
 }
 
+struct esp_info {
+	struct	ip_esp_hdr *esph;
+	__be64	seqno;
+	int	tfclen;
+	int	tailen;
+	int	plen;
+	int	clen;
+	int 	len;
+	int 	nfrags;
+	__u8	proto;
+	bool	inplace;
+};
+
+int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp);
+int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp);
+int esp_input_done2(struct sk_buff *skb, int err);
 #endif
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index c6aba23..91e6a40 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -152,11 +152,10 @@ static void esp_output_restore_header(struct sk_buff *skb)
 }
 
 static struct ip_esp_hdr *esp_output_set_extra(struct sk_buff *skb,
+					       struct xfrm_state *x,
 					       struct ip_esp_hdr *esph,
 					       struct esp_output_extra *extra)
 {
-	struct xfrm_state *x = skb_dst(skb)->xfrm;
-
 	/* For ESN we move the header forward by 4 bytes to
 	 * accomodate the high bits.  We will move it back after
 	 * encryption.
@@ -198,98 +197,56 @@ static void esp_output_fill_trailer(u8 *tail, int tfclen, int plen, __u8 proto)
 	tail[plen - 1] = proto;
 }
 
-static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
+static void esp_output_udp_encap(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp)
 {
-	struct esp_output_extra *extra;
-	int err = -ENOMEM;
-	struct ip_esp_hdr *esph;
-	struct crypto_aead *aead;
-	struct aead_request *req;
-	struct scatterlist *sg, *dsg;
-	struct sk_buff *trailer;
-	struct page *page;
-	void *tmp;
-	u8 *iv;
-	u8 *tail;
-	u8 *vaddr;
-	int blksize;
-	int clen;
-	int alen;
-	int plen;
-	int ivlen;
-	int tfclen;
-	int nfrags;
-	int assoclen;
-	int extralen;
-	int tailen;
-	__be64 seqno;
-	__u8 proto = *skb_mac_header(skb);
-
-	/* skb is pure payload to encrypt */
-
-	aead = x->data;
-	alen = crypto_aead_authsize(aead);
-	ivlen = crypto_aead_ivsize(aead);
-
-	tfclen = 0;
-	if (x->tfcpad) {
-		struct xfrm_dst *dst = (struct xfrm_dst *)skb_dst(skb);
-		u32 padto;
-
-		padto = min(x->tfcpad, esp4_get_mtu(x, dst->child_mtu_cached));
-		if (skb->len < padto)
-			tfclen = padto - skb->len;
+	int encap_type;
+	struct udphdr *uh;
+	__be32 *udpdata32;
+	__be16 sport, dport;
+	struct xfrm_encap_tmpl *encap = x->encap;
+	struct ip_esp_hdr *esph = esp->esph;
+
+	spin_lock_bh(&x->lock);
+	sport = encap->encap_sport;
+	dport = encap->encap_dport;
+	encap_type = encap->encap_type;
+	spin_unlock_bh(&x->lock);
+
+	uh = (struct udphdr *)esph;
+	uh->source = sport;
+	uh->dest = dport;
+	uh->len = htons(skb->len + esp->tailen
+		  - skb_transport_offset(skb));
+	uh->check = 0;
+
+	switch (encap_type) {
+	default:
+	case UDP_ENCAP_ESPINUDP:
+		esph = (struct ip_esp_hdr *)(uh + 1);
+		break;
+	case UDP_ENCAP_ESPINUDP_NON_IKE:
+		udpdata32 = (__be32 *)(uh + 1);
+		udpdata32[0] = udpdata32[1] = 0;
+		esph = (struct ip_esp_hdr *)(udpdata32 + 2);
+		break;
 	}
-	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
-	clen = ALIGN(skb->len + 2 + tfclen, blksize);
-	plen = clen - skb->len - tfclen;
-	tailen = tfclen + plen + alen;
-	assoclen = sizeof(*esph);
-	extralen = 0;
 
-	if (x->props.flags & XFRM_STATE_ESN) {
-		extralen += sizeof(*extra);
-		assoclen += sizeof(__be32);
-	}
+	*skb_mac_header(skb) = IPPROTO_UDP;
+	esp->esph = esph;
+}
 
-	*skb_mac_header(skb) = IPPROTO_ESP;
-	esph = ip_esp_hdr(skb);
+int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp)
+{
+	u8 *tail;
+	u8 *vaddr;
+	int nfrags;
+	struct page *page;
+	struct sk_buff *trailer;
+	int tailen = esp->tailen;
 
 	/* this is non-NULL only with UDP Encapsulation */
-	if (x->encap) {
-		struct xfrm_encap_tmpl *encap = x->encap;
-		struct udphdr *uh;
-		__be32 *udpdata32;
-		__be16 sport, dport;
-		int encap_type;
-
-		spin_lock_bh(&x->lock);
-		sport = encap->encap_sport;
-		dport = encap->encap_dport;
-		encap_type = encap->encap_type;
-		spin_unlock_bh(&x->lock);
-
-		uh = (struct udphdr *)esph;
-		uh->source = sport;
-		uh->dest = dport;
-		uh->len = htons(skb->len + tailen
-				- skb_transport_offset(skb));
-		uh->check = 0;
-
-		switch (encap_type) {
-		default:
-		case UDP_ENCAP_ESPINUDP:
-			esph = (struct ip_esp_hdr *)(uh + 1);
-			break;
-		case UDP_ENCAP_ESPINUDP_NON_IKE:
-			udpdata32 = (__be32 *)(uh + 1);
-			udpdata32[0] = udpdata32[1] = 0;
-			esph = (struct ip_esp_hdr *)(udpdata32 + 2);
-			break;
-		}
-
-		*skb_mac_header(skb) = IPPROTO_UDP;
-	}
+	if (x->encap)
+		esp_output_udp_encap(x, skb, esp);
 
 	if (!skb_cloned(skb)) {
 		if (tailen <= skb_availroom(skb)) {
@@ -304,6 +261,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			struct sock *sk = skb->sk;
 			struct page_frag *pfrag = &x->xfrag;
 
+			esp->inplace = false;
+
 			allocsize = ALIGN(tailen, L1_CACHE_BYTES);
 
 			spin_lock_bh(&x->lock);
@@ -320,10 +279,12 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 			tail = vaddr + pfrag->offset;
 
-			esp_output_fill_trailer(tail, tfclen, plen, proto);
+			esp_output_fill_trailer(tail, esp->tfclen, esp->plen, esp->proto);
 
 			kunmap_atomic(vaddr);
 
+			spin_unlock_bh(&x->lock);
+
 			nfrags = skb_shinfo(skb)->nr_frags;
 
 			__skb_fill_page_desc(skb, nfrags, page, pfrag->offset,
@@ -339,76 +300,56 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			if (sk)
 				atomic_add(tailen, &sk->sk_wmem_alloc);
 
-			skb_push(skb, -skb_network_offset(skb));
-
-			esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
-			esph->spi = x->id.spi;
-
-			tmp = esp_alloc_tmp(aead, nfrags + 2, extralen);
-			if (!tmp) {
-				spin_unlock_bh(&x->lock);
-				err = -ENOMEM;
-				goto error;
-			}
-
-			extra = esp_tmp_extra(tmp);
-			iv = esp_tmp_iv(aead, tmp, extralen);
-			req = esp_tmp_req(aead, iv);
-			sg = esp_req_sg(aead, req);
-			dsg = &sg[nfrags];
-
-			esph = esp_output_set_extra(skb, esph, extra);
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
-	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
-	esph->spi = x->id.spi;
+out:
+	return nfrags;
+}
+EXPORT_SYMBOL_GPL(esp_output_head);
+
+int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *esp)
+{
+	u8 *iv;
+	int alen;
+	void *tmp;
+	int ivlen;
+	int assoclen;
+	int extralen;
+	struct page *page;
+	struct ip_esp_hdr *esph;
+	struct crypto_aead *aead;
+	struct aead_request *req;
+	struct scatterlist *sg, *dsg;
+	struct esp_output_extra *extra;
+	int err = -ENOMEM;
+
+	assoclen = sizeof(struct ip_esp_hdr);
+	extralen = 0;
+
+	if (x->props.flags & XFRM_STATE_ESN) {
+		extralen += sizeof(*extra);
+		assoclen += sizeof(__be32);
+	}
 
-	tmp = esp_alloc_tmp(aead, nfrags, extralen);
+	aead = x->data;
+	alen = crypto_aead_authsize(aead);
+	ivlen = crypto_aead_ivsize(aead);
+
+	tmp = esp_alloc_tmp(aead, esp->nfrags + 2, extralen);
 	if (!tmp) {
+		spin_unlock_bh(&x->lock);
 		err = -ENOMEM;
 		goto error;
 	}
@@ -417,26 +358,58 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	iv = esp_tmp_iv(aead, tmp, extralen);
 	req = esp_tmp_req(aead, iv);
 	sg = esp_req_sg(aead, req);
-	dsg = sg;
 
-	esph = esp_output_set_extra(skb, esph, extra);
+	if (esp->inplace)
+		dsg = sg;
+	else
+		dsg = &sg[esp->nfrags];
 
-	sg_init_table(sg, nfrags);
+	esph = esp_output_set_extra(skb, x, esp->esph, extra);
+	esp->esph = esph;
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
 
 	memset(iv, 0, ivlen);
-	memcpy(iv + ivlen - min(ivlen, 8), (u8 *)&seqno + 8 - min(ivlen, 8),
+	memcpy(iv + ivlen - min(ivlen, 8), (u8 *)&esp->seqno + 8 - min(ivlen, 8),
 	       min(ivlen, 8));
 
 	ESP_SKB_CB(skb)->tmp = tmp;
@@ -462,8 +435,59 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 error:
 	return err;
 }
+EXPORT_SYMBOL_GPL(esp_output_tail);
+
+static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
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
+		padto = min(x->tfcpad, esp4_get_mtu(x, dst->child_mtu_cached));
+		if (skb->len < padto)
+			esp.tfclen = padto - skb->len;
+	}
+	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
+	esp.clen = ALIGN(skb->len + 2 + esp.tfclen, blksize);
+	esp.plen = esp.clen - skb->len - esp.tfclen;
+	esp.tailen = esp.tfclen + esp.plen + alen;
+
+	esp.esph = ip_esp_hdr(skb);
+
+	esp.nfrags = esp_output_head(x, skb, &esp);
+	if (esp.nfrags < 0)
+		return esp.nfrags;
+
+	esph = esp.esph;
+	esph->spi = x->id.spi;
+
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
+	esp.seqno = cpu_to_be64(XFRM_SKB_CB(skb)->seq.output.low +
+				 ((u64)XFRM_SKB_CB(skb)->seq.output.hi << 32));
+
+	skb_push(skb, -skb_network_offset(skb));
+
+	return esp_output_tail(x, skb, &esp);
+}
 
-static int esp_input_done2(struct sk_buff *skb, int err)
+int esp_input_done2(struct sk_buff *skb, int err)
 {
 	const struct iphdr *iph;
 	struct xfrm_state *x = xfrm_input_state(skb);
@@ -548,6 +572,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(esp_input_done2);
 
 static void esp_input_done(struct crypto_async_request *base, int err)
 {
@@ -930,7 +955,7 @@ static const struct xfrm_type esp_type =
 	.destructor	= esp_destroy,
 	.get_mtu	= esp4_get_mtu,
 	.input		= esp_input,
-	.output		= esp_output
+	.output		= esp_output,
 };
 
 static struct xfrm4_protocol esp4_protocol = {
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index 1de4426..efaaa44 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -84,19 +84,121 @@ static struct sk_buff **esp4_gro_receive(struct sk_buff **head,
 	return NULL;
 }
 
+static int esp_input_tail(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct crypto_aead *aead = x->data;
+
+	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead)))
+		return -EINVAL;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return esp_input_done2(skb, 0);
+}
+
+static int esp_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features_t features)
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
+		hw_offload = false;
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
+	esp.esph = ip_esp_hdr(skb);
+
+
+	if (!hw_offload || (hw_offload && !skb_is_gso(skb))) {
+		esp.nfrags = esp_output_head(x, skb, &esp);
+		if (esp.nfrags < 0)
+			return esp.nfrags;
+	}
+
+	esph = esp.esph;
+	esph->spi = x->id.spi;
+
+	skb_push(skb, -skb_network_offset(skb));
+
+	if (xo->flags & XFRM_GSO_SEGMENT) {
+		esph->seq_no = htonl(xo->seq.low);
+	} else {
+		ip_hdr(skb)->tot_len = htons(skb->len);
+		ip_send_check(ip_hdr(skb));
+	}
+
+	if (hw_offload)
+		return 0;
+
+	esp.seqno = cpu_to_be64(xo->seq.low + ((u64)xo->seq.hi << 32));
+
+	err = esp_output_tail(x, skb, &esp);
+	if (err < 0)
+		return err;
+
+	secpath_reset(skb);
+
+	return 0;
+}
+
 static const struct net_offload esp4_offload = {
 	.callbacks = {
 		.gro_receive = esp4_gro_receive,
 	},
 };
 
+static const struct xfrm_type_offload esp_type_offload = {
+	.description	= "ESP4 OFFLOAD",
+	.owner		= THIS_MODULE,
+	.proto	     	= IPPROTO_ESP,
+	.input_tail	= esp_input_tail,
+	.xmit		= esp_xmit,
+};
+
 static int __init esp4_offload_init(void)
 {
+	if (xfrm_register_type_offload(&esp_type_offload, AF_INET) < 0) {
+		pr_info("%s: can't add xfrm type offload\n", __func__);
+		return -EAGAIN;
+	}
+
 	return inet_add_offload(&esp4_offload, IPPROTO_ESP);
 }
 
 static void __exit esp4_offload_exit(void)
 {
+	if (xfrm_unregister_type_offload(&esp_type_offload, AF_INET) < 0)
+		pr_info("%s: can't remove xfrm type offload\n", __func__);
+
 	inet_del_offload(&esp4_offload, IPPROTO_ESP);
 }
 
-- 
2.7.4
