From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH  v2 07/13] net: ethernet: ti: cpts: rework initialization/deinitialization
Date: Mon, 28 Nov 2016 17:03:31 -0600
Message-ID: <20161128230337.6731-8-grygorii.strashko@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128230337.6731-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current implementation CPTS initialization and deinitialization
(represented by cpts_register/unregister()) does too many static
initialization from .ndo_open(), which is reasonable to do once at probe
time instead, and also require caller to allocate memory for struct cpts,
which is internal for CPTS driver in general.

This patch splits CPTS initialization and deinitialization on two parts:

- static initializtion cpts_create()/cpts_release() which expected to be
executed when parent driver is probed/removed;

- dynamic part cpts_register/unregister() which expected to be executed
when network device is opened/closed.

As result, current code of CPTS parent driver - CPSW - will be simplified
(and it also will allow simplify adding support for Keystone 2 devices in
the future), plus more initialization errors will be catched earlier. In
addition, this change allows to clean up cpts.h for the case when CPTS is
disabled.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |  24 +++++-----
 drivers/net/ethernet/ti/cpts.c | 102 ++++++++++++++++++++++++-----------------
 drivers/net/ethernet/ti/cpts.h |  26 +++++++++--
 3 files changed, 95 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a6a93ad..6c28ef1 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1406,9 +1406,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		if (ret < 0)
 			goto err_cleanup;
 
-		if (cpts_register(cpsw->dev, cpsw->cpts,
-				  cpsw->data.cpts_clock_mult,
-				  cpsw->data.cpts_clock_shift))
+		if (cpts_register(cpsw->cpts))
 			dev_err(priv->dev, "error registering cpts device\n");
 
 	}
@@ -2596,6 +2594,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	struct cpdma_params		dma_params;
 	struct cpsw_ale_params		ale_params;
 	void __iomem			*ss_regs;
+	void __iomem			*cpts_regs;
 	struct resource			*res, *ss_res;
 	const struct of_device_id	*of_id;
 	struct gpio_descs		*mode;
@@ -2623,12 +2622,6 @@ static int cpsw_probe(struct platform_device *pdev)
 	priv->dev  = &ndev->dev;
 	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
 	cpsw->rx_packet_max = max(rx_packet_max, 128);
