From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 11/22] xfrm offload v2: Add offloading of inbound AH & ESP packets
Date: Mon, 10 Jan 2005 10:37:01 -0500
Message-ID: <20040110014300.20@ori.thedillows.org>
References: <20040110014300.19@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:51:49-05:00 dave@thedillows.org 
#   Add crypto offload for inbound IPv4 AH xfrms.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/ipv4/esp4.c
#   2005/01/10 00:51:33-05:00 dave@thedillows.org +30 -16
#   Add crypto offload for inbound IPv4 AH xfrms.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/ipv4/ah4.c
#   2005/01/10 00:51:33-05:00 dave@thedillows.org +13 -4
#   Add crypto offload for inbound IPv4 AH xfrms.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c	2005-01-10 01:18:35 -05:00
+++ b/net/ipv4/ah4.c	2005-01-10 01:18:35 -05:00
@@ -138,6 +138,7 @@
 	struct iphdr *iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
+	int offload;
 	char work_buf[60];
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
@@ -164,6 +165,7 @@
 
 	ah = (struct ip_auth_hdr*)skb->data;
 	iph = skb->nh.iph;
+	offload = skb_pop_xfrm_result(skb);
 
 	memcpy(work_buf, iph, iph->ihl*4);
 
@@ -181,10 +183,17 @@
 		
 		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
 		skb_push(skb, skb->data - skb->nh.raw);
-		ahp->icv(ahp, skb, ah->auth_data);
-		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
-			x->stats.integrity_failed++;
-			goto out;
+		if (offload & XFRM_OFFLOAD_AUTH) {
+			if (unlikely(offload & XFRM_OFFLOAD_AUTH_FAIL)) {
+				x->stats.integrity_failed++;
+				goto out;
+			}
+		} else {
+			ahp->icv(ahp, skb, ah->auth_data);
+			if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
+				x->stats.integrity_failed++;
+				goto out;
+			}
 		}
 	}
 	((struct iphdr*)work_buf)->protocol = ah->nexthdr;
diff -Nru a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c	2005-01-10 01:18:35 -05:00
+++ b/net/ipv4/esp4.c	2005-01-10 01:18:35 -05:00
@@ -164,6 +164,7 @@
 	int elen = skb->len - sizeof(struct ip_esp_hdr) - esp->conf.ivlen - alen;
 	int nfrags;
 	int encap_len = 0;
+	int offload;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
 		goto out;
@@ -171,22 +172,32 @@
 	if (elen <= 0 || (elen & (blksize-1)))
 		goto out;
 
+	offload = skb_pop_xfrm_result(skb);
+
 	/* If integrity check is required, do this. */
 	if (esp->auth.icv_full_len) {
-		u8 sum[esp->auth.icv_full_len];
-		u8 sum1[alen];
+		if (unlikely(offload & XFRM_OFFLOAD_AUTH_FAIL)) {
+			x->stats.integrity_failed++;
+			goto out;
+		}
+
+		if (!(offload & XFRM_OFFLOAD_AUTH)) {
+			u8 sum[esp->auth.icv_full_len];
+			u8 sum1[alen];
 		
-		esp->auth.icv(esp, skb, 0, skb->len-alen, sum);
+			esp->auth.icv(esp, skb, 0, skb->len-alen, sum);
 
-		if (skb_copy_bits(skb, skb->len-alen, sum1, alen))
-			BUG();
+			if (skb_copy_bits(skb, skb->len-alen, sum1, alen))
+				BUG();
 
-		if (unlikely(memcmp(sum, sum1, alen))) {
-			x->stats.integrity_failed++;
-			goto out;
+			if (unlikely(memcmp(sum, sum1, alen))) {
+				x->stats.integrity_failed++;
+				goto out;
+			}
 		}
 	}
 
+	/* XXX I think this can be moved to the !offload case */
 	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0)
 		goto out;
 
@@ -195,15 +206,12 @@
 	esph = (struct ip_esp_hdr*)skb->data;
 	iph = skb->nh.iph;
 
-	/* Get ivec. This can be wrong, check against another impls. */
-	if (esp->conf.ivlen)
-		crypto_cipher_set_iv(esp->conf.tfm, esph->enc_data, crypto_tfm_alg_ivsize(esp->conf.tfm));
-
-        {
-		u8 nexthdr[2];
+	if (!(offload & XFRM_OFFLOAD_CONF)) {
 		struct scatterlist *sg = &esp->sgbuf[0];
-		u8 workbuf[60];
-		int padlen;
+
+		/* Get ivec. This can be wrong, check against another impls. */
+		if (esp->conf.ivlen)
+			crypto_cipher_set_iv(esp->conf.tfm, esph->enc_data, crypto_tfm_alg_ivsize(esp->conf.tfm));
 
 		if (unlikely(nfrags > ESP_NUM_FAST_SG)) {
 			sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
@@ -214,6 +222,12 @@
 		crypto_cipher_decrypt(esp->conf.tfm, sg, sg, elen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
+	}
+
+        {
+		u8 nexthdr[2];
+		u8 workbuf[60];
+		int padlen;
 
 		if (skb_copy_bits(skb, skb->len-alen-2, nexthdr, 2))
 			BUG();
