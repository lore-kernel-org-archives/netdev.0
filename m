From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 7/7] r8169: remove work from irq handler.
Date: Fri, 27 Jan 2012 21:59:03 +0100
Message-ID: <20120127205903.GG24507@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57465 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab2A0VJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:09:57 -0500
Content-Disposition: inline
In-Reply-To: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The irq handler was a mess.

See 7ab87ff4c770eed71e3777936299292739fcd0fe ("via-rhine: move work from
irq handler to softirq and beyond") for similar changes. One can notice:
- all non-napi tasks are explicitely scheduled trough a single work queue.
- hiding software tx queue start behind the rtl_hw_start method is mildly
  natural. Move it in the caller where needed.
- as can be seen from the heavy use of bh disabling locks, the driver is
  not safe for irq context messages with netconsole. It is still quite
  usable for general messaging though. Tested ok with concurrent registers
  dump (ethtool -d) + background traffic + "echo t > /proc/sysrq-trigger".

Tested with old PCI chipset, PCIe 8168 and 810x:
- XID 0c900800 RTL8168evl/8111evl
- XID 18000000 RTL8168b/8111b
- XID 98000000 RTL8169sc/8110sc
- XID 083000c0 RTL8168d/8111d
- XID 081000c0 RTL8168d/8111d
- XID 00b00000 RTL8105e
- XID 04a00000 RTL8102e

As a side note, the comments in f11a377b3f4e897d11f0e8d1fc688667e2f19708
("r8169: avoid losing MSI interrupts") does not seem completely clear: if
I hack the driver further to stop acking the irq link event bit, MSI
interrupts keep being delivered (RTL8168b/8111b, XID 18000000).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  449 +++++++++++++++++----------------
 1 files changed, 231 insertions(+), 218 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8dd13f5..d039d39 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -667,6 +667,13 @@ struct rtl8169_counters {
 	__le16	tx_underun;
 };
 
+enum rtl_flag {
+	RTL_FLAG_TASK_SLOW_PENDING,
+	RTL_FLAG_TASK_RESET_PENDING,
+	RTL_FLAG_TASK_PHY_PENDING,
+	RTL_FLAG_MAX
+};
+
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;
@@ -688,9 +695,8 @@ struct rtl8169_private {
 	struct ring_info tx_skb[NUM_TX_DESC];	/* Tx data buffers */
 	struct timer_list timer;
 	u16 cp_cmd;
-	u16 intr_event;
-	u16 napi_event;
-	u16 intr_mask;
+
+	u16 event_slow;
 
 	struct mdio_ops {
 		void (*write)(void __iomem *, int, int);
@@ -716,7 +722,10 @@ struct rtl8169_private {
 	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
 
 	struct {
+		DECLARE_BITMAP(flags, RTL_FLAG_MAX);
+		struct mutex mutex;
 		struct work_struct work;
+		bool enabled;
 	} wk;
 
 	unsigned features;
@@ -768,13 +777,20 @@ static int rtl8169_close(struct net_device *dev);
 static void rtl_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
 static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
-static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
-				void __iomem *, u32 budget);
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
-static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
 
+static void rtl_lock_work(struct rtl8169_private *tp)
+{
+	mutex_lock(&tp->wk.mutex);
+}
+
+static void rtl_unlock_work(struct rtl8169_private *tp)
+{
+	mutex_unlock(&tp->wk.mutex);
+}
+
 static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
 {
 	int cap = pci_pcie_cap(pdev);
@@ -1214,12 +1230,21 @@ static void rtl_irq_enable(struct rtl8169_private *tp, u16 bits)
 	RTL_W16(IntrMask, bits);
 }
 
+#define RTL_EVENT_NAPI_RX	(RxOK | RxErr)
+#define RTL_EVENT_NAPI_TX	(TxOK | TxErr)
+#define RTL_EVENT_NAPI		(RTL_EVENT_NAPI_RX | RTL_EVENT_NAPI_TX)
+
+static void rtl_irq_enable_all(struct rtl8169_private *tp)
+{
+	rtl_irq_enable(tp, RTL_EVENT_NAPI | tp->event_slow);
+}
+
 static void rtl8169_irq_mask_and_ack(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	rtl_irq_disable(tp);
-	rtl_ack_events(tp, tp->intr_event);
+	rtl_ack_events(tp, RTL_EVENT_NAPI | tp->event_slow);
 	RTL_R8(ChipCmd);
 }
 
@@ -1310,9 +1335,6 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 					struct rtl8169_private *tp,
 					void __iomem *ioaddr, bool pm)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		rtl_link_chg_patch(tp);
 		/* This is to cancel a scheduled suspend if there's one. */
@@ -1327,7 +1349,6 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 		if (pm)
 			pm_schedule_suspend(&tp->pci_dev->dev, 5000);
 	}
-	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
 static void rtl8169_check_link_status(struct net_device *dev,
@@ -1370,12 +1391,12 @@ static void rtl8169_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	spin_lock_irq(&tp->lock);
+	rtl_lock_work(tp);
 
 	wol->supported = WAKE_ANY;
 	wol->wolopts = __rtl8169_get_wol(tp);
 
-	spin_unlock_irq(&tp->lock);
+	rtl_unlock_work(tp);
 }
 
 static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
@@ -1412,14 +1433,15 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	spin_lock_irq(&tp->lock);
+	rtl_lock_work(tp);
 
 	if (wol->wolopts)
 		tp->features |= RTL_FEATURE_WOL;
 	else
 		tp->features &= ~RTL_FEATURE_WOL;
 	__rtl8169_set_wol(tp, wol->wolopts);
-	spin_unlock_irq(&tp->lock);
+
+	rtl_unlock_work(tp);
 
 	device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopts);
 
