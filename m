From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] net: Implmement RFC 6936 (zero RX csums for UDP/IPv6)
Date: Sat, 5 Apr 2014 14:56:55 -0700
Message-ID: <CA+mtBx-o6WjF7ZJSs_+NQO1MYNxkeRG2KoLq2+B4AySTf1kTiA@mail.gmail.com>
References: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:57855 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653AbaDEV45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2014 17:56:57 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so3193688igc.0
        for <netdev@vger.kernel.org>; Sat, 05 Apr 2014 14:56:56 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please disregard new option, I think we can just use sk_no_check
instead of new socket option.

On Fri, Apr 4, 2014 at 5:28 PM, Tom Herbert <therbert@google.com> wrote:
> RFC 6936 relaxes the requirement of RFC 2460 that UDP/IPv6 packets which
> are received with a zero UDP checksum value must be dropped. RFC 6936
> allow zero checksums to support tunnels over UDP.
>
> This patch adds a new socket option UDP_CHECK6_ZERO_OKAY whcih can be
> set on a UDP socket to indicate that a zero checksum is acceptable
> (e.g. the socket is for a tunnel). The ip6 checksum and UDP receive
> functions were updated accordingly to deal with this.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/udp.h      |  3 ++-
>  include/uapi/linux/udp.h |  1 +
>  net/ipv4/udp.c           |  8 ++++++++
>  net/ipv6/ip6_checksum.c  | 19 ++++++++-----------
>  net/ipv6/udp.c           | 39 +++++++++++++++++++++++++++++++++++++--
>  5 files changed, 56 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/udp.h b/include/linux/udp.h
> index 42278bb..647ffc9 100644
> --- a/include/linux/udp.h
> +++ b/include/linux/udp.h
> @@ -63,7 +63,8 @@ struct udp_sock {
>  #define UDPLITE_SEND_CC  0x2           /* set via udplite setsockopt         */
>  #define UDPLITE_RECV_CC  0x4           /* set via udplite setsocktopt        */
>         __u8             pcflag;        /* marks socket as UDP-Lite if > 0    */
> -       __u8             unused[3];
> +       __u8             check6_zero_okay; /* Zero csum okay for IPv6 */
> +       __u8             unused[2];
>         /*
>          * For encapsulation sockets.
>          */
> diff --git a/include/uapi/linux/udp.h b/include/uapi/linux/udp.h
> index e2bcfd7..46d0e58 100644
> --- a/include/uapi/linux/udp.h
> +++ b/include/uapi/linux/udp.h
> @@ -28,6 +28,7 @@ struct udphdr {
>
>  /* UDP socket options */
>  #define UDP_CORK       1       /* Never send partially complete segments */
> +#define UDP_CHECK6_ZERO_OKAY   2       /* Zero checksum okay for IPv6 UDP */
>  #define UDP_ENCAP      100     /* Set the socket to accept encapsulated packets */
>
>  /* UDP encapsulation types */
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index d5e3a76..9b88788 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2003,6 +2003,10 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
>                 }
>                 break;
>
> +       case UDP_CHECK6_ZERO_OKAY:
> +               up->check6_zero_okay = !!val;
> +               break;
> +
>         /*
>          *      UDP-Lite's partial checksum coverage (RFC 3828).
>          */
> @@ -2081,6 +2085,10 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
>                 val = up->corkflag;
>                 break;
>
> +       case UDP_CHECK6_ZERO_OKAY:
> +               val = up->check6_zero_okay;
> +               break;
> +
>         case UDP_ENCAP:
>                 val = up->encap_type;
>                 break;
> diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
> index 6105b8f..55896cd 100644
> --- a/net/ipv6/ip6_checksum.c
> +++ b/net/ipv6/ip6_checksum.c
> @@ -83,16 +83,13 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
>                         return err;
>         }
>
> -       if (uh->check == 0) {
> -               /* RFC 2460 section 8.1 says that we SHOULD log
> -                  this error. Well, it is reasonable.
> -                */
> -               LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 for [%pI6c]:%u->[%pI6c]:%u\n",
> -                              &ipv6_hdr(skb)->saddr, ntohs(uh->source),
> -                              &ipv6_hdr(skb)->daddr, ntohs(uh->dest));
> -               return 1;
> -       }
> -
> -       return skb_checksum_init(skb, IPPROTO_UDP, ip6_pseudo_compute);
> +       /*
> +        * To support RFC 6936 (allow zero checksum in UDP/IPV6 for tunnels)
> +        * we accept a checksum of zero here. When we find the socket
> +        * for the UDP packet we'll check if that socket allows zero checksum
> +        * for IPv6 (set by socket option).
> +        */
> +       return skb_checksum_init_zero_check(skb, proto, uh->check,
> +                                          ip6_pseudo_compute);
>  }
>  EXPORT_SYMBOL(udp6_csum_init);
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 1e586d9..8b874b9 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -760,13 +760,25 @@ static void flush_stack(struct sock **stack, unsigned int count,
>         if (unlikely(skb1))
>                 kfree_skb(skb1);
>  }
> +
> +static void udp6_csum_zero_error(struct sk_buff *skb)
> +{
> +       /*
> +        * RFC 2460 section 8.1 says that we SHOULD log
> +        * this error. Well, it is reasonable.
> +       */
> +       LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 for [%pI6c]:%u->[%pI6c]:%u\n",
> +                      &ipv6_hdr(skb)->saddr, ntohs(udp_hdr(skb)->source),
> +                      &ipv6_hdr(skb)->daddr, ntohs(udp_hdr(skb)->dest));
> +}
> +
>  /*
>   * Note: called only from the BH handler context,
>   * so we don't need to lock the hashes.
>   */
>  static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>                 const struct in6_addr *saddr, const struct in6_addr *daddr,
> -               struct udp_table *udptable)
> +               struct udp_table *udptable, int proto)
>  {
>         struct sock *sk, *stack[256 / sizeof(struct sock *)];
>         const struct udphdr *uh = udp_hdr(skb);
> @@ -779,6 +791,19 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>         dif = inet6_iif(skb);
>         sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
>         while (sk) {
> +               if (!uh->check && !udp_sk(sk)->check6_zero_okay) {
> +                       /*
> +                        * If checksum in packet is zero and not all the
> +                        * sockets accept a zero checksum then declare
> +                        * a checksum error.
> +                        */
> +                       flush_stack(stack, count, skb, ~0);
> +                       count = 0;
> +                       udp6_csum_zero_error(skb);
> +                       UDP6_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
> +                       UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
> +                       break;
> +               }
>                 stack[count++] = sk;
>                 sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
>                                        uh->source, saddr, dif);
> @@ -855,7 +880,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>          */
>         if (ipv6_addr_is_multicast(daddr))
>                 return __udp6_lib_mcast_deliver(net, skb,
> -                               saddr, daddr, udptable);
> +                               saddr, daddr, udptable, proto);
>
>         /* Unicast */
>
> @@ -867,6 +892,11 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>         if (sk != NULL) {
>                 int ret;
>
> +               if (!uh->check && !udp_sk(sk)->check6_zero_okay) {
> +                       udp6_csum_zero_error(skb);
> +                       goto csum_error;
> +               }
> +
>                 ret = udpv6_queue_rcv_skb(sk, skb);
>                 sock_put(sk);
>
> @@ -879,6 +909,11 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>                 return 0;
>         }
>
> +       if (!uh->check) {
> +               udp6_csum_zero_error(skb);
> +               goto csum_error;
> +       }
> +
>         if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
>                 goto discard;
>
> --
> 1.9.1.423.g4596e3a
>
