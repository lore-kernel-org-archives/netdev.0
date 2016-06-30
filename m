From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 1/4] net: ethernet: ti: davinci_cpdma: split descs num between all channels
Date: Thu, 30 Jun 2016 22:04:35 +0300
Message-ID: <1467313478-22919-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, nsekhar@ti.com,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the tx channels are using the same pool of descriptors.
Thus one channel can block another if pool is emptied by one.
But, the shaper should decide which channel is allowed to send
packets. To avoid such impact of one channel on another let every
channel to have its own peace of pool.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c          | 59 +++++++++++++++++++++------------
 drivers/net/ethernet/ti/davinci_cpdma.c | 54 ++++++++++++++++++++++++++++--
 drivers/net/ethernet/ti/davinci_cpdma.h |  2 +-
 3 files changed, 89 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1a93a1f..a713336 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1230,6 +1230,39 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	}
 }
 
+static int cpsw_fill_rx_channels(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct sk_buff *skb;
+	int ch_buf_num;
+	int i, ret;
+
+	ch_buf_num = cpdma_chan_get_rx_buf_num(priv->rxch);
+	for (i = 0; i < ch_buf_num; i++) {
+		skb = __netdev_alloc_skb_ip_align(ndev,
+						  priv->rx_packet_max,
+						  GFP_KERNEL);
+		if (!skb) {
+			dev_err(priv->dev, "cannot allocate skb\n");
+			return -ENOMEM;
+		}
+
+		ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
+					skb_tailroom(skb), 0);
+		if (ret < 0) {
+			dev_err(priv->dev,
+				"cannot submit skb to rx channel, error %d\n",
+				ret);
+			kfree_skb(skb);
+			return ret;
+		}
+	}
+
+	cpsw_info(priv, ifup, "submitted %d rx descriptors\n", ch_buf_num);
+
+	return ch_buf_num;
+}
+
 static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
 {
 	u32 slave_port;
@@ -1249,7 +1282,7 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
 static int cpsw_ndo_open(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	int i, ret;
+	int ret;
 	u32 reg;
 
 	ret = pm_runtime_get_sync(&priv->pdev->dev);
@@ -1282,7 +1315,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 
 	if (!cpsw_common_res_usage_state(priv)) {
 		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
-		int buf_num;
 
 		/* setup tx dma to fixed prio and zero offset */
 		cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
@@ -1310,26 +1342,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 			enable_irq(priv->irqs_table[0]);
 		}
 
-		buf_num = cpdma_chan_get_rx_buf_num(priv->dma);
-		for (i = 0; i < buf_num; i++) {
-			struct sk_buff *skb;
-
-			ret = -ENOMEM;
-			skb = __netdev_alloc_skb_ip_align(priv->ndev,
-					priv->rx_packet_max, GFP_KERNEL);
-			if (!skb)
-				goto err_cleanup;
-			ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
-					skb_tailroom(skb), 0);
-			if (ret < 0) {
-				kfree_skb(skb);
-				goto err_cleanup;
-			}
-		}
-		/* continue even if we didn't manage to submit all
-		 * receive descs
-		 */
-		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
+		ret = cpsw_fill_rx_channels(ndev);
+		if (ret < 0)
+			goto err_cleanup;
 
 		if (cpts_register(&priv->pdev->dev, priv->cpts,
 				  priv->data.cpts_clock_mult,
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 1c653ca..2f4b571 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -106,6 +106,7 @@ struct cpdma_ctlr {
 	struct cpdma_desc_pool	*pool;
 	spinlock_t		lock;
 	struct cpdma_chan	*channels[2 * CPDMA_MAX_CHANNELS];
+	int chan_num;
 };
 
 struct cpdma_chan {
@@ -262,6 +263,7 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 	ctlr->state = CPDMA_STATE_IDLE;
 	ctlr->params = *params;
 	ctlr->dev = params->dev;
+	ctlr->chan_num = 0;
 	spin_lock_init(&ctlr->lock);
 
 	ctlr->pool = cpdma_desc_pool_create(ctlr->dev,
@@ -479,6 +481,32 @@ void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value)
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_eoi);
 
+/**
+ * cpdma_chan_split_pool - Splits ctrl pool between all channels.
+ * Has to be called under ctlr lock
+ *
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
@@ -527,14 +555,25 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
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
 
@@ -551,6 +590,10 @@ int cpdma_chan_destroy(struct cpdma_chan *chan)
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
@@ -720,7 +763,7 @@ unlock_ret:
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_submit);
 
-bool cpdma_check_free_tx_desc(struct cpdma_chan *chan)
+inline bool cpdma_check_free_desc(struct cpdma_chan *chan)
 {
 	struct cpdma_ctlr	*ctlr = chan->ctlr;
 	struct cpdma_desc_pool	*pool = ctlr->pool;
@@ -733,6 +776,11 @@ bool cpdma_check_free_tx_desc(struct cpdma_chan *chan)
 	spin_unlock_irqrestore(&chan->lock, flags);
 	return free_tx_desc;
 }
+
+bool cpdma_check_free_tx_desc(struct cpdma_chan *chan)
+{
+	return cpdma_check_free_desc(chan);
+}
 EXPORT_SYMBOL_GPL(cpdma_check_free_tx_desc);
 
 static void __cpdma_chan_free(struct cpdma_chan *chan,
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 80c015c..0308b67 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -81,7 +81,7 @@ int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler);
-int cpdma_chan_get_rx_buf_num(struct cpdma_ctlr *ctlr);
+int cpdma_chan_get_rx_buf_num(struct cpdma_chan *chan);
 int cpdma_chan_destroy(struct cpdma_chan *chan);
 int cpdma_chan_start(struct cpdma_chan *chan);
 int cpdma_chan_stop(struct cpdma_chan *chan);
-- 
1.9.1
