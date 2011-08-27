From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] ixgbevf: convert to ndo_fix_features
Date: Sat, 27 Aug 2011 00:09:29 -0700
Message-ID: <1314428971-7676-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:65345 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab1H0HJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Aug 2011 03:09:36 -0400
In-Reply-To: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Private rx_csum flags are now duplicate of netdev->features & NETIF_F_R=
XCSUM.
Removing this needs deeper surgery.

Since ixgbevf doesn't change hardware state on RX csum enable/disable
its reset is avoided.

Things noticed:
 - HW VLAN acceleration probably can be toggled, but it's left as is
 - the resets on RX csum offload change can probably be avoided
 - there is A LOT of copy-and-pasted code here

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |   46 -------------=
--------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   25 +++++++++--
 2 files changed, 20 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net=
/ethernet/intel/ixgbevf/ethtool.c
index deee375..e1d9e3b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
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
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/driver=
s/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index bc12dd8..9896397 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3253,6 +3253,18 @@ static struct rtnl_link_stats64 *ixgbevf_get_sta=
ts(struct net_device *netdev,
 	return stats;
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
 static const struct net_device_ops ixgbe_netdev_ops =3D {
 	.ndo_open		=3D ixgbevf_open,
 	.ndo_stop		=3D ixgbevf_close,
@@ -3265,6 +3277,7 @@ static const struct net_device_ops ixgbe_netdev_o=
ps =3D {
 	.ndo_tx_timeout		=3D ixgbevf_tx_timeout,
 	.ndo_vlan_rx_add_vid	=3D ixgbevf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	=3D ixgbevf_vlan_rx_kill_vid,
+	.ndo_set_features	=3D ixgbevf_set_features,
 };
=20
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
@@ -3377,16 +3390,18 @@ static int __devinit ixgbevf_probe(struct pci_d=
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
1.7.6
