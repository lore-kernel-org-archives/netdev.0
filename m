From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 1/1] net: ethernet: davinci_cpdma: Add boundary for rx and tx descriptors
Date: Tue, 11 Dec 2012 09:13:53 +0530
Message-ID: <1355197433-7492-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <s.hauer@pengutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When there is heavy transmission traffic in the CPDMA, then Rx descriptors
memory is also utilized as tx desc memory looses all rx descriptors and the
driver stops working then.

This patch adds boundary for tx and rx descriptors in bd ram dividing the
descriptor memory to ensure that during heavy transmission tx doesn't use
rx descriptors.

This patch is already applied to davinci_emac driver, since CPSW and
davici_dmac shares the same CPDMA, moving the boundry seperation from
Davinci EMAC driver to CPDMA driver which was done in the following
commit

commit 86d8c07ff2448eb4e860e50f34ef6ee78e45c40c
Author: Sascha Hauer <s.hauer@pengutronix.de>
Date:   Tue Jan 3 05:27:47 2012 +0000

    net/davinci: do not use all descriptors for tx packets

    The driver uses a shared pool for both rx and tx descriptors.
    During open it queues fixed number of 128 descriptors for receive
    packets. For each received packet it tries to queue another
    descriptor. If this fails the descriptor is lost for rx.
    The driver has no limitation on tx descriptors to use, so it
    can happen during a nmap / ping -f attack that the driver
    allocates all descriptors for tx and looses all rx descriptors.
    The driver stops working then.
    To fix this limit the number of tx descriptors used to half of
    the descriptors available, the rx path uses the other half.

    Tested on a custom board using nmap / ping -f to the board from
    two different hosts.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
Changes from initial patch:
* Modified commit message with proper description as in previous commit message

 drivers/net/ethernet/ti/davinci_cpdma.c |   20 ++++++++++++++------
 drivers/net/ethernet/ti/davinci_emac.c  |    8 --------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 4995673..d37f546 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -105,13 +105,13 @@ struct cpdma_ctlr {
 };
 
 struct cpdma_chan {
+	struct cpdma_desc __iomem	*head, *tail;
+	void __iomem			*hdp, *cp, *rxfree;
 	enum cpdma_state		state;
 	struct cpdma_ctlr		*ctlr;
 	int				chan_num;
 	spinlock_t			lock;
-	struct cpdma_desc __iomem	*head, *tail;
 	int				count;
-	void __iomem			*hdp, *cp, *rxfree;
 	u32				mask;
 	cpdma_handler_fn		handler;
 	enum dma_data_direction		dir;
@@ -217,7 +217,7 @@ desc_from_phys(struct cpdma_desc_pool *pool, dma_addr_t dma)
 }
 
 static struct cpdma_desc __iomem *
-cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc)
+cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc, bool is_rx)
 {
 	unsigned long flags;
 	int index;
@@ -225,8 +225,14 @@ cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc)
 
 	spin_lock_irqsave(&pool->lock, flags);
 
-	index = bitmap_find_next_zero_area(pool->bitmap, pool->num_desc, 0,
-					   num_desc, 0);
+	if (is_rx) {
+		index = bitmap_find_next_zero_area(pool->bitmap,
+				pool->num_desc/2, 0, num_desc, 0);
+	 } else {
+		index = bitmap_find_next_zero_area(pool->bitmap,
+				pool->num_desc, pool->num_desc/2, num_desc, 0);
+	}
+
 	if (index < pool->num_desc) {
 		bitmap_set(pool->bitmap, index, num_desc);
 		desc = pool->iomap + pool->desc_size * index;
@@ -660,6 +666,7 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 	unsigned long			flags;
 	u32				mode;
 	int				ret = 0;
+	bool                            is_rx;
 
 	spin_lock_irqsave(&chan->lock, flags);
 
@@ -668,7 +675,8 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 		goto unlock_ret;
 	}
 
-	desc = cpdma_desc_alloc(ctlr->pool, 1);
+	is_rx = (chan->rxfree != 0);
+	desc = cpdma_desc_alloc(ctlr->pool, 1, is_rx);
 	if (!desc) {
 		chan->stats.desc_alloc_fail++;
 		ret = -ENOMEM;
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index fce89a0..f349273 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -120,7 +120,6 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 #define EMAC_DEF_TX_CH			(0) /* Default 0th channel */
 #define EMAC_DEF_RX_CH			(0) /* Default 0th channel */
 #define EMAC_DEF_RX_NUM_DESC		(128)
-#define EMAC_DEF_TX_NUM_DESC		(128)
 #define EMAC_DEF_MAX_TX_CH		(1) /* Max TX channels configured */
 #define EMAC_DEF_MAX_RX_CH		(1) /* Max RX channels configured */
 #define EMAC_POLL_WEIGHT		(64) /* Default NAPI poll weight */
@@ -342,7 +341,6 @@ struct emac_priv {
 	u32 mac_hash2;
 	u32 multicast_hash_cnt[EMAC_NUM_MULTICAST_BITS];
 	u32 rx_addr_type;
-	atomic_t cur_tx;
 	const char *phy_id;
 #ifdef CONFIG_OF
 	struct device_node *phy_node;
@@ -1050,9 +1048,6 @@ static void emac_tx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
-	struct emac_priv	*priv = netdev_priv(ndev);
-
-	atomic_dec(&priv->cur_tx);
 
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_start_queue(ndev);
@@ -1101,9 +1096,6 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 		goto fail_tx;
 	}
 
-	if (atomic_inc_return(&priv->cur_tx) >= EMAC_DEF_TX_NUM_DESC)
-		netif_stop_queue(ndev);
-
 	return NETDEV_TX_OK;
 
 fail_tx:
-- 
1.7.9.5

