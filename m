From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/2] tg3: Scale back code that modifies MRRS
Date: Mon, 28 Nov 2011 11:41:04 -0800
Message-ID: <1322509264-19636-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4479 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753410Ab1K1Tk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 14:40:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tg3 normally gets a performance boost by increasing the PCI Maximum Read
Request Size (MRRS) to 4k.  Unfortunately, this is causing some problems
on particular hardware platforms.  This patch removes all code that
modifies the MRRS except for one case.

As part of a solution to fix an internal FIFO problem on the 5719, the
driver artificially capped the MRRS to 2k for the entire 5719, and later
5720, ASIC revs.  This was overly aggressive and only really needed to
be done for the 5719 A0.  In the spirit of the rest of this patch, the
driver will only reprogram the MRRS for this device if the value exceeds
the 2k cap.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   27 ++++++++++-----------------
 1 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0c695dc..aa413d6 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7615,15 +7615,11 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 
 	pci_write_config_word(tp->pdev, PCI_COMMAND, tp->pci_cmd);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785) {
-		if (tg3_flag(tp, PCI_EXPRESS))
-			pcie_set_readrq(tp->pdev, tp->pcie_readrq);
-		else {
-			pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
-					      tp->pci_cacheline_sz);
-			pci_write_config_byte(tp->pdev, PCI_LATENCY_TIMER,
-					      tp->pci_lat_timer);
-		}
+	if (!tg3_flag(tp, PCI_EXPRESS)) {
+		pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
+				      tp->pci_cacheline_sz);
+		pci_write_config_byte(tp->pdev, PCI_LATENCY_TIMER,
+				      tp->pci_lat_timer);
 	}
 
 	/* Make sure PCI-X relaxed ordering bit is clear. */
@@ -7808,8 +7804,6 @@ static int tg3_chip_reset(struct tg3 *tp)
 				      pci_pcie_cap(tp->pdev) + PCI_EXP_DEVCTL,
 				      val16);
 
-		pcie_set_readrq(tp->pdev, tp->pcie_readrq);
-
 		/* Clear error status */
 		pci_write_config_word(tp->pdev,
 				      pci_pcie_cap(tp->pdev) + PCI_EXP_DEVSTA,
@@ -14053,12 +14047,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 		tg3_flag_set(tp, PCI_EXPRESS);
 
-		tp->pcie_readrq = 4096;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
-			tp->pcie_readrq = 2048;
-
-		pcie_set_readrq(tp->pdev, tp->pcie_readrq);
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0) {
+			int readrq = pcie_get_readrq(tp->pdev);
+			if (readrq > 2048)
+				pcie_set_readrq(tp->pdev, 2048);
+		}
 
 		pci_read_config_word(tp->pdev,
 				     pci_pcie_cap(tp->pdev) + PCI_EXP_LNKCTL,
-- 
1.7.3.4
