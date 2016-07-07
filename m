From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v5 01/11] drivers: net: xgene: Separate set_speed from mac_init
Date: Thu,  7 Jul 2016 16:02:49 -0700
Message-ID: <1467932579-14320-2-git-send-email-isubramanian@apm.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch, linux@armlinux.org.uk,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34765 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbcGGXCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:02:55 -0400
Received: by mail-pf0-f175.google.com with SMTP id h14so9981198pfe.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 16:02:55 -0700 (PDT)
In-Reply-To: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since mac_init is too heavy to be called when the link changes,
moved the speed_set configuration to a new function and added
mac_ops->set_speed function pointer.  This function will be
called from adjust_link callback.

Added cases for 10/100 support for SGMII based 1G interface.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
Tested-by: Matthias Brugger <mbrugger@suse.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  30 +++--
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |   2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |   6 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |   1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 133 ++++++++++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |   7 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |   3 +
 7 files changed, 149 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 2f5638f..725109b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -512,14 +512,11 @@ static void xgene_enet_configure_clock(struct xgene_enet_pdata *pdata)
 #endif
 }
 
-static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
+static void xgene_gmac_set_speed(struct xgene_enet_pdata *pdata)
 {
 	struct device *dev = &pdata->pdev->dev;
-	u32 value, mc2;
-	u32 intf_ctl, rgmii;
-	u32 icm0, icm2;
-
-	xgene_gmac_reset(pdata);
+	u32 icm0, icm2, mc2;
+	u32 intf_ctl, rgmii, value;
 
 	xgene_enet_rd_mcx_csr(pdata, ICM_CONFIG0_REG_0_ADDR, &icm0);
 	xgene_enet_rd_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, &icm2);
@@ -564,7 +561,19 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 	mc2 |= FULL_DUPLEX2 | PAD_CRC;
 	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_2_ADDR, mc2);
 	xgene_enet_wr_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, intf_ctl);
+	xgene_enet_wr_csr(pdata, RGMII_REG_0_ADDR, rgmii);
+	xgene_enet_configure_clock(pdata);
+
+	xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG0_REG_0_ADDR, icm0);
+	xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, icm2);
+}
 
+static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
+{
+	u32 value;
+
+	xgene_gmac_reset(pdata);
+	xgene_gmac_set_speed(pdata);
 	xgene_gmac_set_mac_addr(pdata);
 
 	/* Adjust MDC clock frequency */
@@ -579,15 +588,10 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 
 	/* Rtype should be copied from FP */
 	xgene_enet_wr_csr(pdata, RSIF_RAM_DBG_REG0_ADDR, 0);
-	xgene_enet_wr_csr(pdata, RGMII_REG_0_ADDR, rgmii);
-	xgene_enet_configure_clock(pdata);
 
 	/* Rx-Tx traffic resume */
 	xgene_enet_wr_csr(pdata, CFG_LINK_AGGR_RESUME_0_ADDR, TX_PORT0);
 
-	xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG0_REG_0_ADDR, icm0);
-	xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, icm2);
-
 	xgene_enet_rd_mcx_csr(pdata, RX_DV_GATE_REG_0_ADDR, &value);
 	value &= ~TX_DV_GATE_EN0;
 	value &= ~RX_DV_GATE_EN0;
