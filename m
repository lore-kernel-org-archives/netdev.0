From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] sky2: convert to new VLAN model (v0.2)
Date: Fri, 7 Jan 2011 20:13:50 -0800
Message-ID: <20110107201350.0be350bf@nehalam>
References: <20110106204146.16b3a328@nehalam>
	<AANLkTikwGQFByOZGgCCjTJySPa8QYndZ903CFmOkS1Ha@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60719 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399Ab1AHEOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 23:14:01 -0500
In-Reply-To: <AANLkTikwGQFByOZGgCCjTJySPa8QYndZ903CFmOkS1Ha@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts sky2 to new VLAN offload flags control via ethtool.
It also allows for transmit offload of vlan tagged frames which
was not possible before.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Changed the setting of vlan_features in this version to keep
non-offload settings (GRO|HIGHDMA) even if vlan offload is not
enabled.

--- a/drivers/net/sky2.c	2011-01-07 20:06:03.082168965 -0800
+++ b/drivers/net/sky2.c	2011-01-07 20:09:06.006180327 -0800
@@ -46,10 +46,6 @@
 
 #include <asm/irq.h>
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-#define SKY2_VLAN_TAG_USED 1
-#endif
-
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
@@ -1326,39 +1322,34 @@ static int sky2_ioctl(struct net_device
 	return err;
 }
 
-#ifdef SKY2_VLAN_TAG_USED
-static void sky2_set_vlan_mode(struct sky2_hw *hw, u16 port, bool onoff)
-{
-	if (onoff) {
-		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
-			     RX_VLAN_STRIP_ON);
-		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     TX_VLAN_TAG_ON);
-	} else {
-		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
-			     RX_VLAN_STRIP_OFF);
-		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     TX_VLAN_TAG_OFF);
-	}
-}
+#define NETIF_F_ALL_VLAN (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX)
 
-static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
+static void sky2_vlan_mode(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	u16 port = sky2->port;
 
-	netif_tx_lock_bh(dev);
-	napi_disable(&hw->napi);
+	if (dev->features & NETIF_F_HW_VLAN_RX)
+		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
+			     RX_VLAN_STRIP_ON);
+	else
+		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
+			     RX_VLAN_STRIP_OFF);
 
-	sky2->vlgrp = grp;
-	sky2_set_vlan_mode(hw, port, grp != NULL);
+	dev->vlan_features = dev->features &~ NETIF_F_ALL_VLAN;
+	if (dev->features & NETIF_F_HW_VLAN_TX)
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_VLAN_TAG_ON);
+	else {
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_VLAN_TAG_OFF);
 
-	sky2_read32(hw, B0_Y2_SP_LISR);
-	napi_enable(&hw->napi);
-	netif_tx_unlock_bh(dev);
+		/* Can't do transmit offload of vlan without hw vlan */
+		dev->vlan_features &= ~(NETIF_F_TSO | NETIF_F_SG
+					| NETIF_F_ALL_CSUM);
+	}
 }
-#endif
 
 /* Amount of required worst case padding in rx buffer */
 static inline unsigned sky2_rx_pad(const struct sky2_hw *hw)
@@ -1635,9 +1626,7 @@ static void sky2_hw_up(struct sky2_port
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   sky2->tx_ring_size - 1);
 
-#ifdef SKY2_VLAN_TAG_USED
-	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
-#endif
+	sky2_vlan_mode(sky2->netdev);
 
 	sky2_rx_start(sky2);
 }
@@ -1780,7 +1769,7 @@ static netdev_tx_t sky2_xmit_frame(struc
 	}
 
 	ctrl = 0;
