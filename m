From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Fri, 07 Mar 2014 18:27:42 -0800
Message-ID: <1394245662.6972.12.camel@joe-AO722>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net>
	 <1394241960-1764-1-git-send-email-behanw@converseincode.com>
	 <1394243809.6972.4.camel@joe-AO722> <531A7D4F.7090303@converseincode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org,
	Jan-Simon =?ISO-8859-1?Q?M=F6ller?= <dl9pf-Mmb7MZpHnFY@public.gmane.org>,
	=?ISO-8859-1?Q?Vin=EDcius?= Tinti <viniciustinti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mark Charlebois <charlebm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Behan Webster <behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <531A7D4F.7090303-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-07 at 18:15 -0800, Behan Webster wrote:
> On 03/07/14 17:56, Joe Perches wrote:
> > On Fri, 2014-03-07 at 17:26 -0800, behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org wrote:
> >> From: Jan-Simon M=F6ller <dl9pf-Mmb7MZpHnFY@public.gmane.org>
> >>
> >> Replaced the use of a Variable Length Array In Struct (VLAIS) with=
 a C99
> >> compliant equivalent. This is the original VLAIS struct.
> > []
> >> diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
> > []
> >> @@ -23,12 +23,14 @@ void ieee80211_aes_ccm_encrypt(struct crypto_a=
ead *tfm, u8 *b_0, u8 *aad,
> >>   			       u8 *data, size_t data_len, u8 *mic)
> >>   {
> >>   	struct scatterlist assoc, pt, ct[2];
> >> -	struct {
> >> -		struct aead_request	req;
> >> -		u8			priv[crypto_aead_reqsize(tfm)];
> >> -	} aead_req;
> >>  =20
> >> -	memset(&aead_req, 0, sizeof(aead_req));
> >> +	char aead_req_data[sizeof(struct aead_request) +
> >> +				crypto_aead_reqsize(tfm) +
> >> +				CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;
> > Can this be a too large amount of stack?
> >
> > Is crypto_aead_reqsize() limited to < ~1k?
> >
> > Perhaps it'd be better to use kzalloc for this
> > or another reserved pool
> No more stack being used than with the the original code. The stack=20
> memory use is identical.

I do understand that, but that's not my question.

I appreciate you're getting this to compile for llvm.

Any idea of the max value of crypto_aead_reqsize?

include/linux/crypto.h:static inline unsigned int crypto_aead_reqsize(s=
truct crypto_aead *tfm)
include/linux/crypto.h-{
include/linux/crypto.h- return crypto_aead_crt(tfm)->reqsize;
include/linux/crypto.h-}

$ grep-2.5.4 -rP --include=3D*.[ch] "(?:->|\.)\s*\breqsize\s*=3D[^=3D][=
^;]+;" *
arch/x86/crypto/aesni-intel_glue.c:	tfm->crt_aead.reqsize =3D sizeof(st=
ruct aead_request)
		+ crypto_aead_reqsize(&cryptd_tfm->base);
crypto/chainiv.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struct ablkcip=
her_request);
crypto/authenc.c:	tfm->crt_aead.reqsize =3D sizeof(struct authenc_reque=
st_ctx) +
				ctx->reqoff +
				max_t(unsigned int,
				crypto_ahash_reqsize(auth) +
				sizeof(struct ahash_request),
				sizeof(struct skcipher_givcrypt_request) +
				crypto_ablkcipher_reqsize(enc));
crypto/authencesn.c:	tfm->crt_aead.reqsize =3D sizeof(struct authenc_es=
n_request_ctx) +
				ctx->reqoff +
				max_t(unsigned int,
				crypto_ahash_reqsize(auth) +
				sizeof(struct ahash_request),
				sizeof(struct skcipher_givcrypt_request) +
				crypto_ablkcipher_reqsize(enc));
crypto/shash.c:	crt->reqsize =3D sizeof(struct shash_desc) + crypto_sha=
sh_descsize(shash);
crypto/cryptd.c:	tfm->crt_ablkcipher.reqsize =3D
		sizeof(struct cryptd_blkcipher_request_ctx);
crypto/cryptd.c:	tfm->crt_aead.reqsize =3D sizeof(struct cryptd_aead_re=
quest_ctx);
crypto/seqiv.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struct ablkciphe=
r_request);
crypto/seqiv.c:	tfm->crt_aead.reqsize =3D sizeof(struct aead_request);
crypto/ablk_helper.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struct abl=
kcipher_request) +
		crypto_ablkcipher_reqsize(&cryptd_tfm->base);
