From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 31/39] uli526x: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Fri,  6 Apr 2012 12:06:45 +0200
Message-ID: <0a3928f4342bab3bf0b2eb63fe71cecace548e99.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43492 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756071Ab2DFKKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:43 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bulk of the patch comes from the __iomem changes.

- the phy read and write operations were carrying the chip id deep
  down the call chain. Let's waste a pointer and contain the flying
  spaghetti monster.
- phy_{read, write}_1bit only need to access the DCR9 register. The loss
  of generality here should not hurt.
- removed a leftover printk of the EISA era. This is a pure PCI device.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/uli526x.c |  397 +++++++++++++++---------------
 1 files changed, 202 insertions(+), 195 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index c9b3396..75d45f8 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -42,6 +42,8 @@
 #include <asm/dma.h>
 #include <asm/uaccess.h>
 
+#define uw32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define ur32(reg)	ioread32(ioaddr + (reg))
 
 /* Board/System/Debug information/definition ---------------- */
 #define PCI_ULI5261_ID  0x526110B9	/* ULi M5261 ID*/
@@ -110,14 +112,6 @@ do {								\
 
 #define SROM_V41_CODE   0x14
 
-#define SROM_CLK_WRITE(data, ioaddr)					\
-		outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);		\
-		udelay(5);						\
-		outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr);	\
-		udelay(5);						\
-		outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);		\
-		udelay(5);
-
 /* Structure/enum declaration ------------------------------- */
 struct tx_desc {
         __le32 tdes0, tdes1, tdes2, tdes3; /* Data for the card */
@@ -132,12 +126,15 @@ struct rx_desc {
 } __attribute__(( aligned(32) ));
 
 struct uli526x_board_info {
-	u32 chip_id;			/* Chip vendor/Device ID */
+	struct uli_phy_ops {
+		void (*write)(struct uli526x_board_info *, u8, u8, u16);
+		u16 (*read)(struct uli526x_board_info *, u8, u8);
+	} phy;
 	struct net_device *next_dev;	/* next device */
 	struct pci_dev *pdev;		/* PCI device */
 	spinlock_t lock;
 
-	long ioaddr;			/* I/O base address */
+	void __iomem *ioaddr;		/* I/O base address */
 	u32 cr0_data;
 	u32 cr5_data;
 	u32 cr6_data;
@@ -227,21 +224,21 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *,
 static int uli526x_stop(struct net_device *);
 static void uli526x_set_filter_mode(struct net_device *);
 static const struct ethtool_ops netdev_ethtool_ops;
-static u16 read_srom_word(long, int);
+static u16 read_srom_word(struct uli526x_board_info *, int);
 static irqreturn_t uli526x_interrupt(int, void *);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void uli526x_poll(struct net_device *dev);
 #endif
-static void uli526x_descriptor_init(struct net_device *, unsigned long);
+static void uli526x_descriptor_init(struct net_device *, void __iomem *);
 static void allocate_rx_buffer(struct net_device *);
-static void update_cr6(u32, unsigned long);
+static void update_cr6(u32, void __iomem *);
 static void send_filter_frame(struct net_device *, int);
-static u16 phy_read(unsigned long, u8, u8, u32);
-static u16 phy_readby_cr10(unsigned long, u8, u8);
-static void phy_write(unsigned long, u8, u8, u16, u32);
-static void phy_writeby_cr10(unsigned long, u8, u8, u16);
-static void phy_write_1bit(unsigned long, u32, u32);
-static u16 phy_read_1bit(unsigned long, u32);
+static u16 phy_readby_cr9(struct uli526x_board_info *, u8, u8);
+static u16 phy_readby_cr10(struct uli526x_board_info *, u8, u8);
+static void phy_writeby_cr9(struct uli526x_board_info *, u8, u8, u16);
+static void phy_writeby_cr10(struct uli526x_board_info *, u8, u8, u16);
+static void phy_write_1bit(struct uli526x_board_info *db, u32);
+static u16 phy_read_1bit(struct uli526x_board_info *db);
 static u8 uli526x_sense_speed(struct uli526x_board_info *);
 static void uli526x_process_mode(struct uli526x_board_info *);
 static void uli526x_timer(unsigned long);
@@ -253,6 +250,18 @@ static void uli526x_free_rxbuffer(struct uli526x_board_info *);
 static void uli526x_init(struct net_device *);
 static void uli526x_set_phyxcer(struct uli526x_board_info *);
 
+static void srom_clk_write(struct uli526x_board_info *db, u32 data)
+{
+	void __iomem *ioaddr = db->ioaddr;
+
+	uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS);
+	udelay(5);
+	uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS | CR9_SRCLK);
+	udelay(5);
+	uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS);
+	udelay(5);
+}
+
 /* ULI526X network board routine ---------------------------- */
 
 static const struct net_device_ops netdev_ops = {
@@ -277,6 +286,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 {
 	struct uli526x_board_info *db;	/* board information structure */
 	struct net_device *dev;
+	void __iomem *ioaddr;
 	int i, err;
 
 	ULI526X_DBUG(0, "uli526x_init_one()", 0);
@@ -338,14 +348,26 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	db->buf_pool_start = db->buf_pool_ptr;
 	db->buf_pool_dma_start = db->buf_pool_dma_ptr;
 
-	db->chip_id = ent->driver_data;
-	db->ioaddr = pci_resource_start(pdev, 0);
+	switch (ent->driver_data) {
+	case PCI_ULI5263_ID:
+		db->phy.write	= phy_writeby_cr10;
+		db->phy.read	= phy_readby_cr10;
+		break;
+	default:
+		db->phy.write	= phy_writeby_cr9;
+		db->phy.read	= phy_readby_cr9;
+		break;
+	}
 
+	/* IO region. */
+	ioaddr = pci_iomap(pdev, 0, 0);
+	if (!ioaddr)
+		goto err_out_free_tx_buf;
+
+	db->ioaddr = ioaddr;
 	db->pdev = pdev;
 	db->init = 1;
 
-	dev->base_addr = db->ioaddr;
-	dev->irq = pdev->irq;
 	pci_set_drvdata(pdev, dev);
 
 	/* Register some necessary functions */
@@ -357,24 +379,24 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 
 	/* read 64 word srom data */
 	for (i = 0; i < 64; i++)
-		((__le16 *) db->srom)[i] = cpu_to_le16(read_srom_word(db->ioaddr, i));
+		((__le16 *) db->srom)[i] = cpu_to_le16(read_srom_word(db, i));
 
 	/* Set Node address */
 	if(((u16 *) db->srom)[0] == 0xffff || ((u16 *) db->srom)[0] == 0)		/* SROM absent, so read MAC address from ID Table */
 	{
-		outl(0x10000, db->ioaddr + DCR0);	//Diagnosis mode
-		outl(0x1c0, db->ioaddr + DCR13);	//Reset dianostic pointer port
-		outl(0, db->ioaddr + DCR14);		//Clear reset port
-		outl(0x10, db->ioaddr + DCR14);		//Reset ID Table pointer
-		outl(0, db->ioaddr + DCR14);		//Clear reset port
-		outl(0, db->ioaddr + DCR13);		//Clear CR13
-		outl(0x1b0, db->ioaddr + DCR13);	//Select ID Table access port
+		uw32(DCR0, 0x10000);	//Diagnosis mode
+		uw32(DCR13, 0x1c0);	//Reset dianostic pointer port
+		uw32(DCR14, 0);		//Clear reset port
+		uw32(DCR14, 0x10);	//Reset ID Table pointer
+		uw32(DCR14, 0);		//Clear reset port
+		uw32(DCR13, 0);		//Clear CR13
+		uw32(DCR13, 0x1b0);	//Select ID Table access port
 		//Read MAC address from CR14
 		for (i = 0; i < 6; i++)
-			dev->dev_addr[i] = inl(db->ioaddr + DCR14);
+			dev->dev_addr[i] = ur32(DCR14);
 		//Read end
-		outl(0, db->ioaddr + DCR13);	//Clear CR13
-		outl(0, db->ioaddr + DCR0);		//Clear CR0
+		uw32(DCR13, 0);		//Clear CR13
+		uw32(DCR0, 0);		//Clear CR0
 		udelay(10);
 	}
 	else		/*Exist SROM*/
@@ -384,16 +406,18 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	}
 	err = register_netdev (dev);
 	if (err)
-		goto err_out_free_tx_buf;
+		goto err_out_unmap;
 
 	netdev_info(dev, "ULi M%04lx at pci%s, %pM, irq %d\n",
 		    ent->driver_data >> 16, pci_name(pdev),
-		    dev->dev_addr, dev->irq);
+		    dev->dev_addr, pdev->irq);
 
 	pci_set_master(pdev);
 
 	return 0;
 
