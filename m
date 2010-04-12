From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/8] tg3: Disable CLKREQ in L2
Date: Mon, 12 Apr 2010 09:58:24 -0700
Message-ID: <1271091511-11173-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2756 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291Ab0DLQ6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 12:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch disables CLKREQ in L2 to workaround a chipset bug.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   14 ++++++++++++++
 drivers/net/tg3.h |    2 ++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 460a0c2..4ae01b3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7642,6 +7642,20 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(GRC_MODE, grc_mode);
 	}
 
+	if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0) {
+		u32 grc_mode = tr32(GRC_MODE);
+
+		/* Access the lower 1K of PL PCIE block registers. */
+		val = grc_mode & ~GRC_MODE_PCIE_PORT_MASK;
+		tw32(GRC_MODE, val | GRC_MODE_PCIE_PL_SEL);
+
+		val = tr32(TG3_PCIE_TLDLPL_PORT + TG3_PCIE_PL_LO_PHYCTL5);
+		tw32(TG3_PCIE_TLDLPL_PORT + TG3_PCIE_PL_LO_PHYCTL5,
+		     val | TG3_PCIE_PL_LO_PHYCTL5_DIS_L2CLKREQ);
+
+		tw32(GRC_MODE, grc_mode);
+	}
+
 	/* This works around an issue with Athlon chipsets on
 	 * B3 tigon3 silicon.  This bit has no effect on any
 	 * other revision.  But do not set this on PCI Express
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5d7f72a..8a6012a 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1854,6 +1854,8 @@
 #define TG3_PCIE_TLDLPL_PORT		0x00007c00
 #define TG3_PCIE_PL_LO_PHYCTL1		 0x00000004
 #define TG3_PCIE_PL_LO_PHYCTL1_L1PLLPD_EN	  0x00001000
+#define TG3_PCIE_PL_LO_PHYCTL5		 0x00000014
+#define TG3_PCIE_PL_LO_PHYCTL5_DIS_L2CLKREQ	  0x80000000
 
 /* OTP bit definitions */
 #define TG3_OTP_AGCTGT_MASK		0x000000e0
-- 
1.6.4.4


