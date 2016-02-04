From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 09/13] esp: Avoid skb_cow_data whenever possible
Date: Thu, 4 Feb 2016 07:37:02 +0100
Message-ID: <1454567826-13018-10-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36679 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756586AbcBDHFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:50 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we are allowed to write the buffer and have enough free
space on the lineaer part of the buffer, we add the IPsec
tailbit to it. If there is no space on the linare part
but we are allowed to write, we add a page fragment with
the tailbits to the buffer.

With this, we can avoid a linearization of the buffer
whenever we are allowed to write on it.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h |   2 +
 net/ipv4/esp4.c    | 125 ++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 111 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index a33ceb7..7939c39 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -217,6 +217,8 @@ struct xfrm_state {
 	/* Last used time */
 	unsigned long		lastused;
 
+	struct page_frag xfrag;
+
 	/* Reference to data common to all the instances of this
 	 * transformer. */
 	const struct xfrm_type	*type;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 550323d..b702467 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -18,6 +18,8 @@
 #include <net/protocol.h>
 #include <net/udp.h>
 
+#include <linux/highmem.h>
+
 struct esp_skb_cb {
 	struct xfrm_skb_cb xfrm;
 	void *tmp;
@@ -61,6 +63,7 @@ static inline __be32 *esp_tmp_seqhi(void *tmp)
 {
 	return PTR_ALIGN((__be32 *)tmp, __alignof__(__be32));
 }
+
 static inline u8 *esp_tmp_iv(struct crypto_aead *aead, void *tmp, int seqhilen)
 {
 	return crypto_aead_ivsize(aead) ?
@@ -192,15 +195,17 @@ error:
 
 static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	int err;
+	int err = -ENOMEM;
 	struct ip_esp_hdr *esph;
 	struct crypto_aead *aead;
 	struct aead_request *req;
 	struct scatterlist *sg;
 	struct sk_buff *trailer;
+	struct page *page;
 	void *tmp;
 	u8 *iv;
 	u8 *tail;
+	u8 *vaddr;
 	int blksize;
 	int clen;
 	int alen;
@@ -232,12 +237,6 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	clen = ALIGN(skb->len + 2 + tfclen, blksize);
 	plen = clen - skb->len - tfclen;
-
-	err = skb_cow_data(skb, tfclen + plen + alen, &trailer);
-	if (err < 0)
-		goto error;
-	nfrags = err;
-
 	assoclen = sizeof(*esph);
 	seqhilen = 0;
 	proto = ip_esp_hdr(skb)->seq_no;
@@ -247,19 +246,100 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		assoclen += seqhilen;
 	}
 
-	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
-	if (!tmp) {
-		err = -ENOMEM;
-		goto error;
+	if (!(skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG) && !skb_cloned(skb)) {
+		if (tfclen + plen + alen <= skb_availroom(skb)) {
+			nfrags = 1;
+			trailer = skb;
+			tail = skb_tail_pointer(trailer);
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
+			if (!skb->hw_xfrm)
+				tail[plen - 1] = *skb_mac_header(skb);
+			else
+				tail[plen - 1] = proto;
+
+			pskb_put(skb, trailer, clen - skb->len + alen);
+
+			goto skip_cow;
+
+		} else if ((skb_shinfo(skb)->nr_frags < MAX_SKB_FRAGS)
+			   && !skb_has_frag_list(skb)) {
+			int allocsize;
+			struct sock *sk = skb->sk;
+			struct page_frag *pfrag = &x->xfrag;
+
+			allocsize = ALIGN(tfclen + plen + alen, L1_CACHE_BYTES);
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
+			if (!skb->hw_xfrm)
+				tail[plen - 1] = *skb_mac_header(skb);
+			else
+				tail[plen - 1] = proto;
+
+			kunmap_atomic(vaddr);
+
+			nfrags = skb_shinfo(skb)->nr_frags;
+
+			__skb_fill_page_desc(skb, nfrags, page, pfrag->offset, tfclen + plen + alen);
+			skb_shinfo(skb)->nr_frags = ++nfrags;
+
+			pfrag->offset = pfrag->offset + allocsize;
+			nfrags++;
+
+			skb->len += tfclen + plen + alen;
+			skb->data_len += tfclen + plen + alen;
+			skb->truesize += tfclen + plen + alen;
+			if (sk)
+				atomic_add(tfclen + plen + alen, &sk->sk_wmem_alloc);
+
+			spin_unlock_bh(&x->lock);
+
+			goto skip_cow;
+		}
 	}
 
-	seqhi = esp_tmp_seqhi(tmp);
-	iv = esp_tmp_iv(aead, tmp, seqhilen);
-	req = esp_tmp_req(aead, iv);
-	sg = esp_req_sg(aead, req);
+cow:
+	err = skb_cow_data(skb, tfclen + plen + alen, &trailer);
+	if (err < 0)
+		goto error;
+	nfrags = err;
+	tail = skb_tail_pointer(trailer);
 
 	/* Fill padding... */
-	tail = skb_tail_pointer(trailer);
 	if (tfclen) {
 		memset(tail, 0, tfclen);
 		tail += tfclen;
@@ -277,6 +357,19 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	pskb_put(skb, trailer, clen - skb->len + alen);
 
+skip_cow:
+	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
+	if (!tmp) {
+		err = -ENOMEM;
+		goto error;
+	}
+
+	seqhi = esp_tmp_seqhi(tmp);
+	iv = esp_tmp_iv(aead, tmp, seqhilen);
+	req = esp_tmp_req(aead, iv);
+	sg = esp_req_sg(aead, req);
+
+
 	skb_push(skb, -skb_network_offset(skb));
 	esph = ip_esp_hdr(skb);
 
-- 
1.9.1
