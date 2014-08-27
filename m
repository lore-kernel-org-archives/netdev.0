From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next v3 2/3] vxlan: Refactor vxlan driver to make use of the
 common UDP tunnel functions.
Date: Tue, 26 Aug 2014 22:19:15 -0700
Message-ID: <CACzMAJJeoVrCNmd_MN6_RTthudcXW17xafoxuqAdrsC=fCheUQ@mail.gmail.com>
References: <1409110530-4383-1-git-send-email-azhou@nicira.com>
	<1409110530-4383-2-git-send-email-azhou@nicira.com>
	<CA+mtBx8R2YyAMbPuw=iYDbLpSwRo_robnxOYPUFV2368-RzdLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:43282 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750919AbaH0FTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 01:19:16 -0400
Received: by mail-oa0-f54.google.com with SMTP id n16so12636056oag.41
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 22:19:15 -0700 (PDT)
In-Reply-To: <CA+mtBx8R2YyAMbPuw=iYDbLpSwRo_robnxOYPUFV2368-RzdLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2014 at 9:14 PM, Tom Herbert <therbert@google.com> wrote:
>
>
> On Tue, Aug 26, 2014 at 8:35 PM, Andy Zhou <azhou@nicira.com> wrote:
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> ---
>>  drivers/net/vxlan.c           |  199
>> ++++++++++++-----------------------------
>>  include/net/vxlan.h           |   16 ++--
>>  net/openvswitch/vport-vxlan.c |    6 +-
>>  3 files changed, 68 insertions(+), 153 deletions(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index beb377b..f1f1c48 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -42,6 +42,7 @@
>>  #include <net/netns/generic.h>
>>  #include <net/vxlan.h>
>>  #include <net/protocol.h>
>> +#include <net/udp_tunnel.h>
>>  #if IS_ENABLED(CONFIG_IPV6)
>>  #include <net/ipv6.h>
>>  #include <net/addrconf.h>
>> @@ -277,13 +278,7 @@ static inline struct vxlan_rdst
>> *first_remote_rtnl(struct vxlan_fdb *fdb)
>>  /* Find VXLAN socket based on network namespace and UDP port */
>>  static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
>>  {
>> -       struct vxlan_sock *vs;
>> -
>> -       hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
>> -               if (inet_sk(vs->sock->sk)->inet_sport == port)
>> -                       return vs;
>> -       }
>> -       return NULL;
>> +       return (struct vxlan_sock *)udp_tunnel_find_sock(net, port);
>
> It seems incorrect to assume that the socket returned is vxlan, presumably
> this could be some other type of tunnel socket.
>
If I drop udp_tunnel_find_sock API from last patch, then this should
not be an issue any more right?
vxlan driver will just keep track of its own open sock.
>>  }
>>
>>  static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, u32 id)
>> @@ -636,7 +631,7 @@ static int vxlan_gro_complete(struct sk_buff *skb, int
>> nhoff)
>>  static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
>>  {
>>         struct net_device *dev;
>> -       struct sock *sk = vs->sock->sk;
>> +       struct sock *sk = vs->uts.sock->sk;
>>         struct net *net = sock_net(sk);
>>         sa_family_t sa_family = sk->sk_family;
>>         __be16 port = inet_sk(sk)->inet_sport;
>> @@ -661,7 +656,7 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock
>> *vs)
>>  static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
>>  {
>>         struct net_device *dev;
>> -       struct sock *sk = vs->sock->sk;
>> +       struct sock *sk = vs->uts.sock->sk;
>>         struct net *net = sock_net(sk);
>>         sa_family_t sa_family = sk->sk_family;
>>         __be16 port = inet_sk(sk)->inet_sport;
>> @@ -1053,7 +1048,7 @@ static void vxlan_sock_hold(struct vxlan_sock *vs)
>>
>>  void vxlan_sock_release(struct vxlan_sock *vs)
>>  {
>> -       struct sock *sk = vs->sock->sk;
>> +       struct sock *sk = vs->uts.sock->sk;
>>         struct net *net = sock_net(sk);
>>         struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>>
>> @@ -1062,7 +1057,6 @@ void vxlan_sock_release(struct vxlan_sock *vs)
>>
>>         spin_lock(&vn->sock_lock);
>>         hlist_del_rcu(&vs->hlist);
>> -       rcu_assign_sk_user_data(vs->sock->sk, NULL);
>>         vxlan_notify_del_rx_port(vs);
>>         spin_unlock(&vn->sock_lock);
>>
>> @@ -1078,7 +1072,7 @@ static void vxlan_igmp_join(struct work_struct
>> *work)
>>  {
>>         struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev,
>> igmp_join);
>>         struct vxlan_sock *vs = vxlan->vn_sock;
>> -       struct sock *sk = vs->sock->sk;
>> +       struct sock *sk = vs->uts.sock->sk;
>>         union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
>>         int ifindex = vxlan->default_dst.remote_ifindex;
>>
>> @@ -1107,7 +1101,7 @@ static void vxlan_igmp_leave(struct work_struct
>> *work)
>>  {
>>         struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev,
>> igmp_leave);
>>         struct vxlan_sock *vs = vxlan->vn_sock;
>> -       struct sock *sk = vs->sock->sk;
>> +       struct sock *sk = vs->uts.sock->sk;
>>         union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
>>         int ifindex = vxlan->default_dst.remote_ifindex;
>>
>> @@ -1338,7 +1332,6 @@ out:
>>  }
>>
>>  #if IS_ENABLED(CONFIG_IPV6)
>> -
>>  static struct sk_buff *vxlan_na_create(struct sk_buff *request,
>>         struct neighbour *n, bool isrouter)
>>  {
>> @@ -1572,13 +1565,6 @@ static bool route_shortcircuit(struct net_device
>> *dev, struct sk_buff *skb)
>>         return false;
>>  }
>>
>> -static inline struct sk_buff *vxlan_handle_offloads(struct sk_buff *skb,
>> -                                                   bool udp_csum)
>> -{
>> -       int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM :
>> SKB_GSO_UDP_TUNNEL;
>> -       return iptunnel_handle_offloads(skb, udp_csum, type);
>> -}
>> -
>>  #if IS_ENABLED(CONFIG_IPV6)
>>  static int vxlan6_xmit_skb(struct vxlan_sock *vs,
>>                            struct dst_entry *dst, struct sk_buff *skb,
>> @@ -1587,13 +1573,13 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
>>                            __be16 src_port, __be16 dst_port, __be32 vni,
>>                            bool xnet)
>>  {
>> -       struct ipv6hdr *ip6h;
>>         struct vxlanhdr *vxh;
>> -       struct udphdr *uh;
>>         int min_headroom;
>>         int err;
>>
>> -       skb = vxlan_handle_offloads(skb,
>> !udp_get_no_check6_tx(vs->sock->sk));
>> +       skb = udp_tunnel_handle_offloads(skb,
>> +                                        !udp_get_no_check6_tx(
>> +                                                vs->uts.sock->sk));
>>         if (IS_ERR(skb))
>>                 return -EINVAL;
>>
>> @@ -1621,38 +1607,8 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
>>         vxh->vx_flags = htonl(VXLAN_FLAGS);
>>         vxh->vx_vni = vni;
>>
>> -       __skb_push(skb, sizeof(*uh));
>> -       skb_reset_transport_header(skb);
>> -       uh = udp_hdr(skb);
>> -
>> -       uh->dest = dst_port;
>> -       uh->source = src_port;
>> -
>> -       uh->len = htons(skb->len);
>> -
>> -       memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>> -       IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE |
>> IPSKB_XFRM_TRANSFORMED |
>> -                             IPSKB_REROUTED);
>> -       skb_dst_set(skb, dst);
>> -
>> -       udp6_set_csum(udp_get_no_check6_tx(vs->sock->sk), skb,
>> -                     saddr, daddr, skb->len);
>> -
>> -       __skb_push(skb, sizeof(*ip6h));
>> -       skb_reset_network_header(skb);
>> -       ip6h              = ipv6_hdr(skb);
>> -       ip6h->version     = 6;
>> -       ip6h->priority    = prio;
>> -       ip6h->flow_lbl[0] = 0;
>> -       ip6h->flow_lbl[1] = 0;
>> -       ip6h->flow_lbl[2] = 0;
>> -       ip6h->payload_len = htons(skb->len);
>> -       ip6h->nexthdr     = IPPROTO_UDP;
>> -       ip6h->hop_limit   = ttl;
>> -       ip6h->daddr       = *daddr;
>> -       ip6h->saddr       = *saddr;
>> -
>> -       ip6tunnel_xmit(skb, dev);
>> +       udp_tunnel6_xmit_skb(vs->uts.sock, dst, skb, dev, saddr, daddr,
>> prio,
>> +                            ttl, src_port, dst_port);
>>         return 0;
>>  }
>>  #endif
>> @@ -1663,11 +1619,11 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>>                    __be16 src_port, __be16 dst_port, __be32 vni, bool
>> xnet)
>>  {
>>         struct vxlanhdr *vxh;
>> -       struct udphdr *uh;
>>         int min_headroom;
>>         int err;
>>
>> -       skb = vxlan_handle_offloads(skb, !vs->sock->sk->sk_no_check_tx);
>> +       skb = udp_tunnel_handle_offloads(skb,
>> +
>> !vs->uts.sock->sk->sk_no_check_tx);
>>         if (IS_ERR(skb))
>>                 return -EINVAL;
>>
>> @@ -1693,20 +1649,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>>         vxh->vx_flags = htonl(VXLAN_FLAGS);
>>         vxh->vx_vni = vni;
>>
>> -       __skb_push(skb, sizeof(*uh));
>> -       skb_reset_transport_header(skb);
>> -       uh = udp_hdr(skb);
>> -
>> -       uh->dest = dst_port;
>> -       uh->source = src_port;
>> -
>> -       uh->len = htons(skb->len);
>> -
>> -       udp_set_csum(vs->sock->sk->sk_no_check_tx, skb,
>> -                    src, dst, skb->len);
>> -
>> -       return iptunnel_xmit(vs->sock->sk, rt, skb, src, dst, IPPROTO_UDP,
>> -                            tos, ttl, df, xnet);
>> +       return udp_tunnel_xmit_skb(vs->uts.sock, rt, skb, src, dst, tos,
>> +                                  ttl, df, src_port, dst_port, xnet);
>>  }
>>  EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
>>
>> @@ -1831,18 +1775,18 @@ static void vxlan_xmit_one(struct sk_buff *skb,
>> struct net_device *dev,
>>                 tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
>>                 ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
>>
>> -               err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
>> -                                    fl4.saddr, dst->sin.sin_addr.s_addr,
>> -                                    tos, ttl, df, src_port, dst_port,
>> -                                    htonl(vni << 8),
>> -                                    !net_eq(vxlan->net,
>> dev_net(vxlan->dev)));
>> +               err = udp_tunnel_xmit_skb(vxlan->vn_sock->uts.sock, rt,
>> skb,
>> +                                         fl4.saddr,
>> dst->sin.sin_addr.s_addr,
>> +                                         tos, ttl, df, src_port,
>> dst_port,
>> +                                         !net_eq(vxlan->net,
>> +                                                 dev_net(vxlan->dev)));
>>
>>                 if (err < 0)
>>                         goto rt_tx_error;
>>                 iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
>>  #if IS_ENABLED(CONFIG_IPV6)
>>         } else {
>> -               struct sock *sk = vxlan->vn_sock->sock->sk;
>> +               struct sock *sk = vxlan->vn_sock->uts.sock->sk;
>>                 struct dst_entry *ndst;
>>                 struct flowi6 fl6;
>>                 u32 flags;
>> @@ -2204,8 +2148,8 @@ void vxlan_get_rx_port(struct net_device *dev)
>>         spin_lock(&vn->sock_lock);
>>         for (i = 0; i < PORT_HASH_SIZE; ++i) {
>>                 hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
>> -                       port = inet_sk(vs->sock->sk)->inet_sport;
>> -                       sa_family = vs->sock->sk->sk_family;
>> +                       port = inet_sk(vs->uts.sock->sk)->inet_sport;
>> +                       sa_family = vs->uts.sock->sk->sk_family;
>>                         dev->netdev_ops->ndo_add_vxlan_port(dev,
>> sa_family,
>>                                                             port);
>>                 }
>> @@ -2335,79 +2279,60 @@ static const struct ethtool_ops vxlan_ethtool_ops
>> = {
>>  static void vxlan_del_work(struct work_struct *work)
>>  {
>>         struct vxlan_sock *vs = container_of(work, struct vxlan_sock,
>> del_work);
>> -
>> -       sk_release_kernel(vs->sock->sk);
>> +       udp_tunnel_sock_release(&vs->uts);
>>         kfree_rcu(vs, rcu);
>>  }
>>
>> -static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
>> -                                       __be16 port, u32 flags)
>> +/* Create new listen socket if needed */
>> +static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16
>> port,
>> +                                             vxlan_rcv_t rcv, void *data,
>> +                                             u32 flags)
>>  {
>> -       struct socket *sock;
>> -       struct udp_port_cfg udp_conf;
>> -       int err;
>> +       struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>> +       struct vxlan_sock *vs;
>> +       struct udp_tunnel_socket_cfg vxlan_ts_cfg;
>> +       bool ipv6 = !!(flags & VXLAN_F_IPV6);
>> +       unsigned int h;
>>
>> -       memset(&udp_conf, 0, sizeof(udp_conf));
>> +       memset(&vxlan_ts_cfg, 0, sizeof(struct udp_tunnel_socket_cfg));
>>
>>         if (ipv6) {
>> -               udp_conf.family = AF_INET6;
>> -               udp_conf.use_udp6_tx_checksums =
>> +               vxlan_ts_cfg.port.family = AF_INET6;
>> +               vxlan_ts_cfg.port.use_udp6_tx_checksums =
>>                     !!(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
>> -               udp_conf.use_udp6_rx_checksums =
>> +               vxlan_ts_cfg.port.use_udp6_rx_checksums =
>>                     !!(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
>>         } else {
>> -               udp_conf.family = AF_INET;
>> -               udp_conf.local_ip.s_addr = INADDR_ANY;
>> -               udp_conf.use_udp_checksums =
>> +               vxlan_ts_cfg.port.family = AF_INET;
>> +               vxlan_ts_cfg.port.local_ip.s_addr = INADDR_ANY;
>> +               vxlan_ts_cfg.port.use_udp_checksums =
>>                     !!(flags & VXLAN_F_UDP_CSUM);
>>         }
>>
>> -       udp_conf.local_udp_port = port;
>> +       vxlan_ts_cfg.port.local_udp_port = port;
>> +       vxlan_ts_cfg.encap_type = 1;
>> +       vxlan_ts_cfg.encap_rcv = vxlan_udp_encap_recv;
>> +       vxlan_ts_cfg.encap_destroy = NULL;
>>
>> -       /* Open UDP socket */
>> -       err = udp_sock_create(net, &udp_conf, &sock);
>> -       if (err < 0)
>> -               return ERR_PTR(err);
>> -
>> -       /* Disable multicast loopback */
>> -       inet_sk(sock->sk)->mc_loop = 0;
>> -
>> -       return sock;
>> -}
>> -
>> -/* Create new listen socket if needed */
>> -static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16
>> port,
>> -                                             vxlan_rcv_t *rcv, void
>> *data,
>> -                                             u32 flags)
>> -{
>> -       struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>> -       struct vxlan_sock *vs;
>> -       struct socket *sock;
>> -       struct sock *sk;
>> -       unsigned int h;
>> -       bool ipv6 = !!(flags & VXLAN_F_IPV6);
>> -
>> -       vs = kzalloc(sizeof(*vs), GFP_KERNEL);
>> +       vs = (struct vxlan_sock *)create_udp_tunnel_sock(net, sizeof(*vs),
>> +                                                        NULL,
>> +                                                        &vxlan_ts_cfg);
>>         if (!vs)
>>                 return ERR_PTR(-ENOMEM);
>>
>>         for (h = 0; h < VNI_HASH_SIZE; ++h)
>>                 INIT_HLIST_HEAD(&vs->vni_list[h]);
>>
>> -       INIT_WORK(&vs->del_work, vxlan_del_work);
>> +       spin_lock(&vn->sock_lock);
>> +       list_add(&vs->next, &vn->vxlan_list);
>> +       spin_unlock(&vn->sock_lock);
>>
>> -       sock = vxlan_create_sock(net, ipv6, port, flags);
>> -       if (IS_ERR(sock)) {
>> -               kfree(vs);
>> -               return ERR_CAST(sock);
>> -       }
>> +       INIT_WORK(&vs->del_work, vxlan_del_work);
>>
>> -       vs->sock = sock;
>> -       sk = sock->sk;
>>         atomic_set(&vs->refcnt, 1);
>> +
>>         vs->rcv = rcv;
>> -       vs->data = data;
>> -       rcu_assign_sk_user_data(vs->sock->sk, vs);
>> +       vs->rcv_data = data;
>>
>>         /* Initialize the vxlan udp offloads structure */
>>         vs->udp_offloads.port = port;
>> @@ -2419,24 +2344,13 @@ static struct vxlan_sock
>> *vxlan_socket_create(struct net *net, __be16 port,
>>         vxlan_notify_add_rx_port(vs);
>>         spin_unlock(&vn->sock_lock);
>>
>> -       /* Mark socket as an encapsulation socket. */
>> -       udp_sk(sk)->encap_type = 1;
>> -       udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
>> -#if IS_ENABLED(CONFIG_IPV6)
>> -       if (ipv6)
>> -               ipv6_stub->udpv6_encap_enable();
>> -       else
>> -#endif
>> -               udp_encap_enable();
>> -
>>         return vs;
>>  }
>>
>>  struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
>> -                                 vxlan_rcv_t *rcv, void *data,
>> +                                 vxlan_rcv_t rcv, void *data,
>>                                   bool no_share, u32 flags)
>>  {
>> -       struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>>         struct vxlan_sock *vs;
>>
>>         vs = vxlan_socket_create(net, port, rcv, data, flags);
>> @@ -2446,7 +2360,6 @@ struct vxlan_sock *vxlan_sock_add(struct net *net,
>> __be16 port,
>>         if (no_share)   /* Return error if sharing is not allowed. */
>>                 return vs;
>>
>> -       spin_lock(&vn->sock_lock);
>>         vs = vxlan_find_sock(net, port);
>>         if (vs) {
>>                 if (vs->rcv == rcv)
>> @@ -2454,7 +2367,6 @@ struct vxlan_sock *vxlan_sock_add(struct net *net,
>> __be16 port,
>>                 else
>>                         vs = ERR_PTR(-EBUSY);
>>         }
>> -       spin_unlock(&vn->sock_lock);
>>
>>         if (!vs)
>>                 vs = ERR_PTR(-EINVAL);
>> @@ -2634,7 +2546,6 @@ static int vxlan_newlink(struct net *net, struct
>> net_device *dev,
>>         }
>>
>>         list_add(&vxlan->next, &vn->vxlan_list);
>> -
>>         return 0;
>>  }
>>
>> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
>> index d5f59f3..10bfc13 100644
>> --- a/include/net/vxlan.h
>> +++ b/include/net/vxlan.h
>> @@ -4,23 +4,27 @@
>>  #include <linux/skbuff.h>
>>  #include <linux/netdevice.h>
>>  #include <linux/udp.h>
>> +#include <net/udp_tunnel.h>
>>
>>  #define VNI_HASH_BITS  10
>>  #define VNI_HASH_SIZE  (1<<VNI_HASH_BITS)
>>
>>  struct vxlan_sock;
>> -typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb,
>> __be32 key);
>>
>> -/* per UDP socket information */
>> +typedef void (*vxlan_rcv_t)(struct vxlan_sock *vs, struct sk_buff *skb,
>> +                           __be32 key);
>> +
>> +/* per vxlan socket information */
>>  struct vxlan_sock {
>> +       struct udp_tunnel_sock uts;  /* Must be the first member */
>>         struct hlist_node hlist;
>> -       vxlan_rcv_t      *rcv;
>> -       void             *data;
>> +       struct list_head next;
>>         struct work_struct del_work;
>> -       struct socket    *sock;
>>         struct rcu_head   rcu;
>>         struct hlist_head vni_list[VNI_HASH_SIZE];
>>         atomic_t          refcnt;
>> +       vxlan_rcv_t       rcv;
>> +       void              *rcv_data;
>>         struct udp_offload udp_offloads;
>>  };
>>
>> @@ -35,7 +39,7 @@ struct vxlan_sock {
>>  #define VXLAN_F_UDP_ZERO_CSUM6_RX      0x100
>>
>>  struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
>> -                                 vxlan_rcv_t *rcv, void *data,
>> +                                 vxlan_rcv_t rcv, void *data,
>>                                   bool no_share, u32 flags);
>>
>>  void vxlan_sock_release(struct vxlan_sock *vs);
>> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
>> index d8b7e24..7599efd 100644
>> --- a/net/openvswitch/vport-vxlan.c
>> +++ b/net/openvswitch/vport-vxlan.c
>> @@ -59,7 +59,7 @@ static inline struct vxlan_port *vxlan_vport(const
>> struct vport *vport)
>>  static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32
>> vx_vni)
>>  {
>>         struct ovs_key_ipv4_tunnel tun_key;
>> -       struct vport *vport = vs->data;
>> +       struct vport *vport = vs->rcv_data;
>>         struct iphdr *iph;
>>         __be64 key;
>>
>> @@ -74,7 +74,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct
>> sk_buff *skb, __be32 vx_vni)
>>  static int vxlan_get_options(const struct vport *vport, struct sk_buff
>> *skb)
>>  {
>>         struct vxlan_port *vxlan_port = vxlan_vport(vport);
>> -       __be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
>> +       __be16 dst_port =
>> inet_sk(vxlan_port->vs->uts.sock->sk)->inet_sport;
>>
>>         if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
>>                 return -EMSGSIZE;
>> @@ -139,7 +139,7 @@ static int vxlan_tnl_send(struct vport *vport, struct
>> sk_buff *skb)
>>  {
>>         struct net *net = ovs_dp_get_net(vport->dp);
>>         struct vxlan_port *vxlan_port = vxlan_vport(vport);
>> -       __be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
>> +       __be16 dst_port =
>> inet_sk(vxlan_port->vs->uts.sock->sk)->inet_sport;
>>         struct rtable *rt;
>>         struct flowi4 fl;
>>         __be16 src_port;
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
