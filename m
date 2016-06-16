From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 09/17] i40e: Move all UDP port notifiers to
 single function
Date: Thu, 16 Jun 2016 12:22:06 -0700
Message-ID: <20160616192206.20872.41944.stgit@localhost.localdomain>
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
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32962 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333AbcFPTWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:22:15 -0400
Received: by mail-pf0-f173.google.com with SMTP id i123so18931534pfg.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:22:14 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch goes through and combines the notifiers for VXLAN and GENEVE
into a single function for each action.  So there is now one combined
function for getting ports, one for adding the ports, and one for deleting
the ports.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/Kconfig          |   21 ---
 drivers/net/ethernet/intel/i40e/i40e_main.c |  186 +++++++--------------------
 2 files changed, 51 insertions(+), 156 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 11fc5e8ea968..1fbf9088a4d7 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -236,27 +236,6 @@ config I40E
 	  To compile this driver as a module, choose M here. The module
 	  will be called i40e.
 
-config I40E_VXLAN
-	bool "Virtual eXtensible Local Area Network Support"
-	default n
-	depends on I40E && VXLAN && !(I40E=y && VXLAN=m)
-	---help---
-	  This allows one to create VXLAN virtual interfaces that provide
-	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
-	  to tunnel virtual network infrastructure in virtualized environments.
-	  Say Y here if you want to use Virtual eXtensible Local Area Network
-	  (VXLAN) in the driver.
-
-config I40E_GENEVE
-	bool "Generic Network Virtualization Encapsulation (GENEVE) Support"
-	depends on I40E && GENEVE && !(I40E=y && GENEVE=m)
-	default n
-	---help---
-	  This allows one to create GENEVE virtual interfaces that provide
-	  Layer 2 Networks over Layer 3 Networks. GENEVE is often used
-	  to tunnel virtual network infrastructure in virtualized environments.
-	  Say Y here if you want to use GENEVE in the driver.
-
 config I40E_DCB
 	bool "Data Center Bridging (DCB) Support"
 	default n
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 68172759bf71..2b1140563a64 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -31,12 +31,7 @@
 /* Local includes */
 #include "i40e.h"
 #include "i40e_diag.h"
-#if IS_ENABLED(CONFIG_VXLAN)
-#include <net/vxlan.h>
-#endif
-#if IS_ENABLED(CONFIG_GENEVE)
-#include <net/geneve.h>
-#endif
+#include <net/udp_tunnel.h>
 
 const char i40e_driver_name[] = "i40e";
 static const char i40e_driver_string[] =
@@ -5367,14 +5362,7 @@ int i40e_open(struct net_device *netdev)
 						       TCP_FLAG_CWR) >> 16);
 	wr32(&pf->hw, I40E_GLLAN_TSOMSK_L, be32_to_cpu(TCP_FLAG_CWR) >> 16);
 
-#ifdef CONFIG_I40E_VXLAN
-	vxlan_get_rx_port(netdev);
-#endif
-#ifdef CONFIG_I40E_GENEVE
-	if (pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE)
-		geneve_get_rx_port(netdev);
-#endif
-
+	udp_tunnel_get_rx_info(netdev);
 	i40e_notify_client_of_netdev_open(vsi);
 
 	return 0;
@@ -7083,7 +7071,6 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
  **/
 static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 {
-#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret;
 	__be16 port;
@@ -7118,7 +7105,6 @@ static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 			}
 		}
 	}
-#endif
 }
 
 /**
@@ -8658,7 +8644,6 @@ static int i40e_set_features(struct net_device *netdev,
 	return 0;
 }
 
-#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
 /**
  * i40e_get_udp_port_idx - Lookup a possibly offloaded for Rx UDP port
  * @pf: board private structure
@@ -8678,21 +8663,18 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 	return i;
 }
 
-#endif
-
-#if IS_ENABLED(CONFIG_VXLAN)
 /**
- * i40e_add_vxlan_port - Get notifications about VXLAN ports that come up
+ * i40e_udp_tunnel_add - Get notifications about UDP tunnel ports that come up
  * @netdev: This physical port's netdev
- * @sa_family: Socket Family that VXLAN is notifying us about
- * @port: New UDP port number that VXLAN started listening to
+ * @ti: Tunnel endpoint information
  **/
