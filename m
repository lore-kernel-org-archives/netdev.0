From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [2/3] gso: Handle new frag_list of frags GRO packets
Date: Thu, 7 Nov 2013 18:16:44 +0000
Message-ID: <1383848204.3802.6.camel@bwh-desktop.uk.level5networks.com>
References: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
	 <20131107062234.GA31156@gondor.apana.org.au>
	 <20131107070335.GA31638@gondor.apana.org.au>
	 <20131107070647.GB31638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	<christoph.paasch@uclouvain.be>, <netdev@vger.kernel.org>,
	<hkchu@google.com>, <mwdalton@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6184 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918Ab3KGSQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 13:16:49 -0500
In-Reply-To: <20131107070647.GB31638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 15:06 +0800, Herbert Xu wrote:
> Recently GRO started generating packets with frag_lists of frags.
> This was not handled by GSO, thus leading to a crash.
> 
> Thankfully these packets are of a regular form and are easy to
> handle.  This patch handles them by calling skb_segment for each 
> frag_list entry.  The depth of recursion is limited to just one.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 88b7dc6..bcc3f1c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
[...]
> @@ -2855,8 +2853,40 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  						 nskb->data - tnl_hlen,
>  						 doffset + tnl_hlen);
>  
> -		if (fskb != skb_shinfo(skb)->frag_list)
> -			goto perform_csum_check;
> +		if (fskb != skb_shinfo(skb)->frag_list) {
> +			struct sk_buff *nsegs;
> +
> +			if (nskb->len == len + doffset)
> +				goto perform_csum_check;
> +
> +			SKB_FRAG_ASSERT(nskb);
> +
> +			__skb_pull(nskb, doffset);
> +			skb_shinfo(nskb)->gso_size = mss;
> +			nsegs = skb_segment(nskb, features);
> +
> +			err = PTR_ERR(nsegs);
> +			if (IS_ERR(nsegs)) {
> +				kfree(nskb);

Should be kfree_skb().

> +				goto err;
> +			}
> +			err = -ENOMEM;

It would be clearer to put this in front of the 'err' label:

err_nomem:
	err = -ENOMEM;

and change the allocation failure paths to goto err_nomem.

> +			if (segs)
> +				tail->next = nsegs;
> +			else
> +				segs = nsegs;
> +
> +			tail = nsegs;
> +			while (tail->next)
> +				tail = tail->next;
> +
> +			BUG_ON(fskb && tail->len != len + doffset);

Deserves a comment, maybe?

> +			len = nskb->len;
> +			kfree(nskb);
> +			continue;
> +		}
>  
>  		if (!sg) {
>  			nskb->ip_summed = CHECKSUM_NONE;

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
