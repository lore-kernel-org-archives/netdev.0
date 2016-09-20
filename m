From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 2/3] mlx4: Change XDP/BPF to use generic XDP infrastructure
Date: Tue, 20 Sep 2016 15:00:23 -0700
Message-ID: <1474408824-418864-3-git-send-email-tom@herbertland.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tariqt@mellanox.com>,
        <bblanco@plumgrid.com>, <alexei.starovoitov@gmail.com>,
        <eric.dumazet@gmail.com>, <brouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39914 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754924AbcITWAf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 18:00:35 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8KLxXGd020171
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:00:35 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25kbkegxs8-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:00:35 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 a7a79cac7f7d11e6a7f70002c99293a0-65feca50 for <netdev@vger.kernel.org>;        Tue,
 20 Sep 2016 15:00:34 -0700
In-Reply-To: <1474408824-418864-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the XDP-BPF implementation to use the generic
XDP infrastructure. This includes corresponding changes to the
Mellanox XDP code.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 64 ++++----------------------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 25 ++++------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 -
 include/linux/filter.h                         | 13 ------
 net/core/dev.c                                 | 40 +++++++++++++---
 net/core/filter.c                              |  7 +--
 net/core/rtnetlink.c                           | 16 +++----
 7 files changed, 63 insertions(+), 103 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 62516f8..47990b7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2622,39 +2622,15 @@ static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 m
 	return err;
 }
 
-static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+static int mlx4_xdp_make_tx_rings(struct net_device *dev, int xdp_ring_num)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
-	struct bpf_prog *old_prog;
-	int xdp_ring_num;
 	int port_up = 0;
 	int err;
-	int i;
-
-	xdp_ring_num = prog ? ALIGN(priv->rx_ring_num, MLX4_EN_NUM_UP) : 0;
 
-	/* No need to reconfigure buffers when simply swapping the
-	 * program for a new one.
-	 */
-	if (priv->xdp_ring_num == xdp_ring_num) {
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
+	if (priv->xdp_ring_num == xdp_ring_num)
 		return 0;
-	}
 
 	if (priv->num_frags > 1) {
 		en_err(priv, "Cannot set XDP if MTU requires multiple frags\n");
@@ -2668,12 +2644,6 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -EINVAL;
 	}
 
-	if (prog) {
-		prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
-		if (IS_ERR(prog))
-			return PTR_ERR(prog);
-	}
-
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
@@ -2684,15 +2654,6 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num -
 							priv->xdp_ring_num);
 
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
@@ -2706,23 +2667,18 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	return 0;
 }
 
-static bool mlx4_xdp_attached(struct net_device *dev)
+static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-	return !!priv->xdp_ring_num;
-}
-
-static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
-{
 	switch (xdp->command) {
-	case XDP_SETUP_PROG:
-		return mlx4_xdp_set(dev, xdp->prog);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = mlx4_xdp_attached(dev);
-		return 0;
+	case XDP_DEV_INIT:
+		return mlx4_xdp_make_tx_rings(dev,
+		    ALIGN(priv->rx_ring_num, MLX4_EN_NUM_UP));
+	case XDP_DEV_FINISH:
+		return mlx4_xdp_make_tx_rings(dev, 0);
 	default:
-		return -EINVAL;
+		return 0;
 	}
 }
 
@@ -3210,7 +3166,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	dev->vlan_features = dev->hw_features;
 
-	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH;
+	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_XDP;
 	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
 			NETIF_F_HW_VLAN_CTAG_FILTER;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c80073e..e06ac63 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -42,6 +42,7 @@
 #include <linux/if_vlan.h>
 #include <linux/vmalloc.h>
 #include <linux/irq.h>
+#include <net/xdp.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ip6_checksum.h>
@@ -535,13 +536,7 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
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
@@ -783,7 +778,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
 	struct mlx4_en_rx_alloc *frags;
 	struct mlx4_en_rx_desc *rx_desc;
