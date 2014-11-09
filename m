From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V3 net-next 2/2] net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE
Date: Sun,  9 Nov 2014 13:51:53 +0200
Message-ID: <1415533913-7012-3-git-send-email-ogerlitz@mellanox.com>
References: <1415533913-7012-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42290 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751589AbaKILwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Nov 2014 06:52:09 -0500
In-Reply-To: <1415533913-7012-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaeli <shanim@mellanox.com>

When processing received traffic, pass CHECKSUM_COMPLETE status to the
stack, with calculated checksum for non TCP/UDP packets (such
as GRE or ICMP).

Although the stack expects checksum which doesn't include the pseudo
header, the HW adds it. To address that, we are subtracting the pseudo
header checksum from the checksum value provided by the HW.

In the IPv6 case, we also compute/add the IP header checksum which
is not added by the HW for such packets.

Cc: Jerry Chu <hkchu@google.com>
Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    5 +
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |    2 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  126 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/main.c       |    9 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    5 +-
 include/linux/mlx4/device.h                     |    1 +
 7 files changed, 142 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 8ea4d5b..6c64323 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -115,7 +115,7 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	"tso_packets",
 	"xmit_more",
 	"queue_stopped", "wake_queue", "tx_timeout", "rx_alloc_failed",
-	"rx_csum_good", "rx_csum_none", "tx_chksum_offload",
+	"rx_csum_good", "rx_csum_none", "rx_csum_complete", "tx_chksum_offload",
 
 	/* packet statistics */
 	"broadcast", "rx_prio_0", "rx_prio_1", "rx_prio_2", "rx_prio_3",
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0efbae9..d1eb25d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1893,6 +1893,7 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 		priv->rx_ring[i]->packets = 0;
 		priv->rx_ring[i]->csum_ok = 0;
 		priv->rx_ring[i]->csum_none = 0;
+		priv->rx_ring[i]->csum_complete = 0;
 	}
 }
 
@@ -2503,6 +2504,10 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	/* Query for default mac and max mtu */
 	priv->max_mtu = mdev->dev->caps.eth_mtu_cap[priv->port];
 
+	if (mdev->dev->caps.rx_checksum_flags_port[priv->port] &
+	    MLX4_RX_CSUM_MODE_VAL_NON_TCP_UDP)
+		priv->flags |= MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP;
+
 	/* Set default MAC */
 	dev->addr_len = ETH_ALEN;
 	mlx4_en_u64_to_mac(dev->dev_addr, mdev->dev->caps.def_mac[priv->port]);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 134b12e..6cb8007 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -155,11 +155,13 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	stats->rx_bytes = 0;
 	priv->port_stats.rx_chksum_good = 0;
 	priv->port_stats.rx_chksum_none = 0;
+	priv->port_stats.rx_chksum_complete = 0;
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		stats->rx_packets += priv->rx_ring[i]->packets;
 		stats->rx_bytes += priv->rx_ring[i]->bytes;
 		priv->port_stats.rx_chksum_good += priv->rx_ring[i]->csum_ok;
 		priv->port_stats.rx_chksum_none += priv->rx_ring[i]->csum_none;
+		priv->port_stats.rx_chksum_complete += priv->rx_ring[i]->csum_complete;
 	}
 	stats->tx_packets = 0;
 	stats->tx_bytes = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c83127e..8b04e32 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -42,6 +42,10 @@
 #include <linux/vmalloc.h>
 #include <linux/irq.h>
 
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ip6_checksum.h>
+#endif
+
 #include "mlx4_en.h"
 
 static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
@@ -643,6 +647,86 @@ static void mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
 	}
 }
 
