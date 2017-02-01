From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 12/15] esp6: Avoid skb_cow_data whenever possible
Date: Wed, 1 Feb 2017 09:17:54 +0100
Message-ID: <1485937077-612-13-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37068 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751687AbdBAISM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:12 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tries to avoid skb_cow_data on esp6.

On the encrypt side we add the IPsec tailbits
to the linear part of the buffer if there is
space on it. If there is no space on the linear
part, we add a page fragment with the tailbits to
the buffer and use separate src and dst scatterlists.

On the decrypt side, we leave the buffer as it is
if it is not cloned.

With this, we can avoid a linearization of the buffer
in most of the cases.

Joint work with:
Sowmini Varadhan <sowmini.varadhan@oracle.com>
Ilan Tayari <ilant@mellanox.com>

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c | 302 +++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 246 insertions(+), 56 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index cbcdd5d..a428ac6 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -44,6 +44,8 @@
 #include <net/protocol.h>
 #include <linux/icmpv6.h>
 
+#include <linux/highmem.h>
+
 struct esp_skb_cb {
 	struct xfrm_skb_cb xfrm;
 	void *tmp;
@@ -114,11 +116,40 @@ static inline struct scatterlist *esp_req_sg(struct crypto_aead *aead,
 			     __alignof__(struct scatterlist));
 }
 
+static void esp_ssg_unref(struct xfrm_state *x, void *tmp)
+{
+	__be32 *seqhi;
+	struct crypto_aead *aead = x->data;
+	int seqhilen = 0;
+	u8 *iv;
+	struct aead_request *req;
+	struct scatterlist *sg;
+
+	if (x->props.flags & XFRM_STATE_ESN)
+		seqhilen += sizeof(__be32);
+
+	seqhi = esp_tmp_seqhi(tmp);
+	iv = esp_tmp_iv(aead, tmp, seqhilen);
+	req = esp_tmp_req(aead, iv);
+
+	/* Unref skb_frag_pages in the src scatterlist if necessary.
+	 * Skip the first sg which comes from skb->data.
+	 */
+	if (req->src != req->dst)
+		for (sg = sg_next(req->src); sg; sg = sg_next(sg))
+			put_page(sg_page(sg));
+}
+
 static void esp_output_done(struct crypto_async_request *base, int err)
 {
 	struct sk_buff *skb = base->data;
+	void *tmp;
+	struct dst_entry *dst = skb_dst(skb);
+	struct xfrm_state *x = dst->xfrm;
 
-	kfree(ESP_SKB_CB(skb)->tmp);
+	tmp = ESP_SKB_CB(skb)->tmp;
+	esp_ssg_unref(x, tmp);
+	kfree(tmp);
 	xfrm_output_resume(skb, err);
 }
 
@@ -138,6 +169,27 @@ static void esp_output_restore_header(struct sk_buff *skb)
 	esp_restore_header(skb, skb_transport_offset(skb) - sizeof(__be32));
 }
 
+static struct ip_esp_hdr *esp_output_set_esn(struct sk_buff *skb,
+					     struct ip_esp_hdr *esph,
+					     __be32 *seqhi)
+{
+	struct xfrm_state *x = skb_dst(skb)->xfrm;
+
+	/* For ESN we move the header forward by 4 bytes to
+	 * accomodate the high bits.  We will move it back after
+	 * encryption.
+	 */
+	if ((x->props.flags & XFRM_STATE_ESN)) {
+		esph = (void *)(skb_transport_header(skb) - sizeof(__be32));
+		*seqhi = esph->spi;
+		esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
+	}
+
+	esph->spi = x->id.spi;
+
+	return esph;
+}
+
 static void esp_output_done_esn(struct crypto_async_request *base, int err)
 {
 	struct sk_buff *skb = base->data;
@@ -152,8 +204,9 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct ip_esp_hdr *esph;
 	struct crypto_aead *aead;
 	struct aead_request *req;
-	struct scatterlist *sg;
+	struct scatterlist *sg, *dsg;
 	struct sk_buff *trailer;
+	struct page *page;
 	void *tmp;
 	int blksize;
 	int clen;
@@ -164,10 +217,13 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	int nfrags;
 	int assoclen;
 	int seqhilen;
+	int tailen;
 	u8 *iv;
 	u8 *tail;
+	u8 *vaddr;
 	__be32 *seqhi;
 	__be64 seqno;
+	__u8 proto = *skb_mac_header(skb);
 
 	/* skb is pure payload to encrypt */
 	aead = x->data;
@@ -186,11 +242,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	clen = ALIGN(skb->len + 2 + tfclen, blksize);
 	plen = clen - skb->len - tfclen;
-
-	err = skb_cow_data(skb, tfclen + plen + alen, &trailer);
-	if (err < 0)
-		goto error;
-	nfrags = err;
+	tailen = tfclen + plen + alen;
 
 	assoclen = sizeof(*esph);
 	seqhilen = 0;
@@ -200,19 +252,130 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 		assoclen += seqhilen;
 	}
 
