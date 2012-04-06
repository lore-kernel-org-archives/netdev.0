From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 33/39] dmfe: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Fri,  6 Apr 2012 12:06:47 +0200
Message-ID: <83b453d5ea2df18d0af1a760e458c5b649415bfd.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43493 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756084Ab2DFKKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:43 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a pure PCI driver, no ISA here.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/dmfe.c |  295 +++++++++++++++++----------------
 1 files changed, 153 insertions(+), 142 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 1eccf49..0ef5b68 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -150,6 +150,12 @@
 #define DMFE_TX_TIMEOUT ((3*HZ)/2)	/* tx packet time-out time 1.5 s" */
 #define DMFE_TX_KICK 	(HZ/2)	/* tx packet Kick-out time 0.5 s" */
 
+#define dw32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define dw16(reg, val)	iowrite16(val, ioaddr + (reg))
+#define dr32(reg)	ioread32(ioaddr + (reg))
+#define dr16(reg)	ioread16(ioaddr + (reg))
+#define dr8(reg)	ioread8(ioaddr + (reg))
+
 #define DMFE_DBUG(dbug_now, msg, value)			\
 	do {						\
 		if (dmfe_debug || (dbug_now))		\
@@ -178,14 +184,6 @@
 
 #define SROM_V41_CODE   0x14
 
-#define SROM_CLK_WRITE(data, ioaddr) \
-	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
-	udelay(5); \
-	outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr); \
-	udelay(5); \
-	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
-	udelay(5);
-
 #define __CHK_IO_SIZE(pci_id, dev_rev) \
  (( ((pci_id)==PCI_DM9132_ID) || ((dev_rev) >= 0x30) ) ? \
 	DM9102A_IO_SIZE: DM9102_IO_SIZE)
@@ -213,11 +211,11 @@ struct rx_desc {
 struct dmfe_board_info {
 	u32 chip_id;			/* Chip vendor/Device ID */
 	u8 chip_revision;		/* Chip revision */
-	struct DEVICE *next_dev;	/* next device */
+	struct net_device *next_dev;	/* next device */
 	struct pci_dev *pdev;		/* PCI device */
 	spinlock_t lock;
 
-	long ioaddr;			/* I/O base address */
+	void __iomem *ioaddr;		/* I/O base address */
 	u32 cr0_data;
 	u32 cr5_data;
 	u32 cr6_data;
@@ -320,20 +318,20 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *, struct DEVICE *);
 static int dmfe_stop(struct DEVICE *);
 static void dmfe_set_filter_mode(struct DEVICE *);
 static const struct ethtool_ops netdev_ethtool_ops;
-static u16 read_srom_word(long ,int);
+static u16 read_srom_word(void __iomem *, int);
 static irqreturn_t dmfe_interrupt(int , void *);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_dmfe (struct net_device *dev);
 #endif
-static void dmfe_descriptor_init(struct net_device *, unsigned long);
+static void dmfe_descriptor_init(struct net_device *);
 static void allocate_rx_buffer(struct net_device *);
-static void update_cr6(u32, unsigned long);
+static void update_cr6(u32, void __iomem *);
 static void send_filter_frame(struct DEVICE *);
 static void dm9132_id_table(struct DEVICE *);
-static u16 phy_read(unsigned long, u8, u8, u32);
-static void phy_write(unsigned long, u8, u8, u16, u32);
-static void phy_write_1bit(unsigned long, u32);
-static u16 phy_read_1bit(unsigned long);
+static u16 phy_read(void __iomem *, u8, u8, u32);
+static void phy_write(void __iomem *, u8, u8, u16, u32);
+static void phy_write_1bit(void __iomem *, u32);
+static u16 phy_read_1bit(void __iomem *);
 static u8 dmfe_sense_speed(struct dmfe_board_info *);
 static void dmfe_process_mode(struct dmfe_board_info *);
 static void dmfe_timer(unsigned long);
@@ -462,14 +460,16 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	db->buf_pool_dma_start = db->buf_pool_dma_ptr;
 
 	db->chip_id = ent->driver_data;
-	db->ioaddr = pci_resource_start(pdev, 0);
+	/* IO type range. */
+	db->ioaddr = pci_iomap(pdev, 0, 0);
+	if (!db->ioaddr)
+		goto err_out_free_buf;
+
 	db->chip_revision = pdev->revision;
 	db->wol_mode = 0;
 
 	db->pdev = pdev;
 
-	dev->base_addr = db->ioaddr;
-	dev->irq = pdev->irq;
 	pci_set_drvdata(pdev, dev);
 	dev->netdev_ops = &netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
@@ -484,9 +484,10 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 		db->chip_type = 0;
 
 	/* read 64 word srom data */
-	for (i = 0; i < 64; i++)
+	for (i = 0; i < 64; i++) {
 		((__le16 *) db->srom)[i] =
 			cpu_to_le16(read_srom_word(db->ioaddr, i));
+	}
 
 	/* Set Node address */
 	for (i = 0; i < 6; i++)
@@ -494,16 +495,18 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 
 	err = register_netdev (dev);
 	if (err)
-		goto err_out_free_buf;
+		goto err_out_unmap;
 
 	dev_info(&dev->dev, "Davicom DM%04lx at pci%s, %pM, irq %d\n",
 		 ent->driver_data >> 16,
-		 pci_name(pdev), dev->dev_addr, dev->irq);
+		 pci_name(pdev), dev->dev_addr, pdev->irq);
 
 	pci_set_master(pdev);
 
 	return 0;
 
