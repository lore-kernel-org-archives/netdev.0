From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
Date: Tue, 27 Oct 2015 09:36:21 -0700
Message-ID: <CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
	<1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34209 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965061AbbJ0QgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 12:36:22 -0400
Received: by iody8 with SMTP id y8so71889711iod.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 09:36:21 -0700 (PDT)
In-Reply-To: <1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 8:02 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> We cannot reliable calculate packet size on MSG_MORE corked sockets
> and thus cannot decide if they are going to be fragmented later on,
> so better not use CHECKSUM_PARTIAL in the first place.
>
> The IPv6 code also intended to protect and not use CHECKSUM_PARTIAL in
> the existence of IPv6 extension headers, but the condition was wrong. Fix
> it up, too. Also the condition to check whether the packet fits into
> one fragment was wrong and has been corrected.
>
> Fixes: commit 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
> See-also: commit 72e843bb09d45 ("ipv6: ip6_fragment() should check CHECKSUM_PARTIAL")
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Benjamin Coddington <bcodding@redhat.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_output.c | 70 ++++++++++++++++++++++++---------------------------
>  1 file changed, 33 insertions(+), 37 deletions(-)
>
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index c265068..9828a71 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1272,6 +1272,7 @@ static int __ip6_append_data(struct sock *sk,
>         struct rt6_info *rt = (struct rt6_info *)cork->dst;
>         struct ipv6_txoptions *opt = v6_cork->opt;
>         int csummode = CHECKSUM_NONE;
> +       unsigned int maxnonfragsize, headersize;
>
>         skb = skb_peek_tail(queue);
>         if (!skb) {
> @@ -1289,38 +1290,43 @@ static int __ip6_append_data(struct sock *sk,
>         maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen -
>                      sizeof(struct frag_hdr);
>
> -       if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {

It seems like most of the diffs in this patch are a result of
eliminating this line. Is this check not needed?

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

No, please don't do this. CHECKSUM_PARTIAL should work with extension
headers as defined, so this is just disabling otherwise valid and
useful functionality. If (some) drivers have problems with this they
need to be identified and fixed.

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
> @@ -1328,16 +1334,6 @@ emsgsize:
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
> 2.5.0
>
