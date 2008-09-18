From: Victor Gallardo <vgallardo@amcc.com>
Subject: [PATCH] ibm_newemac: Fix EMAC soft reset on 460EX/GT
Date: Thu, 18 Sep 2008 15:41:26 -0700
Message-ID: <1221777686-6181-1-git-send-email-vgallardo@amcc.com>
Cc: benh@kernel.crashing.org, jwboyer@linux.vnet.ibm.com,
	fkan@amcc.com, Victor Gallardo <vgallardo@amcc.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sdcmail02.amcc.com ([198.137.200.73]:9880 "EHLO
	sdcmail02.amcc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbYIRWle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 18:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes EMAC soft reset on 460EX/GT when no external clock is
available.

Signed-off-by: Victor Gallardo <vgallardo@amcc.com>
---
 arch/powerpc/include/asm/dcr-regs.h |    4 ++++
 drivers/net/ibm_newemac/core.c      |   18 ++++++++++++++++++
 drivers/net/ibm_newemac/core.h      |    5 +++++
 3 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/dcr-regs.h b/arch/powerpc/include/asm/dcr-regs.h
index 29b0ece..f15296c 100644
--- a/arch/powerpc/include/asm/dcr-regs.h
+++ b/arch/powerpc/include/asm/dcr-regs.h
@@ -68,6 +68,10 @@
 #define SDR0_UART3		0x0123
 #define SDR0_CUST0		0x4000
 
+/* SDRs (460EX/460GT) */
+#define SDR0_ETH_CFG		0x4103
+#define SDR0_ETH_CFG_ECS	0x00000100	/* EMAC int clk source */
+
 /*
  * All those DCR register addresses are offsets from the base address
  * for the SRAM0 controller (e.g. 0x20 on 440GX). The base address is
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 2e720f2..f6871ba 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -130,6 +130,7 @@ static inline void emac_report_timeout_error(struct emac_instance *dev,
 					     const char *error)
 {
 	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX |
+				  EMAC_FTR_460EX_PHY_CLK_FIX |
 				  EMAC_FTR_440EP_PHY_CLK_FIX))
 		DBG(dev, "%s" NL, error);
 	else if (net_ratelimit())
@@ -351,10 +352,24 @@ static int emac_reset(struct emac_instance *dev)
 		emac_tx_disable(dev);
 	}
 
+#ifdef CONFIG_PPC_DCR_NATIVE
+	/* Enable internal clock source */
+	if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_ETH_CFG,
+			    0, SDR0_ETH_CFG_ECS << dev->cell_index);
+#endif
+
 	out_be32(&p->mr0, EMAC_MR0_SRST);
 	while ((in_be32(&p->mr0) & EMAC_MR0_SRST) && n)
 		--n;
 
+#ifdef CONFIG_PPC_DCR_NATIVE
+	 /* Enable external clock source */
+	if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_ETH_CFG,
+			    SDR0_ETH_CFG_ECS << dev->cell_index, 0);
+#endif
+
 	if (n) {
 		dev->reset_failed = 0;
 		return 0;
@@ -2559,6 +2574,9 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 	/* Check EMAC version */
 	if (of_device_is_compatible(np, "ibm,emac4sync")) {
 		dev->features |= (EMAC_FTR_EMAC4 | EMAC_FTR_EMAC4SYNC);
+		if (of_device_is_compatible(np, "ibm,emac-460ex") ||
+		    of_device_is_compatible(np, "ibm,emac-460gt"))
+			dev->features |= EMAC_FTR_460EX_PHY_CLK_FIX;
 	} else if (of_device_is_compatible(np, "ibm,emac4")) {
 		dev->features |= EMAC_FTR_EMAC4;
 		if (of_device_is_compatible(np, "ibm,emac-440gx"))
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index 6545e69..5ca70e5 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -317,6 +317,10 @@ struct emac_instance {
  * The 405EX and 460EX contain the EMAC4SYNC core
  */
 #define EMAC_FTR_EMAC4SYNC		0x00000200
+/*
+ * Set if we need phy clock workaround for 460ex or 460gt
+ */
+#define EMAC_FTR_460EX_PHY_CLK_FIX	0x00000400
 
 
 /* Right now, we don't quite handle the always/possible masks on the
@@ -341,6 +345,7 @@ enum {
 #ifdef CONFIG_IBM_NEW_EMAC_RGMII
 	    EMAC_FTR_HAS_RGMII	|
 #endif
+	EMAC_FTR_460EX_PHY_CLK_FIX |
 	EMAC_FTR_440EP_PHY_CLK_FIX,
 };
 
-- 
1.5.5

