From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 4/5] drivers: net: xgene: Add 10GbE support
Date: Tue, 23 Sep 2014 20:51:27 -0700
Message-ID: <1411530688-2939-5-git-send-email-isubramanian@apm.com>
References: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
Cc: kchudgar@apm.com, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og101.obsmtp.com ([64.18.0.141]:39978 "HELO
	exprod5og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752277AbaIXDvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 23:51:49 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so576422pab.0
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 20:51:47 -0700 (PDT)
In-Reply-To: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding 10GbE support to APM X-Gene SoC ethernet driver.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/Makefile           |   3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 123 +++++++-------
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  31 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  87 +++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  24 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 187 ++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |  64 ++++++++
 7 files changed, 422 insertions(+), 97 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h

diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
index c643e8a..589b352 100644
--- a/drivers/net/ethernet/apm/xgene/Makefile
+++ b/drivers/net/ethernet/apm/xgene/Makefile
@@ -2,5 +2,6 @@
 # Makefile for APM X-Gene Ethernet Driver.
 #
 
-xgene-enet-objs := xgene_enet_hw.o xgene_enet_main.o xgene_enet_ethtool.o
+xgene-enet-objs := xgene_enet_hw.o xgene_enet_xgmac.o \
+		   xgene_enet_main.o xgene_enet_ethtool.o
 obj-$(CONFIG_NET_XGENE) += xgene-enet.o
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 812d8d6..2795367 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -217,8 +217,7 @@ void xgene_enet_parse_error(struct xgene_enet_desc_ring *ring,
 	}
 }
 
