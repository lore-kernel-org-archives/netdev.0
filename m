From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 01/10] tg3: Enable PLL PD when CLKREQ disabled
 for 5717A0
Date: Wed, 20 Jan 2010 18:58:02 -0800
Message-ID: <1264042691-28284-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4718 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416Ab0AUC6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCIe PLL power down cannot be used if CLKREQ is enabled because data
corruption will occur.  If CLKREQ is disabled though, enabling PCIE P1
PLL power-down saves some power.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   16 ++++++++++++++++
 drivers/net/tg3.h |   14 ++++++++++++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b0630cd..b80e7ee 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7569,6 +7569,20 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(TG3_PCIE_LNKCTL, val | TG3_PCIE_LNKCTL_L1_PLL_PD_DIS);
 	}
 
+	if (tp->tg3_flags3 & TG3_FLG3_L1PLLPD_EN) {
+		u32 grc_mode = tr32(GRC_MODE);
+
+		/* Access the lower 1K of PL PCIE block registers. */
+		val = grc_mode & ~GRC_MODE_PCIE_PORT_MASK;
+		tw32(GRC_MODE, val | GRC_MODE_PCIE_PL_SEL);
+
+		val = tr32(TG3_PCIE_TLDLPL_PORT + TG3_PCIE_PL_LO_PHYCTL1);
+		tw32(TG3_PCIE_TLDLPL_PORT + TG3_PCIE_PL_LO_PHYCTL1,
+		     val | TG3_PCIE_PL_LO_PHYCTL1_L1PLLPD_EN);
+
+		tw32(GRC_MODE, grc_mode);
+	}
+
 	/* This works around an issue with Athlon chipsets on
 	 * B3 tigon3 silicon.  This bit has no effect on any
 	 * other revision.  But do not set this on PCI Express
@@ -13096,6 +13110,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			    tp->pci_chip_rev_id == CHIPREV_ID_57780_A0 ||
 			    tp->pci_chip_rev_id == CHIPREV_ID_57780_A1)
 				tp->tg3_flags3 |= TG3_FLG3_CLKREQ_BUG;
+		} else if (tp->pci_chip_rev_id == CHIPREV_ID_5717_A0) {
+			tp->tg3_flags3 |= TG3_FLG3_L1PLLPD_EN;
 		}
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index cd30889..44a505d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1540,6 +1540,8 @@
 #define  GRC_MODE_HOST_SENDBDS		0x00020000
 #define  GRC_MODE_NO_TX_PHDR_CSUM	0x00100000
 #define  GRC_MODE_NVRAM_WR_ENABLE	0x00200000
+#define  GRC_MODE_PCIE_TL_SEL		0x00000000
+#define  GRC_MODE_PCIE_PL_SEL		0x00400000
 #define  GRC_MODE_NO_RX_PHDR_CSUM	0x00800000
 #define  GRC_MODE_IRQ_ON_TX_CPU_ATTN	0x01000000
 #define  GRC_MODE_IRQ_ON_RX_CPU_ATTN	0x02000000
@@ -1547,7 +1549,13 @@
 #define  GRC_MODE_IRQ_ON_DMA_ATTN	0x08000000
 #define  GRC_MODE_IRQ_ON_FLOW_ATTN	0x10000000
 #define  GRC_MODE_4X_NIC_SEND_RINGS	0x20000000
+#define  GRC_MODE_PCIE_DL_SEL		0x20000000
 #define  GRC_MODE_MCAST_FRM_ENABLE	0x40000000
+#define  GRC_MODE_PCIE_HI_1K_EN		0x80000000
+#define  GRC_MODE_PCIE_PORT_MASK	(GRC_MODE_PCIE_TL_SEL | \
+					 GRC_MODE_PCIE_PL_SEL | \
+					 GRC_MODE_PCIE_DL_SEL | \
+					 GRC_MODE_PCIE_HI_1K_EN)
 #define GRC_MISC_CFG			0x00006804
 #define  GRC_MISC_CFG_CORECLK_RESET	0x00000001
 #define  GRC_MISC_CFG_PRESCALAR_MASK	0x000000fe
@@ -1801,6 +1809,11 @@
 /* 0x7e74 --> 0x8000 unused */
 
 
+/* Alternate PCIE definitions */
+#define TG3_PCIE_TLDLPL_PORT		0x00007c00
+#define TG3_PCIE_PL_LO_PHYCTL1		 0x00000004
+#define TG3_PCIE_PL_LO_PHYCTL1_L1PLLPD_EN	  0x00001000
+
 /* OTP bit definitions */
 #define TG3_OTP_AGCTGT_MASK		0x000000e0
 #define TG3_OTP_AGCTGT_SHIFT		1
@@ -2809,6 +2822,7 @@ struct tg3 {
 #define TG3_FLG3_40BIT_DMA_LIMIT_BUG	0x00100000
 #define TG3_FLG3_SHORT_DMA_BUG		0x00200000
 #define TG3_FLG3_USE_JUMBO_BDFLAG	0x00400000
+#define TG3_FLG3_L1PLLPD_EN		0x00800000
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.6.4.4


