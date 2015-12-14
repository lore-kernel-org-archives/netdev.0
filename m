From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 1/2] net: udp: local checksum offload for encapsulation
Date: Mon, 14 Dec 2015 09:16:00 -0800
Message-ID: <CALx6S34pyayogC3ZrifL9TGCzQbu_sC9R2Xtp8GsnybbZ9Ve6g@mail.gmail.com>
References: <566EDC16.1060706@solarflare.com>
	<566EDC85.6060101@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37479 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbbLNRQC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 12:16:02 -0500
Received: by igcto18 with SMTP id to18so87546810igc.0
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 09:16:00 -0800 (PST)
In-Reply-To: <566EDC85.6060101@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2015 at 7:13 AM, Edward Cree <ecree@solarflare.com> wrote:
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
>  net/ipv4/udp.c | 31 +++++++++++++++++++++++++++----
>  1 file changed, 27 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 0c7b0e6..07d679e 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -767,12 +767,35 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
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
> -                (skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {
> +       } else if (skb->ip_summed == CHECKSUM_PARTIAL &&
> +                  skb_dst(skb) && skb_dst(skb)->dev &&
> +                  (skb_dst(skb)->dev->features & NETIF_F_HW_CSUM)) {
> +               /* Everything from csum_start onwards will be
> +                * checksummed and will thus have a sum of whatever
> +                * we previously put in the checksum field (eg. sum
> +                * of pseudo-header)
> +                */
> +               __wsum csum;
> +
> +               /* Fill in our pseudo-header checksum */
> +               uh->check = ~udp_v4_check(len, saddr, daddr, 0);
> +               /* Start with complement of inner pseudo-header checksum */
> +               csum = ~skb_checksum(skb, skb_checksum_start_offset(skb) + skb->csum_offset,
> +                                    2, 0);
> +               /* Add in checksum of our headers (incl. pseudo-header
> +                * checksum filled in above)
> +                */
> +               csum = skb_checksum(skb, 0, skb_checksum_start_offset(skb), csum);
> +               /* The result is the outer checksum */
> +               uh->check = csum_fold(csum);
> +               if (uh->check == 0)
> +                       uh->check = CSUM_MANGLED_0;
> +       } else if (skb_dst(skb) && skb_dst(skb)->dev &&
> +                  (skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {
>
It's clever, but I'm not sure this saves much. The outer checksum
could still be offloaded to the device without the extra work. Where
this technique would be nice is if the device doesn't support checksum
offload at all, then we would definitely avoid doing multiple
checksums. That's going to be harder since we won't see
CHECKSUM_PARTIAL in that case for the inner checksum, but it would get
us to the principle that we only ever calculate the packet checksum
once or zero times.
.

>                 BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
>
> --
> 2.4.3
>
>
> The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
