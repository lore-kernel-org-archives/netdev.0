From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bnx2: Update vlan_features
Date: Thu, 23 Jul 2009 10:29:23 +0200
Message-ID: <4A681F63.7060001@gmail.com>
References: <24949.1240530461@death.nxdomain.ibm.com>	<4A2CDB16.9030000@Voltaire.com> <4A642600.2010501@voltaire.com>	<3463.1248298460@death.nxdomain.ibm.com> <4A67FD4C.4080407@cosmosbay.com> <4A681029.4070600@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36961 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbZGWI3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 04:29:43 -0400
In-Reply-To: <4A681029.4070600@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz a =E9crit :
> Eric Dumazet wrote:
>> Jay Vosburgh a =E9crit :
>>> Propogate the vlan_features of the slave devices to the bonding
>>> master device, using the same logic as for regular features.
>> Seems pretty cool, but I could not test it on my dev machine, since
>> tg3 and bnx2 drivers dont advertize yet vlan_features
> The bnx2x maintainer posted yesterday a patch that does so, I assume =
a
> similar patch could work for at least one of tg3 or bnx2. I copied bo=
th
> maintainers on this email, in  the hope they can come up with a patch=
=2E
>=20

Here is the bnx2 patch I cooked to test this vlan_features propagation =
on bonding.

Everything fine so far !

# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth1    (bnx2 driver)
MII Status: up
Link Failure Count: 2
Permanent HW addr: 00:1e:0b:ec:d3:d2

Slave Interface: eth2    (tg3 driver)
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:1e:0b:92:78:50


# ethtool -k bond0
Offload parameters for bond0:
Cannot get device rx csum settings: Operation not supported
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off

# ip link add link bond0 vlan.103 type vlan id 103
# ethtool -k vlan.103
Offload parameters for vlan.103:
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: off
large-receive-offload: off


Thanks Or & Jay

[PATCH net-next-2.6] bnx2: Update vlan_features

In order to get full use of some advanced features of BNX2, we now need=
 to
fill dev->vlan_features.

Patch successfully tested with vlan devices built on top of bonding.
(bond0 : one bnx2 slave, one tg3 slave (not yet vlan_features enabled)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bnx2.c |   36 ++++++++++++++++++++++++++++++------
 1 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b70cc99..0868673 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3485,6 +3485,20 @@ static int bnx2_poll(struct napi_struct *napi, i=
nt budget)
 	return work_done;
 }
=20
+static void inline vlan_features_add(struct net_device *dev, unsigned =
long flags)
+{
+#ifdef BCM_VLAN
+	dev->vlan_features |=3D flags;
+#endif
+}
+
+static void inline vlan_features_del(struct net_device *dev, unsigned =
long flags)
+{
+#ifdef BCM_VLAN
+	dev->vlan_features &=3D ~flags;
+#endif
+}
+
 /* Called with rtnl_lock from vlan functions and also netif_tx_lock
  * from set_multicast.
  */
@@ -7068,11 +7082,17 @@ bnx2_set_tso(struct net_device *dev, u32 data)
=20
 	if (data) {
 		dev->features |=3D NETIF_F_TSO | NETIF_F_TSO_ECN;
-		if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
+		vlan_features_add(dev, NETIF_F_TSO | NETIF_F_TSO_ECN);
+		if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
 			dev->features |=3D NETIF_F_TSO6;
-	} else
+			vlan_features_add(dev, NETIF_F_TSO6);
+		}
+	} else {
 		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6 |
 				   NETIF_F_TSO_ECN);
+		vlan_features_del(dev, NETIF_F_TSO | NETIF_F_TSO6 |
+				  NETIF_F_TSO_ECN);
+	}
 	return 0;
 }
=20
@@ -8064,16 +8084,20 @@ bnx2_init_one(struct pci_dev *pdev, const struc=
t pci_device_id *ent)
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
=20
 	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG;
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
+	vlan_features_add(dev, NETIF_F_IP_CSUM | NETIF_F_SG);
+	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
 		dev->features |=3D NETIF_F_IPV6_CSUM;
-
+		vlan_features_add(dev, NETIF_F_IPV6_CSUM);
+	}
 #ifdef BCM_VLAN
 	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
 	dev->features |=3D NETIF_F_TSO | NETIF_F_TSO_ECN;
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
+	vlan_features_add(dev, NETIF_F_TSO | NETIF_F_TSO_ECN);
+	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
 		dev->features |=3D NETIF_F_TSO6;
-
+		vlan_features_add(dev, NETIF_F_TSO6);
+	}
 	if ((rc =3D register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
 		goto error;
