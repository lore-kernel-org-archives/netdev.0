From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 6/9] ixgb: Fix tx cleanup logic error
Date: Thu, 6 Jan 2005 17:26:13 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061553550.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-01-05 17:13:29.000000000 -0800
@@ -923,6 +923,24 @@ ixgb_free_tx_resources(struct ixgb_adapt
 	adapter->tx_ring.desc = NULL;
 }
 
+static inline void
+ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
+						struct ixgb_buffer *buffer_info)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	if(buffer_info->dma) {
+		pci_unmap_page(pdev,
+			   buffer_info->dma,
+			   buffer_info->length,
+				   PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
+	}
+	if(buffer_info->skb) {
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
+	}
+}
+
 /**
  * ixgb_clean_tx_ring - Free Tx Buffers
  * @adapter: board private structure
@@ -933,7 +885,6 @@ ixgb_clean_tx_ring(struct ixgb_adapter *
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_buffer *buffer_info;
-	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
 	unsigned int i;
 
@@ -941,17 +941,7 @@ ixgb_clean_tx_ring(struct ixgb_adapter *
 
 	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
-		if(buffer_info->skb) {
-
-			pci_unmap_page(pdev,
-					   buffer_info->dma,
-					   buffer_info->length,
-					   PCI_DMA_TODEVICE);
-
-			dev_kfree_skb(buffer_info->skb);
-
-			buffer_info->skb = NULL;
-		}
+		ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
 
 	size = sizeof(struct ixgb_buffer) * tx_ring->count;
@@ -1735,7 +1742,6 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
 	struct ixgb_tx_desc *tx_desc, *eop_desc;
 	struct ixgb_buffer *buffer_info;
 	unsigned int i, eop;
@@ -1756,22 +1690,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
 			       IXGB_TX_DESC_POPTS_IXSM))
 				adapter->hw_csum_tx_good++;
 
-			if(buffer_info->dma) {
-
-				pci_unmap_page(pdev,
-						   buffer_info->dma,
-						   buffer_info->length,
-						   PCI_DMA_TODEVICE);
-
-				buffer_info->dma = 0;
-			}
-
-			if(buffer_info->skb) {
-
-				dev_kfree_skb_any(buffer_info->skb);
-
-				buffer_info->skb = NULL;
-			}
+			ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 
 			*(uint32_t *)&(tx_desc->status) = 0;
 
