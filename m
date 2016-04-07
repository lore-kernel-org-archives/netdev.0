From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 2/2] drivers: net: cpsw: drop host_port field from struct cpsw_priv
Date: Thu, 7 Apr 2016 15:16:44 +0300
Message-ID: <1460031404-28594-3-git-send-email-grygorii.strashko@ti.com>
References: <1460031404-28594-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460031404-28594-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The host_port field is constantly assigned to 0 and this value has
never changed (since time when cpsw driver was introduced. More over,
if this field will be assigned to non 0 value it will break current
driver functionality.

Hence, there are no reasons to continue maintaining this host_port
field and it can be removed, and the HOST_PORT_NUM and ALE_PORT_HOST
defines can be used instead.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 30 ++++++++++++------------------
 1 file changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5292e70..54bcc38 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -381,7 +381,6 @@ struct cpsw_priv {
 	u32				coal_intvl;
 	u32				bus_freq_mhz;
 	int				rx_packet_max;
-	int				host_port;
 	struct clk			*clk;
 	u8				mac_addr[ETH_ALEN];
 	struct cpsw_slave		*slaves;
@@ -531,7 +530,7 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 			int slave_port = cpsw_get_slave_port(priv,	\
 						slave->slave_num);	\
 			cpsw_ale_add_mcast(priv->ale, addr,		\
-				1 << slave_port | 1 << priv->host_port,	\
+				1 << slave_port | ALE_PORT_HOST,	\
 				ALE_VLAN, slave->port_vlan, 0);		\
 		} else {						\
 			cpsw_ale_add_mcast(priv->ale, addr,		\
@@ -542,10 +541,7 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 
 static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
 {
-	if (priv->host_port == 0)
-		return slave_num + 1;
-	else
-		return slave_num;
+	return slave_num + 1;
 }
 
 static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
@@ -1090,7 +1086,7 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
 		struct cpsw_priv *priv, struct cpsw_slave *slave,
 		u32 slave_port)
 {
-	u32 port_mask = 1 << slave_port | 1 << priv->host_port;
+	u32 port_mask = 1 << slave_port | ALE_PORT_HOST;
 
 	if (priv->version == CPSW_VERSION_1)
 		slave_write(slave, slave->port_vlan, CPSW1_PORT_VLAN);
@@ -1101,7 +1097,7 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
 	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 			   port_mask, ALE_VLAN, slave->port_vlan, 0);
 	cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
-		priv->host_port, ALE_VLAN | ALE_SECURE, slave->port_vlan);
+		HOST_PORT_NUM, ALE_VLAN | ALE_SECURE, slave->port_vlan);
 }
 
 static void soft_reset_slave(struct cpsw_slave *slave)
@@ -1202,7 +1198,7 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	cpsw_ale_start(priv->ale);
 
 	/* switch to vlan unaware mode */
-	cpsw_ale_control_set(priv->ale, priv->host_port, ALE_VLAN_AWARE,
+	cpsw_ale_control_set(priv->ale, HOST_PORT_NUM, ALE_VLAN_AWARE,
 			     CPSW_ALE_VLAN_AWARE);
 	control_reg = readl(&priv->regs->control);
 	control_reg |= CPSW_VLAN_AWARE;
@@ -1216,14 +1212,14 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 		     &priv->host_port_regs->cpdma_tx_pri_map);
 	__raw_writel(0, &priv->host_port_regs->cpdma_rx_chan_map);
 
-	cpsw_ale_control_set(priv->ale, priv->host_port,
+	cpsw_ale_control_set(priv->ale, HOST_PORT_NUM,
 			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
 	if (!priv->data.dual_emac) {
-		cpsw_ale_add_ucast(priv->ale, priv->mac_addr, priv->host_port,
+		cpsw_ale_add_ucast(priv->ale, priv->mac_addr, HOST_PORT_NUM,
 				   0, 0);
 		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
-				   1 << priv->host_port, 0, 0, ALE_MCAST_FWD_2);
+				   ALE_PORT_HOST, 0, 0, ALE_MCAST_FWD_2);
 	}
 }
 
@@ -1616,9 +1612,9 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 		flags = ALE_VLAN;
 	}
 
-	cpsw_ale_del_ucast(priv->ale, priv->mac_addr, priv->host_port,
+	cpsw_ale_del_ucast(priv->ale, priv->mac_addr, HOST_PORT_NUM,
 			   flags, vid);
-	cpsw_ale_add_ucast(priv->ale, addr->sa_data, priv->host_port,
+	cpsw_ale_add_ucast(priv->ale, addr->sa_data, HOST_PORT_NUM,
 			   flags, vid);
 
 	memcpy(priv->mac_addr, addr->sa_data, ETH_ALEN);
@@ -1667,7 +1663,7 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
 		return ret;
 
 	ret = cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
-				 priv->host_port, ALE_VLAN, vid);
+				 HOST_PORT_NUM, ALE_VLAN, vid);
 	if (ret != 0)
 		goto clean_vid;
 
@@ -1679,7 +1675,7 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
 
 clean_vlan_ucast:
 	cpsw_ale_del_ucast(priv->ale, priv->mac_addr,
-			    priv->host_port, ALE_VLAN, vid);
+			   HOST_PORT_NUM, ALE_VLAN, vid);
 clean_vid:
 	cpsw_ale_del_vlan(priv->ale, vid, 0);
 	return ret;
@@ -2148,7 +2144,6 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	priv_sl2->bus_freq_mhz = priv->bus_freq_mhz;
 
 	priv_sl2->regs = priv->regs;
-	priv_sl2->host_port = priv->host_port;
 	priv_sl2->host_port_regs = priv->host_port_regs;
 	priv_sl2->wr_regs = priv->wr_regs;
 	priv_sl2->hw_stats = priv->hw_stats;
@@ -2317,7 +2312,6 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 	priv->regs = ss_regs;
-	priv->host_port = HOST_PORT_NUM;
 
 	/* Need to enable clocks with runtime PM api to access module
 	 * registers
-- 
2.8.0
