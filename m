From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 4/4] openvswitch: IPv6 support for ovs_tunnel_get_egress_info
Date: Thu, 1 Oct 2015 17:11:56 -0700
Message-ID: <CALnjE+o-ou=Vpv8_e20-CyRMA62ceGiDOZuSaRU9Qwb_WBBP8Q@mail.gmail.com>
References: <cover.1443710454.git.jbenc@redhat.com>
	<8eeae62b794d6d7486cedd8178414d2fdfb6e4f8.1443710454.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36648 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbbJBAL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 20:11:57 -0400
Received: by igcrk20 with SMTP id rk20so6820106igc.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 17:11:56 -0700 (PDT)
In-Reply-To: <8eeae62b794d6d7486cedd8178414d2fdfb6e4f8.1443710454.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 1, 2015 at 7:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> For compat tunnel interfaces, reject IPv6 keys.
>
> Also fixes a related thinko in vport-vxlan: upcall->egress_tun_info is not
> yet set at the point where it is used, thus the obtained family is
> incorrect. As this is IPv4 anyway, just use AF_INET.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> New patch in v2 of the set.
> ---
>  net/openvswitch/vport-geneve.c |  4 ++-
>  net/openvswitch/vport-gre.c    |  4 ++-
>  net/openvswitch/vport-vxlan.c  |  6 ++--
>  net/openvswitch/vport.c        | 62 ++++++++++++++++++++++++++++--------------
>  net/openvswitch/vport.h        | 26 ++++++++++++++++++
>  5 files changed, 77 insertions(+), 25 deletions(-)
>
...

> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
> index fb3cdb85905d..0973acb5432c 100644
> --- a/net/openvswitch/vport-vxlan.c
> +++ b/net/openvswitch/vport-vxlan.c
> @@ -151,8 +151,7 @@ static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
>  {
>         struct vxlan_dev *vxlan = netdev_priv(vport->dev);
>         struct net *net = ovs_dp_get_net(vport->dp);
> -       unsigned short family = ip_tunnel_info_af(upcall->egress_tun_info);
> -       __be16 dst_port = vxlan_dev_dst_port(vxlan, family);
> +       __be16 dst_port = vxlan_dev_dst_port(vxlan, AF_INET);
>         __be16 src_port;
>         int port_min;
>         int port_max;
> @@ -160,7 +159,8 @@ static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
>         inet_get_local_port_range(net, &port_min, &port_max);
>         src_port = udp_flow_src_port(net, skb, 0, 0, true);
>
> -       return ovs_tunnel_get_egress_info(upcall, net,
> +       /* Only IPv4 supported in the compat layer. Pass NULL ipv6 socket. */
> +       return ovs_tunnel_get_egress_info(upcall, net, NULL,
>                                           skb, IPPROTO_UDP,
>                                           src_port, dst_port);
>  }
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index dc81dc619aa2..c58d95eed5fd 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -489,6 +489,7 @@ EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
>
>  int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
>                                struct net *net,
> +                              struct sock *ipv6_sk,
>                                struct sk_buff *skb,
>                                u8 ipproto,
>                                __be16 tp_src,
> @@ -498,13 +499,9 @@ int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
>         const struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
>         const struct ip_tunnel_key *tun_key;
>         u32 skb_mark = skb->mark;
> -       struct rtable *rt;
> -       struct flowi4 fl;
>
>         if (unlikely(!tun_info))
>                 return -EINVAL;
> -       if (ip_tunnel_info_af(tun_info) != AF_INET)
> -               return -EINVAL;
>
>         tun_key = &tun_info->key;
>
> @@ -512,22 +509,47 @@ int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
>          * The process may need to be changed if the corresponding process
>          * in vports ops changed.
>          */
> -       rt = ovs_tunnel_route_lookup(net, tun_key, skb_mark, &fl, ipproto);
> -       if (IS_ERR(rt))
> -               return PTR_ERR(rt);
> -
> -       ip_rt_put(rt);
> -
> -       /* Generate egress_tun_info based on tun_info,
> -        * saddr, tp_src and tp_dst
> -        */
> -       ip_tunnel_key_init(&egress_tun_info->key,
> -                          fl.saddr, tun_key->u.ipv4.dst,
> -                          tun_key->tos,
> -                          tun_key->ttl,
> -                          tp_src, tp_dst,
> -                          tun_key->tun_id,
> -                          tun_key->tun_flags);
> +       if (ip_tunnel_info_af(tun_info) == AF_INET) {
> +               struct rtable *rt;
> +               struct flowi4 fl;
> +
> +               rt = ovs_tunnel_route_lookup(net, tun_key, skb_mark, &fl, ipproto);
> +               if (IS_ERR(rt))
> +                       return PTR_ERR(rt);
> +
> +               ip_rt_put(rt);
> +
> +               /* Generate egress_tun_info based on tun_info,
> +               * saddr, tp_src and tp_dst
> +               */
> +               ip_tunnel_key_init(&egress_tun_info->key,
> +                                  fl.saddr, tun_key->u.ipv4.dst,
> +                                  tun_key->tos,
> +                                  tun_key->ttl,
> +                                  tp_src, tp_dst,
> +                                  tun_key->tun_id,
> +                                  tun_key->tun_flags);
> +       } else {
> +               struct dst_entry *ndst;
> +               struct flowi6 fl6;
> +
> +               if (!ipv6_sk)
> +                       return -EPFNOSUPPORT;
> +
> +               ndst = ovs_tunnel6_route_lookup(net, ipv6_sk, tun_key,
> +                                               skb_mark, &fl6, ipproto);
> +               if (IS_ERR(ndst))
> +                       return PTR_ERR(ndst);
> +               dst_release(ndst);
> +
> +               ip6_tunnel_key_init(&egress_tun_info->key,
> +                                   &fl6.saddr, &tun_key->u.ipv6.dst,
> +                                   tun_key->tos,
> +                                   tun_key->ttl,
> +                                   tp_src, tp_dst,
> +                                   tun_key->tun_id,
> +                                   tun_key->tun_flags);
> +       }

I dont see point of adding this code when IPv6 sampling not support by
the patch series.