-static void xgene_enet_wr_csr(struct xgene_enet_pdata *pdata,
-			      u32 offset, u32 val)
+void xgene_enet_wr_csr(struct xgene_enet_pdata *pdata, u32 offset, u32 val)
 {
 	void __iomem *addr = pdata->eth_csr_addr + offset;
 
@@ -244,7 +243,7 @@ static void xgene_enet_wr_diag_csr(struct xgene_enet_pdata *pdata,
 static void xgene_enet_wr_mcx_csr(struct xgene_enet_pdata *pdata,
 				  u32 offset, u32 val)
 {
-	void __iomem *addr = pdata->mcx_mac_csr_addr + offset;
+	void __iomem *addr = pdata->mac_csr_addr + offset;
 
 	iowrite32(val, addr);
 }
@@ -272,23 +271,21 @@ static bool xgene_enet_wr_indirect(void __iomem *addr, void __iomem *wr,
 	return true;
 }
 
-static void xgene_enet_wr_mcx_mac(struct xgene_enet_pdata *pdata,
-				  u32 wr_addr, u32 wr_data)
+void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata, u32 wr_addr, u32 wr_data)
 {
 	void __iomem *addr, *wr, *cmd, *cmd_done;
 
-	addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
-	wr = pdata->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
-	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
-	cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
+	addr = pdata->mac_addr + MAC_ADDR_REG_OFFSET;
+	wr = pdata->mac_addr + MAC_WRITE_REG_OFFSET;
+	cmd = pdata->mac_addr + MAC_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
 
 	if (!xgene_enet_wr_indirect(addr, wr, cmd, cmd_done, wr_addr, wr_data))
 		netdev_err(pdata->ndev, "MCX mac write failed, addr: %04x\n",
 			   wr_addr);
 }
 
-static void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata,
-			      u32 offset, u32 *val)
+void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata, u32 offset, u32 *val)
 {
 	void __iomem *addr = pdata->eth_csr_addr + offset;
 
@@ -306,7 +303,7 @@ static void xgene_enet_rd_diag_csr(struct xgene_enet_pdata *pdata,
 static void xgene_enet_rd_mcx_csr(struct xgene_enet_pdata *pdata,
 				  u32 offset, u32 *val)
 {
-	void __iomem *addr = pdata->mcx_mac_csr_addr + offset;
+	void __iomem *addr = pdata->mac_csr_addr + offset;
 
 	*val = ioread32(addr);
 }
@@ -334,15 +331,15 @@ static bool xgene_enet_rd_indirect(void __iomem *addr, void __iomem *rd,
 	return true;
 }
 
-static void xgene_enet_rd_mcx_mac(struct xgene_enet_pdata *pdata,
-				  u32 rd_addr, u32 *rd_data)
+void xgene_enet_rd_mac(struct xgene_enet_pdata *pdata,
+		       u32 rd_addr, u32 *rd_data)
 {
 	void __iomem *addr, *rd, *cmd, *cmd_done;
 
-	addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
-	rd = pdata->mcx_mac_addr + MAC_READ_REG_OFFSET;
-	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
-	cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
+	addr = pdata->mac_addr + MAC_ADDR_REG_OFFSET;
+	rd = pdata->mac_addr + MAC_READ_REG_OFFSET;
+	cmd = pdata->mac_addr + MAC_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
 
 	if (!xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data))
 		netdev_err(pdata->ndev, "MCX mac read failed, addr: %04x\n",
@@ -358,13 +355,13 @@ static int xgene_mii_phy_write(struct xgene_enet_pdata *pdata, int phy_id,
 
 	PHY_ADDR_SET(&addr, phy_id);
 	REG_ADDR_SET(&addr, reg);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
+	xgene_enet_wr_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
 
 	PHY_CONTROL_SET(&wr_data, data);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONTROL_ADDR, wr_data);
+	xgene_enet_wr_mac(pdata, MII_MGMT_CONTROL_ADDR, wr_data);
 	do {
 		usleep_range(5, 10);
-		xgene_enet_rd_mcx_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
+		xgene_enet_rd_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
 	} while ((done & BUSY_MASK) && wait--);
 
 	if (done & BUSY_MASK) {
@@ -384,11 +381,11 @@ static int xgene_mii_phy_read(struct xgene_enet_pdata *pdata,
 
 	PHY_ADDR_SET(&addr, phy_id);
 	REG_ADDR_SET(&addr, reg);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
+	xgene_enet_wr_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
+	xgene_enet_wr_mac(pdata, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
 	do {
 		usleep_range(5, 10);
-		xgene_enet_rd_mcx_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
+		xgene_enet_rd_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
 	} while ((done & BUSY_MASK) && wait--);
 
 	if (done & BUSY_MASK) {
@@ -396,8 +393,8 @@ static int xgene_mii_phy_read(struct xgene_enet_pdata *pdata,
 		return -EBUSY;
 	}
 
-	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_STATUS_ADDR, &data);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, 0);
+	xgene_enet_rd_mac(pdata, MII_MGMT_STATUS_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MII_MGMT_COMMAND_ADDR, 0);
 
 	return data;
 }
@@ -412,11 +409,11 @@ void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata)
 	addr1 = (dev_addr[5] << 24) | (dev_addr[4] << 16);
 	addr1 |= pdata->phy_addr & 0xFFFF;
 
-	xgene_enet_wr_mcx_mac(pdata, STATION_ADDR0_ADDR, addr0);
-	xgene_enet_wr_mcx_mac(pdata, STATION_ADDR1_ADDR, addr1);
+	xgene_enet_wr_mac(pdata, STATION_ADDR0_ADDR, addr0);
+	xgene_enet_wr_mac(pdata, STATION_ADDR1_ADDR, addr1);
 }
 
-static int xgene_enet_ecc_init(struct xgene_enet_pdata *pdata)
+int xgene_enet_ecc_init(struct xgene_enet_pdata *pdata)
 {
 	struct net_device *ndev = pdata->ndev;
 	u32 data;
@@ -438,11 +435,11 @@ static int xgene_enet_ecc_init(struct xgene_enet_pdata *pdata)
 
 void xgene_gmac_reset(struct xgene_enet_pdata *pdata)
 {
-	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, SOFT_RESET1);
-	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, 0);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, SOFT_RESET1);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, 0);
 }
 
-void xgene_gmac_init(struct xgene_enet_pdata *pdata, int speed)
+void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 {
 	u32 value, mc2;
 	u32 intf_ctl, rgmii;
@@ -452,11 +449,11 @@ void xgene_gmac_init(struct xgene_enet_pdata *pdata, int speed)
 
 	xgene_enet_rd_mcx_csr(pdata, ICM_CONFIG0_REG_0_ADDR, &icm0);
 	xgene_enet_rd_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, &icm2);
-	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_2_ADDR, &mc2);
-	xgene_enet_rd_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, &intf_ctl);
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_2_ADDR, &mc2);
+	xgene_enet_rd_mac(pdata, INTERFACE_CONTROL_ADDR, &intf_ctl);
 	xgene_enet_rd_csr(pdata, RGMII_REG_0_ADDR, &rgmii);
 
