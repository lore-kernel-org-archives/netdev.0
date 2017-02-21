From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v3 2/8] mlx4: Changes to use generic XDP infrastructure
Date: Tue, 21 Feb 2017 11:34:11 -0800
Message-ID: <20170221193417.3641224-3-tom@herbertland.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55715 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753670AbdBUTe2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 14:34:28 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LJWmvN029779
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:27 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28rut5r074-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:27 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 c137b702f86c11e695100002c9dfb610-85f9a00 for <netdev@vger.kernel.org>; Tue,
 21 Feb 2017 11:34:26 -0800
In-Reply-To: <20170221193417.3641224-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change XDP program management functional interface to correspond to new
XDP API.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 92 +++++---------------------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 27 ++++----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |  1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 -
 4 files changed, 29 insertions(+), 92 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index afe4444..e1dbfe7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -42,6 +42,7 @@
 #include <net/busy_poll.h>
 #include <net/vxlan.h>
 #include <net/devlink.h>
+#include <net/xdp.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
@@ -2199,8 +2200,7 @@ int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
 				struct mlx4_en_port_profile *prof,
 				bool carry_xdp_prog)
 {
-	struct bpf_prog *xdp_prog;
-	int i, t;
+	int t;
 
 	mlx4_en_copy_priv(tmp, priv, prof);
 
@@ -2215,22 +2215,6 @@ int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
 		return -ENOMEM;
 	}
 
-	/* All rx_rings has the same xdp_prog.  Pick the first one. */
-	xdp_prog = rcu_dereference_protected(
-		priv->rx_ring[0]->xdp_prog,
-		lockdep_is_held(&priv->mdev->state_lock));
-
-	if (xdp_prog && carry_xdp_prog) {
-		xdp_prog = bpf_prog_add(xdp_prog, tmp->rx_ring_num);
-		if (IS_ERR(xdp_prog)) {
-			mlx4_en_free_resources(tmp);
-			return PTR_ERR(xdp_prog);
-		}
-		for (i = 0; i < tmp->rx_ring_num; i++)
-			rcu_assign_pointer(tmp->rx_ring[i]->xdp_prog,
-					   xdp_prog);
-	}
-
 	return 0;
 }
 
@@ -2717,42 +2701,20 @@ static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 m
 	return err;
 }
 
-static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+static int mlx4_xdp_init(struct net_device *dev, bool enable)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_port_profile new_prof;
-	struct bpf_prog *old_prog;
 	struct mlx4_en_priv *tmp;
 	int tx_changed = 0;
-	int xdp_ring_num;
 	int port_up = 0;
-	int err;
-	int i;
+	int xdp_ring_num, err;
 
-	xdp_ring_num = prog ? priv->rx_ring_num : 0;
+	xdp_ring_num = enable ? ALIGN(priv->rx_ring_num, MLX4_EN_NUM_UP) : 0;
 
-	/* No need to reconfigure buffers when simply swapping the
-	 * program for a new one.
-	 */
-	if (priv->tx_ring_num[TX_XDP] == xdp_ring_num) {
-		if (prog) {
-			prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
-			if (IS_ERR(prog))
-				return PTR_ERR(prog);
-		}
-		mutex_lock(&mdev->state_lock);
-		for (i = 0; i < priv->rx_ring_num; i++) {
-			old_prog = rcu_dereference_protected(
-					priv->rx_ring[i]->xdp_prog,
-					lockdep_is_held(&mdev->state_lock));
-			rcu_assign_pointer(priv->rx_ring[i]->xdp_prog, prog);
-			if (old_prog)
-				bpf_prog_put(old_prog);
-		}
-		mutex_unlock(&mdev->state_lock);
+	if (priv->tx_ring_num[TX_XDP] == xdp_ring_num)
 		return 0;
-	}
 
 	if (!mlx4_en_check_xdp_mtu(dev, dev->mtu))
 		return -EOPNOTSUPP;
@@ -2761,14 +2723,6 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	if (!tmp)
 		return -ENOMEM;
 
-	if (prog) {
-		prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
-		if (IS_ERR(prog)) {
-			err = PTR_ERR(prog);
-			goto out;
-		}
-	}
-
 	mutex_lock(&mdev->state_lock);
 	memcpy(&new_prof, priv->prof, sizeof(struct mlx4_en_port_profile));
 	new_prof.tx_ring_num[TX_XDP] = xdp_ring_num;
@@ -2781,11 +2735,8 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	}
 
 	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof, false);
