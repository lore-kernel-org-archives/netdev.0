From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 23 Nov 2015 13:02:54 -0800
Message-ID: <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Cc: jesse@kernel.org, Anjali Singhai Jain <anjali.singhai@intel.com>,
	Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48052 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755088AbbKWUqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 15:46:18 -0500
In-Reply-To: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace add/del ndo ops for vxlan_port with tunnel_port so that all UDP
based tunnels can use the same ndo op. Add a parameter to pass tunnel
type to the ndo_op.

Change all drivers to use the generalized udp tunnel offload

Patch was compile tested with x86_64_defconfig.

Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 15 ++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c        | 13 +++++---
 drivers/net/ethernet/emulex/benet/be_main.c      | 14 +++++---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 27 ++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 41 +++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 17 +++++++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   | 21 ++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 17 +++++++---
 drivers/net/vxlan.c                              | 23 +++++++------
 include/linux/netdevice.h                        | 34 ++++++++++----------
 include/net/udp_tunnel.h                         |  6 ++++
 11 files changed, 157 insertions(+), 71 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2273576..ad2782f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -47,6 +47,7 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
+#include <net/udp_tunnel.h>
 #include <net/vxlan.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
@@ -10124,11 +10125,14 @@ static void __bnx2x_add_vxlan_port(struct bnx2x *bp, u16 port)
 }
 
 static void bnx2x_add_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+				 sa_family_t sa_family, __be16 port,
+				 u32 type)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	u16 t_port = ntohs(port);
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
 	__bnx2x_add_vxlan_port(bp, t_port);
 }
 
@@ -10152,11 +10156,14 @@ static void __bnx2x_del_vxlan_port(struct bnx2x *bp, u16 port)
 }
 
 static void bnx2x_del_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+				 sa_family_t sa_family, __be16 port,
+				 u32 type)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	u16 t_port = ntohs(port);
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
 	__bnx2x_del_vxlan_port(bp, t_port);
 }
 #endif
@@ -13008,8 +13015,8 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_set_vf_link_state	= bnx2x_set_vf_link_state,
 	.ndo_features_check	= bnx2x_features_check,
 #ifdef CONFIG_BNX2X_VXLAN
-	.ndo_add_vxlan_port	= bnx2x_add_vxlan_port,
-	.ndo_del_vxlan_port	= bnx2x_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= bnx2x_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= bnx2x_del_vxlan_port,
 #endif
 };
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f2d0dc9..5b96ddf 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5421,7 +5421,7 @@ static void bnxt_cfg_ntp_filters(struct bnxt *bp)
 #endif /* CONFIG_RFS_ACCEL */
 
 static void bnxt_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				__be16 port)
+				__be16 port, u32 type)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
@@ -5431,6 +5431,9 @@ static void bnxt_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
 	if (sa_family != AF_INET6 && sa_family != AF_INET)
 		return;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (bp->vxlan_port_cnt && bp->vxlan_port != port)
 		return;
 
@@ -5443,7 +5446,7 @@ static void bnxt_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
 }
 
 static void bnxt_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				__be16 port)
+				__be16 port, u32 type)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
@@ -5453,6 +5456,8 @@ static void bnxt_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
 	if (sa_family != AF_INET6 && sa_family != AF_INET)
 		return;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
 	if (bp->vxlan_port_cnt && bp->vxlan_port == port) {
 		bp->vxlan_port_cnt--;
 
@@ -5491,8 +5496,8 @@ static const struct net_device_ops bnxt_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= bnxt_rx_flow_steer,
 #endif
-	.ndo_add_vxlan_port	= bnxt_add_vxlan_port,
-	.ndo_del_vxlan_port	= bnxt_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= bnxt_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= bnxt_del_vxlan_port,
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= bnxt_busy_poll,
 #endif
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4cab887..e699deca 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -23,6 +23,7 @@
 #include <linux/aer.h>
 #include <linux/if_bridge.h>
 #include <net/busy_poll.h>
+#include <net/udp_tunnel.h>
 #include <net/vxlan.h>
 
 MODULE_VERSION(DRV_VER);
@@ -5175,12 +5176,15 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
  * until after all the tunnels are removed.
  */
 static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-			      __be16 port)
