From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/9] vmxnet3: convert to 64 bit stats interface
Date: Wed, 08 Jun 2011 17:53:57 -0700
Message-ID: <20110609005417.324633042@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com
To: "David S. Miller" <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664Ab1FIBQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:42 -0400
Content-Disposition: inline; filename=vmxnet3-stats64.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert vmxnet3 driver to 64 bit statistics interface.
This driver was already counting packet per queue in a 64 bit value so not
a huge change. Eliminate unused old net_device_stats structure.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/vmxnet3/vmxnet3_drv.c	2011-06-04 22:01:31.932389206 +0900
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c	2011-06-07 19:50:23.189420166 +0900
@@ -2864,7 +2864,7 @@ vmxnet3_probe_device(struct pci_dev *pde
 		.ndo_set_mac_address = vmxnet3_set_mac_addr,
 		.ndo_change_mtu = vmxnet3_change_mtu,
 		.ndo_set_features = vmxnet3_set_features,
-		.ndo_get_stats = vmxnet3_get_stats,
+		.ndo_get_stats64 = vmxnet3_get_stats64,
 		.ndo_tx_timeout = vmxnet3_tx_timeout,
 		.ndo_set_multicast_list = vmxnet3_set_mc,
 		.ndo_vlan_rx_register = vmxnet3_vlan_rx_register,
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c	2011-06-04 21:54:27.110282630 +0900
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c	2011-06-07 20:13:34.492319266 +0900
@@ -113,15 +113,15 @@ vmxnet3_global_stats[] = {
 };
 
 
-struct net_device_stats *
-vmxnet3_get_stats(struct net_device *netdev)
+struct rtnl_link_stats64 *
+vmxnet3_get_stats64(struct net_device *netdev,
+		   struct rtnl_link_stats64 *stats)
 {
 	struct vmxnet3_adapter *adapter;
 	struct vmxnet3_tq_driver_stats *drvTxStats;
 	struct vmxnet3_rq_driver_stats *drvRxStats;
 	struct UPT1_TxStats *devTxStats;
 	struct UPT1_RxStats *devRxStats;
-	struct net_device_stats *net_stats = &netdev->stats;
 	unsigned long flags;
 	int i;
 
@@ -132,36 +132,36 @@ vmxnet3_get_stats(struct net_device *net
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_STATS);
 	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
-	memset(net_stats, 0, sizeof(*net_stats));
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		devTxStats = &adapter->tqd_start[i].stats;
 		drvTxStats = &adapter->tx_queue[i].stats;
-		net_stats->tx_packets += devTxStats->ucastPktsTxOK +
-					devTxStats->mcastPktsTxOK +
-					devTxStats->bcastPktsTxOK;
-		net_stats->tx_bytes += devTxStats->ucastBytesTxOK +
-				      devTxStats->mcastBytesTxOK +
-				      devTxStats->bcastBytesTxOK;
-		net_stats->tx_errors += devTxStats->pktsTxError;
-		net_stats->tx_dropped += drvTxStats->drop_total;
+		stats->tx_packets += devTxStats->ucastPktsTxOK +
+				     devTxStats->mcastPktsTxOK +
+				     devTxStats->bcastPktsTxOK;
+		stats->tx_bytes += devTxStats->ucastBytesTxOK +
+				   devTxStats->mcastBytesTxOK +
+				   devTxStats->bcastBytesTxOK;
+		stats->tx_errors += devTxStats->pktsTxError;
+		stats->tx_dropped += drvTxStats->drop_total;
 	}
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		devRxStats = &adapter->rqd_start[i].stats;
 		drvRxStats = &adapter->rx_queue[i].stats;
-		net_stats->rx_packets += devRxStats->ucastPktsRxOK +
-					devRxStats->mcastPktsRxOK +
-					devRxStats->bcastPktsRxOK;
-
-		net_stats->rx_bytes += devRxStats->ucastBytesRxOK +
-				      devRxStats->mcastBytesRxOK +
-				      devRxStats->bcastBytesRxOK;
-
-		net_stats->rx_errors += devRxStats->pktsRxError;
-		net_stats->rx_dropped += drvRxStats->drop_total;
-		net_stats->multicast +=  devRxStats->mcastPktsRxOK;
+		stats->rx_packets += devRxStats->ucastPktsRxOK +
+				     devRxStats->mcastPktsRxOK +
+				     devRxStats->bcastPktsRxOK;
+
+		stats->rx_bytes += devRxStats->ucastBytesRxOK +
+				   devRxStats->mcastBytesRxOK +
+				   devRxStats->bcastBytesRxOK;
+
+		stats->rx_errors += devRxStats->pktsRxError;
+		stats->rx_dropped += drvRxStats->drop_total;
+		stats->multicast +=  devRxStats->mcastPktsRxOK;
 	}
-	return net_stats;
+
+	return stats;
 }
 
 static int
--- a/drivers/net/vmxnet3/vmxnet3_int.h	2011-06-04 22:02:03.048543506 +0900
+++ b/drivers/net/vmxnet3/vmxnet3_int.h	2011-06-07 19:54:22.890608779 +0900
@@ -323,7 +323,6 @@ struct vmxnet3_adapter {
 	struct Vmxnet3_TxQueueDesc	*tqd_start;     /* all tx queue desc */
 	struct Vmxnet3_RxQueueDesc	*rqd_start;	/* all rx queue desc */
 	struct net_device		*netdev;
-	struct net_device_stats		net_stats;
 	struct pci_dev			*pdev;
 
 	u8			__iomem *hw_addr0; /* for BAR 0 */
@@ -407,7 +406,9 @@ vmxnet3_create_queues(struct vmxnet3_ada
 		      u32 tx_ring_size, u32 rx_ring_size, u32 rx_ring2_size);
 
 extern void vmxnet3_set_ethtool_ops(struct net_device *netdev);
-extern struct net_device_stats *vmxnet3_get_stats(struct net_device *netdev);
+
+extern struct rtnl_link_stats64 *
+vmxnet3_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats);
 
 extern char vmxnet3_driver_name[];
 #endif


