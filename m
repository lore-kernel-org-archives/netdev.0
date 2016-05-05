From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 3/4] net-next: mediatek: add IRQ locking
Date: Thu,  5 May 2016 11:27:42 +0200
Message-ID: <1462440463-52076-4-git-send-email-john@phrozen.org>
References: <1462440463-52076-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-Vt+b4OUoWG0@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1462440463-52076-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The code that enables and disables IRQs is missing proper locking. After
adding the IRQ separation patch and routing the putting the RX and TX IRQs
on different cores we experienced IRQ stalls. Fix this by adding proper
locking. We use a dedicated lock to reduce the latency if the IRQ code.
Otherwise it might wait for bottom code to finish before reenabling or
disabling IRQs.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    7 +++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    1 +
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 4322585..3d84309 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -316,18 +316,24 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
 
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
@@ -1755,6 +1761,7 @@ static int mtk_probe(struct platform_device *pdev)
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
