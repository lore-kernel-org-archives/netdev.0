From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: do not bring device down when suspending
Date: Thu, 11 Jun 2009 22:48:51 +0200
Message-ID: <20090611204850.GA26691@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aeriksson@fastmail.fm, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55346 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752032AbZFKUrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 16:47:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stopping all activity through ChipCmd and blindly acking the irqs
is neither nice nor completely needed: the transition to low-power
mode does enough work and it apparently keeps the device in a sane
state.

Patch suggested by a fix for http://bugzilla.kernel.org/show_bug.cgi?id=9512

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Anders Eriksson <aeriksson@fastmail.fm>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3b19e0c..d354a3a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3808,7 +3808,6 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 
 	if (!netif_running(dev))
 		goto out_pci_suspend;
@@ -3816,14 +3815,6 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 	netif_device_detach(dev);
 	netif_stop_queue(dev);
 
-	spin_lock_irq(&tp->lock);
-
-	rtl8169_asic_down(ioaddr);
-
-	rtl8169_rx_missed(dev, ioaddr);
-
-	spin_unlock_irq(&tp->lock);
-
 out_pci_suspend:
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state),
-- 
1.6.0.6

