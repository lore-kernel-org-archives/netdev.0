From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [IGNORE PATCH 1/9] Intel net drivers: convert to ndo_fix_features
Date: Mon, 20 Jun 2011 21:55:35 +0200 (CEST)
Message-ID: <d1778fa5347fa56709c991b80eb7743cd7b321f2.1308599594.git.mirq-linux@rere.qmqm.pl>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>                                                
	<20110620.123538.1237637857260925516.davem@davemloft.net>                                         
	<20110620194756.GB3231@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:33497 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750829Ab1FTTzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 15:55:40 -0400
In-Reply-To: <20110620194756.GB3231@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[This is an outdated patch just for making the rest of the series compi=
le.]

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
 drivers/net/e1000/e1000_ethtool.c  |   69 --------------
 drivers/net/e1000/e1000_main.c     |   30 +++++-
 drivers/net/e1000e/ethtool.c       |   88 -----------------
 drivers/net/e1000e/netdev.c        |   35 ++++++--
 drivers/net/igb/igb_ethtool.c      |   67 -------------
 drivers/net/igb/igb_main.c         |   33 +++++--
 drivers/net/igbvf/ethtool.c        |   57 -----------
 drivers/net/igbvf/netdev.c         |   25 ++++-
 drivers/net/ixgb/ixgb.h            |    2 +
 drivers/net/ixgb/ixgb_ethtool.c    |   98 +-------------------
 drivers/net/ixgb/ixgb_main.c       |   44 ++++++++-
 drivers/net/ixgbe/ixgbe_ethtool.c  |  182 +++++++++++-----------------=
--------
 drivers/net/ixgbe/ixgbe_main.c     |   41 +++++---
 drivers/net/ixgbevf/ethtool.c      |   46 ---------
 drivers/net/ixgbevf/ixgbevf_main.c |   26 ++++-
 15 files changed, 244 insertions(+), 599 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e100=
0_ethtool.c
index ec0fa42..c5f0f04 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -290,69 +290,6 @@ static int e1000_set_pauseparam(struct net_device =
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
@@ -1905,12 +1842,6 @@ static const struct ethtool_ops e1000_ethtool_op=
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
 	.set_phys_id            =3D e1000_set_phys_id,
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index 76e8af0..188d99a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -797,6 +797,24 @@ static int e1000_is_need_ioport(struct pci_dev *pd=
ev)
 	}
 }
=20
+static int e1000_set_features(struct net_device *netdev, u32 features)
+{
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	u32 changed =3D features ^ netdev->features;
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
@@ -815,6 +833,7 @@ static const struct net_device_ops e1000_netdev_ops=
 =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D e1000_netpoll,
 #endif
+	.ndo_set_features       =3D e1000_set_features,
 };
