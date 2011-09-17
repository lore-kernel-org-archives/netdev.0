From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgb: convert to ndo_fix_features
Date: Fri, 16 Sep 2011 19:15:42 -0700
Message-ID: <1316225752-1709-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30296 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab1IQCP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:15:56 -0400
In-Reply-To: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Private rx_csum flags are now duplicate of netdev->features & NETIF_F_R=
XCSUM.
Removing this needs deeper surgery.

Things noticed:
 - ixgb has RX csum disabled by default
 - HW VLAN acceleration probably can be toggled, but it's left as is
 - the resets on RX csum offload change can probably be avoided
 - there is A LOT of copy-and-pasted code here

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb.h         |    2 +
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c |   59 +---------------=
--------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c    |   31 +++++++++++-
 3 files changed, 31 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb.h b/drivers/net/ether=
net/intel/ixgb/ixgb.h
index 49e8408..cb23448 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb.h
+++ b/drivers/net/ethernet/intel/ixgb/ixgb.h
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
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/n=
et/ethernet/intel/ixgb/ixgb_ethtool.c
index 6da890b..fdb30cc 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
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
@@ -736,14 +685,8 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
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
 	.set_phys_id =3D ixgb_set_phys_id,
 	.get_sset_count =3D ixgb_get_sset_count,
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/=
ethernet/intel/ixgb/ixgb_main.c
index c8b9c90..b8fb163 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -325,6 +325,28 @@ ixgb_reset(struct ixgb_adapter *adapter)
 	}
 }
=20
+static int
+ixgb_set_features(struct net_device *netdev, u32 features)
+{
+	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
+	u32 changed =3D features ^ netdev->features;
+
+	if (!(changed & NETIF_F_RXCSUM))
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
+
 static const struct net_device_ops ixgb_netdev_ops =3D {
 	.ndo_open 		=3D ixgb_open,
 	.ndo_stop		=3D ixgb_close,
@@ -340,6 +362,7 @@ static const struct net_device_ops ixgb_netdev_ops =
=3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D ixgb_netpoll,
 #endif
+	.ndo_set_features       =3D ixgb_set_features,
 };
=20
 /**
@@ -439,12 +462,14 @@ ixgb_probe(struct pci_dev *pdev, const struct pci=
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
--=20
1.7.6
