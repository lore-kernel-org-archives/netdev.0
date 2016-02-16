From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/5] bnx2x: Add Geneve inner-RSS support
Date: Tue, 16 Feb 2016 18:07:58 +0200
Message-ID: <1455638881-2527-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:6510 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932261AbcBPQIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 11:08:45 -0500
In-Reply-To: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the ability to perform RSS hashing based on encapsulated
headers for a geneve-encapsulated packet.

This also changes the Vxlan implementation in bnx2x to be uniform
for both vxlan and geneve [from configuration perspective].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  19 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |  11 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 175 ++++++++++++++++-------
 3 files changed, 146 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index cae0956..7dd7490 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1277,8 +1277,7 @@ enum sp_rtnl_flag {
 	BNX2X_SP_RTNL_HYPERVISOR_VLAN,
 	BNX2X_SP_RTNL_TX_STOP,
 	BNX2X_SP_RTNL_GET_DRV_VERSION,
-	BNX2X_SP_RTNL_ADD_VXLAN_PORT,
-	BNX2X_SP_RTNL_DEL_VXLAN_PORT,
+	BNX2X_SP_RTNL_CHANGE_UDP_PORT,
 };
 
 enum bnx2x_iov_flag {
@@ -1327,6 +1326,17 @@ struct bnx2x_vlan_entry {
 	bool hw;
 };
 
+enum bnx2x_udp_port_type {
+	BNX2X_UDP_PORT_VXLAN,
+	BNX2X_UDP_PORT_GENEVE,
+	BNX2X_UDP_PORT_MAX,
+};
+
+struct bnx2x_udp_tunnel {
+	u16 dst_port;
+	u8 count;
+};
+
 struct bnx2x {
 	/* Fields used in the tx and intr/napi performance paths
 	 * are grouped together in the beginning of the structure
@@ -1830,9 +1840,10 @@ struct bnx2x {
 	struct list_head vlan_reg;
 	u16 vlan_cnt;
 	u16 vlan_credit;
-	u16 vxlan_dst_port;
-	u8 vxlan_dst_port_count;
 	bool accept_any_vlan;
+
+	/* Vxlan/Geneve related information */
+	struct bnx2x_udp_tunnel udp_tunnel_ports[BNX2X_UDP_PORT_MAX];
 };
 
 /* Tx queues may be less or equal to Rx queues */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 4cbb03f8..3736986 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -923,6 +923,7 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 	struct bnx2x_func_state_params func_params = {NULL};
 	struct bnx2x_func_start_params *start_params =
 		&func_params.params.start;
+	u16 port;
 
 	/* Prepare parameters for function state transitions */
 	__set_bit(RAMROD_COMP_WAIT, &func_params.ramrod_flags);
@@ -959,8 +960,14 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 		start_params->network_cos_mode = STATIC_COS;
 	else /* CHIP_IS_E1X */
 		start_params->network_cos_mode = FW_WRR;
-
-	start_params->vxlan_dst_port = bp->vxlan_dst_port;
+	if (bp->udp_tunnel_ports[BNX2X_UDP_PORT_VXLAN].count) {
+		port = bp->udp_tunnel_ports[BNX2X_UDP_PORT_VXLAN].dst_port;
+		start_params->vxlan_dst_port = port;
+	}
+	if (bp->udp_tunnel_ports[BNX2X_UDP_PORT_GENEVE].count) {
+		port = bp->udp_tunnel_ports[BNX2X_UDP_PORT_GENEVE].dst_port;
+		start_params->geneve_dst_port = port;
+	}
 
 	start_params->inner_rss = 1;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6c4e3a6..5d6b2d9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -59,7 +59,9 @@
 #include <linux/semaphore.h>
 #include <linux/stringify.h>
 #include <linux/vmalloc.h>
-
+#if IS_ENABLED(CONFIG_GENEVE)
+#include <net/geneve.h>
+#endif
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 #include "bnx2x_init_ops.h"
@@ -10076,11 +10078,13 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 	}
 }
 
