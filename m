From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.32: padlock_sha1 and hmac broken?
Date: Mon, 1 Feb 2010 10:18:09 +1100
Message-ID: <20100131231809.GA29600@gondor.apana.org.au>
References: <201001300044.15769.wolfgang.walter@stwm.de> <201001310311.23116.wolfgang.walter@stwm.de> <20100131092222.GA22508@gondor.apana.org.au> <201001311437.55534.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34227 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752430Ab0AaXSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2010 18:18:12 -0500
Content-Disposition: inline
In-Reply-To: <201001311437.55534.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 31, 2010 at 02:37:55PM +0100, Wolfgang Walter wrote:
>
> This patch works. /proc/crypto shows
> 
> name         : authenc(hmac(sha1),cbc(aes))
> driver       : authenc(hmac(sha1-padlock),cbc-aes-padlock)
> module       : kernel
> priority     : 4300
> refcnt       : 85
> selftest     : passed
> type         : aead
> async        : yes
> blocksize    : 16
> ivsize       : 16
> maxauthsize  : 20
> geniv        : <built-in>

Thank you for checking!

I've added this patch into crypto-2.6 and will push to stable
when it is merged upstream.

commit 137bb21e8f03758eeffb464a5033338f34446b4e
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Feb 1 09:17:56 2010 +1100

    crypto: padlock-sha - Add import/export support
    
    As the padlock driver for SHA uses a software fallback to perform
    partial hashing, it must implement custom import/export functions.
    Otherwise hmac which depends on import/export for prehashing will
    not work with padlock-sha.
    
    Reported-by: Wolfgang Walter <wolfgang.walter@stwm.de>
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

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


Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