+			      __be16 port, u32 type)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct device *dev = &adapter->pdev->dev;
 	int status;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
 		return;
 
@@ -5229,10 +5233,12 @@ err:
 }
 
 static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-			      __be16 port)
+			      __be16 port, u32 type)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
 	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
 		return;
 
@@ -5342,8 +5348,8 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_busy_poll		= be_busy_poll,
 #endif
 #ifdef CONFIG_BE2NET_VXLAN
-	.ndo_add_vxlan_port	= be_add_vxlan_port,
-	.ndo_del_vxlan_port	= be_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= be_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= be_del_vxlan_port,
 	.ndo_features_check	= be_features_check,
 #endif
 	.ndo_get_phys_port_id   = be_get_phys_port_id,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 639263d..447d5e6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -21,6 +21,7 @@
 #include "fm10k.h"
 #include <linux/vmalloc.h>
 #if IS_ENABLED(CONFIG_FM10K_VXLAN)
+#include <net/udp_tunnel.h>
 #include <net/vxlan.h>
 #endif /* CONFIG_FM10K_VXLAN */
 
@@ -439,18 +440,24 @@ static void fm10k_restore_vxlan_port(struct fm10k_intfc *interface)
  * @netdev: network interface device structure
  * @sa_family: Address family of new port
  * @port: port number used for VXLAN
+ * @type: Tunnel type
  *
- * This funciton is called when a new VXLAN interface has added a new port
+ * This function is called when a new VXLAN interface has added a new port
  * number to the range that is currently in use for VXLAN.  The new port
  * number is always added to the tail so that the port number list should
  * match the order in which the ports were allocated.  The head of the list
  * is always used as the VXLAN port number for offloads.
  **/
 static void fm10k_add_vxlan_port(struct net_device *dev,
-				 sa_family_t sa_family, __be16 port) {
+				 sa_family_t sa_family, __be16 port,
+				 u32 type) {
+#if IS_ENABLED(CONFIG_FM10K_VXLAN)
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	struct fm10k_vxlan_port *vxlan_port;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	/* only the PF supports configuring tunnels */
 	if (interface->hw.mac.type != fm10k_mac_pf)
 		return;
@@ -476,6 +483,7 @@ insert_tail:
 	list_add_tail(&vxlan_port->list, &interface->vxlan_port);
 
 	fm10k_restore_vxlan_port(interface);
+#endif
 }
 
 /**
@@ -483,17 +491,23 @@ insert_tail:
  * @netdev: network interface device structure
  * @sa_family: Address family of freed port
  * @port: port number used for VXLAN
+ * @type: Tunnel type
  *
- * This funciton is called when a new VXLAN interface has freed a port
+ * This function is called when a new VXLAN interface has freed a port
  * number from the range that is currently in use for VXLAN.  The freed
  * port is removed from the list and the new head is used to determine
  * the port number for offloads.
  **/
 static void fm10k_del_vxlan_port(struct net_device *dev,
-				 sa_family_t sa_family, __be16 port) {
+				 sa_family_t sa_family, __be16 port,
+				 u32 type) {
+#if IS_ENABLED(CONFIG_FM10K_VXLAN)
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	struct fm10k_vxlan_port *vxlan_port;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (interface->hw.mac.type != fm10k_mac_pf)
 		return;
 
@@ -508,6 +522,7 @@ static void fm10k_del_vxlan_port(struct net_device *dev,
 	}
 
 	fm10k_restore_vxlan_port(interface);
+#endif
 }
 
 /**
@@ -1373,8 +1388,8 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_set_vf_vlan	= fm10k_ndo_set_vf_vlan,
 	.ndo_set_vf_rate	= fm10k_ndo_set_vf_bw,
 	.ndo_get_vf_config	= fm10k_ndo_get_vf_config,
-	.ndo_add_vxlan_port	= fm10k_add_vxlan_port,
-	.ndo_del_vxlan_port	= fm10k_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= fm10k_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= fm10k_del_vxlan_port,
 	.ndo_do_ioctl		= fm10k_ioctl,
 	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
 	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b825f97..520e34e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -30,6 +30,7 @@
 #ifdef CONFIG_I40E_VXLAN
 #include <net/vxlan.h>
 #endif
+#include <net/udp_tunnel.h>
 
 const char i40e_driver_name[] = "i40e";
 static const char i40e_driver_string[] =
@@ -8296,13 +8297,18 @@ static u8 i40e_get_vxlan_port_idx(struct i40e_pf *pf, __be16 port)
 }
 
 /**
- * i40e_add_vxlan_port - Get notifications about VXLAN ports that come up
+ * i40e_add_tunnel_port - Get notifications about UDP tunnel ports that come up
  * @netdev: This physical port's netdev
- * @sa_family: Socket Family that VXLAN is notifying us about
- * @port: New UDP port number that VXLAN started listening to
+ * @sa_family: Socket Family that tunnel netdev is  associated with
+ * @port: New UDP port number that tunnel started listening to
+ * @type: Tunnel Type
+ *
+ * This function modifies a common data structure for all udp_tunnels
+ * hence it is expected that it is called under a common lock.
  **/
