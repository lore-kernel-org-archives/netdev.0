From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/4] tulip: Convert uses of KERN_DEBUG
Date: Mon,  9 May 2011 12:45:22 -0700
Message-ID: <7686b8ddd70df6d46eac56b40bedc4b4d267af3f.1304970062.git.joe@perches.com>
References: <cover.1304970062.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1304970062.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert logging messages to more current styles.

Added -DDEBUG to Makefile to maintain current message logging.
This could be converted to a specific CONFIG_TULIP_DEBUG option.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/21142.c       |   14 ++++----
 drivers/net/tulip/Makefile      |    2 +
 drivers/net/tulip/de2104x.c     |   47 +++++++++++--------------
 drivers/net/tulip/interrupt.c   |   48 +++++++++++++-------------
 drivers/net/tulip/media.c       |   49 +++++++++++++-------------
 drivers/net/tulip/pnic.c        |   22 ++++++------
 drivers/net/tulip/pnic2.c       |   16 ++++----
 drivers/net/tulip/timer.c       |   47 ++++++++++++-------------
 drivers/net/tulip/tulip.h       |    8 ++---
 drivers/net/tulip/tulip_core.c  |   20 +++++------
 drivers/net/tulip/winbond-840.c |   73 ++++++++++++++++++---------------------
 drivers/net/tulip/xircom_cb.c   |    2 +-
 12 files changed, 166 insertions(+), 182 deletions(-)

diff --git a/drivers/net/tulip/21142.c b/drivers/net/tulip/21142.c
index 007d8e7..092c3fa 100644
--- a/drivers/net/tulip/21142.c
+++ b/drivers/net/tulip/21142.c
@@ -122,8 +122,8 @@ void t21142_start_nway(struct net_device *dev)
 	tp->nway = tp->mediasense = 1;
 	tp->nwayset = tp->lpar = 0;
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: Restarting 21143 autonegotiation, csr14=%08x\n",
-		       dev->name, csr14);
+		netdev_dbg(dev, "Restarting 21143 autonegotiation, csr14=%08x\n",
+			   csr14);
 	iowrite32(0x0001, ioaddr + CSR13);
 	udelay(100);
 	iowrite32(csr14, ioaddr + CSR14);
@@ -206,14 +206,14 @@ void t21142_lnk_change(struct net_device *dev, int csr5)
 #if 0							/* Restart shouldn't be needed. */
 		iowrite32(tp->csr6 | RxOn, ioaddr + CSR6);
 		if (tulip_debug > 2)
-			printk(KERN_DEBUG "%s:  Restarting Tx and Rx, CSR5 is %08x\n",
-			       dev->name, ioread32(ioaddr + CSR5));
+			netdev_dbg(dev, " Restarting Tx and Rx, CSR5 is %08x\n",
+				   ioread32(ioaddr + CSR5));
 #endif
 		tulip_start_rxtx(tp);
 		if (tulip_debug > 2)
