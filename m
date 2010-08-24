From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 13/14] mlx4_en: Moving to work with GRO
Date: Tue, 24 Aug 2010 16:46:46 +0300
Message-ID: <4C73CD46.10907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50191 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755250Ab0HXNqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_ethtool.c |   58 +---------------------------------
 drivers/net/mlx4/en_main.c    |    5 ---
 drivers/net/mlx4/en_netdev.c  |    3 +-
 drivers/net/mlx4/en_rx.c      |   68 ++++++++---------------------------------
 drivers/net/mlx4/en_tx.c      |    1 +
 drivers/net/mlx4/mlx4_en.h    |    6 ---
 6 files changed, 17 insertions(+), 124 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index acdcda8..01634a3 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -39,21 +39,6 @@
 #include "en_port.h"
 
 
-static void mlx4_en_update_lro_stats(struct mlx4_en_priv *priv)
-{
-	int i;
-
-	priv->port_stats.lro_aggregated = 0;
-	priv->port_stats.lro_flushed = 0;
-	priv->port_stats.lro_no_desc = 0;
-
-	for (i = 0; i < priv->rx_ring_num; i++) {
-		priv->port_stats.lro_aggregated += priv->rx_ring[i].lro.stats.aggregated;
-		priv->port_stats.lro_flushed += priv->rx_ring[i].lro.stats.flushed;
-		priv->port_stats.lro_no_desc += priv->rx_ring[i].lro.stats.no_desc;
-	}
-}
-
 static void
 mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
@@ -112,7 +97,7 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	"tx_heartbeat_errors", "tx_window_errors",
 
 	/* port statistics */
-	"lro_aggregated", "lro_flushed", "lro_no_desc", "tso_packets",
+	"tso_packets",
 	"queue_stopped", "wake_queue", "tx_timeout", "rx_alloc_failed",
 	"rx_csum_good", "rx_csum_none", "tx_chksum_offload",
 
@@ -122,7 +107,7 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	"tx_prio_1", "tx_prio_2", "tx_prio_3", "tx_prio_4", "tx_prio_5",
 	"tx_prio_6", "tx_prio_7",
 };
-#define NUM_MAIN_STATS	21
+#define NUM_MAIN_STATS	18
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + NUM_PERF_STATS)
 
 static const char mlx4_en_test_names[][ETH_GSTRING_LEN]= {
@@ -174,8 +159,6 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 
 	spin_lock_bh(&priv->stats_lock);
 
-	mlx4_en_update_lro_stats(priv);
-
 	for (i = 0; i < NUM_MAIN_STATS; i++)
 		data[index++] = ((unsigned long *) &priv->stats)[i];
 	for (i = 0; i < NUM_PORT_STATS; i++)
@@ -439,42 +422,6 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
 	param->tx_pending = priv->tx_ring[0].size;
 }
 
-static int mlx4_ethtool_op_set_flags(struct net_device *dev, u32 data)
-{
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
-	int rc = 0;
-	int changed = 0;
-
-	if (data & ~ETH_FLAG_LRO)
-		return -EOPNOTSUPP;
-
-	if (data & ETH_FLAG_LRO) {
-		if (mdev->profile.num_lro == 0)
-			return -EOPNOTSUPP;
-		if (!(dev->features & NETIF_F_LRO))
-			changed = 1;
-	} else if (dev->features & NETIF_F_LRO) {
-		changed = 1;
-	}
-
-	if (changed) {
-		if (netif_running(dev)) {
-			mutex_lock(&mdev->state_lock);
-			mlx4_en_stop_port(dev);
-		}
-		dev->features ^= NETIF_F_LRO;
-		if (netif_running(dev)) {
-			rc = mlx4_en_start_port(dev);
-			if (rc)
-				en_err(priv, "Failed to restart port\n");
-			mutex_unlock(&mdev->state_lock);
-		}
-	}
-
-	return rc;
-}
-
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
 	.get_settings = mlx4_en_get_settings,
@@ -504,7 +451,6 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_ringparam = mlx4_en_get_ringparam,
 	.set_ringparam = mlx4_en_set_ringparam,
 	.get_flags = ethtool_op_get_flags,
