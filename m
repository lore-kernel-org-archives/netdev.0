From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 31/34] uli526x: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Thu, 15 Mar 2012 14:57:28 +0100
Message-ID: <01b3ae027e23d903f38da93ebc9e6c0d18c940a3.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51893 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761251Ab2CON74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:56 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/uli526x.c |  138 ++++++++++++++++--------------
 1 files changed, 73 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index c9b3396..2035791 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -42,6 +42,8 @@
 #include <asm/dma.h>
 #include <asm/uaccess.h>
 
+#define outl	iowrite32
+#define inl	ioread32
 
 /* Board/System/Debug information/definition ---------------- */
 #define PCI_ULI5261_ID  0x526110B9	/* ULi M5261 ID*/
@@ -137,7 +139,7 @@ struct uli526x_board_info {
 	struct pci_dev *pdev;		/* PCI device */
 	spinlock_t lock;
 
-	long ioaddr;			/* I/O base address */
+	void __iomem *ioaddr;		/* I/O base address */
 	u32 cr0_data;
 	u32 cr5_data;
 	u32 cr6_data;
@@ -227,21 +229,21 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *,
 static int uli526x_stop(struct net_device *);
 static void uli526x_set_filter_mode(struct net_device *);
 static const struct ethtool_ops netdev_ethtool_ops;
-static u16 read_srom_word(long, int);
+static u16 read_srom_word(void __iomem *, int);
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
+static u16 phy_read(void __iomem *, u8, u8, u32);
+static u16 phy_readby_cr10(void __iomem *, u8, u8);
+static void phy_write(void __iomem *, u8, u8, u16, u32);
+static void phy_writeby_cr10(void __iomem *, u8, u8, u16);
+static void phy_write_1bit(void __iomem *, u32, u32);
+static u16 phy_read_1bit(void __iomem *, u32);
 static u8 uli526x_sense_speed(struct uli526x_board_info *);
 static void uli526x_process_mode(struct uli526x_board_info *);
 static void uli526x_timer(unsigned long);
@@ -339,13 +341,15 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	db->buf_pool_dma_start = db->buf_pool_dma_ptr;
 
 	db->chip_id = ent->driver_data;
-	db->ioaddr = pci_resource_start(pdev, 0);
+
+	/* IO region. */
+	db->ioaddr = pci_iomap(pdev, 0, 0);
+	if (!db->ioaddr)
+		goto err_out_free_tx_buf;
 
 	db->pdev = pdev;
 	db->init = 1;
 
-	dev->base_addr = db->ioaddr;
-	dev->irq = pdev->irq;
 	pci_set_drvdata(pdev, dev);
 
 	/* Register some necessary functions */
@@ -384,16 +388,18 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
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
@@ -418,6 +424,7 @@ static void __devexit uli526x_remove_one (struct pci_dev *pdev)
 	struct uli526x_board_info *db = netdev_priv(dev);
 
 	unregister_netdev(dev);
+	pci_iounmap(pdev, db->ioaddr);
 	pci_free_consistent(db->pdev, sizeof(struct tx_desc) *
 				DESC_ALL_CNT + 0x20, db->desc_pool_ptr,
  				db->desc_pool_dma_ptr);
@@ -460,7 +467,8 @@ static int uli526x_open(struct net_device *dev)
 	/* Initialize ULI526X board */
 	uli526x_init(dev);
 
-	ret = request_irq(dev->irq, uli526x_interrupt, IRQF_SHARED, dev->name, dev);
+	ret = request_irq(db->pdev->irq, uli526x_interrupt, IRQF_SHARED,
+			  dev->name, dev);
 	if (ret)
 		return ret;
 
@@ -488,7 +496,7 @@ static int uli526x_open(struct net_device *dev)
 static void uli526x_init(struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = db->ioaddr;
+	void __iomem *ioaddr = db->ioaddr;
 	u8	phy_tmp;
 	u8	timeout;
 	u16	phy_value;
@@ -571,6 +579,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 	struct tx_desc *txptr;
 	unsigned long flags;
 
@@ -596,7 +605,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	}
 
 	/* Disable NIC interrupt */
-	outl(0, dev->base_addr + DCR7);
+	outl(0, ioaddr + DCR7);
 
 	/* transmit this packet */
 	txptr = db->tx_insert_ptr;
@@ -610,7 +619,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	if ( (db->tx_packet_cnt < TX_DESC_CNT) ) {
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
-		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
+		outl(0x1, ioaddr + DCR1);	/* Issue Tx polling */
 		dev->trans_start = jiffies;		/* saved time stamp */
 	}
 
@@ -620,7 +629,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 
 	/* Restore CR7 to enable interrupt */
 	spin_unlock_irqrestore(&db->lock, flags);
-	outl(db->cr7_data, dev->base_addr + DCR7);
+	outl(db->cr7_data, ioaddr + DCR7);
 
 	/* free this SKB */
 	dev_kfree_skb(skb);
@@ -637,7 +646,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 static int uli526x_stop(struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = db->ioaddr;
 
 	ULI526X_DBUG(0, "uli526x_stop", 0);
 
@@ -653,7 +662,7 @@ static int uli526x_stop(struct net_device *dev)
 	phy_write(db->ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
 
 	/* free interrupt */
-	free_irq(dev->irq, dev);
+	free_irq(db->pdev->irq, dev);
 
 	/* free allocated rx buffer */
 	uli526x_free_rxbuffer(db);
@@ -671,7 +680,7 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct uli526x_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = db->ioaddr;
 	unsigned long flags;
 
 	spin_lock_irqsave(&db->lock, flags);
@@ -719,8 +728,10 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
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
 
@@ -954,12 +965,7 @@ static void netdev_get_drvinfo(struct net_device *dev,
 
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
@@ -1020,7 +1026,7 @@ static void uli526x_timer(unsigned long data)
 	/* TX polling kick monitor */
 	if ( db->tx_packet_cnt &&
 	     time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_KICK) ) {
-		outl(0x1, dev->base_addr + DCR1);   // Tx polling again
+		outl(0x1, db->ioaddr + DCR1);   // Tx polling again
 
 		// TX Timeout
 		if ( time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_TIMEOUT) ) {
@@ -1111,12 +1117,13 @@ static void uli526x_timer(unsigned long data)
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
+	outl(0, ioaddr + DCR7);		/* Disable Interrupt */
+	outl(inl(ioaddr + DCR5), ioaddr + DCR5);
 
 	/* Disable upper layer interface */
 	netif_stop_queue(dev);
@@ -1281,7 +1288,7 @@ static void uli526x_reuse_skb(struct uli526x_board_info *db, struct sk_buff * sk
  *	Using Chain structure, and allocate Tx/Rx buffer
  */
 
-static void uli526x_descriptor_init(struct net_device *dev, unsigned long ioaddr)
+static void uli526x_descriptor_init(struct net_device *dev, void __iomem *ioaddr)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
 	struct tx_desc *tmp_tx;
@@ -1345,7 +1352,7 @@ static void uli526x_descriptor_init(struct net_device *dev, unsigned long ioaddr
  *	Firstly stop ULI526X, then written value and start
  */
 
-static void update_cr6(u32 cr6_data, unsigned long ioaddr)
+static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
 {
 
 	outl(cr6_data, ioaddr + DCR6);
@@ -1367,6 +1374,7 @@ static void update_cr6(u32 cr6_data, unsigned long ioaddr)
 static void send_filter_frame(struct net_device *dev, int mc_cnt)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
+	void __iomem *ioaddr = db->ioaddr;
 	struct netdev_hw_addr *ha;
 	struct tx_desc *txptr;
 	u16 * addrptr;
@@ -1412,9 +1420,9 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 		/* Resource Empty */
 		db->tx_packet_cnt++;
 		txptr->tdes0 = cpu_to_le32(0x80000000);
-		update_cr6(db->cr6_data | 0x2000, dev->base_addr);
-		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
-		update_cr6(db->cr6_data, dev->base_addr);
+		update_cr6(db->cr6_data | 0x2000, ioaddr);
+		outl(0x1, ioaddr + DCR1);	/* Issue Tx polling */
+		update_cr6(db->cr6_data, ioaddr);
 		dev->trans_start = jiffies;
 	} else
 		netdev_err(dev, "No Tx resource - Send_filter_frame!\n");
@@ -1457,11 +1465,11 @@ static void allocate_rx_buffer(struct net_device *dev)
  *	Read one word data from the serial ROM
  */
 
-static u16 read_srom_word(long ioaddr, int offset)
+static u16 read_srom_word(void __iomem *ioaddr, int offset)
 {
-	int i;
+	void __iomem *cr9_ioaddr = ioaddr + DCR9;
 	u16 srom_data = 0;
-	long cr9_ioaddr = ioaddr + DCR9;
+	int i;
 
 	outl(CR9_SROM_READ, cr9_ioaddr);
 	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
@@ -1615,18 +1623,18 @@ static void uli526x_process_mode(struct uli526x_board_info *db)
  *	Write a word to Phy register
  */
 
-static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data, u32 chip_id)
+static void phy_write(void __iomem *iobase, u8 phy_addr, u8 offset,
+		      u16 phy_data, u32 chip_id)
 {
+	/* M5261/M5263 Chip */
+	void __iomem *ioaddr = iobase + DCR9;
 	u16 i;
-	unsigned long ioaddr;
 
 	if(chip_id == PCI_ULI5263_ID)
 	{
 		phy_writeby_cr10(iobase, phy_addr, offset, phy_data);
 		return;
 	}
-	/* M5261/M5263 Chip */
-	ioaddr = iobase + DCR9;
 
 	/* Send 33 synchronization clock to Phy controller */
 	for (i = 0; i < 35; i++)
@@ -1663,11 +1671,11 @@ static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data
  *	Read a word data from phy register
  */
 
-static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
+static u16 phy_read(void __iomem *iobase, u8 phy_addr, u8 offset, u32 chip_id)
 {
+	void __iomem *ioaddr;
 	int i;
 	u16 phy_data;
-	unsigned long ioaddr;
 
 	if(chip_id == PCI_ULI5263_ID)
 		return phy_readby_cr10(iobase, phy_addr, offset);
@@ -1706,41 +1714,41 @@ static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
 	return phy_data;
 }
 
-static u16 phy_readby_cr10(unsigned long iobase, u8 phy_addr, u8 offset)
+static u16 phy_readby_cr10(void __iomem *iobase, u8 phy_addr, u8 offset)
 {
-	unsigned long ioaddr,cr10_value;
+	void __iomem *ioaddr = iobase + DCR10;
+	u32 cr10_value;
 
-	ioaddr = iobase + DCR10;
 	cr10_value = phy_addr;
-	cr10_value = (cr10_value<<5) + offset;
-	cr10_value = (cr10_value<<16) + 0x08000000;
-	outl(cr10_value,ioaddr);
+	cr10_value = (cr10_value <<  5) + offset;
+	cr10_value = (cr10_value << 16) + 0x08000000;
+	outl(cr10_value, ioaddr);
 	udelay(1);
-	while(1)
-	{
+	while(1) {
 		cr10_value = inl(ioaddr);
-		if(cr10_value&0x10000000)
+		if (cr10_value & 0x10000000)
 			break;
 	}
 	return cr10_value & 0x0ffff;
 }
 
-static void phy_writeby_cr10(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data)
+static void phy_writeby_cr10(void __iomem *iobase, u8 phy_addr, u8 offset,
+			     u16 phy_data)
 {
-	unsigned long ioaddr,cr10_value;
+	void __iomem *ioaddr = iobase + DCR10;
+	u32 cr10_value;
 
-	ioaddr = iobase + DCR10;
 	cr10_value = phy_addr;
-	cr10_value = (cr10_value<<5) + offset;
-	cr10_value = (cr10_value<<16) + 0x04000000 + phy_data;
-	outl(cr10_value,ioaddr);
+	cr10_value = (cr10_value <<  5) + offset;
+	cr10_value = (cr10_value << 16) + 0x04000000 + phy_data;
+	outl(cr10_value, ioaddr);
 	udelay(1);
 }
 /*
  *	Write one bit data to Phy Controller
  */
 
-static void phy_write_1bit(unsigned long ioaddr, u32 phy_data, u32 chip_id)
+static void phy_write_1bit(void __iomem *ioaddr, u32 phy_data, u32 chip_id)
 {
 	outl(phy_data , ioaddr);			/* MII Clock Low */
 	udelay(1);
@@ -1755,7 +1763,7 @@ static void phy_write_1bit(unsigned long ioaddr, u32 phy_data, u32 chip_id)
  *	Read one bit phy data from PHY controller
  */
 
-static u16 phy_read_1bit(unsigned long ioaddr, u32 chip_id)
+static u16 phy_read_1bit(void __iomem *ioaddr, u32 chip_id)
 {
 	u16 phy_data;
 
-- 
1.7.7.6