@@ -1574,15 +1596,14 @@ out:
 static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned long flags;
 	int ret;
 
 	del_timer_sync(&tp->timer);
 
-	spin_lock_irqsave(&tp->lock, flags);
+	rtl_lock_work(tp);
 	ret = rtl8169_set_speed(dev, cmd->autoneg, ethtool_cmd_speed(cmd),
 				cmd->duplex, cmd->advertising);
-	spin_unlock_irqrestore(&tp->lock, flags);
+	rtl_unlock_work(tp);
 
 	return ret;
 }
@@ -1602,14 +1623,12 @@ static netdev_features_t rtl8169_fix_features(struct net_device *dev,
 	return features;
 }
 
-static int rtl8169_set_features(struct net_device *dev,
-	netdev_features_t features)
+static void __rtl8169_set_features(struct net_device *dev,
+				   netdev_features_t features)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned long flags;
 
-	spin_lock_irqsave(&tp->lock, flags);
+	void __iomem *ioaddr = tp->mmio_addr;
 
 	if (features & NETIF_F_RXCSUM)
 		tp->cp_cmd |= RxChkSum;
@@ -1623,12 +1642,21 @@ static int rtl8169_set_features(struct net_device *dev,
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 	RTL_R16(CPlusCmd);
+}
 
-	spin_unlock_irqrestore(&tp->lock, flags);
+static int rtl8169_set_features(struct net_device *dev,
+				netdev_features_t features)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	rtl_lock_work(tp);
+	__rtl8169_set_features(dev, features);
+	rtl_unlock_work(tp);
 
 	return 0;
 }
 
+
 static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
 				      struct sk_buff *skb)
 {
@@ -1677,14 +1705,12 @@ static int rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cmd *cmd)
 static int rtl8169_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned long flags;
 	int rc;
 
-	spin_lock_irqsave(&tp->lock, flags);
-
+	rtl_lock_work(tp);
 	rc = tp->get_settings(dev, cmd);
+	rtl_unlock_work(tp);
 
-	spin_unlock_irqrestore(&tp->lock, flags);
 	return rc;
 }
 
@@ -1692,14 +1718,15 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned long flags;
 
 	if (regs->len > R8169_REGS_SIZE)
 		regs->len = R8169_REGS_SIZE;
 
-	spin_lock_irqsave(&tp->lock, flags);
+	rtl_lock_work(tp);
+	spin_lock_bh(&tp->lock);
 	memcpy_fromio(p, tp->mmio_addr, regs->len);
-	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_bh(&tp->lock);
+	rtl_unlock_work(tp);
 }
 
 static u32 rtl8169_get_msglevel(struct net_device *dev)