-			printk(KERN_DEBUG "%s:  Setting CSR6 %08x/%x CSR12 %08x\n",
-			       dev->name, tp->csr6, ioread32(ioaddr + CSR6),
-			       ioread32(ioaddr + CSR12));
+			netdev_dbg(dev, " Setting CSR6 %08x/%x CSR12 %08x\n",
+				   tp->csr6, ioread32(ioaddr + CSR6),
+				   ioread32(ioaddr + CSR12));
 	} else if ((tp->nwayset  &&  (csr5 & 0x08000000) &&
 		    (dev->if_port == 3  ||  dev->if_port == 5) &&
 		    (csr12 & 2) == 2) ||
diff --git a/drivers/net/tulip/Makefile b/drivers/net/tulip/Makefile
index 200cbf7..5e8be38 100644
--- a/drivers/net/tulip/Makefile
+++ b/drivers/net/tulip/Makefile
@@ -2,6 +2,8 @@
 # Makefile for the Linux "Tulip" family network device drivers.
 #
 
+ccflags-$(CONFIG_NET_TULIP)	:= -DDEBUG
+
 obj-$(CONFIG_PCMCIA_XIRCOM)	+= xircom_cb.o
 obj-$(CONFIG_DM9102)		+= dmfe.o
 obj-$(CONFIG_WINBOND_840)	+= winbond-840.o
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 62883a0..e925c1e 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -377,9 +377,9 @@ static u16 t21041_csr15[] = { 0x0008, 0x0006, 0x000E, 0x0008, 0x0008, };
 static void de_rx_err_acct (struct de_private *de, unsigned rx_tail,
 			    u32 status, u32 len)
 {
-	netif_printk(de, rx_err, KERN_DEBUG, de->dev,
-		     "rx err, slot %d status 0x%x len %d\n",
-		     rx_tail, status, len);
+	netif_dbg(de, rx_err, de->dev,
+		  "rx err, slot %d status 0x%x len %d\n",
+		  rx_tail, status, len);
 
 	if ((status & 0x38000300) != 0x0300) {
 		/* Ingore earlier buffers. */
@@ -433,10 +433,9 @@ static void de_rx (struct de_private *de)
 
 		copying_skb = (len <= rx_copybreak);
 
-		if (unlikely(netif_msg_rx_status(de)))
-			printk(KERN_DEBUG "%s: rx slot %d status 0x%x len %d copying? %d\n",
-			       de->dev->name, rx_tail, status, len,
-			       copying_skb);
+		netif_dbg(de, rx_status, de->dev,
+			  "rx slot %d status 0x%x len %d copying? %d\n",
+			  rx_tail, status, len, copying_skb);
 
 		buflen = copying_skb ? (len + RX_OFFSET) : de->rx_buf_sz;
 		copy_skb = dev_alloc_skb (buflen);
@@ -504,10 +503,9 @@ static irqreturn_t de_interrupt (int irq, void *dev_instance)
 	if ((!(status & (IntrOK|IntrErr))) || (status == 0xFFFF))
 		return IRQ_NONE;
 
-	if (netif_msg_intr(de))
-		printk(KERN_DEBUG "%s: intr, status %08x mode %08x desc %u/%u/%u\n",
-		       dev->name, status, dr32(MacMode),
-		       de->rx_tail, de->tx_head, de->tx_tail);
+	netif_dbg(de, intr, dev, "intr, status %08x mode %08x desc %u/%u/%u\n",
+		  status, dr32(MacMode),
+		  de->rx_tail, de->tx_head, de->tx_tail);
 
 	dw32(MacStatus, status);
 
@@ -570,9 +568,9 @@ static void de_tx (struct de_private *de)
 
 		if (status & LastFrag) {
 			if (status & TxError) {
-				if (netif_msg_tx_err(de))
-					printk(KERN_DEBUG "%s: tx err, status 0x%x\n",
-					       de->dev->name, status);
+				netif_dbg(de, tx_err, de->dev,
+					  "tx err, status 0x%x\n",
+					  status);
 				de->net_stats.tx_errors++;
 				if (status & TxOWC)
 					de->net_stats.tx_window_errors++;
@@ -585,9 +583,8 @@ static void de_tx (struct de_private *de)
 			} else {
 				de->net_stats.tx_packets++;
 				de->net_stats.tx_bytes += skb->len;
-				if (netif_msg_tx_done(de))
-					printk(KERN_DEBUG "%s: tx done, slot %d\n",
-					       de->dev->name, tx_tail);
+				netif_dbg(de, tx_done, de->dev,
+					  "tx done, slot %d\n", tx_tail);
 			}
 			dev_kfree_skb_irq(skb);
 		}
@@ -644,9 +641,8 @@ static netdev_tx_t de_start_xmit (struct sk_buff *skb,
 	wmb();
 
 	de->tx_head = NEXT_TX(entry);
-	if (netif_msg_tx_queued(de))
-		printk(KERN_DEBUG "%s: tx queued, slot %d, skblen %d\n",
-		       dev->name, entry, skb->len);
+	netif_dbg(de, tx_queued, dev, "tx queued, slot %d, skblen %d\n",
+		  entry, skb->len);
 
 	if (tx_free == 0)
 		netif_stop_queue(dev);
@@ -1387,7 +1383,7 @@ static int de_open (struct net_device *dev)
 	struct de_private *de = netdev_priv(dev);
 	int rc;
 
-	netif_printk(de, ifup, KERN_DEBUG, dev, "enabling interface\n");
+	netif_dbg(de, ifup, dev, "enabling interface\n");
 
 	de->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
 
@@ -1429,7 +1425,7 @@ static int de_close (struct net_device *dev)
 	struct de_private *de = netdev_priv(dev);
 	unsigned long flags;
 
-	netif_printk(de, ifdown, KERN_DEBUG, dev, "disabling interface\n");
+	netif_dbg(de, ifdown, dev, "disabling interface\n");
 
 	del_timer_sync(&de->media_timer);
 
@@ -1450,10 +1446,9 @@ static void de_tx_timeout (struct net_device *dev)
 {
 	struct de_private *de = netdev_priv(dev);
 
-	netdev_printk(KERN_DEBUG, dev,
-		      "NIC status %08x mode %08x sia %08x desc %u/%u/%u\n",
-		      dr32(MacStatus), dr32(MacMode), dr32(SIAStatus),
-		      de->rx_tail, de->tx_head, de->tx_tail);
+	netdev_dbg(dev, "NIC status %08x mode %08x sia %08x desc %u/%u/%u\n",
+		   dr32(MacStatus), dr32(MacMode), dr32(SIAStatus),
+		   de->rx_tail, de->tx_head, de->tx_tail);
 
 	del_timer_sync(&de->media_timer);
 
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 0013642..5350d75 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -125,12 +125,12 @@ int tulip_poll(struct napi_struct *napi, int budget)
 #endif
 
 	if (tulip_debug > 4)
-		printk(KERN_DEBUG " In tulip_rx(), entry %d %08x\n",
-		       entry, tp->rx_ring[entry].status);
+		netdev_dbg(dev, " In tulip_rx(), entry %d %08x\n",
+			   entry, tp->rx_ring[entry].status);
 
        do {
 		if (ioread32(tp->base_addr + CSR5) == 0xffffffff) {
-			printk(KERN_DEBUG " In tulip_poll(), hardware disappeared\n");
+			netdev_dbg(dev, " In tulip_poll(), hardware disappeared\n");
 			break;
 		}
                /* Acknowledge current RX interrupt sources. */
@@ -145,9 +145,9 @@ int tulip_poll(struct napi_struct *napi, int budget)
                        if (tp->dirty_rx + RX_RING_SIZE == tp->cur_rx)
                                break;
 
-                       if (tulip_debug > 5)
-                               printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %08x\n",
-                                      dev->name, entry, status);
+		       if (tulip_debug > 5)
+				netdev_dbg(dev, "In tulip_rx(), entry %d %08x\n",
+					   entry, status);
 
 		       if (++work_done >= budget)
                                goto not_done;
@@ -184,9 +184,9 @@ int tulip_poll(struct napi_struct *napi, int budget)
 					}
 			       } else {
                                 /* There was a fatal error. */
-                                       if (tulip_debug > 2)
-                                               printk(KERN_DEBUG "%s: Receive error, Rx status %08x\n",
-                                                      dev->name, status);
+				       if (tulip_debug > 2)
+						netdev_dbg(dev, "Receive error, Rx status %08x\n",
+							   status);
 					dev->stats.rx_errors++; /* end of a packet.*/
 					if (pkt_len > 1518 ||
 					    (status & RxDescRunt))
@@ -367,16 +367,16 @@ static int tulip_rx(struct net_device *dev)
 	int received = 0;
 
 	if (tulip_debug > 4)
-		printk(KERN_DEBUG " In tulip_rx(), entry %d %08x\n",
-		       entry, tp->rx_ring[entry].status);
+		netdev_dbg(dev, "In tulip_rx(), entry %d %08x\n",
+			   entry, tp->rx_ring[entry].status);
 	/* If we own the next entry, it is a new packet. Send it up. */
 	while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
 		s32 status = le32_to_cpu(tp->rx_ring[entry].status);
 		short pkt_len;
 
 		if (tulip_debug > 5)
-			printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %08x\n",
-			       dev->name, entry, status);
+			netdev_dbg(dev, "In tulip_rx(), entry %d %08x\n",
+				   entry, status);
 		if (--rx_work_limit < 0)
 			break;
 
@@ -404,16 +404,16 @@ static int tulip_rx(struct net_device *dev)
 				/* Ingore earlier buffers. */
 				if ((status & 0xffff) != 0x7fff) {
 					if (tulip_debug > 1)
-						dev_warn(&dev->dev,
-							 "Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
-							 status);
+						netdev_warn(dev,
+							    "Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
+							    status);
 					dev->stats.rx_length_errors++;
 				}
 			} else {
 				/* There was a fatal error. */
 				if (tulip_debug > 2)
-					printk(KERN_DEBUG "%s: Receive error, Rx status %08x\n",
-					       dev->name, status);
+					netdev_dbg(dev, "Receive error, Rx status %08x\n",
+						   status);
 				dev->stats.rx_errors++; /* end of a packet.*/
 				if (pkt_len > 1518 ||
 				    (status & RxDescRunt))
@@ -573,8 +573,8 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 #endif /*  CONFIG_TULIP_NAPI */
 
 		if (tulip_debug > 4)
-			printk(KERN_DEBUG "%s: interrupt  csr5=%#8.8x new csr5=%#8.8x\n",
-			       dev->name, csr5, ioread32(ioaddr + CSR5));
+			netdev_dbg(dev, "interrupt  csr5=%#8.8x new csr5=%#8.8x\n",
+				   csr5, ioread32(ioaddr + CSR5));
 
 
 		if (csr5 & (TxNoBuf | TxDied | TxIntr | TimerInt)) {
@@ -605,8 +605,8 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 					/* There was an major error, log it. */
 #ifndef final_version
 					if (tulip_debug > 1)
-						printk(KERN_DEBUG "%s: Transmit error, Tx status %08x\n",
-						       dev->name, status);
+						netdev_dbg(dev, "Transmit error, Tx status %08x\n",
+							   status);
 #endif
 					dev->stats.tx_errors++;
 					if (status & 0x4104)
@@ -804,8 +804,8 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 	}
 
 	if (tulip_debug > 4)
-		printk(KERN_DEBUG "%s: exiting interrupt, csr5=%#04x\n",
-		       dev->name, ioread32(ioaddr + CSR5));
+		netdev_dbg(dev, "exiting interrupt, csr5=%#04x\n",
+			   ioread32(ioaddr + CSR5));
 
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
index a0c770e..4bd1392 100644
--- a/drivers/net/tulip/media.c
+++ b/drivers/net/tulip/media.c
@@ -182,8 +182,8 @@ void tulip_select_media(struct net_device *dev, int startup)
 		switch (mleaf->type) {
 		case 0:					/* 21140 non-MII xcvr. */
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s: Using a 21140 non-MII transceiver with control setting %02x\n",
-				       dev->name, p[1]);
+				netdev_dbg(dev, "Using a 21140 non-MII transceiver with control setting %02x\n",
+					   p[1]);
 			dev->if_port = p[0];
 			if (startup)
 				iowrite32(mtable->csr12dir | 0x100, ioaddr + CSR12);
@@ -204,15 +204,14 @@ void tulip_select_media(struct net_device *dev, int startup)
 				struct medialeaf *rleaf = &mtable->mleaf[mtable->has_reset];
 				unsigned char *rst = rleaf->leafdata;
 				if (tulip_debug > 1)
-					printk(KERN_DEBUG "%s: Resetting the transceiver\n",
-					       dev->name);
+					netdev_dbg(dev, "Resetting the transceiver\n");
 				for (i = 0; i < rst[0]; i++)
 					iowrite32(get_u16(rst + 1 + (i<<1)) << 16, ioaddr + CSR15);
 			}
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s: 21143 non-MII %s transceiver control %04x/%04x\n",
-				       dev->name, medianame[dev->if_port],
-				       setup[0], setup[1]);
+				netdev_dbg(dev, "21143 non-MII %s transceiver control %04x/%04x\n",
+					   medianame[dev->if_port],
+					   setup[0], setup[1]);
 			if (p[0] & 0x40) {	/* SIA (CSR13-15) setup values are provided. */
 				csr13val = setup[0];
 				csr14val = setup[1];
@@ -239,8 +238,8 @@ void tulip_select_media(struct net_device *dev, int startup)
 				if (startup) iowrite32(csr13val, ioaddr + CSR13);
 			}
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s:  Setting CSR15 to %08x/%08x\n",
-				       dev->name, csr15dir, csr15val);
+				netdev_dbg(dev, "Setting CSR15 to %08x/%08x\n",
+					   csr15dir, csr15val);
 			if (mleaf->type == 4)
 				new_csr6 = 0x82020000 | ((setup[2] & 0x71) << 18);
 			else
