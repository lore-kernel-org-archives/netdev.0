From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: convert to ndo_fix_features
Date: Fri, 06 May 2011 11:18:04 -0700
Message-ID: <5525.1304705884@death>
References: <20110506175629.BC59D1389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:56985 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131Ab1EFSSK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 14:18:10 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p46HtMA1032383
	for <netdev@vger.kernel.org>; Fri, 6 May 2011 13:55:22 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p46II8MA091116
	for <netdev@vger.kernel.org>; Fri, 6 May 2011 14:18:08 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p46EHuDW025119
	for <netdev@vger.kernel.org>; Fri, 6 May 2011 11:17:57 -0300
In-reply-to: <20110506175629.BC59D1389B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

>This should also fix updating of vlan_features and propagating changes=
 to
>VLAN devices on the bond.
>
>Side effect: it allows user to force-disable some offloads on the bond
>interface.
>
>Note: NETIF_F_VLAN_CHALLENGED is managed by bond_fix_features() now.
>
>BTW, What are the problems in creating VLAN devices on an empty bond
>(as stated in one of bond_setup() comments)?

	If there are no slaves, then the bond does not have a MAC
address assigned (because it gets its initial MAC from the first slave)=
=2E
It's therefore impossible to pass a MAC address up to the VLAN
interface.

	So the limitation is that the bond must have at least one slave
before a VLAN may be configured above it.

	-J


>Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>---
>
>Note: This is only compile tested, yet.
>
> drivers/net/bonding/bond_main.c |  133 +++++++++++++++---------------=
---------
> 1 files changed, 50 insertions(+), 83 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bon=
d_main.c
>index 9a5feaf..04a2205 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -344,32 +344,6 @@ out:
> }
>
> /**
>- * bond_has_challenged_slaves
>- * @bond: the bond we're working on
>- *
>- * Searches the slave list. Returns 1 if a vlan challenged slave
>- * was found, 0 otherwise.
>- *
>- * Assumes bond->lock is held.
>- */
>-static int bond_has_challenged_slaves(struct bonding *bond)
>-{
>-	struct slave *slave;
>-	int i;
>-
>-	bond_for_each_slave(bond, slave, i) {
>-		if (slave->dev->features & NETIF_F_VLAN_CHALLENGED) {
>-			pr_debug("found VLAN challenged slave - %s\n",
>-				 slave->dev->name);
>-			return 1;
>-		}
>-	}
>-
>-	pr_debug("no VLAN challenged slaves found\n");
>-	return 0;
>-}
>-
>-/**
>  * bond_next_vlan - safely skip to the next item in the vlans list.
>  * @bond: the bond we're working on
>  * @curr: item we're advancing from
>@@ -1406,52 +1380,61 @@ static int bond_sethwaddr(struct net_device *b=
ond_dev,
> 	return 0;
> }
>
>-#define BOND_VLAN_FEATURES \
>-	(NETIF_F_VLAN_CHALLENGED | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |=
 \
>-	 NETIF_F_HW_VLAN_FILTER)
>-
>-/*
>- * Compute the common dev->feature set available to all slaves.  Some
>- * feature bits are managed elsewhere, so preserve those feature bits
>- * on the master device.
>- */
>-static int bond_compute_features(struct bonding *bond)
>+static u32 bond_fix_features(struct net_device *dev, u32 features)
> {
> 	struct slave *slave;
>-	struct net_device *bond_dev =3D bond->dev;
>-	u32 features =3D bond_dev->features;
>-	u32 vlan_features =3D 0;
>-	unsigned short max_hard_header_len =3D max((u16)ETH_HLEN,
>-						bond_dev->hard_header_len);
>+	struct bonding *bond =3D netdev_priv(dev);
>+	u32 mask;
> 	int i;
>
>-	features &=3D ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES);
>-	features |=3D  NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_NOCACHE_=
COPY;
>-
> 	if (!bond->first_slave)
>-		goto done;
>+		/* Disable adding VLANs to empty bond. But why? --mq */
>+		return features | NETIF_F_VLAN_CHALLENGED;
>
>+	mask =3D features;
> 	features &=3D ~NETIF_F_ONE_FOR_ALL;
>+	features |=3D NETIF_F_ALL_FOR_ALL;
>
>-	vlan_features =3D bond->first_slave->dev->vlan_features;
> 	bond_for_each_slave(bond, slave, i) {
> 		features =3D netdev_increment_features(features,
> 						     slave->dev->features,
>-						     NETIF_F_ONE_FOR_ALL);
>+						     mask);
>+	}
>+
>+	return features;
>+}
>+
>+#define BOND_VLAN_FEATURES	(NETIF_F_ALL_TX_OFFLOADS | \
>+				 NETIF_F_SOFT_FEATURES | \
>+				 NETIF_F_LRO)
>+
>+static void bond_compute_features(struct bonding *bond)
>+{
>+	struct slave *slave;
>+	struct net_device *bond_dev =3D bond->dev;
>+	u32 old_features, vlan_features =3D BOND_VLAN_FEATURES;
>+	unsigned short max_hard_header_len =3D ETH_HLEN;
>+	int i;
>+
>+	if (!bond->first_slave)
>+		goto done;
>+
>+	bond_for_each_slave(bond, slave, i) {
> 		vlan_features =3D netdev_increment_features(vlan_features,
>-							slave->dev->vlan_features,
>-							NETIF_F_ONE_FOR_ALL);
>+			slave->dev->vlan_features, BOND_VLAN_FEATURES);
>+
> 		if (slave->dev->hard_header_len > max_hard_header_len)
> 			max_hard_header_len =3D slave->dev->hard_header_len;
> 	}
>
> done:
>-	features |=3D (bond_dev->features & BOND_VLAN_FEATURES);
>-	bond_dev->features =3D netdev_fix_features(bond_dev, features);
>-	bond_dev->vlan_features =3D netdev_fix_features(bond_dev, vlan_featu=
res);
>+	bond_dev->vlan_features =3D vlan_features;
> 	bond_dev->hard_header_len =3D max_hard_header_len;
>
>-	return 0;
>+	old_features =3D bond_dev->features;
>+	netdev_update_features(bond_dev);
>+	if (old_features =3D=3D bond_dev->features)
>+		netdev_features_change(bond_dev);
> }
>
> static void bond_setup_by_slave(struct net_device *bond_dev,
>@@ -1544,7 +1527,6 @@ int bond_enslave(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
> 	struct netdev_hw_addr *ha;
> 	struct sockaddr addr;
> 	int link_reporting;
>-	int old_features =3D bond_dev->features;
> 	int res =3D 0;
>
> 	if (!bond->params.use_carrier && slave_dev->ethtool_ops =3D=3D NULL =
&&
>@@ -1577,16 +1559,9 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
> 			pr_warning("%s: Warning: enslaved VLAN challenged slave %s. Adding=
 VLANs will be blocked as long as %s is part of bond %s\n",
> 				   bond_dev->name, slave_dev->name,
> 				   slave_dev->name, bond_dev->name);
>-			bond_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
> 		}
> 	} else {
> 		pr_debug("%s: ! NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
>-		if (bond->slave_cnt =3D=3D 0) {
>-			/* First slave, and it is not VLAN challenged,
>-			 * so remove the block of adding VLANs over the bond.
>-			 */
>-			bond_dev->features &=3D ~NETIF_F_VLAN_CHALLENGED;
>-		}
> 	}
>
> 	/*
>@@ -1958,7 +1933,7 @@ err_free:
> 	kfree(new_slave);
>
> err_undo_flags:
>-	bond_dev->features =3D old_features;
>+	bond_compute_features(bond);
>
> 	return res;
> }
>@@ -1979,6 +1954,7 @@ int bond_release(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
> 	struct bonding *bond =3D netdev_priv(bond_dev);
> 	struct slave *slave, *oldcurrent;
> 	struct sockaddr addr;
>+	u32 old_features =3D bond_dev->features;
>
> 	/* slave is not a slave or master is not master of this slave */
> 	if (!(slave_dev->flags & IFF_SLAVE) ||
>@@ -2084,19 +2060,16 @@ int bond_release(struct net_device *bond_dev, =
struct net_device *slave_dev)
> 		 */
> 		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>
>-		if (!bond->vlgrp) {
>-			bond_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
>-		} else {
>+		if (bond->vlgrp) {
> 			pr_warning("%s: Warning: clearing HW address of %s while it still =
has VLANs.\n",
> 				   bond_dev->name, bond_dev->name);
> 			pr_warning("%s: When re-adding slaves, make sure the bond's HW add=
ress matches its VLANs'.\n",
> 				   bond_dev->name);
> 		}
>-	} else if ((bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
>-		   !bond_has_challenged_slaves(bond)) {
>+	} else if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
>+		   old_features & NETIF_F_VLAN_CHALLENGED) {
> 		pr_info("%s: last VLAN challenged slave %s left bond %s. VLAN block=
ing is removed\n",
> 			bond_dev->name, slave_dev->name, bond_dev->name);
>-		bond_dev->features &=3D ~NETIF_F_VLAN_CHALLENGED;
> 	}
>
> 	write_unlock_bh(&bond->lock);
>@@ -2269,9 +2242,7 @@ static int bond_release_all(struct net_device *b=
ond_dev)
> 	 */
> 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>
>-	if (!bond->vlgrp) {
>-		bond_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
>-	} else {
>+	if (bond->vlgrp) {
> 		pr_warning("%s: Warning: clearing HW address of %s while it still h=
as VLANs.\n",
> 			   bond_dev->name, bond_dev->name);
> 		pr_warning("%s: When re-adding slaves, make sure the bond's HW addr=
ess matches its VLANs'.\n",
>@@ -4347,11 +4318,6 @@ static void bond_ethtool_get_drvinfo(struct net=
_device *bond_dev,
> static const struct ethtool_ops bond_ethtool_ops =3D {
> 	.get_drvinfo		=3D bond_ethtool_get_drvinfo,
> 	.get_link		=3D ethtool_op_get_link,
>-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
>-	.get_sg			=3D ethtool_op_get_sg,
>-	.get_tso		=3D ethtool_op_get_tso,
>-	.get_ufo		=3D ethtool_op_get_ufo,
>-	.get_flags		=3D ethtool_op_get_flags,
> };
>
> static const struct net_device_ops bond_netdev_ops =3D {
>@@ -4377,6 +4343,7 @@ static const struct net_device_ops bond_netdev_o=
ps =3D {
> #endif
> 	.ndo_add_slave		=3D bond_enslave,
> 	.ndo_del_slave		=3D bond_release,
>+	.ndo_fix_features	=3D bond_fix_features,
> };
>
> static void bond_destructor(struct net_device *bond_dev)
>@@ -4432,14 +4399,14 @@ static void bond_setup(struct net_device *bond=
_dev)
> 	 * when there are slaves that are not hw accel
> 	 * capable
> 	 */
>-	bond_dev->features |=3D (NETIF_F_HW_VLAN_TX |
>-			       NETIF_F_HW_VLAN_RX |
>-			       NETIF_F_HW_VLAN_FILTER);
>
>-	/* By default, we enable GRO on bonding devices.
>-	 * Actual support requires lowlevel drivers are GRO ready.
>-	 */
>-	bond_dev->features |=3D NETIF_F_GRO;
>+	bond_dev->hw_features =3D BOND_VLAN_FEATURES |
>+				NETIF_F_HW_VLAN_TX |
>+				NETIF_F_HW_VLAN_RX |
>+				NETIF_F_HW_VLAN_FILTER;
>+
>+	bond_dev->hw_features &=3D ~(NETIF_F_ALL_CSUM & ~NETIF_F_NO_CSUM);
>+	bond_dev->features |=3D bond_dev->hw_features;
> }
>
> static void bond_work_cancel_all(struct bonding *bond)
>--=20
>1.7.2.5
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
