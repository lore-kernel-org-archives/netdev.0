From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 01/10] net: Rename ndo_add_vxlan_port to ndo_add_udp_tunnel_port.
Date: Tue, 22 Jul 2014 03:19:44 -0700
Message-ID: <1406024393-6778-2-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:58981 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751471AbaGVKbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:31:41 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so9369498pdj.26
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:31:40 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename ndo_add_vxlan_port() API provided by net_device_ops to
ndo_add_udp_tunnel_port(). Generalized the API in preparation for
up coming NICs and device drivers that may support offloading more
UDP tunnels protocols besides VxLAN.  There is no behavioral changes
with this patch.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c      |   15 +++++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c      |   16 ++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   17 ++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   17 ++++++++---
 drivers/net/vxlan.c                              |   23 +++++++-------
 include/linux/netdevice.h                        |   35 ++++++++++++----------
 include/net/udp_tunnel.h                         |    2 ++
 7 files changed, 84 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9c50814..028dc6e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -24,6 +24,7 @@
 #include <linux/if_bridge.h>
 #include <net/busy_poll.h>
 #include <net/vxlan.h>
+#include <net/udp_tunnel.h>
 
 MODULE_VERSION(DRV_VER);
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -4324,7 +4325,7 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 
 #ifdef CONFIG_BE2NET_VXLAN
 static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-			      __be16 port)
+			      __be16 port, u8 udp_tunnel_type)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct device *dev = &adapter->pdev->dev;
@@ -4333,6 +4334,9 @@ static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 	if (lancer_chip(adapter) || BEx_chip(adapter))
 		return;
 
+	if (udp_tunnel_type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
 		dev_warn(dev, "Cannot add UDP port %d for VxLAN offloads\n",
 			 be16_to_cpu(port));
@@ -4365,13 +4369,16 @@ err:
 }
 
 static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-			      __be16 port)
+			      __be16 port, u8 udp_tunnel_type)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	if (lancer_chip(adapter) || BEx_chip(adapter))
 		return;
 
