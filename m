From: Keyur Chudgar <kchudgar@apm.com>
Subject: [PATCH v1 3/3] drivers: net: xgene: Add second SGMII based 1G interface
Date: Tue, 17 Mar 2015 11:27:13 -0700
Message-ID: <1426616833-9671-4-git-send-email-kchudgar@apm.com>
References: <1426616833-9671-1-git-send-email-kchudgar@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Keyur Chudgar <kchudgar@apm.com>,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og106.obsmtp.com ([64.18.0.182]:56928 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753405AbbCQSXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 14:23:03 -0400
Received: by pabyw6 with SMTP id yw6so16736343pab.2
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 11:23:02 -0700 (PDT)
In-Reply-To: <1426616833-9671-1-git-send-email-kchudgar@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Added resource initialization based on port-id field
- Enabled second SGMII 1G interface

Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 50 ++++++++++++++++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  | 17 ++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 10 +++--
 4 files changed, 67 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index ec45f32..d9bc89d6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -97,6 +97,8 @@ enum xgene_enet_rm {
 #define QCOHERENT		BIT(4)
 #define RECOMBBUF		BIT(27)
 
+#define MAC_OFFSET			0x30
+
 #define BLOCK_ETH_CSR_OFFSET		0x2000
 #define BLOCK_ETH_RING_IF_OFFSET	0x9000
 #define BLOCK_ETH_DIAG_CSR_OFFSET	0xD000
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 635a83b..f0cb39d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -645,9 +645,11 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	struct device *dev = ndev_to_dev(ndev);
 	struct xgene_enet_desc_ring *rx_ring, *tx_ring, *cp_ring;
 	struct xgene_enet_desc_ring *buf_pool = NULL;
-	u8 cpu_bufnum = 0, eth_bufnum = START_ETH_BUFNUM;
-	u8 bp_bufnum = START_BP_BUFNUM;
-	u16 ring_id, ring_num = START_RING_NUM;
+	u8 cpu_bufnum = pdata->cpu_bufnum;
+	u8 eth_bufnum = pdata->eth_bufnum;
+	u8 bp_bufnum = pdata->bp_bufnum;
+	u16 ring_num = pdata->ring_num;
+	u16 ring_id;
 	int ret;
 
 	/* allocate rx descriptor ring */
@@ -752,6 +754,22 @@ static const struct net_device_ops xgene_ndev_ops = {
 	.ndo_set_mac_address = xgene_enet_set_mac_address,
 };
 
+static int xgene_get_port_id(struct device *dev, struct xgene_enet_pdata *pdata)
+{
+	u32 id = 0;
+	int ret;
+
+	ret = device_property_read_u32(dev, "port-id", &id);
+	if (!ret && id > 1) {
+		dev_err(dev, "Incorrect port-id specified\n");
+		return -ENODEV;
+	}
+
+	pdata->port_id = id;
+
+	return 0;
+}
+
 static int xgene_get_mac_address(struct device *dev,
 				 unsigned char *addr)
 {
@@ -843,6 +861,10 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	}
 	pdata->rx_irq = ret;
 
+	ret = xgene_get_port_id(dev, pdata);
+	if (ret)
+		return ret;
+
 	if (xgene_get_mac_address(dev, ndev->dev_addr) != ETH_ALEN)
 		eth_hw_addr_random(ndev);
 
@@ -866,13 +888,13 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 		pdata->clk = NULL;
 	}
 
-	base_addr = pdata->base_addr;
+	base_addr = pdata->base_addr - (pdata->port_id * MAC_OFFSET);
 	pdata->eth_csr_addr = base_addr + BLOCK_ETH_CSR_OFFSET;
 	pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
 	pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII ||
 	    pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
-		pdata->mcx_mac_addr = base_addr + BLOCK_ETH_MAC_OFFSET;
+		pdata->mcx_mac_addr = pdata->base_addr + BLOCK_ETH_MAC_OFFSET;
 		pdata->mcx_mac_csr_addr = base_addr + BLOCK_ETH_MAC_CSR_OFFSET;
 	} else {
 		pdata->mcx_mac_addr = base_addr + BLOCK_AXG_MAC_OFFSET;
@@ -935,6 +957,24 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 		pdata->rm = RM0;
 		break;
 	}
