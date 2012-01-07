From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 5/7] via-rhine: RHINE_WAIT_FOR macro removal.
Date: Sat, 7 Jan 2012 23:51:47 +0100
Message-ID: <20120107225147.GE25021@electric-eye.fr.zoreil.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50382 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578Ab2AGXBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 18:01:08 -0500
Content-Disposition: inline
In-Reply-To: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c |   74 +++++++++++++++++++++++-----------
 1 files changed, 50 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 9a7bacc..98ec14e 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -501,15 +501,31 @@ static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
 static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
 static void rhine_restart_tx(struct net_device *dev);
 
-#define RHINE_WAIT_FOR(condition)				\
-do {								\
-	int i = 1024;						\
-	while (!(condition) && --i)				\
-		;						\
-	if (debug > 1 && i < 512)				\
-		pr_info("%4d cycles used @ %s:%d\n",		\
-			1024 - i, __func__, __LINE__);		\
-} while (0)
+static void rhine_wait_bit(struct rhine_private *rp, u8 reg, u8 mask, bool high)
+{
+	void __iomem *ioaddr = rp->base;
+	int i;
+
+	for (i = 0; i < 1024; i++) {
+		if (high ^ !!(ioread8(ioaddr + reg) & mask))
+			break;
+		udelay(10);
+	}
+	if (i > 64) {
+		netdev_dbg(rp->dev, "%s bit wait (%02x/%02x) cycle "
+			   "count: %04d\n", high ? "high" : "low", reg, mask, i);
+	}
+}
+
+static void rhine_wait_bit_high(struct rhine_private *rp, u8 reg, u8 mask)
+{
+	rhine_wait_bit(rp, reg, mask, true);
+}
+
+static void rhine_wait_bit_low(struct rhine_private *rp, u8 reg, u8 mask)
+{
+	rhine_wait_bit(rp, reg, mask, false);
+}
 
 static u32 rhine_get_events(struct rhine_private *rp)
 {
@@ -609,7 +625,7 @@ static void rhine_chip_reset(struct net_device *dev)
 			iowrite8(0x40, ioaddr + MiscCmd);
 
 		/* Reset can take somewhat longer (rare) */
-		RHINE_WAIT_FOR(!(ioread8(ioaddr + ChipCmd1) & Cmd1Reset));
+		rhine_wait_bit_low(rp, ChipCmd1, Cmd1Reset);
 	}
 
 	if (debug > 1)
@@ -641,9 +657,15 @@ static void __devinit rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
+	int i;
 
 	outb(0x20, pioaddr + MACRegEEcsr);
-	RHINE_WAIT_FOR(!(inb(pioaddr + MACRegEEcsr) & 0x20));
+	for (i = 0; i < 1024; i++) {
+		if (!(inb(pioaddr + MACRegEEcsr) & 0x20))
+			break;
+	}
+	if (i > 512)
+		pr_info("%4d cycles used @ %s:%d\n", i, __func__, __LINE__);
 
 #ifdef USE_MMIO
 	/*
@@ -770,7 +792,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 			u8 cmd;
 
 			/* Avoid scavenging before Tx engine turned off */