@@ -316,9 +315,9 @@ void tulip_select_media(struct net_device *dev, int startup)
 				if (tp->mii_advertise == 0)
 					tp->mii_advertise = tp->advertising[phy_num];
 				if (tulip_debug > 1)
-					printk(KERN_DEBUG "%s:  Advertising %04x on MII %d\n",
-					       dev->name, tp->mii_advertise,
-					       tp->phys[phy_num]);
+					netdev_dbg(dev, " Advertising %04x on MII %d\n",
+						   tp->mii_advertise,
+						   tp->phys[phy_num]);
 				tulip_mdio_write(dev, tp->phys[phy_num], 4, tp->mii_advertise);
 			}
 			break;
@@ -335,8 +334,7 @@ void tulip_select_media(struct net_device *dev, int startup)
 				struct medialeaf *rleaf = &mtable->mleaf[mtable->has_reset];
 				unsigned char *rst = rleaf->leafdata;
 				if (tulip_debug > 1)
-					printk(KERN_DEBUG "%s: Resetting the transceiver\n",
-					       dev->name);
+					netdev_dbg(dev, "Resetting the transceiver\n");
 				for (i = 0; i < rst[0]; i++)
 					iowrite32(get_u16(rst + 1 + (i<<1)) << 16, ioaddr + CSR15);
 			}
