From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [BUG] eth_type_trans() can access stale data
Date: Wed, 15 Jan 2014 00:21:09 +0000
Message-ID: <1389745269.2025.228.camel@bwh-desktop.uk.level5networks.com>
References: <1389743541.31367.279.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39634 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbaAOAVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:21:14 -0500
In-Reply-To: <1389743541.31367.279.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 15:52 -0800, Eric Dumazet wrote:
> Following code :
> 
> if (unlikely(skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF))
> 	return htons(ETH_P_802_3);
> 
> expects the additional bytes are in skb->head
>
> I do not think all eth_type_trans() are ready for a pskb_may_pull()
> (I am too lazy to perform a whole check)
> 
> Would following workaround be OK ?

It seems to be an improvement, as LLC packets will no longer falsely be
marked as Netware raw 802.3.  You don't fix errors in the other
direction, which should be more common, but the lack of bug reports
about that suggests that no-one is using the old Netware protocol any
more, or they're being very careful about which drivers they use.

Ben.

> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 8f032bae60ad..d95403098f09 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -194,7 +194,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>  	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
>  	 *      won't work for fault tolerant netware but does for the rest.
>  	 */
> -	if (unlikely(skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF))
> +	if (unlikely(skb_headlen(skb) >= 2 &&
> +		     *(unsigned short *)(skb->data) == 0xFFFF))
>  		return htons(ETH_P_802_3);
>  
>  	/*



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
