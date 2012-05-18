From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 5/5] cirrus: cs89x0: Remove function prototypes and reorder declarations
Date: Fri, 18 May 2012 15:56:31 -0700
Message-ID: <95211b9b5cf7c5cf5d59404127afa0bf0c63c148.1337381533.git.joe@perches.com>
References: <cover.1337381533.git.joe@perches.com>
Cc: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337381533.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move blocks of code around to avoid function prototypes.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c | 1919 +++++++++++++++++-----------------
 1 files changed, 947 insertions(+), 972 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 859f8be..845b202 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -174,28 +174,6 @@ struct net_local {
 #endif
 };
 
-/* Index to functions, as function prototypes. */
-static int net_open(struct net_device *dev);
-static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev);
-static irqreturn_t net_interrupt(int irq, void *dev_id);
-static void set_multicast_list(struct net_device *dev);
-static void net_timeout(struct net_device *dev);
-static void net_rx(struct net_device *dev);
-static int net_close(struct net_device *dev);
-static struct net_device_stats *net_get_stats(struct net_device *dev);
-static void reset_chip(struct net_device *dev);
-static int get_eeprom_data(struct net_device *dev, int off, int len, int *buffer);
-static int get_eeprom_cksum(int off, int len, int *buffer);
-static int set_mac_address(struct net_device *dev, void *addr);
-static void count_rx_errors(int status, struct net_device *dev);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static void net_poll_controller(struct net_device *dev);
-#endif
-#if ALLOW_DMA
-static void get_dma_channel(struct net_device *dev);
-static void release_dma_buff(struct net_local *lp);
-#endif
-
 /* Example routines you must write ;->. */
 #define tx_done(dev) 1
 
@@ -321,7 +299,7 @@ get_eeprom_data(struct net_device *dev, int off, int len, int *buffer)
 {
 	int i;
 
-	cs89_dbg(3, info, "EEPROM data from %x for %x:\n", off, len);
+	cs89_dbg(3, info, "EEPROM data from %x for %x:", off, len);
 	for (i = 0; i < len; i++) {
 		if (wait_eeprom_ready(dev) < 0)
 			return -1;
@@ -330,7 +308,7 @@ get_eeprom_data(struct net_device *dev, int off, int len, int *buffer)
 		if (wait_eeprom_ready(dev) < 0)
 			return -1;
 		buffer[i] = readreg(dev, PP_EEData);
-		cs89_dbg(3, cont, "%04x ", buffer[i]);
+		cs89_dbg(3, cont, " %04x", buffer[i]);
 	}
 	cs89_dbg(3, cont, "\n");
 	return 0;
@@ -350,564 +328,425 @@ get_eeprom_cksum(int off, int len, int *buffer)
 	return -1;
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-/*
- * Polling receive - used by netconsole and other diagnostic tools
- * to allow network i/o with interrupts disabled.
- */
-static void net_poll_controller(struct net_device *dev)
+static void
+write_irq(struct net_device *dev, int chip_type, int irq)
 {
-	disable_irq(dev->irq);
-	net_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
-}
-#endif
+	int i;
 
-static const struct net_device_ops net_ops = {
-	.ndo_open		= net_open,
-	.ndo_stop		= net_close,
-	.ndo_tx_timeout		= net_timeout,
-	.ndo_start_xmit		= net_send_packet,
-	.ndo_get_stats		= net_get_stats,
-	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_set_mac_address	= set_mac_address,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= net_poll_controller,
+	if (chip_type == CS8900) {
+#ifndef CONFIG_CS89x0_PLATFORM
+		/* Search the mapping table for the corresponding IRQ pin. */
+		for (i = 0; i != ARRAY_SIZE(cs8900_irq_map); i++)
+			if (cs8900_irq_map[i] == irq)
+				break;
+		/* Not found */
+		if (i == ARRAY_SIZE(cs8900_irq_map))
+			i = 3;
+#else
+		/* INTRQ0 pin is used for interrupt generation. */
+		i = 0;
 #endif
-	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_validate_addr	= eth_validate_addr,
-};
+		writereg(dev, PP_CS8900_ISAINT, i);
+	} else {
+		writereg(dev, PP_CS8920_ISAINT, irq);
+	}
+}
 
-/* This is the real probe routine.
- * Linux has a history of friendly device probes on the ISA bus.
- * A good device probes avoids doing writes, and
- * verifies that the correct device exists and functions.
- * Return 0 on success.
- */
-static int __init
-cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
+static void
+count_rx_errors(int status, struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
-	int i;
-	int tmp;
-	unsigned rev_type = 0;
-	int eeprom_buff[CHKSUM_LEN];
-	int retval;
+	dev->stats.rx_errors++;
+	if (status & RX_RUNT)
+		dev->stats.rx_length_errors++;
+	if (status & RX_EXTRA_DATA)
+		dev->stats.rx_length_errors++;
+	if ((status & RX_CRC_ERROR) && !(status & (RX_EXTRA_DATA | RX_RUNT)))
+		/* per str 172 */
+		dev->stats.rx_crc_errors++;
+	if (status & RX_DRIBBLE)
+		dev->stats.rx_frame_errors++;
+}
+
+/*********************************
+ * This page contains DMA routines
+ *********************************/
 
