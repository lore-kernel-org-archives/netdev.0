From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2] bonding: convert to ndo_fix_features
Date: Sat,  7 May 2011 15:22:17 +0200 (CEST)
Message-ID: <20110507132217.0CB5A13A69@rere.qmqm.pl>
References: <20110506175629.BC59D1389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37168 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab1EGNWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 09:22:18 -0400
In-Reply-To: <20110506175629.BC59D1389B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should also fix updating of vlan_features and propagating changes =
to
VLAN devices on the bond.

Side effect: it allows user to force-disable some offloads on the bond =
                                  =20
interface.                                                             =
                                  =20
                                                                       =
                                  =20
Note: NETIF_F_VLAN_CHALLENGED is managed by bond_fix_features() now.   =
                                  =20

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

Note: Depends on netdev_change_features() patch.

v2:	- use netdev_change_features()
	- fix locking around bond_compute_features()

 drivers/net/bonding/bond_main.c |  161 ++++++++++++++++---------------=
-------
 1 files changed, 68 insertions(+), 93 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 9a5feaf..36ff316 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -344,32 +344,6 @@ out:
 }
=20
 /**
- * bond_has_challenged_slaves
- * @bond: the bond we're working on
- *
- * Searches the slave list. Returns 1 if a vlan challenged slave
- * was found, 0 otherwise.
- *
- * Assumes bond->lock is held.
- */
-static int bond_has_challenged_slaves(struct bonding *bond)
-{
-	struct slave *slave;
-	int i;
-
-	bond_for_each_slave(bond, slave, i) {
-		if (slave->dev->features & NETIF_F_VLAN_CHALLENGED) {
-			pr_debug("found VLAN challenged slave - %s\n",
-				 slave->dev->name);
-			return 1;
-		}
-	}
-
-	pr_debug("no VLAN challenged slaves found\n");
-	return 0;
-}
-
-/**
  * bond_next_vlan - safely skip to the next item in the vlans list.
  * @bond: the bond we're working on
  * @curr: item we're advancing from
@@ -1406,52 +1380,68 @@ static int bond_sethwaddr(struct net_device *bo=
nd_dev,
 	return 0;
 }
=20
-#define BOND_VLAN_FEATURES \
-	(NETIF_F_VLAN_CHALLENGED | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX | =
\
-	 NETIF_F_HW_VLAN_FILTER)
-
-/*
- * Compute the common dev->feature set available to all slaves.  Some
- * feature bits are managed elsewhere, so preserve those feature bits
- * on the master device.
- */
-static int bond_compute_features(struct bonding *bond)
+static u32 bond_fix_features(struct net_device *dev, u32 features)
 {
 	struct slave *slave;
-	struct net_device *bond_dev =3D bond->dev;
-	u32 features =3D bond_dev->features;
-	u32 vlan_features =3D 0;
-	unsigned short max_hard_header_len =3D max((u16)ETH_HLEN,
-						bond_dev->hard_header_len);
+	struct bonding *bond =3D netdev_priv(dev);
+	u32 mask;
 	int i;
=20
-	features &=3D ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES);
-	features |=3D  NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_NOCACHE_C=
OPY;
+	read_lock(&bond->lock);
=20
-	if (!bond->first_slave)
-		goto done;
+	if (!bond->first_slave) {
+		/* Disable adding VLANs to empty bond. But why? --mq */
+		features |=3D NETIF_F_VLAN_CHALLENGED;
+		goto out;
+	}
=20
+	mask =3D features;
 	features &=3D ~NETIF_F_ONE_FOR_ALL;
