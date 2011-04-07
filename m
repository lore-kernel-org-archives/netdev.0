From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: atl*: convert to hw_features
Date: Thu,  7 Apr 2011 19:32:18 +0200 (CEST)
Message-ID: <20110407173218.1532213909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47706 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889Ab1DGRcV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 13:32:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Things left as they were:
 - atl1: is RX checksum really enabled?
 - atl2: copy-paste from atl1, with-errors-on-modify I presume
 - atl1c: there's a bug: MTU can't be changed if device is not up

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/atl1c/atl1c_ethtool.c |    8 --------
 drivers/net/atl1c/atl1c_main.c    |   23 ++++++++++++++---------
 drivers/net/atl1e/atl1e_ethtool.c |    3 ---
 drivers/net/atl1e/atl1e_main.c    |   12 ++++--------
 drivers/net/atlx/atl1.c           |   15 +++++----------
 drivers/net/atlx/atl2.c           |   14 +-------------
 6 files changed, 24 insertions(+), 51 deletions(-)

diff --git a/drivers/net/atl1c/atl1c_ethtool.c b/drivers/net/atl1c/atl1=
c_ethtool.c
index 7c52150..3af5a33 100644
--- a/drivers/net/atl1c/atl1c_ethtool.c
+++ b/drivers/net/atl1c/atl1c_ethtool.c
@@ -113,11 +113,6 @@ static int atl1c_set_settings(struct net_device *n=
etdev,
 	return 0;
 }
=20
-static u32 atl1c_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
 static u32 atl1c_get_msglevel(struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter =3D netdev_priv(netdev);
@@ -307,9 +302,6 @@ static const struct ethtool_ops atl1c_ethtool_ops =3D=
 {
 	.get_link               =3D ethtool_op_get_link,
 	.get_eeprom_len         =3D atl1c_get_eeprom_len,
 	.get_eeprom             =3D atl1c_get_eeprom,
-	.get_tx_csum            =3D atl1c_get_tx_csum,
-	.get_sg                 =3D ethtool_op_get_sg,
-	.set_sg                 =3D ethtool_op_set_sg,
 };
=20
 void atl1c_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_m=
ain.c
index 7d9d506..894d485 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -484,6 +484,15 @@ static void atl1c_set_rxbufsize(struct atl1c_adapt=
er *adapter,
 	adapter->rx_buffer_len =3D mtu > AT_RX_BUF_SIZE ?
 		roundup(mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN, 8) : AT_RX_BUF_SIZ=
E;
 }
+
+static u32 atl1c_fix_features(struct net_device *netdev, u32 features)
+{
+	if (netdev->mtu > MAX_TSO_FRAME_SIZE)
+		features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
+
+	return features;
+}
+
 /*
  * atl1c_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
@@ -510,14 +519,8 @@ static int atl1c_change_mtu(struct net_device *net=
dev, int new_mtu)
 		netdev->mtu =3D new_mtu;
 		adapter->hw.max_frame_size =3D new_mtu;
 		atl1c_set_rxbufsize(adapter, netdev);
-		if (new_mtu > MAX_TSO_FRAME_SIZE) {
-			adapter->netdev->features &=3D ~NETIF_F_TSO;
-			adapter->netdev->features &=3D ~NETIF_F_TSO6;
-		} else {
-			adapter->netdev->features |=3D NETIF_F_TSO;
-			adapter->netdev->features |=3D NETIF_F_TSO6;
-		}
 		atl1c_down(adapter);
+		netdev_update_features(netdev);
 		atl1c_up(adapter);
 		clear_bit(__AT_RESETTING, &adapter->flags);
 		if (adapter->hw.ctrl_flags & ATL1C_FPGA_VERSION) {
@@ -2585,6 +2588,7 @@ static const struct net_device_ops atl1c_netdev_o=
ps =3D {
 	.ndo_set_mac_address 	=3D atl1c_set_mac_addr,
 	.ndo_set_multicast_list =3D atl1c_set_multi,
 	.ndo_change_mtu		=3D atl1c_change_mtu,
+	.ndo_fix_features	=3D atl1c_fix_features,
 	.ndo_do_ioctl		=3D atl1c_ioctl,
 	.ndo_tx_timeout		=3D atl1c_tx_timeout,
 	.ndo_get_stats		=3D atl1c_get_stats,
@@ -2605,12 +2609,13 @@ static int atl1c_init_netdev(struct net_device =
*netdev, struct pci_dev *pdev)
 	atl1c_set_ethtool_ops(netdev);
=20
 	/* TODO: add when ready */
-	netdev->features =3D	NETIF_F_SG	   |
+	netdev->hw_features =3D	NETIF_F_SG	   |
 				NETIF_F_HW_CSUM	   |
 				NETIF_F_HW_VLAN_TX |
-				NETIF_F_HW_VLAN_RX |
 				NETIF_F_TSO	   |
 				NETIF_F_TSO6;
+	netdev->features =3D	netdev->hw_features |
+				NETIF_F_HW_VLAN_RX;
 	return 0;
 }
