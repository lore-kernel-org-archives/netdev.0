From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6] hang on ZEROCOPY/TSO when hitting no-Tx-resources
 condition
Date: Thu, 2 Oct 2003 18:06:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310021744320.4238-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Critical bug fix: under heavy Tx stress using ZEROCOPY or TSO, if we
  ran out of Tx descriptors, we didn't calculate for the context
  descritor used as the first of the ZEROCOPY/TSO send, nor do we clean
  up the context desriptor bits in the case where the send isn't going
  to fit, where we need to undo the mappings.  This bug was introduced
  with the 5.2.16 patch set which included a workaround for a hang
  on 82544 over PCI-X.  This workaround cause the check for no-Tx-
  rosource logic to change, and this bug slipped in.

------------

diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_main.c net-drivers-2.5/drivers/net/e1000.mod/e1000_main.c
--- net-drivers-2.5/drivers/net/e1000/e1000_main.c	2003-10-02 17:34:04.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_main.c	2003-10-02 17:38:35.000000000 -0700
@@ -30,7 +30,7 @@
 
 /* Change Log
  *
- * 5.2.18	9/13/03
+ * 5.2.20	9/30/03
  *   o Bug fix: SERDES devices might be connected to a back-plane
  *     switch that doesn't support auto-neg, so add the capability
  *     to force 1000/Full.
@@ -39,6 +39,9 @@
  *     Jumbo Frames or with the reduced FIFO in 82547.
  *   o Better propagation of error codes. [Janice Girouard 
  *     (janiceg@us.ibm.com)].
+ *   o Bug fix: hang under heavy Tx stress when running out of Tx
+ *     descriptors; wasn't clearing context descriptor when backing
+ *     out of send because of no-resource condition.
  *
  * 5.2.16	8/8/03
  *   o Added support for new controllers: 82545GM, 82546GB, 82541/7_B1
@@ -61,7 +64,7 @@
 
 char e1000_driver_name[] = "e1000";
 char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-char e1000_driver_version[] = "5.2.19-k1";
+char e1000_driver_version[] = "5.2.20-k1";
 char e1000_copyright[] = "Copyright (c) 1999-2003 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -1501,6 +1504,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 	unsigned int first)
 {
 	struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
+	struct e1000_tx_desc *tx_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb->len, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int offset = 0, size, count = 0, i;
@@ -1596,17 +1600,29 @@ e1000_tx_map(struct e1000_adapter *adapt
 		}
 	}
 
-	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count) {
+	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {
 
 		/* There aren't enough descriptors available to queue up
-		 * this send, so undo the mapping and abort the send. 
-		 * We could have done the check before we mapped the skb,
-		 * but because of all the workarounds (above), it's too
-		 * difficult to predict how many we're going to need.*/
-		i = first;
+		 * this send (need: count + 1 context desc + 1 desc gap
+		 * to keep tail from touching head), so undo the mapping
+		 * and abort the send.  We could have done the check before
+		 * we mapped the skb, but because of all the workarounds
+		 * (above), it's too difficult to predict how many we're
+		 * going to need.*/
+		i = adapter->tx_ring.next_to_use;
+
+		if(i == first) {
+			/* Cleanup after e1000_tx_[csum|tso] scribbling
+			 * on descriptors. */
+			tx_desc = E1000_TX_DESC(*tx_ring, first);
+			tx_desc->buffer_addr = 0;
+			tx_desc->lower.data = 0;
+			tx_desc->upper.data = 0;
+		}
 
 		while(count--) {
 			buffer_info = &tx_ring->buffer_info[i];
+
 			if(buffer_info->dma) {
 				pci_unmap_page(adapter->pdev,
 					       buffer_info->dma,
@@ -1614,9 +1630,12 @@ e1000_tx_map(struct e1000_adapter *adapt
 					       PCI_DMA_TODEVICE);
 				buffer_info->dma = 0;
 			}
+
 			if(++i == tx_ring->count) i = 0;
 		}
 
+		adapter->tx_ring.next_to_use = first;
+
 		return 0;
 	}
 
