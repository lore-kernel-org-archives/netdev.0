From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Sat, 21 Nov 2015 23:36:27 +0100
Message-ID: <20151121223627.GA3493@electric-eye.fr.zoreil.com>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
 <20151120024616.GL7136@marvin.atrad.com.au>
 <20151120224534.GA25025@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Cc: netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35003 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590AbbKUWgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 17:36:37 -0500
Content-Disposition: inline
In-Reply-To: <20151120224534.GA25025@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Francois Romieu <romieu@fr.zoreil.com> :
[...]

If you can crash your system at will, you may apply the patch below to
da78dbff2e05630921c551dbbc70a4b7981a8fff ("r8169: remove work from irq
handler.") parent (aka 1e874e041fc7c222cbd85b20c4406070be1f687a) and
build it in a current tree (say 4.2).

If it works it will be easier for me to compare behaviors in current
tree (especially as none of my current test boxes wants to boot with
my own ga311).

How much memory and CPU may I rely on in your test computer ?

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
Ueimor

--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169.patch"

--- r8169.c	2015-11-21 22:27:27.530227533 +0100
+++ r8169.c	2015-11-21 22:52:53.178319309 +0100
@@ -26,7 +26,6 @@
 #include <linux/pm_runtime.h>
 #include <linux/pci-aspm.h>
 
-#include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 
@@ -1011,34 +1010,6 @@ static int rtl8169_set_settings(struct n
 	return ret;
 }
 
-static u32 rtl8169_get_rx_csum(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-
-	return tp->cp_cmd & RxChkSum;
-}
-
-static int rtl8169_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->lock, flags);
-
-	if (data)
-		tp->cp_cmd |= RxChkSum;
-	else
-		tp->cp_cmd &= ~RxChkSum;
-
-	RTL_W16(CPlusCmd, tp->cp_cmd);
-	RTL_R16(CPlusCmd);
-
-	spin_unlock_irqrestore(&tp->lock, flags);
-
-	return 0;
-}
-
 #ifdef CONFIG_R8169_VLAN
 
 static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
@@ -1278,11 +1249,6 @@ static const struct ethtool_ops rtl8169_
 	.set_settings		= rtl8169_set_settings,
 	.get_msglevel		= rtl8169_get_msglevel,
 	.set_msglevel		= rtl8169_set_msglevel,
-	.get_rx_csum		= rtl8169_get_rx_csum,
-	.set_rx_csum		= rtl8169_set_rx_csum,
-	.set_tx_csum		= ethtool_op_set_tx_csum,
-	.set_sg			= ethtool_op_set_sg,
-	.set_tso		= ethtool_op_set_tso,
 	.get_regs		= rtl8169_get_regs,
 	.get_wol		= rtl8169_get_wol,
 	.set_wol		= rtl8169_set_wol,
@@ -2991,7 +2957,7 @@ static const struct net_device_ops rtl81
 	.ndo_change_mtu		= rtl8169_change_mtu,
 	.ndo_set_mac_address	= rtl_set_mac_address,
 	.ndo_do_ioctl		= rtl8169_ioctl,
-	.ndo_set_multicast_list	= rtl_set_rx_mode,
+	.ndo_set_rx_mode        = rtl_set_rx_mode,
 #ifdef CONFIG_R8169_VLAN
 	.ndo_vlan_rx_register	= rtl8169_vlan_rx_register,
 #endif
@@ -3001,7 +2967,7 @@ static const struct net_device_ops rtl81
 
 };
 
-static int __devinit
+static int
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
@@ -3182,7 +3148,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
+	dev->ethtool_ops = &rtl8169_ethtool_ops;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
@@ -3247,7 +3213,7 @@ err_out_free_dev_1:
 	goto out;
 }
 
-static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
+static void rtl8169_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3322,8 +3288,6 @@ static int rtl8169_open(struct net_devic
 	if (retval < 0)
 		goto err_free_rx_1;
 
-	INIT_DELAYED_WORK(&tp->task, NULL);
-
 	smp_mb();
 
 	retval = request_irq(dev->irq, rtl8169_interrupt,
@@ -4149,7 +4113,7 @@ static void rtl8169_schedule_work(struct
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	PREPARE_DELAYED_WORK(&tp->task, task);
+	INIT_WORK(&tp->task.work, task);
 	schedule_delayed_work(&tp->task, 4);
 }
 
@@ -4257,7 +4221,7 @@ static int rtl8169_xmit_frags(struct rtl
 
 		txd = tp->TxDescArray + entry;
 		len = frag->size;
-		addr = ((void *) page_address(frag->page)) + frag->page_offset;
+		addr = skb_frag_address(frag);
 		mapping = pci_map_single(tp->pci_dev, addr, len, PCI_DMA_TODEVICE);
 
 		/* anti gcc 2.95.3 bugware (sic) */
@@ -5019,7 +4983,7 @@ static struct pci_driver rtl8169_pci_dri
 	.name		= MODULENAME,
 	.id_table	= rtl8169_pci_tbl,
 	.probe		= rtl8169_init_one,
-	.remove		= __devexit_p(rtl8169_remove_one),
+	.remove		= rtl8169_remove_one,
 	.shutdown	= rtl_shutdown,
 	.driver.pm	= RTL8169_PM_OPS,
 };

--9amGYk9869ThD9tj--
