From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v1 2/3] drivers: net: xgene: Add SGMII based 1GbE support
Date: Fri, 10 Oct 2014 13:18:35 -0700
Message-ID: <1412972316-16344-3-git-send-email-isubramanian@apm.com>
References: <1412972316-16344-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	kchudgar-qTEPVZfXA3Y@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1412972316-16344-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/Makefile           |   2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |   1 -
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |   2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  24 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |   5 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 407 ++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |  41 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |   3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |   4 -
 9 files changed, 473 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h

diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
index 589b352..68be5655 100644
--- a/drivers/net/ethernet/apm/xgene/Makefile
+++ b/drivers/net/ethernet/apm/xgene/Makefile
@@ -2,6 +2,6 @@
 # Makefile for APM X-Gene Ethernet Driver.
 #
 
-xgene-enet-objs := xgene_enet_hw.o xgene_enet_xgmac.o \
+xgene-enet-objs := xgene_enet_hw.o xgene_enet_sgmac.o xgene_enet_xgmac.o \
 		   xgene_enet_main.o xgene_enet_ethtool.o
 obj-$(CONFIG_NET_XGENE) += xgene-enet.o
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index c8f3824..63ea194 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -410,7 +410,6 @@ static void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata)
 	addr0 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
 		(dev_addr[1] << 8) | dev_addr[0];
 	addr1 = (dev_addr[5] << 24) | (dev_addr[4] << 16);
-	addr1 |= pdata->phy_addr & 0xFFFF;
 
 	xgene_enet_wr_mcx_mac(pdata, STATION_ADDR0_ADDR, addr0);
 	xgene_enet_wr_mcx_mac(pdata, STATION_ADDR1_ADDR, addr1);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 15ec426..dc024c1 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -44,6 +44,7 @@ static inline u32 xgene_get_bits(u32 val, u32 start, u32 end)
 
 enum xgene_enet_rm {
 	RM0,
+	RM1,
 	RM3 = 3
 };
 
@@ -179,7 +180,6 @@ enum xgene_enet_rm {
 #define TUND_ADDR			0x4a
 
 #define TSO_IPPROTO_TCP			1
-#define	FULL_DUPLEX			2
 
 #define USERINFO_POS			0
 #define USERINFO_LEN			32
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 9b85239..743eccf 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -21,6 +21,7 @@
 
 #include "xgene_enet_main.h"
 #include "xgene_enet_hw.h"
+#include "xgene_enet_sgmac.h"
 #include "xgene_enet_xgmac.h"
 
 static void xgene_enet_init_bufpool(struct xgene_enet_desc_ring *buf_pool)
@@ -813,6 +814,7 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 		return pdata->phy_mode;
 	}
 	if (pdata->phy_mode != PHY_INTERFACE_MODE_RGMII &&
+	    pdata->phy_mode != PHY_INTERFACE_MODE_SGMII &&
 	    pdata->phy_mode != PHY_INTERFACE_MODE_XGMII) {
 		dev_err(dev, "Incorrect phy-connection-type specified\n");
 		return -ENODEV;
@@ -830,14 +832,12 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	pdata->eth_csr_addr = base_addr + BLOCK_ETH_CSR_OFFSET;
 	pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
 	pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
-		pdata->mcx_mac_addr = base_addr + BLOCK_ETH_MAC_OFFSET;
-		pdata->mcx_mac_csr_addr = base_addr + BLOCK_ETH_MAC_CSR_OFFSET;
-		pdata->rm = RM3;
-	} else {
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
 		pdata->mcx_mac_addr = base_addr + BLOCK_AXG_MAC_OFFSET;
 		pdata->mcx_mac_csr_addr = base_addr + BLOCK_AXG_MAC_CSR_OFFSET;
-		pdata->rm = RM0;
+	} else {
+		pdata->mcx_mac_addr = base_addr + BLOCK_ETH_MAC_OFFSET;
+		pdata->mcx_mac_csr_addr = base_addr + BLOCK_ETH_MAC_CSR_OFFSET;
 	}
 	pdata->rx_buff_cnt = NUM_PKT_BUF;
 
