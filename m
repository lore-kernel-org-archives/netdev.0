From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 03/10] tg3: Always turn on APE features in
 mac_mode reg
Date: Wed, 24 Nov 2010 10:31:47 -0800
Message-ID: <1290623514-18193-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3929 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753985Ab0KXScN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:32:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The APE needs certain bits in the mac_mode register to be enabled for
traffic to flow correctly.  This patch changes the code to always enable
these bits in the presence of the APE.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   37 ++++++++++++++++++-------------------
 1 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4dc0756..2624d71 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2728,12 +2728,10 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)))
 			mac_mode |= MAC_MODE_KEEP_FRAME_IN_WOL;
 
-		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
-			mac_mode |= tp->mac_mode &
-				    (MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN);
-			if (mac_mode & MAC_MODE_APE_TX_EN)
-				mac_mode |= MAC_MODE_TDE_ENABLE;
-		}
+		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+			mac_mode |= MAC_MODE_APE_TX_EN |
+				    MAC_MODE_APE_RX_EN |
+				    MAC_MODE_TDE_ENABLE;
 
 		tw32_f(MAC_MODE, mac_mode);
 		udelay(100);
@@ -7222,19 +7220,21 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tw32(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
 	}
 
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+		tp->mac_mode = MAC_MODE_APE_TX_EN |
+			       MAC_MODE_APE_RX_EN |
+			       MAC_MODE_TDE_ENABLE;
+
 	if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES) {
-		tp->mac_mode = MAC_MODE_PORT_MODE_TBI;
-		tw32_f(MAC_MODE, tp->mac_mode);
+		tp->mac_mode |= MAC_MODE_PORT_MODE_TBI;
+		val = tp->mac_mode;
 	} else if (tp->phy_flags & TG3_PHYFLG_MII_SERDES) {
-		tp->mac_mode = MAC_MODE_PORT_MODE_GMII;
-		tw32_f(MAC_MODE, tp->mac_mode);
-	} else if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
-		tp->mac_mode &= (MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN);
-		if (tp->mac_mode & MAC_MODE_APE_TX_EN)
-			tp->mac_mode |= MAC_MODE_TDE_ENABLE;
-		tw32_f(MAC_MODE, tp->mac_mode);
+		tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
+		val = tp->mac_mode;
 	} else
-		tw32_f(MAC_MODE, 0);
+		val = 0;
+
+	tw32_f(MAC_MODE, val);
 	udelay(40);
 
 	tg3_ape_unlock(tp, TG3_APE_LOCK_GRC);
@@ -8287,7 +8287,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	}
 
 	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
-		tp->mac_mode &= MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
+		tp->mac_mode = MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
 	else
 		tp->mac_mode = 0;
 	tp->mac_mode |= MAC_MODE_TXSTAT_ENABLE | MAC_MODE_RXSTAT_ENABLE |
@@ -13729,8 +13729,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	/* Preserve the APE MAC_MODE bits */
 	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
-		tp->mac_mode = tr32(MAC_MODE) |
-			       MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
+		tp->mac_mode = MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
 	else
 		tp->mac_mode = TG3_DEF_MAC_MODE;
 
-- 
1.7.2.2


