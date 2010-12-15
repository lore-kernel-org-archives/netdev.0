From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 10/12] Intel net drivers: convert to ndo_fix_features
Date: Wed, 15 Dec 2010 23:24:30 +0100 (CET)
Message-ID: <42c9ff4760f697554db4d6caba78bc5c9611d68d.1292451560.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53557 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752293Ab0LOWYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:32 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Private rx_csum flags are now duplicate of netdev->features & NETIF_F_R=
XCSUM.
Removing this needs deeper surgery.

Since ixgbevf doesn't change hardware state on RX csum enable/disable
its reset is avoided.

Things noticed:
 - e1000, e1000e and ixgb have RX csum disabled by default
 - HW VLAN acceleration probably can be toggled, but it's left as is
 - the resets on RX csum offload change can probably be avoided
 - there is A LOT of copy-and-pasted code here

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/e1000/e1000_ethtool.c  |   69 ----------------------------=
--------
 drivers/net/e1000/e1000_main.c     |   31 ++++++++++++++--
 drivers/net/e1000e/ethtool.c       |   62 ----------------------------=
----
 drivers/net/e1000e/netdev.c        |   31 ++++++++++++++--
 drivers/net/igb/igb_ethtool.c      |   67 ----------------------------=
------
 drivers/net/igb/igb_main.c         |   34 ++++++++++++++----
 drivers/net/igbvf/ethtool.c        |   57 ----------------------------=
-
 drivers/net/igbvf/netdev.c         |   26 +++++++++++---
 drivers/net/ixgb/ixgb.h            |    2 +
 drivers/net/ixgb/ixgb_ethtool.c    |   59 +---------------------------=
---
 drivers/net/ixgb/ixgb_main.c       |   31 ++++++++++++++--
 drivers/net/ixgbe/ixgbe_ethtool.c  |   65 ----------------------------=
-----
 drivers/net/ixgbe/ixgbe_main.c     |   32 ++++++++++++-----
 drivers/net/ixgbevf/ethtool.c      |   46 ------------------------
 drivers/net/ixgbevf/ixgbevf_main.c |   27 +++++++++++---
 15 files changed, 178 insertions(+), 461 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e100=
0_ethtool.c
index f4d0922..8002b5b 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -288,69 +288,6 @@ static int e1000_set_pauseparam(struct net_device =
*netdev,
 	return retval;
 }
=20
-static u32 e1000_get_rx_csum(struct net_device *netdev)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	return adapter->rx_csum;
-}
-
-static int e1000_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	adapter->rx_csum =3D data;
-
-	if (netif_running(netdev))
-		e1000_reinit_locked(adapter);
-	else
-		e1000_reset(adapter);
-	return 0;
-}
-
-static u32 e1000_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	struct e1000_hw *hw =3D &adapter->hw;
-
-	if (hw->mac_type < e1000_82543) {
-		if (!data)
-			return -EINVAL;
-		return 0;
-	}
-
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
-static int e1000_set_tso(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	struct e1000_hw *hw =3D &adapter->hw;
-
-	if ((hw->mac_type < e1000_82544) ||
-	    (hw->mac_type =3D=3D e1000_82547))
-		return data ? -EINVAL : 0;
-
-	if (data)
-		netdev->features |=3D NETIF_F_TSO;
-	else
-		netdev->features &=3D ~NETIF_F_TSO;
-
-	netdev->features &=3D ~NETIF_F_TSO6;
-
-	e_info(probe, "TSO is %s\n", data ? "Enabled" : "Disabled");
-	adapter->tso_force =3D true;
-	return 0;
-}
-
 static u32 e1000_get_msglevel(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
@@ -1921,12 +1858,6 @@ static const struct ethtool_ops e1000_ethtool_op=
s =3D {
 	.set_ringparam          =3D e1000_set_ringparam,
 	.get_pauseparam         =3D e1000_get_pauseparam,
 	.set_pauseparam         =3D e1000_set_pauseparam,
-	.get_rx_csum            =3D e1000_get_rx_csum,
-	.set_rx_csum            =3D e1000_set_rx_csum,
-	.get_tx_csum            =3D e1000_get_tx_csum,
-	.set_tx_csum            =3D e1000_set_tx_csum,
-	.set_sg                 =3D ethtool_op_set_sg,
-	.set_tso                =3D e1000_set_tso,
 	.self_test              =3D e1000_diag_test,
 	.get_strings            =3D e1000_get_strings,
 	.phys_id                =3D e1000_phys_id,
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index 340e12d..a85765e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -788,6 +788,25 @@ static int e1000_is_need_ioport(struct pci_dev *pd=
ev)
 	}
 }