-#ifdef CONFIG_BNX2X_VXLAN
-static int bnx2x_vxlan_port_update(struct bnx2x *bp, u16 port)
+#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
+static int bnx2x_udp_port_update(struct bnx2x *bp)
 {
 	struct bnx2x_func_switch_update_params *switch_update_params;
 	struct bnx2x_func_state_params func_params = {NULL};
+	struct bnx2x_udp_tunnel *udp_tunnel;
+	u16 vxlan_port = 0, geneve_port = 0;
 	int rc;
 
 	switch_update_params = &func_params.params.switch_update;
@@ -10095,69 +10099,125 @@ static int bnx2x_vxlan_port_update(struct bnx2x *bp, u16 port)
 	/* Function parameters */
 	__set_bit(BNX2X_F_UPDATE_TUNNEL_CFG_CHNG,
 		  &switch_update_params->changes);
-	switch_update_params->vxlan_dst_port = port;
+
+	if (bp->udp_tunnel_ports[BNX2X_UDP_PORT_GENEVE].count) {
+		udp_tunnel = &bp->udp_tunnel_ports[BNX2X_UDP_PORT_GENEVE];
+		geneve_port = udp_tunnel->dst_port;
+		switch_update_params->geneve_dst_port = geneve_port;
+	}
+
+	if (bp->udp_tunnel_ports[BNX2X_UDP_PORT_VXLAN].count) {
+		udp_tunnel = &bp->udp_tunnel_ports[BNX2X_UDP_PORT_VXLAN];
+		vxlan_port = udp_tunnel->dst_port;
+		switch_update_params->vxlan_dst_port = vxlan_port;
+	}
+
+	/* Re-enable inner-rss for the offloaded UDP tunnels */
+	__set_bit(BNX2X_F_UPDATE_TUNNEL_INNER_RSS,
+		  &switch_update_params->changes);
+
 	rc = bnx2x_func_state_change(bp, &func_params);
 	if (rc)
-		BNX2X_ERR("failed to change vxlan dst port to %d (rc = 0x%x)\n",
-			  port, rc);
+		BNX2X_ERR("failed to set UDP dst port to %04x %04x (rc = 0x%x)\n",
+			  vxlan_port, geneve_port, rc);
+	else
+		DP(BNX2X_MSG_SP,
+		   "Configured UDP ports: Vxlan [%04x] Geneve [%04x]\n",
+		   vxlan_port, geneve_port);
+
 	return rc;
 }
 
-static void __bnx2x_add_vxlan_port(struct bnx2x *bp, u16 port)
+static void __bnx2x_add_udp_port(struct bnx2x *bp, u16 port,
+				 enum bnx2x_udp_port_type type)
 {
-	if (!netif_running(bp->dev))
+	struct bnx2x_udp_tunnel *udp_port = &bp->udp_tunnel_ports[type];
+
+	if (!netif_running(bp->dev) || !IS_PF(bp))
+		return;
+
+	if (udp_port->count && udp_port->dst_port == port) {
+		udp_port->count++;
 		return;
+	}
 
-	if (bp->vxlan_dst_port_count && bp->vxlan_dst_port == port) {
-		bp->vxlan_dst_port_count++;
+	if (udp_port->count) {
+		DP(BNX2X_MSG_SP,
+		   "UDP tunnel [%d] -  destination port limit reached\n",
+		   type);
 		return;
 	}
 
-	if (bp->vxlan_dst_port_count || !IS_PF(bp)) {
-		DP(BNX2X_MSG_SP, "Vxlan destination port limit reached\n");
+	udp_port->dst_port = port;
+	udp_port->count = 1;
+	bnx2x_schedule_sp_rtnl(bp, BNX2X_SP_RTNL_CHANGE_UDP_PORT, 0);
+}
+
+static void __bnx2x_del_udp_port(struct bnx2x *bp, u16 port,
+				 enum bnx2x_udp_port_type type)
+{
+	struct bnx2x_udp_tunnel *udp_port = &bp->udp_tunnel_ports[type];
+
+	if (!IS_PF(bp))
+		return;
+
+	if (!udp_port->count || udp_port->dst_port != port) {
+		DP(BNX2X_MSG_SP, "Invalid UDP tunnel [%d] port\n",
+		   type);
 		return;
 	}
 
-	bp->vxlan_dst_port = port;
-	bp->vxlan_dst_port_count = 1;
-	bnx2x_schedule_sp_rtnl(bp, BNX2X_SP_RTNL_ADD_VXLAN_PORT, 0);
+	/* Remove reference, and make certain it's no longer in use */
+	udp_port->count--;
+	if (udp_port->count)
+		return;
+	udp_port->dst_port = 0;
+
+	if (netif_running(bp->dev))
+		bnx2x_schedule_sp_rtnl(bp, BNX2X_SP_RTNL_CHANGE_UDP_PORT, 0);
+	else
+		DP(BNX2X_MSG_SP, "Deleted UDP tunnel [%d] port %d\n",
+		   type, port);
 }
+#endif
 
+#ifdef CONFIG_BNX2X_VXLAN
 static void bnx2x_add_vxlan_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	u16 t_port = ntohs(port);
 
-	__bnx2x_add_vxlan_port(bp, t_port);
+	__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
 }
 
-static void __bnx2x_del_vxlan_port(struct bnx2x *bp, u16 port)
+static void bnx2x_del_vxlan_port(struct net_device *netdev,
+				 sa_family_t sa_family, __be16 port)
 {
-	if (!bp->vxlan_dst_port_count || bp->vxlan_dst_port != port ||
-	    !IS_PF(bp)) {
-		DP(BNX2X_MSG_SP, "Invalid vxlan port\n");
-		return;
-	}
-	bp->vxlan_dst_port_count--;
-	if (bp->vxlan_dst_port_count)
-		return;
+	struct bnx2x *bp = netdev_priv(netdev);
+	u16 t_port = ntohs(port);
 
-	if (netif_running(bp->dev)) {
-		bnx2x_schedule_sp_rtnl(bp, BNX2X_SP_RTNL_DEL_VXLAN_PORT, 0);
-	} else {
-		bp->vxlan_dst_port = 0;
-		netdev_info(bp->dev, "Deleted vxlan dest port %d", port);
-	}
+	__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
+}
+#endif
+
+#if IS_ENABLED(CONFIG_GENEVE)
+static void bnx2x_add_geneve_port(struct net_device *netdev,
+				  sa_family_t sa_family, __be16 port)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u16 t_port = ntohs(port);
+
+	__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
 }
 
