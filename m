From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Fix vlan_gro_frags vs netpoll and bonding paths
Date: Sat, 28 Aug 2010 08:13:37 +0800
Message-ID: <20100828001337.GA1955@gondor.apana.org.au>
References: <20100827205042.GA13844@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:55002 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214Ab0H1ANn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 20:13:43 -0400
Content-Disposition: inline
In-Reply-To: <20100827205042.GA13844@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 27, 2010 at 10:50:42PM +0200, Jarek Poplawski wrote:
> After positive netpoll_rx_on() check in vlan_gro_receive() there is
> skipped part of the "common" GRO_NORMAL path, especially "pull:" in
> dev_gro_receive(), where at least eth header should be copied for
> entirely paged skbs. So, eth_type_trans() can read zeroed header only.

Right, thanks for catching this.

> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 01ddb04..58289fe 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -139,13 +139,19 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
>  	if (!skb)
>  		return GRO_DROP;
>  
> -	if (netpoll_rx_on(skb)) {
> -		skb->protocol = eth_type_trans(skb, skb->dev);
> +	/*
> +	 * Complete the eth header here, mainly for skb_bond_should_drop(),
> +	 * and for netpoll_rx_on() btw.
> +	 */
> +	skb_gro_pull_in(skb);
> +	skb->protocol = eth_type_trans(skb, skb->dev);
> +	skb_gro_pull(skb, -ETH_HLEN);

But this code should go into the netpoll (i.e., slow-path) case
only so as not to impede performance.

Also, we need to fix this for the non-VLAN case as well.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