@@ -724,12 +728,13 @@ static int xgene_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 static void xgene_enet_adjust_link(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 	struct phy_device *phydev = pdata->phy_dev;
 
 	if (phydev->link) {
 		if (pdata->phy_speed != phydev->speed) {
 			pdata->phy_speed = phydev->speed;
-			xgene_gmac_init(pdata);
+			mac_ops->set_speed(pdata);
 			xgene_gmac_rx_enable(pdata);
 			xgene_gmac_tx_enable(pdata);
 			phy_print_status(phydev);
@@ -890,6 +895,7 @@ const struct xgene_mac_ops xgene_gmac_ops = {
 	.tx_enable = xgene_gmac_tx_enable,
 	.rx_disable = xgene_gmac_rx_disable,
 	.tx_disable = xgene_gmac_tx_disable,
+	.set_speed = xgene_gmac_set_speed,
 	.set_mac_addr = xgene_gmac_set_mac_addr,
 };
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 45220be..e840f96 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -104,6 +104,8 @@ enum xgene_enet_rm {
 #define RECOMBBUF		BIT(27)
 
 #define MAC_OFFSET			0x30
+#define OFFSET_4			0x04
+#define OFFSET_8			0x08
 
 #define BLOCK_ETH_CSR_OFFSET		0x2000
 #define BLOCK_ETH_CLE_CSR_OFFSET	0x6000
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index d208b17..8da3860 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -730,8 +730,10 @@ static int xgene_enet_open(struct net_device *ndev)
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		phy_start(pdata->phy_dev);
-	else
+	else {
 		schedule_delayed_work(&pdata->link_work, PHY_POLL_LINK_OFF);
+		netif_carrier_off(ndev);
+	}
 
 	netif_start_queue(ndev);
 
@@ -761,7 +763,6 @@ static int xgene_enet_close(struct net_device *ndev)
 
 	return 0;
 }
-
 static void xgene_enet_delete_ring(struct xgene_enet_desc_ring *ring)
 {
 	struct xgene_enet_pdata *pdata;
@@ -1447,6 +1448,7 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 		pdata->port_ops->cle_bypass(pdata, dst_ring_num, buf_pool->id);
 	}
 
+	pdata->phy_speed = SPEED_UNKNOWN;
 	pdata->mac_ops->init(pdata);
 
 	return ret;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 092fbec..aed9f43 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -140,6 +140,7 @@ struct xgene_mac_ops {
 	void (*rx_enable)(struct xgene_enet_pdata *pdata);
 	void (*tx_disable)(struct xgene_enet_pdata *pdata);
 	void (*rx_disable)(struct xgene_enet_pdata *pdata);
+	void (*set_speed)(struct xgene_enet_pdata *pdata);
 	void (*set_mac_addr)(struct xgene_enet_pdata *pdata);
 	void (*set_mss)(struct xgene_enet_pdata *pdata);
 	void (*link_state)(struct work_struct *work);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index 7847551..01447ef 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -93,6 +93,11 @@ static u32 xgene_enet_rd_diag_csr(struct xgene_enet_pdata *p, u32 offset)
 	return ioread32(p->eth_diag_csr_addr + offset);
 }
 
+static u32 xgene_enet_rd_mcx_csr(struct xgene_enet_pdata *p, u32 offset)
+{
+	return ioread32(p->mcx_mac_csr_addr + offset);
+}
+
 static u32 xgene_enet_rd_indirect(struct xgene_indirect_ctl *ctl, u32 rd_addr)
 {
 	u32 rd_data;
@@ -230,21 +235,103 @@ static u32 xgene_enet_link_status(struct xgene_enet_pdata *p)
 	data = xgene_mii_phy_read(p, INT_PHY_ADDR,
 				  SGMII_BASE_PAGE_ABILITY_ADDR >> 2);
 
+	if (LINK_SPEED(data) == PHY_SPEED_1000)
+		p->phy_speed = SPEED_1000;
+	else if (LINK_SPEED(data) == PHY_SPEED_100)
+		p->phy_speed = SPEED_100;
+	else
+		p->phy_speed = SPEED_10;
+
 	return data & LINK_UP;
 }
 
-static void xgene_sgmac_init(struct xgene_enet_pdata *p)
+static void xgene_sgmii_control_reset(struct xgene_enet_pdata *p)
 {
-	u32 data, loop = 10;
-	u32 offset = p->port_id * 4;
-	u32 enet_spare_cfg_reg, rsif_config_reg;
-	u32 cfg_bypass_reg, rx_dv_gate_reg;
-
-	xgene_sgmac_reset(p);
+	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_CONTROL_ADDR >> 2, 0x9140);
+}
 
-	/* Enable auto-negotiation */
-	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_CONTROL_ADDR >> 2, 0x1000);
+static void xgene_sgmii_tbi_control_reset(struct xgene_enet_pdata *p)
+{
+	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_TBI_CONTROL_ADDR >> 2,
+			    0x8000);
 	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_TBI_CONTROL_ADDR >> 2, 0);
