From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 02/15] drivers, net, ethernet: convert mtk_eth.dma_refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:36 +0300
Message-ID: <1508484229-19706-3-git-send-email-elena.reshetova@intel.com>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, john@phrozen.org,
        sean.wang@mediatek.com, matthias.bgg@gmail.com,
        yishaih@mellanox.com, saeedm@mellanox.com, matanb@mellanox.com,
        tariqt@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, zbr@ioremap.net,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable mtk_eth.dma_refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 8 +++++---
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 4 +++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 5e81a72..54adfd9 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1817,7 +1817,7 @@ static int mtk_open(struct net_device *dev)
 	struct mtk_eth *eth = mac->hw;
 
 	/* we run 2 netdevs on the same dma ring so we only bring it up once */
-	if (!atomic_read(&eth->dma_refcnt)) {
+	if (!refcount_read(&eth->dma_refcnt)) {
 		int err = mtk_start_dma(eth);
 
 		if (err)
@@ -1827,8 +1827,10 @@ static int mtk_open(struct net_device *dev)
 		napi_enable(&eth->rx_napi);
 		mtk_tx_irq_enable(eth, MTK_TX_DONE_INT);
 		mtk_rx_irq_enable(eth, MTK_RX_DONE_INT);
+		refcount_set(&eth->dma_refcnt, 1);
 	}
-	atomic_inc(&eth->dma_refcnt);
+	else
+		refcount_inc(&eth->dma_refcnt);
 
 	phy_start(dev->phydev);
 	netif_start_queue(dev);
@@ -1868,7 +1870,7 @@ static int mtk_stop(struct net_device *dev)
 	phy_stop(dev->phydev);
 
 	/* only shutdown DMA if this is the last user */
-	if (!atomic_dec_and_test(&eth->dma_refcnt))
+	if (!refcount_dec_and_test(&eth->dma_refcnt))
 		return 0;
 
 	mtk_tx_irq_disable(eth, MTK_TX_DONE_INT);
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 3d3c24a..a3af466 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -15,6 +15,8 @@
 #ifndef MTK_ETH_H
 #define MTK_ETH_H
 
+#include <linux/refcount.h>
+
 #define MTK_QDMA_PAGE_SIZE	2048
 #define	MTK_MAX_RX_LENGTH	1536
 #define MTK_TX_DMA_BUF_LEN	0x3fff
@@ -632,7 +634,7 @@ struct mtk_eth {
 	struct regmap			*pctl;
 	u32				chip_id;
 	bool				hwlro;
-	atomic_t			dma_refcnt;
+	refcount_t			dma_refcnt;
 	struct mtk_tx_ring		tx_ring;
 	struct mtk_rx_ring		rx_ring[MTK_MAX_RX_RING_NUM];
 	struct mtk_rx_ring		rx_ring_qdma;
-- 
2.7.4
