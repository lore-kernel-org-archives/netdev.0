From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 04/14] gianfar: Optimize interrupt coalescing configuration
Date: Tue, 16 Dec 2008 17:20:57 -0600
Message-ID: <1229469667-25002-5-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Haruki Dai <Dai.Haruki@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39689 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbYLPXVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:21 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL9ZC013533
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:09 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL8Lm020486
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:08 -0600 (CST)
In-Reply-To: <1229469667-25002-4-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haruki Dai <Dai.Haruki@freescale.com>

Store the interrupt coalescing values in the form in which they will be
written to the interrupt coalescing registers.  This puts a little overhead
into the ethtool configuration, and takes it out of the interrupt handler

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c         |   24 +++++++---------------
 drivers/net/gianfar.h         |   12 +++++++---
 drivers/net/gianfar_ethtool.c |   42 +++++++++++++++++++++++-----------------
 3 files changed, 40 insertions(+), 38 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ad222bf..9b1a423 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -428,11 +428,9 @@ static int gfar_probe(struct of_device *ofdev,
 	priv->rx_ring_size = DEFAULT_RX_RING_SIZE;
 
 	priv->txcoalescing = DEFAULT_TX_COALESCE;
-	priv->txcount = DEFAULT_TXCOUNT;
-	priv->txtime = DEFAULT_TXTIME;
+	priv->txic = DEFAULT_TXIC;
 	priv->rxcoalescing = DEFAULT_RX_COALESCE;
-	priv->rxcount = DEFAULT_RXCOUNT;
-	priv->rxtime = DEFAULT_RXTIME;
+	priv->rxic = DEFAULT_RXIC;
 
 	/* Enable most messages by default */
 	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
@@ -1060,17 +1058,13 @@ int startup_gfar(struct net_device *dev)
 	phy_start(priv->phydev);
 
 	/* Configure the coalescing support */
+	gfar_write(&regs->txic, 0);
 	if (priv->txcoalescing)
-		gfar_write(&regs->txic,
-			   mk_ic_value(priv->txcount, priv->txtime));
-	else
-		gfar_write(&regs->txic, 0);
+		gfar_write(&regs->txic, priv->txic);
 
+	gfar_write(&regs->rxic, 0);
 	if (priv->rxcoalescing)
-		gfar_write(&regs->rxic,
-			   mk_ic_value(priv->rxcount, priv->rxtime));
-	else
-		gfar_write(&regs->rxic, 0);
+		gfar_write(&regs->rxic, priv->rxic);
 
 	if (priv->rx_csum_enable)
 		rctrl |= RCTRL_CHECKSUMMING;
@@ -1534,8 +1528,7 @@ static irqreturn_t gfar_transmit(int irq, void *dev_id)
 	/* Otherwise, clear it */
 	if (likely(priv->txcoalescing)) {
 		gfar_write(&priv->regs->txic, 0);
-		gfar_write(&priv->regs->txic,
-			   mk_ic_value(priv->txcount, priv->txtime));
+		gfar_write(&priv->regs->txic, priv->txic);
 	}
 
 	spin_unlock(&priv->txlock);
@@ -1823,8 +1816,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		/* Otherwise, clear it */
 		if (likely(priv->rxcoalescing)) {
 			gfar_write(&priv->regs->rxic, 0);
-			gfar_write(&priv->regs->rxic,
-				   mk_ic_value(priv->rxcount, priv->rxtime));
+			gfar_write(&priv->regs->rxic, priv->rxic);
 		}
 	}
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index ca7f0a6..449f508 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -189,6 +189,12 @@ extern const char gfar_driver_version[];
 #define mk_ic_value(count, time) (IC_ICEN | \
 				mk_ic_icft(count) | \
 				mk_ic_ictt(time))
+#define get_icft_value(ic)	(((unsigned long)ic & IC_ICFT_MASK) >> \
+				 IC_ICFT_SHIFT)
+#define get_ictt_value(ic)	((unsigned long)ic & IC_ICTT_MASK)
+
+#define DEFAULT_TXIC mk_ic_value(DEFAULT_TXCOUNT, DEFAULT_TXTIME)
+#define DEFAULT_RXIC mk_ic_value(DEFAULT_RXCOUNT, DEFAULT_RXTIME)
 
 #define RCTRL_PAL_MASK		0x001f0000
 #define RCTRL_VLEX		0x00002000
