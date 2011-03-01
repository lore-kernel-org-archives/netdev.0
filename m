From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Tue, 1 Mar 2011 11:16:09 +0100
Message-ID: <20110301101609.GA13261@electric-eye.fr.zoreil.com>
References: <loom.20110205T163216-459@post.gmane.org> <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com> <loom.20110206T203347-475@post.gmane.org> <4D4FE100.5090808@gmail.com> <loom.20110214T141934-88@post.gmane.org> <AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com> <loom.20110226T011347-702@post.gmane.org> <AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com> <loom.20110226T120245-774@post.gmane.org> <AANLkTimmbG3_GjYhoO7F46hOcRM3Fq_mNifk2PpLstPa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chriss <mail_to_chriss@gmx.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52712 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011Ab1CAKUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 05:20:22 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimmbG3_GjYhoO7F46hOcRM3Fq_mNifk2PpLstPa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse@nicira.com> :
[...]
> Putting a vlan device on eth1 actually affects the behavior of the
> driver, which is why that works.  I suspect that if you put the vlan
> device on both the physical interface and the bridge you would see
> packets with tags on the bridge.
> 
> Regardless, the solution is to remove the dependency on vlan devices
> by converting over to the new vlan model.  Francois, any chance that
> you might have some time to look at this?

The completely untested patch below is available for the (really) desperate
souls.

I should do a -next testing session this afternoon for this patch + 
Oliver's Neukum advertisement control + Hayes 8105e stuff (in reverse order).

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..8e7da78 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2235,15 +2235,6 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
-config R8169_VLAN
-	bool "VLAN support"
-	depends on R8169 && VLAN_8021Q
-	---help---
-	  Say Y here for the r8169 driver to support the functions required
-	  by the kernel 802.1Q code.
-
-	  If in doubt, say Y.
-
 config SB1250_MAC
 	tristate "SB1250 Gigabit Ethernet support"
 	depends on SIBYTE_SB1xxx_SOC
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bde7d61..5c4f03d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -526,9 +526,6 @@ struct rtl8169_private {
 	u16 napi_event;
 	u16 intr_mask;
 	int phy_1000_ctrl_reg;
-#ifdef CONFIG_R8169_VLAN
-	struct vlan_group *vlgrp;
-#endif
 
 	struct mdio_ops {
 		void (*write)(void __iomem *, int, int);
@@ -1254,8 +1251,6 @@ static int rtl8169_set_rx_csum(struct net_device *dev, u32 data)
 	return 0;
 }
 
-#ifdef CONFIG_R8169_VLAN
-
 static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
 				      struct sk_buff *skb)
 {
@@ -1263,64 +1258,37 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
 		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
 }
 
-static void rtl8169_vlan_rx_register(struct net_device *dev,
-				     struct vlan_group *grp)
+#define NETIF_F_HW_VLAN_TX_RX	(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX)
+
+static void rtl8169_vlan_mode(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	tp->vlgrp = grp;
-	/*
-	 * Do not disable RxVlan on 8110SCd.
-	 */
-	if (tp->vlgrp || (tp->mac_version == RTL_GIGA_MAC_VER_05))
+	if (dev->features & NETIF_F_HW_VLAN_RX)
 		tp->cp_cmd |= RxVlan;
 	else
 		tp->cp_cmd &= ~RxVlan;
 	RTL_W16(CPlusCmd, tp->cp_cmd);
+	/* PCI commit */
 	RTL_R16(CPlusCmd);
 	spin_unlock_irqrestore(&tp->lock, flags);
+
+	dev->vlan_features = dev->features &~ NETIF_F_HW_VLAN_TX_RX;
 }
 
