From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v5 1/1] net: ethernet: davinci_cpdma: Add boundary for rx and tx descriptors
Date: Thu, 17 Jan 2013 22:01:34 +0530
Message-ID: <1358440294-13676-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <s.hauer@pengutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:59093 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757163Ab3AQQdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 11:33:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Changes from v4
* Removed duplicate calls of bitmap_find_next_zero_area()
* Used is_rx_chan() to find whether the channel is rx channel

 drivers/net/ethernet/ti/cpsw.c          |    9 ++++++
 drivers/net/ethernet/ti/davinci_cpdma.c |   47 ++++++++++++++++++++++++++-----
 drivers/net/ethernet/ti/davinci_cpdma.h |    1 +
 drivers/net/ethernet/ti/davinci_emac.c  |   13 +++++----
 4 files changed, 57 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3772804..b35e6a7 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -374,6 +374,9 @@ void cpsw_tx_handler(void *token, int len, int status)
 	struct net_device	*ndev = skb->dev;
 	struct cpsw_priv	*priv = netdev_priv(ndev);
 
+	/* Check whether the queue is stopped due to stalled tx dma, if the
+	 * queue is stopped then start the queue as we have free desc for tx
+	 */
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_start_queue(ndev);
 	cpts_tx_timestamp(&priv->cpts, skb);
@@ -736,6 +739,12 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 		goto fail;
 	}
 
+	/* If there is no more tx desc left free then we need to
+	 * tell the kernel to stop sending us tx frames.
+	 */
+	if (unlikely(cpdma_check_free_tx_desc(priv->txch)))
+		netif_stop_queue(ndev);
+
 	return NETDEV_TX_OK;
 fail:
 	priv->stats.tx_dropped++;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 4995673..f862918 100644
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
@@ -217,17 +217,27 @@ desc_from_phys(struct cpdma_desc_pool *pool, dma_addr_t dma)
 }
 
 static struct cpdma_desc __iomem *
-cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc)
+cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc, bool is_rx)
 {
 	unsigned long flags;
 	int index;
+	int desc_start;
+	int desc_end;
 	struct cpdma_desc __iomem *desc = NULL;
 
 	spin_lock_irqsave(&pool->lock, flags);
 
-	index = bitmap_find_next_zero_area(pool->bitmap, pool->num_desc, 0,
-					   num_desc, 0);
-	if (index < pool->num_desc) {
+	if (is_rx) {
+		desc_start = 0;
+		desc_end = pool->num_desc/2;
+	 } else {
+		desc_start = pool->num_desc/2;
+		desc_end = pool->num_desc;
+	}
+
+	index = bitmap_find_next_zero_area(pool->bitmap,
+				desc_end, desc_start, num_desc, 0);
+	if (index < desc_end) {
 		bitmap_set(pool->bitmap, index, num_desc);
 		desc = pool->iomap + pool->desc_size * index;
 		pool->used_desc++;
@@ -668,7 +678,7 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 		goto unlock_ret;
 	}
 
-	desc = cpdma_desc_alloc(ctlr->pool, 1);
+	desc = cpdma_desc_alloc(ctlr->pool, 1, is_rx_chan(chan));
 	if (!desc) {
 		chan->stats.desc_alloc_fail++;
 		ret = -ENOMEM;
@@ -704,6 +714,29 @@ unlock_ret:
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_submit);
 
+bool cpdma_check_free_tx_desc(struct cpdma_chan *chan)
+{
+	unsigned long flags;
+	int index;
+	bool ret;
+	struct cpdma_ctlr	*ctlr = chan->ctlr;
+	struct cpdma_desc_pool	*pool = ctlr->pool;
+
+	spin_lock_irqsave(&pool->lock, flags);
+
+	index = bitmap_find_next_zero_area(pool->bitmap,
+				pool->num_desc, pool->num_desc/2, 1, 0);
+
+	if (index < pool->num_desc)
+		ret = true;
+	else
+		ret = false;
+
+	spin_unlock_irqrestore(&pool->lock, flags);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(cpdma_check_free_tx_desc);
+
 static void __cpdma_chan_free(struct cpdma_chan *chan,
 			      struct cpdma_desc __iomem *desc,
 			      int outlen, int status)
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index afa19a0..8d2aeb2 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -88,6 +88,7 @@ int cpdma_chan_process(struct cpdma_chan *chan, int quota);
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
 void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr);
 int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable);
+bool cpdma_check_free_tx_desc(struct cpdma_chan *chan);
 
 enum cpdma_control {
 	CPDMA_CMD_IDLE,			/* write-only */
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 8478d98..1c97c81 100644
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
@@ -1050,10 +1048,10 @@ static void emac_tx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
-	struct emac_priv	*priv = netdev_priv(ndev);
-
-	atomic_dec(&priv->cur_tx);
 
+	/* Check whether the queue is stopped due to stalled tx dma, if the
+	 * queue is stopped then start the queue as we have free desc for tx
+	 */
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_start_queue(ndev);
 	ndev->stats.tx_packets++;
@@ -1101,7 +1099,10 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 		goto fail_tx;
 	}
 
-	if (atomic_inc_return(&priv->cur_tx) >= EMAC_DEF_TX_NUM_DESC)
+	/* If there is no more tx desc left free then we need to
+	 * tell the kernel to stop sending us tx frames.
+	 */
+	if (unlikely(cpdma_check_free_tx_desc(priv->txch)))
 		netif_stop_queue(ndev);
 
 	return NETDEV_TX_OK;
-- 
1.7.9.5
