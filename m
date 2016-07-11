From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3] chcr: Support for Chelsio's Crypto Hardware
Date: Mon, 11 Jul 2016 11:57:16 -0700
Message-ID: <1468263436.8360.154.camel@perches.com>
References: <1468261688-24525-1-git-send-email-yeshaswi@chelsio.com>
	 <1468261688-24525-3-git-send-email-yeshaswi@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Yeshaswi M R Gowda <yeshaswi@chelsio.com>, hariprasad@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	linux-crypto@vger.kernel.org, jlulla@chelsio.com,
	atul.gupta@chelsio.com, harsh@chelsio.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1468261688-24525-3-git-send-email-yeshaswi@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-07-11 at 11:28 -0700, Yeshaswi M R Gowda wrote:
> The Chelsio's Crypto Hardware can perform the following operations:
> SHA1, SHA224, SHA256, SHA384 and SHA512, HMAC(SHA1), HMAC(SHA224),
> HMAC(SHA256), HMAC(SHA384), HAMC(SHA512), AES-128-CBC, AES-192-CBC,
> AES-256-CBC, AES-128-XTS, AES-256-XTS
>=20
> This patch implements the driver for above mentioned features.

trivial notes:

> diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chel=
sio/chcr_algo.c
[]
> +int chcr_handle_resp(struct crypto_async_request *req, unsigned char=
 *input,
> +		=A0=A0=A0=A0=A0int error_status)
> +{
[]
> +	case CRYPTO_ALG_TYPE_BLKCIPHER:
> +		ctx_req.req.ablk_req =3D (struct ablkcipher_request *)req;
> +		ctx_req.ctx.ablk_ctx =3D
> +			ablkcipher_request_ctx(ctx_req.req.ablk_req);
> +		if (error_status)
> +			goto dma_unmap_blkcipher;
> +		fw6_pld =3D (struct cpl_fw6_pld *)input;
> +		memcpy(ctx_req.req.ablk_req->info, &fw6_pld->data[2],
> +		=A0=A0=A0=A0=A0=A0=A0AES_BLOCK_SIZE);
> +dma_unmap_blkcipher:
> +		dma_unmap_sg(&u_ctx->lldi.pdev->dev, ctx_req.req.ablk_req->dst,
> +			=A0=A0=A0=A0=A0ABLK_CTX(ctx)->dst_nents, DMA_FROM_DEVICE);
> +		if (ctx_req.ctx.ablk_ctx->skb) {
> +			kfree_skb(ctx_req.ctx.ablk_ctx->skb);
> +			ctx_req.ctx.ablk_ctx->skb =3D NULL;
> +		}
> +		break;

This case label is only used here right?

This would be better without the goto

[]

> +	if (IS_ERR(base_hash)) {
> +		pr_err("Can not allocate sha-generic algo.\n");
> +		return (void *)base_hash;
> +	}

Please add
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
before any #include to prefix any pr_<level> uses.

[]
> +/*
> + *	chcr_register_alg - Register crypto algorithms with kernel framew=
ork.
> + */
> +static int chcr_register_alg(void)
> +{
> +	struct crypto_alg ai;
> +	int err =3D 0, i;
> +	char *name =3D NULL;
> +
> +	for (i =3D 0; i < ARRAY_SIZE(driver_algs); i++) {
> +		if (driver_algs[i].is_registered)
> +			continue;
> +		switch (driver_algs[i].type & CRYPTO_ALG_TYPE_MASK) {
> +		case CRYPTO_ALG_TYPE_ABLKCIPHER:
> +			err =3D crypto_register_alg(&driver_algs[i].alg.crypto);
> +			name =3D driver_algs[i].alg.crypto.cra_driver_name;
> +			break;
> +		case CRYPTO_ALG_TYPE_AHASH:

This could be clearer with a temporary for
driver_algs[i].alg.hash

			<whatever type *> hash =3D &driver_algs[i].alg.hash;

> +			driver_algs[i].alg.hash.update =3D chcr_ahash_update;

			hash->update =3D chcr_ahash_update;
	etc...

> +			driver_algs[i].alg.hash.final =3D chcr_ahash_final;
> +			driver_algs[i].alg.hash.finup =3D chcr_ahash_finup;
> +			driver_algs[i].alg.hash.digest =3D chcr_ahash_digest;
> +			driver_algs[i].alg.hash.export =3D chcr_ahash_export;
> +			driver_algs[i].alg.hash.import =3D chcr_ahash_import;
> +			driver_algs[i].alg.hash.halg.statesize =3D
> +				sizeof(struct chcr_ahash_req_ctx);

Even with this sort of change, a lot of barely >80 column lines
are split making the code a bit less readable.

It might be better to avoid splitting these long lines and
ignore the >80 column limits occasionally.