@@ -3216,18 +3243,14 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	}
 }
 
-static void rtl8169_phy_timer(unsigned long __opaque)
+static void rtl_phy_work(struct rtl8169_private *tp)
 {
-	struct net_device *dev = (struct net_device *)__opaque;
-	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
 
-	spin_lock_irq(&tp->lock);
-
 	if (tp->phy_reset_pending(tp)) {
 		/*
 		 * A busy loop could burn quite a few cycles on nowadays CPU.
@@ -3238,32 +3261,45 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	}
 
 	if (tp->link_ok(ioaddr))
-		goto out_unlock;
+		return;
 
-	netif_warn(tp, link, dev, "PHY reset until link up\n");
+	netif_warn(tp, link, tp->dev, "PHY reset until link up\n");
 
 	tp->phy_reset_enable(tp);
 
 out_mod_timer:
 	mod_timer(timer, jiffies + timeout);
-out_unlock:
-	spin_unlock_irq(&tp->lock);
+}
+
+static void rtl_schedule_task(struct rtl8169_private *tp, enum rtl_flag flag)
+{
+	spin_lock(&tp->lock);
+	if (!test_and_set_bit(flag, tp->wk.flags))
+		schedule_work(&tp->wk.work);
+	spin_unlock(&tp->lock);
+}
+
+static void rtl_schedule_task_bh(struct rtl8169_private *tp, enum rtl_flag flag)
+{
+	local_bh_disable();
+	rtl_schedule_task(tp, flag);
+	local_bh_enable();
+}
+
+static void rtl8169_phy_timer(unsigned long __opaque)
+{
+	struct net_device *dev = (struct net_device *)__opaque;
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_PHY_PENDING);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-/*
- * Polling 'interrupt' - used by things like netconsole to send skbs
- * without having to re-enable interrupts. It's not called while
- * the interrupt routine is executing.
- */
 static void rtl8169_netpoll(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	struct pci_dev *pdev = tp->pci_dev;
 
-	disable_irq(pdev->irq);
-	rtl8169_interrupt(pdev->irq, dev);
-	enable_irq(pdev->irq);
+	rtl8169_interrupt(tp->pci_dev->irq, dev);
 }
 #endif
 
@@ -3344,7 +3380,7 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
 	high = addr[4] | (addr[5] << 8);
 
-	spin_lock_irq(&tp->lock);
+	rtl_lock_work(tp);
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -3368,7 +3404,7 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	spin_unlock_irq(&tp->lock);
+	rtl_unlock_work(tp);
 }
 
 static int rtl_set_mac_address(struct net_device *dev, void *p)
@@ -3422,8 +3458,7 @@ static const struct rtl_cfg_info {
 	void (*hw_start)(struct net_device *);
 	unsigned int region;
 	unsigned int align;
-	u16 intr_event;
-	u16 napi_event;
+	u16 event_slow;
 	unsigned features;
 	u8 default_ver;
 } rtl_cfg_infos [] = {
@@ -3431,9 +3466,7 @@ static const struct rtl_cfg_info {
 		.hw_start	= rtl_hw_start_8169,
 		.region		= 1,
 		.align		= 0,
-		.intr_event	= SYSErr | LinkChg | RxOverflow |
-				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver,
 		.features	= RTL_FEATURE_GMII,
 		.default_ver	= RTL_GIGA_MAC_VER_01,
 	},
@@ -3441,9 +3474,7 @@ static const struct rtl_cfg_info {
 		.hw_start	= rtl_hw_start_8168,
 		.region		= 2,
 		.align		= 8,
-		.intr_event	= SYSErr | LinkChg | RxOverflow |
-				  TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
+		.event_slow	= SYSErr | LinkChg | RxOverflow,
 		.features	= RTL_FEATURE_GMII | RTL_FEATURE_MSI,
 		.default_ver	= RTL_GIGA_MAC_VER_11,
 	},
@@ -3451,9 +3482,8 @@ static const struct rtl_cfg_info {
 		.hw_start	= rtl_hw_start_8101,
 		.region		= 2,
 		.align		= 8,
-		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
-				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver |
+				  PCSTimeout,
 		.features	= RTL_FEATURE_MSI,
 		.default_ver	= RTL_GIGA_MAC_VER_13,
 	}
@@ -4131,6 +4161,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	spin_lock_init(&tp->lock);
+	mutex_init(&tp->wk.mutex);
 
 	/* Get MAC address */
 	for (i = 0; i < ETH_ALEN; i++)
@@ -4158,10 +4189,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
 		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
 
-	tp->intr_mask = 0xffff;
 	tp->hw_start = cfg->hw_start;
-	tp->intr_event = cfg->intr_event;
-	tp->napi_event = cfg->napi_event;
+	tp->event_slow = cfg->event_slow;
 
 	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
 		~(RxBOVF | RxFOVF) : ~0;
@@ -4330,16 +4359,24 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_release_fw_2;
 
+	rtl_lock_work(tp);
+
+	tp->wk.enabled = true;
+
 	napi_enable(&tp->napi);
 
 	rtl8169_init_phy(dev, tp);
 
-	rtl8169_set_features(dev, dev->features);
+	__rtl8169_set_features(dev, dev->features);
 
 	rtl_pll_power_up(tp);
 
 	rtl_hw_start(dev);
 
+	netif_start_queue(dev);
+
+	rtl_unlock_work(tp);
+
 	tp->saved_wolopts = 0;
 	pm_runtime_put_noidle(&pdev->dev);
 
@@ -4413,9 +4450,7 @@ static void rtl_hw_start(struct net_device *dev)
 
 	tp->hw_start(dev);
 
-	rtl_irq_enable(tp, tp->intr_event);
-
-	netif_start_queue(dev);
+	rtl_irq_enable_all(tp);
 }
 
 static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
@@ -4921,8 +4956,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	/* Work around for RxFIFO overflow. */
 	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
-		tp->intr_event |= RxFIFOOver | PCSTimeout;
-		tp->intr_event &= ~RxOverflow;
+		tp->event_slow |= RxFIFOOver | PCSTimeout;
+		tp->event_slow &= ~RxOverflow;
 	}
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
@@ -5108,10 +5143,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
-	if (tp->mac_version >= RTL_GIGA_MAC_VER_30) {
-		tp->intr_event &= ~RxFIFOOver;
-		tp->napi_event &= ~RxFIFOOver;
-	}
+	if (tp->mac_version >= RTL_GIGA_MAC_VER_30)
+		tp->event_slow &= ~RxFIFOOver;
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_13 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_16) {
@@ -5359,61 +5392,34 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 	tp->cur_tx = tp->dirty_tx = 0;
 }
 
