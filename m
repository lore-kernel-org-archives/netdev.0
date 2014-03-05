From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 2/2] gianfar: Make multi-queue polling optional
Date: Wed, 5 Mar 2014 10:28:39 +0200
Message-ID: <1394008119-27899-3-git-send-email-claudiu.manoil@freescale.com>
References: <1394008119-27899-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:24148
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751551AbaCEIaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 03:30:14 -0500
In-Reply-To: <1394008119-27899-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the newer controllers (etsec2 models) the driver currently
supports 8 Tx and Rx DMA rings (aka HW queues).  However, there
are only 2 pairs of Rx/Tx interrupt lines, as these controllers
are integrated in low power SoCs with 2 CPUs at most.  As a result,
there are at most 2 NAPI instances that have to service multiple
Tx and Rx queues for these devices.  This complicates the NAPI
polling routine having to iterate over the mutiple Rx/Tx queues
hooked to the same interrupt lines.  And there's also an overhead
at HW level, as the controller needs to service all the 8 Tx rings
in a round robin manner.  The cumulated overhead shows up for mutiple
parrallel Tx flows transmitted by the kernel stack, when the driver
usually starts returning NETDEV_TX_BUSY and leading to NETDEV WATCHDOG
Tx timeout triggering if the Tx path is congested for too long.

As an alternative, this patch makes the driver support only one
Tx/Rx DMA ring per NAPI instace (per interrupt group or pair
of Tx/Rx interrupt lines) by default.  The simplified single queue
polling routine (gfar_poll_sq) will be the default napi poll routine
for the etsec2 devices too.  Only small adjustments needed to be made
to link the Tx/Rx HW queues with each NAPI instance (2 in this case).
The gfar_poll_sq() is already succefully used by older SQ_SG (single
interrupt group) controllers.  And there's also a significat memory
footprint reduction by supporting 2 Rx/Tx DMA rings (at most), instead
of 8.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 40 +++++++++++++++++++++++++++-----
 drivers/net/ethernet/freescale/gianfar.h | 18 ++++++++++----
 2 files changed, 47 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 1aa2d55..829eb34 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -128,8 +128,10 @@ static void free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 static void gfar_configure_serdes(struct net_device *dev);
+#ifdef GFAR_MULTI_Q_POLL
 static int gfar_poll_rx(struct napi_struct *napi, int budget);
 static int gfar_poll_tx(struct napi_struct *napi, int budget);
