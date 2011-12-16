From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v3] tg3: Make the RSS indir tbl admin configurable
Date: Fri, 16 Dec 2011 14:33:11 -0800
Message-ID: <1324074791-10463-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2291 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932667Ab1LPWcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 17:32:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ethtool callbacks necessary to change the rss
indirection table from userspace.  Should the number of interrupts
change (e.g.  across a close / open call, or through a reset) and
any one of the indirection table values fall out-of-range, the driver
will reset the indirection table to a default layout.

[Integrated many suggestions made by Ben Hutchings.]

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  114 ++++++++++++++++++++++++++++++++--
 1 files changed, 107 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 8bf11ca..f64ae91 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8220,21 +8220,38 @@ static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
 		tw32(JMB_REPLENISH_LWM, bdcache_maxcnt);
 }
 
-void tg3_rss_init_indir_tbl(struct tg3 *tp)
+static void tg3_rss_init_dflt_indir_tbl(struct tg3 *tp)
+{
+	int i;
+
+	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
+		tp->rss_ind_tbl[i] =
+			ethtool_rxfh_indir_default(i, tp->irq_cnt - 1);
+}
+
+static void tg3_rss_check_indir_tbl(struct tg3 *tp)
 {
 	int i;
 
 	if (!tg3_flag(tp, SUPPORT_MSIX))
 		return;
 
-	if (tp->irq_cnt <= 2)
+	if (tp->irq_cnt <= 2) {
 		memset(&tp->rss_ind_tbl[0], 0, sizeof(tp->rss_ind_tbl));
-	else
-		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
-			tp->rss_ind_tbl[i] = i % (tp->irq_cnt - 1);
+		return;
+	}
+
+	/* Validate table against current IRQ count */
+	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++) {
+		if (tp->rss_ind_tbl[i] >= tp->irq_cnt - 1)
+			break;
+	}
+
+	if (i != TG3_RSS_INDIR_TBL_SIZE)
+		tg3_rss_init_dflt_indir_tbl(tp);
 }
 
-void tg3_rss_write_indir_tbl(struct tg3 *tp)
+static void tg3_rss_write_indir_tbl(struct tg3 *tp)
 {
 	int i = 0;
 	u32 reg = MAC_RSS_INDIR_TBL_0;
@@ -9668,7 +9685,7 @@ static int tg3_open(struct net_device *dev)
 	 */
 	tg3_ints_init(tp);
 
-	tg3_rss_init_indir_tbl(tp);
+	tg3_rss_check_indir_tbl(tp);
 
 	/* The placement of this call is tied
 	 * to the setup and use of Host TX descriptors.
@@ -10719,6 +10736,84 @@ static int tg3_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+static int tg3_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
+			 u32 *rules __always_unused)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (!tg3_flag(tp, SUPPORT_MSIX))
+		return -EOPNOTSUPP;
+
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		if (netif_running(tp->dev))
+			info->data = tp->irq_cnt;
+		else {
+			info->data = num_online_cpus();
+			if (info->data > TG3_IRQ_MAX_VECS_RSS)
+				info->data = TG3_IRQ_MAX_VECS_RSS;
+		}
+
+		/* The first interrupt vector only
+		 * handles link interrupts.
+		 */
+		info->data -= 1;
+		return 0;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static u32 tg3_get_rxfh_indir_size(struct net_device *dev)
+{
+	u32 size = 0;
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (tg3_flag(tp, SUPPORT_MSIX))
+		size = TG3_RSS_INDIR_TBL_SIZE;
+
+	return size;
+}
+
+static int tg3_get_rxfh_indir(struct net_device *dev, u32 *indir)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int i;
+
+	if (!tg3_flag(tp, SUPPORT_MSIX))
+		return -EOPNOTSUPP;
+
+	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
+		indir[i] = tp->rss_ind_tbl[i];
+
+	return 0;
+}
+
+static int tg3_set_rxfh_indir(struct net_device *dev, const u32 *indir)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	size_t i;
+
+	if (!tg3_flag(tp, SUPPORT_MSIX))
+		return -EOPNOTSUPP;
+
+	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
+		tp->rss_ind_tbl[i] = indir[i];
+
+	if (!netif_running(dev) || !tg3_flag(tp, ENABLE_RSS))
+		return 0;
+
+	/* It is legal to write the indirection
+	 * table while the device is running.
+	 */
+	tg3_full_lock(tp, 0);
+	tg3_rss_write_indir_tbl(tp);
+	tg3_full_unlock(tp);
+
+	return 0;
+}
+
 static void tg3_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	switch (stringset) {
@@ -11949,6 +12044,10 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.get_coalesce		= tg3_get_coalesce,
 	.set_coalesce		= tg3_set_coalesce,
 	.get_sset_count		= tg3_get_sset_count,
+	.get_rxnfc		= tg3_get_rxnfc,
+	.get_rxfh_indir_size    = tg3_get_rxfh_indir_size,
+	.get_rxfh_indir		= tg3_get_rxfh_indir,
+	.set_rxfh_indir		= tg3_set_rxfh_indir,
 };
 
 static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
@@ -14051,6 +14150,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		if (tg3_flag(tp, 57765_PLUS)) {
 			tg3_flag_set(tp, SUPPORT_MSIX);
 			tp->irq_max = TG3_IRQ_MAX_VECS;
+			tg3_rss_init_dflt_indir_tbl(tp);
 		}
 	}
 
-- 
1.7.3.4
