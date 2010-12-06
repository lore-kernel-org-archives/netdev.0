From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/6] tg3: Minor EEE code tweaks
Date: Mon, 6 Dec 2010 10:28:52 -0800
Message-ID: <1291660134-3801-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4142 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368Ab0LFS3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 13:29:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first hunk of this patch makes sure that the driver checks for the
appropriate preconditions before checking if EEE negotiation succeeded.
More specifically the link needs to be full duplex for EEE to be
enabled.

The second and third hunks of this patch fix a bug where the eee
advertisement register would be programmed with extra bits set.

The fourth hunk of this patch makes sure the EEE capability flag is not
set for 5718 A0 devices and that the device is not a serdes device.

None of these modifications are strictly necessary.  The driver /
hardware still does the right thing.  They are submitted primarily for
correctness.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e4efb52..81dafc2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1770,9 +1770,9 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 
 	if (tp->link_config.autoneg == AUTONEG_ENABLE &&
 	    current_link_up == 1 &&
-	    (tp->link_config.active_speed == SPEED_1000 ||
-	     (tp->link_config.active_speed == SPEED_100 &&
-	      tp->link_config.active_duplex == DUPLEX_FULL))) {
+	    tp->link_config.active_duplex == DUPLEX_FULL &&
+	    (tp->link_config.active_speed == SPEED_100 ||
+	     tp->link_config.active_speed == SPEED_1000)) {
 		u32 eeectl;
 
 		if (tp->link_config.active_speed == SPEED_1000)
@@ -2969,7 +2969,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 	}
 
 	if (tp->phy_flags & TG3_PHYFLG_EEE_CAP) {
-		u32 val = 0;
+		u32 val;
 
 		tw32(TG3_CPMU_EEE_MODE,
 		     tr32(TG3_CPMU_EEE_MODE) & ~TG3_CPMU_EEEMD_LPI_ENABLE);
@@ -2986,6 +2986,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 			tg3_phydsp_write(tp, MII_TG3_DSP_CH34TP2,
 					 val | MII_TG3_DSP_CH34TP2_HIBW01);
 
+		val = 0;
 		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
 			/* Advertise 100-BaseTX EEE ability */
 			if (tp->link_config.advertising &
@@ -12569,9 +12570,11 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 		}
 	}
 
-	if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
-	     tp->pci_chip_rev_id != CHIPREV_ID_57765_A0))
+	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
+	    ((tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 &&
+	      tp->pci_chip_rev_id != CHIPREV_ID_5717_A0) ||
+	     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
+	      tp->pci_chip_rev_id != CHIPREV_ID_57765_A0)))
 		tp->phy_flags |= TG3_PHYFLG_EEE_CAP;
 
 	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
-- 
1.7.2.2