-	/* Initialize the device structure. */
-	if (!modular) {
-		memset(lp, 0, sizeof(*lp));
-		spin_lock_init(&lp->lock);
-#ifndef MODULE
 #if ALLOW_DMA
-		if (g_cs89x0_dma) {
-			lp->use_dma = 1;
-			lp->dma = g_cs89x0_dma;
-			lp->dmasize = 16;	/* Could make this an option... */
+
+#define dma_page_eq(ptr1, ptr2) ((long)(ptr1) >> 17 == (long)(ptr2) >> 17)
+
+static void
+get_dma_channel(struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+
+	if (lp->dma) {
+		dev->dma = lp->dma;
+		lp->isa_config |= ISA_RxDMA;
+	} else {
+		if ((lp->isa_config & ANY_ISA_DMA) == 0)
+			return;
+		dev->dma = lp->isa_config & DMA_NO_MASK;
+		if (lp->chip_type == CS8900)
+			dev->dma += 5;
+		if (dev->dma < 5 || dev->dma > 7) {
+			lp->isa_config &= ~ANY_ISA_DMA;
+			return;
 		}
-#endif
-		lp->force = g_cs89x0_media__force;
-#endif
 	}
+}
 
-	pr_debug("PP_addr at %p[%x]: 0x%x\n",
-		 ioaddr, ADD_PORT, ioread16(ioaddr + ADD_PORT));
-	iowrite16(PP_ChipID, ioaddr + ADD_PORT);
+static void
+write_dma(struct net_device *dev, int chip_type, int dma)
+{
+	struct net_local *lp = netdev_priv(dev);
+	if ((lp->isa_config & ANY_ISA_DMA) == 0)
+		return;
+	if (chip_type == CS8900)
+		writereg(dev, PP_CS8900_ISADMA, dma - 5);
+	else
+		writereg(dev, PP_CS8920_ISADMA, dma);
+}
 
-	tmp = ioread16(ioaddr + DATA_PORT);
-	if (tmp != CHIP_EISA_ID_SIG) {
-		pr_debug("%s: incorrect signature at %p[%x]: 0x%x!="
-			 CHIP_EISA_ID_SIG_STR "\n",
-			 dev->name, ioaddr, DATA_PORT, tmp);
-		retval = -ENODEV;
-		goto out1;
-	}
+static void
+set_dma_cfg(struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
 
-	lp->virt_addr = ioaddr;
+	if (lp->use_dma) {
+		if ((lp->isa_config & ANY_ISA_DMA) == 0) {
+			cs89_dbg(3, err, "set_dma_cfg(): no DMA\n");
+			return;
+		}
+		if (lp->isa_config & ISA_RxDMA) {
+			lp->curr_rx_cfg |= RX_DMA_ONLY;
+			cs89_dbg(3, info, "set_dma_cfg(): RX_DMA_ONLY\n");
+		} else {
+			lp->curr_rx_cfg |= AUTO_RX_DMA;	/* not that we support it... */
+			cs89_dbg(3, info, "set_dma_cfg(): AUTO_RX_DMA\n");
+		}
+	}
+}
 
-	/* get the chip type */
-	rev_type = readreg(dev, PRODUCT_ID_ADD);
-	lp->chip_type = rev_type & ~REVISON_BITS;
-	lp->chip_revision = ((rev_type & REVISON_BITS) >> 8) + 'A';
+static int
+dma_bufcfg(struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	if (lp->use_dma)
+		return (lp->isa_config & ANY_ISA_DMA) ? RX_DMA_ENBL : 0;
+	else
+		return 0;
+}
 
-	/* Check the chip type and revision in order to set the correct send command
-	   CS8920 revision C and CS8900 revision F can use the faster send. */
-	lp->send_cmd = TX_AFTER_381;
-	if (lp->chip_type == CS8900 && lp->chip_revision >= 'F')
-		lp->send_cmd = TX_NOW;
-	if (lp->chip_type != CS8900 && lp->chip_revision >= 'C')
-		lp->send_cmd = TX_NOW;
+static int
+dma_busctl(struct net_device *dev)
+{
+	int retval = 0;
+	struct net_local *lp = netdev_priv(dev);
+	if (lp->use_dma) {
+		if (lp->isa_config & ANY_ISA_DMA)
+			retval |= RESET_RX_DMA; /* Reset the DMA pointer */
+		if (lp->isa_config & DMA_BURST)
+			retval |= DMA_BURST_MODE; /* Does ISA config specify DMA burst ? */
+		if (lp->dmasize == 64)
+			retval |= RX_DMA_SIZE_64K; /* did they ask for 64K? */
+		retval |= MEMORY_ON;	/* we need memory enabled to use DMA. */
+	}
+	return retval;
+}
 
-	pr_info_once("%s\n", version);
+static void
+dma_rx(struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	struct sk_buff *skb;
+	int status, length;
+	unsigned char *bp = lp->rx_dma_ptr;
 
-	pr_info("%s: cs89%c0%s rev %c found at %p ",
-		dev->name,
-		lp->chip_type == CS8900  ? '0' : '2',
-		lp->chip_type == CS8920M ? "M" : "",
-		lp->chip_revision,
-		lp->virt_addr);
+	status = bp[0] + (bp[1] << 8);
+	length = bp[2] + (bp[3] << 8);
+	bp += 4;
 
-	reset_chip(dev);
+	cs89_dbg(5, debug, "%s: receiving DMA packet at %lx, status %x, length %x\n",
+		 dev->name, (unsigned long)bp, status, length);
 
-	/* Here we read the current configuration of the chip.
-	 * If there is no Extended EEPROM then the idea is to not disturb
-	 * the chip configuration, it should have been correctly setup by
-	 * automatic EEPROM read on reset. So, if the chip says it read
-	 * the EEPROM the driver will always do *something* instead of
-	 * complain that adapter_cnf is 0.
-	 */
+	if ((status & RX_OK) == 0) {
+		count_rx_errors(status, dev);
+		goto skip_this_frame;
+	}
 
-	if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) ==
-	    (EEPROM_OK | EEPROM_PRESENT)) {
-		/* Load the MAC. */
-		for (i = 0; i < ETH_ALEN / 2; i++) {
-			unsigned int Addr;
-			Addr = readreg(dev, PP_IA + i * 2);
-			dev->dev_addr[i * 2] = Addr & 0xFF;
-			dev->dev_addr[i * 2 + 1] = Addr >> 8;
-		}
+	/* Malloc up new buffer. */
+	skb = netdev_alloc_skb(dev, length + 2);
+	if (skb == NULL) {
+		/* I don't think we want to do this to a stressed system */
+		cs89_dbg(0, err, "%s: Memory squeeze, dropping packet\n",
+			 dev->name);
+		dev->stats.rx_dropped++;
 
-		/* Load the Adapter Configuration.
-		 * Note:  Barring any more specific information from some
-		 * other source (ie EEPROM+Schematics), we would not know
-		 * how to operate a 10Base2 interface on the AUI port.
-		 * However, since we  do read the status of HCB1 and use
-		 * settings that always result in calls to control_dc_dc(dev,0)
-		 * a BNC interface should work if the enable pin
-		 * (dc/dc converter) is on HCB1.
-		 * It will be called AUI however.
-		 */
-
-		lp->adapter_cnf = 0;
-		i = readreg(dev, PP_LineCTL);
-		/* Preserve the setting of the HCB1 pin. */
-		if ((i & (HCB1 | HCB1_ENBL)) == (HCB1 | HCB1_ENBL))
-			lp->adapter_cnf |= A_CNF_DC_DC_POLARITY;
-		/* Save the sqelch bit */
-		if ((i & LOW_RX_SQUELCH) == LOW_RX_SQUELCH)
-			lp->adapter_cnf |= A_CNF_EXTND_10B_2 | A_CNF_LOW_RX_SQUELCH;
-		/* Check if the card is in 10Base-t only mode */
-		if ((i & (AUI_ONLY | AUTO_AUI_10BASET)) == 0)
-			lp->adapter_cnf |=  A_CNF_10B_T | A_CNF_MEDIA_10B_T;
-		/* Check if the card is in AUI only mode */
-		if ((i & (AUI_ONLY | AUTO_AUI_10BASET)) == AUI_ONLY)
-			lp->adapter_cnf |=  A_CNF_AUI | A_CNF_MEDIA_AUI;
-		/* Check if the card is in Auto mode. */
-		if ((i & (AUI_ONLY | AUTO_AUI_10BASET)) == AUTO_AUI_10BASET)
-			lp->adapter_cnf |=  A_CNF_AUI | A_CNF_10B_T |
-				A_CNF_MEDIA_AUI | A_CNF_MEDIA_10B_T | A_CNF_MEDIA_AUTO;
-
-		cs89_dbg(1, info, "%s: PP_LineCTL=0x%x, adapter_cnf=0x%x\n",
-			 dev->name, i, lp->adapter_cnf);
-
-		/* IRQ. Other chips already probe, see below. */
-		if (lp->chip_type == CS8900)
-			lp->isa_config = readreg(dev, PP_CS8900_ISAINT) & INT_NO_MASK;
-
-		pr_cont("[Cirrus EEPROM] ");
-	}
-
-	pr_cont("\n");
-
-	/* First check to see if an EEPROM is attached. */
-
-	if ((readreg(dev, PP_SelfST) & EEPROM_PRESENT) == 0)
-		pr_warn("No EEPROM, relying on command line....\n");
-	else if (get_eeprom_data(dev, START_EEPROM_DATA, CHKSUM_LEN, eeprom_buff) < 0) {
-		pr_warn("EEPROM read failed, relying on command line\n");
-	} else if (get_eeprom_cksum(START_EEPROM_DATA, CHKSUM_LEN, eeprom_buff) < 0) {
-		/* Check if the chip was able to read its own configuration starting
-		   at 0 in the EEPROM*/
-		if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) !=
-		    (EEPROM_OK | EEPROM_PRESENT))
-			pr_warn("Extended EEPROM checksum bad and no Cirrus EEPROM, relying on command line\n");
+		/* AKPM: advance bp to the next frame */
+skip_this_frame:
+		bp += (length + 3) & ~3;
+		if (bp >= lp->end_dma_buff)
+			bp -= lp->dmasize * 1024;
+		lp->rx_dma_ptr = bp;
+		return;
+	}
+	skb_reserve(skb, 2);	/* longword align L3 header */
 
+	if (bp + length > lp->end_dma_buff) {
+		int semi_cnt = lp->end_dma_buff - bp;
+		memcpy(skb_put(skb, semi_cnt), bp, semi_cnt);
+		memcpy(skb_put(skb, length - semi_cnt), lp->dma_buff,
+		       length - semi_cnt);
 	} else {
-		/* This reads an extended EEPROM that is not documented
-		 * in the CS8900 datasheet.
-		 */
-
-		/* get transmission control word  but keep the autonegotiation bits */
-		if (!lp->auto_neg_cnf)
-			lp->auto_neg_cnf = eeprom_buff[AUTO_NEG_CNF_OFFSET / 2];
-		/* Store adapter configuration */
-		if (!lp->adapter_cnf)
-			lp->adapter_cnf = eeprom_buff[ADAPTER_CNF_OFFSET / 2];
-		/* Store ISA configuration */
-		lp->isa_config = eeprom_buff[ISA_CNF_OFFSET / 2];
-		dev->mem_start = eeprom_buff[PACKET_PAGE_OFFSET / 2] << 8;
-
-		/* eeprom_buff has 32-bit ints, so we can't just memcpy it */
-		/* store the initial memory base address */
-		for (i = 0; i < ETH_ALEN / 2; i++) {
-			dev->dev_addr[i * 2] = eeprom_buff[i];
-			dev->dev_addr[i * 2 + 1] = eeprom_buff[i] >> 8;
-		}
-		cs89_dbg(1, debug, "%s: new adapter_cnf: 0x%x\n",
-			 dev->name, lp->adapter_cnf);
+		memcpy(skb_put(skb, length), bp, length);
 	}
+	bp += (length + 3) & ~3;
+	if (bp >= lp->end_dma_buff)
+		bp -= lp->dmasize*1024;
+	lp->rx_dma_ptr = bp;
 
-	/* allow them to force multiple transceivers.  If they force multiple, autosense */
-	{
-		int count = 0;
-		if (lp->force & FORCE_RJ45) {
-			lp->adapter_cnf |= A_CNF_10B_T;
-			count++;
-		}
-		if (lp->force & FORCE_AUI) {
-			lp->adapter_cnf |= A_CNF_AUI;
-			count++;
-		}
-		if (lp->force & FORCE_BNC) {
-			lp->adapter_cnf |= A_CNF_10B_2;
-			count++;
-		}
-		if (count > 1)
-			lp->adapter_cnf |= A_CNF_MEDIA_AUTO;
-		else if (lp->force & FORCE_RJ45)
-			lp->adapter_cnf |= A_CNF_MEDIA_10B_T;
-		else if (lp->force & FORCE_AUI)
-			lp->adapter_cnf |= A_CNF_MEDIA_AUI;
-		else if (lp->force & FORCE_BNC)
-			lp->adapter_cnf |= A_CNF_MEDIA_10B_2;
-	}
+	cs89_dbg(3, info, "%s: received %d byte DMA packet of type %x\n",
+		 dev->name, length,
+		 ((skb->data[ETH_ALEN + ETH_ALEN] << 8) |
+		  skb->data[ETH_ALEN + ETH_ALEN + 1]));
 
-	cs89_dbg(1, debug, "%s: after force 0x%x, adapter_cnf=0x%x\n",
-		 dev->name, lp->force, lp->adapter_cnf);
+	skb->protocol = eth_type_trans(skb, dev);
+	netif_rx(skb);
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += length;
+}
 
-	/* FIXME: We don't let you set dc-dc polarity or low RX squelch from the command line: add it here */
+static void release_dma_buff(struct net_local *lp)
+{
+	if (lp->dma_buff) {
+		free_pages((unsigned long)(lp->dma_buff),
+			   get_order(lp->dmasize * 1024));
+		lp->dma_buff = NULL;
+	}
+}
 
-	/* FIXME: We don't let you set the IMM bit from the command line: add it to lp->auto_neg_cnf here */
+#endif	/* ALLOW_DMA */
 
-	/* FIXME: we don't set the Ethernet address on the command line.  Use
-	 * ifconfig IFACE hw ether AABBCCDDEEFF
+static void
+control_dc_dc(struct net_device *dev, int on_not_off)
+{
+	struct net_local *lp = netdev_priv(dev);
+	unsigned int selfcontrol;
+	int timenow = jiffies;
+	/* control the DC to DC convertor in the SelfControl register.
+	 * Note: This is hooked up to a general purpose pin, might not
+	 * always be a DC to DC convertor.
 	 */
 
