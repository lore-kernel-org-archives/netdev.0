From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 1/2] net: ethernet: ti: cpsw: remove rx_descs property
Date: Fri, 17 Jun 2016 13:25:39 +0300
Message-ID: <1466159140-3329-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1466159140-3329-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, bcousson@baylibre.com, tony@atomide.com,
	devicetree@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466159140-3329-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no reason in rx_descs property because davinici_cpdma
driver splits pool of descriptors equally between tx and rx channels.
That is, if number of descriptors 256, 128 of them are for rx
channels. While receiving, the descriptor is freed to the pool and
then allocated with new skb. And if in DT the "rx_descs" is set to
64, then 128 - 64 = 64 descriptors are always in the pool and cannot
be used, for tx, for instance. It's not correct resource usage,
better to set it to half of pool, then the rx pool can be used in
full. It will not have any impact on performance, as anyway, the
"redundant" descriptors were unused.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c          | 13 +++----------
 drivers/net/ethernet/ti/cpsw.h          |  1 -
 drivers/net/ethernet/ti/davinci_cpdma.c |  6 ++++++
 drivers/net/ethernet/ti/davinci_cpdma.h |  1 +
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f2a4cd6..8327328 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1277,6 +1277,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 
 	if (!cpsw_common_res_usage_state(priv)) {
 		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
+		int buf_num;
 
 		/* setup tx dma to fixed prio and zero offset */
 		cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
@@ -1304,10 +1305,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 			enable_irq(priv->irqs_table[0]);
 		}
 
-		if (WARN_ON(!priv->data.rx_descs))
-			priv->data.rx_descs = 128;
-
-		for (i = 0; i < priv->data.rx_descs; i++) {
+		buf_num = cpdma_chan_get_rx_buf_num(priv->dma);
+		for (i = 0; i < buf_num; i++) {
 			struct sk_buff *skb;
 
 			ret = -ENOMEM;
@@ -1998,12 +1997,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->bd_ram_size = prop;
 
-	if (of_property_read_u32(node, "rx_descs", &prop)) {
-		dev_err(&pdev->dev, "Missing rx_descs property in the DT.\n");
-		return -EINVAL;
-	}
-	data->rx_descs = prop;
-
 	if (of_property_read_u32(node, "mac_control", &prop)) {
 		dev_err(&pdev->dev, "Missing mac_control property in the DT.\n");
 		return -EINVAL;
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index e50afd1..16b54c6 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -35,7 +35,6 @@ struct cpsw_platform_data {
 	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
 	u32	ale_entries;	/* ale table size */
 	u32	bd_ram_size;  /*buffer descriptor ram size */
-	u32	rx_descs;	/* Number of Rx Descriptios */
 	u32	mac_control;	/* Mac control register */
 	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
 	bool	dual_emac;	/* Enable Dual EMAC mode */
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 18bf3a8..bcd9e45 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -543,6 +543,12 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_create);
 
+int cpdma_chan_get_rx_buf_num(struct cpdma_ctlr *ctlr)
+{
+	return ctlr->pool->num_desc / 2;
+}
+EXPORT_SYMBOL_GPL(cpdma_chan_get_rx_buf_num);
+
 int cpdma_chan_destroy(struct cpdma_chan *chan)
 {
 	struct cpdma_ctlr *ctlr;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 86dee48..80c015c 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -81,6 +81,7 @@ int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler);
+int cpdma_chan_get_rx_buf_num(struct cpdma_ctlr *ctlr);
 int cpdma_chan_destroy(struct cpdma_chan *chan);
 int cpdma_chan_start(struct cpdma_chan *chan);
 int cpdma_chan_stop(struct cpdma_chan *chan);
-- 
1.9.1