-			RHINE_WAIT_FOR(!(ioread8(ioaddr + ChipCmd) & CmdTxOn));
+			rhine_wait_bit_low(rp, ChipCmd, CmdTxOn);
 			cmd = ioread8(ioaddr + ChipCmd);
 			if ((cmd & CmdTxOn) && (debug > 2)) {
 				netdev_warn(dev, "%s: Tx engine still on\n",
@@ -1444,23 +1466,27 @@ static void init_registers(struct net_device *dev)
 }
 
 /* Enable MII link status auto-polling (required for IntrLinkChange) */
-static void rhine_enable_linkmon(void __iomem *ioaddr)
+static void rhine_enable_linkmon(struct rhine_private *rp)
 {
+	void __iomem *ioaddr = rp->base;
+
 	iowrite8(0, ioaddr + MIICmd);
 	iowrite8(MII_BMSR, ioaddr + MIIRegAddr);
 	iowrite8(0x80, ioaddr + MIICmd);
 
-	RHINE_WAIT_FOR((ioread8(ioaddr + MIIRegAddr) & 0x20));
+	rhine_wait_bit_high(rp, MIIRegAddr, 0x20);
 
 	iowrite8(MII_BMSR | 0x40, ioaddr + MIIRegAddr);
 }
 
 /* Disable MII link status auto-polling (required for MDIO access) */
-static void rhine_disable_linkmon(void __iomem *ioaddr, u32 quirks)
+static void rhine_disable_linkmon(struct rhine_private *rp)
 {
+	void __iomem *ioaddr = rp->base;
+
 	iowrite8(0, ioaddr + MIICmd);
 
-	if (quirks & rqRhineI) {
+	if (rp->quirks & rqRhineI) {
 		iowrite8(0x01, ioaddr + MIIRegAddr);	// MII_BMSR
 
 		/* Can be called from ISR. Evil. */
@@ -1469,13 +1495,13 @@ static void rhine_disable_linkmon(void __iomem *ioaddr, u32 quirks)
 		/* 0x80 must be set immediately before turning it off */
 		iowrite8(0x80, ioaddr + MIICmd);
 
-		RHINE_WAIT_FOR(ioread8(ioaddr + MIIRegAddr) & 0x20);
+		rhine_wait_bit_high(rp, MIIRegAddr, 0x20);
 
 		/* Heh. Now clear 0x80 again. */
 		iowrite8(0, ioaddr + MIICmd);
 	}
 	else
-		RHINE_WAIT_FOR(ioread8(ioaddr + MIIRegAddr) & 0x80);
+		rhine_wait_bit_high(rp, MIIRegAddr, 0x80);
 }
 
 /* Read and write over the MII Management Data I/O (MDIO) interface. */
@@ -1486,16 +1512,16 @@ static int mdio_read(struct net_device *dev, int phy_id, int regnum)
 	void __iomem *ioaddr = rp->base;
 	int result;
 
-	rhine_disable_linkmon(ioaddr, rp->quirks);
+	rhine_disable_linkmon(rp);
 
 	/* rhine_disable_linkmon already cleared MIICmd */
 	iowrite8(phy_id, ioaddr + MIIPhyAddr);
 	iowrite8(regnum, ioaddr + MIIRegAddr);
 	iowrite8(0x40, ioaddr + MIICmd);		/* Trigger read */
-	RHINE_WAIT_FOR(!(ioread8(ioaddr + MIICmd) & 0x40));
+	rhine_wait_bit_low(rp, MIICmd, 0x40);
 	result = ioread16(ioaddr + MIIData);
 
-	rhine_enable_linkmon(ioaddr);
+	rhine_enable_linkmon(rp);
 	return result;
 }
 
@@ -1504,16 +1530,16 @@ static void mdio_write(struct net_device *dev, int phy_id, int regnum, int value
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	rhine_disable_linkmon(ioaddr, rp->quirks);
+	rhine_disable_linkmon(rp);
 
 	/* rhine_disable_linkmon already cleared MIICmd */
 	iowrite8(phy_id, ioaddr + MIIPhyAddr);
 	iowrite8(regnum, ioaddr + MIIRegAddr);
 	iowrite16(value, ioaddr + MIIData);
 	iowrite8(0x20, ioaddr + MIICmd);		/* Trigger write */
-	RHINE_WAIT_FOR(!(ioread8(ioaddr + MIICmd) & 0x20));
+	rhine_wait_bit_low(rp, MIICmd, 0x20);
 
-	rhine_enable_linkmon(ioaddr);
+	rhine_enable_linkmon(rp);
 }
 
 static void rhine_task_disable(struct rhine_private *rp)
-- 
1.7.6.4