-static void rtl8169_schedule_work(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-
-	schedule_work(&tp->wk.work);
-}
-
-static void rtl8169_wait_for_quiescence(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	synchronize_irq(dev->irq);
-
-	/* Wait for any pending NAPI task to complete */
-	napi_disable(&tp->napi);
-
-	rtl8169_irq_mask_and_ack(tp);
-
-	tp->intr_mask = 0xffff;
-	RTL_W16(IntrMask, tp->intr_event);
-	napi_enable(&tp->napi);
-}
-
 static void rtl_reset_work(struct rtl8169_private *tp)
 {
 	struct net_device *dev = tp->dev;
 	int i;
 
-	rtnl_lock();
-
-	if (!netif_running(dev))
-		goto out_unlock;
+	napi_disable(&tp->napi);
+	netif_stop_queue(dev);
+	synchronize_sched();
 
 	rtl8169_hw_reset(tp);
 
-	rtl8169_wait_for_quiescence(dev);
-
 	for (i = 0; i < NUM_RX_DESC; i++)
 		rtl8169_mark_to_asic(tp->RxDescArray + i, rx_buf_sz);
 
 	rtl8169_tx_clear(tp);
 	rtl8169_init_ring_indexes(tp);
 
+	napi_enable(&tp->napi);
 	rtl_hw_start(dev);
 	netif_wake_queue(dev);
 	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
-
-out_unlock:
-	rtnl_unlock();
 }
 
 static void rtl8169_tx_timeout(struct net_device *dev)
 {
-	rtl8169_schedule_work(dev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
 static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
@@ -5550,6 +5556,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	RTL_W8(TxPoll, NPQ);
 
+	mmiowb();
+
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
 		smp_mb();
@@ -5616,12 +5624,10 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 
 	rtl8169_hw_reset(tp);
 
-	rtl8169_schedule_work(dev);
+	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
-static void rtl8169_tx_interrupt(struct net_device *dev,
-				 struct rtl8169_private *tp,
-				 void __iomem *ioaddr)
+static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
 	unsigned int dirty_tx, tx_left;
 
@@ -5664,8 +5670,11 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		 * of start_xmit activity is detected (if it is not detected,
 		 * it is slow enough). -- FR
 		 */
-		if (tp->cur_tx != dirty_tx)
+		if (tp->cur_tx != dirty_tx) {
+			void __iomem *ioaddr = tp->mmio_addr;
+
 			RTL_W8(TxPoll, NPQ);
+		}
 	}
 }
 
