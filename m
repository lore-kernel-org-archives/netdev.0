From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH  v2 02/13] net: ethernet: ti: allow cpts to be built separately
Date: Mon, 28 Nov 2016 17:03:26 -0600
Message-ID: <20161128230337.6731-3-grygorii.strashko@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161128230337.6731-1-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

TI CPTS IP is used as part of TI OMAP CPSW driver, but it's also
present as part of NETCP on TI Keystone 2 SoCs. So, It's required
to enable build of CPTS for both this drivers and this can be
achieved by allowing CPTS to be built separately.

Hence, allow cpts to be built separately and convert it to be
a module as both CPSW and NETCP drives can be built as modules.

Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 drivers/net/ethernet/ti/Kconfig  |  2 +-
 drivers/net/ethernet/ti/Makefile |  3 ++-
 drivers/net/ethernet/ti/cpsw.c   | 22 +++++++++++++++++-----
 drivers/net/ethernet/ti/cpts.c   | 15 +++++++--------
 drivers/net/ethernet/ti/cpts.h   | 18 ++++++++++++++----
 5 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 9904d74..ff7f518 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -74,7 +74,7 @@ config TI_CPSW
 	  will be called cpsw.
 
 config TI_CPTS
-	bool "TI Common Platform Time Sync (CPTS) Support"
+	tristate "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW
 	select PTP_1588_CLOCK
 	---help---
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
index 58947aa..f65a4e8 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1513,7 +1513,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_BUSY;
 }
 
-#ifdef CONFIG_TI_CPTS
+#if IS_ENABLED(CONFIG_TI_CPTS)
 
 static void cpsw_hwtstamp_v1(struct cpsw_common *cpsw)
 {
@@ -1661,7 +1661,16 @@ static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 
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
@@ -1674,12 +1683,10 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
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
@@ -1935,10 +1942,10 @@ static void cpsw_set_msglevel(struct net_device *ndev, u32 value)
 	priv->msg_enable = value;
 }
 
+#if IS_ENABLED(CONFIG_TI_CPTS)
 static int cpsw_get_ts_info(struct net_device *ndev,
 			    struct ethtool_ts_info *info)
 {
-#ifdef CONFIG_TI_CPTS
 	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 
 	info->so_timestamping =
@@ -1955,7 +1962,12 @@ static int cpsw_get_ts_info(struct net_device *ndev,
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
@@ -1963,9 +1975,9 @@ static int cpsw_get_ts_info(struct net_device *ndev,
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
index a42c449..b26d6fe 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -31,8 +31,6 @@
 
 #include "cpts.h"
 
-#ifdef CONFIG_TI_CPTS
-
 #define cpts_read32(c, r)	readl_relaxed(&c->reg->r)
 #define cpts_write32(c, v, r)	writel_relaxed(v, &c->reg->r)
 
@@ -334,6 +332,7 @@ void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 	memset(ssh, 0, sizeof(*ssh));
 	ssh->hwtstamp = ns_to_ktime(ns);
 }
+EXPORT_SYMBOL_GPL(cpts_rx_timestamp);
 
 void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
@@ -349,13 +348,11 @@ void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 	ssh.hwtstamp = ns_to_ktime(ns);
 	skb_tstamp_tx(skb, &ssh);
 }
-
-#endif /*CONFIG_TI_CPTS*/
+EXPORT_SYMBOL_GPL(cpts_tx_timestamp);
 
 int cpts_register(struct device *dev, struct cpts *cpts,
 		  u32 mult, u32 shift)
 {
-#ifdef CONFIG_TI_CPTS
 	int err, i;
 	unsigned long flags;
 
@@ -391,18 +388,20 @@ int cpts_register(struct device *dev, struct cpts *cpts,
 	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
 
 	cpts->phc_index = ptp_clock_index(cpts->clock);
-#endif
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpts_register);
 
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
+EXPORT_SYMBOL_GPL(cpts_unregister);
+
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("TI CPTS ALE driver");
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 69a46b9..416ba2c 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -111,7 +111,7 @@ struct cpts {
 	struct cpsw_cpts __iomem *reg;
 	int tx_enable;
 	int rx_enable;
-#ifdef CONFIG_TI_CPTS
+#if IS_ENABLED(CONFIG_TI_CPTS)
 	struct ptp_clock_info info;
 	struct ptp_clock *clock;
 	spinlock_t lock; /* protects time registers */
@@ -127,9 +127,11 @@ struct cpts {
 #endif
 };
 
-#ifdef CONFIG_TI_CPTS
+#if IS_ENABLED(CONFIG_TI_CPTS)
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
2.10.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
