From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 8/8] vxlan: Add support for zero UDP6 checksums
Date: Tue, 13 May 2014 21:27:55 +0300
Message-ID: <CAJZOPZJBHQt3W5i2w=nyDsEm72ZysPOSdC4uAJhCPETM6XzqGA@mail.gmail.com>
References: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:44509 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855AbaEMS15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 14:27:57 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so948876qgf.21
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 11:27:56 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 7:59 PM, Tom Herbert <therbert@google.com> wrote:
> Added module parameters to specify sending of TX checksums and
> allow receiving RX checksums. Also added a module parameter and
> support for using IPv4 checksums on TX

Hi Tom,

So... module params have their limited (which could turn to be nasty)
nature, do we really want to have them here (which practically also
means supporting them forever) or maybe/better use some more
programmable method to control that?

> (default is off so zero checksums are sent).

Or.




>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/vxlan.c | 42 ++++++++++++++++++++++++++----------------
>  1 file changed, 26 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 1dfee9a..4839edb 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -83,6 +83,18 @@ static bool log_ecn_error = true;
>  module_param(log_ecn_error, bool, 0644);
>  MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
>
> +static bool use_udp_checksums;
> +module_param(use_udp_checksums, bool, 0644);
> +MODULE_PARM_DESC(use_udp_checksums, "Send UDP checksums (IPv4)");
> +
> +static bool udp6_tx_zero_checksums;
> +module_param(udp6_tx_zero_checksums, bool, 0644);
> +MODULE_PARM_DESC(udp6_tx_zero_checksums, "Send zero IPv6 checksums");
> +
> +static bool udp6_rx_zero_checksums;
> +module_param(udp6_rx_zero_checksums, bool, 0644);
> +MODULE_PARM_DESC(udp6_rx_zero_checksums, "Receive zero IPv6 checksums");
> +
>  static int vxlan_net_id;
>
>  static const u8 all_zeros_mac[ETH_ALEN];
> @@ -1666,27 +1678,13 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
>         uh->source = src_port;
>
>         uh->len = htons(skb->len);
> -       uh->check = 0;
>
>         memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>         IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
>                               IPSKB_REROUTED);
>         skb_dst_set(skb, dst);
>
> -       if (!skb_is_gso(skb) && !(dst->dev->features & NETIF_F_IPV6_CSUM)) {
> -               __wsum csum = skb_checksum(skb, 0, skb->len, 0);
> -               skb->ip_summed = CHECKSUM_UNNECESSARY;
> -               uh->check = csum_ipv6_magic(saddr, daddr, skb->len,
> -                                           IPPROTO_UDP, csum);
> -               if (uh->check == 0)
> -                       uh->check = CSUM_MANGLED_0;
> -       } else {
> -               skb->ip_summed = CHECKSUM_PARTIAL;
> -               skb->csum_start = skb_transport_header(skb) - skb->head;
> -               skb->csum_offset = offsetof(struct udphdr, check);
> -               uh->check = ~csum_ipv6_magic(saddr, daddr,
> -                                            skb->len, IPPROTO_UDP, 0);
> -       }
> +       udp6_set_csum(vs->sock->sk, skb, saddr, daddr, skb->len);
>
>         __skb_push(skb, sizeof(*ip6h));
>         skb_reset_network_header(skb);
> @@ -1756,7 +1754,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>         uh->source = src_port;
>
>         uh->len = htons(skb->len);
> -       uh->check = 0;
> +
> +       udp_set_csum(vs->sock->sk, skb, src, dst, skb->len);
>
>         err = handle_offloads(skb);
>         if (err)
> @@ -2442,6 +2441,13 @@ static struct socket *create_v6_sock(struct net *net, __be16 port)
>
>         /* Disable multicast loopback */
>         inet_sk(sk)->mc_loop = 0;
> +
> +       if (udp6_rx_zero_checksums)
> +               udp_set_no_check6_rx(sk, true);
> +
> +       if (udp6_tx_zero_checksums)
> +               udp_set_no_check6_tx(sk, true);
> +
>         return sock;
>  }
>
> @@ -2486,6 +2492,10 @@ static struct socket *create_v4_sock(struct net *net, __be16 port)
>
>         /* Disable multicast loopback */
>         inet_sk(sk)->mc_loop = 0;
> +
> +       if (!use_udp_checksums)
> +               sock->sk->sk_no_check_tx = 1;
> +
>         return sock;
>  }
>
> --
> 1.9.1.423.g4596e3a
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
