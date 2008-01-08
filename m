From: linux@horizon.com
Subject: [PATCH 3/3] drivers/net/ipg.c: fix horrible mdio_read and _write
Date: 8 Jan 2008 07:40:49 -0500
Message-ID: <20080108124049.12199.qmail@science.horizon.com>
Cc: akpm@linux-foundation.org, davem@davemloft.net, linux@horizon.com
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:19694 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754617AbYAHN2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 08:28:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm noticed that this code was awful.
 ipg.c |  158 +++++++++++++++++------------------------------------------------- 1 file changed, 43 insertions(+), 115 deletions(-)
should be sufficient justification all by itself.
---
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 3860fcd..b3d3fc8 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -202,12 +202,31 @@ static u16 read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
 }
 
 /*
+ * Transmit the given bits, MSB-first, through the MgmtData bit (bit 1)
+ * of the PhyCtrl register. 1 <= len <= 32.  "ioaddr" is the register
+ * address, and "otherbits" are the values of the other bits.
+ */
+static void mdio_write_bits(void __iomem *ioaddr, u8 otherbits, u32 data, unsigned len)
+{
+	otherbits |= IPG_PC_MGMTDIR;
+	do {
+		/* IPG_PC_MGMTDATA is a power of 2; compiler knows to shift */
+		u8 d = ((data >> --len) & 1) * IPG_PC_MGMTDATA;
+		/* + rather than | lets compiler microoptimize better */
+		ipg_drive_phy_ctl_low_high(ioaddr, d + otherbits);
+	} while (len);
+}
+
+/*
  * Read a register from the Physical Layer device located
  * on the IPG NIC, using the IPG PHYCTRL register.
  */
 static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
