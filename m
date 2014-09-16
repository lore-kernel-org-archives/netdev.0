From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/2] r8169: fix the default setting of rx vlan
Date: Tue, 16 Sep 2014 02:03:21 +0200
Message-ID: <20140916000321.GA19564@electric-eye.fr.zoreil.com>
References: <1394712342-15778-38-Taiwan-albertk@realtek.com>
 <1394712342-15778-39-Taiwan-albertk@realtek.com>
 <20140912194014.GA15496@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2523183@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42402 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755016AbaIPADf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 20:03:35 -0400
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2523183@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
>  Francois Romieu [mailto:romieu@fr.zoreil.com] 
> > Sent: Saturday, September 13, 2014 3:40 AM
> [...]
> > The same fix should be relevant for NETIF_F_RXCSUM. You may thus as
> > well remove the "changed" test in __rtl8169_set_features and keep
> > everything there.
> 
> In the probe function (rtl_init_one), RxChkSum has been assgined to
> tp->cp_cmd, so only the vlan setting is incorrect. Therefore, I fix
> it only. Do I still have to remove the "changed" test?

You are right, this part does work.

However it's getting messy and the code stomps CPlusCmd in rtl_open right
before it's given a chance to be read in hw_start. Something like the
untested patch below should avoid it and keep related things together.

Thoughts ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7a7860a..ef2cee5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1783,33 +1783,31 @@ static void __rtl8169_set_features(struct net_device *dev,
 				   netdev_features_t features)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	netdev_features_t changed = features ^ dev->features;
 	void __iomem *ioaddr = tp->mmio_addr;
+	u32 rx_config;
 
-	if (!(changed & (NETIF_F_RXALL | NETIF_F_RXCSUM |
-			 NETIF_F_HW_VLAN_CTAG_RX)))
-		return;
+	rx_config = RTL_R32(RxConfig);
+	if (features & NETIF_F_RXALL)
+		rx_config |= (AcceptErr | AcceptRunt);
+	else
+		rx_config &= ~(AcceptErr | AcceptRunt);
 
-	if (changed & (NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_RX)) {
-		if (features & NETIF_F_RXCSUM)
-			tp->cp_cmd |= RxChkSum;
-		else
-			tp->cp_cmd &= ~RxChkSum;
+	RTL_W32(RxConfig, rx_config);
 
-		if (features & NETIF_F_HW_VLAN_CTAG_RX)
-			tp->cp_cmd |= RxVlan;
-		else
-			tp->cp_cmd &= ~RxVlan;
+	if (features & NETIF_F_RXCSUM)
+		tp->cp_cmd |= RxChkSum;
+	else
+		tp->cp_cmd &= ~RxChkSum;
 
-		RTL_W16(CPlusCmd, tp->cp_cmd);
-		RTL_R16(CPlusCmd);
-	}
-	if (changed & NETIF_F_RXALL) {
-		int tmp = (RTL_R32(RxConfig) & ~(AcceptErr | AcceptRunt));
-		if (features & NETIF_F_RXALL)
-			tmp |= (AcceptErr | AcceptRunt);
-		RTL_W32(RxConfig, tmp);
-	}
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		tp->cp_cmd |= RxVlan;
+	else
+		tp->cp_cmd &= ~RxVlan;
+
+	tp->cp_cmd |= RTL_R16(CPlusCmd) & ~(RxVlan | RxChkSum);
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+	RTL_R16(CPlusCmd);
 }
 
 static int rtl8169_set_features(struct net_device *dev,
@@ -1817,8 +1815,11 @@ static int rtl8169_set_features(struct net_device *dev,
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
+	features &= NETIF_F_RXALL | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_RX;
+
 	rtl_lock_work(tp);
-	__rtl8169_set_features(dev, features);
+	if (features ^ dev->features);
+		__rtl8169_set_features(dev, features);
 	rtl_unlock_work(tp);
 
 	return 0;
@@ -6707,12 +6708,7 @@ static int rtl_open(struct net_device *dev)
 
 	rtl8169_init_phy(dev, tp);
 
-	if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
-		tp->cp_cmd |= RxVlan;
-	else
-		tp->cp_cmd &= ~RxVlan;
-
-	RTL_W16(CPlusCmd, tp->cp_cmd);
+	__rtl8169_set_features(dev, dev->features);
 
 	rtl_pll_power_up(tp);
 
@@ -7123,8 +7119,7 @@ static void rtl_hw_initialize(struct rtl8169_private *tp)
 	}
 }
 
-static int
-rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
 	const unsigned int region = cfg->region;
@@ -7199,7 +7194,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_mwi_2;
 	}
 
-	tp->cp_cmd = RxChkSum;
+	tp->cp_cmd = 0;
 
 	if ((sizeof(dma_addr_t) > 4) &&
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
@@ -7240,13 +7235,6 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_master(pdev);
 
-	/*
-	 * Pretend we are using VLANs; This bypasses a nasty bug where
-	 * Interrupts stop flowing on high load on 8110SCd controllers.
-	 */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
-		tp->cp_cmd |= RxVlan;
-
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
 	rtl_init_jumbo_ops(tp);
@@ -7307,8 +7295,14 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 		NETIF_F_HIGHDMA;
 
+	tp->cp_cmd |= RxChkSum | RxVlan;
+
+	/*
+	 * Pretend we are using VLANs; This bypasses a nasty bug where
+	 * Interrupts stop flowing on high load on 8110SCd controllers.
+	 */
 	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
-		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
+		/* Disallow toggling */
 		dev->hw_features &= ~NETIF_F_HW_VLAN_CTAG_RX;
 
 	if (tp->txd_version == RTL_TD_0)
