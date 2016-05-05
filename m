From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 01/14] gso: Remove arbitrary checks for
 unsupported GSO
Date: Wed, 4 May 2016 19:59:20 -0700
Message-ID: <CAKgT0UeZWv7pnHNC8b5zjPe=SxZBz9EBUGkxnnjnqkmhDe34xg@mail.gmail.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
	<1462410164-1953217-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35078 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709AbcEEC7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 22:59:22 -0400
Received: by mail-ig0-f175.google.com with SMTP id bi2so4197171igb.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 19:59:21 -0700 (PDT)
In-Reply-To: <1462410164-1953217-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2016 at 6:02 PM, Tom Herbert <tom@herbertland.com> wrote:
> In several gso_segment functions there are checks of gso_type against
> a seemingly abitrary list of SKB_GSO_* flags. This seems like an
> attempt to identify unsupported GSO types, but since the stack is
> the one that set these GSO types in the first place this seems
> unnecessary to do. If a combination isn't valid in the first
> place that stack should not allow setting it.

You would think that was the case.  The problem is I have already seen
one issue with GUE allowing an unsupported combination of GRE_CSUM and
UDP tunnels.

> This is a code simplication especially for add new GSO types.

I'd say you might be better off going through and just putting in
place a few specific restrictions with a WARN_ONCE or something like
that.

> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv4/af_inet.c     | 18 ------------------
>  net/ipv4/gre_offload.c | 14 --------------
>  net/ipv4/tcp_offload.c | 19 -------------------
>  net/ipv4/udp_offload.c | 10 ----------
>  net/ipv6/ip6_offload.c | 18 ------------------
>  net/ipv6/udp_offload.c | 13 -------------
>  6 files changed, 92 deletions(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 2e6e65f..7f08d45 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1205,24 +1205,6 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>         int ihl;
>         int id;
>
> -       if (unlikely(skb_shinfo(skb)->gso_type &
> -                    ~(SKB_GSO_TCPV4 |
> -                      SKB_GSO_UDP |
> -                      SKB_GSO_DODGY |
> -                      SKB_GSO_TCP_ECN |
> -                      SKB_GSO_GRE |
> -                      SKB_GSO_GRE_CSUM |
> -                      SKB_GSO_IPIP |
> -                      SKB_GSO_SIT |
> -                      SKB_GSO_TCPV6 |
> -                      SKB_GSO_UDP_TUNNEL |
> -                      SKB_GSO_UDP_TUNNEL_CSUM |
> -                      SKB_GSO_TCP_FIXEDID |
> -                      SKB_GSO_TUNNEL_REMCSUM |
> -                      SKB_GSO_PARTIAL |
> -                      0)))
> -               goto out;
> -

This can go.  It basically just reads like a feature list for GSO.

>         skb_reset_network_header(skb);
>         nhoff = skb_network_header(skb) - skb_mac_header(skb);
>         if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index e88190a..ecd1e09 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -26,20 +26,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         int gre_offset, outer_hlen;
>         bool need_csum, ufo;
>
> -       if (unlikely(skb_shinfo(skb)->gso_type &
> -                               ~(SKB_GSO_TCPV4 |
> -                                 SKB_GSO_TCPV6 |
> -                                 SKB_GSO_UDP |
> -                                 SKB_GSO_DODGY |
> -                                 SKB_GSO_TCP_ECN |
> -                                 SKB_GSO_TCP_FIXEDID |
> -                                 SKB_GSO_GRE |
> -                                 SKB_GSO_GRE_CSUM |
> -                                 SKB_GSO_IPIP |
> -                                 SKB_GSO_SIT |
> -                                 SKB_GSO_PARTIAL)))
> -               goto out;
> -

This is trying to catch that specific case I mentioned where GRE and
UDP are being applied to the same tunnel.  We should have a mutual
exclusion on them, but UDP is getting around it by skipping over the
GRE header in its offload.  If GRE contains a UDP tunnel we definitely
should throw something like a WARN_ONCE.  I'd say just test for the
UDP_TUNNEL and UDP_TUNNEL_CSUM bits though until GRE and UDP_TUNNEL
can find a way to deal with sharing the inner_mac_header.

>         if (!skb->encapsulation)
>                 goto out;
>
> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index 02737b6..5c59649 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -83,25 +83,6 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
>
>         if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>                 /* Packet is from an untrusted source, reset gso_segs. */
> -               int type = skb_shinfo(skb)->gso_type;
> -
> -               if (unlikely(type &
> -                            ~(SKB_GSO_TCPV4 |
> -                              SKB_GSO_DODGY |
> -                              SKB_GSO_TCP_ECN |
> -                              SKB_GSO_TCP_FIXEDID |
> -                              SKB_GSO_TCPV6 |
> -                              SKB_GSO_GRE |
> -                              SKB_GSO_GRE_CSUM |
> -                              SKB_GSO_IPIP |
> -                              SKB_GSO_SIT |
> -                              SKB_GSO_UDP_TUNNEL |
> -                              SKB_GSO_UDP_TUNNEL_CSUM |
> -                              SKB_GSO_TUNNEL_REMCSUM |
> -                              0) ||
> -                            !(type & (SKB_GSO_TCPV4 |
> -                                      SKB_GSO_TCPV6))))
> -                       goto out;

This could probably be reduced to a check for SKB_GSO_UDP.

>                 skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 097060de..b556ef6 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -209,16 +209,6 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>
>         if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>                 /* Packet is from an untrusted source, reset gso_segs. */
> -               int type = skb_shinfo(skb)->gso_type;
> -
> -               if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
> -                                     SKB_GSO_UDP_TUNNEL |
> -                                     SKB_GSO_UDP_TUNNEL_CSUM |
> -                                     SKB_GSO_TUNNEL_REMCSUM |
> -                                     SKB_GSO_IPIP |
> -                                     SKB_GSO_GRE | SKB_GSO_GRE_CSUM) ||
> -                            !(type & (SKB_GSO_UDP))))
> -                       goto out;

