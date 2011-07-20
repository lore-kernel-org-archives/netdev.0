From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 17/47] gianfar: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:19 +0200
Message-ID: <1311173689-17419-18-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	sebastian.belden@googlemail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822Ab1GTOzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:24 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill priv->vlgrp and gfar_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/gianfar.c         |   55 +++++++++++++++++++++-------------------
 drivers/net/gianfar.h         |    3 +-
 drivers/net/gianfar_ethtool.c |    3 ++
 3 files changed, 33 insertions(+), 28 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index d265c6e..835cd25 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -140,8 +140,6 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
 static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue);
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 			      int amount_pull);
-static void gfar_vlan_rx_register(struct net_device *netdev,
-		                struct vlan_group *grp);
 void gfar_halt(struct net_device *dev);
 static void gfar_halt_nodisable(struct net_device *dev);
 void gfar_start(struct net_device *dev);
@@ -391,10 +389,11 @@ static void gfar_init_mac(struct net_device *ndev)
 		rctrl |= RCTRL_PRSDEP_INIT | RCTRL_TS_ENABLE;
 
 	/* keep vlan related bits if it's enabled */
-	if (priv->vlgrp) {
+	if (ndev->features & NETIF_F_HW_VLAN_TX)
 		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
+
+	if (ndev->features & NETIF_F_HW_VLAN_RX)
 		tctrl |= TCTRL_VLINS;
-	}
 
 	/* Init rctrl based on our settings */
 	gfar_write(&regs->rctrl, rctrl);
@@ -467,7 +466,6 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
 	.ndo_get_stats = gfar_get_stats,
-	.ndo_vlan_rx_register = gfar_vlan_rx_register,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -507,10 +505,17 @@ void unlock_tx_qs(struct gfar_private *priv)
 		spin_unlock(&priv->tx_queue[i]->txlock);
 }
 
+static bool gfar_is_vlan_on(struct gfar_private *priv)
+{
+	return (priv->ndev->features & NETIF_F_HW_VLAN_RX) ||
+	       (priv->ndev->features & NETIF_F_HW_VLAN_TX);
+}
+
 /* Returns 1 if incoming frames use an FCB */
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
-	return priv->vlgrp || (priv->ndev->features & NETIF_F_RXCSUM) ||
+	return gfar_is_vlan_on(priv) ||
+		(priv->ndev->features & NETIF_F_RXCSUM) ||
 		(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER);
 }
 
@@ -1038,10 +1043,10 @@ static int gfar_probe(struct platform_device *ofdev)
 			NETIF_F_RXCSUM | NETIF_F_HIGHDMA;
 	}
 
-	priv->vlgrp = NULL;
-
-	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN)
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN) {
+		dev->hw_features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	}
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
 		priv->extended_hash = 1;
@@ -2304,10 +2309,8 @@ void gfar_check_rx_parser_mode(struct gfar_private *priv)
 	gfar_write(&regs->rctrl, tempval);
 }
 
-
 /* Enables and disables VLAN insertion/extraction */
-static void gfar_vlan_rx_register(struct net_device *dev,
-		struct vlan_group *grp)
+void gfar_vlan_mode(struct net_device *dev, u32 features)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = NULL;
@@ -2318,25 +2321,24 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 	local_irq_save(flags);
 	lock_rx_qs(priv);
 
-	priv->vlgrp = grp;
-
-	if (grp) {
+	if (features & NETIF_F_HW_VLAN_TX) {
 		/* Enable VLAN tag insertion */
 		tempval = gfar_read(&regs->tctrl);
 		tempval |= TCTRL_VLINS;
-
 		gfar_write(&regs->tctrl, tempval);
-
-		/* Enable VLAN tag extraction */
-		tempval = gfar_read(&regs->rctrl);
-		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
-		gfar_write(&regs->rctrl, tempval);
 	} else {
 		/* Disable VLAN tag insertion */
 		tempval = gfar_read(&regs->tctrl);
 		tempval &= ~TCTRL_VLINS;
 		gfar_write(&regs->tctrl, tempval);
+	}
 
+	if (features & NETIF_F_HW_VLAN_RX) {
+		/* Enable VLAN tag extraction */
+		tempval = gfar_read(&regs->rctrl);
+		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
+		gfar_write(&regs->rctrl, tempval);
+	} else {
 		/* Disable VLAN tag extraction */
 		tempval = gfar_read(&regs->rctrl);
 		tempval &= ~RCTRL_VLEX;
@@ -2359,7 +2361,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	int oldsize = priv->rx_buffer_size;
 	int frame_size = new_mtu + ETH_HLEN;
 
-	if (priv->vlgrp)
+	if (gfar_is_vlan_on(priv))
 		frame_size += VLAN_HLEN;
 
 	if ((frame_size < 64) || (frame_size > JUMBO_FRAME_SIZE)) {
@@ -2712,11 +2714,12 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	/* Tell the skb what kind of packet this is */
 	skb->protocol = eth_type_trans(skb, dev);
 
+	/* Set vlan tag */
+	if (fcb->flags & RXFCB_VLN)
+		__vlan_hwaccel_put_tag(skb, fcb->vlctl);
+
 	/* Send the packet up the stack */
-	if (unlikely(priv->vlgrp && (fcb->flags & RXFCB_VLN)))
-		ret = vlan_hwaccel_receive_skb(skb, priv->vlgrp, fcb->vlctl);
-	else
-		ret = netif_receive_skb(skb);
+	ret = netif_receive_skb(skb);
 
 	if (NET_RX_DROP == ret)
 		priv->extra_stats.kernel_dropped++;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 87c1d86..9aa4377 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1077,8 +1077,6 @@ struct gfar_private {
 
 	struct sk_buff_head rx_recycle;
 
-	struct vlan_group *vlgrp;
-
 	/* RX queue filer rule set*/
 	struct ethtool_rx_list rx_list;
 	struct mutex rx_queue_access;
@@ -1183,6 +1181,7 @@ extern void gfar_configure_coalescing(struct gfar_private *priv,
 void gfar_init_sysfs(struct net_device *dev);
 int gfar_set_features(struct net_device *dev, u32 features);
 extern void gfar_check_rx_parser_mode(struct gfar_private *priv);
+extern void gfar_vlan_mode(struct net_device *dev, u32 features);
 
 extern const struct ethtool_ops gfar_ethtool_ops;
 
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 203369c..6e35069 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -526,6 +526,9 @@ int gfar_set_features(struct net_device *dev, u32 features)
 	int err = 0, i = 0;
 	u32 changed = dev->features ^ features;
 
+	if (changed & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
+		gfar_vlan_mode(dev, features);
+
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
 
-- 
1.7.6

