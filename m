From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [3/3] gso: Handle malicious GRO packets without crashing
Date: Thu, 7 Nov 2013 18:18:35 +0000
Message-ID: <1383848315.3802.8.camel@bwh-desktop.uk.level5networks.com>
References: <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
	 <20131107062234.GA31156@gondor.apana.org.au>
	 <20131107070335.GA31638@gondor.apana.org.au>
	 <20131107070647.GB31638@gondor.apana.org.au>
	 <20131107070847.GC31638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	<christoph.paasch@uclouvain.be>, <netdev@vger.kernel.org>,
	<hkchu@google.com>, <mwdalton@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6228 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562Ab3KGSSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 13:18:39 -0500
In-Reply-To: <20131107070847.GC31638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 15:08 +0800, Herbert Xu wrote:
> As virtio_net can now generate GRO frag_list packets without
> sufficient verification, we need to handle malicious GRO packets
> thrown at us.
> 
> This patch converts to affected BUG_ONs in skb_segment to rate-
> limited warnings.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index bcc3f1c..fb1106d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2881,7 +2881,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  			while (tail->next)
>  				tail = tail->next;
>  
> -			BUG_ON(fskb && tail->len != len + doffset);

Oh well, disregard my previous request for a comment.

> +			if (fskb && tail->len != len + doffset) {
> +				net_warn_ratelimited(
> +					"skb_segment: "
> +					"illegal GSO fragment: %u %u\n",
> +					tail->len, len + doffset);
> +				kfree(nskb);

kfree_skb()

> +				err = -EINVAL;
> +				goto err;
> +			}
>  
>  			len = nskb->len;
>  			kfree(nskb);
> @@ -2929,7 +2937,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  		if (pos < offset + len) {
>  			struct sk_buff *fskb2 = fskb;
>  
> -			BUG_ON(pos + fskb->len != offset + len);
> +			if (pos + fskb->len != offset + len) {
> +				net_warn_ratelimited(
> +					"skb_segment: "
> +					"illegal GSO trailer: %u %u\n",
> +					pos + fskb->len, offset + len);
> +				kfree(nskb);

kfree_skb()

> +				err = -EINVAL;
> +				goto err;
> +			}
>  
>  			pos += fskb->len;
>  			fskb = fskb->next;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
