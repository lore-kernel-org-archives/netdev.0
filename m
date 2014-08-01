From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 3/5] net: Refactor vxlan driver to make use of common UDP tunnel functions
Date: Fri,  1 Aug 2014 14:54:43 -0700
Message-ID: <1406930085-26445-4-git-send-email-azhou@nicira.com>
References: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:43850 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756366AbaHAV7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 17:59:45 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so6540179pab.2
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 14:59:42 -0700 (PDT)
In-Reply-To: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor vxlan driver to make use of the common UDP tunnel
functions.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c      |   16 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |   18 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   18 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   18 +-
 drivers/net/vxlan.c                              |  275 ++++++----------------
 include/linux/netdevice.h                        |   43 ++--
 include/net/vxlan.h                              |   23 +-
 net/ipv4/udp_tunnel.c                            |    8 +-
 net/openvswitch/vport-vxlan.c                    |    6 +-
 9 files changed, 161 insertions(+), 264 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f8cbd9a..6932787 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2921,7 +2921,7 @@ static int be_open(struct net_device *netdev)
 
 #ifdef CONFIG_BE2NET_VXLAN
 	if (skyhawk_chip(adapter))
-		vxlan_get_rx_port(netdev);
+		udp_tunnel_get_rx_port(netdev);
 #endif
 
 	return 0;
@@ -4324,7 +4324,7 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 
 #ifdef CONFIG_BE2NET_VXLAN
 static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-			      __be16 port)
+			      __be16 port, u64 protocol_bit)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct device *dev = &adapter->pdev->dev;
@@ -4333,6 +4333,9 @@ static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 	if (lancer_chip(adapter) || BEx_chip(adapter))
 		return;
 
+	if (protocol_bit != NETIF_F_RX_UT_VXLAN)
+		return;
+
 	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
 		dev_warn(dev, "Cannot add UDP port %d for VxLAN offloads\n",
 			 be16_to_cpu(port));
@@ -4365,13 +4368,16 @@ err:
 }
 
 static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-			      __be16 port)
+			      __be16 port, u64 protocol_bit)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	if (lancer_chip(adapter) || BEx_chip(adapter))
 		return;
 
+	if (protocol_bit != NETIF_F_RX_UT_VXLAN)
+		return;
+
 	if (adapter->vxlan_port != port)
 		return;
 
@@ -4408,8 +4414,8 @@ static const struct net_device_ops be_netdev_ops = {
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
index a77ad6d..343a110 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4526,7 +4526,7 @@ static int i40e_open(struct net_device *netdev)
 	wr32(&pf->hw, I40E_GLLAN_TSOMSK_L, be32_to_cpu(TCP_FLAG_CWR) >> 16);
 
 #ifdef CONFIG_I40E_VXLAN
-	vxlan_get_rx_port(netdev);
+	udp_tunnel_get_rx_port(netdev);
 #endif
 
 	return 0;
@@ -6946,7 +6946,8 @@ static u8 i40e_get_vxlan_port_idx(struct i40e_pf *pf, __be16 port)
  * @port: New UDP port number that VXLAN started listening to
  **/
 static void i40e_add_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
+				sa_family_t sa_family, __be16 port,
+				u64 protocol_bit)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -6957,6 +6958,9 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (protocol_bit != NETIF_F_RX_UT_VXLAN)
+		return;
+
 	idx = i40e_get_vxlan_port_idx(pf, port);
 
 	/* Check if port already exists */
@@ -6988,7 +6992,8 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
  * @port: UDP port number that VXLAN stopped listening to
  **/
 static void i40e_del_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
+				sa_family_t sa_family, __be16 port,
+				u64 protocol_bit)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -6998,6 +7003,9 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (protocol_bit != NETIF_F_RX_UT_VXLAN)
+		return;
+
 	idx = i40e_get_vxlan_port_idx(pf, port);
 
 	/* Check if port already exists */
