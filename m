From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: pch_gbe: convert to hw_features
Date: Tue, 19 Apr 2011 13:56:12 +0200 (CEST)
Message-ID: <20110419115612.C83881389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55611 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407Ab1DSL4O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 07:56:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also fixes bug in xmit path, where TX checksum offload state was u=
sed
instead of skb->ip_summed to decide if the offload was needed.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/pch_gbe/pch_gbe.h         |    4 --
 drivers/net/pch_gbe/pch_gbe_ethtool.c |   54 -------------------------=
--------
 drivers/net/pch_gbe/pch_gbe_main.c    |   42 +++++++++++++++++++------
 drivers/net/pch_gbe/pch_gbe_param.c   |   16 ++++++----
 4 files changed, 42 insertions(+), 74 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/pch_gbe/pch_gb=
e.h
index bf126e7..59fac77 100644
--- a/drivers/net/pch_gbe/pch_gbe.h
+++ b/drivers/net/pch_gbe/pch_gbe.h
@@ -597,8 +597,6 @@ struct pch_gbe_hw_stats {
  * @rx_ring:		Pointer of Rx descriptor ring structure
  * @rx_buffer_len:	Receive buffer length
  * @tx_queue_len:	Transmit queue length
- * @rx_csum:		Receive TCP/IP checksum enable/disable
- * @tx_csum:		Transmit TCP/IP checksum enable/disable
  * @have_msi:		PCI MSI mode flag
  */
=20
@@ -623,8 +621,6 @@ struct pch_gbe_adapter {
 	struct pch_gbe_rx_ring *rx_ring;
 	unsigned long rx_buffer_len;
 	unsigned long tx_queue_len;
-	bool rx_csum;
-	bool tx_csum;
 	bool have_msi;
 };
=20
diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gb=
e/pch_gbe_ethtool.c
index d2174a4..c35d105 100644
--- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
@@ -434,57 +434,6 @@ static int pch_gbe_set_pauseparam(struct net_devic=
e *netdev,
 }
=20
 /**
- * pch_gbe_get_rx_csum - Report whether receive checksums are turned o=
n or off
- * @netdev:  Network interface device structure
- * Returns
- *	true(1):  Checksum On
- *	false(0): Checksum Off
- */
-static u32 pch_gbe_get_rx_csum(struct net_device *netdev)
-{
-	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
-
-	return adapter->rx_csum;
-}
-
-/**
- * pch_gbe_set_rx_csum - Turn receive checksum on or off
- * @netdev:  Network interface device structure
- * @data:    Checksum On[true] or Off[false]
- * Returns
- *	0:			Successful.
- *	Negative value:		Failed.
- */
-static int pch_gbe_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
-
-	adapter->rx_csum =3D data;
-	if ((netif_running(netdev)))
-		pch_gbe_reinit_locked(adapter);
-	else
-		pch_gbe_reset(adapter);
-
-	return 0;
-}
-
-/**
- * pch_gbe_set_tx_csum - Turn transmit checksums on or off
- * @netdev: Network interface device structure
- * @data:   Checksum on[true] or off[false]
- * Returns
- *	0:			Successful.
- *	Negative value:		Failed.
- */
-static int pch_gbe_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
-
-	adapter->tx_csum =3D data;
-	return ethtool_op_set_tx_ipv6_csum(netdev, data);
-}
-
-/**
  * pch_gbe_get_strings - Return a set of strings that describe the req=
uested
  *			 objects
  * @netdev:    Network interface device structure
@@ -554,9 +503,6 @@ static const struct ethtool_ops pch_gbe_ethtool_ops=
 =3D {
 	.set_ringparam =3D pch_gbe_set_ringparam,
 	.get_pauseparam =3D pch_gbe_get_pauseparam,
 	.set_pauseparam =3D pch_gbe_set_pauseparam,
-	.get_rx_csum =3D pch_gbe_get_rx_csum,
-	.set_rx_csum =3D pch_gbe_set_rx_csum,
-	.set_tx_csum =3D pch_gbe_set_tx_csum,
 	.get_strings =3D pch_gbe_get_strings,
 	.get_ethtool_stats =3D pch_gbe_get_ethtool_stats,
 	.get_sset_count =3D pch_gbe_get_sset_count,
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/p=
ch_gbe_main.c
index 2ef2f9c..4cc9872 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -656,6 +656,7 @@ static void pch_gbe_configure_tx(struct pch_gbe_ada=
pter *adapter)
  */
 static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
 {
+	struct net_device *netdev =3D adapter->netdev;
 	struct pch_gbe_hw *hw =3D &adapter->hw;
 	u32 rx_mode, tcpip;
=20
@@ -666,7 +667,7 @@ static void pch_gbe_setup_rctl(struct pch_gbe_adapt=
er *adapter)
=20
 	tcpip =3D ioread32(&hw->reg->TCPIP_ACC);
=20
-	if (adapter->rx_csum) {
+	if (netdev->features & NETIF_F_RXCSUM) {
 		tcpip &=3D ~PCH_GBE_RX_TCPIPACC_OFF;
 		tcpip |=3D PCH_GBE_RX_TCPIPACC_EN;
 	} else {
@@ -950,7 +951,7 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter=
 *adapter,
 	frame_ctrl =3D 0;
 	if (unlikely(skb->len < PCH_GBE_SHORT_PKT))
 		frame_ctrl |=3D PCH_GBE_TXD_CTRL_APAD;
-	if (unlikely(!adapter->tx_csum))
+	if (skb->ip_summed =3D=3D CHECKSUM_NONE)
 		frame_ctrl |=3D PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
=20
 	/* Performs checksum processing */
@@ -958,7 +959,7 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter=
 *adapter,
 	 * It is because the hardware accelerator does not support a checksum=
,
 	 * when the received data size is less than 64 bytes.
 	 */
-	if ((skb->len < PCH_GBE_SHORT_PKT) && (adapter->tx_csum)) {
+	if (skb->len < PCH_GBE_SHORT_PKT && skb->ip_summed !=3D CHECKSUM_NONE=
) {
 		frame_ctrl |=3D PCH_GBE_TXD_CTRL_APAD |
 			      PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
 		if (skb->protocol =3D=3D htons(ETH_P_IP)) {
@@ -1426,7 +1427,7 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			length =3D (rx_desc->rx_words_eob) - 3;
=20
 			/* Decide the data conversion method */
-			if (!adapter->rx_csum) {
+			if (!(netdev->features & NETIF_F_RXCSUM)) {
 				/* [Header:14][payload] */
 				if (NET_IP_ALIGN) {
 					/* Because alignment differs,
@@ -2030,6 +2031,29 @@ static int pch_gbe_change_mtu(struct net_device =
*netdev, int new_mtu)
 }
=20
 /**
+ * pch_gbe_set_features - Reset device after features changed
+ * @netdev:   Network interface device structure
+ * @features:  New features
+ * Returns
+ *	0:		HW state updated successfully
+ */
+static int pch_gbe_set_features(struct net_device *netdev, u32 feature=
s)
+{
+	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
+	u32 changed =3D features ^ netdev->features;
+
+	if (!(changed & NETIF_F_RXCSUM))
+		return 0;
+
+	if (netif_running(netdev))
+		pch_gbe_reinit_locked(adapter);
+	else
+		pch_gbe_reset(adapter);
+
+	return 0;
+}
+
+/**
  * pch_gbe_ioctl - Controls register through a MII interface
  * @netdev:   Network interface device structure
  * @ifr:      Pointer to ifr structure
@@ -2129,6 +2153,7 @@ static const struct net_device_ops pch_gbe_netdev=
_ops =3D {
 	.ndo_set_mac_address =3D pch_gbe_set_mac,
 	.ndo_tx_timeout =3D pch_gbe_tx_timeout,
 	.ndo_change_mtu =3D pch_gbe_change_mtu,
+	.ndo_set_features =3D pch_gbe_set_features,
 	.ndo_do_ioctl =3D pch_gbe_ioctl,
 	.ndo_set_multicast_list =3D &pch_gbe_set_multi,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2334,7 +2359,9 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	netdev->watchdog_timeo =3D PCH_GBE_WATCHDOG_PERIOD;
 	netif_napi_add(netdev, &adapter->napi,
 		       pch_gbe_napi_poll, PCH_GBE_RX_WEIGHT);
-	netdev->features =3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_GR=
O;
+	netdev->hw_features =3D NETIF_F_RXCSUM |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	netdev->features =3D netdev->hw_features;
 	pch_gbe_set_ethtool_ops(netdev);
=20
 	pch_gbe_mac_load_mac_addr(&adapter->hw);
@@ -2373,11 +2400,6 @@ static int pch_gbe_probe(struct pci_dev *pdev,
=20
 	pch_gbe_check_options(adapter);
=20
-	if (adapter->tx_csum)
-		netdev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	else
-		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wake_up_evt =3D PCH_GBE_WL_INIT_SETTING;
 	dev_info(&pdev->dev, "MAC address : %pM\n", netdev->dev_addr);
diff --git a/drivers/net/pch_gbe/pch_gbe_param.c b/drivers/net/pch_gbe/=
pch_gbe_param.c
index ef0996a..5b5d90a 100644
--- a/drivers/net/pch_gbe/pch_gbe_param.c
+++ b/drivers/net/pch_gbe/pch_gbe_param.c
@@ -426,6 +426,8 @@ full_duplex_only:
 void pch_gbe_check_options(struct pch_gbe_adapter *adapter)
 {
 	struct pch_gbe_hw *hw =3D &adapter->hw;
+	struct net_device *dev =3D adapter->netdev;
+	int val;
=20
 	{ /* Transmit Descriptor Count */
 		static const struct pch_gbe_option opt =3D {
@@ -466,9 +468,10 @@ void pch_gbe_check_options(struct pch_gbe_adapter =
*adapter)
 			.err  =3D "defaulting to Enabled",
 			.def  =3D PCH_GBE_DEFAULT_RX_CSUM
 		};
-		adapter->rx_csum =3D XsumRX;
-		pch_gbe_validate_option((int *)(&adapter->rx_csum),
-					&opt, adapter);
+		val =3D XsumRX;
+		pch_gbe_validate_option(&val, &opt, adapter);
+		if (!val)
+			dev->features &=3D ~NETIF_F_RXCSUM;
 	}
 	{ /* Checksum Offload Enable/Disable */
 		static const struct pch_gbe_option opt =3D {
@@ -477,9 +480,10 @@ void pch_gbe_check_options(struct pch_gbe_adapter =
*adapter)
 			.err  =3D "defaulting to Enabled",
 			.def  =3D PCH_GBE_DEFAULT_TX_CSUM
 		};
-		adapter->tx_csum =3D XsumTX;
-		pch_gbe_validate_option((int *)(&adapter->tx_csum),
-						&opt, adapter);
+		val =3D XsumTX;
+		pch_gbe_validate_option(&val, &opt, adapter);
+		if (!val)
+			dev->features &=3D ~NETIF_F_ALL_CSUM;
 	}
 	{ /* Flow Control */
 		static const struct pch_gbe_option opt =3D {
--=20
1.7.2.5

