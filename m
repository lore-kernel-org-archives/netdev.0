From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Thu, 12 Nov 2009 11:12:17 +0800
Message-ID: <412e6f7f0911111912q27f2b0aate56c637349292c3f@mail.gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFADF64.8070601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:60657 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760042AbZKLDMM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:12:12 -0500
Received: by pzk1 with SMTP id 1so222100pzk.33
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 19:12:17 -0800 (PST)
In-Reply-To: <4AFADF64.8070601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2009 at 11:59 PM, Patrick McHardy <kaber@trash.net> wro=
te:
> Changli Gao wrote:
>> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
>> index 69c2566..ac04e85 100644
>> --- a/drivers/net/ifb.c
>> +++ b/drivers/net/ifb.c
>> ...
>> +/* Number of ifb devices to be set up by this module. */
>> =C2=A0static int numifbs =3D 2;
>> +module_param(numifbs, int, 0444);
>> +MODULE_PARM_DESC(numifbs, "Number of ifb devices");
>>
>> -static void ri_tasklet(unsigned long dev);
>> -static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device =
*dev);
>> -static int ifb_open(struct net_device *dev);
>> -static int ifb_close(struct net_device *dev);
>> +/* Number of TX queues per ifb */
>> +static int numtxqs =3D 1;
>> +module_param(numtxqs, int, 0444);
>> +MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");
>
> unsigned?

Yea, unsigned is better, and I need to check whether its value is
smaller than 1 somewhere. The same will be done with IFLA_NTXQ.

>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while ((skb =3D skb_dequ=
eue(&pq->tq)) !=3D NULL) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 u32 from =3D G_TC_FROM(skb->tc_verd);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 skb->tc_verd =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 skb->tc_verd =3D SET_TC_NCLS(skb->tc_verd);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 txq->tx_packets++;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 txq->tx_bytes +=3Dskb->len;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 rcu_read_lock();
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 skb->dev =3D dev_get_by_index_rcu(&init_net, skb->iif);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (!skb->dev) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_kfree_skb(skb);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 txq->tx_dropped++;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 rcu_read_unlock();
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 skb->iif =3D dev->ifindex;
>
> What protects the device from disappearing here and below during
> dev_queue_xmit() and netif_rx_ni()?

=46or dev_queue_xmit(), dev is holded by skb->_dst, so there is no
problem. But for netif_rx_ni(), I don't know how to prevent the device
disappearing, and it seems that all the NIC drivers have this problem.
Maybe there was the assumption about the execution context of
netif_rx() before. Now softirq can't be executed by softirqd, so the
packet receiving path maybe interleaved. I don't know how to prevent
it happening.


