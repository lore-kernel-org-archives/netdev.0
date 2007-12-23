From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Sun, 23 Dec 2007 00:33:14 -0500
Message-ID: <20071223053314.GA31966@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:42299 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbXLWFdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2007 00:33:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A couple [minorly] notable wireless bug fixes, and plenty of viro fixes
for obscure issues :)


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/dl2k.c                          |   51 +++---
 drivers/net/dl2k.h                          |    6 +-
 drivers/net/fec_mpc52xx.c                   |    5 +-
 drivers/net/macb.c                          |   25 +++-
 drivers/net/pcmcia/3c574_cs.c               |   10 +-
 drivers/net/pcmcia/3c589_cs.c               |    9 +-
 drivers/net/r8169.c                         |    4 +-
 drivers/net/rrunner.c                       |   49 +++---
 drivers/net/rrunner.h                       |    2 +-
 drivers/net/tokenring/3c359.c               |   90 +++++------
 drivers/net/tokenring/3c359.h               |   38 +++---
 drivers/net/typhoon.c                       |   45 +++---
 drivers/net/typhoon.h                       |   15 ++-
 drivers/net/usb/asix.c                      |  235 ++++++++++++---------------
 drivers/net/wan/cycx_x25.c                  |   12 +-
 drivers/net/wireless/Kconfig                |   51 ++++++
 drivers/net/wireless/ipw2200.c              |   13 ++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   18 +--
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   18 +--
 drivers/net/wireless/rtl8187_dev.c          |    2 +
 drivers/net/yellowfin.c                     |   25 ++--
 21 files changed, 387 insertions(+), 336 deletions(-)

Al Viro (15):
      typhoon: endianness bug in tx/rx byte counters
      typhoon: missing le32_to_cpu() in get_drvinfo
      typhoon: set_settings broken on big-endian
      typhoon: missed rx overruns on big-endian
      typhoon: memory corruptor on big-endian if TSO is enabled
      typhoon: trivial endianness annotations
      cycx: annotations and fixes (.24 fodder?)
      asix fixes
      yellowfin: annotations and fixes (.24 fodder?)
      dl2k endianness fixes (.24 fodder?)
      r8169 endianness
      rrunner: use offsetof() instead of homegrown insanity
      3c574 and 3c589 endianness fixes (.24?)
      fec_mpc52xx: write in C...
      3c359 endianness annotations and fixes

Gregory CLEMENT (1):
      MACB: clear transmit buffers properly on transmit underrun

Matthias Mueller (1):
      rtl8187: Add USB ID for Sitecom WL-168 v1 001

Michael Wu (1):
      p54: add Kconfig description

Reinette Chatre (1):
      ipw2200: prevent alloc of unspecified size on stack

Zhu Yi (1):
      iwlwifi: fix possible priv->mutex deadlock during suspend

diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 5066beb..47cce9c 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -332,7 +332,7 @@ parse_eeprom (struct net_device *dev)
 #endif
 	/* Read eeprom */
 	for (i = 0; i < 128; i++) {
-		((u16 *) sromdata)[i] = le16_to_cpu (read_eeprom (ioaddr, i));
+		((__le16 *) sromdata)[i] = cpu_to_le16(read_eeprom (ioaddr, i));
 	}
 #ifdef	MEM_MAPPING
 	ioaddr = dev->base_addr;
@@ -516,7 +516,7 @@ rio_timer (unsigned long data)
 					  PCI_DMA_FROMDEVICE));
 			}
 			np->rx_ring[entry].fraginfo |=
-			    cpu_to_le64 (np->rx_buf_sz) << 48;
+			    cpu_to_le64((u64)np->rx_buf_sz << 48);
 			np->rx_ring[entry].status = 0;
 		} /* end for */
 	} /* end if */
@@ -584,11 +584,11 @@ alloc_list (struct net_device *dev)
 		    cpu_to_le64 ( pci_map_single (
 			 	  np->pdev, skb->data, np->rx_buf_sz,
 				  PCI_DMA_FROMDEVICE));
-		np->rx_ring[i].fraginfo |= cpu_to_le64 (np->rx_buf_sz) << 48;
+		np->rx_ring[i].fraginfo |= cpu_to_le64((u64)np->rx_buf_sz << 48);
 	}
 
 	/* Set RFDListPtr */
-	writel (cpu_to_le32 (np->rx_ring_dma), dev->base_addr + RFDListPtr0);
+	writel (np->rx_ring_dma, dev->base_addr + RFDListPtr0);
 	writel (0, dev->base_addr + RFDListPtr1);
 
 	return;
@@ -620,15 +620,14 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 	}
 #endif
 	if (np->vlan) {
-		tfc_vlan_tag =
-		    cpu_to_le64 (VLANTagInsert) |
-		    (cpu_to_le64 (np->vlan) << 32) |
-		    (cpu_to_le64 (skb->priority) << 45);
+		tfc_vlan_tag = VLANTagInsert |
+		    ((u64)np->vlan << 32) |
+		    ((u64)skb->priority << 45);
 	}
 	txdesc->fraginfo = cpu_to_le64 (pci_map_single (np->pdev, skb->data,
 							skb->len,
 							PCI_DMA_TODEVICE));
-	txdesc->fraginfo |= cpu_to_le64 (skb->len) << 48;
+	txdesc->fraginfo |= cpu_to_le64((u64)skb->len << 48);
 
 	/* DL2K bug: DMA fails to get next descriptor ptr in 10Mbps mode
 	 * Work around: Always use 1 descriptor in 10Mbps mode */
@@ -708,6 +707,11 @@ rio_interrupt (int irq, void *dev_instance)
 	return IRQ_RETVAL(handled);
 }
 
+static inline dma_addr_t desc_to_dma(struct netdev_desc *desc)
+{
+	return le64_to_cpu(desc->fraginfo) & DMA_48BIT_MASK;
+}
+
 static void
 rio_free_tx (struct net_device *dev, int irq)
 {
@@ -725,11 +729,11 @@ rio_free_tx (struct net_device *dev, int irq)
 	while (entry != np->cur_tx) {
 		struct sk_buff *skb;
 
-		if (!(np->tx_ring[entry].status & TFDDone))
+		if (!(np->tx_ring[entry].status & cpu_to_le64(TFDDone)))
 			break;
 		skb = np->tx_skbuff[entry];
 		pci_unmap_single (np->pdev,
-				  np->tx_ring[entry].fraginfo & DMA_48BIT_MASK,
+				  desc_to_dma(&np->tx_ring[entry]),
 				  skb->len, PCI_DMA_TODEVICE);
 		if (irq)
 			dev_kfree_skb_irq (skb);
@@ -831,13 +835,14 @@ receive_packet (struct net_device *dev)
 		int pkt_len;
 		u64 frame_status;
 
-		if (!(desc->status & RFDDone) ||
-		    !(desc->status & FrameStart) || !(desc->status & FrameEnd))
+		if (!(desc->status & cpu_to_le64(RFDDone)) ||
+		    !(desc->status & cpu_to_le64(FrameStart)) ||
+		    !(desc->status & cpu_to_le64(FrameEnd)))
 			break;
 
 		/* Chip omits the CRC. */
-		pkt_len = le64_to_cpu (desc->status & 0xffff);
-		frame_status = le64_to_cpu (desc->status);
+		frame_status = le64_to_cpu(desc->status);
+		pkt_len = frame_status & 0xffff;
 		if (--cnt < 0)
 			break;
 		/* Update rx error statistics, drop packet. */
@@ -857,15 +862,14 @@ receive_packet (struct net_device *dev)
 			/* Small skbuffs for short packets */
 			if (pkt_len > copy_thresh) {
 				pci_unmap_single (np->pdev,
-						  desc->fraginfo & DMA_48BIT_MASK,
+						  desc_to_dma(desc),
 						  np->rx_buf_sz,
 						  PCI_DMA_FROMDEVICE);
 				skb_put (skb = np->rx_skbuff[entry], pkt_len);
 				np->rx_skbuff[entry] = NULL;
 			} else if ((skb = dev_alloc_skb (pkt_len + 2)) != NULL) {
 				pci_dma_sync_single_for_cpu(np->pdev,
-				  			    desc->fraginfo &
-							    	DMA_48BIT_MASK,
+							    desc_to_dma(desc),
 							    np->rx_buf_sz,
 							    PCI_DMA_FROMDEVICE);
 				/* 16 byte align the IP header */
@@ -875,8 +879,7 @@ receive_packet (struct net_device *dev)
 						  pkt_len);
 				skb_put (skb, pkt_len);
 				pci_dma_sync_single_for_device(np->pdev,
-				  			       desc->fraginfo &
-							       	 DMA_48BIT_MASK,
+							       desc_to_dma(desc),
 							       np->rx_buf_sz,
 							       PCI_DMA_FROMDEVICE);
 			}
@@ -919,7 +922,7 @@ receive_packet (struct net_device *dev)
 					  PCI_DMA_FROMDEVICE));
 		}
 		np->rx_ring[entry].fraginfo |=
-		    cpu_to_le64 (np->rx_buf_sz) << 48;
+		    cpu_to_le64((u64)np->rx_buf_sz << 48);
 		np->rx_ring[entry].status = 0;
 		entry = (entry + 1) % RX_RING_SIZE;
 	}
@@ -1121,7 +1124,7 @@ set_multicast (struct net_device *dev)
 
 	hash_table[0] = hash_table[1] = 0;
 	/* RxFlowcontrol DA: 01-80-C2-00-00-01. Hash index=0x39 */