+	u8 const polarity = ipg_r8(PHY_CTRL) &
+			(IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
+	unsigned i, data = 0;
 	/*
 	 * The GMII mangement frame structure for a read is as follows:
 	 *
@@ -221,75 +240,30 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
 	 * D = bit of read data (MSB first)
 	 *
 	 * Transmission order is 'Preamble' field first, bits transmitted
-	 * left to right (first to last).
+	 * left to right (msbit-first).
 	 */
-	struct {
-		u32 field;
-		unsigned int len;
-	} p[] = {
-		{ GMII_PREAMBLE,	32 },	/* Preamble */
-		{ GMII_ST,		2  },	/* ST */
-		{ GMII_READ,		2  },	/* OP */
-		{ phy_id,		5  },	/* PHYAD */
-		{ phy_reg,		5  },	/* REGAD */
-		{ 0x0000,		2  },	/* TA */
-		{ 0x0000,		16 },	/* DATA */
-		{ 0x0000,		1  }	/* IDLE */
-	};
-	unsigned int i, j;
-	u8 polarity, data;
-
-	polarity  = ipg_r8(PHY_CTRL);
-	polarity &= (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
-
-	/* Create the Preamble, ST, OP, PHYAD, and REGAD field. */
-	for (j = 0; j < 5; j++) {
-		for (i = 0; i < p[j].len; i++) {
-			/* For each variable length field, the MSB must be
-			 * transmitted first. Rotate through the field bits,
-			 * starting with the MSB, and move each bit into the
-			 * the 1st (2^1) bit position (this is the bit position
-			 * corresponding to the MgmtData bit of the PhyCtrl
-			 * register for the IPG).
-			 *
-			 * Example: ST = 01;
-			 *
-			 *          First write a '0' to bit 1 of the PhyCtrl
-			 *          register, then write a '1' to bit 1 of the
-			 *          PhyCtrl register.
-			 *
-			 * To do this, right shift the MSB of ST by the value:
-			 * [field length - 1 - #ST bits already written]
-			 * then left shift this result by 1.
-			 */
-			data  = (p[j].field >> (p[j].len - 1 - i)) << 1;
-			data &= IPG_PC_MGMTDATA;
-			data |= polarity | IPG_PC_MGMTDIR;
-
-			ipg_drive_phy_ctl_low_high(ioaddr, data);
-		}
-	}
-
-	send_three_state(ioaddr, polarity);
-
-	read_phy_bit(ioaddr, polarity);
+	mdio_write_bits(ioaddr, polarity, GMII_PREAMBLE, 32);
+	mdio_write_bits(ioaddr, polarity, GMII_ST<<12 | GMII_READ << 10 |
+	                                  phy_id << 5 | phy_reg, 14);
 
 	/*
 	 * For a read cycle, the bits for the next two fields (TA and
 	 * DATA) are driven by the PHY (the IPG reads these bits).
 	 */
-	for (i = 0; i < p[6].len; i++) {
-		p[6].field |=
-		    (read_phy_bit(ioaddr, polarity) << (p[6].len - 1 - i));
-	}
+	send_three_state(ioaddr, polarity);	/* TA first bit */
+	(void)read_phy_bit(ioaddr, polarity);		/* TA second bit */
+
+	for (i = 0; i < 16; i++)
+		data += data + read_phy_bit(ioaddr, polarity);
 
+	/* Trailing idle */
 	send_three_state(ioaddr, polarity);
 	send_three_state(ioaddr, polarity);
 	send_three_state(ioaddr, polarity);
 	send_end(ioaddr, polarity);
 
 	/* Return the value of the DATA field. */
-	return p[6].field;
+	return data;
 }
 
 /*
@@ -299,11 +273,13 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
 static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
+	u8 const polarity = ipg_r8(PHY_CTRL) &
+			(IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
 	/*
-	 * The GMII mangement frame structure for a read is as follows:
+	 * The GMII mangement frame structure for a write is as follows:
 	 *
 	 * |Preamble|st|op|phyad|regad|ta|      data      |idle|
-	 * |< 32 1s>|01|10|AAAAA|RRRRR|z0|DDDDDDDDDDDDDDDD|z   |
+	 * |< 32 1s>|01|01|AAAAA|RRRRR|10|DDDDDDDDDDDDDDDD|z   |
 	 *
 	 * <32 1s> = 32 consecutive logic 1 values
 	 * A = bit of Physical Layer device address (MSB first)
@@ -312,66 +288,18 @@ static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
 	 * D = bit of write data (MSB first)
 	 *
 	 * Transmission order is 'Preamble' field first, bits transmitted
-	 * left to right (first to last).
+	 * left to right (msbit-first).
 	 */
-	struct {
-		u32 field;
-		unsigned int len;
-	} p[] = {
-		{ GMII_PREAMBLE,	32 },	/* Preamble */
-		{ GMII_ST,		2  },	/* ST */
-		{ GMII_WRITE,		2  },	/* OP */
-		{ phy_id,		5  },	/* PHYAD */
-		{ phy_reg,		5  },	/* REGAD */
-		{ 0x0002,		2  },	/* TA */
-		{ val & 0xffff,		16 },	/* DATA */
-		{ 0x0000,		1  }	/* IDLE */
-	};
-	unsigned int i, j;
-	u8 polarity, data;
-
-	polarity  = ipg_r8(PHY_CTRL);
-	polarity &= (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
-
-	/* Create the Preamble, ST, OP, PHYAD, and REGAD field. */
-	for (j = 0; j < 7; j++) {
-		for (i = 0; i < p[j].len; i++) {
-			/* For each variable length field, the MSB must be
-			 * transmitted first. Rotate through the field bits,
-			 * starting with the MSB, and move each bit into the
-			 * the 1st (2^1) bit position (this is the bit position
-			 * corresponding to the MgmtData bit of the PhyCtrl
-			 * register for the IPG).
-			 *
-			 * Example: ST = 01;
-			 *
-			 *          First write a '0' to bit 1 of the PhyCtrl
-			 *          register, then write a '1' to bit 1 of the
-			 *          PhyCtrl register.
-			 *
-			 * To do this, right shift the MSB of ST by the value:
-			 * [field length - 1 - #ST bits already written]
-			 * then left shift this result by 1.
-			 */
-			data  = (p[j].field >> (p[j].len - 1 - i)) << 1;
-			data &= IPG_PC_MGMTDATA;
-			data |= polarity | IPG_PC_MGMTDIR;
-
-			ipg_drive_phy_ctl_low_high(ioaddr, data);
-		}
-	}
+	mdio_write_bits(ioaddr, polarity, GMII_PREAMBLE, 32);
+	mdio_write_bits(ioaddr, polarity, GMII_ST << 14 | GMII_WRITE << 12 |
+	                                  phy_id << 7 | phy_reg << 2 |
+					  0x2, 16);
+	mdio_write_bits(ioaddr, polarity, val, 16);	/* DATA */
 
 	/* The last cycle is a tri-state, so read from the PHY. */
-	for (j = 7; j < 8; j++) {
-		for (i = 0; i < p[j].len; i++) {
-			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
-
-			p[j].field |= ((ipg_r8(PHY_CTRL) &
-				IPG_PC_MGMTDATA) >> 1) << (p[j].len - 1 - i);
-
-			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
-		}
-	}
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
+	(void)ipg_r8(PHY_CTRL);
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
 }
 
 /* Set LED_Mode JES20040127EEPROM */