+#endif
 static int gfar_poll_rx_sq(struct napi_struct *napi, int budget);
 static int gfar_poll_tx_sq(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -636,7 +638,6 @@ static int gfar_parse_group(struct device_node *np,
 			    struct gfar_private *priv, const char *model)
 {
 	struct gfar_priv_grp *grp = &priv->gfargrp[priv->num_grps];
-	u32 *queue_mask;
 	int i;
 
 	for (i = 0; i < GFAR_NUM_IRQS; i++) {
@@ -665,12 +666,18 @@ static int gfar_parse_group(struct device_node *np,
 	grp->priv = priv;
 	spin_lock_init(&grp->grplock);
 	if (priv->mode == MQ_MG_MODE) {
+#ifdef GFAR_MULTI_Q_POLL
+		u32 *queue_mask;
 		queue_mask = (u32 *)of_get_property(np, "fsl,rx-bit-map", NULL);
 		grp->rx_bit_map = queue_mask ?
 			*queue_mask : (DEFAULT_MAPPING >> priv->num_grps);
 		queue_mask = (u32 *)of_get_property(np, "fsl,tx-bit-map", NULL);
 		grp->tx_bit_map = queue_mask ?
 			*queue_mask : (DEFAULT_MAPPING >> priv->num_grps);
+#else /* One Q per interrupt group: Q0 to G0, Q1 to G1 */
+		grp->rx_bit_map = (DEFAULT_MAPPING >> priv->num_grps);
+		grp->tx_bit_map = (DEFAULT_MAPPING >> priv->num_grps);
+#endif
 	} else {
 		grp->rx_bit_map = 0xFF;
 		grp->tx_bit_map = 0xFF;
@@ -686,6 +693,8 @@ static int gfar_parse_group(struct device_node *np,
 	 * also assign queues to groups
 	 */
 	for_each_set_bit(i, &grp->rx_bit_map, priv->num_rx_queues) {
+		if (!grp->rx_queue)
+			grp->rx_queue = priv->rx_queue[i];
 		grp->num_rx_queues++;
 		grp->rstat |= (RSTAT_CLEAR_RHALT >> i);
 		priv->rqueue |= ((RQUEUE_EN0 | RQUEUE_EX0) >> i);
@@ -693,6 +702,8 @@ static int gfar_parse_group(struct device_node *np,
 	}
 
 	for_each_set_bit(i, &grp->tx_bit_map, priv->num_tx_queues) {
+		if (!grp->tx_queue)
+			grp->tx_queue = priv->tx_queue[i];
 		grp->num_tx_queues++;
 		grp->tstat |= (TSTAT_CLEAR_THALT >> i);
 		priv->tqueue |= (TQUEUE_EN0 >> i);
@@ -726,6 +737,9 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	/* parse the num of tx and rx queues */
 	tx_queues = (u32 *)of_get_property(np, "fsl,num_tx_queues", NULL);
 	num_tx_qs = tx_queues ? *tx_queues : 1;
+#ifndef GFAR_MULTI_Q_POLL
+	num_tx_qs = (num_tx_qs > 2) ? 2 : num_tx_qs; /* one q per int group */
+#endif
 
 	if (num_tx_qs > MAX_TX_QS) {
 		pr_err("num_tx_qs(=%d) greater than MAX_TX_QS(=%d)\n",
@@ -736,6 +750,9 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 
 	rx_queues = (u32 *)of_get_property(np, "fsl,num_rx_queues", NULL);
 	num_rx_qs = rx_queues ? *rx_queues : 1;
+#ifndef GFAR_MULTI_Q_POLL
+	num_rx_qs = (num_rx_qs > 2) ? 2 : num_rx_qs; /* one q per int group */
+#endif
 
 	if (num_rx_qs > MAX_RX_QS) {
 		pr_err("num_rx_qs(=%d) greater than MAX_RX_QS(=%d)\n",
@@ -1271,9 +1288,19 @@ static int gfar_probe(struct platform_device *ofdev)
 	} else {
 		for (i = 0; i < priv->num_grps; i++) {
 			netif_napi_add(dev, &priv->gfargrp[i].napi_rx,
-				       gfar_poll_rx, GFAR_DEV_WEIGHT);
+#ifdef GFAR_MULTI_Q_POLL
+				       gfar_poll_rx,
+#else
+				       gfar_poll_rx_sq,
+#endif
+				       GFAR_DEV_WEIGHT);
 			netif_napi_add(dev, &priv->gfargrp[i].napi_tx,
-				       gfar_poll_tx, 2);
+#ifdef GFAR_MULTI_Q_POLL
+				       gfar_poll_tx,
+#else
+				       gfar_poll_tx_sq,
+#endif
+				       2);
 		}
 	}
 
@@ -2819,7 +2846,7 @@ static int gfar_poll_rx_sq(struct napi_struct *napi, int budget)
 	struct gfar_priv_grp *gfargrp =
 		container_of(napi, struct gfar_priv_grp, napi_rx);
 	struct gfar __iomem *regs = gfargrp->regs;
-	struct gfar_priv_rx_q *rx_queue = gfargrp->priv->rx_queue[0];
+	struct gfar_priv_rx_q *rx_queue = gfargrp->rx_queue;
 	int work_done = 0;
 
 	/* Clear IEVENT, so interrupts aren't called again
@@ -2850,7 +2877,7 @@ static int gfar_poll_tx_sq(struct napi_struct *napi, int budget)
 	struct gfar_priv_grp *gfargrp =
 		container_of(napi, struct gfar_priv_grp, napi_tx);
 	struct gfar __iomem *regs = gfargrp->regs;
-	struct gfar_priv_tx_q *tx_queue = gfargrp->priv->tx_queue[0];
+	struct gfar_priv_tx_q *tx_queue = gfargrp->tx_queue;
 	u32 imask;
 
 	/* Clear IEVENT, so interrupts aren't called again
@@ -2873,6 +2900,7 @@ static int gfar_poll_tx_sq(struct napi_struct *napi, int budget)
 	return 0;
 }
 
+#ifdef GFAR_MULTI_Q_POLL
 static int gfar_poll_rx(struct napi_struct *napi, int budget)
 {
 	struct gfar_priv_grp *gfargrp =
@@ -2972,7 +3000,7 @@ static int gfar_poll_tx(struct napi_struct *napi, int budget)
 
 	return 0;
 }
-
+#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* Polling 'interrupt' - used by things like netconsole to send skbs
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 1aeb34e..a90c848 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -410,9 +410,14 @@ extern const char gfar_driver_version[];
 #define FPR_FILER_MASK	0xFFFFFFFF
 #define MAX_FILER_IDX	0xFF
 
+#ifdef GFAR_MULTI_Q_POLL
 /* This default RIR value directly corresponds
  * to the 3-bit hash value generated */
 #define DEFAULT_RIR0	0x05397700
+#else /* only 2 Qs used */
+/* Map even hash values to Q0, and odd ones to Q1 */
+#define DEFAULT_RIR0	0x04104100
+#endif
 
 /* RQFCR register bits */
 #define RQFCR_GPI		0x80000000
@@ -1016,17 +1021,20 @@ struct gfar_irqinfo {
  */
 
 struct gfar_priv_grp {
-	spinlock_t grplock __attribute__ ((aligned (SMP_CACHE_BYTES)));
+	spinlock_t grplock __aligned(SMP_CACHE_BYTES);
 	struct	napi_struct napi_rx;
 	struct	napi_struct napi_tx;
-	struct gfar_private *priv;
 	struct gfar __iomem *regs;
-	unsigned int rstat;
-	unsigned long num_rx_queues;
-	unsigned long rx_bit_map;
+	struct gfar_priv_tx_q *tx_queue;
+	struct gfar_priv_rx_q *rx_queue;
 	unsigned int tstat;
+	unsigned int rstat;
+
+	struct gfar_private *priv;
 	unsigned long num_tx_queues;
 	unsigned long tx_bit_map;
+	unsigned long num_rx_queues;
+	unsigned long rx_bit_map;
 
 	struct gfar_irqinfo *irqinfo[GFAR_NUM_IRQS];
 };
-- 
1.7.11.7