@@ -881,10 +881,17 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 	case PHY_INTERFACE_MODE_RGMII:
 		pdata->mac_ops = &xgene_gmac_ops;
 		pdata->port_ops = &xgene_gport_ops;
+		pdata->rm = RM3;
+		break;
+	case PHY_INTERFACE_MODE_SGMII:
+		pdata->mac_ops = &xgene_sgmac_ops;
+		pdata->port_ops = &xgene_sgport_ops;
+		pdata->rm = RM1;
 		break;
 	default:
 		pdata->mac_ops = &xgene_xgmac_ops;
 		pdata->port_ops = &xgene_xgport_ops;
+		pdata->rm = RM0;
 		break;
 	}
 }
@@ -895,6 +902,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	struct xgene_enet_pdata *pdata;
 	struct device *dev = &pdev->dev;
 	struct napi_struct *napi;
+	struct xgene_mac_ops *mac_ops;
 	int ret;
 
 	ndev = alloc_etherdev(sizeof(struct xgene_enet_pdata));
@@ -937,10 +945,12 @@ static int xgene_enet_probe(struct platform_device *pdev)
 
 	napi = &pdata->rx_ring->napi;
 	netif_napi_add(ndev, napi, xgene_enet_napi, NAPI_POLL_WEIGHT);
+
+	mac_ops = pdata->mac_ops;
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		ret = xgene_enet_mdio_config(pdata);
 	else
-		INIT_DELAYED_WORK(&pdata->link_work, xgene_enet_link_state);
+		INIT_DELAYED_WORK(&pdata->link_work, mac_ops->link_state);
 
 	return ret;
 err:
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 86cf68b..1057181 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -39,6 +39,9 @@
 #define NUM_PKT_BUF	64
 #define NUM_BUFPOOL	32
 