@@ -694,8 +700,7 @@ struct gfar_private {
 
 	/* Configuration info for the coalescing features */
 	unsigned char txcoalescing;
-	unsigned short txcount;
-	unsigned short txtime;
+	unsigned long txic;
 
 	/* Buffer descriptor pointers */
 	struct txbd8 *tx_bd_base;	/* First tx buffer descriptor */
@@ -717,8 +722,7 @@ struct gfar_private {
 
 	/* RX Coalescing values */
 	unsigned char rxcoalescing;
-	unsigned short rxcount;
-	unsigned short rxtime;
+	unsigned long rxic;
 
 	struct rxbd8 *rx_bd_base;	/* First Rx buffers */
 	struct rxbd8 *cur_rx;           /* Next free rx ring entry */
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 53944b1..c111c53 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -201,8 +201,8 @@ static int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (NULL == phydev)
 		return -ENODEV;
 
-	cmd->maxtxpkt = priv->txcount;
-	cmd->maxrxpkt = priv->rxcount;
+	cmd->maxtxpkt = get_icft_value(priv->txic);
+	cmd->maxrxpkt = get_icft_value(priv->rxic);
 
 	return phy_ethtool_gset(phydev, cmd);
 }
@@ -279,6 +279,10 @@ static unsigned int gfar_ticks2usecs(struct gfar_private *priv, unsigned int tic
 static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	unsigned long rxtime;
+	unsigned long rxcount;
+	unsigned long txtime;
+	unsigned long txcount;
 
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
 		return -EOPNOTSUPP;
@@ -286,11 +290,15 @@ static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 	if (NULL == priv->phydev)
 		return -ENODEV;
 
-	cvals->rx_coalesce_usecs = gfar_ticks2usecs(priv, priv->rxtime);
-	cvals->rx_max_coalesced_frames = priv->rxcount;
+	rxtime  = get_ictt_value(priv->rxic);
+	rxcount = get_icft_value(priv->rxic);
+	txtime  = get_ictt_value(priv->txic);
+	txcount = get_icft_value(priv->txic);;
+	cvals->rx_coalesce_usecs = gfar_ticks2usecs(priv, rxtime);
+	cvals->rx_max_coalesced_frames = rxcount;
 
-	cvals->tx_coalesce_usecs = gfar_ticks2usecs(priv, priv->txtime);
-	cvals->tx_max_coalesced_frames = priv->txcount;
+	cvals->tx_coalesce_usecs = gfar_ticks2usecs(priv, txtime);
+	cvals->tx_max_coalesced_frames = txcount;
 
 	cvals->use_adaptive_rx_coalesce = 0;
 	cvals->use_adaptive_tx_coalesce = 0;
@@ -358,8 +366,9 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 		return -EINVAL;
 	}
 
-	priv->rxtime = gfar_usecs2ticks(priv, cvals->rx_coalesce_usecs);
-	priv->rxcount = cvals->rx_max_coalesced_frames;
+	priv->rxic = mk_ic_value(
+		gfar_usecs2ticks(priv, cvals->rx_coalesce_usecs),
+		cvals->rx_max_coalesced_frames);
 
 	/* Set up tx coalescing */
 	if ((cvals->tx_coalesce_usecs == 0) ||
@@ -381,20 +390,17 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 		return -EINVAL;
 	}
 
-	priv->txtime = gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs);
-	priv->txcount = cvals->tx_max_coalesced_frames;
+	priv->txic = mk_ic_value(
+		gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs),
+		cvals->tx_max_coalesced_frames);
 
+	gfar_write(&priv->regs->rxic, 0);
 	if (priv->rxcoalescing)
-		gfar_write(&priv->regs->rxic,
-			   mk_ic_value(priv->rxcount, priv->rxtime));
-	else
-		gfar_write(&priv->regs->rxic, 0);
+		gfar_write(&priv->regs->rxic, priv->rxic);
 
+	gfar_write(&priv->regs->txic, 0);
 	if (priv->txcoalescing)
-		gfar_write(&priv->regs->txic,
-			   mk_ic_value(priv->txcount, priv->txtime));
-	else
-		gfar_write(&priv->regs->txic, 0);
+		gfar_write(&priv->regs->txic, priv->txic);
 
 	return 0;
 }
-- 
1.5.4.GIT