@@ -5704,9 +5713,7 @@ static struct sk_buff *rtl8169_try_rx_copy(void *data,
 	return skb;
 }
 
-static int rtl8169_rx_interrupt(struct net_device *dev,
-				struct rtl8169_private *tp,
-				void __iomem *ioaddr, u32 budget)
+static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int count;
@@ -5734,7 +5741,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			if (status & RxCRC)
 				dev->stats.rx_crc_errors++;
 			if (status & RxFOVF) {
-				rtl8169_schedule_work(dev);
+				rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 				dev->stats.rx_fifo_errors++;
 			}
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
@@ -5795,109 +5802,120 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 	int handled = 0;
 	u16 status;
 
-	/* loop handling interrupts until we have no new ones or
-	 * we hit a invalid/hotplug case.
-	 */
 	status = rtl_get_events(tp);
-	while (status && status != 0xffff) {
-		status &= tp->intr_event;
-		if (!status)
-			break;
-
-		handled = 1;
+	if (status && status != 0xffff) {
+		status &= RTL_EVENT_NAPI | tp->event_slow;
+		if (status) {
+			handled = 1;
 
-		/* Handle all of the error cases first. These will reset
-		 * the chip, so just exit the loop.
-		 */
-		if (unlikely(!netif_running(dev))) {
-			rtl8169_hw_reset(tp);
-			break;
+			rtl_irq_disable(tp);
+			napi_schedule(&tp->napi);
 		}
+	}
+	return IRQ_RETVAL(handled);
+}
 
-		if (unlikely(status & RxFIFOOver)) {
-			switch (tp->mac_version) {
-			/* Work around for rx fifo overflow */
-			case RTL_GIGA_MAC_VER_11:
-				netif_stop_queue(dev);
-				rtl8169_tx_timeout(dev);
-				goto done;
-			default:
-				break;
-			}
-		}
+/*
+ * Workqueue context.
+ */
+static void rtl_slow_event_work(struct rtl8169_private *tp)
+{
+	struct net_device *dev = tp->dev;
+	u16 status;
+
+	status = rtl_get_events(tp) & tp->event_slow;
+	rtl_ack_events(tp, status);
 
-		if (unlikely(status & SYSErr)) {
-			rtl8169_pcierr_interrupt(dev);
+	if (unlikely(status & RxFIFOOver)) {
+		switch (tp->mac_version) {
+		/* Work around for rx fifo overflow */
+		case RTL_GIGA_MAC_VER_11:
+			netif_stop_queue(dev);
+			rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
+		default:
 			break;
 		}
+	}
 
-		if (status & LinkChg)
-			__rtl8169_check_link_status(dev, tp, ioaddr, true);
+	if (unlikely(status & SYSErr))
+		rtl8169_pcierr_interrupt(dev);
 
-		/* We need to see the lastest version of tp->intr_mask to
-		 * avoid ignoring an MSI interrupt and having to wait for
-		 * another event which may never come.
-		 */
-		smp_rmb();
-		if (status & tp->intr_mask & tp->napi_event) {
-			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-			tp->intr_mask = ~tp->napi_event;
-
-			if (likely(napi_schedule_prep(&tp->napi)))
-				__napi_schedule(&tp->napi);
-			else
-				netif_info(tp, intr, dev,
-					   "interrupt %04x in poll\n", status);
-		}
+	if (status & LinkChg)
+		__rtl8169_check_link_status(dev, tp, tp->mmio_addr, true);
 
-		/* We only get a new MSI interrupt when all active irq
-		 * sources on the chip have been acknowledged. So, ack
-		 * everything we've seen and check if new sources have become
-		 * active to avoid blocking all interrupts from the chip.
-		 */
-		RTL_W16(IntrStatus,
-			(status & RxFIFOOver) ? (status | RxOverflow) : status);
-		status = rtl_get_events(tp);
-	}
-done:
-	return IRQ_RETVAL(handled);
+	napi_disable(&tp->napi);
+	rtl_irq_disable(tp);
+
+	napi_enable(&tp->napi);
+	napi_schedule(&tp->napi);
 }
 
 static void rtl_task(struct work_struct *work)
 {
+	static const struct {
+		int bitnr;
+		void (*action)(struct rtl8169_private *);
+	} rtl_work[] = {
+		{ RTL_FLAG_TASK_SLOW_PENDING,	rtl_slow_event_work },
+		{ RTL_FLAG_TASK_RESET_PENDING,	rtl_reset_work },
+		{ RTL_FLAG_TASK_PHY_PENDING,	rtl_phy_work }
+	};
 	struct rtl8169_private *tp =
 		container_of(work, struct rtl8169_private, wk.work);
+	struct net_device *dev = tp->dev;
+	int i;
+
+	rtl_lock_work(tp);
+
+	if (!netif_running(dev) || !tp->wk.enabled)
+		goto out_unlock;
+
+	for (i = 0; i < ARRAY_SIZE(rtl_work); i++) {
+		bool pending;
+
+		spin_lock_bh(&tp->lock);
+		pending = test_and_clear_bit(rtl_work[i].bitnr, tp->wk.flags);
+		spin_unlock_bh(&tp->lock);
+
+		if (pending)
+			rtl_work[i].action(tp);
+	}
 
-	rtl_reset_work(tp);
+out_unlock:
+	rtl_unlock_work(tp);
 }
 
 static int rtl8169_poll(struct napi_struct *napi, int budget)
 {
 	struct rtl8169_private *tp = container_of(napi, struct rtl8169_private, napi);
 	struct net_device *dev = tp->dev;
-	void __iomem *ioaddr = tp->mmio_addr;
-	int work_done;
+	u16 enable_mask = RTL_EVENT_NAPI | tp->event_slow;
+	int work_done= 0;
+	u16 status;
+
+	status = rtl_get_events(tp);
+	rtl_ack_events(tp, status & ~tp->event_slow);
+
+	if (status & RTL_EVENT_NAPI_RX)
+		work_done = rtl_rx(dev, tp, (u32) budget);
+
+	if (status & RTL_EVENT_NAPI_TX)
+		rtl_tx(dev, tp);
 
-	work_done = rtl8169_rx_interrupt(dev, tp, ioaddr, (u32) budget);
-	rtl8169_tx_interrupt(dev, tp, ioaddr);
+	if (status & tp->event_slow) {
+		enable_mask &= ~tp->event_slow;
+
+		rtl_schedule_task(tp, RTL_FLAG_TASK_SLOW_PENDING);
+	}
 
 	if (work_done < budget) {
 		napi_complete(napi);
 
-		/* We need for force the visibility of tp->intr_mask
-		 * for other CPUs, as we can loose an MSI interrupt
-		 * and potentially wait for a retransmit timeout if we don't.
-		 * The posted write to IntrMask is safe, as it will
-		 * eventually make it to the chip and we won't loose anything
-		 * until it does.
-		 */
-		tp->intr_mask = 0xffff;
-		wmb();
-		RTL_W16(IntrMask, tp->intr_event);
+		rtl_irq_enable(tp, enable_mask);
+		mmiowb();
 	}
 
 	return work_done;
@@ -5921,11 +5939,8 @@ static void rtl8169_down(struct net_device *dev)
 
 	del_timer_sync(&tp->timer);
 
-	netif_stop_queue(dev);
-
 	napi_disable(&tp->napi);
-
-	spin_lock_irq(&tp->lock);
+	netif_stop_queue(dev);
 
 	rtl8169_hw_reset(tp);
 	/*
@@ -5935,12 +5950,8 @@ static void rtl8169_down(struct net_device *dev)
 	 */
 	rtl8169_rx_missed(dev, ioaddr);
 
-	spin_unlock_irq(&tp->lock);
-
-	synchronize_irq(dev->irq);
-
 	/* Give a racing hard_start_xmit a few cycles to complete. */
-	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */
+	synchronize_sched();
 
 	rtl8169_tx_clear(tp);
 
@@ -5959,7 +5970,11 @@ static int rtl8169_close(struct net_device *dev)
 	/* Update counters before going down */
 	rtl8169_update_counters(dev);
 
+	rtl_lock_work(tp);
+	tp->wk.enabled = false;
+
 	rtl8169_down(dev);
+	rtl_unlock_work(tp);
 
 	free_irq(dev->irq, dev);
 
@@ -5979,7 +5994,6 @@ static void rtl_set_rx_mode(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned long flags;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int rx_mode;
 	u32 tmp = 0;
@@ -6008,7 +6022,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		}
 	}
 
-	spin_lock_irqsave(&tp->lock, flags);
+	spin_lock_bh(&tp->lock);
 
 	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
 
@@ -6024,7 +6038,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 
 	RTL_W32(RxConfig, tmp);
 
-	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_bh(&tp->lock);
 }
 
 /**
@@ -6037,13 +6051,9 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned long flags;
 
-	if (netif_running(dev)) {
-		spin_lock_irqsave(&tp->lock, flags);
+	if (netif_running(dev))
 		rtl8169_rx_missed(dev, ioaddr);
-		spin_unlock_irqrestore(&tp->lock, flags);
-	}
 
 	return &dev->stats;
 }
@@ -6055,10 +6065,15 @@ static void rtl8169_net_suspend(struct net_device *dev)
 	if (!netif_running(dev))
 		return;
 
-	rtl_pll_power_down(tp);
-
 	netif_device_detach(dev);
 	netif_stop_queue(dev);
+
+	rtl_lock_work(tp);
+	napi_disable(&tp->napi);
+	tp->wk.enabled = false;
+	rtl_unlock_work(tp);
+
+	rtl_pll_power_down(tp);
 }
 
 #ifdef CONFIG_PM
@@ -6081,7 +6096,9 @@ static void __rtl8169_resume(struct net_device *dev)
 
 	rtl_pll_power_up(tp);
 
-	rtl8169_schedule_work(dev);
+	tp->wk.enabled = true;
+
+	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
 static int rtl8169_resume(struct device *device)
@@ -6107,10 +6124,10 @@ static int rtl8169_runtime_suspend(struct device *device)
 	if (!tp->TxDescArray)
 		return 0;
 
-	spin_lock_irq(&tp->lock);
+	rtl_lock_work(tp);
 	tp->saved_wolopts = __rtl8169_get_wol(tp);
 	__rtl8169_set_wol(tp, WAKE_ANY);
-	spin_unlock_irq(&tp->lock);
+	rtl_unlock_work(tp);
 
 	rtl8169_net_suspend(dev);
 
@@ -6126,10 +6143,10 @@ static int rtl8169_runtime_resume(struct device *device)
 	if (!tp->TxDescArray)
 		return 0;
 
-	spin_lock_irq(&tp->lock);
+	rtl_lock_work(tp);
 	__rtl8169_set_wol(tp, tp->saved_wolopts);
 	tp->saved_wolopts = 0;
-	spin_unlock_irq(&tp->lock);
+	rtl_unlock_work(tp);
 
 	rtl8169_init_phy(dev, tp);
 
@@ -6197,12 +6214,8 @@ static void rtl_shutdown(struct pci_dev *pdev)
 	/* Restore original MAC address */
 	rtl_rar_set(tp, dev->perm_addr);
 
-	spin_lock_irq(&tp->lock);
-
 	rtl8169_hw_reset(tp);
 
-	spin_unlock_irq(&tp->lock);
-
 	if (system_state == SYSTEM_POWER_OFF) {
 		if (__rtl8169_get_wol(tp) & WAKE_ANY) {
 			rtl_wol_suspend_quirk(tp);
-- 
1.7.6.5
