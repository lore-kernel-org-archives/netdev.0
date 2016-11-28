From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH  v2 03/13] net: ethernet: ti: cpsw: minimize direct access to struct cpts
Date: Mon, 28 Nov 2016 17:03:27 -0600
Message-ID: <20161128230337.6731-4-grygorii.strashko@ti.com>
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

This will provide more flexibility in changing CPTS internals and also
required for further changes.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 28 +++++++++++++++-------------
 drivers/net/ethernet/ti/cpts.h | 39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f65a4e8..a6a93ad 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1481,7 +1481,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	}
 
 	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-				cpsw->cpts->tx_enable)
+	    cpts_is_tx_enabled(cpsw->cpts))
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 	skb_tx_timestamp(skb);
@@ -1520,7 +1520,8 @@ static void cpsw_hwtstamp_v1(struct cpsw_common *cpsw)
 	struct cpsw_slave *slave = &cpsw->slaves[cpsw->data.active_slave];
 	u32 ts_en, seq_id;
 
-	if (!cpsw->cpts->tx_enable && !cpsw->cpts->rx_enable) {
+	if (!cpts_is_tx_enabled(cpsw->cpts) &&
+	    !cpts_is_rx_enabled(cpsw->cpts)) {
 		slave_write(slave, 0, CPSW1_TS_CTL);
 		return;
 	}
@@ -1528,10 +1529,10 @@ static void cpsw_hwtstamp_v1(struct cpsw_common *cpsw)
 	seq_id = (30 << CPSW_V1_SEQ_ID_OFS_SHIFT) | ETH_P_1588;
 	ts_en = EVENT_MSG_BITS << CPSW_V1_MSG_TYPE_OFS;
 
-	if (cpsw->cpts->tx_enable)
+	if (cpts_is_tx_enabled(cpsw->cpts))
 		ts_en |= CPSW_V1_TS_TX_EN;
 
-	if (cpsw->cpts->rx_enable)
+	if (cpts_is_rx_enabled(cpsw->cpts))
 		ts_en |= CPSW_V1_TS_RX_EN;
 
 	slave_write(slave, ts_en, CPSW1_TS_CTL);
@@ -1554,20 +1555,20 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 	case CPSW_VERSION_2:
 		ctrl &= ~CTRL_V2_ALL_TS_MASK;
 
-		if (cpsw->cpts->tx_enable)
+		if (cpts_is_tx_enabled(cpsw->cpts))
 			ctrl |= CTRL_V2_TX_TS_BITS;
 
-		if (cpsw->cpts->rx_enable)
+		if (cpts_is_rx_enabled(cpsw->cpts))
 			ctrl |= CTRL_V2_RX_TS_BITS;
 		break;
 	case CPSW_VERSION_3:
 	default:
 		ctrl &= ~CTRL_V3_ALL_TS_MASK;
 
-		if (cpsw->cpts->tx_enable)
+		if (cpts_is_tx_enabled(cpsw->cpts))
 			ctrl |= CTRL_V3_TX_TS_BITS;
 
-		if (cpsw->cpts->rx_enable)
+		if (cpts_is_rx_enabled(cpsw->cpts))
 			ctrl |= CTRL_V3_RX_TS_BITS;
 		break;
 	}
@@ -1603,7 +1604,7 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 
 	switch (cfg.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
-		cpts->rx_enable = 0;
+		cpts_rx_enable(cpts, 0);
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
@@ -1619,14 +1620,14 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
-		cpts->rx_enable = 1;
+		cpts_rx_enable(cpts, 1);
 		cfg.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		break;
 	default:
 		return -ERANGE;
 	}
 
-	cpts->tx_enable = cfg.tx_type == HWTSTAMP_TX_ON;
+	cpts_tx_enable(cpts, cfg.tx_type == HWTSTAMP_TX_ON);
 
 	switch (cpsw->version) {
 	case CPSW_VERSION_1:
@@ -1655,8 +1656,9 @@ static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 		return -EOPNOTSUPP;
 
 	cfg.flags = 0;
-	cfg.tx_type = cpts->tx_enable ? HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
-	cfg.rx_filter = (cpts->rx_enable ?
+	cfg.tx_type = cpts_is_tx_enabled(cpts) ?
+		      HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+	cfg.rx_filter = (cpts_is_rx_enabled(cpts) ?
 			 HWTSTAMP_FILTER_PTP_V2_EVENT : HWTSTAMP_FILTER_NONE);
 
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 416ba2c..29a1e80c 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -132,6 +132,27 @@ void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 int cpts_register(struct device *dev, struct cpts *cpts, u32 mult, u32 shift);
 void cpts_unregister(struct cpts *cpts);
+
+static inline void cpts_rx_enable(struct cpts *cpts, int enable)
+{
+	cpts->rx_enable = enable;
+}
+
+static inline bool cpts_is_rx_enabled(struct cpts *cpts)
+{
+	return !!cpts->rx_enable;
+}
+
+static inline void cpts_tx_enable(struct cpts *cpts, int enable)
+{
+	cpts->tx_enable = enable;
+}
+
+static inline bool cpts_is_tx_enabled(struct cpts *cpts)
+{
+	return !!cpts->tx_enable;
+}
+
 #else
 static inline void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
@@ -149,6 +170,24 @@ cpts_register(struct device *dev, struct cpts *cpts, u32 mult, u32 shift)
 static inline void cpts_unregister(struct cpts *cpts)
 {
 }
+
+static inline void cpts_rx_enable(struct cpts *cpts, int enable)
+{
+}
+
+static inline bool cpts_is_rx_enabled(struct cpts *cpts)
+{
+	return false;
+}
+
+static inline void cpts_tx_enable(struct cpts *cpts, int enable)
+{
+}
+
+static inline bool cpts_is_tx_enabled(struct cpts *cpts)
+{
+	return false;
+}
 #endif
 
 
-- 
2.10.1