-static void bnx2x_del_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+static void bnx2x_del_geneve_port(struct net_device *netdev,
+				  sa_family_t sa_family, __be16 port)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	u16 t_port = ntohs(port);
 
-	__bnx2x_del_vxlan_port(bp, t_port);
+	__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
 }
 #endif
 
@@ -10169,9 +10229,6 @@ static int bnx2x_close(struct net_device *dev);
 static void bnx2x_sp_rtnl_task(struct work_struct *work)
 {
 	struct bnx2x *bp = container_of(work, struct bnx2x, sp_rtnl_task.work);
-#ifdef CONFIG_BNX2X_VXLAN
-	u16 port;
-#endif
 
 	rtnl_lock();
 
@@ -10270,23 +10327,27 @@ sp_rtnl_not_reset:
 			       &bp->sp_rtnl_state))
 		bnx2x_update_mng_version(bp);
 
-#ifdef CONFIG_BNX2X_VXLAN
-	port = bp->vxlan_dst_port;
-	if (test_and_clear_bit(BNX2X_SP_RTNL_ADD_VXLAN_PORT,
-			       &bp->sp_rtnl_state)) {
-		if (!bnx2x_vxlan_port_update(bp, port))
-			netdev_info(bp->dev, "Added vxlan dest port %d", port);
-		else
-			bp->vxlan_dst_port = 0;
-	}
-
-	if (test_and_clear_bit(BNX2X_SP_RTNL_DEL_VXLAN_PORT,
+#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
+	if (test_and_clear_bit(BNX2X_SP_RTNL_CHANGE_UDP_PORT,
 			       &bp->sp_rtnl_state)) {
-		if (!bnx2x_vxlan_port_update(bp, 0)) {
-			netdev_info(bp->dev,
-				    "Deleted vxlan dest port %d", port);
-			bp->vxlan_dst_port = 0;
-			vxlan_get_rx_port(bp->dev);
+		if (bnx2x_udp_port_update(bp)) {
+			/* On error, forget configuration */
+			memset(bp->udp_tunnel_ports, 0,
+			       sizeof(struct bnx2x_udp_tunnel) *
+			       BNX2X_UDP_PORT_MAX);
+		} else {
+			/* Since we don't store additional port information,
+			 * if no port is configured for any feature ask for
+			 * information about currently configured ports.
+			 */
+#ifdef CONFIG_BNX2X_VXLAN
+			if (!bp->udp_tunnel_ports[BNX2X_UDP_PORT_VXLAN].count)
+				vxlan_get_rx_port(bp->dev);
+#endif
+#if IS_ENABLED(CONFIG_GENEVE)
+			if (!bp->udp_tunnel_ports[BNX2X_UDP_PORT_GENEVE].count)
+				geneve_get_rx_port(bp->dev);
+#endif
 		}
 	}
 #endif
@@ -12494,6 +12555,10 @@ static int bnx2x_open(struct net_device *dev)
 	if (IS_PF(bp))
 		vxlan_get_rx_port(dev);
 #endif
+#if IS_ENABLED(CONFIG_GENEVE)
+	if (IS_PF(bp))
+		geneve_get_rx_port(dev);
+#endif
 
 	return 0;
 }
@@ -13011,6 +13076,10 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_add_vxlan_port	= bnx2x_add_vxlan_port,
 	.ndo_del_vxlan_port	= bnx2x_del_vxlan_port,
 #endif
+#if IS_ENABLED(CONFIG_GENEVE)
+	.ndo_add_geneve_port	= bnx2x_add_geneve_port,
+	.ndo_del_geneve_port	= bnx2x_del_geneve_port,
+#endif
 };
 
 static int bnx2x_set_coherency_mask(struct bnx2x *bp)
-- 
1.9.3
