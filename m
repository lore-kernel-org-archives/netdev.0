From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 03/12] net: bcmgenet: simplify circular pointer arithmetic
Date: Mon, 13 Mar 2017 17:41:33 -0700
Message-ID: <20170314004142.4746-4-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A 2's complement subtraction will always do a borrow, so masking
off the sign bits is the same as conditionally adding (mask+1).

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f92896835d2a..2c008b09c4e3 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1,7 +1,7 @@
 /*
  * Broadcom GENET (Gigabit Ethernet) controller driver
  *
- * Copyright (c) 2014 Broadcom Corporation
+ * Copyright (c) 2014-2017 Broadcom
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -1175,13 +1175,9 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	unsigned int txbds_processed = 0;
 
 	/* Compute how many buffers are transmitted since last xmit call */
-	c_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_CONS_INDEX);
-	c_index &= DMA_C_INDEX_MASK;
-
-	if (likely(c_index >= ring->c_index))
-		txbds_ready = c_index - ring->c_index;
-	else
-		txbds_ready = (DMA_C_INDEX_MASK + 1) - ring->c_index + c_index;
+	c_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_CONS_INDEX)
+		& DMA_C_INDEX_MASK;
+	txbds_ready = (c_index - ring->c_index) & DMA_C_INDEX_MASK;
 
 	netif_dbg(priv, tx_done, dev,
 		  "%s ring=%d old_c_index=%u c_index=%u txbds_ready=%u\n",
@@ -1611,12 +1607,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_rx_ring *ring,
 	}
 
 	p_index &= DMA_P_INDEX_MASK;
-
-	if (likely(p_index >= ring->c_index))
-		rxpkttoprocess = p_index - ring->c_index;
-	else
-		rxpkttoprocess = (DMA_C_INDEX_MASK + 1) - ring->c_index +
-				 p_index;
+	rxpkttoprocess = (p_index - ring->c_index) & DMA_C_INDEX_MASK;
 
 	netif_dbg(priv, rx_status, dev,
 		  "RDMA: rxpkttoprocess=%d\n", rxpkttoprocess);
-- 
2.11.1
