From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/2] udp: Do not require sock in udp_tunnel_xmit_skb
Date: Mon, 19 Jan 2015 00:43:16 +0200
Message-ID: <CAJ3xEMg0xJU4JShBLzs4g+zZVzH+uo79=aQGx4NwoQOv1h13Kw@mail.gmail.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
	<1421518700-22460-2-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:57748 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbbARWnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 17:43:16 -0500
Received: by mail-oi0-f53.google.com with SMTP id g201so24348582oib.12
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 14:43:16 -0800 (PST)
In-Reply-To: <1421518700-22460-2-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 17, 2015 at 8:18 PM, Tom Herbert <therbert@google.com> wrote:
> The UDP tunnel transmit functions udp_tunnel_xmit_skb and
> udp_tunnel6_xmit_skb include a socket argument. The socket being
> passed to the functions (from VXLAN) is a UDP created for receive
> side. The only thing that the socket is used for in the transmit
> functions is to get the setting for checksum (enabled or zero).

Tom, just to clarify - re the sockets usage in the transmit side,
somewhere bind or alike is done on them such that we have multiple
source UDP ports for given host VXLAN traffic. Here for example the
sender host is 192.168.31.17 and two ports are seen here 54206 and
50795.

Just wanted to make sure this series doesn't change that, since if
this is the case, we introduce here a regression w.r.t RSS hash
spreading from the outer UDP header data at the receiver side (which
is the right thing to do, per your LKS session...)

IP 192.168.31.18.45367 > 192.168.31.17.4789: UDP, length 62
IP 192.168.31.18.45515 > 192.168.31.17.4789: UDP, length 62
IP 192.168.31.17.54206 > 192.168.31.18.4789: UDP, length 26814
IP 192.168.31.18.45367 > 192.168.31.17.4789: UDP, length 62
IP 192.168.31.18.45515 > 192.168.31.17.4789: UDP, length 62
IP 192.168.31.17.50795 > 192.168.31.18.4789: UDP, length 25498
IP 192.168.31.17.50795 > 192.168.31.18.4789: UDP, length 64922
IP 192.168.31.17.50795 > 192.168.31.18.4789: UDP, length 64922
IP 192.168.31.18.45367 > 192.168.31.17.4789: UDP, length 62
IP 192.168.31.17.54206 > 192.168.31.18.4789: UDP, length 38170

