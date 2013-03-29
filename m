From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH] r8169: fix auto speed down issue
Date: Fri, 29 Mar 2013 15:11:02 +0800
Message-ID: <1364541062-9024-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bowgotsai@google.com>, Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:50967 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab3C2HLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 03:11:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It would cause no link after suspending or shutdowning when the
nic changes the speed to 10M and connects to a link partner which
forces the speed to 100M.

Check the link partner ability to determine if to change the speed
to 10M when suspending or shutdowning. Regardless of keeping the
speed to giga for power saving.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 28fb50a..a9eedf7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3818,6 +3818,21 @@ static void rtl_init_mdio_ops(struct rtl8169_private *tp)
 	}
 }
 
+static void rtl_speed_down(struct rtl8169_private *tp)
+{
+	u32	adv;
+	int	lpa;
+
+	rtl_writephy(tp, 0x1f, 0x0000);
+	lpa = rtl_readphy(tp, MII_LPA);
+
+	adv = ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full;
+	if (!(lpa & (ADVERTISE_10HALF | ADVERTISE_10FULL)))
+		adv |= ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full;
+
+	rtl8169_set_speed(tp->dev, AUTONEG_ENABLE, SPEED_100, DUPLEX_FULL, adv);
+}
+
 static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3848,9 +3863,7 @@ static bool rtl_wol_pll_power_down(struct rtl8169_private *tp)
 	if (!(__rtl8169_get_wol(tp) & WAKE_ANY))
 		return false;
 
-	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_writephy(tp, MII_BMCR, 0x0000);
-
+	rtl_speed_down(tp);
 	rtl_wol_suspend_quirk(tp);
 
 	return true;
-- 
1.8.1
