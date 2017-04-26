From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 6/9] drivers: net: xgene: Add rx_overrun/tx_underrun statistic
Date: Wed, 26 Apr 2017 16:38:52 -0700
Message-ID: <1493249935-30759-7-git-send-email-isubramanian@apm.com>
References: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33747 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032773AbdDZXgl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:36:41 -0400
Received: by mail-pf0-f180.google.com with SMTP id a188so8319737pfa.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:36:40 -0700 (PDT)
In-Reply-To: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch adds rx_overrun and tx_underrun ethtool statistic counters.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c | 16 +++++++++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c      | 11 +++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h      |  8 ++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h    |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c   | 14 ++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c   | 11 +++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h   |  4 ++++
 7 files changed, 62 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index bbc90b6..369658b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -71,6 +71,7 @@ struct xgene_gstrings_stats {
 	XGENE_EXTD_STAT(rx_fragments_cntr, RFRG, 16),
 	XGENE_EXTD_STAT(rx_jabber_cntr, RJBR, 16),
 	XGENE_EXTD_STAT(rx_dropped_pkt_cntr, RDRP, 16),
+	XGENE_EXTD_STAT(rx_overrun_cntr, DUMP, 0),
 	XGENE_EXTD_STAT(tx_multicast_pkt_cntr, TMCA, 31),
 	XGENE_EXTD_STAT(tx_broadcast_pkt_cntr, TBCA, 31),
 	XGENE_EXTD_STAT(tx_pause_ctrl_frame_cntr, TXPF, 16),
@@ -88,11 +89,14 @@ struct xgene_gstrings_stats {
 	XGENE_EXTD_STAT(tx_ctrl_frame_cntr, TXCF, 12),
 	XGENE_EXTD_STAT(tx_oversize_frame_cntr, TOVR, 12),
 	XGENE_EXTD_STAT(tx_undersize_frame_cntr, TUND, 12),
-	XGENE_EXTD_STAT(tx_fragments_cntr, TFRG, 12)
+	XGENE_EXTD_STAT(tx_fragments_cntr, TFRG, 12),
+	XGENE_EXTD_STAT(tx_underrun_cntr, DUMP, 0)
 };
 
 #define XGENE_STATS_LEN		ARRAY_SIZE(gstrings_stats)
 #define XGENE_EXTD_STATS_LEN	ARRAY_SIZE(gstrings_extd_stats)
+#define RX_OVERRUN_IDX		22
+#define TX_UNDERRUN_IDX		41
 
 static void xgene_get_drvinfo(struct net_device *ndev,
 			      struct ethtool_drvinfo *info)
@@ -211,15 +215,21 @@ static int xgene_get_sset_count(struct net_device *ndev, int sset)
 
 static void xgene_get_extd_stats(struct xgene_enet_pdata *pdata)
 {
+	u32 rx_drop, tx_drop;
 	u32 tmp;
 	int i;
 
 	for (i = 0; i < XGENE_EXTD_STATS_LEN; i++) {
 		pdata->mac_ops->read_stats(pdata,
 					   gstrings_extd_stats[i].addr, &tmp);
-		pdata->extd_stats[i] += tmp &
-			GENMASK(gstrings_extd_stats[i].mask - 1, 0);
+		if (gstrings_extd_stats[i].mask)
+			pdata->extd_stats[i] += tmp &
+				GENMASK(gstrings_extd_stats[i].mask - 1, 0);
 	}
+
+	pdata->mac_ops->get_drop_cnt(pdata, &rx_drop, &tx_drop);
+	pdata->extd_stats[RX_OVERRUN_IDX] += rx_drop;
+	pdata->extd_stats[TX_UNDERRUN_IDX] += tx_drop;
 }
 
 int xgene_extd_stats_init(struct xgene_enet_pdata *pdata)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index ec5f61f..f79eb78 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -615,6 +615,16 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 	xgene_enet_wr_csr(pdata, CFG_BYPASS_ADDR, RESUME_TX);
 }
 
