From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 3/5] crypto: add possibility to force sync transform
Date: Mon, 1 Dec 2008 08:19:03 +0100
Message-ID: <20081201071903.GS476@secunet.com>
References: <20081201071614.GP476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	klassert@mathematik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:46527 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750895AbYLAHsW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 02:48:22 -0500
Content-Disposition: inline
In-Reply-To: <20081201071614.GP476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>

If IPsec is parallelized by xfrm_padata, async transform
is not allowed. So Add a possibility to force sync
transform in this case.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 crypto/chainiv.c |   14 ++++++++++++--
 net/ipv4/esp4.c  |   12 ++++++++++--
 net/ipv6/esp6.c  |   12 ++++++++++--
 3 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/crypto/chainiv.c b/crypto/chainiv.c
index 7c37a49..2079fdd 100644
--- a/crypto/chainiv.c
+++ b/crypto/chainiv.c
@@ -168,8 +168,12 @@ static int async_chainiv_givencrypt_tail(struct skcipher_givcrypt_request *req)
 	memcpy(subreq->info, ctx->iv, ivsize);
 
 	ctx->err = crypto_ablkcipher_encrypt(subreq);
-	if (ctx->err)
-		goto out;
+	if (ctx->err) {
+		if (ablkcipher_request_flags(&req->creq) & CRYPTO_TFM_REQ_FORCE_SYNC)
+			return ctx->err;
+		else
+			goto out;
+	}
 
 	memcpy(ctx->iv, subreq->info, ivsize);
 
@@ -190,6 +194,11 @@ static int async_chainiv_givencrypt(struct skcipher_givcrypt_request *req)
 	ablkcipher_request_set_crypt(subreq, req->creq.src, req->creq.dst,
 				     req->creq.nbytes, req->creq.info);
 
+	 if (ablkcipher_request_flags(&req->creq) & CRYPTO_TFM_REQ_FORCE_SYNC) {
+		 clear_bit(CHAINIV_STATE_INUSE, &ctx->state);
+		 goto sync_out;
+	 }
+
 	if (test_and_set_bit(CHAINIV_STATE_INUSE, &ctx->state))
 		goto postpone;
 
@@ -198,6 +207,7 @@ static int async_chainiv_givencrypt(struct skcipher_givcrypt_request *req)
 		goto postpone;
 	}
 
+sync_out:
 	return async_chainiv_givencrypt_tail(req);
 
 postpone:
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 21515d4..3ea3fb2 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -114,6 +114,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	void *tmp;
 	u8 *iv;
 	u8 *tail;
+	u32 flags;
 	int blksize;
 	int clen;
 	int alen;
@@ -123,6 +124,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	err = -ENOMEM;
 
+	flags = 0;
+
 	/* Round to block size */
 	clen = skb->len;
 
@@ -207,7 +210,9 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		     clen + alen);
 	sg_init_one(asg, esph, sizeof(*esph));
 
-	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
+	xfrm_aead_set_flags(skb, flags);
+
+	aead_givcrypt_set_callback(req, flags, esp_output_done, skb);
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
 	aead_givcrypt_set_assoc(req, asg, sizeof(*esph));
 	aead_givcrypt_set_giv(req, esph->enc_data,
@@ -332,6 +337,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	int nfrags;
 	void *tmp;
 	u8 *iv;
+	u32 flags = 0;
 	struct scatterlist *sg;
 	struct scatterlist *asg;
 	int err = -EINVAL;
@@ -368,7 +374,9 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	skb_to_sgvec(skb, sg, sizeof(*esph) + crypto_aead_ivsize(aead), elen);
 	sg_init_one(asg, esph, sizeof(*esph));
 
-	aead_request_set_callback(req, 0, esp_input_done, skb);
+	xfrm_aead_set_flags(skb, flags);
+
+	aead_request_set_callback(req, flags, esp_input_done, skb);
 	aead_request_set_crypt(req, sg, sg, elen, iv);
 	aead_request_set_assoc(req, asg, sizeof(*esph));
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index b181b08..9874adf 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -143,11 +143,14 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	int nfrags;
 	u8 *iv;
 	u8 *tail;
+	u32 flags;
 	struct esp_data *esp = x->data;
 
 	/* skb is pure payload to encrypt */
 	err = -ENOMEM;
 
+	flags = 0;
+
 	/* Round to block size */
 	clen = skb->len;
 
@@ -196,7 +199,9 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 		     clen + alen);
 	sg_init_one(asg, esph, sizeof(*esph));
 
-	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
+	xfrm_aead_set_flags(skb, flags);
+
+	aead_givcrypt_set_callback(req, flags, esp_output_done, skb);
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
 	aead_givcrypt_set_assoc(req, asg, sizeof(*esph));
 	aead_givcrypt_set_giv(req, esph->enc_data,
@@ -279,6 +284,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	int ret = 0;
 	void *tmp;
 	u8 *iv;
+	u32 flags = 0;
 	struct scatterlist *sg;
 	struct scatterlist *asg;
 
@@ -319,7 +325,9 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	skb_to_sgvec(skb, sg, sizeof(*esph) + crypto_aead_ivsize(aead), elen);
 	sg_init_one(asg, esph, sizeof(*esph));
 
-	aead_request_set_callback(req, 0, esp_input_done, skb);
+	xfrm_aead_set_flags(skb, flags);
+
+	aead_request_set_callback(req, flags, esp_input_done, skb);
 	aead_request_set_crypt(req, sg, sg, elen, iv);
 	aead_request_set_assoc(req, asg, sizeof(*esph));
 
-- 
1.5.4.2

