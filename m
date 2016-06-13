From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 03/15] bnx2x: Move all UDP port notifiers to single
 function
Date: Mon, 13 Jun 2016 10:48:15 -0700
Message-ID: <20160613174815.15186.73559.stgit@localhost.localdomain>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33289 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423227AbcFMRsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:48:18 -0400
Received: by mail-pa0-f53.google.com with SMTP id b13so25415782pat.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:48:18 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch goes through and combines the notifiers for VXLAN and GENEVE
into a single function for each action.  So there is now one combined
function for getting ports, one for adding the ports, and one for deleting
the ports.

While going through and updating this I also removed the use of IS_ENABLED
for the CONFIG_BNX2X_GENEVE checks and instead just checked for defined
since there is no option to have this as a module.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   96 ++++++++++------------
 1 file changed, 44 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a59d55e25d5f..8faef81aff89 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -59,7 +59,7 @@
 #include <linux/semaphore.h>
 #include <linux/stringify.h>
 #include <linux/vmalloc.h>
-#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
+#ifdef CONFIG_BNX2X_GENEVE
 #include <net/geneve.h>
 #endif
 #include "bnx2x.h"
@@ -10076,7 +10076,7 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 	}
 }
 
-#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_BNX2X_GENEVE)
+#if defined(CONFIG_BNX2X_VXLAN) || defined(CONFIG_BNX2X_GENEVE)
 static int bnx2x_udp_port_update(struct bnx2x *bp)
 {
 	struct bnx2x_func_switch_update_params *switch_update_params;
@@ -10177,46 +10177,53 @@ static void __bnx2x_del_udp_port(struct bnx2x *bp, u16 port,
 		DP(BNX2X_MSG_SP, "Deleted UDP tunnel [%d] port %d\n",
 		   type, port);
 }
-#endif
 
-#ifdef CONFIG_BNX2X_VXLAN
-static void bnx2x_add_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+static void bnx2x_add_udp_enc_port(struct net_device *netdev,
+				   sa_family_t sa_family, __be16 port,
+				   unsigned int type)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	u16 t_port = ntohs(port);
 
-	__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
+	switch (type) {
+#ifdef CONFIG_BNX2X_VXLAN
+	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
+		__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
+		break;
+#endif
+#ifdef CONFIG_BNX2X_GENEVE
+	case UDP_ENC_OFFLOAD_TYPE_GENEVE:
+		__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
+		break;
+#endif
+	default:
+		break;
+	}
 }
 
-static void bnx2x_del_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+static void bnx2x_del_udp_enc_port(struct net_device *netdev,
+				   sa_family_t sa_family, __be16 port,
+				   unsigned int type)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	u16 t_port = ntohs(port);
 
-	__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
-}
+	switch (type) {
+#ifdef CONFIG_BNX2X_VXLAN
+	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
+		__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
+		break;
 #endif
-
-#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
-static void bnx2x_add_geneve_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
-{
-	struct bnx2x *bp = netdev_priv(netdev);
-	u16 t_port = ntohs(port);
-
-	__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
+#ifdef CONFIG_BNX2X_GENEVE
+	case UDP_ENC_OFFLOAD_TYPE_GENEVE:
+		__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
+		break;
+#endif
+	default:
+		break;
+	}
 }
 
-static void bnx2x_del_geneve_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
-{
-	struct bnx2x *bp = netdev_priv(netdev);
-	u16 t_port = ntohs(port);
-
-	__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
-}
 #endif
 
 static int bnx2x_close(struct net_device *dev);
@@ -10325,7 +10332,7 @@ sp_rtnl_not_reset:
 			       &bp->sp_rtnl_state))
 		bnx2x_update_mng_version(bp);
 
-#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_BNX2X_GENEVE)
+#if defined(CONFIG_BNX2X_VXLAN) || defined(CONFIG_BNX2X_GENEVE)
 	if (test_and_clear_bit(BNX2X_SP_RTNL_CHANGE_UDP_PORT,
 			       &bp->sp_rtnl_state)) {
 		if (bnx2x_udp_port_update(bp)) {
@@ -10335,17 +10342,12 @@ sp_rtnl_not_reset:
 			       BNX2X_UDP_PORT_MAX);
 		} else {
 			/* Since we don't store additional port information,
-			 * if no port is configured for any feature ask for
+			 * if no ports are configured for any feature ask for
 			 * information about currently configured ports.
 			 */
-#ifdef CONFIG_BNX2X_VXLAN
-			if (!bp->udp_tunnel_ports[BNX2X_UDP_PORT_VXLAN].count)
-				vxlan_get_rx_port(bp->dev);
-#endif
-#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
-			if (!bp->udp_tunnel_ports[BNX2X_UDP_PORT_GENEVE].count)
-				geneve_get_rx_port(bp->dev);
-#endif
+			if (!bp->udp_tunnel_ports[BNX2X_UDP_PORT_VXLAN].count &&
+			    !bp->udp_tunnel_ports[BNX2X_UDP_PORT_GENEVE].count)
+				udp_tunnel_get_rx_port(bp->dev);
 		}
 	}
 #endif
@@ -12551,13 +12553,9 @@ static int bnx2x_open(struct net_device *dev)
 	if (rc)
 		return rc;
 
-#ifdef CONFIG_BNX2X_VXLAN
+#if defined(CONFIG_BNX2X_VXLAN) || defined(CONFIG_BNX2X_GENEVE)
 	if (IS_PF(bp))
-		vxlan_get_rx_port(dev);
-#endif
-#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
-	if (IS_PF(bp))
-		geneve_get_rx_port(dev);
+		udp_tunnel_get_rx_port(dev);
 #endif
 
 	return 0;
@@ -13045,14 +13043,8 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_get_phys_port_id	= bnx2x_get_phys_port_id,
 	.ndo_set_vf_link_state	= bnx2x_set_vf_link_state,
 	.ndo_features_check	= bnx2x_features_check,
-#ifdef CONFIG_BNX2X_VXLAN
-	.ndo_add_vxlan_port	= bnx2x_add_vxlan_port,
-	.ndo_del_vxlan_port	= bnx2x_del_vxlan_port,
-#endif
-#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
-	.ndo_add_geneve_port	= bnx2x_add_geneve_port,
-	.ndo_del_geneve_port	= bnx2x_del_geneve_port,
-#endif
+	.ndo_add_udp_enc_port	= bnx2x_add_udp_enc_port,
+	.ndo_del_udp_enc_port	= bnx2x_del_udp_enc_port,
 };
 
 static int bnx2x_set_coherency_mask(struct bnx2x *bp)
