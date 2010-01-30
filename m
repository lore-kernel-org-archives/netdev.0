From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.32: padlock_sha1 and hmac broken?
Date: Sun, 31 Jan 2010 09:17:31 +1100
Message-ID: <20100130221731.GA18982@gondor.apana.org.au>
References: <201001300044.15769.wolfgang.walter@stwm.de> <20100130022721.GA8324@gondor.apana.org.au> <201001301734.46003.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753973Ab0A3WRh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201001301734.46003.wolfgang.walter@stwm.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 30, 2010 at 05:34:45PM +0100, Wolfgang Walter wrote:
>
> > Please also try "modprobe tcrypt mode=101".
> 
> [  474.947508] alg: hash: Failed to load transform for hmac(sha1): -2
> [  474.952660] alg: hash: Failed to load transform for hmac(sha1): -2
> [  474.952737] tcrypt: one or more tests failed!

Oops, it looks like this has been broken ever since we added
prehashing to hmac.

Please try this patch and let me know whether it makes it work
again.

diff --git a/drivers/crypto/padlock-sha.c b/drivers/crypto/padlock-sha.c
index 0af8057..a1180ca 100644
--- a/drivers/crypto/padlock-sha.c
+++ b/drivers/crypto/padlock-sha.c
@@ -57,6 +57,20 @@ static int padlock_sha_update(struct shash_desc *desc,
 	return crypto_shash_update(&dctx->fallback, data, length);
 }
 
+static int padlock_sha_export(struct shash_desc *desc, void *out)
+{
+	struct padlock_sha_desc *dctx = shash_desc_ctx(desc);
+
+	return crypto_shash_export(&dctx->fallback, out);
+}
+
+static int padlock_sha_import(struct shash_desc *desc, const void *in)
+{
+	struct padlock_sha_desc *dctx = shash_desc_ctx(desc);
+
+	return crypto_shash_import(&dctx->fallback, in);
+}
+
 static inline void padlock_output_block(uint32_t *src,
 		 	uint32_t *dst, size_t count)
 {
@@ -235,7 +249,10 @@ static struct shash_alg sha1_alg = {
 	.update 	=	padlock_sha_update,
 	.finup  	=	padlock_sha1_finup,
 	.final  	=	padlock_sha1_final,
+	.export		=	padlock_sha_export,
+	.import		=	padlock_sha_import,
 	.descsize	=	sizeof(struct padlock_sha_desc),
+	.statesize	=	sizeof(struct sha1_state),
 	.base		=	{
 		.cra_name		=	"sha1",
 		.cra_driver_name	=	"sha1-padlock",
@@ -256,7 +273,10 @@ static struct shash_alg sha256_alg = {
 	.update 	=	padlock_sha_update,
 	.finup  	=	padlock_sha256_finup,
 	.final  	=	padlock_sha256_final,
+	.export		=	padlock_sha_export,
+	.import		=	padlock_sha_import,
 	.descsize	=	sizeof(struct padlock_sha_desc),
+	.statesize	=	sizeof(struct sha256_state),
 	.base		=	{
 		.cra_name		=	"sha256",
 		.cra_driver_name	=	"sha256-padlock",

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
