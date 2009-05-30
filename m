From: Ed Swierk <eswierk@aristanetworks.com>
Subject: [PATCH] forcedeth: add phy_power_down parameter, leave phy powered
 up by default
Date: Sat, 30 May 2009 15:59:46 -0700
Message-ID: <1243724386.13996.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f177.google.com ([209.85.222.177]:50256 "EHLO
	mail-pz0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763232AbZE3W7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 18:59:51 -0400
Received: by pzk7 with SMTP id 7so5355360pzk.33
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 15:59:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a phy_power_down parameter to forcedeth: set to 1 to power down the
phy and disable the link when an interface goes down; set to 0 to always
leave the phy powered up.

The phy power state persists across reboots; Windows, some BIOSes, and
older versions of Linux don't bother to power up the phy again, forcing
users to remove all power to get the interface working (see
http://bugzilla.kernel.org/show_bug.cgi?id=13072).  Leaving the phy
powered on is the safest default behavior.  Users accustomed to seeing
the link state reflect the interface state and/or wanting to minimize
power consumption can set phy_power_down=1 if compatibility with other
OSes is not an issue.

Signed-off-by: Ed Swierk <eswierk@aristanetworks.com>

---
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index f9a846b..ace1160 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -897,6 +897,16 @@ enum {
 };
 static int phy_cross = NV_CROSSOVER_DETECTION_DISABLED;
 
+/*
+ * Power down phy when interface is down (persists through reboot;
+ * older Linux and other OSes may not bother to power it up again)
+ */
+enum {
+	NV_PHY_POWER_DOWN_NEVER,
+	NV_PHY_POWER_DOWN_ON_INTF_DOWN
+};
+static int phy_power_down = NV_PHY_POWER_DOWN_NEVER;
+
 static inline struct fe_priv *get_nvpriv(struct net_device *dev)
 {
 	return netdev_priv(dev);
@@ -1485,7 +1495,10 @@ static int phy_init(struct net_device *dev)
 
 	/* restart auto negotiation, power down phy */
 	mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
-	mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE | BMCR_PDOWN);
+	mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE);
+	if (phy_power_down == NV_PHY_POWER_DOWN_ON_INTF_DOWN) {
+		mii_control |= BMCR_PDOWN;
+	}
 	if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
 		return PHY_ERROR;
 	}
@@ -5513,7 +5526,7 @@ static int nv_close(struct net_device *dev)
 
 	nv_drain_rxtx(dev);
 
-	if (np->wolenabled) {
+	if (np->wolenabled || phy_power_down == NV_PHY_POWER_DOWN_NEVER) {
 		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
 		nv_start_rx(dev);
 	} else {
@@ -6367,6 +6380,8 @@ module_param(dma_64bit, int, 0);
 MODULE_PARM_DESC(dma_64bit, "High DMA is enabled by setting to 1 and disabled by setting to 0.");
 module_param(phy_cross, int, 0);
 MODULE_PARM_DESC(phy_cross, "Phy crossover detection for Realtek 8201 phy is enabled by setting to 1 and disabled by setting to 0.");
+module_param(phy_power_down, int, 0);
+MODULE_PARM_DESC(phy_power_down, "Power down phy and disable link when interface is down (1), or always leave phy powered up (0).");
 
 MODULE_AUTHOR("Manfred Spraul <manfred@colorfullife.com>");
 MODULE_DESCRIPTION("Reverse Engineered nForce ethernet driver");