-static void i40e_add_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
+static void i40e_add_tunnel_port(struct net_device *netdev,
+				 sa_family_t sa_family, __be16 port,
+				 u32 type)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -8310,6 +8316,9 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	u8 next_idx;
 	u8 idx;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (sa_family == AF_INET6)
 		return;
 
@@ -8338,19 +8347,27 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 }
 
 /**
- * i40e_del_vxlan_port - Get notifications about VXLAN ports that go away
+ * i40e_del_tunnel_port - Get notifications about UDP tunnel ports that go away
  * @netdev: This physical port's netdev
- * @sa_family: Socket Family that VXLAN is notifying us about
- * @port: UDP port number that VXLAN stopped listening to
+ * @sa_family: Socket Family that tunnel netdev is associated with
+ * @port: UDP port number that tunnel stopped listening to
+ * @type: Tunnel Type
+ *
+ * This function modifies a common data structure for all udp_tunnels
+ * hence it is expected that it is called under common lock.
  **/
-static void i40e_del_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
+static void i40e_del_tunnel_port(struct net_device *netdev,
+				 sa_family_t sa_family, __be16 port,
+				 u32 type)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	u8 idx;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (sa_family == AF_INET6)
 		return;
 
@@ -8596,8 +8613,8 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
 	.ndo_set_vf_spoofchk	= i40e_ndo_set_vf_spoofchk,
 #ifdef CONFIG_I40E_VXLAN
-	.ndo_add_vxlan_port	= i40e_add_vxlan_port,
-	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= i40e_add_tunnel_port,
+	.ndo_del_udp_tunnel_port	= i40e_del_tunnel_port,
 #endif
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
 	.ndo_fdb_add		= i40e_ndo_fdb_add,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4089d77..76ccc77 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -50,6 +50,7 @@
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
+#include <net/udp_tunnel.h>
 #include <net/vxlan.h>
 
 #ifdef CONFIG_OF
@@ -8088,14 +8089,18 @@ static int ixgbe_set_features(struct net_device *netdev,
  * @dev: The port's netdev
  * @sa_family: Socket Family that VXLAN is notifiying us about
  * @port: New UDP port number that VXLAN started listening to
+ * @type: Tunnel type
  **/
 static void ixgbe_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				 __be16 port)
+				 __be16 port, u32 type)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u16 new_port = ntohs(port);
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
 		return;
 
@@ -8121,13 +8126,17 @@ static void ixgbe_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
  * @dev: The port's netdev
  * @sa_family: Socket Family that VXLAN is notifying us about
  * @port: UDP port number that VXLAN stopped listening to
