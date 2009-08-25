From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 01/12] tg3: Fix 57780 asic rev PCIe link receiver errors
Date: Tue, 25 Aug 2009 13:06:01 -0700
Message-ID: <1251232429.25399@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3451 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755550AbZHYUeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes some PCIe link receiver errors by decreasing the internal
electrical idle timeout.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    5 +++++
 drivers/net/tg3.h |   13 +++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 46a3f86..e8def28 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6719,6 +6719,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		val |= PCIE_PWR_MGMT_EXT_ASPM_TMR_EN |
 		       PCIE_PWR_MGMT_L1_THRESH_4MS;
 		tw32(PCIE_PWR_MGMT_THRESH, val);
+
+		val = tr32(TG3_PCIE_EIDLE_DELAY) & ~TG3_PCIE_EIDLE_DELAY_MASK;
+		tw32(TG3_PCIE_EIDLE_DELAY, val | TG3_PCIE_EIDLE_DELAY_13_CLKS);
+
+		tw32(TG3_CORR_ERR_STAT, TG3_CORR_ERR_STAT_CLEAR);
 	}
 
 	/* This works around an issue with Athlon chipsets on
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b3347c4..c613cbb 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -214,9 +214,11 @@
 #define  DUAL_MAC_CTRL_ID		 0x00000004
 #define TG3PCI_PRODID_ASICREV		0x000000bc
 #define  PROD_ID_ASIC_REV_MASK		 0x0fffffff
-/* 0xc0 --> 0x100 unused */
+/* 0xc0 --> 0x110 unused */
 
-/* 0x100 --> 0x200 unused */
+#define TG3_CORR_ERR_STAT		0x00000110
+#define  TG3_CORR_ERR_STAT_CLEAR	0xffffffff
+/* 0x114 --> 0x200 unused */
 
 /* Mailbox registers */
 #define MAILBOX_INTERRUPT_0		0x00000200 /* 64-bit */
@@ -1696,11 +1698,18 @@
 #define PCIE_TRANSACTION_CFG		0x00007c04
 #define PCIE_TRANS_CFG_1SHOT_MSI	 0x20000000
 #define PCIE_TRANS_CFG_LOM		 0x00000020
+/* 0x7c08 --> 0x7d28 unused */
 
 #define PCIE_PWR_MGMT_THRESH		0x00007d28
 #define PCIE_PWR_MGMT_L1_THRESH_MSK	 0x0000ff00
 #define PCIE_PWR_MGMT_L1_THRESH_4MS	 0x0000ff00
 #define PCIE_PWR_MGMT_EXT_ASPM_TMR_EN	 0x01000000
+/* 0x7d2c --> 0x7e70 unused */
+
+#define TG3_PCIE_EIDLE_DELAY		0x00007e70
+#define  TG3_PCIE_EIDLE_DELAY_MASK	 0x0000001f
+#define  TG3_PCIE_EIDLE_DELAY_13_CLKS	 0x0000000c
+/* 0x7e74 --> 0x8000 unused */
 
 
 /* OTP bit definitions */
-- 
1.6.3.3


