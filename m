From: John Crispin <john@phrozen.org>
Subject: [PATCH 3/4] net-next: mediatek: add IRQ locking
Date: Wed, 15 Jun 2016 16:58:49 +0200
Message-ID: <1466002730-58476-4-git-send-email-john@phrozen.org>
References: <1466002730-58476-1-git-send-email-john@phrozen.org>
Cc: Felix Fietkau <nbd@nbd.name>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466002730-58476-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code that enables and disables IRQs is missing proper locking. After
adding the IRQ grouping patch and routing the RX and TX IRQs to different
cores we experienced IRQ stalls. Fix this by adding proper locking.
We use a dedicated lock to reduce the latency if the IRQ code.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    7 +++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    1 +
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index cc38eae..c7da00b 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -300,18 +300,24 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
 
 static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
 {
+	unsigned long flags;
 	u32 val;
 
+	spin_lock_irqsave(&eth->irq_lock, flags);
 	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
 	mtk_w32(eth, val & ~mask, MTK_QDMA_INT_MASK);
+	spin_unlock_irqrestore(&eth->irq_lock, flags);
 }
 
 static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
 {
+	unsigned long flags;
 	u32 val;
 
+	spin_lock_irqsave(&eth->irq_lock, flags);
 	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
 	mtk_w32(eth, val | mask, MTK_QDMA_INT_MASK);
+	spin_unlock_irqrestore(&eth->irq_lock, flags);
 }
 
 static int mtk_set_mac_address(struct net_device *dev, void *p)
@@ -1739,6 +1745,7 @@ static int mtk_probe(struct platform_device *pdev)
 		return PTR_ERR(eth->base);
 
 	spin_lock_init(&eth->page_lock);
+	spin_lock_init(&eth->irq_lock);
 
 	eth->ethsys = syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
 						      "mediatek,ethsys");
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index a5eb7c6..3159d2a 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -373,6 +373,7 @@ struct mtk_eth {
 	void __iomem			*base;
 	struct reset_control		*rstc;
 	spinlock_t			page_lock;
+	spinlock_t			irq_lock;
 	struct net_device		dummy_dev;
 	struct net_device		*netdev[MTK_MAX_DEVS];
 	struct mtk_mac			*mac[MTK_MAX_DEVS];
-- 
1.7.10.4