=20
+static int e1000_set_features(struct net_device *netdev,
+	unsigned long features)
+{
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	unsigned long changed =3D features ^ netdev->features;
+
+	if (!(changed & NETIF_F_RXCSUM))
+		return 0;
+
+	adapter->rx_csum =3D !!(features & NETIF_F_RXCSUM);
+
+	if (netif_running(netdev))
+		e1000_reinit_locked(adapter);
+	else
+		e1000_reset(adapter);
+
+	return 0;
+}
+
 static const struct net_device_ops e1000_netdev_ops =3D {
 	.ndo_open		=3D e1000_open,
 	.ndo_stop		=3D e1000_close,
@@ -806,6 +825,7 @@ static const struct net_device_ops e1000_netdev_ops=
 =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D e1000_netpoll,
 #endif
+	.ndo_set_features       =3D e1000_set_features,
 };
=20
 /**
@@ -998,16 +1018,19 @@ static int __devinit e1000_probe(struct pci_dev =
*pdev,
 	err =3D -EIO;
=20
 	if (hw->mac_type >=3D e1000_82543) {
-		netdev->features =3D NETIF_F_SG |
-				   NETIF_F_HW_CSUM |
-				   NETIF_F_HW_VLAN_TX |
+		netdev->hw_features =3D NETIF_F_SG |
+				   NETIF_F_HW_CSUM;
+		netdev->features =3D NETIF_F_HW_VLAN_TX |
 				   NETIF_F_HW_VLAN_RX |
 				   NETIF_F_HW_VLAN_FILTER;
 	}
=20
 	if ((hw->mac_type >=3D e1000_82544) &&
 	   (hw->mac_type !=3D e1000_82547))
-		netdev->features |=3D NETIF_F_TSO;
+		netdev->hw_features |=3D NETIF_F_TSO;
+
+	netdev->features |=3D netdev->hw_features;
+	netdev->hw_features |=3D NETIF_F_RXCSUM;
=20
 	if (pci_using_dac) {
 		netdev->features |=3D NETIF_F_HIGHDMA;
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.=
c
index 39349d6..adb6f14 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -351,59 +351,6 @@ out:
 	return retval;
 }
=20
-static u32 e1000_get_rx_csum(struct net_device *netdev)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	return adapter->flags & FLAG_RX_CSUM_ENABLED;
-}
-
-static int e1000_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data)
-		adapter->flags |=3D FLAG_RX_CSUM_ENABLED;
-	else
-		adapter->flags &=3D ~FLAG_RX_CSUM_ENABLED;
-
-	if (netif_running(netdev))
-		e1000e_reinit_locked(adapter);
-	else
-		e1000e_reset(adapter);
-	return 0;
-}
-
-static u32 e1000_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
-static int e1000_set_tso(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-
-	adapter->flags |=3D FLAG_TSO_FORCE;
-	return 0;
-}
-
 static u32 e1000_get_msglevel(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
@@ -2027,14 +1974,6 @@ static const struct ethtool_ops e1000_ethtool_op=
s =3D {
 	.set_ringparam		=3D e1000_set_ringparam,
 	.get_pauseparam		=3D e1000_get_pauseparam,
 	.set_pauseparam		=3D e1000_set_pauseparam,
-	.get_rx_csum		=3D e1000_get_rx_csum,
-	.set_rx_csum		=3D e1000_set_rx_csum,
-	.get_tx_csum		=3D e1000_get_tx_csum,
-	.set_tx_csum		=3D e1000_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D e1000_set_tso,
 	.self_test		=3D e1000_diag_test,
 	.get_strings		=3D e1000_get_strings,
 	.phys_id		=3D e1000_phys_id,
@@ -2042,7 +1981,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.get_sset_count		=3D e1000e_get_sset_count,
 	.get_coalesce		=3D e1000_get_coalesce,
 	.set_coalesce		=3D e1000_set_coalesce,
-	.get_flags		=3D ethtool_op_get_flags,
 };
=20
 void e1000e_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a45dafd..8d71c35 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5663,6 +5663,28 @@ static void e1000_eeprom_checks(struct e1000_ada=
pter *adapter)
 	}
 }
=20
+static int e1000_set_features(struct net_device *netdev,
+	unsigned long features)
+{
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	unsigned long changed =3D features ^ netdev->features;
+
+	if (!(changed & NETIF_F_RXCSUM))
+		return 0;
+
+	if (features & NETIF_F_RXCSUM)
+		adapter->flags |=3D FLAG_RX_CSUM_ENABLED;
+	else
+		adapter->flags &=3D ~FLAG_RX_CSUM_ENABLED;
+
+	if (netif_running(netdev))
+		e1000e_reinit_locked(adapter);
+	else
+		e1000e_reset(adapter);
+
+	return 0;
+}
+
 static const struct net_device_ops e1000e_netdev_ops =3D {
 	.ndo_open		=3D e1000_open,
 	.ndo_stop		=3D e1000_close,
@@ -5681,6 +5703,7 @@ static const struct net_device_ops e1000e_netdev_=
ops =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D e1000_netpoll,
 #endif
+	.ndo_set_features	=3D e1000_set_features,
 };
=20
 /**
@@ -5835,17 +5858,17 @@ static int __devinit e1000_probe(struct pci_dev=
 *pdev,
 	if (e1000_check_reset_block(&adapter->hw))
 		e_info("PHY reset is blocked due to SOL/IDER session.\n");
=20
-	netdev->features =3D NETIF_F_SG |
+	netdev->hw_features =3D NETIF_F_SG |
 			   NETIF_F_HW_CSUM |
+			   NETIF_F_TSO | NETIF_F_TSO6;
+	netdev->features =3D netdev->hw_features |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX;
+	netdev->hw_features |=3D NETIF_F_RXCSUM;
=20
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 		netdev->features |=3D NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->features |=3D NETIF_F_TSO;
-	netdev->features |=3D NETIF_F_TSO6;
-
 	netdev->vlan_features |=3D NETIF_F_TSO;
 	netdev->vlan_features |=3D NETIF_F_TSO6;
 	netdev->vlan_features |=3D NETIF_F_HW_CSUM;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtoo=
l.c
index a70e16b..7736b59 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -313,65 +313,6 @@ static int igb_set_pauseparam(struct net_device *n=
etdev,
 	return retval;
 }
=20
-static u32 igb_get_rx_csum(struct net_device *netdev)
-{
-	struct igb_adapter *adapter =3D netdev_priv(netdev);
-	return !!(adapter->rx_ring[0]->flags & IGB_RING_FLAG_RX_CSUM);
-}
-
-static int igb_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct igb_adapter *adapter =3D netdev_priv(netdev);
-	int i;
-
-	for (i =3D 0; i < adapter->num_rx_queues; i++) {
-		if (data)
-			adapter->rx_ring[i]->flags |=3D IGB_RING_FLAG_RX_CSUM;
-		else
-			adapter->rx_ring[i]->flags &=3D ~IGB_RING_FLAG_RX_CSUM;
-	}
-
-	return 0;
-}
-
-static u32 igb_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-static int igb_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct igb_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-		if (adapter->hw.mac.type >=3D e1000_82576)
-			netdev->features |=3D NETIF_F_SCTP_CSUM;
-	} else {
-		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		                      NETIF_F_SCTP_CSUM);
-	}
-
-	return 0;
-}
-
-static int igb_set_tso(struct net_device *netdev, u32 data)
-{
-	struct igb_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-
-	dev_info(&adapter->pdev->dev, "TSO is %s\n",
-		 data ? "Enabled" : "Disabled");
-	return 0;
-}
-
 static u32 igb_get_msglevel(struct net_device *netdev)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
@@ -2189,14 +2130,6 @@ static const struct ethtool_ops igb_ethtool_ops =
=3D {
 	.set_ringparam          =3D igb_set_ringparam,
 	.get_pauseparam         =3D igb_get_pauseparam,
 	.set_pauseparam         =3D igb_set_pauseparam,
-	.get_rx_csum            =3D igb_get_rx_csum,
-	.set_rx_csum            =3D igb_set_rx_csum,
-	.get_tx_csum            =3D igb_get_tx_csum,
-	.set_tx_csum            =3D igb_set_tx_csum,
-	.get_sg                 =3D ethtool_op_get_sg,
-	.set_sg                 =3D ethtool_op_set_sg,
-	.get_tso                =3D ethtool_op_get_tso,
-	.set_tso                =3D igb_set_tso,
 	.self_test              =3D igb_diag_test,
 	.get_strings            =3D igb_get_strings,
 	.phys_id                =3D igb_phys_id,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 62348fc..663144a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1687,6 +1687,22 @@ void igb_reset(struct igb_adapter *adapter)
 	igb_get_phy_info(hw);
 }
=20
+static int igb_set_features(struct net_device *netdev,
+	unsigned long features)
+{
+	struct igb_adapter *adapter =3D netdev_priv(netdev);
+	int i;
+
+	for (i =3D 0; i < adapter->num_rx_queues; i++) {
+		if (features & NETIF_F_RXCSUM)
+			adapter->rx_ring[i]->flags |=3D IGB_RING_FLAG_RX_CSUM;
+		else
+			adapter->rx_ring[i]->flags &=3D ~IGB_RING_FLAG_RX_CSUM;
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops igb_netdev_ops =3D {
 	.ndo_open		=3D igb_open,
 	.ndo_stop		=3D igb_close,
@@ -1709,6 +1725,7 @@ static const struct net_device_ops igb_netdev_ops=
 =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D igb_netpoll,
 #endif
+	.ndo_set_features       =3D igb_set_features,
 };
=20
 /**
@@ -1848,17 +1865,18 @@ static int __devinit igb_probe(struct pci_dev *=
pdev,
 		dev_info(&pdev->dev,
 			"PHY reset is blocked due to SOL/IDER session.\n");
=20
-	netdev->features =3D NETIF_F_SG |
+	netdev->hw_features =3D NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
+			   NETIF_F_IPV6_CSUM |
+			   NETIF_F_TSO |
+			   NETIF_F_TSO6 |
+			   NETIF_F_RXCSUM;
+
+	netdev->features =3D netdev->hw_features |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->features |=3D NETIF_F_IPV6_CSUM;
-	netdev->features |=3D NETIF_F_TSO;
-	netdev->features |=3D NETIF_F_TSO6;
-	netdev->features |=3D NETIF_F_GRO;
-
 	netdev->vlan_features |=3D NETIF_F_TSO;
 	netdev->vlan_features |=3D NETIF_F_TSO6;
 	netdev->vlan_features |=3D NETIF_F_IP_CSUM;
@@ -1870,8 +1888,10 @@ static int __devinit igb_probe(struct pci_dev *p=
dev,
 		netdev->vlan_features |=3D NETIF_F_HIGHDMA;
 	}
=20
-	if (hw->mac.type >=3D e1000_82576)
+	if (hw->mac.type >=3D e1000_82576) {
+		netdev->hw_features |=3D NETIF_F_SCTP_CSUM;
 		netdev->features |=3D NETIF_F_SCTP_CSUM;
+	}
=20
 	adapter->en_mng_pt =3D igb_enable_mng_pass_thru(hw);
=20
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index ed6e3d9..91ada3c 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -128,55 +128,6 @@ static int igbvf_set_pauseparam(struct net_device =
*netdev,
 	return -EOPNOTSUPP;
 }
=20
-static u32 igbvf_get_rx_csum(struct net_device *netdev)
-{
-	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
-	return !(adapter->flags & IGBVF_FLAG_RX_CSUM_DISABLED);
-}
-
-static int igbvf_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data)
-		adapter->flags &=3D ~IGBVF_FLAG_RX_CSUM_DISABLED;
-	else
-		adapter->flags |=3D IGBVF_FLAG_RX_CSUM_DISABLED;
-
-	return 0;
-}
-
-static u32 igbvf_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-static int igbvf_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	else
-		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	return 0;
-}
-
-static int igbvf_set_tso(struct net_device *netdev, u32 data)
-{
-	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-
-	dev_info(&adapter->pdev->dev, "TSO is %s\n",
-	         data ? "Enabled" : "Disabled");
-	return 0;
-}
-
 static u32 igbvf_get_msglevel(struct net_device *netdev)
 {
 	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
@@ -518,14 +469,6 @@ static const struct ethtool_ops igbvf_ethtool_ops =
=3D {
 	.set_ringparam		=3D igbvf_set_ringparam,
 	.get_pauseparam		=3D igbvf_get_pauseparam,
 	.set_pauseparam		=3D igbvf_set_pauseparam,
-	.get_rx_csum            =3D igbvf_get_rx_csum,
-	.set_rx_csum            =3D igbvf_set_rx_csum,
-	.get_tx_csum		=3D igbvf_get_tx_csum,
-	.set_tx_csum		=3D igbvf_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D igbvf_set_tso,
 	.self_test		=3D igbvf_diag_test,
 	.get_sset_count		=3D igbvf_get_sset_count,
 	.get_strings		=3D igbvf_get_strings,
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 4fb023b..71acae7 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2597,6 +2597,19 @@ static void igbvf_print_device_info(struct igbvf=
_adapter *adapter)
 	dev_info(&pdev->dev, "MAC: %d\n", hw->mac.type);
 }
=20
+static int igbvf_set_features(struct net_device *netdev,
+	unsigned long features)
+{
+	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
+
+	if (features & NETIF_F_RXCSUM)
+		adapter->flags &=3D ~IGBVF_FLAG_RX_CSUM_DISABLED;
+	else
+		adapter->flags |=3D IGBVF_FLAG_RX_CSUM_DISABLED;
+
+	return 0;
+}
+
 static const struct net_device_ops igbvf_netdev_ops =3D {
 	.ndo_open                       =3D igbvf_open,
 	.ndo_stop                       =3D igbvf_close,
@@ -2613,6 +2626,7 @@ static const struct net_device_ops igbvf_netdev_o=
ps =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller            =3D igbvf_netpoll,
 #endif
+	.ndo_set_features               =3D igbvf_set_features,
 };
=20
 /**
@@ -2721,16 +2735,18 @@ static int __devinit igbvf_probe(struct pci_dev=
 *pdev,
=20
 	adapter->bd_number =3D cards_found++;
=20
-	netdev->features =3D NETIF_F_SG |
+	netdev->hw_features =3D NETIF_F_SG |
 	                   NETIF_F_IP_CSUM |
+	                   NETIF_F_IPV6_CSUM |
+			   NETIF_F_TSO |
+			   NETIF_F_TSO6 |
+			   NETIF_F_RXCSUM;
+
+	netdev->features =3D netdev->hw_features |
 	                   NETIF_F_HW_VLAN_TX |
 	                   NETIF_F_HW_VLAN_RX |
 	                   NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->features |=3D NETIF_F_IPV6_CSUM;
-	netdev->features |=3D NETIF_F_TSO;
-	netdev->features |=3D NETIF_F_TSO6;
-
 	if (pci_using_dac)
 		netdev->features |=3D NETIF_F_HIGHDMA;
=20
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 521c0c7..ac0f424 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -207,6 +207,8 @@ extern void ixgb_set_ethtool_ops(struct net_device =
*netdev);
 extern char ixgb_driver_name[];
 extern const char ixgb_driver_version[];
=20
+extern void ixgb_set_speed_duplex(struct net_device *netdev);
+
 extern int ixgb_up(struct ixgb_adapter *adapter);
 extern void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog=
);
 extern void ixgb_reset(struct ixgb_adapter *adapter);
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_et=
htool.c
index 43994c1..35e6f11 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -115,7 +115,7 @@ ixgb_get_settings(struct net_device *netdev, struct=
 ethtool_cmd *ecmd)
 	return 0;
 }
=20
-static void ixgb_set_speed_duplex(struct net_device *netdev)
+void ixgb_set_speed_duplex(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
 	/* be optimistic about our link, since we were up before */