+	if (udp_tunnel_type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	if (adapter->vxlan_port != port)
 		return;
 
@@ -4408,8 +4415,8 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_busy_poll		= be_busy_poll,
 #endif
 #ifdef CONFIG_BE2NET_VXLAN
-	.ndo_add_vxlan_port	= be_add_vxlan_port,
-	.ndo_del_vxlan_port	= be_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= be_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= be_del_vxlan_port,
 #endif
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c34e390..d9fd53b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -29,6 +29,7 @@
 #include "i40e_diag.h"
 #ifdef CONFIG_I40E_VXLAN
 #include <net/vxlan.h>
+#include <net/udp_tunnel.h>
 #endif
 
 const char i40e_driver_name[] = "i40e";
@@ -6944,9 +6945,11 @@ static u8 i40e_get_vxlan_port_idx(struct i40e_pf *pf, __be16 port)
  * @netdev: This physical port's netdev
  * @sa_family: Socket Family that VXLAN is notifying us about
  * @port: New UDP port number that VXLAN started listening to
+ * @udp_tunnel_type: Only UDP_TUNNEL_TYPE_VXLAN will be processed.
  **/
 static void i40e_add_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
+				sa_family_t sa_family, __be16 port,
+				u8 udp_tunnel_type)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -6957,6 +6960,9 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (udp_tunnel_type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	idx = i40e_get_vxlan_port_idx(pf, port);
 
 	/* Check if port already exists */
@@ -6986,6 +6992,7 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
  * @netdev: This physical port's netdev
  * @sa_family: Socket Family that VXLAN is notifying us about
  * @port: UDP port number that VXLAN stopped listening to
+ * @udp_tunnel_type: Only UDP_TUNNEL_TYPE_VXLAN will be processed.
  **/
 static void i40e_del_vxlan_port(struct net_device *netdev,
 				sa_family_t sa_family, __be16 port)
@@ -6998,6 +7005,9 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (udp_tunnel_type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	idx = i40e_get_vxlan_port_idx(pf, port);
 
 	/* Check if port already exists */
@@ -7149,8 +7159,8 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
 	.ndo_set_vf_spoofchk	= i40e_ndo_set_vf_spoofck,
 #ifdef CONFIG_I40E_VXLAN
-	.ndo_add_vxlan_port	= i40e_add_vxlan_port,
-	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= i40e_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= i40e_del_vxlan_port,
 #endif
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
 #ifdef HAVE_FDB_OPS
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 887cf01..d5f6b91 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -40,6 +40,7 @@
 #include <net/ip.h>
 #include <net/busy_poll.h>
 #include <net/vxlan.h>
+#include <net/udp_tunnel.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
@@ -2326,7 +2327,8 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 }
 
 static void mlx4_en_add_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   sa_family_t sa_family, __be16 port,
+				   u8 udp_tunnel_type)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
@@ -2337,6 +2339,9 @@ static void mlx4_en_add_vxlan_port(struct  net_device *dev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (udp_tunnel_type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	current_port = priv->vxlan_port;
 	if (current_port && current_port != port) {
 		en_warn(priv, "vxlan port %d configured, can't add port %d\n",
@@ -2349,7 +2354,8 @@ static void mlx4_en_add_vxlan_port(struct  net_device *dev,
 }
 
 static void mlx4_en_del_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   sa_family_t sa_family, __be16 port,
+				   u8 udp_tunnel_type)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
@@ -2360,6 +2366,9 @@ static void mlx4_en_del_vxlan_port(struct  net_device *dev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (udp_tunnel_type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	current_port = priv->vxlan_port;
 	if (current_port != port) {
 		en_dbg(DRV, priv, "vxlan port %d isn't configured, ignoring\n", ntohs(port));
@@ -2397,8 +2406,8 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #endif
 	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
 #ifdef CONFIG_MLX4_EN_VXLAN
-	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
-	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= mlx4_en_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= mlx4_en_del_vxlan_port,
 #endif
 };
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0fdbcc8..a39020d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -23,6 +23,7 @@
 #include <linux/pci.h>
 #ifdef CONFIG_QLCNIC_VXLAN
 #include <net/vxlan.h>
+#include <net/udp_tunnel.h>
 #endif
 
 MODULE_DESCRIPTION("QLogic 1/10 GbE Converged/Intelligent Ethernet Driver");
@@ -470,7 +471,8 @@ static int qlcnic_get_phys_port_id(struct net_device *netdev,
 
 #ifdef CONFIG_QLCNIC_VXLAN
 static void qlcnic_add_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  sa_family_t sa_family, __be16 port,
+				  u8 udp_tunnel_type)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -481,12 +483,16 @@ static void qlcnic_add_vxlan_port(struct net_device *netdev,
 	if (!qlcnic_encap_rx_offload(adapter) || ahw->vxlan_port)
 		return;
 
+	if (udp_tunnel_type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	ahw->vxlan_port = ntohs(port);
 	adapter->flags |= QLCNIC_ADD_VXLAN_PORT;
 }
 
 static void qlcnic_del_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  sa_family_t sa_family, __be16 port,
+				  u8 udp_tunnel_type)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -495,6 +501,9 @@ static void qlcnic_del_vxlan_port(struct net_device *netdev,
 	    (ahw->vxlan_port != ntohs(port)))
 		return;
 
+	if (udp_tunnel_type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	adapter->flags |= QLCNIC_DEL_VXLAN_PORT;
 }
 #endif
@@ -518,8 +527,8 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_fdb_dump		= qlcnic_fdb_dump,
 	.ndo_get_phys_port_id	= qlcnic_get_phys_port_id,
 #ifdef CONFIG_QLCNIC_VXLAN
-	.ndo_add_vxlan_port	= qlcnic_add_vxlan_port,
-	.ndo_del_vxlan_port	= qlcnic_del_vxlan_port,
+	.ndo_add_udp_tunnel_port	= qlcnic_add_vxlan_port,
+	.ndo_del_udp_tunnel_port	= qlcnic_del_vxlan_port,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = qlcnic_poll_controller,
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d3f3e5d..829d447 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -650,9 +650,11 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_add_vxlan_port)
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
+		if (!dev->netdev_ops->ndo_add_udp_tunnel_port)
+			continue;
+
+		dev->netdev_ops->ndo_add_udp_tunnel_port(dev, sa_family, port,
+							 UDP_TUNNEL_TYPE_VXLAN);
 	}
 	rcu_read_unlock();
 }
@@ -668,9 +670,10 @@ static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_del_vxlan_port)
-			dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
-							    port);
+		if (!dev->netdev_ops->ndo_del_udp_tunnel_port)
+			continue;
+		dev->netdev_ops->ndo_del_udp_tunnel_port(dev, sa_family, port,
+							 UDP_TUNNEL_TYPE_VXLAN);
 	}
 	rcu_read_unlock();
 