@@ -344,20 +342,21 @@ void tulip_select_media(struct net_device *dev, int startup)
 			break;
 		}
 		default:
-			printk(KERN_DEBUG "%s:  Invalid media table selection %d\n",
-			       dev->name, mleaf->type);
+			netdev_dbg(dev, " Invalid media table selection %d\n",
+				   mleaf->type);
 			new_csr6 = 0x020E0000;
 		}
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: Using media type %s, CSR12 is %02x\n",
-			       dev->name, medianame[dev->if_port],
+			netdev_dbg(dev, "Using media type %s, CSR12 is %02x\n",
+				   medianame[dev->if_port],
 				   ioread32(ioaddr + CSR12) & 0xff);
 	} else if (tp->chip_id == LC82C168) {
 		if (startup && ! tp->medialock)
 			dev->if_port = tp->mii_cnt ? 11 : 0;
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: PNIC PHY status is %3.3x, media %s\n",
-			       dev->name, ioread32(ioaddr + 0xB8), medianame[dev->if_port]);
+			netdev_dbg(dev, "PNIC PHY status is %3.3x, media %s\n",
+				   ioread32(ioaddr + 0xB8),
+				   medianame[dev->if_port]);
 		if (tp->mii_cnt) {
 			new_csr6 = 0x810C0000;
 			iowrite32(0x0001, ioaddr + CSR15);
@@ -388,9 +387,9 @@ void tulip_select_media(struct net_device *dev, int startup)
 		} else
 			new_csr6 = 0x03860000;
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: No media description table, assuming %s transceiver, CSR12 %02x\n",
-			       dev->name, medianame[dev->if_port],
-			       ioread32(ioaddr + CSR12));
+			netdev_dbg(dev, "No media description table, assuming %s transceiver, CSR12 %02x\n",
+				   medianame[dev->if_port],
+				   ioread32(ioaddr + CSR12));
 	}
 
 	tp->csr6 = new_csr6 | (tp->csr6 & 0xfdff) | (tp->full_duplex ? 0x0200 : 0);
@@ -504,8 +503,8 @@ void __devinit tulip_find_mii (struct net_device *dev, int board_idx)
 
 		/* Fixup for DLink with miswired PHY. */
 		if (mii_advert != to_advert) {
-			printk(KERN_DEBUG "tulip%d:  Advertising %04x on PHY %d, previously advertising %04x\n",
-			       board_idx, to_advert, phy, mii_advert);
+			pr_debug("tulip%d:  Advertising %04x on PHY %d, previously advertising %04x\n",
+				 board_idx, to_advert, phy, mii_advert);
 			tulip_mdio_write (dev, phy, 4, to_advert);
 		}
 
