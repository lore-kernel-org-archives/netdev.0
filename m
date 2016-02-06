From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 08/10] udp: Clean up the use of flags in UDP
 segmentation offload
Date: Sat, 6 Feb 2016 12:57:48 -0800
Message-ID: <CALx6S35DaAYceaAnTgJPPNSaNUtburvpdGUXqdsa-LqNV8n63A@mail.gmail.com>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
	<20160205232814.18529.595.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35830 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbcBFU5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:57:49 -0500
Received: by mail-io0-f175.google.com with SMTP id d63so161994402ioj.2
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:57:49 -0800 (PST)
In-Reply-To: <20160205232814.18529.595.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 5, 2016 at 3:28 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch goes though and cleans up the logic related to several of the
> control flags used in UDP segmentation.  Specifically the use of dont_encap
> isn't really needed as we can just check the skb for CHECKSUM_PARTIAL and
> if it isn't set then we don't need to update the internal headers.  As such
> we can just drop that value.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/ipv4/udp_offload.c |   37 ++++++++++++++++++-------------------
>  1 file changed, 18 insertions(+), 19 deletions(-)
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 86687f58d613..9e4816fc9927 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -33,16 +33,13 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>         __be16 new_protocol, bool is_ipv6)
>  {
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
> +       bool remcsum, need_csum, offload_csum;
>         u16 mac_offset = skb->mac_header;
>         int mac_len = skb->mac_len;
>         int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
>         __be16 protocol = skb->protocol;
>         int udp_offset, outer_hlen;
>         unsigned int oldlen;
> -       bool need_csum = !!(skb_shinfo(skb)->gso_type &
> -                           SKB_GSO_UDP_TUNNEL_CSUM);
> -       bool remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
> -       bool offload_csum = false, dont_encap = (need_csum || remcsum);
>
>         oldlen = (u16)~skb->len;
>
> @@ -55,14 +52,18 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>         skb_set_network_header(skb, skb_inner_network_offset(skb));
>         skb->mac_len = skb_inner_network_offset(skb);
>         skb->protocol = new_protocol;
> +
> +       need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
>         skb->encap_hdr_csum = need_csum;
> +
> +       remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
>         skb->remcsum_offload = remcsum;
>
>         /* Try to offload checksum if possible */
>         offload_csum = !!(need_csum &&
> -                         ((skb->dev->features & NETIF_F_HW_CSUM) ||
> -                          (skb->dev->features & (is_ipv6 ?
> -                           NETIF_F_IPV6_CSUM : NETIF_F_IP_CSUM))));
> +                         (skb->dev->features &
> +                          (is_ipv6 ? (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM) :
> +                                     (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM))));
>
>         features &= skb->dev->hw_enc_features;
>
> @@ -92,13 +93,11 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>                 int len;
>                 __be32 delta;
>
> -               if (dont_encap) {
> -                       skb->encapsulation = 0;
> +               if (remcsum)
>                         skb->ip_summed = CHECKSUM_NONE;
> -               } else {
> -                       /* Only set up inner headers if we might be offloading
> -                        * inner checksum.
> -                        */
> +
> +               /* Set up inner headers if we are offloading inner checksum */
> +               if (skb->ip_summed == CHECKSUM_PARTIAL) {
>                         skb_reset_inner_headers(skb);
>                         skb->encapsulation = 1;
>                 }
> @@ -122,15 +121,15 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>                 uh->check = ~csum_fold((__force __wsum)
>                                        ((__force u32)uh->check +
>                                         (__force u32)delta));
> -               if (offload_csum) {
> -                       skb->ip_summed = CHECKSUM_PARTIAL;
> -                       skb->csum_start = skb_transport_header(skb) - skb->head;
> -                       skb->csum_offset = offsetof(struct udphdr, check);
> -               } else {
> -                       uh->check = gso_make_checksum(skb, ~uh->check);
>
> +               if (skb->encapsulation || !offload_csum) {
> +                       uh->check = gso_make_checksum(skb, ~uh->check);
>                         if (uh->check == 0)
>                                 uh->check = CSUM_MANGLED_0;
> +               } else {
> +                       skb->ip_summed = CHECKSUM_PARTIAL;
> +                       skb->csum_start = skb_transport_header(skb) - skb->head;
> +                       skb->csum_offset = offsetof(struct udphdr, check);
>                 }
>         } while ((skb = skb->next));
>  out:
>
