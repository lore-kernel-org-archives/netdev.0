From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH V3 net-next] LISP: Locator/Identifier Separation Protocol
Date: Wed, 18 Jun 2014 17:08:50 -0700
Message-ID: <CA+mtBx-aNF9-H+N_VmHqFGdVgGAdR5xer8F19wAvSKmUZpGy4Q@mail.gmail.com>
References: <86BFD474-6614-418E-B4B3-C725848FE196@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:62941 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836AbaFSAIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 20:08:51 -0400
Received: by mail-ie0-f174.google.com with SMTP id lx4so1346533iec.5
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 17:08:50 -0700 (PDT)
In-Reply-To: <86BFD474-6614-418E-B4B3-C725848FE196@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* Compute source port for outgoing packet
> + *   first choice to use L4 flow hash since it will spread
> + *     better and maybe available from hardware
> + *   secondary choice is to use jhash on the Ethernet header
> + */
> +static inline  __be16 udp_tunnel_get_src_port(__u16 port_min, __u16 port_max,
> +                                             struct sk_buff *skb)
> +{
> +       unsigned int range = (port_max - port_min) + 1;
> +       u32 hash;
> +
> +       hash = skb_get_hash(skb);
> +       if (!hash)
> +               hash = jhash(skb->data, 2 * ETH_ALEN,
> +                            (__force u32) skb->protocol);
> +

This is probably okay for now, but we should really be smarter here.
Looks like another consumer of a TX hash in skbuf (Eric was looking to
add that I believe).

> +       return htons((((u64) hash * range) >> 32) + port_min);
> +}
> +
> +/* Compute source UDP port for outgoing packets on UDP tunnels
> + */
>  static inline void udp_lib_close(struct sock *sk, long timeout)
>  {
>         sk_common_release(sk);
> @@ -270,7 +291,8 @@ void udp4_proc_exit(void);
>  #endif
>
>  int udpv4_offload_init(void);
> -
> +int udpv4_create_encap_sock(struct net *net, __be16 port, struct socket **psock,
> +                           bool csum);
>  void udp_init(void);
>
>  void udp_encap_enable(void);
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index b385348..0077832 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -331,6 +331,23 @@ struct ifla_vxlan_port_range {
>         __be16  high;
>  };
>
> +/* LISP section */
> +enum {
> +       IFLA_LISP_UNSPEC,
> +       IFLA_LISP_IID,
> +       IFLA_LISP_LOCAL,
> +       IFLA_LISP_REMOTE,
> +       IFLA_LISP_LOCAL6,
> +       IFLA_LISP_REMOTE6,
> +       IFLA_LISP_ENCAP_PORT,
> +       IFLA_LISP_LISTEN_PORT,
> +       IFLA_LISP_TOS,
> +       IFLA_LISP_TTL,
> +       IFLA_LISP_UDP_CSUM,
> +       __IFLA_LISP_MAX
> +};
> +#define IFLA_LISP_MAX (__IFLA_LISP_MAX - 1)
> +
>  /* Bonding section */
>
>  enum {
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index d92f94b..c69b198 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2524,78 +2524,3 @@ void __init udp_init(void)
>         sysctl_udp_wmem_min = SK_MEM_QUANTUM;
>  }
>
> -struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
> -                                      netdev_features_t features)
> -{
> -       struct sk_buff *segs = ERR_PTR(-EINVAL);
> -       u16 mac_offset = skb->mac_header;
> -       int mac_len = skb->mac_len;
> -       int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
> -       __be16 protocol = skb->protocol;
> -       netdev_features_t enc_features;
> -       int udp_offset, outer_hlen;
> -       unsigned int oldlen;
> -       bool need_csum;
> -
> -       oldlen = (u16)~skb->len;
> -
> -       if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
> -               goto out;
> -
> -       skb->encapsulation = 0;
> -       __skb_pull(skb, tnl_hlen);
> -       skb_reset_mac_header(skb);
> -       skb_set_network_header(skb, skb_inner_network_offset(skb));
> -       skb->mac_len = skb_inner_network_offset(skb);
> -       skb->protocol = htons(ETH_P_TEB);
> -
> -       need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
> -       if (need_csum)
> -               skb->encap_hdr_csum = 1;
> -
> -       /* segment inner packet. */
> -       enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
> -       segs = skb_mac_gso_segment(skb, enc_features);
> -       if (!segs || IS_ERR(segs)) {
> -               skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
> -                                    mac_len);
> -               goto out;
> -       }
> -
> -       outer_hlen = skb_tnl_header_len(skb);
> -       udp_offset = outer_hlen - tnl_hlen;
> -       skb = segs;
> -       do {
> -               struct udphdr *uh;
> -               int len;
> -
> -               skb_reset_inner_headers(skb);
> -               skb->encapsulation = 1;
> -
> -               skb->mac_len = mac_len;
> -
> -               skb_push(skb, outer_hlen);
> -               skb_reset_mac_header(skb);
> -               skb_set_network_header(skb, mac_len);
> -               skb_set_transport_header(skb, udp_offset);
> -               len = skb->len - udp_offset;
> -               uh = udp_hdr(skb);
> -               uh->len = htons(len);
> -
> -               if (need_csum) {
> -                       __be32 delta = htonl(oldlen + len);
> -
> -                       uh->check = ~csum_fold((__force __wsum)
> -                                              ((__force u32)uh->check +
> -                                               (__force u32)delta));
> -                       uh->check = gso_make_checksum(skb, ~uh->check);
> -
> -                       if (uh->check == 0)
> -                               uh->check = CSUM_MANGLED_0;
> -               }
> -
> -               skb->protocol = protocol;
> -       } while ((skb = skb->next));
> -out:
> -       return segs;
> -}
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 546d2d4..cb77404 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -248,3 +248,121 @@ int __init udpv4_offload_init(void)
>  {
>         return inet_add_offload(&udpv4_offload, IPPROTO_UDP);
>  }
> +
> +struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
> +                                      netdev_features_t features)
> +{
> +       struct sk_buff *segs = ERR_PTR(-EINVAL);
> +       u16 mac_offset = skb->mac_header;
> +       int mac_len = skb->mac_len;
> +       int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
> +       __be16 protocol = skb->protocol;
> +       netdev_features_t enc_features;
> +       int udp_offset, outer_hlen;
> +       unsigned int oldlen;
> +       bool need_csum;
> +
> +       oldlen = (u16)~skb->len;
> +
> +       if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
> +               goto out;
> +
> +       skb->encapsulation = 0;
> +       __skb_pull(skb, tnl_hlen);
> +       skb_reset_mac_header(skb);
> +       skb_set_network_header(skb, skb_inner_network_offset(skb));
> +       skb->mac_len = skb_inner_network_offset(skb);
> +       skb->protocol = htons(ETH_P_TEB);
> +
> +       need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
> +       if (need_csum)
> +               skb->encap_hdr_csum = 1;
> +
> +       /* segment inner packet. */
> +       enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
> +       segs = skb_mac_gso_segment(skb, enc_features);
> +       if (!segs || IS_ERR(segs)) {
> +               skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
> +                                    mac_len);
> +               goto out;
> +       }
> +
> +       outer_hlen = skb_tnl_header_len(skb);
> +       udp_offset = outer_hlen - tnl_hlen;
> +       skb = segs;
> +       do {
> +               struct udphdr *uh;
> +               int len;
> +
> +               skb_reset_inner_headers(skb);
> +               skb->encapsulation = 1;
> +
> +               skb->mac_len = mac_len;
> +
> +               skb_push(skb, outer_hlen);
> +               skb_reset_mac_header(skb);
> +               skb_set_network_header(skb, mac_len);
> +               skb_set_transport_header(skb, udp_offset);
> +               len = skb->len - udp_offset;
> +               uh = udp_hdr(skb);
> +               uh->len = htons(len);
> +
> +               if (need_csum) {
> +                       __be32 delta = htonl(oldlen + len);
> +
> +                       uh->check = ~csum_fold((__force __wsum)
> +                                              ((__force u32)uh->check +
> +                                               (__force u32)delta));
> +                       uh->check = gso_make_checksum(skb, ~uh->check);
> +
> +                       if (uh->check == 0)
> +                               uh->check = CSUM_MANGLED_0;
> +               }
> +
> +               skb->protocol = protocol;
> +       } while ((skb = skb->next));
> +out:
> +       return segs;
> +}
> +
Please split out generic changes into their own patches.

