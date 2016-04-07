From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 1/2] drivers: net: cpsw: fix port_mask parameters in ale calls
Date: Thu, 7 Apr 2016 15:16:43 +0300
Message-ID: <1460031404-28594-2-git-send-email-grygorii.strashko@ti.com>
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

ALE APIs expect to receive port masks as input values for arguments
port_mask, untag, reg_mcast, unreg_mcast. But there are few places in
code where port masks are passed left-shifted by cpsw_priv->host_port,
like below:

 cpsw_ale_add_vlan(priv->ale, priv->data.default_vlan,
		  ALE_ALL_PORTS << priv->host_port,
		  ALE_ALL_PORTS << priv->host_port, 0, 0);

and cpsw is still working just because priv->host_port == 0
and has never ever been changed.

Hence, fix port_mask parameters in ALE APIs calls and drop
"<< priv->host_port" from all places where it's used to
shift valid port mask.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 42fdfd4..5292e70 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -535,7 +535,7 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 				ALE_VLAN, slave->port_vlan, 0);		\
 		} else {						\
 			cpsw_ale_add_mcast(priv->ale, addr,		\
-				ALE_ALL_PORTS << priv->host_port,	\
+				ALE_ALL_PORTS,				\
 				0, 0, 0);				\
 		}							\
 	} while (0)
@@ -602,8 +602,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 			cpsw_ale_control_set(ale, 0, ALE_AGEOUT, 1);
 
 			/* Clear all mcast from ALE */
-			cpsw_ale_flush_multicast(ale, ALE_ALL_PORTS <<
-						 priv->host_port, -1);
+			cpsw_ale_flush_multicast(ale, ALE_ALL_PORTS, -1);
 
 			/* Flood All Unicast Packets to Host port */
 			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 1);
@@ -648,8 +647,7 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	cpsw_ale_set_allmulti(priv->ale, priv->ndev->flags & IFF_ALLMULTI);
 
 	/* Clear all mcast from ALE */
-	cpsw_ale_flush_multicast(priv->ale, ALE_ALL_PORTS << priv->host_port,
-				 vid);
+	cpsw_ale_flush_multicast(priv->ale, ALE_ALL_PORTS, vid);
 
 	if (!netdev_mc_empty(ndev)) {
 		struct netdev_hw_addr *ha;
@@ -1172,7 +1170,6 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 {
 	const int vlan = priv->data.default_vlan;
-	const int port = priv->host_port;
 	u32 reg;
 	int i;
 	int unreg_mcast_mask;
@@ -1190,9 +1187,9 @@ static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 	else
 		unreg_mcast_mask = ALE_PORT_1 | ALE_PORT_2;
 
-	cpsw_ale_add_vlan(priv->ale, vlan, ALE_ALL_PORTS << port,
-			  ALE_ALL_PORTS << port, ALE_ALL_PORTS << port,
-			  unreg_mcast_mask << port);
+	cpsw_ale_add_vlan(priv->ale, vlan, ALE_ALL_PORTS,
+			  ALE_ALL_PORTS, ALE_ALL_PORTS,
+			  unreg_mcast_mask);
 }
 
 static void cpsw_init_host_port(struct cpsw_priv *priv)
@@ -1273,8 +1270,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_add_default_vlan(priv);
 	else
 		cpsw_ale_add_vlan(priv->ale, priv->data.default_vlan,
-				  ALE_ALL_PORTS << priv->host_port,
-				  ALE_ALL_PORTS << priv->host_port, 0, 0);
+				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
 	if (!cpsw_common_res_usage_state(priv)) {
 		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
@@ -1666,7 +1662,7 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
 	}
 
 	ret = cpsw_ale_add_vlan(priv->ale, vid, port_mask, 0, port_mask,
-				unreg_mcast_mask << priv->host_port);
+				unreg_mcast_mask);
 	if (ret != 0)
 		return ret;
 
@@ -1738,7 +1734,7 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 		return ret;
 
 	ret = cpsw_ale_del_ucast(priv->ale, priv->mac_addr,
-				 priv->host_port, ALE_VLAN, vid);
+				 HOST_PORT_NUM, ALE_VLAN, vid);
 	if (ret != 0)
 		return ret;
 
-- 
2.8.0
