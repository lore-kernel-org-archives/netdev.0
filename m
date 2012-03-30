From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 1/5] r8169: modify pll power function
Date: Fri, 30 Mar 2012 14:33:00 +0800
Message-ID: <1333089184-1773-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:32922 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab2C3G2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 02:28:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust r810x_pll_power_down, r810x_pll_power_up, and r8168_pll_power_up.
Always power up device during rtl_open. For r810x, turn off more power
when the WOL is disabled.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   37 +++++++++++++++++++++++++++------
 1 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 27c358c..3edb996 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3508,15 +3508,45 @@ static void r810x_phy_power_up(struct rtl8169_private *tp)
 
 static void r810x_pll_power_down(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	if (rtl_wol_pll_power_down(tp))
 		return;
 
 	r810x_phy_power_down(tp);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+	case RTL_GIGA_MAC_VER_10:
+	case RTL_GIGA_MAC_VER_13:
+	case RTL_GIGA_MAC_VER_16:
+		break;
+	default:
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
+		break;
+	}
 }
 
 static void r810x_pll_power_up(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	r810x_phy_power_up(tp);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+	case RTL_GIGA_MAC_VER_10:
+	case RTL_GIGA_MAC_VER_13:
+	case RTL_GIGA_MAC_VER_16:
+		break;
+	default:
+		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
+		break;
+	}
 }
 
 static void r8168_phy_power_up(struct rtl8169_private *tp)
@@ -3620,13 +3650,6 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
-	    r8168dp_check_dash(tp)) {
-		return;
-	}
-
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
-- 
1.7.7.6
