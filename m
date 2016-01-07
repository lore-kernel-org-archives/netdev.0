From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next 1/5] net: local checksum offload for encapsulation
Date: Thu, 7 Jan 2016 14:53:34 -0800
Message-ID: <CAKgT0UfjGkjiXuV8EqdtwrunAS0MDSb2rCzkt+6F+yipGzK9sw@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com>
	<568E9C64.6090305@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com, Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:32793 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817AbcAGWxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 17:53:35 -0500
Received: by mail-ig0-f194.google.com with SMTP id y8so6999142igw.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 14:53:34 -0800 (PST)
In-Reply-To: <568E9C64.6090305@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 7, 2016 at 9:12 AM, Edward Cree <ecree@solarflare.com> wrote:
>
> The arithmetic properties of the ones-complement checksum mean that a
>  correctly checksummed inner packet, including its checksum, has a ones
>  complement sum depending only on whatever value was used to initialise
>  the checksum field before checksumming (in the case of TCP and UDP,
>  this is the ones complement sum of the pseudo header, complemented).
> Consequently, if we are going to offload the inner checksum with
>  CHECKSUM_PARTIAL, we can compute the outer checksum based only on the
>  packed data not covered by the inner checksum, and the initial value of
>  the inner checksum field.
>
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
>  include/linux/skbuff.h    | 26 ++++++++++++++++++++++++++
>  net/ipv4/ip_tunnel_core.c |  4 ++++
>  net/ipv4/udp.c            | 29 ++++++++++-------------------
>  net/ipv6/ip6_checksum.c   | 24 ++++++++----------------
>  4 files changed, 48 insertions(+), 35 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 6b6bd42..6590d08 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3665,5 +3665,31 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
>         return hdr_len + skb_gso_transport_seglen(skb);
>  }
>
> +/* Local Checksum Offload.
> + * Compute outer checksum based on the assumption that the
> + * inner checksum will be offloaded later.
> + * See Documentation/networking/tx-offloads.txt for
> + * explanation of how this works.
> + * Fill in outer checksum adjustment (e.g. with sum of outer
> + * pseudo-header) before calling.
> + * Also ensure that inner checksum is in linear data area.
> + */
> +static inline __wsum lco_csum(struct sk_buff *skb)
> +{
> +       char *inner_csum_field;
> +       __wsum csum;
> +
> +       /* Start with complement of inner checksum adjustment */
> +       inner_csum_field = skb->data + skb_checksum_start_offset(skb) +
> +                               skb->csum_offset;

You would probably benefit from caching off the result of
skb_checksum_start_offset into a local variable so the compiler
doesn't go through and recompute it when you call it again below.

> +       csum = ~csum_unfold(*(__force __sum16 *)inner_csum_field);

This seems like a lot of work, couldn't you get away with just
bit-flipping this and moving it into uh->check on the outer header?

> +       /* Add in checksum of our headers (incl. outer checksum
> +        * adjustment filled in by caller)
> +        */
> +       csum = skb_checksum(skb, 0, skb_checksum_start_offset(skb), csum);
> +       /* The result is the outer checksum */
> +       return csum;
> +}
> +

The more I think about it I am not sure how much there is to be gained
by having this as a separate function anyway since I think you might
be able to better exploit things with a few changes to the ordering of
operations.  See my notes below in the IPv4 section.

