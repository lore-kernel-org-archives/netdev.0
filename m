From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 1/1] drivers: net: cpsw: enable promiscuous mode support
Date: Thu, 23 Jan 2014 00:03:12 +0530
Message-ID: <1390415592-13719-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:46182 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbaAVSdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 13:33:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable promiscuous mode support for CPSW.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c     | 105 ++++++++++++++++++++++++++++---------
 drivers/net/ethernet/ti/cpsw_ale.c |  16 ++++++
 drivers/net/ethernet/ti/cpsw_ale.h |   2 +
 3 files changed, 98 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e8bb77d..bde63e3 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -541,14 +541,93 @@ static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
 		return slave_num;
 }
 
+static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_ale *ale = priv->ale;
+	int i;
+
+	if (priv->data.dual_emac) {
+		bool flag = false;
+
+		/* Enabling promiscuous mode for one interface will be
+		 * common for both the interface as the interface shares
+		 * the same hardware resource.
+		 */
+		for (i = 0; i <= priv->data.slaves; i++)
+			if (priv->slaves[i].ndev->flags & IFF_PROMISC)
+				flag = true;
+
+		if (!enable && flag) {
+			enable = true;
+			dev_err(&ndev->dev, "promiscuity not disabled as the other interface is still in promiscuity mode\n");
+		}
+
+		if (enable) {
+			/* Enable Bypass */
+			cpsw_ale_control_set(ale, 0, ALE_BYPASS, 1);
+
+			dev_dbg(&ndev->dev, "promiscuity enabled\n");
+		} else {
+			/* Disable Bypass */
+			cpsw_ale_control_set(ale, 0, ALE_BYPASS, 0);
+			dev_dbg(&ndev->dev, "promiscuity disabled\n");
+		}
+	} else {
+		if (enable) {
+			unsigned long timeout = jiffies + HZ;
+
+			/* Disable Learn for all ports */
+			for (i = 0; i <= priv->data.slaves; i++) {
+				cpsw_ale_control_set(ale, i,
+						     ALE_PORT_NOLEARN, 1);
+				cpsw_ale_control_set(ale, i,
+						     ALE_PORT_NO_SA_UPDATE, 1);
+			}
+
+			/* Clear All Untouched entries */
+			cpsw_ale_control_set(ale, 0, ALE_AGEOUT, 1);
+			do {
+				cpu_relax();
+				if (cpsw_ale_control_get(ale, 0, ALE_AGEOUT))
+					break;
+			} while (time_after(timeout, jiffies));
+			cpsw_ale_control_set(ale, 0, ALE_AGEOUT, 1);
+
+			/* Clear all mcast from ALE */
+			cpsw_ale_flush_multicast(ale, ALE_ALL_PORTS <<
+						 priv->host_port);
+
+			/* Flood All Unicast Packets to Host port */
+			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 1);
+			dev_dbg(&ndev->dev, "promiscuity enabled\n");
+		} else {
+			/* Flood All Unicast Packets to Host port */
+			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 0);
+
+			/* Enable Learn for all ports */
+			for (i = 0; i <= priv->data.slaves; i++) {
+				cpsw_ale_control_set(ale, i,
+						     ALE_PORT_NOLEARN, 0);
+				cpsw_ale_control_set(ale, i,
+						     ALE_PORT_NO_SA_UPDATE, 0);
+			}
+			dev_dbg(&ndev->dev, "promiscuity disabled\n");
+		}
+	}
+}
+
 static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
 	if (ndev->flags & IFF_PROMISC) {
 		/* Enable promiscuous mode */
-		dev_err(priv->dev, "Ignoring Promiscuous mode\n");
+		cpsw_set_promiscious(ndev, true);
 		return;
+	} else {
+		/* Disable promiscuous mode */
+		cpsw_set_promiscious(ndev, false);
 	}
 
 	/* Clear all mcast from ALE */
