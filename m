From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 7/13] e1000: fix tx resource cleanup logic
Date: Thu, 6 Jan 2005 17:10:00 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061507270.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2004-12-06 08:43:11.635381920 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2004-12-06 08:43:12.534245272 -0800
@@ -1054,6 +1054,24 @@ e1000_free_tx_resources(struct e1000_ada
 	adapter->tx_ring.desc = NULL;
 }
 
+static inline void
+e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
+			struct e1000_buffer *buffer_info)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	if(buffer_info->dma) {
+		pci_unmap_page(pdev,
+			       buffer_info->dma,
+			       buffer_info->length,
+			       PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
+	}
+	if(buffer_info->skb) {
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
+	}
+}
+
 /**
  * e1000_clean_tx_ring - Free Tx Buffers
  * @adapter: board private structure
@@ -1064,7 +1082,6 @@ e1000_clean_tx_ring(struct e1000_adapter
 {
 	struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
 	struct e1000_buffer *buffer_info;
-	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
 	unsigned int i;
 
@@ -1072,17 +1089,7 @@ e1000_clean_tx_ring(struct e1000_adapter
 
 	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
-		if(buffer_info->skb) {
-
-			pci_unmap_page(pdev,
-				       buffer_info->dma,
-				       buffer_info->length,
-				       PCI_DMA_TODEVICE);
-
-			dev_kfree_skb(buffer_info->skb);
-
-			buffer_info->skb = NULL;
-		}
+		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
 
 	size = sizeof(struct e1000_buffer) * tx_ring->count;
@@ -2180,7 +2187,6 @@ e1000_clean_tx_irq(struct e1000_adapter 
 {
 	struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
 	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_tx_desc *tx_desc, *eop_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
@@ -2195,20 +2201,7 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 
-			if(likely(buffer_info->dma)) {
-				pci_unmap_page(pdev,
-					       buffer_info->dma,
-					       buffer_info->length,
-					       PCI_DMA_TODEVICE);
-
-				buffer_info->dma = 0;
-			}
-
-			if(buffer_info->skb) {
-				dev_kfree_skb_any(buffer_info->skb);
-				buffer_info->skb = NULL;
-			}
-
+			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->buffer_addr = 0;
 			tx_desc->lower.data = 0;
 			tx_desc->upper.data = 0;
