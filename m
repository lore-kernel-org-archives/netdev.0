From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate
 driver local data structures
Date: Fri, 29 Oct 2004 05:11:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290458520.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/ixgb/ixgb.h netdev-2.6/drivers/net/ixgb.new/ixgb.h
--- netdev-2.6/drivers/net/ixgb/ixgb.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb.h	2004-10-15 13:15:51.000000000 -0700
@@ -46,6 +46,7 @@
 #include <linux/delay.h>
 #include <linux/timer.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/pagemap.h>
diff -up netdev-2.6/drivers/net/ixgb/ixgb_main.c netdev-2.6/drivers/net/ixgb.new/ixgb_main.c
--- netdev-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-15 13:15:55.000000000 -0700
@@ -608,8 +608,8 @@ static int ixgb_close(struct net_device 
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * txdr->count;
-	txdr->buffer_info = kmalloc(size, GFP_KERNEL);
 	if (!txdr->buffer_info) {
+	txdr->buffer_info = vmalloc(size);
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -621,7 +620,7 @@ static int ixgb_setup_tx_resources(struc
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if (!txdr->desc) {
-		kfree(txdr->buffer_info);
+		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -697,8 +692,8 @@ static void ixgb_configure_tx(struct ixg
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
-	rxdr->buffer_info = kmalloc(size, GFP_KERNEL);
 	if (!rxdr->buffer_info) {
+	rxdr->buffer_info = vmalloc(size);
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -711,7 +713,7 @@ static int ixgb_setup_rx_resources(struc
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
 	if (!rxdr->desc) {
-		kfree(rxdr->buffer_info);
+		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -865,7 +867,7 @@ static void ixgb_configure_rx(struct ixg
 
 	ixgb_clean_tx_ring(adapter);
 
-	kfree(adapter->tx_ring.buffer_info);
+	vfree(adapter->tx_ring.buffer_info);
 	adapter->tx_ring.buffer_info = NULL;
 
 	pci_free_consistent(pdev, adapter->tx_ring.size,
@@ -931,7 +935,7 @@ static void ixgb_clean_tx_ring(struct ix
 
 	ixgb_clean_rx_ring(adapter);
 
-	kfree(rx_ring->buffer_info);
+	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
