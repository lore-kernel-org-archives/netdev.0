From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/4 v2] net: Use sk_tx_queue_mapping for connected sockets
Date: Fri, 16 Oct 2009 11:48:56 +0200
Message-ID: <4AD84188.7030804@gmail.com>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain> <20091016072132.24384.38301.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45444 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758183AbZJPJtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 05:49:47 -0400
In-Reply-To: <20091016072132.24384.38301.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> For connected sockets, the first run of dev_pick_tx saves the
> calculated txq in sk_tx_queue_mapping. This is not saved if
> either skb rx was recorded, or if the device has a queue select
> handler. Next iterations of dev_pick_tx uses the cached value of
> sk_tx_queue_mapping.

Are we sure that for selection done by skb_tx_hash(dev, skb),
rx packets will use the same queue/cpu ?

Probably not, since it uses sk->sk_hash (tcp/udp port) :

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

If NIC has some proprietary hash, and selects rx queue 3 for feeding us
packets, it would be nice to also use tx queue 3 for transmit.

We would have to record in sk the rx queue chosen by the device
when processing SYN / SYN-ACK packet for example for tcp flows.