@@ -194,57 +194,6 @@ ixgb_set_pauseparam(struct net_device *netdev,
 }
=20
 static u32
-ixgb_get_rx_csum(struct net_device *netdev)
-{
-	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
-
-	return adapter->rx_csum;
-}
-
-static int
-ixgb_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
-
-	adapter->rx_csum =3D data;
-
-	if (netif_running(netdev)) {
-		ixgb_down(adapter, true);
-		ixgb_up(adapter);
-		ixgb_set_speed_duplex(netdev);
-	} else
-		ixgb_reset(adapter);
-	return 0;
-}
-
-static u32
-ixgb_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-static int
-ixgb_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
-static int
-ixgb_set_tso(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_TSO;
-	else
-		netdev->features &=3D ~NETIF_F_TSO;
-	return 0;
-}
-
-static u32
 ixgb_get_msglevel(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
@@ -720,14 +669,8 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
 {
 	.set_ringparam =3D ixgb_set_ringparam,
 	.get_pauseparam	=3D ixgb_get_pauseparam,
 	.set_pauseparam	=3D ixgb_set_pauseparam,
-	.get_rx_csum =3D ixgb_get_rx_csum,
-	.set_rx_csum =3D ixgb_set_rx_csum,
-	.get_tx_csum =3D ixgb_get_tx_csum,
-	.set_tx_csum =3D ixgb_set_tx_csum,
-	.set_sg	=3D ethtool_op_set_sg,
 	.get_msglevel =3D ixgb_get_msglevel,
 	.set_msglevel =3D ixgb_set_msglevel,
-	.set_tso =3D ixgb_set_tso,
 	.get_strings =3D ixgb_get_strings,
 	.phys_id =3D ixgb_phys_id,
 	.get_sset_count =3D ixgb_get_sset_count,
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.=
c
index 5639ccc..0a1b036 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -326,6 +326,28 @@ ixgb_reset(struct ixgb_adapter *adapter)
 	}
 }
