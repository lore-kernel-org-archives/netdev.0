From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] e1000: convert to ndo_fix_features
Date: Sun, 19 Jun 2011 17:58:22 -0700
Message-ID: <1308531518-17298-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10991 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232Ab1FTA7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 20:59:01 -0400
In-Reply-To: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Private rx_csum flags are now duplicate of netdev->features & NETIF_F_R=
XCSUM.
Removing this needs deeper surgery.

Things noticed:
 - RX csum disabled by default
 - HW VLAN acceleration probably can be toggled, but it's left as is
 - the resets on RX csum offload change can probably be avoided
 - there is A LOT of copy-and-pasted code here

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_ethtool.c |   69 -----------------------------=
--------
 drivers/net/e1000/e1000_main.c    |   30 ++++++++++++++--
 2 files changed, 26 insertions(+), 73 deletions(-)

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
--=20
1.7.5.4

