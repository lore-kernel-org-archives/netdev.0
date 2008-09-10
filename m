From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] r8169: fix RxMissed register access
Date: Wed, 10 Sep 2008 22:28:56 +0200
Message-ID: <20080910202856.GA22884@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Adam Huffman <bloch@verdurin.com>,
	Hermann Gausterer <kernel-bug-tracker@mrq1.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ivan Vecera <ivecera@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41268 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752086AbYIJUbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 16:31:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- the register is defined for the 8169 chipset only and there is
  no 8169 beyond RTL_GIGA_MAC_VER_06.
- only the lower 3 bytes of the register are valid

Fixes:
1. http://bugzilla.kernel.org/show_bug.cgi?id=10180
2. http://bugzilla.kernel.org/show_bug.cgi?id=11062 (bits of)

Tested by Hermann Gausterer and Adam Huffman.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0f6f974..4190ee7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2099,8 +2099,6 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_R8(IntrMask);
 
-	RTL_W32(RxMissed, 0);
-
 	rtl_set_rx_mode(dev);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2143,8 +2141,6 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_R8(IntrMask);
 
-	RTL_W32(RxMissed, 0);
-
 	rtl_set_rx_mode(dev);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2922,6 +2918,17 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
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
@@ -2939,9 +2946,7 @@ core_down:
 
 	rtl8169_asic_down(ioaddr);
 
-	/* Update the error counts. */
-	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
 
@@ -3063,8 +3068,7 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
-		dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-		RTL_W32(RxMissed, 0);
+		rtl8169_rx_missed(dev, ioaddr);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
@@ -3089,8 +3093,7 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	rtl8169_asic_down(ioaddr);
 
-	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
 
-- 
1.5.3.3
