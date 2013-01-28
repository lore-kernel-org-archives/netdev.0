From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Tue, 29 Jan 2013 01:42:25 +0530
Message-ID: <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:35032 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155Ab3A1UMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 15:12:42 -0500
In-Reply-To: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adding support for VLAN interface for cpsw.

CPSW VLAN Capability
* Can filter VLAN packets in Hardware

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    2 +
 drivers/net/ethernet/ti/cpsw.c                 |  108 +++++++++++++++++++++++-
 include/linux/platform_data/cpsw.h             |    1 +
 3 files changed, 110 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 6ddd028..99696bf 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -24,6 +24,8 @@ Required properties:
 Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
 - no_bd_ram		: Must be 0 or 1
+- default_vlan		: Specifies Default VLAN for non tagged packets
+			  ALE processing
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b35e6a7..dee6951 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -32,6 +32,7 @@
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/of_device.h>
+#include <linux/if_vlan.h>
 
 #include <linux/platform_data/cpsw.h>
 
@@ -72,6 +73,11 @@ do {								\
 		dev_notice(priv->dev, format, ## __VA_ARGS__);	\
 } while (0)
 
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#define VLAN_SUPPORT
+#define CPSW_VLAN_AWARE_MODE
+#endif
+
 #define ALE_ALL_PORTS		0x7
 
 #define CPSW_MAJOR_VERSION(reg)		(reg >> 8 & 0x7)
@@ -118,6 +124,14 @@ do {								\
 #define TX_PRIORITY_MAPPING	0x33221100
 #define CPDMA_TX_PRIORITY_MAP	0x76543210
 
+#ifdef CPSW_VLAN_AWARE_MODE
+#define CPSW_VLAN_AWARE		BIT(1)
+#define CPSW_ALE_VLAN_AWARE	1
+#else
+#define CPSW_VLAN_AWARE		0x0
+#define CPSW_ALE_VLAN_AWARE	0
+#endif
+
 #define cpsw_enable_irq(priv)	\
 	do {			\
 		u32 i;		\
@@ -607,14 +621,44 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	}
 }
 
+#ifdef VLAN_SUPPORT
+static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
+{
+	writel(priv->data.default_vlan, &priv->host_port_regs->port_vlan);
+	if (priv->version == CPSW_VERSION_1) {
+		slave_write(&priv->slaves[0], priv->data.default_vlan,
+			    CPSW1_PORT_VLAN);
+		slave_write(&priv->slaves[1], priv->data.default_vlan,
+			    CPSW1_PORT_VLAN);
+	} else {
+		slave_write(&priv->slaves[0], priv->data.default_vlan,
+			    CPSW2_PORT_VLAN);
+		slave_write(&priv->slaves[1], priv->data.default_vlan,
+			    CPSW2_PORT_VLAN);
+	}
+	cpsw_ale_add_vlan(priv->ale, priv->data.default_vlan,
+			ALE_ALL_PORTS << priv->host_port,
+			ALE_ALL_PORTS << priv->host_port,
+			ALE_ALL_PORTS << priv->host_port, 0);
+}
+#else
+#define cpsw_add_default_vlan(priv)
+#endif
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
@@ -650,6 +694,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpsw_init_host_port(priv);
 	for_each_slave(priv, cpsw_slave_open, priv);
 
+	/* Add default VLAN */
+	cpsw_add_default_vlan(priv);
+
 	/* setup tx dma to fixed prio and zero offset */
 	cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
 	cpdma_control_set(priv->dma, CPDMA_RX_BUFFER_OFFSET, 0);
@@ -933,6 +980,54 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 }
 #endif
 
+#ifdef VLAN_SUPPORT
+
+static inline void cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
+				unsigned short vid)
+{
+	cpsw_ale_add_vlan(priv->ale, vid, ALE_ALL_PORTS << priv->host_port,
+			0, ALE_ALL_PORTS << priv->host_port,
+			(BIT(1) | BIT(2)) << priv->host_port);
+	cpsw_ale_vlan_add_ucast(priv->ale, priv->mac_addr,
+			priv->host_port, 0, vid);
+	cpsw_ale_vlan_add_mcast(priv->ale, priv->ndev->broadcast,
+			ALE_ALL_PORTS << priv->host_port, vid, 0, 0);
+}
+
+static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
+		unsigned short vid)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	spin_lock(&priv->lock);
+
+	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
+	cpsw_add_vlan_ale_entry(priv, vid);
+
+	spin_unlock(&priv->lock);
+	return 0;
+}
+
+static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
+		unsigned short vid)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	spin_lock(&priv->lock);
+
+	dev_info(priv->dev, "removing vlanid %d from vlan filter\n", vid);
+	cpsw_ale_del_vlan(priv->ale, vid, ALE_ALL_PORTS << priv->host_port);
+	cpsw_ale_vlan_del_ucast(priv->ale, priv->mac_addr,
+				priv->host_port, vid);
+	cpsw_ale_vlan_del_mcast(priv->ale, priv->ndev->broadcast, 0, vid);
+
+	spin_unlock(&priv->lock);
+	return 0;
+}
+
+#endif /* VLAN_SUPPORT */
+
+
 static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_open		= cpsw_ndo_open,
 	.ndo_stop		= cpsw_ndo_stop,
@@ -947,6 +1042,10 @@ static const struct net_device_ops cpsw_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cpsw_ndo_poll_controller,
 #endif
+#ifdef VLAN_SUPPORT
+	.ndo_vlan_rx_add_vid	= cpsw_ndo_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= cpsw_ndo_vlan_rx_kill_vid,
+#endif
 };
 
 static void cpsw_get_drvinfo(struct net_device *ndev,
@@ -1103,6 +1202,9 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->mac_control = prop;
 
+	if (!of_property_read_u32(node, "default_vlan", &prop))
+		data->default_vlan = prop;
+
 	/*
 	 * Populate all the child nodes here...
 	 */
@@ -1356,6 +1458,10 @@ static int cpsw_probe(struct platform_device *pdev)
 		k++;
 	}
 
+#ifdef VLAN_SUPPORT
+	ndev->features |= NETIF_F_HW_VLAN_FILTER;
+#endif
+
 	ndev->flags |= IFF_ALLMULTI;	/* see cpsw_ndo_change_rx_flags() */
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
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
