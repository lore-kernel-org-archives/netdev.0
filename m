From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 2/9] DM9000: Add support for DM9000A and DM9000B chips
Date: Mon, 16 Jun 2008 00:26:55 +0100
Message-ID: <20080615232814.937125263@fluff.org.uk>
References: <20080615232653.642837440@fluff.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:54111 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756508AbYFOX2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 19:28:17 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-support-dm9000ab.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for both the DM9000A and DM9000B versions of
the DM9000 networking chip. This includes adding support
for the Link-Change IRQ which is used instead of polling
the PHY every 2 seconds.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-15 22:52:15.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-15 22:52:19.000000000 +0100
@@ -85,6 +85,16 @@ MODULE_PARM_DESC(watchdog, "transmit tim
  * these two devices.
  */
 
+/* The driver supports the original DM9000E, and now the two newer
+ * devices, DM9000A and DM9000B.
+ */
+
+enum dm9000_type {
+	TYPE_DM9000E,	/* original DM9000 */
+	TYPE_DM9000A,
+	TYPE_DM9000B
+};
+
 /* Structure/enum declaration ------------------------------- */
 typedef struct board_info {
 
@@ -98,9 +108,11 @@ typedef struct board_info {
 	u16 dbug_cnt;
 	u8 io_mode;		/* 0:word, 2:byte */
 	u8 phy_addr;
+	u8 imr_all;
 	unsigned int flags;
 	unsigned int in_suspend :1;
 
+	enum dm9000_type type;
 	int debug_level;
 
 	void (*inblk)(void __iomem *port, void *data, int length);
@@ -302,7 +314,8 @@ static void dm9000_set_io(struct board_i
 
 static void dm9000_schedule_poll(board_info_t *db)
 {
-	schedule_delayed_work(&db->phy_poll, HZ * 2);
+	if (db->type == TYPE_DM9000E)
+		schedule_delayed_work(&db->phy_poll, HZ * 2);
 }
 
 /* Our watchdog timed out. Called by the networking layer */
@@ -516,6 +529,17 @@ dm9000_release_board(struct platform_dev
 	}
 }
 
+static unsigned char dm9000_type_to_char(enum dm9000_type type)
+{
+	switch (type) {
+	case TYPE_DM9000E: return 'e';
+	case TYPE_DM9000A: return 'a';
+	case TYPE_DM9000B: return 'b';
+	}
+
+	return '?';
+}
+
 #define res_size(_r) (((_r)->end - (_r)->start) + 1)
 
 /*
@@ -665,6 +689,23 @@ dm9000_probe(struct platform_device *pde
 		goto out;
 	}
 
+	/* Identify what type of DM9000 we are working on */
+
+	id_val = ior(db, DM9000_CHIPR);
+	dev_dbg(db->dev, "dm9000 revision 0x%02x\n", id_val);
+
+	switch (id_val) {
+	case CHIPR_DM9000A:
+		db->type = TYPE_DM9000A;
+		break;
+	case CHIPR_DM9000B:
+		db->type = TYPE_DM9000B;
+		break;
+	default:
+		dev_dbg(db->dev, "ID %02x => defaulting to DM9000E\n", id_val);
+		db->type = TYPE_DM9000E;
+	}
+
 	/* from this point we assume that we have found a DM9000 */
 
 	/* driver system function */
@@ -715,8 +756,9 @@ dm9000_probe(struct platform_device *pde
 
 	if (ret == 0) {
 		DECLARE_MAC_BUF(mac);
-		printk("%s: dm9000 at %p,%p IRQ %d MAC: %s (%s)\n",
-		       ndev->name,  db->io_addr, db->io_data, ndev->irq,
+		printk("%s: dm9000%c at %p,%p IRQ %d MAC: %s (%s)\n",
+		       ndev->name, dm9000_type_to_char(db->type),
+		       db->io_addr, db->io_data, ndev->irq,
 		       print_mac(mac, ndev->dev_addr), mac_src);
 	}
 	return 0;
@@ -778,6 +820,7 @@ static void
 dm9000_init_dm9000(struct net_device *dev)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
+	unsigned int imr;
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
@@ -804,8 +847,14 @@ dm9000_init_dm9000(struct net_device *de
 	/* Set address filter table */
 	dm9000_hash_table(dev);
 
+	imr = IMR_PAR | IMR_PTM | IMR_PRM;
+	if (db->type != TYPE_DM9000E)
+		imr |= IMR_LNKCHNG;
+
+	db->imr_all = imr;
+
 	/* Enable TX/RX interrupt mask */
-	iow(db, DM9000_IMR, IMR_PAR | IMR_PTM | IMR_PRM);
+	iow(db, DM9000_IMR, imr);
 
 	/* Init Driver variable */
 	db->tx_pkt_cnt = 0;
@@ -962,8 +1011,15 @@ dm9000_interrupt(int irq, void *dev_id)
 	if (int_status & ISR_PTS)
 		dm9000_tx_done(dev, db);
 
+	if (db->type != TYPE_DM9000E) {
+		if (int_status & ISR_LNKCHNG) {
+			/* fire a link-change request */
+			schedule_delayed_work(&db->phy_poll, 1);
+		}
+	}
+
 	/* Re-enable interrupt mask */
-	iow(db, DM9000_IMR, IMR_PAR | IMR_PTM | IMR_PRM);
+	iow(db, DM9000_IMR, db->imr_all);
 
 	/* Restore previous register address */
 	writeb(reg_save, db->io_addr);
Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.h
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.h	2008-06-15 22:50:45.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.h	2008-06-15 22:52:19.000000000 +0100
@@ -45,6 +45,9 @@
 #define DM9000_CHIPR           0x2C
 #define DM9000_SMCR            0x2F
 
+#define CHIPR_DM9000A	       0x19
+#define CHIPR_DM9000B	       0x1B
+
 #define DM9000_MRCMDX          0xF0
 #define DM9000_MRCMD           0xF2
 #define DM9000_MRRL            0xF4
@@ -131,5 +134,13 @@
 #define DM9000_PKT_RDY		0x01	/* Packet ready to receive */
 #define DM9000_PKT_MAX		1536	/* Received packet max size */
 
+/* DM9000A / DM9000B definitions */
+
+#define IMR_LNKCHNG		(1<<5)
+#define IMR_UNDERRUN		(1<<4)
+
+#define ISR_LNKCHNG		(1<<5)
+#define ISR_UNDERRUN		(1<<4)
+
 #endif /* _DM9000X_H_ */
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