@@ -2188,9 +2191,9 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
-/* Calls the ndo_add_vxlan_port of the caller in order to
+/* Calls the ndo_add_tunnel_port of the caller in order to
  * supply the listening VXLAN udp ports. Callers are expected
- * to implement the ndo_add_vxlan_port.
+ * to implement the ndo_add_tunnle_port.
  */
 void vxlan_get_rx_port(struct net_device *dev)
 {
@@ -2206,8 +2209,8 @@ void vxlan_get_rx_port(struct net_device *dev)
 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
 			port = inet_sk(vs->sock->sk)->inet_sport;
 			sa_family = vs->sock->sk->sk_family;
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
+			dev->netdev_ops->ndo_add_udp_tunnel_port(dev,
+					sa_family, port, UDP_TUNNEL_TYPE_VXLAN);
 		}
 	}
 	spin_unlock(&vn->sock_lock);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8e8fb3e..4b79db4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -966,18 +966,21 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
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
+ *				   sa_family_t sa_family, __be16 port,
+ *				   u8 udp_tunnel_type);
+ *	Called by udp based tunnels to notify a driver about the UDP port,
+ *	socket address family and the tunnel type that udp tunnels is
+ *	listening to. It is called only when a new port starts listening.
+ *	The operation is protected by the udp_net->sock_lock.
+ *
+ * void (*ndo_del_udp_tunnel_port)(struct  net_device *dev,
+ *				   sa_family_t sa_family, __be16 port,
+ *				   u8 udp_tunnel_type);
+ *	Called by udp based tunnels to notify the driver about a UDP port,
+ *	socket address family and the tunnel type that udp tunnel is not
+ *	listening to anymore.  The operation is protected by the
+ *	udp_net->sock_lock.
  *
  * void* (*ndo_dfwd_add_station)(struct net_device *pdev,
  *				 struct net_device *dev)
@@ -1130,12 +1133,12 @@ struct net_device_ops {
 						      bool new_carrier);
 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
 							struct netdev_phys_port_id *ppid);
-	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
+	void			(*ndo_add_udp_tunnel_port)(struct net_device *dev,
 						      sa_family_t sa_family,
-						      __be16 port);
-	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
+						      __be16 port, u8 type);
+	void			(*ndo_del_udp_tunnel_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
-						      __be16 port);
+						      __be16 port, u8 type);
 
 	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
 							struct net_device *dev);
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index ffd69cb..3f34c65 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -1,6 +1,8 @@
 #ifndef __NET_UDP_TUNNEL_H
 #define __NET_UDP_TUNNEL_H
 
+#define UDP_TUNNEL_TYPE_VXLAN 0x01
+
 struct udp_port_cfg {
 	u8			family;
 
-- 
1.7.9.5
