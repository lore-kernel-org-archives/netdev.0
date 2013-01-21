From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Mon, 21 Jan 2013 11:40:56 -0500
Message-ID: <1358786456.2595.44.camel@obelisk.thedillows.org>
References: <436404741.94502.1358773048618.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <436404741.94502.1358773048618.JavaMail.root@elliptictech.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Apologies for the dupe, fixing stupid typo for netdev address...
-ENOCAFFEINE]

I hesitate to reward the squeaky wheel, but in the community spirit,
here goes...

Please fix the subject for future submissions. The subject should be a
short, one line description of the patch. It helps if the subject
includes the section of the code you are affecting. Also, if you are
resending a patch after addressing review comments, change the tag to
[PATCH v2] etc. will indicate that. For example:
	[PATCH v2] crypto: add support for the NIST CMAC hash

This keeps the maintainers from having to hand edit your patch, which
dramatically slows them down. The goal is to get to a patch that can be
applied as-is after review.

On Mon, 2013-01-21 at 07:57 -0500, Tom St Denis wrote:
> Hey all,
> 
> Here's an updated patch which addresses a couple of build issues and
> coding style complaints.  
> 
> I still can't get it to run via testmgr I get 
> 
> [  162.407807] alg: No test for cmac(aes) (cmac(aes-generic))
> 
> Despite the fact I have an entry for cmac(aes) (much like xcbc(aes)...).
> 
> Here's the patch to bring 3.8-rc4 up with CMAC ...

All of this commentary should go after the '---' separator; the
maintainer will have to hand edit it out otherwise. It's good
information, it's just the wrong place.

There should be a short description here of the patch, if needed. You
may be fine with the one line description in this case, or you could
point to the RFC, etc.

> Signed-off-by: Tom St Denis <tstdenis@elliptictech.com>
> 
> ---
>  crypto/Kconfig               |   8 ++
>  crypto/Makefile              |   1 +
>  crypto/cmac.c                | 317 +++++++++++++++++++++++++++++++++++++++++++
>  crypto/testmgr.c             |   9 ++
>  crypto/testmgr.h             |  52 +++++++
>  include/uapi/linux/pfkeyv2.h |   1 +
>  net/xfrm/xfrm_algo.c         |  17 +++

You may be asked to split out the net changes into a separate patch, but
since you are adding the user at the time you add the code, you may not.

>  7 files changed, 405 insertions(+)
>  create mode 100644 crypto/cmac.c
> 
> diff --git a/crypto/Kconfig b/crypto/Kconfig
> index 4641d95..5ac2c7f 100644
> --- a/crypto/Kconfig
> +++ b/crypto/Kconfig
> @@ -301,6 +301,14 @@ config CRYPTO_XCBC
>  		http://csrc.nist.gov/encryption/modes/proposedmodes/
>  		 xcbc-mac/xcbc-mac-spec.pdf
>  
> +config CRYPTO_CMAC
> +	tristate "CMAC support"
> +	depends on EXPERIMENTAL
> +	select CRYPTO_HASH
> +	select CRYPTO_MANAGER
> +	help
> +	  NIST CMAC cipher based MAC

Pointers to the docs as for XCBC above would be useful here.

> diff --git a/crypto/cmac.c b/crypto/cmac.c
> new file mode 100644
> index 0000000..1ffeea7
> --- /dev/null
> +++ b/crypto/cmac.c
> @@ -0,0 +1,317 @@
> +/*
> + * Copyright (C)2006 USAGI/WIDE Project

Add your copyright info, 2013?

> +static int crypto_cmac_digest_setkey(struct crypto_shash *parent,
> +					  const u8 *inkey, unsigned int keylen)
> +{
> +	unsigned long alignmask = crypto_shash_alignmask(parent);
> +	struct cmac_tfm_ctx *ctx = crypto_shash_ctx(parent);
> +	int bs = crypto_shash_blocksize(parent);
> +	u8 *consts = PTR_ALIGN(&ctx->ctx[0], alignmask + 1);
> +	int x, y, err = 0;
> +	u8 msb, mask;
> +
> +	switch (bs) {
> +	case 16:
> +		mask = 0x87;
> +		break;
> +	case 8:
> +		mask = 0x1B;
> +		break;
> +	default:
> +		return -EINVAL; /*  only support 64/128 bit block ciphers */

Checkpatch doesn't warn, but this comment would probably be preferred to
be on a line by itself.

