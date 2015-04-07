From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 4/4] udp_tunnel: Pass UDP socket down through udp_tunnel{,6}_xmit_skb().
Date: Tue, 7 Apr 2015 11:56:14 -0700
Message-ID: <CALx6S37vo+9mDJKnkOhJXjArDLDju7hw4N5_Ggoir_U-OqmdAw@mail.gmail.com>
References: <20150405.221909.1825232827861250716.davem@davemloft.net>
	<CALx6S35rK35GFZAcqygjGNRUhC=vJx60TYLFDUeUd2bAim7Vzg@mail.gmail.com>
	<1428421534.2928.3.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428421534.2928.3.camel@stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 7, 2015 at 8:45 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mo, 2015-04-06 at 23:02 -0700, Tom Herbert wrote:
>> On Sun, Apr 5, 2015 at 7:19 PM, David Miller <davem@davemloft.net> wrote:
>> >
>> > That was we can make sure the output path of ipv4/ipv6 operate on
>> > the UDP socket rather than whatever random thing happens to be in
>> > skb->sk.
>> >
>> > Based upon a patch by Jiri Pirko.
>> >
>> > Signed-off-by: David S. Miller <davem@davemloft.net>
>> > ---
>> >  drivers/net/vxlan.c           | 14 ++++++++------
>> >  include/net/ip6_tunnel.h      |  5 +++--
>> >  include/net/ipv6.h            |  1 +
>> >  include/net/udp_tunnel.h      |  5 +++--
>> >  include/net/vxlan.h           |  2 +-
>> >  net/ipv4/geneve.c             |  2 +-
>> >  net/ipv4/udp_tunnel.c         |  4 ++--
>> >  net/ipv6/ip6_gre.c            |  2 +-
>> >  net/ipv6/ip6_tunnel.c         |  2 +-
>> >  net/ipv6/ip6_udp_tunnel.c     |  5 +++--
>> >  net/ipv6/output_core.c        | 21 ++++++++++++++++-----
>> >  net/openvswitch/vport-vxlan.c |  5 +++--
>> >  net/tipc/udp_media.c          |  6 ++++--
>> >  13 files changed, 47 insertions(+), 27 deletions(-)
>> >
>> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> > index b5fecb4..51baac7 100644
>> > --- a/drivers/net/vxlan.c
>> > +++ b/drivers/net/vxlan.c
>> > @@ -1672,7 +1672,8 @@ static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, u32 vxflags,
>> >  }
>> >
>> >  #if IS_ENABLED(CONFIG_IPV6)
>> > -static int vxlan6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
>> > +static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
>> > +                          struct sk_buff *skb,
>> >                            struct net_device *dev, struct in6_addr *saddr,
>> >                            struct in6_addr *daddr, __u8 prio, __u8 ttl,
>> >                            __be16 src_port, __be16 dst_port,
>> > @@ -1748,7 +1749,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
>> >
>> >         skb_set_inner_protocol(skb, htons(ETH_P_TEB));
>> >
>> > -       udp_tunnel6_xmit_skb(dst, skb, dev, saddr, daddr, prio,
>> > +       udp_tunnel6_xmit_skb(dst, sk, skb, dev, saddr, daddr, prio,
>> >                              ttl, src_port, dst_port,
>> >                              !!(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX));
>> >         return 0;
>> > @@ -1758,7 +1759,7 @@ err:
>> >  }
>> >  #endif
>> >
>> > -int vxlan_xmit_skb(struct rtable *rt, struct sk_buff *skb,
>> > +int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
>> >                    __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
>> >                    __be16 src_port, __be16 dst_port,
>> >                    struct vxlan_metadata *md, bool xnet, u32 vxflags)
>> > @@ -1827,7 +1828,7 @@ int vxlan_xmit_skb(struct rtable *rt, struct sk_buff *skb,
>> >
>> >         skb_set_inner_protocol(skb, htons(ETH_P_TEB));
>> >
>> > -       return udp_tunnel_xmit_skb(rt, skb, src, dst, tos,
>> > +       return udp_tunnel_xmit_skb(rt, sk, skb, src, dst, tos,
>> >                                    ttl, df, src_port, dst_port, xnet,
>> >                                    !(vxflags & VXLAN_F_UDP_CSUM));
>> >  }
>> > @@ -1882,6 +1883,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>> >                            struct vxlan_rdst *rdst, bool did_rsc)
>> >  {
>> >         struct vxlan_dev *vxlan = netdev_priv(dev);
>> > +       struct sock *sk = vxlan->vn_sock->sock->sk;
>> >         struct rtable *rt = NULL;
>> >         const struct iphdr *old_iph;
>> >         struct flowi4 fl4;
>> > @@ -1961,7 +1963,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>> >                 md.vni = htonl(vni << 8);
>> >                 md.gbp = skb->mark;
>> >
>> > -               err = vxlan_xmit_skb(rt, skb, fl4.saddr,
>> > +               err = vxlan_xmit_skb(rt, sk, skb, fl4.saddr,
>> >                                      dst->sin.sin_addr.s_addr, tos, ttl, df,
>> >                                      src_port, dst_port, &md,
>> >                                      !net_eq(vxlan->net, dev_net(vxlan->dev)),
>> > @@ -2021,7 +2023,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>> >                 md.vni = htonl(vni << 8);
>> >                 md.gbp = skb->mark;
>> >
>> > -               err = vxlan6_xmit_skb(ndst, skb, dev, &fl6.saddr, &fl6.daddr,
>> > +               err = vxlan6_xmit_skb(ndst, sk, skb, dev, &fl6.saddr, &fl6.daddr,
>> >                                       0, ttl, src_port, dst_port, &md,
>> >                                       !net_eq(vxlan->net, dev_net(vxlan->dev)),
>> >                                       vxlan->flags);
>> > diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
>> > index 1668be5..b8529aa 100644
>> > --- a/include/net/ip6_tunnel.h
>> > +++ b/include/net/ip6_tunnel.h
>> > @@ -73,13 +73,14 @@ __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
>> >  struct net *ip6_tnl_get_link_net(const struct net_device *dev);
>> >  int ip6_tnl_get_iflink(const struct net_device *dev);
>> >
>> > -static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>> > +static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
>> > +                                 struct net_device *dev)
>> >  {
>> >         struct net_device_stats *stats = &dev->stats;
>> >         int pkt_len, err;
>> >
>> >         pkt_len = skb->len;
>> > -       err = ip6_local_out(skb);
>> > +       err = ip6_local_out_sk(sk, skb);
>> >
>> >         if (net_xmit_eval(err) == 0) {
>> >                 struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
>> > diff --git a/include/net/ipv6.h b/include/net/ipv6.h
>> > index b6ae959..27470cd 100644
>> > --- a/include/net/ipv6.h
>> > +++ b/include/net/ipv6.h
>> > @@ -827,6 +827,7 @@ int ip6_input(struct sk_buff *skb);
>> >  int ip6_mc_input(struct sk_buff *skb);
>> >
>> >  int __ip6_local_out(struct sk_buff *skb);
>> > +int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb);
>> >  int ip6_local_out(struct sk_buff *skb);
>> >
>> >  /*
>> > diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
>> > index 1a20d33..c491c12 100644
>> > --- a/include/net/udp_tunnel.h
>> > +++ b/include/net/udp_tunnel.h
>> > @@ -77,13 +77,14 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
>> >                            struct udp_tunnel_sock_cfg *sock_cfg);
>> >
>> >  /* Transmit the skb using UDP encapsulation. */
>> > -int udp_tunnel_xmit_skb(struct rtable *rt, struct sk_buff *skb,
>> > +int udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
>> >                         __be32 src, __be32 dst, __u8 tos, __u8 ttl,
>> >                         __be16 df, __be16 src_port, __be16 dst_port,
>> >                         bool xnet, bool nocheck);
>> >
>> >  #if IS_ENABLED(CONFIG_IPV6)
>> > -int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
>> > +int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sock *sk,
>> > +                        struct sk_buff *skb,
>> >                          struct net_device *dev, struct in6_addr *saddr,
>> >                          struct in6_addr *daddr,
>> >                          __u8 prio, __u8 ttl, __be16 src_port,
>> > diff --git a/include/net/vxlan.h b/include/net/vxlan.h
>> > index 756e463..0082b5d 100644
>> > --- a/include/net/vxlan.h
>> > +++ b/include/net/vxlan.h
>> > @@ -145,7 +145,7 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
>> >
>> >  void vxlan_sock_release(struct vxlan_sock *vs);
>> >
>> > -int vxlan_xmit_skb(struct rtable *rt, struct sk_buff *skb,
>> > +int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
>> >                    __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
>> >                    __be16 src_port, __be16 dst_port, struct vxlan_metadata *md,
>> >                    bool xnet, u32 vxflags);
>> > diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
>> > index e64f8e9..b77f5e8 100644
>> > --- a/net/ipv4/geneve.c
>> > +++ b/net/ipv4/geneve.c
>> > @@ -136,7 +136,7 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
>> >
>> >         skb_set_inner_protocol(skb, htons(ETH_P_TEB));
>> >
>> > -       return udp_tunnel_xmit_skb(rt, skb, src, dst,
>> > +       return udp_tunnel_xmit_skb(rt, gs->sock->sk, skb, src, dst,
>> >                                    tos, ttl, df, src_port, dst_port, xnet,
>> >                                    !csum);
>> >  }
>> > diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
>> > index c83b354..6bb98cc 100644
>> > --- a/net/ipv4/udp_tunnel.c
>> > +++ b/net/ipv4/udp_tunnel.c
>> > @@ -75,7 +75,7 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
>> >  }
>> >  EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
>> >
>> > -int udp_tunnel_xmit_skb(struct rtable *rt, struct sk_buff *skb,
>> > +int udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
>> >                         __be32 src, __be32 dst, __u8 tos, __u8 ttl,
>> >                         __be16 df, __be16 src_port, __be16 dst_port,
>> >                         bool xnet, bool nocheck)
>> > @@ -92,7 +92,7 @@ int udp_tunnel_xmit_skb(struct rtable *rt, struct sk_buff *skb,
>> >
>> >         udp_set_csum(nocheck, skb, src, dst, skb->len);
>> >
>> > -       return iptunnel_xmit(skb->sk, rt, skb, src, dst, IPPROTO_UDP,
>> > +       return iptunnel_xmit(sk, rt, skb, src, dst, IPPROTO_UDP,
>> >                              tos, ttl, df, xnet);
>> >  }
>> >  EXPORT_SYMBOL_GPL(udp_tunnel_xmit_skb);
>> > diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
>> > index f724329..b5e6cc1 100644
>> > --- a/net/ipv6/ip6_gre.c
>> > +++ b/net/ipv6/ip6_gre.c
>> > @@ -760,7 +760,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
>> >
>> >         skb_set_inner_protocol(skb, protocol);
>> >
>> > -       ip6tunnel_xmit(skb, dev);
>> > +       ip6tunnel_xmit(NULL, skb, dev);
>> >         if (ndst)
>> >                 ip6_tnl_dst_store(tunnel, ndst);
>> >         return 0;
>> > diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
>> > index b6a211a..5cafd92 100644
>> > --- a/net/ipv6/ip6_tunnel.c
>> > +++ b/net/ipv6/ip6_tunnel.c
>> > @@ -1100,7 +1100,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
>> >         ipv6h->nexthdr = proto;
>> >         ipv6h->saddr = fl6->saddr;
>> >         ipv6h->daddr = fl6->daddr;
>> > -       ip6tunnel_xmit(skb, dev);
>> > +       ip6tunnel_xmit(NULL, skb, dev);
>>
>> By same should logic iptunnel_xmit call in ip_tunnel_xmit should take
>> NULL arg for socket?
>
> Sure!
>
Actually, for consistency amongst all the IP encapsulation protocols
and given Dave's comments on how this is supposed to work, maybe for
the v4 and v6 tunnels we could have a raw AF_INET{6} socket opened for
all the tunnels to use when ip_tunnel_xmit is called. If it makes a
difference for UDP encapsulation, a UDP socket could also be opened.

Tom

> Thanks, otherwise the patches look good!
>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
>
>
