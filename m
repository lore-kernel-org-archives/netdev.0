From: Grant Grundler <grundler@parisc-linux.org>
Subject: [RFC/TEST] 2.6.28-rc3 dmfe fixes for bug 9094
Date: Sun, 9 Nov 2008 01:21:33 -0700
Message-ID: <20081109082133.GA30697@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Alessandro Polverini <alex@nibbles.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:46746 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045AbYKIIVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Nov 2008 03:21:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is am attempt to "port" phy setup fixes from the tulip driver
to the dmfe driver. Can someone with dmfe HW please test this?

Patch was originally written for 2.6.23 but applies correctly to
2.6.28-rc3 with "offset 10 lines" for all of the hunks.

I'm trying to wrap up work on bug 9094:
    http://bugzilla.kernel.org/show_bug.cgi?id=9094

thanks,
grant


diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index dab74fe..4389093 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -59,6 +59,9 @@
     Check and fix on big endian boxes.
 
     Test and make sure PCI latency is now correct for all cases.
+
+    FIXME: Update driver to 1.43 version
+       http://www.davicom.com.tw/big5/download/Driver/dm9102a/dmfe_1.43.tar.gz
 */
 
 #define DRV_NAME	"dmfe"
@@ -289,6 +292,18 @@ enum dmfe_CR6_bits {
 	CR6_SFT = 0x200000, CR6_RXA = 0x40000000, CR6_NO_PURGE = 0x20000000
 };
 
+/* Phy Regs -- See page 32 "6.3 Phy Management Register Set" of
+ * DM9102D-DS-P03-011006.pdf or other DM91x2 Design doc.
+ */
+enum phy_regs {
+	BMCR = 0, BMSR = 1, PHYIDR1 = 2, PHYIDR2 = 3, ANAR = 4,
+	ANLPAR = 5, ANER = 6, /* 7-15 reserved */
+	DSCR = 0x10, DSCSR = 0x11, CSR_10BT = 0x12,
+	PWDOR = 0x13, MDIX = 0x14
+};
+
+#define BMCR_PHY_RESET 0x8000
+
 /* Global variable declaration ----------------------------- */
 static int __devinitdata printed_version;
 static char version[] __devinitdata =
@@ -329,10 +344,6 @@ static void allocate_rx_buffer(struct dmfe_board_info *);
 static void update_cr6(u32, unsigned long);
 static void send_filter_frame(struct DEVICE * ,int);
 static void dm9132_id_table(struct DEVICE * ,int);
-static u16 phy_read(unsigned long, u8, u8, u32);
-static void phy_write(unsigned long, u8, u8, u16, u32);
-static void phy_write_1bit(unsigned long, u32);
-static u16 phy_read_1bit(unsigned long);
 static u8 dmfe_sense_speed(struct dmfe_board_info *);
 static void dmfe_process_mode(struct dmfe_board_info *);
 static void dmfe_timer(unsigned long);
@@ -349,6 +360,142 @@ static void dmfe_program_DM9802(struct dmfe_board_info *);
 static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * );
 static void dmfe_set_phyxcer(struct dmfe_board_info *);
 
