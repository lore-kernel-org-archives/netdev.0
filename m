From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/2] forcedeth: watermark fixup
Date: Thu, 06 Jul 2006 16:46:25 -0400
Message-ID: <44AD76A1.40107@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030101070501050208050602"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:25405 "EHLO
	HQEMGATE02.nvidia.com") by vger.kernel.org with ESMTP
	id S1751000AbWGFWzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 18:55:25 -0400
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030101070501050208050602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch defines the watermark registers and fixes up the use of this 
register.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030101070501050208050602
Content-Type: text/plain;
 name="patch-forcedeth-watermark"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-watermark"

--- orig-2.6/drivers/net/forcedeth.c	2006-07-06 15:04:39.000000000 -0400
+++ new-2.6/drivers/net/forcedeth.c	2006-07-06 15:05:00.000000000 -0400
@@ -271,8 +271,10 @@
 #define NVREG_LINKSPEED_MASK	(0xFFF)
 	NvRegUnknownSetupReg5 = 0x130,
 #define NVREG_UNKSETUP5_BIT31	(1<<31)
-	NvRegUnknownSetupReg3 = 0x13c,
-#define NVREG_UNKSETUP3_VAL1	0x200010
+	NvRegTxWatermark = 0x13c,
+#define NVREG_TX_WM_DESC1_DEFAULT	0x0200010
+#define NVREG_TX_WM_DESC2_3_DEFAULT	0x1e08000
+#define NVREG_TX_WM_DESC2_3_1000	0xfe08000
 	NvRegTxRxControl = 0x144,
 #define NVREG_TXRXCTL_KICK	0x0001
 #define NVREG_TXRXCTL_BIT1	0x0002
@@ -660,7 +662,7 @@
 	{ NvRegMisc1, 0x03c },
 	{ NvRegOffloadConfig, 0x03ff },
 	{ NvRegMulticastAddrA, 0xffffffff },
-	{ NvRegUnknownSetupReg3, 0x0ff },
+	{ NvRegTxWatermark, 0x0ff },
 	{ NvRegWakeUpFlags, 0x07777 },
 	{ 0,0 }
 };
@@ -2257,6 +2259,16 @@
 	}
 	writel(txreg, base + NvRegTxDeferral);
 
+	if (np->desc_ver == DESC_VER_1) {
+		txreg = NVREG_TX_WM_DESC1_DEFAULT;
+	} else {
+		if ((np->linkspeed & NVREG_LINKSPEED_MASK) == NVREG_LINKSPEED_1000)
+			txreg = NVREG_TX_WM_DESC2_3_1000;
+		else
+			txreg = NVREG_TX_WM_DESC2_3_DEFAULT;
+	}
+	writel(txreg, base + NvRegTxWatermark);
+
 	writel(NVREG_MISC1_FORCE | ( np->duplex ? 0 : NVREG_MISC1_HD),
 		base + NvRegMisc1);
 	pci_push(base);
@@ -3922,7 +3934,10 @@
 
 	/* 5) continue setup */
 	writel(np->linkspeed, base + NvRegLinkSpeed);
-	writel(NVREG_UNKSETUP3_VAL1, base + NvRegUnknownSetupReg3);
+	if (np->desc_ver == DESC_VER_1)
+		writel(NVREG_TX_WM_DESC1_DEFAULT, base + NvRegTxWatermark);
+	else
+		writel(NVREG_TX_WM_DESC2_3_DEFAULT, base + NvRegTxWatermark);
 	writel(np->txrxctl_bits, base + NvRegTxRxControl);
 	writel(np->vlanctl_bits, base + NvRegVlanControl);
 	pci_push(base);

--------------030101070501050208050602--
