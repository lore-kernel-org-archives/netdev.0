From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 11/11] r8169: vlan support
Date: Tue, 24 Aug 2004 00:59:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823225821.GK20726@electric-eye.fr.zoreil.com>
References: <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com> <20040823224927.GE20726@electric-eye.fr.zoreil.com> <20040823225120.GF20726@electric-eye.fr.zoreil.com> <20040823225335.GG20726@electric-eye.fr.zoreil.com> <20040823225505.GH20726@electric-eye.fr.zoreil.com> <20040823225620.GI20726@electric-eye.fr.zoreil.com> <20040823225713.GJ20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823225713.GJ20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

802.1Q support.
Mostly stolen from the 8139cp.c driver. The relevant registers and
descriptors bits are identical for both chipsets.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-110 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-110	2004-08-23 23:31:33.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:31:33.000000000 +0200
@@ -50,6 +50,7 @@ VERSION 1.6LK	<2004/04/14>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/if_vlan.h>
 #include <linux/crc32.h>
 #include <linux/in.h>
 #include <linux/ip.h>
@@ -78,9 +79,11 @@ VERSION 1.6LK	<2004/04/14>
 
 #ifdef CONFIG_R8169_NAPI
 #define rtl8169_rx_skb			netif_receive_skb
+#define rtl8169_rx_hwaccel_skb		vlan_hwaccel_rx
 #define rtl8169_rx_quota(count, quota)	min(count, quota)
 #else
 #define rtl8169_rx_skb			netif_rx
+#define rtl8169_rx_hwaccel_skb		vlan_hwaccel_receive_skb
 #define rtl8169_rx_quota(count, quota)	count
 #endif
 
@@ -320,6 +323,7 @@ enum _DescStatusBit {
 	IPCS		= (1 << 18), /* Calculate IP checksum */
 	UDPCS		= (1 << 17), /* Calculate UDP/IP checksum */
 	TCPCS		= (1 << 16), /* Calculate TCP/IP checksum */
+	TxVlanTag	= (1 << 17), /* Add VLAN tag */
 
 	/* Rx private */
 	PID1		= (1 << 18), /* Protocol ID bit 1/2 */
@@ -333,6 +337,7 @@ enum _DescStatusBit {
 	IPFail		= (1 << 16), /* IP checksum failed */
 	UDPFail		= (1 << 15), /* UDP/IP checksum failed */
 	TCPFail		= (1 << 14), /* TCP/IP checksum failed */
+	RxVlanTag	= (1 << 16), /* VLAN tag available */
 };
 
 #define RsvdMask	0x3fffc000
@@ -379,7 +384,9 @@ struct rtl8169_private {
 	u16 intr_mask;
 	int phy_auto_nego_reg;
 	int phy_1000_ctrl_reg;
-
+#ifdef CONFIG_R8169_VLAN
+	struct vlan_group *vlgrp;
+#endif
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void *);
@@ -664,6 +671,77 @@ static int rtl8169_set_rx_csum(struct ne
 	return 0;
 }
 
+#ifdef CONFIG_R8169_VLAN
+
+static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
+				      struct sk_buff *skb)
+{
+	return (tp->vlgrp && vlan_tx_tag_present(skb)) ?
+		TxVlanTag | cpu_to_be16(vlan_tx_tag_get(skb)) : 0x00;
+}
+
+static void rtl8169_vlan_rx_register(struct net_device *dev,
+				     struct vlan_group *grp)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tp->lock, flags);
+	tp->vlgrp = grp;
+	tp->cp_cmd |= RxVlan;
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+	RTL_R16(CPlusCmd);
+	spin_unlock_irqrestore(&tp->lock, flags);
+}
+
+static void rtl8169_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tp->lock, flags);
+	tp->cp_cmd &= ~RxVlan;
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+	RTL_R16(CPlusCmd);
+	if (tp->vlgrp)
+		tp->vlgrp->vlan_devices[vid] = NULL;
+	spin_unlock_irqrestore(&tp->lock, flags);
+}
+
+static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
+			       struct sk_buff *skb)
+{
+	u32 opts2 = desc->opts2;
+	int ret;
+
+	if (tp->vlgrp && (opts2 & RxVlanTag)) {
+		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp,
+				       be16_to_cpu(opts2 & 0xffff));
+		ret = 0;
+	} else
+		ret = -1;
+	desc->opts2 = 0;
+	return ret;
+}
+
+#else /* !CONFIG_R8169_VLAN */
+
+static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
+				      struct sk_buff *skb)
+{
+	return 0;
+}
+
+static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
+			       struct sk_buff *skb)
+{
+	return -1;
+}
+
+#endif
+
 static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1072,6 +1150,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
+	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+
 	if ((sizeof(dma_addr_t) > 32) && !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		tp->cp_cmd |= PCIDAC;
 		dev->features |= NETIF_F_HIGHDMA;
@@ -1206,11 +1286,19 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
+
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
 	dev->weight = R8169_NAPI_WEIGHT;
 	printk(KERN_INFO PFX "NAPI enabled\n");
 #endif
+
+#ifdef CONFIG_R8169_VLAN
+	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->vlan_rx_register = rtl8169_vlan_rx_register;
+	dev->vlan_rx_kill_vid = rtl8169_vlan_rx_kill_vid;
+#endif
+
 	tp->intr_mask = 0xffff;
 	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
@@ -1560,6 +1648,7 @@ static void rtl8169_unmap_tx_skb(struct 
 	unsigned int len = tx_skb->len;
 
 	pci_unmap_single(pdev, le64_to_cpu(desc->addr), len, PCI_DMA_TODEVICE);
+	desc->opts2 = 0x00;
 	desc->addr = 0x00;
 	tx_skb->len = 0;
 }
@@ -1711,6 +1800,7 @@ static int rtl8169_start_xmit(struct sk_
 
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
+	txd->opts2 = rtl8169_tx_vlan_tag(tp, skb);
 
 	wmb();
 
@@ -1878,7 +1968,9 @@ rtl8169_rx_interrupt(struct net_device *
 			skb->dev = dev;
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
-			rtl8169_rx_skb(skb);
+
+			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
+				rtl8169_rx_skb(skb);
 
 			dev->last_rx = jiffies;
 			tp->stats.rx_bytes += pkt_size;
diff -puN drivers/net/Kconfig~r8169-110 drivers/net/Kconfig
--- linux-2.6.8.1/drivers/net/Kconfig~r8169-110	2004-08-23 23:31:33.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/Kconfig	2004-08-23 23:31:33.000000000 +0200
@@ -2061,6 +2061,15 @@ config R8169_NAPI
 
 	  If in doubt, say N.
 
+config R8169_VLAN
+	bool "VLAN support"
+	depends on R8169 && VLAN_8021Q
+	---help---
+	  Say Y here for the r8169 driver to support the functions required
+	  by the kernel 802.1Q code.
+	  
+	  If in doubt, say Y.
+
 config SK98LIN
 	tristate "Marvell Yukon Chipset / SysKonnect SK-98xx Support"
 	depends on PCI

_