-#ifdef SKY2_VLAN_TAG_USED
+
 	/* Add VLAN tag, can piggyback on LRGLEN or ADDR64 */
 	if (vlan_tx_tag_present(skb)) {
 		if (!le) {
@@ -1792,7 +1781,6 @@ static netdev_tx_t sky2_xmit_frame(struc
 		le->length = cpu_to_be16(vlan_tx_tag_get(skb));
 		ctrl |= INS_VLAN;
 	}
-#endif
 
 	/* Handle TCP checksum offload */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -2432,11 +2420,8 @@ static struct sk_buff *sky2_receive(stru
 	struct sk_buff *skb = NULL;
 	u16 count = (status & GMR_FS_LEN) >> 16;
 
-#ifdef SKY2_VLAN_TAG_USED
-	/* Account for vlan tag */
-	if (sky2->vlgrp && (status & GMR_FS_VLAN))
-		count -= VLAN_HLEN;
-#endif
+	if (status & GMR_FS_VLAN)
+		count -= VLAN_HLEN;	/* Account for vlan tag */
 
 	netif_printk(sky2, rx_status, KERN_DEBUG, dev,
 		     "rx slot %u status 0x%x len %d\n",
@@ -2504,17 +2489,9 @@ static inline void sky2_tx_done(struct n
 static inline void sky2_skb_rx(const struct sky2_port *sky2,
 			       u32 status, struct sk_buff *skb)
 {
-#ifdef SKY2_VLAN_TAG_USED
-	u16 vlan_tag = be16_to_cpu(sky2->rx_tag);
-	if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
-		if (skb->ip_summed == CHECKSUM_NONE)
-			vlan_hwaccel_receive_skb(skb, sky2->vlgrp, vlan_tag);
-		else
-			vlan_gro_receive(&sky2->hw->napi, sky2->vlgrp,
-					 vlan_tag, skb);
-		return;
-	}
-#endif
+	if (status & GMR_FS_VLAN)
+		__vlan_hwaccel_put_tag(skb, be16_to_cpu(sky2->rx_tag));
+
 	if (skb->ip_summed == CHECKSUM_NONE)
 		netif_receive_skb(skb);
 	else
@@ -2631,7 +2608,6 @@ static int sky2_status_intr(struct sky2_
 				goto exit_loop;
 			break;
 
-#ifdef SKY2_VLAN_TAG_USED
 		case OP_RXVLAN:
 			sky2->rx_tag = length;
 			break;
@@ -2639,7 +2615,6 @@ static int sky2_status_intr(struct sky2_
 		case OP_RXCHKSVLAN:
 			sky2->rx_tag = length;
 			/* fall through */
-#endif
 		case OP_RXCHKS:
 			if (likely(sky2->flags & SKY2_FLAG_RX_CHECKSUM))
 				sky2_rx_checksum(sky2, status);
@@ -3042,6 +3017,10 @@ static int __devinit sky2_init(struct sk
 			| SKY2_HW_NEW_LE
 			| SKY2_HW_AUTO_TX_SUM
 			| SKY2_HW_ADV_POWER_CTL;
+
+		/* The workaround for status conflicts VLAN tag detection. */
+		if (hw->chip_rev == CHIP_REV_YU_FE2_A0)
+			hw->flags |= SKY2_HW_VLAN_BROKEN;
 		break;
 
 	case CHIP_ID_YUKON_SUPR:
@@ -4237,15 +4216,28 @@ static int sky2_set_eeprom(struct net_de
 static int sky2_set_flags(struct net_device *dev, u32 data)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	u32 supported =
-		(sky2->hw->flags & SKY2_HW_RSS_BROKEN) ? 0 : ETH_FLAG_RXHASH;
+	unsigned long old_feat = dev->features;
+	u32 supported = 0;
 	int rc;
 
+	if (!(sky2->hw->flags & SKY2_HW_RSS_BROKEN))
+		supported |= ETH_FLAG_RXHASH;
+
+	if (!(sky2->hw->flags & SKY2_HW_VLAN_BROKEN))
+		supported |= ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN;
+
+	printk(KERN_DEBUG "sky2 set_flags: supported %x data %x\n",
+	       supported, data);
+
 	rc = ethtool_op_set_flags(dev, data, supported);
 	if (rc)
 		return rc;
 
-	rx_set_rss(dev);
+	if ((old_feat ^ dev->features) & NETIF_F_RXHASH)
+		rx_set_rss(dev);
+
+	if ((old_feat ^ dev->features) & NETIF_F_ALL_VLAN)
+		sky2_vlan_mode(dev);
 
 	return 0;
 }
@@ -4281,6 +4273,7 @@ static const struct ethtool_ops sky2_eth
 	.get_sset_count = sky2_get_sset_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
 	.set_flags	= sky2_set_flags,
+	.get_flags	= ethtool_op_get_flags,
 };
 
 #ifdef CONFIG_SKY2_DEBUG
@@ -4562,9 +4555,6 @@ static const struct net_device_ops sky2_
 	.ndo_change_mtu		= sky2_change_mtu,
 	.ndo_tx_timeout		= sky2_tx_timeout,
 	.ndo_get_stats64	= sky2_get_stats,
-#ifdef SKY2_VLAN_TAG_USED
-	.ndo_vlan_rx_register	= sky2_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= sky2_netpoll,
 #endif
@@ -4580,9 +4570,6 @@ static const struct net_device_ops sky2_
 	.ndo_change_mtu		= sky2_change_mtu,
 	.ndo_tx_timeout		= sky2_tx_timeout,
 	.ndo_get_stats64	= sky2_get_stats,
-#ifdef SKY2_VLAN_TAG_USED
-	.ndo_vlan_rx_register	= sky2_vlan_rx_register,
-#endif
   },
 };
 
@@ -4633,7 +4620,8 @@ static __devinit struct net_device *sky2
 	sky2->port = port;
 
 	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG
-		| NETIF_F_TSO  | NETIF_F_GRO;
+		| NETIF_F_TSO | NETIF_F_GRO;
+
 	if (highmem)
 		dev->features |= NETIF_F_HIGHDMA;
 
@@ -4641,13 +4629,8 @@ static __devinit struct net_device *sky2
 	if (!(hw->flags & SKY2_HW_RSS_BROKEN))
 		dev->features |= NETIF_F_RXHASH;
 
-#ifdef SKY2_VLAN_TAG_USED
-	/* The workaround for FE+ status conflicts with VLAN tag detection. */
-	if (!(sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
-	      sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0)) {
+	if (!(hw->flags & SKY2_HW_VLAN_BROKEN))
 		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	}
-#endif
 
 	/* read the mac address */
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
--- a/drivers/net/sky2.h	2011-01-07 20:05:59.982101189 -0800
+++ b/drivers/net/sky2.h	2011-01-07 20:06:03.094169226 -0800
@@ -2236,11 +2236,8 @@ struct sky2_port {
 	u16		     rx_pending;
 	u16		     rx_data_size;
 	u16		     rx_nfrags;
-
-#ifdef SKY2_VLAN_TAG_USED
 	u16		     rx_tag;
-	struct vlan_group    *vlgrp;
-#endif
+
 	struct {
 		unsigned long last;
 		u32	mac_rp;
@@ -2284,6 +2281,7 @@ struct sky2_hw {
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
 #define SKY2_HW_RSS_BROKEN	0x00000100
+#define SKY2_HW_VLAN_BROKEN     0x00000200
 
 	u8	     	     chip_id;
 	u8		     chip_rev;
