From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 13/16] [SUNRPC] GSS: Use block ciphers where applicable
Date: Sun, 13 Aug 2006 22:20:22 +1000
Message-ID: <E1GCEx4-0004gS-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:17161 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751097AbWHMMUe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:34 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SUNRPC] GSS: Use block ciphers where applicable

This patch converts SUNRPC/GSS to use the new block cipher type where
applicable.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/sunrpc/gss_krb5.h       |   19 +++++------
 include/linux/sunrpc/gss_spkm3.h      |    4 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   57 +++++++++++++++++++---------------
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   22 ++++++-------
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |    4 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    4 +-
 net/sunrpc/auth_gss/gss_spkm3_mech.c  |   27 +++++++---------
 7 files changed, 72 insertions(+), 65 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -46,8 +46,8 @@ struct krb5_ctx {
 	unsigned char		seed[16];
 	int			signalg;
 	int			sealalg;
-	struct crypto_tfm	*enc;
-	struct crypto_tfm	*seq;
+	struct crypto_blkcipher	*enc;
+	struct crypto_blkcipher	*seq;
 	s32			endtime;
 	u32			seq_send;
 	struct xdr_netobj	mech_used;
@@ -136,26 +136,27 @@ gss_unwrap_kerberos(struct gss_ctx *ctx_
 
 
 u32
-krb5_encrypt(struct crypto_tfm * key,
+krb5_encrypt(struct crypto_blkcipher *key,
 	     void *iv, void *in, void *out, int length);
 
 u32
-krb5_decrypt(struct crypto_tfm * key,
+krb5_decrypt(struct crypto_blkcipher *key,
 	     void *iv, void *in, void *out, int length); 
 
 int
-gss_encrypt_xdr_buf(struct crypto_tfm *tfm, struct xdr_buf *outbuf, int offset,
-		struct page **pages);
+gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *outbuf,
+		    int offset, struct page **pages);
 
 int
-gss_decrypt_xdr_buf(struct crypto_tfm *tfm, struct xdr_buf *inbuf, int offset);
+gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *inbuf,
+		    int offset);
 
 s32
-krb5_make_seq_num(struct crypto_tfm * key,
+krb5_make_seq_num(struct crypto_blkcipher *key,
 		int direction,
 		s32 seqnum, unsigned char *cksum, unsigned char *buf);
 
 s32
-krb5_get_seq_num(struct crypto_tfm * key,
+krb5_get_seq_num(struct crypto_blkcipher *key,
 	       unsigned char *cksum,
 	       unsigned char *buf, int *direction, s32 * seqnum);
diff --git a/include/linux/sunrpc/gss_spkm3.h b/include/linux/sunrpc/gss_spkm3.h
--- a/include/linux/sunrpc/gss_spkm3.h
+++ b/include/linux/sunrpc/gss_spkm3.h
@@ -19,9 +19,9 @@ struct spkm3_ctx {
 	unsigned int		req_flags ;
 	struct xdr_netobj	share_key;
 	int			conf_alg;
-	struct crypto_tfm*	derived_conf_key;
+	struct crypto_blkcipher	*derived_conf_key;
 	int			intg_alg;
-	struct crypto_tfm*	derived_integ_key;
+	struct crypto_blkcipher	*derived_integ_key;
 	int			keyestb_alg;   /* alg used to get share_key */
 	int			owf_alg;   /* one way function */
 };
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -49,7 +49,7 @@
 
 u32
 krb5_encrypt(
-	struct crypto_tfm *tfm,
+	struct crypto_blkcipher *tfm,
 	void * iv,
 	void * in,
 	void * out,
@@ -58,26 +58,27 @@ krb5_encrypt(
 	u32 ret = -EINVAL;
         struct scatterlist sg[1];
 	u8 local_iv[16] = {0};
+	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
 
 	dprintk("RPC:      krb5_encrypt: input data:\n");
 	print_hexl((u32 *)in, length, 0);
 
-	if (length % crypto_tfm_alg_blocksize(tfm) != 0)
+	if (length % crypto_blkcipher_blocksize(tfm) != 0)
 		goto out;
 
-	if (crypto_tfm_alg_ivsize(tfm) > 16) {
+	if (crypto_blkcipher_ivsize(tfm) > 16) {
 		dprintk("RPC:      gss_k5encrypt: tfm iv size to large %d\n",
-		         crypto_tfm_alg_ivsize(tfm));
+		         crypto_blkcipher_ivsize(tfm));
 		goto out;
 	}
 
 	if (iv)
-		memcpy(local_iv, iv, crypto_tfm_alg_ivsize(tfm));
+		memcpy(local_iv, iv, crypto_blkcipher_ivsize(tfm));
 
 	memcpy(out, in, length);
 	sg_set_buf(sg, out, length);
 
-	ret = crypto_cipher_encrypt_iv(tfm, sg, sg, length, local_iv);
+	ret = crypto_blkcipher_encrypt_iv(&desc, sg, sg, length);
 
 	dprintk("RPC:      krb5_encrypt: output data:\n");
 	print_hexl((u32 *)out, length, 0);
@@ -90,7 +91,7 @@ EXPORT_SYMBOL(krb5_encrypt);
 
 u32
 krb5_decrypt(
-     struct crypto_tfm *tfm,
+     struct crypto_blkcipher *tfm,
      void * iv,
      void * in,
      void * out,
@@ -99,25 +100,26 @@ krb5_decrypt(
 	u32 ret = -EINVAL;
 	struct scatterlist sg[1];
 	u8 local_iv[16] = {0};
+	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
 
 	dprintk("RPC:      krb5_decrypt: input data:\n");
 	print_hexl((u32 *)in, length, 0);
 
-	if (length % crypto_tfm_alg_blocksize(tfm) != 0)
+	if (length % crypto_blkcipher_blocksize(tfm) != 0)
 		goto out;
 
-	if (crypto_tfm_alg_ivsize(tfm) > 16) {
+	if (crypto_blkcipher_ivsize(tfm) > 16) {
 		dprintk("RPC:      gss_k5decrypt: tfm iv size to large %d\n",
-			crypto_tfm_alg_ivsize(tfm));
+			crypto_blkcipher_ivsize(tfm));
 		goto out;
 	}
 	if (iv)
-		memcpy(local_iv,iv, crypto_tfm_alg_ivsize(tfm));
+		memcpy(local_iv,iv, crypto_blkcipher_ivsize(tfm));
 
 	memcpy(out, in, length);
 	sg_set_buf(sg, out, length);
 
-	ret = crypto_cipher_decrypt_iv(tfm, sg, sg, length, local_iv);
+	ret = crypto_blkcipher_decrypt_iv(&desc, sg, sg, length);
 
 	dprintk("RPC:      krb5_decrypt: output_data:\n");
 	print_hexl((u32 *)out, length, 0);
@@ -240,7 +242,7 @@ EXPORT_SYMBOL(make_checksum);
 
 struct encryptor_desc {
 	u8 iv[8]; /* XXX hard-coded blocksize */
-	struct crypto_tfm *tfm;
+	struct blkcipher_desc desc;
 	int pos;
 	struct xdr_buf *outbuf;
 	struct page **pages;
@@ -285,8 +287,8 @@ encryptor(struct scatterlist *sg, void *
 	if (thislen == 0)
 		return 0;
 
-	ret = crypto_cipher_encrypt_iv(desc->tfm, desc->outfrags, desc->infrags,
-					thislen, desc->iv);
+	ret = crypto_blkcipher_encrypt_iv(&desc->desc, desc->outfrags,
+					  desc->infrags, thislen);
 	if (ret)
 		return ret;
 	if (fraglen) {
@@ -305,16 +307,18 @@ encryptor(struct scatterlist *sg, void *
 }
 
 int
-gss_encrypt_xdr_buf(struct crypto_tfm *tfm, struct xdr_buf *buf, int offset,
-		struct page **pages)
+gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
+		    int offset, struct page **pages)
 {
 	int ret;
 	struct encryptor_desc desc;
 
-	BUG_ON((buf->len - offset) % crypto_tfm_alg_blocksize(tfm) != 0);
+	BUG_ON((buf->len - offset) % crypto_blkcipher_blocksize(tfm) != 0);
 
 	memset(desc.iv, 0, sizeof(desc.iv));
-	desc.tfm = tfm;
+	desc.desc.tfm = tfm;
+	desc.desc.info = desc.iv;
+	desc.desc.flags = 0;
 	desc.pos = offset;
 	desc.outbuf = buf;
 	desc.pages = pages;
@@ -329,7 +333,7 @@ EXPORT_SYMBOL(gss_encrypt_xdr_buf);
 
 struct decryptor_desc {
 	u8 iv[8]; /* XXX hard-coded blocksize */
-	struct crypto_tfm *tfm;
+	struct blkcipher_desc desc;
 	struct scatterlist frags[4];
 	int fragno;
 	int fraglen;
@@ -355,8 +359,8 @@ decryptor(struct scatterlist *sg, void *
 	if (thislen == 0)
 		return 0;
 
-	ret = crypto_cipher_decrypt_iv(desc->tfm, desc->frags, desc->frags,
-					thislen, desc->iv);
+	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
+					  desc->frags, thislen);
 	if (ret)
 		return ret;
 	if (fraglen) {
@@ -373,15 +377,18 @@ decryptor(struct scatterlist *sg, void *
 }
 
 int
-gss_decrypt_xdr_buf(struct crypto_tfm *tfm, struct xdr_buf *buf, int offset)
+gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
+		    int offset)
 {
 	struct decryptor_desc desc;
 
 	/* XXXJBF: */
-	BUG_ON((buf->len - offset) % crypto_tfm_alg_blocksize(tfm) != 0);
+	BUG_ON((buf->len - offset) % crypto_blkcipher_blocksize(tfm) != 0);
 
 	memset(desc.iv, 0, sizeof(desc.iv));
-	desc.tfm = tfm;
+	desc.desc.tfm = tfm;
+	desc.desc.info = desc.iv;
+	desc.desc.flags = 0;
 	desc.fragno = 0;
 	desc.fraglen = 0;
 	return process_xdr_buf(buf, offset, buf->len - offset, decryptor, &desc);
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -78,10 +78,10 @@ simple_get_netobj(const void *p, const v
 }
 
 static inline const void *
-get_key(const void *p, const void *end, struct crypto_tfm **res)
+get_key(const void *p, const void *end, struct crypto_blkcipher **res)
 {
 	struct xdr_netobj	key;
-	int			alg, alg_mode;
+	int			alg;
 	char			*alg_name;
 
 	p = simple_get_bytes(p, end, &alg, sizeof(alg));
@@ -93,18 +93,18 @@ get_key(const void *p, const void *end, 
 
 	switch (alg) {
 		case ENCTYPE_DES_CBC_RAW:
-			alg_name = "des";
-			alg_mode = CRYPTO_TFM_MODE_CBC;
+			alg_name = "cbc(des)";
 			break;
 		default:
 			printk("gss_kerberos_mech: unsupported algorithm %d\n", alg);
 			goto out_err_free_key;
 	}
-	if (!(*res = crypto_alloc_tfm(alg_name, alg_mode))) {
+	*res = crypto_alloc_blkcipher(alg_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(*res)) {
 		printk("gss_kerberos_mech: unable to initialize crypto algorithm %s\n", alg_name);
 		goto out_err_free_key;
 	}
-	if (crypto_cipher_setkey(*res, key.data, key.len)) {
+	if (crypto_blkcipher_setkey(*res, key.data, key.len)) {
 		printk("gss_kerberos_mech: error setting key for crypto algorithm %s\n", alg_name);
 		goto out_err_free_tfm;
 	}
@@ -113,7 +113,7 @@ get_key(const void *p, const void *end, 
 	return p;
 
 out_err_free_tfm:
-	crypto_free_tfm(*res);
+	crypto_free_blkcipher(*res);
 out_err_free_key:
 	kfree(key.data);
 	p = ERR_PTR(-EINVAL);
@@ -173,9 +173,9 @@ gss_import_sec_context_kerberos(const vo
 	return 0;
 
 out_err_free_key2:
-	crypto_free_tfm(ctx->seq);
+	crypto_free_blkcipher(ctx->seq);
 out_err_free_key1:
-	crypto_free_tfm(ctx->enc);
+	crypto_free_blkcipher(ctx->enc);
 out_err_free_mech:
 	kfree(ctx->mech_used.data);
 out_err_free_ctx:
@@ -188,8 +188,8 @@ static void
 gss_delete_sec_context_kerberos(void *internal_ctx) {
 	struct krb5_ctx *kctx = internal_ctx;
 
-	crypto_free_tfm(kctx->seq);
-	crypto_free_tfm(kctx->enc);
+	crypto_free_blkcipher(kctx->seq);
+	crypto_free_blkcipher(kctx->enc);
 	kfree(kctx->mech_used.data);
 	kfree(kctx);
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -41,7 +41,7 @@
 #endif
 
 s32
-krb5_make_seq_num(struct crypto_tfm *key,
+krb5_make_seq_num(struct crypto_blkcipher *key,
 		int direction,
 		s32 seqnum,
 		unsigned char *cksum, unsigned char *buf)
@@ -62,7 +62,7 @@ krb5_make_seq_num(struct crypto_tfm *key
 }
 
 s32
-krb5_get_seq_num(struct crypto_tfm *key,
+krb5_get_seq_num(struct crypto_blkcipher *key,
 	       unsigned char *cksum,
 	       unsigned char *buf,
 	       int *direction, s32 * seqnum)
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -149,7 +149,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, i
 		goto out_err;
 	}
 
-	blocksize = crypto_tfm_alg_blocksize(kctx->enc);
+	blocksize = crypto_blkcipher_blocksize(kctx->enc);
 	gss_krb5_add_padding(buf, offset, blocksize);
 	BUG_ON((buf->len - offset) % blocksize);
 	plainlen = blocksize + buf->len - offset;
@@ -346,7 +346,7 @@ gss_unwrap_kerberos(struct gss_ctx *ctx,
 	/* Copy the data back to the right position.  XXX: Would probably be
 	 * better to copy and encrypt at the same time. */
 
-	blocksize = crypto_tfm_alg_blocksize(kctx->enc);
+	blocksize = crypto_blkcipher_blocksize(kctx->enc);
 	data_start = ptr + 22 + blocksize;
 	orig_start = buf->head[0].iov_base + offset;
 	data_len = (buf->head[0].iov_base + buf->head[0].iov_len) - data_start;
diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
--- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_mech.c
@@ -83,10 +83,11 @@ simple_get_netobj(const void *p, const v
 }
 
 static inline const void *
-get_key(const void *p, const void *end, struct crypto_tfm **res, int *resalg)
+get_key(const void *p, const void *end, struct crypto_blkcipher **res,
+	int *resalg)
 {
 	struct xdr_netobj	key = { 0 };
-	int			alg_mode,setkey = 0;
+	int			setkey = 0;
 	char			*alg_name;
 
 	p = simple_get_bytes(p, end, resalg, sizeof(*resalg));
@@ -98,14 +99,12 @@ get_key(const void *p, const void *end, 
 
 	switch (*resalg) {
 		case NID_des_cbc:
-			alg_name = "des";
-			alg_mode = CRYPTO_TFM_MODE_CBC;
+			alg_name = "cbc(des)";
 			setkey = 1;
 			break;
 		case NID_cast5_cbc:
 			/* XXXX here in name only, not used */
-			alg_name = "cast5";
-			alg_mode = CRYPTO_TFM_MODE_CBC;
+			alg_name = "cbc(cast5)";
 			setkey = 0; /* XXX will need to set to 1 */
 			break;
 		case NID_md5:
@@ -113,19 +112,19 @@ get_key(const void *p, const void *end, 
 				dprintk("RPC: SPKM3 get_key: NID_md5 zero Key length\n");
 			}
 			alg_name = "md5";
-			alg_mode = 0;
 			setkey = 0;
 			break;
 		default:
 			dprintk("gss_spkm3_mech: unsupported algorithm %d\n", *resalg);
 			goto out_err_free_key;
 	}
-	if (!(*res = crypto_alloc_tfm(alg_name, alg_mode))) {
+	*res = crypto_alloc_blkcipher(alg_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(*res)) {
 		printk("gss_spkm3_mech: unable to initialize crypto algorthm %s\n", alg_name);
 		goto out_err_free_key;
 	}
 	if (setkey) {
-		if (crypto_cipher_setkey(*res, key.data, key.len)) {
+		if (crypto_blkcipher_setkey(*res, key.data, key.len)) {
 			printk("gss_spkm3_mech: error setting key for crypto algorthm %s\n", alg_name);
 			goto out_err_free_tfm;
 		}
@@ -136,7 +135,7 @@ get_key(const void *p, const void *end, 
 	return p;
 
 out_err_free_tfm:
-	crypto_free_tfm(*res);
+	crypto_free_blkcipher(*res);
 out_err_free_key:
 	if(key.len > 0)
 		kfree(key.data);
@@ -205,9 +204,9 @@ gss_import_sec_context_spkm3(const void 
 	return 0;
 
 out_err_free_key2:
-	crypto_free_tfm(ctx->derived_integ_key);
+	crypto_free_blkcipher(ctx->derived_integ_key);
 out_err_free_key1:
-	crypto_free_tfm(ctx->derived_conf_key);
+	crypto_free_blkcipher(ctx->derived_conf_key);
 out_err_free_s_key:
 	kfree(ctx->share_key.data);
 out_err_free_mech:
@@ -224,8 +223,8 @@ static void
 gss_delete_sec_context_spkm3(void *internal_ctx) {
 	struct spkm3_ctx *sctx = internal_ctx;
 
-	crypto_free_tfm(sctx->derived_integ_key);
-	crypto_free_tfm(sctx->derived_conf_key);
+	crypto_free_blkcipher(sctx->derived_integ_key);
+	crypto_free_blkcipher(sctx->derived_conf_key);
 	kfree(sctx->share_key.data);
 	kfree(sctx->mech_used.data);
 	kfree(sctx);
