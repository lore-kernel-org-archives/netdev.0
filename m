From: Simon Horman <horms@verge.net.au>
Subject: Re: macvlan: Move skb_clone check closer to call
Date: Tue, 10 Sep 2013 10:38:10 +0900
Message-ID: <20130910013810.GA28966@verge.net.au>
References: <20130907022711.GA22613@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44764 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab3IJBiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 21:38:13 -0400
Content-Disposition: inline
In-Reply-To: <20130907022711.GA22613@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 07, 2013 at 12:27:11PM +1000, Herbert Xu wrote:
> Currently macvlan calls skb_clone in macvlan_broadcast but checks
> for a NULL return in macvlan_broadcast_one instead.  This is
> needlessly confusing and may lead to bugs introduced later.
> 
> This patch moves the error check to where the skb_clone call is.
> 
> The only other caller of macvlan_broadcast_one never passes in a
> NULL value so it doesn't need the check either.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This seems good to me as macvlan_handle_frame(), which is
the only other caller of macvlan_broadcast_one(), already checks
that skb is non-NULL before calling macvlan_handle_frame().

Reviewed-by: Simon Horman <horms@verge.net.au>

> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 64dfaa3..9bf46bd 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -118,8 +118,6 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
>  				 const struct ethhdr *eth, bool local)
>  {
>  	struct net_device *dev = vlan->dev;
> -	if (!skb)
> -		return NET_RX_DROP;
>  
>  	if (local)
>  		return vlan->forward(dev, skb);
> @@ -171,9 +169,13 @@ static void macvlan_broadcast(struct sk_buff *skb,
>  			hash = mc_hash(vlan, eth->h_dest);
>  			if (!test_bit(hash, vlan->mc_filter))
>  				continue;
> +
> +			err = NET_RX_DROP;
>  			nskb = skb_clone(skb, GFP_ATOMIC);
> -			err = macvlan_broadcast_one(nskb, vlan, eth,
> -					 mode == MACVLAN_MODE_BRIDGE);
> +			if (likely(nskb))
> +				err = macvlan_broadcast_one(
> +					nskb, vlan, eth,
> +					mode == MACVLAN_MODE_BRIDGE);
>  			macvlan_count_rx(vlan, skb->len + ETH_HLEN,
>  					 err == NET_RX_SUCCESS, 1);
>  		}
> 
> Thanks,
> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
