From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: dm-crypt changes in git-net tree
Date: Tue, 5 Dec 2006 19:40:41 +1100
Message-ID: <20061205084041.GA25615@gondor.apana.org.au>
References: <20061204225907.6b486e57.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rik Snel <rsnel@cube.dyndns.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4265 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S968089AbWLEIlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 03:41:00 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061204225907.6b486e57.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 04, 2006 at 10:59:07PM -0800, Andrew Morton wrote:
> 
> On x86_64:
> 
> drivers/md/dm-crypt.c: In function 'crypt_iv_benbi_ctr':
> drivers/md/dm-crypt.c:235: warning: cast to pointer from integer of different size
> drivers/md/dm-crypt.c: In function 'crypt_iv_benbi_gen':
> drivers/md/dm-crypt.c:248: warning: cast from pointer to integer of different size
> drivers/md/dm-crypt.c:248: warning: cast from pointer to integer of different size
> drivers/md/dm-crypt.c:248: warning: cast from pointer to integer of different size

Yeah that isn't pretty.  I've changed it like this.

[CRYPTO] dm-crypt: Make iv_gen_private a union

Rather than stuffing integers into pointers with casts, let's use
a union.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 2c7aaac..9b3b126 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -86,7 +86,10 @@ struct crypt_config {
 	 */
 	struct crypt_iv_operations *iv_gen_ops;
 	char *iv_mode;
-	struct crypto_cipher *iv_gen_private;
+	union {
+		struct crypto_cipher *essiv_tfm;
+		int benbi_shift;
+	} iv_gen_private;
 	sector_t iv_offset;
 	unsigned int iv_size;
 
@@ -195,21 +198,21 @@ static int crypt_iv_essiv_ctr(struct cry
 	}
 	kfree(salt);
 
-	cc->iv_gen_private = essiv_tfm;
+	cc->iv_gen_private.essiv_tfm = essiv_tfm;
 	return 0;
 }
 
 static void crypt_iv_essiv_dtr(struct crypt_config *cc)
 {
-	crypto_free_cipher(cc->iv_gen_private);
-	cc->iv_gen_private = NULL;
+	crypto_free_cipher(cc->iv_gen_private.essiv_tfm);
+	cc->iv_gen_private.essiv_tfm = NULL;
 }
 
 static int crypt_iv_essiv_gen(struct crypt_config *cc, u8 *iv, sector_t sector)
 {
 	memset(iv, 0, cc->iv_size);
 	*(u64 *)iv = cpu_to_le64(sector);
-	crypto_cipher_encrypt_one(cc->iv_gen_private, iv, iv);
+	crypto_cipher_encrypt_one(cc->iv_gen_private.essiv_tfm, iv, iv);
 	return 0;
 }
 
@@ -232,21 +235,23 @@ static int crypt_iv_benbi_ctr(struct cry
 		return -EINVAL;
 	}
 
-	cc->iv_gen_private = (void *)(9 - log);
+	cc->iv_gen_private.benbi_shift = 9 - log;
 
 	return 0;
 }
 
 static void crypt_iv_benbi_dtr(struct crypt_config *cc)
 {
-	cc->iv_gen_private = NULL;
 }
 
 static int crypt_iv_benbi_gen(struct crypt_config *cc, u8 *iv, sector_t sector)
 {
+	__be64 val;
+
 	memset(iv, 0, cc->iv_size - sizeof(u64)); /* rest is cleared below */
-	put_unaligned(cpu_to_be64(((u64)sector << (u32)cc->iv_gen_private) + 1),
-		      (__be64 *)(iv + cc->iv_size - sizeof(u64)));
+
+	val = cpu_to_be64(((u64)sector << cc->iv_gen_private.benbi_shift) + 1);
+	put_unaligned(val, (__be64 *)(iv + cc->iv_size - sizeof(u64)));
 
 	return 0;
 }