-	switch (speed) {
+	switch (pdata->phy_speed) {
 	case SPEED_10:
 		ENET_INTERFACE_MODE2_SET(&mc2, 1);
 		CFG_MACMODE_SET(&icm0, 0);
@@ -481,15 +478,15 @@ void xgene_gmac_init(struct xgene_enet_pdata *pdata, int speed)
 	}
 
 	mc2 |= FULL_DUPLEX2;
-	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_2_ADDR, mc2);
-	xgene_enet_wr_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, intf_ctl);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_2_ADDR, mc2);
+	xgene_enet_wr_mac(pdata, INTERFACE_CONTROL_ADDR, intf_ctl);
 
 	xgene_gmac_set_mac_addr(pdata);
 
 	/* Adjust MDC clock frequency */
-	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, &value);
+	xgene_enet_rd_mac(pdata, MII_MGMT_CONFIG_ADDR, &value);
 	MGMT_CLOCK_SEL_SET(&value, 7);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, value);
+	xgene_enet_wr_mac(pdata, MII_MGMT_CONFIG_ADDR, value);
 
 	/* Enable drop if bufpool not available */
 	xgene_enet_rd_csr(pdata, RSIF_CONFIG_REG_ADDR, &value);
@@ -515,10 +512,8 @@ void xgene_gmac_init(struct xgene_enet_pdata *pdata, int speed)
 	xgene_enet_wr_csr(pdata, CFG_BYPASS_ADDR, RESUME_TX);
 }
 
-static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata)
+void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata, u32 val)
 {
-	u32 val = 0xffffffff;
-
 	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQASSOC_ADDR, val);
 	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIFPQASSOC_ADDR, val);
 	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIQMLITEWQASSOC_ADDR, val);
@@ -548,32 +543,32 @@ void xgene_gmac_rx_enable(struct xgene_enet_pdata *pdata)
 {
 	u32 data;
 
-	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
-	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data | RX_EN);
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data | RX_EN);
 }
 
 void xgene_gmac_tx_enable(struct xgene_enet_pdata *pdata)
 {
 	u32 data;
 
-	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
-	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data | TX_EN);
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data | TX_EN);
 }
 
 void xgene_gmac_rx_disable(struct xgene_enet_pdata *pdata)
 {
 	u32 data;
 
-	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
-	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data & ~RX_EN);
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data & ~RX_EN);
 }
 
 void xgene_gmac_tx_disable(struct xgene_enet_pdata *pdata)
 {
 	u32 data;
 
-	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
-	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data & ~TX_EN);
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data & ~TX_EN);
 }
 
 void xgene_enet_reset(struct xgene_enet_pdata *pdata)
@@ -584,16 +579,16 @@ void xgene_enet_reset(struct xgene_enet_pdata *pdata)
 	clk_disable_unprepare(pdata->clk);
 	clk_prepare_enable(pdata->clk);
 	xgene_enet_ecc_init(pdata);
-	xgene_enet_config_ring_if_assoc(pdata);
+	xgene_enet_config_ring_if_assoc(pdata, 0xffffffff);
 
 	/* Enable auto-incr for scanning */
-	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, &val);
+	xgene_enet_rd_mac(pdata, MII_MGMT_CONFIG_ADDR, &val);
 	val |= SCAN_AUTO_INCR;
 	MGMT_CLOCK_SEL_SET(&val, 1);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, val);
+	xgene_enet_wr_mac(pdata, MII_MGMT_CONFIG_ADDR, val);
 }
 
-void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
+void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
 {
 	clk_disable_unprepare(pdata->clk);
 }
@@ -627,10 +622,10 @@ static void xgene_enet_adjust_link(struct net_device *ndev)
 
 	if (phydev->link) {
 		if (pdata->phy_speed != phydev->speed) {
-			xgene_gmac_init(pdata, phydev->speed);
+			pdata->phy_speed = phydev->speed;
+			xgene_gmac_init(pdata);
 			xgene_gmac_rx_enable(pdata);
 			xgene_gmac_tx_enable(pdata);
-			pdata->phy_speed = phydev->speed;
 			phy_print_status(phydev);
 		}
 	} else {
@@ -726,3 +721,19 @@ void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
 	mdiobus_free(pdata->mdio_bus);
 	pdata->mdio_bus = NULL;
 }
+
+struct xgene_mac_ops xgene_gmac_ops = {
+	.init = xgene_gmac_init,
+	.reset = xgene_gmac_reset,
+	.rx_enable = xgene_gmac_rx_enable,
+	.tx_enable = xgene_gmac_tx_enable,
+	.rx_disable = xgene_gmac_rx_disable,
+	.tx_disable = xgene_gmac_tx_disable,
+	.set_mac_addr = xgene_gmac_set_mac_addr,
+};
+
+struct xgene_port_ops xgene_gport_ops = {
+	.reset = xgene_enet_reset,
+	.cle_bypass = xgene_enet_cle_bypass,
+	.shutdown = xgene_enet_shutdown,
+};
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 371e7a5..1187de0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -42,6 +42,11 @@ static inline u32 xgene_get_bits(u32 val, u32 start, u32 end)
 	return (val & GENMASK(end, start)) >> start;
 }
 
