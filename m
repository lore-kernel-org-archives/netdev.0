From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: [PATCH] gianfar: add support for LFC (Lossless Flow Control)
Date: Fri,  9 Aug 2013 10:26:30 +0200
Message-ID: <1376036790-18238-3-git-send-email-ljaenicke@innominate.com>
References: <1375987549.2853.67.camel@deadeye.wl.decadent.org.uk>
 <1376036790-18238-1-git-send-email-ljaenicke@innominate.com>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lutz Jaenicke <ljaenicke@innominate.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.bln.innominate.com ([77.245.32.75]:51863 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030575Ab3HII0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 04:26:41 -0400
In-Reply-To: <1376036790-18238-1-git-send-email-ljaenicke@innominate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement Lossless Flow Control (let the MAC automatically generate
PAUSE frames in case of too much incoming traffic.
Selection of this feature is performed via device tree parameter.
The board (and processor) specific device tree is authoritative wrt this
information.
---
 drivers/net/ethernet/freescale/gianfar.c |   40 +++++++++++++++++++++++++++++-
 drivers/net/ethernet/freescale/gianfar.h |   34 ++++++++++++++++++++++++-
 2 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 8436f00..5273492 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -169,10 +169,12 @@ static void gfar_init_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 static int gfar_init_bds(struct net_device *ndev)
 {
 	struct gfar_private *priv = netdev_priv(ndev);
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
+	u32 *rfbptr;
 	int i, j;
 
 	for (i = 0; i < priv->num_tx_queues; i++) {
@@ -197,6 +199,7 @@ static int gfar_init_bds(struct net_device *ndev)
 		txbdp->status |= TXBD_WRAP;
 	}
 
+	rfbptr = &regs->rfbptr0;
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_queue = priv->rx_queue[i];
 		rx_queue->cur_rx = rx_queue->rx_bd_base;
@@ -222,6 +225,11 @@ static int gfar_init_bds(struct net_device *ndev)
 
 			rxbdp++;
 		}
+		if (priv->device_flags & FSL_GIANFAR_DEV_HAS_LFC)
+			rx_queue->rfbptr = rfbptr;
+		else
+			rx_queue->rfbptr = 0;
+		rfbptr += 2;
 
 	}
 
@@ -340,6 +348,19 @@ static void gfar_init_tx_rx_base(struct gfar_private *priv)
 	}
 }
 
+static void gfar_init_rqprm(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 __iomem *baddr;
+	int i;
+
+	baddr = &regs->rqprm0;
+	for(i = 0; i < priv->num_rx_queues; i++) {
+		gfar_write(baddr, priv->rx_queue[i]->rx_ring_size | (DEFAULT_RX_LFC_THR << FBTHR_SHIFT));
+		baddr++;
+	}
+}
+
 static void gfar_init_mac(struct net_device *ndev)
 {
 	struct gfar_private *priv = netdev_priv(ndev);
@@ -348,6 +369,15 @@ static void gfar_init_mac(struct net_device *ndev)
 	u32 tctrl = 0;
 	u32 attrs = 0;
 
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_LFC) {
+		/* Clear the LFC bit */
+		gfar_write(&regs->rctrl, rctrl);
+		/* Init flow control threshold values */
+		gfar_init_rqprm(priv);
+		gfar_write(&regs->ptv, DEFAULT_LFC_PTVVAL);
+		rctrl |= RCTRL_LFC;
+	}
+
 	/* write the tx/rx base registers */
 	gfar_init_tx_rx_base(priv);
 
@@ -443,7 +473,6 @@ static struct net_device_stats *gfar_get_stats(struct net_device *dev)
 
 	dev->stats.tx_bytes = tx_bytes;
 	dev->stats.tx_packets = tx_packets;
-
 	return &dev->stats;
 }
 
@@ -672,6 +701,7 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	const u32 *stash;
 	const u32 *stash_len;
 	const u32 *stash_idx;
+	const int *lfc_flag;
 	unsigned int num_tx_qs, num_rx_qs;
 	u32 *tx_queues, *rx_queues;
 
@@ -824,6 +854,10 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	if (of_get_property(np, "fsl,magic-packet", NULL))
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
 
+	lfc_flag = of_get_property(np, "fsl,lossless-flow-ctrl", NULL);
+	if (lfc_flag && (*lfc_flag == 1))
+		priv->device_flags |= FSL_GIANFAR_DEV_HAS_LFC;
+
 	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
 
 	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
