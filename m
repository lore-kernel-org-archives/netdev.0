From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH v1 3/6] net: netcp: Fixes error in oversized memory allocation for statistics storage
Date: Thu, 23 Jul 2015 15:57:21 -0400
Message-ID: <1437681444-23109-4-git-send-email-w-kwok2@ti.com>
References: <1437681444-23109-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437681444-23109-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CPSW driver keeps internally some, but not all, of
the statistics available in the hw statistics modules.  Furthermore,
some of the locations in the hw statistics modules are reserved and
contain no useful information.  Prior to this patch, the driver
allocates memory of the size of the the whole hw statistics modules,
instead of the size of statistics-entries-interested-in (i.e. et_stats),
for internal storage.  This patch fixes that.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c |   46 +++++++++++++++------------------
 1 file changed, 21 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index b954856..3976516 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -295,8 +295,6 @@ struct xgbe_hw_stats {
 	u32	rx_dma_overruns;
 };
 
-#define XGBE10_NUM_STAT_ENTRIES (sizeof(struct xgbe_hw_stats)/sizeof(u32))
-
 struct gbenu_ss_regs {
 	u32	id_ver;
 	u32	synce_count;		/* NU */
@@ -480,7 +478,6 @@ struct gbenu_hw_stats {
 	u32	tx_pri7_drop_bcnt;
 };
 
-#define GBENU_NUM_HW_STAT_ENTRIES (sizeof(struct gbenu_hw_stats) / sizeof(u32))
 #define GBENU_HW_STATS_REG_MAP_SZ	0x200
 
 struct gbe_ss_regs {
@@ -615,7 +612,6 @@ struct gbe_hw_stats {
 	u32	rx_dma_overruns;
 };
 
-#define GBE13_NUM_HW_STAT_ENTRIES (sizeof(struct gbe_hw_stats)/sizeof(u32))
 #define GBE_MAX_HW_STAT_MODS			9
 #define GBE_HW_STATS_REG_MAP_SZ			0x100
 
@@ -2555,10 +2551,12 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	}
 	gbe_dev->xgbe_serdes_regs = regs;
 
+	gbe_dev->et_stats = xgbe10_et_stats;
+	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
+
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
-				  XGBE10_NUM_STAT_ENTRIES *
-				  (gbe_dev->max_num_ports) * sizeof(u64),
-				  GFP_KERNEL);
+					 gbe_dev->num_et_stats * sizeof(u64),
+					 GFP_KERNEL);
 	if (!gbe_dev->hw_stats) {
 		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
 		return -ENOMEM;
@@ -2577,8 +2575,6 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = XGBE10_HOST_PORT_NUM;
 	gbe_dev->ale_entries = XGBE10_NUM_ALE_ENTRIES;
-	gbe_dev->et_stats = xgbe10_et_stats;
-	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
 	gbe_dev->stats_en_mask = (1 << (gbe_dev->max_num_ports)) - 1;
 
 	/* Subsystem registers */
@@ -2663,10 +2659,12 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 	}
 	gbe_dev->switch_regs = regs;
 
+	gbe_dev->et_stats = gbe13_et_stats;
+	gbe_dev->num_et_stats = ARRAY_SIZE(gbe13_et_stats);
+
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
-					  GBE13_NUM_HW_STAT_ENTRIES *
-					  gbe_dev->max_num_slaves * sizeof(u64),
-					  GFP_KERNEL);
+					 gbe_dev->num_et_stats * sizeof(u64),
+					 GFP_KERNEL);
 	if (!gbe_dev->hw_stats) {
 		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
 		return -ENOMEM;
@@ -2689,8 +2687,6 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = GBE13_HOST_PORT_NUM;
 	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
-	gbe_dev->et_stats = gbe13_et_stats;
-	gbe_dev->num_et_stats = ARRAY_SIZE(gbe13_et_stats);
 	gbe_dev->stats_en_mask = GBE13_REG_VAL_STAT_ENABLE_ALL;
 
 	/* Subsystem registers */
@@ -2717,10 +2713,18 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 	void __iomem *regs;
 	int i, ret;
 
+	gbe_dev->et_stats = gbenu_et_stats;
+
+	if (IS_SS_ID_NU(gbe_dev))
+		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
+			(gbe_dev->max_num_slaves * GBENU_ET_STATS_PORT_SIZE);
+	else
+		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
+					GBENU_ET_STATS_PORT_SIZE;
+
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
-				  GBENU_NUM_HW_STAT_ENTRIES *
-				  (gbe_dev->max_num_ports) * sizeof(u64),
-				  GFP_KERNEL);
+					 gbe_dev->num_et_stats * sizeof(u64),
+					 GFP_KERNEL);
 	if (!gbe_dev->hw_stats) {
 		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
 		return -ENOMEM;
@@ -2753,16 +2757,8 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = GBENU_HOST_PORT_NUM;
 	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
-	gbe_dev->et_stats = gbenu_et_stats;
 	gbe_dev->stats_en_mask = (1 << (gbe_dev->max_num_ports)) - 1;
 
-	if (IS_SS_ID_NU(gbe_dev))
-		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
-			(gbe_dev->max_num_slaves * GBENU_ET_STATS_PORT_SIZE);
-	else
-		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
-					GBENU_ET_STATS_PORT_SIZE;
-
 	/* Subsystem registers */
 	GBENU_SET_REG_OFS(gbe_dev, ss_regs, id_ver);
 
-- 
1.7.9.5