crypto/ctr.c:	tfm->crt_ablkcipher.reqsize =3D align +
		sizeof(struct crypto_rfc3686_req_ctx) +
		crypto_ablkcipher_reqsize(cipher);
crypto/eseqiv.c:	tfm->crt_ablkcipher.reqsize =3D reqsize +
				      sizeof(struct ablkcipher_request);
crypto/ccm.c:	tfm->crt_aead.reqsize =3D align +
				sizeof(struct crypto_ccm_req_priv_ctx) +
				crypto_ablkcipher_reqsize(ctr);
crypto/ccm.c:	tfm->crt_aead.reqsize =3D sizeof(struct aead_request) +
				ALIGN(crypto_aead_reqsize(aead),
				      crypto_tfm_ctx_alignment()) +
				align + 16;
crypto/gcm.c:	tfm->crt_aead.reqsize =3D align +
		offsetof(struct crypto_gcm_req_priv_ctx, u) +
		max(sizeof(struct ablkcipher_request) +
		    crypto_ablkcipher_reqsize(ctr),
		    sizeof(struct ahash_request) +
		    crypto_ahash_reqsize(ghash));
crypto/gcm.c:	tfm->crt_aead.reqsize =3D sizeof(struct aead_request) +
				ALIGN(crypto_aead_reqsize(aead),
				      crypto_tfm_ctx_alignment()) +
				align + 16;
crypto/gcm.c:	tfm->crt_aead.reqsize =3D sizeof(struct crypto_rfc4543_re=
q_ctx) +
				ALIGN(crypto_aead_reqsize(aead),
				      crypto_tfm_ctx_alignment()) +
				align + 16;
crypto/pcrypt.c:	tfm->crt_aead.reqsize =3D sizeof(struct pcrypt_request=
)
		+ sizeof(struct aead_givcrypt_request)
		+ crypto_aead_reqsize(cipher);
drivers/staging/sep/sep_crypto.c:	tfm->crt_ablkcipher.reqsize =3D sizeo=
f(struct this_task_ctx);
drivers/crypto/n2_core.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struct=
 n2_request_context);
drivers/crypto/mxs-dcp.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struct=
 dcp_aes_req_ctx);
drivers/crypto/sahara.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struct =
sahara_aes_reqctx);
drivers/crypto/ccp/ccp-crypto-aes.c:	tfm->crt_ablkcipher.reqsize =3D si=
zeof(struct ccp_aes_req_ctx);
drivers/crypto/ccp/ccp-crypto-aes.c:	tfm->crt_ablkcipher.reqsize =3D si=
zeof(struct ccp_aes_req_ctx);
drivers/crypto/ccp/ccp-crypto-aes-xts.c:	tfm->crt_ablkcipher.reqsize =3D=
 sizeof(struct ccp_aes_req_ctx) +
				      fallback_tfm->base.crt_ablkcipher.reqsize;
drivers/crypto/s5p-sss.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struct=
 s5p_aes_reqctx);
drivers/crypto/atmel-aes.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(stru=
ct atmel_aes_reqctx);
drivers/crypto/ixp4xx_crypto.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(=
struct ablk_ctx);
drivers/crypto/ixp4xx_crypto.c:	tfm->crt_aead.reqsize =3D sizeof(struct=
 aead_ctx);
drivers/crypto/omap-des.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struc=
t omap_des_reqctx);
drivers/crypto/mv_cesa.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struct=
 mv_req_ctx);
drivers/crypto/omap-aes.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(struc=
t omap_aes_reqctx);
drivers/crypto/hifn_795x.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(stru=
ct hifn_request_context);
drivers/crypto/amcc/crypto4xx_core.c:		tfm->crt_ablkcipher.reqsize =3D =
sizeof(struct crypto4xx_ctx);
drivers/crypto/atmel-tdes.c:	tfm->crt_ablkcipher.reqsize =3D sizeof(str=
uct atmel_tdes_reqctx);
drivers/crypto/picoxcell_crypto.c:	tfm->crt_aead.reqsize =3D sizeof(str=
uct spacc_req);
drivers/crypto/picoxcell_crypto.c:	tfm->crt_ablkcipher.reqsize =3D size=
of(struct spacc_req);
include/crypto/internal/hash.h:	tfm->reqsize =3D reqsize;


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
