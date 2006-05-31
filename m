From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [RFT] r8169: MAC address change support
Date: Thu, 1 Jun 2006 00:59:17 +0200
Message-ID: <20060531225917.GA23288@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefano Cavallari <spiky.kiwi@gmail.com>,
	Tim Mattox <tmattox@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:2199 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S965156AbWFAL21
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 07:28:27 -0400
Received: from electric-eye.fr.zoreil.com (localhost.localdomain [127.0.0.1])
	by fr.zoreil.com (8.13.4/8.12.1) with ESMTP id k51BOxGr002601
	for <netdev@vger.kernel.org>; Thu, 1 Jun 2006 13:24:59 +0200
Received: (from romieu@localhost)
	by electric-eye.fr.zoreil.com (8.13.4/8.12.1) id k51BOwgW002600
	for netdev@vger.kernel.org; Thu, 1 Jun 2006 13:24:58 +0200
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It works fine here (x86 so far) but I would welcome more testers.

The patch applies against 2.6.17-rcX.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0ad3310..4208d9a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1381,6 +1381,41 @@ static void rtl8169_netpoll(struct net_d
 }
 #endif
 
+static void __rtl8169_set_mac_addr(struct net_device *dev, void __iomem *ioaddr)
+{
+	unsigned int i, j;
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	for (i = 0; i < 2; i++) {
+		__le32 l = 0;
+
+		for (j = 0; j < 4; j++) {
+			l <<= 8;
+			l |= dev->dev_addr[4*i + j];
+		}
+		RTL_W32(MAC0 + 4*i, cpu_to_be32(l));
+	}
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+}
+
+static int rtl8169_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	if (netif_running(dev)) {
+		spin_lock_irq(&tp->lock);
+		__rtl8169_set_mac_addr(dev, tp->mmio_addr);
+		spin_unlock_irq(&tp->lock);
+	}
+	return 0;
+}
+
 static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 				  void __iomem *ioaddr)
 {
@@ -1616,6 +1651,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
 	dev->set_multicast_list = rtl8169_set_rx_mode;
+	dev->set_mac_address = rtl8169_set_mac_addr;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
@@ -1849,6 +1885,8 @@ rtl8169_hw_start(struct net_device *dev)
 	/* Enable all known interrupts by setting the interrupt mask. */
 	RTL_W16(IntrMask, rtl8169_intr_mask);
 
+	__rtl8169_set_mac_addr(dev, ioaddr);
+
 	netif_start_queue(dev);
 }
 

