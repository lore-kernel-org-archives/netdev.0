From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next V2 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 7 Jan 2014 10:08:05 -0800
Message-ID: <CA+mtBx-fUe_VbUUnjEVXeJO=87yypoDuMfoctO0Q3nMx+6UZFA@mail.gmail.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:32876 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbaAGSIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 13:08:07 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so807438iec.13
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 10:08:06 -0800 (PST)
In-Reply-To: <1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 7:29 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Add gro handlers for vxlan using the udp gro infrastructure
>
> On my setup, which is net-next (now with the mlx4 vxlan offloads patches) --
> for single TCP session that goes through vxlan tunneling I got nice improvement
> from 6.8Gbs to 11.5Gbs
>
> --> UDP/VXLAN GRO disabled
> $ netperf  -H 192.168.52.147 -c -C
>
> $ netperf -t TCP_STREAM -H 192.168.52.147 -c -C
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.52.147 () port 0 AF_INET
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
>
>  87380  65536  65536    10.00      6799.75   12.54    24.79    0.604   1.195
>
> --> UDP/VXLAN GRO enabled
>
> $ netperf -t TCP_STREAM -H 192.168.52.147 -c -C
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.52.147 () port 0 AF_INET
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
>
>  87380  65536  65536    10.00      11562.72   24.90    20.34    0.706   0.577
>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/vxlan.c |  101 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 99 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 481f85d..b51823b 100644
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
> @@ -554,6 +555,98 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
>         return 1;
>  }
>
> +static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff *skb)
> +{
> +       struct sk_buff *p, **pp = NULL;
> +       struct vxlanhdr *vh, *vh2;
> +       struct ethhdr *eh;
> +       unsigned int hlen, off, off_eth;
> +       const struct packet_offload *ptype;
> +       __be16 type;
> +       int flush = 1;
> +
> +       off  = skb_gro_offset(skb);
> +       hlen = off + sizeof(*vh);
> +       vh   = skb_gro_header_fast(skb, off);
> +       if (skb_gro_header_hard(skb, hlen)) {
> +               vh = skb_gro_header_slow(skb, hlen, off);
> +               if (unlikely(!vh))
> +                       goto out;
> +       }
> +
> +       flush = 0;
> +
> +       for (p = *head; p; p = p->next) {
> +               if (!NAPI_GRO_CB(p)->same_flow)
> +                       continue;
> +
> +               vh2 = (struct vxlanhdr   *)(p->data + off);
> +               if (vh->vx_vni ^ vh2->vx_vni) {

Why ^ instead of != ?

> +                       NAPI_GRO_CB(p)->same_flow = 0;
> +                       continue;
> +               }
> +               goto found;
> +       }
> +
> +found:
> +       skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
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
> +
> +       rcu_read_lock();
> +       ptype = gro_find_receive_by_type(type);
> +       if (ptype == NULL) {
> +               flush = 1;
> +               goto out_unlock;
> +       }
> +
> +       skb_gro_pull(skb, sizeof(*eh)); /* pull inner eth header */
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
> +static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +       struct ethhdr *eh;
> +       struct packet_offload *ptype;
> +       __be16 type;
> +       /* 22 = 8 bytes for the vlxan header + 14 bytes for the inner eth header */
> +       int vxlan_len  = 22;
> +       int err = -ENOSYS;
> +
> +       eh = (struct ethhdr *)(skb->data + nhoff + sizeof (struct vxlanhdr));
> +       type = eh->h_proto;
> +
> +       rcu_read_lock();
> +       ptype = gro_find_complete_by_type(type);
> +       if (ptype != NULL)
> +               err = ptype->callbacks.gro_complete(skb, nhoff + vxlan_len);
> +
> +       rcu_read_unlock();
> +       return err;
> +}
> +
> +static const struct net_offload vxlan_offload = {
> +       .callbacks = {
> +               .gro_receive  = vxlan_gro_receive,
> +               .gro_complete = vxlan_gro_complete,
> +       },
> +};
> +
>  /* Notify netdevs that UDP port started listening */
>  static void vxlan_notify_add_rx_port(struct sock *sk)
>  {
> @@ -568,6 +661,8 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
>                         dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
>                                                             port);
>         }
> +       if (sa_family == AF_INET)
> +               udp_add_offload(&vxlan_offload, port);
>         rcu_read_unlock();
>  }
>
> @@ -585,6 +680,8 @@ static void vxlan_notify_del_rx_port(struct sock *sk)
>                         dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
>                                                             port);
>         }
> +       if (sa_family == AF_INET)
> +               udp_del_offload(&vxlan_offload, port);
>         rcu_read_unlock();
>  }
>
> @@ -1125,8 +1222,8 @@ static void vxlan_rcv(struct vxlan_sock *vs,
>          * leave the CHECKSUM_UNNECESSARY, the device checksummed it
>          * for us. Otherwise force the upper layers to verify it.
>          */
> -       if (skb->ip_summed != CHECKSUM_UNNECESSARY || !skb->encapsulation ||
> -           !(vxlan->dev->features & NETIF_F_RXCSUM))
> +       if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||
> +           !skb->encapsulation || !(vxlan->dev->features & NETIF_F_RXCSUM))
>                 skb->ip_summed = CHECKSUM_NONE;
>
>         skb->encapsulation = 0;
> --
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
