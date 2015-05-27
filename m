From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 8/8] crypto: tcrypt - Switch to new AEAD interface
Date: Wed, 27 May 2015 16:03:51 +0800
Message-ID: <E1YxWJb-00070N-AP@gondolin.me.apana.org.au>
References: <20150527080105.GA26751@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes use of the new AEAD interface which uses a single
SG list instead of separate lists for the AD and plain text.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/tcrypt.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 2bff613..4b4a931 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -277,7 +277,6 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 	const char *key;
 	struct aead_request *req;
 	struct scatterlist *sg;
-	struct scatterlist *asg;
 	struct scatterlist *sgout;
 	const char *e;
 	void *assoc;
@@ -309,11 +308,10 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 	if (testmgr_alloc_buf(xoutbuf))
 		goto out_nooutbuf;
 
-	sg = kmalloc(sizeof(*sg) * 8 * 3, GFP_KERNEL);
+	sg = kmalloc(sizeof(*sg) * 9 * 2, GFP_KERNEL);
 	if (!sg)
 		goto out_nosg;
-	asg = &sg[8];
-	sgout = &asg[8];
+	sgout = &sg[9];
 
 	tfm = crypto_alloc_aead(algo, 0, 0);
 
@@ -339,7 +337,8 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 		do {
 			assoc = axbuf[0];
 			memset(assoc, 0xff, aad_size);
-			sg_init_one(&asg[0], assoc, aad_size);
+			sg_set_buf(&sg[0], assoc, aad_size);
+			sg_set_buf(&sgout[0], assoc, aad_size);
 
 			if ((*keysize + *b_size) > TVMEMSIZE * PAGE_SIZE) {
 				pr_err("template (%u) too big for tvmem (%lu)\n",
@@ -375,14 +374,14 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 				goto out;
 			}
 
-			sg_init_aead(&sg[0], xbuf,
+			sg_init_aead(&sg[1], xbuf,
 				    *b_size + (enc ? authsize : 0));
 
-			sg_init_aead(&sgout[0], xoutbuf,
+			sg_init_aead(&sgout[1], xoutbuf,
 				    *b_size + (enc ? authsize : 0));
 
 			aead_request_set_crypt(req, sg, sgout, *b_size, iv);
-			aead_request_set_assoc(req, asg, aad_size);
+			aead_request_set_ad(req, aad_size);
 
 			if (secs)
 				ret = test_aead_jiffies(req, enc, *b_size,