-	hash_table[1] |= cpu_to_le32(0x02000000);
+	hash_table[1] |= 0x02000000;
 	if (dev->flags & IFF_PROMISC) {
 		/* Receive all frames promiscuously. */
 		rx_mode = ReceiveAllFrames;
@@ -1762,7 +1765,7 @@ rio_close (struct net_device *dev)
 		skb = np->rx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pdev,
-					 np->rx_ring[i].fraginfo & DMA_48BIT_MASK,
+					 desc_to_dma(&np->rx_ring[i]),
 					 skb->len, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb (skb);
 			np->rx_skbuff[i] = NULL;
@@ -1772,7 +1775,7 @@ rio_close (struct net_device *dev)
 		skb = np->tx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pdev,
-					 np->tx_ring[i].fraginfo & DMA_48BIT_MASK,
+					 desc_to_dma(&np->tx_ring[i]),
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb (skb);
 			np->tx_skbuff[i] = NULL;
diff --git a/drivers/net/dl2k.h b/drivers/net/dl2k.h
index 5b80177..014b77c 100644
--- a/drivers/net/dl2k.h
+++ b/drivers/net/dl2k.h
@@ -633,9 +633,9 @@ struct mii_data {
 
 /* The Rx and Tx buffer descriptors. */
 struct netdev_desc {
-	u64 next_desc;
-	u64 status;
-	u64 fraginfo;
+	__le64 next_desc;
+	__le64 status;
+	__le64 fraginfo;
 };
 
 #define PRIV_ALIGN	15	/* Required alignment mask */
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 79f7ead..f91ee70 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -568,8 +568,9 @@ static void mpc52xx_fec_reset_stats(struct net_device *dev)
 	struct mpc52xx_fec __iomem *fec = priv->fec;
 
 	out_be32(&fec->mib_control, FEC_MIB_DISABLE);
-	memset_io(&fec->rmon_t_drop, 0,	(__force u32)&fec->reserved10 -
-			(__force u32)&fec->rmon_t_drop);
+	memset_io(&fec->rmon_t_drop, 0,
+		   offsetof(struct mpc52xx_fec, reserved10) -
+		   offsetof(struct mpc52xx_fec, rmon_t_drop));
 	out_be32(&fec->mib_control, 0);
 
 	memset(&dev->stats, 0, sizeof(dev->stats));
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 047ea7b..e10528e 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -307,8 +307,31 @@ static void macb_tx(struct macb *bp)
 		(unsigned long)status);
 
 	if (status & MACB_BIT(UND)) {
+		int i;
 		printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
-		       bp->dev->name);
+			bp->dev->name);
+
+		head = bp->tx_head;
+
+		/*Mark all the buffer as used to avoid sending a lost buffer*/
+		for (i = 0; i < TX_RING_SIZE; i++)
+			bp->tx_ring[i].ctrl = MACB_BIT(TX_USED);
+
+		/* free transmit buffer in upper layer*/
+		for (tail = bp->tx_tail; tail != head; tail = NEXT_TX(tail)) {
+			struct ring_info *rp = &bp->tx_skb[tail];
+			struct sk_buff *skb = rp->skb;
+
+			BUG_ON(skb == NULL);
+
+			rmb();
+
+			dma_unmap_single(&bp->pdev->dev, rp->mapping, skb->len,
+							 DMA_TO_DEVICE);
+			rp->skb = NULL;
+			dev_kfree_skb_irq(skb);
+		}
+
 		bp->tx_head = bp->tx_tail = 0;
 	}
 
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index ad134a6..2881777 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -337,15 +337,15 @@ static int tc574_config(struct pcmcia_device *link)
 	struct net_device *dev = link->priv;
 	struct el3_private *lp = netdev_priv(dev);
 	tuple_t tuple;
-	unsigned short buf[32];
+	__le16 buf[32];
 	int last_fn, last_ret, i, j;
 	kio_addr_t ioaddr;
-	u16 *phys_addr;
+	__be16 *phys_addr;
 	char *cardname;
 	union wn3_config config;
 	DECLARE_MAC_BUF(mac);
 
-	phys_addr = (u16 *)dev->dev_addr;
+	phys_addr = (__be16 *)dev->dev_addr;
 
 	DEBUG(0, "3c574_config(0x%p)\n", link);
 
