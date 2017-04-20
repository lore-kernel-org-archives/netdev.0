From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: calculate L4 checksums also for GSO case
 before encrypting packets
Date: Thu, 20 Apr 2017 11:47:43 +0200
Message-ID: <20170420094743.GI2649@secunet.com>
References: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
 <20170411070755.GW5092@secunet.com>
 <CAMQa7Biajree5Kc1fOWQN42R1UDDGp7ZevZZRtUMZOKDWTk-Vw@mail.gmail.com>
 <20170418090919.GD30104@secunet.com>
 <CAMQa7Bimd378QJgsv6yBP0ULH+__C9gjjcXa39wx1z7p_9mT=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ansis Atteka <aatteka@ovn.org>, <netdev@vger.kernel.org>
To: Ansis Atteka <ansisatteka@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:53488 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944144AbdDTJry (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 05:47:54 -0400
Content-Disposition: inline
In-Reply-To: <CAMQa7Bimd378QJgsv6yBP0ULH+__C9gjjcXa39wx1z7p_9mT=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 07:10:03PM -0700, Ansis Atteka wrote:
> 
> However, after taking pointers from your patch I came up with this one
> that may solve this problem once and for all (note, that I was seeing
> this bug only with ixgbe NIC that supports tx csum offloads). I hope
> it does not break any other IPsec tests that you have.
> 
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index b2be1d9..7812501 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -29,6 +29,7 @@ static struct sk_buff
> *__skb_udp_tunnel_segment(struct sk_buff *skb,
>         u16 mac_len = skb->mac_len;
>         int udp_offset, outer_hlen;
>         __wsum partial;
> +       bool need_ipsec;
> 
>         if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
>                 goto out;
> @@ -62,8 +63,10 @@ static struct sk_buff
> *__skb_udp_tunnel_segment(struct sk_buff *skb,
> 
>         ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
> 
> +       need_ipsec = skb_dst(skb) && dst_xfrm(skb_dst(skb));
>         /* Try to offload checksum if possible */
>         offload_csum = !!(need_csum &&
> +                         !need_ipsec &&
>                           (skb->dev->features &
>                            (is_ipv6 ? (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM) :
>                                       (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM))));

This looks good, but we should fix udp4_ufo_fragment() too.

Thanks!
