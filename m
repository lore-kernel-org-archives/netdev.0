From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 05/11] xfrm: Use separate low and high order bits of
 the sequence numbers in xfrm_skb_cb
Date: Mon, 22 Nov 2010 11:29:25 +0100
Message-ID: <20101122102924.GH1868@secunet.com>
References: <20101122102455.GC1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102455.GC1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To support IPsec extended sequence numbers, we split the
output sequence numbers of xfrm_skb_cb in low and high order 32 bits
and we add the high order 32 bits to the input sequence numbers.
All users are updated accordingly.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |   10 ++++++++--
 net/ipv4/ah4.c         |    2 +-
 net/ipv4/esp4.c        |    4 ++--
 net/ipv6/ah6.c         |    2 +-
 net/ipv6/esp6.c        |    4 ++--
 net/xfrm/xfrm_input.c  |    4 ++--
 net/xfrm/xfrm_output.c |    2 +-
 7 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1456254..7f196e5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -571,8 +571,14 @@ struct xfrm_skb_cb {
 
         /* Sequence number for replay protection. */
 	union {
-		u64 output;
-		__be32 input;
+		struct {
+			__u32 low;
+			__u32 hi;
+		} output;
+		struct {
+			__be32 low;
+			__be32 hi;
+		} input;
 	} seq;
 };
 
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 880a5ec..461ccac 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -205,7 +205,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
-	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
+	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg, 0, skb->len);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 14ca1f1..f986aee 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -199,7 +199,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 	esph->spi = x->id.spi;
-	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg,
@@ -211,7 +211,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
 	aead_givcrypt_set_assoc(req, asg, sizeof(*esph));
 	aead_givcrypt_set_giv(req, esph->enc_data,
-			      XFRM_SKB_CB(skb)->seq.output);
+			      XFRM_SKB_CB(skb)->seq.output.low);
 
 	ESP_SKB_CB(skb)->tmp = tmp;
 	err = crypto_aead_givencrypt(req);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ee82d4e..8fccce7 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -409,7 +409,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
-	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
+	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg, 0, skb->len);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index ee9b93b..672cb69 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -188,7 +188,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	*skb_mac_header(skb) = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;
-	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg,
@@ -200,7 +200,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
 	aead_givcrypt_set_assoc(req, asg, sizeof(*esph));
 	aead_givcrypt_set_giv(req, esph->enc_data,
-			      XFRM_SKB_CB(skb)->seq.output);
+			      XFRM_SKB_CB(skb)->seq.output.low);
 
 	ESP_SKB_CB(skb)->tmp = tmp;
 	err = crypto_aead_givencrypt(req);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 45f1c98..b173b7f 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -118,7 +118,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	if (encap_type < 0) {
 		async = 1;
 		x = xfrm_input_state(skb);
-		seq = XFRM_SKB_CB(skb)->seq.input;
+		seq = XFRM_SKB_CB(skb)->seq.input.low;
 		goto resume;
 	}
 
@@ -184,7 +184,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		spin_unlock(&x->lock);
 
-		XFRM_SKB_CB(skb)->seq.input = seq;
+		XFRM_SKB_CB(skb)->seq.input.low = seq;
 
 		nexthdr = x->type->input(x, skb);
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 64f2ae1..4b63776 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -68,7 +68,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		}
 
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
-			XFRM_SKB_CB(skb)->seq.output = ++x->replay.oseq;
+			XFRM_SKB_CB(skb)->seq.output.low = ++x->replay.oseq;
 			if (unlikely(x->replay.oseq == 0)) {
 				XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATESEQERROR);
 				x->replay.oseq--;
-- 
1.7.0.4