-	pr_info("media %s%s%s",
-		(lp->adapter_cnf & A_CNF_10B_T) ? "RJ-45," : "",
-		(lp->adapter_cnf & A_CNF_AUI) ? "AUI," : "",
-		(lp->adapter_cnf & A_CNF_10B_2) ? "BNC," : "");
-
-	lp->irq_map = 0xffff;
-
-	/* If this is a CS8900 then no pnp soft */
-	if (lp->chip_type != CS8900 &&
-	    /* Check if the ISA IRQ has been set  */
-	    (i = readreg(dev, PP_CS8920_ISAINT) & 0xff,
-	     (i != 0 && i < CS8920_NO_INTS))) {
-		if (!dev->irq)
-			dev->irq = i;
-	} else {
-		i = lp->isa_config & INT_NO_MASK;
-#ifndef CONFIG_CS89x0_PLATFORM
-		if (lp->chip_type == CS8900) {
-#ifdef CS89x0_NONISA_IRQ
-			i = cs8900_irq_map[0];
-#else
-			/* Translate the IRQ using the IRQ mapping table. */
-			if (i >= ARRAY_SIZE(cs8900_irq_map))
-				pr_err("invalid ISA interrupt number %d\n", i);
-			else
-				i = cs8900_irq_map[i];
+	selfcontrol = HCB1_ENBL; /* Enable the HCB1 bit as an output */
+	if (((lp->adapter_cnf & A_CNF_DC_DC_POLARITY) != 0) ^ on_not_off)
+		selfcontrol |= HCB1;
+	else
+		selfcontrol &= ~HCB1;
+	writereg(dev, PP_SelfCTL, selfcontrol);
 
-			lp->irq_map = CS8900_IRQ_MAP; /* fixed IRQ map for CS8900 */
-		} else {
-			int irq_map_buff[IRQ_MAP_LEN/2];
+	/* Wait for the DC/DC converter to power up - 500ms */
+	while (jiffies - timenow < HZ)
+		;
+}
 
-			if (get_eeprom_data(dev, IRQ_MAP_EEPROM_DATA,
-					    IRQ_MAP_LEN / 2,
-					    irq_map_buff) >= 0) {
-				if ((irq_map_buff[0] & 0xff) == PNP_IRQ_FRMT)
-					lp->irq_map = ((irq_map_buff[0] >> 8) |
-						       (irq_map_buff[1] << 8));
-			}
-#endif
-		}
-#endif
-		if (!dev->irq)
-			dev->irq = i;
-	}
+/* send a test packet - return true if carrier bits are ok */
+static int
+send_test_pkt(struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	char test_packet[] = {
+		0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,
+		0, 46,		/* A 46 in network order */
+		0, 0,		/* DSAP=0 & SSAP=0 fields */
+		0xf3, 0		/* Control (Test Req + P bit set) */
+	};
+	long timenow = jiffies;
 
-	pr_cont(" IRQ %d", dev->irq);
+	writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) | SERIAL_TX_ON);
 
-#if ALLOW_DMA
-	if (lp->use_dma) {
-		get_dma_channel(dev);
-		pr_cont(", DMA %d", dev->dma);
-	} else
-#endif
-		pr_cont(", programmed I/O");
+	memcpy(test_packet,            dev->dev_addr, ETH_ALEN);
+	memcpy(test_packet + ETH_ALEN, dev->dev_addr, ETH_ALEN);
 
-	/* print the ethernet address. */
-	pr_cont(", MAC %pM\n", dev->dev_addr);
+	iowrite16(TX_AFTER_ALL, lp->virt_addr + TX_CMD_PORT);
+	iowrite16(ETH_ZLEN, lp->virt_addr + TX_LEN_PORT);
 
-	dev->netdev_ops	= &net_ops;
-	dev->watchdog_timeo = HZ;
+	/* Test to see if the chip has allocated memory for the packet */
+	while (jiffies - timenow < 5)
+		if (readreg(dev, PP_BusST) & READY_FOR_TX_NOW)
+			break;
+	if (jiffies - timenow >= 5)
+		return 0;	/* this shouldn't happen */
 
-	cs89_dbg(0, info, "cs89x0_probe1() successful\n");
+	/* Write the contents of the packet */
+	writewords(lp, TX_FRAME_PORT, test_packet, (ETH_ZLEN + 1) >> 1);
 
-	retval = register_netdev(dev);
-	if (retval)
-		goto out2;
+	cs89_dbg(1, debug, "Sending test packet ");
+	/* wait a couple of jiffies for packet to be received */
+	for (timenow = jiffies; jiffies - timenow < 3;)
+		;
+	if ((readreg(dev, PP_TxEvent) & TX_SEND_OK_BITS) == TX_OK) {
+		cs89_dbg(1, cont, "succeeded\n");
+		return 1;
+	}
+	cs89_dbg(1, cont, "failed\n");
 	return 0;
-out2:
-	iowrite16(PP_ChipID, lp->virt_addr + ADD_PORT);
-out1:
-	return retval;
 }
 
