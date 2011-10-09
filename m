From: Marc Ballarin <ballarin.marc@gmx.de>
Subject: [PATCH] r8169: Fix WOL in power down case
Date: Sun, 9 Oct 2011 10:49:07 +0200
Message-ID: <20111009104907.0c6cd439900ca5eb7789295f@gmx.de>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de>
	<20111007210017.GA27820@electric-eye.fr.zoreil.com>
	<20111007214200.GA28365@electric-eye.fr.zoreil.com>
	<20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de>
	<20111007232834.GA29770@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:35712 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750975Ab1JIItM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 04:49:12 -0400
In-Reply-To: <20111007232834.GA29770@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 92fc43b4159b518f5baae57301f26d770b0834c9 ("r8169: modify the flow of the
hw reset.") breaks WOL on some versions of the hardware.

Commit 106633897e086e1b47126996aac1a427eb80eb1b ("r8169: fix WOL setting for
8105 and 8111evl") tries to fix this, but only does so in the standby case.

This patch applies an analogous fix to the shutdown path.

Signed-off-by: Marc Ballarin <ballarin.marc@gmx.de>

---

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c236670..a2d6e3a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -5817,6 +5817,15 @@ static void rtl_shutdown(struct pci_dev *pdev)
 			/* PCI commit */
 			RTL_R8(ChipCmd);
 		}
+		/* rtl8105, rtl8111E, and rtl8111evl need the following bits
+		 * set for WOL to work */
+		if ((tp->mac_version == RTL_GIGA_MAC_VER_32 ||
+		     tp->mac_version == RTL_GIGA_MAC_VER_33 ||
+		     tp->mac_version == RTL_GIGA_MAC_VER_34) &&
+		    (__rtl8169_get_wol(tp) & WAKE_ANY)) {
+			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
+			  AcceptMulticast | AcceptMyPhys);
+		}
 
 		pci_wake_from_d3(pdev, true);
 		pci_set_power_state(pdev, PCI_D3hot);
