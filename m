From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 10/22] xfrm offload v2: Add offloading of outbound AH & ESP packets
Date: Mon, 10 Jan 2005 10:37:01 -0500
Message-ID: <20040110014300.19@ori.thedillows.org>
References: <20040110014300.18@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:50:28-05:00 dave@thedillows.org 
#   Add crypto processing for outbound AH and ESP xfrms (IPv4).
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/ipv4/esp4.c
#   2005/01/10 00:50:12-05:00 dave@thedillows.org +35 -21
#   Add crypto offload for outbound ESP (IPv4) xfrms. Note that we always
#   generate a random IV, as we are not guaranteed to have any state in
#   the software crypto engine (we may have always been offloaded), and
#   we cannot rely on secure IV generation by the NIC driver/hw.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/ipv4/ah4.c
#   2005/01/10 00:50:12-05:00 dave@thedillows.org +31 -21
#   Add crypto offload for outbound AH (IPv4) xfrms. Note that the NIC
#   driver/hw is responsible for zeroing the mutable IP header fields.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c	2005-01-10 01:18:48 -05:00
+++ b/net/ipv4/ah4.c	2005-01-10 01:18:48 -05:00
@@ -83,31 +83,41 @@
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(x->replay.oseq + 1);
 
-	iph->tos = top_iph->tos;
-	iph->ttl = top_iph->ttl;
-	iph->frag_off = top_iph->frag_off;
-
-	if (top_iph->ihl != 5) {
-		iph->daddr = top_iph->daddr;
-		memcpy(iph+1, top_iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
-		err = ip_clear_mutable_options(top_iph, &top_iph->daddr);
-		if (err)
+	if (dst->xfrm_offload) {
+		err = -ENOMEM;
+		xfrm_offload_hold(dst->xfrm_offload);
+		if (skb_push_xfrm_offload(skb, dst->xfrm_offload)) {
+			xfrm_offload_release(dst->xfrm_offload);
 			goto error;
-	}
+		}
+	} else {
+		/* Not offloaded, manually calculate the auth hash */
+		iph->tos = top_iph->tos;
+		iph->ttl = top_iph->ttl;
+		iph->frag_off = top_iph->frag_off;
+
+		if (top_iph->ihl != 5) {
+			iph->daddr = top_iph->daddr;
+			memcpy(iph+1, top_iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
+			err = ip_clear_mutable_options(top_iph, &top_iph->daddr);
+			if (err)
+				goto error;
+		}
 
-	top_iph->tos = 0;
-	top_iph->frag_off = 0;
-	top_iph->ttl = 0;
-	top_iph->check = 0;
+		top_iph->tos = 0;
+		top_iph->frag_off = 0;
+		top_iph->ttl = 0;
+		top_iph->check = 0;
 
-	ahp->icv(ahp, skb, ah->auth_data);
+		ahp->icv(ahp, skb, ah->auth_data);
 
-	top_iph->tos = iph->tos;
-	top_iph->ttl = iph->ttl;
-	top_iph->frag_off = iph->frag_off;
-	if (top_iph->ihl != 5) {
-		top_iph->daddr = iph->daddr;
-		memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
+		top_iph->tos = iph->tos;
+		top_iph->ttl = iph->ttl;
+		top_iph->frag_off = iph->frag_off;
+		if (top_iph->ihl != 5) {
+			top_iph->daddr = iph->daddr;
+			memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
+		}
 	}
 
 	/* Delay incrementing the replay sequence until we know we're going
diff -Nru a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c	2005-01-10 01:18:48 -05:00
+++ b/net/ipv4/esp4.c	2005-01-10 01:18:48 -05:00
@@ -98,33 +98,47 @@
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);
 
-	if (esp->conf.ivlen)
-		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+	if (dst->xfrm_offload) {
+		xfrm_offload_hold(dst->xfrm_offload);
+		if (skb_push_xfrm_offload(skb, dst->xfrm_offload)) {
+			xfrm_offload_release(dst->xfrm_offload);
+			goto error;
+		}
+
+		if (esp->conf.ivlen)
+			get_random_bytes(esph->enc_data, esp->conf.ivlen);
+	} else {
+		if (esp->conf.ivlen)
+			crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+
+		do {
+			struct scatterlist *sg = &esp->sgbuf[0];
 
-	do {
-		struct scatterlist *sg = &esp->sgbuf[0];
+			if (unlikely(nfrags > ESP_NUM_FAST_SG)) {
+				sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
+				if (!sg)
+					goto error;
+			}
+			skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
+			crypto_cipher_encrypt(tfm, sg, sg, clen);
+			if (unlikely(sg != &esp->sgbuf[0]))
+				kfree(sg);
+		} while (0);
 
-		if (unlikely(nfrags > ESP_NUM_FAST_SG)) {
-			sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
-			if (!sg)
-				goto error;
+		if (esp->conf.ivlen) {
+			memcpy(esph->enc_data, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+			crypto_cipher_get_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+		}
+
+		if (esp->auth.icv_full_len) {
+			esp->auth.icv(esp, skb, (u8*)esph-skb->data,
+		              	sizeof(struct ip_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
 		}
-		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
-		crypto_cipher_encrypt(tfm, sg, sg, clen);
-		if (unlikely(sg != &esp->sgbuf[0]))
-			kfree(sg);
-	} while (0);
-
-	if (esp->conf.ivlen) {
-		memcpy(esph->enc_data, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
-		crypto_cipher_get_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
 	}
 
-	if (esp->auth.icv_full_len) {
-		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
-		              sizeof(struct ip_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
+	/* Need to account for auth data, offloading or not... */
+	if (esp->auth.icv_full_len)
 		pskb_put(skb, trailer, alen);
-	}
 
 	ip_send_check(top_iph);
 
