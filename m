From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: do not bring device down when suspending
Date: Sat, 13 Jun 2009 00:50:29 +0200
Message-ID: <20090612225029.GA29331@electric-eye.fr.zoreil.com>
References: <20090611204850.GA26691@electric-eye.fr.zoreil.com> <20090611.172257.90040273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edward_hsu@realtek.com.tw
To: aeriksson@fastmail.fm
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58811 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933786AbZFLWsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 18:48:33 -0400
Content-Disposition: inline
In-Reply-To: <20090611.172257.90040273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anders, can you try davem's net-next +

--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3812,22 +3812,11 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
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
@@ -3877,9 +3866,17 @@ static struct dev_pm_ops rtl8169_pm_ops = {
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


If it is easier for you, you can try against 2.6.30 the patch at
http://userweb.kernel.org/~romieu/r8169/2.6.30/20090612-r8169-test.patch

Thanks.

-- 
Ueimor
