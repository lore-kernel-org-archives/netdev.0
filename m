From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH 06/11] esp4: Add support for IPsec extended
	sequence numbers
Date: Thu, 2 Dec 2010 15:29:47 +0800
Message-ID: <20101202072947.GA22998@gondor.apana.org.au>
References: <20101122102455.GC1868@secunet.com> <20101122103014.GI1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122103014.GI1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 22, 2010 at 11:30:14AM +0100, Steffen Klassert wrote:
>
> @@ -205,11 +228,18 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
>  	skb_to_sgvec(skb, sg,
>  		     esph->enc_data + crypto_aead_ivsize(aead) - skb->data,
>  		     clen + alen);
> -	sg_init_one(asg, esph, sizeof(*esph));
> +
> +	if ((x->props.flags & XFRM_STATE_ESN)) {
> +		sg_init_table(asg, 2);
> +		sg_set_buf(asg, esph, sizeof(*esph));
> +		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
> +		sg_set_buf(asg + 1, seqhi, seqhilen);
> +	} else
> +		sg_init_one(asg, esph, sizeof(*esph));

I think this is wrong for AEAD algorithms.  You want the sequence
number in network byte order for them so the high bits need to be
inserted into the middle of the ESP header.

The other problem is that you're currently requiring the authencesn
user to provide two SG entries which is fine for now.  However,
since this might be exported to user-space in future, authenecesn
shouldn't really rely on that, or at least it shouldn't BUG.

So one solution is to do it based on bytes in authencesn.  That is,
your associated input should always be 12 bytes long, and then you
simply construct a new SG list for your actual processing with the
middle 4 bytes taken out.

For IPsec it could just provide an SG list with three entries,
of 4 bytes each.

Of course for simplicity, you could require this to be the case in
authencesn and return -EINVAL (not BUG :) if it's not the case.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