@@ -378,12 +378,12 @@ static int tc574_config(struct pcmcia_device *link)
 	if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) {
 		pcmcia_get_tuple_data(link, &tuple);
 		for (i = 0; i < 3; i++)
-			phys_addr[i] = htons(buf[i]);
+			phys_addr[i] = htons(le16_to_cpu(buf[i]));
 	} else {
 		EL3WINDOW(0);
 		for (i = 0; i < 3; i++)
 			phys_addr[i] = htons(read_eeprom(ioaddr, i + 10));
-		if (phys_addr[0] == 0x6060) {
+		if (phys_addr[0] == htons(0x6060)) {
 			printk(KERN_NOTICE "3c574_cs: IO port conflict at 0x%03lx"
 				   "-0x%03lx\n", dev->base_addr, dev->base_addr+15);
 			goto failed;
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index a98fe07..e862d14 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -251,7 +251,8 @@ static int tc589_config(struct pcmcia_device *link)
     struct net_device *dev = link->priv;
     struct el3_private *lp = netdev_priv(dev);
     tuple_t tuple;
-    u16 buf[32], *phys_addr;
+    __le16 buf[32];
+    __be16 *phys_addr;
     int last_fn, last_ret, i, j, multi = 0, fifo;
     kio_addr_t ioaddr;
     char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
@@ -259,7 +260,7 @@ static int tc589_config(struct pcmcia_device *link)
     
     DEBUG(0, "3c589_config(0x%p)\n", link);
 
-    phys_addr = (u16 *)dev->dev_addr;
+    phys_addr = (__be16 *)dev->dev_addr;
     tuple.Attributes = 0;
     tuple.TupleData = (cisdata_t *)buf;
     tuple.TupleDataMax = sizeof(buf);
@@ -298,11 +299,11 @@ static int tc589_config(struct pcmcia_device *link)
     if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) {
 	pcmcia_get_tuple_data(link, &tuple);
 	for (i = 0; i < 3; i++)
-	    phys_addr[i] = htons(buf[i]);
+	    phys_addr[i] = htons(le16_to_cpu(buf[i]));
     } else {
 	for (i = 0; i < 3; i++)
 	    phys_addr[i] = htons(read_eeprom(ioaddr, i));
-	if (phys_addr[0] == 0x6060) {
+	if (phys_addr[0] == htons(0x6060)) {
 	    printk(KERN_ERR "3c589_cs: IO port conflict at 0x%03lx"
 		   "-0x%03lx\n", dev->base_addr, dev->base_addr+15);
 	    goto failed;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1f647b9..5863190 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2211,7 +2211,7 @@ out:
 
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
-	desc->addr = 0x0badbadbadbadbadull;
+	desc->addr = cpu_to_le64(0x0badbadbadbadbadull);
 	desc->opts1 &= ~cpu_to_le32(DescOwn | RsvdMask);
 }
 
@@ -2835,7 +2835,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		}
 
 		/* Work around for AMD plateform. */
-		if ((desc->opts2 & 0xfffe000) &&
+		if ((desc->opts2 & cpu_to_le32(0xfffe000)) &&
 		    (tp->mac_version == RTL_GIGA_MAC_VER_05)) {
 			desc->opts2 = 0;
 			cur_rx++;
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 73a7e65..55a590a 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -294,7 +294,6 @@ static int rr_reset(struct net_device *dev)
 {
 	struct rr_private *rrpriv;
 	struct rr_regs __iomem *regs;
-	struct eeprom *hw = NULL;
 	u32 start_pc;
 	int i;
 
@@ -381,7 +380,8 @@ static int rr_reset(struct net_device *dev)
 	writel(RBURST_64|WBURST_64, &regs->PciState);
 	wmb();
 
-	start_pc = rr_read_eeprom_word(rrpriv, &hw->rncd_info.FwStart);
+	start_pc = rr_read_eeprom_word(rrpriv,
+			offsetof(struct eeprom, rncd_info.FwStart));
 
 #if (DEBUG > 1)
 	printk("%s: Executing firmware at address 0x%06x\n",
@@ -438,12 +438,12 @@ static unsigned int rr_read_eeprom(struct rr_private *rrpriv,
  * it to our CPU byte-order.
  */
 static u32 rr_read_eeprom_word(struct rr_private *rrpriv,
-			    void * offset)
+			    size_t offset)
 {
-	u32 word;
+	__be32 word;
 
-	if ((rr_read_eeprom(rrpriv, (unsigned long)offset,
-			    (char *)&word, 4) == 4))
+	if ((rr_read_eeprom(rrpriv, offset,
+			    (unsigned char *)&word, 4) == 4))
 		return be32_to_cpu(word);
 	return 0;
 }
@@ -510,7 +510,6 @@ static int __devinit rr_init(struct net_device *dev)
 {
 	struct rr_private *rrpriv;
 	struct rr_regs __iomem *regs;
-	struct eeprom *hw = NULL;
 	u32 sram_size, rev;
 	DECLARE_MAC_BUF(mac);
 
@@ -545,14 +544,14 @@ static int __devinit rr_init(struct net_device *dev)
 	 * other method I've seen.  -VAL
 	 */
 
-	*(u16 *)(dev->dev_addr) =
-	  htons(rr_read_eeprom_word(rrpriv, &hw->manf.BoardULA));
-	*(u32 *)(dev->dev_addr+2) =
-	  htonl(rr_read_eeprom_word(rrpriv, &hw->manf.BoardULA[4]));
+	*(__be16 *)(dev->dev_addr) =
+	  htons(rr_read_eeprom_word(rrpriv, offsetof(struct eeprom, manf.BoardULA)));
+	*(__be32 *)(dev->dev_addr+2) =
+	  htonl(rr_read_eeprom_word(rrpriv, offsetof(struct eeprom, manf.BoardULA[4])));
 
 	printk("  MAC: %s\n", print_mac(mac, dev->dev_addr));
 
-	sram_size = rr_read_eeprom_word(rrpriv, (void *)8);
+	sram_size = rr_read_eeprom_word(rrpriv, 8);
 	printk("  SRAM size 0x%06x\n", sram_size);
 
 	return 0;
@@ -1477,11 +1476,10 @@ static int rr_load_firmware(struct net_device *dev)
 {
 	struct rr_private *rrpriv;
 	struct rr_regs __iomem *regs;
-	unsigned long eptr, segptr;
+	size_t eptr, segptr;
 	int i, j;
 	u32 localctrl, sptr, len, tmp;
 	u32 p2len, p2size, nr_seg, revision, io, sram_size;
-	struct eeprom *hw = NULL;
 
 	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
@@ -1509,7 +1507,7 @@ static int rr_load_firmware(struct net_device *dev)
 	 */
 	io = readl(&regs->ExtIo);
 	writel(0, &regs->ExtIo);
-	sram_size = rr_read_eeprom_word(rrpriv, (void *)8);
+	sram_size = rr_read_eeprom_word(rrpriv, 8);
 
 	for (i = 200; i < sram_size / 4; i++){
 		writel(i * 4, &regs->WinBase);
@@ -1520,13 +1518,13 @@ static int rr_load_firmware(struct net_device *dev)
 	writel(io, &regs->ExtIo);
 	mb();
 
-	eptr = (unsigned long)rr_read_eeprom_word(rrpriv,
-					       &hw->rncd_info.AddrRunCodeSegs);
+	eptr = rr_read_eeprom_word(rrpriv,
+		       offsetof(struct eeprom, rncd_info.AddrRunCodeSegs));
 	eptr = ((eptr & 0x1fffff) >> 3);
 
-	p2len = rr_read_eeprom_word(rrpriv, (void *)(0x83*4));
+	p2len = rr_read_eeprom_word(rrpriv, 0x83*4);
 	p2len = (p2len << 2);
-	p2size = rr_read_eeprom_word(rrpriv, (void *)(0x84*4));
+	p2size = rr_read_eeprom_word(rrpriv, 0x84*4);
 	p2size = ((p2size & 0x1fffff) >> 3);
 
 	if ((eptr < p2size) || (eptr > (p2size + p2len))){
@@ -1534,7 +1532,8 @@ static int rr_load_firmware(struct net_device *dev)
 		goto out;
 	}
 
-	revision = rr_read_eeprom_word(rrpriv, &hw->manf.HeaderFmt);
+	revision = rr_read_eeprom_word(rrpriv,
+			offsetof(struct eeprom, manf.HeaderFmt));
 
 	if (revision != 1){
 		printk("%s: invalid firmware format (%i)\n",
@@ -1542,18 +1541,18 @@ static int rr_load_firmware(struct net_device *dev)
 		goto out;
 	}
 
-	nr_seg = rr_read_eeprom_word(rrpriv, (void *)eptr);
+	nr_seg = rr_read_eeprom_word(rrpriv, eptr);
 	eptr +=4;
 #if (DEBUG > 1)
 	printk("%s: nr_seg %i\n", dev->name, nr_seg);
 #endif
 
 	for (i = 0; i < nr_seg; i++){
-		sptr = rr_read_eeprom_word(rrpriv, (void *)eptr);
+		sptr = rr_read_eeprom_word(rrpriv, eptr);
 		eptr += 4;
-		len = rr_read_eeprom_word(rrpriv, (void *)eptr);
+		len = rr_read_eeprom_word(rrpriv, eptr);
 		eptr += 4;
-		segptr = (unsigned long)rr_read_eeprom_word(rrpriv, (void *)eptr);
+		segptr = rr_read_eeprom_word(rrpriv, eptr);
 		segptr = ((segptr & 0x1fffff) >> 3);
 		eptr += 4;
 #if (DEBUG > 1)
@@ -1561,7 +1560,7 @@ static int rr_load_firmware(struct net_device *dev)
 		       dev->name, i, sptr, len, segptr);
 #endif
 		for (j = 0; j < len; j++){
-			tmp = rr_read_eeprom_word(rrpriv, (void *)segptr);
+			tmp = rr_read_eeprom_word(rrpriv, segptr);
 			writel(sptr, &regs->WinBase);
 			mb();
 			writel(tmp, &regs->WinData);
diff --git a/drivers/net/rrunner.h b/drivers/net/rrunner.h
index 6a79825..6173f11 100644
--- a/drivers/net/rrunner.h
+++ b/drivers/net/rrunner.h
@@ -838,7 +838,7 @@ static unsigned int rr_read_eeprom(struct rr_private *rrpriv,
 				   unsigned long offset,
 				   unsigned char *buf,
 				   unsigned long length);
-static u32 rr_read_eeprom_word(struct rr_private *rrpriv, void * offset);
+static u32 rr_read_eeprom_word(struct rr_private *rrpriv, size_t offset);
 static int rr_load_firmware(struct net_device *dev);
 static inline void rr_raz_tx(struct rr_private *, struct net_device *);
 static inline void rr_raz_rx(struct rr_private *, struct net_device *);
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 5d31519..44a06f8 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -570,7 +570,7 @@ static int xl_open(struct net_device *dev)
 	struct xl_private *xl_priv=netdev_priv(dev);
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 	u8 i ; 
-	u16 hwaddr[3] ; /* Should be u8[6] but we get word return values */
+	__le16 hwaddr[3] ; /* Should be u8[6] but we get word return values */
 	int open_err ;
 
 	u16 switchsettings, switchsettings_eeprom  ;
@@ -580,15 +580,12 @@ static int xl_open(struct net_device *dev)
 	}
 
 	/* 
-	 * Read the information from the EEPROM that we need. I know we
- 	 * should use ntohs, but the word gets stored reversed in the 16
-	 * bit field anyway and it all works its self out when we memcpy
-	 * it into dev->dev_addr. 
+	 * Read the information from the EEPROM that we need.
 	 */
 	
-	hwaddr[0] = xl_ee_read(dev,0x10) ; 
-	hwaddr[1] = xl_ee_read(dev,0x11) ; 
-	hwaddr[2] = xl_ee_read(dev,0x12) ; 
+	hwaddr[0] = cpu_to_le16(xl_ee_read(dev,0x10));
+	hwaddr[1] = cpu_to_le16(xl_ee_read(dev,0x11));
+	hwaddr[2] = cpu_to_le16(xl_ee_read(dev,0x12));
 
 	/* Ring speed */
 
@@ -665,8 +662,8 @@ static int xl_open(struct net_device *dev)
 			break ; 
 
 		skb->dev = dev ; 
-		xl_priv->xl_rx_ring[i].upfragaddr = pci_map_single(xl_priv->pdev, skb->data,xl_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE) ; 
-		xl_priv->xl_rx_ring[i].upfraglen = xl_priv->pkt_buf_sz | RXUPLASTFRAG;
+		xl_priv->xl_rx_ring[i].upfragaddr = cpu_to_le32(pci_map_single(xl_priv->pdev, skb->data,xl_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE));
+		xl_priv->xl_rx_ring[i].upfraglen = cpu_to_le32(xl_priv->pkt_buf_sz) | RXUPLASTFRAG;
 		xl_priv->rx_ring_skb[i] = skb ; 	
 	}
 
@@ -680,7 +677,7 @@ static int xl_open(struct net_device *dev)
 	xl_priv->rx_ring_tail = 0 ; 
 	xl_priv->rx_ring_dma_addr = pci_map_single(xl_priv->pdev,xl_priv->xl_rx_ring, sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE, PCI_DMA_TODEVICE) ; 
 	for (i=0;i<(xl_priv->rx_ring_no-1);i++) { 
-		xl_priv->xl_rx_ring[i].upnextptr = xl_priv->rx_ring_dma_addr + (sizeof (struct xl_rx_desc) * (i+1)) ; 
+		xl_priv->xl_rx_ring[i].upnextptr = cpu_to_le32(xl_priv->rx_ring_dma_addr + (sizeof (struct xl_rx_desc) * (i+1)));
 	} 
 	xl_priv->xl_rx_ring[i].upnextptr = 0 ; 
 
@@ -698,7 +695,7 @@ static int xl_open(struct net_device *dev)
  	 * Setup the first dummy DPD entry for polling to start working.
 	 */
 
-	xl_priv->xl_tx_ring[0].framestartheader = TXDPDEMPTY ; 
+	xl_priv->xl_tx_ring[0].framestartheader = TXDPDEMPTY;
 	xl_priv->xl_tx_ring[0].buffer = 0 ; 
 	xl_priv->xl_tx_ring[0].buffer_length = 0 ; 
 	xl_priv->xl_tx_ring[0].dnnextptr = 0 ; 
@@ -811,17 +808,17 @@ static int xl_open_hw(struct net_device *dev)
 		return open_err ; 
 	} else { 
 		writel( (MEM_WORD_READ | 0xD0000 | xl_priv->srb) + 8, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-		xl_priv->asb = ntohs(readw(xl_mmio + MMIO_MACDATA)) ; 
+		xl_priv->asb = swab16(readw(xl_mmio + MMIO_MACDATA)) ;
 		printk(KERN_INFO "%s: Adapter Opened Details: ",dev->name) ; 
 		printk("ASB: %04x",xl_priv->asb ) ; 
 		writel( (MEM_WORD_READ | 0xD0000 | xl_priv->srb) + 10, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-		printk(", SRB: %04x",ntohs(readw(xl_mmio + MMIO_MACDATA)) ) ; 
+		printk(", SRB: %04x",swab16(readw(xl_mmio + MMIO_MACDATA)) ) ;
  
 		writel( (MEM_WORD_READ | 0xD0000 | xl_priv->srb) + 12, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-		xl_priv->arb = ntohs(readw(xl_mmio + MMIO_MACDATA)) ; 
+		xl_priv->arb = swab16(readw(xl_mmio + MMIO_MACDATA)) ;
 		printk(", ARB: %04x \n",xl_priv->arb ) ; 
 		writel( (MEM_WORD_READ | 0xD0000 | xl_priv->srb) + 14, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-		vsoff = ntohs(readw(xl_mmio + MMIO_MACDATA)) ; 
+		vsoff = swab16(readw(xl_mmio + MMIO_MACDATA)) ;
 
 		/* 
 		 * Interesting, sending the individual characters directly to printk was causing klogd to use
@@ -873,16 +870,15 @@ static int xl_open_hw(struct net_device *dev)
 static void adv_rx_ring(struct net_device *dev) /* Advance rx_ring, cut down on bloat in xl_rx */ 
 {
 	struct xl_private *xl_priv=netdev_priv(dev);
-	int prev_ring_loc ; 
-
-	prev_ring_loc = (xl_priv->rx_ring_tail + XL_RX_RING_SIZE - 1) & (XL_RX_RING_SIZE - 1);
-	xl_priv->xl_rx_ring[prev_ring_loc].upnextptr = xl_priv->rx_ring_dma_addr + (sizeof (struct xl_rx_desc) * xl_priv->rx_ring_tail) ; 
-	xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].framestatus = 0 ; 
-	xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upnextptr = 0 ; 	
-	xl_priv->rx_ring_tail++ ; 
-	xl_priv->rx_ring_tail &= (XL_RX_RING_SIZE-1) ; 
-
-	return ; 
+	int n = xl_priv->rx_ring_tail;
+	int prev_ring_loc;
+
+	prev_ring_loc = (n + XL_RX_RING_SIZE - 1) & (XL_RX_RING_SIZE - 1);
+	xl_priv->xl_rx_ring[prev_ring_loc].upnextptr = cpu_to_le32(xl_priv->rx_ring_dma_addr + (sizeof (struct xl_rx_desc) * n));
+	xl_priv->xl_rx_ring[n].framestatus = 0;
+	xl_priv->xl_rx_ring[n].upnextptr = 0;
+	xl_priv->rx_ring_tail++;
+	xl_priv->rx_ring_tail &= (XL_RX_RING_SIZE-1);
 }
 
 static void xl_rx(struct net_device *dev)
@@ -914,7 +910,7 @@ static void xl_rx(struct net_device *dev)
 				temp_ring_loc &= (XL_RX_RING_SIZE-1) ; 
 			}
 
-			frame_length = xl_priv->xl_rx_ring[temp_ring_loc].framestatus & 0x7FFF ; 
+			frame_length = le32_to_cpu(xl_priv->xl_rx_ring[temp_ring_loc].framestatus) & 0x7FFF;
 
 			skb = dev_alloc_skb(frame_length) ;
  
@@ -931,29 +927,29 @@ static void xl_rx(struct net_device *dev)
 			}
 	
 			while (xl_priv->rx_ring_tail != temp_ring_loc) { 
-				copy_len = xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfraglen & 0x7FFF ; 
+				copy_len = le32_to_cpu(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfraglen) & 0x7FFF;
 				frame_length -= copy_len ;  
-				pci_dma_sync_single_for_cpu(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
+				pci_dma_sync_single_for_cpu(xl_priv->pdev,le32_to_cpu(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr),xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE);
 				skb_copy_from_linear_data(xl_priv->rx_ring_skb[xl_priv->rx_ring_tail],
 							  skb_put(skb, copy_len),
 							  copy_len);
-				pci_dma_sync_single_for_device(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
+				pci_dma_sync_single_for_device(xl_priv->pdev,le32_to_cpu(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr),xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE);
 				adv_rx_ring(dev) ; 
 			} 
 
 			/* Now we have found the last fragment */
-			pci_dma_sync_single_for_cpu(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
+			pci_dma_sync_single_for_cpu(xl_priv->pdev,le32_to_cpu(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr),xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE);
 			skb_copy_from_linear_data(xl_priv->rx_ring_skb[xl_priv->rx_ring_tail],
 				      skb_put(skb,copy_len), frame_length);
 /*			memcpy(skb_put(skb,frame_length), bus_to_virt(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr), frame_length) ; */
-			pci_dma_sync_single_for_device(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
+			pci_dma_sync_single_for_device(xl_priv->pdev,le32_to_cpu(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr),xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE);
 			adv_rx_ring(dev) ; 
 			skb->protocol = tr_type_trans(skb,dev) ; 
 			netif_rx(skb) ; 
 
 		} else { /* Single Descriptor Used, simply swap buffers over, fast path  */
 
-			frame_length = xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].framestatus & 0x7FFF ; 
+			frame_length = le32_to_cpu(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].framestatus) & 0x7FFF;
 			
 			skb = dev_alloc_skb(xl_priv->pkt_buf_sz) ; 
 
@@ -966,13 +962,13 @@ static void xl_rx(struct net_device *dev)
 			}
 
 			skb2 = xl_priv->rx_ring_skb[xl_priv->rx_ring_tail] ; 
-			pci_unmap_single(xl_priv->pdev, xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr, xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ; 
+			pci_unmap_single(xl_priv->pdev, le32_to_cpu(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr), xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
 			skb_put(skb2, frame_length) ; 
 			skb2->protocol = tr_type_trans(skb2,dev) ; 
 
 			xl_priv->rx_ring_skb[xl_priv->rx_ring_tail] = skb ; 	
-			xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr = pci_map_single(xl_priv->pdev,skb->data,xl_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE) ; 
-			xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfraglen = xl_priv->pkt_buf_sz | RXUPLASTFRAG ; 
+			xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr = cpu_to_le32(pci_map_single(xl_priv->pdev,skb->data,xl_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE));
+			xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfraglen = cpu_to_le32(xl_priv->pkt_buf_sz) | RXUPLASTFRAG;
 			adv_rx_ring(dev) ; 
 			xl_priv->xl_stats.rx_packets++ ; 
 			xl_priv->xl_stats.rx_bytes += frame_length ; 	
@@ -1022,7 +1018,7 @@ static void xl_freemem(struct net_device *dev)
 
 	for (i=0;i<XL_RX_RING_SIZE;i++) {
 		dev_kfree_skb_irq(xl_priv->rx_ring_skb[xl_priv->rx_ring_tail]) ; 
-		pci_unmap_single(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE) ; 
+		pci_unmap_single(xl_priv->pdev,le32_to_cpu(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr),xl_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE);
 		xl_priv->rx_ring_tail++ ; 
 		xl_priv->rx_ring_tail &= XL_RX_RING_SIZE-1; 
 	} 
@@ -1181,9 +1177,9 @@ static int xl_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		txd = &(xl_priv->xl_tx_ring[tx_head]) ; 
 		txd->dnnextptr = 0 ; 
-		txd->framestartheader = skb->len | TXDNINDICATE ; 
-		txd->buffer = pci_map_single(xl_priv->pdev, skb->data, skb->len, PCI_DMA_TODEVICE) ; 
-		txd->buffer_length = skb->len | TXDNFRAGLAST  ; 
+		txd->framestartheader = cpu_to_le32(skb->len) | TXDNINDICATE;
+		txd->buffer = cpu_to_le32(pci_map_single(xl_priv->pdev, skb->data, skb->len, PCI_DMA_TODEVICE));
+		txd->buffer_length = cpu_to_le32(skb->len) | TXDNFRAGLAST;
 		xl_priv->tx_ring_skb[tx_head] = skb ; 
 		xl_priv->xl_stats.tx_packets++ ; 
 		xl_priv->xl_stats.tx_bytes += skb->len ;
@@ -1199,7 +1195,7 @@ static int xl_xmit(struct sk_buff *skb, struct net_device *dev)
 		xl_priv->tx_ring_head &= (XL_TX_RING_SIZE - 1) ;
 		xl_priv->free_ring_entries-- ; 
 
-		xl_priv->xl_tx_ring[tx_prev].dnnextptr = xl_priv->tx_ring_dma_addr + (sizeof (struct xl_tx_desc) * tx_head) ; 
+		xl_priv->xl_tx_ring[tx_prev].dnnextptr = cpu_to_le32(xl_priv->tx_ring_dma_addr + (sizeof (struct xl_tx_desc) * tx_head));
 
 		/* Sneaky, by doing a read on DnListPtr we can force the card to poll on the DnNextPtr */
 		/* readl(xl_mmio + MMIO_DNLISTPTR) ; */
@@ -1237,9 +1233,9 @@ static void xl_dn_comp(struct net_device *dev)
 
 	while (xl_priv->xl_tx_ring[xl_priv->tx_ring_tail].framestartheader & TXDNCOMPLETE ) { 
 		txd = &(xl_priv->xl_tx_ring[xl_priv->tx_ring_tail]) ;
-		pci_unmap_single(xl_priv->pdev,txd->buffer, xl_priv->tx_ring_skb[xl_priv->tx_ring_tail]->len, PCI_DMA_TODEVICE) ; 
+		pci_unmap_single(xl_priv->pdev, le32_to_cpu(txd->buffer), xl_priv->tx_ring_skb[xl_priv->tx_ring_tail]->len, PCI_DMA_TODEVICE);
 		txd->framestartheader = 0 ; 
-		txd->buffer = 0xdeadbeef  ; 
+		txd->buffer = cpu_to_le32(0xdeadbeef);
 		txd->buffer_length  = 0 ;  
 		dev_kfree_skb_irq(xl_priv->tx_ring_skb[xl_priv->tx_ring_tail]) ;
 		xl_priv->tx_ring_tail++ ; 
@@ -1507,9 +1503,9 @@ static void xl_arb_cmd(struct net_device *dev)
 	if (arb_cmd == RING_STATUS_CHANGE) { /* Ring.Status.Change */
 		writel( ( (MEM_WORD_READ | 0xD0000 | xl_priv->arb) + 6), xl_mmio + MMIO_MAC_ACCESS_CMD) ;
 		 
-		printk(KERN_INFO "%s: Ring Status Change: New Status = %04x\n", dev->name, ntohs(readw(xl_mmio + MMIO_MACDATA) )) ; 
+		printk(KERN_INFO "%s: Ring Status Change: New Status = %04x\n", dev->name, swab16(readw(xl_mmio + MMIO_MACDATA) )) ;
 
-		lan_status = ntohs(readw(xl_mmio + MMIO_MACDATA));
+		lan_status = swab16(readw(xl_mmio + MMIO_MACDATA));
 	
 		/* Acknowledge interrupt, this tells nic we are done with the arb */
 		writel(ACK_INTERRUPT | ARBCACK | LATCH_ACK, xl_mmio + MMIO_COMMAND) ; 
@@ -1573,7 +1569,7 @@ static void xl_arb_cmd(struct net_device *dev)
 		printk(KERN_INFO "Received.Data \n") ; 
 #endif 		
 		writel( ((MEM_WORD_READ | 0xD0000 | xl_priv->arb) + 6), xl_mmio + MMIO_MAC_ACCESS_CMD) ;
-		xl_priv->mac_buffer = ntohs(readw(xl_mmio + MMIO_MACDATA)) ;
+		xl_priv->mac_buffer = swab16(readw(xl_mmio + MMIO_MACDATA)) ;
 		
 		/* Now we are going to be really basic here and not do anything
 		 * with the data at all. The tech docs do not give me enough
@@ -1634,7 +1630,7 @@ static void xl_asb_cmd(struct net_device *dev)
 	writeb(0x81, xl_mmio + MMIO_MACDATA) ; 
 
 	writel(MEM_WORD_WRITE | 0xd0000 | xl_priv->asb | 6, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-	writew(ntohs(xl_priv->mac_buffer), xl_mmio + MMIO_MACDATA) ; 
+	writew(swab16(xl_priv->mac_buffer), xl_mmio + MMIO_MACDATA) ;
 
 	xl_wait_misr_flags(dev) ; 	
 
diff --git a/drivers/net/tokenring/3c359.h b/drivers/net/tokenring/3c359.h
index 05c8603..b880cba 100644
--- a/drivers/net/tokenring/3c359.h
+++ b/drivers/net/tokenring/3c359.h
@@ -156,19 +156,19 @@
 #define HOSTERRINT (1<<1)
 
 /* Receive descriptor bits */
-#define RXOVERRUN (1<<19)
-#define RXFC (1<<21)
-#define RXAR (1<<22)
-#define RXUPDCOMPLETE (1<<23)
-#define RXUPDFULL (1<<24)
-#define RXUPLASTFRAG (1<<31)
+#define RXOVERRUN cpu_to_le32(1<<19)
+#define RXFC cpu_to_le32(1<<21)
+#define RXAR cpu_to_le32(1<<22)
+#define RXUPDCOMPLETE cpu_to_le32(1<<23)
+#define RXUPDFULL cpu_to_le32(1<<24)
+#define RXUPLASTFRAG cpu_to_le32(1<<31)
 
 /* Transmit descriptor bits */
-#define TXDNCOMPLETE (1<<16)
-#define TXTXINDICATE (1<<27)
-#define TXDPDEMPTY (1<<29)
-#define TXDNINDICATE (1<<31)
-#define TXDNFRAGLAST (1<<31)
+#define TXDNCOMPLETE cpu_to_le32(1<<16)
+#define TXTXINDICATE cpu_to_le32(1<<27)
+#define TXDPDEMPTY cpu_to_le32(1<<29)
+#define TXDNINDICATE cpu_to_le32(1<<31)
+#define TXDNFRAGLAST cpu_to_le32(1<<31)
 
 /* Interrupts to Acknowledge */
 #define LATCH_ACK 1 
@@ -232,17 +232,17 @@
 /* 3c359 data structures */
 
 struct xl_tx_desc {
-	u32 dnnextptr ; 
-	u32 framestartheader ; 
-	u32 buffer ;
-	u32 buffer_length ;
+	__le32 dnnextptr;
+	__le32 framestartheader;
+	__le32 buffer;
+	__le32 buffer_length;
 };
 
 struct xl_rx_desc {
-	u32 upnextptr ; 
-	u32 framestatus ; 
-	u32 upfragaddr ; 
-	u32 upfraglen ; 
+	__le32 upnextptr;
+	__le32 framestatus;
+	__le32 upfragaddr;
+	__le32 upfraglen;
 };
 
 struct xl_private {
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 94ac586..f50cb52 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -813,8 +813,7 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 	first_txd->flags = TYPHOON_TX_DESC | TYPHOON_DESC_VALID;
 	first_txd->numDesc = 0;
 	first_txd->len = 0;
-	first_txd->addr = (u64)((unsigned long) skb) & 0xffffffff;
-	first_txd->addrHi = (u64)((unsigned long) skb) >> 32;
+	first_txd->tx_addr = (u64)((unsigned long) skb);
 	first_txd->processFlags = 0;
 
 	if(skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -850,8 +849,8 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 				       PCI_DMA_TODEVICE);
 		txd->flags = TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
 		txd->len = cpu_to_le16(skb->len);
-		txd->addr = cpu_to_le32(skb_dma);
-		txd->addrHi = 0;
+		txd->frag.addr = cpu_to_le32(skb_dma);
+		txd->frag.addrHi = 0;
 		first_txd->numDesc++;
 	} else {
 		int i, len;
@@ -861,8 +860,8 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 				         PCI_DMA_TODEVICE);
 		txd->flags = TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
 		txd->len = cpu_to_le16(len);
-		txd->addr = cpu_to_le32(skb_dma);
-		txd->addrHi = 0;
+		txd->frag.addr = cpu_to_le32(skb_dma);
+		txd->frag.addrHi = 0;
 		first_txd->numDesc++;
 
 		for(i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
@@ -880,8 +879,8 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 					 PCI_DMA_TODEVICE);
 			txd->flags = TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
 			txd->len = cpu_to_le16(len);
-			txd->addr = cpu_to_le32(skb_dma);
-			txd->addrHi = 0;
+			txd->frag.addr = cpu_to_le32(skb_dma);
+			txd->frag.addrHi = 0;
 			first_txd->numDesc++;
 		}
 	}
@@ -977,12 +976,12 @@ typhoon_do_get_stats(struct typhoon *tp)
 	 * ethtool_ops->get_{strings,stats}()
 	 */
 	stats->tx_packets = le32_to_cpu(s->txPackets);
-	stats->tx_bytes = le32_to_cpu(s->txBytes);
+	stats->tx_bytes = le64_to_cpu(s->txBytes);
 	stats->tx_errors = le32_to_cpu(s->txCarrierLost);
 	stats->tx_carrier_errors = le32_to_cpu(s->txCarrierLost);
 	stats->collisions = le32_to_cpu(s->txMultipleCollisions);
 	stats->rx_packets = le32_to_cpu(s->rxPacketsGood);
-	stats->rx_bytes = le32_to_cpu(s->rxBytesGood);
+	stats->rx_bytes = le64_to_cpu(s->rxBytesGood);
 	stats->rx_fifo_errors = le32_to_cpu(s->rxFifoOverruns);
 	stats->rx_errors = le32_to_cpu(s->rxFifoOverruns) +
 			le32_to_cpu(s->BadSSD) + le32_to_cpu(s->rxCrcErrors);
@@ -1056,7 +1055,7 @@ typhoon_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 		if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
 			strcpy(info->fw_version, "Unknown runtime");
 		} else {
-			u32 sleep_ver = xp_resp[0].parm2;
+			u32 sleep_ver = le32_to_cpu(xp_resp[0].parm2);
 			snprintf(info->fw_version, 32, "%02x.%03x.%03x",
 				 sleep_ver >> 24, (sleep_ver >> 12) & 0xfff,
 				 sleep_ver & 0xfff);
@@ -1157,7 +1156,7 @@ typhoon_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_XCVR_SELECT);
-	xp_cmd.parm1 = cpu_to_le16(xcvr);
+	xp_cmd.parm1 = xcvr;
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0)
 		goto out;
@@ -1320,7 +1319,7 @@ typhoon_init_interface(struct typhoon *tp)
 	tp->txLoRing.writeRegister = TYPHOON_REG_TX_LO_READY;
 	tp->txHiRing.writeRegister = TYPHOON_REG_TX_HI_READY;
 
-	tp->txlo_dma_addr = iface->txLoAddr;
+	tp->txlo_dma_addr = le32_to_cpu(iface->txLoAddr);
 	tp->card_state = Sleeping;
 	smp_wmb();
 
@@ -1358,7 +1357,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	u8 *image_data;
 	void *dpage;
 	dma_addr_t dpage_dma;
-	unsigned int csum;
+	__sum16 csum;
 	u32 irqEnabled;
 	u32 irqMasked;
 	u32 numSections;
@@ -1450,13 +1449,13 @@ typhoon_download_firmware(struct typhoon *tp)
 			 * summing. Fortunately, due to the properties of
 			 * the checksum, we can do this once, at the end.
 			 */
-			csum = csum_partial_copy_nocheck(image_data, dpage,
-							 len, 0);
-			csum = csum_fold(csum);
-			csum = le16_to_cpu(csum);
+			csum = csum_fold(csum_partial_copy_nocheck(image_data,
+								  dpage, len,
+								  0));
 
 			iowrite32(len, ioaddr + TYPHOON_REG_BOOT_LENGTH);
-			iowrite32(csum, ioaddr + TYPHOON_REG_BOOT_CHECKSUM);
+			iowrite32(le16_to_cpu((__force __le16)csum),
+					ioaddr + TYPHOON_REG_BOOT_CHECKSUM);
 			iowrite32(load_addr,
 					ioaddr + TYPHOON_REG_BOOT_DEST_ADDR);
 			iowrite32(0, ioaddr + TYPHOON_REG_BOOT_DATA_HI);
@@ -1551,13 +1550,13 @@ typhoon_clean_tx(struct typhoon *tp, struct transmit_ring *txRing,
 		if(type == TYPHOON_TX_DESC) {
 			/* This tx_desc describes a packet.
 			 */
-			unsigned long ptr = tx->addr | ((u64)tx->addrHi << 32);
+			unsigned long ptr = tx->tx_addr;
 			struct sk_buff *skb = (struct sk_buff *) ptr;
 			dev_kfree_skb_irq(skb);
 		} else if(type == TYPHOON_FRAG_DESC) {
 			/* This tx_desc describes a memory mapping. Free it.
 			 */
-			skb_dma = (dma_addr_t) le32_to_cpu(tx->addr);
+			skb_dma = (dma_addr_t) le32_to_cpu(tx->frag.addr);
 			dma_len = le16_to_cpu(tx->len);
 			pci_unmap_single(tp->pdev, skb_dma, dma_len,
 				       PCI_DMA_TODEVICE);
@@ -1596,7 +1595,7 @@ typhoon_recycle_rx_skb(struct typhoon *tp, u32 idx)
 	struct rx_free *r;
 
 	if((ring->lastWrite + sizeof(*r)) % (RXFREE_ENTRIES * sizeof(*r)) ==
-				indexes->rxBuffCleared) {
+				le32_to_cpu(indexes->rxBuffCleared)) {
 		/* no room in ring, just drop the skb
 		 */
 		dev_kfree_skb_any(rxb->skb);
@@ -1627,7 +1626,7 @@ typhoon_alloc_rx_skb(struct typhoon *tp, u32 idx)
 	rxb->skb = NULL;
 
 	if((ring->lastWrite + sizeof(*r)) % (RXFREE_ENTRIES * sizeof(*r)) ==
-				indexes->rxBuffCleared)
+				le32_to_cpu(indexes->rxBuffCleared))
 		return -ENOMEM;
 
 	skb = dev_alloc_skb(PKT_BUF_SZ);
diff --git a/drivers/net/typhoon.h b/drivers/net/typhoon.h
index 19df208..dd7022c 100644
--- a/drivers/net/typhoon.h
+++ b/drivers/net/typhoon.h
@@ -73,7 +73,7 @@ struct typhoon_indexes {
 	volatile __le32 txLoCleared;
 	volatile __le32 txHiCleared;
 	volatile __le32 rxLoReady;
-	volatile __u32 rxBuffCleared;	/* AV: really? */
+	volatile __le32 rxBuffCleared;
 	volatile __le32 cmdCleared;
 	volatile __le32 respReady;
 	volatile __le32 rxHiReady;
@@ -166,8 +166,13 @@ struct tx_desc {
 #define TYPHOON_DESC_VALID	0x80
 	u8  numDesc;
 	__le16 len;
-	u32 addr;
-	u32 addrHi;
+	union {
+		struct {
+			__le32 addr;
+			__le32 addrHi;
+		} frag;
+		u64 tx_addr;	/* opaque for hardware, for TX_DESC */
+	};
 	__le32 processFlags;
 #define TYPHOON_TX_PF_NO_CRC		__constant_cpu_to_le32(0x00000001)
 #define TYPHOON_TX_PF_IP_CHKSUM		__constant_cpu_to_le32(0x00000002)
@@ -240,8 +245,8 @@ struct rx_desc {
 	u8  flags;
 	u8  numDesc;
 	__le16 frameLen;
-	u32 addr;
-	u32 addrHi;
+	u32 addr;	/* opaque, comes from virtAddr */
+	u32 addrHi;	/* opaque, comes from virtAddrHi */
 	__le32 rxStatus;
 #define TYPHOON_RX_ERR_INTERNAL		__constant_cpu_to_le32(0x00000000)
 #define TYPHOON_RX_ERR_FIFO_UNDERRUN	__constant_cpu_to_le32(0x00000001)
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 61daa09..1249f44 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -172,45 +172,76 @@ struct asix_data {
 };
 
 struct ax88172_int_data {
-	u16 res1;
+	__le16 res1;
 	u8 link;
-	u16 res2;
+	__le16 res2;
 	u8 status;
-	u16 res3;
+	__le16 res3;
 } __attribute__ ((packed));
 
 static int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			    u16 size, void *data)
 {
+	void *buf;
+	int err = -ENOMEM;
+
 	devdbg(dev,"asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
 		cmd, value, index, size);
-	return usb_control_msg(
+
+	buf = kmalloc(size, GFP_KERNEL);
+	if (!buf)
+		goto out;
+
+	err = usb_control_msg(
 		dev->udev,
 		usb_rcvctrlpipe(dev->udev, 0),
 		cmd,
 		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		value,
 		index,
-		data,
+		buf,
 		size,
 		USB_CTRL_GET_TIMEOUT);
+	if (err >= 0 && err < size)
+		err = -EINVAL;
+	if (!err)
+		memcpy(data, buf, size);
+	kfree(buf);
+
+out:
+	return err;
 }
 
 static int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			     u16 size, void *data)
 {
+	void *buf = NULL;
+	int err = -ENOMEM;
+
 	devdbg(dev,"asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
 		cmd, value, index, size);
-	return usb_control_msg(
+
+	if (data) {
+		buf = kmalloc(size, GFP_KERNEL);
+		if (!buf)
+			goto out;
+		memcpy(buf, data, size);
+	}
+
+	err = usb_control_msg(
 		dev->udev,
 		usb_sndctrlpipe(dev->udev, 0),
 		cmd,
 		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		value,
 		index,
-		data,
+		buf,
 		size,
 		USB_CTRL_SET_TIMEOUT);
+	kfree(buf);
+
+out:
+	return err;
 }
 
 static void asix_async_cmd_callback(struct urb *urb)
@@ -402,25 +433,19 @@ static inline int asix_set_hw_mii(struct usbnet *dev)
 
 static inline int asix_get_phy_addr(struct usbnet *dev)
 {
-	int ret = 0;
-	void *buf;
+	u8 buf[2];
+	int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
 
 	devdbg(dev, "asix_get_phy_addr()");
 
-	buf = kmalloc(2, GFP_KERNEL);
-	if (!buf)
-		goto out1;
-
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID,
-				    0, 0, 2, buf)) < 2) {
+	if (ret < 0) {
 		deverr(dev, "Error reading PHYID register: %02x", ret);
-		goto out2;
+		goto out;
 	}
-	devdbg(dev, "asix_get_phy_addr() returning 0x%04x", *((u16 *)buf));
-	ret = *((u8 *)buf + 1);
-out2:
-	kfree(buf);
-out1:
+	devdbg(dev, "asix_get_phy_addr() returning 0x%04x", *((__le16 *)buf));
+	ret = buf[1];
+
+out:
 	return ret;
 }
 
@@ -437,22 +462,15 @@ static int asix_sw_reset(struct usbnet *dev, u8 flags)
 
 static u16 asix_read_rx_ctl(struct usbnet *dev)
 {
-	u16 ret = 0;
-	void *buf;
-
-	buf = kmalloc(2, GFP_KERNEL);
-	if (!buf)
-		goto out1;
+	__le16 v;
+	int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
 
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL,
-				    0, 0, 2, buf)) < 2) {
+	if (ret < 0) {
 		deverr(dev, "Error reading RX_CTL register: %02x", ret);
-		goto out2;
+		goto out;
 	}
-	ret = le16_to_cpu(*((u16 *)buf));
-out2:
-	kfree(buf);
-out1:
+	ret = le16_to_cpu(v);
+out:
 	return ret;
 }
 
@@ -471,22 +489,15 @@ static int asix_write_rx_ctl(struct usbnet *dev, u16 mode)
 
 static u16 asix_read_medium_status(struct usbnet *dev)
 {
-	u16 ret = 0;
-	void *buf;
+	__le16 v;
+	int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
 
-	buf = kmalloc(2, GFP_KERNEL);
-	if (!buf)
-		goto out1;
-
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS,
-				    0, 0, 2, buf)) < 2) {
+	if (ret < 0) {
 		deverr(dev, "Error reading Medium Status register: %02x", ret);
-		goto out2;
+		goto out;
 	}
-	ret = le16_to_cpu(*((u16 *)buf));
-out2:
-	kfree(buf);
-out1:
+	ret = le16_to_cpu(v);
+out:
 	return ret;
 }
 
@@ -568,31 +579,30 @@ static void asix_set_multicast(struct net_device *net)
 static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
 {
 	struct usbnet *dev = netdev_priv(netdev);
-	u16 res;
+	__le16 res;
 
 	mutex_lock(&dev->phy_mutex);
 	asix_set_sw_mii(dev);
 	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
-				(__u16)loc, 2, (u16 *)&res);
+				(__u16)loc, 2, &res);
 	asix_set_hw_mii(dev);
 	mutex_unlock(&dev->phy_mutex);
 
-	devdbg(dev, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x", phy_id, loc, le16_to_cpu(res & 0xffff));
+	devdbg(dev, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x", phy_id, loc, le16_to_cpu(res));
 
-	return le16_to_cpu(res & 0xffff);
+	return le16_to_cpu(res);
 }
 
 static void
 asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
 {
 	struct usbnet *dev = netdev_priv(netdev);
-	u16 res = cpu_to_le16(val);
+	__le16 res = cpu_to_le16(val);
 
 	devdbg(dev, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x", phy_id, loc, val);
 	mutex_lock(&dev->phy_mutex);
 	asix_set_sw_mii(dev);
-	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
-				(__u16)loc, 2, (u16 *)&res);
+	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
 	asix_set_hw_mii(dev);
 	mutex_unlock(&dev->phy_mutex);
 }
@@ -644,7 +654,6 @@ asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
 {
 	struct usbnet *dev = netdev_priv(net);
 	u8 opt = 0;
-	u8 buf[1];
 
 	if (wolinfo->wolopts & WAKE_PHY)
 		opt |= AX_MONITOR_LINK;
@@ -654,7 +663,7 @@ asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
 		opt |= AX_MONITOR_MODE;
 
 	if (asix_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
-			      opt, 0, 0, &buf) < 0)
+			      opt, 0, 0, NULL) < 0)
 		return -EINVAL;
 
 	return 0;
@@ -672,7 +681,7 @@ static int asix_get_eeprom(struct net_device *net,
 			      struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct usbnet *dev = netdev_priv(net);
-	u16 *ebuf = (u16 *)data;
+	__le16 *ebuf = (__le16 *)data;
 	int i;
 
 	/* Crude hack to ensure that we don't overwrite memory
@@ -801,7 +810,7 @@ static int ax88172_link_reset(struct usbnet *dev)
 static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret = 0;
-	void *buf;
+	u8 buf[ETH_ALEN];
 	int i;
 	unsigned long gpio_bits = dev->driver_info->data;
 	struct asix_data *data = (struct asix_data *)&dev->data;
@@ -810,30 +819,23 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	usbnet_get_endpoints(dev,intf);
 
-	buf = kmalloc(ETH_ALEN, GFP_KERNEL);
-	if(!buf) {
-		ret = -ENOMEM;
-		goto out1;
-	}
-
 	/* Toggle the GPIOs in a manufacturer/model specific way */
 	for (i = 2; i >= 0; i--) {
 		if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS,
 					(gpio_bits >> (i * 8)) & 0xff, 0, 0,
-					buf)) < 0)
-			goto out2;
+					NULL)) < 0)
+			goto out;
 		msleep(5);
 	}
 
 	if ((ret = asix_write_rx_ctl(dev, 0x80)) < 0)
-		goto out2;
+		goto out;
 
 	/* Get the MAC address */
-	memset(buf, 0, ETH_ALEN);
 	if ((ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID,
-				0, 0, 6, buf)) < 0) {
+				0, 0, ETH_ALEN, buf)) < 0) {
 		dbg("read AX_CMD_READ_NODE_ID failed: %d", ret);
-		goto out2;
+		goto out;
 	}
 	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
 
@@ -855,9 +857,8 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 	mii_nway_restart(&dev->mii);
 
 	return 0;
-out2:
-	kfree(buf);
-out1:
+
+out:
 	return ret;
 }
 
