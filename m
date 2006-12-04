From: Stephen Hemminger <shemminger@osdl.org>
Subject: network devices don't handle pci_dma_mapping_error()'s
Date: Mon, 4 Dec 2006 10:39:49 -0800
Message-ID: <20061204103949.3d05b1ff@freekitty>
References: <200612011340.kB1DeEhR014690@dut39.unminc.com>
	<45711007.5030704@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:50390 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937228AbWLDSkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 13:40:20 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45711007.5030704@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 02 Dec 2006 00:32:55 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> Amit S. Kale wrote:
> > NetXen: 1G/10G Ethernet driver updates
> > 	- These fixes take care of driver on machines with >4G memory
> > 	- Driver cleanup
> > 
> > Signed-off-by: Amit S. Kale <amitkale@netxen.com>
> > 
> >  netxen_nic.h          |   29 +++++--
> >  netxen_nic_ethtool.c  |   19 ++--
> >  netxen_nic_hw.c       |    4 
> >  netxen_nic_hw.h       |    4 
> >  netxen_nic_init.c     |   51 +++++++++++-
> >  netxen_nic_isr.c      |    3 
> >  netxen_nic_main.c     |  204 +++++++++++++++++++++++++++++++++++++++++++++++---
> >  netxen_nic_phan_reg.h |   10 +-
> 
> NAK, the driver itself should not be doing bounce buffering
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I notice that no current network driver handles dma mapping errors.
Might that be part of the problem.  On i386, this never happens, and
it would be rare on most others.

Why don't drivers do some checking/unwind.  Here is what it would look like on
Tx for sky2...

--- sky2.orig/drivers/net/sky2.c	2006-12-04 10:12:16.000000000 -0800
+++ sky2/drivers/net/sky2.c	2006-12-04 10:37:42.000000000 -0800
@@ -1277,6 +1277,38 @@
 	return count;
 }
 
+
+static inline void tx_le_done(struct sky2_port *sky2, unsigned idx)
+{
+	struct pci_dev *pdev = sky2->hw->pdev;
+	struct sky2_tx_le *le = sky2->tx_le + idx;
+	struct tx_ring_info *re = sky2->tx_ring + idx;
+
+	switch(le->opcode & ~HW_OWNER) {
+	case OP_LARGESEND:
+	case OP_PACKET:
+		pci_unmap_single(pdev,
+				 pci_unmap_addr(re, mapaddr),
+				 pci_unmap_len(re, maplen),
+				 PCI_DMA_TODEVICE);
+		break;
+	case OP_BUFFER:
+		pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
+			       pci_unmap_len(re, maplen),
+			       PCI_DMA_TODEVICE);
+		break;
+	}
+
+	if (le->ctrl & EOP) {
+		if (unlikely(netif_msg_tx_done(sky2)))
+			printk(KERN_DEBUG "%s: tx done %u\n", sky2->netdev->name,
+			       idx);
+		dev_kfree_skb_any(re->skb);
+	}
+
+	le->opcode = 0;	/* paranoia */
+}
+
 /*
  * Put one packet in ring for transmit.
  * A single packet can generate multiple list elements, and
@@ -1292,7 +1324,7 @@
 	unsigned i, len;
 	dma_addr_t mapping;
 	u32 addr64;
-	u16 mss;
+	u16 mss, first;
 	u8 ctrl;
 
  	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
@@ -1303,7 +1335,13 @@
 		       dev->name, sky2->tx_prod, skb->len);
 
 	len = skb_headlen(skb);
+	first = sky2->tx_prod;
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(mapping)) {
+		printk(KERN_INFO "%s: tx dma mapping error\n", dev->name);
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
 	addr64 = high32(mapping);
 
 	/* Send high bits if changed or crosses boundary */
@@ -1383,6 +1421,10 @@
 
 		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
+
+		if (pci_dma_mapping_error(mapping))
+			goto map_error;
+
 		addr64 = high32(mapping);
 		if (addr64 != sky2->tx_addr64) {
 			le = get_tx_le(sky2);
@@ -1413,6 +1455,15 @@
 
 	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
+
+map_error:
+	/* map failure on fragmented send, free work from first..sky2->tx_prod */
+	printk(KERN_INFO "%s: tx dma page mapping error\n", dev->name);
+	le->ctrl |= EOP;
+	for (i = first; i != sky2->tx_prod; i = RING_NEXT(i, TX_RING_SIZE))
+		tx_le_done(sky2, i);
+	sky2->tx_prod = first;
+	return NETDEV_TX_OK;
 }
 
 /*
@@ -1424,40 +1475,12 @@
 static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 {
 	struct net_device *dev = sky2->netdev;
-	struct pci_dev *pdev = sky2->hw->pdev;
 	unsigned idx;
 
 	BUG_ON(done >= TX_RING_SIZE);
 
-	for (idx = sky2->tx_cons; idx != done;
-	     idx = RING_NEXT(idx, TX_RING_SIZE)) {
-		struct sky2_tx_le *le = sky2->tx_le + idx;
-		struct tx_ring_info *re = sky2->tx_ring + idx;
-
-		switch(le->opcode & ~HW_OWNER) {
-		case OP_LARGESEND:
-		case OP_PACKET:
-			pci_unmap_single(pdev,
-					 pci_unmap_addr(re, mapaddr),
-					 pci_unmap_len(re, maplen),
-					 PCI_DMA_TODEVICE);
-			break;
-		case OP_BUFFER:
-			pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
-				       pci_unmap_len(re, maplen),
-				       PCI_DMA_TODEVICE);
-			break;
-		}
-
-		if (le->ctrl & EOP) {
-			if (unlikely(netif_msg_tx_done(sky2)))
-				printk(KERN_DEBUG "%s: tx done %u\n",
-				       dev->name, idx);
-			dev_kfree_skb_any(re->skb);
-		}
-
-		le->opcode = 0;	/* paranoia */
-	}
+	for (idx = sky2->tx_cons; idx != done; idx = RING_NEXT(idx, TX_RING_SIZE))
+		tx_le_done(sky2, idx);
 
 	sky2->tx_cons = idx;
 	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
