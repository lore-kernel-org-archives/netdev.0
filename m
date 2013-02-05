From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v4 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Tue, 5 Feb 2013 23:56:48 +0530
Message-ID: <1360088808-8971-3-git-send-email-mugunthanvnm@ti.com>
References: <1360088808-8971-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1360088808-8971-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adding support for VLAN interface for cpsw.

CPSW VLAN Capability
* Can filter VLAN packets in Hardware

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c     |  106 +++++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/ti/cpsw_ale.h |    4 ++
 include/linux/platform_data/cpsw.h |    1 +
 3 files changed, 109 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 534bf7b..888708c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -32,6 +32,7 @@
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/of_device.h>
+#include <linux/if_vlan.h>
 
 #include <linux/platform_data/cpsw.h>
 
@@ -118,6 +119,9 @@ do {								\
 #define TX_PRIORITY_MAPPING	0x33221100
 #define CPDMA_TX_PRIORITY_MAP	0x76543210
 
+#define CPSW_VLAN_AWARE		BIT(1)
+#define CPSW_ALE_VLAN_AWARE	1
+
 #define cpsw_enable_irq(priv)	\
 	do {			\
 		u32 i;		\
@@ -607,14 +611,40 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	}
 }
 
+static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
+{
+	const int vlan = priv->data.default_vlan;
+	const int port = priv->host_port;
+	u32 reg;
+	int i;
+
+	reg = (priv->version == CPSW_VERSION_1) ? CPSW1_PORT_VLAN :
+	       CPSW2_PORT_VLAN;
+
+	writel(vlan, &priv->host_port_regs->port_vlan);
+
+	for (i = 0; i < 2; i++)
+		slave_write(priv->slaves + i, vlan, reg);
+
+	cpsw_ale_add_vlan(priv->ale, vlan, ALE_ALL_PORTS << port,
+			  ALE_ALL_PORTS << port, ALE_ALL_PORTS << port,
+			  (ALE_PORT_1 | ALE_PORT_2) << port);
+}
+
 static void cpsw_init_host_port(struct cpsw_priv *priv)
 {
+	u32 control_reg;
+
 	/* soft reset the controller and initialize ale */
 	soft_reset("cpsw", &priv->regs->soft_reset);
 	cpsw_ale_start(priv->ale);
 
 	/* switch to vlan unaware mode */
-	cpsw_ale_control_set(priv->ale, 0, ALE_VLAN_AWARE, 0);
+	cpsw_ale_control_set(priv->ale, priv->host_port, ALE_VLAN_AWARE,
+			     CPSW_ALE_VLAN_AWARE);
+	control_reg = readl(&priv->regs->control);
+	control_reg |= CPSW_VLAN_AWARE;
+	writel(control_reg, &priv->regs->control);
 
 	/* setup host port priority mapping */
 	__raw_writel(CPDMA_TX_PRIORITY_MAP,
@@ -650,6 +680,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpsw_init_host_port(priv);
 	for_each_slave(priv, cpsw_slave_open, priv);
 
+	/* Add default VLAN */
+	cpsw_add_default_vlan(priv);
+
 	/* setup tx dma to fixed prio and zero offset */
 	cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
 	cpdma_control_set(priv->dma, CPDMA_RX_BUFFER_OFFSET, 0);
@@ -933,6 +966,73 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 }
 #endif
 
+static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
+				unsigned short vid)
+{
+	int ret;
+
+	ret = cpsw_ale_add_vlan(priv->ale, vid,
+				ALE_ALL_PORTS << priv->host_port,
+				0, ALE_ALL_PORTS << priv->host_port,
+				(ALE_PORT_1 | ALE_PORT_2) << priv->host_port);
+	if (ret != 0)
+		return ret;
+
+	ret = cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
+				 priv->host_port, ALE_VLAN, vid);
+	if (ret != 0)
+		goto clean_vid;
+
+	ret = cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+				 ALE_ALL_PORTS << priv->host_port,
+				 ALE_VLAN, vid, 0);
+	if (ret != 0)
+		goto clean_vlan_ucast;
+	return 0;
+
+clean_vlan_ucast:
+	cpsw_ale_del_ucast(priv->ale, priv->mac_addr,
+			    priv->host_port, ALE_VLAN, vid);
+clean_vid:
+	cpsw_ale_del_vlan(priv->ale, vid, 0);
+	return ret;
+}
+
+static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
+		unsigned short vid)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	if (vid == priv->data.default_vlan)
+		return 0;
+
+	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
+	return cpsw_add_vlan_ale_entry(priv, vid);
+}
+
+static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
+		unsigned short vid)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	if (vid == priv->data.default_vlan)
+		return 0;
+
+	dev_info(priv->dev, "removing vlanid %d from vlan filter\n", vid);
+	ret = cpsw_ale_del_vlan(priv->ale, vid, 0);
+	if (ret != 0)
+		return ret;
+
+	ret = cpsw_ale_del_ucast(priv->ale, priv->mac_addr,
+				 priv->host_port, ALE_VLAN, vid);
+	if (ret != 0)
+		return ret;
+
+	return cpsw_ale_del_mcast(priv->ale, priv->ndev->broadcast,
+				  0, ALE_VLAN, vid);
+}
+
 static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_open		= cpsw_ndo_open,
 	.ndo_stop		= cpsw_ndo_stop,
@@ -947,6 +1047,8 @@ static const struct net_device_ops cpsw_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cpsw_ndo_poll_controller,
 #endif
+	.ndo_vlan_rx_add_vid	= cpsw_ndo_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= cpsw_ndo_vlan_rx_kill_vid,
 };
 
 static void cpsw_get_drvinfo(struct net_device *ndev,
@@ -1354,7 +1456,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		k++;
 	}
 
-	ndev->flags |= IFF_ALLMULTI;	/* see cpsw_ndo_change_rx_flags() */
+	ndev->features |= NETIF_F_HW_VLAN_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &cpsw_ethtool_ops);
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index a002417..30daa12 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -69,6 +69,10 @@ enum cpsw_ale_port_state {
 #define ALE_SUPER			BIT(2)
 #define ALE_VLAN			BIT(3)
 
+#define ALE_PORT_HOST			BIT(0)
+#define ALE_PORT_1			BIT(1)
+#define ALE_PORT_2			BIT(2)
+
 #define ALE_MCAST_FWD			0
 #define ALE_MCAST_BLOCK_LEARN_FWD	1
 #define ALE_MCAST_FWD_LEARN		2
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index 24368a2..e962cfd 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -35,6 +35,7 @@ struct cpsw_platform_data {
 	u32	bd_ram_size;  /*buffer descriptor ram size */
 	u32	rx_descs;	/* Number of Rx Descriptios */
 	u32	mac_control;	/* Mac control register */
+	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
 };
 
 #endif /* __CPSW_H__ */
-- 
1.7.9.5

