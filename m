From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/7] Pull request for r8169 branch
Date: Fri, 27 Jan 2012 21:54:12 +0100
Message-ID: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44566 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab2A0VFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:05:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

Distance from 'davem-next' (a7563f342db6490e66dbf2c8a50577a72a158c9a)
---------------------------------------------------------------------

da78dbff2e05630921c551dbbc70a4b7981a8fff
1e874e041fc7c222cbd85b20c4406070be1f687a
9085cdfa2f9f04d8678465748e2cced6e3f02e26
3e990ff5f119c2f9b142f3e2548dc90ca9b7dfa1
4422bcd4907d1bbb9f63e049e3c3819132c047a1
209e5ac83b4d038ffb52cabc793f75031602a031
4512ff9f361a2786a18cb805d1f64b8d8719f121

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c |  558 ++++++++++++++++++----------------
 1 files changed, 288 insertions(+), 270 deletions(-)

Shortlog
--------

Francois Romieu (7):
      r8169: remove hardcoded PCIe registers accesses.
      r8169: remove rtl8169_reinit_task.
      r8169: stop delaying workqueue.
      r8169: factor out IntrMask writes.
      r8169: irq mask helpers.
      r8169: missing barriers.
      r8169: remove work from irq handler.

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7a0c800..d039d39 100644
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
@@ -714,7 +720,14 @@ struct rtl8169_private {
 	unsigned int (*phy_reset_pending)(struct rtl8169_private *tp);
 	unsigned int (*link_ok)(void __iomem *);
 	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
-	struct delayed_work task;
+
+	struct {
+		DECLARE_BITMAP(flags, RTL_FLAG_MAX);
+		struct mutex mutex;
+		struct work_struct work;
+		bool enabled;
+	} wk;
+
 	unsigned features;
 
 	struct mii_if_info mii;
@@ -764,13 +777,20 @@ static int rtl8169_close(struct net_device *dev);
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
@@ -1180,12 +1200,51 @@ static u8 rtl8168d_efuse_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static u16 rtl_get_events(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R16(IntrStatus);
+}
+
+static void rtl_ack_events(struct rtl8169_private *tp, u16 bits)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W16(IntrStatus, bits);
+	mmiowb();
+}
+
+static void rtl_irq_disable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W16(IntrMask, 0);
+	mmiowb();
+}
+
+static void rtl_irq_enable(struct rtl8169_private *tp, u16 bits)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W16(IntrMask, bits);
+}
+
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
 
-	RTL_W16(IntrMask, 0x0000);
-	RTL_W16(IntrStatus, tp->intr_event);
+	rtl_irq_disable(tp);
+	rtl_ack_events(tp, RTL_EVENT_NAPI | tp->event_slow);
 	RTL_R8(ChipCmd);
 }
 
@@ -1276,9 +1335,6 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 					struct rtl8169_private *tp,
 					void __iomem *ioaddr, bool pm)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		rtl_link_chg_patch(tp);
 		/* This is to cancel a scheduled suspend if there's one. */
@@ -1293,7 +1349,6 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 		if (pm)
 			pm_schedule_suspend(&tp->pci_dev->dev, 5000);
 	}
-	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
 static void rtl8169_check_link_status(struct net_device *dev,
@@ -1336,12 +1391,12 @@ static void rtl8169_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
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
@@ -1378,14 +1433,15 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
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
 
@@ -1540,15 +1596,14 @@ out:
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
@@ -1568,14 +1623,12 @@ static netdev_features_t rtl8169_fix_features(struct net_device *dev,
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
@@ -1589,12 +1642,21 @@ static int rtl8169_set_features(struct net_device *dev,
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 	RTL_R16(CPlusCmd);
+}
+
+static int rtl8169_set_features(struct net_device *dev,
+				netdev_features_t features)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
 
-	spin_unlock_irqrestore(&tp->lock, flags);
+	rtl_lock_work(tp);
+	__rtl8169_set_features(dev, features);
+	rtl_unlock_work(tp);
 
 	return 0;
 }
 
+
 static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
 				      struct sk_buff *skb)
 {
@@ -1643,14 +1705,12 @@ static int rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cmd *cmd)
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
 
@@ -1658,14 +1718,15 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
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
@@ -3182,18 +3243,14 @@ static void rtl_hw_phy_config(struct net_device *dev)
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
@@ -3204,32 +3261,45 @@ static void rtl8169_phy_timer(unsigned long __opaque)
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
 
