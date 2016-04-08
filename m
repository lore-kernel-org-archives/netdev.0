From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [RFC PATCH v2 4/5] mlx4: add support for fast rx drop bpf program
Date: Thu,  7 Apr 2016 21:48:49 -0700
Message-ID: <1460090930-11219-4-git-send-email-bblanco@plumgrid.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	ogerlitz@mellanox.com, daniel@iogearbox.net, brouer@redhat.com,
	eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36160 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818AbcDHEs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 00:48:59 -0400
Received: by mail-pf0-f175.google.com with SMTP id e128so68981949pfe.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 21:48:59 -0700 (PDT)
In-Reply-To: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx4 driver. Since
bpf programs require a skb context to navigate the packet, build a
percpu fake skb with the minimal fields. This avoids the costly
allocation for packets that end up being dropped.

Since mlx4 is so far the only user of bpf_phys_dev_md, the build
function is defined locally.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 65 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 25 ++++++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  6 +++
 3 files changed, 92 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b4b258c..b228651 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -31,6 +31,7 @@
  *
  */
 
+#include <linux/bpf.h>
 #include <linux/etherdevice.h>
 #include <linux/tcp.h>
 #include <linux/if_vlan.h>
@@ -1966,6 +1967,9 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 			mlx4_en_destroy_cq(priv, &priv->rx_cq[i]);
 	}
 
+	if (priv->prog)
+		bpf_prog_put(priv->prog);
+
 }
 
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
@@ -2078,6 +2082,11 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 		en_err(priv, "Bad MTU size:%d.\n", new_mtu);
 		return -EPERM;
 	}
+	if (priv->prog && MLX4_EN_EFF_MTU(new_mtu) > FRAG_SZ0) {
+		en_err(priv, "MTU size:%d requires frags but bpf prog running",
+		       new_mtu);
+		return -EOPNOTSUPP;
+	}
 	dev->mtu = new_mtu;
 
 	if (netif_running(dev)) {
@@ -2456,6 +2465,58 @@ static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 m
 	return err;
 }
 
+static DEFINE_PER_CPU(struct sk_buff, percpu_bpf_phys_dev_md);
+
+static void build_bpf_phys_dev_md(struct sk_buff *skb, void *data,
+				  unsigned int length)
+{
+	/* data_len is intentionally not set here so that skb_is_nonlinear()
+	 * returns false
+	 */
+
+	skb->len = length;
+	skb->head = data;
+	skb->data = data;
+}
+
+int mlx4_call_bpf(struct bpf_prog *prog, void *data, unsigned int length)
+{
+	struct sk_buff *skb = this_cpu_ptr(&percpu_bpf_phys_dev_md);
+	int ret;
+
+	build_bpf_phys_dev_md(skb, data, length);
+
+	rcu_read_lock();
+	ret = BPF_PROG_RUN(prog, (void *)skb);
+	rcu_read_unlock();
+
+	return ret;
+}
+
+static int mlx4_bpf_set(struct net_device *dev, struct bpf_prog *prog)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct bpf_prog *old_prog;
+
+	if (priv->num_frags > 1)
+		return -EOPNOTSUPP;
+
+	old_prog = xchg(&priv->prog, prog);
+	if (old_prog) {
+		synchronize_net();
+		bpf_prog_put(old_prog);
+	}
+
+	return 0;
+}
+
+static bool mlx4_bpf_get(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	return !!priv->prog;
+}
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2486,6 +2547,8 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_features_check	= mlx4_en_features_check,
 #endif
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
+	.ndo_bpf_set		= mlx4_bpf_set,
+	.ndo_bpf_get		= mlx4_bpf_get,
 };
 
 static const struct net_device_ops mlx4_netdev_ops_master = {
@@ -2524,6 +2587,8 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_features_check	= mlx4_en_features_check,
 #endif
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
+	.ndo_bpf_set		= mlx4_bpf_set,
+	.ndo_bpf_get		= mlx4_bpf_get,
 };
 
 struct mlx4_en_bond {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 86bcfe5..287da02 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -748,6 +748,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
 	struct mlx4_en_rx_alloc *frags;
 	struct mlx4_en_rx_desc *rx_desc;
+	struct bpf_prog *prog;
 	struct sk_buff *skb;
 	int index;
 	int nr;
@@ -764,6 +765,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	if (budget <= 0)
 		return polled;
 
+	prog = READ_ONCE(priv->prog);
+
 	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
 	 * descriptor offset can be deduced from the CQE index instead of
 	 * reading 'cqe->index' */
@@ -840,6 +843,23 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
 			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
 
+		/* A bpf program gets first chance to drop the packet. It may
+		 * read bytes but not past the end of the frag.
+		 */
+		if (prog) {
+			struct ethhdr *ethh;
+			dma_addr_t dma;
+
+			dma = be64_to_cpu(rx_desc->data[0].addr);
+			dma_sync_single_for_cpu(priv->ddev, dma, sizeof(*ethh),
+						DMA_FROM_DEVICE);
+			ethh = page_address(frags[0].page) +
+							frags[0].page_offset;
+			if (mlx4_call_bpf(prog, ethh, frags[0].page_size) ==
+							BPF_PHYS_DEV_DROP)
+				goto next;
+		}
+
 		if (likely(dev->features & NETIF_F_RXCSUM)) {
 			if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP |
 						      MLX4_CQE_STATUS_UDP)) {
@@ -1067,10 +1087,7 @@ static const int frag_sizes[] = {
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
index d12ab6a..40eb32d 100644
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
@@ -568,6 +572,7 @@ struct mlx4_en_priv {
 	struct hlist_head mac_hash[MLX4_EN_MAC_HASH_SIZE];
 	struct hwtstamp_config hwtstamp_config;
 	u32 counter_index;
+	struct bpf_prog *prog;
 
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets ets;
@@ -682,6 +687,7 @@ int mlx4_en_create_drop_qp(struct mlx4_en_priv *priv);
 void mlx4_en_destroy_drop_qp(struct mlx4_en_priv *priv);
 int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
 void mlx4_en_rx_irq(struct mlx4_cq *mcq);
+int mlx4_call_bpf(struct bpf_prog *prog, void *data, unsigned int length);
 
 int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
 int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv);
-- 
2.8.0
