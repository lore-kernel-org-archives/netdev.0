From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v9 04/11] net/mlx4_en: add support for fast rx drop bpf program
Date: Fri, 15 Jul 2016 16:28:51 -0700
Message-ID: <1468625338-32391-5-git-send-email-bblanco@plumgrid.com>
References: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33612 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbcGOX3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:29:33 -0400
Received: by mail-pf0-f175.google.com with SMTP id y134so19354733pfg.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 16:29:32 -0700 (PDT)
In-Reply-To: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.

In tc/socket bpf programs, helpers linearize skb fragments as needed
when the program touches the packet data. However, in the pursuit of
speed, XDP programs will not be allowed to use these slower functions,
especially if it involves allocating an skb.

Therefore, disallow MTU settings that would produce a multi-fragment
packet that XDP programs would fail to access. Future enhancements could
be done to increase the allowable MTU.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 51 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 37 +++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  5 +++
 3 files changed, 89 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 6083775..b7c1804 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -31,6 +31,7 @@
  *
  */
 
+#include <linux/bpf.h>
 #include <linux/etherdevice.h>
 #include <linux/tcp.h>
 #include <linux/if_vlan.h>
@@ -2084,6 +2085,9 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
 		mlx4_en_remove_timestamp(mdev);
 
+	if (priv->prog)
+		bpf_prog_put(priv->prog);
+
 	/* Detach the netdev so tasks would not attempt to access it */
 	mutex_lock(&mdev->state_lock);
 	mdev->pndev[priv->port] = NULL;
@@ -2112,6 +2116,11 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 		en_err(priv, "Bad MTU size:%d.\n", new_mtu);
 		return -EPERM;
 	}
+	if (priv->prog && MLX4_EN_EFF_MTU(new_mtu) > FRAG_SZ0) {
+		en_err(priv, "MTU size:%d requires frags but XDP running\n",
+		       new_mtu);
+		return -EOPNOTSUPP;
+	}
 	dev->mtu = new_mtu;
 
 	if (netif_running(dev)) {
@@ -2520,6 +2529,46 @@ static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 m
 	return err;
 }
 
+static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct bpf_prog *old_prog;
+
+	if (priv->num_frags > 1) {
+		en_err(priv, "Cannot set XDP if MTU requires multiple frags\n");
+		return -EOPNOTSUPP;
+	}
+
+	/* This xchg is paired with READ_ONCE in the fast path, but is
+	 * also protected from itself via rtnl lock
+	 */
+	old_prog = xchg(&priv->prog, prog);
+	if (old_prog)
+		bpf_prog_put(old_prog);
+
+	return 0;
+}
+
+static bool mlx4_xdp_attached(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	return !!READ_ONCE(priv->prog);
+}
+
+static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+{
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return mlx4_xdp_set(dev, xdp->prog);
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = mlx4_xdp_attached(dev);
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2548,6 +2597,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_udp_tunnel_del	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
+	.ndo_xdp		= mlx4_xdp,
 };
 
 static const struct net_device_ops mlx4_netdev_ops_master = {
@@ -2584,6 +2634,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_udp_tunnel_del	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
+	.ndo_xdp		= mlx4_xdp,
 };
 
 struct mlx4_en_bond {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c1b3a9c..adfa123 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -743,6 +743,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
 	struct mlx4_en_rx_alloc *frags;
 	struct mlx4_en_rx_desc *rx_desc;
+	struct bpf_prog *prog;
 	struct sk_buff *skb;
 	int index;
 	int nr;
@@ -759,6 +760,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	if (budget <= 0)
 		return polled;
 
+	prog = READ_ONCE(priv->prog);
+
 	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
 	 * descriptor offset can be deduced from the CQE index instead of
 	 * reading 'cqe->index' */
@@ -835,6 +838,35 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
 			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
 
+		/* A bpf program gets first chance to drop the packet. It may
+		 * read bytes but not past the end of the frag.
+		 */
+		if (prog) {
+			struct xdp_buff xdp;
+			dma_addr_t dma;
+			u32 act;
+
+			dma = be64_to_cpu(rx_desc->data[0].addr);
+			dma_sync_single_for_cpu(priv->ddev, dma,
+						priv->frag_info[0].frag_size,
+						DMA_FROM_DEVICE);
+
+			xdp.data = page_address(frags[0].page) +
+							frags[0].page_offset;
+			xdp.data_end = xdp.data + length;
+
+			act = bpf_prog_run_xdp(prog, &xdp);
+			switch (act) {
+			case XDP_PASS:
+				break;
+			default:
+				bpf_warn_invalid_xdp_action(act);
+			case XDP_ABORTED:
+			case XDP_DROP:
+				goto next;
+			}
+		}
+
 		if (likely(dev->features & NETIF_F_RXCSUM)) {
 			if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP |
 						      MLX4_CQE_STATUS_UDP)) {
@@ -1062,10 +1094,7 @@ static const int frag_sizes[] = {
 void mlx4_en_calc_rx_buf(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	/* VLAN_HLEN is added twice,to support skb vlan tagged with multiple
-	 * headers. (For example: ETH_P_8021Q and ETH_P_8021AD).
-	 */
-	int eff_mtu = dev->mtu + ETH_HLEN + (2 * VLAN_HLEN);
+	int eff_mtu = MLX4_EN_EFF_MTU(dev->mtu);
 	int buf_size = 0;
 	int i = 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d39bf59..35ecfa2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -164,6 +164,10 @@ enum {
 #define MLX4_LOOPBACK_TEST_PAYLOAD (HEADER_COPY_SIZE - ETH_HLEN)
 
 #define MLX4_EN_MIN_MTU		46
+/* VLAN_HLEN is added twice,to support skb vlan tagged with multiple
+ * headers. (For example: ETH_P_8021Q and ETH_P_8021AD).
+ */
+#define MLX4_EN_EFF_MTU(mtu)	((mtu) + ETH_HLEN + (2 * VLAN_HLEN))
 #define ETH_BCAST		0xffffffffffffULL
 
 #define MLX4_EN_LOOPBACK_RETRIES	5
@@ -590,6 +594,7 @@ struct mlx4_en_priv {
 	struct hlist_head mac_hash[MLX4_EN_MAC_HASH_SIZE];
 	struct hwtstamp_config hwtstamp_config;
 	u32 counter_index;
+	struct bpf_prog *prog;
 
 #ifdef CONFIG_MLX4_EN_DCB
 #define MLX4_EN_DCB_ENABLED	0x3
-- 
2.8.2