@@ -3310,7 +3380,7 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
 	high = addr[4] | (addr[5] << 8);
 
-	spin_lock_irq(&tp->lock);
+	rtl_lock_work(tp);
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -3334,7 +3404,7 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	spin_unlock_irq(&tp->lock);
+	rtl_unlock_work(tp);
 }
 
 static int rtl_set_mac_address(struct net_device *dev, void *p)
@@ -3388,8 +3458,7 @@ static const struct rtl_cfg_info {
 	void (*hw_start)(struct net_device *);
 	unsigned int region;
 	unsigned int align;
-	u16 intr_event;
-	u16 napi_event;
+	u16 event_slow;
 	unsigned features;
 	u8 default_ver;
 } rtl_cfg_infos [] = {
@@ -3397,9 +3466,7 @@ static const struct rtl_cfg_info {
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
@@ -3407,9 +3474,7 @@ static const struct rtl_cfg_info {
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
@@ -3417,9 +3482,8 @@ static const struct rtl_cfg_info {
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
@@ -3824,23 +3888,21 @@ static void r8168dp_hw_jumbo_disable(struct rtl8169_private *tp)
 static void r8168e_hw_jumbo_enable(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
 
 	RTL_W8(MaxTxPacketSize, 0x3f);
 	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) | 0x01);
-	pci_write_config_byte(pdev, 0x79, 0x20);
+	rtl_tx_performance_tweak(tp->pci_dev, 0x2 << MAX_READ_REQUEST_SHIFT);
 }
 
 static void r8168e_hw_jumbo_disable(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
 
 	RTL_W8(MaxTxPacketSize, 0x0c);
 	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) & ~0x01);
-	pci_write_config_byte(pdev, 0x79, 0x50);
+	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 }
 
 static void r8168b_0_hw_jumbo_enable(struct rtl8169_private *tp)
@@ -4048,11 +4110,11 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_init_rxcfg(tp);
 
-	RTL_W16(IntrMask, 0x0000);
+	rtl_irq_disable(tp);
 
 	rtl_hw_reset(tp);
 
-	RTL_W16(IntrStatus, 0xffff);
+	rtl_ack_events(tp, 0xffff);
 
 	pci_set_master(pdev);
 
@@ -4099,6 +4161,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	spin_lock_init(&tp->lock);
+	mutex_init(&tp->wk.mutex);
 
 	/* Get MAC address */
 	for (i = 0; i < ETH_ALEN; i++)
@@ -4126,10 +4189,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
 		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
 
-	tp->intr_mask = 0xffff;
 	tp->hw_start = cfg->hw_start;
-	tp->intr_event = cfg->intr_event;
-	tp->napi_event = cfg->napi_event;
+	tp->event_slow = cfg->event_slow;
 
 	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
 		~(RxBOVF | RxFOVF) : ~0;
@@ -4196,7 +4257,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 		rtl8168_driver_stop(tp);
 	}
 
-	cancel_delayed_work_sync(&tp->task);
+	cancel_work_sync(&tp->wk.work);
 
 	unregister_netdev(dev);
 
@@ -4257,6 +4318,8 @@ static void rtl_request_firmware(struct rtl8169_private *tp)
 		rtl_request_uncached_firmware(tp);
 }
 
+static void rtl_task(struct work_struct *);
+
 static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4284,7 +4347,7 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_free_rx_1;
 
-	INIT_DELAYED_WORK(&tp->task, NULL);
+	INIT_WORK(&tp->wk.work, rtl_task);
 
 	smp_mb();
 
@@ -4296,16 +4359,24 @@ static int rtl8169_open(struct net_device *dev)
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
 
@@ -4379,7 +4450,7 @@ static void rtl_hw_start(struct net_device *dev)
 
 	tp->hw_start(dev);
 
-	netif_start_queue(dev);
+	rtl_irq_enable_all(tp);
 }
 
 static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
@@ -4506,9 +4577,6 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	/* no early-rx interrupts */
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
-
-	/* Enable all known interrupts by setting the interrupt mask. */
-	RTL_W16(IntrMask, tp->intr_event);
 }
 
 static void rtl_csi_access_enable(void __iomem *ioaddr, u32 bits)
@@ -4888,8 +4956,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	/* Work around for RxFIFO overflow. */
 	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