@@ -2900,6 +2934,10 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		/* Setup the new bdp */
 		gfar_new_rxbdp(rx_queue, bdp, newskb);
 
+		/* Update Last Free RxBD pointer for LFC */
+		if (rx_queue->rfbptr)
+			gfar_write(rx_queue->rfbptr, (u32)bdp);
+
 		/* Update to the next pointer */
 		bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 41740e2..0a6ae93 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -104,6 +104,10 @@ extern const char gfar_driver_version[];
 #define GFAR_MAX_FIFO_STARVE	511
 #define GFAR_MAX_FIFO_STARVE_OFF 511
 
+#define FBTHR_SHIFT		24
+#define DEFAULT_RX_LFC_THR	16
+#define DEFAULT_LFC_PTVVAL	4
+
 #define DEFAULT_RX_BUFFER_SIZE  1536
 #define TX_RING_MOD_MASK(size) (size-1)
 #define RX_RING_MOD_MASK(size) (size-1)
@@ -278,6 +282,7 @@ extern const char gfar_driver_version[];
 
 #define RCTRL_TS_ENABLE 	0x01000000
 #define RCTRL_PAL_MASK		0x001f0000
+#define RCTRL_LFC		0x00004000
 #define RCTRL_VLEX		0x00002000
 #define RCTRL_FILREN		0x00001000
 #define RCTRL_GHTX		0x00000400
@@ -850,7 +855,32 @@ struct gfar {
 	u8	res23c[248];
 	u32	attr;		/* 0x.bf8 - Attributes Register */
 	u32	attreli;	/* 0x.bfc - Attributes Extract Length and Extract Index Register */
-	u8	res24[688];
+	u32	rqprm0;		/* 0x.c00 - Receive queue parameters register 0 */
+	u32	rqprm1;		/* 0x.c04 - Receive queue parameters register 1 */
+	u32	rqprm2;		/* 0x.c08 - Receive queue parameters register 2 */
+	u32	rqprm3;		/* 0x.c0c - Receive queue parameters register 3 */
+	u32	rqprm4;		/* 0x.c10 - Receive queue parameters register 4 */
+	u32	rqprm5;		/* 0x.c14 - Receive queue parameters register 5 */
+	u32	rqprm6;		/* 0x.c18 - Receive queue parameters register 6 */
+	u32	rqprm7;		/* 0x.c1c - Receive queue parameters register 7 */
+	u8	res24[36];
+	u32	rfbptr0;	/* 0x.c44 - Last free RxBD pointer for ring 0 */
+	u8	res24a[4];
+	u32	rfbptr1;	/* 0x.c4c - Last free RxBD pointer for ring 1 */
+	u8	res24b[4];
+	u32	rfbptr2;	/* 0x.c54 - Last free RxBD pointer for ring 2 */
+	u8	res24c[4];
+	u32	rfbptr3;	/* 0x.c5c - Last free RxBD pointer for ring 3 */
+	u8	res24d[4];
+	u32	rfbptr4;	/* 0x.c64 - Last free RxBD pointer for ring 4 */
+	u8	res24e[4];
+	u32	rfbptr5;	/* 0x.c6c - Last free RxBD pointer for ring 5 */
+	u8	res24f[4];
+	u32	rfbptr6;	/* 0x.c74 - Last free RxBD pointer for ring 6 */
+	u8	res24g[4];
+	u32	rfbptr7;	/* 0x.c7c - Last free RxBD pointer for ring 7 */
+	u8	res24h[4];
+	u8	res24x[556];
 	u32	isrg0;		/* 0x.eb0 - Interrupt steering group 0 register */
 	u32	isrg1;		/* 0x.eb4 - Interrupt steering group 1 register */
 	u32	isrg2;		/* 0x.eb8 - Interrupt steering group 2 register */
@@ -889,6 +919,7 @@ struct gfar {
 #define FSL_GIANFAR_DEV_HAS_BD_STASHING		0x00000200
 #define FSL_GIANFAR_DEV_HAS_BUF_STASHING	0x00000400
 #define FSL_GIANFAR_DEV_HAS_TIMER		0x00000800
+#define FSL_GIANFAR_DEV_HAS_LFC			0x80000000
 
 #if (MAXGROUPS == 2)
 #define DEFAULT_MAPPING 	0xAA
@@ -998,6 +1029,7 @@ struct gfar_priv_rx_q {
 	/* RX Coalescing values */
 	unsigned char rxcoalescing;
 	unsigned long rxic;
+	u32	*rfbptr;
 };
 
 /**
-- 
1.7.10.4