-	struct bpf_prog *xdp_prog;
 	int doorbell_pending;
 	struct sk_buff *skb;
 	int tx_index;
@@ -795,6 +789,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	int factor = priv->cqe_factor;
 	u64 timestamp;
 	bool l2_tunnel;
+	bool run_xdp;
 
 	if (!priv->port_up)
 		return 0;
@@ -802,9 +797,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	if (budget <= 0)
 		return polled;
 
-	/* Protect accesses to: ring->xdp_prog, priv->mac_hash list */
+	/* Protect accesses to: XDP hooks, priv->mac_hash list */
 	rcu_read_lock();
-	xdp_prog = rcu_dereference(ring->xdp_prog);
+	run_xdp = xdp_hook_run_needed_check(&cq->napi);
 	doorbell_pending = 0;
 	tx_index = (priv->tx_ring_num - priv->xdp_ring_num) + cq->ring;
 
@@ -880,10 +875,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
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
 			u32 act;
@@ -897,7 +892,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							frags[0].page_offset;
 			xdp.data_end = xdp.data + length;
 
-			act = bpf_prog_run_xdp(xdp_prog, &xdp);
+			act = xdp_hook_run(&cq->napi, &xdp);
 			switch (act) {
 			case XDP_PASS:
 				break;
@@ -906,14 +901,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							length, tx_index,
 							&doorbell_pending))
 					goto consumed;
-				goto next; /* Drop on xmit failure */
-			default:
-				bpf_warn_invalid_xdp_action(act);
+				break;
 			case XDP_ABORTED:
 			case XDP_DROP:
 				if (mlx4_en_rx_recycle(ring, frags))
 					goto consumed;
 				goto next;
