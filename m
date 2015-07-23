From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH v0 5/6] net: netcp: Fixes to CPSW statistics collection
Date: Thu, 23 Jul 2015 09:32:47 -0400
Message-ID: <1437658368-1679-6-git-send-email-w-kwok2@ti.com>
References: <1437658368-1679-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:40373 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753257AbbGWNdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:33:14 -0400
In-Reply-To: <1437658368-1679-1-git-send-email-w-kwok2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In certain applications it's beneficial to allow the CPSW h/w
stats counters to continue to increment even while the kernel
polls them. This patch implements this behavior for both 1G
and 10G ethernet subsystem modules.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c |   86 ++++++++++++++++++++++++++++-----
 1 file changed, 75 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index aadca02..e2ef7ba 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -646,6 +646,7 @@ struct gbe_priv {
 	bool				enable_ale;
 	u8				max_num_slaves;
 	u8				max_num_ports; /* max_num_slaves + 1 */
+	u8				num_stats_mods;
 	struct netcp_tx_pipe		tx_pipe;
 
 	int				host_port;
@@ -675,6 +676,7 @@ struct gbe_priv {
 	struct net_device		*dummy_ndev;
 
 	u64				*hw_stats;
+	u32				*hw_stats_prev;
 	const struct netcp_ethtool_stat *et_stats;
 	int				num_et_stats;
 	/*  Lock for updating the hwstats */
@@ -1554,25 +1556,37 @@ static int keystone_get_sset_count(struct net_device *ndev, int stringset)
 	}
 }
 
+static void gbe_reset_mod_stats(struct gbe_priv *gbe_dev, int stats_mod)
+{
+	void __iomem *base = gbe_dev->hw_stats_regs[stats_mod];
+	u32  __iomem *p_stats_entry;
+	int i;
+
+	for (i = 0; i < gbe_dev->num_et_stats; i++) {
+		if (gbe_dev->et_stats[i].type == stats_mod) {
+			p_stats_entry = base + gbe_dev->et_stats[i].offset;
+			gbe_dev->hw_stats[i] = 0;
+			gbe_dev->hw_stats_prev[i] = readl(p_stats_entry);
+		}
+	}
+}
+
 static inline void gbe_update_hw_stats_entry(struct gbe_priv *gbe_dev,
 					     int et_stats_entry)
 {
 	void __iomem *base = NULL;
-	u32  __iomem *p;
-	u32 tmp = 0;
+	u32  __iomem *p_stats_entry;
+	u32 curr, delta;
 
 	/* The hw_stats_regs pointers are already
 	 * properly set to point to the right base:
 	 */
 	base = gbe_dev->hw_stats_regs[gbe_dev->et_stats[et_stats_entry].type];
-	p = base + gbe_dev->et_stats[et_stats_entry].offset;
-	tmp = readl(p);
-	gbe_dev->hw_stats[et_stats_entry] += tmp;
-
-	/* write-to-decrement:
-	 * new register value = old register value - write value
-	 */
-	writel(tmp, p);
+	p_stats_entry = base + gbe_dev->et_stats[et_stats_entry].offset;
+	curr = readl(p_stats_entry);
+	delta = curr - gbe_dev->hw_stats_prev[et_stats_entry];
+	gbe_dev->hw_stats_prev[et_stats_entry] = curr;
+	gbe_dev->hw_stats[et_stats_entry] += delta;
 }
 
 static void gbe_update_stats(struct gbe_priv *gbe_dev, uint64_t *data)
@@ -1611,6 +1625,12 @@ static inline void gbe_stats_mod_visible_ver14(struct gbe_priv *gbe_dev,
 	writel(val, GBE_REG_ADDR(gbe_dev, switch_regs, stat_port_en));
 }
 
+static void gbe_reset_mod_stats_ver14(struct gbe_priv *gbe_dev, int stats_mod)
+{
+	gbe_stats_mod_visible_ver14(gbe_dev, stats_mod);
+	gbe_reset_mod_stats(gbe_dev, stats_mod);
+}
+
 static void gbe_update_stats_ver14(struct gbe_priv *gbe_dev, uint64_t *data)
 {
 	u32 half_num_et_stats = (gbe_dev->num_et_stats / 2);
@@ -2564,6 +2584,7 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	}
 	gbe_dev->xgbe_serdes_regs = regs;
 