@@ -900,66 +901,58 @@ static int ax88772_link_reset(struct usbnet *dev)
 static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret, embd_phy;
-	void *buf;
 	u16 rx_ctl;
 	struct asix_data *data = (struct asix_data *)&dev->data;
+	u8 buf[ETH_ALEN];
 	u32 phyid;
 
 	data->eeprom_len = AX88772_EEPROM_LEN;
 
 	usbnet_get_endpoints(dev,intf);
 
-	buf = kmalloc(6, GFP_KERNEL);
-	if(!buf) {
-		dbg ("Cannot allocate memory for buffer");
-		ret = -ENOMEM;
-		goto out1;
-	}
-
 	if ((ret = asix_write_gpio(dev,
 			AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5)) < 0)
-		goto out2;
+		goto out;
 
 	/* 0x10 is the phy id of the embedded 10/100 ethernet phy */
 	embd_phy = ((asix_get_phy_addr(dev) & 0x1f) == 0x10 ? 1 : 0);
 	if ((ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT,
-				embd_phy, 0, 0, buf)) < 0) {
+				embd_phy, 0, 0, NULL)) < 0) {
 		dbg("Select PHY #1 failed: %d", ret);
-		goto out2;
+		goto out;
 	}
 
 	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL)) < 0)
-		goto out2;
+		goto out;
 
 	msleep(150);
 	if ((ret = asix_sw_reset(dev, AX_SWRESET_CLEAR)) < 0)
