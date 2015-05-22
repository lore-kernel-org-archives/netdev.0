From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Fri, 22 May 2015 16:31:04 +0800
Message-ID: <E1YviMC-00010E-Uk@gondolin.me.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40579 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756663AbbEVIbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 04:31:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes use of the new AEAD interface which uses a single
SG list instead of separate lists for the AD and plain text.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/algif_aead.c |   61 ++++++++++++++++++++++++++++++----------------------
 1 file changed, 36 insertions(+), 25 deletions(-)

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 53702e9..5674a33 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -26,7 +26,7 @@
 
 struct aead_sg_list {
 	unsigned int cur;
-	struct scatterlist sg[ALG_MAX_PAGES];
+	struct scatterlist sg[ALG_MAX_PAGES + 1];
 };
 
 struct aead_ctx {
@@ -357,7 +357,8 @@ static int aead_recvmsg(struct socket *sock, struct msghdr *msg, size_t ignored,
 	unsigned as = crypto_aead_authsize(crypto_aead_reqtfm(&ctx->aead_req));
 	struct aead_sg_list *sgl = &ctx->tsgl;
 	struct scatterlist *sg = NULL;
-	struct scatterlist assoc[ALG_MAX_PAGES];
+	struct scatterlist dstbuf[ALG_MAX_PAGES + 1];
+	struct scatterlist *dst = dstbuf;
 	size_t assoclen = 0;
 	unsigned int i = 0;
 	int err = -EINVAL;
@@ -453,7 +454,7 @@ static int aead_recvmsg(struct socket *sock, struct msghdr *msg, size_t ignored,
 	if (usedpages < outlen)
 		goto unlock;
 
-	sg_init_table(assoc, ALG_MAX_PAGES);
+	sg_mark_end(sgl->sg + sgl->cur);
 	assoclen = ctx->aead_assoclen;
 	/*
 	 * Split scatterlist into two: first part becomes AD, second part
@@ -465,35 +466,45 @@ static int aead_recvmsg(struct socket *sock, struct msghdr *msg, size_t ignored,
 		sg = sgl->sg + i;
 		if (sg->length <= assoclen) {
 			/* AD is larger than one page */
-			sg_set_page(assoc + i, sg_page(sg),
+			sg_set_page(dst + i, sg_page(sg),
 				    sg->length, sg->offset);
 			assoclen -= sg->length;
-			if (i >= ctx->tsgl.cur)
-				goto unlock;
-		} else if (!assoclen) {
-			/* current page is to start of plaintext / ciphertext */
-			if (i)
-				/* AD terminates at page boundary */
-				sg_mark_end(assoc + i - 1);
-			else
-				/* AD size is zero */
-				sg_mark_end(assoc);
-			break;
-		} else {
+			continue;
+		}
+
+		if (assoclen) {
 			/* AD does not terminate at page boundary */
-			sg_set_page(assoc + i, sg_page(sg),
+			sg_set_page(dst + i, sg_page(sg),
 				    assoclen, sg->offset);
-			sg_mark_end(assoc + i);
-			/* plaintext / ciphertext starts after AD */
-			sg->length -= assoclen;
-			sg->offset += assoclen;
-			break;
+			assoclen = 0;
+			i++;
 		}
+
+		break;
 	}
 
-	aead_request_set_assoc(&ctx->aead_req, assoc, ctx->aead_assoclen);
-	aead_request_set_crypt(&ctx->aead_req, sg, ctx->rsgl[0].sg, used,
-			       ctx->iv);
+	/* This should never happen because of aead_sufficient_data. */
+	if (WARN_ON_ONCE(assoclen))
+		goto unlock;
+
+	/* current page is the start of plaintext / ciphertext */
+	if (!i)
+		/* AD size is zero */
+		dst = ctx->rsgl[0].sg;
+	else if (outlen)
+		/* AD size is non-zero */
+		scatterwalk_crypto_chain(
+			dst, ctx->rsgl[0].sg,
+			sg_page(ctx->rsgl[0].sg) == sg_page(dst + i - 1) &&
+			ctx->rsgl[0].sg[0].offset == dst[i - 1].offset +
+						     dst[i - 1].length,
+			i + 1);
+	else
+		/* AD only */
+		sg_mark_end(dst + i);
+
+	aead_request_set_crypt(&ctx->aead_req, sgl->sg, dst, used, ctx->iv);
+	aead_request_set_ad(&ctx->aead_req, ctx->aead_assoclen, 0);
 
 	err = af_alg_wait_for_completion(ctx->enc ?
 					 crypto_aead_encrypt(&ctx->aead_req) :
