From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next] gianfar: Fix multi-queue support checks @probe()
Date: Tue, 11 Mar 2014 18:01:24 +0200
Message-ID: <1394553684-12061-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:39358
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752692AbaCKQDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 12:03:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

priv is not instantiated at gfar_of_init() time, when
parsing the DT for info on supported HW queues.  Before
the netdev can be allocated, the number of supported
queues must be known.  Because the number of supported
queues depends on device type, move the compatibility
checks before netdev allocation.  Local vars are used
to hold the operation mode info before netdev allocation.
This fixes the null accesses for priv->.., in gfar_of_init.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 28effbe..68d9bf7 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -733,21 +733,30 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	const u32 *stash_idx;
 	unsigned int num_tx_qs, num_rx_qs;
 	u32 *tx_queues, *rx_queues;
+	unsigned short mode, poll_mode;
 
 	if (!np || !of_device_is_available(np))
 		return -ENODEV;
 
+	if (of_device_is_compatible(np, "fsl,etsec2")) {
+		mode = MQ_MG_MODE;
+		poll_mode = GFAR_SQ_POLLING;
+	} else {
+		mode = SQ_SG_MODE;
+		poll_mode = GFAR_SQ_POLLING;
+	}
+
 	/* parse the num of HW tx and rx queues */
 	tx_queues = (u32 *)of_get_property(np, "fsl,num_tx_queues", NULL);
 	rx_queues = (u32 *)of_get_property(np, "fsl,num_rx_queues", NULL);
 
-	if (priv->mode == SQ_SG_MODE) {
+	if (mode == SQ_SG_MODE) {
 		num_tx_qs = 1;
 		num_rx_qs = 1;
 	} else { /* MQ_MG_MODE */
-		if (priv->poll_mode == GFAR_SQ_POLLING) {
-			num_tx_qs = 2; /* one q per int group */
-			num_rx_qs = 2; /* one q per int group */
+		if (poll_mode == GFAR_SQ_POLLING) {
+			num_tx_qs = 2; /* one txq per int group */
+			num_rx_qs = 2; /* one rxq per int group */
 		} else { /* GFAR_MQ_POLLING */
 			num_tx_qs = tx_queues ? *tx_queues : 1;
 			num_rx_qs = rx_queues ? *rx_queues : 1;
@@ -776,6 +785,9 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	priv = netdev_priv(dev);
 	priv->ndev = dev;
 
+	priv->mode = mode;
+	priv->poll_mode = poll_mode;
+
 	priv->num_tx_queues = num_tx_qs;
 	netif_set_real_num_rx_queues(dev, num_rx_qs);
 	priv->num_rx_queues = num_rx_qs;
@@ -799,17 +811,13 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 		priv->gfargrp[i].regs = NULL;
 
 	/* Parse and initialize group specific information */
-	if (of_device_is_compatible(np, "fsl,etsec2")) {
-		priv->mode = MQ_MG_MODE;
-		priv->poll_mode = GFAR_SQ_POLLING;
+	if (priv->mode == MQ_MG_MODE) {
 		for_each_child_of_node(np, child) {
 			err = gfar_parse_group(child, priv, model);
 			if (err)
 				goto err_grp_init;
 		}
-	} else {
-		priv->mode = SQ_SG_MODE;
-		priv->poll_mode = GFAR_SQ_POLLING;
+	} else { /* SQ_SG_MODE */
 		err = gfar_parse_group(np, priv, model);
 		if (err)
 			goto err_grp_init;
-- 
1.7.11.7
