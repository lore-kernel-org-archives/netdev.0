From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 02/10] net: Move GSO csum into SKB_GSO_CB
Date: Sat, 6 Feb 2016 12:41:23 -0800
Message-ID: <CALx6S37EPE0kh8epqgy=zL99eYyNXjCJhF5+-gFTLpO4N6ggcg@mail.gmail.com>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
	<20160205232737.18529.83813.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36592 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbcBFUlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:41:24 -0500
Received: by mail-io0-f174.google.com with SMTP id g73so161892945ioe.3
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:41:23 -0800 (PST)
In-Reply-To: <20160205232737.18529.83813.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 5, 2016 at 3:27 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch moves the checksum maintained by GSO out of skb->csum and into
> the GSO context block in order to allow for us to work on outer checksums
> while maintaining the inner checksum offsets in the case of the inner
> checksum being offloaded, while the outer checksums will be computed.
>
> While updating the code I also did a minor cleanu-up on gso_make_checksum.
> The change is mostly to make it so that we store the values and compute the
> checksum instead of computing the checksum and then storing the values we
> needed to update.
>
Typo in commit log (cleanu-up)

Acked-by: Tom Herbert <tom@herbertland.com>

> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  include/linux/skbuff.h |   14 +++++++-------
>  net/core/skbuff.c      |   16 +++++++++-------
>  2 files changed, 16 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 61b8cef73296..33c3807b618a 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3549,6 +3549,7 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
>  struct skb_gso_cb {
>         int     mac_offset;
>         int     encap_level;
> +       __wsum  csum;
>         __u16   csum_start;
>  };
>  #define SKB_SGO_CB_OFFSET      32
> @@ -3585,15 +3586,14 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
>   */
>  static inline __sum16 gso_make_checksum(struct sk_buff *skb, __wsum res)
>  {
> -       int plen = SKB_GSO_CB(skb)->csum_start - skb_headroom(skb) -
> -                  skb_transport_offset(skb);
> -       __wsum partial;
> +       unsigned char *csum_start = skb_transport_header(skb);
> +       int plen = (skb->head + SKB_GSO_CB(skb)->csum_start) - csum_start;
> +       __wsum partial = SKB_GSO_CB(skb)->csum;
>
> -       partial = csum_partial(skb_transport_header(skb), plen, skb->csum);
> -       skb->csum = res;
> -       SKB_GSO_CB(skb)->csum_start -= plen;
> +       SKB_GSO_CB(skb)->csum = res;
> +       SKB_GSO_CB(skb)->csum_start = csum_start - skb->head;
>
> -       return csum_fold(partial);
> +       return csum_fold(csum_partial(csum_start, plen, partial));
>  }
>
>  static inline bool skb_is_gso(const struct sk_buff *skb)
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index b2df375ec9c2..02c638a643ea 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3100,11 +3100,12 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>
>                 if (!sg && !nskb->remcsum_offload) {
>                         nskb->ip_summed = CHECKSUM_NONE;
> -                       nskb->csum = skb_copy_and_csum_bits(head_skb, offset,
> -                                                           skb_put(nskb, len),
> -                                                           len, 0);
> +                       SKB_GSO_CB(nskb)->csum =
> +                               skb_copy_and_csum_bits(head_skb, offset,
> +                                                      skb_put(nskb, len),
> +                                                      len, 0);
>                         SKB_GSO_CB(nskb)->csum_start =
> -                           skb_headroom(nskb) + doffset;
> +                               skb_headroom(nskb) + doffset;
>                         continue;
>                 }
>
> @@ -3171,11 +3172,12 @@ skip_fraglist:
>
>  perform_csum_check:
>                 if (!csum && !nskb->remcsum_offload) {
> -                       nskb->csum = skb_checksum(nskb, doffset,
> -                                                 nskb->len - doffset, 0);
>                         nskb->ip_summed = CHECKSUM_NONE;
> +                       SKB_GSO_CB(nskb)->csum =
> +                               skb_checksum(nskb, doffset,
> +                                            nskb->len - doffset, 0);
>                         SKB_GSO_CB(nskb)->csum_start =
> -                           skb_headroom(nskb) + doffset;
> +                               skb_headroom(nskb) + doffset;
>                 }
>         } while ((offset += len) < head_skb->len);
>
>
