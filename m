From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 5/5] drivers: net: APM X-Gene SoC Ethernet driver ethtool
 support
Date: Fri, 20 Dec 2013 19:42:56 -0800
Message-ID: <1387597376-29303-6-git-send-email-isubramanian@apm.com>
References: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, gregkh@linuxfoundation.org,
 Iyappan Subramanian <isubramanian@apm.com>, patches@apm.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, jcm@redhat.com,
 Keyur Chudgar <kchudgar@apm.com>, linux-arm-kernel@lists.infradead.org,
 Ravi Patel <rapatel@apm.com>
To: davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
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

Ethtool support for APM X-Gene SoC ethernet driver.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/net/ethernet/apm/xgene/Makefile           |    3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_csr.h   |    4 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |    1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |    1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_tools.c |  296 +++++++++++++++++++++
 5 files changed, 304 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_tools.c

diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
index 091547e..472710d 100644
--- a/drivers/net/ethernet/apm/xgene/Makefile
+++ b/drivers/net/ethernet/apm/xgene/Makefile
@@ -6,6 +6,7 @@ xgene-enet-objs := \
 		xgene_enet_common.o	\
 		xgene_enet_mac.o	\
 		xgene_enet_main.o	\
-		xgene_enet_err.o
+		xgene_enet_err.o	\
+		xgene_enet_tools.o
 
 obj-$(CONFIG_NET_XGENE) += xgene-enet.o
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h b/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
index 858d155..5ca0d81 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
@@ -357,6 +357,10 @@
 #define INTERFACE_CONTROL_ADDR                                       0x00000038
 #define STATION_ADDR0_ADDR                                           0x00000040
 #define STATION_ADDR1_ADDR                                           0x00000044
+#define RX_FLOW_EN1_MASK                                             0x00000020
+#define TX_FLOW_EN1_MASK                                             0x00000010
+#define RX_FLOW_EN1_RD(src)                           (((src) & 0x00000020)>>5)
+#define TX_FLOW_EN1_RD(src)                           (((src) & 0x00000010)>>4)
 #define SCAN_CYCLE_MASK                                              0x00000002
 #define SOFT_RESET1_MASK                                             0x80000000
 #define MAX_FRAME_LEN_SET(dst, src) \
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 90f53b8..77d3fd8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1416,6 +1416,7 @@ static int xgene_enet_init_hw(struct xgene_enet_pdev *pdev)
 
 	/* Ethtool checks the capabilities/features in hw_features flag */
 	ndev->hw_features = ndev->features;
