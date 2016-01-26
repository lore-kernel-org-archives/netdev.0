From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 16/26] libceph: Use skcipher
Date: Tue, 26 Jan 2016 18:54:55 +0800
Message-ID: <20160126105455.GA19674@gondor.apana.org.au>
References: <20160124131021.GA31153@gondor.apana.org.au>
 <E1aNKYy-0008E6-GI@gondolin.me.apana.org.au>
 <CAOi1vP9jmMYHR21UeAO175susZ5V74vcXyoxwayBVSTFHxjhBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, open-iscsi@googlegroups.com,
 netdev <netdev@vger.kernel.org>, ecryptfs@vger.kernel.org,
 linux-wireless@vger.kernel.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-f2fs-devel@lists.sourceforge.net, linux-bluetooth@vger.kernel.org,
 dm-devel@redhat.com, keyrings@vger.kernel.org,
 Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
 Ceph Development <ceph-devel@vger.kernel.org>, linux-ext4@vger.kernel.org,
 linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
 Lars Ellenberg <drbd-dev@lists.linbit.com>
To: Ilya Dryomov <idryomov@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <CAOi1vP9jmMYHR21UeAO175susZ5V74vcXyoxwayBVSTFHxjhBQ@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2016 at 05:18:47PM +0100, Ilya Dryomov wrote:
> 
> Could you get rid of ivsize instead of assigning to it - see the
> attached diff?

How about an incremental patch like this? Thanks!

---8<---
From: Ilya Dryomov <idryomov@gmail.com>
Subject: libceph: Remove unnecessary ivsize variables

This patch removes the unnecessary ivsize variabls as they always
have the value of AES_BLOCK_SIZE.

Signed-off-by: Ilya Dryomov <idryomov@gmail.com>

diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
index fb9cb2b..db2847a 100644
--- a/net/ceph/crypto.c
+++ b/net/ceph/crypto.c
@@ -166,8 +166,7 @@ static int ceph_aes_encrypt(const void *key, int key_len,
 	struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
 	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	int ret;
-	int ivsize = AES_BLOCK_SIZE;
-	char iv[ivsize];
+	char iv[AES_BLOCK_SIZE];
 	size_t zero_padding = (0x10 - (src_len & 0x0f));
 	char pad[16];
 
@@ -186,7 +185,7 @@ static int ceph_aes_encrypt(const void *key, int key_len,
 		goto out_tfm;
 
 	crypto_skcipher_setkey((void *)tfm, key, key_len);
-	memcpy(iv, aes_iv, ivsize);
+	memcpy(iv, aes_iv, AES_BLOCK_SIZE);
 
 	skcipher_request_set_tfm(req, tfm);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
@@ -229,8 +228,7 @@ static int ceph_aes_encrypt2(const void *key, int key_len, void *dst,
 	struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
 	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	int ret;
-	int ivsize = AES_BLOCK_SIZE;
-	char iv[ivsize];
+	char iv[AES_BLOCK_SIZE];
 	size_t zero_padding = (0x10 - ((src1_len + src2_len) & 0x0f));
 	char pad[16];
 
@@ -250,7 +248,7 @@ static int ceph_aes_encrypt2(const void *key, int key_len, void *dst,
 		goto out_tfm;
 
 	crypto_skcipher_setkey((void *)tfm, key, key_len);
-	memcpy(iv, aes_iv, ivsize);
+	memcpy(iv, aes_iv, AES_BLOCK_SIZE);
 
 	skcipher_request_set_tfm(req, tfm);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
@@ -294,8 +292,7 @@ static int ceph_aes_decrypt(const void *key, int key_len,
 	struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
 	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	char pad[16];
-	int ivsize = AES_BLOCK_SIZE;
-	char iv[16];
+	char iv[AES_BLOCK_SIZE];
 	int ret;
 	int last_byte;
 
@@ -310,7 +307,7 @@ static int ceph_aes_decrypt(const void *key, int key_len,
 		goto out_tfm;
 
 	crypto_skcipher_setkey((void *)tfm, key, key_len);
-	memcpy(iv, aes_iv, ivsize);
+	memcpy(iv, aes_iv, AES_BLOCK_SIZE);
 
 	skcipher_request_set_tfm(req, tfm);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
@@ -363,8 +360,7 @@ static int ceph_aes_decrypt2(const void *key, int key_len,
 	struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
 	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	char pad[16];
-	int ivsize = AES_BLOCK_SIZE;
-	char iv[ivsize];
+	char iv[AES_BLOCK_SIZE];
 	int ret;
 	int last_byte;
 
@@ -380,7 +376,7 @@ static int ceph_aes_decrypt2(const void *key, int key_len,
 		goto out_tfm;
 
 	crypto_skcipher_setkey((void *)tfm, key, key_len);
-	memcpy(iv, aes_iv, ivsize);
+	memcpy(iv, aes_iv, AES_BLOCK_SIZE);
 
 	skcipher_request_set_tfm(req, tfm);
 	skcipher_request_set_callback(req, 0, NULL, NULL);

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