-		tp->intr_event |= RxFIFOOver | PCSTimeout;
-		tp->intr_event &= ~RxOverflow;
+		tp->event_slow |= RxFIFOOver | PCSTimeout;
+		tp->event_slow &= ~RxOverflow;
 	}
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
@@ -4977,8 +5045,6 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
-
-	RTL_W16(IntrMask, tp->intr_event);
 }
 
 #define R810X_CPCMD_QUIRK_MASK (\
@@ -5077,10 +5143,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
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
@@ -5136,8 +5200,6 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	rtl_set_rx_mode(dev);
 
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xf000);
-
-	RTL_W16(IntrMask, tp->intr_event);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
@@ -5330,92 +5392,34 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 	tp->cur_tx = tp->dirty_tx = 0;
 }
 
-static void rtl8169_schedule_work(struct net_device *dev, work_func_t task)
+static void rtl_reset_work(struct rtl8169_private *tp)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
-
-	PREPARE_DELAYED_WORK(&tp->task, task);
-	schedule_delayed_work(&tp->task, 4);
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
-static void rtl8169_reinit_task(struct work_struct *work)
-{
-	struct rtl8169_private *tp =
-		container_of(work, struct rtl8169_private, task.work);
-	struct net_device *dev = tp->dev;
-	int ret;
-
-	rtnl_lock();
-
-	if (!netif_running(dev))
-		goto out_unlock;
-
-	rtl8169_wait_for_quiescence(dev);
-	rtl8169_close(dev);
-
-	ret = rtl8169_open(dev);
-	if (unlikely(ret < 0)) {
-		if (net_ratelimit())
-			netif_err(tp, drv, dev,
-				  "reinit failure (status = %d). Rescheduling\n",
-				  ret);
-		rtl8169_schedule_work(dev, rtl8169_reinit_task);
-	}
-
-out_unlock:
-	rtnl_unlock();
-}
-
-static void rtl8169_reset_task(struct work_struct *work)
-{
-	struct rtl8169_private *tp =
-		container_of(work, struct rtl8169_private, task.work);
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
-	rtl8169_schedule_work(dev, rtl8169_reset_task);
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
 static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
@@ -5552,9 +5556,11 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	RTL_W8(TxPoll, NPQ);
 
+	mmiowb();
+
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-		smp_rmb();
+		smp_mb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
 			netif_wake_queue(dev);
 	}
@@ -5618,12 +5624,10 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 
 	rtl8169_hw_reset(tp);
 
-	rtl8169_schedule_work(dev, rtl8169_reinit_task);
+	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
-static void rtl8169_tx_interrupt(struct net_device *dev,
-				 struct rtl8169_private *tp,
-				 void __iomem *ioaddr)
+static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
 	unsigned int dirty_tx, tx_left;
 
@@ -5655,7 +5659,7 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-		smp_wmb();
+		smp_mb();
 		if (netif_queue_stopped(dev) &&
 		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
@@ -5666,9 +5670,11 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		 * of start_xmit activity is detected (if it is not detected,
 		 * it is slow enough). -- FR
 		 */
-		smp_rmb();
-		if (tp->cur_tx != dirty_tx)
+		if (tp->cur_tx != dirty_tx) {
+			void __iomem *ioaddr = tp->mmio_addr;
+
 			RTL_W8(TxPoll, NPQ);
+		}
 	}
 }
 
@@ -5707,9 +5713,7 @@ static struct sk_buff *rtl8169_try_rx_copy(void *data,
 	return skb;
 }
 