+err_out_unmap:
+	pci_iounmap(pdev, db->ioaddr);
 err_out_free_buf:
 	pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
 			    db->buf_pool_ptr, db->buf_pool_dma_ptr);
@@ -532,7 +535,7 @@ static void __devexit dmfe_remove_one (struct pci_dev *pdev)
  	if (dev) {
 
 		unregister_netdev(dev);
-
+		pci_iounmap(db->pdev, db->ioaddr);
 		pci_free_consistent(db->pdev, sizeof(struct tx_desc) *
 					DESC_ALL_CNT + 0x20, db->desc_pool_ptr,
  					db->desc_pool_dma_ptr);
@@ -555,13 +558,13 @@ static void __devexit dmfe_remove_one (struct pci_dev *pdev)
 
 static int dmfe_open(struct DEVICE *dev)
 {
-	int ret;
 	struct dmfe_board_info *db = netdev_priv(dev);
+	const int irq = db->pdev->irq;
+	int ret;
 
 	DMFE_DBUG(0, "dmfe_open", 0);
 
-	ret = request_irq(dev->irq, dmfe_interrupt,
-			  IRQF_SHARED, dev->name, dev);
+	ret = request_irq(irq, dmfe_interrupt, IRQF_SHARED, dev->name, dev);
 	if (ret)
 		return ret;
 
@@ -615,14 +618,14 @@ static int dmfe_open(struct DEVICE *dev)
 static void dmfe_init_dm910x(struct DEVICE *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = db->ioaddr;
+	void __iomem *ioaddr = db->ioaddr;
 
 	DMFE_DBUG(0, "dmfe_init_dm910x()", 0);
 
 	/* Reset DM910x MAC controller */
-	outl(DM910X_RESET, ioaddr + DCR0);	/* RESET MAC */
+	dw32(DCR0, DM910X_RESET);	/* RESET MAC */
 	udelay(100);
-	outl(db->cr0_data, ioaddr + DCR0);
+	dw32(DCR0, db->cr0_data);
 	udelay(5);
 
 	/* Phy addr : DM910(A)2/DM9132/9801, phy address = 1 */
@@ -633,12 +636,12 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 	db->media_mode = dmfe_media_mode;
 
 	/* RESET Phyxcer Chip by GPR port bit 7 */
-	outl(0x180, ioaddr + DCR12);		/* Let bit 7 output port */
+	dw32(DCR12, 0x180);		/* Let bit 7 output port */
 	if (db->chip_id == PCI_DM9009_ID) {
-		outl(0x80, ioaddr + DCR12);	/* Issue RESET signal */
+		dw32(DCR12, 0x80);	/* Issue RESET signal */
 		mdelay(300);			/* Delay 300 ms */
 	}
-	outl(0x0, ioaddr + DCR12);	/* Clear RESET signal */
+	dw32(DCR12, 0x0);	/* Clear RESET signal */
 
 	/* Process Phyxcer Media Mode */
 	if ( !(db->media_mode & 0x10) )	/* Force 1M mode */
@@ -649,7 +652,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 		db->op_mode = db->media_mode; 	/* Force Mode */
 
 	/* Initialize Transmit/Receive decriptor and CR3/4 */
-	dmfe_descriptor_init(dev, ioaddr);
+	dmfe_descriptor_init(dev);
 
 	/* Init CR6 to program DM910x operation */
 	update_cr6(db->cr6_data, ioaddr);
@@ -662,10 +665,10 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
-	outl(db->cr7_data, ioaddr + DCR7);
+	dw32(DCR7, db->cr7_data);
 
 	/* Init CR15, Tx jabber and Rx watchdog timer */
-	outl(db->cr15_data, ioaddr + DCR15);
+	dw32(DCR15, db->cr15_data);
 
 	/* Enable DM910X Tx/Rx function */
 	db->cr6_data |= CR6_RXSC | CR6_TXSC | 0x40000;
@@ -682,6 +685,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 					 struct DEVICE *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 	struct tx_desc *txptr;
 	unsigned long flags;
 
@@ -707,7 +711,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 	}
 
 	/* Disable NIC interrupt */
-	outl(0, dev->base_addr + DCR7);
+	dw32(DCR7, 0);
 
 	/* transmit this packet */
 	txptr = db->tx_insert_ptr;
@@ -721,11 +725,11 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 	if ( (!db->tx_queue_cnt) && (db->tx_packet_cnt < TX_MAX_SEND_CNT) ) {
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
-		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
+		dw32(DCR1, 0x1);			/* Issue Tx polling */
 		dev->trans_start = jiffies;		/* saved time stamp */
 	} else {
 		db->tx_queue_cnt++;			/* queue TX packet */
-		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
+		dw32(DCR1, 0x1);			/* Issue Tx polling */
 	}
 
 	/* Tx resource check */
@@ -734,7 +738,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 
 	/* Restore CR7 to enable interrupt */
 	spin_unlock_irqrestore(&db->lock, flags);
-	outl(db->cr7_data, dev->base_addr + DCR7);
+	dw32(DCR7, db->cr7_data);
 
 	/* free this SKB */
 	dev_kfree_skb(skb);
@@ -751,7 +755,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 static int dmfe_stop(struct DEVICE *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = db->ioaddr;
 
 	DMFE_DBUG(0, "dmfe_stop", 0);
 
@@ -762,12 +766,12 @@ static int dmfe_stop(struct DEVICE *dev)
 	del_timer_sync(&db->timer);
 
 	/* Reset & stop DM910X board */
-	outl(DM910X_RESET, ioaddr + DCR0);
+	dw32(DCR0, DM910X_RESET);
 	udelay(5);
-	phy_write(db->ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
+	phy_write(ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
 
 	/* free interrupt */
-	free_irq(dev->irq, dev);
+	free_irq(db->pdev->irq, dev);
 
 	/* free allocated rx buffer */
 	dmfe_free_rxbuffer(db);
@@ -794,7 +798,7 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 {
 	struct DEVICE *dev = dev_id;
 	struct dmfe_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = db->ioaddr;
 	unsigned long flags;
 
 	DMFE_DBUG(0, "dmfe_interrupt()", 0);
@@ -802,15 +806,15 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 	spin_lock_irqsave(&db->lock, flags);
 
 	/* Got DM910X status */
-	db->cr5_data = inl(ioaddr + DCR5);
-	outl(db->cr5_data, ioaddr + DCR5);
+	db->cr5_data = dr32(DCR5);
+	dw32(DCR5, db->cr5_data);
 	if ( !(db->cr5_data & 0xc1) ) {
 		spin_unlock_irqrestore(&db->lock, flags);
 		return IRQ_HANDLED;
 	}
 
 	/* Disable all interrupt in CR7 to solve the interrupt edge problem */
-	outl(0, ioaddr + DCR7);
+	dw32(DCR7, 0);
 
 	/* Check system status */
 	if (db->cr5_data & 0x2000) {
@@ -838,11 +842,11 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 	if (db->dm910x_chk_mode & 0x2) {
 		db->dm910x_chk_mode = 0x4;
 		db->cr6_data |= 0x100;
-		update_cr6(db->cr6_data, db->ioaddr);
+		update_cr6(db->cr6_data, ioaddr);
 	}
 
 	/* Restore CR7 to enable interrupt mask */
-	outl(db->cr7_data, ioaddr + DCR7);
+	dw32(DCR7, db->cr7_data);
 
 	spin_unlock_irqrestore(&db->lock, flags);
 	return IRQ_HANDLED;
@@ -858,11 +862,14 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 
 static void poll_dmfe (struct net_device *dev)
 {
+	struct dmfe_board_info *db = netdev_priv(dev);
+	const int irq = db->pdev->irq;
+
 	/* disable_irq here is not very nice, but with the lockless
 	   interrupt handler we have no other choice. */
-	disable_irq(dev->irq);
-	dmfe_interrupt (dev->irq, dev);
-	enable_irq(dev->irq);
+	disable_irq(irq);
+	dmfe_interrupt (irq, dev);
+	enable_irq(irq);
 }
 #endif
 
@@ -873,7 +880,7 @@ static void poll_dmfe (struct net_device *dev)
 static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 {
 	struct tx_desc *txptr;
-	unsigned long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = db->ioaddr;
 	u32 tdes0;
 
 	txptr = db->tx_remove_ptr;
@@ -897,7 +904,7 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 					db->tx_fifo_underrun++;
 					if ( !(db->cr6_data & CR6_SFT) ) {
 						db->cr6_data = db->cr6_data | CR6_SFT;
-						update_cr6(db->cr6_data, db->ioaddr);
+						update_cr6(db->cr6_data, ioaddr);
 					}
 				}
 				if (tdes0 & 0x0100)
@@ -924,7 +931,7 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
 		db->tx_queue_cnt--;
-		outl(0x1, ioaddr + DCR1);		/* Issue Tx polling */
+		dw32(DCR1, 0x1);			/* Issue Tx polling */
 		dev->trans_start = jiffies;		/* saved time stamp */
 	}
 
@@ -1087,12 +1094,7 @@ static void dmfe_ethtool_get_drvinfo(struct net_device *dev,
 
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	if (np->pdev)
-		strlcpy(info->bus_info, pci_name(np->pdev),
-			sizeof(info->bus_info));
-	else
-		sprintf(info->bus_info, "EISA 0x%lx %d",
-			dev->base_addr, dev->irq);
+	strlcpy(info->bus_info, pci_name(np->pdev), sizeof(info->bus_info));
 }
 
 static int dmfe_ethtool_set_wol(struct net_device *dev,
@@ -1132,10 +1134,11 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 
 static void dmfe_timer(unsigned long data)
 {
+	struct net_device *dev = (struct net_device *)data;
+	struct dmfe_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 	u32 tmp_cr8;
 	unsigned char tmp_cr12;
-	struct DEVICE *dev = (struct DEVICE *) data;
-	struct dmfe_board_info *db = netdev_priv(dev);
  	unsigned long flags;
 
 	int link_ok, link_ok_phy;
@@ -1148,11 +1151,10 @@ static void dmfe_timer(unsigned long data)
 		db->first_in_callback = 1;
 		if (db->chip_type && (db->chip_id==PCI_DM9102_ID)) {
 			db->cr6_data &= ~0x40000;
-			update_cr6(db->cr6_data, db->ioaddr);
-			phy_write(db->ioaddr,
-				  db->phy_addr, 0, 0x1000, db->chip_id);
+			update_cr6(db->cr6_data, ioaddr);
+			phy_write(ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
 			db->cr6_data |= 0x40000;
-			update_cr6(db->cr6_data, db->ioaddr);
+			update_cr6(db->cr6_data, ioaddr);
 			db->timer.expires = DMFE_TIMER_WUT + HZ * 2;
 			add_timer(&db->timer);
 			spin_unlock_irqrestore(&db->lock, flags);
@@ -1167,7 +1169,7 @@ static void dmfe_timer(unsigned long data)
 		db->dm910x_chk_mode = 0x4;
 
 	/* Dynamic reset DM910X : system error or transmit time-out */
-	tmp_cr8 = inl(db->ioaddr + DCR8);
+	tmp_cr8 = dr32(DCR8);
 	if ( (db->interval_rx_cnt==0) && (tmp_cr8) ) {
 		db->reset_cr8++;
 		db->wait_reset = 1;
@@ -1177,7 +1179,7 @@ static void dmfe_timer(unsigned long data)
 	/* TX polling kick monitor */
 	if ( db->tx_packet_cnt &&
 	     time_after(jiffies, dev_trans_start(dev) + DMFE_TX_KICK) ) {
-		outl(0x1, dev->base_addr + DCR1);   /* Tx polling again */
+		dw32(DCR1, 0x1);   /* Tx polling again */
 
 		/* TX Timeout */
 		if (time_after(jiffies, dev_trans_start(dev) + DMFE_TX_TIMEOUT) ) {
@@ -1200,9 +1202,9 @@ static void dmfe_timer(unsigned long data)
 
 	/* Link status check, Dynamic media type change */
 	if (db->chip_id == PCI_DM9132_ID)
-		tmp_cr12 = inb(db->ioaddr + DCR9 + 3);	/* DM9132 */
+		tmp_cr12 = dr8(DCR9 + 3);	/* DM9132 */
 	else
-		tmp_cr12 = inb(db->ioaddr + DCR12);	/* DM9102/DM9102A */
+		tmp_cr12 = dr8(DCR12);		/* DM9102/DM9102A */
 
 	if ( ((db->chip_id == PCI_DM9102_ID) &&
 		(db->chip_revision == 0x30)) ||
@@ -1251,7 +1253,7 @@ static void dmfe_timer(unsigned long data)
 			/* 10/100M link failed, used 1M Home-Net */
 			db->cr6_data|=0x00040000;	/* bit18=1, MII */
 			db->cr6_data&=~0x00000200;	/* bit9=0, HD mode */
-			update_cr6(db->cr6_data, db->ioaddr);
+			update_cr6(db->cr6_data, ioaddr);
 		}
 	} else if (!netif_carrier_ok(dev)) {
 
@@ -1288,17 +1290,18 @@ static void dmfe_timer(unsigned long data)
  *	Re-initialize DM910X board
  */
 
-static void dmfe_dynamic_reset(struct DEVICE *dev)
+static void dmfe_dynamic_reset(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 
 	DMFE_DBUG(0, "dmfe_dynamic_reset()", 0);
 
 	/* Sopt MAC controller */
 	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);	/* Disable Tx/Rx */
-	update_cr6(db->cr6_data, dev->base_addr);
-	outl(0, dev->base_addr + DCR7);		/* Disable Interrupt */
-	outl(inl(dev->base_addr + DCR5), dev->base_addr + DCR5);
+	update_cr6(db->cr6_data, ioaddr);
+	dw32(DCR7, 0);				/* Disable Interrupt */
+	dw32(DCR5, dr32(DCR5));
 
 	/* Disable upper layer interface */
 	netif_stop_queue(dev);
@@ -1364,9 +1367,10 @@ static void dmfe_reuse_skb(struct dmfe_board_info *db, struct sk_buff * skb)
  *	Using Chain structure, and allocate Tx/Rx buffer
  */
 
-static void dmfe_descriptor_init(struct net_device *dev, unsigned long ioaddr)
+static void dmfe_descriptor_init(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 	struct tx_desc *tmp_tx;
 	struct rx_desc *tmp_rx;
 	unsigned char *tmp_buf;
@@ -1379,7 +1383,7 @@ static void dmfe_descriptor_init(struct net_device *dev, unsigned long ioaddr)
 	/* tx descriptor start pointer */
 	db->tx_insert_ptr = db->first_tx_desc;
 	db->tx_remove_ptr = db->first_tx_desc;
-	outl(db->first_tx_desc_dma, ioaddr + DCR4);     /* TX DESC address */
+	dw32(DCR4, db->first_tx_desc_dma);     /* TX DESC address */
 
 	/* rx descriptor start pointer */
 	db->first_rx_desc = (void *)db->first_tx_desc +
@@ -1389,7 +1393,7 @@ static void dmfe_descriptor_init(struct net_device *dev, unsigned long ioaddr)
 			sizeof(struct tx_desc) * TX_DESC_CNT;
 	db->rx_insert_ptr = db->first_rx_desc;
 	db->rx_ready_ptr = db->first_rx_desc;
-	outl(db->first_rx_desc_dma, ioaddr + DCR3);	/* RX DESC address */
+	dw32(DCR3, db->first_rx_desc_dma);		/* RX DESC address */
 
 	/* Init Transmit chain */
 	tmp_buf = db->buf_pool_start;
@@ -1431,14 +1435,14 @@ static void dmfe_descriptor_init(struct net_device *dev, unsigned long ioaddr)
  *	Firstly stop DM910X , then written value and start
  */
 
-static void update_cr6(u32 cr6_data, unsigned long ioaddr)
+static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
 {
 	u32 cr6_tmp;
 
 	cr6_tmp = cr6_data & ~0x2002;           /* stop Tx/Rx */
-	outl(cr6_tmp, ioaddr + DCR6);
+	dw32(DCR6, cr6_tmp);
 	udelay(5);
-	outl(cr6_data, ioaddr + DCR6);
+	dw32(DCR6, cr6_data);
 	udelay(5);
 }
 
@@ -1448,24 +1452,19 @@ static void update_cr6(u32 cr6_data, unsigned long ioaddr)
  *	This setup frame initialize DM910X address filter mode
 */
 
-static void dm9132_id_table(struct DEVICE *dev)
+static void dm9132_id_table(struct net_device *dev)
 {
+	struct dmfe_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr + 0xc0;
+	u16 *addrptr = (u16 *)dev->dev_addr;
 	struct netdev_hw_addr *ha;
-	u16 * addrptr;
-	unsigned long ioaddr = dev->base_addr+0xc0;		/* ID Table */
-	u32 hash_val;
 	u16 i, hash_table[4];
 
-	DMFE_DBUG(0, "dm9132_id_table()", 0);
-
 	/* Node address */
-	addrptr = (u16 *) dev->dev_addr;
-	outw(addrptr[0], ioaddr);
-	ioaddr += 4;
-	outw(addrptr[1], ioaddr);
-	ioaddr += 4;
-	outw(addrptr[2], ioaddr);
-	ioaddr += 4;
+	for (i = 0; i < 3; i++) {
+		dw16(0, addrptr[i]);
+		ioaddr += 4;
+	}
 
 	/* Clear Hash Table */
 	memset(hash_table, 0, sizeof(hash_table));
@@ -1475,13 +1474,14 @@ static void dm9132_id_table(struct DEVICE *dev)
 
 	/* the multicast address in Hash Table : 64 bits */
 	netdev_for_each_mc_addr(ha, dev) {
-		hash_val = cal_CRC((char *) ha->addr, 6, 0) & 0x3f;
+		u32 hash_val = cal_CRC((char *)ha->addr, 6, 0) & 0x3f;
+
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
 	/* Write the hash table to MAC MD table */
 	for (i = 0; i < 4; i++, ioaddr += 4)
-		outw(hash_table[i], ioaddr);
+		dw16(0, hash_table[i]);
 }
 
 
@@ -1490,7 +1490,7 @@ static void dm9132_id_table(struct DEVICE *dev)
  *	This setup frame initialize DM910X address filter mode
  */
 
-static void send_filter_frame(struct DEVICE *dev)
+static void send_filter_frame(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	struct netdev_hw_addr *ha;
@@ -1535,12 +1535,14 @@ static void send_filter_frame(struct DEVICE *dev)
 
 	/* Resource Check and Send the setup packet */
 	if (!db->tx_packet_cnt) {
+		void __iomem *ioaddr = db->ioaddr;
+
 		/* Resource Empty */
 		db->tx_packet_cnt++;
 		txptr->tdes0 = cpu_to_le32(0x80000000);
-		update_cr6(db->cr6_data | 0x2000, dev->base_addr);
-		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
-		update_cr6(db->cr6_data, dev->base_addr);
+		update_cr6(db->cr6_data | 0x2000, ioaddr);
+		dw32(DCR1, 0x1);	/* Issue Tx polling */
+		update_cr6(db->cr6_data, ioaddr);
 		dev->trans_start = jiffies;
 	} else
 		db->tx_queue_cnt++;	/* Put in TX queue */
@@ -1575,43 +1577,55 @@ static void allocate_rx_buffer(struct net_device *dev)
 	db->rx_insert_ptr = rxptr;
 }
 
+static void srom_clk_write(void __iomem *ioaddr, u32 data)
+{
+	static const u32 cmd[] = {
+		CR9_SROM_READ | CR9_SRCS,
+		CR9_SROM_READ | CR9_SRCS | CR9_SRCLK,
+		CR9_SROM_READ | CR9_SRCS
+	};
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(cmd); i++) {
+		dw32(DCR9, data | cmd[i]);
+		udelay(5);
+	}
+}
 
 /*
  *	Read one word data from the serial ROM
  */
-
-static u16 read_srom_word(long ioaddr, int offset)
+static u16 read_srom_word(void __iomem *ioaddr, int offset)
 {
+	u16 srom_data;
 	int i;
-	u16 srom_data = 0;
-	long cr9_ioaddr = ioaddr + DCR9;
 
-	outl(CR9_SROM_READ, cr9_ioaddr);
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+	dw32(DCR9, CR9_SROM_READ);
+	dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 
 	/* Send the Read Command 110b */
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_0, cr9_ioaddr);
+	srom_clk_write(ioaddr, SROM_DATA_1);
+	srom_clk_write(ioaddr, SROM_DATA_1);
+	srom_clk_write(ioaddr, SROM_DATA_0);
 
 	/* Send the offset */
 	for (i = 5; i >= 0; i--) {
 		srom_data = (offset & (1 << i)) ? SROM_DATA_1 : SROM_DATA_0;
-		SROM_CLK_WRITE(srom_data, cr9_ioaddr);
+		srom_clk_write(ioaddr, srom_data);
 	}
 
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+	dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 
 	for (i = 16; i > 0; i--) {
-		outl(CR9_SROM_READ | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
+		dw32(DCR9, CR9_SROM_READ | CR9_SRCS | CR9_SRCLK);
 		udelay(5);
 		srom_data = (srom_data << 1) |
-				((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
-		outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+				((dr32(DCR9) & CR9_CRDOUT) ? 1 : 0);
+		dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 		udelay(5);
 	}
 
-	outl(CR9_SROM_READ, cr9_ioaddr);
+	dw32(DCR9, CR9_SROM_READ);
 	return srom_data;
 }
 
@@ -1620,13 +1634,14 @@ static u16 read_srom_word(long ioaddr, int offset)
  *	Auto sense the media mode
  */
 
-static u8 dmfe_sense_speed(struct dmfe_board_info * db)
+static u8 dmfe_sense_speed(struct dmfe_board_info *db)
 {
+	void __iomem *ioaddr = db->ioaddr;
 	u8 ErrFlag = 0;
 	u16 phy_mode;
 
 	/* CR6 bit18=0, select 10/100M */
-	update_cr6( (db->cr6_data & ~0x40000), db->ioaddr);
+	update_cr6(db->cr6_data & ~0x40000, ioaddr);
 
 	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
 	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
@@ -1665,11 +1680,12 @@ static u8 dmfe_sense_speed(struct dmfe_board_info * db)
 
 static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 {
+	void __iomem *ioaddr = db->ioaddr;
 	u16 phy_reg;
 
 	/* Select 10/100M phyxcer */
 	db->cr6_data &= ~0x40000;
-	update_cr6(db->cr6_data, db->ioaddr);
+	update_cr6(db->cr6_data, ioaddr);
 
 	/* DM9009 Chip: Phyxcer reg18 bit12=0 */
 	if (db->chip_id == PCI_DM9009_ID) {
@@ -1765,18 +1781,15 @@ static void dmfe_process_mode(struct dmfe_board_info *db)
  *	Write a word to Phy register
  */
 
-static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
+static void phy_write(void __iomem *ioaddr, u8 phy_addr, u8 offset,
 		      u16 phy_data, u32 chip_id)
 {
 	u16 i;
-	unsigned long ioaddr;
 
 	if (chip_id == PCI_DM9132_ID) {
-		ioaddr = iobase + 0x80 + offset * 4;
-		outw(phy_data, ioaddr);
+		dw16(0x80 + offset * 4, phy_data);
 	} else {
 		/* DM9102/DM9102A Chip */
-		ioaddr = iobase + DCR9;
 
 		/* Send 33 synchronization clock to Phy controller */
 		for (i = 0; i < 35; i++)
@@ -1816,19 +1829,16 @@ static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
  *	Read a word data from phy register
  */
 
-static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
+static u16 phy_read(void __iomem *ioaddr, u8 phy_addr, u8 offset, u32 chip_id)
 {
 	int i;
 	u16 phy_data;
-	unsigned long ioaddr;
 
 	if (chip_id == PCI_DM9132_ID) {
 		/* DM9132 Chip */
-		ioaddr = iobase + 0x80 + offset * 4;
-		phy_data = inw(ioaddr);
+		phy_data = dr16(0x80 + offset * 4);
 	} else {
 		/* DM9102/DM9102A Chip */
-		ioaddr = iobase + DCR9;
 
 		/* Send 33 synchronization clock to Phy controller */
 		for (i = 0; i < 35; i++)
@@ -1870,13 +1880,13 @@ static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
  *	Write one bit data to Phy Controller
  */
 
-static void phy_write_1bit(unsigned long ioaddr, u32 phy_data)
+static void phy_write_1bit(void __iomem *ioaddr, u32 phy_data)
 {
-	outl(phy_data, ioaddr);			/* MII Clock Low */
+	dw32(DCR9, phy_data);		/* MII Clock Low */
 	udelay(1);
-	outl(phy_data | MDCLKH, ioaddr);	/* MII Clock High */
+	dw32(DCR9, phy_data | MDCLKH);	/* MII Clock High */
 	udelay(1);
-	outl(phy_data, ioaddr);			/* MII Clock Low */
+	dw32(DCR9, phy_data);		/* MII Clock Low */
 	udelay(1);
 }
 
@@ -1885,14 +1895,14 @@ static void phy_write_1bit(unsigned long ioaddr, u32 phy_data)
  *	Read one bit phy data from PHY controller
  */
 
-static u16 phy_read_1bit(unsigned long ioaddr)
+static u16 phy_read_1bit(void __iomem *ioaddr)
 {
 	u16 phy_data;
 
-	outl(0x50000, ioaddr);
+	dw32(DCR9, 0x50000);
 	udelay(1);
-	phy_data = ( inl(ioaddr) >> 19 ) & 0x1;
-	outl(0x40000, ioaddr);
+	phy_data = (dr32(DCR9) >> 19) & 0x1;
+	dw32(DCR9, 0x40000);
 	udelay(1);
 
 	return phy_data;
@@ -1978,7 +1988,7 @@ static void dmfe_parse_srom(struct dmfe_board_info * db)
 
 	/* Check DM9801 or DM9802 present or not */
 	db->HPNA_present = 0;
-	update_cr6(db->cr6_data|0x40000, db->ioaddr);
+	update_cr6(db->cr6_data | 0x40000, db->ioaddr);
 	tmp_reg = phy_read(db->ioaddr, db->phy_addr, 3, db->chip_id);
 	if ( ( tmp_reg & 0xfff0 ) == 0xb900 ) {
 		/* DM9801 or DM9802 present */
@@ -2095,6 +2105,7 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct dmfe_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 	u32 tmp;
 
 	/* Disable upper layer interface */
@@ -2102,11 +2113,11 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 
 	/* Disable Tx/Rx */
 	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);
-	update_cr6(db->cr6_data, dev->base_addr);
+	update_cr6(db->cr6_data, ioaddr);
 
 	/* Disable Interrupt */
-	outl(0, dev->base_addr + DCR7);
-	outl(inl (dev->base_addr + DCR5), dev->base_addr + DCR5);
+	dw32(DCR7, 0);
+	dw32(DCR5, dr32(DCR5));
 
 	/* Fre RX buffers */
 	dmfe_free_rxbuffer(db);
-- 
1.7.7.6