> This patch removes the argument and and adds a nocheck argument
> for checksum setting. This eliminates the unnecessary dependency
> on a UDP socket for UDP tunnel transmit.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/vxlan.c       | 10 ++++++----
>  include/net/udp_tunnel.h  | 16 ++++++++--------
>  net/ipv4/udp_tunnel.c     | 12 ++++++------
>  net/ipv6/ip6_udp_tunnel.c | 12 ++++++------
>  4 files changed, 26 insertions(+), 24 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 6b6b456..4fb4205 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1763,8 +1763,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
>
>         skb_set_inner_protocol(skb, htons(ETH_P_TEB));
>
> -       udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
> -                            ttl, src_port, dst_port);
> +       udp_tunnel6_xmit_skb(dst, skb, dev, saddr, daddr, prio,
> +                            ttl, src_port, dst_port,
> +                            udp_get_no_check6_tx(vs->sock->sk));
>         return 0;
>  err:
>         dst_release(dst);
> @@ -1842,8 +1843,9 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>
>         skb_set_inner_protocol(skb, htons(ETH_P_TEB));
>
> -       return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
> -                                  ttl, df, src_port, dst_port, xnet);
> +       return udp_tunnel_xmit_skb(rt, skb, src, dst, tos,
> +                                  ttl, df, src_port, dst_port, xnet,
> +                                  vs->sock->sk->sk_no_check_tx);
>  }
>  EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
>
> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
> index 2a50a70..1a20d33 100644
> --- a/include/net/udp_tunnel.h
> +++ b/include/net/udp_tunnel.h
> @@ -77,17 +77,17 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
>                            struct udp_tunnel_sock_cfg *sock_cfg);
>
>  /* Transmit the skb using UDP encapsulation. */
> -int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
> -                       struct sk_buff *skb, __be32 src, __be32 dst,
> -                       __u8 tos, __u8 ttl, __be16 df, __be16 src_port,
> -                       __be16 dst_port, bool xnet);
> +int udp_tunnel_xmit_skb(struct rtable *rt, struct sk_buff *skb,
> +                       __be32 src, __be32 dst, __u8 tos, __u8 ttl,
> +                       __be16 df, __be16 src_port, __be16 dst_port,
> +                       bool xnet, bool nocheck);
>
>  #if IS_ENABLED(CONFIG_IPV6)
> -int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
> -                        struct sk_buff *skb, struct net_device *dev,
> -                        struct in6_addr *saddr, struct in6_addr *daddr,
> +int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
> +                        struct net_device *dev, struct in6_addr *saddr,
> +                        struct in6_addr *daddr,
>                          __u8 prio, __u8 ttl, __be16 src_port,
> -                        __be16 dst_port);
> +                        __be16 dst_port, bool nocheck);
>  #endif
>
>  void udp_tunnel_sock_release(struct socket *sock);
> diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
> index 9996e63..c83b354 100644
> --- a/net/ipv4/udp_tunnel.c
> +++ b/net/ipv4/udp_tunnel.c
> @@ -75,10 +75,10 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
>  }
>  EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
>
> -int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
> -                       struct sk_buff *skb, __be32 src, __be32 dst,
> -                       __u8 tos, __u8 ttl, __be16 df, __be16 src_port,
> -                       __be16 dst_port, bool xnet)
> +int udp_tunnel_xmit_skb(struct rtable *rt, struct sk_buff *skb,
> +                       __be32 src, __be32 dst, __u8 tos, __u8 ttl,
> +                       __be16 df, __be16 src_port, __be16 dst_port,
> +                       bool xnet, bool nocheck)
>  {
>         struct udphdr *uh;
>
> @@ -90,9 +90,9 @@ int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
>         uh->source = src_port;
>         uh->len = htons(skb->len);
>
> -       udp_set_csum(sock->sk->sk_no_check_tx, skb, src, dst, skb->len);
> +       udp_set_csum(nocheck, skb, src, dst, skb->len);
>
> -       return iptunnel_xmit(sock->sk, rt, skb, src, dst, IPPROTO_UDP,
> +       return iptunnel_xmit(skb->sk, rt, skb, src, dst, IPPROTO_UDP,
>                              tos, ttl, df, xnet);
>  }
>  EXPORT_SYMBOL_GPL(udp_tunnel_xmit_skb);
> diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
> index 8db6c98..32d9b26 100644
> --- a/net/ipv6/ip6_udp_tunnel.c
> +++ b/net/ipv6/ip6_udp_tunnel.c
> @@ -62,14 +62,14 @@ error:
>  }
>  EXPORT_SYMBOL_GPL(udp_sock_create6);
>
> -int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
> -                        struct sk_buff *skb, struct net_device *dev,
> -                        struct in6_addr *saddr, struct in6_addr *daddr,
> -                        __u8 prio, __u8 ttl, __be16 src_port, __be16 dst_port)
> +int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
> +                        struct net_device *dev, struct in6_addr *saddr,
> +                        struct in6_addr *daddr,
> +                        __u8 prio, __u8 ttl, __be16 src_port,
> +                        __be16 dst_port, bool nocheck)
>  {
>         struct udphdr *uh;
>         struct ipv6hdr *ip6h;
> -       struct sock *sk = sock->sk;
>
>         __skb_push(skb, sizeof(*uh));
>         skb_reset_transport_header(skb);
> @@ -85,7 +85,7 @@ int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
>                             | IPSKB_REROUTED);
>         skb_dst_set(skb, dst);
>
> -       udp6_set_csum(udp_get_no_check6_tx(sk), skb, saddr, daddr, skb->len);
> +       udp6_set_csum(nocheck, skb, saddr, daddr, skb->len);
>
>         __skb_push(skb, sizeof(*ip6h));
>         skb_reset_network_header(skb);
> --
> 2.2.0.rc0.207.ga3a616c
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
