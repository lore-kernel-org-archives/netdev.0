From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH] xdp: separate struct xdp_prog as container for bpf_prog
Date: Tue, 20 Sep 2016 21:55:07 +0200
Message-ID: <20160920195458.21735.21873.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, bblanco@plumgrid.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752089AbcITTzK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 15:55:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the XDP program is simply a bpf_prog pointer.  While it
is good for simplicity, it is limiting extendability for upcoming
features.

Introducing a new struct xdp_prog, that can carry information
related to the XDP program.  Notice this approach does not affect
performance (tested and benchmarked), because the extra dereference
for the eBPF program only happens once per 64 packets in the poll
function.

The features that need this is:

* Multi-port TX:
  Need to know own port index and port lookup table.

* XDP program per RX queue:
  Need setup info about program type, global or specific, due to
  replace semantics.

* Capabilities negotiation:
  Need to store information about features program want to use,
  in-order to validate this.

I do realize this new struct xdp_prog features cannot go into the
kernel before one of the three users of the struct is also implemented.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 +++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |   10 +++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 -
 include/linux/filter.h                         |   14 +++++++
 include/linux/netdevice.h                      |    2 -
 net/core/dev.c                                 |   15 +++++--
 net/core/filter.c                              |   50 ++++++++++++++++++++++++
 7 files changed, 89 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 62516f8369ba..f86f65b170f7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2622,11 +2622,11 @@ static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 m
 	return err;
 }
 
-static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+static int mlx4_xdp_set(struct net_device *dev, struct xdp_prog *prog)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
-	struct bpf_prog *old_prog;
+	struct xdp_prog *old_prog;
 	int xdp_ring_num;
 	int port_up = 0;
 	int err;
@@ -2639,7 +2639,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	 */
 	if (priv->xdp_ring_num == xdp_ring_num) {
 		if (prog) {
-			prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
+			prog = xdp_prog_add(prog, priv->rx_ring_num);
 			if (IS_ERR(prog))
 				return PTR_ERR(prog);
 		}
@@ -2650,7 +2650,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 					lockdep_is_held(&mdev->state_lock));
 			rcu_assign_pointer(priv->rx_ring[i]->xdp_prog, prog);
 			if (old_prog)
-				bpf_prog_put(old_prog);
+				xdp_prog_put(old_prog);
 		}
 		mutex_unlock(&mdev->state_lock);
 		return 0;
@@ -2669,7 +2669,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	}
 
 	if (prog) {
-		prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
+		prog = xdp_prog_add(prog, priv->rx_ring_num);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
 	}
@@ -2690,7 +2690,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 					lockdep_is_held(&mdev->state_lock));
 		rcu_assign_pointer(priv->rx_ring[i]->xdp_prog, prog);
 		if (old_prog)
-			bpf_prog_put(old_prog);
+			xdp_prog_put(old_prog);
 	}
 
 	if (port_up) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c46355bce613..e1182879ea6f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -535,13 +535,13 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rx_ring *ring = *pring;
-	struct bpf_prog *old_prog;
+	struct xdp_prog *old_prog;
 
 	old_prog = rcu_dereference_protected(
 					ring->xdp_prog,
 					lockdep_is_held(&mdev->state_lock));
 	if (old_prog)
-		bpf_prog_put(old_prog);
+		xdp_prog_put(old_prog);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
@@ -783,7 +783,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
 	struct mlx4_en_rx_alloc *frags;
 	struct mlx4_en_rx_desc *rx_desc;
-	struct bpf_prog *xdp_prog;
+	struct xdp_prog *xdp_prog;
+	struct bpf_prog *bpf_prog;
 	int doorbell_pending;
 	struct sk_buff *skb;
 	int tx_index;
@@ -805,6 +806,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	/* Protect accesses to: ring->xdp_prog, priv->mac_hash list */
 	rcu_read_lock();
 	xdp_prog = rcu_dereference(ring->xdp_prog);
+	bpf_prog = rcu_dereference(xdp_prog->bpf);
 	doorbell_pending = 0;
 	tx_index = (priv->tx_ring_num - priv->xdp_ring_num) + cq->ring;
 
@@ -897,7 +899,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							frags[0].page_offset;
 			xdp.data_end = xdp.data + length;
 
