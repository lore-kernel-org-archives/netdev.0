From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 20:35:50 +0200
Message-ID: <4ADE0306.6060101@gmail.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33344 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbZJTSfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 14:35:51 -0400
In-Reply-To: <4ADDF948.1050208@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear a =E9crit :

> I should have looked at the latest code, but even if mac-vlan is no l=
onger
> an issue, I suspect it may still be possible to get into this case wi=
th
> other virtual devices because pktgen plays tricks by cloning pkts.

Sure, you may be right.

>=20
> That said, I have no proof, so no further arguments from me.
>=20
> Thanks for pointing out the new mac-vlan patch.
>=20

fill_packet() does the mapping setting, so if a device/tunnel transmit =
change it,
we might have a problem for cloned pktgen packets.

Hmm... dev_pick_tx() logic might be the problem...

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




So if pktgen does a skb_set_queue_mapping(skb, 0);
dev_pick_tx() will call skb_tx_hash().
skb_tx_hash() will consider mapping is not set and will
generate a new one based on hash value.


David, we are changing skb->mapping while transmitting it...

So yes, it can break pktgen if its skbs are cloned.

Maybe pktgen should call skb_record_rx_queue() instead of skb_set_queue=
_mapping()

Or maybe we should avoid this +/- 1 thing we do in skb_record_rx_queue(=
), since
we use same skb field for recording rx_queue or tx_queue :(

