From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] crypto: Resolve shadow warnings
Date: Fri, 25 Jul 2014 02:53:38 -0700
Message-ID: <1406282018-23393-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Rustad <mark.d.rustad@intel.com>

Change formal parameters to not clash with global names to
eliminate many W=2 warnings.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 crypto/cryptd.c           | 12 ++++----
 crypto/eseqiv.c           |  8 ++---
 crypto/gcm.c              | 30 +++++++++---------
 crypto/seqiv.c            | 16 +++++-----
 crypto/tcrypt.c           | 77 ++++++++++++++++++++++++-----------------------
 include/crypto/aead.h     |  4 +--
 include/crypto/hash.h     |  4 +--
 include/crypto/skcipher.h |  4 +--
 include/linux/crypto.h    |  8 ++---
 9 files changed, 82 insertions(+), 81 deletions(-)

diff --git a/crypto/cryptd.c b/crypto/cryptd.c
index 7bdd61b..e592c90 100644
--- a/crypto/cryptd.c
+++ b/crypto/cryptd.c
@@ -233,7 +233,7 @@ static void cryptd_blkcipher_decrypt(struct crypto_async_request *req, int err)
 }
 
 static int cryptd_blkcipher_enqueue(struct ablkcipher_request *req,
-				    crypto_completion_t complete)
+				    crypto_completion_t compl)
 {
 	struct cryptd_blkcipher_request_ctx *rctx = ablkcipher_request_ctx(req);
 	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
@@ -241,7 +241,7 @@ static int cryptd_blkcipher_enqueue(struct ablkcipher_request *req,
 
 	queue = cryptd_get_queue(crypto_ablkcipher_tfm(tfm));
 	rctx->complete = req->base.complete;
-	req->base.complete = complete;
+	req->base.complete = compl;
 
 	return cryptd_enqueue_request(queue, &req->base);
 }
@@ -414,7 +414,7 @@ static int cryptd_hash_setkey(struct crypto_ahash *parent,
 }
 
 static int cryptd_hash_enqueue(struct ahash_request *req,
-				crypto_completion_t complete)
+				crypto_completion_t compl)
 {
 	struct cryptd_hash_request_ctx *rctx = ahash_request_ctx(req);
 	struct crypto_ahash *tfm = crypto_ahash_reqtfm(req);
@@ -422,7 +422,7 @@ static int cryptd_hash_enqueue(struct ahash_request *req,
 		cryptd_get_queue(crypto_ahash_tfm(tfm));
 
 	rctx->complete = req->base.complete;
-	req->base.complete = complete;
+	req->base.complete = compl;
 
 	return cryptd_enqueue_request(queue, &req->base);
 }
@@ -667,14 +667,14 @@ static void cryptd_aead_decrypt(struct crypto_async_request *areq, int err)
 }
 
 static int cryptd_aead_enqueue(struct aead_request *req,
-				    crypto_completion_t complete)
+				    crypto_completion_t compl)
 {
 	struct cryptd_aead_request_ctx *rctx = aead_request_ctx(req);
 	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
 	struct cryptd_queue *queue = cryptd_get_queue(crypto_aead_tfm(tfm));
 
 	rctx->complete = req->base.complete;
-	req->base.complete = complete;
+	req->base.complete = compl;
 	return cryptd_enqueue_request(queue, &req->base);
 }
 
diff --git a/crypto/eseqiv.c b/crypto/eseqiv.c
index 42ce9f5..bf7ab4a 100644
--- a/crypto/eseqiv.c
+++ b/crypto/eseqiv.c
@@ -68,7 +68,7 @@ static int eseqiv_givencrypt(struct skcipher_givcrypt_request *req)
 	struct eseqiv_ctx *ctx = crypto_ablkcipher_ctx(geniv);
 	struct eseqiv_request_ctx *reqctx = skcipher_givcrypt_reqctx(req);
 	struct ablkcipher_request *subreq;