+
+/*
+ *	Write one bit data to Phy Controller
+ */
+static void phy_write_1bit(unsigned long ioaddr, u32 phy_data)
+{
+	outl(phy_data, ioaddr);			/* MII Clock Low */
+	udelay(1);
+	outl(phy_data | MDCLKH, ioaddr);	/* MII Clock High */
+	udelay(1);
+	outl(phy_data, ioaddr);			/* MII Clock Low */
+	udelay(1);
+}
+
+
+/*
+ *	Read one bit phy data from PHY controller
+ */
+static u16 phy_read_1bit(unsigned long ioaddr)
+{
+	u16 phy_data;
+
+	outl(0x50000, ioaddr);
+	udelay(1);
+	phy_data = ( inl(ioaddr) >> 19 ) & 0x1;
+	outl(0x40000, ioaddr);
+	udelay(1);
+
+	return phy_data;
+}
+
+
+/*
+ *	Write a word to Phy register
+ */
+static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
+		      u16 phy_data, u32 chip_id)
+{
+	u16 i;
+	unsigned long ioaddr;
+
+	if (chip_id == PCI_DM9132_ID) {
+		ioaddr = iobase + 0x80 + offset * 4;
+		outw(phy_data, ioaddr);
+	} else {
+		/* DM9102/DM9102A Chip */
+		ioaddr = iobase + DCR9;
+
+		/* Send 33 synchronization clock to Phy controller */
+		for (i = 0; i < 35; i++)
+			phy_write_1bit(ioaddr, PHY_DATA_1);
+
+		/* Send start command(01) to Phy */
+		phy_write_1bit(ioaddr, PHY_DATA_0);
+		phy_write_1bit(ioaddr, PHY_DATA_1);
+
+		/* Send write command(01) to Phy */
+		phy_write_1bit(ioaddr, PHY_DATA_0);
+		phy_write_1bit(ioaddr, PHY_DATA_1);
+
+		/* Send Phy address */
+		for (i = 0x10; i > 0; i = i >> 1)
+			phy_write_1bit(ioaddr,
+				       phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
+
+		/* Send register address */
+		for (i = 0x10; i > 0; i = i >> 1)
+			phy_write_1bit(ioaddr,
+				       offset & i ? PHY_DATA_1 : PHY_DATA_0);
+
+		/* written trasnition */
+		phy_write_1bit(ioaddr, PHY_DATA_1);
+		phy_write_1bit(ioaddr, PHY_DATA_0);
+
+		/* Write a word data to PHY controller */
+		for ( i = 0x8000; i > 0; i >>= 1)
+			phy_write_1bit(ioaddr,
+				       phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
+	}
+}
+
+
+/*
+ *	Read a word data from phy register
+ */
+static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
+{
+	int i;
+	u16 phy_data;
+	unsigned long ioaddr;
+
+	if (chip_id == PCI_DM9132_ID) {
+		/* DM9132 Chip */
+		ioaddr = iobase + 0x80 + offset * 4;
+		phy_data = inw(ioaddr);
+	} else {
+		/* DM9102/DM9102A Chip */
+		ioaddr = iobase + DCR9;
+
+		/* Send 33 synchronization clock to Phy controller */
+		for (i = 0; i < 35; i++)
+			phy_write_1bit(ioaddr, PHY_DATA_1);
+
+		/* Send start command(01) to Phy */
+		phy_write_1bit(ioaddr, PHY_DATA_0);
+		phy_write_1bit(ioaddr, PHY_DATA_1);
+
+		/* Send read command(10) to Phy */
+		phy_write_1bit(ioaddr, PHY_DATA_1);
+		phy_write_1bit(ioaddr, PHY_DATA_0);
+
+		/* Send Phy address */
+		for (i = 0x10; i > 0; i = i >> 1)
+			phy_write_1bit(ioaddr,
+				       phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
+
+		/* Send register address */
+		for (i = 0x10; i > 0; i = i >> 1)
+			phy_write_1bit(ioaddr,
+				       offset & i ? PHY_DATA_1 : PHY_DATA_0);
+
+		/* Skip transition state */
+		phy_read_1bit(ioaddr);
+
+		/* read 16bit data */
+		for (phy_data = 0, i = 0; i < 16; i++) {
+			phy_data <<= 1;
+			phy_data |= phy_read_1bit(ioaddr);
+		}
+	}
+
+	return phy_data;
+}
+
+
+
 /* DM910X network board routine ---------------------------- */
 
 /*
@@ -589,6 +736,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = db->ioaddr;
+	unsigned int timeout;
 
 	DMFE_DBUG(0, "dmfe_init_dm910x()", 0);
 
@@ -606,13 +754,21 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 	db->media_mode = dmfe_media_mode;
 
 	/* RESET Phyxcer Chip by GPR port bit 7 */
-	outl(0x180, ioaddr + DCR12);		/* Let bit 7 output port */
+	outl(0x180, ioaddr + DCR12);	/* FIXME: reserved bits in 9102 */
 	if (db->chip_id == PCI_DM9009_ID) {
-		outl(0x80, ioaddr + DCR12);	/* Issue RESET signal */
-		mdelay(300);			/* Delay 300 ms */
+		outl(0x80, ioaddr + DCR12);     /* Issue RESET signal */
+		mdelay(300);
+	} else {
+		udelay(100);
 	}
 	outl(0x0, ioaddr + DCR12);	/* Clear RESET signal */
 
+	/* poll BMCR until Phy RESET bit is clear (< 2ms) */
+	timeout=20;
+	while (timeout-- &&
+		phy_read(db->ioaddr, db->phy_addr, BMCR, db->chip_id) & BMCR_PHY_RESET)
+			udelay(100);
+
 	/* Process Phyxcer Media Mode */
 	if ( !(db->media_mode & 0x10) )	/* Force 1M mode */
 		dmfe_set_phyxcer(db);
@@ -737,7 +893,7 @@ static int dmfe_stop(struct DEVICE *dev)
 	/* Reset & stop DM910X board */
 	outl(DM910X_RESET, ioaddr + DCR0);
 	udelay(5);
-	phy_write(db->ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
+	phy_write(db->ioaddr, db->phy_addr, BMCR, 0x8000, db->chip_id);
 
 	/* free interrupt */
 	free_irq(dev->irq, dev);
@@ -1140,8 +1296,8 @@ static void dmfe_timer(unsigned long data)
 		if (db->chip_type && (db->chip_id==PCI_DM9102_ID)) {
 			db->cr6_data &= ~0x40000;
 			update_cr6(db->cr6_data, db->ioaddr);
-			phy_write(db->ioaddr,
-				  db->phy_addr, 0, 0x1000, db->chip_id);
+			phy_write(db->ioaddr, db->phy_addr, BMCR, 0x1000,
+								db->chip_id);
 			db->cr6_data |= 0x40000;
 			update_cr6(db->cr6_data, db->ioaddr);
 			db->timer.expires = DMFE_TIMER_WUT + HZ * 2;
@@ -1218,9 +1374,9 @@ static void dmfe_timer(unsigned long data)
 	*/
 
 	/* need a dummy read because of PHY's register latch*/
-	phy_read (db->ioaddr, db->phy_addr, 1, db->chip_id);
-	link_ok_phy = (phy_read (db->ioaddr,
-		       db->phy_addr, 1, db->chip_id) & 0x4) ? 1 : 0;
+	phy_read(db->ioaddr, db->phy_addr, BMSR, db->chip_id);
+	link_ok_phy = (phy_read(db->ioaddr, db->phy_addr, BMSR, db->chip_id) & 0x4)
+			>> 2;
 
 	if (link_ok_phy != link_ok) {
 		DMFE_DBUG (0, "PHY and chip report different link status", 0);
@@ -1235,8 +1391,8 @@ static void dmfe_timer(unsigned long data)
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO or force 1M Homerun/Longrun don't need */
 		if ( !(db->media_mode & 0x38) )
-			phy_write(db->ioaddr, db->phy_addr,
-				  0, 0x1000, db->chip_id);
+			phy_write(db->ioaddr, db->phy_addr, BMCR, 0x1000,
+								db->chip_id);
 
 		/* AUTO mode, if INT phyxcer link failed, select EXT device */
 		if (db->media_mode & DMFE_AUTO) {
@@ -1619,16 +1775,19 @@ static u8 dmfe_sense_speed(struct dmfe_board_info * db)
 	/* CR6 bit18=0, select 10/100M */
 	update_cr6( (db->cr6_data & ~0x40000), db->ioaddr);
 
-	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
-	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
+	phy_mode = phy_read(db->ioaddr, db->phy_addr, BMSR, db->chip_id);
+	phy_mode = phy_read(db->ioaddr, db->phy_addr, BMSR, db->chip_id);
 
 	if ( (phy_mode & 0x24) == 0x24 ) {
 		if (db->chip_id == PCI_DM9132_ID)	/* DM9132 */
-			phy_mode = phy_read(db->ioaddr,
-				    db->phy_addr, 7, db->chip_id) & 0xf000;
-		else 				/* DM9102/DM9102A */
-			phy_mode = phy_read(db->ioaddr,
-				    db->phy_addr, 17, db->chip_id) & 0xf000;
+			/* FIXME: "7" is a reserved phy register.
+			 * Can't find DM9132 docs on davicom website. :(
+			 */
+			phy_mode = phy_read(db->ioaddr, db->phy_addr, 7,
+							db->chip_id) & 0xf000;
+		else /* DM9102/DM9102A */
+			phy_mode = phy_read(db->ioaddr, db->phy_addr, DSCSR,
+							db->chip_id) & 0xf000;
 		/* printk(DRV_NAME ": Phy_mode %x ",phy_mode); */
 		switch (phy_mode) {
 		case 0x1000: db->op_mode = DMFE_10MHF; break;
@@ -1665,15 +1824,16 @@ static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 
 	/* DM9009 Chip: Phyxcer reg18 bit12=0 */
 	if (db->chip_id == PCI_DM9009_ID) {
-		phy_reg = phy_read(db->ioaddr,
-				   db->phy_addr, 18, db->chip_id) & ~0x1000;
-
-		phy_write(db->ioaddr,
-			  db->phy_addr, 18, phy_reg, db->chip_id);
+		phy_reg = phy_read(db->ioaddr, db->phy_addr, CSR_10BT,
+								db->chip_id);
+		phy_reg &= ~0x1000;
+		phy_write(db->ioaddr, db->phy_addr, CSR_10BT, phy_reg,
+								db->chip_id);
 	}
 
 	/* Phyxcer capability setting */
-	phy_reg = phy_read(db->ioaddr, db->phy_addr, 4, db->chip_id) & ~0x01e0;
+	phy_reg = phy_read(db->ioaddr, db->phy_addr, ANAR, db->chip_id);
+	phy_reg &= ~0x01e0;
 
 	if (db->media_mode & DMFE_AUTO) {
 		/* AUTO Mode */
@@ -1694,13 +1854,13 @@ static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 		phy_reg|=db->PHY_reg4;
 		db->media_mode|=DMFE_AUTO;
 	}
-	phy_write(db->ioaddr, db->phy_addr, 4, phy_reg, db->chip_id);
+	phy_write(db->ioaddr, db->phy_addr, ANAR, phy_reg, db->chip_id);
 
  	/* Restart Auto-Negotiation */
 	if ( db->chip_type && (db->chip_id == PCI_DM9102_ID) )
-		phy_write(db->ioaddr, db->phy_addr, 0, 0x1800, db->chip_id);
+		phy_write(db->ioaddr, db->phy_addr, BMCR, 0x1800, db->chip_id);
 	if ( !db->chip_type )
-		phy_write(db->ioaddr, db->phy_addr, 0, 0x1200, db->chip_id);
+		phy_write(db->ioaddr, db->phy_addr, BMCR, 0x1200, db->chip_id);
 }
 
 
@@ -1732,7 +1892,7 @@ static void dmfe_process_mode(struct dmfe_board_info *db)
 	/* 10/100M phyxcer force mode need */
 	if ( !(db->media_mode & 0x18)) {
 		/* Forece Mode */
-		phy_reg = phy_read(db->ioaddr, db->phy_addr, 6, db->chip_id);
+		phy_reg = phy_read(db->ioaddr, db->phy_addr, ANER, db->chip_id);
 		if ( !(phy_reg & 0x1) ) {
 			/* parter without N-Way capability */
 			phy_reg = 0x0;
@@ -1742,155 +1902,15 @@ static void dmfe_process_mode(struct dmfe_board_info *db)
 			case DMFE_100MHF: phy_reg = 0x2000; break;
 			case DMFE_100MFD: phy_reg = 0x2100; break;
 			}
-			phy_write(db->ioaddr,
-				  db->phy_addr, 0, phy_reg, db->chip_id);
+			phy_write(db->ioaddr, db->phy_addr, BMCR, phy_reg,
+								db->chip_id);
        			if ( db->chip_type && (db->chip_id == PCI_DM9102_ID) )
 				mdelay(20);
-			phy_write(db->ioaddr,
-				  db->phy_addr, 0, phy_reg, db->chip_id);
-		}
-	}
-}
-
-
-/*
- *	Write a word to Phy register
- */
-
-static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
-		      u16 phy_data, u32 chip_id)
-{
-	u16 i;
-	unsigned long ioaddr;
-
-	if (chip_id == PCI_DM9132_ID) {
-		ioaddr = iobase + 0x80 + offset * 4;
-		outw(phy_data, ioaddr);
-	} else {
-		/* DM9102/DM9102A Chip */
-		ioaddr = iobase + DCR9;
-
-		/* Send 33 synchronization clock to Phy controller */
-		for (i = 0; i < 35; i++)
-			phy_write_1bit(ioaddr, PHY_DATA_1);
-
-		/* Send start command(01) to Phy */
-		phy_write_1bit(ioaddr, PHY_DATA_0);
-		phy_write_1bit(ioaddr, PHY_DATA_1);
-
-		/* Send write command(01) to Phy */
-		phy_write_1bit(ioaddr, PHY_DATA_0);
-		phy_write_1bit(ioaddr, PHY_DATA_1);
-
-		/* Send Phy address */
-		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr,
-				       phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
-
-		/* Send register address */
-		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr,
-				       offset & i ? PHY_DATA_1 : PHY_DATA_0);
-
-		/* written trasnition */
-		phy_write_1bit(ioaddr, PHY_DATA_1);
-		phy_write_1bit(ioaddr, PHY_DATA_0);
-
-		/* Write a word data to PHY controller */
-		for ( i = 0x8000; i > 0; i >>= 1)
-			phy_write_1bit(ioaddr,
-				       phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
-	}
-}
-
-
-/*
- *	Read a word data from phy register
- */
-
-static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
-{
-	int i;
-	u16 phy_data;
-	unsigned long ioaddr;
-
-	if (chip_id == PCI_DM9132_ID) {
-		/* DM9132 Chip */
-		ioaddr = iobase + 0x80 + offset * 4;
-		phy_data = inw(ioaddr);
-	} else {
-		/* DM9102/DM9102A Chip */
-		ioaddr = iobase + DCR9;
-
-		/* Send 33 synchronization clock to Phy controller */
-		for (i = 0; i < 35; i++)
-			phy_write_1bit(ioaddr, PHY_DATA_1);
-
-		/* Send start command(01) to Phy */
-		phy_write_1bit(ioaddr, PHY_DATA_0);
-		phy_write_1bit(ioaddr, PHY_DATA_1);
-
-		/* Send read command(10) to Phy */
-		phy_write_1bit(ioaddr, PHY_DATA_1);
-		phy_write_1bit(ioaddr, PHY_DATA_0);
-
-		/* Send Phy address */
-		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr,
-				       phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
-
-		/* Send register address */
-		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr,
-				       offset & i ? PHY_DATA_1 : PHY_DATA_0);
-
-		/* Skip transition state */
-		phy_read_1bit(ioaddr);
-
-		/* read 16bit data */
-		for (phy_data = 0, i = 0; i < 16; i++) {
-			phy_data <<= 1;
-			phy_data |= phy_read_1bit(ioaddr);
+			phy_write(db->ioaddr, db->phy_addr, BMCR, phy_reg,
+								db->chip_id);
 		}
 	}
-
-	return phy_data;
 }
-
-
-/*
- *	Write one bit data to Phy Controller
- */
-
-static void phy_write_1bit(unsigned long ioaddr, u32 phy_data)
-{
-	outl(phy_data, ioaddr);			/* MII Clock Low */
-	udelay(1);
-	outl(phy_data | MDCLKH, ioaddr);	/* MII Clock High */
-	udelay(1);
-	outl(phy_data, ioaddr);			/* MII Clock Low */
-	udelay(1);
-}
-
-
-/*
- *	Read one bit phy data from PHY controller
- */
-
-static u16 phy_read_1bit(unsigned long ioaddr)
-{
-	u16 phy_data;
-
-	outl(0x50000, ioaddr);
-	udelay(1);
-	phy_data = ( inl(ioaddr) >> 19 ) & 0x1;
-	outl(0x40000, ioaddr);
-	udelay(1);
-
-	return phy_data;
-}
-
-
 /*
  *	Parser SROM and media mode
  */
@@ -1971,7 +1991,7 @@ static void dmfe_parse_srom(struct dmfe_board_info * db)
 	/* Check DM9801 or DM9802 present or not */
 	db->HPNA_present = 0;
 	update_cr6(db->cr6_data|0x40000, db->ioaddr);
-	tmp_reg = phy_read(db->ioaddr, db->phy_addr, 3, db->chip_id);
+	tmp_reg = phy_read(db->ioaddr, db->phy_addr, PHYIDR2, db->chip_id);
 	if ( ( tmp_reg & 0xfff0 ) == 0xb900 ) {
 		/* DM9801 or DM9802 present */
 		db->HPNA_timer = 8;
@@ -2003,12 +2023,12 @@ static void dmfe_program_DM9801(struct dmfe_board_info * db, int HPNA_rev)
 		db->HPNA_command |= 0x1000;
 		reg25 = phy_read(db->ioaddr, db->phy_addr, 24, db->chip_id);
 		reg25 = ( (reg25 + HPNA_NoiseFloor) & 0xff) | 0xf000;
-		reg17 = phy_read(db->ioaddr, db->phy_addr, 17, db->chip_id);
+		reg17 = phy_read(db->ioaddr, db->phy_addr, DSCSR, db->chip_id);
 		break;
 	case 0xb901: /* DM9801 E4 */
 		reg25 = phy_read(db->ioaddr, db->phy_addr, 25, db->chip_id);
 		reg25 = (reg25 & 0xff00) + HPNA_NoiseFloor;
-		reg17 = phy_read(db->ioaddr, db->phy_addr, 17, db->chip_id);
+		reg17 = phy_read(db->ioaddr, db->phy_addr, DSCSR, db->chip_id);
 		reg17 = (reg17 & 0xfff0) + HPNA_NoiseFloor + 3;
 		break;
 	case 0xb902: /* DM9801 E5 */
@@ -2017,12 +2037,12 @@ static void dmfe_program_DM9801(struct dmfe_board_info * db, int HPNA_rev)
 		db->HPNA_command |= 0x1000;
 		reg25 = phy_read(db->ioaddr, db->phy_addr, 25, db->chip_id);
 		reg25 = (reg25 & 0xff00) + HPNA_NoiseFloor - 5;
-		reg17 = phy_read(db->ioaddr, db->phy_addr, 17, db->chip_id);
+		reg17 = phy_read(db->ioaddr, db->phy_addr, DSCSR, db->chip_id);
 		reg17 = (reg17 & 0xfff0) + HPNA_NoiseFloor;
 		break;
 	}
-	phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command, db->chip_id);
-	phy_write(db->ioaddr, db->phy_addr, 17, reg17, db->chip_id);
+	phy_write(db->ioaddr, db->phy_addr, DSCR, db->HPNA_command, db->chip_id);
+	phy_write(db->ioaddr, db->phy_addr, DSCSR, reg17, db->chip_id);
 	phy_write(db->ioaddr, db->phy_addr, 25, reg25, db->chip_id);
 }
 
@@ -2036,7 +2056,7 @@ static void dmfe_program_DM9802(struct dmfe_board_info * db)
 	uint phy_reg;
 
 	if ( !HPNA_NoiseFloor ) HPNA_NoiseFloor = DM9802_NOISE_FLOOR;
-	phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command, db->chip_id);
+	phy_write(db->ioaddr, db->phy_addr, DSCR, db->HPNA_command, db->chip_id);
 	phy_reg = phy_read(db->ioaddr, db->phy_addr, 25, db->chip_id);
 	phy_reg = ( phy_reg & 0xff00) + HPNA_NoiseFloor;
 	phy_write(db->ioaddr, db->phy_addr, 25, phy_reg, db->chip_id);
@@ -2053,7 +2073,8 @@ static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * db)
 	uint phy_reg;
 
 	/* Got remote device status */
-	phy_reg = phy_read(db->ioaddr, db->phy_addr, 17, db->chip_id) & 0x60;
+	phy_reg = phy_read(db->ioaddr, db->phy_addr, DSCSR, db->chip_id);
+	phy_reg &= 0x60;
 	switch(phy_reg) {
 	case 0x00: phy_reg = 0x0a00;break; /* LP/LS */
 	case 0x20: phy_reg = 0x0900;break; /* LP/HS */
@@ -2063,7 +2084,7 @@ static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * db)
 
 	/* Check remote device status match our setting ot not */
 	if ( phy_reg != (db->HPNA_command & 0x0f00) ) {
-		phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command,
+		phy_write(db->ioaddr, db->phy_addr, DSCR, db->HPNA_command,
 			  db->chip_id);
 		db->HPNA_timer=8;
 	} else