=20
+static int
+ixgb_set_features(struct net_device *netdev, unsigned long features)
+{
+	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
+	unsigned long changed =3D features ^ netdev->features;
+
+        if (!(changed & NETIF_F_RXCSUM))
+                return 0;
+
+	adapter->rx_csum =3D !!(features & NETIF_F_RXCSUM);
+
+	if (netif_running(netdev)) {
+		ixgb_down(adapter, true);
+		ixgb_up(adapter);
+		ixgb_set_speed_duplex(netdev);
+	} else
+		ixgb_reset(adapter);
+
+	return 0;
+}
+
+
 static const struct net_device_ops ixgb_netdev_ops =3D {
 	.ndo_open 		=3D ixgb_open,
 	.ndo_stop		=3D ixgb_close,
@@ -342,6 +364,7 @@ static const struct net_device_ops ixgb_netdev_ops =
=3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D ixgb_netpoll,
 #endif
+	.ndo_set_features       =3D ixgb_set_features,
 };
=20
 /**
@@ -441,12 +464,14 @@ ixgb_probe(struct pci_dev *pdev, const struct pci=
_device_id *ent)
 	if (err)
 		goto err_sw_init;
=20
-	netdev->features =3D NETIF_F_SG |
-			   NETIF_F_HW_CSUM |
+	netdev->hw_features =3D NETIF_F_SG |
+			   NETIF_F_TSO |
+			   NETIF_F_HW_CSUM;
+	netdev->features =3D netdev->hw_features |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
-	netdev->features |=3D NETIF_F_TSO;
+	netdev->hw_features |=3D NETIF_F_RXCSUM;
=20
 	if (pci_using_dac) {
 		netdev->features |=3D NETIF_F_HIGHDMA;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgb=
e_ethtool.c
index 23ff23e..f0795db 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -406,62 +406,6 @@ static int ixgbe_set_pauseparam(struct net_device =
*netdev,
 	return 0;
 }
=20
-static u32 ixgbe_get_rx_csum(struct net_device *netdev)
-{
-	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
-	return adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED;
-}
-
-static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
-	if (data)
-		adapter->flags |=3D IXGBE_FLAG_RX_CSUM_ENABLED;
-	else
-		adapter->flags &=3D ~IXGBE_FLAG_RX_CSUM_ENABLED;
-
-	return 0;
-}
-
-static u32 ixgbe_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
-	u32 feature_list;
-
-	feature_list =3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		feature_list |=3D NETIF_F_SCTP_CSUM;
-		break;
-	default:
-		break;
-	}
-	if (data)
-		netdev->features |=3D feature_list;
-	else
-		netdev->features &=3D ~feature_list;
-
-	return 0;
-}
-
-static int ixgbe_set_tso(struct net_device *netdev, u32 data)
-{
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-	return 0;
-}
-
 static u32 ixgbe_get_msglevel(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
@@ -2370,16 +2314,8 @@ static const struct ethtool_ops ixgbe_ethtool_op=
s =3D {
 	.set_ringparam          =3D ixgbe_set_ringparam,
 	.get_pauseparam         =3D ixgbe_get_pauseparam,
 	.set_pauseparam         =3D ixgbe_set_pauseparam,
-	.get_rx_csum            =3D ixgbe_get_rx_csum,
-	.set_rx_csum            =3D ixgbe_set_rx_csum,
-	.get_tx_csum            =3D ixgbe_get_tx_csum,
-	.set_tx_csum            =3D ixgbe_set_tx_csum,
-	.get_sg                 =3D ethtool_op_get_sg,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.get_msglevel           =3D ixgbe_get_msglevel,
 	.set_msglevel           =3D ixgbe_set_msglevel,
-	.get_tso                =3D ethtool_op_get_tso,
-	.set_tso                =3D ixgbe_set_tso,
 	.self_test              =3D ixgbe_diag_test,
 	.get_strings            =3D ixgbe_get_strings,
 	.phys_id                =3D ixgbe_phys_id,
@@ -2387,7 +2323,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops=
 =3D {
 	.get_ethtool_stats      =3D ixgbe_get_ethtool_stats,
 	.get_coalesce           =3D ixgbe_get_coalesce,
 	.set_coalesce           =3D ixgbe_set_coalesce,
-	.get_flags              =3D ethtool_op_get_flags,
 	.set_flags              =3D ixgbe_set_flags,
 	.set_rx_ntuple          =3D ixgbe_set_rx_ntuple,
 };
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index ca9036d..ad0e0ca 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6850,6 +6850,17 @@ static struct rtnl_link_stats64 *ixgbe_get_stats=
64(struct net_device *netdev,
 	return stats;
 }
=20
+static int ixgbe_set_features(struct net_device *netdev,
+	unsigned long features)
+{
+	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
+	if (features & NETIF_F_RXCSUM)
+		adapter->flags |=3D IXGBE_FLAG_RX_CSUM_ENABLED;
+	else
+		adapter->flags &=3D ~IXGBE_FLAG_RX_CSUM_ENABLED;
+
+	return 0;
+}
=20
 static const struct net_device_ops ixgbe_netdev_ops =3D {
 	.ndo_open		=3D ixgbe_open,
@@ -6880,6 +6891,7 @@ static const struct net_device_ops ixgbe_netdev_o=
ps =3D {
 	.ndo_fcoe_disable =3D ixgbe_fcoe_disable,
 	.ndo_fcoe_get_wwn =3D ixgbe_fcoe_get_wwn,
 #endif /* IXGBE_FCOE */