@@ -7149,8 +7157,8 @@ static const struct net_device_ops i40e_netdev_ops = {
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
index e563b55..cf41622 100644
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
@@ -2327,7 +2327,8 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 }
 
 static void mlx4_en_add_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   sa_family_t sa_family, __be16 port,
+				   u64 protocol_bit)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
@@ -2338,6 +2339,9 @@ static void mlx4_en_add_vxlan_port(struct  net_device *dev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (protocol_bit != NETIF_F_RX_UT_VXLAN)
+		return;
+
 	current_port = priv->vxlan_port;
 	if (current_port && current_port != port) {
 		en_warn(priv, "vxlan port %d configured, can't add port %d\n",
@@ -2350,7 +2354,8 @@ static void mlx4_en_add_vxlan_port(struct  net_device *dev,
 }
 
 static void mlx4_en_del_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   sa_family_t sa_family, __be16 port,
+				   u64 protocol_bit)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
@@ -2361,6 +2366,9 @@ static void mlx4_en_del_vxlan_port(struct  net_device *dev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (protocol_bit != NETIF_F_RX_UT_VXLAN)
+		return;
+
 	current_port = priv->vxlan_port;
 	if (current_port != port) {
 		en_dbg(DRV, priv, "vxlan port %d isn't configured, ignoring\n", ntohs(port));
@@ -2398,8 +2406,8 @@ static const struct net_device_ops mlx4_netdev_ops = {
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
index 227cfb1..37ab266 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -470,7 +470,8 @@ static int qlcnic_get_phys_port_id(struct net_device *netdev,
 
 #ifdef CONFIG_QLCNIC_VXLAN
 static void qlcnic_add_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  sa_family_t sa_family, __be16 port,
+				  u64 protocol_bit)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -481,12 +482,16 @@ static void qlcnic_add_vxlan_port(struct net_device *netdev,
 	if (!qlcnic_encap_rx_offload(adapter) || ahw->vxlan_port)
 		return;
 
+	if (protocol_bit != NETIF_F_RX_UT_VXLAN)
+		return;
+
 	ahw->vxlan_port = ntohs(port);
 	adapter->flags |= QLCNIC_ADD_VXLAN_PORT;
 }
 
 static void qlcnic_del_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  sa_family_t sa_family, __be16 port,
+				  u64 protocol_bit)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -495,6 +500,9 @@ static void qlcnic_del_vxlan_port(struct net_device *netdev,
 	    (ahw->vxlan_port != ntohs(port)))
 		return;
 
+	if (protocol_bit != NETIF_F_RX_UT_VXLAN)
+		return;
+
 	adapter->flags |= QLCNIC_DEL_VXLAN_PORT;
 }
 #endif
@@ -518,8 +526,8 @@ static const struct net_device_ops qlcnic_netdev_ops = {
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
@@ -1993,7 +2001,7 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 
 #ifdef CONFIG_QLCNIC_VXLAN
 	if (qlcnic_encap_rx_offload(adapter))
-		vxlan_get_rx_port(netdev);
+		udp_tunnel_get_rx_port(netdev);
 #endif
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1fb7b37..65e3731 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -42,6 +42,7 @@
 #include <net/netns/generic.h>
 #include <net/vxlan.h>
 #include <net/protocol.h>
+#include <net/udp_tunnel.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -51,8 +52,6 @@
 
 #define VXLAN_VERSION	"0.1"
 
-#define PORT_HASH_BITS	8
-#define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 #define FDB_HASH_BITS	8
@@ -91,8 +90,7 @@ static const u8 all_zeros_mac[ETH_ALEN];
 /* per-network namespace private data for this module */
 struct vxlan_net {
 	struct list_head  vxlan_list;
-	struct hlist_head sock_list[PORT_HASH_SIZE];
-	spinlock_t	  sock_lock;
+	spinlock_t	  vxlan_list_lock; /* protecting vxlan_list */
 };
 
 union vxlan_addr {
@@ -253,14 +251,6 @@ static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
 	return &vs->vni_list[hash_32(id, VNI_HASH_BITS)];
 }
 
-/* Socket hash table head */
-static inline struct hlist_head *vs_head(struct net *net, __be16 port)
-{
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-
-	return &vn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
-}
-
 /* First remote destination for a forwarding entry.
  * Guaranteed to be non-NULL because remotes are never deleted.
  */
@@ -277,13 +267,7 @@ static inline struct vxlan_rdst *first_remote_rtnl(struct vxlan_fdb *fdb)
 /* Find VXLAN socket based on network namespace and UDP port */
 static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
 {
-	struct vxlan_sock *vs;
-
-	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
-		if (inet_sk(vs->sock->sk)->inet_sport == port)
-			return vs;
-	}
-	return NULL;
+	return (struct vxlan_sock *)udp_tunnel_find_sock(net, port);
 }
 
 static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, u32 id)
@@ -636,7 +620,7 @@ static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
 static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 {
 	struct net_device *dev;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
@@ -650,9 +634,12 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_add_vxlan_port)
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
+		if (!(dev->features & NETIF_F_RX_UT_VXLAN))
+			continue;
+
+		if (dev->netdev_ops->ndo_add_udp_tunnel_port)
+			dev->netdev_ops->ndo_add_udp_tunnel_port(dev,
+					sa_family, port, NETIF_F_RX_UT_VXLAN);
 	}
 	rcu_read_unlock();
 }
