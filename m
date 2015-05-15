From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Fri, 15 May 2015 11:11:58 -0400
Message-ID: <CALx6S34ETTapmY7nBTohfs0Cu03PQuBteLXPVC7sSrvSJ5CdLQ@mail.gmail.com>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
	<1431401204-731380-6-git-send-email-tom@herbertland.com>
	<1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
	<1431406237.566.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
	<1431446777.566.87.camel@edumazet-glaptop2.roam.corp.google.com>
	<1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34720 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693AbbEOPL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:11:59 -0400
Received: by igblo3 with SMTP id lo3so41349476igb.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 08:11:58 -0700 (PDT)
In-Reply-To: <1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2015 at 8:48 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> First one in __skb_checksum_validate_complete() fixes the following
> (and other callers)
>
> make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/tcp_ipv4.o
>   CHECK   net/ipv4/tcp_ipv4.c
> include/linux/skbuff.h:3052:24: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3052:24:    expected restricted __sum16
> include/linux/skbuff.h:3052:24:    got int
>
> Second is fixing gso_make_checksum() :
>
>   CHECK   net/ipv4/gre_offload.c
> include/linux/skbuff.h:3360:14: warning: incorrect type in assignment (different base types)
> include/linux/skbuff.h:3360:14:    expected unsigned short [unsigned] [usertype] csum
> include/linux/skbuff.h:3360:14:    got restricted __sum16
> include/linux/skbuff.h:3365:16: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3365:16:    expected restricted __sum16
> include/linux/skbuff.h:3365:16:    got unsigned short [unsigned] [usertype] csum
>
>
> Fixes: 5a21232983aa7 ("net: Support for csum_bad in skbuff")
> Fixes: 7e2b10c1e52ca ("net: Support for multiple checksums with gso")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> CC: Tom Herbert <tom@herbertland.com>


Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  include/linux/skbuff.h |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f83aa6568cbf5e1794fdb1a8da28642ea417cc76..b57eebfb67e06dc90addfe5f2fea9d913b2121cc 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3051,7 +3051,7 @@ static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
>                 }
>         } else if (skb->csum_bad) {
>                 /* ip_summed == CHECKSUM_NONE in this case */
> -               return 1;
> +               return (__force __sum16)1;
>         }
>
>         skb->csum = psum;
> @@ -3353,15 +3353,14 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
>  static inline __sum16 gso_make_checksum(struct sk_buff *skb, __wsum res)
>  {
>         int plen = SKB_GSO_CB(skb)->csum_start - skb_headroom(skb) -
> -           skb_transport_offset(skb);
> -       __u16 csum;
> +                  skb_transport_offset(skb);
> +       __wsum partial;
>
> -       csum = csum_fold(csum_partial(skb_transport_header(skb),
> -                                     plen, skb->csum));
> +       partial = csum_partial(skb_transport_header(skb), plen, skb->csum);
>         skb->csum = res;
>         SKB_GSO_CB(skb)->csum_start -= plen;
>
> -       return csum;
> +       return csum_fold(partial);
>  }
>
>  static inline bool skb_is_gso(const struct sk_buff *skb)
>
>
