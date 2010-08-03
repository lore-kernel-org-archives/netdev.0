From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3 1/2] core: Factor out flow calculation from get_rps_cpu
Date: Tue, 3 Aug 2010 12:05:34 +0800
Message-ID: <AANLkTikNOstJr3qqMUqtUoOm1xHOjw5uM7NpQUNJz4PR@mail.gmail.com>
References: <20100803030256.8486.82622.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, arnd@arndb.de, bhutchings@solarflare.com,
	netdev@vger.kernel.org, therbert@google.com, mst@redhat.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62511 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab0HCEFz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 00:05:55 -0400
Received: by wyb39 with SMTP id 39so3981768wyb.19
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 21:05:54 -0700 (PDT)
In-Reply-To: <20100803030256.8486.82622.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 3, 2010 at 11:02 AM, Krishna Kumar <krkumar2@in.ibm.com> wr=
ote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
>
> Factor out flow calculation code from get_rps_cpu, since macvtap
> driver can use the same code.
>
> Revisions:
>
> v2 - Ben: Separate flow calcuation out and use in select queue
> v3 - Arnd: Don't re-implement MIN
>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> =A0include/linux/netdevice.h | =A0 =A01
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 94 +++++++++++++++++++=
+++--------------
> =A02 files changed, 59 insertions(+), 36 deletions(-)
>
> diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.=
h
> --- org/include/linux/netdevice.h =A0 =A0 =A0 2010-08-03 08:19:57.000=
000000 +0530
> +++ new/include/linux/netdevice.h =A0 =A0 =A0 2010-08-03 08:19:57.000=
000000 +0530
> @@ -2253,6 +2253,7 @@ static inline const char *netdev_name(co
> =A0 =A0 =A0 =A0return dev->name;
> =A0}
>
> +extern int skb_calculate_flow(struct net_device *dev, struct sk_buff=
 *skb);
