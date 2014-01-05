From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH V1 net-next 2/2] net: Add UDP GRO support for vxlan traffic
Date: Sun, 5 Jan 2014 14:42:31 -0800
Message-ID: <CA+mtBx-g1tsBEG6D0oOmG-J_fz68fr6py2OY6RAtoJHUts7h3g@mail.gmail.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
	<1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, yanb@mellanox.com,
	shlomop@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35886 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbaAEWmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 17:42:31 -0500
Received: by mail-ig0-f176.google.com with SMTP id k19so5707614igc.3
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 14:42:31 -0800 (PST)
In-Reply-To: <1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 5, 2014 at 7:23 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Add GRO handlers for UDP, with the intent of being able to coalesce vxlan
> packets which encapsulate packets belonging to the same TCP session.
>
We need a generic solution, please don't assume that vxlan is the only
UDP encapsulation we'll have and let's avoid making UDP dependent on
VXLAN module (see GUE, GRE/UDP, QUIC, ...).

> The UDP GRO handler will only attempt to coalesce packets whose
> destination port is used as vxlan listening port. There are two
> issues here for which I will be happy to get feedback
>
> 1. what is the most efficient way to determine if a udp port is
> owned by the vxlan driver, e.g maybe through a bit map exported by
> the vxlan driver?
>
I would suggest doing a lookup to find the socket (like an early
demux). We can add another callback to UDP sockets to do GRO.  If
needed, we can optimize the socket lookup by doing a special case
lookup for encapsulation ports. Also, if the encapsulation is
transparent (like just using UDP to get RSS with IPIP) we should be
also be able to decap in this function, avoiding a mostly redundant
trip through the UDP stack. VXLAN or other UDP encapsulation
implementations would just need to populate this callback function
appropriately.

