From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v2] net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
Date: Sat,  3 Sep 2016 21:29:58 -0700
Message-ID: <20160904042958.8594-1-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35661 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbcIDEba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 00:31:30 -0400
Received: by mail-pf0-f171.google.com with SMTP id x72so54598255pfd.2
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2016 21:30:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending on the preempt mode, the bpf_prog stored in xdp_prog may be
freed despite the use of call_rcu inside bpf_prog_put. The situation is
possible when running in PREEMPT_RCU=y mode, for instance, since the rcu
callback for destroying the bpf prog can run even during the bh handling
in the mlx4 rx path.

Several options were considered before this patch was settled on:

Add a napi_synchronize loop in mlx4_xdp_set, which would occur after all
of the rings are updated with the new program.
This approach has the disadvantage that as the number of rings
increases, the speed of update will slow down significantly due to
napi_synchronize's msleep(1).

Add a new rcu_head in bpf_prog_aux, to be used by a new bpf_prog_put_bh.
The action of the bpf_prog_put_bh would be to then call bpf_prog_put
later. Those drivers that consume a bpf prog in a bh context (like mlx4)
would then use the bpf_prog_put_bh instead when the ring is up. This has
the problem of complexity, in maintaining proper refcnts and rcu lists,
and would likely be harder to review. In addition, this approach to
freeing must be exclusive with other frees of the bpf prog, for instance
a _bh prog must not be referenced from a prog array that is consumed by
a non-_bh prog.

The placement of rcu_read_lock in this patch is functionally the same as
putting an rcu_read_lock in napi_poll. Actually doing so could be a
potentially controversial change, but would bring the implementation in
line with sk_busy_loop (though of course the nature of those two paths
is substantially different), and would also avoid future copy/paste
problems with future supporters of XDP. Still, this patch does not take
that opinionated option.

Testing was done with kernels in either PREEMPT_RCU=y or
CONFIG_PREEMPT_VOLUNTARY=y+PREEMPT_RCU=n modes, with neither exhibiting
any drawback. With PREEMPT_RCU=n, the extra call to rcu_read_lock did
not show up in the perf report whatsoever, and with PREEMPT_RCU=y the
overhead of rcu_read_lock (according to perf) was the same before/after.
In the rx path, rcu_read_lock is eventually called for every packet
from netif_receive_skb_internal, so the napi poll call's rcu_read_lock
is easily amortized.

v2:
Remove extra rcu_read_lock in mlx4_en_process_rx_cq body
Annotate xdp_prog with __rcu, and convert all usages to rcu_assign or
rcu_dereference[_protected] as appropriate.
Add explicit mutex lock around rcu_assign instead of xchg loop.

Fixes: d576acf0a22 ("net/mlx4_en: add page recycle to prepare rx ring for tx support")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 13 ++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 15 ++++++++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  2 +-
 3 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4198e9b..31a41ad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2642,12 +2642,16 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 			if (IS_ERR(prog))
 				return PTR_ERR(prog);
 		}
+		mutex_lock(&mdev->state_lock);
 		for (i = 0; i < priv->rx_ring_num; i++) {
-			/* This xchg is paired with READ_ONCE in the fastpath */
-			old_prog = xchg(&priv->rx_ring[i]->xdp_prog, prog);
+			old_prog = rcu_dereference_protected(
+					priv->rx_ring[i]->xdp_prog,
+					lockdep_is_held(&mdev->state_lock));
+			rcu_assign_pointer(priv->rx_ring[i]->xdp_prog, prog);
 			if (old_prog)
 				bpf_prog_put(old_prog);
 		}
+		mutex_unlock(&mdev->state_lock);
 		return 0;
 	}
 
@@ -2680,7 +2684,10 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 							priv->xdp_ring_num);
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		old_prog = xchg(&priv->rx_ring[i]->xdp_prog, prog);
+		old_prog = rcu_dereference_protected(
+					priv->rx_ring[i]->xdp_prog,
+					lockdep_is_held(&mdev->state_lock));
+		rcu_assign_pointer(priv->rx_ring[i]->xdp_prog, prog);
 		if (old_prog)
 			bpf_prog_put(old_prog);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2040dad..6758292 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -537,7 +537,9 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 	struct mlx4_en_rx_ring *ring = *pring;
 	struct bpf_prog *old_prog;
 
-	old_prog = READ_ONCE(ring->xdp_prog);
+	old_prog = rcu_dereference_protected(
+					ring->xdp_prog,
+					lockdep_is_held(&mdev->state_lock));
 	if (old_prog)
 		bpf_prog_put(old_prog);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
@@ -800,7 +802,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	if (budget <= 0)
 		return polled;
 
-	xdp_prog = READ_ONCE(ring->xdp_prog);
+	/* Protect accesses to: ring->xdp_prog, priv->mac_hash list */
+	rcu_read_lock();
+	xdp_prog = rcu_dereference(ring->xdp_prog);
 	doorbell_pending = 0;
 	tx_index = (priv->tx_ring_num - priv->xdp_ring_num) + cq->ring;
 
@@ -858,15 +862,11 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				/* Drop the packet, since HW loopback-ed it */
 				mac_hash = ethh->h_source[MLX4_EN_MAC_HASH_IDX];
 				bucket = &priv->mac_hash[mac_hash];
-				rcu_read_lock();
 				hlist_for_each_entry_rcu(entry, bucket, hlist) {
 					if (ether_addr_equal_64bits(entry->mac,
-								    ethh->h_source)) {
-						rcu_read_unlock();
+								    ethh->h_source))
 						goto next;
-					}
 				}
-				rcu_read_unlock();
 			}
 		}
 
@@ -1077,6 +1077,7 @@ consumed:
 	}
 
 out:
+	rcu_read_unlock();
 	if (doorbell_pending)
 		mlx4_en_xmit_doorbell(priv->tx_ring[tx_index]);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 2c2913d..47867c4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -340,7 +340,7 @@ struct mlx4_en_rx_ring {
 	u8  fcs_del;
 	void *buf;
 	void *rx_info;
-	struct bpf_prog *xdp_prog;
+	struct bpf_prog __rcu *xdp_prog;
 	struct mlx4_en_page_cache page_cache;
 	unsigned long bytes;
 	unsigned long packets;
-- 
2.9.3
