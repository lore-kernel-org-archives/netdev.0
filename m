From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] igbvf: convert to ndo_fix_features
Date: Thu, 13 Oct 2011 23:21:28 -0700
Message-ID: <1318573288-18286-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8874 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753704Ab1JNGVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 02:21:34 -0400
In-Reply-To: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/ethtool.c |   57 --------------------=
--------
 drivers/net/ethernet/intel/igbvf/netdev.c  |   25 ++++++++++--
 2 files changed, 20 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/e=
thernet/intel/igbvf/ethtool.c
index 0ee8b68..2c25858 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
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
@@ -507,14 +458,6 @@ static const struct ethtool_ops igbvf_ethtool_ops =
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
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/et=
hernet/intel/igbvf/netdev.c
index b3d760b..32b3044 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2530,6 +2530,18 @@ static void igbvf_print_device_info(struct igbvf=
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
@@ -2545,6 +2557,7 @@ static const struct net_device_ops igbvf_netdev_o=
ps =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller            =3D igbvf_netpoll,
 #endif
+	.ndo_set_features               =3D igbvf_set_features,
 };
=20
 /**
@@ -2652,16 +2665,18 @@ static int __devinit igbvf_probe(struct pci_dev=
 *pdev,
=20
 	adapter->bd_number =3D cards_found++;
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
-
 	if (pci_using_dac)
 		netdev->features |=3D NETIF_F_HIGHDMA;
=20
--=20
1.7.6.4