-static void i40e_add_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
+static void i40e_udp_tunnel_add(struct net_device *netdev,
+				struct udp_tunnel_info *ti)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
+	__be16 port = ti->port;
 	u8 next_idx;
 	u8 idx;
 
@@ -8700,7 +8682,7 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 
 	/* Check if port already exists */
 	if (idx < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "vxlan port %d already offloaded\n",
+		netdev_info(netdev, "port %d already offloaded\n",
 			    ntohs(port));
 		return;
 	}
@@ -8709,131 +8691,75 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	next_idx = i40e_get_udp_port_idx(pf, 0);
 
 	if (next_idx == I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "maximum number of vxlan UDP ports reached, not adding port %d\n",
-			    ntohs(port));
-		return;
-	}
-
-	/* New port: add it and mark its index in the bitmap */
-	pf->udp_ports[next_idx].index = port;
-	pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_VXLAN;
-	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
-	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-}
-
-/**
- * i40e_del_vxlan_port - Get notifications about VXLAN ports that go away
- * @netdev: This physical port's netdev
- * @sa_family: Socket Family that VXLAN is notifying us about
- * @port: UDP port number that VXLAN stopped listening to
- **/
-static void i40e_del_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
-{
-	struct i40e_netdev_priv *np = netdev_priv(netdev);
-	struct i40e_vsi *vsi = np->vsi;
-	struct i40e_pf *pf = vsi->back;
-	u8 idx;
-
-	idx = i40e_get_udp_port_idx(pf, port);
-
-	/* Check if port already exists */
-	if (idx < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		/* if port exists, set it to 0 (mark for deletion)
-		 * and make it pending
-		 */
-		pf->udp_ports[idx].index = 0;
-		pf->pending_udp_bitmap |= BIT_ULL(idx);
-		pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-	} else {
-		netdev_warn(netdev, "vxlan port %d was not found, not deleting\n",
-			    ntohs(port));
-	}
-}
-#endif
-
-#if IS_ENABLED(CONFIG_GENEVE)
-/**
- * i40e_add_geneve_port - Get notifications about GENEVE ports that come up
- * @netdev: This physical port's netdev
- * @sa_family: Socket Family that GENEVE is notifying us about
- * @port: New UDP port number that GENEVE started listening to
- **/
-static void i40e_add_geneve_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
-{
-	struct i40e_netdev_priv *np = netdev_priv(netdev);
-	struct i40e_vsi *vsi = np->vsi;
-	struct i40e_pf *pf = vsi->back;
-	u8 next_idx;
-	u8 idx;
-
-	if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
-		return;
-
-	idx = i40e_get_udp_port_idx(pf, port);
-
-	/* Check if port already exists */
-	if (idx < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "udp port %d already offloaded\n",
+		netdev_info(netdev, "maximum number of offloaded UDP ports reached, not adding port %d\n",
 			    ntohs(port));
 		return;
 	}
 
-	/* Now check if there is space to add the new port */
-	next_idx = i40e_get_udp_port_idx(pf, 0);
-
-	if (next_idx == I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "maximum number of UDP ports reached, not adding port %d\n",
-			    ntohs(port));
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_VXLAN;
+		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
+			return;
+		pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_NGE;
+		break;
+	default:
 		return;
 	}
 
 	/* New port: add it and mark its index in the bitmap */
 	pf->udp_ports[next_idx].index = port;
-	pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_NGE;
 	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-