+ * @type: Tunnel type
  **/
 static void ixgbe_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				 __be16 port)
+				 __be16 port, u32 type)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	u16 new_port = ntohs(port);
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
 		return;
 
@@ -8436,8 +8445,8 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_dfwd_add_station	= ixgbe_fwd_add,
 	.ndo_dfwd_del_station	= ixgbe_fwd_del,
 #ifdef CONFIG_IXGBE_VXLAN
-	.ndo_add_vxlan_port	= ixgbe_add_vxlan_port,
-	.ndo_del_vxlan_port	= ixgbe_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= ixgbe_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= ixgbe_del_vxlan_port,
 #endif /* CONFIG_IXGBE_VXLAN */
 	.ndo_features_check	= ixgbe_features_check,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 659209f..2cb19c7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -39,6 +39,7 @@
 #include <linux/hash.h>
 #include <net/ip.h>
 #include <net/busy_poll.h>
+#include <net/udp_tunnel.h>
 #include <net/vxlan.h>
 
 #include <linux/mlx4/driver.h>
@@ -2365,11 +2366,15 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 }
 
 static void mlx4_en_add_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   sa_family_t sa_family, __be16 port,
+				   u32 type)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		return;
 
@@ -2388,11 +2393,15 @@ static void mlx4_en_add_vxlan_port(struct  net_device *dev,
 }
 
 static void mlx4_en_del_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   sa_family_t sa_family, __be16 port,
+				   u32 type)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		return;
 
@@ -2469,8 +2478,8 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #endif
 	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
 #ifdef CONFIG_MLX4_EN_VXLAN
-	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
-	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= mlx4_en_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 #endif
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
@@ -2507,8 +2516,8 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 #endif
 	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
 #ifdef CONFIG_MLX4_EN_VXLAN
-	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
-	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= mlx4_en_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 #endif
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1205f6f..aa38dbb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -17,6 +17,7 @@
 #include <linux/log2.h>
 #include <linux/pci.h>
 #ifdef CONFIG_QLCNIC_VXLAN
+#include <net/udp_tunnel.h>
 #include <net/vxlan.h>
 #endif
 
@@ -476,11 +477,15 @@ static int qlcnic_get_phys_port_id(struct net_device *netdev,
 
 #ifdef CONFIG_QLCNIC_VXLAN
 static void qlcnic_add_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  sa_family_t sa_family, __be16 port,
+				  u32 type)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	/* Adapter supports only one VXLAN port. Use very first port
 	 * for enabling offload
 	 */
@@ -498,11 +503,15 @@ static void qlcnic_add_vxlan_port(struct net_device *netdev,
 }
 
 static void qlcnic_del_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  sa_family_t sa_family, __be16 port,
+				  u32 type)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
+	if (type != UDP_TUNNEL_VXLAN)
+		return;
+
 	if (!qlcnic_encap_rx_offload(adapter) || !ahw->vxlan_port_count ||
 	    (ahw->vxlan_port != ntohs(port)))
 		return;
@@ -540,8 +549,8 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_fdb_dump		= qlcnic_fdb_dump,
 	.ndo_get_phys_port_id	= qlcnic_get_phys_port_id,
 #ifdef CONFIG_QLCNIC_VXLAN
-	.ndo_add_vxlan_port	= qlcnic_add_vxlan_port,
-	.ndo_del_vxlan_port	= qlcnic_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= qlcnic_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= qlcnic_del_vxlan_port,
 	.ndo_features_check	= qlcnic_features_check,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6369a57..5490629 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -628,9 +628,10 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_add_vxlan_port)
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
+		if (dev->netdev_ops->ndo_add_udp_tunnel_port)
+			dev->netdev_ops->ndo_add_udp_tunnel_port(dev, sa_family,
+							      port,
+							      UDP_TUNNEL_VXLAN);
 	}
 	rcu_read_unlock();
 }
