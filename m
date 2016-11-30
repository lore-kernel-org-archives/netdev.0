From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, xdp: drop rcu_read_lock from bpf_prog_run_xdp and move to caller
Date: Wed, 30 Nov 2016 22:16:06 +0100
Message-ID: <b70c47e0284823e6a5db600ae75c01eac4cf7922.1480538565.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, saeedm@mellanox.com, kubakici@wp.pl,
        Yuval.Mintz@cavium.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48332 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754405AbcK3VQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 16:16:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After 326fe02d1ed6 ("net/mlx4_en: protect ring->xdp_prog with rcu_read_lock"),
the rcu_read_lock() in bpf_prog_run_xdp() is superfluous, since callers
need to hold rcu_read_lock() already to make sure BPF program doesn't
get released in the background.

Thus, drop it from bpf_prog_run_xdp(), as it can otherwise be misleading.
Still keeping the bpf_prog_run_xdp() is useful as it allows for grepping
in XDP supported drivers and to keep the typecheck on the context intact.
For mlx4, this means we don't have a double rcu_read_lock() anymore. nfp can
just make use of bpf_prog_run_xdp(), too. For qede, just move rcu_read_lock()
out of the helper. When the driver gets atomic replace support, this will
move to call-sites eventually.

mlx5 needs actual fixing as it has the same issue as described already in
326fe02d1ed6 ("net/mlx4_en: protect ring->xdp_prog with rcu_read_lock"),
that is, we're under RCU bh at this time, BPF programs are released via
call_rcu(), and call_rcu() != call_rcu_bh(), so we need to properly mark
read side as programs can get xchg()'ed in mlx5e_xdp_set() without queue
reset.

Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 ( Also here net-next is just fine, imho. )

 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c     |  8 ++++++--
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c |  2 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c        |  7 +++++++
 include/linux/filter.h                              | 18 +++++++++---------
 4 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index b036710..42cd687 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -737,10 +737,10 @@ static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
 struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 			     u16 wqe_counter, u32 cqe_bcnt)
 {
-	struct bpf_prog *xdp_prog = READ_ONCE(rq->xdp_prog);
 	struct mlx5e_dma_info *di;
 	struct sk_buff *skb;
 	void *va, *data;
+	bool consumed;
 
 	di             = &rq->dma_info[wqe_counter];
 	va             = page_address(di->page);
@@ -759,7 +759,11 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 		return NULL;
 	}
 
-	if (mlx5e_xdp_handle(rq, xdp_prog, di, data, cqe_bcnt))
+	rcu_read_lock();
+	consumed = mlx5e_xdp_handle(rq, READ_ONCE(rq->xdp_prog), di, data,
+				    cqe_bcnt);
+	rcu_read_unlock();
+	if (consumed)
 		return NULL; /* page/packet was consumed by XDP */
 
 	skb = build_skb(va, RQ_PAGE_SIZE(rq));
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 876ab3a..00d9a03 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1518,7 +1518,7 @@ static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, unsigned int len)
 	xdp.data = data;
 	xdp.data_end = data + len;
 
-	return BPF_PROG_RUN(prog, &xdp);
+	return bpf_prog_run_xdp(prog, &xdp);
 }
 
 /**
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 172ff6d..faeaa9f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1497,7 +1497,14 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 
 	xdp.data = page_address(bd->data) + cqe->placement_offset;
 	xdp.data_end = xdp.data + len;
+
+	/* Queues always have a full reset currently, so for the time
+	 * being until there's atomic program replace just mark read
+	 * side for map helpers.
+	 */
+	rcu_read_lock();
 	act = bpf_prog_run_xdp(prog, &xdp);
+	rcu_read_unlock();
 
 	if (act == XDP_PASS)
 		return true;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7f246a2..45bd83e 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -498,16 +498,16 @@ static inline u32 bpf_prog_run_clear_cb(const struct bpf_prog *prog,
 	return BPF_PROG_RUN(prog, skb);
 }
 
-static inline u32 bpf_prog_run_xdp(const struct bpf_prog *prog,
-				   struct xdp_buff *xdp)
+static __always_inline u32 bpf_prog_run_xdp(const struct bpf_prog *prog,
+					    struct xdp_buff *xdp)
 {
-	u32 ret;
-
-	rcu_read_lock();
-	ret = BPF_PROG_RUN(prog, xdp);
-	rcu_read_unlock();
-
-	return ret;
+	/* Caller needs to hold rcu_read_lock() (!), otherwise program
+	 * can be released while still running, or map elements could be
+	 * freed early while still having concurrent users. XDP fastpath
+	 * already takes rcu_read_lock() when fetching the program, so
+	 * it's not necessary here anymore.
+	 */
+	return BPF_PROG_RUN(prog, xdp);
 }
 
 static inline unsigned int bpf_prog_size(unsigned int proglen)
-- 
1.9.3
