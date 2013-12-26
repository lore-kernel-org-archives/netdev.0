From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fix tunneled VM traffic over hw
 VXLAN/GRE GSO NIC
Date: Thu, 26 Dec 2013 13:10:59 -0500 (EST)
Message-ID: <20131226.131059.774046353564501606.davem@davemloft.net>
References: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org,
	joseph.gasparakis@intel.com, or.gerlitz@gmail.com
To: weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab3LZSLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:11:04 -0500
In-Reply-To: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei-Chun Chao <weichunc@plumgrid.com>
Date: Wed, 18 Dec 2013 11:02:48 -0800

> This is also seen on 'net'.
> 
> VM to VM GSO traffic is broken if it goes through VXLAN or GRE
> tunnel and the physical NIC on the host supports hardware VXLAN/GRE
> GSO offload (e.g. bnx2x and next-gen mlx4).
> 
> Two issues -
> (VXLAN) VM traffic has SKB_GSO_DODGY and SKB_GSO_UDP_TUNNEL with
> SKB_GSO_TCP/UDP set depending on the inner protocol. GSO header
> integrity check fails in udp4_ufo_fragment if inner protocol is
> TCP. Also gso_segs is calculated incorrectly using skb->len that
> includes tunnel header. Fix: robust check should only be applied
> to the inner packet.
> 
> (VXLAN & GRE) Once GSO header integrity check passes, NULL segs
> is returned and the original skb is sent to hardware. However the
> tunnel header is already pulled. Fix: tunnel header needs to be
> restored so that hardware can perform GSO properly on the original
> packet.
> 
> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>

I'd like to see some changes to this patch:

> @@ -73,7 +74,19 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>  	/* segment inner packet. */
>  	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
>  	segs = skb_mac_gso_segment(skb, enc_features);
> -	if (!segs || IS_ERR(segs))
> +	/* Verifying header integrity only. */
> +	if (!segs) {
> +		skb->protocol = protocol;
> +		skb->encapsulation = 1;
> +		skb_push(skb, ghl);
> +		skb_reset_transport_header(skb);
> +		skb->mac_header = mac_offset;
> +		skb->network_header = skb->mac_header + mac_len;
> +		skb->mac_len = mac_len;
> +		goto out;
> +	}
> +
> +	if (IS_ERR(segs))
>  		goto out;
>  
>  	skb = segs;
 ...
> @@ -2493,7 +2494,19 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
>  	/* segment inner packet. */
>  	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
>  	segs = skb_mac_gso_segment(skb, enc_features);
> -	if (!segs || IS_ERR(segs))
> +	/* Verifying header integrity only. */
> +	if (!segs) {
> +		skb->encapsulation = 1;
> +		skb_push(skb, tnl_hlen);
> +		skb_reset_transport_header(skb);
> +		skb->mac_header = mac_offset;
> +		skb->network_header = skb->mac_header + mac_len;
> +		skb->mac_len = mac_len;
> +		skb->protocol = protocol;
> +		goto out;
> +	}
> +

These two code blocks are identical, please make a helper function that
does something like:

static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
					int pulled_hlen, u16 mac_offset, int mac_len)
{
	skb->protocol = protocol;
	skb->encapsulation = 1;
	skb_push(skb, pulled_hlen);
	skb_reset_transport_header(skb);
	skb->mac_header = mac_offset;
	skb->network_header = skb->mac_header + mac_len;
	skb->mac_len = mac_len;
}

And call it from the two spots above.

Secondly, in gre_gso_segment(), we clear skb->encapsulation and set the
skb->protocol too early, for if:

	if (unlikely(!pskb_may_pull(skb, ghl)))
		goto out;

fails, we will not unwind those changes.  I'd suggest simply moving the:

	skb->protocol = greh->protocol;
	skb->encapsulation = 0;

after the pskb_may_pull() check.  That way this function will leave the
skb unmodified if the pskb_may_pull() fails.

skb_udp_tunnel_segment() already gets this right.

I'd like to apply this to 'net' so please make your patch against that
tree, thanks.
