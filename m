From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH v1 2/6] net: Add a generic udp_offload_get_port function
Date: Mon, 23 Nov 2015 13:02:55 -0800
Message-ID: <1448312579-159544-3-git-send-email-anjali.singhai@intel.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Cc: jesse@kernel.org, Anjali Singhai Jain <anjali.singhai@intel.com>,
	Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48052 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097AbbKWUqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 15:46:16 -0500
In-Reply-To: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new function udp_offload_get_port replaces vxlan_get_rx_port().
This is a generic function that will help replay all udp tunnel ports
irrespective of tunnel type.
This way when new udp tunnels get added this function need not change.

Note: Drivers besides i40e are compile tested with this change.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  5 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c        |  4 +++-
 drivers/net/ethernet/emulex/benet/be_main.c      |  4 +++-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  3 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  5 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  5 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  3 ++-
 drivers/net/vxlan.c                              | 29 ++----------------------
 include/linux/netdevice.h                        |  2 ++
 include/net/protocol.h                           |  2 ++
 include/net/vxlan.h                              |  8 -------
 net/ipv4/udp_offload.c                           | 27 ++++++++++++++++++++++
 13 files changed, 53 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ad2782f..56777c8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -60,6 +60,7 @@
 #include <linux/semaphore.h>
 #include <linux/stringify.h>
 #include <linux/vmalloc.h>
+#include <net/protocol.h>
 
 #include "bnx2x.h"
 #include "bnx2x_init.h"
@@ -10293,7 +10294,7 @@ sp_rtnl_not_reset:
 			netdev_info(bp->dev,
 				    "Deleted vxlan dest port %d", port);
 			bp->vxlan_dst_port = 0;
-			vxlan_get_rx_port(bp->dev);
+			udp_offload_get_port(bp->dev);
 		}
 	}
 #endif
@@ -12499,7 +12500,7 @@ static int bnx2x_open(struct net_device *dev)
 
 #ifdef CONFIG_BNX2X_VXLAN
 	if (IS_PF(bp))
-		vxlan_get_rx_port(dev);
+		udp_offload_get_port(dev);
 #endif
 
 	return 0;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5b96ddf..f49ca38 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -39,6 +39,7 @@
 #include <net/ip6_checksum.h>
 #if defined(CONFIG_VXLAN) || defined(CONFIG_VXLAN_MODULE)
 #include <net/vxlan.h>
+#include <net/protocol.h>
 #endif
 #ifdef CONFIG_NET_RX_BUSY_POLL
 #include <net/busy_poll.h>