-#ifndef CONFIG_CS89x0_PLATFORM
-/*
- * This function converts the I/O port addres used by the cs89x0_probe() and
- * init_module() functions to the I/O memory address used by the
- * cs89x0_probe1() function.
- */
-static int __init
-cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
+#define DETECTED_NONE  0
+#define DETECTED_RJ45H 1
+#define DETECTED_RJ45F 2
+#define DETECTED_AUI   3
+#define DETECTED_BNC   4
+
+static int
+detect_tp(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
-	int ret;
-	void __iomem *io_mem;
-
-	if (!lp)
-		return -ENOMEM;
-
-	dev->base_addr = ioport;
-
-	if (!request_region(ioport, NETCARD_IO_EXTENT, DRV_NAME)) {
-		ret = -EBUSY;
-		goto out;
-	}
+	int timenow = jiffies;
+	int fdx;
 
-	io_mem = ioport_map(ioport & ~3, NETCARD_IO_EXTENT);
-	if (!io_mem) {
-		ret = -ENOMEM;
-		goto release;
-	}
+	cs89_dbg(1, debug, "%s: Attempting TP\n", dev->name);
 
-	/* if they give us an odd I/O address, then do ONE write to
-	 * the address port, to get it back to address zero, where we
-	 * expect to find the EISA signature word. An IO with a base of 0x3
-	 * will skip the test for the ADD_PORT.
+	/* If connected to another full duplex capable 10-Base-T card
+	 * the link pulses seem to be lost when the auto detect bit in
+	 * the LineCTL is set.  To overcome this the auto detect bit will
+	 * be cleared whilst testing the 10-Base-T interface.  This would
+	 * not be necessary for the sparrow chip but is simpler to do it
+	 * anyway.
 	 */
-	if (ioport & 1) {
-		cs89_dbg(1, info, "%s: odd ioaddr 0x%lx\n", dev->name, ioport);
-		if ((ioport & 2) != 2) {
-			if ((ioread16(io_mem + ADD_PORT) & ADD_MASK) !=
-			    ADD_SIG) {
-				pr_err("%s: bad signature 0x%x\n",
-				       dev->name, ioread16(io_mem + ADD_PORT));
-				ret = -ENODEV;
-				goto unmap;
-			}
-		}
-	}
-
-	ret = cs89x0_probe1(dev, io_mem, modular);
-	if (!ret)
-		goto out;
-unmap:
-	ioport_unmap(io_mem);
-release:
-	release_region(ioport, NETCARD_IO_EXTENT);
-out:
-	return ret;
-}
-
-#ifndef MODULE
-/* Check for a network adaptor of this type, and return '0' iff one exists.
- * If dev->base_addr == 0, probe all likely locations.
- * If dev->base_addr == 1, always return failure.
- * If dev->base_addr == 2, allocate space for the device and return success
- * (detachable devices only).
- * Return 0 on success.
- */
-
-struct net_device * __init cs89x0_probe(int unit)
-{
-	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
-	unsigned *port;
-	int err = 0;
-	int irq;
-	int io;
-
-	if (!dev)
-		return ERR_PTR(-ENODEV);
-
-	sprintf(dev->name, "eth%d", unit);
-	netdev_boot_setup_check(dev);
-	io = dev->base_addr;
-	irq = dev->irq;
+	writereg(dev, PP_LineCTL, lp->linectl & ~AUI_ONLY);
+	control_dc_dc(dev, 0);
 
-	cs89_dbg(0, info, "cs89x0_probe(0x%x)\n", io);
+	/* Delay for the hardware to work out if the TP cable is present
+	 * - 150ms
+	 */
+	for (timenow = jiffies; jiffies - timenow < 15;)
+		;
+	if ((readreg(dev, PP_LineST) & LINK_OK) == 0)
+		return DETECTED_NONE;
 
-	if (io > 0x1ff)	{	/* Check a single specified location. */
-		err = cs89x0_ioport_probe(dev, io, 0);
-	} else if (io != 0) {	/* Don't probe at all. */
-		err = -ENXIO;
+	if (lp->chip_type == CS8900) {
+		switch (lp->force & 0xf0) {
+#if 0
+		case FORCE_AUTO:
+			pr_info("%s: cs8900 doesn't autonegotiate\n",
+				dev->name);
+			return DETECTED_NONE;
+#endif
+			/* CS8900 doesn't support AUTO, change to HALF*/
+		case FORCE_AUTO:
+			lp->force &= ~FORCE_AUTO;
+			lp->force |= FORCE_HALF;
+			break;
+		case FORCE_HALF:
+			break;
+		case FORCE_FULL:
+			writereg(dev, PP_TestCTL,
+				 readreg(dev, PP_TestCTL) | FDX_8900);
+			break;
+		}
+		fdx = readreg(dev, PP_TestCTL) & FDX_8900;
 	} else {
-		for (port = netcard_portlist; *port; port++) {
-			if (cs89x0_ioport_probe(dev, *port, 0) == 0)
-				break;
-			dev->irq = irq;
+		switch (lp->force & 0xf0) {
+		case FORCE_AUTO:
+			lp->auto_neg_cnf = AUTO_NEG_ENABLE;
+			break;
+		case FORCE_HALF:
+			lp->auto_neg_cnf = 0;
+			break;
+		case FORCE_FULL:
+			lp->auto_neg_cnf = RE_NEG_NOW | ALLOW_FDX;
+			break;
 		}
-		if (!*port)
-			err = -ENODEV;
-	}
-	if (err)
-		goto out;
-	return dev;
-out:
-	free_netdev(dev);
-	pr_warn("no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP\n");
-	return ERR_PTR(err);
-}
-#endif
-#endif
-
-/*********************************
- * This page contains DMA routines
- *********************************/
-
-#if ALLOW_DMA
-
-#define dma_page_eq(ptr1, ptr2) ((long)(ptr1) >> 17 == (long)(ptr2) >> 17)
 
-static void
-get_dma_channel(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
+		writereg(dev, PP_AutoNegCTL, lp->auto_neg_cnf & AUTO_NEG_MASK);
 
-	if (lp->dma) {
-		dev->dma = lp->dma;
-		lp->isa_config |= ISA_RxDMA;
-	} else {
-		if ((lp->isa_config & ANY_ISA_DMA) == 0)
-			return;
-		dev->dma = lp->isa_config & DMA_NO_MASK;
-		if (lp->chip_type == CS8900)
-			dev->dma += 5;
-		if (dev->dma < 5 || dev->dma > 7) {
-			lp->isa_config &= ~ANY_ISA_DMA;
-			return;
+		if ((lp->auto_neg_cnf & AUTO_NEG_BITS) == AUTO_NEG_ENABLE) {
+			pr_info("%s: negotiating duplex...\n", dev->name);
+			while (readreg(dev, PP_AutoNegST) & AUTO_NEG_BUSY) {
+				if (jiffies - timenow > 4000) {
+					pr_err("**** Full / half duplex auto-negotiation timed out ****\n");
+					break;
+				}
+			}
 		}
+		fdx = readreg(dev, PP_AutoNegST) & FDX_ACTIVE;
 	}
-}
-
-static void
-write_dma(struct net_device *dev, int chip_type, int dma)
-{
-	struct net_local *lp = netdev_priv(dev);
-	if ((lp->isa_config & ANY_ISA_DMA) == 0)
-		return;
-	if (chip_type == CS8900)
-		writereg(dev, PP_CS8900_ISADMA, dma - 5);
+	if (fdx)
+		return DETECTED_RJ45F;
 	else
-		writereg(dev, PP_CS8920_ISADMA, dma);
+		return DETECTED_RJ45H;
 }
 
-static void
-set_dma_cfg(struct net_device *dev)
+static int
+detect_bnc(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 
-	if (lp->use_dma) {
-		if ((lp->isa_config & ANY_ISA_DMA) == 0) {
-			cs89_dbg(3, err, "set_dma_cfg(): no DMA\n");
-			return;
-		}
-		if (lp->isa_config & ISA_RxDMA) {
-			lp->curr_rx_cfg |= RX_DMA_ONLY;
-			cs89_dbg(3, info, "set_dma_cfg(): RX_DMA_ONLY\n");
-		} else {
-			lp->curr_rx_cfg |= AUTO_RX_DMA;	/* not that we support it... */
-			cs89_dbg(3, info, "set_dma_cfg(): AUTO_RX_DMA\n");
-		}
-	}
-}
+	cs89_dbg(1, debug, "%s: Attempting BNC\n", dev->name);
+	control_dc_dc(dev, 1);
 
-static int
-dma_bufcfg(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-	if (lp->use_dma)
-		return (lp->isa_config & ANY_ISA_DMA) ? RX_DMA_ENBL : 0;
+	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
+
+	if (send_test_pkt(dev))
+		return DETECTED_BNC;
 	else
-		return 0;
+		return DETECTED_NONE;
 }
 
 static int
-dma_busctl(struct net_device *dev)
+detect_aui(struct net_device *dev)
 {
-	int retval = 0;
 	struct net_local *lp = netdev_priv(dev);
-	if (lp->use_dma) {
-		if (lp->isa_config & ANY_ISA_DMA)
-			retval |= RESET_RX_DMA; /* Reset the DMA pointer */
-		if (lp->isa_config & DMA_BURST)
-			retval |= DMA_BURST_MODE; /* Does ISA config specify DMA burst ? */
-		if (lp->dmasize == 64)
-			retval |= RX_DMA_SIZE_64K; /* did they ask for 64K? */
-		retval |= MEMORY_ON;	/* we need memory enabled to use DMA. */
-	}
-	return retval;
+
+	cs89_dbg(1, debug, "%s: Attempting AUI\n", dev->name);
+	control_dc_dc(dev, 0);
+
+	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
+
+	if (send_test_pkt(dev))
+		return DETECTED_AUI;
+	else
+		return DETECTED_NONE;
 }
 
+/* We have a good packet(s), get it/them out of the buffers. */
 static void
-dma_rx(struct net_device *dev)
+net_rx(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int status, length;
-	unsigned char *bp = lp->rx_dma_ptr;
-
-	status = bp[0] + (bp[1] << 8);
-	length = bp[2] + (bp[3] << 8);
-	bp += 4;
 
-	cs89_dbg(5, debug, "%s: receiving DMA packet at %lx, status %x, length %x\n",
-		 dev->name, (unsigned long)bp, status, length);
+	status = ioread16(lp->virt_addr + RX_FRAME_PORT);
+	length = ioread16(lp->virt_addr + RX_FRAME_PORT);
 
 	if ((status & RX_OK) == 0) {
 		count_rx_errors(status, dev);
-		goto skip_this_frame;
+		return;
 	}
 
 	/* Malloc up new buffer. */
 	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
-		/* I don't think we want to do this to a stressed system */
-		cs89_dbg(0, err, "%s: Memory squeeze, dropping packet\n",
-			 dev->name);
+#if 0		/* Again, this seems a cruel thing to do */
+		pr_warn("%s: Memory squeeze, dropping packet\n", dev->name);
+#endif
 		dev->stats.rx_dropped++;
-
-		/* AKPM: advance bp to the next frame */
-skip_this_frame:
-		bp += (length + 3) & ~3;
-		if (bp >= lp->end_dma_buff)
-			bp -= lp->dmasize * 1024;
-		lp->rx_dma_ptr = bp;
 		return;
 	}
 	skb_reserve(skb, 2);	/* longword align L3 header */
 
-	if (bp + length > lp->end_dma_buff) {
-		int semi_cnt = lp->end_dma_buff - bp;
-		memcpy(skb_put(skb, semi_cnt), bp, semi_cnt);
-		memcpy(skb_put(skb, length - semi_cnt), lp->dma_buff,
-		       length - semi_cnt);
-	} else {
-		memcpy(skb_put(skb, length), bp, length);
-	}
-	bp += (length + 3) & ~3;
-	if (bp >= lp->end_dma_buff)
-		bp -= lp->dmasize*1024;
-	lp->rx_dma_ptr = bp;
+	readwords(lp, RX_FRAME_PORT, skb_put(skb, length), length >> 1);
+	if (length & 1)
+		skb->data[length-1] = ioread16(lp->virt_addr + RX_FRAME_PORT);
 
-	cs89_dbg(3, info, "%s: received %d byte DMA packet of type %x\n",
+	cs89_dbg(3, debug, "%s: received %d byte packet of type %x\n",
 		 dev->name, length,
-		 ((skb->data[ETH_ALEN + ETH_ALEN] << 8) |
-		  skb->data[ETH_ALEN + ETH_ALEN + 1]));
+		 (skb->data[ETH_ALEN + ETH_ALEN] << 8) |
+		 skb->data[ETH_ALEN + ETH_ALEN + 1]);
 
 	skb->protocol = eth_type_trans(skb, dev);
 	netif_rx(skb);
@@ -915,278 +754,137 @@ skip_this_frame:
 	dev->stats.rx_bytes += length;
 }
 
-#endif	/* ALLOW_DMA */
+/* The typical workload of the driver:
+ * Handle the network interface interrupts.
+ */
 
-static void __init reset_chip(struct net_device *dev)
+static irqreturn_t net_interrupt(int irq, void *dev_id)
 {
-#if !defined(CONFIG_MACH_MX31ADS)
-#if !defined(CS89x0_NONISA_IRQ)
-	struct net_local *lp = netdev_priv(dev);
-#endif /* CS89x0_NONISA_IRQ */
-	int reset_start_time;
-
-	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
-
-	/* wait 30 ms */
-	msleep(30);
+	struct net_device *dev = dev_id;
+	struct net_local *lp;
+	int status;
+	int handled = 0;
 
-#if !defined(CS89x0_NONISA_IRQ)
-	if (lp->chip_type != CS8900) {
-		/* Hardware problem requires PNP registers to be reconfigured after a reset */
-		iowrite16(PP_CS8920_ISAINT, lp->virt_addr + ADD_PORT);
-		iowrite8(dev->irq, lp->virt_addr + DATA_PORT);
-		iowrite8(0, lp->virt_addr + DATA_PORT + 1);
+	lp = netdev_priv(dev);
 
-		iowrite16(PP_CS8920_ISAMemB, lp->virt_addr + ADD_PORT);
-		iowrite8((dev->mem_start >> 16) & 0xff,
-			 lp->virt_addr + DATA_PORT);
-		iowrite8((dev->mem_start >> 8) & 0xff,
-			 lp->virt_addr + DATA_PORT + 1);
+	/* we MUST read all the events out of the ISQ, otherwise we'll never
+	 * get interrupted again.  As a consequence, we can't have any limit
+	 * on the number of times we loop in the interrupt handler.  The
+	 * hardware guarantees that eventually we'll run out of events.  Of
+	 * course, if you're on a slow machine, and packets are arriving
+	 * faster than you can read them off, you're screwed.  Hasta la
+	 * vista, baby!
+	 */
+	while ((status = ioread16(lp->virt_addr + ISQ_PORT))) {
+		cs89_dbg(4, debug, "%s: event=%04x\n", dev->name, status);
+		handled = 1;
+		switch (status & ISQ_EVENT_MASK) {
+		case ISQ_RECEIVER_EVENT:
+			/* Got a packet(s). */
+			net_rx(dev);
+			break;
+		case ISQ_TRANSMITTER_EVENT:
+			dev->stats.tx_packets++;
+			netif_wake_queue(dev);	/* Inform upper layers. */
+			if ((status & (TX_OK |
+				       TX_LOST_CRS |
+				       TX_SQE_ERROR |
+				       TX_LATE_COL |
+				       TX_16_COL)) != TX_OK) {
+				if ((status & TX_OK) == 0)
+					dev->stats.tx_errors++;
+				if (status & TX_LOST_CRS)
+					dev->stats.tx_carrier_errors++;
+				if (status & TX_SQE_ERROR)
+					dev->stats.tx_heartbeat_errors++;
+				if (status & TX_LATE_COL)
+					dev->stats.tx_window_errors++;
+				if (status & TX_16_COL)
+					dev->stats.tx_aborted_errors++;
+			}
+			break;
+		case ISQ_BUFFER_EVENT:
+			if (status & READY_FOR_TX) {
+				/* we tried to transmit a packet earlier,
+				 * but inexplicably ran out of buffers.
+				 * That shouldn't happen since we only ever
+				 * load one packet.  Shrug.  Do the right
+				 * thing anyway.
+				 */
+				netif_wake_queue(dev);	/* Inform upper layers. */
+			}
+			if (status & TX_UNDERRUN) {
+				cs89_dbg(0, err, "%s: transmit underrun\n",
+					 dev->name);
+				lp->send_underrun++;
+				if (lp->send_underrun == 3)
+					lp->send_cmd = TX_AFTER_381;
+				else if (lp->send_underrun == 6)
+					lp->send_cmd = TX_AFTER_ALL;
+				/* transmit cycle is done, although
+				 * frame wasn't transmitted - this
+				 * avoids having to wait for the upper
+				 * layers to timeout on us, in the
+				 * event of a tx underrun
+				 */
+				netif_wake_queue(dev);	/* Inform upper layers. */
+			}
+#if ALLOW_DMA
+			if (lp->use_dma && (status & RX_DMA)) {
+				int count = readreg(dev, PP_DmaFrameCnt);
+				while (count) {
+					cs89_dbg(5, debug,
+						 "%s: receiving %d DMA frames\n",
+						 dev->name, count);
+					if (count > 1)
+						cs89_dbg(2, debug,
+							 "%s: receiving %d DMA frames\n",
+							 dev->name, count);
+					dma_rx(dev);
+					if (--count == 0)
+						count = readreg(dev, PP_DmaFrameCnt);
+					if (count > 0)
+						cs89_dbg(2, debug,
+							 "%s: continuing with %d DMA frames\n",
+							 dev->name, count);
+				}
+			}
+#endif
+			break;
+		case ISQ_RX_MISS_EVENT:
+			dev->stats.rx_missed_errors += (status >> 6);
+			break;
+		case ISQ_TX_COL_EVENT:
+			dev->stats.collisions += (status >> 6);
+			break;
+		}
 	}
-#endif /* CS89x0_NONISA_IRQ */
-
-	/* Wait until the chip is reset */
-	reset_start_time = jiffies;
-	while ((readreg(dev, PP_SelfST) & INIT_DONE) == 0 &&
-	       jiffies - reset_start_time < 2)
-		;
-#endif /* !CONFIG_MACH_MX31ADS */
+	return IRQ_RETVAL(handled);
 }
 
+/* Open/initialize the board.  This is called (in the current kernel)
+   sometime after booting when the 'ifconfig' program is run.
 
-static void
-control_dc_dc(struct net_device *dev, int on_not_off)
-{
-	struct net_local *lp = netdev_priv(dev);
-	unsigned int selfcontrol;
-	int timenow = jiffies;
-	/* control the DC to DC convertor in the SelfControl register.
-	 * Note: This is hooked up to a general purpose pin, might not
-	 * always be a DC to DC convertor.
-	 */
-
-	selfcontrol = HCB1_ENBL; /* Enable the HCB1 bit as an output */
-	if (((lp->adapter_cnf & A_CNF_DC_DC_POLARITY) != 0) ^ on_not_off)
-		selfcontrol |= HCB1;
-	else
-		selfcontrol &= ~HCB1;
-	writereg(dev, PP_SelfCTL, selfcontrol);
-
-	/* Wait for the DC/DC converter to power up - 500ms */
-	while (jiffies - timenow < HZ)
-		;
-}
+   This routine should set everything up anew at each open, even
+   registers that "should" only need to be set once at boot, so that
+   there is non-reboot way to recover if something goes wrong.
+*/
 
-#define DETECTED_NONE  0
-#define DETECTED_RJ45H 1
-#define DETECTED_RJ45F 2
-#define DETECTED_AUI   3
-#define DETECTED_BNC   4
+/* AKPM: do we need to do any locking here? */
 
 static int
-detect_tp(struct net_device *dev)
+net_open(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
-	int timenow = jiffies;
-	int fdx;
-
-	cs89_dbg(1, debug, "%s: Attempting TP\n", dev->name);
-
-	/* If connected to another full duplex capable 10-Base-T card
-	 * the link pulses seem to be lost when the auto detect bit in
-	 * the LineCTL is set.  To overcome this the auto detect bit will
-	 * be cleared whilst testing the 10-Base-T interface.  This would
-	 * not be necessary for the sparrow chip but is simpler to do it
-	 * anyway.
-	 */
-	writereg(dev, PP_LineCTL, lp->linectl & ~AUI_ONLY);
-	control_dc_dc(dev, 0);
-
-	/* Delay for the hardware to work out if the TP cable is present
-	 * - 150ms
-	 */
-	for (timenow = jiffies; jiffies - timenow < 15;)
-		;
-	if ((readreg(dev, PP_LineST) & LINK_OK) == 0)
-		return DETECTED_NONE;
+	int result = 0;
+	int i;
+	int ret;
 
-	if (lp->chip_type == CS8900) {
-		switch (lp->force & 0xf0) {
+	if (dev->irq < 2) {
+		/* Allow interrupts to be generated by the chip */
+/* Cirrus' release had this: */
 #if 0
-		case FORCE_AUTO:
-			pr_info("%s: cs8900 doesn't autonegotiate\n",
-				dev->name);
-			return DETECTED_NONE;
-#endif
-			/* CS8900 doesn't support AUTO, change to HALF*/
-		case FORCE_AUTO:
-			lp->force &= ~FORCE_AUTO;
-			lp->force |= FORCE_HALF;
-			break;
-		case FORCE_HALF:
-			break;
-		case FORCE_FULL:
-			writereg(dev, PP_TestCTL,
-				 readreg(dev, PP_TestCTL) | FDX_8900);
-			break;
-		}
-		fdx = readreg(dev, PP_TestCTL) & FDX_8900;
-	} else {
-		switch (lp->force & 0xf0) {
-		case FORCE_AUTO:
-			lp->auto_neg_cnf = AUTO_NEG_ENABLE;
-			break;
-		case FORCE_HALF:
-			lp->auto_neg_cnf = 0;
-			break;
-		case FORCE_FULL:
-			lp->auto_neg_cnf = RE_NEG_NOW | ALLOW_FDX;
-			break;
-		}
-
-		writereg(dev, PP_AutoNegCTL, lp->auto_neg_cnf & AUTO_NEG_MASK);
-
-		if ((lp->auto_neg_cnf & AUTO_NEG_BITS) == AUTO_NEG_ENABLE) {
-			pr_info("%s: negotiating duplex...\n", dev->name);
-			while (readreg(dev, PP_AutoNegST) & AUTO_NEG_BUSY) {
-				if (jiffies - timenow > 4000) {
-					pr_err("**** Full / half duplex auto-negotiation timed out ****\n");
-					break;
-				}
-			}
-		}
-		fdx = readreg(dev, PP_AutoNegST) & FDX_ACTIVE;
-	}
-	if (fdx)
-		return DETECTED_RJ45F;
-	else
-		return DETECTED_RJ45H;
-}
-
-/* send a test packet - return true if carrier bits are ok */
-static int
-send_test_pkt(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-	char test_packet[] = {
-		0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,
-		0, 46,		/* A 46 in network order */
-		0, 0,		/* DSAP=0 & SSAP=0 fields */
-		0xf3, 0		/* Control (Test Req + P bit set) */
-	};
-	long timenow = jiffies;
-
-	writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) | SERIAL_TX_ON);
-
-	memcpy(test_packet,            dev->dev_addr, ETH_ALEN);
-	memcpy(test_packet + ETH_ALEN, dev->dev_addr, ETH_ALEN);
-
-	iowrite16(TX_AFTER_ALL, lp->virt_addr + TX_CMD_PORT);
-	iowrite16(ETH_ZLEN, lp->virt_addr + TX_LEN_PORT);
-
-	/* Test to see if the chip has allocated memory for the packet */
-	while (jiffies - timenow < 5)
-		if (readreg(dev, PP_BusST) & READY_FOR_TX_NOW)
-			break;
-	if (jiffies - timenow >= 5)
-		return 0;	/* this shouldn't happen */
-
-	/* Write the contents of the packet */
-	writewords(lp, TX_FRAME_PORT, test_packet, (ETH_ZLEN + 1) >> 1);
-
-	cs89_dbg(1, debug, "Sending test packet ");
-	/* wait a couple of jiffies for packet to be received */
-	for (timenow = jiffies; jiffies - timenow < 3;)
-		;
-	if ((readreg(dev, PP_TxEvent) & TX_SEND_OK_BITS) == TX_OK) {
-		cs89_dbg(1, cont, "succeeded\n");
-		return 1;
-	}
-	cs89_dbg(1, cont, "failed\n");
-	return 0;
-}
-
-
-static int
-detect_aui(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-
-	cs89_dbg(1, debug, "%s: Attempting AUI\n", dev->name);
-	control_dc_dc(dev, 0);
-
-	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
-
-	if (send_test_pkt(dev))
-		return DETECTED_AUI;
-	else
-		return DETECTED_NONE;
-}
-
-static int
-detect_bnc(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-
-	cs89_dbg(1, debug, "%s: Attempting BNC\n", dev->name);
-	control_dc_dc(dev, 1);
-
-	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
-
-	if (send_test_pkt(dev))
-		return DETECTED_BNC;
-	else
-		return DETECTED_NONE;
-}
-
-
-static void
-write_irq(struct net_device *dev, int chip_type, int irq)
-{
-	int i;
-
-	if (chip_type == CS8900) {
-#ifndef CONFIG_CS89x0_PLATFORM
-		/* Search the mapping table for the corresponding IRQ pin. */
-		for (i = 0; i != ARRAY_SIZE(cs8900_irq_map); i++)
-			if (cs8900_irq_map[i] == irq)
-				break;
-		/* Not found */
-		if (i == ARRAY_SIZE(cs8900_irq_map))
-			i = 3;
-#else
-		/* INTRQ0 pin is used for interrupt generation. */
-		i = 0;
-#endif
-		writereg(dev, PP_CS8900_ISAINT, i);
-	} else {
-		writereg(dev, PP_CS8920_ISAINT, irq);
-	}
-}
-
-/* Open/initialize the board.  This is called (in the current kernel)
-   sometime after booting when the 'ifconfig' program is run.
-
-   This routine should set everything up anew at each open, even
-   registers that "should" only need to be set once at boot, so that
-   there is non-reboot way to recover if something goes wrong.
-*/
-
-/* AKPM: do we need to do any locking here? */
-
-static int
-net_open(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-	int result = 0;
-	int i;
-	int ret;
-
-	if (dev->irq < 2) {
-		/* Allow interrupts to be generated by the chip */
-/* Cirrus' release had this: */
-#if 0
-		writereg(dev, PP_BusCTL, readreg(dev, PP_BusCTL) | ENABLE_IRQ);
+		writereg(dev, PP_BusCTL, readreg(dev, PP_BusCTL) | ENABLE_IRQ);
 #endif
 /* And 2.3.47 had this: */
 		writereg(dev, PP_BusCTL, ENABLE_IRQ | MEMORY_ON);
@@ -1433,6 +1131,52 @@ bad_out:
 	return ret;
 }
 
+/* The inverse routine to net_open(). */
+static int
+net_close(struct net_device *dev)
+{
+#if ALLOW_DMA
+	struct net_local *lp = netdev_priv(dev);
+#endif
+
+	netif_stop_queue(dev);
+
+	writereg(dev, PP_RxCFG, 0);
+	writereg(dev, PP_TxCFG, 0);
+	writereg(dev, PP_BufCFG, 0);
+	writereg(dev, PP_BusCTL, 0);
+
+	free_irq(dev->irq, dev);
+
+#if ALLOW_DMA
+	if (lp->use_dma && lp->dma) {
+		free_dma(dev->dma);
+		release_dma_buff(lp);
+	}
+#endif
+
+	/* Update the statistics here. */
+	return 0;
+}
+
+/* Get the current statistics.
+ * This may be called with the card open or closed.
+ */
+static struct net_device_stats *
+net_get_stats(struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	/* Update the statistics from the device registers. */
+	dev->stats.rx_missed_errors += (readreg(dev, PP_RxMiss) >> 6);
+	dev->stats.collisions += (readreg(dev, PP_TxCol) >> 6);
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	return &dev->stats;
+}
+
 static void net_timeout(struct net_device *dev)
 {
 	/* If we get here, some higher level has decided we are broken.
@@ -1495,278 +1239,509 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-/* The typical workload of the driver:
- * Handle the network interface interrupts.
- */
-
-static irqreturn_t net_interrupt(int irq, void *dev_id)
+static void set_multicast_list(struct net_device *dev)
 {
-	struct net_device *dev = dev_id;
-	struct net_local *lp;
-	int status;
-	int handled = 0;
+	struct net_local *lp = netdev_priv(dev);
+	unsigned long flags;
 
-	lp = netdev_priv(dev);
+	spin_lock_irqsave(&lp->lock, flags);
+	if (dev->flags & IFF_PROMISC)
+		lp->rx_mode = RX_ALL_ACCEPT;
+	else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev))
+		/* The multicast-accept list is initialized to accept-all,
+		 * and we rely on higher-level filtering for now.
+		 */
+		lp->rx_mode = RX_MULTCAST_ACCEPT;
+	else
+		lp->rx_mode = 0;
 
-	/* we MUST read all the events out of the ISQ, otherwise we'll never
-	 * get interrupted again.  As a consequence, we can't have any limit
-	 * on the number of times we loop in the interrupt handler.  The
-	 * hardware guarantees that eventually we'll run out of events.  Of
-	 * course, if you're on a slow machine, and packets are arriving
-	 * faster than you can read them off, you're screwed.  Hasta la
-	 * vista, baby!
+	writereg(dev, PP_RxCTL, DEF_RX_ACCEPT | lp->rx_mode);
+
+	/* in promiscuous mode, we accept errored packets,
+	 * so we have to enable interrupts on them also
 	 */
-	while ((status = ioread16(lp->virt_addr + ISQ_PORT))) {
-		cs89_dbg(4, debug, "%s: event=%04x\n", dev->name, status);
-		handled = 1;
-		switch (status & ISQ_EVENT_MASK) {
-		case ISQ_RECEIVER_EVENT:
-			/* Got a packet(s). */
-			net_rx(dev);
-			break;
-		case ISQ_TRANSMITTER_EVENT:
-			dev->stats.tx_packets++;
-			netif_wake_queue(dev);	/* Inform upper layers. */
-			if ((status & (TX_OK |
-				       TX_LOST_CRS |
-				       TX_SQE_ERROR |
-				       TX_LATE_COL |
-				       TX_16_COL)) != TX_OK) {
-				if ((status & TX_OK) == 0)
-					dev->stats.tx_errors++;
-				if (status & TX_LOST_CRS)
-					dev->stats.tx_carrier_errors++;
-				if (status & TX_SQE_ERROR)
-					dev->stats.tx_heartbeat_errors++;
-				if (status & TX_LATE_COL)
-					dev->stats.tx_window_errors++;
-				if (status & TX_16_COL)
-					dev->stats.tx_aborted_errors++;
-			}
-			break;
-		case ISQ_BUFFER_EVENT:
-			if (status & READY_FOR_TX) {
-				/* we tried to transmit a packet earlier,
-				 * but inexplicably ran out of buffers.
-				 * That shouldn't happen since we only ever
-				 * load one packet.  Shrug.  Do the right
-				 * thing anyway.
-				 */
-				netif_wake_queue(dev);	/* Inform upper layers. */
-			}
-			if (status & TX_UNDERRUN) {
-				cs89_dbg(0, err, "%s: transmit underrun\n",
-					 dev->name);
-				lp->send_underrun++;
-				if (lp->send_underrun == 3)
-					lp->send_cmd = TX_AFTER_381;
-				else if (lp->send_underrun == 6)
-					lp->send_cmd = TX_AFTER_ALL;
-				/* transmit cycle is done, although
-				 * frame wasn't transmitted - this
-				 * avoids having to wait for the upper
-				 * layers to timeout on us, in the
-				 * event of a tx underrun
-				 */
-				netif_wake_queue(dev);	/* Inform upper layers. */
-			}
-#if ALLOW_DMA
-			if (lp->use_dma && (status & RX_DMA)) {
-				int count = readreg(dev, PP_DmaFrameCnt);
-				while (count) {
-					cs89_dbg(5, debug,
-						 "%s: receiving %d DMA frames\n",
-						 dev->name, count);
-					if (count > 1)
-						cs89_dbg(2, debug,
-							 "%s: receiving %d DMA frames\n",
-							 dev->name, count);
-					dma_rx(dev);
-					if (--count == 0)
-						count = readreg(dev, PP_DmaFrameCnt);
-					if (count > 0)
-						cs89_dbg(2, debug,
-							 "%s: continuing with %d DMA frames\n",
-							 dev->name, count);
-				}
-			}
-#endif
-			break;
-		case ISQ_RX_MISS_EVENT:
-			dev->stats.rx_missed_errors += (status >> 6);
-			break;
-		case ISQ_TX_COL_EVENT:
-			dev->stats.collisions += (status >> 6);
-			break;
-		}
-	}
-	return IRQ_RETVAL(handled);
+	writereg(dev, PP_RxCFG,
+		 (lp->curr_rx_cfg |
+		  (lp->rx_mode == RX_ALL_ACCEPT)
+		  ? (RX_CRC_ERROR_ENBL | RX_RUNT_ENBL | RX_EXTRA_DATA_ENBL)
+		  : 0));
+	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
-static void
-count_rx_errors(int status, struct net_device *dev)
+static int set_mac_address(struct net_device *dev, void *p)
 {
-	dev->stats.rx_errors++;
-	if (status & RX_RUNT)
-		dev->stats.rx_length_errors++;
-	if (status & RX_EXTRA_DATA)
-		dev->stats.rx_length_errors++;
-	if ((status & RX_CRC_ERROR) && !(status & (RX_EXTRA_DATA | RX_RUNT)))
-		/* per str 172 */
-		dev->stats.rx_crc_errors++;
-	if (status & RX_DRIBBLE)
-		dev->stats.rx_frame_errors++;
+	int i;
+	struct sockaddr *addr = p;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	cs89_dbg(0, debug, "%s: Setting MAC address to %pM\n",
+		 dev->name, dev->dev_addr);
+
+	/* set the Ethernet address */
+	for (i = 0; i < ETH_ALEN / 2; i++)
+		writereg(dev, PP_IA + i * 2,
+			 (dev->dev_addr[i * 2] |
+			  (dev->dev_addr[i * 2 + 1] << 8)));
+
+	return 0;
 }
 
-/* We have a good packet(s), get it/them out of the buffers. */
-static void
-net_rx(struct net_device *dev)
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void net_poll_controller(struct net_device *dev)
 {
+	disable_irq(dev->irq);
+	net_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
+static const struct net_device_ops net_ops = {
+	.ndo_open		= net_open,
+	.ndo_stop		= net_close,
+	.ndo_tx_timeout		= net_timeout,
+	.ndo_start_xmit		= net_send_packet,
+	.ndo_get_stats		= net_get_stats,
+	.ndo_set_rx_mode	= set_multicast_list,
+	.ndo_set_mac_address	= set_mac_address,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= net_poll_controller,
+#endif
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static void __init reset_chip(struct net_device *dev)
+{
+#if !defined(CONFIG_MACH_MX31ADS)
+#if !defined(CS89x0_NONISA_IRQ)
 	struct net_local *lp = netdev_priv(dev);
-	struct sk_buff *skb;
-	int status, length;
+#endif /* CS89x0_NONISA_IRQ */
+	int reset_start_time;
 
-	status = ioread16(lp->virt_addr + RX_FRAME_PORT);
-	length = ioread16(lp->virt_addr + RX_FRAME_PORT);
+	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
 
-	if ((status & RX_OK) == 0) {
-		count_rx_errors(status, dev);
-		return;
+	/* wait 30 ms */
+	msleep(30);
+
+#if !defined(CS89x0_NONISA_IRQ)
+	if (lp->chip_type != CS8900) {
+		/* Hardware problem requires PNP registers to be reconfigured after a reset */
+		iowrite16(PP_CS8920_ISAINT, lp->virt_addr + ADD_PORT);
+		iowrite8(dev->irq, lp->virt_addr + DATA_PORT);
+		iowrite8(0, lp->virt_addr + DATA_PORT + 1);
+
+		iowrite16(PP_CS8920_ISAMemB, lp->virt_addr + ADD_PORT);
+		iowrite8((dev->mem_start >> 16) & 0xff,
+			 lp->virt_addr + DATA_PORT);
+		iowrite8((dev->mem_start >> 8) & 0xff,
+			 lp->virt_addr + DATA_PORT + 1);
 	}
+#endif /* CS89x0_NONISA_IRQ */
 
-	/* Malloc up new buffer. */
-	skb = netdev_alloc_skb(dev, length + 2);
-	if (skb == NULL) {
-#if 0		/* Again, this seems a cruel thing to do */
-		pr_warn("%s: Memory squeeze, dropping packet\n", dev->name);
+	/* Wait until the chip is reset */
+	reset_start_time = jiffies;
+	while ((readreg(dev, PP_SelfST) & INIT_DONE) == 0 &&
+	       jiffies - reset_start_time < 2)
+		;
+#endif /* !CONFIG_MACH_MX31ADS */
+}
+
+/* This is the real probe routine.
+ * Linux has a history of friendly device probes on the ISA bus.
+ * A good device probes avoids doing writes, and
+ * verifies that the correct device exists and functions.
+ * Return 0 on success.
+ */
+static int __init
+cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int i;
+	int tmp;
+	unsigned rev_type = 0;
+	int eeprom_buff[CHKSUM_LEN];
+	int retval;
+
+	/* Initialize the device structure. */
+	if (!modular) {
+		memset(lp, 0, sizeof(*lp));
+		spin_lock_init(&lp->lock);
+#ifndef MODULE
+#if ALLOW_DMA
+		if (g_cs89x0_dma) {
+			lp->use_dma = 1;
+			lp->dma = g_cs89x0_dma;
+			lp->dmasize = 16;	/* Could make this an option... */
+		}
 #endif
-		dev->stats.rx_dropped++;
-		return;
+		lp->force = g_cs89x0_media__force;
+#endif
+	}
+
+	pr_debug("PP_addr at %p[%x]: 0x%x\n",
+		 ioaddr, ADD_PORT, ioread16(ioaddr + ADD_PORT));
+	iowrite16(PP_ChipID, ioaddr + ADD_PORT);
+
+	tmp = ioread16(ioaddr + DATA_PORT);
+	if (tmp != CHIP_EISA_ID_SIG) {
+		pr_debug("%s: incorrect signature at %p[%x]: 0x%x!="
+			 CHIP_EISA_ID_SIG_STR "\n",
+			 dev->name, ioaddr, DATA_PORT, tmp);
+		retval = -ENODEV;
+		goto out1;
+	}
+
+	lp->virt_addr = ioaddr;
+
+	/* get the chip type */
+	rev_type = readreg(dev, PRODUCT_ID_ADD);
+	lp->chip_type = rev_type & ~REVISON_BITS;
+	lp->chip_revision = ((rev_type & REVISON_BITS) >> 8) + 'A';
+
+	/* Check the chip type and revision in order to set the correct
+	 * send command.  CS8920 revision C and CS8900 revision F can use
+	 * the faster send.
+	 */
+	lp->send_cmd = TX_AFTER_381;
+	if (lp->chip_type == CS8900 && lp->chip_revision >= 'F')
+		lp->send_cmd = TX_NOW;
+	if (lp->chip_type != CS8900 && lp->chip_revision >= 'C')
+		lp->send_cmd = TX_NOW;
+
+	pr_info_once("%s\n", version);
+
+	pr_info("%s: cs89%c0%s rev %c found at %p ",
+		dev->name,
+		lp->chip_type == CS8900  ? '0' : '2',
+		lp->chip_type == CS8920M ? "M" : "",
+		lp->chip_revision,
+		lp->virt_addr);
+
+	reset_chip(dev);
+
+	/* Here we read the current configuration of the chip.
+	 * If there is no Extended EEPROM then the idea is to not disturb
+	 * the chip configuration, it should have been correctly setup by
+	 * automatic EEPROM read on reset. So, if the chip says it read
+	 * the EEPROM the driver will always do *something* instead of
+	 * complain that adapter_cnf is 0.
+	 */
+
+	if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) ==
+	    (EEPROM_OK | EEPROM_PRESENT)) {
+		/* Load the MAC. */
+		for (i = 0; i < ETH_ALEN / 2; i++) {
+			unsigned int Addr;
+			Addr = readreg(dev, PP_IA + i * 2);
+			dev->dev_addr[i * 2] = Addr & 0xFF;
+			dev->dev_addr[i * 2 + 1] = Addr >> 8;
+		}
+
+		/* Load the Adapter Configuration.
+		 * Note:  Barring any more specific information from some
+		 * other source (ie EEPROM+Schematics), we would not know
+		 * how to operate a 10Base2 interface on the AUI port.
+		 * However, since we  do read the status of HCB1 and use
+		 * settings that always result in calls to control_dc_dc(dev,0)
+		 * a BNC interface should work if the enable pin
+		 * (dc/dc converter) is on HCB1.
+		 * It will be called AUI however.
+		 */
+
+		lp->adapter_cnf = 0;
+		i = readreg(dev, PP_LineCTL);
+		/* Preserve the setting of the HCB1 pin. */
+		if ((i & (HCB1 | HCB1_ENBL)) == (HCB1 | HCB1_ENBL))
+			lp->adapter_cnf |= A_CNF_DC_DC_POLARITY;
+		/* Save the sqelch bit */
+		if ((i & LOW_RX_SQUELCH) == LOW_RX_SQUELCH)
+			lp->adapter_cnf |= A_CNF_EXTND_10B_2 | A_CNF_LOW_RX_SQUELCH;
+		/* Check if the card is in 10Base-t only mode */
+		if ((i & (AUI_ONLY | AUTO_AUI_10BASET)) == 0)
+			lp->adapter_cnf |=  A_CNF_10B_T | A_CNF_MEDIA_10B_T;
+		/* Check if the card is in AUI only mode */
+		if ((i & (AUI_ONLY | AUTO_AUI_10BASET)) == AUI_ONLY)
+			lp->adapter_cnf |=  A_CNF_AUI | A_CNF_MEDIA_AUI;
+		/* Check if the card is in Auto mode. */
+		if ((i & (AUI_ONLY | AUTO_AUI_10BASET)) == AUTO_AUI_10BASET)
+			lp->adapter_cnf |=  A_CNF_AUI | A_CNF_10B_T |
+				A_CNF_MEDIA_AUI | A_CNF_MEDIA_10B_T | A_CNF_MEDIA_AUTO;
+
+		cs89_dbg(1, info, "%s: PP_LineCTL=0x%x, adapter_cnf=0x%x\n",
+			 dev->name, i, lp->adapter_cnf);
+
+		/* IRQ. Other chips already probe, see below. */
+		if (lp->chip_type == CS8900)
+			lp->isa_config = readreg(dev, PP_CS8900_ISAINT) & INT_NO_MASK;
+
+		pr_cont("[Cirrus EEPROM] ");
+	}
+
+	pr_cont("\n");
+
+	/* First check to see if an EEPROM is attached. */
+
+	if ((readreg(dev, PP_SelfST) & EEPROM_PRESENT) == 0)
+		pr_warn("No EEPROM, relying on command line....\n");
+	else if (get_eeprom_data(dev, START_EEPROM_DATA, CHKSUM_LEN, eeprom_buff) < 0) {
+		pr_warn("EEPROM read failed, relying on command line\n");
+	} else if (get_eeprom_cksum(START_EEPROM_DATA, CHKSUM_LEN, eeprom_buff) < 0) {
+		/* Check if the chip was able to read its own configuration starting
+		   at 0 in the EEPROM*/
+		if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) !=
+		    (EEPROM_OK | EEPROM_PRESENT))
+			pr_warn("Extended EEPROM checksum bad and no Cirrus EEPROM, relying on command line\n");
+
+	} else {
+		/* This reads an extended EEPROM that is not documented
+		 * in the CS8900 datasheet.
+		 */
+
+		/* get transmission control word  but keep the autonegotiation bits */
+		if (!lp->auto_neg_cnf)
+			lp->auto_neg_cnf = eeprom_buff[AUTO_NEG_CNF_OFFSET / 2];
+		/* Store adapter configuration */
+		if (!lp->adapter_cnf)
+			lp->adapter_cnf = eeprom_buff[ADAPTER_CNF_OFFSET / 2];
+		/* Store ISA configuration */
+		lp->isa_config = eeprom_buff[ISA_CNF_OFFSET / 2];
+		dev->mem_start = eeprom_buff[PACKET_PAGE_OFFSET / 2] << 8;
+
+		/* eeprom_buff has 32-bit ints, so we can't just memcpy it */
+		/* store the initial memory base address */
+		for (i = 0; i < ETH_ALEN / 2; i++) {
+			dev->dev_addr[i * 2] = eeprom_buff[i];
+			dev->dev_addr[i * 2 + 1] = eeprom_buff[i] >> 8;
+		}
+		cs89_dbg(1, debug, "%s: new adapter_cnf: 0x%x\n",
+			 dev->name, lp->adapter_cnf);
+	}
+
+	/* allow them to force multiple transceivers.  If they force multiple, autosense */
+	{
+		int count = 0;
+		if (lp->force & FORCE_RJ45) {
+			lp->adapter_cnf |= A_CNF_10B_T;
+			count++;
+		}
+		if (lp->force & FORCE_AUI) {
+			lp->adapter_cnf |= A_CNF_AUI;
+			count++;
+		}
+		if (lp->force & FORCE_BNC) {
+			lp->adapter_cnf |= A_CNF_10B_2;
+			count++;
+		}
+		if (count > 1)
+			lp->adapter_cnf |= A_CNF_MEDIA_AUTO;
+		else if (lp->force & FORCE_RJ45)
+			lp->adapter_cnf |= A_CNF_MEDIA_10B_T;
+		else if (lp->force & FORCE_AUI)
+			lp->adapter_cnf |= A_CNF_MEDIA_AUI;
+		else if (lp->force & FORCE_BNC)
+			lp->adapter_cnf |= A_CNF_MEDIA_10B_2;
 	}
-	skb_reserve(skb, 2);	/* longword align L3 header */
 
-	readwords(lp, RX_FRAME_PORT, skb_put(skb, length), length >> 1);
-	if (length & 1)
-		skb->data[length-1] = ioread16(lp->virt_addr + RX_FRAME_PORT);
+	cs89_dbg(1, debug, "%s: after force 0x%x, adapter_cnf=0x%x\n",
+		 dev->name, lp->force, lp->adapter_cnf);
 
-	cs89_dbg(3, debug, "%s: received %d byte packet of type %x\n",
-		 dev->name, length,
-		 (skb->data[ETH_ALEN + ETH_ALEN] << 8) |
-		 skb->data[ETH_ALEN + ETH_ALEN + 1]);
+	/* FIXME: We don't let you set dc-dc polarity or low RX squelch from the command line: add it here */
 
-	skb->protocol = eth_type_trans(skb, dev);
-	netif_rx(skb);
-	dev->stats.rx_packets++;
-	dev->stats.rx_bytes += length;
-}
+	/* FIXME: We don't let you set the IMM bit from the command line: add it to lp->auto_neg_cnf here */
 
-#if ALLOW_DMA
-static void release_dma_buff(struct net_local *lp)
-{
-	if (lp->dma_buff) {
-		free_pages((unsigned long)(lp->dma_buff),
-			   get_order(lp->dmasize * 1024));
-		lp->dma_buff = NULL;
-	}
-}
-#endif
+	/* FIXME: we don't set the Ethernet address on the command line.  Use
+	 * ifconfig IFACE hw ether AABBCCDDEEFF
+	 */
 
-/* The inverse routine to net_open(). */
-static int
-net_close(struct net_device *dev)
-{
-#if ALLOW_DMA
-	struct net_local *lp = netdev_priv(dev);
-#endif
+	pr_info("media %s%s%s",
+		(lp->adapter_cnf & A_CNF_10B_T) ? "RJ-45," : "",
+		(lp->adapter_cnf & A_CNF_AUI) ? "AUI," : "",
+		(lp->adapter_cnf & A_CNF_10B_2) ? "BNC," : "");
 
-	netif_stop_queue(dev);
+	lp->irq_map = 0xffff;
 
-	writereg(dev, PP_RxCFG, 0);
-	writereg(dev, PP_TxCFG, 0);
-	writereg(dev, PP_BufCFG, 0);
-	writereg(dev, PP_BusCTL, 0);
+	/* If this is a CS8900 then no pnp soft */
+	if (lp->chip_type != CS8900 &&
+	    /* Check if the ISA IRQ has been set  */
+	    (i = readreg(dev, PP_CS8920_ISAINT) & 0xff,
+	     (i != 0 && i < CS8920_NO_INTS))) {
+		if (!dev->irq)
+			dev->irq = i;
+	} else {
+		i = lp->isa_config & INT_NO_MASK;
+#ifndef CONFIG_CS89x0_PLATFORM
+		if (lp->chip_type == CS8900) {
+#ifdef CS89x0_NONISA_IRQ
+			i = cs8900_irq_map[0];
+#else
+			/* Translate the IRQ using the IRQ mapping table. */
+			if (i >= ARRAY_SIZE(cs8900_irq_map))
+				pr_err("invalid ISA interrupt number %d\n", i);
+			else
+				i = cs8900_irq_map[i];
 
-	free_irq(dev->irq, dev);
+			lp->irq_map = CS8900_IRQ_MAP; /* fixed IRQ map for CS8900 */
+		} else {
+			int irq_map_buff[IRQ_MAP_LEN/2];
 
-#if ALLOW_DMA
-	if (lp->use_dma && lp->dma) {
-		free_dma(dev->dma);
-		release_dma_buff(lp);
+			if (get_eeprom_data(dev, IRQ_MAP_EEPROM_DATA,
+					    IRQ_MAP_LEN / 2,
+					    irq_map_buff) >= 0) {
+				if ((irq_map_buff[0] & 0xff) == PNP_IRQ_FRMT)
+					lp->irq_map = ((irq_map_buff[0] >> 8) |
+						       (irq_map_buff[1] << 8));
+			}
+#endif
+		}
+#endif
+		if (!dev->irq)
+			dev->irq = i;
 	}
+
+	pr_cont(" IRQ %d", dev->irq);
+
+#if ALLOW_DMA
+	if (lp->use_dma) {
+		get_dma_channel(dev);
+		pr_cont(", DMA %d", dev->dma);
+	} else
 #endif
+		pr_cont(", programmed I/O");
 
-	/* Update the statistics here. */
+	/* print the ethernet address. */
+	pr_cont(", MAC %pM\n", dev->dev_addr);
+
+	dev->netdev_ops	= &net_ops;
+	dev->watchdog_timeo = HZ;
+
+	cs89_dbg(0, info, "cs89x0_probe1() successful\n");
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out2;
 	return 0;
+out2:
+	iowrite16(PP_ChipID, lp->virt_addr + ADD_PORT);
+out1:
+	return retval;
 }
 
-/* Get the current statistics.
- * This may be called with the card open or closed.
+#ifndef CONFIG_CS89x0_PLATFORM
+/*
+ * This function converts the I/O port addres used by the cs89x0_probe() and
+ * init_module() functions to the I/O memory address used by the
+ * cs89x0_probe1() function.
  */
-static struct net_device_stats *
-net_get_stats(struct net_device *dev)
+static int __init
+cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
 {
 	struct net_local *lp = netdev_priv(dev);
-	unsigned long flags;
-
-	spin_lock_irqsave(&lp->lock, flags);
-	/* Update the statistics from the device registers. */
-	dev->stats.rx_missed_errors += (readreg(dev, PP_RxMiss) >> 6);
-	dev->stats.collisions += (readreg(dev, PP_TxCol) >> 6);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	int ret;
+	void __iomem *io_mem;
 
-	return &dev->stats;
-}
+	if (!lp)
+		return -ENOMEM;
 
-static void set_multicast_list(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-	unsigned long flags;
+	dev->base_addr = ioport;
 
-	spin_lock_irqsave(&lp->lock, flags);
-	if (dev->flags & IFF_PROMISC)
-		lp->rx_mode = RX_ALL_ACCEPT;
-	else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev))
-		/* The multicast-accept list is initialized to accept-all,
-		 * and we rely on higher-level filtering for now.
-		 */
-		lp->rx_mode = RX_MULTCAST_ACCEPT;
-	else
-		lp->rx_mode = 0;
+	if (!request_region(ioport, NETCARD_IO_EXTENT, DRV_NAME)) {
+		ret = -EBUSY;
+		goto out;
+	}
 
-	writereg(dev, PP_RxCTL, DEF_RX_ACCEPT | lp->rx_mode);
+	io_mem = ioport_map(ioport & ~3, NETCARD_IO_EXTENT);
+	if (!io_mem) {
+		ret = -ENOMEM;
+		goto release;
+	}
 
-	/* in promiscuous mode, we accept errored packets,
-	 * so we have to enable interrupts on them also
+	/* if they give us an odd I/O address, then do ONE write to
+	 * the address port, to get it back to address zero, where we
+	 * expect to find the EISA signature word. An IO with a base of 0x3
+	 * will skip the test for the ADD_PORT.
 	 */
-	writereg(dev, PP_RxCFG,
-		 (lp->curr_rx_cfg |
-		  (lp->rx_mode == RX_ALL_ACCEPT)
-		  ? (RX_CRC_ERROR_ENBL | RX_RUNT_ENBL | RX_EXTRA_DATA_ENBL)
-		  : 0));
-	spin_unlock_irqrestore(&lp->lock, flags);
+	if (ioport & 1) {
+		cs89_dbg(1, info, "%s: odd ioaddr 0x%lx\n", dev->name, ioport);
+		if ((ioport & 2) != 2) {
+			if ((ioread16(io_mem + ADD_PORT) & ADD_MASK) !=
+			    ADD_SIG) {
+				pr_err("%s: bad signature 0x%x\n",
+				       dev->name, ioread16(io_mem + ADD_PORT));
+				ret = -ENODEV;
+				goto unmap;
+			}
+		}
+	}
+
+	ret = cs89x0_probe1(dev, io_mem, modular);
+	if (!ret)
+		goto out;
+unmap:
+	ioport_unmap(io_mem);
+release:
+	release_region(ioport, NETCARD_IO_EXTENT);
+out:
+	return ret;
 }
 