> 2. how to prevent the host GRO stack from coalescing guest UDP
> packets which went through vxlan encapsulation and happen to carry
> the same udp destination port as used by the host vxlan driver..
>
> On my setup, which is net-next (now with the mlx4 vxlan offloads patches) -- for
> single TCP session that goes through vxlan tunneling I got nice improvement
> from 6.8Gbs to 11.7Gbs
>
> --> UDP/VXLAN GRO disabled
> $ netperf  -H 192.168.52.147 -c -C
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.52.147 () port 0 AF_INET
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
>
>  87380  65536  65536    10.00      6821.21   14.99    29.14    0.720   1.400
>
> --> UDP/VXLAN GRO enabled
> $ netperf  -H 192.168.52.147 -c -C
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.52.147 () port 0 AF_INET
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
>
>  87380  65536  65536    10.00      11694.65   24.87    20.71    0.697   0.580
>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/vxlan.c    |    3 +
>  include/net/protocol.h |    3 +
>  net/ipv4/udp_offload.c |  127 ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 133 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index e3d8183..c1d6647 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -40,6 +40,7 @@
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
>  #include <net/vxlan.h>
> +#include <net/protocol.h>
>  #if IS_ENABLED(CONFIG_IPV6)
>  #include <net/ipv6.h>
>  #include <net/addrconf.h>
> @@ -562,6 +563,7 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
>                         dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
>                                                             port);
>         }
> +       udp_gro_add_vxlan_port(port);
>         rcu_read_unlock();
>  }
>
> @@ -579,6 +581,7 @@ static void vxlan_notify_del_rx_port(struct sock *sk)
>                         dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
>                                                             port);
>         }
> +       udp_gro_del_vxlan_port(port);
>         rcu_read_unlock();
>  }
>
> diff --git a/include/net/protocol.h b/include/net/protocol.h
> index fbf7676..ca42395 100644
> --- a/include/net/protocol.h
> +++ b/include/net/protocol.h
> @@ -103,6 +103,9 @@ int inet_del_offload(const struct net_offload *prot, unsigned char num);
>  void inet_register_protosw(struct inet_protosw *p);
>  void inet_unregister_protosw(struct inet_protosw *p);
>
> +void udp_gro_add_vxlan_port(__be16 port);
> +void udp_gro_del_vxlan_port(__be16 port);
> +
>  #if IS_ENABLED(CONFIG_IPV6)
>  int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
>  int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index bd09f65..2462469 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -13,6 +13,7 @@
>  #include <linux/skbuff.h>
>  #include <net/udp.h>
>  #include <net/protocol.h>
> +#include <net/vxlan.h>
>
>  static int udp4_ufo_send_check(struct sk_buff *skb)
>  {
> @@ -90,10 +91,136 @@ out:
>         return segs;
>  }
>
> +
> +static u8 udp_gro_vxlan_ports[1 << 16];
> +
> +void udp_gro_add_vxlan_port(__be16 port)
> +{
> +       udp_gro_vxlan_ports[port] = 1;
> +}
> +EXPORT_SYMBOL(udp_gro_add_vxlan_port);
> +
> +void udp_gro_del_vxlan_port(__be16 port)
> +{
> +       udp_gro_vxlan_ports[port] = 0;
> +}
> +EXPORT_SYMBOL(udp_gro_del_vxlan_port);
> +
> +static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
> +{
> +       struct sk_buff *p, **pp = NULL;
> +       struct udphdr *uh, *uh2;
> +       struct vxlanhdr *vh, *vh2;
> +       struct ethhdr *eh;
> +       unsigned int hlen, off_udp, off_vxlan, off_eth;
> +       struct packet_offload *ptype;
> +       __be16 type;
> +       int flush = 1;
> +
> +       off_udp = skb_gro_offset(skb);
> +       hlen  = off_udp + sizeof(*uh);
> +       uh    = skb_gro_header_fast(skb, off_udp);
> +       if (skb_gro_header_hard(skb, hlen)) {
> +               uh = skb_gro_header_slow(skb, hlen, off_udp);
> +               if (unlikely(!uh))
> +                       goto out;
> +       }
> +
> +       if (!udp_gro_vxlan_ports[uh->dest] || !skb->encapsulation)
> +               goto out;
> +
> +       skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
> +
> +       off_vxlan = skb_gro_offset(skb);
> +       hlen  = off_vxlan + sizeof(*vh);
> +       vh    = skb_gro_header_fast(skb, off_vxlan);
> +       if (skb_gro_header_hard(skb, hlen)) {
> +               vh = skb_gro_header_slow(skb, hlen, off_vxlan);
> +               if (unlikely(!vh))
> +                       goto out;
> +       }
> +       skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
> +       flush = 0;
> +
> +
> +       for (p = *head; p; p = p->next) {
> +               if (!NAPI_GRO_CB(p)->same_flow)
> +                       continue;
> +
> +               uh2 = (struct udphdr   *)(p->data + off_udp);
> +               vh2 = (struct vxlanhdr *)(p->data + off_vxlan);
> +
> +               if ((*(u32 *)&uh->source ^ *(u32 *)&uh2->source) |
> +                   (vh->vx_vni ^ vh2->vx_vni)) {
> +                       NAPI_GRO_CB(p)->same_flow = 0;
> +                       continue;
> +               }
> +
> +               goto found;
> +       }
> +
> +found:
> +
> +       off_eth = skb_gro_offset(skb);
> +       hlen = off_eth + sizeof(*eh);
> +       eh   = skb_gro_header_fast(skb, off_eth);
> +       if (skb_gro_header_hard(skb, hlen)) {
> +               eh = skb_gro_header_slow(skb, hlen, off_eth);
> +               if (unlikely(!eh))
> +                       goto out;
> +       }
> +       type = eh->h_proto;
> +       skb_gro_pull(skb, sizeof(*eh)); /* pull inner eth header */
> +
> +       rcu_read_lock();
> +       ptype = gro_find_receive_by_type(type);
> +       if (ptype == NULL) {
> +               flush = 1;
> +               goto out_unlock;
> +       }
> +
> +       pp = ptype->callbacks.gro_receive(head, skb);
> +
> +out_unlock:
> +       rcu_read_unlock();
> +out:
> +       NAPI_GRO_CB(skb)->flush |= flush;
> +
> +       return pp;
> +}
> +
> +static int udp_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +       __be16 newlen = htons(skb->len - nhoff);
> +       struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
> +       struct ethhdr *eh;
> +       struct packet_offload *ptype;
> +       __be16 type;
> +       /* 22 = 8 bytes for the vlxan header + 14 bytes for the inner eth header */
> +       int vxlan_len  = 22;
> +       int err = -ENOENT;
> +
> +       uh->len = newlen;
> +
> +       /* 16 = 8 bytes for the udp header + 8 bytes for the vxlan header */
> +       eh = (struct ethhdr *)(skb->data + nhoff + 16);
> +       type = eh->h_proto;
> +
> +       rcu_read_lock();
> +       ptype = gro_find_complete_by_type(type);
> +       if (ptype != NULL)
> +               err = ptype->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr) + vxlan_len);
> +
> +       rcu_read_unlock();
> +       return err;
> +}
> +
>  static const struct net_offload udpv4_offload = {
>         .callbacks = {
>                 .gso_send_check = udp4_ufo_send_check,
>                 .gso_segment = udp4_ufo_fragment,
> +               .gro_receive  = udp_gro_receive,
> +               .gro_complete = udp_gro_complete,
>         },
>  };
>
> --
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
