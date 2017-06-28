From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 11/14] amd-xgbe: Add NUMA affinity support for
 IRQ hints
Date: Wed, 28 Jun 2017 13:43:00 -0500
Message-ID: <20170628184300.21972.50184.stgit@tlendack-t1.amdoffice.net>
References: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0083.outbound.protection.outlook.com ([104.47.34.83]:60576
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751501AbdF1SnP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 14:43:15 -0400
In-Reply-To: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For IRQ affinity, set the affinity hints for the IRQs to be (initially) on
the processors corresponding to the NUMA node of the device.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   18 +++++++++++++++---
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    2 ++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 43b84ff..ecef3ee 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -192,12 +192,17 @@ static int xgbe_alloc_channels(struct xgbe_prv_data *pdata)
 	struct xgbe_channel *channel;
 	struct xgbe_ring *ring;
 	unsigned int count, i;
+	unsigned int cpu;
 	int node;
 
-	node = dev_to_node(pdata->dev);
-
 	count = max_t(unsigned int, pdata->tx_ring_count, pdata->rx_ring_count);
 	for (i = 0; i < count; i++) {
+		/* Attempt to use a CPU on the node the device is on */
+		cpu = cpumask_local_spread(i, dev_to_node(pdata->dev));
+
+		/* Set the allocation node based on the returned CPU */
+		node = cpu_to_node(cpu);
+
 		channel = xgbe_alloc_node(sizeof(*channel), node);
 		if (!channel)
 			goto err_mem;
@@ -209,6 +214,7 @@ static int xgbe_alloc_channels(struct xgbe_prv_data *pdata)
 		channel->dma_regs = pdata->xgmac_regs + DMA_CH_BASE +
 				    (DMA_CH_INC * i);
 		channel->node = node;
+		cpumask_set_cpu(cpu, &channel->affinity_mask);
 
 		if (pdata->per_channel_irq)
 			channel->dma_irq = pdata->channel_irq[i];
@@ -236,7 +242,7 @@ static int xgbe_alloc_channels(struct xgbe_prv_data *pdata)
 		}
 
 		netif_dbg(pdata, drv, pdata->netdev,
-			  "%s: node=%d\n", channel->name, node);
+			  "%s: cpu=%u, node=%d\n", channel->name, cpu, node);
 
 		netif_dbg(pdata, drv, pdata->netdev,
 			  "%s: dma_regs=%p, dma_irq=%d, tx=%p, rx=%p\n",
@@ -916,6 +922,9 @@ static int xgbe_request_irqs(struct xgbe_prv_data *pdata)
 				     channel->dma_irq);
 			goto err_dma_irq;
 		}
+
+		irq_set_affinity_hint(channel->dma_irq,
+				      &channel->affinity_mask);
 	}
 
 	return 0;
@@ -925,6 +934,7 @@ static int xgbe_request_irqs(struct xgbe_prv_data *pdata)
 	for (i--; i < pdata->channel_count; i--) {
 		channel = pdata->channel[i];
 
+		irq_set_affinity_hint(channel->dma_irq, NULL);
 		devm_free_irq(pdata->dev, channel->dma_irq, channel);
 	}
 
@@ -952,6 +962,8 @@ static void xgbe_free_irqs(struct xgbe_prv_data *pdata)
 
 	for (i = 0; i < pdata->channel_count; i++) {
 		channel = pdata->channel[i];
+
+		irq_set_affinity_hint(channel->dma_irq, NULL);
 		devm_free_irq(pdata->dev, channel->dma_irq, channel);
 	}
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index ac3b558..7b50469 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -128,6 +128,7 @@
 #include <linux/net_tstamp.h>
 #include <net/dcbnl.h>
 #include <linux/completion.h>
+#include <linux/cpumask.h>
 
 #define XGBE_DRV_NAME		"amd-xgbe"
 #define XGBE_DRV_VERSION	"1.0.3"
@@ -465,6 +466,7 @@ struct xgbe_channel {
 	struct xgbe_ring *rx_ring;
 
 	int node;
+	cpumask_t affinity_mask;
 } ____cacheline_aligned;
 
 enum xgbe_state {