-static int set_mac_address(struct net_device *dev, void *p)
-{
-	int i;
-	struct sockaddr *addr = p;
+#ifndef MODULE
+/* Check for a network adaptor of this type, and return '0' iff one exists.
+ * If dev->base_addr == 0, probe all likely locations.
+ * If dev->base_addr == 1, always return failure.
+ * If dev->base_addr == 2, allocate space for the device and return success
+ * (detachable devices only).
+ * Return 0 on success.
+ */
 
-	if (netif_running(dev))
-		return -EBUSY;
+struct net_device * __init cs89x0_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	unsigned *port;
+	int err = 0;
+	int irq;
+	int io;
 
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	if (!dev)
+		return ERR_PTR(-ENODEV);
 
-	cs89_dbg(0, debug, "%s: Setting MAC address to %pM\n",
-		 dev->name, dev->dev_addr);
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+	io = dev->base_addr;
+	irq = dev->irq;
 
-	/* set the Ethernet address */
-	for (i = 0; i < ETH_ALEN / 2; i++)
-		writereg(dev, PP_IA + i * 2,
-			 (dev->dev_addr[i * 2] |
-			  (dev->dev_addr[i * 2 + 1] << 8)));
+	cs89_dbg(0, info, "cs89x0_probe(0x%x)\n", io);
 
-	return 0;
+	if (io > 0x1ff)	{	/* Check a single specified location. */
+		err = cs89x0_ioport_probe(dev, io, 0);
+	} else if (io != 0) {	/* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (port = netcard_portlist; *port; port++) {
+			if (cs89x0_ioport_probe(dev, *port, 0) == 0)
+				break;
+			dev->irq = irq;
+		}
+		if (!*port)
+			err = -ENODEV;
+	}
+	if (err)
+		goto out;
+	return dev;
+out:
+	free_netdev(dev);
+	pr_warn("no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP\n");
+	return ERR_PTR(err);
 }
+#endif
+#endif
 
 #if defined(MODULE) && !defined(CONFIG_CS89x0_PLATFORM)
 
-- 
1.7.8.111.gad25c.dirty