-	cpsw->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL);
-	if (!cpsw->cpts) {
-		dev_err(&pdev->dev, "error allocating cpts\n");
-		ret = -ENOMEM;
-		goto clean_ndev_ret;
-	}
 
 	mode = devm_gpiod_get_array_optional(&pdev->dev, "mode", GPIOD_OUT_LOW);
 	if (IS_ERR(mode)) {
@@ -2716,7 +2709,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	switch (cpsw->version) {
 	case CPSW_VERSION_1:
 		cpsw->host_port_regs = ss_regs + CPSW1_HOST_PORT_OFFSET;
-		cpsw->cpts->reg      = ss_regs + CPSW1_CPTS_OFFSET;
+		cpts_regs		= ss_regs + CPSW1_CPTS_OFFSET;
 		cpsw->hw_stats	     = ss_regs + CPSW1_HW_STATS;
 		dma_params.dmaregs   = ss_regs + CPSW1_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW1_STATERAM_OFFSET;
@@ -2730,7 +2723,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	case CPSW_VERSION_3:
 	case CPSW_VERSION_4:
 		cpsw->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
-		cpsw->cpts->reg      = ss_regs + CPSW2_CPTS_OFFSET;
+		cpts_regs		= ss_regs + CPSW2_CPTS_OFFSET;
 		cpsw->hw_stats	     = ss_regs + CPSW2_HW_STATS;
 		dma_params.dmaregs   = ss_regs + CPSW2_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW2_STATERAM_OFFSET;
@@ -2796,6 +2789,14 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_dma_ret;
 	}
 
+	cpsw->cpts = cpts_create(cpsw->dev, cpts_regs,
+				 cpsw->data.cpts_clock_mult,
+				 cpsw->data.cpts_clock_shift);
+	if (IS_ERR(cpsw->cpts)) {
+		ret = PTR_ERR(cpsw->cpts);
+		goto clean_ale_ret;
+	}
+
 	ndev->irq = platform_get_irq(pdev, 1);
 	if (ndev->irq < 0) {
 		dev_err(priv->dev, "error getting irq resource\n");
@@ -2911,6 +2912,7 @@ static int cpsw_remove(struct platform_device *pdev)
 		unregister_netdev(cpsw->slaves[1].ndev);
 	unregister_netdev(ndev);
 
+	cpts_release(cpsw->cpts);
 	cpsw_ale_destroy(cpsw->ale);
 	cpdma_ctlr_destroy(cpsw->dma);
 	cpsw_remove_dt(pdev);
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 9ad0998..ec3f702 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -228,24 +228,6 @@ static void cpts_overflow_check(struct work_struct *work)
 	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
 }
 
-static void cpts_clk_init(struct device *dev, struct cpts *cpts)
-{
-	if (!cpts->refclk) {
-		cpts->refclk = devm_clk_get(dev, "cpts");
-		if (IS_ERR(cpts->refclk)) {
-			dev_err(dev, "Failed to get cpts refclk\n");
-			cpts->refclk = NULL;
-			return;
-		}
-	}
-	clk_prepare_enable(cpts->refclk);
-}
-
-static void cpts_clk_release(struct cpts *cpts)
-{
-	clk_disable_unprepare(cpts->refclk);
-}
-
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
 		      u16 ts_seqid, u8 ts_msgtype)
 {
@@ -352,34 +334,24 @@ void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(cpts_tx_timestamp);
 
-int cpts_register(struct device *dev, struct cpts *cpts,
-		  u32 mult, u32 shift)
+int cpts_register(struct cpts *cpts)
 {
 	int err, i;
 
-	cpts->info = cpts_info;
-	spin_lock_init(&cpts->lock);
-
-	cpts->cc.read = cpts_systim_read;
-	cpts->cc.mask = CLOCKSOURCE_MASK(32);
-	cpts->cc_mult = mult;
-	cpts->cc.mult = mult;
-	cpts->cc.shift = shift;
-
 	INIT_LIST_HEAD(&cpts->events);
 	INIT_LIST_HEAD(&cpts->pool);
 	for (i = 0; i < CPTS_MAX_EVENTS; i++)
 		list_add(&cpts->pool_data[i].list, &cpts->pool);
 
-	cpts_clk_init(dev, cpts);
+	clk_enable(cpts->refclk);
+
 	cpts_write32(cpts, CPTS_EN, control);
 	cpts_write32(cpts, TS_PEND_EN, int_enable);
 
+	cpts->cc.mult = cpts->cc_mult;
 	timecounter_init(&cpts->tc, &cpts->cc, ktime_to_ns(ktime_get_real()));
 
-	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
-
-	cpts->clock = ptp_clock_register(&cpts->info, dev);
+	cpts->clock = ptp_clock_register(&cpts->info, cpts->dev);
 	if (IS_ERR(cpts->clock)) {
 		err = PTR_ERR(cpts->clock);
 		cpts->clock = NULL;
@@ -392,26 +364,74 @@ int cpts_register(struct device *dev, struct cpts *cpts,
 	return 0;
 
 err_ptp:
-	if (cpts->refclk)
-		cpts_clk_release(cpts);
+	clk_disable(cpts->refclk);
 	return err;
 }
 EXPORT_SYMBOL_GPL(cpts_register);
 
 void cpts_unregister(struct cpts *cpts)
 {
-	if (cpts->clock) {
-		ptp_clock_unregister(cpts->clock);
-		cancel_delayed_work_sync(&cpts->overflow_work);
-	}
+	if (WARN_ON(!cpts->clock))
+		return;
+
+	cancel_delayed_work_sync(&cpts->overflow_work);
+
+	ptp_clock_unregister(cpts->clock);
+	cpts->clock = NULL;
 
 	cpts_write32(cpts, 0, int_enable);
 	cpts_write32(cpts, 0, control);
 
-	if (cpts->refclk)
-		cpts_clk_release(cpts);
+	clk_disable(cpts->refclk);
 }
 EXPORT_SYMBOL_GPL(cpts_unregister);
 
+struct cpts *cpts_create(struct device *dev, void __iomem *regs,
+			 u32 mult, u32 shift)
+{
+	struct cpts *cpts;
+
+	if (!regs || !dev)
+		return ERR_PTR(-EINVAL);
+
+	cpts = devm_kzalloc(dev, sizeof(*cpts), GFP_KERNEL);
+	if (!cpts)
+		return ERR_PTR(-ENOMEM);
+
+	cpts->dev = dev;
+	cpts->reg = (struct cpsw_cpts __iomem *)regs;
+	spin_lock_init(&cpts->lock);
+	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
+
+	cpts->refclk = devm_clk_get(dev, "cpts");
+	if (IS_ERR(cpts->refclk)) {
+		dev_err(dev, "Failed to get cpts refclk\n");
+		return ERR_PTR(PTR_ERR(cpts->refclk));
+	}
+
+	clk_prepare(cpts->refclk);
+
+	cpts->cc.read = cpts_systim_read;
+	cpts->cc.mask = CLOCKSOURCE_MASK(32);
+	cpts->cc.shift = shift;
+	cpts->cc_mult = mult;
+	cpts->info = cpts_info;
+
+	return cpts;
+}
+EXPORT_SYMBOL_GPL(cpts_create);
+
+void cpts_release(struct cpts *cpts)
+{
+	if (!cpts)
+		return;
+
+	if (WARN_ON(!cpts->clock))
+		return;
+
+	clk_unprepare(cpts->refclk);
+}
+EXPORT_SYMBOL_GPL(cpts_release);
+
 MODULE_LICENSE("GPL v2");
 MODULE_DESCRIPTION("TI CPTS ALE driver");
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 29a1e80c..e7d857c 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -20,6 +20,8 @@
 #ifndef _TI_CPTS_H_
 #define _TI_CPTS_H_
 
+#if IS_ENABLED(CONFIG_TI_CPTS)
+
 #include <linux/clk.h>
 #include <linux/clkdev.h>
 #include <linux/clocksource.h>
@@ -108,10 +110,10 @@ struct cpts_event {
 };
 
 struct cpts {
+	struct device *dev;
 	struct cpsw_cpts __iomem *reg;
 	int tx_enable;
 	int rx_enable;
-#if IS_ENABLED(CONFIG_TI_CPTS)
 	struct ptp_clock_info info;
 	struct ptp_clock *clock;
 	spinlock_t lock; /* protects time registers */
@@ -124,14 +126,15 @@ struct cpts {
 	struct list_head events;
 	struct list_head pool;
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
-#endif
 };
 
-#if IS_ENABLED(CONFIG_TI_CPTS)
 void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-int cpts_register(struct device *dev, struct cpts *cpts, u32 mult, u32 shift);
+int cpts_register(struct cpts *cpts);
 void cpts_unregister(struct cpts *cpts);
+struct cpts *cpts_create(struct device *dev, void __iomem *regs,
+			 u32 mult, u32 shift);
+void cpts_release(struct cpts *cpts);
 
 static inline void cpts_rx_enable(struct cpts *cpts, int enable)
 {
@@ -154,6 +157,8 @@ static inline bool cpts_is_tx_enabled(struct cpts *cpts)
 }
 
 #else
+struct cpts;
+
 static inline void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
 }
@@ -161,8 +166,19 @@ static inline void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
 }
 
+static inline
+struct cpts *cpts_create(struct device *dev, void __iomem *regs,
+			 u32 mult, u32 shift)
+{
+	return NULL;
+}
+
+static inline void cpts_release(struct cpts *cpts)
+{
+}
+
 static inline int
-cpts_register(struct device *dev, struct cpts *cpts, u32 mult, u32 shift)
+cpts_register(struct cpts *cpts)
 {
 	return 0;
 }
-- 
2.10.1
