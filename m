From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 5/13] crypto: testmgr - Switch to new AEAD interface
Date: Fri, 22 May 2015 16:30:53 +0800
Message-ID: <E1YviM1-0000xu-GV@gondolin.me.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35419 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728AbbEVIa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 04:30:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes use of the new AEAD interface which uses a single
SG list instead of separate lists for the AD and plain text.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/testmgr.c |   84 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 48 insertions(+), 36 deletions(-)

diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index 1817252..e6472b2 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -427,7 +427,6 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 	char *key;
 	struct aead_request *req;
 	struct scatterlist *sg;
-	struct scatterlist *asg;
 	struct scatterlist *sgout;
 	const char *e, *d;
 	struct tcrypt_result result;
@@ -454,11 +453,10 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 		goto out_nooutbuf;
 
 	/* avoid "the frame size is larger than 1024 bytes" compiler warning */
-	sg = kmalloc(sizeof(*sg) * 8 * (diff_dst ? 3 : 2), GFP_KERNEL);
+	sg = kmalloc(sizeof(*sg) * 8 * (diff_dst ? 4 : 2), GFP_KERNEL);
 	if (!sg)
 		goto out_nosg;
-	asg = &sg[8];
-	sgout = &asg[8];
+	sgout = &sg[16];
 
 	if (diff_dst)
 		d = "-ddst";
@@ -537,23 +535,28 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 			goto out;
 		}
 
+		k = !!template[i].alen;
+		sg_init_table(sg, k + 1);
+		sg_set_buf(&sg[0], assoc, template[i].alen);
+
 		if (diff_dst) {
+			sg_init_table(sgout, k + 1);
+			sg_set_buf(&sgout[0], assoc, template[i].alen);
+
 			output = xoutbuf[0];
 			output += align_offset;
-			sg_init_one(&sg[0], input, template[i].ilen);
-			sg_init_one(&sgout[0], output, template[i].rlen);
+			sg_set_buf(&sg[k], input, template[i].ilen);
+			sg_set_buf(&sgout[k], output, template[i].rlen);
 		} else {
-			sg_init_one(&sg[0], input,
-				    template[i].ilen + (enc ? authsize : 0));
+			sg_set_buf(&sg[k], input,
+				   template[i].ilen + (enc ? authsize : 0));
 			output = input;
 		}
 
-		sg_init_one(&asg[0], assoc, template[i].alen);
-
 		aead_request_set_crypt(req, sg, (diff_dst) ? sgout : sg,
 				       template[i].ilen, iv);
 
-		aead_request_set_assoc(req, asg, template[i].alen);
+		aead_request_set_ad(req, template[i].alen, 0);
 
 		ret = enc ? crypto_aead_encrypt(req) : crypto_aead_decrypt(req);
 
@@ -633,9 +636,29 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 		authsize = abs(template[i].rlen - template[i].ilen);
 
 		ret = -EINVAL;
-		sg_init_table(sg, template[i].np);
+		sg_init_table(sg, template[i].anp + template[i].np);
 		if (diff_dst)
-			sg_init_table(sgout, template[i].np);
+			sg_init_table(sgout, template[i].anp + template[i].np);
+
+		ret = -EINVAL;
+		for (k = 0, temp = 0; k < template[i].anp; k++) {
+			if (WARN_ON(offset_in_page(IDX[k]) +
+				    template[i].atap[k] > PAGE_SIZE))
+				goto out;
+			sg_set_buf(&sg[k],
+				   memcpy(axbuf[IDX[k] >> PAGE_SHIFT] +
+					  offset_in_page(IDX[k]),
+					  template[i].assoc + temp,
+					  template[i].atap[k]),
+				   template[i].atap[k]);
+			if (diff_dst)
+				sg_set_buf(&sgout[k],
+					   axbuf[IDX[k] >> PAGE_SHIFT] +
+					   offset_in_page(IDX[k]),
+					   template[i].atap[k]);
+			temp += template[i].atap[k];
+		}
+
 		for (k = 0, temp = 0; k < template[i].np; k++) {
 			if (WARN_ON(offset_in_page(IDX[k]) +
 				    template[i].tap[k] > PAGE_SIZE))
@@ -643,7 +666,8 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 
 			q = xbuf[IDX[k] >> PAGE_SHIFT] + offset_in_page(IDX[k]);
 			memcpy(q, template[i].input + temp, template[i].tap[k]);
-			sg_set_buf(&sg[k], q, template[i].tap[k]);
+			sg_set_buf(&sg[template[i].anp + k],
+				   q, template[i].tap[k]);
 
 			if (diff_dst) {
 				q = xoutbuf[IDX[k] >> PAGE_SHIFT] +
@@ -651,7 +675,8 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 
 				memset(q, 0, template[i].tap[k]);
 
-				sg_set_buf(&sgout[k], q, template[i].tap[k]);
+				sg_set_buf(&sgout[template[i].anp + k],
+					   q, template[i].tap[k]);
 			}
 
 			n = template[i].tap[k];
@@ -671,39 +696,26 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 		}
 
 		if (enc) {
-			if (WARN_ON(sg[k - 1].offset +
-				    sg[k - 1].length + authsize >
-				    PAGE_SIZE)) {
+			if (WARN_ON(sg[template[i].anp + k - 1].offset +
+				    sg[template[i].anp + k - 1].length +
+				    authsize > PAGE_SIZE)) {
 				ret = -EINVAL;
 				goto out;
 			}
 
 			if (diff_dst)
-				sgout[k - 1].length += authsize;
+				sgout[template[i].anp + k - 1].length +=
+					authsize;
 			else
-				sg[k - 1].length += authsize;
-		}
-
-		sg_init_table(asg, template[i].anp);
-		ret = -EINVAL;
-		for (k = 0, temp = 0; k < template[i].anp; k++) {
-			if (WARN_ON(offset_in_page(IDX[k]) +
-				    template[i].atap[k] > PAGE_SIZE))
-				goto out;
-			sg_set_buf(&asg[k],
-				   memcpy(axbuf[IDX[k] >> PAGE_SHIFT] +
-					  offset_in_page(IDX[k]),
-					  template[i].assoc + temp,
-					  template[i].atap[k]),
-				   template[i].atap[k]);
-			temp += template[i].atap[k];
+				sg[template[i].anp + k - 1].length +=
+					authsize;
 		}
 
 		aead_request_set_crypt(req, sg, (diff_dst) ? sgout : sg,
 				       template[i].ilen,
 				       iv);
 
-		aead_request_set_assoc(req, asg, template[i].alen);
+		aead_request_set_ad(req, template[i].alen, 0);
 
 		ret = enc ? crypto_aead_encrypt(req) : crypto_aead_decrypt(req);
 