+			default:
+				xdp_warn_invalid_action(act);
 			}
 		}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index a3528dd..56d5950 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -340,7 +340,6 @@ struct mlx4_en_rx_ring {
 	u8  fcs_del;
 	void *buf;
 	void *rx_info;
-	struct bpf_prog __rcu *xdp_prog;
 	struct mlx4_en_page_cache page_cache;
 	unsigned long bytes;
 	unsigned long packets;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 2a26133..f9863ee 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -494,18 +494,6 @@ static inline u32 bpf_prog_run_clear_cb(const struct bpf_prog *prog,
 	return BPF_PROG_RUN(prog, skb);
 }
 
-static inline u32 bpf_prog_run_xdp(const struct bpf_prog *prog,
-				   struct xdp_buff *xdp)
-{
-	u32 ret;
-
-	rcu_read_lock();
-	ret = BPF_PROG_RUN(prog, (void *)xdp);
-	rcu_read_unlock();
-
-	return ret;
-}
-
 static inline unsigned int bpf_prog_size(unsigned int proglen)
 {
 	return max(sizeof(struct bpf_prog),
@@ -590,7 +578,6 @@ bool bpf_helper_changes_skb_data(void *func);
 
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
-void bpf_warn_invalid_xdp_action(u32 act);
 
 #ifdef CONFIG_BPF_JIT
 extern int bpf_jit_enable;
diff --git a/net/core/dev.c b/net/core/dev.c
index 0d2c826..d35ee4d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -142,6 +142,7 @@
 #include <linux/sctp.h>
 #include <linux/crash_dump.h>
 #include <net/xdp.h>
+#include <linux/filter.h>
 
 #include "net-sysfs.h"
 
@@ -6635,6 +6636,32 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
+static u32 dev_bpf_prog_run_xdp(const void *priv,
+				struct xdp_buff *xdp)
+{
+	const struct bpf_prog *prog = (const struct bpf_prog *)priv;
+	u32 ret;
+
+	rcu_read_lock();
+	ret = BPF_PROG_RUN(prog, (void *)xdp);
+	rcu_read_unlock();
+
+	return ret;
+}
+
+static void dev_bpf_prog_put_xdp(const void *priv)
+{
+	bpf_prog_put((struct bpf_prog *)priv);
+}
+
+struct xdp_hook_ops xdp_bpf_hook_ops = {
+	.hook = dev_bpf_prog_run_xdp,
+	.put_priv = dev_bpf_prog_put_xdp,
+	.priority = 0,
+};
+
+static DEFINE_MUTEX(xdp_bpf_lock);
+
 /**
  *	dev_change_xdp_fd - set or clear a bpf program for a device rx path
  *	@dev: device
@@ -6644,22 +6671,23 @@ EXPORT_SYMBOL(dev_change_proto_down);
  */
 int dev_change_xdp_fd(struct net_device *dev, int fd)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
 	struct bpf_prog *prog = NULL;
-	struct netdev_xdp xdp = {};
 	int err;
 
-	if (!ops->ndo_xdp)
+	if (!(dev->features & NETIF_F_XDP))
 		return -EOPNOTSUPP;
+
 	if (fd >= 0) {
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
 	}
 
-	xdp.command = XDP_SETUP_PROG;
-	xdp.prog = prog;
-	err = ops->ndo_xdp(dev, &xdp);
+	mutex_lock(&xdp_bpf_lock); /* Since xdp_bpf_hook_ops is modified */
+	xdp_bpf_hook_ops.priv = prog;
+	err = xdp_change_dev_hook(dev, &xdp_bpf_hook_ops);
+	mutex_unlock(&xdp_bpf_lock);
+
 	if (err < 0 && prog)
 		bpf_prog_put(prog);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 298b146..f4a1ea8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -51,6 +51,7 @@
 #include <net/dst_metadata.h>
 #include <net/dst.h>
 #include <net/sock_reuseport.h>
+#include <net/xdp.h>
 
 /**
  *	sk_filter_trim_cap - run a packet through a socket filter
@@ -2595,12 +2596,6 @@ static bool xdp_is_valid_access(int off, int size,
 	return __is_valid_xdp_access(off, size, type);
 }
 
-void bpf_warn_invalid_xdp_action(u32 act)
-{
-	WARN_ONCE(1, "Illegal XDP return value %u, expect packet loss\n", act);
-}
-EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
-
 static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 					int src_reg, int ctx_off,
 					struct bpf_insn *insn_buf,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 0dbae42..c1aeb71 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -56,6 +56,7 @@
 #include <net/fib_rules.h>
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
+#include <net/xdp.h>
 
 struct rtnl_link {
 	rtnl_doit_func		doit;
@@ -897,7 +898,7 @@ static size_t rtnl_xdp_size(const struct net_device *dev)
 {
 	size_t xdp_size = nla_total_size(1);	/* XDP_ATTACHED */
 
-	if (!dev->netdev_ops->ndo_xdp)
+	if (!(dev->features & NETIF_F_XDP))
 		return 0;
 	else
 		return xdp_size;
@@ -1226,20 +1227,19 @@ static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
 
 static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdev_xdp xdp_op = {};
 	struct nlattr *xdp;
+	struct xdp_hook_ops ret;
 	int err;
 
-	if (!dev->netdev_ops->ndo_xdp)
-		return 0;
 	xdp = nla_nest_start(skb, IFLA_XDP);
 	if (!xdp)
 		return -EMSGSIZE;
-	xdp_op.command = XDP_QUERY_PROG;
-	err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
-	if (err)
+
+	err = xdp_find_dev_hook(dev, &xdp_bpf_hook_ops, &ret);
+	if (err && err != -ENOENT)
 		goto err_cancel;
-	err = nla_put_u8(skb, IFLA_XDP_ATTACHED, xdp_op.prog_attached);
+
+	err = nla_put_u8(skb, IFLA_XDP_ATTACHED, !err);
 	if (err)
 		goto err_cancel;
 
-- 
2.8.0.rc2
