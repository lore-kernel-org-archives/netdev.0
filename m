From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 5/9] qlcnic: cleanup unused code
Date: Thu, 13 May 2010 06:07:46 -0700
Message-ID: <1273756070-7205-6-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:38406 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758615Ab0EMNHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:54 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LRO ring, cut-thru mode and specific fw version are not
valid to Qlogic CNA device.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    6 ------
 drivers/net/qlcnic/qlcnic_ethtool.c |    1 -
 drivers/net/qlcnic/qlcnic_init.c    |   31 ++++++-------------------------
 drivers/net/qlcnic/qlcnic_main.c    |   33 ++++-----------------------------
 4 files changed, 10 insertions(+), 61 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 189453f..ed9df15 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -98,8 +98,6 @@
 #define QLCNIC_CT_DEFAULT_RX_BUF_LEN	2048
 #define QLCNIC_LRO_BUFFER_EXTRA		2048
 
-#define QLCNIC_RX_LRO_BUFFER_LENGTH		(8060)
-
 /* Opcodes to be used with the commands */
 #define TX_ETHER_PKT	0x01
 #define TX_TCP_PKT	0x02
@@ -133,7 +131,6 @@
 
 #define RCV_RING_NORMAL 0
 #define RCV_RING_JUMBO	1
-#define RCV_RING_LRO	2
 
 #define MIN_CMD_DESCRIPTORS		64
 #define MIN_RCV_DESCRIPTORS		64
@@ -144,7 +141,6 @@
 #define MAX_RCV_DESCRIPTORS_10G 	8192
 #define MAX_JUMBO_RCV_DESCRIPTORS_1G	512
 #define MAX_JUMBO_RCV_DESCRIPTORS_10G	1024
-#define MAX_LRO_RCV_DESCRIPTORS		8
 
 #define DEFAULT_RCV_DESCRIPTORS_1G	2048
 #define DEFAULT_RCV_DESCRIPTORS_10G	4096
@@ -402,7 +398,6 @@ struct qlcnic_hardware_context {
 	rwlock_t crb_lock;
 	struct mutex mem_lock;
 
-	u8 cut_through;
 	u8 revision_id;
 	u8 pci_func;
 	u8 linkup;
@@ -917,7 +912,6 @@ struct qlcnic_adapter {
 	u16 num_txd;
 	u16 num_rxd;
 	u16 num_jumbo_rxd;
-	u16 num_lro_rxd;
 
 	u8 max_rds_rings;
 	u8 max_sds_rings;
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index e494ccc..3bd514e 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -412,7 +412,6 @@ qlcnic_get_ringparam(struct net_device *dev,
 
 	ring->rx_pending = adapter->num_rxd;
 	ring->rx_jumbo_pending = adapter->num_jumbo_rxd;
-	ring->rx_jumbo_pending += adapter->num_lro_rxd;
 	ring->tx_pending = adapter->num_txd;
 
 	if (adapter->ahw.port_type == QLCNIC_GBE) {
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 9b01042..c4bef57 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -230,17 +230,8 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 		switch (ring) {
 		case RCV_RING_NORMAL:
 			rds_ring->num_desc = adapter->num_rxd;
-			if (adapter->ahw.cut_through) {
-				rds_ring->dma_size =
-					QLCNIC_CT_DEFAULT_RX_BUF_LEN;
-				rds_ring->skb_size =
-					QLCNIC_CT_DEFAULT_RX_BUF_LEN;
-			} else {
-				rds_ring->dma_size =
-					QLCNIC_P3_RX_BUF_MAX_LEN;
-				rds_ring->skb_size =
-					rds_ring->dma_size + NET_IP_ALIGN;
-			}
+			rds_ring->dma_size = QLCNIC_P3_RX_BUF_MAX_LEN;
+			rds_ring->skb_size = rds_ring->dma_size + NET_IP_ALIGN;
 			break;
 
 		case RCV_RING_JUMBO:
@@ -254,13 +245,6 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 			rds_ring->skb_size =
 				rds_ring->dma_size + NET_IP_ALIGN;
 			break;
-
-		case RCV_RING_LRO:
-			rds_ring->num_desc = adapter->num_lro_rxd;
-			rds_ring->dma_size = QLCNIC_RX_LRO_BUFFER_LENGTH;
-			rds_ring->skb_size = rds_ring->dma_size + NET_IP_ALIGN;
-			break;
-
 		}
 		rds_ring->rx_buf_arr = (struct qlcnic_rx_buffer *)
 			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
@@ -556,12 +540,10 @@ qlcnic_has_mn(struct qlcnic_adapter *adapter)
 			QLCNIC_FW_VERSION_OFFSET, (int *)&flashed_ver);
 	flashed_ver = QLCNIC_DECODE_VERSION(flashed_ver);
 
-	if (flashed_ver >= QLCNIC_VERSION_CODE(4, 0, 220)) {
+	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY);
+	if (capability & QLCNIC_PEG_TUNE_MN_PRESENT)
+		return 1;
 
-		capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY);
-		if (capability & QLCNIC_PEG_TUNE_MN_PRESENT)
-			return 1;
-	}
 	return 0;
 }
 