+	gbe_dev->num_stats_mods = gbe_dev->max_num_ports;
 	gbe_dev->et_stats = xgbe10_et_stats;
 	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
 
@@ -2575,6 +2596,16 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 		return -ENOMEM;
 	}
 
+	gbe_dev->hw_stats_prev =
+		devm_kzalloc(gbe_dev->dev,
+			     gbe_dev->num_et_stats * sizeof(u32),
+			     GFP_KERNEL);
+	if (!gbe_dev->hw_stats_prev) {
+		dev_err(gbe_dev->dev,
+			"hw_stats_prev memory allocation failed\n");
+		return -ENOMEM;
+	}
+
 	gbe_dev->ss_version = XGBE_SS_VERSION_10;
 	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs +
 					XGBE10_SGMII_MODULE_OFFSET;
@@ -2672,6 +2703,7 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 	}
 	gbe_dev->switch_regs = regs;
 
+	gbe_dev->num_stats_mods = gbe_dev->max_num_slaves;
 	gbe_dev->et_stats = gbe13_et_stats;
 	gbe_dev->num_et_stats = ARRAY_SIZE(gbe13_et_stats);
 
@@ -2683,6 +2715,16 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 		return -ENOMEM;
 	}
 
+	gbe_dev->hw_stats_prev =
+		devm_kzalloc(gbe_dev->dev,
+			     gbe_dev->num_et_stats * sizeof(u32),
+			     GFP_KERNEL);
+	if (!gbe_dev->hw_stats_prev) {
+		dev_err(gbe_dev->dev,
+			"hw_stats_prev memory allocation failed\n");
+		return -ENOMEM;
+	}
+
 	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs + GBE13_SGMII_MODULE_OFFSET;
 	gbe_dev->host_port_regs = gbe_dev->switch_regs + GBE13_HOST_PORT_OFFSET;
 
@@ -2726,6 +2768,7 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 	void __iomem *regs;
 	int i, ret;
 
+	gbe_dev->num_stats_mods = gbe_dev->max_num_ports;
 	gbe_dev->et_stats = gbenu_et_stats;
 
 	if (IS_SS_ID_NU(gbe_dev))
@@ -2743,6 +2786,16 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 		return -ENOMEM;
 	}
 
+	gbe_dev->hw_stats_prev =
+		devm_kzalloc(gbe_dev->dev,
+			     gbe_dev->num_et_stats * sizeof(u32),
+			     GFP_KERNEL);
+	if (!gbe_dev->hw_stats_prev) {
+		dev_err(gbe_dev->dev,
+			"hw_stats_prev memory allocation failed\n");
+		return -ENOMEM;
+	}
+
 	ret = of_address_to_resource(node, GBENU_SM_REG_INDEX, &res);
 	if (ret) {
 		dev_err(gbe_dev->dev,
@@ -2801,7 +2854,7 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	struct cpsw_ale_params ale_params;
 	struct gbe_priv *gbe_dev;
 	u32 slave_num;
-	int ret = 0;
+	int i, ret = 0;
 
 	if (!node) {
 		dev_err(dev, "device tree info unavailable\n");
@@ -2949,6 +3002,15 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	/* initialize host port */
 	gbe_init_host_port(gbe_dev);
 
+	spin_lock_bh(&gbe_dev->hw_stats_lock);
+	for (i = 0; i < gbe_dev->num_stats_mods; i++) {
+		if (gbe_dev->ss_version == GBE_SS_VERSION_14)
+			gbe_reset_mod_stats_ver14(gbe_dev, i);
+		else
+			gbe_reset_mod_stats(gbe_dev, i);
+	}
+	spin_unlock_bh(&gbe_dev->hw_stats_lock);
+
 	init_timer(&gbe_dev->timer);
 	gbe_dev->timer.data	 = (unsigned long)gbe_dev;
 	gbe_dev->timer.function = netcp_ethss_timer;
@@ -2960,6 +3022,8 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 quit:
 	if (gbe_dev->hw_stats)
 		devm_kfree(dev, gbe_dev->hw_stats);
+	if (gbe_dev->hw_stats_prev)
+		devm_kfree(dev, gbe_dev->hw_stats_prev);
 	cpsw_ale_destroy(gbe_dev->ale);
 	if (gbe_dev->ss_regs)
 		devm_iounmap(dev, gbe_dev->ss_regs);
-- 
1.7.9.5
