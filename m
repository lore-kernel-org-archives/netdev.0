From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.32: padlock_sha1 and hmac broken?
Date: Sun, 31 Jan 2010 20:22:22 +1100
Message-ID: <20100131092222.GA22508@gondor.apana.org.au>
References: <201001300044.15769.wolfgang.walter@stwm.de> <201001301734.46003.wolfgang.walter@stwm.de> <20100130221731.GA18982@gondor.apana.org.au> <201001310311.23116.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201001310311.23116.wolfgang.walter@stwm.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 31, 2010 at 03:11:22AM +0100, Wolfgang Walter wrote:
> 
> Not sure.
> 
> When I do
> 
> modprobe tcrypt mode=101
> 
> I get a kernel oops:

Sorry, this one should have a better chance at working.

diff --git a/drivers/crypto/padlock-sha.c b/drivers/crypto/padlock-sha.c
index 0af8057..d3a27e0 100644
--- a/drivers/crypto/padlock-sha.c
+++ b/drivers/crypto/padlock-sha.c
@@ -57,6 +57,23 @@ static int padlock_sha_update(struct shash_desc *desc,
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
+	struct padlock_sha_ctx *ctx = crypto_shash_ctx(desc->tfm);
+
+	dctx->fallback.tfm = ctx->fallback;
+	dctx->fallback.flags = desc->flags & CRYPTO_TFM_REQ_MAY_SLEEP;
+	return crypto_shash_import(&dctx->fallback, in);
+}
+
 static inline void padlock_output_block(uint32_t *src,
 		 	uint32_t *dst, size_t count)
 {
@@ -235,7 +252,10 @@ static struct shash_alg sha1_alg = {
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
@@ -256,7 +276,10 @@ static struct shash_alg sha256_alg = {
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