@@ -661,16 +648,19 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 {
 	struct net_device *dev;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_del_vxlan_port)
-			dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
-							    port);
+		if (!(dev->features & vs->uts.protocol_bit))
+			continue;
+
+		if (dev->netdev_ops->ndo_del_udp_tunnel_port)
+			dev->netdev_ops->ndo_del_udp_tunnel_port(dev,
+					sa_family, port, vs->uts.protocol_bit);
 	}
 	rcu_read_unlock();
 
@@ -1053,19 +1043,11 @@ static void vxlan_sock_hold(struct vxlan_sock *vs)
 
 void vxlan_sock_release(struct vxlan_sock *vs)
 {
-	struct sock *sk = vs->sock->sk;
-	struct net *net = sock_net(sk);
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-
 	if (!atomic_dec_and_test(&vs->refcnt))
 		return;
 
-	spin_lock(&vn->sock_lock);
-	hlist_del_rcu(&vs->hlist);
-	rcu_assign_sk_user_data(vs->sock->sk, NULL);
+	udp_tunnel_sock_release(&vs->uts);
 	vxlan_notify_del_rx_port(vs);
-	spin_unlock(&vn->sock_lock);
-
 	queue_work(vxlan_wq, &vs->del_work);
 }
 EXPORT_SYMBOL_GPL(vxlan_sock_release);
@@ -1078,7 +1060,7 @@ static void vxlan_igmp_join(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_join);
 	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 
@@ -1107,7 +1089,7 @@ static void vxlan_igmp_leave(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_leave);
 	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 
