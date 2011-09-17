From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/5] Pull request for 'davem.r8169.fixes' branch
Date: Sat, 17 Sep 2011 11:56:17 +0200
Message-ID: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54274 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab1IQJ5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 05:57:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem.r8169.fixes' in repository

git://violet.fr.zoreil.com/romieu/linux davem.r8169.fixes

to get the changes below.

Distance from 'davem' (8e2ec639173f325977818c45011ee176ef2b11f6)
----------------------------------------------------------------

2544bfc0eb2581e0eedbdfea1468b3866223d47e
e03f33af79f0772156e1a1a1e36bdddf8012b2e4
106633897e086e1b47126996aac1a427eb80eb1b
bbb8af75d0a6a5138ff00fe0b1b95c4824effd55
c2b0c1e7fb69b54e704cb2dae5a80cc78a8cb0b2

Diffstat
--------

 drivers/net/r8169.c |   32 +++++++++++++++++++++++++++-----
 1 files changed, 27 insertions(+), 5 deletions(-)

Shortlog
--------

Francois Romieu (2):
      r8169: remove erroneous processing of always set bit.
      r8169: do not enable the TBI for anything but the original 8169.

Hayes Wang (3):
      r8169: fix the reset setting for 8111evl
      r8169: add MODULE_FIRMWARE for the firmware of 8111evl
      r8169: fix WOL setting for 8105 and 8111evl

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 02339b3..c236670 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -407,6 +407,7 @@ enum rtl_register_content {
 	RxOK		= 0x0001,
 
 	/* RxStatusDesc */
+	RxBOVF	= (1 << 24),
 	RxFOVF	= (1 << 23),
 	RxRWT	= (1 << 22),
 	RxRES	= (1 << 21),
@@ -682,6 +683,7 @@ struct rtl8169_private {
 	struct mii_if_info mii;
 	struct rtl8169_counters counters;
 	u32 saved_wolopts;
+	u32 opts1_mask;
 
 	struct rtl_fw {
 		const struct firmware *fw;
@@ -710,6 +712,7 @@ MODULE_FIRMWARE(FIRMWARE_8168D_1);
 MODULE_FIRMWARE(FIRMWARE_8168D_2);
 MODULE_FIRMWARE(FIRMWARE_8168E_1);
 MODULE_FIRMWARE(FIRMWARE_8168E_2);
+MODULE_FIRMWARE(FIRMWARE_8168E_3);
 MODULE_FIRMWARE(FIRMWARE_8105E_1);
 
 static int rtl8169_open(struct net_device *dev);
@@ -3077,6 +3080,14 @@ static void rtl8169_phy_reset(struct net_device *dev,
 	netif_err(tp, link, dev, "PHY reset failed\n");
 }
 
+static bool rtl_tbi_enabled(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return (tp->mac_version == RTL_GIGA_MAC_VER_01) &&
+	    (RTL_R8(PHYstatus) & TBI_Enable);
+}
+
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3109,7 +3120,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 			   ADVERTISED_1000baseT_Half |
 			   ADVERTISED_1000baseT_Full : 0));
 
-	if (RTL_R8(PHYstatus) & TBI_Enable)
+	if (rtl_tbi_enabled(tp))
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
 }
 
@@ -3319,9 +3330,16 @@ static void r810x_phy_power_up(struct rtl8169_private *tp)
 
 static void r810x_pll_power_down(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	if (__rtl8169_get_wol(tp) & WAKE_ANY) {
 		rtl_writephy(tp, 0x1f, 0x0000);
 		rtl_writephy(tp, MII_BMCR, 0x0000);
+
+		if (tp->mac_version == RTL_GIGA_MAC_VER_29 ||
+		    tp->mac_version == RTL_GIGA_MAC_VER_30)
+			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
+				AcceptMulticast | AcceptMyPhys);
 		return;
 	}
 
@@ -3417,7 +3435,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 		rtl_writephy(tp, MII_BMCR, 0x0000);
 
 		if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
-		    tp->mac_version == RTL_GIGA_MAC_VER_33)
+		    tp->mac_version == RTL_GIGA_MAC_VER_33 ||
+		    tp->mac_version == RTL_GIGA_MAC_VER_34)
 			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
 				AcceptMulticast | AcceptMyPhys);
 		return;
@@ -3727,8 +3746,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_06) &&
-	    (RTL_R8(PHYstatus) & TBI_Enable)) {
+	if (rtl_tbi_enabled(tp)) {
 		tp->set_speed = rtl8169_set_speed_tbi;
 		tp->get_settings = rtl8169_gset_tbi;
 		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
@@ -3777,6 +3795,9 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->intr_event = cfg->intr_event;
 	tp->napi_event = cfg->napi_event;
 
+	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
+		~(RxBOVF | RxFOVF) : ~0;
+
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
@@ -3988,6 +4009,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
 			udelay(100);
 	} else {
@@ -5314,7 +5336,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		u32 status;
 
 		rmb();
-		status = le32_to_cpu(desc->opts1);
+		status = le32_to_cpu(desc->opts1) & tp->opts1_mask;
 
 		if (status & DescOwn)
 			break;
-- 
Ueimor
