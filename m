From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_en: Add netdev support for TCP/IP offloads of vxlan tunneling
Date: Wed, 18 Dec 2013 16:05:28 +0200
Message-ID: <1387375528-2337-3-git-send-email-ogerlitz@mellanox.com>
References: <1387375528-2337-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, yanb@mellanox.com,
	ast@plumgrid.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38431 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754356Ab3LROFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 09:05:36 -0500
In-Reply-To: <1387375528-2337-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the device tunneling offloads mode is vxlan do the following

 - call SET_PORT with the relevant setting

 - add DMFS steering vxlan rule for the device self and multicast mac addresses
   of the form: {<ETH, outer-mac> <VXLAN, ANY vnid> <ETH, ANY mac>} --> RSS QP

 - set relevant QPC fields in RSS context and RX ring QPs

 - in TX flow, set WQE fields to generate HW checksum, and handle gso skbs
   which are marked for encapsulation such that the HW will segment them properly.

 - in RX flow, read HW offloaded checksum for encapsulated packets from the CQE

 - advertize hw_enc_features and NETIF_F_GSO_UDP_TUNNEL to the networking stack

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   95 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    6 ++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   15 +++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   14 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |    3 +-
 5 files changed, 130 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 6f92090..b4b36d8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -468,6 +468,53 @@ static void mlx4_en_u64_to_mac(unsigned char dst_mac[ETH_ALEN + 2], u64 src_mac)
 	memset(&dst_mac[ETH_ALEN], 0, 2);
 }
 
+
+static int mlx4_en_tunnel_steer_add(struct mlx4_en_priv *priv, unsigned char *addr,
+				    int qpn, u64 *reg_id)
+{
+	int err;
+	struct mlx4_spec_list spec_eth_outer = { {NULL} };
+	struct mlx4_spec_list spec_vxlan     = { {NULL} };
+	struct mlx4_spec_list spec_eth_inner = { {NULL} };
+
+	struct mlx4_net_trans_rule rule = {
+		.queue_mode = MLX4_NET_TRANS_Q_FIFO,
+		.exclusive = 0,
+		.allow_loopback = 1,
+		.promisc_mode = MLX4_FS_REGULAR,
+		.priority = MLX4_DOMAIN_NIC,
+	};
+
+	__be64 mac_mask = cpu_to_be64(MLX4_MAC_MASK << 16);
+
+	if ((priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN))
+		return 0; /* do nothing */
+
+	rule.port = priv->port;
+	rule.qpn = qpn;
+	INIT_LIST_HEAD(&rule.list);
+
+	spec_eth_outer.id = MLX4_NET_TRANS_RULE_ID_ETH;
+	memcpy(spec_eth_outer.eth.dst_mac, addr, ETH_ALEN);
+	memcpy(spec_eth_outer.eth.dst_mac_msk, &mac_mask, ETH_ALEN);
+
+	spec_vxlan.id = MLX4_NET_TRANS_RULE_ID_VXLAN;    /* any vxlan header */
+	spec_eth_inner.id = MLX4_NET_TRANS_RULE_ID_ETH;	 /* any inner eth header */
+
+	list_add_tail(&spec_eth_outer.list, &rule.list);
+	list_add_tail(&spec_vxlan.list,     &rule.list);
+	list_add_tail(&spec_eth_inner.list, &rule.list);
+
+	err = mlx4_flow_attach(priv->mdev->dev, &rule, reg_id);
+	if (err) {
+		en_err(priv, "failed to add vxlan steering rule, err %d\n", err);
+		return err;
+	}
+	en_dbg(DRV, priv, "added vxlan steering rule, mac %pM reg_id %llx\n", addr, *reg_id);
+	return 0;
+}
+
+
 static int mlx4_en_uc_steer_add(struct mlx4_en_priv *priv,
 				unsigned char *mac, int *qpn, u64 *reg_id)
 {
@@ -585,6 +632,10 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 	if (err)
 		goto steer_err;
 
+	if (mlx4_en_tunnel_steer_add(priv, priv->dev->dev_addr, *qpn,
+				     &priv->tunnel_reg_id))
+		goto tunnel_err;
+
 	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry) {
 		err = -ENOMEM;
@@ -599,6 +650,9 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 	return 0;
 
 alloc_err:
+	if (priv->tunnel_reg_id)
+		mlx4_flow_detach(priv->mdev->dev, priv->tunnel_reg_id);
+tunnel_err:
 	mlx4_en_uc_steer_release(priv, priv->dev->dev_addr, *qpn, reg_id);
 
 steer_err:
@@ -642,6 +696,11 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
 			}
 		}
 
