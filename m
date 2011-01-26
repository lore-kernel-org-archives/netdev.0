From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 01/11] tg3: Revise 5719 internal FIFO overflow
 solution
Date: Tue, 25 Jan 2011 17:58:47 -0800
Message-ID: <1296007137-23146-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3912 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940Ab1AZB7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cf79003d598b1f82a4caa0564107283b4f560e14, entitled
"tg3: Fix 5719 internal FIFO overflow problem", proposed a way to solve
an internal FIFO overflow problem.  We have since discovered a slightly
better way to solve the problem.  This patch changes the code so that
the problem is contained closer to the problem source.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   46 ++++++++--------------------------------------
 drivers/net/tg3.h |    4 ++++
 2 files changed, 12 insertions(+), 38 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e3d80c9..07d4e61 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8227,8 +8227,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
 		val = tr32(TG3_RDMA_RSRVCTRL_REG);
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
-			val &= ~TG3_RDMA_RSRVCTRL_TXMRGN_MASK;
-			val |= TG3_RDMA_RSRVCTRL_TXMRGN_320B;
+			val &= ~(TG3_RDMA_RSRVCTRL_TXMRGN_MASK |
+				 TG3_RDMA_RSRVCTRL_FIFO_LWM_MASK |
+				 TG3_RDMA_RSRVCTRL_FIFO_HWM_MASK);
+			val |= TG3_RDMA_RSRVCTRL_TXMRGN_320B |
+			       TG3_RDMA_RSRVCTRL_FIFO_LWM_1_5K |
+			       TG3_RDMA_RSRVCTRL_FIFO_HWM_1_5K;
 		}
 		tw32(TG3_RDMA_RSRVCTRL_REG,
 		     val | TG3_RDMA_RSRVCTRL_FIFO_OFLW_FIX);
@@ -13394,42 +13398,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
 
 		tp->pcie_readrq = 4096;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
-			u16 word;
-
-			pci_read_config_word(tp->pdev,
-					     tp->pcie_cap + PCI_EXP_LNKSTA,
-					     &word);
-			switch (word & PCI_EXP_LNKSTA_CLS) {
-			case PCI_EXP_LNKSTA_CLS_2_5GB:
-				word &= PCI_EXP_LNKSTA_NLW;
-				word >>= PCI_EXP_LNKSTA_NLW_SHIFT;
-				switch (word) {
-				case 2:
-					tp->pcie_readrq = 2048;
-					break;
-				case 4:
-					tp->pcie_readrq = 1024;
-					break;
-				}
-				break;
-
-			case PCI_EXP_LNKSTA_CLS_5_0GB:
-				word &= PCI_EXP_LNKSTA_NLW;
-				word >>= PCI_EXP_LNKSTA_NLW_SHIFT;
-				switch (word) {
-				case 1:
-					tp->pcie_readrq = 2048;
-					break;
-				case 2:
-					tp->pcie_readrq = 1024;
-					break;
-				case 4:
-					tp->pcie_readrq = 512;
-					break;
-				}
-			}
-		}
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+			tp->pcie_readrq = 2048;
 
 		pcie_set_readrq(tp->pdev, tp->pcie_readrq);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d62c8d9..0a0987a 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1333,6 +1333,10 @@
 
 #define TG3_RDMA_RSRVCTRL_REG		0x00004900
 #define TG3_RDMA_RSRVCTRL_FIFO_OFLW_FIX	 0x00000004
+#define TG3_RDMA_RSRVCTRL_FIFO_LWM_1_5K	 0x00000c00
+#define TG3_RDMA_RSRVCTRL_FIFO_LWM_MASK	 0x00000ff0
+#define TG3_RDMA_RSRVCTRL_FIFO_HWM_1_5K	 0x000c0000
+#define TG3_RDMA_RSRVCTRL_FIFO_HWM_MASK	 0x000ff000
 #define TG3_RDMA_RSRVCTRL_TXMRGN_320B	 0x28000000
 #define TG3_RDMA_RSRVCTRL_TXMRGN_MASK	 0xffe00000
 /* 0x4904 --> 0x4910 unused */
-- 
1.7.2.2


