From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/7] r8169: modify pll power function
Date: Tue, 17 Apr 2012 12:59:37 +0200
Message-ID: <0004299ad41885a0a1fd321715fe7396be17ce35.1334660032.git.romieu@fr.zoreil.com>
References: <1334660032.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37858 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754604Ab2DQLE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 07:04:26 -0400
In-Reply-To: <1334660032.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>

Adjust r810x_pll_power_down, r810x_pll_power_up, and r8168_pll_power_up.
Always power up device during rtl_open. For r810x, turn off more power
when the WOL is disabled.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   37 +++++++++++++++++++++++++++------
 1 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 207aadc..d9bae30 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3525,15 +3525,45 @@ static void r810x_phy_power_up(struct rtl8169_private *tp)
 
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
@@ -3637,13 +3667,6 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
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
