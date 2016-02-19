From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 2/2] VXLAN: Support outer IPv4 Tx checksums by default
Date: Fri, 19 Feb 2016 12:27:59 -0800
Message-ID: <CALx6S36VDm6Cku1bN-OvNAdu=U5TV-ZAMmStdsdmjWzbD+F3Ng@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
	<20160219192631.15687.78165.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33828 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422953AbcBSU17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:27:59 -0500
Received: by mail-io0-f171.google.com with SMTP id 9so121809623iom.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 12:27:59 -0800 (PST)
In-Reply-To: <20160219192631.15687.78165.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 11:26 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This change makes it so that if UDP CSUM is not specified we will default
> to enabling it.  The main motivation behind this is the fact that with the
> use of outer checksum we can greatly improve the performance for VXLAN
> tunnels on devices that don't know how to parse tunnel headers.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  drivers/net/vxlan.c |   19 +++++++++----------
>  include/net/vxlan.h |    2 +-
>  2 files changed, 10 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 766e6114a37f..909f7931c297 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1957,13 +1957,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>                         goto drop;
>                 sk = vxlan->vn4_sock->sock->sk;
>
> -               if (info) {
> -                       if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
> -                               df = htons(IP_DF);
> -               } else {
> -                       udp_sum = !!(flags & VXLAN_F_UDP_CSUM);
> -               }
> -
>                 rt = vxlan_get_route(vxlan, skb,
>                                      rdst ? rdst->remote_ifindex : 0, tos,
>                                      dst->sin.sin_addr.s_addr, &saddr,
> @@ -1997,6 +1990,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>                         return;
>                 }
>
> +               if (!info)
> +                       udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM_TX);
> +               else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
> +                       df = htons(IP_DF);
> +
>                 tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
>                 ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
>                 err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
> @@ -2920,8 +2918,9 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
>         if (data[IFLA_VXLAN_PORT])
>                 conf.dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
>
> -       if (data[IFLA_VXLAN_UDP_CSUM] && nla_get_u8(data[IFLA_VXLAN_UDP_CSUM]))
> -               conf.flags |= VXLAN_F_UDP_CSUM;
> +       if (data[IFLA_VXLAN_UDP_CSUM] &&
> +           !nla_get_u8(data[IFLA_VXLAN_UDP_CSUM]))
> +               conf.flags |= VXLAN_F_UDP_ZERO_CSUM_TX;
>
>         if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX] &&
>             nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
> @@ -3065,7 +3064,7 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
>             nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->cfg.addrmax) ||
>             nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->cfg.dst_port) ||
>             nla_put_u8(skb, IFLA_VXLAN_UDP_CSUM,
> -                       !!(vxlan->flags & VXLAN_F_UDP_CSUM)) ||
> +                       !(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM_TX)) ||
>             nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
>                         !!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_TX)) ||
>             nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index 748083de367a..6eda4ed4d78b 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -197,7 +197,7 @@ struct vxlan_dev {
>  #define VXLAN_F_L2MISS                 0x08
>  #define VXLAN_F_L3MISS                 0x10
>  #define VXLAN_F_IPV6                   0x20
> -#define VXLAN_F_UDP_CSUM               0x40
> +#define VXLAN_F_UDP_ZERO_CSUM_TX       0x40
>  #define VXLAN_F_UDP_ZERO_CSUM6_TX      0x80
>  #define VXLAN_F_UDP_ZERO_CSUM6_RX      0x100
>  #define VXLAN_F_REMCSUM_TX             0x200
>

Acked-by: Tom Herbert <tom@herbertland.com>

I would also note RFC7348 specifies:

UDP Checksum: It SHOULD be transmitted as zero. ...

The RFC doesn't provide any rationale as to why this is a SHOULD
(neither is there any discussion as to whether this pertains to IPv6
which has stronger requirements for non-zero UDP checksum). I think
there are two possibilities in the intent: 1) The authors assume that
computing UDP checksums is a significant performance hit which is
dis-proven by this patch 2) They are worried about devices that are
unable to compute receive checksums, however this would be addressed
by an allowance that devices can ignore non-zero UDP checksums for
VXLAN ("When a decapsulating end point receives a packet with a
non-zero checksum, it MAY choose to verify the checksum value.")


.
