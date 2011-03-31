From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH] bonding: convert bond_compute_features() to ndo_fix/set_features
Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
Message-ID: <20110331110135.2088713A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50957 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757294Ab1CaLBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 07:01:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: Updating of vlan_features is and was broken, as its not propagate=
d
to vlan devices already created ontop of the bond.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bonding/bond_main.c |   45 +++++++++++++++++++++++++------=
-------
 1 files changed, 29 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 16d6fe9..73d2661 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1396,29 +1396,42 @@ static int bond_sethwaddr(struct net_device *bo=
nd_dev,
  * feature bits are managed elsewhere, so preserve those feature bits
  * on the master device.
  */
-static int bond_compute_features(struct bonding *bond)
+static u32 bond_fix_features(struct net_device *bond_dev, u32 features=
)
 {
+	struct bonding *bond =3D netdev_priv(bond_dev);
 	struct slave *slave;
-	struct net_device *bond_dev =3D bond->dev;
-	u32 features =3D bond_dev->features;
-	u32 vlan_features =3D 0;
-	unsigned short max_hard_header_len =3D max((u16)ETH_HLEN,
-						bond_dev->hard_header_len);
 	int i;
=20
 	features &=3D ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES);
 	features |=3D  NETIF_F_GSO_MASK | NETIF_F_NO_CSUM;
=20
 	if (!bond->first_slave)
-		goto done;
+		return features;
=20
 	features &=3D ~NETIF_F_ONE_FOR_ALL;
=20
-	vlan_features =3D bond->first_slave->dev->vlan_features;
 	bond_for_each_slave(bond, slave, i) {
 		features =3D netdev_increment_features(features,
 						     slave->dev->features,
 						     NETIF_F_ONE_FOR_ALL);
+	}
+
+	return features;
+}
+
+static int bond_set_features(struct net_device *bond_dev, u32 features=
)
+{
+	struct bonding *bond =3D netdev_priv(bond_dev);
+	struct slave *slave;
+	unsigned short max_hard_header_len =3D ETH_HLEN;
+	u32 vlan_features =3D 0;
+	int i;
+
+	if (!bond->first_slave)
+		return 0;
+
+	vlan_features =3D bond->first_slave->dev->vlan_features;
+	bond_for_each_slave(bond, slave, i) {
 		vlan_features =3D netdev_increment_features(vlan_features,
 							slave->dev->vlan_features,
 							NETIF_F_ONE_FOR_ALL);
@@ -1426,10 +1439,8 @@ static int bond_compute_features(struct bonding =
*bond)
 			max_hard_header_len =3D slave->dev->hard_header_len;
 	}
=20
-done:
-	features |=3D (bond_dev->features & BOND_VLAN_FEATURES);
-	bond_dev->features =3D netdev_fix_features(bond_dev, features);
-	bond_dev->vlan_features =3D netdev_fix_features(bond_dev, vlan_featur=
es);
+	/* vlan_features will be trimmed by vlan devices */
+	bond_dev->vlan_features =3D vlan_features;
 	bond_dev->hard_header_len =3D max_hard_header_len;
=20
 	return 0;
@@ -1757,7 +1768,7 @@ int bond_enslave(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	new_slave->delay =3D 0;
 	new_slave->link_failure_count =3D 0;
=20
-	bond_compute_features(bond);
+	netdev_update_features(bond_dev);
=20
 	write_unlock_bh(&bond->lock);
=20
@@ -2021,7 +2032,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	/* release the slave from its bond */
 	bond_detach_slave(bond, slave);
=20
-	bond_compute_features(bond);
+	netdev_update_features(bond_dev);
=20
 	if (bond->primary_slave =3D=3D slave)
 		bond->primary_slave =3D NULL;
@@ -2201,7 +2212,7 @@ static int bond_release_all(struct net_device *bo=
nd_dev)
 			bond_alb_deinit_slave(bond, slave);
 		}
=20
-		bond_compute_features(bond);
+		netdev_update_features(bond_dev);
=20
 		bond_destroy_slave_symlinks(bond_dev, slave_dev);
 		bond_del_vlans_from_slave(bond, slave_dev);
@@ -3380,7 +3391,7 @@ static int bond_slave_netdev_event(unsigned long =
event,
 		 */
 		break;
 	case NETDEV_FEAT_CHANGE:
-		bond_compute_features(bond);
+		netdev_update_features(bond_dev);
 		break;
 	default:
 		break;
@@ -4478,6 +4489,8 @@ static const struct net_device_ops bond_netdev_op=
s =3D {
 #endif
 	.ndo_add_slave		=3D bond_enslave,
 	.ndo_del_slave		=3D bond_release,
+	.ndo_fix_features	=3D bond_fix_features,
+	.ndo_set_features	=3D bond_set_features,
 };
=20
 static void bond_destructor(struct net_device *bond_dev)
--=20
1.7.2.5

