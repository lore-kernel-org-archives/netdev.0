From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v4 10/13] net: ethernet: ti: cpts: move dt props parsing to cpts driver
Date: Mon, 5 Dec 2016 14:05:22 -0600
Message-ID: <20161205200525.16664-11-grygorii.strashko@ti.com>
References: <20161205200525.16664-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161205200525.16664-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move DT properties parsing into CPTS driver to simplify CPSW
code and CPTS driver porting on other SoC in the future
(like Keystone 2) - with this change it will not be required
to add the same DT parsing code in Keystone 2 NETCP driver.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 16 +---------------
 drivers/net/ethernet/ti/cpsw.h |  2 --
 drivers/net/ethernet/ti/cpts.c | 32 +++++++++++++++++++++++++++++---
 drivers/net/ethernet/ti/cpts.h |  5 +++--
 4 files changed, 33 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index deb008a..259c717 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2524,18 +2524,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
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
@@ -2990,9 +2978,7 @@ static int cpsw_probe(struct platform_device *pdev)
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
index 9356803..59c09a4 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -409,10 +409,34 @@ void cpts_unregister(struct cpts *cpts)
 }
 EXPORT_SYMBOL_GPL(cpts_unregister);
 
+static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
+{
+	int ret = -EINVAL;
+	u32 prop;
+
+	if (of_property_read_u32(node, "cpts_clock_mult", &prop))
+		goto  of_error;
+	/* save cc.mult original value as it can be modified
+	 * by cpts_ptp_adjfreq().
+	 */
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
 
 	cpts = devm_kzalloc(dev, sizeof(*cpts), GFP_KERNEL);
 	if (!cpts)
@@ -423,6 +447,10 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	spin_lock_init(&cpts->lock);
 	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
 
+	ret = cpts_of_parse(cpts, node);
+	if (ret)
+		return ERR_PTR(ret);
+
 	cpts->refclk = devm_clk_get(dev, "cpts");
 	if (IS_ERR(cpts->refclk)) {
 		dev_err(dev, "Failed to get cpts refclk\n");
@@ -433,8 +461,6 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 
 	cpts->cc.read = cpts_systim_read;
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
-	cpts->cc.shift = shift;
-	cpts->cc_mult = mult;
 	cpts->info = cpts_info;
 
 	return cpts;
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index e7d857c..5da23af 100644
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
@@ -168,7 +169,7 @@ static inline void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 
 static inline
 struct cpts *cpts_create(struct device *dev, void __iomem *regs,
-			 u32 mult, u32 shift)
+			 struct device_node *node)
 {
 	return NULL;
 }
-- 
2.10.1