+/* When hardware doesn't strip the vlan, we need to calculate the checksum
+ * over it and add it to the hardware's checksum calculation
+ */
+static inline __wsum get_fixed_vlan_csum(__wsum hw_checksum,
+					 struct vlan_hdr *vlanh)
+{
+	return csum_add(hw_checksum, *(__wsum *)vlanh);
+}
+
+/* Although the stack expects checksum which doesn't include the pseudo
+ * header, the HW adds it. To address that, we are subtracting the pseudo
+ * header checksum from the checksum value provided by the HW.
+ */
+static void get_fixed_ipv4_csum(__wsum hw_checksum, struct sk_buff *skb,
+				struct iphdr *iph)
+{
+	__u16 length_for_csum = 0;
+	__wsum csum_pseudo_header = 0;
+
+	length_for_csum = (be16_to_cpu(iph->tot_len) - (iph->ihl << 2));
+	csum_pseudo_header = csum_tcpudp_nofold(iph->saddr, iph->daddr,
+						length_for_csum, iph->protocol, 0);
+	skb->csum = csum_sub(hw_checksum, csum_pseudo_header);
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+/* In IPv6 packets, besides subtracting the pseudo header checksum,
+ * we also compute/add the IP header checksum which
+ * is not added by the HW.
+ */
+static int get_fixed_ipv6_csum(__wsum hw_checksum, struct sk_buff *skb,
+			       struct ipv6hdr *ipv6h)
+{
+	__wsum csum_pseudo_hdr = 0;
+
+	if (ipv6h->nexthdr == IPPROTO_FRAGMENT || ipv6h->nexthdr == IPPROTO_HOPOPTS)
+		return -1;
+	hw_checksum = csum_add(hw_checksum, (__force __wsum)(ipv6h->nexthdr << 8));
+
+	csum_pseudo_hdr = csum_partial(&ipv6h->saddr,
+				       sizeof(ipv6h->saddr) + sizeof(ipv6h->daddr), 0);
+	csum_pseudo_hdr = csum_add(csum_pseudo_hdr, (__force __wsum)ipv6h->payload_len);
+	csum_pseudo_hdr = csum_add(csum_pseudo_hdr, (__force __wsum)ntohs(ipv6h->nexthdr));
+
+	skb->csum = csum_sub(hw_checksum, csum_pseudo_hdr);
+	skb->csum = csum_add(skb->csum, csum_partial(ipv6h, sizeof(struct ipv6hdr), 0));
+	return 0;
+}
+#endif
+static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
+		      int hwtstamp_rx_filter)
+{
+	__wsum hw_checksum = 0;
+
+	void *hdr = (u8 *)va + sizeof(struct ethhdr);
+
+	hw_checksum = csum_unfold((__force __sum16)cqe->checksum);
+
+	if (((struct ethhdr *)va)->h_proto == htons(ETH_P_8021Q) &&
+	    hwtstamp_rx_filter != HWTSTAMP_FILTER_NONE) {
+		/* next protocol non IPv4 or IPv6 */
+		if (((struct vlan_hdr *)hdr)->h_vlan_encapsulated_proto
+		    != htons(ETH_P_IP) &&
+		    ((struct vlan_hdr *)hdr)->h_vlan_encapsulated_proto
+		    != htons(ETH_P_IPV6))
+			return -1;
+		hw_checksum = get_fixed_vlan_csum(hw_checksum, hdr);
+		hdr += sizeof(struct vlan_hdr);
+	}
+
+	if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4))
+		get_fixed_ipv4_csum(hw_checksum, skb, hdr);
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV6))
+		if (get_fixed_ipv6_csum(hw_checksum, skb, hdr))
+			return -1;
+#endif
+	return 0;
+}
+
 int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -744,13 +828,26 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
 
 		if (likely(dev->features & NETIF_F_RXCSUM)) {
-			if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
-			    (cqe->checksum == cpu_to_be16(0xffff))) {
-				ring->csum_ok++;
-				ip_summed = CHECKSUM_UNNECESSARY;
+			if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP |
+						      MLX4_CQE_STATUS_UDP)) {
+				if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
+				    cqe->checksum == cpu_to_be16(0xffff)) {
+					ip_summed = CHECKSUM_UNNECESSARY;
+					ring->csum_ok++;
+				} else {
+					ip_summed = CHECKSUM_NONE;
+					ring->csum_none++;
+				}
 			} else {
-				ip_summed = CHECKSUM_NONE;
-				ring->csum_none++;
+				if (priv->flags & MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP &&
+				    (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4 |
+							       MLX4_CQE_STATUS_IPV6))) {
+					ip_summed = CHECKSUM_COMPLETE;
+					ring->csum_complete++;
+				} else {
+					ip_summed = CHECKSUM_NONE;
+					ring->csum_none++;
+				}
 			}
 		} else {
 			ip_summed = CHECKSUM_NONE;
@@ -776,6 +873,15 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			if (!nr)
 				goto next;
 
+			if (ip_summed == CHECKSUM_COMPLETE) {
+				void *va = skb_frag_address(skb_shinfo(gro_skb)->frags);
+				if (check_csum(cqe, gro_skb, va, ring->hwtstamp_rx_filter)) {
+					ip_summed = CHECKSUM_NONE;
+					ring->csum_none++;
+					ring->csum_complete--;
+				}
+			}
+
 			skb_shinfo(gro_skb)->nr_frags = nr;
 			gro_skb->len = length;
 			gro_skb->data_len = length;
@@ -822,6 +928,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			goto next;
 		}
 