+	.ndo_set_features =3D ixgbe_set_features,
 };
=20
 static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
@@ -7144,20 +7156,22 @@ static int __devinit ixgbe_probe(struct pci_dev=
 *pdev,
=20
 	ixgbe_probe_vf(adapter, ii);
=20
-	netdev->features =3D NETIF_F_SG |
+	netdev->hw_features =3D NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
+			   NETIF_F_IPV6_CSUM |
+			   NETIF_F_TSO |
+			   NETIF_F_TSO6 |
+			   NETIF_F_RXCSUM;
+
+	if (adapter->hw.mac.type =3D=3D ixgbe_mac_82599EB
+	    || adapter->hw.mac.type =3D=3D ixgbe_mac_X540)
+		netdev->hw_features |=3D NETIF_F_SCTP_CSUM;
+
+	netdev->features =3D netdev->hw_features |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->features |=3D NETIF_F_IPV6_CSUM;
-	netdev->features |=3D NETIF_F_TSO;
-	netdev->features |=3D NETIF_F_TSO6;
-	netdev->features |=3D NETIF_F_GRO;
-
-	if (adapter->hw.mac.type =3D=3D ixgbe_mac_82599EB)
-		netdev->features |=3D NETIF_F_SCTP_CSUM;
-
 	netdev->vlan_features |=3D NETIF_F_TSO;
 	netdev->vlan_features |=3D NETIF_F_TSO6;
 	netdev->vlan_features |=3D NETIF_F_IP_CSUM;
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtoo=
l.c
index fa29b3c..9157eea 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -115,44 +115,6 @@ static int ixgbevf_get_settings(struct net_device =
*netdev,
 	return 0;
 }
=20
-static u32 ixgbevf_get_rx_csum(struct net_device *netdev)
-{
-	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
-	return adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED;
-}
-
-static int ixgbevf_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
-	if (data)
-		adapter->flags |=3D IXGBE_FLAG_RX_CSUM_ENABLED;
-	else
-		adapter->flags &=3D ~IXGBE_FLAG_RX_CSUM_ENABLED;
-
-	if (netif_running(netdev)) {
-		if (!adapter->dev_closed)
-			ixgbevf_reinit_locked(adapter);
-	} else {
-		ixgbevf_reset(adapter);
-	}
-
-	return 0;
-}
-
-static int ixgbevf_set_tso(struct net_device *netdev, u32 data)
-{
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netif_tx_stop_all_queues(netdev);
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-		netif_tx_start_all_queues(netdev);
-	}
-	return 0;
-}
-
 static u32 ixgbevf_get_msglevel(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
@@ -718,16 +680,8 @@ static struct ethtool_ops ixgbevf_ethtool_ops =3D =
{
 	.get_link               =3D ethtool_op_get_link,
 	.get_ringparam          =3D ixgbevf_get_ringparam,
 	.set_ringparam          =3D ixgbevf_set_ringparam,
-	.get_rx_csum            =3D ixgbevf_get_rx_csum,
-	.set_rx_csum            =3D ixgbevf_set_rx_csum,
-	.get_tx_csum            =3D ethtool_op_get_tx_csum,
-	.set_tx_csum            =3D ethtool_op_set_tx_ipv6_csum,
-	.get_sg                 =3D ethtool_op_get_sg,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.get_msglevel           =3D ixgbevf_get_msglevel,
 	.set_msglevel           =3D ixgbevf_set_msglevel,
-	.get_tso                =3D ethtool_op_get_tso,
-	.set_tso                =3D ixgbevf_set_tso,
 	.self_test              =3D ixgbevf_diag_test,
 	.get_sset_count         =3D ixgbevf_get_sset_count,
 	.get_strings            =3D ixgbevf_get_strings,
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/i=
xgbevf_main.c
index 809e38c..091d05b 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3252,6 +3252,20 @@ static void ixgbevf_shutdown(struct pci_dev *pde=
v)
 	pci_disable_device(pdev);
 }
=20
+static int ixgbevf_set_features(struct net_device *netdev,
+	unsigned long features)
+{
+	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
+
+	if (features & NETIF_F_RXCSUM)
+		adapter->flags |=3D IXGBE_FLAG_RX_CSUM_ENABLED;
+	else
+		adapter->flags &=3D ~IXGBE_FLAG_RX_CSUM_ENABLED;
+
+	return 0;
+}
+
+
 static const struct net_device_ops ixgbe_netdev_ops =3D {
 	.ndo_open		=3D &ixgbevf_open,
 	.ndo_stop		=3D &ixgbevf_close,
@@ -3265,6 +3279,7 @@ static const struct net_device_ops ixgbe_netdev_o=
ps =3D {
 	.ndo_vlan_rx_register	=3D &ixgbevf_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	=3D &ixgbevf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	=3D &ixgbevf_vlan_rx_kill_vid,
+	.ndo_set_features       =3D ixgbevf_set_features,
 };
=20
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
@@ -3379,16 +3394,18 @@ static int __devinit ixgbevf_probe(struct pci_d=
ev *pdev,
 	/* setup the private structure */
 	err =3D ixgbevf_sw_init(adapter);
=20
-	netdev->features =3D NETIF_F_SG |
+	netdev->hw_features =3D NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
+			   NETIF_F_IPV6_CSUM |
+			   NETIF_F_TSO |
+			   NETIF_F_TSO6 |
+			   NETIF_F_RXCSUM;
+
+	netdev->features =3D netdev->hw_features |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->features |=3D NETIF_F_IPV6_CSUM;
-	netdev->features |=3D NETIF_F_TSO;
-	netdev->features |=3D NETIF_F_TSO6;
-	netdev->features |=3D NETIF_F_GRO;
 	netdev->vlan_features |=3D NETIF_F_TSO;
 	netdev->vlan_features |=3D NETIF_F_TSO6;
 	netdev->vlan_features |=3D NETIF_F_IP_CSUM;
--=20
1.7.2.3

