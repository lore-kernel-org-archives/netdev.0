From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: do not bring device down when suspending
Date: Wed, 17 Jun 2009 23:41:45 +0200
Message-ID: <20090617214145.GA27064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Hsu <edward_hsu@realtek.com.tw>,
	Anders Eriksson <aeriksson@fastmail.fm>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32857 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757548AbZFQVjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 17:39:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stopping all activity through ChipCmd and blindly acking the irqs
is neither nice nor completely needed: the transition to low-power
mode does enough work and it apparently keeps the device in a sane
state.

Patch suggested by a fix for http://bugzilla.kernel.org/show_bug.cgi?id=9512

The rtl_shutdown path is kept unchanged so far.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Anders Eriksson <aeriksson@fastmail.fm>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 35196fa..4e22462 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3811,22 +3811,11 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
 static void rtl8169_net_suspend(struct net_device *dev)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-
 	if (!netif_running(dev))
 		return;
 
 	netif_device_detach(dev);
 	netif_stop_queue(dev);
-
-	spin_lock_irq(&tp->lock);
-
-	rtl8169_asic_down(ioaddr);
-
-	rtl8169_rx_missed(dev, ioaddr);
-
-	spin_unlock_irq(&tp->lock);
 }
 
 #ifdef CONFIG_PM
@@ -3876,9 +3865,17 @@ static struct dev_pm_ops rtl8169_pm_ops = {
 static void rtl_shutdown(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
 
 	rtl8169_net_suspend(dev);
 
+	spin_lock_irq(&tp->lock);
+
+	rtl8169_asic_down(ioaddr);
+
+	spin_unlock_irq(&tp->lock);
+
 	if (system_state == SYSTEM_POWER_OFF) {
 		pci_wake_from_d3(pdev, true);
 		pci_set_power_state(pdev, PCI_D3hot);
-- 
1.6.2.2