-		goto out2;
+		goto out;
 
 	msleep(150);
 	if (embd_phy) {
 		if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
-			goto out2;
+			goto out;
 	}
 	else {
 		if ((ret = asix_sw_reset(dev, AX_SWRESET_PRTE)) < 0)
-			goto out2;
+			goto out;
 	}
 
 	msleep(150);
 	rx_ctl = asix_read_rx_ctl(dev);
 	dbg("RX_CTL is 0x%04x after software reset", rx_ctl);
 	if ((ret = asix_write_rx_ctl(dev, 0x0000)) < 0)
-		goto out2;
+		goto out;
 
 	rx_ctl = asix_read_rx_ctl(dev);
 	dbg("RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
 
 	/* Get the MAC address */
-	memset(buf, 0, ETH_ALEN);
 	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
 				0, 0, ETH_ALEN, buf)) < 0) {
 		dbg("Failed to read MAC address: %d", ret);
-		goto out2;
+		goto out;
 	}
 	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
 
@@ -976,12 +969,12 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	dbg("PHYID=0x%08x", phyid);
 
 	if ((ret = asix_sw_reset(dev, AX_SWRESET_PRL)) < 0)
-		goto out2;
+		goto out;
 
 	msleep(150);
 
 	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_PRL)) < 0)
