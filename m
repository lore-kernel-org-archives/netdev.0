From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] forcedeth: deferral fixup
Date: Thu, 06 Jul 2006 16:45:58 -0400
Message-ID: <44AD7686.8040201@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040704080309080100040706"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:46908 "EHLO
	HQEMGATE02.nvidia.com") by vger.kernel.org with ESMTP
	id S1750998AbWGFWzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 18:55:10 -0400
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040704080309080100040706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds the definition for the deferral registers and fixes up 
the use of these registers.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040704080309080100040706
Content-Type: text/plain;
 name="patch-forcedeth-deferral"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-deferral"

--- orig-2.6/drivers/net/forcedeth.c	2006-07-06 15:03:45.000000000 -0400
+++ new-2.6/drivers/net/forcedeth.c	2006-07-06 15:03:55.000000000 -0400
@@ -240,10 +240,12 @@
 #define NVREG_RNDSEED_FORCE2	0x2d00
 #define NVREG_RNDSEED_FORCE3	0x7400
 
-	NvRegUnknownSetupReg1 = 0xA0,
-#define NVREG_UNKSETUP1_VAL	0x16070f
-	NvRegUnknownSetupReg2 = 0xA4,
-#define NVREG_UNKSETUP2_VAL	0x16
+	NvRegTxDeferral = 0xA0,
+#define NVREG_TX_DEFERRAL_DEFAULT	0x15050f
+#define NVREG_TX_DEFERRAL_RGMII_10_100	0x16070f
+#define NVREG_TX_DEFERRAL_RGMII_1000	0x14050f
+	NvRegRxDeferral = 0xA4,
+#define NVREG_RX_DEFERRAL_DEFAULT	0x16
 	NvRegMacAddrA = 0xA8,
 	NvRegMacAddrB = 0xAC,
 	NvRegMulticastAddrA = 0xB0,
@@ -2127,7 +2129,7 @@
 	int newdup = np->duplex;
 	int mii_status;
 	int retval = 0;
-	u32 control_1000, status_1000, phyreg, pause_flags;
+	u32 control_1000, status_1000, phyreg, pause_flags, txreg;
 
 	/* BMSR_LSTATUS is latched, read it twice:
 	 * we want the current value.
@@ -2245,6 +2247,16 @@
 		phyreg |= PHY_1000;
 	writel(phyreg, base + NvRegPhyInterface);
 
+	if (phyreg & PHY_RGMII) {
+		if ((np->linkspeed & NVREG_LINKSPEED_MASK) == NVREG_LINKSPEED_1000)
+			txreg = NVREG_TX_DEFERRAL_RGMII_1000;
+		else
+			txreg = NVREG_TX_DEFERRAL_RGMII_10_100;
+	} else {
+		txreg = NVREG_TX_DEFERRAL_DEFAULT;
+	}
+	writel(txreg, base + NvRegTxDeferral);
+
 	writel(NVREG_MISC1_FORCE | ( np->duplex ? 0 : NVREG_MISC1_HD),
 		base + NvRegMisc1);
 	pci_push(base);
@@ -3932,8 +3944,8 @@
 	writel(readl(base + NvRegReceiverStatus), base + NvRegReceiverStatus);
 	get_random_bytes(&i, sizeof(i));
 	writel(NVREG_RNDSEED_FORCE | (i&NVREG_RNDSEED_MASK), base + NvRegRandomSeed);
-	writel(NVREG_UNKSETUP1_VAL, base + NvRegUnknownSetupReg1);
-	writel(NVREG_UNKSETUP2_VAL, base + NvRegUnknownSetupReg2);
+	writel(NVREG_TX_DEFERRAL_DEFAULT, base + NvRegTxDeferral);
+	writel(NVREG_RX_DEFERRAL_DEFAULT, base + NvRegRxDeferral);
 	if (poll_interval == -1) {
 		if (optimization_mode == NV_OPTIMIZATION_MODE_THROUGHPUT)
 			writel(NVREG_POLL_DEFAULT_THROUGHPUT, base + NvRegPollingInterval);

--------------040704080309080100040706--