> +int udpv4_create_encap_sock(struct net *net, __be16 port, struct socket **psock,
> +                           bool csum)
> +{
> +       struct sock *sk;
> +       struct socket *sock;
> +       struct sockaddr_in lisp_addr = {
> +               .sin_family             = AF_INET,
> +               .sin_addr.s_addr        = htonl(INADDR_ANY),
> +               .sin_port               = port,
> +       };
> +       int rc;
> +
Still some lisp artifacts.

> +       /* Create UDP socket for encapsulation receive. */
> +       rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
> +       if (rc < 0) {
> +               pr_debug("UDP socket create failed\n");
> +               return rc;
> +       }
> +
> +       /* Put in proper namespace */
> +       sk = sock->sk;
> +       sk_change_net(sk, net);
> +
> +       rc = kernel_bind(sock, (struct sockaddr *)&lisp_addr,
> +                        sizeof(lisp_addr));
> +       if (rc < 0) {
> +               pr_debug("bind for UDP socket %pI4:%u (%d)\n",
> +                        &lisp_addr.sin_addr, ntohs(lisp_addr.sin_port), rc);
> +               sk_release_kernel(sk);
> +               return rc;
> +       }
> +
> +       *psock = sock;
> +       /* Disable multicast loopback */
> +       inet_sk(sk)->mc_loop = 0;
> +
> +       if (!csum)
> +               sock->sk->sk_no_check_tx = 1;
> +       return 0;
> +}
> +EXPORT_SYMBOL(udpv4_create_encap_sock)

I was actually thinking this function could be even more general. The
L2TP_ENCAPTYPE_UDP case in l2tp_tunnel_sock_create looks like
something we might be able to abstract out into a separate function--
it would include IPv6 support and the possibility of binding to other
than INADDR_ANY and connected sockets. l2tp_tunnel_cfg could be the
basis of udp_port_cfg which contains addresses, ports, and sockopts
like sk_no_check_tx...

> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