+err_out_unmap:
+	pci_iounmap(pdev, db->ioaddr);
 err_out_free_tx_buf:
 	pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
 			    db->buf_pool_ptr, db->buf_pool_dma_ptr);
@@ -418,6 +442,7 @@ static void __devexit uli526x_remove_one (struct pci_dev *pdev)
 	struct uli526x_board_info *db = netdev_priv(dev);
 
 	unregister_netdev(dev);
+	pci_iounmap(pdev, db->ioaddr);
 	pci_free_consistent(db->pdev, sizeof(struct tx_desc) *
 				DESC_ALL_CNT + 0x20, db->desc_pool_ptr,
  				db->desc_pool_dma_ptr);
@@ -460,7 +485,8 @@ static int uli526x_open(struct net_device *dev)
 	/* Initialize ULI526X board */
 	uli526x_init(dev);
 
-	ret = request_irq(dev->irq, uli526x_interrupt, IRQF_SHARED, dev->name, dev);
+	ret = request_irq(db->pdev->irq, uli526x_interrupt, IRQF_SHARED,
+			  dev->name, dev);
 	if (ret)
 		return ret;
 
@@ -488,57 +514,57 @@ static int uli526x_open(struct net_device *dev)
 static void uli526x_init(struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = db->ioaddr;
+	struct uli_phy_ops *phy = &db->phy;
+	void __iomem *ioaddr = db->ioaddr;
 	u8	phy_tmp;
 	u8	timeout;
-	u16	phy_value;
 	u16 phy_reg_reset;
 
 
 	ULI526X_DBUG(0, "uli526x_init()", 0);
 
 	/* Reset M526x MAC controller */
-	outl(ULI526X_RESET, ioaddr + DCR0);	/* RESET MAC */
+	uw32(DCR0, ULI526X_RESET);	/* RESET MAC */
 	udelay(100);
-	outl(db->cr0_data, ioaddr + DCR0);
+	uw32(DCR0, db->cr0_data);
 	udelay(5);
 
 	/* Phy addr : In some boards,M5261/M5263 phy address != 1 */
 	db->phy_addr = 1;
-	for(phy_tmp=0;phy_tmp<32;phy_tmp++)
-	{
-		phy_value=phy_read(db->ioaddr,phy_tmp,3,db->chip_id);//peer add
-		if(phy_value != 0xffff&&phy_value!=0)
-		{
+	for (phy_tmp = 0; phy_tmp < 32; phy_tmp++) {
+		u16 phy_value;
+
+		phy_value = phy->read(db, phy_tmp, 3);	//peer add
+		if (phy_value != 0xffff && phy_value != 0) {
 			db->phy_addr = phy_tmp;
 			break;
 		}
 	}
-	if(phy_tmp == 32)
+
+	if (phy_tmp == 32)
 		pr_warn("Can not find the phy address!!!\n");
 	/* Parser SROM and media mode */
 	db->media_mode = uli526x_media_mode;
 
 	/* phyxcer capability setting */
-	phy_reg_reset = phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id);
+	phy_reg_reset = phy->read(db, db->phy_addr, 0);
 	phy_reg_reset = (phy_reg_reset | 0x8000);
-	phy_write(db->ioaddr, db->phy_addr, 0, phy_reg_reset, db->chip_id);
+	phy->write(db, db->phy_addr, 0, phy_reg_reset);
 
 	/* See IEEE 802.3-2002.pdf (Section 2, Chapter "22.2.4 Management
 	 * functions") or phy data sheet for details on phy reset
 	 */
 	udelay(500);
 	timeout = 10;
-	while (timeout-- &&
-		phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id) & 0x8000)
-			udelay(100);
+	while (timeout-- && phy->read(db, db->phy_addr, 0) & 0x8000)
+		udelay(100);
 
 	/* Process Phyxcer Media Mode */
 	uli526x_set_phyxcer(db);
 
 	/* Media Mode Process */
 	if ( !(db->media_mode & ULI526X_AUTO) )
-		db->op_mode = db->media_mode; 	/* Force Mode */
+		db->op_mode = db->media_mode;		/* Force Mode */
 
 	/* Initialize Transmit/Receive decriptor and CR3/4 */
 	uli526x_descriptor_init(dev, ioaddr);
@@ -551,10 +577,10 @@ static void uli526x_init(struct net_device *dev)
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
-	outl(db->cr7_data, ioaddr + DCR7);
+	uw32(DCR7, db->cr7_data);
 
 	/* Init CR15, Tx jabber and Rx watchdog timer */
-	outl(db->cr15_data, ioaddr + DCR15);
+	uw32(DCR15, db->cr15_data);
 
 	/* Enable ULI526X Tx/Rx function */
 	db->cr6_data |= CR6_RXSC | CR6_TXSC;
@@ -571,6 +597,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 	struct tx_desc *txptr;
 	unsigned long flags;
 
@@ -596,7 +623,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	}
 
 	/* Disable NIC interrupt */
