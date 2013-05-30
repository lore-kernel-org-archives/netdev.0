From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH] udp6: Fix udp fragmentation for tunnel traffic.
Date: Thu, 30 May 2013 21:53:37 +0300
Message-ID: <CAM8tLiOi3sMeMecKgRLXq+RtEtY1Pvfeg9v2n-6M9k6WDiG9gg@mail.gmail.com>
References: <1369932327-7913-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:63299 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758266Ab3E3Sxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 14:53:38 -0400
Received: by mail-vc0-f180.google.com with SMTP id gd11so435385vcb.39
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 11:53:37 -0700 (PDT)
In-Reply-To: <1369932327-7913-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 7:45 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> udp6 over GRE tunnel does not work after to GRE tso changes. GRE
> tso handler passes inner packet but keeps track of outer header
> start in SKB_GSO_CB(skb)->mac_offset.  udp6 fragment need to
> take care of outer header, which start at the mac_offset, while
> adding fragment header.
> This bug is introduced by commit 68c3316311 (GRE: Add TCP
> segmentation offload for GRE).
>
> Reported-by: Dmitry Kravkov <dkravkov@gmail.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  include/linux/skbuff.h |   15 +++++++++++++++
>  net/ipv6/udp_offload.c |   20 ++++++++++++--------
>  2 files changed, 27 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 5f93119..f7fdf71 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2758,6 +2758,21 @@ static inline int skb_tnl_header_len(const struct sk_buff *inner_skb)
>                 SKB_GSO_CB(inner_skb)->mac_offset;
>  }
>
> +static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
> +{
> +       int new_headroom, headroom;
> +       int ret;
> +
> +       headroom = skb_headroom(skb);
> +       ret = pskb_expand_head(skb, extra, 0, GFP_ATOMIC);
> +       if (ret)
> +               return ret;
> +
> +       new_headroom = skb_headroom(skb);
> +       SKB_GSO_CB(skb)->mac_offset += (new_headroom - headroom);
> +       return 0;
> +}
> +
>  static inline bool skb_is_gso(const struct sk_buff *skb)
>  {
>         return skb_shinfo(skb)->gso_size;
> diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
> index 76d401a..5d1b8d7 100644
> --- a/net/ipv6/udp_offload.c
> +++ b/net/ipv6/udp_offload.c
> @@ -46,11 +46,12 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>         unsigned int mss;
>         unsigned int unfrag_ip6hlen, unfrag_len;
>         struct frag_hdr *fptr;
> -       u8 *mac_start, *prevhdr;
> +       u8 *packet_start, *prevhdr;
>         u8 nexthdr;
>         u8 frag_hdr_sz = sizeof(struct frag_hdr);
>         int offset;
>         __wsum csum;
> +       int tnl_hlen;
>
>         mss = skb_shinfo(skb)->gso_size;
>         if (unlikely(skb->len <= mss))
> @@ -84,9 +85,11 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>         skb->ip_summed = CHECKSUM_NONE;
>
>         /* Check if there is enough headroom to insert fragment header. */
> -       if ((skb_mac_header(skb) < skb->head + frag_hdr_sz) &&
> -           pskb_expand_head(skb, frag_hdr_sz, 0, GFP_ATOMIC))
> -               goto out;
> +       tnl_hlen = skb_tnl_header_len(skb);
> +       if (skb_headroom(skb) < (tnl_hlen + frag_hdr_sz)) {
> +               if (gso_pskb_expand_head(skb, tnl_hlen + frag_hdr_sz))
> +                       goto out;
> +       }
>
>         /* Find the unfragmentable header and shift it left by frag_hdr_sz
>          * bytes to insert fragment header.
> @@ -94,11 +97,12 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>         unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
>         nexthdr = *prevhdr;
>         *prevhdr = NEXTHDR_FRAGMENT;
> -       unfrag_len = skb_network_header(skb) - skb_mac_header(skb) +
> -                    unfrag_ip6hlen;
> -       mac_start = skb_mac_header(skb);
> -       memmove(mac_start-frag_hdr_sz, mac_start, unfrag_len);
> +       unfrag_len = (skb_network_header(skb) - skb_mac_header(skb)) +
> +                    unfrag_ip6hlen + tnl_hlen;
> +       packet_start = (u8 *) skb->head + SKB_GSO_CB(skb)->mac_offset;
> +       memmove(packet_start-frag_hdr_sz, packet_start, unfrag_len);
>
> +       SKB_GSO_CB(skb)->mac_offset -= frag_hdr_sz;
>         skb->mac_header -= frag_hdr_sz;
>         skb->network_header -= frag_hdr_sz;
>
> --


Yeah, this fixes reported issue. Thanks.

Tested-by: Dmitry Kravkov <dmitry@broadcom.com>
