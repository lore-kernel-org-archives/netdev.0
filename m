From: Anton Blanchard <anton@samba.org>
Subject: e1000_clean_tx_ring
Date: Fri, 25 Jun 2004 09:23:11 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624232311.GG22495@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cramerj@intel.com, john.ronciak@intel.com, ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

I was looking over the e1000 driver and noticed what I think is a bug
in e1000_clean_tx_ring. We wouldnt call pci_unmap_page on tx ring
entries that didnt have ->skb filled, eg zero copy packets.

This is on latest 2.6 BK.

Anton

===== e1000_main.c 1.120 vs edited =====
--- 1.120/drivers/net/e1000/e1000_main.c	Sat Jun 19 10:00:00 2004
+++ edited/e1000_main.c	Thu Jun 24 02:16:42 2004
@@ -1070,14 +1070,19 @@
 
 	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
-		if(buffer_info->skb) {
+		if (buffer_info->dma) {
 
 			pci_unmap_page(pdev,
 			               buffer_info->dma,
 			               buffer_info->length,
 			               PCI_DMA_TODEVICE);
 
-			dev_kfree_skb(buffer_info->skb);
+			buffer_info->dma = NULL;
+		}
+
+		if (buffer_info->skb) {
+
+			dev_kfree_skb_any(buffer_info->skb);
 
 			buffer_info->skb = NULL;
 		}
