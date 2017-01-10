From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 8/8] crypto/testmgr: Allocate only the required output size for hash tests
Date: Tue, 10 Jan 2017 15:24:46 -0800
Message-ID: <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@kernel.org>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are some hashes (e.g. sha224) that have some internal trickery
to make sure that only the correct number of output bytes are
generated.  If something goes wrong, they could potentially overrun
the output buffer.

Make the test more robust by allocating only enough space for the
correct output size so that memory debugging will catch the error if
the output is overrun.

Tested by intentionally breaking sha224 to output all 256
internally-generated bits while running on KASAN.

Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 crypto/testmgr.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index f616ad74cce7..575fc28a9ab2 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -265,6 +265,7 @@ static int __test_hash(struct crypto_ahash *tfm, struct hash_testvec *template,
 		       const int align_offset)
 {
 	const char *algo = crypto_tfm_alg_driver_name(crypto_ahash_tfm(tfm));
+	size_t digest_size = crypto_ahash_digestsize(tfm);
 	unsigned int i, j, k, temp;
 	struct scatterlist sg[8];
 	char *result;
@@ -275,7 +276,7 @@ static int __test_hash(struct crypto_ahash *tfm, struct hash_testvec *template,
 	char *xbuf[XBUFSIZE];
 	int ret = -ENOMEM;
 
-	result = kmalloc(MAX_DIGEST_SIZE, GFP_KERNEL);
+	result = kmalloc(digest_size, GFP_KERNEL);
 	if (!result)
 		return ret;
 	key = kmalloc(MAX_KEYLEN, GFP_KERNEL);
@@ -305,7 +306,7 @@ static int __test_hash(struct crypto_ahash *tfm, struct hash_testvec *template,
 			goto out;
 
 		j++;
-		memset(result, 0, MAX_DIGEST_SIZE);
+		memset(result, 0, digest_size);
 
 		hash_buff = xbuf[0];
 		hash_buff += align_offset;
@@ -380,7 +381,7 @@ static int __test_hash(struct crypto_ahash *tfm, struct hash_testvec *template,
 			continue;
 
 		j++;
-		memset(result, 0, MAX_DIGEST_SIZE);
+		memset(result, 0, digest_size);
 
 		temp = 0;
 		sg_init_table(sg, template[i].np);
@@ -458,7 +459,7 @@ static int __test_hash(struct crypto_ahash *tfm, struct hash_testvec *template,
 			continue;
 
 		j++;
-		memset(result, 0, MAX_DIGEST_SIZE);
+		memset(result, 0, digest_size);
 
 		ret = -EINVAL;
 		hash_buff = xbuf[0];
-- 
2.9.3
