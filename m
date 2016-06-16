From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 04/17] bnx2x: Move all UDP port notifiers to
 single function
Date: Thu, 16 Jun 2016 12:21:09 -0700
Message-ID: <20160616192109.20872.75908.stgit@localhost.localdomain>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36839 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524AbcFPTVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:21:15 -0400
Received: by mail-pf0-f169.google.com with SMTP id t190so22711335pfb.3
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:21:14 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch goes through and combines the notifiers for VXLAN and GENEVE
into a single function for each action.  So there is now one combined
function for getting ports, one for adding the ports, and one for deleting
the ports.

I also went through and dropped the BNX2X VXLAN and GENEVE specific build
flags.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/broadcom/Kconfig            |   20 -----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   94 ++++++++--------------
 2 files changed, 33 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 18042c2460bd..d92c37fa8036 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -139,26 +139,6 @@ config BNX2X_SRIOV
 	  Virtualization support in the 578xx and 57712 products. This
 	  allows for virtual function acceleration in virtual environments.
 
-config BNX2X_VXLAN
-	bool "Virtual eXtensible Local Area Network support"
-	default n
-	depends on BNX2X && VXLAN && !(BNX2X=y && VXLAN=m)
-	---help---
-	  This enables hardward offload support for VXLAN protocol over the
-	  NetXtremeII series adapters.
-	  Say Y here if you want to enable hardware offload support for
-	  Virtual eXtensible Local Area Network (VXLAN) in the driver.
-
-config BNX2X_GENEVE
-	bool "Generic Network Virtualization Encapsulation (GENEVE) support"
-	depends on BNX2X && GENEVE && !(BNX2X=y && GENEVE=m)
-	---help---
-          This allows one to create GENEVE virtual interfaces that provide
-          Layer 2 Networks over Layer 3 Networks. GENEVE is often used
-          to tunnel virtual network infrastructure in virtualized environments.
-	  Say Y here if you want to enable hardware offload support for
-	  Generic Network Virtualization Encapsulation (GENEVE) in the driver.
-
 config BGMAC
 	tristate "BCMA bus GBit core support"
 	depends on BCMA && BCMA_HOST_SOC
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a59d55e25d5f..97e892511666 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -59,9 +59,6 @@
 #include <linux/semaphore.h>
 #include <linux/stringify.h>
 #include <linux/vmalloc.h>
-#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
-#include <net/geneve.h>
-#endif
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 #include "bnx2x_init_ops.h"
@@ -10076,7 +10073,6 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 	}
 }
 
-#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_BNX2X_GENEVE)
 static int bnx2x_udp_port_update(struct bnx2x *bp)
 {
 	struct bnx2x_func_switch_update_params *switch_update_params;
@@ -10177,47 +10173,42 @@ static void __bnx2x_del_udp_port(struct bnx2x *bp, u16 port,
 		DP(BNX2X_MSG_SP, "Deleted UDP tunnel [%d] port %d\n",
 		   type, port);
 }
-#endif
-
-#ifdef CONFIG_BNX2X_VXLAN
-static void bnx2x_add_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
-{
-	struct bnx2x *bp = netdev_priv(netdev);
-	u16 t_port = ntohs(port);
-
-	__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
-}
-
-static void bnx2x_del_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
-{
-	struct bnx2x *bp = netdev_priv(netdev);
-	u16 t_port = ntohs(port);
-
-	__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
-}
-#endif
 
-#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
-static void bnx2x_add_geneve_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+static void bnx2x_udp_tunnel_add(struct net_device *netdev,
+				 struct udp_tunnel_info *ti)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
-	u16 t_port = ntohs(port);
+	u16 t_port = ntohs(ti->port);
 
-	__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
+		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		__bnx2x_add_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
+		break;
+	default:
+		break;
+	}
 }
 
-static void bnx2x_del_geneve_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+static void bnx2x_udp_tunnel_del(struct net_device *netdev,
+				 struct udp_tunnel_info *ti)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
-	u16 t_port = ntohs(port);
+	u16 t_port = ntohs(ti->port);
 
-	__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_VXLAN);
+		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		__bnx2x_del_udp_port(bp, t_port, BNX2X_UDP_PORT_GENEVE);
+		break;
+	default:
+		break;
+	}
 }
-#endif
 
 static int bnx2x_close(struct net_device *dev);
 
@@ -10325,7 +10316,6 @@ sp_rtnl_not_reset:
 			       &bp->sp_rtnl_state))
 		bnx2x_update_mng_version(bp);
 
-#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_BNX2X_GENEVE)
 	if (test_and_clear_bit(BNX2X_SP_RTNL_CHANGE_UDP_PORT,
 			       &bp->sp_rtnl_state)) {
 		if (bnx2x_udp_port_update(bp)) {
@@ -10335,20 +10325,14 @@ sp_rtnl_not_reset:
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
+				udp_tunnel_get_rx_info(bp->dev);
 		}
 	}
-#endif
 
 	/* work which needs rtnl lock not-taken (as it takes the lock itself and
 	 * can be called from other contexts as well)
@@ -12551,14 +12535,8 @@ static int bnx2x_open(struct net_device *dev)
 	if (rc)
 		return rc;
 
-#ifdef CONFIG_BNX2X_VXLAN
-	if (IS_PF(bp))
-		vxlan_get_rx_port(dev);
-#endif
-#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
 	if (IS_PF(bp))
-		geneve_get_rx_port(dev);
-#endif
+		udp_tunnel_get_rx_info(dev);
 
 	return 0;
 }
@@ -13045,14 +13023,8 @@ static const struct net_device_ops bnx2x_netdev_ops = {
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
+	.ndo_udp_tunnel_add	= bnx2x_udp_tunnel_add,
+	.ndo_udp_tunnel_del	= bnx2x_udp_tunnel_del,
 };
 
 static int bnx2x_set_coherency_mask(struct bnx2x *bp)
