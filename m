From: ganesh.venkatesan@intel.com
Subject: [PATCH 3/12 2.4] e1000 - use vmalloc for data structures not shared
 with h/w
Date: Thu, 29 Jul 2004 08:29:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290726020.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000.h linux-2.4/drivers/net/e1000.new/e1000.h
--- linux-2.4/drivers/net/e1000/e1000.h	2004-07-28 08:47:08.172582760 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000.h	2004-07-28 08:47:09.439390176 -0700
@@ -49,6 +49,7 @@
 #include <linux/delay.h>
 #include <linux/timer.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/pagemap.h>
diff -up linux-2.4/drivers/net/e1000/e1000_main.c linux-2.4/drivers/net/e1000.new/e1000_main.c
--- linux-2.4/drivers/net/e1000/e1000_main.c	2004-07-28 08:47:08.177582000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_main.c	2004-07-28 08:47:09.559371936 -0700
@@ -786,7 +786,7 @@ e1000_setup_tx_resources(struct e1000_ad
 	int size;
 
 	size = sizeof(struct e1000_buffer) * txdr->count;
-	txdr->buffer_info = kmalloc(size, GFP_KERNEL);
+	txdr->buffer_info = vmalloc(size);
 	if(!txdr->buffer_info) {
 		return -ENOMEM;
 	}
@@ -799,7 +820,7 @@ e1000_setup_tx_resources(struct e1000_ad
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
-		kfree(txdr->buffer_info);
+		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -903,7 +926,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	int size;
 
 	size = sizeof(struct e1000_buffer) * rxdr->count;
-	rxdr->buffer_info = kmalloc(size, GFP_KERNEL);
+	rxdr->buffer_info = vmalloc(size);
 	if(!rxdr->buffer_info) {
 		return -ENOMEM;
 	}
@@ -917,7 +942,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
 	if(!rxdr->desc) {
-		kfree(rxdr->buffer_info);
+		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -1041,7 +1041,7 @@ e1000_free_tx_resources(struct e1000_ada
 
 	e1000_clean_tx_ring(adapter);
 
-	kfree(adapter->tx_ring.buffer_info);
+	vfree(adapter->tx_ring.buffer_info);
 	adapter->tx_ring.buffer_info = NULL;
 
 	pci_free_consistent(pdev, adapter->tx_ring.size,
@@ -1110,7 +1110,7 @@ e1000_free_rx_resources(struct e1000_ada
 
 	e1000_clean_rx_ring(adapter);
 
-	kfree(rx_ring->buffer_info);
+	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
