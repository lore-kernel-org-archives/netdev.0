From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Kernel 2.6.28 regression: Hang after hibernate (patch included)
Date: Fri, 2 Jan 2009 23:18:45 +0100
Message-ID: <200901022318.45675.rjw@sisk.pl>
References: <a00b9da20812281234u76da2ef5tb715f4c409eaf37c@mail.gmail.com> <a00b9da20901020910i2625073av96ce68ec0c313a8c@mail.gmail.com> <a00b9da20901021118h3e698d04q33fa9e87519e4d42@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Pavel Machek" <pavel@suse.cz>, linux-kernel@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: "Frank Groeneveld" <frankgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:43918 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753307AbZABWSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 17:18:51 -0500
In-Reply-To: <a00b9da20901021118h3e698d04q33fa9e87519e4d42@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Please don't top post, it makes following the discussion really difficult.

On Friday 02 January 2009, Frank Groeneveld wrote:
> A kernel without SMP doesn't solve the problem. It gives the same
> output as before, except without the CPU notices. I also found out
> that a "vanilla" 2.6.27 does have the same problem. A patched 2.6.27
> kernel (by Gentoo Linux) doesn't have this problem. I attached that
> patch, so you might see what the problem is now.

Not really, the patch (reproduced below for reference) is quite big and does
a couple of different things.  Also, it should be shown to the maintainer of
the code in question.

> 2009/1/2 Frank Groeneveld <frankgroeneveld@gmail.com>:
> > With minimum config you mean only the most necessary drivers (like
> > disabling ALSA)?
> > I will try a kernel without SMP.
> >
> > Frank
> >
> > 2009/1/2 Pavel Machek <pavel@suse.cz>:
> >> Hi!
> >>
> >>> Today I tried the new kernel and found out it has a regression. With
> >>> kernel 2.6.27 I never had problems resuming from hibernate, but with
> >>> 2.6.28 it hangs. The output is something like this (it's not exactly,
> >>> I skipped some words that are before the PCI lines):
> >>>
> >>> PM: read .. MB in .. seconds
> >>> SDA: Synchronizing SCSI cache
> >>> r8169: PME# enabled
> >>> PCI INT A disabled
> >>> PCI INT D disabled
> >>> PCI INT B disabled
> >>> PCI INT C disabled
> >>> PCI INT D disabled
> >>> PCI INT A disabled
> >>> Disabling non-boot CPUs
> >>> CPU1 is now offline
> >>> CPU1 is down
> >>> CPU2 is now offline
> >>> CPU2 is down
> >>> CPU3 is now offline
> >>> CPU3 is down
> >>> SMP Alternatives: switching to UP code
> >>>
> >>> I first thought it's the same as bug 12155, but I'm not sure it is.
> >>> If there's any other ouput I can send to help, let me know.

Thanks,
Rafael

---
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0f6f974..39c17bb 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -370,8 +370,9 @@ struct ring_info {
 };
 
 enum features {
-	RTL_FEATURE_WOL	= (1 << 0),
-	RTL_FEATURE_MSI	= (1 << 1),
+	RTL_FEATURE_WOL		= (1 << 0),
+	RTL_FEATURE_MSI		= (1 << 1),
+	RTL_FEATURE_GMII	= (1 << 2),
 };
 
 struct rtl8169_private {
@@ -406,13 +407,15 @@ struct rtl8169_private {
 	struct vlan_group *vlgrp;
 #endif
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
-	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
+	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
 	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
 	struct delayed_work task;
 	unsigned features;
+
+	struct mii_if_info mii;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -482,6 +485,23 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static void rtl_mdio_write(struct net_device *dev, int phy_id, int location,
+			   int val)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	mdio_write(ioaddr, location, val);
+}
+
+static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return mdio_read(ioaddr, location);
+}
+
 static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 {
 	RTL_W16(IntrMask, 0x0000);
@@ -720,9 +740,13 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
-		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
+	    (tp->mac_version >= RTL_GIGA_MAC_VER_17)) {
+		/*
+		 * Wake up the PHY.
+		 * Vendor specific (0x1f) and reserved (0x0e) MII registers.
+		 */
 		mdio_write(ioaddr, 0x1f, 0x0000);
 		mdio_write(ioaddr, 0x0e, 0x0000);
 	}
@@ -850,7 +874,7 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 
 #endif
 
-static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -867,65 +891,29 @@ static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	cmd->speed = SPEED_1000;
 	cmd->duplex = DUPLEX_FULL; /* Always set */
+
+	return 0;
 }
 