=20
 /**
@@ -1016,16 +1035,19 @@ static int __devinit e1000_probe(struct pci_dev=
 *pdev,
 	}
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
index cb1a362..25b5431 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -367,59 +367,6 @@ out:
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
@@ -2003,31 +1950,6 @@ static void e1000_get_strings(struct net_device =
*netdev, u32 stringset,
 	}
 }
=20
-static int e1000e_set_flags(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	bool need_reset =3D false;
-	int rc;
-
-	need_reset =3D (data & ETH_FLAG_RXVLAN) !=3D
-		     (netdev->features & NETIF_F_HW_VLAN_RX);
-
-	rc =3D ethtool_op_set_flags(netdev, data, ETH_FLAG_RXVLAN |
-				  ETH_FLAG_TXVLAN);
-
-	if (rc)
-		return rc;
-
-	if (need_reset) {
-		if (netif_running(netdev))
-			e1000e_reinit_locked(adapter);
-		else
-			e1000e_reset(adapter);
-	}
-
-	return 0;
-}
-
 static const struct ethtool_ops e1000_ethtool_ops =3D {
 	.get_settings		=3D e1000_get_settings,
 	.set_settings		=3D e1000_set_settings,
@@ -2047,14 +1969,6 @@ static const struct ethtool_ops e1000_ethtool_op=
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
 	.set_phys_id		=3D e1000_set_phys_id,
@@ -2062,8 +1976,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.get_sset_count		=3D e1000e_get_sset_count,
 	.get_coalesce		=3D e1000_get_coalesce,
 	.set_coalesce		=3D e1000_set_coalesce,
-	.get_flags		=3D ethtool_op_get_flags,
-	.set_flags		=3D e1000e_set_flags,
 };
=20
 void e1000e_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3bf5249..45c9d06 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5751,6 +5751,28 @@ static void e1000_eeprom_checks(struct e1000_ada=
pter *adapter)
 	}
 }
=20
+static int e1000_set_features(struct net_device *netdev, u32 features)
+{
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	u32 changed =3D features ^ netdev->features;
+
+	if (features & NETIF_F_RXCSUM)
+		adapter->flags |=3D FLAG_RX_CSUM_ENABLED;
+	else
+		adapter->flags &=3D ~FLAG_RX_CSUM_ENABLED;
+
+	if (changed & NETIF_F_HW_VLAN_RX) {
+		netdev->features =3D features;
+		if (netif_running(netdev))
+			e1000e_reinit_locked(adapter);
+		else
+			e1000e_reset(adapter);
+		return 1;
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops e1000e_netdev_ops =3D {
 	.ndo_open		=3D e1000_open,
 	.ndo_stop		=3D e1000_close,
@@ -5768,6 +5790,7 @@ static const struct net_device_ops e1000e_netdev_=
ops =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D e1000_netpoll,
 #endif
+	.ndo_set_features	=3D e1000_set_features,
 };
=20
 /**
@@ -5927,17 +5950,15 @@ static int __devinit e1000_probe(struct pci_dev=
 *pdev,
 	if (e1000_check_reset_block(&adapter->hw))
 		e_info("PHY reset is blocked due to SOL/IDER session.\n");
=20
-	netdev->features =3D NETIF_F_SG |
-			   NETIF_F_HW_CSUM |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX;
+	netdev->hw_features =3D NETIF_F_SG | NETIF_F_HW_CSUM |
+			      NETIF_F_TSO | NETIF_F_TSO6 |
+			      NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	netdev->features =3D netdev->hw_features;
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
index fdc895e..1862c97 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -318,65 +318,6 @@ static int igb_set_pauseparam(struct net_device *n=
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
@@ -2207,14 +2148,6 @@ static const struct ethtool_ops igb_ethtool_ops =
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
 	.set_phys_id            =3D igb_set_phys_id,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c2e9670..2841f14 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1748,6 +1748,21 @@ void igb_reset(struct igb_adapter *adapter)
 	igb_get_phy_info(hw);
 }
=20
+static int igb_set_features(struct net_device *netdev, u32 features)
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
@@ -1770,6 +1785,7 @@ static const struct net_device_ops igb_netdev_ops=
 =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D igb_netpoll,
 #endif
+	.ndo_set_features       =3D igb_set_features,
 };
=20
 /**
@@ -1909,17 +1925,18 @@ static int __devinit igb_probe(struct pci_dev *=
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
@@ -1931,8 +1948,10 @@ static int __devinit igb_probe(struct pci_dev *p=
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
index b0b14d6..fd36366 100644
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
@@ -511,14 +462,6 @@ static const struct ethtool_ops igbvf_ethtool_ops =
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
index 64b47bf..bb2a596 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2546,6 +2546,18 @@ static void igbvf_print_device_info(struct igbvf=
_adapter *adapter)
 	dev_info(&pdev->dev, "MAC: %d\n", hw->mac.type);
 }
=20
+static int igbvf_set_features(struct net_device *netdev, u32 features)
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
@@ -2562,6 +2574,7 @@ static const struct net_device_ops igbvf_netdev_o=
ps =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller            =3D igbvf_netpoll,
 #endif
+	.ndo_set_features               =3D igbvf_set_features,
 };
=20
 /**
@@ -2669,16 +2682,18 @@ static int __devinit igbvf_probe(struct pci_dev=
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
index 49e8408..cb23448 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -204,6 +204,8 @@ extern void ixgb_set_ethtool_ops(struct net_device =
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
index 6da890b..ab404e7 100644
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
@@ -195,57 +195,6 @@ ixgb_set_pauseparam(struct net_device *netdev,
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
@@ -685,43 +634,6 @@ ixgb_get_strings(struct net_device *netdev, u32 st=
ringset, u8 *data)
 	}
 }
=20
-static int ixgb_set_flags(struct net_device *netdev, u32 data)
-{
-	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
-	bool need_reset;
-	int rc;
-
-	/*
-	 * Tx VLAN insertion does not work per HW design when Rx stripping is
-	 * disabled.  Disable txvlan when rxvlan is turned off, and enable
-	 * rxvlan when txvlan is turned on.
-	 */
-	if (!(data & ETH_FLAG_RXVLAN) &&
-	    (netdev->features & NETIF_F_HW_VLAN_TX))
-		data &=3D ~ETH_FLAG_TXVLAN;
-	else if (data & ETH_FLAG_TXVLAN)
-		data |=3D ETH_FLAG_RXVLAN;
-
-	need_reset =3D (data & ETH_FLAG_RXVLAN) !=3D
-		     (netdev->features & NETIF_F_HW_VLAN_RX);
-
-	rc =3D ethtool_op_set_flags(netdev, data, ETH_FLAG_RXVLAN |
-						ETH_FLAG_TXVLAN);
-	if (rc)
-		return rc;
-
-	if (need_reset) {
-		if (netif_running(netdev)) {
-			ixgb_down(adapter, true);
-			ixgb_up(adapter);
-			ixgb_set_speed_duplex(netdev);
-		} else
-			ixgb_reset(adapter);
-	}
-
-	return 0;
-}
-
 static const struct ethtool_ops ixgb_ethtool_ops =3D {
 	.get_settings =3D ixgb_get_settings,
 	.set_settings =3D ixgb_set_settings,
@@ -736,20 +648,12 @@ static const struct ethtool_ops ixgb_ethtool_ops =
=3D {
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
 	.set_phys_id =3D ixgb_set_phys_id,
 	.get_sset_count =3D ixgb_get_sset_count,
 	.get_ethtool_stats =3D ixgb_get_ethtool_stats,
-	.get_flags =3D ethtool_op_get_flags,
-	.set_flags =3D ixgb_set_flags,
 };
=20
 void ixgb_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.=
c
index 6a130eb..a2c47bf 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -325,6 +325,40 @@ ixgb_reset(struct ixgb_adapter *adapter)
 	}
 }