@@ -1257,29 +1336,6 @@ fail:
 	return NETDEV_TX_BUSY;
 }
 
-static void cpsw_ndo_change_rx_flags(struct net_device *ndev, int flags)
-{
-	/*
-	 * The switch cannot operate in promiscuous mode without substantial
-	 * headache.  For promiscuous mode to work, we would need to put the
-	 * ALE in bypass mode and route all traffic to the host port.
-	 * Subsequently, the host will need to operate as a "bridge", learn,
-	 * and flood as needed.  For now, we simply complain here and
-	 * do nothing about it :-)
-	 */
-	if ((flags & IFF_PROMISC) && (ndev->flags & IFF_PROMISC))
-		dev_err(&ndev->dev, "promiscuity ignored!\n");
-
-	/*
-	 * The switch cannot filter multicast traffic unless it is configured
-	 * in "VLAN Aware" mode.  Unfortunately, VLAN awareness requires a
-	 * whole bunch of additional logic that this driver does not implement
-	 * at present.
-	 */
-	if ((flags & IFF_ALLMULTI) && !(ndev->flags & IFF_ALLMULTI))
-		dev_err(&ndev->dev, "multicast traffic cannot be filtered!\n");
-}
-
 #ifdef CONFIG_TI_CPTS
 
 static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
@@ -1575,7 +1631,6 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_open		= cpsw_ndo_open,
 	.ndo_stop		= cpsw_ndo_stop,
 	.ndo_start_xmit		= cpsw_ndo_start_xmit,
-	.ndo_change_rx_flags	= cpsw_ndo_change_rx_flags,
 	.ndo_set_mac_address	= cpsw_ndo_set_mac_address,
 	.ndo_do_ioctl		= cpsw_ndo_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 63e9819..7f89306 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -477,6 +477,14 @@ static const struct ale_control_info ale_controls[ALE_NUM_CONTROLS] = {
 		.port_shift	= 0,
 		.bits		= 1,
 	},
+	[ALE_P0_UNI_FLOOD]	= {
+		.name		= "port0_unicast_flood",
+		.offset		= ALE_CONTROL,
+		.port_offset	= 0,
+		.shift		= 8,
+		.port_shift	= 0,
+		.bits		= 1,
+	},
 	[ALE_VLAN_NOLEARN]	= {
 		.name		= "vlan_nolearn",
 		.offset		= ALE_CONTROL,
@@ -573,6 +581,14 @@ static const struct ale_control_info ale_controls[ALE_NUM_CONTROLS] = {
 		.port_shift	= 0,
 		.bits		= 1,
 	},
+	[ALE_PORT_NO_SA_UPDATE]	= {
+		.name		= "no_source_update",
+		.offset		= ALE_PORTCTL,
+		.port_offset	= 4,
+		.shift		= 5,
+		.port_shift	= 0,
+		.bits		= 1,
+	},
 	[ALE_PORT_MCAST_LIMIT]	= {
 		.name		= "mcast_limit",
 		.offset		= ALE_PORTCTL,
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index 30daa12..de409c3 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -34,6 +34,7 @@ enum cpsw_ale_control {
 	ALE_ENABLE,
 	ALE_CLEAR,
 	ALE_AGEOUT,
+	ALE_P0_UNI_FLOOD,
 	ALE_VLAN_NOLEARN,
 	ALE_NO_PORT_VLAN,
 	ALE_OUI_DENY,
@@ -47,6 +48,7 @@ enum cpsw_ale_control {
 	ALE_PORT_DROP_UNTAGGED,
 	ALE_PORT_DROP_UNKNOWN_VLAN,
 	ALE_PORT_NOLEARN,
+	ALE_PORT_NO_SA_UPDATE,
 	ALE_PORT_UNKNOWN_VLAN_MEMBER,
 	ALE_PORT_UNKNOWN_MCAST_FLOOD,
 	ALE_PORT_UNKNOWN_REG_MCAST_FLOOD,
-- 
1.9.rc0
