From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 5/9] drivers: net: xgene: Extend ethtool statistics
Date: Wed, 26 Apr 2017 16:38:51 -0700
Message-ID: <1493249935-30759-6-git-send-email-isubramanian@apm.com>
References: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33907 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032769AbdDZXgj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:36:39 -0400
Received: by mail-pf0-f179.google.com with SMTP id c198so8313100pfc.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:36:39 -0700 (PDT)
In-Reply-To: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch adds extended ethtool statistics support.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 90 +++++++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 20 +++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     | 50 ++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |  8 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  5 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c  | 16 ++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  | 20 +++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |  1 +
 8 files changed, 209 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 217cde8..bbc90b6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -23,9 +23,17 @@
 struct xgene_gstrings_stats {
 	char name[ETH_GSTRING_LEN];
 	int offset;
+	u32 addr;
+	u32 mask;
 };
 
 #define XGENE_STAT(m) { #m, offsetof(struct rtnl_link_stats64, m) }
+#define XGENE_EXTD_STAT(s, a, m)		\
+		{			\
+		.name = #s,		\
+		.addr = a ## _ADDR,	\
+		.mask = m		\
+		}
 
 static const struct xgene_gstrings_stats gstrings_stats[] = {
 	XGENE_STAT(rx_packets),
@@ -40,7 +48,51 @@ struct xgene_gstrings_stats {
 	XGENE_STAT(rx_fifo_errors)
 };
 
+static const struct xgene_gstrings_stats gstrings_extd_stats[] = {
+	XGENE_EXTD_STAT(tx_rx_64b_frame_cntr, TR64, 31),
+	XGENE_EXTD_STAT(tx_rx_127b_frame_cntr, TR127, 31),
+	XGENE_EXTD_STAT(tx_rx_255b_frame_cntr, TR255, 31),
+	XGENE_EXTD_STAT(tx_rx_511b_frame_cntr, TR511, 31),
+	XGENE_EXTD_STAT(tx_rx_1023b_frame_cntr, TR1K, 31),
+	XGENE_EXTD_STAT(tx_rx_1518b_frame_cntr, TRMAX, 31),
+	XGENE_EXTD_STAT(tx_rx_1522b_frame_cntr, TRMGV, 31),
+	XGENE_EXTD_STAT(rx_fcs_error_cntr, RFCS, 16),
+	XGENE_EXTD_STAT(rx_multicast_pkt_cntr, RMCA, 31),
+	XGENE_EXTD_STAT(rx_broadcast_pkt_cntr, RBCA, 31),
+	XGENE_EXTD_STAT(rx_ctrl_frame_pkt_cntr, RXCF, 16),
+	XGENE_EXTD_STAT(rx_pause_frame_pkt_cntr, RXPF, 16),
+	XGENE_EXTD_STAT(rx_unk_opcode_cntr, RXUO, 16),
+	XGENE_EXTD_STAT(rx_align_err_cntr, RALN, 16),
+	XGENE_EXTD_STAT(rx_frame_len_err_cntr, RFLR, 16),
+	XGENE_EXTD_STAT(rx_code_err_cntr, RCDE, 16),
+	XGENE_EXTD_STAT(rx_carrier_sense_err_cntr, RCSE, 16),
+	XGENE_EXTD_STAT(rx_undersize_pkt_cntr, RUND, 16),
+	XGENE_EXTD_STAT(rx_oversize_pkt_cntr, ROVR, 16),
+	XGENE_EXTD_STAT(rx_fragments_cntr, RFRG, 16),
+	XGENE_EXTD_STAT(rx_jabber_cntr, RJBR, 16),
+	XGENE_EXTD_STAT(rx_dropped_pkt_cntr, RDRP, 16),
+	XGENE_EXTD_STAT(tx_multicast_pkt_cntr, TMCA, 31),
+	XGENE_EXTD_STAT(tx_broadcast_pkt_cntr, TBCA, 31),
+	XGENE_EXTD_STAT(tx_pause_ctrl_frame_cntr, TXPF, 16),
+	XGENE_EXTD_STAT(tx_defer_pkt_cntr, TDFR, 31),
+	XGENE_EXTD_STAT(tx_excv_defer_pkt_cntr, TEDF, 31),
+	XGENE_EXTD_STAT(tx_single_col_pkt_cntr, TSCL, 31),
+	XGENE_EXTD_STAT(tx_multi_col_pkt_cntr, TMCL, 31),
+	XGENE_EXTD_STAT(tx_late_col_pkt_cntr, TLCL, 31),
+	XGENE_EXTD_STAT(tx_excv_col_pkt_cntr, TXCL, 31),
+	XGENE_EXTD_STAT(tx_total_col_cntr, TNCL, 31),
+	XGENE_EXTD_STAT(tx_pause_frames_hnrd_cntr, TPFH, 16),
+	XGENE_EXTD_STAT(tx_drop_frame_cntr, TDRP, 16),
+	XGENE_EXTD_STAT(tx_jabber_frame_cntr, TJBR, 12),
+	XGENE_EXTD_STAT(tx_fcs_error_cntr, TFCS, 12),
+	XGENE_EXTD_STAT(tx_ctrl_frame_cntr, TXCF, 12),
+	XGENE_EXTD_STAT(tx_oversize_frame_cntr, TOVR, 12),
+	XGENE_EXTD_STAT(tx_undersize_frame_cntr, TUND, 12),
+	XGENE_EXTD_STAT(tx_fragments_cntr, TFRG, 12)
+};
+
 #define XGENE_STATS_LEN		ARRAY_SIZE(gstrings_stats)
+#define XGENE_EXTD_STATS_LEN	ARRAY_SIZE(gstrings_extd_stats)
 
 static void xgene_get_drvinfo(struct net_device *ndev,
 			      struct ethtool_drvinfo *info)
@@ -142,6 +194,11 @@ static void xgene_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 		memcpy(p, gstrings_stats[i].name, ETH_GSTRING_LEN);
 		p += ETH_GSTRING_LEN;
 	}