+static void xgene_gmac_get_drop_cnt(struct xgene_enet_pdata *pdata,
+				    u32 *rx, u32 *tx)
+{
+	u32 count;
+
+	xgene_enet_rd_mcx_csr(pdata, ICM_ECM_DROP_COUNT_REG0_ADDR, &count);
+	*rx = ICM_DROP_COUNT(count);
+	*tx = ECM_DROP_COUNT(count);
+}
+
 static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata)
 {
 	u32 val = 0xffffffff;
@@ -1025,6 +1035,7 @@ void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
 	.rx_disable = xgene_gmac_rx_disable,
 	.tx_disable = xgene_gmac_tx_disable,
 	.read_stats = xgene_enet_rd_mcx_stats,
+	.get_drop_cnt = xgene_gmac_get_drop_cnt,
 	.set_speed = xgene_gmac_set_speed,
 	.set_mac_addr = xgene_gmac_set_mac_addr,
 	.set_framesize = xgene_enet_set_frame_size,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 9130c05..c5672df 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -192,6 +192,10 @@ enum xgene_enet_rm {
 #define CFG_CLE_NXTFPSEL0(val)		(((val) << 20) & GENMASK(23, 20))
 #define ICM_CONFIG0_REG_0_ADDR		0x0400
 #define ICM_CONFIG2_REG_0_ADDR		0x0410
+#define ECM_CONFIG0_REG_0_ADDR		0x0500
+#define ECM_CONFIG0_REG_1_ADDR		0x0504
+#define ICM_ECM_DROP_COUNT_REG0_ADDR	0x0508
+#define ICM_ECM_DROP_COUNT_REG1_ADDR	0x050c
 #define RX_DV_GATE_REG_0_ADDR		0x05fc
 #define TX_DV_GATE_EN0			BIT(2)
 #define RX_DV_GATE_EN0			BIT(1)
@@ -267,6 +271,10 @@ enum xgene_enet_rm {
 #define TOVR_ADDR	0x49
 #define TUND_ADDR	0x4a
 #define TFRG_ADDR	0x4b
+#define DUMP_ADDR	0x27
+
+#define ECM_DROP_COUNT(src)	xgene_get_bits(src, 0, 15)
+#define ICM_DROP_COUNT(src)	xgene_get_bits(src, 16, 31)
 
 #define TSO_IPPROTO_TCP			1
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index dc56519..e4b7786 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -158,6 +158,7 @@ struct xgene_mac_ops {
 	void (*tx_disable)(struct xgene_enet_pdata *pdata);
 	void (*rx_disable)(struct xgene_enet_pdata *pdata);
 	void (*read_stats)(struct xgene_enet_pdata *pdata, u32 addr, u32 *data);
+	void (*get_drop_cnt)(struct xgene_enet_pdata *pdata, u32 *rx, u32 *tx);
 	void (*set_speed)(struct xgene_enet_pdata *pdata);
 	void (*set_mac_addr)(struct xgene_enet_pdata *pdata);
 	void (*set_framesize)(struct xgene_enet_pdata *pdata, int framesize);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index ec4341c..b253069 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -186,6 +186,19 @@ static int xgene_enet_ecc_init(struct xgene_enet_pdata *p)
 	return -ENODEV;
 }
 
+static void xgene_sgmac_get_drop_cnt(struct xgene_enet_pdata *pdata,
+				     u32 *rx, u32 *tx)
+{
+	u32 addr, count;
+
+	addr = (pdata->enet_id != XGENE_ENET1) ?
+		XG_MCX_ICM_ECM_DROP_COUNT_REG0_ADDR :
+		ICM_ECM_DROP_COUNT_REG0_ADDR + pdata->port_id * OFFSET_4;
+	count = xgene_enet_rd_mcx_csr(pdata, addr);
+	*rx = ICM_DROP_COUNT(count);
+	*tx = ECM_DROP_COUNT(count);
+}
+
 static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *p)
 {
 	u32 val;
@@ -692,6 +705,7 @@ static void xgene_sgmac_enable_tx_pause(struct xgene_enet_pdata *p, bool enable)
 	.rx_disable	= xgene_sgmac_rx_disable,
 	.tx_disable	= xgene_sgmac_tx_disable,
 	.read_stats	= xgene_enet_rd_mcx_stats,
+	.get_drop_cnt   = xgene_sgmac_get_drop_cnt,
 	.set_speed	= xgene_sgmac_set_speed,
 	.set_mac_addr	= xgene_sgmac_set_mac_addr,
 	.set_framesize  = xgene_sgmac_set_frame_size,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 0a28162..a317596 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -231,6 +231,16 @@ static int xgene_enet_ecc_init(struct xgene_enet_pdata *pdata)
 	return 0;
 }
 
+static void xgene_xgmac_get_drop_cnt(struct xgene_enet_pdata *pdata,
+				     u32 *rx, u32 *tx)
+{
+	u32 count;
+
+	xgene_enet_rd_axg_csr(pdata, XGENET_ICM_ECM_DROP_COUNT_REG0, &count);
+	*rx = ICM_DROP_COUNT(count);
+	*tx = ECM_DROP_COUNT(count);
+}
+
 static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata)
 {
 	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQASSOC_ADDR, 0);
@@ -589,6 +599,7 @@ static void xgene_enet_link_state(struct work_struct *work)
 	.set_framesize = xgene_xgmac_set_frame_size,
 	.set_mss = xgene_xgmac_set_mss,
 	.read_stats = xgene_enet_rd_axg_stats,
+	.get_drop_cnt = xgene_xgmac_get_drop_cnt,
 	.link_state = xgene_enet_link_state,
 	.enable_tx_pause = xgene_xgmac_enable_tx_pause,
 	.flowctl_rx = xgene_xgmac_flowctl_rx,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
index 9b98c83..a3b4551 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
@@ -71,6 +71,8 @@
 #define XG_RSIF_CONFIG1_REG_ADDR       0x00b8
 #define XG_RSIF_PLC_CLE_BUFF_THRESH    0x1
 #define RSIF_PLC_CLE_BUFF_THRESH_SET(dst, val) xgene_set_bits(dst, val, 0, 2)
+#define XG_MCX_ECM_CONFIG0_REG_0_ADDR          0x0070
+#define XG_MCX_ICM_ECM_DROP_COUNT_REG0_ADDR    0x0124
 #define XCLE_BYPASS_REG0_ADDR           0x0160
 #define XCLE_BYPASS_REG1_ADDR           0x0164
 #define XG_CFG_BYPASS_ADDR		0x0204
@@ -81,6 +83,8 @@
 #define XG_ENET_SPARE_CFG_REG_ADDR	0x040c
 #define XG_ENET_SPARE_CFG_REG_1_ADDR	0x0410
 #define XGENET_RX_DV_GATE_REG_0_ADDR	0x0804
+#define XGENET_ECM_CONFIG0_REG_0	0x0870
+#define XGENET_ICM_ECM_DROP_COUNT_REG0	0x0924
 #define XGENET_CSR_ECM_CFG_0_ADDR	0x0880
 #define XGENET_CSR_MULTI_DPF0_ADDR	0x0888
 #define XGENET_CSR_MULTI_DPF1_ADDR	0x088c
-- 
1.9.1
