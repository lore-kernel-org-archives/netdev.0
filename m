From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 8139cp: convert to new VLAN model.
Date: Fri, 15 Jul 2011 12:21:44 +0200
Message-ID: <20110715102144.GA6601@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43001 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965291Ab1GOKgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 06:36:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The registers and descriptors bits are identical to the pre-8168
8169 chipsets : {RxDesc / TxDesc}.opts2 can only contain VLAN information.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/8139cp.c |   83 ++++++++++++++++---------------------------------
 1 files changed, 27 insertions(+), 56 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 73b10b0..cc4c210 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -78,17 +78,6 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-/* VLAN tagging feature enable/disable */
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-#define CP_VLAN_TAG_USED 1
-#define CP_VLAN_TX_TAG(tx_desc,vlan_tag_value) \
-	do { (tx_desc)->opts2 = cpu_to_le32(vlan_tag_value); } while (0)
-#else
-#define CP_VLAN_TAG_USED 0
-#define CP_VLAN_TX_TAG(tx_desc,vlan_tag_value) \
-	do { (tx_desc)->opts2 = 0; } while (0)
-#endif
-
 /* These identify the driver base version and may not be removed. */
 static char version[] =
 DRV_NAME ": 10/100 PCI Ethernet driver v" DRV_VERSION " (" DRV_RELDATE ")\n";
@@ -356,9 +345,6 @@ struct cp_private {
 	unsigned		rx_buf_sz;
 	unsigned		wol_enabled : 1; /* Is Wake-on-LAN enabled? */
 
-#if CP_VLAN_TAG_USED
-	struct vlan_group	*vlgrp;
-#endif
 	dma_addr_t		ring_dma;
 
 	struct mii_if_info	mii_if;
@@ -423,24 +409,6 @@ static struct {
 };
 
 
-#if CP_VLAN_TAG_USED
-static void cp_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct cp_private *cp = netdev_priv(dev);
-	unsigned long flags;
-
-	spin_lock_irqsave(&cp->lock, flags);
-	cp->vlgrp = grp;
-	if (grp)
-		cp->cpcmd |= RxVlanOn;
-	else
-		cp->cpcmd &= ~RxVlanOn;
-
-	cpw16(CpCmd, cp->cpcmd);
-	spin_unlock_irqrestore(&cp->lock, flags);
-}
-#endif /* CP_VLAN_TAG_USED */
-
 static inline void cp_set_rxbufsize (struct cp_private *cp)
 {
 	unsigned int mtu = cp->dev->mtu;
@@ -455,18 +423,17 @@ static inline void cp_set_rxbufsize (struct cp_private *cp)
 static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
 			      struct cp_desc *desc)
 {
+	u32 opts2 = le32_to_cpu(desc->opts2);
+
 	skb->protocol = eth_type_trans (skb, cp->dev);
 
 	cp->dev->stats.rx_packets++;
 	cp->dev->stats.rx_bytes += skb->len;
 
-#if CP_VLAN_TAG_USED
-	if (cp->vlgrp && (desc->opts2 & cpu_to_le32(RxVlanTagged))) {
-		vlan_hwaccel_receive_skb(skb, cp->vlgrp,
-					 swab16(le32_to_cpu(desc->opts2) & 0xffff));
-	} else
-#endif
-		netif_receive_skb(skb);
+	if (opts2 & RxVlanTagged)
+		__vlan_hwaccel_put_tag(skb, swab16(opts2 & 0xffff));
+
+	napi_gro_receive(&cp->napi, skb);
 }
 
 static void cp_rx_err_acct (struct cp_private *cp, unsigned rx_tail,
@@ -730,6 +697,12 @@ static void cp_tx (struct cp_private *cp)
 		netif_wake_queue(cp->dev);
 }
 
+static inline u32 cp_tx_vlan_tag(struct sk_buff *skb)
+{
+	return vlan_tx_tag_present(skb) ?
+		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
+}
+
 static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 					struct net_device *dev)
 {
@@ -737,9 +710,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 	unsigned entry;
 	u32 eor, flags;
 	unsigned long intr_flags;
-#if CP_VLAN_TAG_USED
-	u32 vlan_tag = 0;
-#endif
+	__le32 opts2;
 	int mss = 0;
 
 	spin_lock_irqsave(&cp->lock, intr_flags);
@@ -752,15 +723,12 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-#if CP_VLAN_TAG_USED
-	if (vlan_tx_tag_present(skb))
-		vlan_tag = TxVlanTag | swab16(vlan_tx_tag_get(skb));
-#endif
-
 	entry = cp->tx_head;
 	eor = (entry == (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
 	mss = skb_shinfo(skb)->gso_size;
 
+	opts2 = cpu_to_le32(cp_tx_vlan_tag(skb));
+
 	if (skb_shinfo(skb)->nr_frags == 0) {
 		struct cp_desc *txd = &cp->tx_ring[entry];
 		u32 len;
@@ -768,7 +736,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 
 		len = skb->len;
 		mapping = dma_map_single(&cp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
-		CP_VLAN_TX_TAG(txd, vlan_tag);
+		txd->opts2 = opts2;
 		txd->addr = cpu_to_le64(mapping);
 		wmb();
 
@@ -839,7 +807,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 				ctrl |= LastFrag;
 
 			txd = &cp->tx_ring[entry];
-			CP_VLAN_TX_TAG(txd, vlan_tag);
+			txd->opts2 = opts2;
 			txd->addr = cpu_to_le64(mapping);
 			wmb();
 
@@ -851,7 +819,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 		}
 
 		txd = &cp->tx_ring[first_entry];
-		CP_VLAN_TX_TAG(txd, vlan_tag);
+		txd->opts2 = opts2;
 		txd->addr = cpu_to_le64(first_mapping);
 		wmb();
 
@@ -1431,6 +1399,11 @@ static int cp_set_features(struct net_device *dev, u32 features)
 	else
 		cp->cpcmd &= ~RxChkSum;
 
+	if (features & NETIF_F_HW_VLAN_RX)
+		cp->cpcmd |= RxVlanOn;
+	else
+		cp->cpcmd &= ~RxVlanOn;
+
 	cpw16_f(CpCmd, cp->cpcmd);
 	spin_unlock_irqrestore(&cp->lock, flags);
 
@@ -1818,9 +1791,6 @@ static const struct net_device_ops cp_netdev_ops = {
 	.ndo_start_xmit		= cp_start_xmit,
 	.ndo_tx_timeout		= cp_tx_timeout,
 	.ndo_set_features	= cp_set_features,
-#if CP_VLAN_TAG_USED
-	.ndo_vlan_rx_register	= cp_vlan_rx_register,
-#endif
 #ifdef BROKEN
 	.ndo_change_mtu		= cp_change_mtu,
 #endif
@@ -1949,15 +1919,16 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->ethtool_ops = &cp_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-#if CP_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
 
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
 
 	/* disabled by default until verified */
-	dev->hw_features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
+	dev->hw_features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+		NETIF_F_HIGHDMA;
 
 	dev->irq = pdev->irq;
 
-- 
1.7.4.4