-static int rtl8169_rx_interrupt(struct net_device *dev,
-				struct rtl8169_private *tp,
-				void __iomem *ioaddr, u32 budget)
+static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int count;
@@ -5737,7 +5741,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			if (status & RxCRC)
 				dev->stats.rx_crc_errors++;
 			if (status & RxFOVF) {
-				rtl8169_schedule_work(dev, rtl8169_reset_task);
+				rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 				dev->stats.rx_fifo_errors++;
 			}
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
@@ -5798,101 +5802,120 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 	int handled = 0;
-	int status;
-
-	/* loop handling interrupts until we have no new ones or
-	 * we hit a invalid/hotplug case.
-	 */
-	status = RTL_R16(IntrStatus);
-	while (status && status != 0xffff) {
-		status &= tp->intr_event;
-		if (!status)
-			break;
+	u16 status;
 
-		handled = 1;
+	status = rtl_get_events(tp);
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
-		status = RTL_R16(IntrStatus);
+	napi_disable(&tp->napi);
+	rtl_irq_disable(tp);
+
+	napi_enable(&tp->napi);
+	napi_schedule(&tp->napi);
+}
+
+static void rtl_task(struct work_struct *work)
+{
+	static const struct {
+		int bitnr;
+		void (*action)(struct rtl8169_private *);
+	} rtl_work[] = {
+		{ RTL_FLAG_TASK_SLOW_PENDING,	rtl_slow_event_work },
+		{ RTL_FLAG_TASK_RESET_PENDING,	rtl_reset_work },
+		{ RTL_FLAG_TASK_PHY_PENDING,	rtl_phy_work }
+	};
+	struct rtl8169_private *tp =
+		container_of(work, struct rtl8169_private, wk.work);
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
 	}
-done:
-	return IRQ_RETVAL(handled);
+
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
@@ -5916,26 +5939,19 @@ static void rtl8169_down(struct net_device *dev)
 
 	del_timer_sync(&tp->timer);
 
-	netif_stop_queue(dev);
-
 	napi_disable(&tp->napi);
-
-	spin_lock_irq(&tp->lock);
+	netif_stop_queue(dev);
 
 	rtl8169_hw_reset(tp);
 	/*
 	 * At this point device interrupts can not be enabled in any function,
-	 * as netif_running is not true (rtl8169_interrupt, rtl8169_reset_task,
-	 * rtl8169_reinit_task) and napi is disabled (rtl8169_poll).
+	 * as netif_running is not true (rtl8169_interrupt, rtl8169_reset_task)
+	 * and napi is disabled (rtl8169_poll).
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
 
@@ -5954,7 +5970,11 @@ static int rtl8169_close(struct net_device *dev)
 	/* Update counters before going down */
 	rtl8169_update_counters(dev);
 
+	rtl_lock_work(tp);
+	tp->wk.enabled = false;
+
 	rtl8169_down(dev);
+	rtl_unlock_work(tp);
 
 	free_irq(dev->irq, dev);
 
@@ -5974,7 +5994,6 @@ static void rtl_set_rx_mode(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned long flags;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int rx_mode;
 	u32 tmp = 0;
@@ -6003,7 +6022,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		}
 	}
 
-	spin_lock_irqsave(&tp->lock, flags);
+	spin_lock_bh(&tp->lock);
 
 	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
 
@@ -6019,7 +6038,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 
 	RTL_W32(RxConfig, tmp);
 
-	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_bh(&tp->lock);
 }
 
 /**
@@ -6032,13 +6051,9 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
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
@@ -6050,10 +6065,15 @@ static void rtl8169_net_suspend(struct net_device *dev)
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
@@ -6076,7 +6096,9 @@ static void __rtl8169_resume(struct net_device *dev)
 
 	rtl_pll_power_up(tp);
 
-	rtl8169_schedule_work(dev, rtl8169_reset_task);
+	tp->wk.enabled = true;
+
+	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
 static int rtl8169_resume(struct device *device)
@@ -6102,10 +6124,10 @@ static int rtl8169_runtime_suspend(struct device *device)
 	if (!tp->TxDescArray)
 		return 0;
 
-	spin_lock_irq(&tp->lock);
+	rtl_lock_work(tp);
 	tp->saved_wolopts = __rtl8169_get_wol(tp);
 	__rtl8169_set_wol(tp, WAKE_ANY);
-	spin_unlock_irq(&tp->lock);
+	rtl_unlock_work(tp);
 
 	rtl8169_net_suspend(dev);
 
@@ -6121,10 +6143,10 @@ static int rtl8169_runtime_resume(struct device *device)
 	if (!tp->TxDescArray)
 		return 0;
 
-	spin_lock_irq(&tp->lock);
+	rtl_lock_work(tp);
 	__rtl8169_set_wol(tp, tp->saved_wolopts);
 	tp->saved_wolopts = 0;
-	spin_unlock_irq(&tp->lock);
+	rtl_unlock_work(tp);
 
 	rtl8169_init_phy(dev, tp);
 
@@ -6192,12 +6214,8 @@ static void rtl_shutdown(struct pci_dev *pdev)
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
Ueimor
