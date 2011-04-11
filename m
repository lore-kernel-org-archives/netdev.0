From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v3] net: bnx2x: convert to hw_features
Date: Mon, 11 Apr 2011 21:54:45 +0200 (CEST)
Message-ID: <20110411195445.4EF0F13909@rere.qmqm.pl>
References: <1302531021.21065.79.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39535 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755582Ab1DKTyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 15:54:47 -0400
In-Reply-To: <1302531021.21065.79.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since ndo_fix_features callback is postponing features change when
bp->recovery_state !=3D BNX2X_RECOVERY_DONE, netdev_update_features()
has to be called again when this condition changes. Previously,
ethtool_ops->set_flags callback returned -EBUSY in that case
(it's not possible in the new model).

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
v3: - include NETIF_F_LRO in hw_features
    - don't call netdev_update_features() if bnx2x_nic_load() failed
v2: - comment in ndo_fix_features callback

 drivers/net/bnx2x/bnx2x_cmn.c     |   52 ++++++++++++++++++--
 drivers/net/bnx2x/bnx2x_cmn.h     |    3 +
 drivers/net/bnx2x/bnx2x_ethtool.c |   95 -----------------------------=
--------
 drivers/net/bnx2x/bnx2x_main.c    |   35 ++++++++------
 4 files changed, 70 insertions(+), 115 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cm=
n.c
index e83ac6d..9691b67 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2443,11 +2443,21 @@ alloc_err:
=20
 }
=20
+static int bnx2x_reload_if_running(struct net_device *dev)
+{
+	struct bnx2x *bp =3D netdev_priv(dev);
+
+	if (unlikely(!netif_running(dev)))
+		return 0;
+
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+	return bnx2x_nic_load(bp, LOAD_NORMAL);
+}
+
 /* called with rtnl_lock */
 int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
-	int rc =3D 0;
=20
 	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
 		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
@@ -2464,12 +2474,44 @@ int bnx2x_change_mtu(struct net_device *dev, in=
t new_mtu)
 	 */
 	dev->mtu =3D new_mtu;
=20
-	if (netif_running(dev)) {
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
-		rc =3D bnx2x_nic_load(bp, LOAD_NORMAL);
+	return bnx2x_reload_if_running(dev);
+}
+
+u32 bnx2x_fix_features(struct net_device *dev, u32 features)
+{
+	struct bnx2x *bp =3D netdev_priv(dev);
+
+	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
+		netdev_err(dev, "Handling parity error recovery. Try again later\n")=
;
+
+		/* Don't allow bnx2x_set_features() to be called now. */
+		return dev->features;
+	}
+
+	/* TPA requires Rx CSUM offloading */
+	if (!(features & NETIF_F_RXCSUM) || bp->disable_tpa)
+		features &=3D ~NETIF_F_LRO;
+
+	return features;
+}
+
+int bnx2x_set_features(struct net_device *dev, u32 features)
+{
+	struct bnx2x *bp =3D netdev_priv(dev);
+	u32 flags =3D bp->flags;
+
+	if (features & NETIF_F_LRO)
+		flags |=3D TPA_ENABLE_FLAG;
+	else
+		flags &=3D ~TPA_ENABLE_FLAG;
+
+	if (flags ^ bp->flags) {
+		bp->flags =3D flags;
+
+		return bnx2x_reload_if_running(dev);
 	}
=20
-	return rc;
+	return 0;
 }
=20
 void bnx2x_tx_timeout(struct net_device *dev)
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cm=
n.h
index 775fef0..1cdab69 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -431,6 +431,9 @@ void bnx2x_free_mem_bp(struct bnx2x *bp);
  */
 int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
