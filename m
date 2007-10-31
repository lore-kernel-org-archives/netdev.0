From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 08:46:21 +0100
Message-ID: <20071031074621.GB5059@kernel.dk>
References: <20071030.204002.193703502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:6652 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbXJaHtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 03:49:01 -0400
Content-Disposition: inline
In-Reply-To: <20071030.204002.193703502.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30 2007, David Miller wrote:
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 91cd8f0..4a8aa94 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -211,8 +211,8 @@ encryptor(struct scatterlist *sg, void *data)
>  	if (thislen == 0)
>  		return 0;
>  
> -	sg_mark_end(desc->infrags, desc->fragno);
> -	sg_mark_end(desc->outfrags, desc->fragno);
> +	__sg_mark_end(desc->infrags, desc->fragno);
> +	__sg_mark_end(desc->outfrags, desc->fragno);
>  
>  	ret = crypto_blkcipher_encrypt_iv(&desc->desc, desc->outfrags,
>  					  desc->infrags, thislen);
> @@ -293,7 +293,7 @@ decryptor(struct scatterlist *sg, void *data)
>  	if (thislen == 0)
>  		return 0;
>  
> -	sg_mark_end(desc->frags, desc->fragno);
> +	__sg_mark_end(desc->frags, desc->fragno);
>  
>  	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
>  					  desc->frags, thislen);

Hmm? These don't seem right. It also has a weird code sequence:

...
        sg_mark_end(&desc->infrags[desc->fragno - 1]);
        sg_mark_end(&desc->outfrags[desc->fragno - 1]);

        ret = crypto_blkcipher_encrypt_iv(&desc->desc, desc->outfrags,
                                          desc->infrags, thislen);
        if (ret)
                return ret;

        sg_init_table(desc->infrags, 4);
        sg_init_table(desc->outfrags, 4);
...

Did something go wrong there?

-- 
Jens Axboe

