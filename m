From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v4 1/2] core: Factor out flow calculation from get_rps_cpu
Date: Wed, 4 Aug 2010 19:22:58 +0800
Message-ID: <AANLkTikfW_PfYVfA-9cSx8-j16OuH6mr9K32apPj6nLy@mail.gmail.com>
References: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, arnd@arndb.de, mst@redhat.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	therbert@google.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52393 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201Ab0HDLXU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 07:23:20 -0400
Received: by wyb39 with SMTP id 39so5390234wyb.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 04:23:19 -0700 (PDT)
In-Reply-To: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 4, 2010 at 6:55 PM, Krishna Kumar <krkumar2@in.ibm.com> wro=
te:
> From: Krishna Kumar <krkumar2@in.ibm.com>
>
> Factor out flow calculation code from get_rps_cpu, since other
> functions can use the same code.
>
> Revisions:
>
> v2 - Ben: Separate flow calcuation out and use in select queue.
> v3 - Arnd: Don't re-implement MIN.
> v4 - Changli: skb->data points to ethernet header in macvtap, and
> =A0 =A0 =A0 =A0make a fast path.
>
> Tested macvtap with this patch.
>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> =A0include/linux/skbuff.h | =A0 11 ++++
> =A0net/core/dev.c =A0 =A0 =A0 =A0 | =A0107 ++++++++++++++++++++++----=
-------------
> =A02 files changed, 74 insertions(+), 44 deletions(-)
>
> diff -ruNp org/include/linux/skbuff.h new/include/linux/skbuff.h
> --- org/include/linux/skbuff.h =A02010-08-04 09:07:05.000000000 +0530
> +++ new/include/linux/skbuff.h =A02010-08-04 16:19:30.000000000 +0530
> @@ -558,6 +558,17 @@ extern unsigned int =A0 skb_find_text(stru
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
unsigned int to, struct ts_config *config,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct ts_state *state);
>
> +extern __u32 __skb_get_rxhash(struct sk_buff *skb);
> +static inline __u32 skb_get_rxhash(struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 __u32 rxhash =3D skb->rxhash;
> +
> + =A0 =A0 =A0 if (!rxhash)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxhash =3D __skb_get_rxhash(skb);
> +
> + =A0 =A0 =A0 return rxhash;
> +}
> +
> =A0#ifdef NET_SKBUFF_DATA_USES_OFFSET
> =A0static inline unsigned char *skb_end_pointer(const struct sk_buff =
*skb)
> =A0{
> diff -ruNp org/net/core/dev.c new/net/core/dev.c
> --- org/net/core/dev.c =A02010-08-04 09:07:05.000000000 +0530
> +++ new/net/core/dev.c =A02010-08-04 16:19:30.000000000 +0530
> @@ -2259,69 +2259,41 @@ static inline void ____napi_schedule(str
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
> + * __skb_get_rxhash: calculate a flow hash based on src/dst addresse=
s
> + * and src/dst port numbers. On success, returns a non-zero hash num=
ber,
> + * otherwise 0.
> =A0*/
> -static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct rps_dev_flow **rf=
lowp)
> +__u32 __skb_get_rxhash(struct sk_buff *skb)
> =A0{
> + =A0 =A0 =A0 int nhoff, hash =3D 0;
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
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto got_hash; /* Skip hash computation=
 on packet header */
> + =A0 =A0 =A0 nhoff =3D skb_network_offset(skb);
>
> =A0 =A0 =A0 =A0switch (skb->protocol) {
> =A0 =A0 =A0 =A0case __constant_htons(ETH_P_IP):
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, sizeof(*ip)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, sizeof(*ip) + n=
hoff))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ip =3D (struct iphdr *) skb->data;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ip =3D (struct iphdr *) skb->data + nho=
ff;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_proto =3D ip->protocol;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr1 =3D (__force u32) ip->saddr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr2 =3D (__force u32) ip->daddr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ihl =3D ip->ihl;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case __constant_htons(ETH_P_IPV6):
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, sizeof(*ip6)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, sizeof(*ip6) + =
nhoff))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ip6 =3D (struct ipv6hdr *) skb->data;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ip6 =3D (struct ipv6hdr *) skb->data + =
nhoff;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_proto =3D ip6->nexthdr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr1 =3D (__force u32) ip6->saddr.s6_=
addr32[3];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr2 =3D (__force u32) ip6->daddr.s6_=
addr32[3];
> @@ -2330,6 +2302,7 @@ static int get_rps_cpu(struct net_device
> =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> =A0 =A0 =A0 =A0}
> +
> =A0 =A0 =A0 =A0switch (ip_proto) {
> =A0 =A0 =A0 =A0case IPPROTO_TCP:
> =A0 =A0 =A0 =A0case IPPROTO_UDP:
> @@ -2338,8 +2311,9 @@ static int get_rps_cpu(struct net_device
> =A0 =A0 =A0 =A0case IPPROTO_AH:
> =A0 =A0 =A0 =A0case IPPROTO_SCTP:
> =A0 =A0 =A0 =A0case IPPROTO_UDPLITE:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pskb_may_pull(skb, (ihl * 4) + 4)) =
{
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ports.v32 =3D * (__forc=
e u32 *) (skb->data + (ihl * 4));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pskb_may_pull(skb, (ihl * 4) + 4 + =
nhoff)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ports.v32 =3D * (__forc=
e u32 *) (skb->data + nhoff +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ihl * 4));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ports.v16[1] < por=
ts.v16[0])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swap(p=
orts.v16[0], ports.v16[1]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -2352,11 +2326,56 @@ static int get_rps_cpu(struct net_device
> =A0 =A0 =A0 =A0/* get a consistent hash (same value on both flow dire=
ctions) */
> =A0 =A0 =A0 =A0if (addr2 < addr1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swap(addr1, addr2);
> - =A0 =A0 =A0 skb->rxhash =3D jhash_3words(addr1, addr2, ports.v32, h=
ashrnd);
> - =A0 =A0 =A0 if (!skb->rxhash)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->rxhash =3D 1;
>
> -got_hash:
> + =A0 =A0 =A0 hash =3D jhash_3words(addr1, addr2, ports.v32, hashrnd)=
;
> + =A0 =A0 =A0 if (!hash)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash =3D 1;
> +
> +done:
> + =A0 =A0 =A0 return hash;
> +}
> +EXPORT_SYMBOL(__skb_get_rxhash);
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
> + =A0 =A0 =A0 skb->rxhash =3D skb_get_rxhash(skb);

the return value of skb_get_rxhash() maybe skb->rxhash, so we don't
need to assign it to skb->rxhash again. Use a local variable to save
the value and __skb_get_rxhash() should cache the rxhash into
skb->rxhash for future use.

> + =A0 =A0 =A0 if (skb->rxhash < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> +
> =A0 =A0 =A0 =A0flow_table =3D rcu_dereference(rxqueue->rps_flow_table=
);
> =A0 =A0 =A0 =A0sock_flow_table =3D rcu_dereference(rps_sock_flow_tabl=
e);
> =A0 =A0 =A0 =A0if (flow_table && sock_flow_table) {
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
