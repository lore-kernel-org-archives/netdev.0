From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 1/2] qlcnic: fix compiler warnings
Date: Sun, 18 Nov 2012 02:04:38 -0500
Message-ID: <1353222279-15736-2-git-send-email-sony.chacko@qlogic.com>
References: <1353222279-15736-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21927 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751451Ab2KRHWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Nov 2012 02:22:45 -0500
In-Reply-To: <1353222279-15736-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Fix the following warnings:

qlcnic_main.c: In function 'qlcnic_update_cmd_producer':
qlcnic_main.c:119:51: warning: unused parameter 'adapter' [-Wunused-parameter]
qlcnic_main.c:119: warning: unused parameter adapter
qlcnic_init.c: In function qlcnic_process_lro
qlcnic_init.c:1586: warning: unused parameter sds_ring
qlcnic_init.c: In function qlcnic_process_rcv_diag
qlcnic_init.c:1854: warning: unused parameter sds_ring
qlcnic_init.c: In function qlcnic_fetch_mac
qlcnic_init.c:1938: warning: unused parameter adapter

warning: 'pci_using_dac' may be used uninitialized in this function [-Wmaybe-uninitialized]
qlcnic_main.c:1569:10: note: 'pci_using_dac' was declared here

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |  5 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c  |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c   |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c | 16 ++++++----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 17 +++++++----------
 5 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index eaa1db9..8b3d3b3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1530,9 +1530,8 @@ int qlcnic_set_features(struct net_device *netdev, netdev_features_t features);
 int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
 int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
-void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_tx_ring *tx_ring);
-void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);
+void qlcnic_update_cmd_producer(struct qlcnic_host_tx_ring *);
+void qlcnic_fetch_mac(u32, u32, u8, u8 *);
 void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
 void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter);
 int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 2a179d0..bbd3b30 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -671,7 +671,7 @@ int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 	err = cmd.rsp.cmd;
 
 	if (err == QLCNIC_RCODE_SUCCESS)
-		qlcnic_fetch_mac(adapter, cmd.rsp.arg1, cmd.rsp.arg2, 0, mac);
+		qlcnic_fetch_mac(cmd.rsp.arg1, cmd.rsp.arg2, 0, mac);
 	else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get mac address%d\n", err);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 2a0c9dc..fc308c8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -350,7 +350,7 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 
 	tx_ring->producer = producer;
 
-	qlcnic_update_cmd_producer(adapter, tx_ring);
+	qlcnic_update_cmd_producer(tx_ring);
 
 	__netif_tx_unlock_bh(tx_ring->txq);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 0bcda9c..faae9c5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -1583,7 +1583,6 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 
 static struct qlcnic_rx_buffer *
 qlcnic_process_lro(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_sds_ring *sds_ring,
 		int ring, u64 sts_data0, u64 sts_data1)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1698,8 +1697,8 @@ qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
 		case QLCNIC_LRO_DESC:
 			ring = qlcnic_get_lro_sts_type(sts_data0);
 			sts_data1 = le64_to_cpu(desc->status_desc_data[1]);
-			rxbuf = qlcnic_process_lro(adapter, sds_ring,
-					ring, sts_data0, sts_data1);
+			rxbuf = qlcnic_process_lro(adapter, ring, sts_data0,
+						   sts_data1);
 			break;
 		case QLCNIC_RESPONSE_DESC:
 			qlcnic_handle_fw_message(desc_cnt, consumer, sds_ring);
@@ -1850,9 +1849,8 @@ static void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
 	}
 }
 
-void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_sds_ring *sds_ring,
-		int ring, u64 sts_data0)
+void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter, int ring,
+			     u64 sts_data0)
 {
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct sk_buff *skb;
@@ -1920,7 +1918,7 @@ qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 		break;
 	default:
 		ring = qlcnic_get_sts_type(sts_data0);
-		qlcnic_process_rcv_diag(adapter, sds_ring, ring, sts_data0);
+		qlcnic_process_rcv_diag(adapter, ring, sts_data0);
 		break;
 	}
 
@@ -1934,9 +1932,7 @@ qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 	writel(consumer, sds_ring->crb_sts_consumer);
 }
 
-void
-qlcnic_fetch_mac(struct qlcnic_adapter *adapter, u32 off1, u32 off2,
-			u8 alt_mac, u8 *mac)
+void qlcnic_fetch_mac(u32 off1, u32 off2, u8 alt_mac, u8 *mac)
 {
 	u32 mac_low, mac_high;
 	int i;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 24ad17e..4109a41 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -115,9 +115,7 @@ static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 MODULE_DEVICE_TABLE(pci, qlcnic_pci_tbl);
 
 
-inline void
-qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_tx_ring *tx_ring)
+inline void qlcnic_update_cmd_producer(struct qlcnic_host_tx_ring *tx_ring)
 {
 	writel(tx_ring->producer, tx_ring->crb_cmd_producer);
 }
@@ -1485,8 +1483,8 @@ qlcnic_reset_context(struct qlcnic_adapter *adapter)
 }
 
 static int
-qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
-		struct net_device *netdev, u8 pci_using_dac)
+qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
+		    int pci_using_dac)
 {
 	int err;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1506,7 +1504,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO)
 		netdev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
-	if (pci_using_dac)
+	if (pci_using_dac == 1)
 		netdev->hw_features |= NETIF_F_HIGHDMA;
 
 	netdev->vlan_features = netdev->hw_features;
@@ -1530,7 +1528,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
+static int qlcnic_set_dma_mask(struct pci_dev *pdev, int *pci_using_dac)
 {
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
 			!pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))
@@ -1564,9 +1562,8 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
 	struct qlcnic_adapter *adapter = NULL;
-	int err;
+	int err, pci_using_dac = -1;
 	uint8_t revision_id;
-	uint8_t pci_using_dac;
 	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
 	err = pci_enable_device(pdev);
@@ -2337,7 +2334,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	adapter->stats.txbytes += skb->len;
 	adapter->stats.xmitcalled++;
 
-	qlcnic_update_cmd_producer(adapter, tx_ring);
+	qlcnic_update_cmd_producer(tx_ring);
 
 	return NETDEV_TX_OK;
 
-- 
1.8.0
