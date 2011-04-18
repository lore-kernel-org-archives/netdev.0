From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: vmxnet3: convert to hw_features
Date: Tue, 19 Apr 2011 01:31:21 +0200 (CEST)
Message-ID: <20110418233121.AEC4913A68@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46027 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753510Ab1DRXbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 19:31:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also removes private feature flags that were always set to true.

You may want to move vmxnet3_set_features() to vmxnet3_drv.c as a follo=
wing
cleanup.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/vmxnet3/vmxnet3_drv.c     |   40 +++++++-------------
 drivers/net/vmxnet3/vmxnet3_ethtool.c |   67 +++++--------------------=
-------
 drivers/net/vmxnet3/vmxnet3_int.h     |    7 +--
 3 files changed, 28 insertions(+), 86 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vm=
xnet3_drv.c
index 0d47c3a..7a494f7 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1082,7 +1082,7 @@ vmxnet3_rx_csum(struct vmxnet3_adapter *adapter,
 		struct sk_buff *skb,
 		union Vmxnet3_GenericDesc *gdesc)
 {
-	if (!gdesc->rcd.cnc && adapter->rxcsum) {
+	if (!gdesc->rcd.cnc && adapter->netdev->features & NETIF_F_RXCSUM) {
 		/* typical case: TCP/UDP over IP and both csums are correct */
 		if ((le32_to_cpu(gdesc->dword[3]) & VMXNET3_RCD_CSUM_OK) =3D=3D
 							VMXNET3_RCD_CSUM_OK) {
@@ -2081,10 +2081,10 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adap=
ter *adapter)
 	devRead->misc.ddLen =3D cpu_to_le32(sizeof(struct vmxnet3_adapter));
=20
 	/* set up feature flags */
-	if (adapter->rxcsum)
+	if (adapter->netdev->features & NETIF_F_RXCSUM)
 		devRead->misc.uptFeatures |=3D UPT1_F_RXCSUM;
=20
-	if (adapter->lro) {
+	if (adapter->netdev->features & NETIF_F_LRO) {
 		devRead->misc.uptFeatures |=3D UPT1_F_LRO;
 		devRead->misc.maxNumRxSG =3D cpu_to_le16(1 + MAX_SKB_FRAGS);
 	}
@@ -2593,9 +2593,6 @@ vmxnet3_change_mtu(struct net_device *netdev, int=
 new_mtu)
 	if (new_mtu < VMXNET3_MIN_MTU || new_mtu > VMXNET3_MAX_MTU)
 		return -EINVAL;
=20
-	if (new_mtu > 1500 && !adapter->jumbo_frame)
-		return -EINVAL;
-
 	netdev->mtu =3D new_mtu;
=20
 	/*
@@ -2641,28 +2638,18 @@ vmxnet3_declare_features(struct vmxnet3_adapter=
 *adapter, bool dma64)
 {
 	struct net_device *netdev =3D adapter->netdev;
=20
-	netdev->features =3D NETIF_F_SG |
-		NETIF_F_HW_CSUM |
-		NETIF_F_HW_VLAN_TX |
-		NETIF_F_HW_VLAN_RX |
-		NETIF_F_HW_VLAN_FILTER |
-		NETIF_F_TSO |
-		NETIF_F_TSO6 |
-		NETIF_F_LRO;
-
-	printk(KERN_INFO "features: sg csum vlan jf tso tsoIPv6 lro");
-
-	adapter->rxcsum =3D true;
-	adapter->jumbo_frame =3D true;
-	adapter->lro =3D true;
-
-	if (dma64) {
+	netdev->hw_features =3D NETIF_F_SG | NETIF_F_RXCSUM |
+		NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_TX |
+		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_LRO;
+	if (dma64)
 		netdev->features |=3D NETIF_F_HIGHDMA;
-		printk(" highDMA");
-	}
+	netdev->vlan_features =3D netdev->hw_features & ~NETIF_F_HW_VLAN_TX;
+	netdev->features =3D netdev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->vlan_features =3D netdev->features;
-	printk("\n");
+	netdev_info(adapter->netdev,
+		"features: sg csum vlan jf tso tsoIPv6 lro%s\n",
+		dma64 ? " highDMA" : "");
 }
=20
=20
@@ -2874,6 +2861,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		.ndo_start_xmit =3D vmxnet3_xmit_frame,
 		.ndo_set_mac_address =3D vmxnet3_set_mac_addr,
 		.ndo_change_mtu =3D vmxnet3_change_mtu,
+		.ndo_set_features =3D vmxnet3_set_features,
 		.ndo_get_stats =3D vmxnet3_get_stats,
 		.ndo_tx_timeout =3D vmxnet3_tx_timeout,
 		.ndo_set_multicast_list =3D vmxnet3_set_mc,
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet=
3/vmxnet3_ethtool.c
index 51f2ef1..70c1ab9 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -33,40 +33,6 @@ struct vmxnet3_stat_desc {
 };
=20
=20
-static u32
-vmxnet3_get_rx_csum(struct net_device *netdev)
-{
-	struct vmxnet3_adapter *adapter =3D netdev_priv(netdev);
-	return adapter->rxcsum;
-}
-
-
-static int
-vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
-{
-	struct vmxnet3_adapter *adapter =3D netdev_priv(netdev);
-	unsigned long flags;
-
-	if (adapter->rxcsum !=3D val) {
-		adapter->rxcsum =3D val;
-		if (netif_running(netdev)) {
-			if (val)
-				adapter->shared->devRead.misc.uptFeatures |=3D
-				UPT1_F_RXCSUM;
-			else
-				adapter->shared->devRead.misc.uptFeatures &=3D
-				~UPT1_F_RXCSUM;
-
-			spin_lock_irqsave(&adapter->cmd_lock, flags);
-			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
-					       VMXNET3_CMD_UPDATE_FEATURE);
-			spin_unlock_irqrestore(&adapter->cmd_lock, flags);
-		}
-	}
-	return 0;
-}
-
-
 /* per tq stats maintained by the device */
 static const struct vmxnet3_stat_desc
 vmxnet3_tq_dev_stats[] =3D {
@@ -296,28 +262,27 @@ vmxnet3_get_strings(struct net_device *netdev, u3=
2 stringset, u8 *buf)
 	}
 }
=20
-static int
-vmxnet3_set_flags(struct net_device *netdev, u32 data)
+int vmxnet3_set_features(struct net_device *netdev, u32 features)
 {
 	struct vmxnet3_adapter *adapter =3D netdev_priv(netdev);
-	u8 lro_requested =3D (data & ETH_FLAG_LRO) =3D=3D 0 ? 0 : 1;
-	u8 lro_present =3D (netdev->features & NETIF_F_LRO) =3D=3D 0 ? 0 : 1;
 	unsigned long flags;
+	u32 changed =3D features ^ netdev->features;
=20
-	if (ethtool_invalid_flags(netdev, data, ETH_FLAG_LRO))
-		return -EINVAL;
+	if (changed & (NETIF_F_RXCSUM|NETIF_F_LRO)) {
+		if (features & NETIF_F_RXCSUM)
+			adapter->shared->devRead.misc.uptFeatures |=3D
+			UPT1_F_RXCSUM;
+		else
+			adapter->shared->devRead.misc.uptFeatures &=3D
+			~UPT1_F_RXCSUM;
=20
-	if (lro_requested ^ lro_present) {
-		/* toggle the LRO feature*/
-		netdev->features ^=3D NETIF_F_LRO;
-
-		/* update harware LRO capability accordingly */
-		if (lro_requested)
+		if (features & NETIF_F_LRO)
 			adapter->shared->devRead.misc.uptFeatures |=3D
 							UPT1_F_LRO;
 		else
 			adapter->shared->devRead.misc.uptFeatures &=3D
 							~UPT1_F_LRO;
+
 		spin_lock_irqsave(&adapter->cmd_lock, flags);
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 				       VMXNET3_CMD_UPDATE_FEATURE);
@@ -654,17 +619,7 @@ static struct ethtool_ops vmxnet3_ethtool_ops =3D =
{
 	.get_wol           =3D vmxnet3_get_wol,
 	.set_wol           =3D vmxnet3_set_wol,
 	.get_link          =3D ethtool_op_get_link,
-	.get_rx_csum       =3D vmxnet3_get_rx_csum,
-	.set_rx_csum       =3D vmxnet3_set_rx_csum,
-	.get_tx_csum       =3D ethtool_op_get_tx_csum,
-	.set_tx_csum       =3D ethtool_op_set_tx_hw_csum,
-	.get_sg            =3D ethtool_op_get_sg,
-	.set_sg            =3D ethtool_op_set_sg,
-	.get_tso           =3D ethtool_op_get_tso,
-	.set_tso           =3D ethtool_op_set_tso,
 	.get_strings       =3D vmxnet3_get_strings,
-	.get_flags	   =3D ethtool_op_get_flags,
-	.set_flags	   =3D vmxnet3_set_flags,
 	.get_sset_count	   =3D vmxnet3_get_sset_count,
 	.get_ethtool_stats =3D vmxnet3_get_ethtool_stats,
 	.get_ringparam     =3D vmxnet3_get_ringparam,
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vm=
xnet3_int.h
index fb5d245..8ba7b5f 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -329,10 +329,6 @@ struct vmxnet3_adapter {
 	u8			__iomem *hw_addr0; /* for BAR 0 */
 	u8			__iomem *hw_addr1; /* for BAR 1 */
=20
-	/* feature control */
-	bool				rxcsum;
-	bool				lro;
-	bool				jumbo_frame;
 #ifdef VMXNET3_RSS
 	struct UPT1_RSSConf		*rss_conf;
 	bool				rss;
@@ -404,6 +400,9 @@ void
 vmxnet3_rq_destroy_all(struct vmxnet3_adapter *adapter);
=20
 int
+vmxnet3_set_features(struct net_device *netdev, u32 features);
+
+int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
 		      u32 tx_ring_size, u32 rx_ring_size, u32 rx_ring2_size);
=20
--=20
1.7.2.5