-		goto out2;
+		goto out;
 
 	msleep(150);
 
@@ -994,18 +987,18 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	mii_nway_restart(&dev->mii);
 
 	if ((ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT)) < 0)
-		goto out2;
+		goto out;
 
 	if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
 				AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
-				AX88772_IPG2_DEFAULT, 0, buf)) < 0) {
+				AX88772_IPG2_DEFAULT, 0, NULL)) < 0) {
 		dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
-		goto out2;
+		goto out;
 	}
 
 	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
 	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
-		goto out2;
+		goto out;
 
 	rx_ctl = asix_read_rx_ctl(dev);
 	dbg("RX_CTL is 0x%04x after all initializations", rx_ctl);
@@ -1013,20 +1006,15 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	rx_ctl = asix_read_medium_status(dev);
 	dbg("Medium Status is 0x%04x after all initializations", rx_ctl);
 
-	kfree(buf);
-
 	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
 	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
 		/* hard_mtu  is still the default - the device does not support
 		   jumbo eth frames */
 		dev->rx_urb_size = 2048;
 	}
-
 	return 0;
 
-out2:
-	kfree(buf);
-out1:
+out:
 	return ret;
 }
 
@@ -1195,23 +1183,16 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct asix_data *data = (struct asix_data *)&dev->data;
 	int ret;
