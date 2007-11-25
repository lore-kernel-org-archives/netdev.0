From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.24-rc3, 4GB RAM, swiotlb, r8169, out of space
Date: Sun, 25 Nov 2007 02:27:54 +0100
Message-ID: <20071125012754.GC30759@electric-eye.fr.zoreil.com>
References: <200711242344.49958.alistair@devzero.co.uk> <20071125002510.GA30759@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alistair John Strachan <alistair@devzero.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40387 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752905AbXKYBaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 20:30:55 -0500
Content-Disposition: inline
In-Reply-To: <20071125002510.GA30759@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
> Alistair John Strachan <alistair@devzero.co.uk> :
> [...]
> > The "choke" affects other devices on the system too, notably libata, which 
> > does not recover gracefully. In my logs, I see a stream of:
> > 
> > DMA: Out of SW-IOMMU space for 7222 bytes at device 0000:04:00.0
> > DMA: Out of SW-IOMMU space for 7222 bytes at device 0000:04:00.0
> 
> You are using jumbo frames, aren't you ?

See below for my late night crap. At least it should avoid the driver
issuing Rx/Tx DMA with the single static buffer of lib/swiotlb.c
(io_tlb_overflow_buffer). Ghee.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1f647b9..72a7370 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2262,10 +2262,16 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
 	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
 
+	if (pci_dma_mapping_error(mapping))
+		goto err_kfree_skb;
+
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
 out:
 	return skb;
 
+err_kfree_skb:
+	dev_kfree_skb(skb);
+	skb = NULL;
 err_out:
 	rtl8169_make_unusable_by_asic(desc);
 	goto out;
@@ -2486,6 +2492,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		dma_addr_t mapping;
 		u32 status, len;
 		void *addr;
+		int rc;
 
 		entry = (entry + 1) % NUM_TX_DESC;
 
@@ -2493,6 +2500,22 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		len = frag->size;
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
 		mapping = pci_map_single(tp->pci_dev, addr, len, PCI_DMA_TODEVICE);
+		rc = pci_dma_mapping_error(mapping);
+		if (unlikely(rc < 0)) {
+			while (cur_frag-- > 0) {
+				frag = info->frags + cur_frag;
+				entry = (entry - 1) % NUM_TX_DESC;
+				txd = tp->TxDescArray + entry;
+				len = frag->size;
+				mapping = le64_to_cpu(txd->addr);
+				pci_unmap_single(tp->pci_dev, mapping, len,
+						 PCI_DMA_TODEVICE);
+				txd->opts1 = 0x00;
+				txd->opts2 = 0x00;
+				txd->addr = 0x00;
+			}
+			return rc;
+		}
 
 		/* anti gcc 2.95.3 bugware (sic) */
 		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
@@ -2534,13 +2557,13 @@ static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned int frags, entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned int entry = tp->cur_tx % NUM_TX_DESC;
 	struct TxDesc *txd = tp->TxDescArray + entry;
 	void __iomem *ioaddr = tp->mmio_addr;
 	dma_addr_t mapping;
 	u32 status, len;
 	u32 opts1;
-	int ret = NETDEV_TX_OK;
+	int frags, ret = NETDEV_TX_OK;
 
 	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
 		if (netif_msg_drv(tp)) {
@@ -2557,7 +2580,11 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	opts1 = DescOwn | rtl8169_tso_csum(skb, dev);
 
 	frags = rtl8169_xmit_frags(tp, skb, opts1);
-	if (frags) {
+	if (frags < 0) {
+		printk(KERN_ERR "%s: PCI mapping failure (%d).\n", dev->name,
+		       frags);
+		goto err_busy;
+	} else if (frags > 0) {
 		len = skb_headlen(skb);
 		opts1 |= FirstFrag;
 	} else {
@@ -2605,6 +2632,7 @@ out:
 
 err_stop:
 	netif_stop_queue(dev);
+err_busy:
 	ret = NETDEV_TX_BUSY;
 err_update_stats:
 	dev->stats.tx_dropped++;