+		if (priv->tunnel_reg_id) {
+			mlx4_flow_detach(priv->mdev->dev, priv->tunnel_reg_id);
+			priv->tunnel_reg_id = 0;
+		}
+
 		en_dbg(DRV, priv, "Releasing qp: port %d, qpn %d\n",
 		       priv->port, qpn);
 		mlx4_qp_release_range(dev, qpn, 1);
@@ -1044,6 +1103,12 @@ static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
 				if (err)
 					en_err(priv, "Fail to detach multicast address\n");
 
+				if (mclist->tunnel_reg_id) {
+					err = mlx4_flow_detach(priv->mdev->dev, mclist->tunnel_reg_id);
+					if (err)
+						en_err(priv, "Failed to detach multicast address\n");
+				}
+
 				/* remove from list */
 				list_del(&mclist->list);
 				kfree(mclist);
@@ -1061,6 +1126,10 @@ static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
 				if (err)
 					en_err(priv, "Fail to attach multicast address\n");
 
+				err = mlx4_en_tunnel_steer_add(priv, &mc_list[10], priv->base_qpn,
+							       &mclist->tunnel_reg_id);
+					if (err)
+						en_err(priv, "Failed to attach multicast address\n");
 			}
 		}
 	}
@@ -1598,6 +1667,15 @@ int mlx4_en_start_port(struct net_device *dev)
 		goto tx_err;
 	}
 
+	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
+		err = mlx4_SET_PORT_VXLAN(mdev->dev, priv->port, VXLAN_STEER_BY_OUTER_MAC);
+		if (err) {
+			en_err(priv, "Failed setting port L2 tunnel configuration, err %d\n",
+			       err);
+			goto tx_err;
+		}
+	}
+
 	/* Init port */
 	en_dbg(HW, priv, "Initializing port\n");
 	err = mlx4_INIT_PORT(mdev->dev, priv->port);
@@ -2400,6 +2478,14 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
 		dev->priv_flags |= IFF_UNICAST_FLT;
 
+	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
+		dev->hw_enc_features = NETIF_F_SG | NETIF_F_IP_CSUM |
+					NETIF_F_RXCSUM | NETIF_F_TSO |
+					NETIF_F_GSO_UDP_TUNNEL;
+		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
+	}
+
 	mdev->pndev[port] = dev;
 
 	netif_carrier_off(dev);
@@ -2429,6 +2515,15 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		goto out;
 	}
 
+	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
+		err = mlx4_SET_PORT_VXLAN(mdev->dev, priv->port, VXLAN_STEER_BY_OUTER_MAC);
+		if (err) {
+			en_err(priv, "Failed setting port L2 tunnel configuration, err %d\n",
+			       err);
+			goto out;
+		}
+	}
+
 	/* Init port */
 	en_warn(priv, "Initializing port\n");
 	err = mlx4_INIT_PORT(mdev->dev, priv->port);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index d3f5086..365dc56 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -68,6 +68,12 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	context->db_rec_addr = cpu_to_be64(priv->res.db.dma << 2);
 	if (!(dev->features & NETIF_F_HW_VLAN_CTAG_RX))
 		context->param3 |= cpu_to_be32(1 << 30);