-	.set_flags = mlx4_ethtool_op_set_flags,
 };
 
 
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 2f25800..1439064 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -70,10 +70,6 @@ MLX4_EN_PARM_INT(tcp_rss, 1,
 MLX4_EN_PARM_INT(udp_rss, 1,
 		 "Enable RSS for incomming UDP traffic or disabled (0)");
 
-/* Number of LRO sessions per Rx ring (rounded up to a power of two) */
-MLX4_EN_PARM_INT(num_lro, MLX4_EN_MAX_LRO_DESCRIPTORS,
-		 "Number of LRO sessions per ring or disabled (0)");
-
 /* Priority pausing */
 MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
 			   " Per priority bit mask");
@@ -114,7 +110,6 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		mlx4_warn(mdev, "UDP RSS is not supported on this device.\n");
 		params->udp_rss = 0;
 	}
-	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
 	for (i = 1; i <= MLX4_MAX_PORTS; i++) {
 		params->prof[i].rx_pause = 1;
 		params->prof[i].rx_ppp = pfcrx;
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 2f8d705..411bda5 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1047,8 +1047,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->features |= NETIF_F_HW_VLAN_TX |
 			 NETIF_F_HW_VLAN_RX |
 			 NETIF_F_HW_VLAN_FILTER;
-	if (mdev->profile.num_lro)
-		dev->features |= NETIF_F_LRO;
+	dev->features |= NETIF_F_GRO;
 	if (mdev->LSO_support) {
 		dev->features |= NETIF_F_TSO;
 		dev->features |= NETIF_F_TSO6;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 62604f5..c4aad7f 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -42,18 +42,6 @@
 #include "mlx4_en.h"
 
 
-static int mlx4_en_get_frag_header(struct skb_frag_struct *frags, void **mac_hdr,
-				   void **ip_hdr, void **tcpudp_hdr,
-				   u64 *hdr_flags, void *priv)
-{
-	*mac_hdr = page_address(frags->page) + frags->page_offset;
-	*ip_hdr = *mac_hdr + ETH_HLEN;
-	*tcpudp_hdr = (struct tcphdr *)(*ip_hdr + sizeof(struct iphdr));
-	*hdr_flags = LRO_IPV4 | LRO_TCP;
-
-	return 0;
-}
-
 static int mlx4_en_alloc_frag(struct mlx4_en_priv *priv,
 			      struct mlx4_en_rx_desc *rx_desc,
 			      struct skb_frag_struct *skb_frags,
@@ -312,28 +300,8 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	}
 	ring->buf = ring->wqres.buf.direct.buf;
 
-	/* Configure lro mngr */
-	memset(&ring->lro, 0, sizeof(struct net_lro_mgr));
-	ring->lro.dev = priv->dev;
-	ring->lro.features = LRO_F_NAPI;
-	ring->lro.frag_align_pad = NET_IP_ALIGN;
-	ring->lro.ip_summed = CHECKSUM_UNNECESSARY;
-	ring->lro.ip_summed_aggr = CHECKSUM_UNNECESSARY;
-	ring->lro.max_desc = mdev->profile.num_lro;
-	ring->lro.max_aggr = MAX_SKB_FRAGS;
-	ring->lro.lro_arr = kzalloc(mdev->profile.num_lro *
-				    sizeof(struct net_lro_desc),
-				    GFP_KERNEL);
-	if (!ring->lro.lro_arr) {
-		en_err(priv, "Failed to allocate lro array\n");
-		goto err_map;
-	}
-	ring->lro.get_frag_header = mlx4_en_get_frag_header;
-
 	return 0;
 
-err_map:
-	mlx4_en_unmap_buffer(&ring->wqres.buf);
 err_hwq:
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 err_ring:
@@ -412,7 +380,6 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 
-	kfree(ring->lro.lro_arr);
 	mlx4_en_unmap_buffer(&ring->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size + TXBB_SIZE);
 	vfree(ring->rx_info);
@@ -563,7 +530,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_cqe *cqe;
 	struct mlx4_en_rx_ring *ring = &priv->rx_ring[cq->ring];
 	struct skb_frag_struct *skb_frags;
-	struct skb_frag_struct lro_frags[MLX4_EN_MAX_RX_FRAGS];
 	struct mlx4_en_rx_desc *rx_desc;
 	struct sk_buff *skb;
 	int index;
@@ -623,37 +589,33 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				 * - TCP/IP (v4)
 				 * - without IP options
 				 * - not an IP fragment */
-				if (mlx4_en_can_lro(cqe->status) &&
-				    dev->features & NETIF_F_LRO) {
+				if (dev->features & NETIF_F_GRO) {
+					struct sk_buff *gro_skb = napi_get_frags(&cq->napi);
 
 					nr = mlx4_en_complete_rx_desc(
 						priv, rx_desc,
-						skb_frags, lro_frags,
+						skb_frags, skb_shinfo(gro_skb)->frags,
 						ring->page_alloc, length);
 					if (!nr)
 						goto next;
 
+					skb_shinfo(gro_skb)->nr_frags = nr;
+					gro_skb->len = length;
+					gro_skb->data_len = length;
+					gro_skb->truesize += length;
+					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
+
 					if (priv->vlgrp && (cqe->vlan_my_qpn &
-							    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK))) {
-						lro_vlan_hwaccel_receive_frags(
-						       &ring->lro, lro_frags,
-						       length, length,
-						       priv->vlgrp,
-						       be16_to_cpu(cqe->sl_vid),
-						       NULL, 0);
-					} else
-						lro_receive_frags(&ring->lro,
-								  lro_frags,
-								  length,
-								  length,
-								  NULL, 0);
+							    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)))
+						vlan_gro_frags(&cq->napi, priv->vlgrp, be16_to_cpu(cqe->sl_vid));
+					else
+						napi_gro_frags(&cq->napi);
 
 					goto next;
 				}
 
 				/* LRO not possible, complete processing here */
 				ip_summed = CHECKSUM_UNNECESSARY;
