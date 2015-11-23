From: Dave Watson <davejwatson@fb.com>
Subject: [RFC PATCH 1/2] Crypto support aesni rfc5288
Date: Mon, 23 Nov 2015 09:42:44 -0800
Message-ID: <ca4759f2bfc18d1e4e56b514bba549fd1355d17b.1448299690.git.davejwatson@fb.com>
References: <cover.1448299690.git.davejwatson@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	<linux-crypto@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1448299690.git.davejwatson@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support rfc5288 using intel aesni routines.  See also rfc5246.

AAD length is 13 bytes padded out to 16. Padding bytes have to be
passed in in scatterlist currently, which probably isn't quite the
right fix.

The assoclen checks were moved to the individual rfc stubs, and the
common routines support all assoc lengths.

---
 arch/x86/crypto/aesni-intel_asm.S        |   6 ++
 arch/x86/crypto/aesni-intel_avx-x86_64.S |   4 ++
 arch/x86/crypto/aesni-intel_glue.c       | 105 +++++++++++++++++++++++--------
 3 files changed, 88 insertions(+), 27 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_asm.S b/arch/x86/crypto/aesni-intel_asm.S
index 6bd2c6c..49667c4 100644
--- a/arch/x86/crypto/aesni-intel_asm.S
+++ b/arch/x86/crypto/aesni-intel_asm.S
@@ -228,6 +228,9 @@ XMM2 XMM3 XMM4 XMMDst TMP6 TMP7 i i_seq operation
         MOVADQ     SHUF_MASK(%rip), %xmm14
 	mov	   arg7, %r10           # %r10 = AAD
 	mov	   arg8, %r12           # %r12 = aadLen
+	add        $3, %r12
+	and        $~3, %r12
+
 	mov	   %r12, %r11
 	pxor	   %xmm\i, %xmm\i

@@ -453,6 +456,9 @@ XMM2 XMM3 XMM4 XMMDst TMP6 TMP7 i i_seq operation
         MOVADQ     SHUF_MASK(%rip), %xmm14
 	mov	   arg7, %r10           # %r10 = AAD
 	mov	   arg8, %r12           # %r12 = aadLen
+	add        $3, %r12
+	and        $~3, %r12
+
 	mov	   %r12, %r11
 	pxor	   %xmm\i, %xmm\i
 _get_AAD_loop\num_initial_blocks\operation:
diff --git a/arch/x86/crypto/aesni-intel_avx-x86_64.S b/arch/x86/crypto/aesni-intel_avx-x86_64.S
index 522ab68..0756e4a 100644
--- a/arch/x86/crypto/aesni-intel_avx-x86_64.S
+++ b/arch/x86/crypto/aesni-intel_avx-x86_64.S
@@ -360,6 +360,8 @@ VARIABLE_OFFSET = 16*8

         mov     arg6, %r10                      # r10 = AAD
         mov     arg7, %r12                      # r12 = aadLen
+        add     $3, %r12
+        and     $~3, %r12


         mov     %r12, %r11
@@ -1619,6 +1621,8 @@ ENDPROC(aesni_gcm_dec_avx_gen2)

         mov     arg6, %r10                       # r10 = AAD
         mov     arg7, %r12                       # r12 = aadLen
+        add     $3, %r12
+        and     $~3, %r12


         mov     %r12, %r11
diff --git a/arch/x86/crypto/aesni-intel_glue.c b/arch/x86/crypto/aesni-intel_glue.c
index 3633ad6..00a42ca 100644
--- a/arch/x86/crypto/aesni-intel_glue.c
+++ b/arch/x86/crypto/aesni-intel_glue.c
@@ -949,12 +949,7 @@ static int helper_rfc4106_encrypt(struct aead_request *req)
 	struct scatter_walk src_sg_walk;
 	struct scatter_walk dst_sg_walk;
 	unsigned int i;
-
-	/* Assuming we are supporting rfc4106 64-bit extended */
-	/* sequence numbers We need to have the AAD length equal */
-	/* to 16 or 20 bytes */
-	if (unlikely(req->assoclen != 16 && req->assoclen != 20))
-		return -EINVAL;
+	unsigned int padded_assoclen = (req->assoclen + 3) & ~3;

 	/* IV below built */
 	for (i = 0; i < 4; i++)