=20
+u32 bnx2x_fix_features(struct net_device *dev, u32 features);
+int bnx2x_set_features(struct net_device *dev, u32 features);
+
 /**
  * tx timeout netdev callback
  *
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2=
x_ethtool.c
index 1479994..ad7d91e 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1299,91 +1299,6 @@ static int bnx2x_set_pauseparam(struct net_devic=
e *dev,
 	return 0;
 }
=20
-static int bnx2x_set_flags(struct net_device *dev, u32 data)
-{
-	struct bnx2x *bp =3D netdev_priv(dev);
-	int changed =3D 0;
-	int rc =3D 0;
-
-	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
-		return -EAGAIN;
-	}
-
-	if (!(data & ETH_FLAG_RXVLAN))
-		return -EINVAL;
-
-	if ((data & ETH_FLAG_LRO) && bp->rx_csum && bp->disable_tpa)
-		return -EINVAL;
-
-	rc =3D ethtool_op_set_flags(dev, data, ETH_FLAG_LRO | ETH_FLAG_RXVLAN=
 |
-					ETH_FLAG_TXVLAN | ETH_FLAG_RXHASH);
-	if (rc)
-		return rc;
-
-	/* TPA requires Rx CSUM offloading */
-	if ((data & ETH_FLAG_LRO) && bp->rx_csum) {
-		if (!(bp->flags & TPA_ENABLE_FLAG)) {
-			bp->flags |=3D TPA_ENABLE_FLAG;
-			changed =3D 1;
-		}
-	} else if (bp->flags & TPA_ENABLE_FLAG) {
-		dev->features &=3D ~NETIF_F_LRO;
-		bp->flags &=3D ~TPA_ENABLE_FLAG;
-		changed =3D 1;
-	}
-
-	if (changed && netif_running(dev)) {
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
-		rc =3D bnx2x_nic_load(bp, LOAD_NORMAL);
-	}
-
-	return rc;
-}
-
-static u32 bnx2x_get_rx_csum(struct net_device *dev)
-{
-	struct bnx2x *bp =3D netdev_priv(dev);
-
-	return bp->rx_csum;
-}
-
-static int bnx2x_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct bnx2x *bp =3D netdev_priv(dev);
-	int rc =3D 0;
-
-	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
-		return -EAGAIN;
-	}
-
-	bp->rx_csum =3D data;
-
-	/* Disable TPA, when Rx CSUM is disabled. Otherwise all
-	   TPA'ed packets will be discarded due to wrong TCP CSUM */
-	if (!data) {
-		u32 flags =3D ethtool_op_get_flags(dev);
-
-		rc =3D bnx2x_set_flags(dev, (flags & ~ETH_FLAG_LRO));
-	}
-
-	return rc;
-}
-
-static int bnx2x_set_tso(struct net_device *dev, u32 data)
-{
-	if (data) {
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
-		dev->features |=3D NETIF_F_TSO6;
-	} else {
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
-		dev->features &=3D ~NETIF_F_TSO6;
-	}
-
-	return 0;
-}
-
 static const struct {
 	char string[ETH_GSTRING_LEN];
 } bnx2x_tests_str_arr[BNX2X_NUM_TESTS] =3D {
@@ -2207,16 +2122,6 @@ static const struct ethtool_ops bnx2x_ethtool_op=
s =3D {
 	.set_ringparam		=3D bnx2x_set_ringparam,
 	.get_pauseparam		=3D bnx2x_get_pauseparam,
 	.set_pauseparam		=3D bnx2x_set_pauseparam,
-	.get_rx_csum		=3D bnx2x_get_rx_csum,
-	.set_rx_csum		=3D bnx2x_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
-	.set_flags		=3D bnx2x_set_flags,
-	.get_flags		=3D ethtool_op_get_flags,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D bnx2x_set_tso,
 	.self_test		=3D bnx2x_self_test,
 	.get_sset_count		=3D bnx2x_get_sset_count,
 	.get_strings		=3D bnx2x_get_strings,
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_m=
ain.c
index f3cf889..5a60269 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -7728,6 +7728,7 @@ static void bnx2x_parity_recover(struct bnx2x *bp=
)
 						return;
 					}
=20
+					netdev_update_features(bp->dev);
 					return;
 				}
 			} else { /* non-leader */
@@ -7755,10 +7756,12 @@ static void bnx2x_parity_recover(struct bnx2x *=
bp)
 					  * the "process kill". It's an exit
 					  * point for a non-leader.
 					  */
-					bnx2x_nic_load(bp, LOAD_NORMAL);
+					int rc =3D bnx2x_nic_load(bp, LOAD_NORMAL);
 					bp->recovery_state =3D
 						BNX2X_RECOVERY_DONE;
 					smp_wmb();
+					if (!rc)
+						netdev_update_features(bp->dev);
 					return;
 				}
 			}
@@ -8904,8 +8907,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *=
bp)
 	bp->multi_mode =3D multi_mode;
 	bp->int_mode =3D int_mode;
=20
-	bp->dev->features |=3D NETIF_F_GRO;
-
 	/* Set TPA flags */
 	if (disable_tpa) {
 		bp->flags &=3D ~TPA_ENABLE_FLAG;
@@ -8954,6 +8955,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *=
bp)
 static int bnx2x_open(struct net_device *dev)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
+	int rc;
=20
 	netif_carrier_off(dev);
=20
@@ -8993,7 +8995,10 @@ static int bnx2x_open(struct net_device *dev)
=20
 	bp->recovery_state =3D BNX2X_RECOVERY_DONE;
=20
-	return bnx2x_nic_load(bp, LOAD_OPEN);
+	rc =3D bnx2x_nic_load(bp, LOAD_OPEN);
+	if (!rc)
+		netdev_update_features(bp->dev);
+	return rc;
 }
=20
 /* called with rtnl_lock */
@@ -9304,6 +9309,8 @@ static const struct net_device_ops bnx2x_netdev_o=
ps =3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_do_ioctl		=3D bnx2x_ioctl,
 	.ndo_change_mtu		=3D bnx2x_change_mtu,
+	.ndo_fix_features	=3D bnx2x_fix_features,
+	.ndo_set_features	=3D bnx2x_set_features,
 	.ndo_tx_timeout		=3D bnx2x_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D poll_bnx2x,
@@ -9430,20 +9437,18 @@ static int __devinit bnx2x_init_dev(struct pci_=
dev *pdev,
=20
 	dev->netdev_ops =3D &bnx2x_netdev_ops;
 	bnx2x_set_ethtool_ops(dev);
-	dev->features |=3D NETIF_F_SG;
-	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+
 	if (bp->flags & USING_DAC_FLAG)
 		dev->features |=3D NETIF_F_HIGHDMA;
-	dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
-	dev->features |=3D NETIF_F_TSO6;
-	dev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
=20
-	dev->vlan_features |=3D NETIF_F_SG;
-	dev->vlan_features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	if (bp->flags & USING_DAC_FLAG)
-		dev->vlan_features |=3D NETIF_F_HIGHDMA;
-	dev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
-	dev->vlan_features |=3D NETIF_F_TSO6;
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM=
 |
+		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
+		NETIF_F_LRO | NETIF_F_HW_VLAN_TX;
+
+	dev->features |=3D dev->hw_features | NETIF_F_HW_VLAN_RX;
+
+	dev->vlan_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CS=
UM |
+		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
=20
 #ifdef BCM_DCBNL
 	dev->dcbnl_ops =3D &bnx2x_dcbnl_ops;
--=20
1.7.2.5

