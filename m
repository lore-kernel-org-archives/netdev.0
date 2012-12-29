From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sat, 29 Dec 2012 05:53:23 -0800
Message-ID: <1356789203.21409.3923.camel@edumazet-glaptop>
References: <20121229092417.GA4038@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vvs@parallels.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:53702 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325Ab2L2Nx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 08:53:27 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so5138756dad.38
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 05:53:26 -0800 (PST)
In-Reply-To: <20121229092417.GA4038@paralelels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-29 at 13:24 +0400, Andrew Vagin wrote:
> We found a few nodes, where network works slow in containers.
>=20
> For testing speed of TCP connections we use wget, which downloads iso
> images from the internet.
>=20
> wget in the new netns reports only 1.5 MB/s, but wget in the root net=
ns
> reports 33MB/s.
>=20
> A few facts:
>  * Experiments shows that window size for CT traffic does not increas=
es
>    up to ~900, however for host traffic window size increases up to ~=
14000
>  * packets are shuffled in the netns sometimes.
>  * tso/gro/gso changes on interfaces does not help
>  * issue was _NOT_ reproduced if kernel booted with maxcpus=3D1 or bn=
x2.disable_msi=3D1
>=20
> I reduced steps to reproduce:
> * Create a new network namespace "test" and a veth pair.
>   # ip netns add test
>   # ip link add name veth0 type veth peer name veth1
>=20
> * Move veth1 into the netns test
>   # ip link set veth1 netns test
>=20
> * Set ip address on veth1 and proper routing rules are added for this=
 ip
>   in the root netns.
>   # ip link set up dev veth0;  ip link set up dev veth0
>   # ip netns exec test ip a add REMOTE dev veth1
>   # ip netns exec test ip r a default via veth1
>   # ip r a REMOTE/32 via dev veth0
>=20
> Tcpdump for both cases are attached to this message.
> tcpdump.host - wget in the root netns
> tcpdump.netns.host - tcpdump for the host device, wget in the new net=
ns
> tcpdump.netns.veth - tcpdump for the veth1 device, wget in the new ne=
tns
>=20
> 3.8-rc1 is used for experiments.
>=20
> Do you have any ideas where is a problem?

veth has absolutely no offload features

It needs some care...

At the very miminum, let TCP coalesce do its job by allowing SG

CC Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> for insights.

Please try following patch :

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 95814d9..9fefeb3 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -259,6 +259,10 @@ static const struct net_device_ops veth_netdev_ops=
 =3D {
 	.ndo_set_mac_address =3D eth_mac_addr,
 };
=20
+#define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO |	\
+		       NETIF_F_HW_CSUM | NETIF_F_HIGHDMA |		\
+		       NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX)
+
 static void veth_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -269,9 +273,10 @@ static void veth_setup(struct net_device *dev)
 	dev->netdev_ops =3D &veth_netdev_ops;
 	dev->ethtool_ops =3D &veth_ethtool_ops;
 	dev->features |=3D NETIF_F_LLTX;
+	dev->features |=3D VETH_FEATURES;
 	dev->destructor =3D veth_dev_free;
=20
-	dev->hw_features =3D NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
+	dev->hw_features =3D VETH_FEATURES;
 }
=20
 /*
