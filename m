From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/8] tg3: Fix io failures after chip reset
Date: Wed, 20 Jul 2011 13:20:50 -0700
Message-ID: <1311193257-20531-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2241 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695Ab1GTUTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 16:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f2096f94b514d88593355995d5dd276961e88af1, entitled
"tg3: Add 5720 H2BMC support", needed to add code to preserve some bits
set by firmware.  Unfortunately the new code causes throughput to stop
after a chip reset because it enables state machines before they are
ready.  This patch undoes the problematic code.  The bits will be
restored later in the init sequence.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a5ff82d..5bf7671 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7412,16 +7412,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tw32(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
 	}
 
-	if (tg3_flag(tp, ENABLE_APE))
-		tp->mac_mode = MAC_MODE_APE_TX_EN |
-			       MAC_MODE_APE_RX_EN |
-			       MAC_MODE_TDE_ENABLE;
-
 	if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES) {
-		tp->mac_mode |= MAC_MODE_PORT_MODE_TBI;
+		tp->mac_mode = MAC_MODE_PORT_MODE_TBI;
 		val = tp->mac_mode;
 	} else if (tp->phy_flags & TG3_PHYFLG_MII_SERDES) {
-		tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
+		tp->mac_mode = MAC_MODE_PORT_MODE_GMII;
 		val = tp->mac_mode;
 	} else
 		val = 0;
@@ -8559,12 +8554,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		udelay(10);
 	}
 
-	if (tg3_flag(tp, ENABLE_APE))
-		tp->mac_mode = MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
-	else
-		tp->mac_mode = 0;
 	tp->mac_mode |= MAC_MODE_TXSTAT_ENABLE | MAC_MODE_RXSTAT_ENABLE |
-		MAC_MODE_TDE_ENABLE | MAC_MODE_RDE_ENABLE | MAC_MODE_FHDE_ENABLE;
+			MAC_MODE_TDE_ENABLE | MAC_MODE_RDE_ENABLE |
+			MAC_MODE_FHDE_ENABLE;
+	if (tg3_flag(tp, ENABLE_APE))
+		tp->mac_mode |= MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
 	if (!tg3_flag(tp, 5705_PLUS) &&
 	    !(tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700)
-- 
1.7.3.4


