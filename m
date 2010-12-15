From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv2] fragment locally-generated IPsec6 packets that need
	it
Date: Wed, 15 Dec 2010 08:59:41 +0800
Message-ID: <20101215005941.GA20448@gondor.apana.org.au>
References: <1292351554.4720.7.camel@IBM-1B506CFC885>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57965 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab0LOA7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 19:59:47 -0500
Content-Disposition: inline
In-Reply-To: <1292351554.4720.7.camel@IBM-1B506CFC885>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 10:32:34AM -0800, David L Stevens wrote:
>
> @@ -88,8 +89,17 @@ static int xfrm6_output_finish(struct sk
>  	return xfrm_output(skb);
>  }
>  
> -int xfrm6_output(struct sk_buff *skb)
> +static int __xfrm6_output(struct sk_buff *skb)
>  {
>  	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL,
>  		       skb_dst(skb)->dev, xfrm6_output_finish);
>  }
> +
> +int xfrm6_output(struct sk_buff *skb)
> +{
> +	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
> +		dst_allfrag(skb_dst(skb))) {
> +			return ip6_fragment(skb, __xfrm6_output);
> +	}
> +	return __xfrm6_output(skb);
> +}

Oops, I didn't notice this the first time around.  The fragmentation
call should occur after POST_ROUTING.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