-	crypto_completion_t complete;
+	crypto_completion_t compl;
 	void *data;
 	struct scatterlist *osrc, *odst;
 	struct scatterlist *dst;
@@ -86,7 +86,7 @@ static int eseqiv_givencrypt(struct skcipher_givcrypt_request *req)
 	ablkcipher_request_set_tfm(subreq, skcipher_geniv_cipher(geniv));
 
 	giv = req->giv;
-	complete = req->creq.base.complete;
+	compl = req->creq.base.complete;
 	data = req->creq.base.data;
 
 	osrc = req->creq.src;
@@ -101,11 +101,11 @@ static int eseqiv_givencrypt(struct skcipher_givcrypt_request *req)
 	if (vsrc != giv + ivsize && vdst != giv + ivsize) {
 		giv = PTR_ALIGN((u8 *)reqctx->tail,
 				crypto_ablkcipher_alignmask(geniv) + 1);
-		complete = eseqiv_complete;
+		compl = eseqiv_complete;
 		data = req;
 	}
 
-	ablkcipher_request_set_callback(subreq, req->creq.base.flags, complete,
+	ablkcipher_request_set_callback(subreq, req->creq.base.flags, compl,
 					data);
 
 	sg_init_table(reqctx->src, 2);
diff --git a/crypto/gcm.c b/crypto/gcm.c
index b4f0179..276cdac 100644
--- a/crypto/gcm.c
+++ b/crypto/gcm.c
@@ -228,14 +228,14 @@ static void gcm_hash_final_done(struct crypto_async_request *areq, int err);
 
 static int gcm_hash_update(struct aead_request *req,
 			   struct crypto_gcm_req_priv_ctx *pctx,
-			   crypto_completion_t complete,
+			   crypto_completion_t compl,
 			   struct scatterlist *src,
 			   unsigned int len)
 {
 	struct ahash_request *ahreq = &pctx->u.ahreq;
 
 	ahash_request_set_callback(ahreq, aead_request_flags(req),
-				   complete, req);
+				   compl, req);
 	ahash_request_set_crypt(ahreq, src, NULL, len);
 
 	return crypto_ahash_update(ahreq);
@@ -244,12 +244,12 @@ static int gcm_hash_update(struct aead_request *req,
 static int gcm_hash_remain(struct aead_request *req,
 			   struct crypto_gcm_req_priv_ctx *pctx,
 			   unsigned int remain,
-			   crypto_completion_t complete)
+			   crypto_completion_t compl)
 {
 	struct ahash_request *ahreq = &pctx->u.ahreq;
 
 	ahash_request_set_callback(ahreq, aead_request_flags(req),
-				   complete, req);
+				   compl, req);
 	sg_init_one(pctx->src, gcm_zeroes, remain);
 	ahash_request_set_crypt(ahreq, pctx->src, NULL, remain);
 
@@ -375,14 +375,14 @@ static void __gcm_hash_assoc_remain_done(struct aead_request *req, int err)
 {
 	struct crypto_gcm_req_priv_ctx *pctx = crypto_gcm_reqctx(req);
 	struct crypto_gcm_ghash_ctx *gctx = &pctx->ghash_ctx;
-	crypto_completion_t complete;
+	crypto_completion_t compl;
 	unsigned int remain = 0;
 
 	if (!err && gctx->cryptlen) {
 		remain = gcm_remain(gctx->cryptlen);
-		complete = remain ? gcm_hash_crypt_done :
+		compl = remain ? gcm_hash_crypt_done :
 			gcm_hash_crypt_remain_done;
-		err = gcm_hash_update(req, pctx, complete,
+		err = gcm_hash_update(req, pctx, compl,
 				      gctx->src, gctx->cryptlen);
 		if (err == -EINPROGRESS || err == -EBUSY)
 			return;
@@ -429,14 +429,14 @@ static void gcm_hash_assoc_done(struct crypto_async_request *areq, int err)
 static void __gcm_hash_init_done(struct aead_request *req, int err)
 {
 	struct crypto_gcm_req_priv_ctx *pctx = crypto_gcm_reqctx(req);
-	crypto_completion_t complete;
+	crypto_completion_t compl;
 	unsigned int remain = 0;
 
 	if (!err && req->assoclen) {
 		remain = gcm_remain(req->assoclen);
-		complete = remain ? gcm_hash_assoc_done :
+		compl = remain ? gcm_hash_assoc_done :
 			gcm_hash_assoc_remain_done;
-		err = gcm_hash_update(req, pctx, complete,
+		err = gcm_hash_update(req, pctx, compl,
 				      req->assoc, req->assoclen);
 		if (err == -EINPROGRESS || err == -EBUSY)
 			return;
@@ -462,7 +462,7 @@ static int gcm_hash(struct aead_request *req,
 	struct crypto_gcm_ghash_ctx *gctx = &pctx->ghash_ctx;
 	struct crypto_gcm_ctx *ctx = crypto_tfm_ctx(req->base.tfm);
 	unsigned int remain;
-	crypto_completion_t complete;
+	crypto_completion_t compl;
 	int err;
 
 	ahash_request_set_tfm(ahreq, ctx->ghash);
@@ -473,8 +473,8 @@ static int gcm_hash(struct aead_request *req,
 	if (err)
 		return err;
 	remain = gcm_remain(req->assoclen);
-	complete = remain ? gcm_hash_assoc_done : gcm_hash_assoc_remain_done;
-	err = gcm_hash_update(req, pctx, complete, req->assoc, req->assoclen);
+	compl = remain ? gcm_hash_assoc_done : gcm_hash_assoc_remain_done;
+	err = gcm_hash_update(req, pctx, compl, req->assoc, req->assoclen);
 	if (err)
 		return err;
 	if (remain) {
@@ -484,8 +484,8 @@ static int gcm_hash(struct aead_request *req,
 			return err;
 	}
 	remain = gcm_remain(gctx->cryptlen);
-	complete = remain ? gcm_hash_crypt_done : gcm_hash_crypt_remain_done;
-	err = gcm_hash_update(req, pctx, complete, gctx->src, gctx->cryptlen);
+	compl = remain ? gcm_hash_crypt_done : gcm_hash_crypt_remain_done;
+	err = gcm_hash_update(req, pctx, compl, gctx->src, gctx->cryptlen);
 	if (err)
 		return err;
 	if (remain) {
diff --git a/crypto/seqiv.c b/crypto/seqiv.c
index f2cba4ed..ee190fc 100644
--- a/crypto/seqiv.c
+++ b/crypto/seqiv.c
@@ -100,7 +100,7 @@ static int seqiv_givencrypt(struct skcipher_givcrypt_request *req)
 	struct crypto_ablkcipher *geniv = skcipher_givcrypt_reqtfm(req);
 	struct seqiv_ctx *ctx = crypto_ablkcipher_ctx(geniv);
 	struct ablkcipher_request *subreq = skcipher_givcrypt_reqctx(req);
-	crypto_completion_t complete;
+	crypto_completion_t compl;
 	void *data;
 	u8 *info;
 	unsigned int ivsize;
@@ -108,7 +108,7 @@ static int seqiv_givencrypt(struct skcipher_givcrypt_request *req)
 
 	ablkcipher_request_set_tfm(subreq, skcipher_geniv_cipher(geniv));
 
-	complete = req->creq.base.complete;
+	compl = req->creq.base.complete;
 	data = req->creq.base.data;
 	info = req->creq.info;
 
@@ -122,11 +122,11 @@ static int seqiv_givencrypt(struct skcipher_givcrypt_request *req)
 		if (!info)
 			return -ENOMEM;
 
-		complete = seqiv_complete;
+		compl = seqiv_complete;
 		data = req;
 	}
 
-	ablkcipher_request_set_callback(subreq, req->creq.base.flags, complete,
+	ablkcipher_request_set_callback(subreq, req->creq.base.flags, compl,
 					data);
 	ablkcipher_request_set_crypt(subreq, req->creq.src, req->creq.dst,
 				     req->creq.nbytes, info);
@@ -146,7 +146,7 @@ static int seqiv_aead_givencrypt(struct aead_givcrypt_request *req)
 	struct seqiv_ctx *ctx = crypto_aead_ctx(geniv);
 	struct aead_request *areq = &req->areq;
 	struct aead_request *subreq = aead_givcrypt_reqctx(req);
-	crypto_completion_t complete;
+	crypto_completion_t compl;
 	void *data;
 	u8 *info;
 	unsigned int ivsize;
@@ -154,7 +154,7 @@ static int seqiv_aead_givencrypt(struct aead_givcrypt_request *req)
 
 	aead_request_set_tfm(subreq, aead_geniv_base(geniv));
 
-	complete = areq->base.complete;
+	compl = areq->base.complete;
 	data = areq->base.data;
 	info = areq->iv;
 
@@ -168,11 +168,11 @@ static int seqiv_aead_givencrypt(struct aead_givcrypt_request *req)
 		if (!info)
 			return -ENOMEM;
 
-		complete = seqiv_aead_complete;
+		compl = seqiv_aead_complete;
 		data = req;
 	}
 
-	aead_request_set_callback(subreq, areq->base.flags, complete, data);
+	aead_request_set_callback(subreq, areq->base.flags, compl, data);
 	aead_request_set_crypt(subreq, areq->src, areq->dst, areq->cryptlen,
 			       info);
 	aead_request_set_assoc(subreq, areq->assoc, areq->assoclen);
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index ba247cf..ba9f788 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -68,13 +68,13 @@ static char *check[] = {
 };
 
 static int test_cipher_jiffies(struct blkcipher_desc *desc, int enc,
-			       struct scatterlist *sg, int blen, int sec)
+			       struct scatterlist *sg, int blen, int secs)
 {
 	unsigned long start, end;
 	int bcount;
 	int ret;
 
-	for (start = jiffies, end = start + sec * HZ, bcount = 0;
+	for (start = jiffies, end = start + secs * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		if (enc)
 			ret = crypto_blkcipher_encrypt(desc, sg, sg, blen);
@@ -86,7 +86,7 @@ static int test_cipher_jiffies(struct blkcipher_desc *desc, int enc,
 	}
 
 	printk("%d operations in %d seconds (%ld bytes)\n",
-	       bcount, sec, (long)bcount * blen);
+	       bcount, secs, (long)bcount * blen);
 	return 0;
 }
 
@@ -138,13 +138,13 @@ out:
 }
 
 static int test_aead_jiffies(struct aead_request *req, int enc,
-				int blen, int sec)
+				int blen, int secs)
 {
 	unsigned long start, end;
 	int bcount;
 	int ret;
 
-	for (start = jiffies, end = start + sec * HZ, bcount = 0;
+	for (start = jiffies, end = start + secs * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		if (enc)
 			ret = crypto_aead_encrypt(req);
@@ -156,7 +156,7 @@ static int test_aead_jiffies(struct aead_request *req, int enc,
 	}
 
 	printk("%d operations in %d seconds (%ld bytes)\n",
-	       bcount, sec, (long)bcount * blen);
+	       bcount, secs, (long)bcount * blen);
 	return 0;
 }
 
@@ -260,7 +260,7 @@ static void sg_init_aead(struct scatterlist *sg, char *xbuf[XBUFSIZE],
 	}
 }
 
-static void test_aead_speed(const char *algo, int enc, unsigned int sec,
+static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 			    struct aead_speed_template *template,
 			    unsigned int tcount, u8 authsize,
 			    unsigned int aad_size, u8 *keysize)
@@ -374,8 +374,9 @@ static void test_aead_speed(const char *algo, int enc, unsigned int sec,
 			aead_request_set_crypt(req, sg, sgout, *b_size, iv);
 			aead_request_set_assoc(req, asg, aad_size);
 
-			if (sec)
-				ret = test_aead_jiffies(req, enc, *b_size, sec);
+			if (secs)
+				ret = test_aead_jiffies(req, enc, *b_size,
+							secs);
 			else
 				ret = test_aead_cycles(req, enc, *b_size);
 
@@ -405,7 +406,7 @@ out_noxbuf:
 	return;
 }
 
-static void test_cipher_speed(const char *algo, int enc, unsigned int sec,
+static void test_cipher_speed(const char *algo, int enc, unsigned int secs,
 			      struct cipher_speed_template *template,
 			      unsigned int tcount, u8 *keysize)
 {
@@ -483,9 +484,9 @@ static void test_cipher_speed(const char *algo, int enc, unsigned int sec,
 				crypto_blkcipher_set_iv(tfm, iv, iv_len);
 			}
 
-			if (sec)
+			if (secs)
 				ret = test_cipher_jiffies(&desc, enc, sg,
-							  *b_size, sec);
+							  *b_size, secs);
 			else
 				ret = test_cipher_cycles(&desc, enc, sg,
 							 *b_size);
@@ -506,13 +507,13 @@ out:
 
 static int test_hash_jiffies_digest(struct hash_desc *desc,
 				    struct scatterlist *sg, int blen,
-				    char *out, int sec)
+				    char *out, int secs)
 {
 	unsigned long start, end;
 	int bcount;
 	int ret;
 
-	for (start = jiffies, end = start + sec * HZ, bcount = 0;
+	for (start = jiffies, end = start + secs * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		ret = crypto_hash_digest(desc, sg, blen, out);
 		if (ret)
@@ -520,22 +521,22 @@ static int test_hash_jiffies_digest(struct hash_desc *desc,
 	}
 
 	printk("%6u opers/sec, %9lu bytes/sec\n",
-	       bcount / sec, ((long)bcount * blen) / sec);
+	       bcount / secs, ((long)bcount * blen) / secs);
 
 	return 0;
 }
 
 static int test_hash_jiffies(struct hash_desc *desc, struct scatterlist *sg,
-			     int blen, int plen, char *out, int sec)
+			     int blen, int plen, char *out, int secs)
 {
 	unsigned long start, end;
 	int bcount, pcount;
 	int ret;
 
 	if (plen == blen)
-		return test_hash_jiffies_digest(desc, sg, blen, out, sec);
+		return test_hash_jiffies_digest(desc, sg, blen, out, secs);
 
-	for (start = jiffies, end = start + sec * HZ, bcount = 0;
+	for (start = jiffies, end = start + secs * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		ret = crypto_hash_init(desc);
 		if (ret)
@@ -552,7 +553,7 @@ static int test_hash_jiffies(struct hash_desc *desc, struct scatterlist *sg,
 	}
 
 	printk("%6u opers/sec, %9lu bytes/sec\n",
-	       bcount / sec, ((long)bcount * blen) / sec);
+	       bcount / secs, ((long)bcount * blen) / secs);
 
 	return 0;
 }
@@ -673,7 +674,7 @@ static void test_hash_sg_init(struct scatterlist *sg)
 	}
 }
 
-static void test_hash_speed(const char *algo, unsigned int sec,
+static void test_hash_speed(const char *algo, unsigned int secs,
 			    struct hash_speed *speed)
 {
 	struct scatterlist sg[TVMEMSIZE];
@@ -718,9 +719,9 @@ static void test_hash_speed(const char *algo, unsigned int sec,
 		       "(%5u byte blocks,%5u bytes per update,%4u updates): ",
 		       i, speed[i].blen, speed[i].plen, speed[i].blen / speed[i].plen);
 
-		if (sec)
+		if (secs)
 			ret = test_hash_jiffies(&desc, sg, speed[i].blen,
-						speed[i].plen, output, sec);
+						speed[i].plen, output, secs);
 		else
 			ret = test_hash_cycles(&desc, sg, speed[i].blen,
 					       speed[i].plen, output);
@@ -765,13 +766,13 @@ static inline int do_one_ahash_op(struct ahash_request *req, int ret)
 }
 
 static int test_ahash_jiffies_digest(struct ahash_request *req, int blen,
-				     char *out, int sec)
+				     char *out, int secs)
 {
 	unsigned long start, end;
 	int bcount;
 	int ret;
 
-	for (start = jiffies, end = start + sec * HZ, bcount = 0;
+	for (start = jiffies, end = start + secs * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		ret = do_one_ahash_op(req, crypto_ahash_digest(req));
 		if (ret)
@@ -779,22 +780,22 @@ static int test_ahash_jiffies_digest(struct ahash_request *req, int blen,
 	}
 
 	printk("%6u opers/sec, %9lu bytes/sec\n",
-	       bcount / sec, ((long)bcount * blen) / sec);
+	       bcount / secs, ((long)bcount * blen) / secs);
 
 	return 0;
 }
 
 static int test_ahash_jiffies(struct ahash_request *req, int blen,
-			      int plen, char *out, int sec)
+			      int plen, char *out, int secs)
 {
 	unsigned long start, end;
 	int bcount, pcount;
 	int ret;
 
 	if (plen == blen)
-		return test_ahash_jiffies_digest(req, blen, out, sec);
+		return test_ahash_jiffies_digest(req, blen, out, secs);
 
-	for (start = jiffies, end = start + sec * HZ, bcount = 0;
+	for (start = jiffies, end = start + secs * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		ret = crypto_ahash_init(req);
 		if (ret)
@@ -811,7 +812,7 @@ static int test_ahash_jiffies(struct ahash_request *req, int blen,
 	}
 
 	pr_cont("%6u opers/sec, %9lu bytes/sec\n",
-		bcount / sec, ((long)bcount * blen) / sec);
+		bcount / secs, ((long)bcount * blen) / secs);
 
 	return 0;
 }
@@ -911,7 +912,7 @@ out:
 	return 0;
 }
 
-static void test_ahash_speed(const char *algo, unsigned int sec,
+static void test_ahash_speed(const char *algo, unsigned int secs,
 			     struct hash_speed *speed)
 {
 	struct scatterlist sg[TVMEMSIZE];
@@ -960,9 +961,9 @@ static void test_ahash_speed(const char *algo, unsigned int sec,
 
 		ahash_request_set_crypt(req, sg, output, speed[i].plen);
 
-		if (sec)
+		if (secs)
 			ret = test_ahash_jiffies(req, speed[i].blen,
-						 speed[i].plen, output, sec);
+						 speed[i].plen, output, secs);
 		else
 			ret = test_ahash_cycles(req, speed[i].blen,
 						speed[i].plen, output);
@@ -994,13 +995,13 @@ static inline int do_one_acipher_op(struct ablkcipher_request *req, int ret)
 }
 
 static int test_acipher_jiffies(struct ablkcipher_request *req, int enc,
-				int blen, int sec)
+				int blen, int secs)
 {
 	unsigned long start, end;
 	int bcount;
 	int ret;
 
-	for (start = jiffies, end = start + sec * HZ, bcount = 0;
+	for (start = jiffies, end = start + secs * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		if (enc)
 			ret = do_one_acipher_op(req,
@@ -1014,7 +1015,7 @@ static int test_acipher_jiffies(struct ablkcipher_request *req, int enc,
 	}
 
 	pr_cont("%d operations in %d seconds (%ld bytes)\n",
-		bcount, sec, (long)bcount * blen);
+		bcount, secs, (long)bcount * blen);
 	return 0;
 }
 
@@ -1065,7 +1066,7 @@ out:
 	return ret;
 }
 
-static void test_acipher_speed(const char *algo, int enc, unsigned int sec,
+static void test_acipher_speed(const char *algo, int enc, unsigned int secs,
 			       struct cipher_speed_template *template,
 			       unsigned int tcount, u8 *keysize)
 {
@@ -1168,9 +1169,9 @@ static void test_acipher_speed(const char *algo, int enc, unsigned int sec,
 
 			ablkcipher_request_set_crypt(req, sg, sg, *b_size, iv);
 
-			if (sec)
+			if (secs)
 				ret = test_acipher_jiffies(req, enc,
-							   *b_size, sec);
+							   *b_size, secs);
 			else
 				ret = test_acipher_cycles(req, enc,
 							  *b_size);
diff --git a/include/crypto/aead.h b/include/crypto/aead.h
index 0edf949..94b19be 100644
--- a/include/crypto/aead.h
+++ b/include/crypto/aead.h
@@ -75,9 +75,9 @@ static inline void aead_givcrypt_free(struct aead_givcrypt_request *req)
 
 static inline void aead_givcrypt_set_callback(
 	struct aead_givcrypt_request *req, u32 flags,
-	crypto_completion_t complete, void *data)
+	crypto_completion_t compl, void *data)
 {
-	aead_request_set_callback(&req->areq, flags, complete, data);
+	aead_request_set_callback(&req->areq, flags, compl, data);
 }
 
 static inline void aead_givcrypt_set_crypt(struct aead_givcrypt_request *req,
diff --git a/include/crypto/hash.h b/include/crypto/hash.h
index 26cb1eb..a391955 100644
--- a/include/crypto/hash.h
+++ b/include/crypto/hash.h
@@ -238,10 +238,10 @@ static inline struct ahash_request *ahash_request_cast(
 
 static inline void ahash_request_set_callback(struct ahash_request *req,
 					      u32 flags,
-					      crypto_completion_t complete,
+					      crypto_completion_t compl,
 					      void *data)
 {
-	req->base.complete = complete;
+	req->base.complete = compl;
 	req->base.data = data;
 	req->base.flags = flags;
 }
diff --git a/include/crypto/skcipher.h b/include/crypto/skcipher.h
index 25fd612..07d245f 100644
--- a/include/crypto/skcipher.h
+++ b/include/crypto/skcipher.h
@@ -86,9 +86,9 @@ static inline void skcipher_givcrypt_free(struct skcipher_givcrypt_request *req)
 
 static inline void skcipher_givcrypt_set_callback(
 	struct skcipher_givcrypt_request *req, u32 flags,
-	crypto_completion_t complete, void *data)
+	crypto_completion_t compl, void *data)
 {
-	ablkcipher_request_set_callback(&req->creq, flags, complete, data);
+	ablkcipher_request_set_callback(&req->creq, flags, compl, data);
 }
 
 static inline void skcipher_givcrypt_set_crypt(
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index b92eadf..d45e949 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -710,9 +710,9 @@ static inline void ablkcipher_request_free(struct ablkcipher_request *req)
 
 static inline void ablkcipher_request_set_callback(
 	struct ablkcipher_request *req,
-	u32 flags, crypto_completion_t complete, void *data)
+	u32 flags, crypto_completion_t compl, void *data)
 {
-	req->base.complete = complete;
+	req->base.complete = compl;
 	req->base.data = data;
 	req->base.flags = flags;
 }
@@ -841,10 +841,10 @@ static inline void aead_request_free(struct aead_request *req)
 
 static inline void aead_request_set_callback(struct aead_request *req,
 					     u32 flags,
-					     crypto_completion_t complete,
+					     crypto_completion_t compl,
 					     void *data)
 {
-	req->base.complete = complete;
+	req->base.complete = compl;
 	req->base.data = data;
 	req->base.flags = flags;
 }
-- 
1.9.3
