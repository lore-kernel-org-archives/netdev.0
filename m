From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 02/22] NET: DM9000 update debugging macros to use debug level
Date: Mon, 19 Nov 2007 20:39:12 +0000
Message-ID: <20071119204013.065970173@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61685 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752002AbXKSVSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:18:02 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-debugupdate.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the debug macros to use the compiler to elide any
unnecessary debug level, and to allow device configurable
debug control.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt1/drivers/net/Kconfig
===================================================================
--- linux-2.6.23-quilt1.orig/drivers/net/Kconfig
+++ linux-2.6.23-quilt1/drivers/net/Kconfig
@@ -940,6 +940,14 @@ config DM9000
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called dm9000.
 
+config DM9000_DEBUGLEVEL
+	int "DM9000 maximum debug level"
+	depends on DM9000
+	default 4
+	help
+	  The maximum level of debugging code compiled into the DM9000
+	  driver.
+
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
Index: linux-2.6.23-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt1.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt1/drivers/net/dm9000.c
@@ -82,28 +82,6 @@
 
 #define DM9000_TIMER_WUT  jiffies+(HZ*2)	/* timer wakeup time : 2 second */
 
-#define DM9000_DEBUG 0
-
-#if DM9000_DEBUG > 2
-#define PRINTK3(args...)  printk(CARDNAME ": " args)
-#else
-#define PRINTK3(args...)  do { } while(0)
-#endif
-
-#if DM9000_DEBUG > 1
-#define PRINTK2(args...)  printk(CARDNAME ": " args)
-#else
-#define PRINTK2(args...)  do { } while(0)
-#endif
-
-#if DM9000_DEBUG > 0
-#define PRINTK1(args...)  printk(CARDNAME ": " args)
-#define PRINTK(args...)   printk(CARDNAME ": " args)
-#else
-#define PRINTK1(args...)  do { } while(0)
-#define PRINTK(args...)   printk(KERN_DEBUG args)
-#endif
-
 #ifdef CONFIG_BLACKFIN
 #define readsb	insb
 #define readsw	insw
@@ -138,6 +116,8 @@ typedef struct board_info {
 	u8 phy_addr;
 	unsigned int flags;
 
+	int debug_level;
+
 	void (*inblk)(void __iomem *port, void *data, int length);
 	void (*outblk)(void __iomem *port, void *data, int length);
 	void (*dumpblk)(void __iomem *port, int length);
@@ -159,6 +139,15 @@ typedef struct board_info {
 	u32 msg_enable;
 } board_info_t;
 
+/* debug code */
+
+#define dm9000_dbg(db, lev, msg...) do {		\
+	if ((lev) < CONFIG_DM9000_DEBUGLEVEL &&		\
+	    (lev) < db->debug_level) {			\
+		dev_dbg(db->dev, msg);			\
+	}						\
+} while (0)
+
 /* function declaration ------------------------------------- */
 static int dm9000_probe(struct platform_device *);
 static int dm9000_open(struct net_device *);
@@ -664,7 +653,7 @@ dm9000_init_dm9000(struct net_device *de
 {
 	board_info_t *db = (board_info_t *) dev->priv;
 
-	PRINTK1("entering %s\n",__FUNCTION__);
+	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
 	/* I/O mode */
 	db->io_mode = ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mode */
@@ -710,7 +699,7 @@ dm9000_start_xmit(struct sk_buff *skb, s
 	unsigned long flags;
 	board_info_t *db = (board_info_t *) dev->priv;
 
-	PRINTK3("dm9000_start_xmit\n");
+	dm9000_dbg(db, 3, "%s:\n", __func__);
 
 	if (db->tx_pkt_cnt > 1)
 		return 1;
@@ -769,7 +758,7 @@ dm9000_stop(struct net_device *ndev)
 {
 	board_info_t *db = (board_info_t *) ndev->priv;
 
-	PRINTK1("entering %s\n",__FUNCTION__);
+	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
 	/* deleted timer */
 	del_timer(&db->timer);
@@ -815,19 +804,14 @@ static irqreturn_t
 dm9000_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	board_info_t *db;
+	board_info_t *db = (board_info_t *) dev->priv;
 	int int_status;
 	u8 reg_save;
 
-	PRINTK3("entering %s\n",__FUNCTION__);
-
-	if (!dev) {
-		PRINTK1("dm9000_interrupt() without DEVICE arg\n");
-		return IRQ_HANDLED;
-	}
+	dm9000_dbg(db, 3, "entering %s\n", __func__);
 
 	/* A real interrupt coming */
-	db = (board_info_t *) dev->priv;
+
 	spin_lock(&db->lock);
 
 	/* Save previous register address */
@@ -880,7 +864,7 @@ dm9000_timer(unsigned long data)
 	struct net_device *dev = (struct net_device *) data;
 	board_info_t *db = (board_info_t *) dev->priv;
 
-	PRINTK3("dm9000_timer()\n");
+	dm9000_dbg(db, 3, "entering %s\n", __func__);
 
 	mii_check_media(&db->mii, netif_msg_link(db), 0);
 
@@ -1065,7 +1049,7 @@ dm9000_hash_table(struct net_device *dev
 	u16 i, oft, hash_table[4];
 	unsigned long flags;
 
-	PRINTK2("dm9000_hash_table()\n");
+	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
 	spin_lock_irqsave(&db->lock,flags);
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