@@ -1338,7 +1320,6 @@ out:
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-
 static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	struct neighbour *n, bool isrouter)
 {
@@ -1572,13 +1553,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-static inline struct sk_buff *vxlan_handle_offloads(struct sk_buff *skb,
-						    bool udp_csum)
-{
-	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
-	return iptunnel_handle_offloads(skb, udp_csum, type);
-}
-
 #if IS_ENABLED(CONFIG_IPV6)
 static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   struct dst_entry *dst, struct sk_buff *skb,
@@ -1587,13 +1561,13 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   __be16 src_port, __be16 dst_port, __be32 vni,
 			   bool xnet)
 {
-	struct ipv6hdr *ip6h;
 	struct vxlanhdr *vxh;
-	struct udphdr *uh;
 	int min_headroom;
 	int err;
 
-	skb = vxlan_handle_offloads(skb, !udp_get_no_check6_tx(vs->sock->sk));
+	skb = udp_tunnel_handle_offloads(skb,
+					 !udp_get_no_check6_tx(
+						 vs->uts.sock->sk));
 	if (IS_ERR(skb))
 		return -EINVAL;
 
@@ -1621,38 +1595,8 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
 	vxh->vx_vni = vni;
 
-	__skb_push(skb, sizeof(*uh));
-	skb_reset_transport_header(skb);
-	uh = udp_hdr(skb);
-
-	uh->dest = dst_port;
-	uh->source = src_port;
-
-	uh->len = htons(skb->len);
-
-	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
-			      IPSKB_REROUTED);
-	skb_dst_set(skb, dst);
-
-	udp6_set_csum(udp_get_no_check6_tx(vs->sock->sk), skb,
-		      saddr, daddr, skb->len);
-
-	__skb_push(skb, sizeof(*ip6h));
-	skb_reset_network_header(skb);
-	ip6h		  = ipv6_hdr(skb);
-	ip6h->version	  = 6;
-	ip6h->priority	  = prio;
-	ip6h->flow_lbl[0] = 0;
-	ip6h->flow_lbl[1] = 0;
-	ip6h->flow_lbl[2] = 0;
-	ip6h->payload_len = htons(skb->len);
-	ip6h->nexthdr     = IPPROTO_UDP;
-	ip6h->hop_limit   = ttl;
-	ip6h->daddr	  = *daddr;
-	ip6h->saddr	  = *saddr;
-
-	ip6tunnel_xmit(skb, dev);
+	udp_tunnel6_xmit_skb(vs->uts.sock, dst, skb, dev, saddr, daddr, prio,
+			     ttl, src_port, dst_port);
 	return 0;
 }
 #endif
@@ -1663,11 +1607,11 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet)
 {
 	struct vxlanhdr *vxh;
-	struct udphdr *uh;
 	int min_headroom;
 	int err;
 
-	skb = vxlan_handle_offloads(skb, !vs->sock->sk->sk_no_check_tx);
+	skb = udp_tunnel_handle_offloads(skb,
+					 !vs->uts.sock->sk->sk_no_check_tx);
 	if (IS_ERR(skb))
 		return -EINVAL;
 
@@ -1693,20 +1637,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
 	vxh->vx_vni = vni;
 
-	__skb_push(skb, sizeof(*uh));
-	skb_reset_transport_header(skb);
-	uh = udp_hdr(skb);
-
-	uh->dest = dst_port;
-	uh->source = src_port;
-
-	uh->len = htons(skb->len);
-
-	udp_set_csum(vs->sock->sk->sk_no_check_tx, skb,
-		     src, dst, skb->len);
-
-	return iptunnel_xmit(vs->sock->sk, rt, skb, src, dst, IPPROTO_UDP,
-			     tos, ttl, df, xnet);
+	return udp_tunnel_xmit_skb(vs->uts.sock, rt, skb, src, dst, tos,
+				   ttl, df, src_port, dst_port, xnet);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
@@ -1831,18 +1763,18 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 
-		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
-				     fl4.saddr, dst->sin.sin_addr.s_addr,
-				     tos, ttl, df, src_port, dst_port,
-				     htonl(vni << 8),
-				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
+		err = udp_tunnel_xmit_skb(vxlan->vn_sock->uts.sock, rt, skb,
+					  fl4.saddr, dst->sin.sin_addr.s_addr,
+					  tos, ttl, df, src_port, dst_port,
+					  !net_eq(vxlan->net,
+						  dev_net(vxlan->dev)));
 
 		if (err < 0)
 			goto rt_tx_error;
 		iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		struct sock *sk = vxlan->vn_sock->sock->sk;
+		struct sock *sk = vxlan->vn_sock->uts.sock->sk;
 		struct dst_entry *ndst;
 		struct flowi6 fl6;
 		u32 flags;
@@ -2038,7 +1970,7 @@ static int vxlan_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	spin_lock(&vn->sock_lock);
+	spin_lock(&vn->vxlan_list_lock);
 	vs = vxlan_find_sock(vxlan->net, vxlan->dst_port);
 	if (vs) {
 		/* If we have a socket with same port already, reuse it */
@@ -2049,7 +1981,7 @@ static int vxlan_init(struct net_device *dev)
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->sock_work);
 	}