+enum xgene_enet_ring_manager {
+	RM0,
+	RM3 = 3
+};
+
 #define CSR_RING_ID		0x0008
 #define OVERWRITE		BIT(31)
 #define IS_BUFFER_POOL		BIT(20)
@@ -52,7 +57,6 @@ static inline u32 xgene_get_bits(u32 val, u32 start, u32 end)
 #define CSR_RING_WR_BASE	0x0070
 #define NUM_RING_CONFIG		5
 #define BUFPOOL_MODE		3
-#define RM3			3
 #define INC_DEC_CMD_ADDR	0x002c
 #define UDP_HDR_SIZE		2
 #define BUF_LEN_CODE_2K		0x5000
@@ -318,20 +322,21 @@ void xgene_enet_parse_error(struct xgene_enet_desc_ring *ring,
 			    struct xgene_enet_pdata *pdata,
 			    enum xgene_enet_err_code status);
 
-void xgene_enet_reset(struct xgene_enet_pdata *priv);
-void xgene_gmac_reset(struct xgene_enet_pdata *priv);
-void xgene_gmac_init(struct xgene_enet_pdata *priv, int speed);
-void xgene_gmac_tx_enable(struct xgene_enet_pdata *priv);
-void xgene_gmac_rx_enable(struct xgene_enet_pdata *priv);
-void xgene_gmac_tx_disable(struct xgene_enet_pdata *priv);
-void xgene_gmac_rx_disable(struct xgene_enet_pdata *priv);
-void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata);
-void xgene_enet_cle_bypass(struct xgene_enet_pdata *pdata,
-			   u32 dst_ring_num, u16 bufpool_id);
-void xgene_gport_shutdown(struct xgene_enet_pdata *priv);
-void xgene_gmac_get_tx_stats(struct xgene_enet_pdata *pdata);
+void xgene_enet_wr_csr(struct xgene_enet_pdata *pdata,
+		       u32 offset, u32 val);
+void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata,
+		       u32 offset, u32 *val);
+void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata,
+		       u32 wr_addr, u32 wr_data);
+void xgene_enet_rd_mac(struct xgene_enet_pdata *pdata,
+		       u32 rd_addr, u32 *rd_data);
+int xgene_enet_ecc_init(struct xgene_enet_pdata *pdata);
+void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata, u32 val);
 
 int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata);
 void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata);
 
+extern struct xgene_mac_ops xgene_gmac_ops;
+extern struct xgene_port_ops xgene_gport_ops;
+
 #endif /* __XGENE_ENET_HW_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index e4222af..090bbcd 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -21,6 +21,7 @@
 
 #include "xgene_enet_main.h"
 #include "xgene_enet_hw.h"
+#include "xgene_enet_xgmac.h"
 
 static void xgene_enet_init_bufpool(struct xgene_enet_desc_ring *buf_pool)
 {
@@ -390,7 +391,7 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 		}
 	}
 
-	return budget;
+	return count;
 }
 
 static int xgene_enet_napi(struct napi_struct *napi, const int budget)
@@ -413,7 +414,7 @@ static void xgene_enet_timeout(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 
-	xgene_gmac_reset(pdata);
+	pdata->mac_ops->reset(pdata);
 }
 
 static int xgene_enet_register_irq(struct net_device *ndev)
