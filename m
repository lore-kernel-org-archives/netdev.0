From: "George Spelvin" <linux-+7tBnqSOmQ59SlIZoIAWRdHuzzzSOjJt@public.gmane.org>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack crash, etc)
Date: 28 Jun 2016 08:37:43 -0400
Message-ID: <20160628123743.7960.qmail@ns.sciencehorizons.net>
Cc: linux-+7tBnqSOmQ59SlIZoIAWRdHuzzzSOjJt@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Just a note, crypto/cts.c also does a lot of sg_set_buf() in stack buffers.

I have a local patch (appended, if anyone wants) to reduce the wasteful
amount of buffer space it uses (from 7 to 3 blocks on encrypt, from
6 to 3 blocks on decrypt), but it would take some rework to convert to
crypto_cipher_encrypt_one() or avoid stack buffers entirely.

commit c0aa0ae38dc6115b378939c5483ba6c7eb65d92a
Author: George Spelvin <linux-+7tBnqSOmQ59SlIZoIAWRdHuzzzSOjJt@public.gmane.org>
Date:   Sat Oct 10 17:26:08 2015 -0400

    crypto: cts - Reduce internal buffer usage
    
    It only takes a 3-block temporary buffer to handle all the tricky
    CTS cases.  Encryption could in theory be done with two, but at a cost
    in complexity.
    
    But it's still a saving from the previous six blocks on the stack.
    
    One issue I'm uncertain of and I'd like clarification on: to simplify
    the cts_cbc_{en,de}crypt calls, I pass in the lcldesc structure which
    contains the ctx->child transform rather than the parent one.  I'm
    assuming the block sizes are guaranteed to be the same (they're set up
    in crypto_cts_alloc by copying), but I haven't been able to prove it to
    my satisfaction.
    
    Signed-off-by: George Spelvin <linux-+7tBnqSOmQ59SlIZoIAWRdHuzzzSOjJt@public.gmane.org>

diff --git a/crypto/cts.c b/crypto/cts.c
index e467ec0ac..e24d2e15 100644
--- a/crypto/cts.c
+++ b/crypto/cts.c
@@ -70,54 +70,44 @@ static int crypto_cts_setkey(struct crypto_tfm *parent, const u8 *key,
 	return err;
 }
 