+
+	switch (pdata->port_id) {
+	case 0:
+		pdata->cpu_bufnum = START_CPU_BUFNUM_0;
+		pdata->eth_bufnum = START_ETH_BUFNUM_0;
+		pdata->bp_bufnum = START_BP_BUFNUM_0;
+		pdata->ring_num = START_RING_NUM_0;
+		break;
+	case 1:
+		pdata->cpu_bufnum = START_CPU_BUFNUM_1;
+		pdata->eth_bufnum = START_ETH_BUFNUM_1;
+		pdata->bp_bufnum = START_BP_BUFNUM_1;
+		pdata->ring_num = START_RING_NUM_1;
+		break;
+	default:
+		break;
+	}
+
 }
 
 static int xgene_enet_probe(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index c2d465c..b93ed21 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -41,9 +41,15 @@
 #define SKB_BUFFER_SIZE		(XGENE_ENET_MAX_MTU - NET_IP_ALIGN)
 #define NUM_PKT_BUF	64
 #define NUM_BUFPOOL	32
-#define START_ETH_BUFNUM	2
-#define START_BP_BUFNUM		0x22
-#define START_RING_NUM		8
+
+#define START_CPU_BUFNUM_0	0
+#define START_ETH_BUFNUM_0	2
+#define START_BP_BUFNUM_0	0x22
+#define START_RING_NUM_0	8
+#define START_CPU_BUFNUM_1	12
+#define START_ETH_BUFNUM_1	10
+#define START_BP_BUFNUM_1	0x2A
+#define START_RING_NUM_1	264
 
 #define PHY_POLL_LINK_ON	(10 * HZ)
 #define PHY_POLL_LINK_OFF	(PHY_POLL_LINK_ON / 5)
@@ -125,6 +131,11 @@ struct xgene_enet_pdata {
 	struct xgene_mac_ops *mac_ops;
 	struct xgene_port_ops *port_ops;
 	struct delayed_work link_work;
+	u32 port_id;
+	u8 cpu_bufnum;
+	u8 eth_bufnum;
+	u8 bp_bufnum;
+	u16 ring_num;
 };
 
 struct xgene_indirect_ctl {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index f5d4f68..f27fb6f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -226,6 +226,7 @@ static u32 xgene_enet_link_status(struct xgene_enet_pdata *p)
 static void xgene_sgmac_init(struct xgene_enet_pdata *p)
 {
 	u32 data, loop = 10;
+	u32 offset = p->port_id * 4;
 
 	xgene_sgmac_reset(p);
 
@@ -272,9 +273,9 @@ static void xgene_sgmac_init(struct xgene_enet_pdata *p)
 	xgene_enet_wr_csr(p, RSIF_RAM_DBG_REG0_ADDR, 0);
 
 	/* Bypass traffic gating */
-	xgene_enet_wr_csr(p, CFG_LINK_AGGR_RESUME_0_ADDR, TX_PORT0);
+	xgene_enet_wr_csr(p, CFG_LINK_AGGR_RESUME_0_ADDR + offset, TX_PORT0);
 	xgene_enet_wr_csr(p, CFG_BYPASS_ADDR, RESUME_TX);
-	xgene_enet_wr_csr(p, SG_RX_DV_GATE_REG_0_ADDR, RESUME_RX0);
+	xgene_enet_wr_csr(p, SG_RX_DV_GATE_REG_0_ADDR + offset, RESUME_RX0);
 }
 
 static void xgene_sgmac_rxtx(struct xgene_enet_pdata *p, u32 bits, bool set)
@@ -330,13 +331,14 @@ static void xgene_enet_cle_bypass(struct xgene_enet_pdata *p,
 				  u32 dst_ring_num, u16 bufpool_id)
 {
 	u32 data, fpsel;
+	u32 offset = p->port_id * MAC_OFFSET;
 
 	data = CFG_CLE_BYPASS_EN0;
-	xgene_enet_wr_csr(p, CLE_BYPASS_REG0_0_ADDR, data);
+	xgene_enet_wr_csr(p, CLE_BYPASS_REG0_0_ADDR + offset, data);
 
 	fpsel = xgene_enet_ring_bufnum(bufpool_id) - 0x20;
 	data = CFG_CLE_DSTQID0(dst_ring_num) | CFG_CLE_FPSEL0(fpsel);
-	xgene_enet_wr_csr(p, CLE_BYPASS_REG1_0_ADDR, data);
+	xgene_enet_wr_csr(p, CLE_BYPASS_REG1_0_ADDR + offset, data);
 }
 
 static void xgene_enet_shutdown(struct xgene_enet_pdata *p)
-- 
1.9.1
