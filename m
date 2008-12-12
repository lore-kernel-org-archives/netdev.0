From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/8] net: Add frag_list support to skb_segment
Date: Fri, 12 Dec 2008 22:46:18 +0300
Message-ID: <20081212194618.GA27281@ioremap.net>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cv-0000qk-Ec@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:45378 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702AbYLLTqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 14:46:21 -0500
Content-Disposition: inline
In-Reply-To: <E1LB0cv-0000qk-Ec@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Couple of comments below.

On Fri, Dec 12, 2008 at 04:31:49PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> @@ -2317,9 +2317,34 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
>  		if (hsize > len || !sg)
>  			hsize = len;
>  
> -		nskb = alloc_skb(hsize + doffset + headroom, GFP_ATOMIC);
> -		if (unlikely(!nskb))
> -			goto err;
> +		if (!hsize && i >= nfrags) {
> +			BUG_ON(fskb->len != len);
> +
> +			pos += len;
> +			nskb = skb_clone(fskb, GFP_ATOMIC);
> +			fskb = fskb->next;
> +
> +			if (unlikely(!nskb))
> +				goto err;
> +
> +			hsize = skb_end_pointer(nskb) - nskb->head;
> +			if (skb_cow_head(nskb, doffset + headroom))
> +				goto err;

This should free nskb first.

> +			nskb->truesize += skb_end_pointer(nskb) - nskb->head -
> +					  hsize;
> +			skb_release_head_state(nskb);
> +			__skb_push(nskb, doffset);
> +		} else {
> +			nskb = alloc_skb(hsize + doffset + headroom,
> +					 GFP_ATOMIC);
> +
> +			if (unlikely(!nskb))
> +				goto err;
> +

The same.

> +			skb_reserve(nskb, headroom);
> +			__skb_put(nskb, doffset);
> +		}
>  
>  		if (segs)
>  			tail->next = nskb;
> @@ -2330,13 +2355,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
>  		__copy_skb_header(nskb, skb);
>  		nskb->mac_len = skb->mac_len;
>  
> -		skb_reserve(nskb, headroom);
>  		skb_reset_mac_header(nskb);
>  		skb_set_network_header(nskb, skb->mac_len);
>  		nskb->transport_header = (nskb->network_header +
>  					  skb_network_header_len(skb));
> -		skb_copy_from_linear_data(skb, skb_put(nskb, doffset),
> -					  doffset);
> +		skb_copy_from_linear_data(skb, nskb->data, doffset);
> +
> +		if (pos >= offset + len)
> +			continue;
> +
>  		if (!sg) {
>  			nskb->ip_summed = CHECKSUM_NONE;
>  			nskb->csum = skb_copy_and_csum_bits(skb, offset,
> @@ -2346,14 +2373,11 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
>  		}
>  
>  		frag = skb_shinfo(nskb)->frags;
> -		k = 0;
>  
>  		skb_copy_from_linear_data_offset(skb, offset,
>  						 skb_put(nskb, hsize), hsize);
>  
> -		while (pos < offset + len) {
> -			BUG_ON(i >= nfrags);
> -
> +		while (pos < offset + len && i < nfrags) {
>  			*frag = skb_shinfo(skb)->frags[i];
>  			get_page(frag->page);
>  			size = frag->size;
> @@ -2363,20 +2387,38 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
>  				frag->size -= offset - pos;
>  			}
>  
> -			k++;
> +			skb_shinfo(nskb)->nr_frags++;
>  
>  			if (pos + size <= offset + len) {
>  				i++;
>  				pos += size;
>  			} else {
>  				frag->size -= pos + size - (offset + len);
> -				break;
> +				goto skip_fraglist;
>  			}
>  
>  			frag++;
>  		}
>  
> -		skb_shinfo(nskb)->nr_frags = k;
> +		if (pos < offset + len) {
> +			struct sk_buff *fskb2 = fskb;
> +
> +			BUG_ON(pos + fskb->len != offset + len);
> +
> +			pos += fskb->len;
> +			fskb = fskb->next;
> +
> +			if (fskb2->next) {
> +				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
> +				if (!fskb2)
> +					goto err;
> +			} else
> +				skb_get(fskb2);
> +
> +			skb_shinfo(nskb)->frag_list = fskb2;

Is it guaranteed that nskb does not have frags here?

-- 
	Evgeniy Polyakov
