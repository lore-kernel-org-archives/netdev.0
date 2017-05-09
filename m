From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v7 2/5] ipsec: check return value of skb_to_sgvec always
Date: Tue,  9 May 2017 15:50:06 +0200
Message-ID: <20170509135009.13751-3-Jason@zx2c4.com>
References: <20170509135009.13751-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509135009.13751-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/ipv4/ah4.c  |  8 ++++++--
 net/ipv4/esp4.c | 30 ++++++++++++++++++++----------
 net/ipv6/ah6.c  |  8 ++++++--
 net/ipv6/esp6.c | 31 +++++++++++++++++++++----------
 4 files changed, 53 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 22377c8ff14b..e8f862358518 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -220,7 +220,9 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 
 	sg_init_table(sg, nfrags + sglists);
-	skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+	err = skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+	if (unlikely(err < 0))
+		goto out_free;
 
 	if (x->props.flags & XFRM_STATE_ESN) {
 		/* Attach seqhi sg right after packet payload */
@@ -393,7 +395,9 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 	skb_push(skb, ihl);
 
 	sg_init_table(sg, nfrags + sglists);
-	skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+	err = skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+	if (unlikely(err < 0))
+		goto out_free;
 
 	if (x->props.flags & XFRM_STATE_ESN) {
 		/* Attach seqhi sg right after packet payload */
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b1e24446e297..42cb09cc8533 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -360,9 +360,13 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			esph = esp_output_set_extra(skb, esph, extra);
 
 			sg_init_table(sg, nfrags);
-			skb_to_sgvec(skb, sg,
-				     (unsigned char *)esph - skb->data,
-				     assoclen + ivlen + clen + alen);
+			err = skb_to_sgvec(skb, sg,
+				           (unsigned char *)esph - skb->data,
+				           assoclen + ivlen + clen + alen);
+			if (unlikely(err < 0)) {
+				spin_unlock_bh(&x->lock);
+				goto error;
+			}
 
 			allocsize = ALIGN(skb->data_len, L1_CACHE_BYTES);
 
@@ -381,11 +385,13 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			pfrag->offset = pfrag->offset + allocsize;
 
 			sg_init_table(dsg, skb_shinfo(skb)->nr_frags + 1);
-			skb_to_sgvec(skb, dsg,
-				     (unsigned char *)esph - skb->data,
-				     assoclen + ivlen + clen + alen);
+			err = skb_to_sgvec(skb, dsg,
+				           (unsigned char *)esph - skb->data,
+				           assoclen + ivlen + clen + alen);
 
 			spin_unlock_bh(&x->lock);
+			if (unlikely(err < 0))
+				goto error;
 
 			goto skip_cow2;
 		}
@@ -422,9 +428,11 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph = esp_output_set_extra(skb, esph, extra);
 
 	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg,
-		     (unsigned char *)esph - skb->data,
-		     assoclen + ivlen + clen + alen);
+	err = skb_to_sgvec(skb, sg,
+		           (unsigned char *)esph - skb->data,
+		           assoclen + ivlen + clen + alen);
+	if (unlikely(err < 0))
+		goto error;
 
 skip_cow2:
 	if ((x->props.flags & XFRM_STATE_ESN))
@@ -658,7 +666,9 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	esp_input_set_header(skb, seqhi);
 
 	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	err = skb_to_sgvec(skb, sg, 0, skb->len);
+	if (unlikely(err < 0))
+		goto out;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index dda6035e3b84..755f38271dd5 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -423,7 +423,9 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 
 	sg_init_table(sg, nfrags + sglists);
-	skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+	err = skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+	if (unlikely(err < 0))
+		goto out_free;
 
 	if (x->props.flags & XFRM_STATE_ESN) {
 		/* Attach seqhi sg right after packet payload */
@@ -606,7 +608,9 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	ip6h->hop_limit   = 0;
 
 	sg_init_table(sg, nfrags + sglists);
-	skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+	err = skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+	if (unlikely(err < 0))
+		goto out_free;
 
 	if (x->props.flags & XFRM_STATE_ESN) {
 		/* Attach seqhi sg right after packet payload */
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index ff54faa75631..017e2c2d36e1 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -339,9 +339,13 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 			esph = esp_output_set_esn(skb, esph, seqhi);
 
 			sg_init_table(sg, nfrags);
-			skb_to_sgvec(skb, sg,
-				     (unsigned char *)esph - skb->data,
-				     assoclen + ivlen + clen + alen);
+			err = skb_to_sgvec(skb, sg,
+				           (unsigned char *)esph - skb->data,
+				           assoclen + ivlen + clen + alen);
+			if (unlikely(err < 0)) {
+				spin_unlock_bh(&x->lock);
+				goto error;
+			}
 
 			allocsize = ALIGN(skb->data_len, L1_CACHE_BYTES);
 
@@ -360,12 +364,15 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 			pfrag->offset = pfrag->offset + allocsize;
 
 			sg_init_table(dsg, skb_shinfo(skb)->nr_frags + 1);
-			skb_to_sgvec(skb, dsg,
-				     (unsigned char *)esph - skb->data,
-				     assoclen + ivlen + clen + alen);
+			err = skb_to_sgvec(skb, dsg,
+				           (unsigned char *)esph - skb->data,
+				           assoclen + ivlen + clen + alen);
 
 			spin_unlock_bh(&x->lock);
 
+			if (unlikely(err < 0))
+				goto error;
+
 			goto skip_cow2;
 		}
 	}
@@ -403,9 +410,11 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph = esp_output_set_esn(skb, esph, seqhi);
 
 	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg,
-		     (unsigned char *)esph - skb->data,
-		     assoclen + ivlen + clen + alen);
+	err = skb_to_sgvec(skb, sg,
+		           (unsigned char *)esph - skb->data,
+		           assoclen + ivlen + clen + alen);
+	if (unlikely(err < 0))
+		goto error;
 
 skip_cow2:
 	if ((x->props.flags & XFRM_STATE_ESN))
@@ -600,7 +609,9 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	esp_input_set_header(skb, seqhi);
 
 	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	ret = skb_to_sgvec(skb, sg, 0, skb->len);
+	if (unlikely(ret < 0))
+		goto out;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-- 
2.12.2
