From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix WOL in power down case
Date: Sun, 9 Oct 2011 13:54:38 +0200
Message-ID: <20111009115438.GA12343@electric-eye.fr.zoreil.com>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de> <20111007210017.GA27820@electric-eye.fr.zoreil.com> <20111007214200.GA28365@electric-eye.fr.zoreil.com> <20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de> <20111007232834.GA29770@electric-eye.fr.zoreil.com> <20111009104907.0c6cd439900ca5eb7789295f@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, netdev@vger.kernel.org
To: Marc Ballarin <ballarin.marc@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59623 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab1JIL46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 07:56:58 -0400
Content-Disposition: inline
In-Reply-To: <20111009104907.0c6cd439900ca5eb7789295f@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Ballarin <ballarin.marc@gmx.de> :
> Commit 92fc43b4159b518f5baae57301f26d770b0834c9 ("r8169: modify the flow of the
> hw reset.") breaks WOL on some versions of the hardware.
> 
> Commit 106633897e086e1b47126996aac1a427eb80eb1b ("r8169: fix WOL setting for
> 8105 and 8111evl") tries to fix this, but only does so in the standby case.
> 
> This patch applies an analogous fix to the shutdown path.

Nonononono, you must dig for similar occurrences of this bug. Take a look at
r810x_pll_power_down and you will realize that RTL_GIGA_MAC_VER_{29, 30} have
the exact same problem.

Moreover, the patch duplicates a chunk of conditional code:
1) it bloats the driver (ok, we have seen worse...).
2) you can bet that both instances won't be updated if / when
   RTL_GIGA_MAC_VER_xy appears.

The patch below should fix it.

It looks like PM savings needs some love when WoL is enabled but this is a
different topic.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c236670..b53c83d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3328,22 +3328,36 @@ static void r810x_phy_power_up(struct rtl8169_private *tp)
 	rtl_writephy(tp, MII_BMCR, BMCR_ANENABLE);
 }
 
-static void r810x_pll_power_down(struct rtl8169_private *tp)
+static bool rtl_test_wol_and_enable_packets_receive(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (__rtl8169_get_wol(tp) & WAKE_ANY) {
-		rtl_writephy(tp, 0x1f, 0x0000);
-		rtl_writephy(tp, MII_BMCR, 0x0000);
+	if (!(__rtl8169_get_wol(tp) & WAKE_ANY))
+		return false;
 
-		if (tp->mac_version == RTL_GIGA_MAC_VER_29 ||
-		    tp->mac_version == RTL_GIGA_MAC_VER_30)
-			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
-				AcceptMulticast | AcceptMyPhys);
-		return;
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, MII_BMCR, 0x0000);
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
 	}
 
-	r810x_phy_power_down(tp);
+	return true;
+}
+
+static void r810x_pll_power_down(struct rtl8169_private *tp)
+{
+	if (!rtl_test_wol_and_enable_packets_receive(tp))
+		r810x_phy_power_down(tp);
 }
 
 static void r810x_pll_power_up(struct rtl8169_private *tp)
@@ -3430,17 +3444,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
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
+	if (rtl_test_wol_and_enable_packets_receive(tp))
 		return;
-	}
 
 	r8168_phy_power_down(tp);
 
@@ -5807,10 +5812,10 @@ static void rtl_shutdown(struct pci_dev *pdev)
 
 	if (system_state == SYSTEM_POWER_OFF) {
 		/* WoL fails with 8168b when the receiver is disabled. */
-		if ((tp->mac_version == RTL_GIGA_MAC_VER_11 ||
+		if (rtl_test_wol_and_enable_packets_receive(tp) &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
 		     tp->mac_version == RTL_GIGA_MAC_VER_12 ||
-		     tp->mac_version == RTL_GIGA_MAC_VER_17) &&
-		    (tp->features & RTL_FEATURE_WOL)) {
+		     tp->mac_version == RTL_GIGA_MAC_VER_17)) {
 			pci_clear_master(pdev);
 
 			RTL_W8(ChipCmd, CmdRxEnb);
