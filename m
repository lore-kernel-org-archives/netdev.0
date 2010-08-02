From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 04/14] tg3: Don't access phy test ctrl reg for
 5717+
Date: Mon, 2 Aug 2010 14:25:58 -0700
Message-ID: <1280784368-4226-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2889 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab0HBV0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy test register location has been repurposed for 5717+ devices.
This patch changes the code to avoid this location for these devices.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   10 +++++++---
 drivers/net/tg3.h |    4 ++++
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7892b00..5d155c5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6929,9 +6929,13 @@ static int tg3_chip_reset(struct tg3 *tp)
 	val = GRC_MISC_CFG_CORECLK_RESET;
 
 	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
-		if (tr32(0x7e2c) == 0x60) {
-			tw32(0x7e2c, 0x20);
-		}
+		/* Force PCIe 1.0a mode */
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
+		    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+		    tr32(TG3_PCIE_PHY_TSTCTL) ==
+		    (TG3_PCIE_PHY_TSTCTL_PCIE10 | TG3_PCIE_PHY_TSTCTL_PSCRAM))
+			tw32(TG3_PCIE_PHY_TSTCTL, TG3_PCIE_PHY_TSTCTL_PSCRAM);
+
 		if (tp->pci_chip_rev_id != CHIPREV_ID_5750_A0) {
 			tw32(GRC_MISC_CFG, (1 << 29));
 			val |= (1 << 29);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a544045..a7b8ec7 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1844,6 +1844,10 @@
 #define  TG3_PCIE_LNKCTL_L1_PLL_PD_DIS	 0x00000080
 /* 0x7d58 --> 0x7e70 unused */
 
+#define TG3_PCIE_PHY_TSTCTL		0x00007e2c
+#define  TG3_PCIE_PHY_TSTCTL_PCIE10	 0x00000040
+#define  TG3_PCIE_PHY_TSTCTL_PSCRAM	 0x00000020
+
 #define TG3_PCIE_EIDLE_DELAY		0x00007e70
 #define  TG3_PCIE_EIDLE_DELAY_MASK	 0x0000001f
 #define  TG3_PCIE_EIDLE_DELAY_13_CLKS	 0x0000000c
-- 
1.7.1


