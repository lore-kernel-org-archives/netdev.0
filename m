From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH 1/1] net: stmmac: socfgpa: Ensure emac bit set in System Manger for PTP
Date: Thu,  7 Apr 2016 15:55:35 +0800
Message-ID: <1460015735-8946-2-git-send-email-preid@electromag.com.au>
References: <1460015735-8946-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203-59-230-133.perm.iinet.net.au ([203.59.230.133]:53495 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753713AbcDGIEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 04:04:53 -0400
In-Reply-To: <1460015735-8946-1-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using the PTP fpga to hps clock source for the stmmac module
the appropriate bit in the System Manager FPGA Interface Group register
needs to be set. This is not set by the bootloader setup  when the
HPS emac pins are being for this emac module.

This allows the PTP clock to be sourced from the FPGA and also connects
the PTP pps and ext trig signals to the stmmac PTP hardware.

Patch proposed by Phil Collins.

Signed-off-by: Phil Reid <preid@electromag.com.au>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index f0d797a..44022b1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -34,6 +34,9 @@
 #define SYSMGR_EMACGRP_CTRL_PHYSEL_MASK 0x00000003
 #define SYSMGR_EMACGRP_CTRL_PTP_REF_CLK_MASK 0x00000010
 
+#define SYSMGR_FPGAGRP_MODULE_REG  0x00000028
+#define SYSMGR_FPGAGRP_MODULE_EMAC 0x00000004
+
 #define EMAC_SPLITTER_CTRL_REG			0x0
 #define EMAC_SPLITTER_CTRL_SPEED_MASK		0x3
 #define EMAC_SPLITTER_CTRL_SPEED_10		0x2
@@ -148,7 +151,7 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	int phymode = dwmac->interface;
 	u32 reg_offset = dwmac->reg_offset;
 	u32 reg_shift = dwmac->reg_shift;
-	u32 ctrl, val;
+	u32 ctrl, val, module;
 
 	switch (phymode) {
 	case PHY_INTERFACE_MODE_RGMII:
@@ -175,12 +178,19 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << reg_shift);
 	ctrl |= val << reg_shift;
 
-	if (dwmac->f2h_ptp_ref_clk)
+	if (dwmac->f2h_ptp_ref_clk) {
 		ctrl |= SYSMGR_EMACGRP_CTRL_PTP_REF_CLK_MASK << (reg_shift / 2);
-	else
+		regmap_read(sys_mgr_base_addr, SYSMGR_FPGAGRP_MODULE_REG,
+			    &module);
+		module |= (SYSMGR_FPGAGRP_MODULE_EMAC << (reg_shift / 2));
+		regmap_write(sys_mgr_base_addr, SYSMGR_FPGAGRP_MODULE_REG,
+			     module);
+	} else {
 		ctrl &= ~(SYSMGR_EMACGRP_CTRL_PTP_REF_CLK_MASK << (reg_shift / 2));
+	}
 
 	regmap_write(sys_mgr_base_addr, reg_offset, ctrl);
+
 	return 0;
 }
 
-- 
1.8.3.1
