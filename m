From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: 2.6.32: padlock_sha1 and hmac broken?
Date: Sun, 31 Jan 2010 14:37:55 +0100
Message-ID: <201001311437.55534.wolfgang.walter@stwm.de>
References: <201001300044.15769.wolfgang.walter@stwm.de> <201001310311.23116.wolfgang.walter@stwm.de> <20100131092222.GA22508@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20100131092222.GA22508@gondor.apana.org.au>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 31. Januar 2010 schrieb Herbert Xu:
> On Sun, Jan 31, 2010 at 03:11:22AM +0100, Wolfgang Walter wrote:
> > Not sure.
> >
> > When I do
> >
> > modprobe tcrypt mode=3D101
> >
> > I get a kernel oops:
>
> Sorry, this one should have a better chance at working.
>
> diff --git a/drivers/crypto/padlock-sha.c b/drivers/crypto/padlock-sh=
a.c
> index 0af8057..d3a27e0 100644
> --- a/drivers/crypto/padlock-sha.c
> +++ b/drivers/crypto/padlock-sha.c
> @@ -57,6 +57,23 @@ static int padlock_sha_update(struct shash_desc *d=
esc,
>  	return crypto_shash_update(&dctx->fallback, data, length);
>  }
>
> +static int padlock_sha_export(struct shash_desc *desc, void *out)
> +{
> +	struct padlock_sha_desc *dctx =3D shash_desc_ctx(desc);
> +
> +	return crypto_shash_export(&dctx->fallback, out);
> +}
> +
> +static int padlock_sha_import(struct shash_desc *desc, const void *i=
n)
> +{
> +	struct padlock_sha_desc *dctx =3D shash_desc_ctx(desc);
> +	struct padlock_sha_ctx *ctx =3D crypto_shash_ctx(desc->tfm);
> +
> +	dctx->fallback.tfm =3D ctx->fallback;
> +	dctx->fallback.flags =3D desc->flags & CRYPTO_TFM_REQ_MAY_SLEEP;
> +	return crypto_shash_import(&dctx->fallback, in);
> +}
> +
>  static inline void padlock_output_block(uint32_t *src,
>  		 	uint32_t *dst, size_t count)
>  {
> @@ -235,7 +252,10 @@ static struct shash_alg sha1_alg =3D {
>  	.update 	=3D	padlock_sha_update,
>  	.finup  	=3D	padlock_sha1_finup,
>  	.final  	=3D	padlock_sha1_final,
> +	.export		=3D	padlock_sha_export,
> +	.import		=3D	padlock_sha_import,
>  	.descsize	=3D	sizeof(struct padlock_sha_desc),
> +	.statesize	=3D	sizeof(struct sha1_state),
>  	.base		=3D	{
>  		.cra_name		=3D	"sha1",
>  		.cra_driver_name	=3D	"sha1-padlock",
> @@ -256,7 +276,10 @@ static struct shash_alg sha256_alg =3D {
>  	.update 	=3D	padlock_sha_update,
>  	.finup  	=3D	padlock_sha256_finup,
>  	.final  	=3D	padlock_sha256_final,
> +	.export		=3D	padlock_sha_export,
> +	.import		=3D	padlock_sha_import,
>  	.descsize	=3D	sizeof(struct padlock_sha_desc),
> +	.statesize	=3D	sizeof(struct sha256_state),
>  	.base		=3D	{
>  		.cra_name		=3D	"sha256",
>  		.cra_driver_name	=3D	"sha256-padlock",
>
> Thanks,

This patch works. /proc/crypto shows

name         : authenc(hmac(sha1),cbc(aes))
driver       : authenc(hmac(sha1-padlock),cbc-aes-padlock)
module       : kernel
priority     : 4300
refcnt       : 85
selftest     : passed
type         : aead
async        : yes
blocksize    : 16
ivsize       : 16
maxauthsize  : 20
geniv        : <built-in>

=2E...
=2E...

and

modprobe tcrypt mode=3D101

logs nothing.

Thanks a lot,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
--
To unsubscribe from this list: send the line "unsubscribe linux-crypto"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
