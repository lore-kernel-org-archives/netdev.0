From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/6] tg3: Fix 57765 EEE support
Date: Mon, 6 Dec 2010 10:28:51 -0800
Message-ID: <1291660134-3801-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2564 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754319Ab0LFS3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 13:29:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEE support in the 57765 internal phy will not enable after a phy reset
unless it sees that EEE is supported in the MAC.  This patch moves the
code that programs the CPMU EEE registers to a place before the phy
reset.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1e7a135..e4efb52 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7809,6 +7809,22 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (tp->tg3_flags & TG3_FLAG_INIT_COMPLETE)
 		tg3_abort_hw(tp, 1);
 
+	/* Enable MAC control of LPI */
+	if (tp->phy_flags & TG3_PHYFLG_EEE_CAP) {
+		tw32_f(TG3_CPMU_EEE_LNKIDL_CTRL,
+		       TG3_CPMU_EEE_LNKIDL_PCIE_NL0 |
+		       TG3_CPMU_EEE_LNKIDL_UART_IDL);
+
+		tw32_f(TG3_CPMU_EEE_CTRL,
+		       TG3_CPMU_EEE_CTRL_EXIT_20_1_US);
+
+		tw32_f(TG3_CPMU_EEE_MODE,
+		       TG3_CPMU_EEEMD_ERLY_L1_XIT_DET |
+		       TG3_CPMU_EEEMD_LPI_IN_TX |
+		       TG3_CPMU_EEEMD_LPI_IN_RX |
+		       TG3_CPMU_EEEMD_EEE_ENABLE);
+	}
+
 	if (reset_phy)
 		tg3_phy_reset(tp);
 
@@ -7890,22 +7906,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(TG3_CPMU_LSPD_10MB_CLK, val);
 	}
 
-	/* Enable MAC control of LPI */
-	if (tp->phy_flags & TG3_PHYFLG_EEE_CAP) {
-		tw32_f(TG3_CPMU_EEE_LNKIDL_CTRL,
-		       TG3_CPMU_EEE_LNKIDL_PCIE_NL0 |
-		       TG3_CPMU_EEE_LNKIDL_UART_IDL);
-
-		tw32_f(TG3_CPMU_EEE_CTRL,
-		       TG3_CPMU_EEE_CTRL_EXIT_20_1_US);
-
-		tw32_f(TG3_CPMU_EEE_MODE,
-		       TG3_CPMU_EEEMD_ERLY_L1_XIT_DET |
-		       TG3_CPMU_EEEMD_LPI_IN_TX |
-		       TG3_CPMU_EEEMD_LPI_IN_RX |
-		       TG3_CPMU_EEEMD_EEE_ENABLE);
-	}
-
 	/* This works around an issue with Athlon chipsets on
 	 * B3 tigon3 silicon.  This bit has no effect on any
 	 * other revision.  But do not set this on PCI Express
-- 
1.7.2.2


