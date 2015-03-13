From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 3/3] gianfar: Consider dts property endianess on handling
Date: Fri, 13 Mar 2015 10:52:32 +0200
Message-ID: <1426236752-7337-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0146.outbound.protection.outlook.com ([157.56.111.146]:5600
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751100AbbCML1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 07:27:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingchang Lu <jingchang.lu@freescale.com>

Use of_property_read*() to get arch endian consistent
property values. Do some refactoring in the process.

Signed-off-by: Jingchang Lu <jingchang.lu@freescale.com>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 77 +++++++++++++++++++-------------
 1 file changed, 47 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 5d6883d..70fa688 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -697,19 +697,28 @@ static int gfar_parse_group(struct device_node *np,
 	grp->priv = priv;
 	spin_lock_init(&grp->grplock);
 	if (priv->mode == MQ_MG_MODE) {
-		u32 *rxq_mask, *txq_mask;
-		rxq_mask = (u32 *)of_get_property(np, "fsl,rx-bit-map", NULL);
-		txq_mask = (u32 *)of_get_property(np, "fsl,tx-bit-map", NULL);
+		u32 rxq_mask, txq_mask;
+		int ret;
+
+		grp->rx_bit_map = (DEFAULT_MAPPING >> priv->num_grps);
+		grp->tx_bit_map = (DEFAULT_MAPPING >> priv->num_grps);
+
+		ret = of_property_read_u32(np, "fsl,rx-bit-map", &rxq_mask);
+		if (!ret) {
+			grp->rx_bit_map = rxq_mask ?
+			rxq_mask : (DEFAULT_MAPPING >> priv->num_grps);
+		}
+
+		ret = of_property_read_u32(np, "fsl,tx-bit-map", &txq_mask);
+		if (!ret) {
+			grp->tx_bit_map = txq_mask ?
+			txq_mask : (DEFAULT_MAPPING >> priv->num_grps);
+		}
 
 		if (priv->poll_mode == GFAR_SQ_POLLING) {
 			/* One Q per interrupt group: Q0 to G0, Q1 to G1 */
 			grp->rx_bit_map = (DEFAULT_MAPPING >> priv->num_grps);
 			grp->tx_bit_map = (DEFAULT_MAPPING >> priv->num_grps);
-		} else { /* GFAR_MQ_POLLING */
-			grp->rx_bit_map = rxq_mask ?
-			*rxq_mask : (DEFAULT_MAPPING >> priv->num_grps);
-			grp->tx_bit_map = txq_mask ?
-			*txq_mask : (DEFAULT_MAPPING >> priv->num_grps);
 		}
 	} else {
 		grp->rx_bit_map = 0xFF;
@@ -770,11 +779,10 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	struct gfar_private *priv = NULL;
 	struct device_node *np = ofdev->dev.of_node;
 	struct device_node *child = NULL;
-	const u32 *stash;
-	const u32 *stash_len;
-	const u32 *stash_idx;
+	struct property *stash;
+	u32 stash_len = 0;
+	u32 stash_idx = 0;
 	unsigned int num_tx_qs, num_rx_qs;
-	u32 *tx_queues, *rx_queues;
 	unsigned short mode, poll_mode;
 
 	if (!np)
@@ -788,10 +796,6 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 		poll_mode = GFAR_SQ_POLLING;
 	}
 
-	/* parse the num of HW tx and rx queues */
-	tx_queues = (u32 *)of_get_property(np, "fsl,num_tx_queues", NULL);
-	rx_queues = (u32 *)of_get_property(np, "fsl,num_rx_queues", NULL);
-
 	if (mode == SQ_SG_MODE) {
 		num_tx_qs = 1;
 		num_rx_qs = 1;
@@ -810,8 +814,17 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 			num_tx_qs = num_grps; /* one txq per int group */
 			num_rx_qs = num_grps; /* one rxq per int group */
 		} else { /* GFAR_MQ_POLLING */
-			num_tx_qs = tx_queues ? *tx_queues : 1;
-			num_rx_qs = rx_queues ? *rx_queues : 1;
+			u32 tx_queues, rx_queues;
+			int ret;
+
+			/* parse the num of HW tx and rx queues */
+			ret = of_property_read_u32(np, "fsl,num_tx_queues",
+						   &tx_queues);
+			num_tx_qs = ret ? 1 : tx_queues;
+
+			ret = of_property_read_u32(np, "fsl,num_rx_queues",
+						   &rx_queues);
+			num_rx_qs = ret ? 1 : rx_queues;
 		}
 	}
 
@@ -852,13 +865,17 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	if (err)
 		goto rx_alloc_failed;
 
+	err = of_property_read_string(np, "model", &model);
+	if (err) {
+		pr_err("Device model property missing, aborting\n");
+		goto rx_alloc_failed;
+	}
+
 	/* Init Rx queue filer rule set linked list */
 	INIT_LIST_HEAD(&priv->rx_list.list);
 	priv->rx_list.count = 0;
 	mutex_init(&priv->rx_queue_access);
 
-	model = of_get_property(np, "model", NULL);
-
 	for (i = 0; i < MAXGROUPS; i++)
 		priv->gfargrp[i].regs = NULL;
 
@@ -878,22 +895,22 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 			goto err_grp_init;
 	}
 
-	stash = of_get_property(np, "bd-stash", NULL);
+	stash = of_find_property(np, "bd-stash", NULL);
 
 	if (stash) {
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_BD_STASHING;
 		priv->bd_stash_en = 1;
 	}
 
-	stash_len = of_get_property(np, "rx-stash-len", NULL);
+	err = of_property_read_u32(np, "rx-stash-len", &stash_len);
 
-	if (stash_len)
-		priv->rx_stash_size = *stash_len;
+	if (err == 0)
+		priv->rx_stash_size = stash_len;
 
-	stash_idx = of_get_property(np, "rx-stash-idx", NULL);
+	err = of_property_read_u32(np, "rx-stash-idx", &stash_idx);
 
-	if (stash_idx)
-		priv->rx_stash_index = *stash_idx;
+	if (err == 0)
+		priv->rx_stash_index = stash_idx;
 
 	if (stash_len || stash_idx)
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_BUF_STASHING;
@@ -920,15 +937,15 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 				     FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
 				     FSL_GIANFAR_DEV_HAS_TIMER;
 
-	ctype = of_get_property(np, "phy-connection-type", NULL);
+	err = of_property_read_string(np, "phy-connection-type", &ctype);
 
 	/* We only care about rgmii-id.  The rest are autodetected */
-	if (ctype && !strcmp(ctype, "rgmii-id"))
+	if (err == 0 && !strcmp(ctype, "rgmii-id"))
 		priv->interface = PHY_INTERFACE_MODE_RGMII_ID;
 	else
 		priv->interface = PHY_INTERFACE_MODE_MII;
 
-	if (of_get_property(np, "fsl,magic-packet", NULL))
+	if (of_find_property(np, "fsl,magic-packet", NULL))
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
 
 	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
-- 
1.7.11.7
