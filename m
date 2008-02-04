From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 3/5] forcedeth: phy status fix
Date: Mon, 04 Feb 2008 15:14:04 -0500
Message-ID: <47A7720C.90405@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080600020003090508050807"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:11004 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759327AbYBEVtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 16:49:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080600020003090508050807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The driver needs to ack only the phy status bits that it is currently 
handling and preserve the other bits for the other handlers. For 
example, when reading/writing from the phy, it should not clear the link 
change interrupt bit. This will cause a missing link change interrupt.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------080600020003090508050807
Content-Type: text/plain;
 name="patch-forcedeth-mii-stat-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-mii-stat-fix"

--- old/drivers/net/forcedeth.c	2008-01-15 18:38:52.000000000 -0500
+++ new/drivers/net/forcedeth.c	2008-01-15 19:27:55.000000000 -0500
@@ -327,8 +327,8 @@
 	NvRegMIIStatus = 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
-#define NVREG_MIISTAT_MASK		0x000f
-#define NVREG_MIISTAT_MASK2		0x000f
+#define NVREG_MIISTAT_MASK_RW		0x0007
+#define NVREG_MIISTAT_MASK_ALL		0x000f
 	NvRegMIIMask = 0x184,
 #define NVREG_MII_LINKCHANGE		0x0008
 
@@ -1068,7 +1068,7 @@
 	u32 reg;
 	int retval;
 
-	writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_MASK_RW, base + NvRegMIIStatus);
 
 	reg = readl(base + NvRegMIIControl);
 	if (reg & NVREG_MIICTL_INUSE) {
@@ -3012,7 +3012,7 @@
 	u32 miistat;
 
 	miistat = readl(base + NvRegMIIStatus);
-	writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_LINKCHANGE, base + NvRegMIIStatus);
 	dprintk(KERN_INFO "%s: link change irq, status 0x%x.\n", dev->name, miistat);
 
 	if (miistat & (NVREG_MIISTAT_LINKCHANGE))
@@ -4887,7 +4887,7 @@
 
 	writel(0, base + NvRegMIIMask);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-	writel(NVREG_MIISTAT_MASK2, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
 
 	writel(NVREG_MISC1_FORCE | NVREG_MISC1_HD, base + NvRegMisc1);
 	writel(readl(base + NvRegTransmitterStatus), base + NvRegTransmitterStatus);
@@ -4925,7 +4925,7 @@
 
 	nv_disable_hw_interrupts(dev, np->irqmask);
 	pci_push(base);
-	writel(NVREG_MIISTAT_MASK2, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 	pci_push(base);
 
@@ -4948,7 +4948,7 @@
 	{
 		u32 miistat;
 		miistat = readl(base + NvRegMIIStatus);
-		writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+		writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
 		dprintk(KERN_INFO "startup: got 0x%08x.\n", miistat);
 	}
 	/* set linkspeed to invalid value, thus force nv_update_linkspeed
@@ -5320,7 +5320,7 @@
 		phystate &= ~NVREG_ADAPTCTL_RUNNING;
 		writel(phystate, base + NvRegAdapterControl);
 	}
-	writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
 
 	if (id->driver_data & DEV_HAS_MGMT_UNIT) {
 		/* management unit running on the mac? */

--------------080600020003090508050807--
