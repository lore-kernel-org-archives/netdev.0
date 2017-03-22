From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 2/4] drivers: net: xgene-v2: Add ethtool support
Date: Tue, 21 Mar 2017 18:18:03 -0700
Message-ID: <1490145485-32661-3-git-send-email-isubramanian@apm.com>
References: <1490145485-32661-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
        f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33525 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdCVBRo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:17:44 -0400
Received: by mail-pg0-f46.google.com with SMTP id n190so101420048pga.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:16:52 -0700 (PDT)
In-Reply-To: <1490145485-32661-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added basic ethtool support.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene-v2/Makefile  |   2 +-
 drivers/net/ethernet/apm/xgene-v2/ethtool.c | 121 ++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/main.c    |   1 +
 drivers/net/ethernet/apm/xgene-v2/main.h    |   1 +
 4 files changed, 124 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ethtool.c

diff --git a/drivers/net/ethernet/apm/xgene-v2/Makefile b/drivers/net/ethernet/apm/xgene-v2/Makefile
index 0fa5975..f16a2b3 100644
--- a/drivers/net/ethernet/apm/xgene-v2/Makefile
+++ b/drivers/net/ethernet/apm/xgene-v2/Makefile
@@ -2,5 +2,5 @@
 # Makefile for APM X-Gene Ethernet v2 driver
 #
 
-xgene-enet-v2-objs := main.o mac.o enet.o ring.o mdio.o
+xgene-enet-v2-objs := main.o mac.o enet.o ring.o mdio.o ethtool.o
 obj-$(CONFIG_NET_XGENE_V2) += xgene-enet-v2.o
diff --git a/drivers/net/ethernet/apm/xgene-v2/ethtool.c b/drivers/net/ethernet/apm/xgene-v2/ethtool.c
new file mode 100644
index 0000000..0c426f5
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/ethtool.c
@@ -0,0 +1,121 @@
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
+struct xge_gstrings_stats {
+	char name[ETH_GSTRING_LEN];
+	int offset;
+};
+
+#define XGE_STAT(m)		{ #m, offsetof(struct xge_pdata, stats.m) }
+
+static const struct xge_gstrings_stats gstrings_stats[] = {
+	XGE_STAT(rx_packets),
+	XGE_STAT(tx_packets),
+	XGE_STAT(rx_bytes),
+	XGE_STAT(tx_bytes),
+	XGE_STAT(rx_errors)
+};
+
+#define XGE_STATS_LEN		ARRAY_SIZE(gstrings_stats)
+
+static void xge_get_drvinfo(struct net_device *ndev,
+			    struct ethtool_drvinfo *info)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct platform_device *pdev = pdata->pdev;
+
+	strcpy(info->driver, "xgene-enet-v2");
+	strcpy(info->version, XGENE_ENET_V2_VERSION);
+	snprintf(info->fw_version, ETHTOOL_FWVERS_LEN, "N/A");
+	sprintf(info->bus_info, "%s", pdev->name);
+}
+
+static void xge_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	for (i = 0; i < XGE_STATS_LEN; i++) {
+		memcpy(p, gstrings_stats[i].name, ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+	}
+}
+
+static int xge_get_sset_count(struct net_device *ndev, int sset)
+{
+	if (sset != ETH_SS_STATS)
+		return -EINVAL;
+
+	return XGE_STATS_LEN;
+}
+
+static void xge_get_ethtool_stats(struct net_device *ndev,
+				  struct ethtool_stats *dummy,
+				  u64 *data)
+{
+	void *pdata = netdev_priv(ndev);
+	int i;
+
+	for (i = 0; i < XGE_STATS_LEN; i++)
+		*data++ = *(u64 *)(pdata + gstrings_stats[i].offset);
+}
+
+static int xge_get_link_ksettings(struct net_device *ndev,
+				  struct ethtool_link_ksettings *cmd)
+{
+	struct phy_device *phydev = ndev->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_ksettings_get(phydev, cmd);
+}
+
+static int xge_set_link_ksettings(struct net_device *ndev,
+				  const struct ethtool_link_ksettings *cmd)
+{
+	struct phy_device *phydev = ndev->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_ksettings_set(phydev, cmd);
+}
+
+static const struct ethtool_ops xge_ethtool_ops = {
+	.get_drvinfo = xge_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_strings = xge_get_strings,
+	.get_sset_count = xge_get_sset_count,
+	.get_ethtool_stats = xge_get_ethtool_stats,
+	.get_link_ksettings = xge_get_link_ksettings,
+	.set_link_ksettings = xge_set_link_ksettings,
+};
+
+void xge_set_ethtool_ops(struct net_device *ndev)
+{
+	ndev->ethtool_ops = &xge_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/apm/xgene-v2/main.c b/drivers/net/ethernet/apm/xgene-v2/main.c
index 82ac5b4..e764e58 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.c
+++ b/drivers/net/ethernet/apm/xgene-v2/main.c
@@ -673,6 +673,7 @@ static int xge_probe(struct platform_device *pdev)
 		goto err;
 
 	ndev->hw_features = ndev->features;
+	xge_set_ethtool_ops(ndev);
 
 	ret = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64));
 	if (ret) {
diff --git a/drivers/net/ethernet/apm/xgene-v2/main.h b/drivers/net/ethernet/apm/xgene-v2/main.h
index 777f254..db1178e 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.h
+++ b/drivers/net/ethernet/apm/xgene-v2/main.h
@@ -75,5 +75,6 @@ struct xge_pdata {
 
 int xge_mdio_config(struct net_device *ndev);
 void xge_mdio_remove(struct net_device *ndev);
+void xge_set_ethtool_ops(struct net_device *ndev);
 
 #endif /* __XGENE_ENET_V2_MAIN_H__ */
-- 
1.9.1