+}
+
+static void xgene_sgmii_reset(struct xgene_enet_pdata *p)
+{
+	u32 value;
+
+	if (p->phy_speed == SPEED_UNKNOWN)
+		return;
+
+	value = xgene_mii_phy_read(p, INT_PHY_ADDR,
+				   SGMII_BASE_PAGE_ABILITY_ADDR >> 2);
+	if (!(value & LINK_UP))
+		xgene_sgmii_tbi_control_reset(p);
+}
+
+static void xgene_sgmac_set_speed(struct xgene_enet_pdata *p)
+{
+	u32 icm0_addr, icm2_addr, debug_addr;
+	u32 icm0, icm2, intf_ctl;
+	u32 mc2, value;
+
+	xgene_sgmii_reset(p);
+
+	if (p->enet_id == XGENE_ENET1) {
+		icm0_addr = ICM_CONFIG0_REG_0_ADDR + p->port_id * OFFSET_8;
+		icm2_addr = ICM_CONFIG2_REG_0_ADDR + p->port_id * OFFSET_4;
+		debug_addr = DEBUG_REG_ADDR;
+	} else {
+		icm0_addr = XG_MCX_ICM_CONFIG0_REG_0_ADDR;
+		icm2_addr = XG_MCX_ICM_CONFIG2_REG_0_ADDR;
+		debug_addr = XG_DEBUG_REG_ADDR;
+	}
+
+	icm0 = xgene_enet_rd_mcx_csr(p, icm0_addr);
+	icm2 = xgene_enet_rd_mcx_csr(p, icm2_addr);
+	mc2 = xgene_enet_rd_mac(p, MAC_CONFIG_2_ADDR);
+	intf_ctl = xgene_enet_rd_mac(p, INTERFACE_CONTROL_ADDR);
+
+	switch (p->phy_speed) {
+	case SPEED_10:
+		ENET_INTERFACE_MODE2_SET(&mc2, 1);
+		intf_ctl &= ~(ENET_LHD_MODE | ENET_GHD_MODE);
+		CFG_MACMODE_SET(&icm0, 0);
+		CFG_WAITASYNCRD_SET(&icm2, 500);
+		break;
+	case SPEED_100:
+		ENET_INTERFACE_MODE2_SET(&mc2, 1);
+		intf_ctl &= ~ENET_GHD_MODE;
+		intf_ctl |= ENET_LHD_MODE;
+		CFG_MACMODE_SET(&icm0, 1);
+		CFG_WAITASYNCRD_SET(&icm2, 80);
+		break;
+	default:
+		ENET_INTERFACE_MODE2_SET(&mc2, 2);
+		intf_ctl &= ~ENET_LHD_MODE;
+		intf_ctl |= ENET_GHD_MODE;
+		CFG_MACMODE_SET(&icm0, 2);
+		CFG_WAITASYNCRD_SET(&icm2, 16);
+		value = xgene_enet_rd_csr(p, debug_addr);
+		value |= CFG_BYPASS_UNISEC_TX | CFG_BYPASS_UNISEC_RX;
+		xgene_enet_wr_csr(p, debug_addr, value);
+		break;
+	}
+
+	mc2 |= FULL_DUPLEX2 | PAD_CRC;
+	xgene_enet_wr_mac(p, MAC_CONFIG_2_ADDR, mc2);
+	xgene_enet_wr_mac(p, INTERFACE_CONTROL_ADDR, intf_ctl);
+	xgene_enet_wr_mcx_csr(p, icm0_addr, icm0);
+	xgene_enet_wr_mcx_csr(p, icm2_addr, icm2);
+}
+
+static void xgene_sgmii_enable_autoneg(struct xgene_enet_pdata *p)
+{
+	u32 data, loop = 10;
+
+	xgene_sgmii_control_reset(p);
+	xgene_sgmii_tbi_control_reset(p);
 
 	while (loop--) {
 		data = xgene_mii_phy_read(p, INT_PHY_ADDR,
@@ -255,17 +342,25 @@ static void xgene_sgmac_init(struct xgene_enet_pdata *p)
 	}
 	if (!(data & AUTO_NEG_COMPLETE) || !(data & LINK_STATUS))
 		netdev_err(p->ndev, "Auto-negotiation failed\n");
+}
 
-	data = xgene_enet_rd_mac(p, MAC_CONFIG_2_ADDR);
-	ENET_INTERFACE_MODE2_SET(&data, 2);
-	xgene_enet_wr_mac(p, MAC_CONFIG_2_ADDR, data | FULL_DUPLEX2);
-	xgene_enet_wr_mac(p, INTERFACE_CONTROL_ADDR, ENET_GHD_MODE);
+static void xgene_sgmac_init(struct xgene_enet_pdata *p)
+{
+	u32 enet_spare_cfg_reg, rsif_config_reg;
+	u32 cfg_bypass_reg, rx_dv_gate_reg;
+	u32 data, offset;
+
+	xgene_sgmac_reset(p);
+	xgene_sgmii_enable_autoneg(p);
+	xgene_sgmac_set_speed(p);
+	xgene_sgmac_set_mac_addr(p);
 
 	if (p->enet_id == XGENE_ENET1) {
 		enet_spare_cfg_reg = ENET_SPARE_CFG_REG_ADDR;
 		rsif_config_reg = RSIF_CONFIG_REG_ADDR;
 		cfg_bypass_reg = CFG_BYPASS_ADDR;
-		rx_dv_gate_reg = SG_RX_DV_GATE_REG_0_ADDR;
+		offset = p->port_id * OFFSET_4;
+		rx_dv_gate_reg = SG_RX_DV_GATE_REG_0_ADDR + offset;
 	} else {
 		enet_spare_cfg_reg = XG_ENET_SPARE_CFG_REG_ADDR;
 		rsif_config_reg = XG_RSIF_CONFIG_REG_ADDR;
@@ -277,8 +372,6 @@ static void xgene_sgmac_init(struct xgene_enet_pdata *p)
 	data |= MPA_IDLE_WITH_QMI_EMPTY;
 	xgene_enet_wr_csr(p, enet_spare_cfg_reg, data);
 
-	xgene_sgmac_set_mac_addr(p);
-
 	/* Adjust MDC clock frequency */
 	data = xgene_enet_rd_mac(p, MII_MGMT_CONFIG_ADDR);
 	MGMT_CLOCK_SEL_SET(&data, 7);
@@ -292,7 +385,7 @@ static void xgene_sgmac_init(struct xgene_enet_pdata *p)
 	/* Bypass traffic gating */
 	xgene_enet_wr_csr(p, XG_ENET_SPARE_CFG_REG_1_ADDR, 0x84);
 	xgene_enet_wr_csr(p, cfg_bypass_reg, RESUME_TX);
-	xgene_enet_wr_mcx_csr(p, rx_dv_gate_reg + offset, RESUME_RX0);
+	xgene_enet_wr_mcx_csr(p, rx_dv_gate_reg, RESUME_RX0);
 }
 
 static void xgene_sgmac_rxtx(struct xgene_enet_pdata *p, u32 bits, bool set)
@@ -386,10 +479,11 @@ static void xgene_enet_link_state(struct work_struct *work)
 	if (link) {
 		if (!netif_carrier_ok(ndev)) {
 			netif_carrier_on(ndev);
-			xgene_sgmac_init(p);
+			xgene_sgmac_set_speed(p);
 			xgene_sgmac_rx_enable(p);
 			xgene_sgmac_tx_enable(p);
-			netdev_info(ndev, "Link is Up - 1Gbps\n");
+			netdev_info(ndev, "Link is Up - %dMbps\n",
+				    p->phy_speed);
 		}
 		poll_interval = PHY_POLL_LINK_ON;
 	} else {
@@ -412,6 +506,7 @@ const struct xgene_mac_ops xgene_sgmac_ops = {
 	.tx_enable	= xgene_sgmac_tx_enable,
 	.rx_disable	= xgene_sgmac_rx_disable,
 	.tx_disable	= xgene_sgmac_tx_disable,
+	.set_speed	= xgene_sgmac_set_speed,
 	.set_mac_addr	= xgene_sgmac_set_mac_addr,
 	.link_state	= xgene_enet_link_state
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
index 002df5a..32f140a 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
@@ -24,6 +24,7 @@
 #define PHY_ADDR(src)		(((src)<<8) & GENMASK(12, 8))
 #define REG_ADDR(src)		((src) & GENMASK(4, 0))
 #define PHY_CONTROL(src)	((src) & GENMASK(15, 0))
+#define LINK_SPEED(src)		(((src) & GENMASK(11, 10)) >> 10)
 #define INT_PHY_ADDR			0x1e
 #define SGMII_TBI_CONTROL_ADDR		0x44
 #define SGMII_CONTROL_ADDR		0x00
@@ -35,6 +36,12 @@
 #define MPA_IDLE_WITH_QMI_EMPTY		BIT(12)
 #define SG_RX_DV_GATE_REG_0_ADDR	0x05fc
 
+enum xgene_phy_speed {
+	PHY_SPEED_10,
+	PHY_SPEED_100,
+	PHY_SPEED_1000
+};
+
 extern const struct xgene_mac_ops xgene_sgmac_ops;
 extern const struct xgene_port_ops xgene_sgport_ops;
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
index 0a2dca8..f1ea485 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
@@ -65,9 +65,12 @@
 #define XG_CFG_LINK_AGGR_RESUME_0_ADDR	0x0214
 #define XG_LINK_STATUS_ADDR		0x0228
 #define XG_TSIF_MSS_REG0_ADDR		0x02a4
+#define XG_DEBUG_REG_ADDR		0x0400
 #define XG_ENET_SPARE_CFG_REG_ADDR	0x040c
 #define XG_ENET_SPARE_CFG_REG_1_ADDR	0x0410
 #define XGENET_RX_DV_GATE_REG_0_ADDR	0x0804
+#define XG_MCX_ICM_CONFIG0_REG_0_ADDR	0x00e0
+#define XG_MCX_ICM_CONFIG2_REG_0_ADDR	0x00e8
 
 extern const struct xgene_mac_ops xgene_xgmac_ops;
 extern const struct xgene_port_ops xgene_xgport_ops;
-- 
1.9.1