-static int cts_cbc_encrypt(struct crypto_cts_ctx *ctx,
-			   struct blkcipher_desc *desc,
+/*
+ * The final CTS encryption is just like CBC encryption except that:
+ * - the last plaintext block is zero-padded,
+ * - the second-last ciphertext block is trimmed, and
+ * - the last (complete) block of ciphertext is output before the
+ *   (truncated) second-last one.
+ */
+static int cts_cbc_encrypt(struct blkcipher_desc *lcldesc,
 			   struct scatterlist *dst,
 			   struct scatterlist *src,
 			   unsigned int offset,
 			   unsigned int nbytes)
 {
-	int bsize = crypto_blkcipher_blocksize(desc->tfm);
-	u8 tmp[bsize], tmp2[bsize];
-	struct blkcipher_desc lcldesc;
-	struct scatterlist sgsrc[1], sgdst[1];
+	int bsize = crypto_blkcipher_blocksize(lcldesc->tfm);
+	u8 tmp[3*bsize] __aligned(8);
+	struct scatterlist sgsrc[1], sgdst[2];
 	int lastn = nbytes - bsize;
-	u8 iv[bsize];
-	u8 s[bsize * 2], d[bsize * 2];
 	int err;
 
-	if (lastn < 0)
+	if (lastn <= 0)
 		return -EINVAL;
 
-	sg_init_table(sgsrc, 1);
-	sg_init_table(sgdst, 1);
-
-	memset(s, 0, sizeof(s));
-	scatterwalk_map_and_copy(s, src, offset, nbytes, 0);
-
-	memcpy(iv, desc->info, bsize);
-
-	lcldesc.tfm = ctx->child;
-	lcldesc.info = iv;
-	lcldesc.flags = desc->flags;
-
-	sg_set_buf(&sgsrc[0], s, bsize);
-	sg_set_buf(&sgdst[0], tmp, bsize);
-	err = crypto_blkcipher_encrypt_iv(&lcldesc, sgdst, sgsrc, bsize);
-
-	memcpy(d + bsize, tmp, lastn);
-
-	lcldesc.info = tmp;
-
-	sg_set_buf(&sgsrc[0], s + bsize, bsize);
-	sg_set_buf(&sgdst[0], tmp2, bsize);
-	err = crypto_blkcipher_encrypt_iv(&lcldesc, sgdst, sgsrc, bsize);
-
-	memcpy(d, tmp2, bsize);
-
-	scatterwalk_map_and_copy(d, dst, offset, nbytes, 1);
-
-	memcpy(desc->info, tmp2, bsize);
+	/* Copy the input to a temporary buffer; tmp = xxx, P[n-1], P[n] */
+	memset(tmp+2*bsize, 0, bsize);
+	scatterwalk_map_and_copy(tmp+bsize, src, offset, nbytes, 0);
+
+	sg_init_one(sgsrc, tmp+bsize, 2*bsize);
+	/* Initialize dst specially to do the rearrangement for us */
+	sg_init_table(sgdst, 2);
+	sg_set_buf(sgdst+0, tmp+bsize, bsize);
+	sg_set_buf(sgdst+1, tmp,       bsize);
+
+	/* CBC-encrypt in place the two blocks; tmp = C[n], C[n-1], P[n] */
+	err = crypto_blkcipher_encrypt_iv(lcldesc, sgdst, sgsrc, 2*bsize);
+
+	/* Copy beginning of tmp to the output */
+	scatterwalk_map_and_copy(tmp, dst, offset, nbytes, 1);
+	memzero_explicit(tmp, sizeof(tmp));
 
 	return err;
 }
@@ -126,8 +116,8 @@ static int crypto_cts_encrypt(struct blkcipher_desc *desc,
 			      struct scatterlist *dst, struct scatterlist *src,
 			      unsigned int nbytes)
 {
-	struct crypto_cts_ctx *ctx = crypto_blkcipher_ctx(desc->tfm);
 	int bsize = crypto_blkcipher_blocksize(desc->tfm);
+	struct crypto_cts_ctx *ctx = crypto_blkcipher_ctx(desc->tfm);
 	int tot_blocks = (nbytes + bsize - 1) / bsize;
 	int cbc_blocks = tot_blocks > 2 ? tot_blocks - 2 : 0;
 	struct blkcipher_desc lcldesc;
@@ -140,14 +130,14 @@ static int crypto_cts_encrypt(struct blkcipher_desc *desc,
 	if (tot_blocks == 1) {
 		err = crypto_blkcipher_encrypt_iv(&lcldesc, dst, src, bsize);
 	} else if (nbytes <= bsize * 2) {
-		err = cts_cbc_encrypt(ctx, desc, dst, src, 0, nbytes);
+		err = cts_cbc_encrypt(&lcldesc, dst, src, 0, nbytes);
 	} else {
 		/* do normal function for tot_blocks - 2 */
 		err = crypto_blkcipher_encrypt_iv(&lcldesc, dst, src,
 							cbc_blocks * bsize);
 		if (err == 0) {
 			/* do cts for final two blocks */
-			err = cts_cbc_encrypt(ctx, desc, dst, src,
+			err = cts_cbc_encrypt(&lcldesc, dst, src,
 						cbc_blocks * bsize,
 						nbytes - (cbc_blocks * bsize));
 		}
@@ -156,64 +146,68 @@ static int crypto_cts_encrypt(struct blkcipher_desc *desc,
 	return err;
 }
 
-static int cts_cbc_decrypt(struct crypto_cts_ctx *ctx,
-			   struct blkcipher_desc *desc,
+/*
+ * Decrypting the final two blocks in CTS is a bit trickier;
+ * it has to be done in two separate steps.
+ *
+ * The last two blocks of the CTS ciphertext are (first) the
+ * last block C[n] of the equivalent zero-padded CBC encryption,
+ * followed by a truncated version of the second-last block C[n-1].
+ *
+ * Expressed in terms of CBC decryption (P[i] = decrypt(C[i]) ^ IV),
+ * CTS decryption can be expressed as:
+ * - Pad C[n-1] with zeros to get an IV for C[n].
+ * - CBC-decrypt C[n] to get an intermediate plaintext buffer P.
+ * - P[n] is the prefix of P (1..bsize bytes).
+ * - The suffix of P (0..bzize-1 bytes) is the missing part of C[n-1].
+ * - CBC-decrypt that C[n-1], with the incoming IV, to recover P[n-1].
+ */
+static int cts_cbc_decrypt(struct blkcipher_desc *lcldesc,
 			   struct scatterlist *dst,
 			   struct scatterlist *src,
 			   unsigned int offset,
 			   unsigned int nbytes)
 {
-	int bsize = crypto_blkcipher_blocksize(desc->tfm);
-	u8 tmp[bsize];
-	struct blkcipher_desc lcldesc;
+	int bsize = crypto_blkcipher_blocksize(lcldesc->tfm);
+	u8 tmp[3*bsize] __aligned(8);
 	struct scatterlist sgsrc[1], sgdst[1];
 	int lastn = nbytes - bsize;
-	u8 iv[bsize];
-	u8 s[bsize * 2], d[bsize * 2];
+	u8 *orig_iv;
 	int err;
 
-	if (lastn < 0)
+	if (lastn <= 0)
 		return -EINVAL;
 
-	sg_init_table(sgsrc, 1);
-	sg_init_table(sgdst, 1);
+	/* 1. Copy source into tmp, zero-padded; tmp = C[n], C[n-1]+0, xxx */
+	memset(tmp+bsize, 0, bsize);
+	scatterwalk_map_and_copy(tmp, src, offset, nbytes, 0);
 
-	scatterwalk_map_and_copy(s, src, offset, nbytes, 0);
-
-	lcldesc.tfm = ctx->child;
-	lcldesc.info = iv;
-	lcldesc.flags = desc->flags;
-
-	/* 1. Decrypt Cn-1 (s) to create Dn (tmp)*/
-	memset(iv, 0, sizeof(iv));
-	sg_set_buf(&sgsrc[0], s, bsize);
-	sg_set_buf(&sgdst[0], tmp, bsize);
-	err = crypto_blkcipher_decrypt_iv(&lcldesc, sgdst, sgsrc, bsize);
+	/* 2. Decrypt C[n] into P; tmp = C[n], C[n-1]+0, P */
+	sg_init_one(sgsrc, tmp, bsize);
+	sg_init_one(sgdst, tmp+2*bsize, bsize);
+	orig_iv = lcldesc->info;
+	lcldesc->info = tmp+bsize;	/* IV for decryption: padded C[n-1] */
+	err = crypto_blkcipher_decrypt_iv(lcldesc, sgdst, sgsrc, bsize);
 	if (err)
-		return err;
-	/* 2. Pad Cn with zeros at the end to create C of length BB */
-	memset(iv, 0, sizeof(iv));
-	memcpy(iv, s + bsize, lastn);
-	/* 3. Exclusive-or Dn (tmp) with C (iv) to create Xn (tmp) */
-	crypto_xor(tmp, iv, bsize);
-	/* 4. Select the first Ln bytes of Xn (tmp) to create Pn */
-	memcpy(d + bsize, tmp, lastn);
+		goto cleanup;
 
-	/* 5. Append the tail (BB - Ln) bytes of Xn (tmp) to Cn to create En */
-	memcpy(s + bsize + lastn, tmp + lastn, bsize - lastn);
-	/* 6. Decrypt En to create Pn-1 */
-	memzero_explicit(iv, sizeof(iv));
+	/* 3. Copy tail of P to C[n-1]; tmp = C[n], C[n-1], P */
+	memcpy(tmp+bsize + lastn, tmp+2*bsize + lastn, bsize - lastn);
 
-	sg_set_buf(&sgsrc[0], s + bsize, bsize);
-	sg_set_buf(&sgdst[0], d, bsize);
-	err = crypto_blkcipher_decrypt_iv(&lcldesc, sgdst, sgsrc, bsize);
+	/* 4. Decrypt C[n-1] in place; tmp = C[n], P[n-1], P */
+	sg_set_buf(sgsrc, tmp + bsize, bsize);
+	sg_set_buf(sgdst, tmp + bsize, bsize);
+	lcldesc->info = orig_iv;
+	err = crypto_blkcipher_decrypt_iv(lcldesc, sgdst, sgsrc, bsize);
 
-	/* XOR with previous block */
-	crypto_xor(d, desc->info, bsize);
+	/* 5. Copy P[n-1] and head of P to output */
+	scatterwalk_map_and_copy(tmp+bsize, dst, offset, nbytes, 1);
 
-	scatterwalk_map_and_copy(d, dst, offset, nbytes, 1);
+	/* C[n] is the continuing IV (if anyone cares) */
+	memcpy(lcldesc->info, tmp, bsize);
 
-	memcpy(desc->info, s, bsize);
+cleanup:
+	memzero_explicit(tmp, sizeof(tmp));
 	return err;
 }
 
@@ -235,14 +229,14 @@ static int crypto_cts_decrypt(struct blkcipher_desc *desc,
 	if (tot_blocks == 1) {
 		err = crypto_blkcipher_decrypt_iv(&lcldesc, dst, src, bsize);
 	} else if (nbytes <= bsize * 2) {
-		err = cts_cbc_decrypt(ctx, desc, dst, src, 0, nbytes);
+		err = cts_cbc_decrypt(&lcldesc, dst, src, 0, nbytes);
 	} else {
 		/* do normal function for tot_blocks - 2 */
 		err = crypto_blkcipher_decrypt_iv(&lcldesc, dst, src,
 							cbc_blocks * bsize);
 		if (err == 0) {
 			/* do cts for final two blocks */
-			err = cts_cbc_decrypt(ctx, desc, dst, src,
+			err = cts_cbc_decrypt(&lcldesc, dst, src,
 						cbc_blocks * bsize,
 						nbytes - (cbc_blocks * bsize));
 		}
