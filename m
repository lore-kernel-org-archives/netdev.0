From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 5/8] net/mlx5e: Avoid supporting udp tunnel port ndo for VF reps
Date: Tue, 21 Mar 2017 15:59:16 +0200
Message-ID: <20170321135919.25018-6-saeedm@mellanox.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38157 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757605AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

This was added to allow the TC offloading code to identify offloading
encap/decap vxlan rules.

The VF reps are effectively related to the same mlx5 PCI device as the
PF. Since the kernel invokes the (say) delete ndo for each netdev, the
FW erred on multiple vxlan dst port deletes when the port was deleted
from the system.

We fix that by keeping the registration to be carried out only by the
PF. Since the PF serves as the uplink device, the VF reps will look
up a port there and realize if they are ok to offload that.

Tested:
 <SETUP VFS>
 <SETUP switchdev mode to have representors>
 ip link add vxlan1 type vxlan id 44 dev ens5f0 dstport 9999
 ip link set vxlan1 up
 ip link del dev vxlan1

Fixes: 4a25730eb202 ('net/mlx5e: Add ndo_udp_tunnel_add to VF representors')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 4 ----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 2 --
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 9 +++++++--
 4 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f6a6ded204f6..dc52053128bc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -928,10 +928,6 @@ void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv);
 int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
 void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout);
-void mlx5e_add_vxlan_port(struct net_device *netdev,
-			  struct udp_tunnel_info *ti);
-void mlx5e_del_vxlan_port(struct net_device *netdev,
-			  struct udp_tunnel_info *ti);
 
 int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
 			    void *sp);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8ef64c4db2c2..66c133757a5e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3100,8 +3100,8 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 					    vf_stats);
 }
 
-void mlx5e_add_vxlan_port(struct net_device *netdev,
-			  struct udp_tunnel_info *ti)
+static void mlx5e_add_vxlan_port(struct net_device *netdev,
+				 struct udp_tunnel_info *ti)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
@@ -3114,8 +3114,8 @@ void mlx5e_add_vxlan_port(struct net_device *netdev,
 	mlx5e_vxlan_queue_work(priv, ti->sa_family, be16_to_cpu(ti->port), 1);
 }
 
-void mlx5e_del_vxlan_port(struct net_device *netdev,
-			  struct udp_tunnel_info *ti)
+static void mlx5e_del_vxlan_port(struct net_device *netdev,
+				 struct udp_tunnel_info *ti)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 2c864574a9d5..f621373bd7a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -393,8 +393,6 @@ static const struct net_device_ops mlx5e_netdev_ops_rep = {
 	.ndo_get_phys_port_name  = mlx5e_rep_get_phys_port_name,
 	.ndo_setup_tc            = mlx5e_rep_ndo_setup_tc,
 	.ndo_get_stats64         = mlx5e_rep_get_stats,
-	.ndo_udp_tunnel_add      = mlx5e_add_vxlan_port,
-	.ndo_udp_tunnel_del      = mlx5e_del_vxlan_port,
 	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
 	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 9c13abaf3885..fade7233dac5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -267,12 +267,15 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 			skb_flow_dissector_target(f->dissector,
 						  FLOW_DISSECTOR_KEY_ENC_PORTS,
 						  f->mask);
+		struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+		struct net_device *up_dev = mlx5_eswitch_get_uplink_netdev(esw);
+		struct mlx5e_priv *up_priv = netdev_priv(up_dev);
 
 		/* Full udp dst port must be given */
 		if (memchr_inv(&mask->dst, 0xff, sizeof(mask->dst)))
 			goto vxlan_match_offload_err;
 
-		if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->dst)) &&
+		if (mlx5e_vxlan_lookup_port(up_priv, be16_to_cpu(key->dst)) &&
 		    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap))
 			parse_vxlan_attr(spec, f);
 		else {
@@ -995,6 +998,8 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 			      struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct net_device *up_dev = mlx5_eswitch_get_uplink_netdev(esw);
+	struct mlx5e_priv *up_priv = netdev_priv(up_dev);
 	unsigned short family = ip_tunnel_info_af(tun_info);
 	struct ip_tunnel_key *key = &tun_info->key;
 	struct mlx5_encap_entry *e;
@@ -1015,7 +1020,7 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 		return -EOPNOTSUPP;
 	}
 
-	if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->tp_dst)) &&
+	if (mlx5e_vxlan_lookup_port(up_priv, be16_to_cpu(key->tp_dst)) &&
 	    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap)) {
 		tunnel_type = MLX5_HEADER_TYPE_VXLAN;
 	} else {
-- 
2.11.0