-	spin_unlock(&vn->sock_lock);
+	spin_unlock(&vn->vxlan_list_lock);
 
 	return 0;
 }
@@ -2188,32 +2120,6 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
-/* Calls the ndo_add_vxlan_port of the caller in order to
- * supply the listening VXLAN udp ports. Callers are expected
- * to implement the ndo_add_vxlan_port.
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
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
-		}
-	}
-	spin_unlock(&vn->sock_lock);
-}
-EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
-
 /* Initialize the device structure. */
 static void vxlan_setup(struct net_device *dev)
 {
@@ -2335,59 +2241,44 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
 static void vxlan_del_work(struct work_struct *work)
 {
 	struct vxlan_sock *vs = container_of(work, struct vxlan_sock, del_work);
-
-	sk_release_kernel(vs->sock->sk);
+	sk_release_kernel(vs->uts.sock->sk);
 	kfree_rcu(vs, rcu);
 }
 
-static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
-					__be16 port, u32 flags)
+/* Create new listen socket if needed */
+static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
+					      vxlan_rcv_t rcv, void *data,
+					      u32 flags)
 {
-	struct socket *sock;
-	struct udp_port_cfg udp_conf;
-	int err;
+	bool ipv6 = !!(flags & VXLAN_F_IPV6);
+	struct vxlan_sock *vs;
+	struct udp_tunnel_socket_cfg vxlan_ts_cfg;
+	unsigned int h;
 
-	memset(&udp_conf, 0, sizeof(udp_conf));
+	memset(&vxlan_ts_cfg, 0, sizeof(struct udp_tunnel_socket_cfg));
 
 	if (ipv6) {
-		udp_conf.family = AF_INET6;
-		udp_conf.use_udp6_tx_checksums =
+		vxlan_ts_cfg.port.family = AF_INET6;
+		vxlan_ts_cfg.port.use_udp6_tx_checksums =
 		    !!(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
-		udp_conf.use_udp6_rx_checksums =
+		vxlan_ts_cfg.port.use_udp6_rx_checksums =
 		    !!(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
 	} else {
-		udp_conf.family = AF_INET;
-		udp_conf.local_ip.s_addr = INADDR_ANY;
-		udp_conf.use_udp_checksums =
+		vxlan_ts_cfg.port.family = AF_INET;
+		vxlan_ts_cfg.port.local_ip.s_addr = INADDR_ANY;
+		vxlan_ts_cfg.port.use_udp_checksums =
 		    !!(flags & VXLAN_F_UDP_CSUM);
 	}
 
-	udp_conf.local_udp_port = port;
-
-	/* Open UDP socket */
-	err = udp_sock_create(net, &udp_conf, &sock);
-	if (err < 0)
-		return ERR_PTR(err);
-
-	/* Disable multicast loopback */
-	inet_sk(sock->sk)->mc_loop = 0;
-
-	return sock;
-}
-
-/* Create new listen socket if needed */
-static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      vxlan_rcv_t *rcv, void *data,
-					      u32 flags)
-{
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_sock *vs;
-	struct socket *sock;
-	struct sock *sk;
-	unsigned int h;
-	bool ipv6 = !!(flags & VXLAN_F_IPV6);
+	vxlan_ts_cfg.port.local_udp_port = port;
+	vxlan_ts_cfg.encap_type = 1;
+	vxlan_ts_cfg.encap_rcv = vxlan_udp_encap_recv;
+	vxlan_ts_cfg.encap_destroy = NULL;
+	vxlan_ts_cfg.protocol_bit = NETIF_F_RX_UT_VXLAN;
 
-	vs = kzalloc(sizeof(*vs), GFP_KERNEL);
+	vs = (struct vxlan_sock *)create_udp_tunnel_sock(net, sizeof(*vs),
+							 NULL,
+							 &vxlan_ts_cfg);
 	if (!vs)
 		return ERR_PTR(-ENOMEM);
 
@@ -2396,47 +2287,25 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	INIT_WORK(&vs->del_work, vxlan_del_work);
 
-	sock = vxlan_create_sock(net, ipv6, port, flags);
-	if (IS_ERR(sock)) {
-		kfree(vs);
-		return ERR_CAST(sock);
-	}
-
-	vs->sock = sock;
-	sk = sock->sk;
 	atomic_set(&vs->refcnt, 1);
+
 	vs->rcv = rcv;
-	vs->data = data;
-	rcu_assign_sk_user_data(vs->sock->sk, vs);
+	vs->rcv_data = data;
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
 	vs->udp_offloads.callbacks.gro_receive  = vxlan_gro_receive;
 	vs->udp_offloads.callbacks.gro_complete = vxlan_gro_complete;
 
-	spin_lock(&vn->sock_lock);
-	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
 	vxlan_notify_add_rx_port(vs);
-	spin_unlock(&vn->sock_lock);
-
-	/* Mark socket as an encapsulation socket. */
-	udp_sk(sk)->encap_type = 1;
-	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
-#if IS_ENABLED(CONFIG_IPV6)
-	if (ipv6)
-		ipv6_stub->udpv6_encap_enable();
-	else
-#endif
-		udp_encap_enable();
 
 	return vs;
 }
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-				  vxlan_rcv_t *rcv, void *data,
+				  vxlan_rcv_t rcv, void *data,
 				  bool no_share, u32 flags)
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
 	vs = vxlan_socket_create(net, port, rcv, data, flags);
