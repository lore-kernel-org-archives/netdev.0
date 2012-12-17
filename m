From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 3/3 v2] net/macb: Try to optimize struct macb layout
Date: Mon, 17 Dec 2012 14:01:59 +0100
Message-ID: <cd54582850d50ec7ae391aae423b8982875a123a.1355748676.git.nicolas.ferre@atmel.com>
References: <cover.1355748676.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Havard Skinnemoen <havard@skinnemoen.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1355748676.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Havard Skinnemoen <havard@skinnemoen.net>

Move TX-related fields to the top of the struct so that they end up on
the same cache line. Move the NAPI struct below that since it is used
from the interrupt handler. RX-related fields go below those.

Move the spinlock before regs since they are usually used together.

Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
[nicolas.ferre@atmel.com: adapt to newer kernel]
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.h | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index cef146f..aeeb729 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -548,38 +548,39 @@ struct macb_or_gem_ops {
 };
 
 struct macb {
+	spinlock_t		lock;
 	void __iomem		*regs;
 
+	unsigned int		tx_head;
+	unsigned int		tx_tail;
+	struct macb_dma_desc	*tx_ring;
+	struct macb_tx_skb	*tx_skb;
+	dma_addr_t		tx_ring_dma;
+	struct work_struct	tx_error_task;
+
+	struct napi_struct	napi;
+
 	unsigned int		rx_tail;
 	unsigned int		rx_prepared_head;
 	struct macb_dma_desc	*rx_ring;
 	struct sk_buff		**rx_skbuff;
 	void			*rx_buffers;
 	size_t			rx_buffer_size;
+	dma_addr_t		rx_ring_dma;
+	dma_addr_t		rx_buffers_dma;
 
-	unsigned int		tx_head, tx_tail;
-	struct macb_dma_desc	*tx_ring;
-	struct macb_tx_skb	*tx_skb;
+	struct macb_or_gem_ops	macbgem_ops;
 
-	spinlock_t		lock;
 	struct platform_device	*pdev;
 	struct clk		*pclk;
 	struct clk		*hclk;
 	struct net_device	*dev;
-	struct napi_struct	napi;
-	struct work_struct	tx_error_task;
 	struct net_device_stats	stats;
 	union {
 		struct macb_stats	macb;
 		struct gem_stats	gem;
 	}			hw_stats;
 
-	dma_addr_t		rx_ring_dma;
-	dma_addr_t		tx_ring_dma;
-	dma_addr_t		rx_buffers_dma;
-
-	struct macb_or_gem_ops	macbgem_ops;
-
 	struct mii_bus		*mii_bus;
 	struct phy_device	*phy_dev;
 	unsigned int 		link;
-- 
1.8.0
