From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 1/1] skbuff: Extend gso_type to unsigned int.
Date: Fri, 7 Apr 2017 07:28:28 -0700
Message-ID: <CAKgT0UeGhzBPpFE4yYOZD=5MOFE-sLur1bzGabc_myE=U65b1g@mail.gmail.com>
References: <1491207352-27585-1-git-send-email-steffen.klassert@secunet.com> <1491207352-27585-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36557 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756659AbdDGO2a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:28:30 -0400
Received: by mail-io0-f196.google.com with SMTP id 68so7636948ioh.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 07:28:29 -0700 (PDT)
In-Reply-To: <1491207352-27585-2-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 3, 2017 at 1:15 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> All available gso_type flags are currently in use, so
> extend gso_type from 'unsigned short' to 'unsigned int'
> to be able to add further flags.
>
> We also reorder the struct skb_shared_info to use
> two bytes of the four byte hole before dataref.
> All fields before _unused are cleared now, i.e.
> two bytes more than before the change.
>
> Structure layout on x86-64 before the change:
>
> struct skb_shared_info {
>         unsigned char              nr_frags;             /*     0     1 */
>         __u8                       tx_flags;             /*     1     1 */
>         short unsigned int         gso_size;             /*     2     2 */
>         short unsigned int         gso_segs;             /*     4     2 */
>         short unsigned int         gso_type;             /*     6     2 */
>         struct sk_buff *           frag_list;            /*     8     8 */
>         struct skb_shared_hwtstamps hwtstamps;           /*    16     8 */
>         u32                        tskey;                /*    24     4 */
>         __be32                     ip6_frag_id;          /*    28     4 */
>         atomic_t                   dataref;              /*    32     4 */
>
>         /* XXX 4 bytes hole, try to pack */
>
>         void *                     destructor_arg;       /*    40     8 */
>         skb_frag_t                 frags[17];            /*    48   272 */
>         /* --- cacheline 5 boundary (320 bytes) --- */
>
>         /* size: 320, cachelines: 5, members: 12 */
>         /* sum members: 316, holes: 1, sum holes: 4 */
> };
>
> Structure layout on x86-64 after the change:
>
> struct skb_shared_info {
>         struct sk_buff *           frag_list;            /*     0     8 */
>         struct skb_shared_hwtstamps hwtstamps;           /*     8     8 */
>         u32                        tskey;                /*    16     4 */
>         __be32                     ip6_frag_id;          /*    20     4 */
>         unsigned int               gso_type;             /*    24     4 */
>         unsigned char              nr_frags;             /*    28     1 */
>         __u8                       tx_flags;             /*    29     1 */
>         short unsigned int         gso_size;             /*    30     2 */
>         short unsigned int         gso_segs;             /*    32     2 */
>         short unsigned int         _unused;              /*    34     2 */
>         atomic_t                   dataref;              /*    36     4 */
>         void *                     destructor_arg;       /*    40     8 */
>         skb_frag_t                 frags[17];            /*    48   272 */
>         /* --- cacheline 5 boundary (320 bytes) --- */
>
>         /* size: 320, cachelines: 5, members: 13 */
> };
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  include/linux/skbuff.h | 13 +++++++------
>  net/core/skbuff.c      |  2 +-
>  2 files changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index c776abd..cb36159 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -413,20 +413,21 @@ struct ubuf_info {
>   * the end of the header data, ie. at skb->end.
>   */
>  struct skb_shared_info {
> +       struct sk_buff  *frag_list;
> +       struct skb_shared_hwtstamps hwtstamps;
> +       u32             tskey;
> +       __be32          ip6_frag_id;
> +       unsigned int    gso_type;
>         unsigned char   nr_frags;
>         __u8            tx_flags;
>         unsigned short  gso_size;
>         /* Warning: this field is not always filled in (UFO)! */
>         unsigned short  gso_segs;
> -       unsigned short  gso_type;
> -       struct sk_buff  *frag_list;
> -       struct skb_shared_hwtstamps hwtstamps;
> -       u32             tskey;
> -       __be32          ip6_frag_id;
>
>         /*
> -        * Warning : all fields before dataref are cleared in __alloc_skb()
> +        * Warning : all fields before _unused are cleared in __alloc_skb()
>          */
> +       unsigned short  _unused;

You can probably just put a comment about a 2 byte hole here.

In most cases the cost here is the fact that you are adding bytes
beyond 32.  So if you are adding 2 bytes or 4 the cost should be about
the same for the memset since it is having to deal with something less
than or equal to a long. This all compiles out into 4 mov operations
on x86_64, and adding this regardless of adding 2, 4, or 8 will just
add one more. So adding _unused is just an unnecessary optimization.

Doing that would make the code changes below unneeded.

>         atomic_t        dataref;
>
>         /* Intermediate layers must ensure that destructor_arg
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9f78109..8796b93 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -257,7 +257,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>
>         /* make sure we initialize shinfo sequentially */
>         shinfo = skb_shinfo(skb);
> -       memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> +       memset(shinfo, 0, offsetof(struct skb_shared_info, _unused));
>         atomic_set(&shinfo->dataref, 1);
>         kmemcheck_annotate_variable(shinfo->destructor_arg);
>
> --
> 2.7.4
>