>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_SKBUFF_H */
> diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
> index 1db8418..f39b064 100644
> --- a/net/ipv4/ip_tunnel_core.c
> +++ b/net/ipv4/ip_tunnel_core.c
> @@ -146,6 +146,10 @@ struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
>  }
>  EXPORT_SYMBOL_GPL(iptunnel_metadata_reply);
>
> +/* csum_help should only be ever true if the protocol doesn't support LCO.
> + * If the tunnel uses udp_tunnel_xmit_skb(), then it gets LCO for free, and
> + * should always set csum_help to false.
> + */
>  struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
>                                          bool csum_help,
>                                          int gso_type_mask)
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 8841e98..c1c73be 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -767,32 +767,23 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
>  {
>         struct udphdr *uh = udp_hdr(skb);
>
> -       if (nocheck)
> +       if (nocheck) {
>                 uh->check = 0;
> -       else if (skb_is_gso(skb))
> +       } else if (skb_is_gso(skb)) {
>                 uh->check = ~udp_v4_check(len, saddr, daddr, 0);
> -       else if (skb_dst(skb) && skb_dst(skb)->dev &&
> -                (skb_dst(skb)->dev->features &
> -                 (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
> -
> -               BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
> +       } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +               __wsum csum;
>

I wonder if this shouldn't be made a check that is in addition to the
two options below instead of completely replacing them.  The question
I would have is if there are any cases where we need to follow the
path that results in the CHECKSUM_UNNECESSARY being set.

>
> +               uh->check = ~udp_v4_check(len, saddr, daddr, 0);
> +               csum = lco_csum(skb);
> +               uh->check = csum_fold(csum);
> +               if (uh->check == 0)
> +                       uh->check = CSUM_MANGLED_0;


You would probably benefit from reordering this to something like what
we have in the last block below this one.  The idea is then you only
halve to fold things once and can avoid some unnecessary duplication.

So you could code it up with something like:
  __wsum csum;
  int start_offset;

  start_offset = skb_checksum_start_offset(skb);
  uh->check = ~(*(__sum16 *)(skb->data + start_offset + skb->csum_offset));
  csum = skb_checksum(skb, 0, start_offset, 0);
  uh->check = udp_v4_check(len, saddr, daddr, csum);
  if (uh->check == 0)
    uh->check = CSUM_MANGLED_0;

Forgive the formatting, my email client mangles tabs badly.  By using
the pseudo header checksum from the inner header for the starting
value and then computing the udp_v4_check for the outer header last
you save yourself a few cycles since you only have to fold the
checksum once instead of once for the pseudo-header and again for the
final result.

>
> +       } else {
>                 skb->ip_summed = CHECKSUM_PARTIAL;
>                 skb->csum_start = skb_transport_header(skb) - skb->head;
>                 skb->csum_offset = offsetof(struct udphdr, check);
>                 uh->check = ~udp_v4_check(len, saddr, daddr, 0);
> -       } else {
> -               __wsum csum;
> -
> -               BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
> -
> -               uh->check = 0;
> -               csum = skb_checksum(skb, 0, len, 0);
> -               uh->check = udp_v4_check(len, saddr, daddr, csum);
> -               if (uh->check == 0)
> -                       uh->check = CSUM_MANGLED_0;
> -
> -               skb->ip_summed = CHECKSUM_UNNECESSARY;
>         }
>  }
>  EXPORT_SYMBOL(udp_set_csum);
> diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
> index 9a4d732..19e564a 100644
> --- a/net/ipv6/ip6_checksum.c
> +++ b/net/ipv6/ip6_checksum.c
> @@ -98,27 +98,19 @@ void udp6_set_csum(bool nocheck, struct sk_buff *skb,
>                 uh->check = 0;
>         else if (skb_is_gso(skb))
>                 uh->check = ~udp_v6_check(len, saddr, daddr, 0);
> -       else if (skb_dst(skb) && skb_dst(skb)->dev &&
> -                (skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
> -
> -               BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
> +       else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +               __wsum csum;
>
> +               uh->check = ~udp_v6_check(len, saddr, daddr, 0);
> +               csum = lco_csum(skb);
> +               uh->check = csum_fold(csum);
> +               if (uh->check == 0)
> +                       uh->check = CSUM_MANGLED_0;


Same here for the IPv6 block.  Instead of initializing uh->check using
the outer pseudo-header checksum you would probably be better off
using the inner header and then folding that into the outer
pseudo-header checksum last.

>
> +       } else {
>                 skb->ip_summed = CHECKSUM_PARTIAL;
>                 skb->csum_start = skb_transport_header(skb) - skb->head;
>                 skb->csum_offset = offsetof(struct udphdr, check);
>                 uh->check = ~udp_v6_check(len, saddr, daddr, 0);
> -       } else {
> -               __wsum csum;
> -
> -               BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
> -
> -               uh->check = 0;
> -               csum = skb_checksum(skb, 0, len, 0);
> -               uh->check = udp_v6_check(len, saddr, daddr, csum);
> -               if (uh->check == 0)
> -                       uh->check = CSUM_MANGLED_0;
> -
> -               skb->ip_summed = CHECKSUM_UNNECESSARY;
>         }
>  }
>  EXPORT_SYMBOL(udp6_set_csum);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