diff --git a/drivers/net/tulip/pnic.c b/drivers/net/tulip/pnic.c
index a63e64b..aa4d9da 100644
--- a/drivers/net/tulip/pnic.c
+++ b/drivers/net/tulip/pnic.c
@@ -40,8 +40,8 @@ void pnic_do_nway(struct net_device *dev)
 			new_csr6 |= 0x00000200;
 		}
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: PNIC autonegotiated status %08x, %s\n",
-			       dev->name, phy_reg, medianame[dev->if_port]);
+			netdev_dbg(dev, "PNIC autonegotiated status %08x, %s\n",
+				   phy_reg, medianame[dev->if_port]);
 		if (tp->csr6 != new_csr6) {
 			tp->csr6 = new_csr6;
 			/* Restart Tx */
@@ -58,8 +58,8 @@ void pnic_lnk_change(struct net_device *dev, int csr5)
 	int phy_reg = ioread32(ioaddr + 0xB8);
 
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: PNIC link changed state %08x, CSR5 %08x\n",
-		       dev->name, phy_reg, csr5);
+		netdev_dbg(dev, "PNIC link changed state %08x, CSR5 %08x\n",
+			   phy_reg, csr5);
 	if (ioread32(ioaddr + CSR5) & TPLnkFail) {
 		iowrite32((ioread32(ioaddr + CSR7) & ~TPLnkFail) | TPLnkPass, ioaddr + CSR7);
 		/* If we use an external MII, then we mustn't use the
@@ -114,8 +114,8 @@ void pnic_timer(unsigned long data)
 		int csr5 = ioread32(ioaddr + CSR5);
 
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: PNIC timer PHY status %08x, %s CSR5 %08x\n",
-			       dev->name, phy_reg, medianame[dev->if_port], csr5);
+			netdev_dbg(dev, "PNIC timer PHY status %08x, %s CSR5 %08x\n",
+				   phy_reg, medianame[dev->if_port], csr5);
 		if (phy_reg & 0x04000000) {	/* Remote link fault */
 			iowrite32(0x0201F078, ioaddr + 0xB8);
 			next_tick = 1*HZ;
@@ -125,11 +125,11 @@ void pnic_timer(unsigned long data)
 			next_tick = 60*HZ;
 		} else if (csr5 & TPLnkFail) { /* 100baseTx link beat */
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s: %s link beat failed, CSR12 %04x, CSR5 %08x, PHY %03x\n",
-				       dev->name, medianame[dev->if_port],
-				       csr12,
-				       ioread32(ioaddr + CSR5),
-				       ioread32(ioaddr + 0xB8));
+				netdev_dbg(dev, "%s link beat failed, CSR12 %04x, CSR5 %08x, PHY %03x\n",
+					   medianame[dev->if_port],
+					   csr12,
+					   ioread32(ioaddr + CSR5),
+					   ioread32(ioaddr + 0xB8));
 			next_tick = 3*HZ;
 			if (tp->medialock) {
 			} else if (tp->nwayset  &&  (dev->if_port & 1)) {
diff --git a/drivers/net/tulip/pnic2.c b/drivers/net/tulip/pnic2.c
index 4690c8e..93358ee 100644
--- a/drivers/net/tulip/pnic2.c
+++ b/drivers/net/tulip/pnic2.c
@@ -125,8 +125,8 @@ void pnic2_start_nway(struct net_device *dev)
         csr14 |= 0x00001184;
 
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: Restarting PNIC2 autonegotiation, csr14=%08x\n",
-		       dev->name, csr14);
+		netdev_dbg(dev, "Restarting PNIC2 autonegotiation, csr14=%08x\n",
+			   csr14);
 
         /* tell pnic2_lnk_change we are doing an nway negotiation */
 	dev->if_port = 0;
@@ -137,8 +137,7 @@ void pnic2_start_nway(struct net_device *dev)
 
 	tp->csr6 = ioread32(ioaddr + CSR6);
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: On Entry to Nway, csr6=%08x\n",
-		       dev->name, tp->csr6);
+		netdev_dbg(dev, "On Entry to Nway, csr6=%08x\n", tp->csr6);
 
         /* mask off any bits not to touch
          * comment at top of file explains mask value
@@ -271,9 +270,10 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 			iowrite32(1, ioaddr + CSR13);
 
 			if (tulip_debug > 2)
-			        printk(KERN_DEBUG "%s: Setting CSR6 %08x/%x CSR12 %08x\n",
-				       dev->name, tp->csr6,
-				       ioread32(ioaddr + CSR6), ioread32(ioaddr + CSR12));
+				netdev_dbg(dev, "Setting CSR6 %08x/%x CSR12 %08x\n",
+					   tp->csr6,
+					   ioread32(ioaddr + CSR6),
+					   ioread32(ioaddr + CSR12));
 
 			/* now the following actually writes out the
 			 * new csr6 values
@@ -324,7 +324,7 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 		/* Link blew? Maybe restart NWay. */
 
 		if (tulip_debug > 2)
-			printk(KERN_DEBUG "%s: Ugh! Link blew?\n", dev->name);
+			netdev_dbg(dev, "Ugh! Link blew?\n");
 
 		del_timer_sync(&tp->timer);
 		pnic2_start_nway(dev);
diff --git a/drivers/net/tulip/timer.c b/drivers/net/tulip/timer.c
index 36c2725..2017faf 100644
--- a/drivers/net/tulip/timer.c
+++ b/drivers/net/tulip/timer.c
@@ -28,11 +28,11 @@ void tulip_media_task(struct work_struct *work)
 	unsigned long flags;
 
 	if (tulip_debug > 2) {
-		printk(KERN_DEBUG "%s: Media selection tick, %s, status %08x mode %08x SIA %08x %08x %08x %08x\n",
-		       dev->name, medianame[dev->if_port],
-		       ioread32(ioaddr + CSR5), ioread32(ioaddr + CSR6),
-		       csr12, ioread32(ioaddr + CSR13),
-		       ioread32(ioaddr + CSR14), ioread32(ioaddr + CSR15));
+		netdev_dbg(dev, "Media selection tick, %s, status %08x mode %08x SIA %08x %08x %08x %08x\n",
+			   medianame[dev->if_port],
+			   ioread32(ioaddr + CSR5), ioread32(ioaddr + CSR6),
+			   csr12, ioread32(ioaddr + CSR13),
+			   ioread32(ioaddr + CSR14), ioread32(ioaddr + CSR15));
 	}
 	switch (tp->chip_id) {
 	case DC21140:
@@ -48,9 +48,9 @@ void tulip_media_task(struct work_struct *work)
 			   Assume this a generic MII or SYM transceiver. */
 			next_tick = 60*HZ;
 			if (tulip_debug > 2)
-				printk(KERN_DEBUG "%s: network media monitor CSR6 %08x CSR12 0x%02x\n",
-				       dev->name,
-				       ioread32(ioaddr + CSR6), csr12 & 0xff);
+				netdev_dbg(dev, "network media monitor CSR6 %08x CSR12 0x%02x\n",
+					   ioread32(ioaddr + CSR6),
+					   csr12 & 0xff);
 			break;
 		}
 		mleaf = &tp->mtable->mleaf[tp->cur_index];