+	features |=3D NETIF_F_ALL_FOR_ALL;
=20
-	vlan_features =3D bond->first_slave->dev->vlan_features;
 	bond_for_each_slave(bond, slave, i) {
 		features =3D netdev_increment_features(features,
 						     slave->dev->features,
-						     NETIF_F_ONE_FOR_ALL);
+						     mask);
+	}
+
+out:
+	read_unlock(&bond->lock);
+	return features;
+}
+
+#define BOND_VLAN_FEATURES	(NETIF_F_ALL_TX_OFFLOADS | \
+				 NETIF_F_SOFT_FEATURES | \
+				 NETIF_F_LRO)
+
+static void bond_compute_features(struct bonding *bond)
+{
+	struct slave *slave;
+	struct net_device *bond_dev =3D bond->dev;
+	u32 vlan_features =3D BOND_VLAN_FEATURES;
+	unsigned short max_hard_header_len =3D ETH_HLEN;
+	int i;
+
+	read_lock(&bond->lock);
+
+	if (!bond->first_slave)
+		goto done;
+
+	bond_for_each_slave(bond, slave, i) {
 		vlan_features =3D netdev_increment_features(vlan_features,
-							slave->dev->vlan_features,
-							NETIF_F_ONE_FOR_ALL);
+			slave->dev->vlan_features, BOND_VLAN_FEATURES);
+
 		if (slave->dev->hard_header_len > max_hard_header_len)
 			max_hard_header_len =3D slave->dev->hard_header_len;
 	}
=20
 done:
-	features |=3D (bond_dev->features & BOND_VLAN_FEATURES);
-	bond_dev->features =3D netdev_fix_features(bond_dev, features);
-	bond_dev->vlan_features =3D netdev_fix_features(bond_dev, vlan_featur=
es);
+	bond_dev->vlan_features =3D vlan_features;
 	bond_dev->hard_header_len =3D max_hard_header_len;
=20
-	return 0;
+	read_unlock(&bond->lock);
+
+	netdev_change_features(bond_dev);
 }