+
+	if (!is_tx && !rss &&
+	    (mdev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
+		en_dbg(HW, priv, "Setting RX qp %x tunnel mode to RX tunneled & non-tunneled\n", qpn);
+		context->srqn |= cpu_to_be32(7 << 28); /* this fills bits 30:28 */
+	}
 }
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 07a1d0f..386e931 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -628,7 +628,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	int nr;
 	unsigned int length;
 	int polled = 0;
-	int ip_summed;
+	int ip_summed, l2_tunnel;
 	int factor = priv->cqe_factor;
 	u64 timestamp;
 
@@ -709,6 +709,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		length -= ring->fcs_del;
 		ring->bytes += length;
 		ring->packets++;
+		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
+			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
 
 		if (likely(dev->features & NETIF_F_RXCSUM)) {
 			if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
@@ -738,6 +740,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					gro_skb->data_len = length;
 					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+					if (l2_tunnel)
+						gro_skb->encapsulation = 1;
 					if ((cqe->vlan_my_qpn &
 					    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)) &&
 					    (dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
@@ -788,6 +792,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_record_rx_queue(skb, cq->ring);
 
+		if (l2_tunnel)
+			skb->encapsulation = 1;
+
 		if (dev->features & NETIF_F_RXHASH)
 			skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
 
@@ -1053,6 +1060,12 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 		rss_mask |=  MLX4_RSS_UDP_IPV4 | MLX4_RSS_UDP_IPV6;
 		rss_context->base_qpn_udp = rss_context->default_qpn;
 	}
+
+	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
+		en_info(priv, "Setting RSS context tunnel type to RSS on inner headers\n");
+		rss_mask |= MLX4_RSS_BY_INNER_HEADERS;
+	}
+
 	rss_context->flags = rss_mask;
 	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
 	for (i = 0; i < 10; i++)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e3adceb..160e86d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -39,6 +39,7 @@
 #include <linux/if_vlan.h>
 #include <linux/vmalloc.h>
 #include <linux/tcp.h>
+#include <linux/ip.h>
 #include <linux/moduleparam.h>
 
 #include "mlx4_en.h"
@@ -560,7 +561,10 @@ static int get_real_size(struct sk_buff *skb, struct net_device *dev,
 	int real_size;
 
 	if (skb_is_gso(skb)) {
-		*lso_header_size = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		if (skb->encapsulation)
+			*lso_header_size = (skb_inner_transport_header(skb) - skb->data) + inner_tcp_hdrlen(skb);
+		else
+			*lso_header_size = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		real_size = CTRL_SIZE + skb_shinfo(skb)->nr_frags * DS_SIZE +
 			ALIGN(*lso_header_size + 4, DS_SIZE);
 		if (unlikely(*lso_header_size != skb_headlen(skb))) {
@@ -859,6 +863,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx_info->inl = 1;
 	}
 
+	if (skb->encapsulation) {
+		struct iphdr *ipv4 = (struct iphdr *)skb_inner_network_header(skb);
+		if (ipv4->protocol == IPPROTO_TCP || ipv4->protocol == IPPROTO_UDP)
+			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP | MLX4_WQE_CTRL_ILP);
+		else
+			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
+	}
+
 	ring->prod += nr_txbb;
 
 	/* If we used a bounce buffer then copy descriptor back into place */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 123714c..766691c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -436,6 +436,7 @@ struct mlx4_en_mc_list {
 	enum mlx4_en_mclist_act	action;
 	u8			addr[ETH_ALEN];
 	u64			reg_id;
+	u64			tunnel_reg_id;
 };
 
 struct mlx4_en_frag_info {
@@ -567,7 +568,7 @@ struct mlx4_en_priv {
 	struct list_head filters;
 	struct hlist_head filter_hash[1 << MLX4_EN_FILTER_HASH_SHIFT];
 #endif
-
+	u64 tunnel_reg_id;
 };
 
 enum mlx4_en_wol {
-- 
1.7.1