@@ -62,8 +62,8 @@ void tulip_media_task(struct work_struct *work)
 			s8 bitnum = p[offset];
 			if (p[offset+1] & 0x80) {
 				if (tulip_debug > 1)
-					printk(KERN_DEBUG "%s: Transceiver monitor tick CSR12=%#02x, no media sense\n",
-					       dev->name, csr12);
+					netdev_dbg(dev, "Transceiver monitor tick CSR12=%#02x, no media sense\n",
+						   csr12);
 				if (mleaf->type == 4) {
 					if (mleaf->media == 3 && (csr12 & 0x02))
 						goto select_next_media;
@@ -71,17 +71,16 @@ void tulip_media_task(struct work_struct *work)
 				break;
 			}
 			if (tulip_debug > 2)
-				printk(KERN_DEBUG "%s: Transceiver monitor tick: CSR12=%#02x bit %d is %d, expecting %d\n",
-				       dev->name, csr12, (bitnum >> 1) & 7,
-				       (csr12 & (1 << ((bitnum >> 1) & 7))) != 0,
-				       (bitnum >= 0));
+				netdev_dbg(dev, "Transceiver monitor tick: CSR12=%#02x bit %d is %d, expecting %d\n",
+					   csr12, (bitnum >> 1) & 7,
+					   (csr12 & (1 << ((bitnum >> 1) & 7))) != 0,
+					   (bitnum >= 0));
 			/* Check that the specified bit has the proper value. */
 			if ((bitnum < 0) !=
 				((csr12 & (1 << ((bitnum >> 1) & 7))) != 0)) {
 				if (tulip_debug > 2)
-					printk(KERN_DEBUG "%s: Link beat detected for %s\n",
-					       dev->name,
-					       medianame[mleaf->media & MEDIA_MASK]);
+					netdev_dbg(dev, "Link beat detected for %s\n",
+						   medianame[mleaf->media & MEDIA_MASK]);
 				if ((p[2] & 0x61) == 0x01)	/* Bogus Znyx board. */
 					goto actually_mii;
 				netif_carrier_on(dev);
@@ -99,10 +98,9 @@ void tulip_media_task(struct work_struct *work)
 			if (tulip_media_cap[dev->if_port] & MediaIsFD)
 				goto select_next_media; /* Skip FD entries. */
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s: No link beat on media %s, trying transceiver type %s\n",
-				       dev->name,
-				       medianame[mleaf->media & MEDIA_MASK],
-				       medianame[tp->mtable->mleaf[tp->cur_index].media]);
+				netdev_dbg(dev, "No link beat on media %s, trying transceiver type %s\n",
+					   medianame[mleaf->media & MEDIA_MASK],
+					   medianame[tp->mtable->mleaf[tp->cur_index].media]);
 			tulip_select_media(dev, 0);
 			/* Restart the transmit process. */
 			tulip_restart_rxtx(tp);
@@ -166,10 +164,9 @@ void comet_timer(unsigned long data)
 	int next_tick = 60*HZ;
 
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: Comet link status %04x partner capability %04x\n",
-		       dev->name,
-		       tulip_mdio_read(dev, tp->phys[0], 1),
-		       tulip_mdio_read(dev, tp->phys[0], 5));
+		netdev_dbg(dev, "Comet link status %04x partner capability %04x\n",
+			   tulip_mdio_read(dev, tp->phys[0], 1),
+			   tulip_mdio_read(dev, tp->phys[0], 5));
 	/* mod_timer synchronizes us with potential add_timer calls
 	 * from interrupts.
 	 */
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index ed66a16..9db5289 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -547,11 +547,9 @@ static inline void tulip_stop_rxtx(struct tulip_private *tp)
 			udelay(10);
 
 		if (!i)
-			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed"
-					" (CSR5 0x%x CSR6 0x%x)\n",
-					pci_name(tp->pdev),
-					ioread32(ioaddr + CSR5),
-					ioread32(ioaddr + CSR6));
+			netdev_dbg(tp->dev, "tulip_stop_rxtx() failed (CSR5 0x%x CSR6 0x%x)\n",
+				   ioread32(ioaddr + CSR5),
+				   ioread32(ioaddr + CSR6));
 	}
 }
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index f46898a..ebc8058 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -330,8 +330,7 @@ static void tulip_up(struct net_device *dev)
 	udelay(100);
 
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: tulip_up(), irq==%d\n",
-		       dev->name, dev->irq);
+		netdev_dbg(dev, "tulip_up(), irq==%d\n", dev->irq);
 
 	iowrite32(tp->rx_ring_dma, ioaddr + CSR3);
 	iowrite32(tp->tx_ring_dma, ioaddr + CSR4);