-			act = bpf_prog_run_xdp(xdp_prog, &xdp);
+			act = bpf_prog_run_xdp(bpf_prog, &xdp);
 			switch (act) {
 			case XDP_PASS:
 				break;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index a3528dd1e72e..8942201bcc38 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -340,7 +340,7 @@ struct mlx4_en_rx_ring {
 	u8  fcs_del;
 	void *buf;
 	void *rx_info;
-	struct bpf_prog __rcu *xdp_prog;
+	struct xdp_prog __rcu *xdp_prog;
 	struct mlx4_en_page_cache page_cache;
 	unsigned long bytes;
 	unsigned long packets;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1f09c521adfe..f1eee2f0f70c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -437,6 +437,20 @@ struct xdp_buff {
 	void *data_end;
 };
 
+struct xdp_prog {
+	u64		flags;
+	struct bpf_prog *bpf;
+	atomic_t	refcnt;
+	struct rcu_head	rcu; // Do we need RCU freeing? likely right?
+
+	/* Data associated with XDP program goes here */
+
+} ____cacheline_aligned_in_smp;
+
+struct xdp_prog *xdp_prog_alloc(struct bpf_prog *bpf);
+struct xdp_prog *xdp_prog_add(struct xdp_prog *xdp, int users);
+void xdp_prog_put(struct xdp_prog *prog);
+
 /* compute the linear packet data range [data, data_end) which
  * will be accessed by cls_bpf and act_bpf programs
  */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a10d8d18ce19..f9d900e62cd5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -825,7 +825,7 @@ struct netdev_xdp {
 	enum xdp_netdev_command command;
 	union {
 		/* XDP_SETUP_PROG */
-		struct bpf_prog *prog;
+		struct xdp_prog *prog;
 		/* XDP_QUERY_PROG */
 		bool prog_attached;
 	};
diff --git a/net/core/dev.c b/net/core/dev.c
index 9dbece2f1296..df3f7d3cf62e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6643,23 +6643,30 @@ EXPORT_SYMBOL(dev_change_proto_down);
 int dev_change_xdp_fd(struct net_device *dev, int fd)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-	struct bpf_prog *prog = NULL;
+	struct xdp_prog *prog = NULL;
+	struct bpf_prog *bpf;
 	struct netdev_xdp xdp = {};
 	int err;
 
 	if (!ops->ndo_xdp)
 		return -EOPNOTSUPP;
 	if (fd >= 0) {
-		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
-		if (IS_ERR(prog))
+		bpf = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP); /* inc refcnt */
+		if (IS_ERR(bpf))
+			return PTR_ERR(bpf);
+
+		prog = xdp_prog_alloc(bpf);
+		if (IS_ERR(prog)) {
+			bpf_prog_put(prog->bpf);
 			return PTR_ERR(prog);
+		}
 	}
 
 	xdp.command = XDP_SETUP_PROG;
 	xdp.prog = prog;
 	err = ops->ndo_xdp(dev, &xdp);
 	if (err < 0 && prog)
-		bpf_prog_put(prog);
+		bpf_prog_put(prog->bpf);
 
 	return err;
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index 298b146b47e7..a61ca13b8eaa 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2912,3 +2912,53 @@ out:
 	release_sock(sk);
 	return ret;
 }
+
+struct xdp_prog *xdp_prog_alloc(struct bpf_prog *bpf)
+{
+	struct xdp_prog *xdp;
+
+	xdp = kzalloc(sizeof(*xdp), GFP_KERNEL);
+	if (!xdp)
+		return ERR_PTR(-ENOMEM);
+
+	/* Note dev_change_xdp_fd() already refcnt inc on bpf prog */
+	xdp->bpf = bpf;
+
+	return xdp;
+}
+EXPORT_SYMBOL(xdp_prog_alloc);
+
+struct xdp_prog *xdp_prog_add(struct xdp_prog *xdp, int users)
+{
+	struct bpf_prog *bpf;
+
+	bpf = bpf_prog_add(xdp->bpf, users);
+	if (IS_ERR(bpf)) {
+		return (void*)bpf; /* it is already a PTR_ERR */
+	}
+	atomic_add(users, &xdp->refcnt);
+
+	return xdp;
+}
+EXPORT_SYMBOL(xdp_prog_add);
+
+void __xdp_prog_put_rcu(struct rcu_head *rcu)
+{
+	struct xdp_prog *xdp = container_of(rcu, struct xdp_prog, rcu);
+
+	/* Release reference to (future) xdp_port_table here */
+
+	/* Release refcnt from dev_change_xdp_fd() calling bpf_prog_get_type()*/
+	bpf_prog_put(xdp->bpf);
+
+	kfree(xdp);
+}
+
+void xdp_prog_put(struct xdp_prog *prog)
+{
+	bpf_prog_put(prog->bpf);
+	if (atomic_dec_and_test(&prog->refcnt)) {
+		call_rcu(&prog->rcu, __xdp_prog_put_rcu);
+	}
+}
+EXPORT_SYMBOL(xdp_prog_put);