This could be reduced to a check for the GSO types specific to TCP.

>                 skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index f5eb184..9ad743b 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -69,24 +69,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>         bool encap, udpfrag;
>         int nhoff;
>
> -       if (unlikely(skb_shinfo(skb)->gso_type &
> -                    ~(SKB_GSO_TCPV4 |
> -                      SKB_GSO_UDP |
> -                      SKB_GSO_DODGY |
> -                      SKB_GSO_TCP_ECN |
> -                      SKB_GSO_TCP_FIXEDID |
> -                      SKB_GSO_TCPV6 |
> -                      SKB_GSO_GRE |
> -                      SKB_GSO_GRE_CSUM |
> -                      SKB_GSO_IPIP |
> -                      SKB_GSO_SIT |
> -                      SKB_GSO_UDP_TUNNEL |
> -                      SKB_GSO_UDP_TUNNEL_CSUM |
> -                      SKB_GSO_TUNNEL_REMCSUM |
> -                      SKB_GSO_PARTIAL |
> -                      0)))
> -               goto out;
> -

You could drop this one.

>         skb_reset_network_header(skb);
>         nhoff = skb_network_header(skb) - skb_mac_header(skb);
>         if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
> diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
> index 5429f6b..ac858c4 100644
> --- a/net/ipv6/udp_offload.c
> +++ b/net/ipv6/udp_offload.c
> @@ -36,19 +36,6 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>
>         if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>                 /* Packet is from an untrusted source, reset gso_segs. */
> -               int type = skb_shinfo(skb)->gso_type;
> -
> -               if (unlikely(type & ~(SKB_GSO_UDP |
> -                                     SKB_GSO_DODGY |
> -                                     SKB_GSO_UDP_TUNNEL |
> -                                     SKB_GSO_UDP_TUNNEL_CSUM |
> -                                     SKB_GSO_TUNNEL_REMCSUM |
> -                                     SKB_GSO_GRE |
> -                                     SKB_GSO_GRE_CSUM |
> -                                     SKB_GSO_IPIP |
> -                                     SKB_GSO_SIT) ||
> -                            !(type & (SKB_GSO_UDP))))
> -                       goto out;

This is another one where all that is being checked for is TCP.

>                 skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>
> --
> 2.8.0.rc2
>