@@ -498,10 +497,10 @@ media_picked:
 	iowrite32(0, ioaddr + CSR2);		/* Rx poll demand */
 
 	if (tulip_debug > 2) {
-		printk(KERN_DEBUG "%s: Done tulip_up(), CSR0 %08x, CSR5 %08x CSR6 %08x\n",
-		       dev->name, ioread32(ioaddr + CSR0),
-		       ioread32(ioaddr + CSR5),
-		       ioread32(ioaddr + CSR6));
+		netdev_dbg(dev, "Done tulip_up(), CSR0 %08x, CSR5 %08x CSR6 %08x\n",
+			   ioread32(ioaddr + CSR0),
+			   ioread32(ioaddr + CSR5),
+			   ioread32(ioaddr + CSR6));
 	}
 
 	/* Set the timer to switch to check for link beat and perhaps switch
@@ -842,8 +841,7 @@ static int tulip_close (struct net_device *dev)
 	tulip_down (dev);
 
 	if (tulip_debug > 1)
-		dev_printk(KERN_DEBUG, &dev->dev,
-			   "Shutting down ethercard, status was %02x\n",
+		netdev_dbg(dev, "Shutting down ethercard, status was %02x\n",
 			   ioread32 (ioaddr + CSR5));
 
 	free_irq (dev->irq, dev);
@@ -1206,7 +1204,7 @@ static void __devinit tulip_mwi_config (struct pci_dev *pdev,
 	u32 csr0;
 
 	if (tulip_debug > 3)
-		printk(KERN_DEBUG "%s: tulip_mwi_config()\n", pci_name(pdev));
+		netdev_dbg(dev, "tulip_mwi_config()\n");
 
 	tp->csr0 = csr0 = 0;
 
@@ -1268,8 +1266,8 @@ static void __devinit tulip_mwi_config (struct pci_dev *pdev,
 out:
 	tp->csr0 = csr0;
 	if (tulip_debug > 2)
-		printk(KERN_DEBUG "%s: MWI config cacheline=%d, csr0=%08x\n",
-		       pci_name(pdev), cache, csr0);
+		netdev_dbg(dev, "MWI config cacheline=%d, csr0=%08x\n",
+			   cache, csr0);
 }
 #endif
 
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 939c96e..64e3f01 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -645,8 +645,7 @@ static int netdev_open(struct net_device *dev)
 		goto out_err;
 
 	if (debug > 1)
-		printk(KERN_DEBUG "%s: w89c840_open() irq %d\n",
-		       dev->name, dev->irq);
+		netdev_dbg(dev, "w89c840_open() irq %d\n", dev->irq);
 
 	if((i=alloc_ringdesc(dev)))
 		goto out_err;
@@ -658,7 +657,7 @@ static int netdev_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 	if (debug > 2)
-		printk(KERN_DEBUG "%s: Done netdev_open()\n", dev->name);
+		netdev_dbg(dev, "Done netdev_open()\n");
 
 	/* Set the timer to check for link beat. */
 	init_timer(&np->timer);
@@ -787,9 +786,9 @@ static void netdev_timer(unsigned long data)
 	void __iomem *ioaddr = np->base_addr;
 
 	if (debug > 2)
-		printk(KERN_DEBUG "%s: Media selection timer tick, status %08x config %08x\n",
-		       dev->name, ioread32(ioaddr + IntrStatus),
-		       ioread32(ioaddr + NetworkConfig));
+		netdev_dbg(dev, "Media selection timer tick, status %08x config %08x\n",
+			   ioread32(ioaddr + IntrStatus),
+			   ioread32(ioaddr + NetworkConfig));
 	spin_lock_irq(&np->lock);
 	update_csr6(dev, update_link(dev));
 	spin_unlock_irq(&np->lock);
@@ -1056,8 +1055,8 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irq(&np->lock);
 
 	if (debug > 4) {
-		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d\n",
-		       dev->name, np->cur_tx, entry);
+		netdev_dbg(dev, "Transmit frame #%d queued in slot %d\n",
+			   np->cur_tx, entry);
 	}
 	return NETDEV_TX_OK;
 }
@@ -1074,8 +1073,8 @@ static void netdev_tx_done(struct net_device *dev)
 		if (tx_status & 0x8000) { 	/* There was an error, log it. */
 #ifndef final_version
 			if (debug > 1)
-				printk(KERN_DEBUG "%s: Transmit error, Tx status %08x\n",
-				       dev->name, tx_status);
+				netdev_dbg(dev, "Transmit error, Tx status %08x\n",
+					   tx_status);
 #endif
 			np->stats.tx_errors++;
 			if (tx_status & 0x0104) np->stats.tx_aborted_errors++;
@@ -1087,8 +1086,8 @@ static void netdev_tx_done(struct net_device *dev)
 		} else {
 #ifndef final_version
 			if (debug > 3)
-				printk(KERN_DEBUG "%s: Transmit slot %d ok, Tx status %08x\n",
-				       dev->name, entry, tx_status);
+				netdev_dbg(dev, "Transmit slot %d ok, Tx status %08x\n",
+					   entry, tx_status);
 #endif
 			np->stats.tx_bytes += np->tx_skbuff[entry]->len;
 			np->stats.collisions += (tx_status >> 3) & 15;
@@ -1131,8 +1130,7 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 		iowrite32(intr_status & 0x001ffff, ioaddr + IntrStatus);
 
 		if (debug > 4)
-			printk(KERN_DEBUG "%s: Interrupt, status %04x\n",
-			       dev->name, intr_status);
+			netdev_dbg(dev, "Interrupt, status %04x\n", intr_status);
 
 		if ((intr_status & (NormalIntr|AbnormalIntr)) == 0)
 			break;
@@ -1173,8 +1171,8 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 	} while (1);
 
 	if (debug > 3)
