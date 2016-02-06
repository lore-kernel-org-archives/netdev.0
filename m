From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 01/10] net: Drop unecessary enc_features variable
 from tunnel segmentation functions
Date: Sat, 6 Feb 2016 12:38:33 -0800
Message-ID: <CALx6S36uPZvk0zwgMoCVZ9-_Ke20-iK1Fnw-ae60HENJ14TDQw@mail.gmail.com>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
	<20160205232731.18529.97609.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33100 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbcBFUid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:38:33 -0500
Received: by mail-ig0-f174.google.com with SMTP id y8so7866318igp.0
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:38:33 -0800 (PST)
In-Reply-To: <20160205232731.18529.97609.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 5, 2016 at 3:27 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> The enc_features variable isn't necessary since features isn't used
> anywhere after we create enc_features so instead just use a destructive AND
> on features itself and save ourselves the variable declaration.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/ipv4/gre_offload.c |    6 +++---
>  net/ipv4/udp_offload.c |    6 +++---
>  2 files changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index 5a8ee3282550..02cb1a416c7d 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -19,7 +19,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>                                        netdev_features_t features)
>  {
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
> -       netdev_features_t enc_features;
>         int ghl;
>         struct gre_base_hdr *greh;
>         u16 mac_offset = skb->mac_header;
> @@ -68,9 +67,10 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         skb_set_network_header(skb, skb_inner_network_offset(skb));
>         skb->mac_len = skb_inner_network_offset(skb);
>
> +       features &= skb->dev->hw_enc_features;
> +
>         /* segment inner packet. */
> -       enc_features = skb->dev->hw_enc_features & features;
> -       segs = skb_mac_gso_segment(skb, enc_features);
> +       segs = skb_mac_gso_segment(skb, features);
>         if (IS_ERR_OR_NULL(segs)) {
>                 skb_gso_error_unwind(skb, protocol, ghl, mac_offset, mac_len);
>                 goto out;
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 4c519c1dc161..ce64c2b7ba55 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -37,7 +37,6 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>         int mac_len = skb->mac_len;
>         int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
>         __be16 protocol = skb->protocol;
> -       netdev_features_t enc_features;
>         int udp_offset, outer_hlen;
>         unsigned int oldlen;
>         bool need_csum = !!(skb_shinfo(skb)->gso_type &
> @@ -65,9 +64,10 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>                            (skb->dev->features & (is_ipv6 ?
>                             NETIF_F_IPV6_CSUM : NETIF_F_IP_CSUM))));
>
> +       features &= skb->dev->hw_enc_features;
> +
>         /* segment inner packet. */
> -       enc_features = skb->dev->hw_enc_features & features;
> -       segs = gso_inner_segment(skb, enc_features);
> +       segs = gso_inner_segment(skb, features);
>         if (IS_ERR_OR_NULL(segs)) {
>                 skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
>                                      mac_len);
>
