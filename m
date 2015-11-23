From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH v1 4/6] i40e: Remove CONFIG_I40E_VXLAN
Date: Mon, 23 Nov 2015 13:02:57 -0800
Message-ID: <1448312579-159544-5-git-send-email-anjali.singhai@intel.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Cc: jesse@kernel.org, Anjali Singhai Jain <anjali.singhai@intel.com>,
	Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48036 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755098AbbKWUqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 15:46:18 -0500
In-Reply-To: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the kernel flag CONFIG_VXLAN is true or CONFIG_VXLAN_MODULE is true,
enable VXLAN offload in the driver.

Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
---
 drivers/net/ethernet/intel/Kconfig          | 11 -----------
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++------
 2 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 4163b16..061e4e0 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -269,17 +269,6 @@ config I40E
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
 config I40E_DCB
 	bool "Data Center Bridging (DCB) Support"
 	default n
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d65c10b..f6447c7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -27,7 +27,7 @@
 /* Local includes */
 #include "i40e.h"
 #include "i40e_diag.h"
-#ifdef CONFIG_I40E_VXLAN
+#if IS_ENABLED(CONFIG_VXLAN)
 #include <net/vxlan.h>
 #endif
 #include <net/udp_tunnel.h>
@@ -6990,7 +6990,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
  **/
 static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 {
-#ifdef CONFIG_I40E_VXLAN
+#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret;
 	__be16 port;
@@ -8273,7 +8273,7 @@ static int i40e_set_features(struct net_device *netdev,
 	return 0;
 }
 
-#ifdef CONFIG_I40E_VXLAN
+#if IS_ENABLED(CONFIG_VXLAN)
 /**
  * i40e_get_udp_port_idx - Lookup a possibly offloaded for Rx UDP port
  * @pf: board private structure
@@ -8293,6 +8293,7 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 	return i;
 }
 
+#endif
 /**
  * i40e_add_tunnel_port - Get notifications about UDP tunnel ports that come up
  * @netdev: This physical port's netdev
@@ -8307,6 +8308,7 @@ static void i40e_add_tunnel_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port,
 				 u32 type)
 {
+#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8344,6 +8346,7 @@ static void i40e_add_tunnel_port(struct net_device *netdev,
 
 	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
+#endif
 }
 
 /**
@@ -8360,6 +8363,7 @@ static void i40e_del_tunnel_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port,
 				 u32 type)
 {
+#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8385,9 +8389,9 @@ static void i40e_del_tunnel_port(struct net_device *netdev,
 		netdev_warn(netdev, "udp tunnel port %d was not found, not deleting\n",
 			    ntohs(port));
 	}
+#endif
 }
 
-#endif
 static int i40e_get_phys_port_id(struct net_device *netdev,
 				 struct netdev_phys_item_id *ppid)
 {
@@ -8612,10 +8616,8 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_get_vf_config	= i40e_ndo_get_vf_config,
 	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
 	.ndo_set_vf_spoofchk	= i40e_ndo_set_vf_spoofchk,
-#ifdef CONFIG_I40E_VXLAN
 	.ndo_add_udp_tunnel_port	= i40e_add_tunnel_port,
 	.ndo_del_udp_tunnel_port	= i40e_del_tunnel_port,
-#endif
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
 	.ndo_fdb_add		= i40e_ndo_fdb_add,
 	.ndo_features_check	= i40e_features_check,
-- 
1.8.1.4