-static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
-			       struct sk_buff *skb, int polling)
+static void rtl8169_rx_vlan_tag(struct RxDesc *desc, struct sk_buff *skb)
 {
 	u32 opts2 = le32_to_cpu(desc->opts2);
-	struct vlan_group *vlgrp = tp->vlgrp;
-	int ret;
 
-	if (vlgrp && (opts2 & RxVlanTag)) {
-		u16 vtag = swab16(opts2 & 0xffff);
+	if (opts2 & RxVlanTag)
+		__vlan_hwaccel_put_tag(skb, swab16(opts2 & 0xffff));
 
-		if (likely(polling))
-			vlan_gro_receive(&tp->napi, vlgrp, vtag, skb);
-		else
-			__vlan_hwaccel_rx(skb, vlgrp, vtag, polling);
-		ret = 0;
-	} else
-		ret = -1;
 	desc->opts2 = 0;
-	return ret;
-}
-
-#else /* !CONFIG_R8169_VLAN */
-
-static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
-				      struct sk_buff *skb)
-{
-	return 0;
-}
-
-static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
-			       struct sk_buff *skb, int polling)
-{
-	return -1;
 }
 
-#endif
-
 static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1491,6 +1459,28 @@ static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
+static int rtl8169_set_flags(struct net_device *dev, u32 data)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned long old_feat = dev->features;
+	int rc;
+
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_05) &&
+	    !(data & ETH_FLAG_RXVLAN)) {
+		netif_info(tp, drv, dev, "8110SCd requires hardware Rx VLAN\n");
+		return -EINVAL;
+	}
+
+	rc = ethtool_op_set_flags(dev, data, ETH_FLAG_TXVLAN | ETH_FLAG_RXVLAN);
+	if (rc)
+		return rc;
+
+	if ((old_feat ^ dev->features) & NETIF_F_HW_VLAN_RX)
+		rtl8169_vlan_mode(dev);
+
+	return 0;
+}
+
 static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
@@ -1510,6 +1500,8 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_strings		= rtl8169_get_strings,
 	.get_sset_count		= rtl8169_get_sset_count,
 	.get_ethtool_stats	= rtl8169_get_ethtool_stats,
+	.set_flags		= rtl8169_set_flags,
+	.get_flags		= ethtool_op_get_flags,
 };
 
 static void rtl8169_get_mac_version(struct rtl8169_private *tp,
@@ -2792,9 +2784,6 @@ static const struct net_device_ops rtl8169_netdev_ops = {
 	.ndo_set_mac_address	= rtl_set_mac_address,
 	.ndo_do_ioctl		= rtl8169_ioctl,
 	.ndo_set_multicast_list	= rtl_set_rx_mode,
-#ifdef CONFIG_R8169_VLAN
-	.ndo_vlan_rx_register	= rtl8169_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= rtl8169_netpoll,
 #endif
@@ -3086,6 +3075,13 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
 
+	/*
+	 * Pretend we are using VLANs; This bypasses a nasty bug where
+	 * Interrupts stop flowing on high load on 8110SCd controllers.
+	 */
+	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
+		tp->cp_cmd |= RxVlan;
+
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
 
@@ -3154,10 +3150,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
 
-#ifdef CONFIG_R8169_VLAN
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
-	dev->features |= NETIF_F_GRO;
+	dev->features |= NETIF_F_HW_VLAN_TX_RX | NETIF_F_GRO;
 
 	tp->intr_mask = 0xffff;
 	tp->hw_start = cfg->hw_start;
@@ -3273,12 +3266,7 @@ static int rtl8169_open(struct net_device *dev)
 
 	rtl8169_init_phy(dev, tp);
 
-	/*
-	 * Pretend we are using VLANs; This bypasses a nasty bug where
-	 * Interrupts stop flowing on high load on 8110SCd controllers.
-	 */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
-		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | RxVlan);
+	rtl8169_vlan_mode(dev);
 
 	rtl_pll_power_up(tp);
 
@@ -4589,12 +4577,12 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 
-			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
-				if (likely(polling))
-					napi_gro_receive(&tp->napi, skb);
-				else
-					netif_rx(skb);
-			}
+			rtl8169_rx_vlan_tag(desc, skb);
+
+			if (likely(polling))
+				napi_gro_receive(&tp->napi, skb);
+			else
+				netif_rx(skb);
 
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
