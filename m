From: Scott Feldman <scott.feldman@intel.com>
Subject: [e100 2.6 1/2]
Date: Mon, 3 May 2004 14:58:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405031452480.5014@sfeldma-ich5.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Change mapping on Rx SKB to bi-directional.  skb->data holds both the
  RFD structure and the packet data, and the RFD is read/written by
  HW.  Issue found on XScale HW that doesn't handle cache syncs auto-
  matically.  Other changes in patch are whitespace/spelling.

-----------------

--- linux-2.5/drivers/net/e100.c	2004-05-03 14:43:27.198629944 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-05-03 14:46:27.174269488 -0700
@@ -1392,12 +1392,12 @@ static inline int e100_rx_alloc_skb(stru
 	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + rx_offset)))
 		return -ENOMEM;

-	/* Align, init, and map the RFA. */
+	/* Align, init, and map the RFD. */
 	rx->skb->dev = nic->netdev;
 	skb_reserve(rx->skb, rx_offset);
 	memcpy(rx->skb->data, &nic->blank_rfd, sizeof(struct rfd));
 	rx->dma_addr = pci_map_single(nic->pdev, rx->skb->data,
-		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+		RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);

 	/* Link the RFD to end of RFA by linking previous RFD to
 	 * this one, and clearing EL bit of previous.  */
@@ -1408,7 +1408,7 @@ static inline int e100_rx_alloc_skb(stru
 		wmb();
 		prev_rfd->command &= ~cpu_to_le16(cb_el);
 		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
-					       sizeof(struct rfd), PCI_DMA_TODEVICE);
+			sizeof(struct rfd), PCI_DMA_TODEVICE);
 	}

 	return 0;
@@ -1426,7 +1426,7 @@ static inline int e100_rx_indicate(struc

 	/* Need to sync before taking a peek at cb_complete bit */
 	pci_dma_sync_single_for_cpu(nic->pdev, rx->dma_addr,
-				    sizeof(struct rfd), PCI_DMA_FROMDEVICE);
+		sizeof(struct rfd), PCI_DMA_FROMDEVICE);
 	rfd_status = le16_to_cpu(rfd->status);

 	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);
@@ -1442,7 +1442,7 @@ static inline int e100_rx_indicate(struc

 	/* Get data */
 	pci_unmap_single(nic->pdev, rx->dma_addr,
-			 RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);

 	/* Pull off the RFD and put the actual data (minus eth hdr) */
 	skb_reserve(skb, sizeof(struct rfd));