+	SET_ETHTOOL_OPS(ndev, &xgene_ethtool_ops);
 
 	rc = register_netdev(ndev);
 	if (rc) {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index b25bb37..b95f129 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -173,4 +173,5 @@ void xgene_enet_init_priv(struct xgene_enet_priv *priv);
 int xgene_enet_parse_error(u8 LErr, int qid);
 void xgene_enet_register_err_irqs(struct net_device *ndev);
 
+extern const struct ethtool_ops xgene_ethtool_ops;
 #endif /* __XGENE_ENET_MAIN_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_tools.c b/drivers/net/ethernet/apm/xgene/xgene_enet_tools.c
new file mode 100644
index 0000000..d99f42b
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_tools.c
@@ -0,0 +1,296 @@
+/* AppliedMicro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2013, Applied Micro Circuits Corporation
+ * Authors:	Hrishikesh Karanjikar <hkaranjikar@apm.com>
+ *		Ravi Patel <rapatel@apm.com>
+ *		Iyappan Subramanian <isubramanian@apm.com>
+ *		Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/mii.h>
+#include <linux/phy.h>
+#include "xgene_enet_csr.h"
+#include "xgene_enet_main.h"
+
+struct xgene_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+static const struct xgene_stats xgene_gstrings_stats[] = {
+	{ "rx_bytes",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.rx_stats.rx_byte_count),
+		offsetof(struct xgene_enet_pdev, stats.rx_stats.rx_byte_count)
+	},
+	{ "rx_packets",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.rx_stats.rx_packet_count),
+		offsetof(struct xgene_enet_pdev, stats.rx_stats.rx_packet_count)
+	},
+	{ "rx_fcs_err",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.rx_stats.rx_fcs_err_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.rx_stats.rx_fcs_err_count)
+	},
+	{ "rx_alignment_err",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.rx_stats.rx_alignment_err_pkt_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.rx_stats.rx_alignment_err_pkt_count)
+	},
+	{ "rx_frm_len_err",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.rx_stats.rx_frm_len_err_pkt_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.rx_stats.rx_frm_len_err_pkt_count)
+	},
+	{ "rx_undersize",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.rx_stats.rx_undersize_pkt_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.rx_stats.rx_undersize_pkt_count)
+	},
+	{ "rx_oversize",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.rx_stats.rx_oversize_pkt_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.rx_stats.rx_oversize_pkt_count)
+	},
+	{ "rx_drop",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.rx_stats.rx_drop_pkt_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.rx_stats.rx_drop_pkt_count)
+	},
+	{ "tx_bytes",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.tx_stats.tx_byte_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.tx_stats.tx_byte_count)
+	},
+	{ "tx_packets",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.tx_stats.tx_pkt_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.tx_stats.tx_pkt_count)
+	},
+	{ "tx_drop",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.tx_stats.tx_drop_frm_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.tx_stats.tx_drop_frm_count)
+	},
+	{ "tx_fcs_err",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.tx_stats.tx_fcs_err_frm_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.tx_stats.tx_fcs_err_frm_count)
+	},
+	{ "tx_undersize",
+		FIELD_SIZEOF(struct xgene_enet_pdev,
+			stats.tx_stats.tx_undersize_frm_count),
+		offsetof(struct xgene_enet_pdev,
+			stats.tx_stats.tx_undersize_frm_count)
+	},
+};
+
+#define XGENE_GLOBAL_STATS_LEN ARRAY_SIZE(xgene_gstrings_stats)
+
+/* Ethtool APIs */
+static int xgene_ethtool_get_settings(struct net_device *ndev,
+		struct ethtool_cmd *cmd)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct phy_device *phydev = pdev->phy_dev;
+	struct xgene_enet_priv *priv = &pdev->priv;
+
+	if (priv->phy_mode == PHY_MODE_RGMII) {
+		if (!phydev)
+			return -ENODEV;
+		return phy_ethtool_gset(phydev, cmd);
+	}
+	return 0;
+}
+
+static int xgene_ethtool_set_settings(struct net_device *ndev,
+		struct ethtool_cmd *cmd)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct phy_device *phydev = pdev->phy_dev;
+	struct xgene_enet_priv *priv = &pdev->priv;
+
+	if (priv->phy_mode == PHY_MODE_RGMII) {
+		if (!phydev)
+			return -ENODEV;
+		return phy_ethtool_sset(phydev, cmd);
+	}
+	return 0;
+}
+
+static int xgene_ethtool_set_pauseparam(struct net_device *ndev,
+		struct ethtool_pauseparam *pp)
+{
+	u32 data;
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &pdev->priv;
+
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &data);
+
+	/* Modify value to set or reset rx flow control */
+	if (pp->rx_pause)
+		data |= RX_FLOW_EN1_MASK;
+	else
+		data &= ~RX_FLOW_EN1_MASK;
+
+	/* Modify value to set or reset tx flow control */
+	if (pp->tx_pause)
+		data |= TX_FLOW_EN1_MASK;
+	else
+		data &= ~TX_FLOW_EN1_MASK;
+
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, data);
+
+	return 0;
+}
+
+static void xgene_ethtool_get_pauseparam(struct net_device *ndev,
+		struct ethtool_pauseparam *pp)
+{
+	u32 data;
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &pdev->priv;
+
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &data);
+	pp->rx_pause = RX_FLOW_EN1_RD(data);
+
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &data);
+	pp->tx_pause = TX_FLOW_EN1_RD(data);
+}
+
+static int xgene_ethtool_nway_reset(struct net_device *ndev)
+{
+	u32 data = 0, retry = 0;
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &pdev->priv;
+
+	if (priv->phy_mode == PHY_MODE_RGMII)
+		mutex_lock(&pdev->mdio_bus->mdio_lock);
+
+	/* Power-down PHY */
+	data = MII_CR_POWER_DOWN;
+	xgene_genericmiiphy_write(priv, priv->phy_addr,
+			MII_CTRL_REG, data);
+
+	/* Power-up PHY */
+	data = 0x0;
+	xgene_genericmiiphy_write(priv, priv->phy_addr,
+			MII_CTRL_REG, data);
+
+	/* Reset PHY */
+	data = MII_CR_RESET;
+	xgene_genericmiiphy_write(priv, priv->phy_addr,
+			MII_CTRL_REG, data);
+
+	/* PHY reset may take 100 ms */
+	retry = 100;
+	do {
+		xgene_genericmiiphy_read(priv, priv->phy_addr,
+			MII_CTRL_REG, &data);
+		usleep_range(1000, 2000);
+	} while (--retry && (data & MII_CR_RESET));
+
+	xgene_genericmiiphy_write(priv, priv->phy_addr, MII_CTRL_REG,
+			MII_CR_AUTO_EN|MII_CR_RESTART|MII_CR_FDX);
+
+	priv->autoneg_set = 1;
+	priv->speed = XGENE_ENET_SPEED_1000;
+	priv->mac_init(priv, ndev->dev_addr, priv->speed,
+			HW_MTU(ndev->mtu), priv->crc);
+
+	if (priv->phy_mode == PHY_MODE_RGMII)
+		mutex_unlock(&pdev->mdio_bus->mdio_lock);
+
+	return 0;
+}
+
+static void xgene_get_strings(struct net_device *ndev, u32 stringset,
+		    u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_TEST:
+	case ETH_SS_STATS:
+		for (i = 0; i < XGENE_GLOBAL_STATS_LEN; i++) {
+			memcpy(p, xgene_gstrings_stats[i].stat_string,
+					ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static int xgene_get_sset_count(struct net_device *ndev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_TEST:
+		return XGENE_GLOBAL_STATS_LEN;
+	case ETH_SS_STATS:
+		return XGENE_GLOBAL_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+}
+
+static void xgene_ethtool_get_ethtool_stats(struct net_device *ndev,
+		struct ethtool_stats *ethtool_stats,
+		u64 *data)
+{
+
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &pdev->priv;
+	struct xgene_enet_detailed_stats *stats = &pdev->stats;
+	int i;
+
+	xgene_enet_get_stats(priv, stats);
+	for (i = 0; i < XGENE_GLOBAL_STATS_LEN; i++) {
+		char *p = (char *)pdev + xgene_gstrings_stats[i].stat_offset;
+		data[i] = (xgene_gstrings_stats[i].sizeof_stat ==
+				sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+	}
+}
+
+static void xgene_ethtool_get_drvinfo(struct net_device *ndev,
+		struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, ndev->name);
+	strcpy(info->version, XGENE_ENET_DRIVER_VERSION);
+	strcpy(info->fw_version, "N/A");
+}
+
+const struct ethtool_ops xgene_ethtool_ops = {
+	.get_settings = xgene_ethtool_get_settings,
+	.set_settings = xgene_ethtool_set_settings,
+	.get_drvinfo = xgene_ethtool_get_drvinfo,
+	.nway_reset = xgene_ethtool_nway_reset,
+	.get_pauseparam = xgene_ethtool_get_pauseparam,
+	.set_pauseparam = xgene_ethtool_set_pauseparam,
+	.get_ethtool_stats = xgene_ethtool_get_ethtool_stats,
+	.get_sset_count = xgene_get_sset_count,
+	.get_strings = xgene_get_strings,
+	.get_link = ethtool_op_get_link,
+};
-- 
1.7.9.5
