From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: e1000_clean_tx_ring
Date: Mon, 28 Jun 2004 15:11:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E01967ADD@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "cramerj" <cramerj@intel.com>, "Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Anton Blanchard" <anton@samba.org>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anton:

We will integrate this patch into the next release of our driver.

Thanks,
ganesh 
 
-------------------------------------------------
Ganesh Venkatesan
Network/Storage Division, Hillsboro, OR

-----Original Message-----
From: Anton Blanchard [mailto:anton@samba.org] 
Sent: Thursday, June 24, 2004 4:23 PM
To: netdev@oss.sgi.com
Cc: cramerj; Ronciak, John; Venkatesan, Ganesh
Subject: e1000_clean_tx_ring


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