-	void *buf;
-	u16 eeprom;
+	u8 buf[ETH_ALEN];
+	__le16 eeprom;
+	u8 status;
 	int gpio0 = 0;
 	u32 phyid;
 
 	usbnet_get_endpoints(dev,intf);
 
-	buf = kmalloc(6, GFP_KERNEL);
-	if(!buf) {
-		dbg ("Cannot allocate memory for buffer");
-		ret = -ENOMEM;
-		goto out1;
-	}
-
-	eeprom = 0;
-	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &eeprom);
-	dbg("GPIO Status: 0x%04x", eeprom);
+	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status);
+	dbg("GPIO Status: 0x%04x", status);
 
 	asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL);
 	asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom);
@@ -1219,19 +1200,19 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	dbg("EEPROM index 0x17 is 0x%04x", eeprom);
 
-	if (eeprom == 0xffff) {
+	if (eeprom == cpu_to_le16(0xffff)) {
 		data->phymode = PHY_MODE_MARVELL;
 		data->ledmode = 0;
 		gpio0 = 1;
 	} else {
-		data->phymode = eeprom & 7;
-		data->ledmode = eeprom >> 8;
-		gpio0 = (eeprom & 0x80) ? 0 : 1;
+		data->phymode = le16_to_cpu(eeprom) & 7;
+		data->ledmode = le16_to_cpu(eeprom) >> 8;
+		gpio0 = (le16_to_cpu(eeprom) & 0x80) ? 0 : 1;
 	}
 	dbg("GPIO0: %d, PhyMode: %d", gpio0, data->phymode);
 
 	asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO_GPO1EN, 40);
-	if ((eeprom >> 8) != 1) {
+	if ((le16_to_cpu(eeprom) >> 8) != 1) {
 		asix_write_gpio(dev, 0x003c, 30);
 		asix_write_gpio(dev, 0x001c, 300);
 		asix_write_gpio(dev, 0x003c, 30);
@@ -1250,11 +1231,10 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 	asix_write_rx_ctl(dev, 0);
 
 	/* Get the MAC address */
-	memset(buf, 0, ETH_ALEN);
 	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
 				0, 0, ETH_ALEN, buf)) < 0) {
 		dbg("Failed to read MAC address: %d", ret);
-		goto out2;
+		goto out;
 	}
 	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
 
@@ -1289,12 +1269,10 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 	mii_nway_restart(&dev->mii);
 
 	if ((ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT)) < 0)
-		goto out2;
+		goto out;
 
 	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
-		goto out2;
-
-	kfree(buf);
+		goto out;
 
 	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
 	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
@@ -1302,12 +1280,9 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 		   jumbo eth frames */
 		dev->rx_urb_size = 2048;
 	}
-
 	return 0;
 
-out2:
-	kfree(buf);
-out1:
+out:
 	return ret;
 }
 
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index 8a1778c..d3b28b0 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -503,7 +503,7 @@ static int cycx_netdevice_init(struct net_device *dev)
 	dev->addr_len		= 0;		/* hardware address length */
 
 	if (!chan->svc)
-		*(u16*)dev->dev_addr = htons(chan->lcn);
+		*(__be16*)dev->dev_addr = htons(chan->lcn);
 
 	/* Initialize hardware parameters (just for reference) */
 	dev->irq		= wandev->irq;
@@ -565,7 +565,7 @@ static int cycx_netdevice_hard_header(struct sk_buff *skb,
 				      const void *daddr, const void *saddr,
 				      unsigned len)
 {
-	skb->protocol = type;
+	skb->protocol = htons(type);
 
 	return dev->hard_header_len;
 }
@@ -600,15 +600,15 @@ static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 	struct cycx_device *card = chan->card;
 
 	if (!chan->svc)