-				INC_PERF_COUNTER(priv->pstats.lro_misses);
 			} else {
 				ip_summed = CHECKSUM_NONE;
 				priv->port_stats.rx_chksum_none++;
@@ -694,14 +656,10 @@ next:
 		if (++polled == budget) {
 			/* We are here because we reached the NAPI budget -
 			 * flush only pending LRO sessions */
-			lro_flush_all(&ring->lro);
 			goto out;
 		}
 	}
 
-	/* If CQ is empty flush all LRO sessions unconditionally */
-	lro_flush_all(&ring->lro);
-
 out:
 	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
 	mlx4_cq_set_ci(&cq->mcq);
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index b875f9c..98dd620 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -38,6 +38,7 @@
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <linux/vmalloc.h>
+#include <linux/tcp.h>
 
 #include "mlx4_en.h"
 
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 0662886..7d4ddb9 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -38,7 +38,6 @@
 #include <linux/list.h>
 #include <linux/mutex.h>
 #include <linux/netdevice.h>
-#include <linux/inet_lro.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/qp.h>
@@ -254,7 +253,6 @@ struct mlx4_en_rx_desc {
 struct mlx4_en_rx_ring {
 	struct mlx4_hwq_resources wqres;
 	struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
-	struct net_lro_mgr lro;
 	u32 size ;	/* number of Rx descs*/
 	u32 actual_size;
 	u32 size_mask;
@@ -318,7 +316,6 @@ struct mlx4_en_port_profile {
 
 struct mlx4_en_profile {
 	int rss_xor;
-	int num_lro;
 	int tcp_rss;
 	int udp_rss;
 	u8 rss_mask;
@@ -380,9 +377,6 @@ struct mlx4_en_pkt_stats {
 };
 
 struct mlx4_en_port_stats {
-	unsigned long lro_aggregated;
-	unsigned long lro_flushed;
-	unsigned long lro_no_desc;
 	unsigned long tso_packets;
 	unsigned long queue_stopped;
 	unsigned long wake_queue;
-- 
1.6.1.3