-	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
-	if (!tmp) {
-		err = -ENOMEM;
-		goto error;
+	*skb_mac_header(skb) = IPPROTO_ESP;
+	esph = ip_esp_hdr(skb);
+
+	if (!skb_cloned(skb)) {
+		if (tailen <= skb_availroom(skb)) {
+			nfrags = 1;
+			trailer = skb;
+			tail = skb_tail_pointer(trailer);
+
+			goto skip_cow;
+		} else if ((skb_shinfo(skb)->nr_frags < MAX_SKB_FRAGS)
+			   && !skb_has_frag_list(skb)) {
+			int allocsize;
+			struct sock *sk = skb->sk;
+			struct page_frag *pfrag = &x->xfrag;
+
+			allocsize = ALIGN(tailen, L1_CACHE_BYTES);
+
+			spin_lock_bh(&x->lock);
+
+			if (unlikely(!skb_page_frag_refill(allocsize, pfrag, GFP_ATOMIC))) {
+				spin_unlock_bh(&x->lock);
+				goto cow;
+			}
+
+			page = pfrag->page;
+			get_page(page);
+
+			vaddr = kmap_atomic(page);
+
+			tail = vaddr + pfrag->offset;
+
+			/* Fill padding... */
+			if (tfclen) {
+				memset(tail, 0, tfclen);
+				tail += tfclen;
+			}
+			do {
+				int i;
+				for (i = 0; i < plen - 2; i++)
+					tail[i] = i + 1;
+			} while (0);
+			tail[plen - 2] = plen - 2;
+			tail[plen - 1] = proto;
+
+			kunmap_atomic(vaddr);
+
+			nfrags = skb_shinfo(skb)->nr_frags;
+
+			__skb_fill_page_desc(skb, nfrags, page, pfrag->offset,
+					     tailen);
+			skb_shinfo(skb)->nr_frags = ++nfrags;
+
+			pfrag->offset = pfrag->offset + allocsize;
+			nfrags++;
+
+			skb->len += tailen;
+			skb->data_len += tailen;
+			skb->truesize += tailen;
+			if (sk)
+				atomic_add(tailen, &sk->sk_wmem_alloc);
+
+			skb_push(skb, -skb_network_offset(skb));
+
+			esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
+			esph->spi = x->id.spi;
+
+			tmp = esp_alloc_tmp(aead, nfrags + 2, seqhilen);
+			if (!tmp) {
+				spin_unlock_bh(&x->lock);
+				err = -ENOMEM;
+				goto error;
+			}
+			seqhi = esp_tmp_seqhi(tmp);
+			iv = esp_tmp_iv(aead, tmp, seqhilen);
+			req = esp_tmp_req(aead, iv);
+			sg = esp_req_sg(aead, req);
+			dsg = &sg[nfrags];
+
+			esph = esp_output_set_esn(skb, esph, seqhi);
+
+			sg_init_table(sg, nfrags);
+			skb_to_sgvec(skb, sg,
+				     (unsigned char *)esph - skb->data,
+				     assoclen + ivlen + clen + alen);
+
+			allocsize = ALIGN(skb->data_len, L1_CACHE_BYTES);
+
+			if (unlikely(!skb_page_frag_refill(allocsize, pfrag, GFP_ATOMIC))) {
+				spin_unlock_bh(&x->lock);
+				err = -ENOMEM;
+				goto error;
+			}
+
+			skb_shinfo(skb)->nr_frags = 1;
+
+			page = pfrag->page;
+			get_page(page);
+			/* replace page frags in skb with new page */
+			__skb_fill_page_desc(skb, 0, page, pfrag->offset, skb->data_len);
+			pfrag->offset = pfrag->offset + allocsize;
+
+			sg_init_table(dsg, skb_shinfo(skb)->nr_frags + 1);
+			skb_to_sgvec(skb, dsg,
+				     (unsigned char *)esph - skb->data,
+				     assoclen + ivlen + clen + alen);
+
+			spin_unlock_bh(&x->lock);
+
+			goto skip_cow2;
+		}
 	}
 
-	seqhi = esp_tmp_seqhi(tmp);
-	iv = esp_tmp_iv(aead, tmp, seqhilen);
-	req = esp_tmp_req(aead, iv);
-	sg = esp_req_sg(aead, req);
+cow:
+	err = skb_cow_data(skb, tailen, &trailer);
+	if (err < 0)
+		goto error;
+	nfrags = err;
 
-	/* Fill padding... */
 	tail = skb_tail_pointer(trailer);
+	esph = ip_esp_hdr(skb);
+
+skip_cow:
+	/* Fill padding... */
 	if (tfclen) {
 		memset(tail, 0, tfclen);
 		tail += tfclen;
@@ -223,36 +386,40 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 			tail[i] = i + 1;
 	} while (0);
 	tail[plen - 2] = plen - 2;
-	tail[plen - 1] = *skb_mac_header(skb);
+	tail[plen - 1] = proto;
 	pskb_put(skb, trailer, clen - skb->len + alen);
 
 	skb_push(skb, -skb_network_offset(skb));
-	esph = ip_esp_hdr(skb);
-	*skb_mac_header(skb) = IPPROTO_ESP;
 
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
+	esph->spi = x->id.spi;
 
-	aead_request_set_callback(req, 0, esp_output_done, skb);
-
-	/* For ESN we move the header forward by 4 bytes to
-	 * accomodate the high bits.  We will move it back after
-	 * encryption.
-	 */
-	if ((x->props.flags & XFRM_STATE_ESN)) {
-		esph = (void *)(skb_transport_header(skb) - sizeof(__be32));
-		*seqhi = esph->spi;
-		esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
-		aead_request_set_callback(req, 0, esp_output_done_esn, skb);
+	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
+	if (!tmp) {
+		err = -ENOMEM;
+		goto error;
 	}
 
-	esph->spi = x->id.spi;
+	seqhi = esp_tmp_seqhi(tmp);
+	iv = esp_tmp_iv(aead, tmp, seqhilen);
+	req = esp_tmp_req(aead, iv);
+	sg = esp_req_sg(aead, req);
+	dsg = sg;
+
+	esph = esp_output_set_esn(skb, esph, seqhi);
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg,
 		     (unsigned char *)esph - skb->data,
 		     assoclen + ivlen + clen + alen);
 
-	aead_request_set_crypt(req, sg, sg, ivlen + clen, iv);
+skip_cow2:
+	if ((x->props.flags & XFRM_STATE_ESN))
+		aead_request_set_callback(req, 0, esp_output_done_esn, skb);
+	else
+		aead_request_set_callback(req, 0, esp_output_done, skb);
+
+	aead_request_set_crypt(req, sg, dsg, ivlen + clen, iv);
 	aead_request_set_ad(req, assoclen);
 
 	seqno = cpu_to_be64(XFRM_SKB_CB(skb)->seq.output.low +
@@ -278,6 +445,8 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 			esp_output_restore_header(skb);
 	}
 
+	if (sg != dsg)
+		esp_ssg_unref(x, tmp);
 	kfree(tmp);
 
 error:
@@ -343,6 +512,23 @@ static void esp_input_restore_header(struct sk_buff *skb)
 	__skb_pull(skb, 4);
 }
 
