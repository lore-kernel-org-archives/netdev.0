From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 9/16] [BLOCK] cryptoloop: Use block ciphers where applicable
Date: Sun, 13 Aug 2006 22:20:15 +1000
Message-ID: <E1GCEwx-0004gF-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12297 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751080AbWHMMUV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:21 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BLOCK] cryptoloop: Use block ciphers where applicable

This patch converts cryptoloop to use the new block cipher type where
applicable.  As a result the ECB-specific and CBC-specific transfer
functions have been merged.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/block/cryptoloop.c |  158 +++++++++++++++------------------------------
 1 files changed, 53 insertions(+), 105 deletions(-)

diff --git a/drivers/block/cryptoloop.c b/drivers/block/cryptoloop.c
--- a/drivers/block/cryptoloop.c
+++ b/drivers/block/cryptoloop.c
@@ -40,11 +40,13 @@ static int
 cryptoloop_init(struct loop_device *lo, const struct loop_info64 *info)
 {
 	int err = -EINVAL;
+	int cipher_len;
+	int mode_len;
 	char cms[LO_NAME_SIZE];			/* cipher-mode string */
 	char *cipher;
 	char *mode;
 	char *cmsp = cms;			/* c-m string pointer */
-	struct crypto_tfm *tfm = NULL;
+	struct crypto_blkcipher *tfm;
 
 	/* encryption breaks for non sector aligned offsets */
 
@@ -53,20 +55,39 @@ cryptoloop_init(struct loop_device *lo, 
 
 	strncpy(cms, info->lo_crypt_name, LO_NAME_SIZE);
 	cms[LO_NAME_SIZE - 1] = 0;
-	cipher = strsep(&cmsp, "-");
-	mode = strsep(&cmsp, "-");
 
-	if (mode == NULL || strcmp(mode, "cbc") == 0)
-		tfm = crypto_alloc_tfm(cipher, CRYPTO_TFM_MODE_CBC |
-					       CRYPTO_TFM_REQ_MAY_SLEEP);
-	else if (strcmp(mode, "ecb") == 0)
-		tfm = crypto_alloc_tfm(cipher, CRYPTO_TFM_MODE_ECB |
-					       CRYPTO_TFM_REQ_MAY_SLEEP);
-	if (tfm == NULL)
+	cipher = cmsp;
+	cipher_len = strcspn(cmsp, "-");
+
+	mode = cmsp + cipher_len;
+	mode_len = 0;
+	if (*mode) {
+		mode++;
+		mode_len = strcspn(mode, "-");
+	}
+
+	if (!mode_len) {
+		mode = "ecb";
+		mode_len = 3;
+	}
+
+	if (cipher_len + mode_len + 3 > LO_NAME_SIZE)
 		return -EINVAL;
 
-	err = tfm->crt_u.cipher.cit_setkey(tfm, info->lo_encrypt_key,
-					   info->lo_encrypt_key_size);
+	memmove(cms, mode, mode_len);
+	cmsp = cms + mode_len;
+	*cmsp++ = '(';
+	memcpy(cmsp, info->lo_crypt_name, cipher_len);
+	cmsp += cipher_len;
+	*cmsp++ = ')';
+	*cmsp = 0;
+
+	tfm = crypto_alloc_blkcipher(cms, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
+		return PTR_ERR(tfm);
+
+	err = crypto_blkcipher_setkey(tfm, info->lo_encrypt_key,
+				      info->lo_encrypt_key_size);
 	
 	if (err != 0)
 		goto out_free_tfm;
@@ -75,99 +96,49 @@ cryptoloop_init(struct loop_device *lo, 
 	return 0;
 
  out_free_tfm:
-	crypto_free_tfm(tfm);
+	crypto_free_blkcipher(tfm);
 
  out:
 	return err;
 }
 
 
-typedef int (*encdec_ecb_t)(struct crypto_tfm *tfm,
+typedef int (*encdec_cbc_t)(struct blkcipher_desc *desc,
 			struct scatterlist *sg_out,
 			struct scatterlist *sg_in,
 			unsigned int nsg);
 
-
-static int
-cryptoloop_transfer_ecb(struct loop_device *lo, int cmd,
-			struct page *raw_page, unsigned raw_off,
-			struct page *loop_page, unsigned loop_off,
-			int size, sector_t IV)
-{
-	struct crypto_tfm *tfm = (struct crypto_tfm *) lo->key_data;
-	struct scatterlist sg_out = { NULL, };
-	struct scatterlist sg_in = { NULL, };
-
-	encdec_ecb_t encdecfunc;
-	struct page *in_page, *out_page;
-	unsigned in_offs, out_offs;
-
-	if (cmd == READ) {
-		in_page = raw_page;
-		in_offs = raw_off;
-		out_page = loop_page;
-		out_offs = loop_off;
-		encdecfunc = tfm->crt_u.cipher.cit_decrypt;
-	} else {
-		in_page = loop_page;
-		in_offs = loop_off;
-		out_page = raw_page;
-		out_offs = raw_off;
-		encdecfunc = tfm->crt_u.cipher.cit_encrypt;
-	}
-
-	while (size > 0) {
-		const int sz = min(size, LOOP_IV_SECTOR_SIZE);
-
-		sg_in.page = in_page;
-		sg_in.offset = in_offs;
-		sg_in.length = sz;
-
-		sg_out.page = out_page;
-		sg_out.offset = out_offs;
-		sg_out.length = sz;
-
-		encdecfunc(tfm, &sg_out, &sg_in, sz);
-
-		size -= sz;
-		in_offs += sz;
-		out_offs += sz;
-	}
-
-	return 0;
-}
-
-typedef int (*encdec_cbc_t)(struct crypto_tfm *tfm,
-			struct scatterlist *sg_out,
-			struct scatterlist *sg_in,
-			unsigned int nsg, u8 *iv);
-
 static int
-cryptoloop_transfer_cbc(struct loop_device *lo, int cmd,
-			struct page *raw_page, unsigned raw_off,
-			struct page *loop_page, unsigned loop_off,
-			int size, sector_t IV)
+cryptoloop_transfer(struct loop_device *lo, int cmd,
+		    struct page *raw_page, unsigned raw_off,
+		    struct page *loop_page, unsigned loop_off,
+		    int size, sector_t IV)
 {
-	struct crypto_tfm *tfm = (struct crypto_tfm *) lo->key_data;
+	struct crypto_blkcipher *tfm = lo->key_data;
+	struct blkcipher_desc desc = {
+		.tfm = tfm,
+		.flags = CRYPTO_TFM_REQ_MAY_SLEEP,
+	};
 	struct scatterlist sg_out = { NULL, };
 	struct scatterlist sg_in = { NULL, };
 
 	encdec_cbc_t encdecfunc;
 	struct page *in_page, *out_page;
 	unsigned in_offs, out_offs;
+	int err;
 
 	if (cmd == READ) {
 		in_page = raw_page;
 		in_offs = raw_off;
 		out_page = loop_page;
 		out_offs = loop_off;
-		encdecfunc = tfm->crt_u.cipher.cit_decrypt_iv;
+		encdecfunc = crypto_blkcipher_crt(tfm)->decrypt;
 	} else {
 		in_page = loop_page;
 		in_offs = loop_off;
 		out_page = raw_page;
 		out_offs = raw_off;
-		encdecfunc = tfm->crt_u.cipher.cit_encrypt_iv;
+		encdecfunc = crypto_blkcipher_crt(tfm)->encrypt;
 	}
 
 	while (size > 0) {
@@ -183,7 +154,10 @@ cryptoloop_transfer_cbc(struct loop_devi
 		sg_out.offset = out_offs;
 		sg_out.length = sz;
 
-		encdecfunc(tfm, &sg_out, &sg_in, sz, (u8 *)iv);
+		desc.info = iv;
+		err = encdecfunc(&desc, &sg_out, &sg_in, sz);
+		if (err)
+			return err;
 
 		IV++;
 		size -= sz;
@@ -195,32 +169,6 @@ cryptoloop_transfer_cbc(struct loop_devi
 }
 
 static int
-cryptoloop_transfer(struct loop_device *lo, int cmd,
-		    struct page *raw_page, unsigned raw_off,
-		    struct page *loop_page, unsigned loop_off,
-		    int size, sector_t IV)
-{
-	struct crypto_tfm *tfm = (struct crypto_tfm *) lo->key_data;
-	if(tfm->crt_cipher.cit_mode == CRYPTO_TFM_MODE_ECB)
-	{
-		lo->transfer = cryptoloop_transfer_ecb;
-		return cryptoloop_transfer_ecb(lo, cmd, raw_page, raw_off,
-					       loop_page, loop_off, size, IV);
-	}	
-	if(tfm->crt_cipher.cit_mode == CRYPTO_TFM_MODE_CBC)
-	{	
-		lo->transfer = cryptoloop_transfer_cbc;
-		return cryptoloop_transfer_cbc(lo, cmd, raw_page, raw_off,
-					       loop_page, loop_off, size, IV);
-	}
-	
-	/*  This is not supposed to happen */
-
-	printk( KERN_ERR "cryptoloop: unsupported cipher mode in cryptoloop_transfer!\n");
-	return -EINVAL;
-}
-
-static int
 cryptoloop_ioctl(struct loop_device *lo, int cmd, unsigned long arg)
 {
 	return -EINVAL;
@@ -229,9 +177,9 @@ cryptoloop_ioctl(struct loop_device *lo,
 static int
 cryptoloop_release(struct loop_device *lo)
 {
-	struct crypto_tfm *tfm = (struct crypto_tfm *) lo->key_data;
+	struct crypto_blkcipher *tfm = lo->key_data;
 	if (tfm != NULL) {
-		crypto_free_tfm(tfm);
+		crypto_free_blkcipher(tfm);
 		lo->key_data = NULL;
 		return 0;
 	}
