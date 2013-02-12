From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 5/5] gianfar: Fix and cleanup Rx FCB handling
Date: Tue, 12 Feb 2013 14:47:17 +0200
Message-ID: <1360673237-349-5-git-send-email-claudiu.manoil@freescale.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com>
 <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com>
 <1360673237-349-3-git-send-email-claudiu.manoil@freescale.com>
 <1360673237-349-4-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:42245
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932967Ab3BLMrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:47:35 -0500
In-Reply-To: <1360673237-349-4-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_HW_VLAN_TX flag must not condition RxFCB usage.
In the case of RxBD rings, FCBs (Frame Control Block) are inserted by
the eTSEC whenever RCTRL[PRSDEP] is set to a non-zero value. Only one
FCB is inserted per frame (in the buffer pointed to by the RxBD with
bit F set). TOE acceleration for receive is enabled for all rx frames
in this case.
Indroduce the uses_rxfcb field to signal RxFCB insertion in accordance
with the specification above (leading to cleaner, less confusing code).

Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   41 ++++++++++++++---------------
 drivers/net/ethernet/freescale/gianfar.h |    1 +
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 59fb3bf..3de608c 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -349,6 +349,9 @@ static void gfar_init_mac(struct net_device *ndev)
 	/* Configure the coalescing support */
 	gfar_configure_coalescing(priv, 0xFF, 0xFF);
 
+	/* set this when rx hw offload (TOE) functions are being used */
+	priv->uses_rxfcb = 0;
+
 	if (priv->rx_filer_enable) {
 		rctrl |= RCTRL_FILREN;
 		/* Program the RIR0 reg with the required distribution */
@@ -359,8 +362,10 @@ static void gfar_init_mac(struct net_device *ndev)
 	if (ndev->flags & IFF_PROMISC)
 		rctrl |= RCTRL_PROM;
 
-	if (ndev->features & NETIF_F_RXCSUM)
+	if (ndev->features & NETIF_F_RXCSUM) {
 		rctrl |= RCTRL_CHECKSUMMING;
+		priv->uses_rxfcb = 1;
+	}
 
 	if (priv->extended_hash) {
 		rctrl |= RCTRL_EXTHASH;
@@ -382,11 +387,15 @@ static void gfar_init_mac(struct net_device *ndev)
 	}
 
 	/* Enable HW time stamping if requested from user space */
-	if (priv->hwts_rx_en)
+	if (priv->hwts_rx_en) {
 		rctrl |= RCTRL_PRSDEP_INIT | RCTRL_TS_ENABLE;
+		priv->uses_rxfcb = 1;
+	}
 
-	if (ndev->features & NETIF_F_HW_VLAN_RX)
+	if (ndev->features & NETIF_F_HW_VLAN_RX) {
 		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
+		priv->uses_rxfcb = 1;
+	}
 
 	/* Init rctrl based on our settings */
 	gfar_write(&regs->rctrl, rctrl);
@@ -505,20 +514,6 @@ void unlock_tx_qs(struct gfar_private *priv)
 		spin_unlock(&priv->tx_queue[i]->txlock);
 }
 
-static bool gfar_is_vlan_on(struct gfar_private *priv)
-{
-	return (priv->ndev->features & NETIF_F_HW_VLAN_RX) ||
-	       (priv->ndev->features & NETIF_F_HW_VLAN_TX);
-}
-
-/* Returns 1 if incoming frames use an FCB */
-static inline int gfar_uses_fcb(struct gfar_private *priv)
-{
-	return gfar_is_vlan_on(priv) ||
-	       (priv->ndev->features & NETIF_F_RXCSUM) ||
-	       (priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER);
-}
-
 static void free_tx_pointers(struct gfar_private *priv)
 {
 	int i;
@@ -2331,10 +2326,13 @@ void gfar_check_rx_parser_mode(struct gfar_private *priv)
 
 	tempval = gfar_read(&regs->rctrl);
 	/* If parse is no longer required, then disable parser */
-	if (tempval & RCTRL_REQ_PARSER)
+	if (tempval & RCTRL_REQ_PARSER) {
 		tempval |= RCTRL_PRSDEP_INIT;
-	else
+		priv->uses_rxfcb = 1;
+	} else {
 		tempval &= ~RCTRL_PRSDEP_INIT;
+		priv->uses_rxfcb = 0;
+	}
 	gfar_write(&regs->rctrl, tempval);
 }
 
@@ -2367,6 +2365,7 @@ void gfar_vlan_mode(struct net_device *dev, netdev_features_t features)
 		tempval = gfar_read(&regs->rctrl);
 		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
 		gfar_write(&regs->rctrl, tempval);
+		priv->uses_rxfcb = 1;
 	} else {
 		/* Disable VLAN tag extraction */
 		tempval = gfar_read(&regs->rctrl);
@@ -2395,7 +2394,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 	}
 
-	if (gfar_uses_fcb(priv))
+	if (priv->uses_rxfcb)
 		frame_size += GMAC_FCB_LEN;
 
 	frame_size += priv->padding;
@@ -2766,7 +2765,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 	bdp = rx_queue->cur_rx;
 	base = rx_queue->rx_bd_base;
 
-	amount_pull = (gfar_uses_fcb(priv) ? GMAC_FCB_LEN : 0);
+	amount_pull = priv->uses_rxfcb ? GMAC_FCB_LEN : 0;
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
 		struct sk_buff *newskb;
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 5304a58..386f1fe 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1061,6 +1061,7 @@ struct gfar_private {
 	enum gfar_errata errata;
 	unsigned int rx_buffer_size;
 
+	u16 uses_rxfcb;
 	u16 padding;
 
 	/* HW time stamping enabled flag */
-- 
1.6.6