+#define PHY_POLL_LINK_ON	(10 * HZ)
+#define PHY_POLL_LINK_OFF	(PHY_POLL_LINK_ON / 5)
+
 /* software context of a descriptor ring */
 struct xgene_enet_desc_ring {
 	struct net_device *ndev;
@@ -76,6 +79,7 @@ struct xgene_mac_ops {
 	void (*tx_disable)(struct xgene_enet_pdata *pdata);
 	void (*rx_disable)(struct xgene_enet_pdata *pdata);
 	void (*set_mac_addr)(struct xgene_enet_pdata *pdata);
+	void (*link_state)(struct work_struct *work);
 };
 
 struct xgene_port_ops {
@@ -109,7 +113,6 @@ struct xgene_enet_pdata {
 	void __iomem *base_addr;
 	void __iomem *ring_csr_addr;
 	void __iomem *ring_cmd_addr;
-	u32 phy_addr;
 	int phy_mode;
 	enum xgene_enet_rm rm;
 	struct rtnl_link_stats64 stats;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
new file mode 100644
index 0000000..6038596
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -0,0 +1,407 @@
+/* Applied Micro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2014, Applied Micro Circuits Corporation
+ * Authors: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
+ *	    Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
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
+#include "xgene_enet_sgmac.h"
+
+static void xgene_enet_wr_csr(struct xgene_enet_pdata *pdata,
+			      u32 offset, u32 val)
+{
+	void __iomem *addr = pdata->eth_csr_addr + offset;
+
+	iowrite32(val, addr);
+}
+
+static void xgene_enet_wr_ring_if(struct xgene_enet_pdata *pdata,
+				  u32 offset, u32 val)
+{
+	void __iomem *addr = pdata->eth_ring_if_addr + offset;
+
+	iowrite32(val, addr);
+}
+
+static void xgene_enet_wr_diag_csr(struct xgene_enet_pdata *pdata,
+				   u32 offset, u32 val)
+{
+	void __iomem *addr = pdata->eth_diag_csr_addr + offset;
+
+	iowrite32(val, addr);
+}
+
+static bool xgene_enet_wr_indirect(void __iomem *addr, void __iomem *wr,
+				   void __iomem *cmd, void __iomem *cmd_done,
+				   u32 wr_addr, u32 wr_data)
+{
+	u32 done;
+	u8 wait = 10;
+
+	iowrite32(wr_addr, addr);
+	iowrite32(wr_data, wr);
+	iowrite32(XGENE_ENET_WR_CMD, cmd);
+
+	/* wait for write command to complete */
+	while (!(done = ioread32(cmd_done)) && wait--)
+		udelay(1);
+
+	if (!done)
+		return false;
+
+	iowrite32(0, cmd);
+
+	return true;
+}
+
+static void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata,
+			      u32 wr_addr, u32 wr_data)
+{
+	void __iomem *addr, *wr, *cmd, *cmd_done;
+
+	addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
+	wr = pdata->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
+	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
+
+	if (!xgene_enet_wr_indirect(addr, wr, cmd, cmd_done, wr_addr, wr_data))
+		netdev_err(pdata->ndev, "MCX mac write failed, addr: %04x\n",
+			   wr_addr);
+}
+
+static void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata,
+			      u32 offset, u32 *val)
+{
+	void __iomem *addr = pdata->eth_csr_addr + offset;
+
+	*val = ioread32(addr);
+}
+
+static void xgene_enet_rd_diag_csr(struct xgene_enet_pdata *pdata,
+				   u32 offset, u32 *val)
+{
+	void __iomem *addr = pdata->eth_diag_csr_addr + offset;
+
+	*val = ioread32(addr);
+}
+
+static bool xgene_enet_rd_indirect(void __iomem *addr, void __iomem *rd,
+				   void __iomem *cmd, void __iomem *cmd_done,
+				   u32 rd_addr, u32 *rd_data)
+{
+	u32 done;
+	u8 wait = 10;
+
+	iowrite32(rd_addr, addr);
+	iowrite32(XGENE_ENET_RD_CMD, cmd);
+
+	/* wait for read command to complete */
+	while (!(done = ioread32(cmd_done)) && wait--)
+		udelay(1);
+
+	if (!done)
+		return false;
+
+	*rd_data = ioread32(rd);
+	iowrite32(0, cmd);
+
+	return true;
+}
+
+static void xgene_enet_rd_mac(struct xgene_enet_pdata *pdata,
+			      u32 rd_addr, u32 *rd_data)
+{
+	void __iomem *addr, *rd, *cmd, *cmd_done;
+
+	addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
+	rd = pdata->mcx_mac_addr + MAC_READ_REG_OFFSET;
+	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
+
+	if (!xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data))
+		netdev_err(pdata->ndev, "MCX mac read failed, addr: %04x\n",
+			   rd_addr);
+}
+
+static int xgene_enet_ecc_init(struct xgene_enet_pdata *pdata)
+{
+	struct net_device *ndev = pdata->ndev;
+	u32 data;
+	u8 wait = 10;
+
+	xgene_enet_wr_diag_csr(pdata, ENET_CFG_MEM_RAM_SHUTDOWN_ADDR, 0x0);
+	do {
+		usleep_range(100, 110);
+		xgene_enet_rd_diag_csr(pdata, ENET_BLOCK_MEM_RDY_ADDR, &data);
+	} while ((data != 0xffffffff) && wait--);
+
+	if (data != 0xffffffff) {
+		netdev_err(ndev, "Failed to release memory from shutdown\n");
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata)
+{
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQASSOC_ADDR, 0xffffffff);
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIFPQASSOC_ADDR, 0xffffffff);
+}
+
+static void xgene_mii_phy_write(struct xgene_enet_pdata *pdata, u8 phy_id,
+				u32 reg, u16 data)
+{
+	u32 addr, wr_data, done;
+	u8 wait = 10;
+
+	addr = PHY_ADDR(phy_id) | REG_ADDR(reg);
+	xgene_enet_wr_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
+
+	wr_data = PHY_CONTROL(data);
+	xgene_enet_wr_mac(pdata, MII_MGMT_CONTROL_ADDR, wr_data);
+
+	while (wait--) {
+		xgene_enet_rd_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
+		if (!(done & BUSY_MASK))
+			break;
+		usleep_range(10, 20);
+	}
+	if (done & BUSY_MASK)
+		netdev_err(pdata->ndev, "MII_MGMT write failed\n");
+}
+
+static void xgene_mii_phy_read(struct xgene_enet_pdata *pdata, u8 phy_id,
+			       u32 reg, u32 *data)
+{
+	u32 addr, done;
+	u8 wait = 10;
+
+	addr = PHY_ADDR(phy_id) | REG_ADDR(reg);
+	xgene_enet_wr_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
+	xgene_enet_wr_mac(pdata, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
+
+	while (wait--) {
+		xgene_enet_rd_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
+		if (!(done & BUSY_MASK))
+			break;
+		usleep_range(10, 20);
+	}
+	if (done & BUSY_MASK)
+		netdev_err(pdata->ndev, "MII_MGMT read failed\n");
+
+	xgene_enet_rd_mac(pdata, MII_MGMT_STATUS_ADDR, data);
+	xgene_enet_wr_mac(pdata, MII_MGMT_COMMAND_ADDR, 0);
+}
+
+static void xgene_sgmac_reset(struct xgene_enet_pdata *pdata)
+{
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, SOFT_RESET1);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, 0);
+}
+
+static void xgene_sgmac_set_mac_addr(struct xgene_enet_pdata *pdata)
+{
+	u32 addr0, addr1;
+	u8 *dev_addr = pdata->ndev->dev_addr;
+
+	addr0 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
+		(dev_addr[1] << 8) | dev_addr[0];
+	xgene_enet_wr_mac(pdata, STATION_ADDR0_ADDR, addr0);
+
+	xgene_enet_rd_mac(pdata, STATION_ADDR1_ADDR, &addr1);
+	addr1 |= (dev_addr[5] << 24) | (dev_addr[4] << 16);
+	xgene_enet_wr_mac(pdata, STATION_ADDR1_ADDR, addr1);
+}
+
+static u32 xgene_enet_link_status(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_mii_phy_read(pdata, INT_PHY_ADDR,
+			   SGMII_BASE_PAGE_ABILITY_ADDR >> 2, &data);
+
+	return data & LINK_UP;
+}
+
+static void xgene_sgmac_init(struct xgene_enet_pdata *pdata)
+{
+	u32 data, loop = 10;
+
+	xgene_sgmac_reset(pdata);
+
+	/* Enable auto-negotiation */
+	xgene_mii_phy_write(pdata, INT_PHY_ADDR,
+			    SGMII_CONTROL_ADDR >> 2, 0x1000);
+	xgene_mii_phy_write(pdata, INT_PHY_ADDR,
+			    SGMII_TBI_CONTROL_ADDR >> 2, 0);
+
+	while (loop--) {
+		xgene_mii_phy_read(pdata, INT_PHY_ADDR,
+				   SGMII_STATUS_ADDR >> 2, &data);
+		if ((data & AUTO_NEG_COMPLETE) && (data & LINK_STATUS))
+			break;
+		usleep_range(10, 20);
+	}
+	if (!(data & AUTO_NEG_COMPLETE) || !(data & LINK_STATUS))
+		netdev_err(pdata->ndev, "Auto-negotiation failed\n");
+
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_2_ADDR, &data);
+	ENET_INTERFACE_MODE2_SET(&data, 2);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_2_ADDR, data | FULL_DUPLEX2);
+	xgene_enet_wr_mac(pdata, INTERFACE_CONTROL_ADDR, ENET_GHD_MODE);
+
+	xgene_enet_rd_csr(pdata, ENET_SPARE_CFG_REG_ADDR, &data);
+	data |= MPA_IDLE_WITH_QMI_EMPTY;
+	xgene_enet_wr_csr(pdata, ENET_SPARE_CFG_REG_ADDR, data);
+
+	xgene_sgmac_set_mac_addr(pdata);
+
+	xgene_enet_rd_csr(pdata, DEBUG_REG_ADDR, &data);
+	data |= CFG_BYPASS_UNISEC_TX | CFG_BYPASS_UNISEC_RX;
+	xgene_enet_wr_csr(pdata, DEBUG_REG_ADDR, data);
+
+	/* Adjust MDC clock frequency */
+	xgene_enet_rd_mac(pdata, MII_MGMT_CONFIG_ADDR, &data);
+	MGMT_CLOCK_SEL_SET(&data, 7);
+	xgene_enet_wr_mac(pdata, MII_MGMT_CONFIG_ADDR, data);
+
+	/* Enable drop if bufpool not available */
+	xgene_enet_rd_csr(pdata, RSIF_CONFIG_REG_ADDR, &data);
+	data |= CFG_RSIF_FPBUFF_TIMEOUT_EN;
+	xgene_enet_wr_csr(pdata, RSIF_CONFIG_REG_ADDR, data);
+
+	/* Rtype should be copied from FP */
+	xgene_enet_wr_csr(pdata, RSIF_RAM_DBG_REG0_ADDR, 0);
+
+	/* Bypass traffic gating */
+	xgene_enet_wr_csr(pdata, CFG_LINK_AGGR_RESUME_0_ADDR, TX_PORT0);
+	xgene_enet_wr_csr(pdata, CFG_BYPASS_ADDR, RESUME_TX);
+	xgene_enet_wr_csr(pdata, SG_RX_DV_GATE_REG_0_ADDR, RESUME_RX0);
+}
+
+static void xgene_sgmac_rx_enable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data | RX_EN);
+}
+
+static void xgene_sgmac_tx_enable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data | TX_EN);
+}
+
+static void xgene_sgmac_rx_disable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data & ~RX_EN);
+}
+
+static void xgene_sgmac_tx_disable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data & ~TX_EN);
+}
+
+static void xgene_enet_reset(struct xgene_enet_pdata *pdata)
+{
+	clk_prepare_enable(pdata->clk);
+	clk_disable_unprepare(pdata->clk);
+	clk_prepare_enable(pdata->clk);
+
+	xgene_enet_ecc_init(pdata);
+	xgene_enet_config_ring_if_assoc(pdata);
+}
+
+static void xgene_enet_cle_bypass(struct xgene_enet_pdata *pdata,
+				  u32 dst_ring_num, u16 bufpool_id)
+{
+	u32 cb, fpsel;
+
+	xgene_enet_rd_csr(pdata, CLE_BYPASS_REG0_0_ADDR, &cb);
+	cb |= CFG_CLE_BYPASS_EN0;
+	CFG_CLE_IP_PROTOCOL0_SET(&cb, 3);
+	xgene_enet_wr_csr(pdata, CLE_BYPASS_REG0_0_ADDR, cb);
+
+	fpsel = xgene_enet_ring_bufnum(bufpool_id) - 0x20;
+	xgene_enet_rd_csr(pdata, CLE_BYPASS_REG1_0_ADDR, &cb);
+	CFG_CLE_DSTQID0_SET(&cb, dst_ring_num);
+	CFG_CLE_FPSEL0_SET(&cb, fpsel);
+	xgene_enet_wr_csr(pdata, CLE_BYPASS_REG1_0_ADDR, cb);
+}
+
+static void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
+{
+	clk_disable_unprepare(pdata->clk);
+}
+
+static void xgene_enet_link_state(struct work_struct *work)
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
+			xgene_sgmac_init(pdata);
+			xgene_sgmac_rx_enable(pdata);
+			xgene_sgmac_tx_enable(pdata);
+			netdev_info(ndev, "Link is Up - 1Gbps\n");
+		}
+		poll_interval = PHY_POLL_LINK_ON;
+	} else {
+		if (netif_carrier_ok(ndev)) {
+			xgene_sgmac_rx_disable(pdata);
+			xgene_sgmac_tx_disable(pdata);
+			netif_carrier_off(ndev);
+			netdev_info(ndev, "Link is Down\n");
+		}
+		poll_interval = PHY_POLL_LINK_OFF;
+	}
+
+	schedule_delayed_work(&pdata->link_work, poll_interval);
+}
+
+struct xgene_mac_ops xgene_sgmac_ops = {
+	.init = xgene_sgmac_init,
+	.reset = xgene_sgmac_reset,
+	.rx_enable = xgene_sgmac_rx_enable,
+	.tx_enable = xgene_sgmac_tx_enable,
+	.rx_disable = xgene_sgmac_rx_disable,
+	.tx_disable = xgene_sgmac_tx_disable,
+	.set_mac_addr = xgene_sgmac_set_mac_addr,
+	.link_state = xgene_enet_link_state
+};
+
+struct xgene_port_ops xgene_sgport_ops = {
+	.reset = xgene_enet_reset,
+	.cle_bypass = xgene_enet_cle_bypass,
+	.shutdown = xgene_enet_shutdown,
+};
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
new file mode 100644
index 0000000..de43246
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
@@ -0,0 +1,41 @@
+/* Applied Micro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2014, Applied Micro Circuits Corporation
+ * Authors: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
+ *	    Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
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
+#ifndef __XGENE_ENET_SGMAC_H__
+#define __XGENE_ENET_SGMAC_H__
+
+#define PHY_ADDR(src)		(((src)<<8) & GENMASK(12, 8))
+#define REG_ADDR(src)		((src) & GENMASK(4, 0))
+#define PHY_CONTROL(src)	((src) & GENMASK(15, 0))
+#define INT_PHY_ADDR			0x1e
+#define SGMII_TBI_CONTROL_ADDR		0x44
+#define SGMII_CONTROL_ADDR		0x00
+#define SGMII_STATUS_ADDR		0x04
+#define SGMII_BASE_PAGE_ABILITY_ADDR	0x14
+#define AUTO_NEG_COMPLETE		BIT(5)
+#define LINK_STATUS			BIT(2)
+#define LINK_UP				BIT(15)
+#define MPA_IDLE_WITH_QMI_EMPTY		BIT(12)
+#define SG_RX_DV_GATE_REG_0_ADDR	0x0dfc
+
+extern struct xgene_mac_ops xgene_sgmac_ops;
+extern struct xgene_port_ops xgene_sgport_ops;
+
+#endif  /* __XGENE_ENET_SGMAC_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index cd64b9f..67d0720 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -284,7 +284,7 @@ static void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
 	clk_disable_unprepare(pdata->clk);
 }
 
-void xgene_enet_link_state(struct work_struct *work)
+static void xgene_enet_link_state(struct work_struct *work)
 {
 	struct xgene_enet_pdata *pdata = container_of(to_delayed_work(work),
 					 struct xgene_enet_pdata, link_work);
@@ -322,6 +322,7 @@ struct xgene_mac_ops xgene_xgmac_ops = {
 	.rx_disable = xgene_xgmac_rx_disable,
 	.tx_disable = xgene_xgmac_tx_disable,
 	.set_mac_addr = xgene_xgmac_set_mac_addr,
+	.link_state = xgene_enet_link_state
 };
 
 struct xgene_port_ops xgene_xgport_ops = {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
index d2d59e7..5a5296a 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
@@ -47,10 +47,6 @@
 #define XG_ENET_SPARE_CFG_REG_1_ADDR	0x0410
 #define XGENET_RX_DV_GATE_REG_0_ADDR	0x0804
 
-#define PHY_POLL_LINK_ON	(10 * HZ)
-#define PHY_POLL_LINK_OFF	(PHY_POLL_LINK_ON / 5)
-
-void xgene_enet_link_state(struct work_struct *work);
 extern struct xgene_mac_ops xgene_xgmac_ops;
 extern struct xgene_port_ops xgene_xgport_ops;
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
