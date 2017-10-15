From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v9 12/20] fscrypt: move to generic async completion
Date: Sun, 15 Oct 2017 10:19:57 +0100
Message-ID: <1508059209-25529-13-git-send-email-gilad@benyossef.com>
References: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
Cc: Ofir Drang <ofir.drang@arm.com>, linux-crypto@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org,
        netdev@vger.kernel.org, linux-ima-devel@lists.sourceforge.net,
        linux-ima-user@lists.sourceforge.net,
        linux-security-module@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>,
        David Howells <dhowells@redhat.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Gary Hook <gary.hook@amd.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Arnaud Ebalard <arno@natisbad.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Alasdair Kergon <agk@redhat.com>,
        Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
        Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.ka
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fscrypt starts several async. crypto ops and waiting for them to
complete. Move it over to generic code doing the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 fs/crypto/crypto.c          | 28 ++++------------------------
 fs/crypto/fname.c           | 36 ++++++------------------------------
 fs/crypto/fscrypt_private.h | 10 ----------
 fs/crypto/keyinfo.c         | 21 +++------------------
 4 files changed, 13 insertions(+), 82 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index c7835df..80a3cad 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -126,21 +126,6 @@ struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode, gfp_t gfp_flags)
 }
 EXPORT_SYMBOL(fscrypt_get_ctx);
 
-/**
- * page_crypt_complete() - completion callback for page crypto
- * @req: The asynchronous cipher request context
- * @res: The result of the cipher operation
- */
-static void page_crypt_complete(struct crypto_async_request *req, int res)
-{
-	struct fscrypt_completion_result *ecr = req->data;
-
-	if (res == -EINPROGRESS)
-		return;
-	ecr->res = res;
-	complete(&ecr->completion);
-}
-
 int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 			   u64 lblk_num, struct page *src_page,
 			   struct page *dest_page, unsigned int len,
@@ -151,7 +136,7 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 		u8 padding[FS_IV_SIZE - sizeof(__le64)];
 	} iv;
 	struct skcipher_request *req = NULL;
-	DECLARE_FS_COMPLETION_RESULT(ecr);
+	DECLARE_CRYPTO_WAIT(wait);
 	struct scatterlist dst, src;
 	struct fscrypt_info *ci = inode->i_crypt_info;
 	struct crypto_skcipher *tfm = ci->ci_ctfm;
@@ -179,7 +164,7 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 
 	skcipher_request_set_callback(
 		req, CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
-		page_crypt_complete, &ecr);
+		crypto_req_done, &wait);
 
 	sg_init_table(&dst, 1);
 	sg_set_page(&dst, dest_page, len, offs);
@@ -187,14 +172,9 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 	sg_set_page(&src, src_page, len, offs);
 	skcipher_request_set_crypt(req, &src, &dst, len, &iv);
 	if (rw == FS_DECRYPT)
-		res = crypto_skcipher_decrypt(req);
+		res = crypto_wait_req(crypto_skcipher_decrypt(req), &wait);
 	else
