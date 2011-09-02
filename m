From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 2/3] pch_gbe: added the process of FIFO over run error
Date: Fri,  2 Sep 2011 09:20:08 +0900
Message-ID: <1314922809-4041-2-git-send-email-toshiharu-linux@dsn.okisemi.com>
References: <1314922809-4041-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:47023 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932765Ab1IBAU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 20:20:59 -0400
In-Reply-To: <1314922809-4041-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch added the processing which should be done to hardware,
when a FIFO over run error occurred.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe.h      |   12 ++-
 drivers/net/pch_gbe/pch_gbe_main.c |  273 ++++++++++++++++++++++--------------
 2 files changed, 180 insertions(+), 105 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/pch_gbe/pch_gbe.h
index 59fac77..a09a071 100644
--- a/drivers/net/pch_gbe/pch_gbe.h
+++ b/drivers/net/pch_gbe/pch_gbe.h
@@ -127,8 +127,8 @@ struct pch_gbe_regs {
 
 /* Reset */
 #define PCH_GBE_ALL_RST         0x80000000  /* All reset */
-#define PCH_GBE_TX_RST          0x40000000  /* TX MAC, TX FIFO, TX DMA reset */
-#define PCH_GBE_RX_RST          0x04000000  /* RX MAC, RX FIFO, RX DMA reset */
+#define PCH_GBE_TX_RST          0x00008000  /* TX MAC, TX FIFO, TX DMA reset */
+#define PCH_GBE_RX_RST          0x00004000  /* RX MAC, RX FIFO, RX DMA reset */
 
 /* TCP/IP Accelerator Control */
 #define PCH_GBE_EX_LIST_EN      0x00000008  /* External List Enable */
@@ -276,6 +276,9 @@ struct pch_gbe_regs {
 #define PCH_GBE_RX_DMA_EN       0x00000002   /* Enables Receive DMA */
 #define PCH_GBE_TX_DMA_EN       0x00000001   /* Enables Transmission DMA */
 
+/* RX DMA STATUS */
+#define PCH_GBE_IDLE_CHECK       0xFFFFFFFE
+
 /* Wake On LAN Status */
 #define PCH_GBE_WLS_BR          0x00000008 /* Broadcas Address */
 #define PCH_GBE_WLS_MLT         0x00000004 /* Multicast Address */
@@ -471,6 +474,7 @@ struct pch_gbe_tx_desc {
 struct pch_gbe_buffer {
 	struct sk_buff *skb;
 	dma_addr_t dma;
+	unsigned char *rx_buffer;
 	unsigned long time_stamp;
 	u16 length;
 	bool mapped;
@@ -511,6 +515,9 @@ struct pch_gbe_tx_ring {
 struct pch_gbe_rx_ring {
 	struct pch_gbe_rx_desc *desc;
 	dma_addr_t dma;
+	unsigned char *rx_buff_pool;
+	dma_addr_t rx_buff_pool_logic;
+	unsigned int rx_buff_pool_size;
 	unsigned int size;
 	unsigned int count;
 	unsigned int next_to_use;
@@ -622,6 +629,7 @@ struct pch_gbe_adapter {
 	unsigned long rx_buffer_len;
 	unsigned long tx_queue_len;
 	bool have_msi;
+	bool rx_stop_flag;
 };
 
 extern const char pch_driver_version[];
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 48ff87c..39ce0ee 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -20,7 +20,6 @@
 
 #include "pch_gbe.h"
 #include "pch_gbe_api.h"
-#include <linux/prefetch.h>
 
 #define DRV_VERSION     "1.00"
 const char pch_driver_version[] = DRV_VERSION;
@@ -34,6 +33,7 @@ const char pch_driver_version[] = DRV_VERSION;
 #define PCH_GBE_WATCHDOG_PERIOD		(1 * HZ)	/* watchdog time */
 #define PCH_GBE_COPYBREAK_DEFAULT	256
 #define PCH_GBE_PCI_BAR			1
+#define PCH_GBE_RESERVE_MEMORY		0x200000	/* 2MB */
 
 /* Macros for ML7223 */
 #define PCI_VENDOR_ID_ROHM			0x10db
@@ -52,6 +52,7 @@ const char pch_driver_version[] = DRV_VERSION;
 	)
 
 /* Ethertype field values */
+#define PCH_GBE_MAX_RX_BUFFER_SIZE      0x2880
 #define PCH_GBE_MAX_JUMBO_FRAME_SIZE    10318
 #define PCH_GBE_FRAME_SIZE_2048         2048
 #define PCH_GBE_FRAME_SIZE_4096         4096
@@ -83,10 +84,12 @@ const char pch_driver_version[] = DRV_VERSION;
 #define PCH_GBE_INT_ENABLE_MASK ( \
 	PCH_GBE_INT_RX_DMA_CMPLT |    \
 	PCH_GBE_INT_RX_DSC_EMP   |    \
+	PCH_GBE_INT_RX_FIFO_ERR  |    \
 	PCH_GBE_INT_WOL_DET      |    \
 	PCH_GBE_INT_TX_CMPLT          \
 	)
 
+#define PCH_GBE_INT_DISABLE_ALL		0
 
 static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
 
@@ -138,6 +141,27 @@ static void pch_gbe_wait_clr_bit(void *reg, u32 bit)
 	if (!tmp)
 		pr_err("Error: busy bit is not cleared\n");
 }
+
+/**
+ * pch_gbe_wait_clr_bit_irq - Wait to clear a bit for interrupt context
+ * @reg:	Pointer of register
+ * @busy:	Busy bit
+ */
+static int pch_gbe_wait_clr_bit_irq(void *reg, u32 bit)
+{
+	u32 tmp;
+	int ret = -1;
+	/* wait busy */
+	tmp = 20;
+	while ((ioread32(reg) & bit) && --tmp)
+		udelay(5);
+	if (!tmp)
+		pr_err("Error: busy bit is not cleared\n");
+	else
+		ret = 0;
+	return ret;
+}
+
 /**
  * pch_gbe_mac_mar_set - Set MAC address register
  * @hw:	    Pointer to the HW structure
@@ -189,6 +213,17 @@ static void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
 	return;
 }
 
+static void pch_gbe_mac_reset_rx(struct pch_gbe_hw *hw)
+{
+	/* Read the MAC address. and store to the private data */
+	pch_gbe_mac_read_mac_addr(hw);
+	iowrite32(PCH_GBE_RX_RST, &hw->reg->RESET);
+	pch_gbe_wait_clr_bit_irq(&hw->reg->RESET, PCH_GBE_RX_RST);
+	/* Setup the MAC address */
+	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
+	return;
+}
+
 /**
  * pch_gbe_mac_init_rx_addrs - Initialize receive address's
  * @hw:	Pointer to the HW structure
@@ -671,13 +706,8 @@ static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
 
 	tcpip = ioread32(&hw->reg->TCPIP_ACC);
 
-	if (netdev->features & NETIF_F_RXCSUM) {
-		tcpip &= ~PCH_GBE_RX_TCPIPACC_OFF;
-		tcpip |= PCH_GBE_RX_TCPIPACC_EN;
-	} else {
-		tcpip |= PCH_GBE_RX_TCPIPACC_OFF;
-		tcpip &= ~PCH_GBE_RX_TCPIPACC_EN;
-	}
+	tcpip |= PCH_GBE_RX_TCPIPACC_OFF;
+	tcpip &= ~PCH_GBE_RX_TCPIPACC_EN;
 	iowrite32(tcpip, &hw->reg->TCPIP_ACC);
 	return;
 }
@@ -1090,6 +1120,35 @@ void pch_gbe_update_stats(struct pch_gbe_adapter *adapter)
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 
+static void pch_gbe_stop_receive(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 rxdma;
+	u16 value;
+	int ret;
+
+	/* Disable Receive DMA */
+	rxdma = ioread32(&hw->reg->DMA_CTRL);
+	rxdma &= ~PCH_GBE_RX_DMA_EN;
+	iowrite32(rxdma, &hw->reg->DMA_CTRL);
+	/* Wait Rx DMA BUS is IDLE */
+	ret = pch_gbe_wait_clr_bit_irq(&hw->reg->RX_DMA_ST, PCH_GBE_IDLE_CHECK);
+	if (ret) {
+		/* Disable Bus master */
+		pci_read_config_word(adapter->pdev, PCI_COMMAND, &value);
+		value &= ~PCI_COMMAND_MASTER;
+		pci_write_config_word(adapter->pdev, PCI_COMMAND, value);
+		/* Stop Receive */
+		pch_gbe_mac_reset_rx(hw);
+		/* Enable Bus master */
+		value |= PCI_COMMAND_MASTER;
+		pci_write_config_word(adapter->pdev, PCI_COMMAND, value);
+	} else {
+		/* Stop Receive */
+		pch_gbe_mac_reset_rx(hw);
+	}
+}
+
 static void pch_gbe_start_receive(struct pch_gbe_hw *hw)
 {
 	u32 rxdma;
@@ -1129,7 +1188,15 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 	if (int_st & PCH_GBE_INT_RX_FRAME_ERR)
 		adapter->stats.intr_rx_frame_err_count++;
 	if (int_st & PCH_GBE_INT_RX_FIFO_ERR)
-		adapter->stats.intr_rx_fifo_err_count++;
+		if (!adapter->rx_stop_flag) {
+			adapter->stats.intr_rx_fifo_err_count++;
+			pr_debug("Rx fifo over run\n");
+			adapter->rx_stop_flag = true;
+			int_en = ioread32(&hw->reg->INT_EN);
+			iowrite32((int_en & ~PCH_GBE_INT_RX_FIFO_ERR),
+				  &hw->reg->INT_EN);
+			pch_gbe_stop_receive(adapter);
+		}
 	if (int_st & PCH_GBE_INT_RX_DMA_ERR)
 		adapter->stats.intr_rx_dma_err_count++;
 	if (int_st & PCH_GBE_INT_TX_FIFO_ERR)
@@ -1141,7 +1208,7 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 	/* When Rx descriptor is empty  */
 	if ((int_st & PCH_GBE_INT_RX_DSC_EMP)) {
 		adapter->stats.intr_rx_dsc_empty_count++;
-		pr_err("Rx descriptor is empty\n");
+		pr_debug("Rx descriptor is empty\n");
 		int_en = ioread32(&hw->reg->INT_EN);
 		iowrite32((int_en & ~PCH_GBE_INT_RX_DSC_EMP), &hw->reg->INT_EN);
 		if (hw->mac.tx_fc_enable) {
@@ -1191,29 +1258,23 @@ pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
 	unsigned int i;
 	unsigned int bufsz;
 
-	bufsz = adapter->rx_buffer_len + PCH_GBE_DMA_ALIGN;
+	bufsz = adapter->rx_buffer_len + NET_IP_ALIGN;
 	i = rx_ring->next_to_use;
 
 	while ((cleaned_count--)) {
 		buffer_info = &rx_ring->buffer_info[i];
-		skb = buffer_info->skb;
-		if (skb) {
-			skb_trim(skb, 0);
-		} else {
-			skb = netdev_alloc_skb(netdev, bufsz);
-			if (unlikely(!skb)) {
-				/* Better luck next round */
-				adapter->stats.rx_alloc_buff_failed++;
-				break;
-			}
-			/* 64byte align */
-			skb_reserve(skb, PCH_GBE_DMA_ALIGN);
-
-			buffer_info->skb = skb;
-			buffer_info->length = adapter->rx_buffer_len;
+		skb = netdev_alloc_skb(netdev, bufsz);
+		if (unlikely(!skb)) {
+			/* Better luck next round */
+			adapter->stats.rx_alloc_buff_failed++;
+			break;
 		}
+		/* align */
+		skb_reserve(skb, NET_IP_ALIGN);
+		buffer_info->skb = skb;
+
 		buffer_info->dma = dma_map_single(&pdev->dev,
-						  skb->data,
+						  buffer_info->rx_buffer,
 						  buffer_info->length,
 						  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&adapter->pdev->dev, buffer_info->dma)) {
@@ -1246,6 +1307,36 @@ pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
 	return;
 }
 
+static int
+pch_gbe_alloc_rx_buffers_pool(struct pch_gbe_adapter *adapter,
+			 struct pch_gbe_rx_ring *rx_ring, int cleaned_count)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct pch_gbe_buffer *buffer_info;
+	unsigned int i;
+	unsigned int bufsz;
+	unsigned int size;
+
+	bufsz = adapter->rx_buffer_len;
+
+	size = rx_ring->count * bufsz + PCH_GBE_RESERVE_MEMORY;
+	rx_ring->rx_buff_pool = dma_alloc_coherent(&pdev->dev, size,
+						&rx_ring->rx_buff_pool_logic,
+						GFP_KERNEL);
+	if (!rx_ring->rx_buff_pool) {
+		pr_err("Unable to allocate memory for the receive poll buffer\n");
+		return -ENOMEM;
+	}
+	memset(rx_ring->rx_buff_pool, 0, size);
+	rx_ring->rx_buff_pool_size = size;
+	for (i = 0; i < rx_ring->count; i++) {
+		buffer_info = &rx_ring->buffer_info[i];
+		buffer_info->rx_buffer = rx_ring->rx_buff_pool + bufsz * i;
+		buffer_info->length = bufsz;
+	}
+	return 0;
+}
+
 /**
  * pch_gbe_alloc_tx_buffers - Allocate transmit buffers
  * @adapter:   Board private structure
@@ -1386,7 +1477,7 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 	unsigned int i;
 	unsigned int cleaned_count = 0;
 	bool cleaned = false;
-	struct sk_buff *skb, *new_skb;
+	struct sk_buff *skb;
 	u8 dma_status;
 	u16 gbec_status;
 	u32 tcp_ip_status;
@@ -1407,13 +1498,12 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 		rx_desc->gbec_status = DSC_INIT16;
 		buffer_info = &rx_ring->buffer_info[i];
 		skb = buffer_info->skb;
+		buffer_info->skb = NULL;
 
 		/* unmap dma */
 		dma_unmap_single(&pdev->dev, buffer_info->dma,
 				   buffer_info->length, DMA_FROM_DEVICE);
 		buffer_info->mapped = false;
-		/* Prefetch the packet */
-		prefetch(skb->data);
 
 		pr_debug("RxDecNo = 0x%04x  Status[DMA:0x%02x GBE:0x%04x "
 			 "TCP:0x%08x]  BufInf = 0x%p\n",
@@ -1433,70 +1523,16 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			pr_err("Receive CRC Error\n");
 		} else {
 			/* get receive length */
-			/* length convert[-3] */
-			length = (rx_desc->rx_words_eob) - 3;
-
-			/* Decide the data conversion method */
-			if (!(netdev->features & NETIF_F_RXCSUM)) {
-				/* [Header:14][payload] */
-				if (NET_IP_ALIGN) {
-					/* Because alignment differs,
-					 * the new_skb is newly allocated,
-					 * and data is copied to new_skb.*/
-					new_skb = netdev_alloc_skb(netdev,
-							 length + NET_IP_ALIGN);
-					if (!new_skb) {
-						/* dorrop error */
-						pr_err("New skb allocation "
-							"Error\n");
-						goto dorrop;
-					}
-					skb_reserve(new_skb, NET_IP_ALIGN);
-					memcpy(new_skb->data, skb->data,
-					       length);
-					skb = new_skb;
-				} else {
-					/* DMA buffer is used as SKB as it is.*/
-					buffer_info->skb = NULL;
-				}
-			} else {
-				/* [Header:14][padding:2][payload] */
-				/* The length includes padding length */
-				length = length - PCH_GBE_DMA_PADDING;
-				if ((length < copybreak) ||
-				    (NET_IP_ALIGN != PCH_GBE_DMA_PADDING)) {
-					/* Because alignment differs,
-					 * the new_skb is newly allocated,
-					 * and data is copied to new_skb.
-					 * Padding data is deleted
-					 * at the time of a copy.*/
-					new_skb = netdev_alloc_skb(netdev,
-							 length + NET_IP_ALIGN);
-					if (!new_skb) {
-						/* dorrop error */
-						pr_err("New skb allocation "
-							"Error\n");
-						goto dorrop;
-					}
-					skb_reserve(new_skb, NET_IP_ALIGN);
-					memcpy(new_skb->data, skb->data,
-					       ETH_HLEN);
-					memcpy(&new_skb->data[ETH_HLEN],
-					       &skb->data[ETH_HLEN +
-					       PCH_GBE_DMA_PADDING],
-					       length - ETH_HLEN);
-					skb = new_skb;
-				} else {
-					/* Padding data is deleted
-					 * by moving header data.*/
-					memmove(&skb->data[PCH_GBE_DMA_PADDING],
-						&skb->data[0], ETH_HLEN);
-					skb_reserve(skb, NET_IP_ALIGN);
-					buffer_info->skb = NULL;
-				}
-			}
-			/* The length includes FCS length */
-			length = length - ETH_FCS_LEN;
+			/* length convert[-3], length includes FCS length */
+			length = (rx_desc->rx_words_eob) - 3 - ETH_FCS_LEN;
+			if (rx_desc->rx_words_eob & 0x02)
+				length = length - 4;
+			/*
+			 * buffer_info->rx_buffer: [Header:14][payload]
+			 * skb->data: [Reserve:2][Header:14][payload]
+			 */
+			memcpy(skb->data, buffer_info->rx_buffer, length);
+
 			/* update status of driver */
 			adapter->stats.rx_bytes += length;
 			adapter->stats.rx_packets++;
@@ -1515,7 +1551,6 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			pr_debug("Receive skb->ip_summed: %d length: %d\n",
 				 skb->ip_summed, length);
 		}
-dorrop:
 		/* return some buffers to hardware, one at a time is too slow */
 		if (unlikely(cleaned_count >= PCH_GBE_RX_BUFFER_WRITE)) {
 			pch_gbe_alloc_rx_buffers(adapter, rx_ring,
@@ -1720,6 +1755,11 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 		pr_err("Error: can't bring device up\n");
 		return err;
 	}
+	err = pch_gbe_alloc_rx_buffers_pool(adapter, rx_ring, rx_ring->count);
+	if (err) {
+		pr_err("Error: can't bring device up\n");
+		return err;
+	}
 	pch_gbe_alloc_tx_buffers(adapter, tx_ring);
 	pch_gbe_alloc_rx_buffers(adapter, rx_ring, rx_ring->count);
 	adapter->tx_queue_len = netdev->tx_queue_len;
@@ -1741,6 +1781,7 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 void pch_gbe_down(struct pch_gbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
 
 	/* signal that we're down so the interrupt handler does not
 	 * reschedule our watchdog timer */
@@ -1759,6 +1800,12 @@ void pch_gbe_down(struct pch_gbe_adapter *adapter)
 	pch_gbe_reset(adapter);
 	pch_gbe_clean_tx_ring(adapter, adapter->tx_ring);
 	pch_gbe_clean_rx_ring(adapter, adapter->rx_ring);
+
+	pci_free_consistent(adapter->pdev, rx_ring->rx_buff_pool_size,
+			    rx_ring->rx_buff_pool, rx_ring->rx_buff_pool_logic);
+	rx_ring->rx_buff_pool_logic = 0;
+	rx_ring->rx_buff_pool_size = 0;
+	rx_ring->rx_buff_pool = NULL;
 }
 
 /**
@@ -2011,6 +2058,8 @@ static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	int max_frame;
+	unsigned long old_rx_buffer_len = adapter->rx_buffer_len;
+	int err;
 
 	max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
@@ -2025,14 +2074,24 @@ static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu)
 	else if (max_frame <= PCH_GBE_FRAME_SIZE_8192)
 		adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_8192;
 	else
-		adapter->rx_buffer_len = PCH_GBE_MAX_JUMBO_FRAME_SIZE;
-	netdev->mtu = new_mtu;
-	adapter->hw.mac.max_frame_size = max_frame;
+		adapter->rx_buffer_len = PCH_GBE_MAX_RX_BUFFER_SIZE;
 
-	if (netif_running(netdev))
-		pch_gbe_reinit_locked(adapter);
-	else
+	if (netif_running(netdev)) {
+		pch_gbe_down(adapter);
+		err = pch_gbe_up(adapter);
+		if (err) {
+			adapter->rx_buffer_len = old_rx_buffer_len;
+			pch_gbe_up(adapter);
+			return -ENOMEM;
+		} else {
+			netdev->mtu = new_mtu;
+			adapter->hw.mac.max_frame_size = max_frame;
+		}
+	} else {
 		pch_gbe_reset(adapter);
+		netdev->mtu = new_mtu;
+		adapter->hw.mac.max_frame_size = max_frame;
+	}
 
 	pr_debug("max_frame : %d  rx_buffer_len : %d  mtu : %d  max_frame_size : %d\n",
 		 max_frame, (u32) adapter->rx_buffer_len, netdev->mtu,
@@ -2110,6 +2169,7 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 	int work_done = 0;
 	bool poll_end_flag = false;
 	bool cleaned = false;
+	u32 int_en;
 
 	pr_debug("budget : %d\n", budget);
 
@@ -2117,8 +2177,15 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 	if (!netif_carrier_ok(netdev)) {
 		poll_end_flag = true;
 	} else {
-		cleaned = pch_gbe_clean_tx(adapter, adapter->tx_ring);
 		pch_gbe_clean_rx(adapter, adapter->rx_ring, &work_done, budget);
+		if (adapter->rx_stop_flag) {
+			adapter->rx_stop_flag = false;
+			pch_gbe_start_receive(&adapter->hw);
+			int_en = ioread32(&adapter->hw.reg->INT_EN);
+			iowrite32((int_en | PCH_GBE_INT_RX_FIFO_ERR),
+					&adapter->hw.reg->INT_EN);
+		}
+		cleaned = pch_gbe_clean_tx(adapter, adapter->tx_ring);
 
 		if (cleaned)
 			work_done = budget;
-- 
1.7.4.4
