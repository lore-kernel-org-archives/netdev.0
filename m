From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 1/9] net: ethernet: ti: exclude cpts from build when disabled
Date: Wed, 14 Sep 2016 16:02:23 +0300
Message-ID: <20160914130231.3035-2-grygorii.strashko@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:46490 "EHLO
        devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760939AbcINNCk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 09:02:40 -0400
In-Reply-To: <20160914130231.3035-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TI CPTS feature declared as optional, but cpts.c module is
included in build always.
Exclude  cpts.c from build when CPTS is disabled in Kconfig and
optimize usage of CONFIG_TI_CPTS.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/Makefile |  3 ++-
 drivers/net/ethernet/ti/cpsw.c   | 21 ++++++++++++++++-----
 drivers/net/ethernet/ti/cpts.c   |  8 --------
 drivers/net/ethernet/ti/cpts.h   | 14 ++++++++++++--
 4 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index d420d94..1e7c10b 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -12,8 +12,9 @@ obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
 obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 obj-$(CONFIG_TI_CPSW_PHY_SEL) += cpsw-phy-sel.o
 obj-$(CONFIG_TI_CPSW_ALE) += cpsw_ale.o
+obj-$(CONFIG_TI_CPTS) += cpts.o
 obj-$(CONFIG_TI_CPSW) += ti_cpsw.o
-ti_cpsw-y := cpsw.o cpts.o
+ti_cpsw-y := cpsw.o
 
 obj-$(CONFIG_TI_KEYSTONE_NETCP) += keystone_netcp.o
 keystone_netcp-y := netcp_core.o
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c6cff3d..b743bb1d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1514,7 +1514,6 @@ fail:
 }
 
 #ifdef CONFIG_TI_CPTS
-
 static void cpsw_hwtstamp_v1(struct cpsw_common *cpsw)
 {
 	struct cpsw_slave *slave = &cpsw->slaves[cpsw->data.active_slave];
@@ -1661,7 +1660,16 @@ static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
 }
+#else
+static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
+{
+	return -EOPNOTSUPP;
+}
 
+static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
+{
+	return -EOPNOTSUPP;
+}
 #endif /*CONFIG_TI_CPTS*/
 
 static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
@@ -1674,12 +1682,10 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 		return -EINVAL;
 
 	switch (cmd) {
-#ifdef CONFIG_TI_CPTS
 	case SIOCSHWTSTAMP:
 		return cpsw_hwtstamp_set(dev, req);
 	case SIOCGHWTSTAMP:
 		return cpsw_hwtstamp_get(dev, req);
-#endif
 	}
 
 	if (!cpsw->slaves[slave_no].phy)
@@ -1935,10 +1941,10 @@ static void cpsw_set_msglevel(struct net_device *ndev, u32 value)
 	priv->msg_enable = value;
 }
 
+#ifdef CONFIG_TI_CPTS
 static int cpsw_get_ts_info(struct net_device *ndev,
 			    struct ethtool_ts_info *info)
 {
-#ifdef CONFIG_TI_CPTS
 	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 
 	info->so_timestamping =
@@ -1955,7 +1961,12 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 	info->rx_filters =
 		(1 << HWTSTAMP_FILTER_NONE) |
 		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+	return 0;
+}
 #else
+static int cpsw_get_ts_info(struct net_device *ndev,
+			    struct ethtool_ts_info *info)
+{
 	info->so_timestamping =
 		SOF_TIMESTAMPING_TX_SOFTWARE |
 		SOF_TIMESTAMPING_RX_SOFTWARE |
@@ -1963,9 +1974,9 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 	info->phc_index = -1;
 	info->tx_types = 0;
 	info->rx_filters = 0;
-#endif
 	return 0;
 }
+#endif
 
 static int cpsw_get_settings(struct net_device *ndev,
 			     struct ethtool_cmd *ecmd)
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 85a55b4..aaab08e 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -31,8 +31,6 @@
 
 #include "cpts.h"
 
-#ifdef CONFIG_TI_CPTS
-
 #define cpts_read32(c, r)	__raw_readl(&c->reg->r)
 #define cpts_write32(c, v, r)	__raw_writel(v, &c->reg->r)
 
@@ -350,12 +348,9 @@ void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 	skb_tstamp_tx(skb, &ssh);
 }
 
-#endif /*CONFIG_TI_CPTS*/
-
 int cpts_register(struct device *dev, struct cpts *cpts,
 		  u32 mult, u32 shift)
 {
-#ifdef CONFIG_TI_CPTS
 	int err, i;
 	unsigned long flags;
 
@@ -391,18 +386,15 @@ int cpts_register(struct device *dev, struct cpts *cpts,
 	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
 
 	cpts->phc_index = ptp_clock_index(cpts->clock);
-#endif
 	return 0;
 }
 
 void cpts_unregister(struct cpts *cpts)
 {
-#ifdef CONFIG_TI_CPTS
 	if (cpts->clock) {
 		ptp_clock_unregister(cpts->clock);
 		cancel_delayed_work_sync(&cpts->overflow_work);
 	}
 	if (cpts->refclk)
 		cpts_clk_release(cpts);
-#endif
 }
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 69a46b9..a68780d 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -130,6 +130,8 @@ struct cpts {
 #ifdef CONFIG_TI_CPTS
 void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
+int cpts_register(struct device *dev, struct cpts *cpts, u32 mult, u32 shift);
+void cpts_unregister(struct cpts *cpts);
 #else
 static inline void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
@@ -137,9 +139,17 @@ static inline void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 static inline void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
 }
+
+static inline int
+cpts_register(struct device *dev, struct cpts *cpts, u32 mult, u32 shift)
+{
+	return 0;
+}
+
+static inline void cpts_unregister(struct cpts *cpts)
+{
+}
 #endif
 
-int cpts_register(struct device *dev, struct cpts *cpts, u32 mult, u32 shift);
-void cpts_unregister(struct cpts *cpts);
 
 #endif
-- 
2.9.3
