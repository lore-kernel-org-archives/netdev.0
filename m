From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH,net-next] r8169: Change order to init regs
Date: Sat, 22 Aug 2015 12:45:17 +0300
Message-ID: <1440236717-30405-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35853 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbbHVJp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 05:45:29 -0400
Received: by wicja10 with SMTP id ja10so32860922wic.1
        for <netdev@vger.kernel.org>; Sat, 22 Aug 2015 02:45:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable writting on registers on probe stage because
 register CplusCmd must init first.Here is order:  1. CplusCmd,  2. ChipCmd,  3.
 Rest regs.  I split __rtl8169_set_features func for solve this issue.

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ea461fe..b0f7ed2 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2057,6 +2057,48 @@ static void __rtl8169_set_features(struct net_device *dev,
 	RTL_R16(CPlusCmd);
 }
 
+static void rtl8169_set_feat_part2(struct net_device *dev,
+				   netdev_features_t features)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	
+
+
+	if (features & NETIF_F_RXCSUM)
+		tp->cp_cmd |= RxChkSum;
+	else
+		tp->cp_cmd &= ~RxChkSum;
+
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		tp->cp_cmd |= RxVlan;
+	else
+		tp->cp_cmd &= ~RxVlan;
+
+	tp->cp_cmd |= RTL_R16(CPlusCmd) & ~(RxVlan | RxChkSum);
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+	RTL_R16(CPlusCmd);
+}
+
+static void rtl8169_set_feat_part1(struct net_device *dev,
+				   netdev_features_t features)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 rx_config;
+
+	rx_config = RTL_R32(RxConfig);
+	if (features & NETIF_F_RXALL)
+		rx_config |= (AcceptErr | AcceptRunt);
+	else
+		rx_config &= ~(AcceptErr | AcceptRunt);
+
+	RTL_W32(RxConfig, rx_config);
+
+
+}
+
 static int rtl8169_set_features(struct net_device *dev,
 				netdev_features_t features)
 {
@@ -7604,6 +7646,7 @@ static int rtl_open(struct net_device *dev)
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
 
+	rtl8169_set_feat_part2(dev, dev->features);
 	retval = rtl8169_init_ring(dev);
 	if (retval < 0)
 		goto err_free_rx_1;
@@ -7628,10 +7671,11 @@ static int rtl_open(struct net_device *dev)
 
 	rtl8169_init_phy(dev, tp);
 
-	__rtl8169_set_features(dev, dev->features);
+	//__rtl8169_set_features(dev, dev->features);
 
 	rtl_pll_power_up(tp);
-
+	rtl8169_set_feat_part1(dev, dev->features);
+	rtl_init_rxcfg(tp);
 	rtl_hw_start(dev);
 
 	netif_start_queue(dev);
@@ -8178,13 +8222,13 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
 
-	rtl_init_rxcfg(tp);
+	//rtl_init_rxcfg(tp);
 
 	rtl_irq_disable(tp);
 
 	rtl_hw_initialize(tp);
 
-	rtl_hw_reset(tp);
+	//rtl_hw_reset(tp);
 
 	rtl_ack_events(tp, 0xffff);
 	if (!pci_is_pcie(pdev))
@@ -8200,9 +8244,9 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	chipset = tp->mac_version;
 	tp->txd_version = rtl_chip_infos[chipset].txd_version;
 
-	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	/*RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
-	RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | LanWake | PMEStatus));
+	RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | LanWake | PMEStatus));*/
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_34:
 	case RTL_GIGA_MAC_VER_35:
@@ -8234,7 +8278,7 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
 		tp->features |= RTL_FEATURE_WOL;
 	tp->features |= rtl_try_msi(tp, cfg);
-	RTL_W8(Cfg9346, Cfg9346_Lock);
+	//RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	if (rtl_tbi_enabled(tp)) {
 		tp->set_speed = rtl8169_set_speed_tbi;
-- 
2.1.4