-	outl(0, dev->base_addr + DCR7);
+	uw32(DCR7, 0);
 
 	/* transmit this packet */
 	txptr = db->tx_insert_ptr;
@@ -607,10 +634,10 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	db->tx_insert_ptr = txptr->next_tx_desc;
 
 	/* Transmit Packet Process */
-	if ( (db->tx_packet_cnt < TX_DESC_CNT) ) {
+	if (db->tx_packet_cnt < TX_DESC_CNT) {
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
-		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
+		uw32(DCR1, 0x1);			/* Issue Tx polling */
 		dev->trans_start = jiffies;		/* saved time stamp */
 	}
 
@@ -620,7 +647,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 
 	/* Restore CR7 to enable interrupt */
 	spin_unlock_irqrestore(&db->lock, flags);
-	outl(db->cr7_data, dev->base_addr + DCR7);
+	uw32(DCR7, db->cr7_data);
 
 	/* free this SKB */
 	dev_kfree_skb(skb);
@@ -637,9 +664,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 static int uli526x_stop(struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
-
-	ULI526X_DBUG(0, "uli526x_stop", 0);
+	void __iomem *ioaddr = db->ioaddr;
 
 	/* disable system */
 	netif_stop_queue(dev);
@@ -648,12 +673,12 @@ static int uli526x_stop(struct net_device *dev)
 	del_timer_sync(&db->timer);
 
 	/* Reset & stop ULI526X board */
-	outl(ULI526X_RESET, ioaddr + DCR0);
+	uw32(DCR0, ULI526X_RESET);
 	udelay(5);
-	phy_write(db->ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
+	db->phy.write(db, db->phy_addr, 0, 0x8000);
 
 	/* free interrupt */
-	free_irq(dev->irq, dev);
+	free_irq(db->pdev->irq, dev);
 
 	/* free allocated rx buffer */
 	uli526x_free_rxbuffer(db);
@@ -671,18 +696,18 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct uli526x_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = db->ioaddr;
 	unsigned long flags;
 
 	spin_lock_irqsave(&db->lock, flags);
-	outl(0, ioaddr + DCR7);
+	uw32(DCR7, 0);
 
 	/* Got ULI526X status */
-	db->cr5_data = inl(ioaddr + DCR5);
-	outl(db->cr5_data, ioaddr + DCR5);
+	db->cr5_data = ur32(DCR5);
+	uw32(DCR5, db->cr5_data);
 	if ( !(db->cr5_data & 0x180c1) ) {
 		/* Restore CR7 to enable interrupt mask */
-		outl(db->cr7_data, ioaddr + DCR7);
+		uw32(DCR7, db->cr7_data);
 		spin_unlock_irqrestore(&db->lock, flags);
 		return IRQ_HANDLED;
 	}
@@ -710,7 +735,7 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 		uli526x_free_tx_pkt(dev, db);
 
 	/* Restore CR7 to enable interrupt mask */
-	outl(db->cr7_data, ioaddr + DCR7);
+	uw32(DCR7, db->cr7_data);
 
 	spin_unlock_irqrestore(&db->lock, flags);
 	return IRQ_HANDLED;
@@ -719,8 +744,10 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void uli526x_poll(struct net_device *dev)
 {
+	struct uli526x_board_info *db = netdev_priv(dev);
+
 	/* ISR grabs the irqsave lock, so this should be safe */
-	uli526x_interrupt(dev->irq, dev);
+	uli526x_interrupt(db->pdev->irq, dev);
 }
 #endif
 
@@ -954,12 +981,7 @@ static void netdev_get_drvinfo(struct net_device *dev,
 
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
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd) {
@@ -999,18 +1021,20 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 
 static void uli526x_timer(unsigned long data)
 {
-	u32 tmp_cr8;
-	unsigned char tmp_cr12=0;
 	struct net_device *dev = (struct net_device *) data;
 	struct uli526x_board_info *db = netdev_priv(dev);
+	struct uli_phy_ops *phy = &db->phy;
+	void __iomem *ioaddr = db->ioaddr;
  	unsigned long flags;
+	u8 tmp_cr12 = 0;
+	u32 tmp_cr8;
 
 	//ULI526X_DBUG(0, "uli526x_timer()", 0);
 	spin_lock_irqsave(&db->lock, flags);
 
 
 	/* Dynamic reset ULI526X : system error or transmit time-out */
-	tmp_cr8 = inl(db->ioaddr + DCR8);
+	tmp_cr8 = ur32(DCR8);
 	if ( (db->interval_rx_cnt==0) && (tmp_cr8) ) {
 		db->reset_cr8++;
 		db->wait_reset = 1;
@@ -1020,7 +1044,7 @@ static void uli526x_timer(unsigned long data)
 	/* TX polling kick monitor */
 	if ( db->tx_packet_cnt &&
 	     time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_KICK) ) {
-		outl(0x1, dev->base_addr + DCR1);   // Tx polling again
+		uw32(DCR1, 0x1);   // Tx polling again
 
 		// TX Timeout
 		if ( time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_TIMEOUT) ) {
@@ -1041,7 +1065,7 @@ static void uli526x_timer(unsigned long data)
 	}
 
 	/* Link status check, Dynamic media type change */
-	if((phy_read(db->ioaddr, db->phy_addr, 5, db->chip_id) & 0x01e0)!=0)
+	if ((phy->read(db, db->phy_addr, 5) & 0x01e0)!=0)
 		tmp_cr12 = 3;
 
 	if ( !(tmp_cr12 & 0x3) && !db->link_failed ) {
@@ -1054,7 +1078,7 @@ static void uli526x_timer(unsigned long data)
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO don't need */
 		if ( !(db->media_mode & 0x8) )
-			phy_write(db->ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
+			phy->write(db, db->phy_addr, 0, 0x1000);
 
 		/* AUTO mode, if INT phyxcer link failed, select EXT device */
 		if (db->media_mode & ULI526X_AUTO) {
@@ -1111,12 +1135,13 @@ static void uli526x_timer(unsigned long data)
 static void uli526x_reset_prepare(struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 
 	/* Sopt MAC controller */
 	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);	/* Disable Tx/Rx */
-	update_cr6(db->cr6_data, dev->base_addr);
-	outl(0, dev->base_addr + DCR7);		/* Disable Interrupt */
-	outl(inl(dev->base_addr + DCR5), dev->base_addr + DCR5);
+	update_cr6(db->cr6_data, ioaddr);
+	uw32(DCR7, 0);				/* Disable Interrupt */
+	uw32(DCR5, ur32(DCR5));
 
 	/* Disable upper layer interface */
 	netif_stop_queue(dev);
@@ -1281,7 +1306,7 @@ static void uli526x_reuse_skb(struct uli526x_board_info *db, struct sk_buff * sk
  *	Using Chain structure, and allocate Tx/Rx buffer
  */
 
-static void uli526x_descriptor_init(struct net_device *dev, unsigned long ioaddr)
+static void uli526x_descriptor_init(struct net_device *dev, void __iomem *ioaddr)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
 	struct tx_desc *tmp_tx;
@@ -1296,14 +1321,14 @@ static void uli526x_descriptor_init(struct net_device *dev, unsigned long ioaddr
 	/* tx descriptor start pointer */
 	db->tx_insert_ptr = db->first_tx_desc;
 	db->tx_remove_ptr = db->first_tx_desc;
-	outl(db->first_tx_desc_dma, ioaddr + DCR4);     /* TX DESC address */
+	uw32(DCR4, db->first_tx_desc_dma);	/* TX DESC address */
 
 	/* rx descriptor start pointer */
 	db->first_rx_desc = (void *)db->first_tx_desc + sizeof(struct tx_desc) * TX_DESC_CNT;
 	db->first_rx_desc_dma =  db->first_tx_desc_dma + sizeof(struct tx_desc) * TX_DESC_CNT;
 	db->rx_insert_ptr = db->first_rx_desc;
 	db->rx_ready_ptr = db->first_rx_desc;
-	outl(db->first_rx_desc_dma, ioaddr + DCR3);	/* RX DESC address */
+	uw32(DCR3, db->first_rx_desc_dma);	/* RX DESC address */
 
 	/* Init Transmit chain */
 	tmp_buf = db->buf_pool_start;
@@ -1344,11 +1369,9 @@ static void uli526x_descriptor_init(struct net_device *dev, unsigned long ioaddr
  *	Update CR6 value
  *	Firstly stop ULI526X, then written value and start
  */
-
-static void update_cr6(u32 cr6_data, unsigned long ioaddr)
+static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
 {
-
-	outl(cr6_data, ioaddr + DCR6);
+	uw32(DCR6, cr6_data);
 	udelay(5);
 }
 
@@ -1367,6 +1390,7 @@ static void update_cr6(u32 cr6_data, unsigned long ioaddr)
 static void send_filter_frame(struct net_device *dev, int mc_cnt)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 	struct netdev_hw_addr *ha;
 	struct tx_desc *txptr;
 	u16 * addrptr;
@@ -1412,9 +1436,9 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 		/* Resource Empty */
 		db->tx_packet_cnt++;
 		txptr->tdes0 = cpu_to_le32(0x80000000);
-		update_cr6(db->cr6_data | 0x2000, dev->base_addr);
-		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
-		update_cr6(db->cr6_data, dev->base_addr);
+		update_cr6(db->cr6_data | 0x2000, ioaddr);
+		uw32(DCR1, 0x1);	/* Issue Tx polling */
+		update_cr6(db->cr6_data, ioaddr);
 		dev->trans_start = jiffies;
 	} else
 		netdev_err(dev, "No Tx resource - Send_filter_frame!\n");
@@ -1457,37 +1481,38 @@ static void allocate_rx_buffer(struct net_device *dev)
  *	Read one word data from the serial ROM
  */
 
-static u16 read_srom_word(long ioaddr, int offset)
+static u16 read_srom_word(struct uli526x_board_info *db, int offset)
 {
-	int i;
+	void __iomem *ioaddr = db->ioaddr;
 	u16 srom_data = 0;
-	long cr9_ioaddr = ioaddr + DCR9;
+	int i;
 
-	outl(CR9_SROM_READ, cr9_ioaddr);
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+	uw32(DCR9, CR9_SROM_READ);
+	uw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 
 	/* Send the Read Command 110b */
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_0, cr9_ioaddr);
+	srom_clk_write(db, SROM_DATA_1);
+	srom_clk_write(db, SROM_DATA_1);
+	srom_clk_write(db, SROM_DATA_0);
 
 	/* Send the offset */
 	for (i = 5; i >= 0; i--) {
 		srom_data = (offset & (1 << i)) ? SROM_DATA_1 : SROM_DATA_0;
-		SROM_CLK_WRITE(srom_data, cr9_ioaddr);
+		srom_clk_write(db, srom_data);
 	}
 
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+	uw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 
 	for (i = 16; i > 0; i--) {
-		outl(CR9_SROM_READ | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
+		uw32(DCR9, CR9_SROM_READ | CR9_SRCS | CR9_SRCLK);
 		udelay(5);
-		srom_data = (srom_data << 1) | ((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
-		outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+		srom_data = (srom_data << 1) |
+			    ((ur32(DCR9) & CR9_CRDOUT) ? 1 : 0);
+		uw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 		udelay(5);
 	}
 
-	outl(CR9_SROM_READ, cr9_ioaddr);
+	uw32(DCR9, CR9_SROM_READ);
 	return srom_data;
 }
 
@@ -1498,15 +1523,16 @@ static u16 read_srom_word(long ioaddr, int offset)
 
 static u8 uli526x_sense_speed(struct uli526x_board_info * db)
 {
+	struct uli_phy_ops *phy = &db->phy;
 	u8 ErrFlag = 0;
 	u16 phy_mode;
 
-	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
-	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
+	phy_mode = phy->read(db, db->phy_addr, 1);
+	phy_mode = phy->read(db, db->phy_addr, 1);
 
 	if ( (phy_mode & 0x24) == 0x24 ) {
 
-		phy_mode = ((phy_read(db->ioaddr, db->phy_addr, 5, db->chip_id) & 0x01e0)<<7);
+		phy_mode = ((phy->read(db, db->phy_addr, 5) & 0x01e0)<<7);
 		if(phy_mode&0x8000)
 			phy_mode = 0x8000;
 		else if(phy_mode&0x4000)
@@ -1541,10 +1567,11 @@ static u8 uli526x_sense_speed(struct uli526x_board_info * db)
 
 static void uli526x_set_phyxcer(struct uli526x_board_info *db)
 {
+	struct uli_phy_ops *phy = &db->phy;
 	u16 phy_reg;
 
 	/* Phyxcer capability setting */
-	phy_reg = phy_read(db->ioaddr, db->phy_addr, 4, db->chip_id) & ~0x01e0;
+	phy_reg = phy->read(db, db->phy_addr, 4) & ~0x01e0;
 
 	if (db->media_mode & ULI526X_AUTO) {
 		/* AUTO Mode */
@@ -1565,10 +1592,10 @@ static void uli526x_set_phyxcer(struct uli526x_board_info *db)
 		phy_reg|=db->PHY_reg4;
 		db->media_mode|=ULI526X_AUTO;
 	}
-	phy_write(db->ioaddr, db->phy_addr, 4, phy_reg, db->chip_id);
+	phy->write(db, db->phy_addr, 4, phy_reg);
 
  	/* Restart Auto-Negotiation */
-	phy_write(db->ioaddr, db->phy_addr, 0, 0x1200, db->chip_id);
+	phy->write(db, db->phy_addr, 0, 0x1200);
 	udelay(50);
 }
 
@@ -1582,6 +1609,7 @@ static void uli526x_set_phyxcer(struct uli526x_board_info *db)
 
 static void uli526x_process_mode(struct uli526x_board_info *db)
 {
+	struct uli_phy_ops *phy = &db->phy;
 	u16 phy_reg;
 
 	/* Full Duplex Mode Check */
@@ -1593,10 +1621,10 @@ static void uli526x_process_mode(struct uli526x_board_info *db)
 	update_cr6(db->cr6_data, db->ioaddr);
 
 	/* 10/100M phyxcer force mode need */
-	if ( !(db->media_mode & 0x8)) {
+	if (!(db->media_mode & 0x8)) {
 		/* Forece Mode */
-		phy_reg = phy_read(db->ioaddr, db->phy_addr, 6, db->chip_id);
-		if ( !(phy_reg & 0x1) ) {
+		phy_reg = phy->read(db, db->phy_addr, 6);
+		if (!(phy_reg & 0x1)) {
 			/* parter without N-Way capability */
 			phy_reg = 0x0;
 			switch(db->op_mode) {
@@ -1605,148 +1633,126 @@ static void uli526x_process_mode(struct uli526x_board_info *db)
 			case ULI526X_100MHF: phy_reg = 0x2000; break;
 			case ULI526X_100MFD: phy_reg = 0x2100; break;
 			}
-			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
+			phy->write(db, db->phy_addr, 0, phy_reg);
 		}
 	}
 }
 
 
-/*
- *	Write a word to Phy register
- */
-
-static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data, u32 chip_id)
+/* M5261/M5263 Chip */
+static void phy_writeby_cr9(struct uli526x_board_info *db, u8 phy_addr,
+			    u8 offset, u16 phy_data)
 {
 	u16 i;
-	unsigned long ioaddr;
-
-	if(chip_id == PCI_ULI5263_ID)
-	{
-		phy_writeby_cr10(iobase, phy_addr, offset, phy_data);
-		return;
-	}
-	/* M5261/M5263 Chip */
-	ioaddr = iobase + DCR9;
 
 	/* Send 33 synchronization clock to Phy controller */
 	for (i = 0; i < 35; i++)
-		phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+		phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send start command(01) to Phy */
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+	phy_write_1bit(db, PHY_DATA_0);
+	phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send write command(01) to Phy */
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+	phy_write_1bit(db, PHY_DATA_0);
+	phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send Phy address */
 	for (i = 0x10; i > 0; i = i >> 1)
-		phy_write_1bit(ioaddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
+		phy_write_1bit(db, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
 
 	/* Send register address */
 	for (i = 0x10; i > 0; i = i >> 1)
-		phy_write_1bit(ioaddr, offset & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
+		phy_write_1bit(db, offset & i ? PHY_DATA_1 : PHY_DATA_0);
 
 	/* written trasnition */
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
+	phy_write_1bit(db, PHY_DATA_1);
+	phy_write_1bit(db, PHY_DATA_0);
 
 	/* Write a word data to PHY controller */
-	for ( i = 0x8000; i > 0; i >>= 1)
-		phy_write_1bit(ioaddr, phy_data & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
-
+	for (i = 0x8000; i > 0; i >>= 1)
+		phy_write_1bit(db, phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
 }
 
-
-/*
- *	Read a word data from phy register
- */
-
-static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
+static u16 phy_readby_cr9(struct uli526x_board_info *db, u8 phy_addr, u8 offset)
 {
-	int i;
 	u16 phy_data;
-	unsigned long ioaddr;
-
-	if(chip_id == PCI_ULI5263_ID)
-		return phy_readby_cr10(iobase, phy_addr, offset);
-	/* M5261/M5263 Chip */
-	ioaddr = iobase + DCR9;
+	int i;
 
 	/* Send 33 synchronization clock to Phy controller */
 	for (i = 0; i < 35; i++)
-		phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+		phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send start command(01) to Phy */
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+	phy_write_1bit(db, PHY_DATA_0);
+	phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send read command(10) to Phy */
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
+	phy_write_1bit(db, PHY_DATA_1);
+	phy_write_1bit(db, PHY_DATA_0);
 
 	/* Send Phy address */
 	for (i = 0x10; i > 0; i = i >> 1)
-		phy_write_1bit(ioaddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
+		phy_write_1bit(db, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
 
 	/* Send register address */
 	for (i = 0x10; i > 0; i = i >> 1)
-		phy_write_1bit(ioaddr, offset & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
+		phy_write_1bit(db, offset & i ? PHY_DATA_1 : PHY_DATA_0);
 
 	/* Skip transition state */
-	phy_read_1bit(ioaddr, chip_id);
+	phy_read_1bit(db);
 
 	/* read 16bit data */
 	for (phy_data = 0, i = 0; i < 16; i++) {
 		phy_data <<= 1;
-		phy_data |= phy_read_1bit(ioaddr, chip_id);
+		phy_data |= phy_read_1bit(db);
 	}
 
 	return phy_data;
 }
 
-static u16 phy_readby_cr10(unsigned long iobase, u8 phy_addr, u8 offset)
+static u16 phy_readby_cr10(struct uli526x_board_info *db, u8 phy_addr,
+			   u8 offset)
 {
-	unsigned long ioaddr,cr10_value;
+	void __iomem *ioaddr = db->ioaddr;
+	u32 cr10_value = phy_addr;
 
-	ioaddr = iobase + DCR10;
-	cr10_value = phy_addr;
-	cr10_value = (cr10_value<<5) + offset;
-	cr10_value = (cr10_value<<16) + 0x08000000;
-	outl(cr10_value,ioaddr);
+	cr10_value = (cr10_value <<  5) + offset;
+	cr10_value = (cr10_value << 16) + 0x08000000;
+	uw32(DCR10, cr10_value);
 	udelay(1);
-	while(1)
-	{
-		cr10_value = inl(ioaddr);
-		if(cr10_value&0x10000000)
+	while (1) {
+		cr10_value = ur32(DCR10);
+		if (cr10_value & 0x10000000)
 			break;
 	}
 	return cr10_value & 0x0ffff;
 }
 
-static void phy_writeby_cr10(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data)
+static void phy_writeby_cr10(struct uli526x_board_info *db, u8 phy_addr,
+			     u8 offset, u16 phy_data)
 {
-	unsigned long ioaddr,cr10_value;
+	void __iomem *ioaddr = db->ioaddr;
+	u32 cr10_value = phy_addr;
 
-	ioaddr = iobase + DCR10;
-	cr10_value = phy_addr;
-	cr10_value = (cr10_value<<5) + offset;
-	cr10_value = (cr10_value<<16) + 0x04000000 + phy_data;
-	outl(cr10_value,ioaddr);
+	cr10_value = (cr10_value <<  5) + offset;
+	cr10_value = (cr10_value << 16) + 0x04000000 + phy_data;
+	uw32(DCR10, cr10_value);
 	udelay(1);
 }
 /*
  *	Write one bit data to Phy Controller
  */
 
-static void phy_write_1bit(unsigned long ioaddr, u32 phy_data, u32 chip_id)
+static void phy_write_1bit(struct uli526x_board_info *db, u32 data)
 {
-	outl(phy_data , ioaddr);			/* MII Clock Low */
+	void __iomem *ioaddr = db->ioaddr;
+
+	uw32(DCR9, data);		/* MII Clock Low */
 	udelay(1);
-	outl(phy_data  | MDCLKH, ioaddr);	/* MII Clock High */
+	uw32(DCR9, data | MDCLKH);	/* MII Clock High */
 	udelay(1);
-	outl(phy_data , ioaddr);			/* MII Clock Low */
+	uw32(DCR9, data);		/* MII Clock Low */
 	udelay(1);
 }
 
@@ -1755,14 +1761,15 @@ static void phy_write_1bit(unsigned long ioaddr, u32 phy_data, u32 chip_id)
  *	Read one bit phy data from PHY controller
  */
 
-static u16 phy_read_1bit(unsigned long ioaddr, u32 chip_id)
+static u16 phy_read_1bit(struct uli526x_board_info *db)
 {
+	void __iomem *ioaddr = db->ioaddr;
 	u16 phy_data;
 
-	outl(0x50000 , ioaddr);
+	uw32(DCR9, 0x50000);
 	udelay(1);
-	phy_data = ( inl(ioaddr) >> 19 ) & 0x1;
-	outl(0x40000 , ioaddr);
+	phy_data = (ur32(DCR9) >> 19) & 0x1;
+	uw32(DCR9, 0x40000);
 	udelay(1);
 
 	return phy_data;
-- 
1.7.7.6