> =A0extern int netdev_printk(const char *level, const struct net_devic=
e *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *format, .=
=2E.)
> =A0 =A0 =A0 =A0__attribute__ ((format (printf, 3, 4)));
> diff -ruNp org/net/core/dev.c new/net/core/dev.c
> --- org/net/core/dev.c =A02010-08-03 08:19:57.000000000 +0530
> +++ new/net/core/dev.c =A02010-08-03 08:19:57.000000000 +0530
> @@ -2263,51 +2263,24 @@ static inline void ____napi_schedule(str
> =A0 =A0 =A0 =A0__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> =A0}
>
> -#ifdef CONFIG_RPS
> -
> -/* One global table that all flow-based protocols share. */
> -struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;
> -EXPORT_SYMBOL(rps_sock_flow_table);
> -
> =A0/*
> - * get_rps_cpu is called from netif_receive_skb and returns the targ=
et
> - * CPU from the RPS map of the receiving queue for a given skb.
> - * rcu_read_lock must be held on entry.
> + * skb_calculate_flow: calculate a flow hash based on src/dst addres=
ses
> + * and src/dst port numbers. On success, returns a hash number (> 0)=
,
> + * otherwise -1.
> =A0*/
> -static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct rps_dev_flow **rf=
lowp)
> +int skb_calculate_flow(struct net_device *dev, struct sk_buff *skb)
> =A0{
> + =A0 =A0 =A0 int hash =3D skb->rxhash;
> =A0 =A0 =A0 =A0struct ipv6hdr *ip6;
> =A0 =A0 =A0 =A0struct iphdr *ip;
> - =A0 =A0 =A0 struct netdev_rx_queue *rxqueue;
> - =A0 =A0 =A0 struct rps_map *map;
> - =A0 =A0 =A0 struct rps_dev_flow_table *flow_table;
> - =A0 =A0 =A0 struct rps_sock_flow_table *sock_flow_table;
> - =A0 =A0 =A0 int cpu =3D -1;
> =A0 =A0 =A0 =A0u8 ip_proto;
> - =A0 =A0 =A0 u16 tcpu;
> =A0 =A0 =A0 =A0u32 addr1, addr2, ihl;
> =A0 =A0 =A0 =A0union {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 v32;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u16 v16[2];
> =A0 =A0 =A0 =A0} ports;
>
> - =A0 =A0 =A0 if (skb_rx_queue_recorded(skb)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 index =3D skb_get_rx_queue(skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(index >=3D dev->num_rx_que=
ues)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ONCE(dev->num_rx_q=
ueues > 1, "%s received packet "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "on que=
ue %u, but number of RX queues is %u\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->na=
me, index, dev->num_rx_queues);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx + index;
> - =A0 =A0 =A0 } else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx;
> -
> - =A0 =A0 =A0 if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> -
> - =A0 =A0 =A0 if (skb->rxhash)
> + =A0 =A0 =A0 if (hash)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto got_hash; /* Skip hash computatio=
n on packet header */
>
> =A0 =A0 =A0 =A0switch (skb->protocol) {
> @@ -2334,6 +2307,7 @@ static int get_rps_cpu(struct net_device
> =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> =A0 =A0 =A0 =A0}
> +
> =A0 =A0 =A0 =A0switch (ip_proto) {
> =A0 =A0 =A0 =A0case IPPROTO_TCP:
> =A0 =A0 =A0 =A0case IPPROTO_UDP:
> @@ -2356,11 +2330,59 @@ static int get_rps_cpu(struct net_device
> =A0 =A0 =A0 =A0/* get a consistent hash (same value on both flow dire=
ctions) */
> =A0 =A0 =A0 =A0if (addr2 < addr1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swap(addr1, addr2);
> - =A0 =A0 =A0 skb->rxhash =3D jhash_3words(addr1, addr2, ports.v32, h=
ashrnd);
> - =A0 =A0 =A0 if (!skb->rxhash)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->rxhash =3D 1;
> +
> + =A0 =A0 =A0 hash =3D jhash_3words(addr1, addr2, ports.v32, hashrnd)=
;
> + =A0 =A0 =A0 if (!hash)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash =3D 1;
>
> =A0got_hash:
> + =A0 =A0 =A0 return hash;
> +
> +done:
> + =A0 =A0 =A0 return -1;
> +}
> +EXPORT_SYMBOL(skb_calculate_flow);

I have noticed that you use skb_calculate_flow() in
macvtap_get_queue() where skb->data doesn't point to the network
header but the ethernet header. However, skb_calculate_flow() assume
skb->data points to the network header. There are two choices:
 * update skb_calculate_flow to support called in ethernet layer.
 * pull skb before skb_calculate_flow, and push skb after
skb_calculate_flow() in macvtap_get_queue().

I prefer the former way.

BTW: the function name skb_calculate_flow isn't good. How about
skb_get_rxhash(). Maybe we can implement two versions: fast path and
slow path. And implement the fast path version as a inline function in
skbuff.h.

static inline u32 skb_get_rxhash(struct sk_buff *skb)
{
        u32 rxhash;

        rxhash =3D skb->rxhash;
        if (!rxhash)
                return __skb_get_rxhash(skb);
        return rxhash;
}


> +
> +#ifdef CONFIG_RPS
> +
> +/* One global table that all flow-based protocols share. */
> +struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;
> +EXPORT_SYMBOL(rps_sock_flow_table);
> +
> +/*
> + * get_rps_cpu is called from netif_receive_skb and returns the targ=
et
> + * CPU from the RPS map of the receiving queue for a given skb.
> + * rcu_read_lock must be held on entry.
> + */
> +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct rps_dev_flow **rf=
lowp)
> +{
> + =A0 =A0 =A0 struct netdev_rx_queue *rxqueue;
> + =A0 =A0 =A0 struct rps_map *map;
> + =A0 =A0 =A0 struct rps_dev_flow_table *flow_table;
> + =A0 =A0 =A0 struct rps_sock_flow_table *sock_flow_table;
> + =A0 =A0 =A0 int cpu =3D -1;
> + =A0 =A0 =A0 u16 tcpu;
> +
> + =A0 =A0 =A0 if (skb_rx_queue_recorded(skb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 index =3D skb_get_rx_queue(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(index >=3D dev->num_rx_que=
ues)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ONCE(dev->num_rx_q=
ueues > 1, "%s received packet "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "on que=
ue %u, but number of RX queues is %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->na=
me, index, dev->num_rx_queues);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx + index;
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx;
> +
> + =A0 =A0 =A0 if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> +
> + =A0 =A0 =A0 skb->rxhash =3D skb_calculate_flow(dev, skb);
> + =A0 =A0 =A0 if (skb->rxhash < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> +
> =A0 =A0 =A0 =A0flow_table =3D rcu_dereference(rxqueue->rps_flow_table=
);
> =A0 =A0 =A0 =A0sock_flow_table =3D rcu_dereference(rps_sock_flow_tabl=
e);
> =A0 =A0 =A0 =A0if (flow_table && sock_flow_table) {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
