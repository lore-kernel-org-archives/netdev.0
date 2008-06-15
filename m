From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 3/9] DM9000: Cleanup source code
Date: Mon, 16 Jun 2008 00:26:56 +0100
Message-ID: <20080615232815.143590662@fluff.org.uk>
References: <20080615232653.642837440@fluff.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:54110 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756504AbYFOX2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 19:28:17 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-cleanups1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup bits of the DM9000 driver to make the code
neater and easier to read. This is includes removing
some old definitions, re-indenting areas, etc.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-15 22:52:31.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-15 23:14:39.000000000 +0100
@@ -44,9 +44,8 @@
 
 #define DM9000_PHY		0x40	/* PHY address 0x01 */
 
-#define CARDNAME "dm9000"
-#define PFX CARDNAME ": "
-#define DRV_VERSION	"1.30"
+#define CARDNAME	"dm9000"
+#define DRV_VERSION	"1.31"
 
 #ifdef CONFIG_BLACKFIN
 #define readsb	insb
@@ -98,22 +97,23 @@ enum dm9000_type {
 /* Structure/enum declaration ------------------------------- */
 typedef struct board_info {
 
-	void __iomem *io_addr;	/* Register I/O base address */
-	void __iomem *io_data;	/* Data I/O address */
-	u16 irq;		/* IRQ */
-
-	u16 tx_pkt_cnt;
-	u16 queue_pkt_len;
-	u16 queue_start_addr;
-	u16 dbug_cnt;
-	u8 io_mode;		/* 0:word, 2:byte */
-	u8 phy_addr;
-	u8 imr_all;
-	unsigned int flags;
-	unsigned int in_suspend :1;
+	void __iomem	*io_addr;	/* Register I/O base address */
+	void __iomem	*io_data;	/* Data I/O address */
+	u16		 irq;		/* IRQ */
+
+	u16		tx_pkt_cnt;
+	u16		queue_pkt_len;
+	u16		queue_start_addr;
+	u16		dbug_cnt;
+	u8		io_mode;		/* 0:word, 2:byte */
+	u8		phy_addr;
+	u8		imr_all;
+
+	unsigned int	flags;
+	unsigned int	in_suspend :1;
+	int		debug_level;
 
 	enum dm9000_type type;
-	int debug_level;
 
 	void (*inblk)(void __iomem *port, void *data, int length);
 	void (*outblk)(void __iomem *port, void *data, int length);
@@ -132,10 +132,10 @@ typedef struct board_info {
 	struct delayed_work phy_poll;
 	struct net_device  *ndev;
 
-	spinlock_t lock;
+	spinlock_t	lock;
 
 	struct mii_if_info mii;
-	u32 msg_enable;
+	u32		msg_enable;
 } board_info_t;
 
 /* debug code */
@@ -153,19 +153,16 @@ static inline board_info_t *to_dm9000_bo
 }
 
 /* function declaration ------------------------------------- */
-static int dm9000_probe(struct platform_device *);
 static int dm9000_open(struct net_device *);
 static int dm9000_start_xmit(struct sk_buff *, struct net_device *);
 static int dm9000_stop(struct net_device *);
-static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd);
 
 static void dm9000_init_dm9000(struct net_device *);
 
 static irqreturn_t dm9000_interrupt(int, void *);
 
-static int dm9000_phy_read(struct net_device *dev, int phyaddr_unsused, int reg);
-static void dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg,
-			   int value);
+static int dm9000_phy_read(struct net_device *dev, int phy, int reg);
+static void dm9000_phy_write(struct net_device *dev, int phy, int reg, int v);
 
 static void dm9000_read_eeprom(board_info_t *, int addr, u8 *to);
 static void dm9000_write_eeprom(board_info_t *, int addr, u8 *dp);
@@ -505,12 +502,6 @@ dm9000_poll_work(struct work_struct *w)
 static void
 dm9000_release_board(struct platform_device *pdev, struct board_info *db)
 {
-	if (db->data_res == NULL) {
-		if (db->addr_res != NULL)
-			release_mem_region((unsigned long)db->io_addr, 4);
-		return;
-	}
-
 	/* unmap our resources */
 
 	iounmap(db->io_addr);
@@ -518,15 +509,11 @@ dm9000_release_board(struct platform_dev
 
 	/* release the resources */
 
-	if (db->data_req != NULL) {
-		release_resource(db->data_req);
-		kfree(db->data_req);
-	}
+	release_resource(db->data_req);
+	kfree(db->data_req);
 
-	if (db->addr_req != NULL) {
-		release_resource(db->addr_req);
-		kfree(db->addr_req);
-	}
+	release_resource(db->addr_req);
+	kfree(db->addr_req);
 }
 
 static unsigned char dm9000_type_to_char(enum dm9000_type type)
@@ -580,12 +567,6 @@ dm9000_probe(struct platform_device *pde
 
 	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
 
-
-	if (pdev->num_resources < 2) {
-		ret = -ENODEV;
-		goto out;
-	}
-
 	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
@@ -671,7 +652,7 @@ dm9000_probe(struct platform_device *pde
 
 	dm9000_reset(db);
 
-	/* try two times, DM9000 sometimes gets the first read wrong */
+	/* try multiple times, DM9000 sometimes gets the read wrong */
 	for (i = 0; i < 8; i++) {
 		id_val  = ior(db, DM9000_VIDL);
 		id_val |= (u32)ior(db, DM9000_VIDH) << 8;
@@ -779,7 +760,7 @@ out:
 static int
 dm9000_open(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = dev->priv;
 	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
 
 	if (netif_msg_ifup(db))
@@ -819,7 +800,7 @@ dm9000_open(struct net_device *dev)
 static void
 dm9000_init_dm9000(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = dev->priv;
 	unsigned int imr;
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
@@ -870,7 +851,7 @@ static int
 dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = dev->priv;
 
 	dm9000_dbg(db, 3, "%s:\n", __func__);
 
@@ -913,7 +894,7 @@ dm9000_start_xmit(struct sk_buff *skb, s
 static void
 dm9000_shutdown(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = dev->priv;
 
 	/* RESET device */
 	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
@@ -929,7 +910,7 @@ dm9000_shutdown(struct net_device *dev)
 static int
 dm9000_stop(struct net_device *ndev)
 {
-	board_info_t *db = (board_info_t *) ndev->priv;
+	board_info_t *db = ndev->priv;
 
 	if (netif_msg_ifdown(db))
 		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
@@ -980,7 +961,7 @@ static irqreturn_t
 dm9000_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = dev->priv;
 	int int_status;
 	u8 reg_save;
 
@@ -1361,7 +1342,8 @@ dm9000_phy_read(struct net_device *dev, 
  *   Write a word to phyxcer
  */
 static void
-dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg, int value)
+dm9000_phy_write(struct net_device *dev,
+		 int phyaddr_unused, int reg, int value)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
 	unsigned long flags;
@@ -1470,7 +1452,7 @@ dm9000_init(void)
 {
 	printk(KERN_INFO "%s Ethernet Driver, V%s\n", CARDNAME, DRV_VERSION);
 
-	return platform_driver_register(&dm9000_driver);	/* search board and register */
+	return platform_driver_register(&dm9000_driver);
 }
 
 static void __exit

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
