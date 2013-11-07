From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 23:11:02 -0800
Message-ID: <1383808262.9412.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64673 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab3KGHLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:11:04 -0500
Received: by mail-pd0-f179.google.com with SMTP id y10so179292pdj.24
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 23:11:04 -0800 (PST)
In-Reply-To: <20131107004339.GA28156@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 08:43 +0800, Herbert Xu wrote:

> -		if (fskb != skb_shinfo(skb)->frag_list)
> -			goto perform_csum_check;
> +		if (fskb != skb_shinfo(skb)->frag_list) {
> +			struct sk_buff *nsegs;
> +
> +			if (nskb->len == len + doffset)
> +				goto perform_csum_check;
> +
> +			if (skb_has_frag_list(nskb)) {
> +				net_warn_ratelimited(
> +					"skb_segment: "
> +					"nested frag_list detected\n");
> +				kfree(nskb);
> +				err = -EINVAL;
> +				goto err;
> +			}
> +
> +			__skb_pull(nskb, doffset);
> +			skb_shinfo(nskb)->gso_size = mss;
> +			nsegs = skb_segment(nskb, features);
> +

This still assumes each skb found in frag_list has a exact multiple of
@mss bytes, and that the initial skb also ends at a right boundary.
