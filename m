From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 23:22:44 +0200
Message-ID: <4ADE2A24.6080300@gmail.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59117 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbZJTVWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 17:22:46 -0400
In-Reply-To: <4ADE2735.9000807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear a =E9crit :
> On 10/20/2009 11:54 AM, Eric Dumazet wrote:
>=20
>> -    queue_map =3D skb_get_queue_mapping(pkt_dev->skb);
>> +    queue_map =3D pkt_dev->cur_queue_map;
>> +    /*
>> +     * tells skb_tx_hash() to use this tx queue.
>> +     * We should reset skb->mapping before each xmit() because
>> +     * xmit() might change it.
>> +     */
>> +    skb_record_rx_queue(pkt_dev->skb, queue_map);
>>       txq =3D netdev_get_tx_queue(odev, queue_map);
>=20
> I think that must be wrong.  The record_rx_queue sets it to queue_map=
 + 1,
> but the hard-start-xmit method (in ixgbe/ixgbe_main.c, at least), tak=
es the
> skb->queue_map and uses it as an index with no subtraction.


Yes but check net/core/dev.c I quoted in my previous mail :
We change queue_map if skb goes through dev_queue_xmit()
(as done by macvlan)

u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb=
)
{
        u32 hash;

        if (skb_rx_queue_recorded(skb)) {
                hash =3D skb_get_rx_queue(skb);
                while (unlikely(hash >=3D dev->real_num_tx_queues))
                        hash -=3D dev->real_num_tx_queues;
                return hash;
        }

        if (skb->sk && skb->sk->sk_hash)
                hash =3D skb->sk->sk_hash;
        else
                hash =3D skb->protocol;

        hash =3D jhash_1word(hash, skb_tx_hashrnd);

        return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
}
EXPORT_SYMBOL(skb_tx_hash);

static struct netdev_queue *dev_pick_tx(struct net_device *dev,
                                        struct sk_buff *skb)
{
        const struct net_device_ops *ops =3D dev->netdev_ops;
        u16 queue_index =3D 0;

        if (ops->ndo_select_queue)
                queue_index =3D ops->ndo_select_queue(dev, skb);
        else if (dev->real_num_tx_queues > 1)
                queue_index =3D skb_tx_hash(dev, skb);

        skb_set_queue_mapping(skb, queue_index);
        return netdev_get_tx_queue(dev, queue_index);
}

So if skb->queue_mapping was X+1 before entering dev_pick_tx(), it is X=
 when
leaving dev_pick_tx()

>=20
> This causes watchdog timeouts because we are calling txq_trans_update=
 in
> pktgen on
> queue 0, for instance, but sending pkts on queue 1.  If queue 1 is ev=
er
> busy when the WD fires, link is reset.
>=20

Problem is not pktgen IMHO.=20

Problem is skb->queue_mapping has different meaning if skb is directly =
given to a real device -> start_xmit()

( In this case skb->queue_mapping should be between [O ... real_num_tx_=
queues-1])

But if it goes through dev_queue_xmit(), it should be set between [1 ..=
 real_num_tx_queues], because
dev_pick_tx() will decrement skb->queue_mapping

In fact skb->queue_mapping only works for forwarded packets, not locall=
y generated ones.

I am too tired to cook a fix at this moment, sorry :(
