From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/6] crypto: hash - Make setkey optional
Date: Mon, 01 Dec 2008 21:47:14 +0800
Message-ID: <E1L797K-0005j9-MN@gondolin.me.apana.org.au>
References: <20081201134448.GA21939@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

crypto: hash - Make setkey optional

Since most cryptographic hash algorithms have no keys, this patch
makes the setkey function optional for ahash and shash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/ahash.c |    8 +++++++-
 crypto/shash.c |    3 +++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/crypto/ahash.c b/crypto/ahash.c
index 9f98956..ba5292d 100644
--- a/crypto/ahash.c
+++ b/crypto/ahash.c
@@ -162,6 +162,12 @@ static int ahash_setkey(struct crypto_ahash *tfm, const u8 *key,
 	return ahash->setkey(tfm, key, keylen);
 }
 
+static int ahash_nosetkey(struct crypto_ahash *tfm, const u8 *key,
+			  unsigned int keylen)
+{
+	return -ENOSYS;
+}
+
 int crypto_ahash_import(struct ahash_request *req, const u8 *in)
 {
 	struct crypto_ahash *tfm = crypto_ahash_reqtfm(req);
@@ -194,7 +200,7 @@ static int crypto_init_ahash_ops(struct crypto_tfm *tfm, u32 type, u32 mask)
 	crt->update = alg->update;
 	crt->final  = alg->final;
 	crt->digest = alg->digest;
-	crt->setkey = ahash_setkey;
+	crt->setkey = alg->setkey ? ahash_setkey : ahash_nosetkey;
 	crt->digestsize = alg->digestsize;
 
 	return 0;
diff --git a/crypto/shash.c b/crypto/shash.c
index 50d69a4..c9df367 100644
--- a/crypto/shash.c
+++ b/crypto/shash.c
@@ -55,6 +55,9 @@ int crypto_shash_setkey(struct crypto_shash *tfm, const u8 *key,
 	struct shash_alg *shash = crypto_shash_alg(tfm);
 	unsigned long alignmask = crypto_shash_alignmask(tfm);
 
+	if (!shash->setkey)
+		return -ENOSYS;
+
 	if ((unsigned long)key & alignmask)
 		return shash_setkey_unaligned(tfm, key, keylen);
 
