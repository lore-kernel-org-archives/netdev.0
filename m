From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next v5 1/3] udp-tunnel: Expand UDP tunnel APIs
Date: Thu, 11 Sep 2014 14:04:19 -0700
Message-ID: <CA+mtBx9FLLofOQZ_VRvnPhSoHhXv+3hC=p25LkQMgrgofrnFwg@mail.gmail.com>
References: <1410406193-6185-1-git-send-email-azhou@nicira.com>
	<1410406193-6185-2-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:45581 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbaIKVEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 17:04:20 -0400
Received: by mail-ig0-f170.google.com with SMTP id l13so89517iga.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 14:04:20 -0700 (PDT)
In-Reply-To: <1410406193-6185-2-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 8:29 PM, Andy Zhou <azhou@nicira.com> wrote:
> Added common udp tunnel socket creation, and packet transmission APIs
> API that can be used by other UDP based tunneling protocol
> implementation.
>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---
>  include/net/udp_tunnel.h  |   73 +++++++++++++++++++++++++++
>  net/ipv4/Kconfig          |    1 +
>  net/ipv4/udp_tunnel.c     |  108 ++++++++++++++++++++++++++--------------
>  net/ipv6/Makefile         |    1 +
>  net/ipv6/ip6_udp_tunnel.c |  121 +++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 268 insertions(+), 36 deletions(-)
>  create mode 100644 net/ipv6/ip6_udp_tunnel.c
>
> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
> index ffd69cb..e9dcf83 100644
> --- a/include/net/udp_tunnel.h
> +++ b/include/net/udp_tunnel.h
> @@ -1,6 +1,14 @@
>  #ifndef __NET_UDP_TUNNEL_H
>  #define __NET_UDP_TUNNEL_H
>
> +#include <net/ip_tunnels.h>
> +#include <net/udp.h>
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +#include <net/ipv6.h>
> +#include <net/addrconf.h>
> +#endif
> +
>  struct udp_port_cfg {
>         u8                      family;
>
> @@ -29,4 +37,69 @@ struct udp_port_cfg {
>  int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
>                     struct socket **sockp);
>
> +#if IS_ENABLED(CONFIG_IPV6)
> +int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
> +                    struct socket **sockp);
> +#else
> +static inline int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
> +                                  struct socket **sockp)
> +{
> +       return 0;
> +}
> +#endif
> +
> +struct udp_tunnel_sock;
> +
> +typedef int (*udp_tunnel_encap_rcv_t)(struct sock *sk, struct sk_buff *skb);
> +typedef void (*udp_tunnel_encap_destroy_t)(struct sock *sk);
> +
> +struct udp_tunnel_sock_cfg {
> +       struct socket *sock;    /* The socket UDP tunnel will attach to */
> +       /* Used for setting up udp_sock fields, see udp.h for details */
> +       __u8  encap_type;
> +       udp_tunnel_encap_rcv_t encap_rcv;
> +       udp_tunnel_encap_destroy_t encap_destroy;
> +};
> +
> +struct udp_tunnel_sock {
> +       struct socket *sock;
> +};
> +
> +struct udp_tunnel_sock *create_udp_tunnel_sock(struct net *net, size_t size,
> +                                              struct udp_tunnel_sock_cfg
> +                                                       *sock_cfg);
> +
> +int udp_tunnel_xmit_skb(struct udp_tunnel_sock *uts, struct rtable *rt,
> +                       struct sk_buff *skb, __be32 src, __be32 dst,
> +                       __u8 tos, __u8 ttl, __be16 df, __be16 src_port,
> +                       __be16 dst_port, bool xnet);
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +int udp_tunnel6_xmit_skb(struct udp_tunnel_sock *uts, struct dst_entry *dst,
> +                        struct sk_buff *skb, struct net_device *dev,
> +                        struct in6_addr *saddr, struct in6_addr *daddr,
> +                        __u8 prio, __u8 ttl, __be16 src_port,
> +                        __be16 dst_port);
> +#endif
> +
> +void udp_tunnel_sock_release(struct udp_tunnel_sock *uts);
> +void udp_tunnel_sock_free(struct udp_tunnel_sock *uts);
> +
> +static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
> +                                                        bool udp_csum)
> +{
> +       int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
> +
> +       return iptunnel_handle_offloads(skb, udp_csum, type);
> +}
> +
> +static inline void udp_tunnel_encap_enable(struct socket *sock)
> +{
> +#if IS_ENABLED(CONFIG_IPV6)
> +       if (sock->sk->sk_family == PF_INET6)
> +               ipv6_stub->udpv6_encap_enable();
> +       else
> +#endif
> +               udp_encap_enable();
> +}
>  #endif
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index dbc10d8..cccb95f 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -308,6 +308,7 @@ config NET_IPVTI
>           on top.
>
>  config NET_UDP_TUNNEL
> +       depends on (IPV6 || IPV6=n)
>         tristate
>         default n
>
> diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
> index 61ec1a6..d60c1a0 100644
> --- a/net/ipv4/udp_tunnel.c
> +++ b/net/ipv4/udp_tunnel.c
> @@ -14,42 +14,9 @@ int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
>         int err = -EINVAL;
>         struct socket *sock = NULL;
>
> -#if IS_ENABLED(CONFIG_IPV6)
>         if (cfg->family == AF_INET6) {
> -               struct sockaddr_in6 udp6_addr;
> -
> -               err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, &sock);
> -               if (err < 0)
> -                       goto error;
> -
> -               sk_change_net(sock->sk, net);
> -
> -               udp6_addr.sin6_family = AF_INET6;
> -               memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
> -                      sizeof(udp6_addr.sin6_addr));
> -               udp6_addr.sin6_port = cfg->local_udp_port;
> -               err = kernel_bind(sock, (struct sockaddr *)&udp6_addr,
> -                                 sizeof(udp6_addr));
> -               if (err < 0)
> -                       goto error;
> -
> -               if (cfg->peer_udp_port) {
> -                       udp6_addr.sin6_family = AF_INET6;
> -                       memcpy(&udp6_addr.sin6_addr, &cfg->peer_ip6,
> -                              sizeof(udp6_addr.sin6_addr));
> -                       udp6_addr.sin6_port = cfg->peer_udp_port;
> -                       err = kernel_connect(sock,
> -                                            (struct sockaddr *)&udp6_addr,
> -                                            sizeof(udp6_addr), 0);
> -               }
> -               if (err < 0)
> -                       goto error;
> -
> -               udp_set_no_check6_tx(sock->sk, !cfg->use_udp6_tx_checksums);
> -               udp_set_no_check6_rx(sock->sk, !cfg->use_udp6_rx_checksums);
> -       } else
> -#endif
> -       if (cfg->family == AF_INET) {
> +               return udp_sock_create6(net, cfg, sockp);
> +       } else if (cfg->family == AF_INET) {
>                 struct sockaddr_in udp_addr;
>
>                 err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, &sock);
> @@ -82,7 +49,6 @@ int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
>                 return -EPFNOSUPPORT;
>         }
>
> -
>         *sockp = sock;
>
>         return 0;
> @@ -97,4 +63,74 @@ error:
>  }
>  EXPORT_SYMBOL(udp_sock_create);
>
> +struct udp_tunnel_sock *
> +create_udp_tunnel_sock(struct net *net, size_t size,
> +                      struct udp_tunnel_sock_cfg *cfg)
> +{
> +       struct udp_tunnel_sock *uts;
> +       struct sock *sk;
> +       struct socket *sock = cfg->sock;
> +
> +       uts = kzalloc(size, GFP_KERNEL);
> +       if (!uts)
> +               return ERR_PTR(-ENOMEM);
> +
Allocating memory for the caller seems like overkill to me and there's
no guarantee that is what caller wants anyway (maybe they are using
array of static structures for instance). Seems like it would be just
as easy to return the sock and let caller allocate whatever else it
needs on its own (only field in udp_tunnel_sock is the sock anyway).

> +       sk = sock->sk;
> +
> +       /* Disable multicast loopback */
> +       inet_sk(sk)->mc_loop = 0;
> +
Probably want to enable checksum unnecessary conversions also.

> +       rcu_assign_sk_user_data(sk, uts);
> +
> +       udp_sk(sk)->encap_type = cfg->encap_type;
> +       udp_sk(sk)->encap_rcv = cfg->encap_rcv;
> +       udp_sk(sk)->encap_destroy = cfg->encap_destroy;
> +
> +       uts->sock = sock;
> +
> +       udp_tunnel_encap_enable(sock);
> +
> +       return uts;
> +}
> +EXPORT_SYMBOL_GPL(create_udp_tunnel_sock);
> +
> +int udp_tunnel_xmit_skb(struct udp_tunnel_sock *uts, struct rtable *rt,
> +                       struct sk_buff *skb, __be32 src, __be32 dst,
> +                       __u8 tos, __u8 ttl, __be16 df, __be16 src_port,
> +                       __be16 dst_port, bool xnet)
> +{
> +       struct udphdr *uh;
> +       struct socket *sock = uts->sock;
> +
> +       __skb_push(skb, sizeof(*uh));
> +       skb_reset_transport_header(skb);
> +       uh = udp_hdr(skb);
> +
> +       uh->dest = dst_port;
> +       uh->source = src_port;
> +       uh->len = htons(skb->len);
> +
> +       udp_set_csum(sock->sk->sk_no_check_tx, skb, src, dst, skb->len);
> +
> +       return iptunnel_xmit(sock->sk, rt, skb, src, dst, IPPROTO_UDP,
> +                            tos, ttl, df, xnet);
> +}
> +EXPORT_SYMBOL_GPL(udp_tunnel_xmit_skb);
> +
> +void udp_tunnel_sock_release(struct udp_tunnel_sock *uts)
> +{
> +       struct sock *sk = uts->sock->sk;
> +
> +       rcu_assign_sk_user_data(uts->sock->sk, NULL);
> +       kernel_sock_shutdown(uts->sock, SHUT_RDWR);
> +       sk_release_kernel(sk);
> +}
> +EXPORT_SYMBOL_GPL(udp_tunnel_sock_release);
> +
> +void udp_tunnel_sock_free(struct udp_tunnel_sock *uts)
> +{
> +       kfree(uts);
> +}
> +EXPORT_SYMBOL_GPL(udp_tunnel_sock_free);
> +
>  MODULE_LICENSE("GPL");
> diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
> index 2fe6836..45f830e 100644
> --- a/net/ipv6/Makefile
> +++ b/net/ipv6/Makefile

