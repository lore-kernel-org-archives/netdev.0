From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 08/10] r8169: fix RxMissed register access
Date: Mon, 22 Sep 2008 14:10:22 -0700
Message-ID: <200809222110.m8MLAMDB029897@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	romieu@fr.zoreil.com, edward_hsu@realtek.com.tw,
	ivecera@redhat.com, stable@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52309 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754359AbYIVVQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

- the register is defined for the 8169 chipset only and there is
  no 8169 beyond RTL_GIGA_MAC_VER_06.
- only the lower 3 bytes of the register are valid

Fixes:
1. http://bugzilla.kernel.org/show_bug.cgi?id=10180
2. http://bugzilla.kernel.org/show_bug.cgi?id=11062 (bits of)

Tested by Hermann Gausterer and Adam Huffman.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
Cc: Jeff Garzik <jeff@garzik.org>
Tested-by: Ivan Vecera <ivecera@redhat.com>
Cc: <stable@kernel.org>		[2.6.25.x, 2.6.26.x]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/r8169.c |   25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff -puN drivers/net/r8169.c~r8169-fix-rxmissed-register-access drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-fix-rxmissed-register-access
+++ a/drivers/net/r8169.c
@@ -2286,8 +2286,6 @@ static void rtl_hw_start_8168(struct net
 
 	RTL_R8(IntrMask);
 
-	RTL_W32(RxMissed, 0);
-
 	rtl_set_rx_mode(dev);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2412,8 +2410,6 @@ static void rtl_hw_start_8101(struct net
 
 	RTL_R8(IntrMask);
 
-	RTL_W32(RxMissed, 0);
-
 	rtl_set_rx_mode(dev);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -3191,6 +3187,17 @@ static int rtl8169_poll(struct napi_stru
 	return work_done;
 }
 
+static void rtl8169_rx_missed(struct net_device *dev, void __iomem *ioaddr)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	if (tp->mac_version > RTL_GIGA_MAC_VER_06)
+		return;
+
+	dev->stats.rx_missed_errors += (RTL_R32(RxMissed) & 0xffffff);
+	RTL_W32(RxMissed, 0);
+}
+
 static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3208,9 +3215,7 @@ core_down:
 
 	rtl8169_asic_down(ioaddr);
 
-	/* Update the error counts. */
-	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
 
@@ -3332,8 +3337,7 @@ static struct net_device_stats *rtl8169_
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
-		dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-		RTL_W32(RxMissed, 0);
+		rtl8169_rx_missed(dev, ioaddr);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
@@ -3358,8 +3362,7 @@ static int rtl8169_suspend(struct pci_de
 
 	rtl8169_asic_down(ioaddr);
 
-	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
 
_
