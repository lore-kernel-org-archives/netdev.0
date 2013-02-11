From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/3] driver: net: ethernet: davinci_cpdma: add support for directed packet and source port detection
Date: Tue, 12 Feb 2013 01:22:18 +0530
Message-ID: <1360612340-9266-2-git-send-email-mugunthanvnm@ti.com>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Introduced parameter to add port number for directed packet in cpdma_chan_submit
* Source port detection macro with DMA descriptor status

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c          |    6 +++---
 drivers/net/ethernet/ti/davinci_cpdma.c |   17 +++++++++++++++--
 drivers/net/ethernet/ti/davinci_cpdma.h |    4 +++-
 drivers/net/ethernet/ti/davinci_emac.c  |    6 +++---
 4 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 888708c..8ac60c7 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -424,7 +424,7 @@ void cpsw_rx_handler(void *token, int len, int status)
 			return;
 
 		ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
-					skb_tailroom(skb), GFP_KERNEL);
+					skb_tailroom(skb), 0, GFP_KERNEL);
 	}
 	WARN_ON(ret < 0);
 }
@@ -705,7 +705,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		if (!skb)
 			break;
 		ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
-					skb_tailroom(skb), GFP_KERNEL);
+					skb_tailroom(skb), 0, GFP_KERNEL);
 		if (WARN_ON(ret < 0))
 			break;
 	}
@@ -766,7 +766,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	skb_tx_timestamp(skb);
 
 	ret = cpdma_chan_submit(priv->txch, skb, skb->data,
-				skb->len, GFP_KERNEL);
+				skb->len, 0, GFP_KERNEL);
 	if (unlikely(ret != 0)) {
 		cpsw_err(priv, tx_err, "desc submit failed\n");
 		goto fail;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index afe14a6..ca25cc8 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -60,6 +60,9 @@
 #define CPDMA_DESC_EOQ		BIT(28)
 #define CPDMA_DESC_TD_COMPLETE	BIT(27)
 #define CPDMA_DESC_PASS_CRC	BIT(26)
+#define CPDMA_DESC_TO_PORT_EN	BIT(20)
+#define CPDMA_TO_PORT_SHIFT	16
+#define CPDMA_DESC_PORT_MASK	(BIT(18) | BIT(17) | BIT(16))
 
 #define CPDMA_TEARDOWN_VALUE	0xfffffffc
 
@@ -132,6 +135,14 @@ struct cpdma_chan {
 #define chan_write(chan, fld, v)	__raw_writel(v, (chan)->fld)
 #define desc_write(desc, fld, v)	__raw_writel((u32)(v), &(desc)->fld)
 
+#define cpdma_desc_to_port(chan, mode, directed)			\
+	do {								\
+		if (!is_rx_chan(chan) && ((directed == 1) ||		\
+					  (directed == 2)))		\
+			mode |= (CPDMA_DESC_TO_PORT_EN |		\
+				 (directed << CPDMA_TO_PORT_SHIFT));	\
+	} while (0)
+
 /*
  * Utility constructs for a cpdma descriptor pool.  Some devices (e.g. davinci
  * emac) have dedicated on-chip memory for these descriptors.  Some other
@@ -664,7 +675,7 @@ static void __cpdma_chan_submit(struct cpdma_chan *chan,
 }
 
 int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
-		      int len, gfp_t gfp_mask)
+		      int len, int directed, gfp_t gfp_mask)
 {
 	struct cpdma_ctlr		*ctlr = chan->ctlr;
 	struct cpdma_desc __iomem	*desc;
@@ -694,6 +705,7 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 
 	buffer = dma_map_single(ctlr->dev, data, len, chan->dir);
 	mode = CPDMA_DESC_OWNER | CPDMA_DESC_SOP | CPDMA_DESC_EOP;
+	cpdma_desc_to_port(chan, mode, directed);
 
 	desc_write(desc, hw_next,   0);
 	desc_write(desc, hw_buffer, buffer);
@@ -784,7 +796,8 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 		status = -EBUSY;
 		goto unlock_ret;
 	}
-	status	= status & (CPDMA_DESC_EOQ | CPDMA_DESC_TD_COMPLETE);
+	status	= status & (CPDMA_DESC_EOQ | CPDMA_DESC_TD_COMPLETE |
+			    CPDMA_DESC_PORT_MASK);
 
 	chan->head = desc_from_phys(pool, desc_read(desc, hw_next));
 	chan_write(chan, cp, desc_dma);
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 8d2aeb2..a97d6ab 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -24,6 +24,8 @@
 #define __chan_linear(chan_num)	((chan_num) & (CPDMA_MAX_CHANNELS - 1))
 #define chan_linear(chan)	__chan_linear((chan)->chan_num)
 
+#define CPDMA_RX_SOURCE_PORT(__status__)	((__status__ >> 16) & 0x7)
+
 struct cpdma_params {
 	struct device		*dev;
 	void __iomem		*dmaregs;
@@ -82,7 +84,7 @@ int cpdma_chan_dump(struct cpdma_chan *chan);
 int cpdma_chan_get_stats(struct cpdma_chan *chan,
 			 struct cpdma_chan_stats *stats);
 int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
-		      int len, gfp_t gfp_mask);
+		      int len, int directed, gfp_t gfp_mask);
 int cpdma_chan_process(struct cpdma_chan *chan, int quota);
 
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 242ec55..52c0536 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1037,7 +1037,7 @@ static void emac_rx_handler(void *token, int len, int status)
 
 recycle:
 	ret = cpdma_chan_submit(priv->rxchan, skb, skb->data,
-			skb_tailroom(skb), GFP_KERNEL);
+			skb_tailroom(skb), 0, GFP_KERNEL);
 
 	WARN_ON(ret == -ENOMEM);
 	if (unlikely(ret < 0))
@@ -1092,7 +1092,7 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 	skb_tx_timestamp(skb);
 
 	ret_code = cpdma_chan_submit(priv->txchan, skb, skb->data, skb->len,
-				     GFP_KERNEL);
+				     0, GFP_KERNEL);
 	if (unlikely(ret_code != 0)) {
 		if (netif_msg_tx_err(priv) && net_ratelimit())
 			dev_err(emac_dev, "DaVinci EMAC: desc submit failed");
@@ -1558,7 +1558,7 @@ static int emac_dev_open(struct net_device *ndev)
 			break;
 
 		ret = cpdma_chan_submit(priv->rxchan, skb, skb->data,
-					skb_tailroom(skb), GFP_KERNEL);
+					skb_tailroom(skb), 0, GFP_KERNEL);
 		if (WARN_ON(ret < 0))
 			break;
 	}
-- 
1.7.9.5

