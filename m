From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 05/21] r8169: add hooks for per-device hw_start handler
Date: Fri, 29 Jun 2007 22:23:10 +0200
Message-ID: <20070629202310.GG3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41540 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411AbXF2UY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:24:26 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rationale: rtl8169_hw_start will not help maintaining an unified
driver for different chipsets but people at Realtek are probably
too polite to say it distinctly.

Let's add the hook and keep hw_start handler unchanged.

As can be seen from the content of rtl8169_pci_tbl, the RTL_CFG_1
entry in rtl_cfg_info was unused. I recycled it for the 0x8168.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   64 +++++++++++++++++++++++++++++++++++---------------
 1 files changed, 45 insertions(+), 19 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4d0cdba..5e24a0c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -199,20 +199,25 @@ enum cfg_version {
 	RTL_CFG_2
 };
 
+static void rtl_hw_start_8169(struct net_device *);
+static void rtl_hw_start_8168(struct net_device *);
+static void rtl_hw_start_8101(struct net_device *);
+
 static const struct {
+	void (*hw_start)(struct net_device *);
 	unsigned int region;
 	unsigned int align;
 } rtl_cfg_info[] = {
-	[RTL_CFG_0] = { 1, NET_IP_ALIGN },
-	[RTL_CFG_1] = { 2, NET_IP_ALIGN },
-	[RTL_CFG_2] = { 2, 8 }
+	[RTL_CFG_0] = { rtl_hw_start_8169, 1, NET_IP_ALIGN },
+	[RTL_CFG_1] = { rtl_hw_start_8168, 2, 8 },
+	[RTL_CFG_2] = { rtl_hw_start_8101, 2, 8 }
 };
 
 static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_0 },
-	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_2 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(0x1259,			0xc107), 0, 0, RTL_CFG_0 },
@@ -455,6 +460,7 @@ struct rtl8169_private {
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
+	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
 	struct delayed_work task;
@@ -478,9 +484,9 @@ static int rtl8169_open(struct net_device *dev);
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
 static int rtl8169_init_ring(struct net_device *dev);
-static void rtl8169_hw_start(struct net_device *dev);
+static void rtl_hw_start(struct net_device *dev);
 static int rtl8169_close(struct net_device *dev);
-static void rtl8169_set_rx_mode(struct net_device *dev);
+static void rtl_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
 static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
@@ -1647,7 +1653,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
-	dev->set_multicast_list = rtl8169_set_rx_mode;
+	dev->set_multicast_list = rtl_set_rx_mode;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
@@ -1676,6 +1682,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
 
+	tp->hw_start = rtl_cfg_info[ent->driver_data].hw_start;
+
 	spin_lock_init(&tp->lock);
 
 	rc = register_netdev(dev);
@@ -1774,7 +1782,7 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_release_ring_2;
 
-	rtl8169_hw_start(dev);
+	rtl_hw_start(dev);
 
 	rtl8169_request_timer(dev);
 
@@ -1818,12 +1826,10 @@ static void rtl8169_set_rx_tx_config_registers(struct rtl8169_private *tp)
 		(InterFrameGap << TxInterFrameGapShift));
 }
 
-static void rtl8169_hw_start(struct net_device *dev)
+static void rtl_hw_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
-	u16 cmd;
 	u32 i;
 
 	/* Soft reset the chip. */
@@ -1836,6 +1842,22 @@ static void rtl8169_hw_start(struct net_device *dev)
 		msleep_interruptible(1);
 	}
 
+	tp->hw_start(dev);
+
+	/* Enable all known interrupts by setting the interrupt mask. */
+	RTL_W16(IntrMask, rtl8169_intr_mask);
+
+	netif_start_queue(dev);
+}
+
+
+static void rtl_hw_start_8169(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+	u16 cmd;
+
 	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
 		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | PCIMulRW);
 		pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
@@ -1922,15 +1944,20 @@ static void rtl8169_hw_start(struct net_device *dev)
 
 	RTL_W32(RxMissed, 0);
 
-	rtl8169_set_rx_mode(dev);
+	rtl_set_rx_mode(dev);
 
 	/* no early-rx interrupts */
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
+}
 
-	/* Enable all known interrupts by setting the interrupt mask. */
-	RTL_W16(IntrMask, rtl8169_intr_mask);
+static void rtl_hw_start_8168(struct net_device *dev)
+{
+	rtl_hw_start_8169(dev);
+}
 
-	netif_start_queue(dev);
+static void rtl_hw_start_8101(struct net_device *dev)
+{
+	rtl_hw_start_8169(dev);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
@@ -1956,7 +1983,7 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 
 	netif_poll_enable(dev);
 
-	rtl8169_hw_start(dev);
+	rtl_hw_start(dev);
 
 	rtl8169_request_timer(dev);
 
@@ -2201,7 +2228,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	if (tp->dirty_rx == tp->cur_rx) {
 		rtl8169_init_ring_indexes(tp);
-		rtl8169_hw_start(dev);
+		rtl_hw_start(dev);
 		netif_wake_queue(dev);
 	} else {
 		if (net_ratelimit()) {
@@ -2792,8 +2819,7 @@ static int rtl8169_close(struct net_device *dev)
 	return 0;
 }
 
-static void
-rtl8169_set_rx_mode(struct net_device *dev)
+static void rtl_set_rx_mode(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-- 
1.4.4.2