>> +
>> +static u16 ifb_select_queue(struct net_device *dev, struct sk_buff =
*skb)
>> +{
>> + =C2=A0 =C2=A0 u32 addr1, addr2;
>> + =C2=A0 =C2=A0 u32 hash, ihl;
>> + =C2=A0 =C2=A0 union {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u16 in16[2];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 in32;
>> + =C2=A0 =C2=A0 } ports;
>> + =C2=A0 =C2=A0 u8 ip_proto;
>> +
>> + =C2=A0 =C2=A0 if ((hash =3D skb_rx_queue_recorded(skb))) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (hash >=3D dev->re=
al_num_tx_queues)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 hash -=3D dev->real_num_tx_queues;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return hash;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 switch (skb->protocol) {
>> + =C2=A0 =C2=A0 case __constant_htons(ETH_P_IP):
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(ip_hdr(skb)->frag_=
off & htons(IP_MF | IP_OFFSET)))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ip_proto =3D ip_hdr(skb)->protocol;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ip_proto =3D 0;
>
> So fragments will get reordered?

Yea. It is OK, as the number of fragments isn't large. If we decide to
avoid this, we have to reasm them as netfilter does. and it isn't
efficiency.

>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr1 =3D ip_hdr(skb)->s=
addr;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr2 =3D ip_hdr(skb)->d=
addr;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ihl =3D ip_hdr(skb)->ihl=
 << 2;
>
> ip_hdrlen()?

Yea, I'll use ip_hdrlen() instead.

>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 case __constant_htons(ETH_P_IPV6):
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ip_proto =3D ipv6_hdr(sk=
b)->nexthdr;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr1 =3D ipv6_hdr(skb)-=
>saddr.s6_addr32[3];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr2 =3D ipv6_hdr(skb)-=
>daddr.s6_addr32[3];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ihl =3D 10;
>
> Where does 10 come from?

It should be 40, after reviewing IPV6, I found that I need to loop
until finding the right protocol value.

>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 default:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>
> Perhaps hash on skb->protocol here.

use return skb->protocol % dev->real_num_tx_queues; instead.

>
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 if (addr1 > addr2)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 swap(addr1, addr2);
>> +
>> + =C2=A0 =C2=A0 switch (ip_proto) {
>> + =C2=A0 =C2=A0 case IPPROTO_TCP:
>> + =C2=A0 =C2=A0 case IPPROTO_UDP:
>> + =C2=A0 =C2=A0 case IPPROTO_DCCP:
>> + =C2=A0 =C2=A0 case IPPROTO_ESP:
>> + =C2=A0 =C2=A0 case IPPROTO_AH:
>> + =C2=A0 =C2=A0 case IPPROTO_SCTP:
>> + =C2=A0 =C2=A0 case IPPROTO_UDPLITE:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ports.in32 =3D *((u32 *)=
 (skb_network_header(skb) + ihl));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ports.in16[0] > port=
s.in16[1])
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 swap(ports.in16[0], ports.in16[1]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> +
>> + =C2=A0 =C2=A0 default:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ports.in32 =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 hash =3D jhash_3words(addr1, addr2, ports.in32,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 simple_tx_hashrnd ^ ip_proto);
>> +
>> + =C2=A0 =C2=A0 return (u16) (((u64) hash * dev->real_num_tx_queues)=
 >> 32);
>> +}
>> +
>> +static int ifb_init(struct net_device *dev)
>> +{
>> + =C2=A0 =C2=A0 struct ifb_private *dp =3D netdev_priv(dev);
>> + =C2=A0 =C2=A0 struct ifb_private_q *pq =3D dp->pq;
>> + =C2=A0 =C2=A0 int i;
>> +
>> + =C2=A0 =C2=A0 pq =3D kmalloc(sizeof(*pq) * dev->real_num_tx_queues=
, GFP_KERNEL);
>
> kcalloc()?

OK.

>> + =C2=A0 =C2=A0 if (pq =3D=3D NULL)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
>> + =C2=A0 =C2=A0 dp->pq =3D pq;
>> +
>> + =C2=A0 =C2=A0 for (i =3D 0; i < dev->real_num_tx_queues; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pq[i].dev =3D dev;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_queue_head_init(&pq[=
i].rq);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_queue_head_init(&pq[=
i].tq);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 init_waitqueue_head(&pq[=
i].wq);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pq[i].rx_packets =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pq[i].rx_bytes =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pq[i].rx_dropped =3D 0;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 return 0;
>> +}
>
>> +static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned int *num_tx_queues,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned int *real_num_tx_queues)
>> +{
>> + =C2=A0 =C2=A0 if (tb[IFLA_NTXQ]) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *num_tx_queues =3D nla_g=
et_u16(tb[IFLA_NTXQ]);
>
> We currently use unsigned ints for the queue number, so please
> use an u32 for the attribute as well.
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *real_num_tx_queues =3D =
*num_tx_queues;
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *num_tx_queues =3D numtx=
qs;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *real_num_tx_queues =3D =
numtxqs;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>
        u16                     (*ndo_select_queue)(struct net_device *=
dev,
                                                    struct sk_buff *skb=
);
use u16 as the return value so ..., and I think u16 is big enough. If
you insist on this, I'll use u32 instead.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