@@ -445,18 +446,21 @@ static void xgene_enet_free_irq(struct net_device *ndev)
 static int xgene_enet_open(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 	int ret;
 
-	xgene_gmac_tx_enable(pdata);
-	xgene_gmac_rx_enable(pdata);
+	mac_ops->tx_enable(pdata);
+	mac_ops->rx_enable(pdata);
 
 	ret = xgene_enet_register_irq(ndev);
 	if (ret)
 		return ret;
 	napi_enable(&pdata->rx_ring->napi);
 
-	if (pdata->phy_dev)
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		phy_start(pdata->phy_dev);
+	else
+		schedule_delayed_work(&pdata->link_work, PHY_POLL_LINK_OFF);
 
 	netif_start_queue(ndev);
 
@@ -466,18 +470,21 @@ static int xgene_enet_open(struct net_device *ndev)
 static int xgene_enet_close(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 
 	netif_stop_queue(ndev);
 
-	if (pdata->phy_dev)
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		phy_stop(pdata->phy_dev);
+	else
+		cancel_delayed_work_sync(&pdata->link_work);
 
 	napi_disable(&pdata->rx_ring->napi);
 	xgene_enet_free_irq(ndev);
 	xgene_enet_process_ring(pdata->rx_ring, -1);
 
-	xgene_gmac_tx_disable(pdata);
-	xgene_gmac_rx_disable(pdata);
+	mac_ops->tx_disable(pdata);
+	mac_ops->rx_disable(pdata);
 
 	return 0;
 }
@@ -613,7 +620,6 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
 
 	ring->cmd_base = pdata->ring_cmd_addr + (ring->num << 6);
 	ring->cmd = ring->cmd_base + INC_DEC_CMD_ADDR;
-	pdata->rm = RM3;
 	ring = xgene_enet_setup_ring(ring);
 	netdev_dbg(ndev, "ring info: num=%d  size=%d  id=%d  slots=%d\n",
 		   ring->num, ring->size, ring->id, ring->slots);
@@ -724,7 +730,7 @@ static int xgene_enet_set_mac_address(struct net_device *ndev, void *addr)
 	ret = eth_mac_addr(ndev, addr);
 	if (ret)
 		return ret;
-	xgene_gmac_set_mac_addr(pdata);
+	pdata->mac_ops->set_mac_addr(pdata);
 
 	return ret;
 }
@@ -803,8 +809,13 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 
 	pdata->phy_mode = of_get_phy_mode(pdev->dev.of_node);
 	if (pdata->phy_mode < 0) {
-		dev_err(dev, "Incorrect phy-connection-type in DTS\n");
-		return -EINVAL;
+		dev_err(dev, "Unable to get phy-connection-type\n");
+		return pdata->phy_mode;
+	}
+	if (pdata->phy_mode != PHY_INTERFACE_MODE_RGMII &&
+	    pdata->phy_mode != PHY_INTERFACE_MODE_XGMII) {
+		dev_err(dev, "Incorrect phy-connection-type specified\n");
+		return -ENODEV;
 	}
 
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
@@ -819,12 +830,19 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	pdata->eth_csr_addr = base_addr + BLOCK_ETH_CSR_OFFSET;
 	pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
 	pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
-	pdata->mcx_mac_addr = base_addr + BLOCK_ETH_MAC_OFFSET;
-	pdata->mcx_stats_addr = base_addr + BLOCK_ETH_STATS_OFFSET;
-	pdata->mcx_mac_csr_addr = base_addr + BLOCK_ETH_MAC_CSR_OFFSET;
 	pdata->rx_buff_cnt = NUM_PKT_BUF;
 
-	return ret;
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+		pdata->mac_addr = base_addr + BLOCK_ETH_MAC_OFFSET;
+		pdata->mac_csr_addr = base_addr + BLOCK_ETH_MAC_CSR_OFFSET;
+		pdata->rm = RM3;
+	} else {
+		pdata->mac_addr = base_addr + BLOCK_AXG_MAC_OFFSET;
+		pdata->mac_csr_addr = base_addr + BLOCK_AXG_MAC_CSR_OFFSET;
+		pdata->rm = RM0;
+	}
+
+	return 0;
 }
 
 static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
@@ -834,8 +852,7 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 	u16 dst_ring_num;
 	int ret;
 
-	xgene_gmac_tx_disable(pdata);
-	xgene_gmac_rx_disable(pdata);
+	pdata->port_ops->reset(pdata);
 
 	ret = xgene_enet_create_desc_rings(ndev);
 	if (ret) {
@@ -853,11 +870,26 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 	}
 
 	dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring);
-	xgene_enet_cle_bypass(pdata, dst_ring_num, buf_pool->id);
+	pdata->port_ops->cle_bypass(pdata, dst_ring_num, buf_pool->id);
+	pdata->mac_ops->init(pdata);
 
 	return ret;
 }
 
+static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
+{
+	switch (pdata->phy_mode) {
+	case PHY_INTERFACE_MODE_RGMII:
+		pdata->mac_ops = &xgene_gmac_ops;
+		pdata->port_ops = &xgene_gport_ops;
+		break;
+	default:
+		pdata->mac_ops = &xgene_xgmac_ops;
+		pdata->port_ops = &xgene_xgport_ops;
+		break;
+	}
+}
+
 static int xgene_enet_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
@@ -886,8 +918,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	if (ret)
 		goto err;
 
