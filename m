From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: fix driver shutdown WoL regression.
Date: Fri, 14 Oct 2011 12:57:45 +0200
Message-ID: <20111014105745.GA11204@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Ballarin <ballarin.marc@gmx.de>,
	David Miller <davem@davemloft.net>,
	Hayes <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39878 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325Ab1JNLAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 07:00:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to commit 92fc43b4159b518f5baae57301f26d770b0834c9 ("r8169: modify the
flow of the hw reset."), rtl8169_hw_reset stomps during driver shutdown on
RxConfig bits which are needed for WOL on some versions of the hardware.

As these bits were formerly set from the r81{0x, 68}_pll_power_down methods,
factor them out for use in the driver shutdown (rtl_shutdown) handler.

I favored __rtl8169_get_wol() -hardware state indication- over
RTL_FEATURE_WOL as the latter has become a good candidate for removal.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---

  Marc, can you add your Tested-by: to this patch ? It avoids the extra
  phy writes which were included in the previous revision of the patch.
  They did not happen before the regression so there is no reason to
  sneak them in -release. Works ok with RTL_GIGA_MAC_VER_34.

 drivers/net/r8169.c |   88 ++++++++++++++++++++++++++++++++------------------
 1 files changed, 56 insertions(+), 32 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c236670..24219ec 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3316,6 +3316,37 @@ static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
 	}
 }
 
+static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_29:
+	case RTL_GIGA_MAC_VER_30:
+	case RTL_GIGA_MAC_VER_32:
+	case RTL_GIGA_MAC_VER_33:
+	case RTL_GIGA_MAC_VER_34:
+		RTL_W32(RxConfig, RTL_R32(RxConfig) |
+			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
+		break;
+	default:
+		break;
+	}
+}
+
+static bool rtl_wol_pll_power_down(struct rtl8169_private *tp)
+{
+	if (!(__rtl8169_get_wol(tp) & WAKE_ANY))
+		return false;
+
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, MII_BMCR, 0x0000);
+
+	rtl_wol_suspend_quirk(tp);
+
+	return true;
+}
+
 static void r810x_phy_power_down(struct rtl8169_private *tp)
 {
 	rtl_writephy(tp, 0x1f, 0x0000);
@@ -3330,18 +3361,8 @@ static void r810x_phy_power_up(struct rtl8169_private *tp)
 
 static void r810x_pll_power_down(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	if (__rtl8169_get_wol(tp) & WAKE_ANY) {
-		rtl_writephy(tp, 0x1f, 0x0000);
-		rtl_writephy(tp, MII_BMCR, 0x0000);
-
-		if (tp->mac_version == RTL_GIGA_MAC_VER_29 ||
-		    tp->mac_version == RTL_GIGA_MAC_VER_30)
-			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
-				AcceptMulticast | AcceptMyPhys);
+	if (rtl_wol_pll_power_down(tp))
 		return;
-	}
 
 	r810x_phy_power_down(tp);
 }
@@ -3430,17 +3451,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	    tp->mac_version == RTL_GIGA_MAC_VER_33)
 		rtl_ephy_write(ioaddr, 0x19, 0xff64);
 
-	if (__rtl8169_get_wol(tp) & WAKE_ANY) {
-		rtl_writephy(tp, 0x1f, 0x0000);
-		rtl_writephy(tp, MII_BMCR, 0x0000);
-
-		if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
-		    tp->mac_version == RTL_GIGA_MAC_VER_33 ||
-		    tp->mac_version == RTL_GIGA_MAC_VER_34)
-			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
-				AcceptMulticast | AcceptMyPhys);
+	if (rtl_wol_pll_power_down(tp))
 		return;
-	}
 
 	r8168_phy_power_down(tp);
 
@@ -5788,11 +5800,30 @@ static const struct dev_pm_ops rtl8169_pm_ops = {
 
 #endif /* !CONFIG_PM */
 
+static void rtl_wol_shutdown_quirk(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	/* WoL fails with 8168b when the receiver is disabled. */
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+		pci_clear_master(tp->pci_dev);
+
+		RTL_W8(ChipCmd, CmdRxEnb);
+		/* PCI commit */
+		RTL_R8(ChipCmd);
+		break;
+	default:
+		break;
+	}
+}
+
 static void rtl_shutdown(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 
 	rtl8169_net_suspend(dev);
 
@@ -5806,16 +5837,9 @@ static void rtl_shutdown(struct pci_dev *pdev)
 	spin_unlock_irq(&tp->lock);
 
 	if (system_state == SYSTEM_POWER_OFF) {
-		/* WoL fails with 8168b when the receiver is disabled. */
-		if ((tp->mac_version == RTL_GIGA_MAC_VER_11 ||
-		     tp->mac_version == RTL_GIGA_MAC_VER_12 ||
-		     tp->mac_version == RTL_GIGA_MAC_VER_17) &&
-		    (tp->features & RTL_FEATURE_WOL)) {
-			pci_clear_master(pdev);
-
-			RTL_W8(ChipCmd, CmdRxEnb);
-			/* PCI commit */
-			RTL_R8(ChipCmd);
+		if (__rtl8169_get_wol(tp) & WAKE_ANY) {
+			rtl_wol_suspend_quirk(tp);
+			rtl_wol_shutdown_quirk(tp);
 		}
 
 		pci_wake_from_d3(pdev, true);
-- 
1.7.6.4
