From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 4/9] net: ethernet: ti: cpts: move dt props parsing to cpts driver
Date: Wed, 14 Sep 2016 16:02:26 +0300
Message-ID: <20160914130231.3035-5-grygorii.strashko@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914130231.3035-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move DT properties parsing into CPTS driver to simplify consumer's
code and CPTS driver porting on other SoC in the future
(like Keystone 2).

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 16 +---------------
 drivers/net/ethernet/ti/cpsw.h |  2 --
 drivers/net/ethernet/ti/cpts.c | 29 ++++++++++++++++++++++++++---
 drivers/net/ethernet/ti/cpts.h |  5 +++--
 4 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index dfd5707..3db8fec 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2311,18 +2311,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->active_slave = prop;
 
-	if (of_property_read_u32(node, "cpts_clock_mult", &prop)) {
-		dev_err(&pdev->dev, "Missing cpts_clock_mult property in the DT.\n");
-		return -EINVAL;
-	}
-	data->cpts_clock_mult = prop;
-
-	if (of_property_read_u32(node, "cpts_clock_shift", &prop)) {
-		dev_err(&pdev->dev, "Missing cpts_clock_shift property in the DT.\n");
-		return -EINVAL;
-	}
-	data->cpts_clock_shift = prop;
-
 	data->slave_data = devm_kzalloc(&pdev->dev, data->slaves
 					* sizeof(struct cpsw_slave_data),
 					GFP_KERNEL);
@@ -2742,9 +2730,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_dma_ret;
 	}
 
-	cpsw->cpts = cpts_create(cpsw->dev, cpts_regs,
-				 cpsw->data.cpts_clock_mult,
-				 cpsw->data.cpts_clock_shift);
+	cpsw->cpts = cpts_create(cpsw->dev, cpts_regs, cpsw->dev->of_node);
 	if (IS_ERR(cpsw->cpts)) {
 		ret = PTR_ERR(cpsw->cpts);
 		goto clean_ale_ret;
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index 16b54c6..6c3037a 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -31,8 +31,6 @@ struct cpsw_platform_data {
 	u32	channels;	/* number of cpdma channels (symmetric) */
 	u32	slaves;		/* number of slave cpgmac ports */
 	u32	active_slave; /* time stamping, ethtool and SIOCGMIIPHY slave */
-	u32	cpts_clock_mult;  /* convert input clock ticks to nanoseconds */
-	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
 	u32	ale_entries;	/* ale table size */
 	u32	bd_ram_size;  /*buffer descriptor ram size */
 	u32	mac_control;	/* Mac control register */
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index a46478e..1ee64c6 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -388,10 +388,31 @@ void cpts_unregister(struct cpts *cpts)
 	clk_disable(cpts->refclk);
 }
 
+static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
+{
+	int ret = -EINVAL;
+	u32 prop;
+
+	if (of_property_read_u32(node, "cpts_clock_mult", &prop))
+		goto  of_error;
+	cpts->cc_mult = prop;
+
+	if (of_property_read_u32(node, "cpts_clock_shift", &prop))
+		goto  of_error;
+	cpts->cc.shift = prop;
+
+	return 0;
+
+of_error:
+	dev_err(cpts->dev, "CPTS: Missing property in the DT.\n");
+	return ret;
+}
+
 struct cpts *cpts_create(struct device *dev, void __iomem *regs,
-			 u32 mult, u32 shift)
+			 struct device_node *node)
 {
 	struct cpts *cpts;
+	int ret;
 
 	if (!regs || !dev)
 		return ERR_PTR(-EINVAL);
@@ -405,6 +426,10 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	spin_lock_init(&cpts->lock);
 	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
 
+	ret = cpts_of_parse(cpts, node);
+	if (ret)
+		return ERR_PTR(ret);
+
 	cpts->refclk = devm_clk_get(dev, "cpts");
 	if (IS_ERR(cpts->refclk)) {
 		dev_err(dev, "Failed to get cpts refclk\n");
@@ -415,8 +440,6 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 
 	cpts->cc.read = cpts_systim_read;
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
-	cpts->cc.shift = shift;
-	cpts->cc_mult = mult;
 
 	return cpts;
 }
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 0c02f48..a865193 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -27,6 +27,7 @@
 #include <linux/clocksource.h>
 #include <linux/device.h>
 #include <linux/list.h>
+#include <linux/of.h>
 #include <linux/ptp_clock_kernel.h>
 #include <linux/skbuff.h>
 #include <linux/timecounter.h>
@@ -133,7 +134,7 @@ void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 int cpts_register(struct cpts *cpts);
 void cpts_unregister(struct cpts *cpts);
 struct cpts *cpts_create(struct device *dev, void __iomem *regs,
-			 u32 mult, u32 shift);
+			 struct device_node *node);
 void cpts_release(struct cpts *cpts);
 
 static inline void cpts_rx_enable(struct cpts *cpts, int enable)
@@ -170,7 +171,7 @@ static inline void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 
 static inline
 struct cpts *cpts_create(struct device *dev, void __iomem *regs,
-			 u32 mult, u32 shift)
+			 struct device_node *node)
 {
 	return NULL;
 }
-- 
2.9.3