-		res = crypto_skcipher_encrypt(req);
-	if (res == -EINPROGRESS || res == -EBUSY) {
-		BUG_ON(req->base.data != &ecr);
-		wait_for_completion(&ecr.completion);
-		res = ecr.res;
-	}
+		res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
 	skcipher_request_free(req);
 	if (res) {
 		printk_ratelimited(KERN_ERR
diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index ad9f814..a80a0d3 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -15,21 +15,6 @@
 #include "fscrypt_private.h"
 
 /**
- * fname_crypt_complete() - completion callback for filename crypto
- * @req: The asynchronous cipher request context
- * @res: The result of the cipher operation
- */
-static void fname_crypt_complete(struct crypto_async_request *req, int res)
-{
-	struct fscrypt_completion_result *ecr = req->data;
-
-	if (res == -EINPROGRESS)
-		return;
-	ecr->res = res;
-	complete(&ecr->completion);
-}
-
-/**
  * fname_encrypt() - encrypt a filename
  *
  * The caller must have allocated sufficient memory for the @oname string.
@@ -40,7 +25,7 @@ static int fname_encrypt(struct inode *inode,
 			const struct qstr *iname, struct fscrypt_str *oname)
 {
 	struct skcipher_request *req = NULL;
-	DECLARE_FS_COMPLETION_RESULT(ecr);
+	DECLARE_CRYPTO_WAIT(wait);
 	struct fscrypt_info *ci = inode->i_crypt_info;
 	struct crypto_skcipher *tfm = ci->ci_ctfm;
 	int res = 0;
@@ -76,17 +61,12 @@ static int fname_encrypt(struct inode *inode,
 	}
 	skcipher_request_set_callback(req,
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
-			fname_crypt_complete, &ecr);
+			crypto_req_done, &wait);
 	sg_init_one(&sg, oname->name, cryptlen);
 	skcipher_request_set_crypt(req, &sg, &sg, cryptlen, iv);
 
 	/* Do the encryption */
-	res = crypto_skcipher_encrypt(req);
-	if (res == -EINPROGRESS || res == -EBUSY) {
-		/* Request is being completed asynchronously; wait for it */
-		wait_for_completion(&ecr.completion);
-		res = ecr.res;
-	}
+	res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
 	skcipher_request_free(req);
 	if (res < 0) {
 		printk_ratelimited(KERN_ERR
@@ -110,7 +90,7 @@ static int fname_decrypt(struct inode *inode,
 				struct fscrypt_str *oname)
 {
 	struct skcipher_request *req = NULL;
-	DECLARE_FS_COMPLETION_RESULT(ecr);
+	DECLARE_CRYPTO_WAIT(wait);
 	struct scatterlist src_sg, dst_sg;
 	struct fscrypt_info *ci = inode->i_crypt_info;
 	struct crypto_skcipher *tfm = ci->ci_ctfm;
@@ -131,7 +111,7 @@ static int fname_decrypt(struct inode *inode,
 	}
 	skcipher_request_set_callback(req,
 		CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
-		fname_crypt_complete, &ecr);
+		crypto_req_done, &wait);
 
 	/* Initialize IV */
 	memset(iv, 0, FS_CRYPTO_BLOCK_SIZE);
@@ -140,11 +120,7 @@ static int fname_decrypt(struct inode *inode,
 	sg_init_one(&src_sg, iname->name, iname->len);
 	sg_init_one(&dst_sg, oname->name, oname->len);
 	skcipher_request_set_crypt(req, &src_sg, &dst_sg, iname->len, iv);
-	res = crypto_skcipher_decrypt(req);
-	if (res == -EINPROGRESS || res == -EBUSY) {
-		wait_for_completion(&ecr.completion);
-		res = ecr.res;
-	}
+	res = crypto_wait_req(crypto_skcipher_decrypt(req), &wait);
 	skcipher_request_free(req);
 	if (res < 0) {
 		printk_ratelimited(KERN_ERR
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index a1d5021..c0f1881 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -69,16 +69,6 @@ typedef enum {
 #define FS_CTX_REQUIRES_FREE_ENCRYPT_FL		0x00000001
 #define FS_CTX_HAS_BOUNCE_BUFFER_FL		0x00000002
 
-struct fscrypt_completion_result {
-	struct completion completion;
-	int res;
-};
-
-#define DECLARE_FS_COMPLETION_RESULT(ecr) \
-	struct fscrypt_completion_result ecr = { \
-		COMPLETION_INITIALIZER_ONSTACK((ecr).completion), 0 }
-
-
 /* crypto.c */
 extern int fscrypt_initialize(unsigned int cop_flags);
 extern struct workqueue_struct *fscrypt_read_workqueue;
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 018c588..3c84cac 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -17,17 +17,6 @@
 
 static struct crypto_shash *essiv_hash_tfm;
 
-static void derive_crypt_complete(struct crypto_async_request *req, int rc)
-{
-	struct fscrypt_completion_result *ecr = req->data;
-
-	if (rc == -EINPROGRESS)
-		return;
-
-	ecr->res = rc;
-	complete(&ecr->completion);
-}
-
 /**
  * derive_key_aes() - Derive a key using AES-128-ECB
  * @deriving_key: Encryption key used for derivation.
@@ -42,7 +31,7 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 {
 	int res = 0;
 	struct skcipher_request *req = NULL;
-	DECLARE_FS_COMPLETION_RESULT(ecr);
+	DECLARE_CRYPTO_WAIT(wait);
 	struct scatterlist src_sg, dst_sg;
 	struct crypto_skcipher *tfm = crypto_alloc_skcipher("ecb(aes)", 0, 0);
 
@@ -59,7 +48,7 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 	}
 	skcipher_request_set_callback(req,
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
-			derive_crypt_complete, &ecr);
+			crypto_req_done, &wait);
 	res = crypto_skcipher_setkey(tfm, deriving_key,
 					FS_AES_128_ECB_KEY_SIZE);
 	if (res < 0)
@@ -69,11 +58,7 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 	sg_init_one(&dst_sg, derived_raw_key, source_key->size);
 	skcipher_request_set_crypt(req, &src_sg, &dst_sg, source_key->size,
 				   NULL);
-	res = crypto_skcipher_encrypt(req);
-	if (res == -EINPROGRESS || res == -EBUSY) {
-		wait_for_completion(&ecr.completion);
-		res = ecr.res;
-	}
+	res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
 out:
 	skcipher_request_free(req);
 	crypto_free_skcipher(tfm);
-- 
2.7.4