@@ -646,9 +647,10 @@ static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_del_vxlan_port)
-			dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
-							    port);
+		if (dev->netdev_ops->ndo_del_udp_tunnel_port)
+			dev->netdev_ops->ndo_del_udp_tunnel_port(dev, sa_family,
+							      port,
+							      UDP_TUNNEL_VXLAN);
 	}
 	rcu_read_unlock();
 
@@ -2422,9 +2424,9 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
-/* Calls the ndo_add_vxlan_port of the caller in order to
+/* Calls the ndo_add_udp_tunnel_port of the caller in order to
  * supply the listening VXLAN udp ports. Callers are expected
- * to implement the ndo_add_vxlan_port.
+ * to implement the ndo_add_tunnel_port.
  */
 void vxlan_get_rx_port(struct net_device *dev)
 {
@@ -2440,8 +2442,9 @@ void vxlan_get_rx_port(struct net_device *dev)
 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
 			port = inet_sk(vs->sock->sk)->inet_sport;
 			sa_family = vxlan_get_sk_family(vs);
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
+			dev->netdev_ops->ndo_add_udp_tunnel_port(dev, sa_family,
+							      port,
+							      UDP_TUNNEL_VXLAN);
 		}
 	}
 	spin_unlock(&vn->sock_lock);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7d2d1d7..eaecc42 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1004,18 +1004,19 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	not implement this, it is assumed that the hw is not able to have
  *	multiple net devices on single physical port.
  *
- * void (*ndo_add_vxlan_port)(struct  net_device *dev,
- *			      sa_family_t sa_family, __be16 port);
- *	Called by vxlan to notiy a driver about the UDP port and socket
- *	address family that vxlan is listnening to. It is called only when
- *	a new port starts listening. The operation is protected by the
- *	vxlan_net->sock_lock.
- *
- * void (*ndo_del_vxlan_port)(struct  net_device *dev,
- *			      sa_family_t sa_family, __be16 port);
- *	Called by vxlan to notify the driver about a UDP port and socket
- *	address family that vxlan is not listening to anymore. The operation
- *	is protected by the vxlan_net->sock_lock.
+ * void (*ndo_add_udp_tunnel_port)(struct  net_device *dev,
+ *			      sa_family_t sa_family, __be16 port, u32 type);
+ *	Called by UDP based tunnel modules to notify a driver about a UDP
+ *	port and socket address family that the tunnel is listening to. It is
+ *	called only when a new port starts listening. The operation is
+ *	protected by udp_offload_lock across all udp based tunnels.
+ *
+ * void (*ndo_del_udp_tunnel_port)(struct  net_device *dev,
+ *			      sa_family_t sa_family, __be16 port, u32 type);
+ *	Called by UDP based tunnel modules to notify the driver about a UDP port
+ *	and socket address family that tunnel is not listening to anymore.
+ *	The operation is protected by udp_offload_lock across all udp based
+ *	tunnels.
  *
  * void* (*ndo_dfwd_add_station)(struct net_device *pdev,
  *				 struct net_device *dev)
@@ -1209,13 +1210,12 @@ struct net_device_ops {
 							struct netdev_phys_item_id *ppid);
 	int			(*ndo_get_phys_port_name)(struct net_device *dev,
 							  char *name, size_t len);
-	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
+	void			(*ndo_add_udp_tunnel_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
-						      __be16 port);
-	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
+						      __be16 port, u32 type);
+	void			(*ndo_del_udp_tunnel_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
-						      __be16 port);
-
+						      __be16 port, u32 type);
 	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
 							struct net_device *dev);
 	void			(*ndo_dfwd_del_station)(struct net_device *pdev,
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index cb2f89f..72415aa 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -9,6 +9,12 @@
 #include <net/addrconf.h>
 #endif
 
+enum udp_tunnel_type {
+	UDP_TUNNEL_UNSPEC,
+	UDP_TUNNEL_VXLAN,
+	UDP_TUNNEL_GENEVE,
+};
+
 struct udp_port_cfg {
 	u8			family;
 
-- 
1.8.1.4
