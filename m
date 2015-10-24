From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension
 headers and recalc checksum during fragmentation
Date: Sat, 24 Oct 2015 12:21:49 -0400
Message-ID: <CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36175 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbbJXQVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 12:21:50 -0400
Received: by ioll68 with SMTP id l68so151684340iol.3
        for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 09:21:49 -0700 (PDT)
In-Reply-To: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 9:13 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> CHECKSUM_PARTIAL should only be used on plain vanilla IPv6 + UDP packets
> in ip6_append_data. Some drivers don't correctly handle extension headers,
> especially not ipv6 fragmentation which could result in broken checksums.
>
Yes, we've seen this in some drivers, but the conclusion is that those
drivers are *broken* and need to be fixed! CHECKSUM_PARTIAL works
perfectly well in the presence of extension headers if the
driver/device is correctly implemented (simple algorithm with
csum_start and csum_offset).

Tom

> 1) This patch improves the test for fragmentation and extension headers
> in ip6_append_data, so we set the ip_summed mode as early as possible
> to the correct value to compute the checksum during memory copy-in from
> user space.
>
> 2) We always call skb_checksum_help on CHECKSUM_PARTIAL fragments in
> ip6_fragment, because we don't know if the underlying hardware can deal
> with ip6_fragments.
>
> Fixes: commit 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
> See-also: commit 72e843bb09d45 ("ipv6: ip6_fragment() should check CHECKSUM_PARTIAL")
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Benjamin Coddington <bcodding@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_output.c | 78 ++++++++++++++++++++++++---------------------------
>  1 file changed, 37 insertions(+), 41 deletions(-)
>
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 8dddb45..26d2911 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -593,6 +593,10 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
>         frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
>                                     &ipv6_hdr(skb)->saddr);
>
> +       if ((skb->ip_summed == CHECKSUM_PARTIAL) &&
> +           (err = skb_checksum_help(skb)))
> +               goto fail;
> +
>         hroom = LL_RESERVED_SPACE(rt->dst.dev);
>         if (skb_has_frag_list(skb)) {
>                 int first_len = skb_pagelen(skb);
> @@ -721,10 +725,6 @@ slow_path_clean:
>         }
>
>  slow_path:
> -       if ((skb->ip_summed == CHECKSUM_PARTIAL) &&
> -           skb_checksum_help(skb))
> -               goto fail;
> -
>         left = skb->len - hlen;         /* Space per frame */
>         ptr = hlen;                     /* Where to start from */
>
> @@ -1260,6 +1260,7 @@ static int __ip6_append_data(struct sock *sk,
>         struct rt6_info *rt = (struct rt6_info *)cork->dst;
>         struct ipv6_txoptions *opt = v6_cork->opt;
>         int csummode = CHECKSUM_NONE;
> +       unsigned int maxnonfragsize, headersize;
>
>         skb = skb_peek_tail(queue);
>         if (!skb) {
> @@ -1277,38 +1278,43 @@ static int __ip6_append_data(struct sock *sk,
>         maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen -
>                      sizeof(struct frag_hdr);
>
> -       if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
> -               unsigned int maxnonfragsize, headersize;
> -
> -               headersize = sizeof(struct ipv6hdr) +
> -                            (opt ? opt->opt_flen + opt->opt_nflen : 0) +
> -                            (dst_allfrag(&rt->dst) ?
> -                             sizeof(struct frag_hdr) : 0) +
> -                            rt->rt6i_nfheader_len;
> -
> -               if (ip6_sk_ignore_df(sk))
> -                       maxnonfragsize = sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
> -               else
> -                       maxnonfragsize = mtu;
> +       headersize = sizeof(struct ipv6hdr) +
> +                    (opt ? opt->opt_flen + opt->opt_nflen : 0) +
> +                    (dst_allfrag(&rt->dst) ?
> +                     sizeof(struct frag_hdr) : 0) +
> +                    rt->rt6i_nfheader_len;
> +
> +       if (cork->length + length > mtu - headersize && dontfrag &&
> +           (sk->sk_protocol == IPPROTO_UDP ||
> +            sk->sk_protocol == IPPROTO_RAW)) {
> +               ipv6_local_rxpmtu(sk, fl6, mtu - headersize +
> +                               sizeof(struct ipv6hdr));
> +               goto emsgsize;
> +       }
>
> -               /* dontfrag active */
> -               if ((cork->length + length > mtu - headersize) && dontfrag &&
> -                   (sk->sk_protocol == IPPROTO_UDP ||
> -                    sk->sk_protocol == IPPROTO_RAW)) {
> -                       ipv6_local_rxpmtu(sk, fl6, mtu - headersize +
> -                                                  sizeof(struct ipv6hdr));
> -                       goto emsgsize;
> -               }
> +       if (ip6_sk_ignore_df(sk))
> +               maxnonfragsize = sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
> +       else
> +               maxnonfragsize = mtu;
>
> -               if (cork->length + length > maxnonfragsize - headersize) {
> +       if (cork->length + length > maxnonfragsize - headersize) {
>  emsgsize:
> -                       ipv6_local_error(sk, EMSGSIZE, fl6,
> -                                        mtu - headersize +
> -                                        sizeof(struct ipv6hdr));
> -                       return -EMSGSIZE;
> -               }
> +               ipv6_local_error(sk, EMSGSIZE, fl6,
> +                                mtu - headersize +
> +                                sizeof(struct ipv6hdr));
> +               return -EMSGSIZE;
>         }
>
> +       /* CHECKSUM_PARTIAL only with no extension headers and when
> +        * we are not going to fragment
> +        */
> +       if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
> +           headersize == sizeof(struct ipv6hdr) &&
> +           length < mtu - headersize &&
> +           !(flags & MSG_MORE) &&
> +           rt->dst.dev->features & NETIF_F_V6_CSUM)
> +               csummode = CHECKSUM_PARTIAL;
> +
>         if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW) {
>                 sock_tx_timestamp(sk, &tx_flags);
>                 if (tx_flags & SKBTX_ANY_SW_TSTAMP &&
> @@ -1316,16 +1322,6 @@ emsgsize:
>                         tskey = sk->sk_tskey++;
>         }
>
> -       /* If this is the first and only packet and device
> -        * supports checksum offloading, let's use it.
> -        * Use transhdrlen, same as IPv4, because partial
> -        * sums only work when transhdrlen is set.
> -        */
> -       if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
> -           length + fragheaderlen < mtu &&
> -           rt->dst.dev->features & NETIF_F_V6_CSUM &&
> -           !exthdrlen)
> -               csummode = CHECKSUM_PARTIAL;
>         /*
>          * Let's try using as much space as possible.
>          * Use MTU if total length of the message fits into the MTU.
> --
> 2.4.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
