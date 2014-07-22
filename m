From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 03/10] vxlan: Remove vxlan_get_rx_port()
Date: Tue, 22 Jul 2014 03:19:46 -0700
Message-ID: <1406024393-6778-4-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:54604 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751471AbaGVKbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:31:02 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so11680474pad.27
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:31:01 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of specificly calling vxlan_get_rx_port(), Device driver
should now call udp_tunnel_get_rx_port() instead.  Making this change
to support future NICs and device drivers that may support more
UDP tunnel protocol offloads.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c      |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 drivers/net/vxlan.c                              |   26 ----------------------
 include/net/vxlan.h                              |    7 ------
 6 files changed, 4 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 028dc6e..b6badc0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2922,7 +2922,7 @@ static int be_open(struct net_device *netdev)
 
 #ifdef CONFIG_BE2NET_VXLAN
 	if (skyhawk_chip(adapter))
-		vxlan_get_rx_port(netdev);
+		udp_tunnel_get_rx_port(netdev);
 #endif
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d9fd53b..3cebb1b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4527,7 +4527,7 @@ static int i40e_open(struct net_device *netdev)
 	wr32(&pf->hw, I40E_GLLAN_TSOMSK_L, be32_to_cpu(TCP_FLAG_CWR) >> 16);
 
 #ifdef CONFIG_I40E_VXLAN
-	vxlan_get_rx_port(netdev);
+	udp_tunnel_get_rx_port(netdev);
 #endif
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index d5f6b91..d935ad3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1721,7 +1721,7 @@ int mlx4_en_start_port(struct net_device *dev)
 
 #ifdef CONFIG_MLX4_EN_VXLAN
 	if (priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS)
-		vxlan_get_rx_port(dev);
+		udp_tunnel_get_rx_port(dev);
 #endif
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index a39020d..df760f7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2002,7 +2002,7 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 
 #ifdef CONFIG_QLCNIC_VXLAN
 	if (qlcnic_encap_rx_offload(adapter))
-		vxlan_get_rx_port(netdev);
+		udp_tunnel_get_rx_port(netdev);
 #endif
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 829d447..93f2e40 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2191,32 +2191,6 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
-/* Calls the ndo_add_tunnel_port of the caller in order to
- * supply the listening VXLAN udp ports. Callers are expected
- * to implement the ndo_add_tunnle_port.
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
-			sa_family = vs->sock->sk->sk_family;
-			dev->netdev_ops->ndo_add_udp_tunnel_port(dev,
-					sa_family, port, UDP_TUNNEL_TYPE_VXLAN);
-		}
-	}
-	spin_unlock(&vn->sock_lock);
-}
-EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
-
 /* Initialize the device structure. */
 static void vxlan_setup(struct net_device *dev)
 {
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index d5f59f3..60f9d4d 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -50,11 +50,4 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 /* IPv6 header + UDP + VXLAN + Ethernet header */
 #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 
-#if IS_ENABLED(CONFIG_VXLAN)
-void vxlan_get_rx_port(struct net_device *netdev);
-#else
-static inline void vxlan_get_rx_port(struct net_device *netdev)
-{
-}
-#endif
 #endif
-- 
1.7.9.5