@@ -2446,7 +2315,6 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 	if (no_share)	/* Return error if sharing is not allowed. */
 		return vs;
 
-	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(net, port);
 	if (vs) {
 		if (vs->rcv == rcv)
@@ -2454,7 +2322,6 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 		else
 			vs = ERR_PTR(-EBUSY);
 	}
-	spin_unlock(&vn->sock_lock);
 
 	if (!vs)
 		vs = ERR_PTR(-EINVAL);
@@ -2473,10 +2340,10 @@ static void vxlan_sock_work(struct work_struct *work)
 	struct vxlan_sock *nvs;
 
 	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags);
-	spin_lock(&vn->sock_lock);
+	spin_lock(&vn->vxlan_list_lock);
 	if (!IS_ERR(nvs))
 		vxlan_vs_add_dev(nvs, vxlan);
-	spin_unlock(&vn->sock_lock);
+	spin_unlock(&vn->vxlan_list_lock);
 
 	dev_put(vxlan->dev);
 }
@@ -2643,10 +2510,10 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 
-	spin_lock(&vn->sock_lock);
+	spin_lock(&vn->vxlan_list_lock);
 	if (!hlist_unhashed(&vxlan->hlist))
 		hlist_del_rcu(&vxlan->hlist);
-	spin_unlock(&vn->sock_lock);
+	spin_unlock(&vn->vxlan_list_lock);
 
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
@@ -2804,13 +2671,9 @@ static struct notifier_block vxlan_notifier_block __read_mostly = {
 static __net_init int vxlan_init_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	unsigned int h;
 
 	INIT_LIST_HEAD(&vn->vxlan_list);
-	spin_lock_init(&vn->sock_lock);
-
-	for (h = 0; h < PORT_HASH_SIZE; ++h)
-		INIT_HLIST_HEAD(&vn->sock_list[h]);
+	spin_lock_init(&vn->vxlan_list_lock);
 
 	return 0;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3837739..41d0ad0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -966,18 +966,22 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
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
+ *			      sa_family_t sa_family, __be16 port,
+ *			      u64 protocol_bit);
+ *	Called by a UDP based tunnel protocol to notiy a driver about the UDP
+ *	port and socket address family that the UDP tunnel protocol is
+ *	listnening to. It is called only when a new port starts listening.
+ *	protocol_bit is one of NETIF_F_RX_UT_ fields. The operation is
+ *	protected by the udp_tunnel_net->sock_lock.
+ *
+ * void (*ndo_del_udp_tunnel_port)(struct  net_device *dev,
+ *			      sa_family_t sa_family, __be16 port,
+ *			      u64 protocol_bit);
+ *	Called by a UDP based tunnel protocol to notify the driver about a
+ *	UDP port and socket address family that the UDP tunnel protocol is
+ *	not listening to anymore. protocol_bit is one of the NETIF_F_RX_UT_
+ *	fields. The operation is protected by the udp_tunnel_net->sock_lock.
  *
  * void* (*ndo_dfwd_add_station)(struct net_device *pdev,
  *				 struct net_device *dev)