-	if (err) {
-		if (prog)
-			bpf_prog_sub(prog, priv->rx_ring_num - 1);
+	if (err)
 		goto unlock_out;
-	}
 
 	if (priv->port_up) {
 		port_up = 1;
@@ -2796,15 +2747,6 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	if (tx_changed)
 		netif_set_real_num_tx_queues(dev, priv->tx_ring_num[TX]);
 
-	for (i = 0; i < priv->rx_ring_num; i++) {
-		old_prog = rcu_dereference_protected(
-					priv->rx_ring[i]->xdp_prog,
-					lockdep_is_held(&mdev->state_lock));
-		rcu_assign_pointer(priv->rx_ring[i]->xdp_prog, prog);
-		if (old_prog)
-			bpf_prog_put(old_prog);
-	}
-
 	if (port_up) {
 		err = mlx4_en_start_port(dev);
 		if (err) {
@@ -2816,26 +2758,24 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 
 unlock_out:
 	mutex_unlock(&mdev->state_lock);
-out:
 	kfree(tmp);
 	return err;
 }
 
-static bool mlx4_xdp_attached(struct net_device *dev)
+static int mlx4_xdp_check_bpf(struct net_device *dev, struct bpf_prog *prog)
 {
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-
-	return !!priv->tx_ring_num[TX_XDP];
+	return 0;
 }
 
 static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	switch (xdp->command) {
-	case XDP_SETUP_PROG:
-		return mlx4_xdp_set(dev, xdp->prog);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = mlx4_xdp_attached(dev);
-		return 0;
+	case XDP_MODE_ON:
+		return mlx4_xdp_init(dev, true);
+	case XDP_MODE_OFF:
+		return mlx4_xdp_init(dev, false);
+	case XDP_CHECK_BPF_PROG:
+		return mlx4_xdp_check_bpf(dev, xdp->prog);
 	default:
 		return -EINVAL;
 	}
@@ -3335,7 +3275,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	dev->vlan_features = dev->hw_features;
 
-	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH;
+	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_XDP;
 	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
 			NETIF_F_HW_VLAN_CTAG_FILTER;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index d85e644..a8fddc0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -43,6 +43,7 @@
 #include <linux/if_vlan.h>
 #include <linux/vmalloc.h>
 #include <linux/irq.h>
+#include <net/xdp.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ip6_checksum.h>
@@ -547,13 +548,7 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rx_ring *ring = *pring;
-	struct bpf_prog *old_prog;
 
-	old_prog = rcu_dereference_protected(
-					ring->xdp_prog,
-					lockdep_is_held(&mdev->state_lock));
-	if (old_prog)
-		bpf_prog_put(old_prog);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
@@ -802,7 +797,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
 	struct mlx4_en_rx_alloc *frags;
 	struct mlx4_en_rx_desc *rx_desc;
-	struct bpf_prog *xdp_prog;
 	int doorbell_pending;
 	struct sk_buff *skb;
 	int index;
@@ -813,6 +807,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	int factor = priv->cqe_factor;
 	u64 timestamp;
 	bool l2_tunnel;
+	bool run_xdp;
 
 	if (unlikely(!priv->port_up))
 		return 0;
@@ -820,9 +815,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	if (unlikely(budget <= 0))
 		return polled;
 
-	/* Protect accesses to: ring->xdp_prog, priv->mac_hash list */
+	/* Protect accesses to: XDP hooks, priv->mac_hash list */
 	rcu_read_lock();
-	xdp_prog = rcu_dereference(ring->xdp_prog);
+	run_xdp = xdp_hook_run_needed_check(dev, &cq->napi);
 	doorbell_pending = 0;
 
 	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
@@ -895,13 +890,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
 			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
 
-		/* A bpf program gets first chance to drop the packet. It may
+		/* An xdp program gets first chance to drop the packet. It may
 		 * read bytes but not past the end of the frag.
 		 */
-		if (xdp_prog) {
+		if (run_xdp) {
 			struct xdp_buff xdp;
 			dma_addr_t dma;
 			void *orig_data;
+			struct xdp_hook *last_hook;
 			u32 act;
 
 			dma = be64_to_cpu(rx_desc->data[0].addr);
@@ -914,7 +910,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			xdp.data_end = xdp.data + length;
 			orig_data = xdp.data;
 
-			act = bpf_prog_run_xdp(xdp_prog, &xdp);
+			act = xdp_hook_run_ret_last(&cq->napi, &xdp,
+						    &last_hook);
 
 			if (xdp.data != orig_data) {
 				length = xdp.data_end - xdp.data;
@@ -930,12 +927,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							length, cq->ring,
 							&doorbell_pending)))
 					goto consumed;
-				trace_xdp_exception(dev, xdp_prog, act);
+				trace_xdp_hook_exception(dev, last_hook, act);
 				goto xdp_drop_no_cnt; /* Drop on xmit failure */
 			default:
-				bpf_warn_invalid_xdp_action(act);
+				xdp_warn_invalid_action(act);
 			case XDP_ABORTED:
-				trace_xdp_exception(dev, xdp_prog, act);
+				trace_xdp_hook_exception(dev, last_hook, act);
 			case XDP_DROP:
 				ring->xdp_drop++;
 xdp_drop_no_cnt:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 3ed4219..870acb7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -43,6 +43,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/moduleparam.h>
+#include <net/xdp.h>
 
 #include "mlx4_en.h"
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 4941b69..4e7667e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -348,7 +348,6 @@ struct mlx4_en_rx_ring {
 	u8  fcs_del;
 	void *buf;
 	void *rx_info;
-	struct bpf_prog __rcu *xdp_prog;
 	struct mlx4_en_page_cache page_cache;
 	unsigned long bytes;
 	unsigned long packets;
-- 
2.9.3