@@ -4589,7 +4590,7 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 
 	if (irq_re_init) {
 #if defined(CONFIG_VXLAN) || defined(CONFIG_VXLAN_MODULE)
-		vxlan_get_rx_port(bp->dev);
+		udp_offload_get_port(bp->dev);
 #endif
 		if (!bnxt_hwrm_tunnel_dst_port_alloc(
 				bp, htons(0x17c1),
@@ -5458,6 +5459,7 @@ static void bnxt_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
 
 	if (type != UDP_TUNNEL_VXLAN)
 		return;
+
 	if (bp->vxlan_port_cnt && bp->vxlan_port == port) {
 		bp->vxlan_port_cnt--;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e699deca..a4da753 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -25,6 +25,7 @@
 #include <net/busy_poll.h>
 #include <net/udp_tunnel.h>
 #include <net/vxlan.h>
+#include <net/protocol.h>
 
 MODULE_VERSION(DRV_VER);
 MODULE_DESCRIPTION(DRV_DESC " " DRV_VER);
@@ -3604,7 +3605,7 @@ static int be_open(struct net_device *netdev)
 
 #ifdef CONFIG_BE2NET_VXLAN
 	if (skyhawk_chip(adapter))
-		vxlan_get_rx_port(netdev);
+		udp_offload_get_port(netdev);
 #endif
 
 	return 0;
@@ -5239,6 +5240,7 @@ static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 
 	if (type != UDP_TUNNEL_VXLAN)
 		return;
+
 	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
 		return;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 447d5e6..1564a13 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -23,6 +23,7 @@
 #if IS_ENABLED(CONFIG_FM10K_VXLAN)
 #include <net/udp_tunnel.h>
 #include <net/vxlan.h>
+#include <net/protocol.h>
 #endif /* CONFIG_FM10K_VXLAN */
 
 /**
@@ -573,7 +574,7 @@ int fm10k_open(struct net_device *netdev)
 
 #if IS_ENABLED(CONFIG_FM10K_VXLAN)
 	/* update VXLAN port configuration */
-	vxlan_get_rx_port(netdev);
+	udp_offload_get_port(netdev);
 
 #endif
 	fm10k_up(interface);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 520e34e..4be0a26 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -31,6 +31,7 @@
 #include <net/vxlan.h>
 #endif
 #include <net/udp_tunnel.h>
+#include <net/protocol.h>
 
 const char i40e_driver_name[] = "i40e";
 static const char i40e_driver_string[] =
@@ -5303,9 +5304,7 @@ int i40e_open(struct net_device *netdev)
 						       TCP_FLAG_CWR) >> 16);
 	wr32(&pf->hw, I40E_GLLAN_TSOMSK_L, be32_to_cpu(TCP_FLAG_CWR) >> 16);
 
-#ifdef CONFIG_I40E_VXLAN
-	vxlan_get_rx_port(netdev);
-#endif
+	udp_offload_get_port(netdev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 76ccc77..ba92c7a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -52,6 +52,7 @@
 #include <scsi/fc/fc_fcoe.h>
 #include <net/udp_tunnel.h>
 #include <net/vxlan.h>
+#include <net/protocol.h>
 
 #ifdef CONFIG_OF
 #include <linux/of_net.h>
@@ -5823,7 +5824,7 @@ static int ixgbe_open(struct net_device *netdev)
 
 	ixgbe_clear_vxlan_port(adapter);
 #ifdef CONFIG_IXGBE_VXLAN
-	vxlan_get_rx_port(netdev);
+	udp_offload_get_port(netdev);
 #endif
 
 	return 0;
@@ -6913,7 +6914,7 @@ static void ixgbe_service_task(struct work_struct *work)
 #ifdef CONFIG_IXGBE_VXLAN
 	if (adapter->flags2 & IXGBE_FLAG2_VXLAN_REREG_NEEDED) {
 		adapter->flags2 &= ~IXGBE_FLAG2_VXLAN_REREG_NEEDED;
-		vxlan_get_rx_port(adapter->netdev);
+		udp_offload_get_port(adapter->netdev);
 	}
 #endif /* CONFIG_IXGBE_VXLAN */
 	ixgbe_reset_subtask(adapter);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2cb19c7..b91b8f1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -41,6 +41,7 @@
 #include <net/busy_poll.h>
 #include <net/udp_tunnel.h>
 #include <net/vxlan.h>
+#include <net/protocol.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
@@ -1684,7 +1685,7 @@ int mlx4_en_start_port(struct net_device *dev)
 
 #ifdef CONFIG_MLX4_EN_VXLAN
 	if (priv->mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
-		vxlan_get_rx_port(dev);
+		udp_offload_get_port(dev);
 #endif
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index aa38dbb..a640872 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -19,6 +19,7 @@
 #ifdef CONFIG_QLCNIC_VXLAN
 #include <net/udp_tunnel.h>
 #include <net/vxlan.h>
+#include <net/protocol.h>
 #endif
 
 #include "qlcnic.h"
@@ -2026,7 +2027,7 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 
 #ifdef CONFIG_QLCNIC_VXLAN
 	if (qlcnic_encap_rx_offload(adapter))
-		vxlan_get_rx_port(netdev);
+		udp_offload_get_port(netdev);
 #endif
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5490629..702f9be 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2424,33 +2424,6 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
-/* Calls the ndo_add_udp_tunnel_port of the caller in order to
- * supply the listening VXLAN udp ports. Callers are expected
- * to implement the ndo_add_tunnel_port.
- */
-void vxlan_get_rx_port(struct net_device *dev)
-{
-	struct vxlan_sock *vs;
-	struct net *net = dev_net(dev);
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	sa_family_t sa_family;
-	__be16 port;
-	unsigned int i;
-
-	spin_lock(&vn->sock_lock);
-	for (i = 0; i < PORT_HASH_SIZE; ++i) {
-		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
-			port = inet_sk(vs->sock->sk)->inet_sport;
-			sa_family = vxlan_get_sk_family(vs);
-			dev->netdev_ops->ndo_add_udp_tunnel_port(dev, sa_family,
-							      port,
-							      UDP_TUNNEL_VXLAN);
-		}
-	}
-	spin_unlock(&vn->sock_lock);
-}
-EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
-
 /* Initialize the device structure. */
 static void vxlan_setup(struct net_device *dev)
 {
@@ -2639,6 +2612,8 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
+	vs->udp_offloads.tunnel_type = UDP_TUNNEL_VXLAN;
+	vs->udp_offloads.family = ipv6 ? AF_INET6 : AF_INET;
 	vs->udp_offloads.callbacks.gro_receive  = vxlan_gro_receive;
 	vs->udp_offloads.callbacks.gro_complete = vxlan_gro_complete;
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index eaecc42..0073009 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2075,6 +2075,8 @@ struct udp_offload_callbacks {
 
 struct udp_offload {
 	__be16			 port;
+	u8			 tunnel_type;
+	u8			 family;
 	u8			 ipproto;
 	struct udp_offload_callbacks callbacks;
 };
diff --git a/include/net/protocol.h b/include/net/protocol.h
index d6fcc1f..738bfc6 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -110,6 +110,8 @@ void inet_unregister_protosw(struct inet_protosw *p);
 int  udp_add_offload(struct udp_offload *prot);
 void udp_del_offload(struct udp_offload *prot);
 
+void udp_offload_get_port(struct net_device *dev);
+
 #if IS_ENABLED(CONFIG_IPV6)
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
 int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index c1c899c..926455e 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -242,14 +242,6 @@ static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 /* IPv6 header + UDP + VXLAN + Ethernet header */
 #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 
-#if IS_ENABLED(CONFIG_VXLAN)
-void vxlan_get_rx_port(struct net_device *netdev);
-#else
-static inline void vxlan_get_rx_port(struct net_device *netdev)
-{
-}
-#endif
-
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
 	return vs->sock->sk->sk_family;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index f938616..8597020 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -290,6 +290,33 @@ unlock:
 }
 EXPORT_SYMBOL(udp_del_offload);
 
+void udp_offload_get_port(struct net_device *dev)
+{
+	struct udp_offload_priv __rcu **head;
+	struct udp_offload_priv *uo_priv;
+	struct udp_offload *uo;
+
+	if (udp_offload_base)
+		head = &udp_offload_base;
+	else
+		return;
+
+	spin_lock(&udp_offload_lock);
+	uo_priv = udp_deref_protected(*head);
+	for (; uo_priv != NULL; uo_priv = udp_deref_protected(*head)) {
+		/* call the right add port */
+		uo = uo_priv->offload;
+		if (uo && dev->netdev_ops->ndo_add_udp_tunnel_port)
+			dev->netdev_ops->ndo_add_udp_tunnel_port(dev,
+							uo->family,
+							uo->port,
+							uo->tunnel_type);
+		head = &uo_priv->next;
+	}
+	spin_unlock(&udp_offload_lock);
+}
+EXPORT_SYMBOL(udp_offload_get_port);
+
 struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 				 struct udphdr *uh)
 {
-- 
1.8.1.4
