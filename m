From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Tue, 05 Nov 2013 17:45:47 -0800
Message-ID: <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35475 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab3KFBpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 20:45:51 -0500
Received: by mail-pa0-f42.google.com with SMTP id kp14so9856928pab.29
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 17:45:49 -0800 (PST)
In-Reply-To: <20131106013038.GA14894@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 09:30 +0800, Herbert Xu wrote:
> Here is a totally untested patch that tries to trivially process
> these new frags + frag_list skbs.  It should actually be trivial
> to make this generate TSO packets by just adding a gso_ok check
> and short-circuit.
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3735fad..ec8e8bc 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2816,7 +2816,24 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  			hsize = len;
>  
>  		if (!hsize && i >= nfrags) {
> -			BUG_ON(fskb->len != len);
> +			if (fskb->len != len) {
> +				SKB_FRAG_ASSERT(fskb);
> +
> +				nskb = skb_segment(fskb, features);
> +
> +				err = PTR_ERR(nskb);
> +				if (IS_ERR(nskb))
> +					goto err;
> +				err = -ENOMEM;
> +
> +				if (segs)
> +					tail->next = nskb;
> +				else
> +					segs = nskb;
> +				tail = nskb;
> +				while (tail->next)
> +					tail = tail->next;
> +			}
>  
>  			pos += len;
>  			nskb = skb_clone(fskb, GFP_ATOMIC);
> 
> Thanks,

Hmm, I do not think fskb has the headers in the general case.

It might work in the GRO case only.
