From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 net-next 2/6] drivers: net: xgene-v2: Add mac configuration
Date: Tue,  7 Mar 2017 17:08:41 -0800
Message-ID: <1488935325-13603-3-git-send-email-isubramanian@apm.com>
References: <1488935325-13603-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com, linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
 f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488935325-13603-1-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds functions to configure and control mac.  This
patch also adds helper functions to get/set registers.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/net/ethernet/apm/xgene-v2/mac.c | 116 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/mac.h | 110 ++++++++++++++++++++++++++++++
 2 files changed, 226 insertions(+)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mac.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mac.h

diff --git a/drivers/net/ethernet/apm/xgene-v2/mac.c b/drivers/net/ethernet/apm/xgene-v2/mac.c
new file mode 100644
index 0000000..9c3d32d
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/mac.c
@@ -0,0 +1,116 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *	      Keyur Chudgar <kchudgar@apm.com>
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
+#include "main.h"
+
+void xge_mac_reset(struct xge_pdata *pdata)
+{
+	xge_wr_csr(pdata, MAC_CONFIG_1, SOFT_RESET);
+	xge_wr_csr(pdata, MAC_CONFIG_1, 0);
+}
+
+static void xge_mac_set_speed(struct xge_pdata *pdata)
+{
+	u32 icm0, icm2, ecm0, mc2;
+	u32 intf_ctrl, rgmii;
+
+	icm0 = xge_rd_csr(pdata, ICM_CONFIG0_REG_0);
+	icm2 = xge_rd_csr(pdata, ICM_CONFIG2_REG_0);
+	ecm0 = xge_rd_csr(pdata, ECM_CONFIG0_REG_0);
+	rgmii = xge_rd_csr(pdata, RGMII_REG_0);
+	mc2 = xge_rd_csr(pdata, MAC_CONFIG_2);
+	intf_ctrl = xge_rd_csr(pdata, INTERFACE_CONTROL);
+	icm2 |= CFG_WAITASYNCRD_EN;
+
+	switch (pdata->phy_speed) {
+	case SPEED_10:
+		SET_REG_BITS(&mc2, INTF_MODE, 1);
+		SET_REG_BITS(&intf_ctrl, HD_MODE, 0);
+		SET_REG_BITS(&icm0, CFG_MACMODE, 0);
+		SET_REG_BITS(&icm2, CFG_WAITASYNCRD, 500);
+		SET_REG_BIT(&rgmii, CFG_SPEED_125, 0);
+		break;
+	case SPEED_100:
+		SET_REG_BITS(&mc2, INTF_MODE, 1);
+		SET_REG_BITS(&intf_ctrl, HD_MODE, 1);
+		SET_REG_BITS(&icm0, CFG_MACMODE, 1);
+		SET_REG_BITS(&icm2, CFG_WAITASYNCRD, 80);
+		SET_REG_BIT(&rgmii, CFG_SPEED_125, 0);
+		break;
+	default:
+		SET_REG_BITS(&mc2, INTF_MODE, 2);
+		SET_REG_BITS(&intf_ctrl, HD_MODE, 2);
+		SET_REG_BITS(&icm0, CFG_MACMODE, 2);
+		SET_REG_BITS(&icm2, CFG_WAITASYNCRD, 16);
+		SET_REG_BIT(&rgmii, CFG_SPEED_125, 1);
+		break;
+	}
+
+	mc2 |= FULL_DUPLEX | CRC_EN | PAD_CRC;
+	SET_REG_BITS(&ecm0, CFG_WFIFOFULLTHR, 0x32);
+
+	xge_wr_csr(pdata, MAC_CONFIG_2, mc2);
+	xge_wr_csr(pdata, INTERFACE_CONTROL, intf_ctrl);
+	xge_wr_csr(pdata, RGMII_REG_0, rgmii);
+	xge_wr_csr(pdata, ICM_CONFIG0_REG_0, icm0);
+	xge_wr_csr(pdata, ICM_CONFIG2_REG_0, icm2);
+	xge_wr_csr(pdata, ECM_CONFIG0_REG_0, ecm0);
+}
+
+void xge_mac_set_station_addr(struct xge_pdata *pdata)
+{
+	u32 addr0, addr1;
+	u8 *dev_addr = pdata->ndev->dev_addr;
+
+	addr0 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
+		(dev_addr[1] << 8) | dev_addr[0];
+	addr1 = (dev_addr[5] << 24) | (dev_addr[4] << 16);
+
+	xge_wr_csr(pdata, STATION_ADDR0, addr0);
+	xge_wr_csr(pdata, STATION_ADDR1, addr1);
+}
+
+void xge_mac_init(struct xge_pdata *pdata)
+{
+	xge_mac_reset(pdata);
+	xge_mac_set_speed(pdata);
+	xge_mac_set_station_addr(pdata);
+}
+
+void xge_mac_enable(struct xge_pdata *pdata)
+{
+	u32 data;
+
+	data = xge_rd_csr(pdata, MAC_CONFIG_1);
+	data |= TX_EN | RX_EN;
+	xge_wr_csr(pdata, MAC_CONFIG_1, data);
+
+	data = xge_rd_csr(pdata, MAC_CONFIG_1);
+}
+
+void xge_mac_disable(struct xge_pdata *pdata)
+{
+	u32 data;
+
+	data = xge_rd_csr(pdata, MAC_CONFIG_1);
+	data &= ~(TX_EN | RX_EN);
+	xge_wr_csr(pdata, MAC_CONFIG_1, data);
+}
diff --git a/drivers/net/ethernet/apm/xgene-v2/mac.h b/drivers/net/ethernet/apm/xgene-v2/mac.h
new file mode 100644
index 0000000..0fce6ae
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/mac.h
@@ -0,0 +1,110 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *	      Keyur Chudgar <kchudgar@apm.com>
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
+#ifndef __XGENE_ENET_V2_MAC_H__
+#define __XGENE_ENET_V2_MAC_H__
+
+/* Register offsets */
+#define MAC_CONFIG_1		0xa000
+#define MAC_CONFIG_2		0xa004
+#define MII_MGMT_CONFIG		0xa020
+#define MII_MGMT_COMMAND	0xa024
+#define MII_MGMT_ADDRESS	0xa028
+#define MII_MGMT_CONTROL	0xa02c
+#define MII_MGMT_STATUS		0xa030
+#define MII_MGMT_INDICATORS	0xa034
+#define INTERFACE_CONTROL	0xa038
+#define STATION_ADDR0		0xa040
+#define STATION_ADDR1		0xa044
+#define RBYT			0xa09c
+#define RPKT			0xa0a0
+#define RFCS			0xa0a4
+
+#define RGMII_REG_0		0x27e0
+#define ICM_CONFIG0_REG_0	0x2c00
+#define ICM_CONFIG2_REG_0	0x2c08
+#define ECM_CONFIG0_REG_0	0x2d00
+
+/* Register fields */
+#define SOFT_RESET		BIT(31)
+#define TX_EN			BIT(0)
+#define RX_EN			BIT(2)
+#define PAD_CRC			BIT(2)
+#define CRC_EN			BIT(1)
+#define FULL_DUPLEX		BIT(0)
+
+#define INTF_MODE_POS		8
+#define INTF_MODE_LEN		2
+#define HD_MODE_POS		25
+#define HD_MODE_LEN		2
+#define CFG_MACMODE_POS		18
+#define CFG_MACMODE_LEN		2
+#define CFG_WAITASYNCRD_POS	0
+#define CFG_WAITASYNCRD_LEN	16
+#define CFG_SPEED_125_POS	24
+#define CFG_WFIFOFULLTHR_POS	0
+#define CFG_WFIFOFULLTHR_LEN	7
+#define MGMT_CLOCK_SEL_POS	0
+#define MGMT_CLOCK_SEL_LEN	3
+#define PHY_ADDR_POS		8
+#define PHY_ADDR_LEN		5
+#define REG_ADDR_POS		0
+#define REG_ADDR_LEN		5
+#define MII_MGMT_BUSY		BIT(0)
+#define MII_READ_CYCLE		BIT(0)
+#define CFG_WAITASYNCRD_EN	BIT(16)
+
+static inline void xgene_set_reg_bits(u32 *var, int pos, int len, u32 val)
+{
+	u32 mask = GENMASK(pos + len, pos);
+
+	*var &= ~mask;
+	*var |= ((val << pos) & mask);
+}
+
+static inline u32 xgene_get_reg_bits(u32 var, int pos, int len)
+{
+	u32 mask = GENMASK(pos + len, pos);
+
+	return (var & mask) >> pos;
+}
+
+#define SET_REG_BITS(var, field, val)					\
+	xgene_set_reg_bits(var, field ## _POS, field ## _LEN, val)
+
+#define SET_REG_BIT(var, field, val)					\
+	xgene_set_reg_bits(var, field ## _POS, 1, val)
+
+#define GET_REG_BITS(var, field)					\
+	xgene_get_reg_bits(var, field ## _POS, field ## _LEN)
+
+#define GET_REG_BIT(var, field)		((var) & (field))
+
+struct xge_pdata;
+
+void xge_mac_reset(struct xge_pdata *pdata);
+void xge_mac_enable(struct xge_pdata *pdata);
+void xge_mac_disable(struct xge_pdata *pdata);
+void xge_mac_init(struct xge_pdata *pdata);
+int xge_port_init(struct net_device *ndev);
+void xge_mac_set_station_addr(struct xge_pdata *pdata);
+
+#endif /* __XGENE_ENET_V2_MAC_H__ */
-- 
1.9.1