-	xgene_enet_reset(pdata);
-	xgene_gmac_init(pdata, SPEED_1000);
+	xgene_enet_setup_ops(pdata);
 
 	ret = register_netdev(ndev);
 	if (ret) {
@@ -907,7 +938,10 @@ static int xgene_enet_probe(struct platform_device *pdev)
 
 	napi = &pdata->rx_ring->napi;
 	netif_napi_add(ndev, napi, xgene_enet_napi, NAPI_POLL_WEIGHT);
-	ret = xgene_enet_mdio_config(pdata);
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+		ret = xgene_enet_mdio_config(pdata);
+	else
+		INIT_DELAYED_WORK(&pdata->link_work, xgene_enet_link_state);
 
 	return ret;
 err:
@@ -918,19 +952,21 @@ err:
 static int xgene_enet_remove(struct platform_device *pdev)
 {
 	struct xgene_enet_pdata *pdata;
+	struct xgene_mac_ops *mac_ops;
 	struct net_device *ndev;
 
 	pdata = platform_get_drvdata(pdev);
+	mac_ops = pdata->mac_ops;
 	ndev = pdata->ndev;
 
-	xgene_gmac_rx_disable(pdata);
-	xgene_gmac_tx_disable(pdata);
+	mac_ops->rx_disable(pdata);
+	mac_ops->tx_disable(pdata);
 
 	netif_napi_del(&pdata->rx_ring->napi);
 	xgene_enet_mdio_remove(pdata);
 	xgene_enet_delete_desc_rings(pdata);
 	unregister_netdev(ndev);
-	xgene_gport_shutdown(pdata);
+	pdata->port_ops->shutdown(pdata);
 	free_netdev(ndev);
 
 	return 0;
@@ -956,5 +992,6 @@ module_platform_driver(xgene_enet_driver);
 
 MODULE_DESCRIPTION("APM X-Gene SoC Ethernet driver");
 MODULE_VERSION(XGENE_DRV_VERSION);
+MODULE_AUTHOR("Iyappan Subramanian <isubramanian@apm.com>");
 MODULE_AUTHOR("Keyur Chudgar <kchudgar@apm.com>");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 0815866..567ca6e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -68,6 +68,23 @@ struct xgene_enet_desc_ring {
 	};
 };
 
+struct xgene_mac_ops {
+	void (*init)(struct xgene_enet_pdata *pdata);
+	void (*reset)(struct xgene_enet_pdata *pdata);
+	void (*tx_enable)(struct xgene_enet_pdata *pdata);
+	void (*rx_enable)(struct xgene_enet_pdata *pdata);
+	void (*tx_disable)(struct xgene_enet_pdata *pdata);
+	void (*rx_disable)(struct xgene_enet_pdata *pdata);
+	void (*set_mac_addr)(struct xgene_enet_pdata *pdata);
+};
+
+struct xgene_port_ops {
+	void (*reset)(struct xgene_enet_pdata *pdata);
+	void (*cle_bypass)(struct xgene_enet_pdata *pdata,
+			   u32 dst_ring_num, u16 bufpool_id);
+	void (*shutdown)(struct xgene_enet_pdata *pdata);
+};
+
 /* ethernet private data */
 struct xgene_enet_pdata {
 	struct net_device *ndev;
@@ -87,9 +104,9 @@ struct xgene_enet_pdata {
 	void __iomem *eth_csr_addr;
 	void __iomem *eth_ring_if_addr;
 	void __iomem *eth_diag_csr_addr;
-	void __iomem *mcx_mac_addr;
+	void __iomem *mac_addr;
 	void __iomem *mcx_stats_addr;
-	void __iomem *mcx_mac_csr_addr;
+	void __iomem *mac_csr_addr;
 	void __iomem *base_addr;
 	void __iomem *ring_csr_addr;
 	void __iomem *ring_cmd_addr;
@@ -98,6 +115,9 @@ struct xgene_enet_pdata {
 	u32 speed;
 	u16 rm;
 	struct rtnl_link_stats64 stats;
+	struct xgene_mac_ops *mac_ops;
+	struct xgene_port_ops *port_ops;
+	struct delayed_work link_work;
 };
 
 /* Set the specified value into a bit-field defined by its starting position
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
new file mode 100644
index 0000000..219bb7e
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -0,0 +1,187 @@
+/* Applied Micro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2014, Applied Micro Circuits Corporation
+ * Authors: Iyappan Subramanian <isubramanian@apm.com>
+ *	    Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "xgene_enet_main.h"
+#include "xgene_enet_hw.h"
+#include "xgene_enet_xgmac.h"
+
+static void xgene_xgmac_reset(struct xgene_enet_pdata *pdata)
+{
+	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_0, HSTMACRST);
+	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_0, 0);
+}
+
+static void xgene_xgmac_set_mac_addr(struct xgene_enet_pdata *pdata)
+{
+	u32 addr0, addr1;
+	u8 *dev_addr = pdata->ndev->dev_addr;
+
+	addr0 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
+		(dev_addr[1] << 8) | dev_addr[0];
+	addr1 = (dev_addr[5] << 24) | (dev_addr[4] << 16);
+
+	xgene_enet_wr_mac(pdata, HSTMACADR_LSW_ADDR, addr0);
+	xgene_enet_wr_mac(pdata, HSTMACADR_MSW_ADDR, addr1);
+}
+
+static u32 xgene_enet_link_status(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_csr(pdata, XG_LINK_STATUS_ADDR, &data);
+
+	return data;
+}
+
+static void xgene_xgmac_init(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_xgmac_reset(pdata);
+
+	xgene_enet_rd_mac(pdata, AXGMAC_CONFIG_1, &data);
+	data |= HSTPPEN;
+	data &= ~HSTLENCHK;
+	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_1, data);
+
+	xgene_enet_wr_mac(pdata, HSTMAXFRAME_LENGTH_ADDR, 0x06000600);
+	xgene_xgmac_set_mac_addr(pdata);
+
+	xgene_enet_rd_csr(pdata, XG_RSIF_CONFIG_REG_ADDR, &data);
+	data |= CFG_RSIF_FPBUFF_TIMEOUT_EN;
+	xgene_enet_wr_csr(pdata, XG_RSIF_CONFIG_REG_ADDR, data);
+
+	xgene_enet_wr_csr(pdata, XG_CFG_BYPASS_ADDR, RESUME_TX);
+	xgene_enet_wr_csr(pdata, XGENET_RX_DV_GATE_REG_0_ADDR, 0);
+	xgene_enet_rd_csr(pdata, XG_ENET_SPARE_CFG_REG_ADDR, &data);
+	data |= BIT(12);
+	xgene_enet_wr_csr(pdata, XG_ENET_SPARE_CFG_REG_ADDR, data);
+	xgene_enet_wr_csr(pdata, XG_ENET_SPARE_CFG_REG_1_ADDR, 0x82);
+}
+
+static void xgene_xgmac_rx_enable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mac(pdata, AXGMAC_CONFIG_1, &data);
+	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_1, data | HSTRFEN);
+}
+
+static void xgene_xgmac_tx_enable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mac(pdata, AXGMAC_CONFIG_1, &data);
+	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_1, data | HSTTFEN);
+}
+
+static void xgene_xgmac_rx_disable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mac(pdata, AXGMAC_CONFIG_1, &data);
+	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_1, data & ~HSTRFEN);
+}
+
+static void xgene_xgmac_tx_disable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mac(pdata, AXGMAC_CONFIG_1, &data);
+	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_1, data & ~HSTTFEN);
+}
+
+static void xgene_enet_reset(struct xgene_enet_pdata *pdata)
+{
+	clk_prepare_enable(pdata->clk);
+	clk_disable_unprepare(pdata->clk);
+	clk_prepare_enable(pdata->clk);
+
+	xgene_enet_ecc_init(pdata);
+	xgene_enet_config_ring_if_assoc(pdata, 0);
+}
+
+static void xgene_enet_xgcle_bypass(struct xgene_enet_pdata *pdata,
+				    u32 dst_ring_num, u16 bufpool_id)
+{
+	u32 cb, fpsel;
+
+	xgene_enet_rd_csr(pdata, XCLE_BYPASS_REG0_ADDR, &cb);
+	cb |= CFG_CLE_BYPASS_EN0;
+	CFG_CLE_IP_PROTOCOL0_SET(&cb, 3);
+	xgene_enet_wr_csr(pdata, XCLE_BYPASS_REG0_ADDR, cb);
+
+	fpsel = xgene_enet_ring_bufnum(bufpool_id) - 0x20;
+	xgene_enet_rd_csr(pdata, XCLE_BYPASS_REG1_ADDR, &cb);
+	CFG_CLE_DSTQID0_SET(&cb, dst_ring_num);
+	CFG_CLE_FPSEL0_SET(&cb, fpsel);
+	xgene_enet_wr_csr(pdata, XCLE_BYPASS_REG1_ADDR, cb);
+}
+
+static void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
+{
+	clk_disable_unprepare(pdata->clk);
+}
+
+void xgene_enet_link_state(struct work_struct *work)
+{
+	struct xgene_enet_pdata *pdata = container_of(to_delayed_work(work),
+					 struct xgene_enet_pdata, link_work);
+	struct net_device *ndev = pdata->ndev;
+	u32 link_status, poll_interval;
+
+	link_status = xgene_enet_link_status(pdata);
+	if (link_status) {
+		if (!netif_carrier_ok(ndev)) {
+			netif_carrier_on(ndev);
+			xgene_xgmac_init(pdata);
+			xgene_xgmac_rx_enable(pdata);
+			xgene_xgmac_tx_enable(pdata);
+			netdev_info(ndev, "Link is Up - 10Gbps\n");
+		}
+		poll_interval = PHY_POLL_LINK_ON;
+	} else {
+		if (netif_carrier_ok(ndev)) {
+			xgene_xgmac_rx_disable(pdata);
+			xgene_xgmac_tx_disable(pdata);
+			netif_carrier_off(ndev);
+			netdev_info(ndev, "Link is Down\n");
+		}
+		poll_interval = PHY_POLL_LINK_OFF;
+	}
+
+	schedule_delayed_work(&pdata->link_work, poll_interval);
+}
+
+struct xgene_mac_ops xgene_xgmac_ops = {
+	.init = xgene_xgmac_init,
+	.reset = xgene_xgmac_reset,
+	.rx_enable = xgene_xgmac_rx_enable,
+	.tx_enable = xgene_xgmac_tx_enable,
+	.rx_disable = xgene_xgmac_rx_disable,
+	.tx_disable = xgene_xgmac_tx_disable,
+	.set_mac_addr = xgene_xgmac_set_mac_addr,
+};
+
+struct xgene_port_ops xgene_xgport_ops = {
+	.reset = xgene_enet_reset,
+	.cle_bypass = xgene_enet_xgcle_bypass,
+	.shutdown = xgene_enet_shutdown,
+};
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
new file mode 100644
index 0000000..b6cc0fe
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
@@ -0,0 +1,64 @@
+/* Applied Micro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2014, Applied Micro Circuits Corporation
+ * Authors: Iyappan Subramanian <isubramanian@apm.com>
+ *	    Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __XGENE_ENET_XGMAC_H__
+#define __XGENE_ENET_XGMAC_H__
+
+#define BLOCK_AXG_MAC_OFFSET		0x0800
+#define BLOCK_AXG_MAC_CSR_OFFSET	0x2000
+
+#define AXGMAC_CONFIG_0			0x0000
+#define AXGMAC_CONFIG_1			0x0004
+#define HSTMACRST			BIT(31)
+#define HSTTCTLEN			BIT(31)
+#define HSTTFEN				BIT(30)
+#define HSTRCTLEN			BIT(29)
+#define HSTRFEN				BIT(28)
+#define HSTPPEN				BIT(7)
+#define HSTDRPLT64			BIT(5)
+#define HSTLENCHK			BIT(3)
+#define HSTMACADR_LSW_ADDR		0x0010
+#define HSTMACADR_MSW_ADDR		0x0014
+#define HSTMAXFRAME_LENGTH_ADDR		0x0020
+
+#define XGENET_SRST_ADDR		0x0000
+#define XGENET_CLKEN_ADDR		0x0008
+#define CSR_CLK				BIT(0)
+#define XGENET_CLK			BIT(1)
+#define CSR_RST				BIT(0)
+#define XGENET_RST			BIT(1)
+
+#define XG_RSIF_CONFIG_REG_ADDR		0x00a0
+#define XCLE_BYPASS_REG0_ADDR           0x0160
+#define XCLE_BYPASS_REG1_ADDR           0x0164
+#define XG_CFG_BYPASS_ADDR		0x0204
+#define XG_LINK_STATUS_ADDR		0x0228
+#define XG_ENET_SPARE_CFG_REG_ADDR	0x040c
+#define XG_ENET_SPARE_CFG_REG_1_ADDR	0x0410
+#define XGENET_RX_DV_GATE_REG_0_ADDR	0x0804
+
+#define PHY_POLL_LINK_ON	(10 * HZ)
+#define PHY_POLL_LINK_OFF	(PHY_POLL_LINK_ON / 5)
+
+void xgene_enet_link_state(struct work_struct *work);
+extern struct xgene_mac_ops xgene_xgmac_ops;
+extern struct xgene_port_ops xgene_xgport_ops;
+
+#endif /* __XGENE_ENET_XGMAC_H__ */
-- 
1.9.1