> +	for (x = 0; x < 2; x++) {
> +		/* if msb(L * u^(x+1)) = 0 then just shift,
> +		otherwise shift and xor constant mask */

This comment is incorrectly formatted; I see checkpatch.pl from 3.7-rc4
didn't pick it up, which is interesting.
		/*
		 * if msb(L * u^(x+1)) = 0 then just shift,
		 * otherwise shift and xor constant mask
		 */

Though I'll note that doing 
	grep '/\*' crypto/*.c | grep -v '\*/' | less

provides evidence that it also commonly
		/* is msb....
		 */

> +		/* shift left */
> +		for (y = 0; y < (bs - 1); y++)
> +			consts[x*bs + y] =
> +				((consts[x*bs + y] << 1) |
> +				(consts[x*bs + y+1] >> 7)) & 255;

So, here is a case where you fixed two warnings at the same time, but
made one of them irrelevant in the process -- this should have braces
around the single statement. checkpatch.pl complained initially because
there was a one-line statement, but would not have complained if it
looked like you have it now. Also, probably want a spaces in the y+1, if
not the multiplication.

> +
> +		consts[x*bs + bs - 1] =
> +			((consts[x*bs + bs - 1] << 1) ^
> +			(msb ? mask : 0)) & 255;
> +
> +		/* copy up as require */

Minor English nit: required?

> +		if (x == 0)
> +			memcpy(&consts[(x+1)*bs], &consts[x*bs], bs);

perhaps some spacing, though I'm personally OK with it.

> diff --git a/crypto/testmgr.h b/crypto/testmgr.h
> index b5721e0..9688bfe 100644
> --- a/crypto/testmgr.h
> +++ b/crypto/testmgr.h
> @@ -1639,6 +1639,58 @@ static struct hash_testvec hmac_sha256_tv_template[] = {
>  	},
>  };
>  
> +#define CMAC_AES_TEST_VECTORS 4
> +
> +static struct hash_testvec aes_cmac128_tv_template[] = {
> +	{
> +		.key  = "\x2b\x7e\x15\x16\x28\xae\xd2\xa6\xab"
> +		"\xf7\x15\x88\x09\xcf\x4f\x3c",

There does seem to be some inconsistencies in the test vector
formatting, but it seems to be pretty common for the hex dumps to put 8
bytes in each part of the string, and to most line of the strings up.

Doing this alignment is how I found the missing \x in your first
submission.

> +		.plaintext = zeroed_string,
> +		.digest = "\xbb\x1d\x69\x29\xe9\x59\x37\x28\x7f"
> +		"\xa3\x7d\x12\x9b\x75\x67\x46",
> +		.psize   = 0,
> +		.ksize   = 16,
> +	},
> +
> +	{

The rest of the file uses "}, { " between test vectors.


Because you are working in the networking code, you should cc netdev --
they need to review the following hunks. I don't know what the
allocation policy is for adding algorithm numbers in pfkeyv2, but they
would know if you are creating a conflict with other work.

> diff --git a/include/uapi/linux/pfkeyv2.h b/include/uapi/linux/pfkeyv2.h
> index 0b80c80..d61898e 100644
> --- a/include/uapi/linux/pfkeyv2.h
> +++ b/include/uapi/linux/pfkeyv2.h
> @@ -296,6 +296,7 @@ struct sadb_x_kmaddress {
>  #define SADB_X_AALG_SHA2_512HMAC	7
>  #define SADB_X_AALG_RIPEMD160HMAC	8
>  #define SADB_X_AALG_AES_XCBC_MAC	9
> +#define SADB_X_AALG_AES_CMAC_MAC	10
>  #define SADB_X_AALG_NULL		251	/* kame */
>  #define SADB_AALG_MAX			251
>  
> diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
> index 4ce2d93..bd6f227 100644
> --- a/net/xfrm/xfrm_algo.c
> +++ b/net/xfrm/xfrm_algo.c
> @@ -265,6 +265,23 @@ static struct xfrm_algo_desc aalg_list[] = {
>  	}
>  },
>  {
> +	.name = "cmac(aes)",
> +
> +	.uinfo = {
> +		.auth = {
> +			.icv_truncbits = 96,
> +			.icv_fullbits = 128,
> +		}
> +	},
> +
> +	.desc = {
> +		.sadb_alg_id = SADB_X_AALG_AES_CMAC_MAC,
> +		.sadb_alg_ivlen = 0,
> +		.sadb_alg_minbits = 128,
> +		.sadb_alg_maxbits = 128
> +	}
> +},
> +{
>  	.name = "xcbc(aes)",
>  
>  	.uinfo = {