+
+	for (i = 0; i < XGENE_EXTD_STATS_LEN; i++) {
+		memcpy(p, gstrings_extd_stats[i].name, ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+	}
 }
 
 static int xgene_get_sset_count(struct net_device *ndev, int sset)
@@ -149,19 +206,50 @@ static int xgene_get_sset_count(struct net_device *ndev, int sset)
 	if (sset != ETH_SS_STATS)
 		return -EINVAL;
 
-	return XGENE_STATS_LEN;
+	return XGENE_STATS_LEN + XGENE_EXTD_STATS_LEN;
+}
+
+static void xgene_get_extd_stats(struct xgene_enet_pdata *pdata)
+{
+	u32 tmp;
+	int i;
+
+	for (i = 0; i < XGENE_EXTD_STATS_LEN; i++) {
+		pdata->mac_ops->read_stats(pdata,
+					   gstrings_extd_stats[i].addr, &tmp);
+		pdata->extd_stats[i] += tmp &
+			GENMASK(gstrings_extd_stats[i].mask - 1, 0);
+	}
+}
+
+int xgene_extd_stats_init(struct xgene_enet_pdata *pdata)
+{
+	pdata->extd_stats = devm_kmalloc_array(&pdata->pdev->dev,
+			XGENE_EXTD_STATS_LEN, sizeof(u64), GFP_KERNEL);
+	if (!pdata->extd_stats)
+		return -ENOMEM;
+
+	xgene_get_extd_stats(pdata);
+	memset(pdata->extd_stats, 0, XGENE_EXTD_STATS_LEN * sizeof(u64));
+
+	return 0;
 }
 
 static void xgene_get_ethtool_stats(struct net_device *ndev,
 				    struct ethtool_stats *dummy,
 				    u64 *data)
 {
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct rtnl_link_stats64 stats;
 	int i;
 
 	dev_get_stats(ndev, &stats);
 	for (i = 0; i < XGENE_STATS_LEN; i++)
 		data[i] = *(u64 *)((char *)&stats + gstrings_stats[i].offset);
+
+	xgene_get_extd_stats(pdata);
+	for (i = 0; i < XGENE_EXTD_STATS_LEN; i++)
+		data[i + XGENE_STATS_LEN] = pdata->extd_stats[i];
 }
 
 static void xgene_get_pauseparam(struct net_device *ndev,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 06bef14..ec5f61f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -366,6 +366,25 @@ static void xgene_enet_rd_mcx_mac(struct xgene_enet_pdata *pdata,
 	spin_unlock(&pdata->mac_lock);
 }
 
+static void xgene_enet_rd_mcx_stats(struct xgene_enet_pdata *pdata,
+				    u32 rd_addr, u32 *rd_data)
+{
+	void __iomem *addr, *rd, *cmd, *cmd_done;
+	int ret;
+
+	addr = pdata->mcx_stats_addr + STAT_ADDR_REG_OFFSET;
+	rd = pdata->mcx_stats_addr + STAT_READ_REG_OFFSET;
+	cmd = pdata->mcx_stats_addr + STAT_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mcx_stats_addr + STAT_COMMAND_DONE_REG_OFFSET;
+
+	spin_lock(&pdata->stats_lock);
+	ret = xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data);
+	if (!ret)
+		netdev_err(pdata->ndev, "MCX stats read not completed, addr: %04x\n",
+			   rd_addr);
+	spin_unlock(&pdata->stats_lock);
+}
+
 static void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata)
 {
 	u32 addr0, addr1;
@@ -1005,6 +1024,7 @@ void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
 	.tx_enable = xgene_gmac_tx_enable,
 	.rx_disable = xgene_gmac_rx_disable,
 	.tx_disable = xgene_gmac_tx_disable,
+	.read_stats = xgene_enet_rd_mcx_stats,
 	.set_speed = xgene_gmac_set_speed,
 	.set_mac_addr = xgene_gmac_set_mac_addr,
 	.set_framesize = xgene_enet_set_frame_size,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 5a9f9d5..9130c05 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -115,6 +115,7 @@ enum xgene_enet_rm {
 #define BLOCK_ETH_CLKRST_CSR_OFFSET	0xc000
 #define BLOCK_ETH_DIAG_CSR_OFFSET	0xD000
 #define BLOCK_ETH_MAC_OFFSET		0x0000
+#define BLOCK_ETH_STATS_OFFSET		0x0000
 #define BLOCK_ETH_MAC_CSR_OFFSET	0x2800
 
 #define CLKEN_ADDR			0xc208
@@ -126,6 +127,12 @@ enum xgene_enet_rm {
 #define MAC_READ_REG_OFFSET		0x0c
 #define MAC_COMMAND_DONE_REG_OFFSET	0x10
 
+#define STAT_ADDR_REG_OFFSET            0x14
+#define STAT_COMMAND_REG_OFFSET         0x18
+#define STAT_WRITE_REG_OFFSET           0x1c
+#define STAT_READ_REG_OFFSET            0x20
+#define STAT_COMMAND_DONE_REG_OFFSET    0x24
+
 #define PCS_ADDR_REG_OFFSET		0x00
 #define PCS_COMMAND_REG_OFFSET		0x04
 #define PCS_WRITE_REG_OFFSET		0x08
@@ -218,6 +225,49 @@ enum xgene_enet_rm {
 #define PAD_CRC				BIT(2)
 #define LENGTH_CHK			BIT(4)
 
+#define TR64_ADDR	0x20
+#define TR127_ADDR	0x21
+#define TR255_ADDR	0x22
+#define TR511_ADDR	0x23
+#define TR1K_ADDR	0x24
+#define TRMAX_ADDR	0x25
+#define TRMGV_ADDR	0x26
+
+#define RFCS_ADDR	0x29
+#define RMCA_ADDR	0x2a
+#define RBCA_ADDR	0x2b
+#define RXCF_ADDR	0x2c
+#define RXPF_ADDR	0x2d
+#define RXUO_ADDR	0x2e
+#define RALN_ADDR	0x2f
+#define RFLR_ADDR	0x30
+#define RCDE_ADDR	0x31
+#define RCSE_ADDR	0x32
+#define RUND_ADDR	0x33
+#define ROVR_ADDR	0x34
+#define RFRG_ADDR	0x35
+#define RJBR_ADDR	0x36
+#define RDRP_ADDR	0x37
+
+#define TMCA_ADDR	0x3a
+#define TBCA_ADDR	0x3b
+#define TXPF_ADDR	0x3c
+#define TDFR_ADDR	0x3d
+#define TEDF_ADDR	0x3e
+#define TSCL_ADDR	0x3f
+#define TMCL_ADDR	0x40
+#define TLCL_ADDR	0x41
+#define TXCL_ADDR	0x42
+#define TNCL_ADDR	0x43
+#define TPFH_ADDR	0x44
+#define TDRP_ADDR	0x45
+#define TJBR_ADDR	0x46
+#define TFCS_ADDR	0x47
+#define TXCF_ADDR	0x48
+#define TOVR_ADDR	0x49
+#define TUND_ADDR	0x4a
+#define TFRG_ADDR	0x4b
+
 #define TSO_IPPROTO_TCP			1
 
 #define USERINFO_POS			0
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 3f24b83..bd2486e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1792,12 +1792,15 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII ||
 	    pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
 		pdata->mcx_mac_addr = pdata->base_addr + BLOCK_ETH_MAC_OFFSET;
+		pdata->mcx_stats_addr =
+			pdata->base_addr + BLOCK_ETH_STATS_OFFSET;
 		offset = (pdata->enet_id == XGENE_ENET1) ?
 			  BLOCK_ETH_MAC_CSR_OFFSET :
 			  X2_BLOCK_ETH_MAC_CSR_OFFSET;
 		pdata->mcx_mac_csr_addr = base_addr + offset;
 	} else {
 		pdata->mcx_mac_addr = base_addr + BLOCK_AXG_MAC_OFFSET;
+		pdata->mcx_stats_addr = base_addr + BLOCK_AXG_STATS_OFFSET;
 		pdata->mcx_mac_csr_addr = base_addr + BLOCK_AXG_MAC_CSR_OFFSET;
 		pdata->pcs_addr = base_addr + BLOCK_PCS_OFFSET;
 	}
@@ -2090,6 +2093,11 @@ static int xgene_enet_probe(struct platform_device *pdev)
 			goto err1;
 	}
 
+	spin_lock_init(&pdata->stats_lock);
+	ret = xgene_extd_stats_init(pdata);
+	if (ret)
+		goto err2;
+
 	xgene_enet_napi_add(pdata);
 	ret = register_netdev(ndev);
 	if (ret) {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 3bf6638..dc56519 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -157,6 +157,7 @@ struct xgene_mac_ops {
 	void (*rx_enable)(struct xgene_enet_pdata *pdata);
 	void (*tx_disable)(struct xgene_enet_pdata *pdata);
 	void (*rx_disable)(struct xgene_enet_pdata *pdata);
+	void (*read_stats)(struct xgene_enet_pdata *pdata, u32 addr, u32 *data);
 	void (*set_speed)(struct xgene_enet_pdata *pdata);
 	void (*set_mac_addr)(struct xgene_enet_pdata *pdata);
 	void (*set_framesize)(struct xgene_enet_pdata *pdata, int framesize);
@@ -214,6 +215,7 @@ struct xgene_enet_pdata {
 	void __iomem *eth_diag_csr_addr;
 	void __iomem *mcx_mac_addr;
 	void __iomem *mcx_mac_csr_addr;
+	void __iomem *mcx_stats_addr;
 	void __iomem *base_addr;
 	void __iomem *pcs_addr;
 	void __iomem *ring_csr_addr;
@@ -221,6 +223,8 @@ struct xgene_enet_pdata {
 	int phy_mode;
 	enum xgene_enet_rm rm;
 	struct xgene_enet_cle cle;
+	u64 *extd_stats;
+	spinlock_t stats_lock; /* statistics lock */
 	const struct xgene_mac_ops *mac_ops;
 	spinlock_t mac_lock; /* mac lock */
 	const struct xgene_port_ops *port_ops;
@@ -265,5 +269,6 @@ static inline u16 xgene_enet_dst_ring_num(struct xgene_enet_desc_ring *ring)
 }
 
 void xgene_enet_set_ethtool_ops(struct net_device *netdev);
+int xgene_extd_stats_init(struct xgene_enet_pdata *pdata);
 
 #endif /* __XGENE_ENET_MAIN_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index 4dd41f5..ec4341c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -145,6 +145,21 @@ static u32 xgene_enet_rd_mac(struct xgene_enet_pdata *p, u32 rd_addr)
 	return val;
 }
 
+static void xgene_enet_rd_mcx_stats(struct xgene_enet_pdata *p,
+				    u32 rd_addr, u32 *rd_data)
+{
+	struct xgene_indirect_ctl ctl = {
+		.addr = p->mcx_stats_addr + STAT_ADDR_REG_OFFSET,
+		.ctl = p->mcx_stats_addr + STAT_READ_REG_OFFSET,
+		.cmd = p->mcx_stats_addr + STAT_COMMAND_REG_OFFSET,
+		.cmd_done = p->mcx_stats_addr + STAT_COMMAND_DONE_REG_OFFSET
+	};
+
+	spin_lock(&p->stats_lock);
+	*rd_data = xgene_enet_rd_indirect(&ctl, rd_addr);
+	spin_unlock(&p->stats_lock);
+}
+
 static int xgene_enet_ecc_init(struct xgene_enet_pdata *p)
 {
 	struct net_device *ndev = p->ndev;
@@ -676,6 +691,7 @@ static void xgene_sgmac_enable_tx_pause(struct xgene_enet_pdata *p, bool enable)
 	.tx_enable	= xgene_sgmac_tx_enable,
 	.rx_disable	= xgene_sgmac_rx_disable,
 	.tx_disable	= xgene_sgmac_tx_disable,
+	.read_stats	= xgene_enet_rd_mcx_stats,
 	.set_speed	= xgene_sgmac_set_speed,
 	.set_mac_addr	= xgene_sgmac_set_mac_addr,
 	.set_framesize  = xgene_sgmac_set_frame_size,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 9a2d0ca..0a28162 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -165,6 +165,25 @@ static void xgene_enet_rd_mac(struct xgene_enet_pdata *pdata,
 	spin_unlock(&pdata->mac_lock);
 }
 
+static void xgene_enet_rd_axg_stats(struct xgene_enet_pdata *pdata,
+				    u32 rd_addr, u32 *rd_data)
+{
+	void __iomem *addr, *rd, *cmd, *cmd_done;
+	int ret;
+
+	addr = pdata->mcx_stats_addr + STAT_ADDR_REG_OFFSET;
+	rd = pdata->mcx_stats_addr + STAT_READ_REG_OFFSET;
+	cmd = pdata->mcx_stats_addr + STAT_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mcx_stats_addr + STAT_COMMAND_DONE_REG_OFFSET;
+
+	spin_lock(&pdata->stats_lock);
+	ret = xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data);
+	if (!ret)
+		netdev_err(pdata->ndev, "AXG stats read not completed, addr: %04x\n",
+			   rd_addr);
+	spin_unlock(&pdata->stats_lock);
+}
+
 static bool xgene_enet_rd_pcs(struct xgene_enet_pdata *pdata,
 			      u32 rd_addr, u32 *rd_data)
 {
@@ -569,6 +588,7 @@ static void xgene_enet_link_state(struct work_struct *work)
 	.set_mac_addr = xgene_xgmac_set_mac_addr,
 	.set_framesize = xgene_xgmac_set_frame_size,
 	.set_mss = xgene_xgmac_set_mss,
+	.read_stats = xgene_enet_rd_axg_stats,
 	.link_state = xgene_enet_link_state,
 	.enable_tx_pause = xgene_xgmac_enable_tx_pause,
 	.flowctl_rx = xgene_xgmac_flowctl_rx,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
index e644a42..9b98c83 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
@@ -23,6 +23,7 @@
 
 #define X2_BLOCK_ETH_MAC_CSR_OFFSET	0x3000
 #define BLOCK_AXG_MAC_OFFSET		0x0800
+#define BLOCK_AXG_STATS_OFFSET		0x0800
 #define BLOCK_AXG_MAC_CSR_OFFSET	0x2000
 #define BLOCK_PCS_OFFSET		0x3800
 
-- 
1.9.1