-	dev_info(&pf->pdev->dev, "adding geneve port %d\n", ntohs(port));
 }
 
 /**
- * i40e_del_geneve_port - Get notifications about GENEVE ports that go away
+ * i40e_udp_tunnel_del - Get notifications about UDP tunnel ports that go away
  * @netdev: This physical port's netdev
- * @sa_family: Socket Family that GENEVE is notifying us about
- * @port: UDP port number that GENEVE stopped listening to
+ * @ti: Tunnel endpoint information
  **/
-static void i40e_del_geneve_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+static void i40e_udp_tunnel_del(struct net_device *netdev,
+				struct udp_tunnel_info *ti)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
+	__be16 port = ti->port;
 	u8 idx;
 
-	if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
-		return;
-
 	idx = i40e_get_udp_port_idx(pf, port);
 
 	/* Check if port already exists */
-	if (idx < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		/* if port exists, set it to 0 (mark for deletion)
-		 * and make it pending
-		 */
-		pf->udp_ports[idx].index = 0;
-		pf->pending_udp_bitmap |= BIT_ULL(idx);
-		pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
+	if (idx >= I40E_MAX_PF_UDP_OFFLOAD_PORTS)
+		goto not_found;
 
-		dev_info(&pf->pdev->dev, "deleting geneve port %d\n",
-			 ntohs(port));
-	} else {
-		netdev_warn(netdev, "geneve port %d was not found, not deleting\n",
-			    ntohs(port));
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		if (pf->udp_ports[idx].type != I40E_AQC_TUNNEL_TYPE_VXLAN)
+			goto not_found;
+		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		if (pf->udp_ports[idx].type != I40E_AQC_TUNNEL_TYPE_NGE)
+			goto not_found;
+		break;
+	default:
+		goto not_found;
 	}
+
+	/* if port exists, set it to 0 (mark for deletion)
+	 * and make it pending
+	 */
+	pf->udp_ports[idx].index = 0;
+	pf->pending_udp_bitmap |= BIT_ULL(idx);
+	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
+
+	return;
+not_found:
+	netdev_warn(netdev, "UDP port %d was not found, not deleting\n",
+		    ntohs(port));
 }
-#endif
 
 static int i40e_get_phys_port_id(struct net_device *netdev,
 				 struct netdev_phys_item_id *ppid)
@@ -9063,14 +8989,8 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
 	.ndo_set_vf_spoofchk	= i40e_ndo_set_vf_spoofchk,
 	.ndo_set_vf_trust	= i40e_ndo_set_vf_trust,
-#if IS_ENABLED(CONFIG_VXLAN)
-	.ndo_add_vxlan_port	= i40e_add_vxlan_port,
-	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
-#endif
-#if IS_ENABLED(CONFIG_GENEVE)
-	.ndo_add_geneve_port	= i40e_add_geneve_port,
-	.ndo_del_geneve_port	= i40e_del_geneve_port,
-#endif
+	.ndo_udp_tunnel_add	= i40e_udp_tunnel_add,
+	.ndo_udp_tunnel_del	= i40e_udp_tunnel_del,
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
 	.ndo_fdb_add		= i40e_ndo_fdb_add,
 	.ndo_features_check	= i40e_features_check,
@@ -10719,12 +10639,8 @@ static void i40e_print_features(struct i40e_pf *pf)
 	}
 	if (pf->flags & I40E_FLAG_DCB_CAPABLE)
 		i += snprintf(&buf[i], REMAIN(i), " DCB");
-#if IS_ENABLED(CONFIG_VXLAN)
 	i += snprintf(&buf[i], REMAIN(i), " VxLAN");
-#endif
-#if IS_ENABLED(CONFIG_GENEVE)
 	i += snprintf(&buf[i], REMAIN(i), " Geneve");
-#endif
 	if (pf->flags & I40E_FLAG_PTP)
 		i += snprintf(&buf[i], REMAIN(i), " PTP");
 #ifdef I40E_FCOE