=20
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1=
e_ethtool.c
index 1209297..4778374 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -382,9 +382,6 @@ static const struct ethtool_ops atl1e_ethtool_ops =3D=
 {
 	.get_eeprom_len         =3D atl1e_get_eeprom_len,
 	.get_eeprom             =3D atl1e_get_eeprom,
 	.set_eeprom             =3D atl1e_set_eeprom,
-	.set_tx_csum            =3D ethtool_op_set_tx_hw_csum,
-	.set_sg                 =3D ethtool_op_set_sg,
-	.set_tso                =3D ethtool_op_set_tso,
 };
=20
 void atl1e_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_m=
ain.c
index 1ff001a..c05b2e7 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1927,11 +1927,7 @@ void atl1e_down(struct atl1e_adapter *adapter)
 	 * reschedule our watchdog timer */
 	set_bit(__AT_DOWN, &adapter->flags);
=20
-#ifdef NETIF_F_LLTX
 	netif_stop_queue(netdev);
-#else
-	netif_tx_disable(netdev);
-#endif
=20
 	/* reset MAC to disable all RX/TX */
 	atl1e_reset_hw(&adapter->hw);
@@ -2223,10 +2219,10 @@ static int atl1e_init_netdev(struct net_device =
*netdev, struct pci_dev *pdev)
 	netdev->watchdog_timeo =3D AT_TX_WATCHDOG;
 	atl1e_set_ethtool_ops(netdev);
=20
-	netdev->features =3D NETIF_F_SG | NETIF_F_HW_CSUM |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	netdev->features |=3D NETIF_F_LLTX;
-	netdev->features |=3D NETIF_F_TSO;
+	netdev->hw_features =3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO |
+		NETIF_F_HW_VLAN_TX;
+	netdev->features =3D netdev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_LLTX;
=20
 	return 0;
 }
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index e973d05..98334a1 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2986,6 +2986,11 @@ static int __devinit atl1_probe(struct pci_dev *=
pdev,
 	netdev->features |=3D NETIF_F_SG;
 	netdev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
=20
+	netdev->hw_features =3D NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_TSO;
+
+	/* is this valid? see atl1_setup_mac_ctrl() */
+	netdev->features |=3D NETIF_F_RXCSUM;
+
 	/*
 	 * patch for some L1 of old version,
 	 * the final version of L1 may not need these
@@ -3595,12 +3600,6 @@ static int atl1_set_pauseparam(struct net_device=
 *netdev,
 	return 0;
 }
=20
-/* FIXME: is this right? -- CHS */
-static u32 atl1_get_rx_csum(struct net_device *netdev)
-{
-	return 1;
-}
-
 static void atl1_get_strings(struct net_device *netdev, u32 stringset,
 	u8 *data)
 {
@@ -3668,13 +3667,9 @@ static const struct ethtool_ops atl1_ethtool_ops=
 =3D {
 	.set_ringparam		=3D atl1_set_ringparam,
 	.get_pauseparam		=3D atl1_get_pauseparam,
 	.set_pauseparam		=3D atl1_set_pauseparam,
-	.get_rx_csum		=3D atl1_get_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
 	.get_link		=3D ethtool_op_get_link,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_strings		=3D atl1_get_strings,
 	.nway_reset		=3D atl1_nway_reset,
 	.get_ethtool_stats	=3D atl1_get_ethtool_stats,
 	.get_sset_count		=3D atl1_get_sset_count,
-	.set_tso		=3D ethtool_op_set_tso,
 };
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 937ef1a..02761dd 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1411,9 +1411,8 @@ static int __devinit atl2_probe(struct pci_dev *p=
dev,
=20
 	err =3D -EIO;
=20
-#ifdef NETIF_F_HW_VLAN_TX
+	netdev->hw_features =3D NETIF_F_SG;
 	netdev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
-#endif
=20
 	/* Init PHY as early as possible due to power saving issue  */
 	atl2_phy_init(&adapter->hw);
@@ -1840,11 +1839,6 @@ static int atl2_set_settings(struct net_device *=
netdev,
 	return 0;
 }
=20
-static u32 atl2_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
 static u32 atl2_get_msglevel(struct net_device *netdev)
 {
 	return 0;
@@ -2112,12 +2106,6 @@ static const struct ethtool_ops atl2_ethtool_ops=
 =3D {
 	.get_eeprom_len		=3D atl2_get_eeprom_len,
 	.get_eeprom		=3D atl2_get_eeprom,
 	.set_eeprom		=3D atl2_set_eeprom,
-	.get_tx_csum		=3D atl2_get_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
-#ifdef NETIF_F_TSO
-	.get_tso		=3D ethtool_op_get_tso,
-#endif
 };
=20
 static void atl2_set_ethtool_ops(struct net_device *netdev)
--=20
1.7.2.5