=20
+static u32
+ixgb_fix_features(struct net_device *netdev, u32 features)
+{
+	/*
+	 * Tx VLAN insertion does not work per HW design when Rx stripping is
+	 * disabled.
+	 */
+	if (!(features & NETIF_F_HW_VLAN_RX))
+		features &=3D ~NETIF_F_HW_VLAN_TX;
+
+	return features;
+}
+
+static int
+ixgb_set_features(struct net_device *netdev, u32 features)
+{
+	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
+	u32 changed =3D features ^ netdev->features;
+
+	if (!(changed & (NETIF_F_RXCSUM|NETIF_F_HW_VLAN_RX)))
+		return 0;
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
 static const struct net_device_ops ixgb_netdev_ops =3D {
 	.ndo_open 		=3D ixgb_open,
 	.ndo_stop		=3D ixgb_close,
@@ -334,6 +368,8 @@ static const struct net_device_ops ixgb_netdev_ops =
=3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address	=3D ixgb_set_mac,
 	.ndo_change_mtu		=3D ixgb_change_mtu,
+	.ndo_fix_features       =3D ixgb_fix_features,
+	.ndo_set_features       =3D ixgb_set_features,
 	.ndo_tx_timeout		=3D ixgb_tx_timeout,
 	.ndo_vlan_rx_add_vid	=3D ixgb_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	=3D ixgb_vlan_rx_kill_vid,
@@ -439,12 +475,14 @@ ixgb_probe(struct pci_dev *pdev, const struct pci=
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
index 4950d03..38ee164 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -442,62 +442,6 @@ static int ixgbe_set_pauseparam(struct net_device =
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
@@ -2244,65 +2188,60 @@ static int ixgbe_set_coalesce(struct net_device=
 *netdev,
 	return 0;
 }
=20
-static int ixgbe_set_flags(struct net_device *netdev, u32 data)
+u32 ixgbe_fix_features(struct net_device *netdev, u32 features)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
-	bool need_reset =3D false;
-	int rc;
=20
 #ifdef CONFIG_IXGBE_DCB
-	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
-	    !(data & ETH_FLAG_RXVLAN))
-		return -EINVAL;
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
+		features |=3D NETIF_F_HW_VLAN_RX;
 #endif
=20
-	need_reset =3D (data & ETH_FLAG_RXVLAN) !=3D
-		     (netdev->features & NETIF_F_HW_VLAN_RX);
-
-	if ((data & ETH_FLAG_RXHASH) &&
-	    !(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
-		return -EOPNOTSUPP;
-
-	rc =3D ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO | ETH_FLAG_NTU=
PLE |
-				  ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN |
-				  ETH_FLAG_RXHASH);
-	if (rc)
-		return rc;
-
-	/* if state changes we need to update adapter->flags and reset */
-	if ((adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) &&
-	    (!!(data & ETH_FLAG_LRO) !=3D
-	     !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) {
-		if ((data & ETH_FLAG_LRO) &&
-		    (!adapter->rx_itr_setting ||
-		     (adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE))) {
+	if (!adapter->rx_itr_setting ||
+	    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE) {
+		if (features & NETIF_F_LRO)
 			e_info(probe, "rx-usecs set too low, "
 				      "not enabling RSC.\n");
-		} else {
-			adapter->flags2 ^=3D IXGBE_FLAG2_RSC_ENABLED;
-			switch (adapter->hw.mac.type) {
-			case ixgbe_mac_82599EB:
-				need_reset =3D true;
-				break;
-			case ixgbe_mac_X540: {
-				int i;
-				for (i =3D 0; i < adapter->num_rx_queues; i++) {
-					struct ixgbe_ring *ring =3D
-					                  adapter->rx_ring[i];
-					if (adapter->flags2 &
-					    IXGBE_FLAG2_RSC_ENABLED) {
-						ixgbe_configure_rscctl(adapter,
-						                       ring);
-					} else {
-						ixgbe_clear_rscctl(adapter,
-						                   ring);
-					}
-				}
+		features &=3D ~NETIF_F_LRO;
+	}
+
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
+		features &=3D ~NETIF_F_RXHASH;
+
+	return features;
+}
+
+int ixgbe_set_features(struct net_device *netdev, u32 features)
+{
+	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
+	u32 changed =3D netdev->features ^ features;
+	bool need_reset =3D !!(changed & NETIF_F_HW_VLAN_RX);
+
+	if (features & NETIF_F_RXCSUM)
+		adapter->flags |=3D IXGBE_FLAG_RX_CSUM_ENABLED;
+	else
+		adapter->flags &=3D ~IXGBE_FLAG_RX_CSUM_ENABLED;
+
+	/* if state changes we need to update adapter->flags and reset */
+	if (changed & NETIF_F_LRO) {
+		adapter->flags2 ^=3D IXGBE_FLAG2_RSC_ENABLED;
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82599EB:
+			need_reset =3D true;
+			break;
+		case ixgbe_mac_X540: {
+			int i;
+			for (i =3D 0; i < adapter->num_rx_queues; i++) {
+				struct ixgbe_ring *ring =3D adapter->rx_ring[i];
+				if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
+					ixgbe_configure_rscctl(adapter, ring);
+				else
+					ixgbe_clear_rscctl(adapter, ring);
 			}
-				break;
-			default:
-				break;
+			break;
 			}
+		default:
+			break;
 		}
 	}
=20
@@ -2310,20 +2249,17 @@ static int ixgbe_set_flags(struct net_device *n=
etdev, u32 data)
 	 * Check if Flow Director n-tuple support was enabled or disabled.  I=
f
 	 * the state changed, we need to reset.
 	 */
-	if ((adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) &&
-	    (!(data & ETH_FLAG_NTUPLE))) {
-		/* turn off Flow Director perfect, set hash and reset */
-		adapter->flags &=3D ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-		adapter->flags |=3D IXGBE_FLAG_FDIR_HASH_CAPABLE;
+	if (changed & NETIF_F_NTUPLE) {
+		if (features & NETIF_F_NTUPLE) {
+			/* turn off Flow Director hash, enable perfect and reset */
+			adapter->flags &=3D ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+			adapter->flags |=3D IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+		} else {
+			/* turn off Flow Director perfect, set hash and reset */
+			adapter->flags &=3D ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+			adapter->flags |=3D IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		}
 		need_reset =3D true;
-	} else if ((!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) &&
-	           (data & ETH_FLAG_NTUPLE)) {
-		/* turn off Flow Director hash, enable perfect and reset */
-		adapter->flags &=3D ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-		adapter->flags |=3D IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-		need_reset =3D true;
-	} else {
-		/* no state change */
 	}
=20
 	if (need_reset) {
@@ -2487,16 +2423,8 @@ static const struct ethtool_ops ixgbe_ethtool_op=
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
 	.set_phys_id            =3D ixgbe_set_phys_id,
@@ -2504,8 +2432,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops=
 =3D {
 	.get_ethtool_stats      =3D ixgbe_get_ethtool_stats,
 	.get_coalesce           =3D ixgbe_get_coalesce,
 	.set_coalesce           =3D ixgbe_set_coalesce,
-	.get_flags              =3D ethtool_op_get_flags,
-	.set_flags              =3D ixgbe_set_flags,
 	.set_rx_ntuple          =3D ixgbe_set_rx_ntuple,
 };
=20
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index 06cfaf3..1a77310 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7199,6 +7199,8 @@ static struct rtnl_link_stats64 *ixgbe_get_stats6=
4(struct net_device *netdev,
 	return stats;
 }
=20
+u32 ixgbe_fix_features(struct net_device *netdev, u32 features);
+int ixgbe_set_features(struct net_device *netdev, u32 features);
=20
 static const struct net_device_ops ixgbe_netdev_ops =3D {
 	.ndo_open		=3D ixgbe_open,
@@ -7233,6 +7235,8 @@ static const struct net_device_ops ixgbe_netdev_o=
ps =3D {
 	.ndo_fcoe_disable =3D ixgbe_fcoe_disable,
 	.ndo_fcoe_get_wwn =3D ixgbe_fcoe_get_wwn,
 #endif /* IXGBE_FCOE */
+	.ndo_fix_features =3D ixgbe_fix_features,
+	.ndo_set_features =3D ixgbe_set_features,
 };
=20
 static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
@@ -7496,27 +7500,32 @@ static int __devinit ixgbe_probe(struct pci_dev=
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
+			   NETIF_F_RXCSUM |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
+			   NETIF_F_NTUPLE |
+			   NETIF_F_RXHASH;
+
+	if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)
+		netdev->hw_features |=3D NETIF_F_LRO;
+
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		netdev->hw_features |=3D NETIF_F_SCTP_CSUM;
+		break;
+	default:
+		break;
+	}
+
+	netdev->features =3D netdev->hw_features |
 			   NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->features |=3D NETIF_F_IPV6_CSUM;
-	netdev->features |=3D NETIF_F_TSO;
-	netdev->features |=3D NETIF_F_TSO6;
-	netdev->features |=3D NETIF_F_GRO;
-	netdev->features |=3D NETIF_F_RXHASH;
-
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		netdev->features |=3D NETIF_F_SCTP_CSUM;
-		break;
-	default:
-		break;
-	}
-
 	netdev->vlan_features |=3D NETIF_F_TSO;
 	netdev->vlan_features |=3D NETIF_F_TSO6;
 	netdev->vlan_features |=3D NETIF_F_IP_CSUM;
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtoo=
l.c
index deee375..e1d9e3b 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -117,44 +117,6 @@ static int ixgbevf_get_settings(struct net_device =
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
@@ -720,16 +682,8 @@ static struct ethtool_ops ixgbevf_ethtool_ops =3D =
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
index b2c5ecd..8c2be31 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3248,6 +3248,19 @@ static void ixgbevf_shutdown(struct pci_dev *pde=
v)
 	pci_disable_device(pdev);
 }
=20
+static int ixgbevf_set_features(struct net_device *netdev, u32 feature=
s)
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
@@ -3261,6 +3274,7 @@ static const struct net_device_ops ixgbe_netdev_o=
ps =3D {
 	.ndo_vlan_rx_register	=3D &ixgbevf_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	=3D &ixgbevf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	=3D &ixgbevf_vlan_rx_kill_vid,
+	.ndo_set_features       =3D ixgbevf_set_features,
 };
=20
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
@@ -3373,16 +3387,18 @@ static int __devinit ixgbevf_probe(struct pci_d=
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
1.7.2.5

