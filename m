From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] v2 GRE: Add segmentation offload for GRE
Date: Thu, 24 Jan 2013 15:29:59 -0800
Message-ID: <1359070199.12374.2557.camel@edumazet-glaptop>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:62315 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab3AXXaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 18:30:03 -0500
Received: by mail-da0-f49.google.com with SMTP id v40so4505676dad.36
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 15:30:02 -0800 (PST)
In-Reply-To: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 14:16 -0800, Pravin B Shelar wrote:
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> Fixed according to comments from Jesse and Eric.
>  - Factored a MAC layer handler out of skb_gso_segment().
>  - Eliminated copy operation from gre_gso_segment().
>  - Refresh header pointer after pskb_may_pull().

Seems nice !

> +	if (skb_is_gso(skb)) {
> +		err = skb_unclone(skb, GFP_ATOMIC);
> +		if (unlikely(err))
> +			goto error;
> +		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
> +		return skb;
> +	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		/* Pages aren't locked and could change at any time.
> +		 * If this happens after we compute the checksum, the
> +		 * checksum will be wrong.  We linearize now to avoid
> +		 * this problem.
> +		 */
> +		if (skb_is_nonlinear(skb)) {
> +			err = __skb_linearize(skb);
> +			if (unlikely(err))
> +				goto error;
> +		}
> +
> +		err = skb_checksum_help(skb);
> +		if (unlikely(err))
> +			goto error;
> +	}
> +

I really don't understand why you put chunk this in this patch.

Packet being GSO or not, the underlying problem still remains.

This must be addressed separately and at a different layer.

(in skb_checksum_help() most probably)

If the packet is GSO and we compute checksum in software,
then we also have to copy all frags that could potentially
be overwritten.


> +	skb->ip_summed = CHECKSUM_NONE;
> +
> +	return skb;
> +
> +error:
> +	kfree_skb(skb);
> +	return ERR_PTR(err);
> +}
> +
>  static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct ip_tunnel *tunnel = netdev_priv(dev);
> @@ -751,10 +787,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  	__be32 dst;
>  	int    mtu;
>  	u8     ttl;
> -
> -	if (skb->ip_summed == CHECKSUM_PARTIAL &&
> -	    skb_checksum_help(skb))
> -		goto tx_error;
> +	int pkt_len;
> +	struct pcpu_tstats *tstats;
> +	int err;
>  
>  	if (dev->type == ARPHRD_ETHER)
>  		IPCB(skb)->flags = 0;
> @@ -852,13 +887,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  
>  	if (skb->protocol == htons(ETH_P_IP)) {
>  		df |= (old_iph->frag_off&htons(IP_DF));
> -
> -		if ((old_iph->frag_off&htons(IP_DF)) &&
> -		    mtu < ntohs(old_iph->tot_len)) {
> -			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
> -			ip_rt_put(rt);
> -			goto tx_error;
> -		}

Not clear why this chunk can be safely removed, even for non GSO
packet ?