-static void rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	u8 status;
-
-	cmd->supported = SUPPORTED_10baseT_Half |
-			 SUPPORTED_10baseT_Full |
-			 SUPPORTED_100baseT_Half |
-			 SUPPORTED_100baseT_Full |
-			 SUPPORTED_1000baseT_Full |
-			 SUPPORTED_Autoneg |
-			 SUPPORTED_TP;
-
-	cmd->autoneg = 1;
-	cmd->advertising = ADVERTISED_TP | ADVERTISED_Autoneg;
-
-	if (tp->phy_auto_nego_reg & ADVERTISE_10HALF)
-		cmd->advertising |= ADVERTISED_10baseT_Half;
-	if (tp->phy_auto_nego_reg & ADVERTISE_10FULL)
-		cmd->advertising |= ADVERTISED_10baseT_Full;
-	if (tp->phy_auto_nego_reg & ADVERTISE_100HALF)
-		cmd->advertising |= ADVERTISED_100baseT_Half;
-	if (tp->phy_auto_nego_reg & ADVERTISE_100FULL)
-		cmd->advertising |= ADVERTISED_100baseT_Full;
-	if (tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL)
-		cmd->advertising |= ADVERTISED_1000baseT_Full;
-
-	status = RTL_R8(PHYstatus);
-
-	if (status & _1000bpsF)
-		cmd->speed = SPEED_1000;
-	else if (status & _100bps)
-		cmd->speed = SPEED_100;
-	else if (status & _10bps)
-		cmd->speed = SPEED_10;
-
-	if (status & TxFlowCtrl)
-		cmd->advertising |= ADVERTISED_Asym_Pause;
-	if (status & RxFlowCtrl)
-		cmd->advertising |= ADVERTISED_Pause;
-
-	cmd->duplex = ((status & _1000bpsF) || (status & FullDup)) ?
-		      DUPLEX_FULL : DUPLEX_HALF;
+
+	return mii_ethtool_gset(&tp->mii, cmd);
 }
 
 static int rtl8169_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	unsigned long flags;
+	int rc;
 
 	spin_lock_irqsave(&tp->lock, flags);
 
-	tp->get_settings(dev, cmd);
+	rc = tp->get_settings(dev, cmd);
 
 	spin_unlock_irqrestore(&tp->lock, flags);
-	return 0;
+	return rc;
 }
 
 static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
@@ -1513,7 +1501,7 @@ static const struct rtl_cfg_info {
 	unsigned int align;
 	u16 intr_event;
 	u16 napi_event;
-	unsigned msi;
+	unsigned features;
 } rtl_cfg_infos [] = {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
@@ -1522,7 +1510,7 @@ static const struct rtl_cfg_info {
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
-		.msi		= 0
+		.features	= RTL_FEATURE_GMII
 	},
 	[RTL_CFG_1] = {
 		.hw_start	= rtl_hw_start_8168,
@@ -1531,7 +1519,7 @@ static const struct rtl_cfg_info {
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
-		.msi		= RTL_FEATURE_MSI
+		.features	= RTL_FEATURE_GMII | RTL_FEATURE_MSI
 	},
 	[RTL_CFG_2] = {
 		.hw_start	= rtl_hw_start_8101,
@@ -1540,7 +1528,7 @@ static const struct rtl_cfg_info {
 		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
-		.msi		= RTL_FEATURE_MSI
+		.features	= RTL_FEATURE_MSI
 	}
 };
 
@@ -1552,7 +1540,7 @@ static unsigned rtl_try_msi(struct pci_dev *pdev, void __iomem *ioaddr,
 	u8 cfg2;
 
 	cfg2 = RTL_R8(Config2) & ~MSIEnable;
-	if (cfg->msi) {
+	if (cfg->features & RTL_FEATURE_MSI) {
 		if (pci_enable_msi(pdev)) {
 			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
 		} else {
@@ -1578,6 +1566,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
 	const unsigned int region = cfg->region;
 	struct rtl8169_private *tp;
+	struct mii_if_info *mii;
 	struct net_device *dev;
 	void __iomem *ioaddr;
 	unsigned int i;
@@ -1602,6 +1591,14 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->pci_dev = pdev;
 	tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);
 
+	mii = &tp->mii;
+	mii->dev = dev;
+	mii->mdio_read = rtl_mdio_read;
+	mii->mdio_write = rtl_mdio_write;
+	mii->phy_id_mask = 0x1f;
+	mii->reg_num_mask = 0x1f;
+	mii->supports_gmii = !!(cfg->features & RTL_FEATURE_GMII);
+
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc < 0) {
@@ -2099,8 +2096,6 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_R8(IntrMask);
 
-	RTL_W32(RxMissed, 0);
-
 	rtl_set_rx_mode(dev);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2143,8 +2138,6 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_R8(IntrMask);
 
-	RTL_W32(RxMissed, 0);
-
 	rtl_set_rx_mode(dev);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2922,6 +2915,17 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+static void rtl8169_rx_missed(struct net_device *dev, void __iomem *ioaddr)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	if (tp->mac_version > RTL_GIGA_MAC_VER_06)
+		return;
+
+	dev->stats.rx_missed_errors += (RTL_R32(RxMissed) & 0xffffff);
+	RTL_W32(RxMissed, 0);
+}
+
 static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2939,9 +2943,7 @@ core_down:
 
 	rtl8169_asic_down(ioaddr);
 
-	/* Update the error counts. */
-	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
 
@@ -3063,8 +3065,7 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
-		dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-		RTL_W32(RxMissed, 0);
+		rtl8169_rx_missed(dev, ioaddr);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
@@ -3089,8 +3090,7 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	rtl8169_asic_down(ioaddr);
 
-	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);