@@ -970,21 +965,21 @@ static int helper_rfc4106_encrypt(struct aead_request *req)
 		one_entry_in_sg = 1;
 		scatterwalk_start(&src_sg_walk, req->src);
 		assoc = scatterwalk_map(&src_sg_walk);
-		src = assoc + req->assoclen;
+		src = assoc + padded_assoclen;
 		dst = src;
 		if (unlikely(req->src != req->dst)) {
 			scatterwalk_start(&dst_sg_walk, req->dst);
-			dst = scatterwalk_map(&dst_sg_walk) + req->assoclen;
+			dst = scatterwalk_map(&dst_sg_walk) + padded_assoclen;
 		}
 	} else {
 		/* Allocate memory for src, dst, assoc */
-		assoc = kmalloc(req->cryptlen + auth_tag_len + req->assoclen,
+		assoc = kmalloc(req->cryptlen + auth_tag_len + padded_assoclen,
 			GFP_ATOMIC);
 		if (unlikely(!assoc))
 			return -ENOMEM;
 		scatterwalk_map_and_copy(assoc, req->src, 0,
-					 req->assoclen + req->cryptlen, 0);
-		src = assoc + req->assoclen;
+					 padded_assoclen + req->cryptlen, 0);
+		src = assoc + padded_assoclen;
 		dst = src;
 	}

@@ -998,7 +993,7 @@ static int helper_rfc4106_encrypt(struct aead_request *req)
 	 * back to the packet. */
 	if (one_entry_in_sg) {
 		if (unlikely(req->src != req->dst)) {
-			scatterwalk_unmap(dst - req->assoclen);
+			scatterwalk_unmap(dst - padded_assoclen);
 			scatterwalk_advance(&dst_sg_walk, req->dst->length);
 			scatterwalk_done(&dst_sg_walk, 1, 0);
 		}
@@ -1006,7 +1001,7 @@ static int helper_rfc4106_encrypt(struct aead_request *req)
 		scatterwalk_advance(&src_sg_walk, req->src->length);
 		scatterwalk_done(&src_sg_walk, req->src == req->dst, 0);
 	} else {
-		scatterwalk_map_and_copy(dst, req->dst, req->assoclen,
+		scatterwalk_map_and_copy(dst, req->dst, padded_assoclen,
 					 req->cryptlen + auth_tag_len, 1);
 		kfree(assoc);
 	}
@@ -1029,13 +1024,7 @@ static int helper_rfc4106_decrypt(struct aead_request *req)
 	struct scatter_walk src_sg_walk;
 	struct scatter_walk dst_sg_walk;
 	unsigned int i;
-
-	if (unlikely(req->assoclen != 16 && req->assoclen != 20))
-		return -EINVAL;
-
-	/* Assuming we are supporting rfc4106 64-bit extended */
-	/* sequence numbers We need to have the AAD length */
-	/* equal to 16 or 20 bytes */
+	unsigned int padded_assoclen = (req->assoclen + 3) & ~3;

 	tempCipherLen = (unsigned long)(req->cryptlen - auth_tag_len);
 	/* IV below built */
@@ -1052,21 +1041,21 @@ static int helper_rfc4106_decrypt(struct aead_request *req)
 		one_entry_in_sg = 1;
 		scatterwalk_start(&src_sg_walk, req->src);
 		assoc = scatterwalk_map(&src_sg_walk);
-		src = assoc + req->assoclen;
+		src = assoc + padded_assoclen;
 		dst = src;
 		if (unlikely(req->src != req->dst)) {
 			scatterwalk_start(&dst_sg_walk, req->dst);
-			dst = scatterwalk_map(&dst_sg_walk) + req->assoclen;
+			dst = scatterwalk_map(&dst_sg_walk) + padded_assoclen;
 		}

 	} else {
 		/* Allocate memory for src, dst, assoc */
-		assoc = kmalloc(req->cryptlen + req->assoclen, GFP_ATOMIC);
+		assoc = kmalloc(req->cryptlen + padded_assoclen, GFP_ATOMIC);
 		if (!assoc)
 			return -ENOMEM;
 		scatterwalk_map_and_copy(assoc, req->src, 0,
-					 req->assoclen + req->cryptlen, 0);
-		src = assoc + req->assoclen;
+					 padded_assoclen + req->cryptlen, 0);
+		src = assoc + padded_assoclen;
 		dst = src;
 	}

