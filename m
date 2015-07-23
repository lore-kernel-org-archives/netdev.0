From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH v0 4/6] net: netcp: Consolidates statistics collection code
Date: Thu, 23 Jul 2015 09:32:46 -0400
Message-ID: <1437658368-1679-5-git-send-email-w-kwok2@ti.com>
References: <1437658368-1679-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437658368-1679-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different Keystone2 platforms have different number and
layouts of hw statistics modules.  This patch consolidates
the statistics processing of different Keystone2 platforms
for easy maintenance.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c |   99 ++++++++++++++++++---------------
 1 file changed, 54 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index a1f16e1..aadca02 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -1554,70 +1554,79 @@ static int keystone_get_sset_count(struct net_device *ndev, int stringset)
 	}
 }
 
-static void gbe_update_stats(struct gbe_priv *gbe_dev, uint64_t *data)
+static inline void gbe_update_hw_stats_entry(struct gbe_priv *gbe_dev,
+					     int et_stats_entry)
 {
 	void __iomem *base = NULL;
 	u32  __iomem *p;
 	u32 tmp = 0;
+
+	/* The hw_stats_regs pointers are already
+	 * properly set to point to the right base:
+	 */
+	base = gbe_dev->hw_stats_regs[gbe_dev->et_stats[et_stats_entry].type];
+	p = base + gbe_dev->et_stats[et_stats_entry].offset;
+	tmp = readl(p);
+	gbe_dev->hw_stats[et_stats_entry] += tmp;
+
+	/* write-to-decrement:
+	 * new register value = old register value - write value
+	 */
+	writel(tmp, p);
+}
+
+static void gbe_update_stats(struct gbe_priv *gbe_dev, uint64_t *data)
+{
 	int i;
 
 	for (i = 0; i < gbe_dev->num_et_stats; i++) {
-		base = gbe_dev->hw_stats_regs[gbe_dev->et_stats[i].type];
-		p = base + gbe_dev->et_stats[i].offset;
-		tmp = readl(p);
-		gbe_dev->hw_stats[i] = gbe_dev->hw_stats[i] + tmp;
+		gbe_update_hw_stats_entry(gbe_dev, i);
+
 		if (data)
 			data[i] = gbe_dev->hw_stats[i];
-		/* write-to-decrement:
-		 * new register value = old register value - write value
-		 */
-		writel(tmp, p);
 	}
 }
 
-static void gbe_update_stats_ver14(struct gbe_priv *gbe_dev, uint64_t *data)
+static inline void gbe_stats_mod_visible_ver14(struct gbe_priv *gbe_dev,
+					       int stats_mod)
 {
-	void __iomem *gbe_statsa = gbe_dev->hw_stats_regs[0];
-	void __iomem *gbe_statsb = gbe_dev->hw_stats_regs[1];
-	u64 *hw_stats = &gbe_dev->hw_stats[0];
-	void __iomem *base = NULL;
-	u32  __iomem *p;
-	u32 tmp = 0, val, pair_size = (gbe_dev->num_et_stats / 2);
-	int i, j, pair;
+	u32 val;
 
-	for (pair = 0; pair < 2; pair++) {
-		val = readl(GBE_REG_ADDR(gbe_dev, switch_regs, stat_port_en));
+	val = readl(GBE_REG_ADDR(gbe_dev, switch_regs, stat_port_en));
 
-		if (pair == 0)
-			val &= ~GBE_STATS_CD_SEL;
-		else
-			val |= GBE_STATS_CD_SEL;
+	switch (stats_mod) {
+	case GBE_STATSA_MODULE:
+	case GBE_STATSB_MODULE:
+		val &= ~GBE_STATS_CD_SEL;
+		break;
+	case GBE_STATSC_MODULE:
+	case GBE_STATSD_MODULE:
+		val |= GBE_STATS_CD_SEL;
+		break;
+	default:
+		return;
+	}
+
+	/* make the stat module visible */
+	writel(val, GBE_REG_ADDR(gbe_dev, switch_regs, stat_port_en));
+}
 
-		/* make the stat modules visible */
-		writel(val, GBE_REG_ADDR(gbe_dev, switch_regs, stat_port_en));
+static void gbe_update_stats_ver14(struct gbe_priv *gbe_dev, uint64_t *data)
+{
+	u32 half_num_et_stats = (gbe_dev->num_et_stats / 2);
+	int et_entry, j, pair;
 
-		for (i = 0; i < pair_size; i++) {
-			j = pair * pair_size + i;
-			switch (gbe_dev->et_stats[j].type) {
-			case GBE_STATSA_MODULE:
-			case GBE_STATSC_MODULE:
-				base = gbe_statsa;
-			break;
-			case GBE_STATSB_MODULE:
-			case GBE_STATSD_MODULE:
-				base  = gbe_statsb;
-			break;
-			}
+	for (pair = 0; pair < 2; pair++) {
+		gbe_stats_mod_visible_ver14(gbe_dev, (pair ?
+						      GBE_STATSC_MODULE :
+						      GBE_STATSA_MODULE));
+
+		for (j = 0; j < half_num_et_stats; j++) {
+			et_entry = pair * half_num_et_stats + j;
+			gbe_update_hw_stats_entry(gbe_dev, et_entry);
 
-			p = base + gbe_dev->et_stats[j].offset;
-			tmp = readl(p);
-			hw_stats[j] += tmp;
 			if (data)
-				data[j] = hw_stats[j];
-			/* write-to-decrement:
-			 * new register value = old register value - write value
-			 */
-			writel(tmp, p);
+				data[et_entry] = gbe_dev->hw_stats[et_entry];
 		}
 	}
 }
-- 
1.7.9.5