-		chan->protocol = skb->protocol;
+		chan->protocol = ntohs(skb->protocol);
 
 	if (card->wandev.state != WAN_CONNECTED)
 		++chan->ifstats.tx_dropped;
 	else if (chan->svc && chan->protocol &&
-		 chan->protocol != skb->protocol) {
+		 chan->protocol != ntohs(skb->protocol)) {
 		printk(KERN_INFO
 		       "%s: unsupported Ethertype 0x%04X on interface %s!\n",
-		       card->devname, skb->protocol, dev->name);
+		       card->devname, ntohs(skb->protocol), dev->name);
 		++chan->ifstats.tx_errors;
 	} else if (chan->protocol == ETH_P_IP) {
 		switch (chan->state) {
@@ -1401,7 +1401,7 @@ static void cycx_x25_set_chan_state(struct net_device *dev, u8 state)
 		switch (state) {
 		case WAN_CONNECTED:
 			string_state = "connected!";
-			*(u16*)dev->dev_addr = htons(chan->lcn);
+			*(__be16*)dev->dev_addr = htons(chan->lcn);
 			netif_wake_queue(dev);
 			reset_timer(dev);
 
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 5583719..c98fc62 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -587,15 +587,66 @@ config ADM8211
 config P54_COMMON
 	tristate "Softmac Prism54 support"
 	depends on MAC80211 && WLAN_80211 && FW_LOADER && EXPERIMENTAL
+	---help---
+	  This is common code for isl38xx based cards.
+	  This module does nothing by itself - the USB/PCI frontends
+	  also need to be enabled in order to support any devices.
+
+	  These devices require softmac firmware which can be found at
+	  http://prism54.org/
+
+	  If you choose to build a module, it'll be called p54common.
 
 config P54_USB
 	tristate "Prism54 USB support"
 	depends on P54_COMMON && USB
 	select CRC32
+	---help---
+	  This driver is for USB isl38xx based wireless cards.
+	  These are USB based adapters found in devices such as:
+
+	  3COM 3CRWE254G72
+	  SMC 2862W-G
+	  Accton 802.11g WN4501 USB
+	  Siemens Gigaset USB
+	  Netgear WG121
+	  Netgear WG111
+	  Medion 40900, Roper Europe
+	  Shuttle PN15, Airvast WM168g, IOGear GWU513
+	  Linksys WUSB54G
+	  Linksys WUSB54G Portable
+	  DLink DWL-G120 Spinnaker
+	  DLink DWL-G122
+	  Belkin F5D7050 ver 1000
+	  Cohiba Proto board
+	  SMC 2862W-G version 2
+	  U.S. Robotics U5 802.11g Adapter
+	  FUJITSU E-5400 USB D1700
+	  Sagem XG703A
+	  DLink DWL-G120 Cohiba
+	  Spinnaker Proto board
+	  Linksys WUSB54AG
+	  Inventel UR054G
+	  Spinnaker DUT
+
+	  These devices require softmac firmware which can be found at
+	  http://prism54.org/
+
+	  If you choose to build a module, it'll be called p54usb.
 
 config P54_PCI
 	tristate "Prism54 PCI support"
 	depends on P54_COMMON && PCI
+	---help---
+	  This driver is for PCI isl38xx based wireless cards.
+	  This driver supports most devices that are supported by the
+	  fullmac prism54 driver plus many devices which are not
+	  supported by the fullmac driver/firmware.
+
+	  This driver requires softmac firmware which can be found at
+	  http://prism54.org/
+
+	  If you choose to build a module, it'll be called p54pci.
 
 source "drivers/net/wireless/iwlwifi/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index da51f47..88062c1 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -1233,9 +1233,19 @@ static ssize_t show_event_log(struct device *d,
 {
 	struct ipw_priv *priv = dev_get_drvdata(d);
 	u32 log_len = ipw_get_event_log_len(priv);
-	struct ipw_event log[log_len];
+	u32 log_size;
+	struct ipw_event *log;
 	u32 len = 0, i;
 
+	/* not using min() because of its strict type checking */
+	log_size = PAGE_SIZE / sizeof(*log) > log_len ?
+			sizeof(*log) * log_len : PAGE_SIZE;
+	log = kzalloc(log_size, GFP_KERNEL);
+	if (!log) {
+		IPW_ERROR("Unable to allocate memory for log\n");
+		return 0;
+	}
+	log_len = log_size / sizeof(*log);
 	ipw_capture_event_log(priv, log_len, log);
 
 	len += snprintf(buf + len, PAGE_SIZE - len, "%08X", log_len);
@@ -1244,6 +1254,7 @@ static ssize_t show_event_log(struct device *d,
 				"\n%08X%08X%08X",
 				log[i].time, log[i].event, log[i].data);
 	len += snprintf(buf + len, PAGE_SIZE - len, "\n");
+	kfree(log);
 	return len;
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 3d1da07..1a6b0e0 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6246,8 +6246,6 @@ static void __iwl_down(struct iwl_priv *priv)
 	/* Unblock any waiting calls */
 	wake_up_interruptible_all(&priv->wait_command_queue);
 
-	iwl_cancel_deferred_work(priv);
-
 	/* Wipe out the EXIT_PENDING status bit if we are not actually
 	 * exiting the module */
 	if (!exit_pending)
@@ -6322,6 +6320,8 @@ static void iwl_down(struct iwl_priv *priv)
 	mutex_lock(&priv->mutex);
 	__iwl_down(priv);
 	mutex_unlock(&priv->mutex);
+
+	iwl_cancel_deferred_work(priv);
 }
 
 #define MAX_HW_RESTARTS 5
@@ -8580,10 +8580,9 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 
 	IWL_DEBUG_INFO("*** UNLOAD DRIVER ***\n");
 
-	mutex_lock(&priv->mutex);
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
-	__iwl_down(priv);
-	mutex_unlock(&priv->mutex);
+
+	iwl_down(priv);
 
 	/* Free MAC hash list for ADHOC */
 	for (i = 0; i < IWL_IBSS_MAC_HASH_SIZE; i++) {
@@ -8642,12 +8641,10 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct iwl_priv *priv = pci_get_drvdata(pdev);
 
-	mutex_lock(&priv->mutex);
-
 	set_bit(STATUS_IN_SUSPEND, &priv->status);
 
 	/* Take down the device; powers it off, etc. */
-	__iwl_down(priv);
+	iwl_down(priv);
 
 	if (priv->mac80211_registered)
 		ieee80211_stop_queues(priv->hw);
@@ -8656,8 +8653,6 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
-	mutex_unlock(&priv->mutex);
-
 	return 0;
 }
 
@@ -8715,8 +8710,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 
 	printk(KERN_INFO "Coming out of suspend...\n");
 
-	mutex_lock(&priv->mutex);
-
 	pci_set_power_state(pdev, PCI_D0);
 	err = pci_enable_device(pdev);
 	pci_restore_state(pdev);
@@ -8730,7 +8723,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 	pci_write_config_byte(pdev, 0x41, 0x00);
 
 	iwl_resume(priv);
-	mutex_unlock(&priv->mutex);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index b54fe5e..6cd57c2 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -6601,8 +6601,6 @@ static void __iwl_down(struct iwl_priv *priv)
 	/* Unblock any waiting calls */
 	wake_up_interruptible_all(&priv->wait_command_queue);
 
-	iwl_cancel_deferred_work(priv);
-
 	/* Wipe out the EXIT_PENDING status bit if we are not actually
 	 * exiting the module */
 	if (!exit_pending)
@@ -6677,6 +6675,8 @@ static void iwl_down(struct iwl_priv *priv)
 	mutex_lock(&priv->mutex);
 	__iwl_down(priv);
 	mutex_unlock(&priv->mutex);
+
+	iwl_cancel_deferred_work(priv);
 }
 
 #define MAX_HW_RESTARTS 5
@@ -9174,10 +9174,9 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 
 	IWL_DEBUG_INFO("*** UNLOAD DRIVER ***\n");
 
-	mutex_lock(&priv->mutex);
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
-	__iwl_down(priv);
-	mutex_unlock(&priv->mutex);
+
+	iwl_down(priv);
 
 	/* Free MAC hash list for ADHOC */
 	for (i = 0; i < IWL_IBSS_MAC_HASH_SIZE; i++) {
@@ -9236,12 +9235,10 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct iwl_priv *priv = pci_get_drvdata(pdev);
 
-	mutex_lock(&priv->mutex);
-
 	set_bit(STATUS_IN_SUSPEND, &priv->status);
 
 	/* Take down the device; powers it off, etc. */
-	__iwl_down(priv);
+	iwl_down(priv);
 
 	if (priv->mac80211_registered)
 		ieee80211_stop_queues(priv->hw);
@@ -9250,8 +9247,6 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
-	mutex_unlock(&priv->mutex);
-
 	return 0;
 }
 
@@ -9309,8 +9304,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 
 	printk(KERN_INFO "Coming out of suspend...\n");
 
-	mutex_lock(&priv->mutex);
-
 	pci_set_power_state(pdev, PCI_D0);
 	err = pci_enable_device(pdev);
 	pci_restore_state(pdev);
@@ -9324,7 +9317,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 	pci_write_config_byte(pdev, 0x41, 0x00);
 
 	iwl_resume(priv);
-	mutex_unlock(&priv->mutex);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index e454ae8..bd1ab3b 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -38,6 +38,8 @@ static struct usb_device_id rtl8187_table[] __devinitdata = {
 	{USB_DEVICE(0x0846, 0x6a00)},
 	/* HP */
 	{USB_DEVICE(0x03f0, 0xca02)},
+	/* Sitecom */
+	{USB_DEVICE(0x0df6, 0x000d)},
 	{}
 };
 
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 87f002a..fe6ff3e 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -265,10 +265,10 @@ enum yellowfin_offsets {
 /* The Yellowfin Rx and Tx buffer descriptors.
    Elements are written as 32 bit for endian portability. */
 struct yellowfin_desc {
-	u32 dbdma_cmd;
-	u32 addr;
-	u32 branch_addr;
-	u32 result_status;
+	__le32 dbdma_cmd;
+	__le32 addr;
+	__le32 branch_addr;
+	__le32 result_status;
 };
 
 struct tx_status_words {
@@ -922,7 +922,7 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += skb->len;
 			/* Free the original skb. */
-			pci_unmap_single(yp->pci_dev, yp->tx_ring[entry].addr,
+			pci_unmap_single(yp->pci_dev, le32_to_cpu(yp->tx_ring[entry].addr),
 				skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_irq(skb);
 			yp->tx_skbuff[entry] = NULL;
@@ -1056,13 +1056,13 @@ static int yellowfin_rx(struct net_device *dev)
 
 		if(!desc->result_status)
 			break;
-		pci_dma_sync_single_for_cpu(yp->pci_dev, desc->addr,
+		pci_dma_sync_single_for_cpu(yp->pci_dev, le32_to_cpu(desc->addr),
 			yp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		desc_status = le32_to_cpu(desc->result_status) >> 16;
 		buf_addr = rx_skb->data;
 		data_size = (le32_to_cpu(desc->dbdma_cmd) -
 			le32_to_cpu(desc->result_status)) & 0xffff;
-		frame_status = le16_to_cpu(get_unaligned((s16*)&(buf_addr[data_size - 2])));
+		frame_status = le16_to_cpu(get_unaligned((__le16*)&(buf_addr[data_size - 2])));
 		if (yellowfin_debug > 4)
 			printk(KERN_DEBUG "  yellowfin_rx() status was %4.4x.\n",
 				   frame_status);
@@ -1123,7 +1123,7 @@ static int yellowfin_rx(struct net_device *dev)
 			if (pkt_len > rx_copybreak) {
 				skb_put(skb = rx_skb, pkt_len);
 				pci_unmap_single(yp->pci_dev,
-					yp->rx_ring[entry].addr,
+					le32_to_cpu(yp->rx_ring[entry].addr),
 					yp->rx_buf_sz,
 					PCI_DMA_FROMDEVICE);
 				yp->rx_skbuff[entry] = NULL;
@@ -1134,9 +1134,10 @@ static int yellowfin_rx(struct net_device *dev)
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				skb_copy_to_linear_data(skb, rx_skb->data, pkt_len);
 				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(yp->pci_dev, desc->addr,
-											   yp->rx_buf_sz,
-											   PCI_DMA_FROMDEVICE);
+				pci_dma_sync_single_for_device(yp->pci_dev,
+								le32_to_cpu(desc->addr),
+								yp->rx_buf_sz,
+								PCI_DMA_FROMDEVICE);
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
@@ -1252,7 +1253,7 @@ static int yellowfin_close(struct net_device *dev)
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		yp->rx_ring[i].dbdma_cmd = cpu_to_le32(CMD_STOP);
-		yp->rx_ring[i].addr = 0xBADF00D0; /* An invalid address. */
+		yp->rx_ring[i].addr = cpu_to_le32(0xBADF00D0); /* An invalid address. */
 		if (yp->rx_skbuff[i]) {
 			dev_kfree_skb(yp->rx_skbuff[i]);
 		}