-		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x\n",
-		       dev->name, ioread32(ioaddr + IntrStatus));
+		netdev_dbg(dev, "exiting interrupt, status=%#4.4x\n",
+			   ioread32(ioaddr + IntrStatus));
 	return IRQ_RETVAL(handled);
 }
 
@@ -1187,8 +1185,8 @@ static int netdev_rx(struct net_device *dev)
 	int work_limit = np->dirty_rx + RX_RING_SIZE - np->cur_rx;
 
 	if (debug > 4) {
-		printk(KERN_DEBUG " In netdev_rx(), entry %d status %04x\n",
-		       entry, np->rx_ring[entry].status);
+		netdev_dbg(dev, " In netdev_rx(), entry %d status %04x\n",
+			   entry, np->rx_ring[entry].status);
 	}
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
@@ -1197,8 +1195,8 @@ static int netdev_rx(struct net_device *dev)
 		s32 status = desc->status;
 
 		if (debug > 4)
-			printk(KERN_DEBUG "  netdev_rx() status was %08x\n",
-			       status);
+			netdev_dbg(dev, "  netdev_rx() status was %08x\n",
+				   status);
 		if (status < 0)
 			break;
 		if ((status & 0x38008300) != 0x0300) {
@@ -1213,8 +1211,8 @@ static int netdev_rx(struct net_device *dev)
 			} else if (status & 0x8000) {
 				/* There was a fatal error. */
 				if (debug > 2)
-					printk(KERN_DEBUG "%s: Receive error, Rx status %08x\n",
-					       dev->name, status);
+					netdev_dbg(dev, "Receive error, Rx status %08x\n",
+						   status);
 				np->stats.rx_errors++; /* end of a packet.*/
 				if (status & 0x0890) np->stats.rx_length_errors++;
 				if (status & 0x004C) np->stats.rx_frame_errors++;
@@ -1227,8 +1225,8 @@ static int netdev_rx(struct net_device *dev)
 
 #ifndef final_version
 			if (debug > 4)
-				printk(KERN_DEBUG "  netdev_rx() normal Rx pkt length %d status %x\n",
-				       pkt_len, status);
+				netdev_dbg(dev, "  netdev_rx() normal Rx pkt length %d status %x\n",
+					   pkt_len, status);
 #endif
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
@@ -1253,10 +1251,10 @@ static int netdev_rx(struct net_device *dev)
 #ifndef final_version				/* Remove after testing. */
 			/* You will want this info for the initial debug. */
 			if (debug > 5)
-				printk(KERN_DEBUG "  Rx data %pM %pM %02x%02x %pI4\n",
-				       &skb->data[0], &skb->data[6],
-				       skb->data[12], skb->data[13],
-				       &skb->data[14]);
+				netdev_dbg(dev, "  Rx data %pM %pM %02x%02x %pI4\n",
+					   &skb->data[0], &skb->data[6],
+					   skb->data[12], skb->data[13],
+					   &skb->data[14]);
 #endif
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
@@ -1294,8 +1292,7 @@ static void netdev_error(struct net_device *dev, int intr_status)
 	void __iomem *ioaddr = np->base_addr;
 
 	if (debug > 2)
-		printk(KERN_DEBUG "%s: Abnormal event, %08x\n",
-		       dev->name, intr_status);
+		netdev_dbg(dev, "Abnormal event, %08x\n", intr_status);
 	if (intr_status == 0xffffffff)
 		return;
 	spin_lock(&np->lock);
@@ -1315,8 +1312,7 @@ static void netdev_error(struct net_device *dev, int intr_status)
 		 	new = 127; /* load full packet before starting */
 		new = (np->csr6 & ~(0x7F << 14)) | (new<<14);
 #endif
-		printk(KERN_DEBUG "%s: Tx underflow, new csr6 %08x\n",
-		       dev->name, new);
+		netdev_dbg(dev, "Tx underflow, new csr6 %08x\n", new);
 		update_csr6(dev, new);
 	}
 	if (intr_status & RxDied) {		/* Missed a Rx frame. */
@@ -1489,13 +1485,12 @@ static int netdev_close(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	if (debug > 1) {
-		printk(KERN_DEBUG "%s: Shutting down ethercard, status was %08x Config %08x\n",
-		       dev->name, ioread32(ioaddr + IntrStatus),
-		       ioread32(ioaddr + NetworkConfig));
-		printk(KERN_DEBUG "%s: Queue pointers were Tx %d / %d,  Rx %d / %d\n",
-		       dev->name,
-		       np->cur_tx, np->dirty_tx,
-		       np->cur_rx, np->dirty_rx);
+		netdev_dbg(dev, "Shutting down ethercard, status was %08x Config %08x\n",
+			   ioread32(ioaddr + IntrStatus),
+			   ioread32(ioaddr + NetworkConfig));
+		netdev_dbg(dev, "Queue pointers were Tx %d / %d,  Rx %d / %d\n",
+			   np->cur_tx, np->dirty_tx,
+			   np->cur_rx, np->dirty_rx);
 	}
 
  	/* Stop the chip's Tx and Rx processes. */
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 7e82872..988b8eb 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -333,7 +333,7 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 
 	if (link_status_changed(card)) {
 		int newlink;
-		printk(KERN_DEBUG "xircom_cb: Link status has changed\n");
+		netdev_dbg(dev, "Link status has changed\n");
 		newlink = link_status(card);
 		netdev_info(dev, "Link is %d mbit\n", newlink);
 		if (newlink)
-- 
1.7.5.rc3.dirty
