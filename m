From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Wed, 22 Jun 2016 01:09:57 +0200
Message-ID: <20160621230957.GA19674@electric-eye.fr.zoreil.com>
References: <20151122225039.GE2957@marvin.atrad.com.au>
 <20151122230244.GA12249@electric-eye.fr.zoreil.com>
 <20151130064255.GL5537@marvin.atrad.com.au>
 <20151201235852.GA16429@electric-eye.fr.zoreil.com>
 <20160208023318.GJ9174@marvin.atrad.com.au>
 <20160407024417.GE17921@marvin.atrad.com.au>
 <20160517065231.GO30050@marvin.atrad.com.au>
 <20160518065137.GJ27564@marvin.atrad.com.au>
 <20160601003123.GE3384@marvin.atrad.com.au>
 <20160621032133.GC19735@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41867 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbcFUXKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 19:10:39 -0400
Content-Disposition: inline
In-Reply-To: <20160621032133.GC19735@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Woithe <jwoithe@atrad.com.au> :
[...]
> Is there any chance that this regression can be resolved?  It's been 6
> months since the last contact was received from the list in relation to this
> issue.  If the r8169 driver is to remain broken with respect to UDP traffic
> then we will have no choice but to factor in a change in our standard
> hardware for future systems.  Unfortunately this also means that dozens of
> systems in the field cannot be upgraded to recent kernels since doing so
> will trigger the regression.[1]

If I understood correctly (2015/11/21) you had a working system with a stock
4.2 or 4.3 kernel and the r8169.c from 1e874e041fc7c222cbd85b20c4406070be1f687a
(i.e. da78dbff2e05630921c551dbbc70a4b7981a8fff "r8169: remove work from irq
handler." parent) patched with the snippet below, right ?

If so, while not perfect, it should at least mitigate the "can't upgrade
kernel" part.

--- r8169.c	2015-11-21 23:02:10.435275753 +0100
+++ r8169.c	2015-11-21 23:21:49.429554012 +0100
@@ -29,7 +29,6 @@
 #include <linux/pci-aspm.h>
 #include <linux/prefetch.h>
 
-#include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 
@@ -1616,7 +1615,7 @@ static int rtl8169_set_features(struct n
 	else
 		tp->cp_cmd &= ~RxChkSum;
 
-	if (dev->features & NETIF_F_HW_VLAN_RX)
+	if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
 		tp->cp_cmd |= RxVlan;
 	else
 		tp->cp_cmd &= ~RxVlan;
@@ -1632,8 +1631,8 @@ static int rtl8169_set_features(struct n
 static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
 				      struct sk_buff *skb)
 {
-	return (vlan_tx_tag_present(skb)) ?
-		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
+	return (skb_vlan_tag_present(skb)) ?
+		TxVlanTag | swab16(skb_vlan_tag_get(skb)) : 0x00;
 }
 
 static void rtl8169_rx_vlan_tag(struct RxDesc *desc, struct sk_buff *skb)
@@ -1641,7 +1640,7 @@ static void rtl8169_rx_vlan_tag(struct R
 	u32 opts2 = le32_to_cpu(desc->opts2);
 
 	if (opts2 & RxVlanTag)
-		__vlan_hwaccel_put_tag(skb, swab16(opts2 & 0xffff));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), swab16(opts2 & 0xffff));
 
 	desc->opts2 = 0;
 }
@@ -3508,7 +3507,7 @@ static const struct net_device_ops rtl81
 
 };
 
-static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
+static void rtl_init_mdio_ops(struct rtl8169_private *tp)
 {
 	struct mdio_ops *ops = &tp->mdio_ops;
 
@@ -3725,7 +3724,7 @@ static void rtl_pll_power_up(struct rtl8
 	rtl_generic_op(tp, tp->pll_power_ops.up);
 }
 
-static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
+static void rtl_init_pll_power_ops(struct rtl8169_private *tp)
 {
 	struct pll_power_ops *ops = &tp->pll_power_ops;
 
@@ -3905,7 +3904,7 @@ static void r8168b_1_hw_jumbo_disable(st
 	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
 
-static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
+static void rtl_init_jumbo_ops(struct rtl8169_private *tp)
 {
 	struct jumbo_ops *ops = &tp->jumbo_ops;
 
@@ -3971,7 +3970,7 @@ static void rtl_hw_reset(struct rtl8169_
 	}
 }
 
-static int __devinit
+static int
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
@@ -4137,7 +4136,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
+	dev->ethtool_ops = &rtl8169_ethtool_ops;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
@@ -4147,16 +4146,16 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	/* don't enable SG, IP_CSUM and TSO by default - it might not work
 	 * properly for all devices */
 	dev->features |= NETIF_F_RXCSUM |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
-		NETIF_F_RXCSUM | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 		NETIF_F_HIGHDMA;
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
 		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
-		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
+		dev->hw_features &= ~NETIF_F_HW_VLAN_CTAG_RX;
 
 	tp->intr_mask = 0xffff;
 	tp->hw_start = cfg->hw_start;
@@ -4217,7 +4216,7 @@ err_out_free_dev_1:
 	goto out;
 }
 
-static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
+static void rtl8169_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -6218,20 +6217,9 @@ static struct pci_driver rtl8169_pci_dri
 	.name		= MODULENAME,
 	.id_table	= rtl8169_pci_tbl,
 	.probe		= rtl8169_init_one,
-	.remove		= __devexit_p(rtl8169_remove_one),
+	.remove		= rtl8169_remove_one,
 	.shutdown	= rtl_shutdown,
 	.driver.pm	= RTL8169_PM_OPS,
 };
 
-static int __init rtl8169_init_module(void)
-{
-	return pci_register_driver(&rtl8169_pci_driver);
-}
-
-static void __exit rtl8169_cleanup_module(void)
-{
-	pci_unregister_driver(&rtl8169_pci_driver);
-}
-
-module_init(rtl8169_init_module);
-module_exit(rtl8169_cleanup_module);
+module_pci_driver(rtl8169_pci_driver);

-- 

[...]
> If the decision has been made to leave the regression unfixed, please let me
> know.

No such decision that I know of.

-- 
Ueimor
