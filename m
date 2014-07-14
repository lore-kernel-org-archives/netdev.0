From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH 4/4] udp: Move udp_tunnel_segment into udp_offload.c
Date: Mon, 14 Jul 2014 10:23:59 +0530
Message-ID: <53C36267.8030404@gmail.com>
References: <alpine.DEB.2.02.1407131940460.24734@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:64789 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbaGNEzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 00:55:11 -0400
Received: by mail-pd0-f181.google.com with SMTP id v10so4552667pde.40
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 21:55:11 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1407131940460.24734@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2014 08:19 AM, Tom Herbert wrote:
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>   net/ipv4/udp.c         | 76 --------------------------------------------------
>   net/ipv4/udp_offload.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 76 insertions(+), 76 deletions(-)
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index ac30e10..f6dfe52 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2522,79 +2522,3 @@ void __init udp_init(void)
>   	sysctl_udp_rmem_min = SK_MEM_QUANTUM;
>   	sysctl_udp_wmem_min = SK_MEM_QUANTUM;
>   }
> -
> -struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
> -				       netdev_features_t features)
> -{
> -	struct sk_buff *segs = ERR_PTR(-EINVAL);
> -	u16 mac_offset = skb->mac_header;
> -	int mac_len = skb->mac_len;
> -	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
> -	__be16 protocol = skb->protocol;
> -	netdev_features_t enc_features;
> -	int udp_offset, outer_hlen;
> -	unsigned int oldlen;
> -	bool need_csum;
> -
> -	oldlen = (u16)~skb->len;
> -
> -	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
> -		goto out;
> -
> -	skb->encapsulation = 0;
> -	__skb_pull(skb, tnl_hlen);
> -	skb_reset_mac_header(skb);
> -	skb_set_network_header(skb, skb_inner_network_offset(skb));
> -	skb->mac_len = skb_inner_network_offset(skb);
> -	skb->protocol = htons(ETH_P_TEB);
> -
> -	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
> -	if (need_csum)
> -		skb->encap_hdr_csum = 1;
> -
> -	/* segment inner packet. */
> -	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
> -	segs = skb_mac_gso_segment(skb, enc_features);
> -	if (!segs || IS_ERR(segs)) {
> -		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
> -				     mac_len);
> -		goto out;
> -	}
> -
> -	outer_hlen = skb_tnl_header_len(skb);
> -	udp_offset = outer_hlen - tnl_hlen;
> -	skb = segs;
> -	do {
> -		struct udphdr *uh;
> -		int len;
> -
> -		skb_reset_inner_headers(skb);
> -		skb->encapsulation = 1;
> -
> -		skb->mac_len = mac_len;
> -
> -		skb_push(skb, outer_hlen);
> -		skb_reset_mac_header(skb);
> -		skb_set_network_header(skb, mac_len);
> -		skb_set_transport_header(skb, udp_offset);
> -		len = skb->len - udp_offset;
> -		uh = udp_hdr(skb);
> -		uh->len = htons(len);
> -
> -		if (need_csum) {
> -			__be32 delta = htonl(oldlen + len);
> -
> -			uh->check = ~csum_fold((__force __wsum)
> -					       ((__force u32)uh->check +
> -						(__force u32)delta));
> -			uh->check = gso_make_checksum(skb, ~uh->check);
> -
> -			if (uh->check == 0)
> -				uh->check = CSUM_MANGLED_0;
> -		}
> -
> -		skb->protocol = protocol;
> -	} while ((skb = skb->next));
> -out:
> -	return segs;
> -}
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 546d2d4..4807544 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -47,6 +47,82 @@ static int udp4_ufo_send_check(struct sk_buff *skb)
>   	return 0;
>   }
>   
> +struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
> +				       netdev_features_t features)
> +{
> +	struct sk_buff *segs = ERR_PTR(-EINVAL);
> +	u16 mac_offset = skb->mac_header;
> +	int mac_len = skb->mac_len;

skb->mac_len is u16... But we are storing in int...?

> +	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
> +	__be16 protocol = skb->protocol;
> +	netdev_features_t enc_features;
> +	int udp_offset, outer_hlen;
> +	unsigned int oldlen;
> +	bool need_csum;
> +
> +	oldlen = (u16)~skb->len;
> +
> +	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
> +		goto out;
> +
> +	skb->encapsulation = 0;
> +	__skb_pull(skb, tnl_hlen);
> +	skb_reset_mac_header(skb);
> +	skb_set_network_header(skb, skb_inner_network_offset(skb));
> +	skb->mac_len = skb_inner_network_offset(skb);
> +	skb->protocol = htons(ETH_P_TEB);
> +
> +	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
> +	if (need_csum)
> +		skb->encap_hdr_csum = 1;
> +
> +	/* segment inner packet. */
> +	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
> +	segs = skb_mac_gso_segment(skb, enc_features);
> +	if (!segs || IS_ERR(segs)) {
> +		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
> +				     mac_len);
> +		goto out;
> +	}
> +
> +	outer_hlen = skb_tnl_header_len(skb);
> +	udp_offset = outer_hlen - tnl_hlen;
> +	skb = segs;
> +	do {
> +		struct udphdr *uh;
> +		int len;
> +
> +		skb_reset_inner_headers(skb);
> +		skb->encapsulation = 1;
> +
> +		skb->mac_len = mac_len;
> +
> +		skb_push(skb, outer_hlen);
> +		skb_reset_mac_header(skb);
> +		skb_set_network_header(skb, mac_len);
> +		skb_set_transport_header(skb, udp_offset);
> +		len = skb->len - udp_offset;
> +		uh = udp_hdr(skb);
> +		uh->len = htons(len);
> +
> +		if (need_csum) {
> +			__be32 delta = htonl(oldlen + len);
> +
> +			uh->check = ~csum_fold((__force __wsum)
> +					       ((__force u32)uh->check +
> +						(__force u32)delta));
> +			uh->check = gso_make_checksum(skb, ~uh->check);
> +
> +			if (uh->check == 0)
> +				uh->check = CSUM_MANGLED_0;
> +		}
> +
> +		skb->protocol = protocol;
> +	} while ((skb = skb->next));
> +out:
> +	return segs;
> +}
> +
>   static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>   					 netdev_features_t features)
>   {


-- 
Regards,
Varka Bhadram.