+		if (ip_summed == CHECKSUM_COMPLETE) {
+			if (check_csum(cqe, skb, skb->data, ring->hwtstamp_rx_filter)) {
+				ip_summed = CHECKSUM_NONE;
+				ring->csum_complete--;
+				ring->csum_none++;
+			}
+		}
+
 		skb->ip_summed = ip_summed;
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_record_rx_queue(skb, cq->ring);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 9f82196..2f6ba42 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1629,6 +1629,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 	struct mlx4_init_hca_param init_hca;
 	u64 icm_size;
 	int err;
+	struct mlx4_config_dev_params params;
 
 	if (!mlx4_is_slave(dev)) {
 		err = mlx4_QUERY_FW(dev);
@@ -1762,6 +1763,14 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		goto unmap_bf;
 	}
 
+	/* Query CONFIG_DEV parameters */
+	err = mlx4_config_dev_retrieval(dev, &params);
+	if (err && err != -ENOTSUPP) {
+		mlx4_err(dev, "Failed to query CONFIG_DEV parameters\n");
+	} else if (!err) {
+		dev->caps.rx_checksum_flags_port[1] = params.rx_csum_flags_port_1;
+		dev->caps.rx_checksum_flags_port[2] = params.rx_csum_flags_port_2;
+	}
 	priv->eq_table.inta_pin = adapter.inta_pin;
 	memcpy(dev->board_id, adapter.board_id, sizeof dev->board_id);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index ef83d12..de45674 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -326,6 +326,7 @@ struct mlx4_en_rx_ring {
 #endif
 	unsigned long csum_ok;
 	unsigned long csum_none;
+	unsigned long csum_complete;
 	int hwtstamp_rx_filter;
 	cpumask_var_t affinity_mask;
 };
@@ -449,6 +450,7 @@ struct mlx4_en_port_stats {
 	unsigned long rx_alloc_failed;
 	unsigned long rx_chksum_good;
 	unsigned long rx_chksum_none;
+	unsigned long rx_chksum_complete;
 	unsigned long tx_chksum_offload;
 #define NUM_PORT_STATS		9
 };
@@ -507,7 +509,8 @@ enum {
 	MLX4_EN_FLAG_ENABLE_HW_LOOPBACK	= (1 << 2),
 	/* whether we need to drop packets that hardware loopback-ed */
 	MLX4_EN_FLAG_RX_FILTER_NEEDED	= (1 << 3),
-	MLX4_EN_FLAG_FORCE_PROMISC	= (1 << 4)
+	MLX4_EN_FLAG_FORCE_PROMISC	= (1 << 4),
+	MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP	= (1 << 5),
 };
 
 #define MLX4_EN_MAC_HASH_SIZE (1 << BITS_PER_BYTE)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 5cc5eac..3d9bff0 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -497,6 +497,7 @@ struct mlx4_caps {
 	u16			hca_core_clock;
 	u64			phys_port_id[MLX4_MAX_PORTS + 1];
 	int			tunnel_offload_mode;
+	u8			rx_checksum_flags_port[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_buf_list {
-- 
1.7.1
