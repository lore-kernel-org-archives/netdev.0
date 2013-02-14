From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 7/7] gianfar: Fix and cleanup Rx FCB indication
Date: Thu, 14 Feb 2013 17:00:07 +0200
Message-ID: <1360854007-11094-8-git-send-email-claudiu.manoil@freescale.com>
References: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-2-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-3-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-4-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-5-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-6-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-7-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:2142
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760310Ab3BNPBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:01:41 -0500
In-Reply-To: <1360854007-11094-7-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a less obvious error on one hand, and prevents futher
similar errors by disambiguating and optimizing RxFCB indication,
on the other hand.

The error consists in NETIF_F_HW_VLAN_TX flag being used as an
indication of Rx FCB insertion. This happened as soon gfar_uses_fcb(),
which despite its name indicates Rx FCB insertion, started
incorporating is_vlan_on().
is_vlan_on(), on the other hand, is also a misleading construct because
we need to differentiate b/w hw VLAN extraction/VLEX (marked by VLAN_RX
flag) and hw VLAN insertion/VLINS (VLAN_TX flag), which are different
mechanisms using different types of FCBs.

The hw spec for the RxFCB feature is as follows:
In the case of RxBD rings, FCBs (Frame Control Block) are inserted by
the eTSEC whenever RCTRL[PRSDEP] is set to a non-zero value. Only one
FCB is inserted per frame (in the buffer pointed to by the RxBD with
bit F set). TOE acceleration for receive is enabled for all rx frames
in this case.

This patch introduces priv->uses_rxfcb field to quickly signal RxFCB
insertion in accordance with the specification above.

The dependency on FSL_GIANFAR_DEV_HAS_TIMER was also eliminated as
another source of confusion. The actual dependency is to priv->hwts_rx_en.
Upon changing priv->hwts_rx_en via IOCTL, the gfar device is being
restarted and on init_mac() the priv->hwts_rx_en flag determines RxFCB
insertion, and rctrl is programmed accordingly. The patch takes care
of this case too.

Though maybe not as self documenting as the inlining version uses_fcb(),
priv->uses_rxfcb has the main purpose to quickly signal, on the hot path,
that the incoming frame has a *Rx* FCB block inserted which needs to be
pulled out before passing the skb to the stack. This is a performance
critical operation, it needs to happen fast, that's why uses_rxfcb is
placed in the first cacheline of gfar_private.
This is also why a cached rctrl cannot be used instead: 1) because
we don't have 32 bits available in the first cacheline of gfar_priv
(but only 16); 2) bit operations are expensive on the hot path.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   41 ++++++++++++++---------------
 drivers/net/ethernet/freescale/gianfar.h |    1 +
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index b2c6077..4b5e8a6 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -344,6 +344,9 @@ static void gfar_init_mac(struct net_device *ndev)
 	/* Configure the coalescing support */
 	gfar_configure_coalescing(priv, 0xFF, 0xFF);
 
+	/* set this when rx hw offload (TOE) functions are being used */
+	priv->uses_rxfcb = 0;
+
 	if (priv->rx_filer_enable) {
 		rctrl |= RCTRL_FILREN;
 		/* Program the RIR0 reg with the required distribution */
@@ -354,8 +357,10 @@ static void gfar_init_mac(struct net_device *ndev)
 	if (ndev->flags & IFF_PROMISC)
 		rctrl |= RCTRL_PROM;
 
-	if (ndev->features & NETIF_F_RXCSUM)
+	if (ndev->features & NETIF_F_RXCSUM) {
 		rctrl |= RCTRL_CHECKSUMMING;
+		priv->uses_rxfcb = 1;
+	}
 
 	if (priv->extended_hash) {
 		rctrl |= RCTRL_EXTHASH;
@@ -377,11 +382,15 @@ static void gfar_init_mac(struct net_device *ndev)
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
@@ -500,20 +509,6 @@ void unlock_tx_qs(struct gfar_private *priv)
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
@@ -2326,10 +2321,13 @@ void gfar_check_rx_parser_mode(struct gfar_private *priv)
 
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
 
@@ -2362,6 +2360,7 @@ void gfar_vlan_mode(struct net_device *dev, netdev_features_t features)
 		tempval = gfar_read(&regs->rctrl);
 		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
 		gfar_write(&regs->rctrl, tempval);
+		priv->uses_rxfcb = 1;
 	} else {
 		/* Disable VLAN tag extraction */
 		tempval = gfar_read(&regs->rctrl);
@@ -2390,7 +2389,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 	}
 
-	if (gfar_uses_fcb(priv))
+	if (priv->uses_rxfcb)
 		frame_size += GMAC_FCB_LEN;
 
 	frame_size += priv->padding;
@@ -2759,7 +2758,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 	bdp = rx_queue->cur_rx;
 	base = rx_queue->rx_bd_base;
 
-	amount_pull = (gfar_uses_fcb(priv) ? GMAC_FCB_LEN : 0);
+	amount_pull = priv->uses_rxfcb ? GMAC_FCB_LEN : 0;
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
 		struct sk_buff *newskb;
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 1e2ce8b..63a28d2 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1056,6 +1056,7 @@ struct gfar_private {
 	enum gfar_errata errata;
 	unsigned int rx_buffer_size;
 
+	u16 uses_rxfcb;
 	u16 padding;
 
 	/* HW time stamping enabled flag */
-- 
1.7.7.4
