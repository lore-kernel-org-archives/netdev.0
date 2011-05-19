From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 03/13] tg3: Fix 57765 B0 data corruption
Date: Thu, 19 May 2011 15:12:46 -0700
Message-ID: <1305843176-32358-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1070 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933137Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIe max FTS limit is too aggressive on these chips.  This patch
loosens the limit a little to eliminate data corruption issues.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   16 ++++++++++++++++
 drivers/net/tg3.h |    4 ++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b2b1ba1..09f2c11 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7990,6 +7990,22 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			tw32(GRC_MODE, grc_mode);
 		}
 
+		if (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_57765_AX) {
+			u32 grc_mode = tr32(GRC_MODE);
+
+			/* Access the lower 1K of DL PCIE block registers. */
+			val = grc_mode & ~GRC_MODE_PCIE_PORT_MASK;
+			tw32(GRC_MODE, val | GRC_MODE_PCIE_DL_SEL);
+
+			val = tr32(TG3_PCIE_TLDLPL_PORT +
+				   TG3_PCIE_DL_LO_FTSMAX);
+			val &= ~TG3_PCIE_DL_LO_FTSMAX_MSK;
+			tw32(TG3_PCIE_TLDLPL_PORT + TG3_PCIE_DL_LO_FTSMAX,
+			     val | TG3_PCIE_DL_LO_FTSMAX_VAL);
+
+			tw32(GRC_MODE, grc_mode);
+		}
+
 		val = tr32(TG3_CPMU_LSPD_10MB_CLK);
 		val &= ~CPMU_LSPD_10MB_MACCLK_MASK;
 		val |= CPMU_LSPD_10MB_MACCLK_6_25;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ce010cd3..330959b 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -180,6 +180,7 @@
 #define   CHIPREV_5750_BX		 0x41
 #define   CHIPREV_5784_AX		 0x57840
 #define   CHIPREV_5761_AX		 0x57610
+#define   CHIPREV_57765_AX		 0x577650
 #define  GET_METAL_REV(CHIP_REV_ID)	((CHIP_REV_ID) & 0xff)
 #define   METAL_REV_A0			 0x00
 #define   METAL_REV_A1			 0x01
@@ -1951,6 +1952,9 @@
 
 /* Alternate PCIE definitions */
 #define TG3_PCIE_TLDLPL_PORT		0x00007c00
+#define TG3_PCIE_DL_LO_FTSMAX		0x0000000c
+#define TG3_PCIE_DL_LO_FTSMAX_MSK	0x000000ff
+#define TG3_PCIE_DL_LO_FTSMAX_VAL	0x0000002c
 #define TG3_PCIE_PL_LO_PHYCTL1		 0x00000004
 #define TG3_PCIE_PL_LO_PHYCTL1_L1PLLPD_EN	  0x00001000
 #define TG3_PCIE_PL_LO_PHYCTL5		 0x00000014
-- 
1.7.3.4


