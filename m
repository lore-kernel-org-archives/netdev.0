From: Bhadram Varka <vbhadram@nvidia.com>
Subject: [PATCH] stmmac: use of_property_read_u32 instead of read_u8
Date: Thu, 2 Nov 2017 12:52:13 +0530
Message-ID: <1509607333-8864-1-git-send-email-vbhadram@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <peppe.cavallaro@st.com>, <clabbe.montjoie@gmail.com>,
        <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate14.nvidia.com ([216.228.121.143]:12490 "EHLO
        hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755104AbdKBHYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:24:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Numbers in DT are stored in “cells” which are 32-bits
in size. of_property_read_u8 does not work properly
because of endianness problem.

This causes it to always return 0 with little-endian
architectures.

Fix it by using of_property_read_u32() OF API.

Signed-off-by: Bhadram Varka <vbhadram@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 16 ++++++++--------
 include/linux/stmmac.h                                |  8 ++++----
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 9e616da..d5efe5b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -161,8 +161,8 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 	}
 
 	/* Processing RX queues common config */
-	if (of_property_read_u8(rx_node, "snps,rx-queues-to-use",
-				&plat->rx_queues_to_use))
+	if (of_property_read_u32(rx_node, "snps,rx-queues-to-use",
+				 &plat->rx_queues_to_use))
 		plat->rx_queues_to_use = 1;
 
 	if (of_property_read_bool(rx_node, "snps,rx-sched-sp"))
@@ -184,8 +184,8 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 		else
 			plat->rx_queues_cfg[queue].mode_to_use = MTL_QUEUE_DCB;
 
-		if (of_property_read_u8(q_node, "snps,map-to-dma-channel",
-					&plat->rx_queues_cfg[queue].chan))
+		if (of_property_read_u32(q_node, "snps,map-to-dma-channel",
+					 &plat->rx_queues_cfg[queue].chan))
 			plat->rx_queues_cfg[queue].chan = queue;
 		/* TODO: Dynamic mapping to be included in the future */
 
@@ -215,8 +215,8 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 	}
 
 	/* Processing TX queues common config */
-	if (of_property_read_u8(tx_node, "snps,tx-queues-to-use",
-				&plat->tx_queues_to_use))
+	if (of_property_read_u32(tx_node, "snps,tx-queues-to-use",
+				 &plat->tx_queues_to_use))
 		plat->tx_queues_to_use = 1;
 
 	if (of_property_read_bool(tx_node, "snps,tx-sched-wrr"))
@@ -237,8 +237,8 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 		if (queue >= plat->tx_queues_to_use)
 			break;
 
-		if (of_property_read_u8(q_node, "snps,weight",
-					&plat->tx_queues_cfg[queue].weight))
+		if (of_property_read_u32(q_node, "snps,weight",
+					 &plat->tx_queues_cfg[queue].weight))
 			plat->tx_queues_cfg[queue].weight = 0x10 + queue;
 
 		if (of_property_read_bool(q_node, "snps,dcb-algorithm")) {
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 108739f..32feac5 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -126,14 +126,14 @@ struct stmmac_axi {
 
 struct stmmac_rxq_cfg {
 	u8 mode_to_use;
-	u8 chan;
+	u32 chan;
 	u8 pkt_route;
 	bool use_prio;
 	u32 prio;
 };
 
 struct stmmac_txq_cfg {
-	u8 weight;
+	u32 weight;
 	u8 mode_to_use;
 	/* Credit Base Shaper parameters */
 	u32 send_slope;
@@ -168,8 +168,8 @@ struct plat_stmmacenet_data {
 	int unicast_filter_entries;
 	int tx_fifo_size;
 	int rx_fifo_size;
-	u8 rx_queues_to_use;
-	u8 tx_queues_to_use;
+	u32 rx_queues_to_use;
+	u32 tx_queues_to_use;
 	u8 rx_sched_algorithm;
 	u8 tx_sched_algorithm;
 	struct stmmac_rxq_cfg rx_queues_cfg[MTL_MAX_RX_QUEUES];
-- 
2.7.4
