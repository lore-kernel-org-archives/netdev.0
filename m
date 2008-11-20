From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 02/33] netdev: introduce dev_get_stats()
Date: Thu, 20 Nov 2008 10:17:02 +0100
Message-ID: <49252B0E.10602@cosmosbay.com>
References: <20081117234207.854110282@vyatta.com>	<20081117234354.948324675@vyatta.com> <20081119.214057.200155427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48275 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbYKTJRH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:17:07 -0500
In-Reply-To: <20081119.214057.200155427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 17 Nov 2008 15:42:09 -0800
>=20
>> In order for the network device ops get_stats call to be immutable, =
the handling
>> of the default internal network device stats block has to be changed=
=2E Add a new
>> helper function which replaces the old use of internal_get_stats.
>>
>> Note: change return code to make it clear that the caller should not
>> go changing the returned statistics.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Applied.

I have one comment about netdev stats

on 32bit arches, SMP :

struct net_device =3D 0x480
offsetof(struct net_device, features)=3D0x44
offsetof(struct net_device, stats)=3D0x50
offsetof(struct net_device, stats.rx_packets)=3D0x50

So we trash features field, thats a problem...

I wonder if we could zap stats from netdev structure.
Some drivers already use external stats handling (like loopback)

get_dev_stats() would accept a second parameter : a pointer to a struct=
 net_device_stats
provided by the reader, that the driver could use as a working zone, or=
 not.

static struct net_device_stats *bond_get_stats(struct net_device *bond_=
dev,
	struct net_device_stats *temp)
{
        struct bonding *bond =3D netdev_priv(bond_dev);
        struct net_device_stats wrk;
        struct slave *slave;
        int i;

	/* use the caller provided zone */
        memset(temp, 0, sizeof(struct net_device_stats));

        read_lock_bh(&bond->lock);

        bond_for_each_slave(bond, slave, i) {
                const struct net_device_stats *sstats =3D dev_get_stats=
(slave->dev, &wrk);

                temp->rx_packets +=3D sstats->rx_packets;
                temp->rx_bytes +=3D sstats->rx_bytes;
                temp->rx_errors +=3D sstats->rx_errors;
		...
	}


        read_unlock_bh(&bond->lock);

        return temp;
}

=2E...

static struct net_device_stats *loopback_get_stats(struct net_device *d=
ev,
			struct net_device_stats *temp)
{
        const struct pcpu_lstats *pcpu_lstats;
        unsigned long bytes =3D 0;
        unsigned long packets =3D 0;
        int i;

	memset(temp, 0, sizeof(*temp);
        pcpu_lstats =3D dev->ml_priv;
        for_each_possible_cpu(i) {
                const struct pcpu_lstats *lb_stats;

                lb_stats =3D per_cpu_ptr(pcpu_lstats, i);
                bytes   +=3D lb_stats->bytes;
                packets +=3D lb_stats->packets;
        }
        temp->rx_packets =3D packets;
        temp->tx_packets =3D packets;
        temp->rx_bytes =3D bytes;
        temp->tx_bytes =3D bytes;
        return temp;
}

=2E..

