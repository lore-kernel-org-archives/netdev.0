From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] sundance: Enable WoL support
Date: Sat,  1 Dec 2012 22:39:19 +0400
Message-ID: <1354387159-18793-1-git-send-email-kda@linux-powerpc.org>
References: <Denis Kirjanov <kda@linux-powerpc.org>
Cc: davem@davemloft.net, kda@linux-powerpc.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:48242 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab2LASjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 13:39:44 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so1204671lag.19
        for <netdev@vger.kernel.org>; Sat, 01 Dec 2012 10:39:42 -0800 (PST)
In-Reply-To: <Denis Kirjanov <kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable WoL support.

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 drivers/net/ethernet/dlink/sundance.c |   81 ++++++++++++++++++++++++++++++++-
 1 files changed, 80 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 3b83588..bbeb4c7 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -259,6 +259,7 @@ enum alta_offsets {
 	EECtrl = 0x36,
 	FlashAddr = 0x40,
 	FlashData = 0x44,
+	WakeEvent = 0x45,
 	TxStatus = 0x46,
 	TxFrameId = 0x47,
 	DownCounter = 0x18,
@@ -333,6 +334,14 @@ enum mac_ctrl1_bits {
 	RxEnable=0x0800, RxDisable=0x1000, RxEnabled=0x2000,
 };
 
+/* Bits in WakeEvent register. */
+enum wake_event_bits {
+	WakePktEnable = 0x01,
+	MagicPktEnable = 0x02,
+	LinkEventEnable = 0x04,
+	WolEnable = 0x80,
+};
+
 /* The Rx and Tx buffer descriptors. */
 /* Note that using only 32 bit fields simplifies conversion to big-endian
    architectures. */
@@ -392,6 +401,7 @@ struct netdev_private {
 	unsigned int default_port:4;		/* Last dev->if_port value. */
 	unsigned int an_enable:1;
 	unsigned int speed;
+	unsigned int wol_enabled:1;			/* Wake on LAN enabled */
 	struct tasklet_struct rx_tasklet;
 	struct tasklet_struct tx_tasklet;
 	int budget;
@@ -829,7 +839,7 @@ static int netdev_open(struct net_device *dev)
 	unsigned long flags;
 	int i;
 
-	/* Do we need to reset the chip??? */
+	sundance_reset(dev, 0x00ff << 16);
 
 	i = request_irq(irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (i)
@@ -877,6 +887,10 @@ static int netdev_open(struct net_device *dev)
 
 	iowrite16 (StatsEnable | RxEnable | TxEnable, ioaddr + MACCtrl1);
 
+	/* Disable Wol */
+	iowrite8(ioread8(ioaddr + WakeEvent) | 0x00, ioaddr + WakeEvent);
+	np->wol_enabled = 0;
+
 	if (netif_msg_ifup(np))
 		printk(KERN_DEBUG "%s: Done netdev_open(), status: Rx %x Tx %x "
 			   "MAC Control %x, %4.4x %4.4x.\n",
@@ -1715,6 +1729,60 @@ static void get_ethtool_stats(struct net_device *dev,
 	data[i++] = np->xstats.rx_mcasts;
 }
 
+#ifdef CONFIG_PM
+
+static void sundance_get_wol(struct net_device *dev,
+		struct ethtool_wolinfo *wol)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->base;
+	u8 wol_bits;
+
+	wol->wolopts = 0;
+
+	wol->supported = (WAKE_PHY | WAKE_MAGIC);
+	if (!np->wol_enabled)
+		return;
+
+	wol_bits = ioread8(ioaddr + WakeEvent);
+	if (wol_bits & MagicPktEnable)
+		wol->wolopts |= WAKE_MAGIC;
+	if (wol_bits & LinkEventEnable)
+		wol->wolopts |= WAKE_PHY;
+}
+
+static int sundance_set_wol(struct net_device *dev,
+	struct ethtool_wolinfo *wol)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->base;
+	u8 wol_bits;
+
+	if (!device_can_wakeup(&np->pci_dev->dev))
+		return -EOPNOTSUPP;
+
+	np->wol_enabled = !!(wol->wolopts);
+	wol_bits = ioread8(ioaddr + WakeEvent);
+	wol_bits &= ~(WakePktEnable | MagicPktEnable |
+			LinkEventEnable | WolEnable);
+
+	if (np->wol_enabled) {
+		if (wol->wolopts & WAKE_MAGIC)
+			wol_bits |= (MagicPktEnable | WolEnable);
+		if (wol->wolopts & WAKE_PHY)
+			wol_bits |= (LinkEventEnable | WolEnable);
+	}
+	iowrite8(wol_bits, ioaddr + WakeEvent);
+
+	device_set_wakeup_enable(&np->pci_dev->dev, np->wol_enabled);
+
+	return 0;
+}
+#else
+#define sundance_get_wol NULL
+#define sundance_set_wol NULL
+#endif /* CONFIG_PM */
+
 static const struct ethtool_ops ethtool_ops = {
 	.begin = check_if_running,
 	.get_drvinfo = get_drvinfo,
@@ -1722,6 +1790,8 @@ static const struct ethtool_ops ethtool_ops = {
 	.set_settings = set_settings,
 	.nway_reset = nway_reset,
 	.get_link = get_link,
+	.get_wol = sundance_get_wol,
+	.set_wol = sundance_set_wol,
 	.get_msglevel = get_msglevel,
 	.set_msglevel = set_msglevel,
 	.get_strings = get_strings,
@@ -1867,6 +1937,8 @@ static void __devexit sundance_remove1 (struct pci_dev *pdev)
 static int sundance_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->base;
 
 	if (!netif_running(dev))
 		return 0;
@@ -1875,6 +1947,12 @@ static int sundance_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	netif_device_detach(dev);
 
 	pci_save_state(pci_dev);
+	if (np->wol_enabled) {
+		iowrite8(AcceptBroadcast | AcceptMyPhys, ioaddr + RxMode);
+		iowrite16(RxEnable, ioaddr + MACCtrl1);
+	}
+	pci_enable_wake(pci_dev, pci_choose_state(pci_dev, state),
+			np->wol_enabled);
 	pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state));
 
 	return 0;
@@ -1890,6 +1968,7 @@ static int sundance_resume(struct pci_dev *pci_dev)
 
 	pci_set_power_state(pci_dev, PCI_D0);
 	pci_restore_state(pci_dev);
+	pci_enable_wake(pci_dev, PCI_D0, 0);
 
 	err = netdev_open(dev);
 	if (err) {
-- 
1.7.3.4