=20
 static void bond_setup_by_slave(struct net_device *bond_dev,
@@ -1544,7 +1534,6 @@ int bond_enslave(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	struct netdev_hw_addr *ha;
 	struct sockaddr addr;
 	int link_reporting;
-	int old_features =3D bond_dev->features;
 	int res =3D 0;
=20
 	if (!bond->params.use_carrier && slave_dev->ethtool_ops =3D=3D NULL &=
&
@@ -1577,16 +1566,9 @@ int bond_enslave(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
 			pr_warning("%s: Warning: enslaved VLAN challenged slave %s. Adding =
VLANs will be blocked as long as %s is part of bond %s\n",
 				   bond_dev->name, slave_dev->name,
 				   slave_dev->name, bond_dev->name);
-			bond_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
 		}
 	} else {
 		pr_debug("%s: ! NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
-		if (bond->slave_cnt =3D=3D 0) {
-			/* First slave, and it is not VLAN challenged,
-			 * so remove the block of adding VLANs over the bond.
-			 */
-			bond_dev->features &=3D ~NETIF_F_VLAN_CHALLENGED;
-		}
 	}
=20
 	/*
@@ -1775,10 +1757,10 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
 	new_slave->delay =3D 0;
 	new_slave->link_failure_count =3D 0;
=20
-	bond_compute_features(bond);
-
 	write_unlock_bh(&bond->lock);
=20
+	bond_compute_features(bond);
+
 	read_lock(&bond->lock);
=20
 	new_slave->last_arp_rx =3D jiffies;
@@ -1958,7 +1940,7 @@ err_free:
 	kfree(new_slave);
=20
 err_undo_flags:
-	bond_dev->features =3D old_features;
+	bond_compute_features(bond);
=20
 	return res;
 }
@@ -1979,6 +1961,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	struct bonding *bond =3D netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
+	u32 old_features =3D bond_dev->features;
=20
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
@@ -2039,8 +2022,6 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	/* release the slave from its bond */
 	bond_detach_slave(bond, slave);
=20
-	bond_compute_features(bond);
-
 	if (bond->primary_slave =3D=3D slave)
 		bond->primary_slave =3D NULL;
=20
@@ -2084,23 +2065,22 @@ int bond_release(struct net_device *bond_dev, s=
truct net_device *slave_dev)
 		 */
 		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
=20
-		if (!bond->vlgrp) {
-			bond_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
-		} else {
+		if (bond->vlgrp) {
 			pr_warning("%s: Warning: clearing HW address of %s while it still h=
as VLANs.\n",
 				   bond_dev->name, bond_dev->name);
 			pr_warning("%s: When re-adding slaves, make sure the bond's HW addr=
ess matches its VLANs'.\n",
 				   bond_dev->name);
 		}
-	} else if ((bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
-		   !bond_has_challenged_slaves(bond)) {
+	}
+
+	write_unlock_bh(&bond->lock);
+	unblock_netpoll_tx();
+
+	bond_compute_features(bond);
+	if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
+	    (old_features & NETIF_F_VLAN_CHALLENGED))
 		pr_info("%s: last VLAN challenged slave %s left bond %s. VLAN blocki=
ng is removed\n",
 			bond_dev->name, slave_dev->name, bond_dev->name);
-		bond_dev->features &=3D ~NETIF_F_VLAN_CHALLENGED;
-	}
-
-	write_unlock_bh(&bond->lock);
-	unblock_netpoll_tx();
=20
 	/* must do this from outside any spinlocks */
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
@@ -2219,8 +2199,6 @@ static int bond_release_all(struct net_device *bo=
nd_dev)
 			bond_alb_deinit_slave(bond, slave);
 		}
=20
-		bond_compute_features(bond);
-
 		bond_destroy_slave_symlinks(bond_dev, slave_dev);
 		bond_del_vlans_from_slave(bond, slave_dev);
=20
@@ -2269,9 +2247,7 @@ static int bond_release_all(struct net_device *bo=
nd_dev)
 	 */
 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
=20
-	if (!bond->vlgrp) {
-		bond_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
-	} else {
+	if (bond->vlgrp) {
 		pr_warning("%s: Warning: clearing HW address of %s while it still ha=
s VLANs.\n",
 			   bond_dev->name, bond_dev->name);
 		pr_warning("%s: When re-adding slaves, make sure the bond's HW addre=
ss matches its VLANs'.\n",
@@ -2282,6 +2258,9 @@ static int bond_release_all(struct net_device *bo=
nd_dev)
=20
 out:
 	write_unlock_bh(&bond->lock);
+
+	bond_compute_features(bond);
+
 	return 0;
 }
=20
@@ -4347,11 +4326,6 @@ static void bond_ethtool_get_drvinfo(struct net_=
device *bond_dev,
 static const struct ethtool_ops bond_ethtool_ops =3D {
 	.get_drvinfo		=3D bond_ethtool_get_drvinfo,
 	.get_link		=3D ethtool_op_get_link,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.get_tso		=3D ethtool_op_get_tso,
-	.get_ufo		=3D ethtool_op_get_ufo,
-	.get_flags		=3D ethtool_op_get_flags,
 };
=20
 static const struct net_device_ops bond_netdev_ops =3D {
@@ -4377,6 +4351,7 @@ static const struct net_device_ops bond_netdev_op=
s =3D {
 #endif
 	.ndo_add_slave		=3D bond_enslave,
 	.ndo_del_slave		=3D bond_release,
+	.ndo_fix_features	=3D bond_fix_features,
 };
=20
 static void bond_destructor(struct net_device *bond_dev)
@@ -4432,14 +4407,14 @@ static void bond_setup(struct net_device *bond_=
dev)
 	 * when there are slaves that are not hw accel
 	 * capable
 	 */
-	bond_dev->features |=3D (NETIF_F_HW_VLAN_TX |
-			       NETIF_F_HW_VLAN_RX |
-			       NETIF_F_HW_VLAN_FILTER);
=20
-	/* By default, we enable GRO on bonding devices.
-	 * Actual support requires lowlevel drivers are GRO ready.
-	 */
-	bond_dev->features |=3D NETIF_F_GRO;
+	bond_dev->hw_features =3D BOND_VLAN_FEATURES |
+				NETIF_F_HW_VLAN_TX |
+				NETIF_F_HW_VLAN_RX |
+				NETIF_F_HW_VLAN_FILTER;
+
+	bond_dev->hw_features &=3D ~(NETIF_F_ALL_CSUM & ~NETIF_F_NO_CSUM);
+	bond_dev->features |=3D bond_dev->hw_features;
 }
=20
 static void bond_work_cancel_all(struct bonding *bond)
--=20
1.7.2.5

