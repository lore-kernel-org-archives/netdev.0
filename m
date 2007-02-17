From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.20-git14 rtl8139 possible circular locking dependency detected
Date: Sat, 17 Feb 2007 23:12:52 +0100
Message-ID: <20070217221252.GA16954@electric-eye.fr.zoreil.com>
References: <45D7569F.9030502@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41855 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030270AbXBQWNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 17:13:55 -0500
Content-Disposition: inline
In-Reply-To: <45D7569F.9030502@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Piotrowski <michal.k.k.piotrowski@gmail.com> :
[...]

Did you enable RTL8139_DEBUG ?

If so you can try the patch below.

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 35ad5cf..da61368 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -634,7 +634,6 @@ static int rtl8139_close (struct net_dev
 static int netdev_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
 static struct net_device_stats *rtl8139_get_stats (struct net_device *dev);
 static void rtl8139_set_rx_mode (struct net_device *dev);
-static void __set_rx_mode (struct net_device *dev);
 static void rtl8139_hw_start (struct net_device *dev);
 static void rtl8139_thread (struct work_struct *work);
 static void rtl8139_tx_timeout_task(struct work_struct *work);
@@ -2497,10 +2496,11 @@ static struct net_device_stats *rtl8139_
 	return &tp->stats;
 }
 
-/* Set or clear the multicast filter for this adaptor.
-   This routine is not state sensitive and need not be SMP locked. */
-
-static void __set_rx_mode (struct net_device *dev)
+/*
+ * Set or clear the multicast filter for this adaptor.
+ * This routine is not state sensitive and need not be SMP locked.
+ */
+static void rtl8139_set_rx_mode (struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -2545,16 +2545,6 @@ static void __set_rx_mode (struct net_de
 	RTL_W32_F (MAR0 + 4, mc_filter[1]);
 }
 
-static void rtl8139_set_rx_mode (struct net_device *dev)
-{
-	unsigned long flags;
-	struct rtl8139_private *tp = netdev_priv(dev);
-
-	spin_lock_irqsave (&tp->lock, flags);
-	__set_rx_mode(dev);
-	spin_unlock_irqrestore (&tp->lock, flags);
-}
-
 #ifdef CONFIG_PM
 
 static int rtl8139_suspend (struct pci_dev *pdev, pm_message_t state)
