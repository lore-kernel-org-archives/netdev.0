From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v4 1/5] net: ethernet: ti: davinci_cpdma: split descs num between all channels
Date: Mon, 22 Aug 2016 21:18:24 +0300
Message-ID: <1471889908-29983-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        nsekhar@ti.com, dlide@ti.com,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com,
        grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tx channels share same pool of descriptors. Thus one channel can
block another if pool is emptied by one. But, the shaper should
decide which channel is allowed to send packets. To avoid such
impact of one channel on another, let every channel to have its
own piece of pool.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c          | 62 ++++++++++++++++++++-------------
 drivers/net/ethernet/ti/davinci_cpdma.c | 46 ++++++++++++++++++++++--
 drivers/net/ethernet/ti/davinci_cpdma.h |  2 +-
 3 files changed, 83 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 421ebda..4065f96 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1213,6 +1213,40 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	}
 }
 
+static int cpsw_fill_rx_channels(struct cpsw_priv *priv)
+{
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct sk_buff *skb;
+	int ch_buf_num;
+	int i, ret;
+
+	ch_buf_num = cpdma_chan_get_rx_buf_num(cpsw->rxch);
+	for (i = 0; i < ch_buf_num; i++) {
+		skb = __netdev_alloc_skb_ip_align(priv->ndev,
+						  cpsw->rx_packet_max,
+						  GFP_KERNEL);
+		if (!skb) {
+			cpsw_err(priv, ifup, "cannot allocate skb\n");
+			return -ENOMEM;
+		}
+
+		ret = cpdma_chan_submit(cpsw->rxch, skb, skb->data,
+					skb_tailroom(skb), 0);
+		if (ret < 0) {
+			cpsw_err(priv, ifup,
+				 "cannot submit skb to rx channel, error %d\n",
+				 ret);
+			kfree_skb(skb);
+			return ret;
+		}
+		kmemleak_not_leak(skb);
+	}
+
+	cpsw_info(priv, ifup, "submitted %d rx descriptors\n", ch_buf_num);
+
+	return ch_buf_num;
+}
+
 static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_common *cpsw)
 {
 	u32 slave_port;
@@ -1233,7 +1267,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpsw_common *cpsw = priv->cpsw;
-	int i, ret;
+	int ret;
 	u32 reg;
 
 	ret = pm_runtime_get_sync(cpsw->dev);
@@ -1265,8 +1299,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
 	if (!cpsw_common_res_usage_state(cpsw)) {
-		int buf_num;
-
 		/* setup tx dma to fixed prio and zero offset */
 		cpdma_control_set(cpsw->dma, CPDMA_TX_PRIO_FIXED, 1);
 		cpdma_control_set(cpsw->dma, CPDMA_RX_BUFFER_OFFSET, 0);
@@ -1293,27 +1325,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 			enable_irq(cpsw->irqs_table[0]);
 		}
 
-		buf_num = cpdma_chan_get_rx_buf_num(cpsw->dma);
-		for (i = 0; i < buf_num; i++) {
-			struct sk_buff *skb;
-
-			ret = -ENOMEM;
-			skb = __netdev_alloc_skb_ip_align(priv->ndev,
-					cpsw->rx_packet_max, GFP_KERNEL);
-			if (!skb)
-				goto err_cleanup;
-			ret = cpdma_chan_submit(cpsw->rxch, skb, skb->data,
-						skb_tailroom(skb), 0);
-			if (ret < 0) {
-				kfree_skb(skb);
-				goto err_cleanup;
-			}
-			kmemleak_not_leak(skb);
-		}
-		/* continue even if we didn't manage to submit all
-		 * receive descs
-		 */
-		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
+		ret = cpsw_fill_rx_channels(priv);
+		if (ret < 0)
+			goto err_cleanup;
 
 		if (cpts_register(cpsw->dev, cpsw->cpts,
 				  cpsw->data.cpts_clock_mult,
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index cf72b33..167fd65 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -104,6 +104,7 @@ struct cpdma_ctlr {
 	struct cpdma_desc_pool	*pool;
 	spinlock_t		lock;
 	struct cpdma_chan	*channels[2 * CPDMA_MAX_CHANNELS];
+	int chan_num;
 };
 
 struct cpdma_chan {
@@ -256,6 +257,7 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 	ctlr->state = CPDMA_STATE_IDLE;
 	ctlr->params = *params;
 	ctlr->dev = params->dev;
+	ctlr->chan_num = 0;
 	spin_lock_init(&ctlr->lock);
 
 	ctlr->pool = cpdma_desc_pool_create(ctlr->dev,
@@ -399,6 +401,31 @@ void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value)
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_eoi);
 
+/**
+ * cpdma_chan_split_pool - Splits ctrl pool between all channels.
+ * Has to be called under ctlr lock
+ */
+static void cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
+{
+	struct cpdma_desc_pool *pool = ctlr->pool;
+	struct cpdma_chan *chan;
+	int ch_desc_num;
+	int i;
+
+	if (!ctlr->chan_num)
+		return;
+
+	/* calculate average size of pool slice */
+	ch_desc_num = pool->num_desc / ctlr->chan_num;
+
+	/* split ctlr pool */
+	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
+		chan = ctlr->channels[i];
+		if (chan)
+			chan->desc_num = ch_desc_num;
+	}
+}
+
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler)
 {
@@ -447,14 +474,25 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 	spin_lock_init(&chan->lock);
 
 	ctlr->channels[chan_num] = chan;
+	ctlr->chan_num++;
+
+	cpdma_chan_split_pool(ctlr);
+
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return chan;
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_create);
 
-int cpdma_chan_get_rx_buf_num(struct cpdma_ctlr *ctlr)
+int cpdma_chan_get_rx_buf_num(struct cpdma_chan *chan)
 {
-	return ctlr->pool->num_desc / 2;
+	unsigned long flags;
+	int desc_num;
+
+	spin_lock_irqsave(&chan->lock, flags);
+	desc_num = chan->desc_num;
+	spin_unlock_irqrestore(&chan->lock, flags);
+
+	return desc_num;
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_get_rx_buf_num);
 
@@ -471,6 +509,10 @@ int cpdma_chan_destroy(struct cpdma_chan *chan)
 	if (chan->state != CPDMA_STATE_IDLE)
 		cpdma_chan_stop(chan);
 	ctlr->channels[chan->chan_num] = NULL;
+	ctlr->chan_num--;
+
+	cpdma_chan_split_pool(ctlr);
+
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return 0;
 }
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 4b46cd6..9119b43 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -80,7 +80,7 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler);
-int cpdma_chan_get_rx_buf_num(struct cpdma_ctlr *ctlr);
+int cpdma_chan_get_rx_buf_num(struct cpdma_chan *chan);
 int cpdma_chan_destroy(struct cpdma_chan *chan);
 int cpdma_chan_start(struct cpdma_chan *chan);
 int cpdma_chan_stop(struct cpdma_chan *chan);
-- 
1.9.1