+static void esp_input_set_header(struct sk_buff *skb, __be32 *seqhi)
+{
+	struct xfrm_state *x = xfrm_input_state(skb);
+	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)skb->data;
+
+	/* For ESN we move the header forward by 4 bytes to
+	 * accomodate the high bits.  We will move it back after
+	 * decryption.
+	 */
+	if ((x->props.flags & XFRM_STATE_ESN)) {
+		esph = (void *)skb_push(skb, 4);
+		*seqhi = esph->spi;
+		esph->spi = esph->seq_no;
+		esph->seq_no = XFRM_SKB_CB(skb)->seq.input.hi;
+	}
+}
+
 static void esp_input_done_esn(struct crypto_async_request *base, int err)
 {
 	struct sk_buff *skb = base->data;
@@ -378,14 +564,6 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out;
 	}
 
-	nfrags = skb_cow_data(skb, 0, &trailer);
-	if (nfrags < 0) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	ret = -ENOMEM;
-
 	assoclen = sizeof(*esph);
 	seqhilen = 0;
 
@@ -394,6 +572,27 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 		assoclen += seqhilen;
 	}
 
+	if (!skb_cloned(skb)) {
+		if (!skb_is_nonlinear(skb)) {
+			nfrags = 1;
+
+			goto skip_cow;
+		} else if (!skb_has_frag_list(skb)) {
+			nfrags = skb_shinfo(skb)->nr_frags;
+			nfrags++;
+
+			goto skip_cow;
+		}
+	}
+
+	nfrags = skb_cow_data(skb, 0, &trailer);
+	if (nfrags < 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+skip_cow:
+	ret = -ENOMEM;
 	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
 	if (!tmp)
 		goto out;
@@ -404,26 +603,17 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	req = esp_tmp_req(aead, iv);
 	sg = esp_req_sg(aead, req);
 
-	skb->ip_summed = CHECKSUM_NONE;
+	esp_input_set_header(skb, seqhi);
 
-	esph = (struct ip_esp_hdr *)skb->data;
+	sg_init_table(sg, nfrags);
+	skb_to_sgvec(skb, sg, 0, skb->len);
 
-	aead_request_set_callback(req, 0, esp_input_done, skb);
+	skb->ip_summed = CHECKSUM_NONE;
 
-	/* For ESN we move the header forward by 4 bytes to
-	 * accomodate the high bits.  We will move it back after
-	 * decryption.
-	 */
-	if ((x->props.flags & XFRM_STATE_ESN)) {
-		esph = (void *)skb_push(skb, 4);
-		*seqhi = esph->spi;
-		esph->spi = esph->seq_no;
-		esph->seq_no = XFRM_SKB_CB(skb)->seq.input.hi;
+	if ((x->props.flags & XFRM_STATE_ESN))
 		aead_request_set_callback(req, 0, esp_input_done_esn, skb);
-	}
-
-	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	else
+		aead_request_set_callback(req, 0, esp_input_done, skb);
 
 	aead_request_set_crypt(req, sg, sg, elen + ivlen, iv);
 	aead_request_set_ad(req, assoclen);
-- 
1.9.1