@@ -1130,13 +1134,14 @@ struct net_device_ops {
 						      bool new_carrier);
 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
 							struct netdev_phys_port_id *ppid);
-	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
-						      sa_family_t sa_family,
-						      __be16 port);
-	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
-						      sa_family_t sa_family,
-						      __be16 port);
-
+	void			(*ndo_add_udp_tunnel_port)(
+					struct net_device *dev,
+					sa_family_t sa_family, __be16 port,
+					u64 protocol_bit);
+	void			(*ndo_del_udp_tunnel_port)(
+					struct net_device *dev,
+					sa_family_t sa_family, __be16 port,
+					u64 protocol_bit);
 	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
 							struct net_device *dev);
 	void			(*ndo_dfwd_del_station)(struct net_device *pdev,
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index d5f59f3..50e98f4 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -4,23 +4,25 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/udp.h>
+#include <net/udp_tunnel.h>
 
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 
 struct vxlan_sock;
-typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
 
-/* per UDP socket information */
+typedef void (*vxlan_rcv_t)(struct vxlan_sock *vs, struct sk_buff *skb,
+			    __be32 key);
+
+/* per vxlan socket information */
 struct vxlan_sock {
-	struct hlist_node hlist;
-	vxlan_rcv_t	 *rcv;
-	void		 *data;
+	struct udp_tunnel_sock uts;  /* Must be the first member */
 	struct work_struct del_work;
-	struct socket	 *sock;
 	struct rcu_head	  rcu;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
+	vxlan_rcv_t	  rcv;
+	void		  *rcv_data;
 	struct udp_offload udp_offloads;
 };
 
@@ -35,7 +37,7 @@ struct vxlan_sock {
 #define VXLAN_F_UDP_ZERO_CSUM6_RX	0x100
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-				  vxlan_rcv_t *rcv, void *data,
+				  vxlan_rcv_t rcv, void *data,
 				  bool no_share, u32 flags);
 
 void vxlan_sock_release(struct vxlan_sock *vs);
@@ -50,11 +52,4 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
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
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 8d22ecd..cc8b91c 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -326,10 +326,14 @@ void udp_tunnel_get_rx_port(struct net_device *dev)
 	spin_lock(&utn->sock_lock);
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
 		hlist_for_each_entry_rcu(uts, &utn->sock_list[i], hlist) {
+			if (!(dev->features & uts->protocol_bit))
+				continue;
+
 			port = inet_sk(uts->sock->sk)->inet_sport;
 			sa_family = uts->sock->sk->sk_family;
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
+
+			dev->netdev_ops->ndo_add_udp_tunnel_port(dev,
+					sa_family, port, uts->protocol_bit);
 		}
 	}
 	spin_unlock(&utn->sock_lock);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d8b7e24..7599efd 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -59,7 +59,7 @@ static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 {
 	struct ovs_key_ipv4_tunnel tun_key;
-	struct vport *vport = vs->data;
+	struct vport *vport = vs->rcv_data;
 	struct iphdr *iph;
 	__be64 key;
 
@@ -74,7 +74,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
 {
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
+	__be16 dst_port = inet_sk(vxlan_port->vs->uts.sock->sk)->inet_sport;
 
 	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
 		return -EMSGSIZE;
@@ -139,7 +139,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
+	__be16 dst_port = inet_sk(vxlan_port->vs->uts.sock->sk)->inet_sport;
 	struct rtable *rt;
 	struct flowi4 fl;
 	__be16 src_port;
-- 
1.7.9.5
