From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] igb: convert to ndo_fix_features
Date: Sun, 19 Jun 2011 17:58:23 -0700
Message-ID: <1308531518-17298-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13160 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500Ab1FTA7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 20:59:01 -0400
In-Reply-To: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Private rx_csum flags are now duplicate of netdev->features & NETIF_F_R=
XCSUM.
Removing this needs deeper surgery.

Things noticed:
 - HW VLAN acceleration probably can be toggled, but it's left as is
 - the resets on RX csum offload change can probably be avoided
 - there is A LOT of copy-and-pasted code here

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_ethtool.c |   67 ---------------------------------=
--------
 drivers/net/igb/igb_main.c    |   33 ++++++++++++++++----
 2 files changed, 26 insertions(+), 74 deletions(-)

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
--=20
1.7.5.4