@@ -1082,7 +1071,7 @@ static int helper_rfc4106_decrypt(struct aead_request *req)

 	if (one_entry_in_sg) {
 		if (unlikely(req->src != req->dst)) {
-			scatterwalk_unmap(dst - req->assoclen);
+			scatterwalk_unmap(dst - padded_assoclen);
 			scatterwalk_advance(&dst_sg_walk, req->dst->length);
 			scatterwalk_done(&dst_sg_walk, 1, 0);
 		}
@@ -1090,7 +1079,7 @@ static int helper_rfc4106_decrypt(struct aead_request *req)
 		scatterwalk_advance(&src_sg_walk, req->src->length);
 		scatterwalk_done(&src_sg_walk, req->src == req->dst, 0);
 	} else {
-		scatterwalk_map_and_copy(dst, req->dst, req->assoclen,
+		scatterwalk_map_and_copy(dst, req->dst, padded_assoclen,
 					 tempCipherLen, 1);
 		kfree(assoc);
 	}
@@ -1107,6 +1096,12 @@ static int rfc4106_encrypt(struct aead_request *req)
 				  cryptd_aead_child(cryptd_tfm) :
 				  &cryptd_tfm->base);

+	/* Assuming we are supporting rfc4106 64-bit extended */
+	/* sequence numbers We need to have the AAD length */
+	/* equal to 16 or 20 bytes */
+	if (unlikely(req->assoclen != 16 && req->assoclen != 20))
+		return -EINVAL;
+
 	return crypto_aead_encrypt(req);
 }

@@ -1120,6 +1115,44 @@ static int rfc4106_decrypt(struct aead_request *req)
 				  cryptd_aead_child(cryptd_tfm) :
 				  &cryptd_tfm->base);

+	/* Assuming we are supporting rfc4106 64-bit extended */
+	/* sequence numbers We need to have the AAD length */
+	/* equal to 16 or 20 bytes */
+	if (unlikely(req->assoclen != 16 && req->assoclen != 20))
+		return -EINVAL;
+
+	return crypto_aead_decrypt(req);
+}
+
+static int rfc5288_encrypt(struct aead_request *req)
+{
+	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
+	struct cryptd_aead **ctx = crypto_aead_ctx(tfm);
+	struct cryptd_aead *cryptd_tfm = *ctx;
+
+	if (unlikely(req->assoclen != 21))
+		return -EINVAL;
+
+	aead_request_set_tfm(req, irq_fpu_usable() ?
+				  cryptd_aead_child(cryptd_tfm) :
+				  &cryptd_tfm->base);
+
+	return crypto_aead_encrypt(req);
+}
+
+static int rfc5288_decrypt(struct aead_request *req)
+{
+	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
+	struct cryptd_aead **ctx = crypto_aead_ctx(tfm);
+	struct cryptd_aead *cryptd_tfm = *ctx;
+
+	if (unlikely(req->assoclen != 21))
+		return -EINVAL;
+
+	aead_request_set_tfm(req, irq_fpu_usable() ?
+				  cryptd_aead_child(cryptd_tfm) :
+				  &cryptd_tfm->base);
+
 	return crypto_aead_decrypt(req);
 }
 #endif
@@ -1442,6 +1475,24 @@ static struct aead_alg aesni_aead_algs[] = { {
 		.cra_ctxsize		= sizeof(struct cryptd_aead *),
 		.cra_module		= THIS_MODULE,
 	},
+}, {
+	.init			= rfc4106_init,
+	.exit			= rfc4106_exit,
+	.setkey			= rfc4106_set_key,
+	.setauthsize		= rfc4106_set_authsize,
+	.encrypt		= rfc5288_encrypt,
+	.decrypt		= rfc5288_decrypt,
+	.ivsize			= 8,
+	.maxauthsize		= 16,
+	.base = {
+		.cra_name		= "rfc5288(gcm(aes))",
+		.cra_driver_name	= "rfc5288-gcm-aesni",
+		.cra_priority		= 400,
+		.cra_flags		= CRYPTO_ALG_ASYNC,
+		.cra_blocksize		= 1,
+		.cra_ctxsize		= sizeof(struct cryptd_aead *),
+		.cra_module		= THIS_MODULE,
+	},
 } };
 #else
 static struct aead_alg aesni_aead_algs[0];
--
2.4.6
