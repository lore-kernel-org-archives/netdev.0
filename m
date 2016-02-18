From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v3.16]r8169:   Start on full duplex 8101
Date: Thu, 18 Feb 2016 15:16:29 +0200
Message-ID: <1455801389-2094-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-226-11.residential.rdsnet.ro ([5.14.226.11]:49124 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425871AbcBRNQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 08:16:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  For more info send email.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 69 ++++++++++++++++++++++--------------
 1 file changed, 42 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 61623e9..e215812 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3709,14 +3709,6 @@ static void rtl_schedule_task(struct rtl8169_private *tp, enum rtl_flag flag)
 		schedule_work(&tp->wk.work);
 }
 
-static void rtl8169_phy_timer(unsigned long __opaque)
-{
-	struct net_device *dev = (struct net_device *)__opaque;
-	struct rtl8169_private *tp = netdev_priv(dev);
-
-	rtl_schedule_task(tp, RTL_FLAG_TASK_PHY_PENDING);
-}
-
 static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 				  void __iomem *ioaddr)
 {
@@ -4427,7 +4419,6 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 
 	RTL_W8(ChipCmd, CmdReset);
 
-	rtl_udelay_loop_wait_low(tp, &rtl_chipcmd_cond, 100, 100);
 }
 
 static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
@@ -4704,6 +4695,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
+
 	if (tp->mac_version != RTL_GIGA_MAC_VER_01 &&
 	    tp->mac_version != RTL_GIGA_MAC_VER_02 &&
 	    tp->mac_version != RTL_GIGA_MAC_VER_03 &&
@@ -5625,20 +5617,25 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	    tp->mac_version == RTL_GIGA_MAC_VER_16)
 		pcie_capability_set_word(pdev, PCI_EXP_DEVCTL,
 					 PCI_EXP_DEVCTL_NOSNOOP_EN);
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_09:
+		break;
+	default:
 
-	RTL_W8(Cfg9346, Cfg9346_Unlock);
-
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+		RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
+		rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
-	tp->cp_cmd &= ~R810X_CPCMD_QUIRK_MASK;
-	RTL_W16(CPlusCmd, tp->cp_cmd);
+		tp->cp_cmd &= ~R810X_CPCMD_QUIRK_MASK;
+		RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	rtl_set_rx_tx_desc_registers(tp, ioaddr);
+		rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	rtl_set_rx_tx_config_registers(tp);
+		rtl_set_rx_tx_config_registers(tp);
+		break;
+	}
 
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_07:
 		rtl_hw_start_8102e_1(tp);
@@ -6393,7 +6390,7 @@ static void rtl_task(struct work_struct *work)
 	struct rtl8169_private *tp =
 		container_of(work, struct rtl8169_private, wk.work);
 	struct net_device *dev = tp->dev;
-	int i;
+	bool pending;
 
 	rtl_lock_work(tp);
 
@@ -6401,13 +6398,25 @@ static void rtl_task(struct work_struct *work)
 	    !test_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags))
 		goto out_unlock;
 
-	for (i = 0; i < ARRAY_SIZE(rtl_work); i++) {
-		bool pending;
+		pending = test_and_clear_bit(rtl_work[0].bitnr, tp->wk.flags);
+		if (pending)
+			rtl_work[0].action(tp);
+
+		switch (tp->mac_version) {
+		case RTL_GIGA_MAC_VER_09:
+			test_and_clear_bit(rtl_work[1].bitnr, tp->wk.flags);
+			break;
+		default:
+			pending = test_and_clear_bit(rtl_work[1].bitnr,
+							tp->wk.flags);
+			if (pending)
+				rtl_work[1].action(tp);
+			break;
+		}
 
-		pending = test_and_clear_bit(rtl_work[i].bitnr, tp->wk.flags);
+		pending = test_and_clear_bit(rtl_work[2].bitnr, tp->wk.flags);
 		if (pending)
-			rtl_work[i].action(tp);
-	}
+			rtl_work[2].action(tp);
 
 out_unlock:
 	rtl_unlock_work(tp);
@@ -6553,6 +6562,14 @@ static int rtl_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_free_rx_1;
 
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_09:
+		rtl_set_rx_tx_desc_registers(tp, ioaddr);
+		break;
+	default:
+		break;
+	}
+
 	INIT_WORK(&tp->wk.work, rtl_task);
 
 	smp_mb();
@@ -6569,7 +6586,6 @@ static int rtl_open(struct net_device *dev)
 
 	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 
-	napi_enable(&tp->napi);
 
 	rtl8169_init_phy(dev, tp);
 
@@ -6580,7 +6596,7 @@ static int rtl_open(struct net_device *dev)
 	rtl_hw_start(dev);
 
 	netif_start_queue(dev);
-
+	napi_enable(&tp->napi);
 	rtl_unlock_work(tp);
 
 	tp->saved_wolopts = 0;
@@ -6892,7 +6908,7 @@ static const struct rtl_cfg_info {
 		.region		= 2,
 		.align		= 8,
 		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver |
-				  PCSTimeout,
+				  PCSTimeout | SWInt | TxDescUnavail,
 		.features	= RTL_FEATURE_MSI,
 		.default_ver	= RTL_GIGA_MAC_VER_13,
 	}
@@ -7183,7 +7199,6 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long) dev;
-	tp->timer.function = rtl8169_phy_timer;
 
 	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
-- 
2.1.4
