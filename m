From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 12/16 2.5] ixgb: replace kmalloc with vmalloc to allocate
 driver local data structures
Date: Fri, 15 Oct 2004 06:55:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150638490.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2004-10-05 16:03:24.000000000 -0700
@@ -46,10 +46,10 @@
 #include <linux/delay.h>
 #include <linux/timer.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/pagemap.h>
-#include <linux/dma-mapping.h>
 #include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/irq.h>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
@@ -609,8 +609,8 @@ static int ixgb_close(struct net_device 
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * txdr->count;
-	txdr->buffer_info = kmalloc(size, GFP_KERNEL);
-	if (!txdr->buffer_info) {
+	txdr->buffer_info = vmalloc(size);
+	if(!txdr->buffer_info) {
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -621,8 +620,8 @@ static int ixgb_setup_tx_resources(struc
 	IXGB_ROUNDUP(txdr->size, 4096);
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
-	if (!txdr->desc) {
-		kfree(txdr->buffer_info);
+	if(!txdr->desc) {
+		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -698,8 +692,8 @@ static void ixgb_configure_tx(struct ixg
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
-	rxdr->buffer_info = kmalloc(size, GFP_KERNEL);
-	if (!rxdr->buffer_info) {
+	rxdr->buffer_info = vmalloc(size);
+	if(!rxdr->buffer_info) {
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -711,8 +713,8 @@ static int ixgb_setup_rx_resources(struc
 
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
-	if (!rxdr->desc) {
-		kfree(rxdr->buffer_info);
+	if(!rxdr->desc) {
+		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -866,7 +867,7 @@ static void ixgb_configure_rx(struct ixg
 
 	ixgb_clean_tx_ring(adapter);
 
-	kfree(adapter->tx_ring.buffer_info);
+	vfree(adapter->tx_ring.buffer_info);
 	adapter->tx_ring.buffer_info = NULL;
 
 	pci_free_consistent(pdev, adapter->tx_ring.size,
@@ -932,7 +935,7 @@ static void ixgb_clean_tx_ring(struct ix
 
 	ixgb_clean_rx_ring(adapter);
 
-	kfree(rx_ring->buffer_info);
+	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