@@ -1279,8 +1261,7 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 
 	skb = buffer->skb;
 
-	if (!adapter->ahw.cut_through)
-		skb_reserve(skb, 2);
+	skb_reserve(skb, 2);
 
 	dma = pci_map_single(pdev, skb->data,
 			rds_ring->dma_size, PCI_DMA_FROMDEVICE);
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index f10ea32..d86c50d 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -544,22 +544,10 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 				brd_name, adapter->ahw.revision_id);
 	}
 
-	if (adapter->fw_version < QLCNIC_VERSION_CODE(3, 4, 216)) {
-		adapter->driver_mismatch = 1;
-		dev_warn(&pdev->dev, "firmware version %d.%d.%d unsupported\n",
-				fw_major, fw_minor, fw_build);
-		return;
-	}
-
-	i = QLCRD32(adapter, QLCNIC_SRE_MISC);
-	adapter->ahw.cut_through = (i & 0x8000) ? 1 : 0;
-
-	dev_info(&pdev->dev, "firmware v%d.%d.%d [%s]\n",
-			fw_major, fw_minor, fw_build,
-			adapter->ahw.cut_through ? "cut-through" : "legacy");
+	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
+			fw_major, fw_minor, fw_build);
 
-	if (adapter->fw_version >= QLCNIC_VERSION_CODE(4, 0, 222))
-		adapter->capabilities = QLCRD32(adapter, CRB_FW_CAPABILITIES_1);
+	adapter->capabilities = QLCRD32(adapter, CRB_FW_CAPABILITIES_1);
 
 	adapter->flags &= ~QLCNIC_LRO_ENABLED;
 
@@ -576,7 +564,6 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	adapter->num_txd = MAX_CMD_DESCRIPTORS;
 
-	adapter->num_lro_rxd = 0;
 	adapter->max_rds_rings = 2;
 }
 
@@ -2567,24 +2554,12 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
 
-static int
-qlcnic_destip_supported(struct qlcnic_adapter *adapter)
-{
-	if (adapter->ahw.cut_through)
-		return 0;
-
-	return 1;
-}
-
 static void
 qlcnic_config_indev_addr(struct net_device *dev, unsigned long event)
 {
 	struct in_device *indev;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 
-	if (!qlcnic_destip_supported(adapter))
-		return;
-
 	indev = in_dev_get(dev);
 	if (!indev)
 		return;
@@ -2664,7 +2639,7 @@ recheck:
 
 	adapter = netdev_priv(dev);
 
-	if (!adapter || !qlcnic_destip_supported(adapter))
+	if (!adapter)
 		goto done;
 
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
-- 
1.6.0.2

