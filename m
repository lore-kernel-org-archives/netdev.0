From: Roger Luethi <rl@hellgate.ch>
Subject: [8/9][PATCH 2.6] Add rhine_power_init(): get power regs into sane state
Date: Wed, 2 Jun 2004 13:59:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115906.GA17612@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040602115703.GA16079@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add rhine_power_init(): get power regs into sane state.
Move the respective code out of rhine_init_one. Add code for
two additional patterns (Rhine III).

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -408,8 +408,10 @@
 	MIICmd=0x70, MIIRegAddr=0x71, MIIData=0x72, MACRegEEcsr=0x74,
 	ConfigA=0x78, ConfigB=0x79, ConfigC=0x7A, ConfigD=0x7B,
 	RxMissed=0x7C, RxCRCErrs=0x7E, MiscCmd=0x81,
-	StickyHW=0x83, IntrStatus2=0x84, WOLcrClr=0xA4, WOLcgClr=0xA7,
-	PwrcsrClr=0xAC,
+	StickyHW=0x83, IntrStatus2=0x84,
+	WOLcrSet=0xA0, WOLcrClr=0xA4, WOLcrClr1=0xA6,
+	WOLcgClr=0xA7,
+	PwrcsrSet=0xA8, PwrcsrSet1=0xA9, PwrcsrClr=0xAC, PwrcsrClr1=0xAD,
 };
 
 /* Bits in ConfigD */
@@ -548,6 +550,35 @@
 	return intr_status;
 }
 
+/*
+ * Get power related registers into sane state.
+ * Returns content of power-event (WOL) registers.
+ */
+static void rhine_power_init(struct net_device *dev)
+{
+	long ioaddr = dev->base_addr;
+	struct rhine_private *rp = netdev_priv(dev);
+
+	if (rp->quirks & rqWOL) {
+		/* Make sure chip is in power state D0 */
+		writeb(readb(ioaddr + StickyHW) & 0xFC, ioaddr + StickyHW);
+
+		/* Disable "force PME-enable" */
+		writeb(0x80, ioaddr + WOLcgClr);
+
+		/* Clear power-event config bits (WOL) */
+		writeb(0xFF, ioaddr + WOLcrClr);
+		/* More recent cards can manage two additional patterns */
+		if (rp->quirks & rq6patterns)
+			writeb(0x03, ioaddr + WOLcrClr1);
+
+		/* Clear power-event status bits */
+		writeb(0xFF, ioaddr + PwrcsrClr);
+		if (rp->quirks & rq6patterns)
+			writeb(0x03, ioaddr + PwrcsrClr1);
+	}
+}
+
 static void wait_for_reset(struct net_device *dev, u32 quirks, char *name)
 {
 	long ioaddr = dev->base_addr;
@@ -722,29 +753,13 @@
 		}
 	}
 #endif /* USE_MMIO */
+	dev->base_addr = ioaddr;
 
-	/* D-Link provided reset code (with comment additions) */
-	if (quirks & rqWOL) {
-		unsigned char byOrgValue;
-
-		/* clear sticky bit before reset & read ethernet address */
-		byOrgValue = readb(ioaddr + StickyHW);
-		byOrgValue = byOrgValue & 0xFC;
-		writeb(byOrgValue, ioaddr + StickyHW);
-
-		/* (bits written are cleared?) */
-		/* disable force PME-enable */
-		writeb(0x80, ioaddr + WOLcgClr);
-		/* disable power-event config bit */
-		writeb(0xFF, ioaddr + WOLcrClr);
-		/* clear power status (undocumented in vt6102 docs?) */
-		writeb(0xFF, ioaddr + PwrcsrClr);
-	}
+	rhine_power_init(dev);
 
 	/* Reset the chip to erase previous misconfiguration. */
 	writew(CmdReset, ioaddr + ChipCmd);
 
-	dev->base_addr = ioaddr;
 	wait_for_reset(dev, quirks, shortname);
 
 	/* Reload the station address from the EEPROM. */