Probably good to make IPv4 and v6 stuff in separate patches.

> @@ -35,6 +35,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
>  obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
>  obj-$(CONFIG_IPV6_MIP6) += mip6.o
>  obj-$(CONFIG_NETFILTER)        += netfilter/
> +obj-$(CONFIG_NET_UDP_TUNNEL) += ip6_udp_tunnel.o
>
>  obj-$(CONFIG_IPV6_VTI) += ip6_vti.o
>  obj-$(CONFIG_IPV6_SIT) += sit.o
> diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
> new file mode 100644
> index 0000000..5109f46
> --- /dev/null
> +++ b/net/ipv6/ip6_udp_tunnel.c
> @@ -0,0 +1,121 @@
> +#include <linux/module.h>
> +#include <linux/errno.h>
> +#include <linux/socket.h>
> +#include <linux/udp.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/in6.h>
> +#include <net/udp.h>
> +#include <net/udp_tunnel.h>
> +#include <net/net_namespace.h>
> +#include <net/netns/generic.h>
> +#include <net/ip6_tunnel.h>
> +#include <net/ip6_checksum.h>
> +
> +int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
> +                    struct socket **sockp)
> +{
> +       struct sockaddr_in6 udp6_addr;
> +       int err = -EINVAL;
> +       struct socket *sock = NULL;
> +
> +       err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, &sock);
> +       if (err < 0)
> +               goto error;
> +
> +       sk_change_net(sock->sk, net);
> +
> +       udp6_addr.sin6_family = AF_INET6;
> +       memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
> +              sizeof(udp6_addr.sin6_addr));
> +       udp6_addr.sin6_port = cfg->local_udp_port;
> +       err = kernel_bind(sock, (struct sockaddr *)&udp6_addr,
> +                         sizeof(udp6_addr));
> +       if (err < 0)
> +               goto error;
> +
> +       if (cfg->peer_udp_port) {
> +               udp6_addr.sin6_family = AF_INET6;
> +               memcpy(&udp6_addr.sin6_addr, &cfg->peer_ip6,
> +                      sizeof(udp6_addr.sin6_addr));
> +               udp6_addr.sin6_port = cfg->peer_udp_port;
> +               err = kernel_connect(sock,
> +                                    (struct sockaddr *)&udp6_addr,
> +                                    sizeof(udp6_addr), 0);
> +       }
> +       if (err < 0)
> +               goto error;
> +
> +       udp_set_no_check6_tx(sock->sk, !cfg->use_udp6_tx_checksums);
> +       udp_set_no_check6_rx(sock->sk, !cfg->use_udp6_rx_checksums);
> +
> +       *sockp = sock;
> +       return 0;
> +
> +error:
> +       if (sock) {
> +               kernel_sock_shutdown(sock, SHUT_RDWR);
> +               sk_release_kernel(sock->sk);
> +       }
> +       *sockp = NULL;
> +       return err;
> +}
> +EXPORT_SYMBOL_GPL(udp_sock_create6);
> +
> +int udp_tunnel6_xmit_skb(struct udp_tunnel_sock *uts, struct dst_entry *dst,
> +                        struct sk_buff *skb, struct net_device *dev,
> +                        struct in6_addr *saddr, struct in6_addr *daddr,
> +                        __u8 prio, __u8 ttl, __be16 src_port, __be16 dst_port)
> +{
> +       struct udphdr *uh;
> +       struct ipv6hdr *ip6h;
> +
> +       __skb_push(skb, sizeof(*uh));
> +       skb_reset_transport_header(skb);
> +       uh = udp_hdr(skb);
> +
> +       uh->dest = dst_port;
> +       uh->source = src_port;
> +
> +       uh->len = htons(skb->len);
> +       uh->check = 0;
> +
> +       memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> +       IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED
> +                           | IPSKB_REROUTED);
> +       skb_dst_set(skb, dst);
> +
> +       if (!skb_is_gso(skb) && !(dst->dev->features & NETIF_F_IPV6_CSUM)) {
> +               __wsum csum = skb_checksum(skb, 0, skb->len, 0);
> +
> +               skb->ip_summed = CHECKSUM_UNNECESSARY;
> +               uh->check = csum_ipv6_magic(saddr, daddr, skb->len,
> +                               IPPROTO_UDP, csum);
> +               if (uh->check == 0)
> +                       uh->check = CSUM_MANGLED_0;
> +       } else {
> +               skb->ip_summed = CHECKSUM_PARTIAL;
> +               skb->csum_start = skb_transport_header(skb) - skb->head;
> +               skb->csum_offset = offsetof(struct udphdr, check);
> +               uh->check = ~csum_ipv6_magic(saddr, daddr,
> +                               skb->len, IPPROTO_UDP, 0);
> +       }

Can't we call udp6_set_csum for this?

> +
> +       __skb_push(skb, sizeof(*ip6h));
> +       skb_reset_network_header(skb);
> +       ip6h              = ipv6_hdr(skb);
> +       ip6h->version     = 6;
> +       ip6h->priority    = prio;
> +       ip6h->flow_lbl[0] = 0;
> +       ip6h->flow_lbl[1] = 0;
> +       ip6h->flow_lbl[2] = 0;
> +       ip6h->payload_len = htons(skb->len);
> +       ip6h->nexthdr     = IPPROTO_UDP;
> +       ip6h->hop_limit   = ttl;
> +       ip6h->daddr       = *daddr;
> +       ip6h->saddr       = *saddr;
> +
> +       ip6tunnel_xmit(skb, dev);

So iptunnel_xmit creates the IP header, but ip6tunnel_xmit doesn't. It
should be on the TODO list to make this consistent!

> +       return 0;
> +}
> +EXPORT_SYMBOL_GPL(udp_tunnel6_xmit_skb);
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
