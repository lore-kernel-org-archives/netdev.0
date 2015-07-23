From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/6] net/mlx5e: TX latency optimization to save DMA reads
Date: Thu, 23 Jul 2015 23:35:59 +0300
Message-ID: <1437683761-28052-5-git-send-email-amirv@mellanox.com>
References: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39691 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754061AbbGWUg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 16:36:58 -0400
In-Reply-To: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

A regular TX WQE execution involves two or more DMA reads -
one to fetch the WQE, and another one per WQE gather entry.

These DMA reads obviously increase the TX latency.
There are two mlx5 mechanisms to bypass these DMA reads:
1) Inline WQE
2) Blue Flame (BF)

An inline WQE contains a whole packet, thus saves the DMA read/s
of the regular WQE gather entry/s. Inline WQE support was already
added in the previous commit.

A BF WQE is written directly to the device I/O mapped memory, thus
enables saving the DMA read that fetches the WQE.

The BF WQE I/O write must be in cache line granularity, thus uses
the CPU write combining mechanism.
A BF WQE I/O write acts also as a TX doorbell for notifying the
device of new TX WQEs.
A BF WQE is written to the same I/O mapped address as the regular TX
doorbell, thus this address is being mapped twice - once by ioremap()
and once by io_mapping_map_wc().

While both mechanisms reduce the TX latency, they both consume more CPU
cycles than a regular WQE:
- A BF WQE must still be written to host memory, in addition to being
  written directly to the device I/O mapped memory.
- An inline WQE involves copying the SKB data into it.

To handle this tradeoff, we introduce here a heuristic algorithm that
strives to avoid using these two mechanisms in case the TX queue is
being back-pressured by the device, and limit their usage rate otherwise.

An inline WQE will always be "Blue Flamed" (written directly to the
device I/O mapped memory) while a BF WQE may not be inlined (may contain
gather entries).

Preliminary testing using netperf UDP_RR shows that the latency goes down
from 17.5us to 16.9us, while the message rate (tested with pktgen) stays
the same.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 24 +++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 12 ++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 26 ++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/main.c    | 26 +++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/uar.c     |  6 ++++++
 include/linux/mlx5/driver.h                       |  4 +++-
 6 files changed, 79 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index d9dc506..b66edd2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -60,6 +60,7 @@
 
 #define MLX5E_TX_CQ_POLL_BUDGET        128
 #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
+#define MLX5E_SQ_BF_BUDGET             16
 
 static const char vport_strings[][ETH_GSTRING_LEN] = {
 	/* vport statistics */
@@ -268,7 +269,9 @@ struct mlx5e_sq {
 	/* dirtied @xmit */
 	u16                        pc ____cacheline_aligned_in_smp;
 	u32                        dma_fifo_pc;
-	u32                        bf_offset;
+	u16                        bf_offset;
+	u16                        prev_cc;
+	u8                         bf_budget;
 	struct mlx5e_sq_stats      stats;
 
 	struct mlx5e_cq            cq;
@@ -281,9 +284,10 @@ struct mlx5e_sq {
 	struct mlx5_wq_cyc         wq;
 	u32                        dma_fifo_mask;
 	void __iomem              *uar_map;
+	void __iomem              *uar_bf_map;
 	struct netdev_queue       *txq;
 	u32                        sqn;
-	u32                        bf_buf_size;
+	u16                        bf_buf_size;
 	u16                        max_inline;
 	u16                        edge;
 	struct device             *pdev;
@@ -493,8 +497,10 @@ int mlx5e_update_priv_params(struct mlx5e_priv *priv,
 			     struct mlx5e_params *new_params);
 
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
-				      struct mlx5e_tx_wqe *wqe)
+				      struct mlx5e_tx_wqe *wqe, int bf_sz)
 {
+	u16 ofst = MLX5_BF_OFFSET + sq->bf_offset;
+
 	/* ensure wqe is visible to device before updating doorbell record */
 	dma_wmb();
 
@@ -505,9 +511,15 @@ static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 	 */
 	wmb();
 
-	mlx5_write64((__be32 *)&wqe->ctrl,
-		     sq->uar_map + MLX5_BF_OFFSET + sq->bf_offset,
-		     NULL);
+	if (bf_sz) {
+		__iowrite64_copy(sq->uar_bf_map + ofst, &wqe->ctrl, bf_sz);
+
+		/* flush the write-combining mapped buffer */
+		wmb();
+
+	} else {
+		mlx5_write64((__be32 *)&wqe->ctrl, sq->uar_map + ofst, NULL);
+	}
 
 	sq->bf_offset ^= sq->bf_buf_size;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c55fad4..4a87e9d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -514,6 +514,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 
 	sq->wq.db       = &sq->wq.db[MLX5_SND_DBR];
 	sq->uar_map     = sq->uar.map;
+	sq->uar_bf_map  = sq->uar.bf_map;
 	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
 	sq->max_inline  = param->max_inline;
 
@@ -524,11 +525,12 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	txq_ix = c->ix + tc * priv->params.num_channels;
 	sq->txq = netdev_get_tx_queue(priv->netdev, txq_ix);
 
-	sq->pdev    = c->pdev;
-	sq->mkey_be = c->mkey_be;
-	sq->channel = c;
-	sq->tc      = tc;
-	sq->edge    = (sq->wq.sz_m1 + 1) - MLX5_SEND_WQE_MAX_WQEBBS;
+	sq->pdev      = c->pdev;
+	sq->mkey_be   = c->mkey_be;
+	sq->channel   = c;
+	sq->tc        = tc;
+	sq->edge      = (sq->wq.sz_m1 + 1) - MLX5_SEND_WQE_MAX_WQEBBS;
+	sq->bf_budget = MLX5E_SQ_BF_BUDGET;
 	priv->txq_to_sq_map[txq_ix] = sq;
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 351ac69..64380bc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -57,7 +57,7 @@ void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
 
 	if (notify_hw) {
 		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, wqe);
+		mlx5e_tx_notify_hw(sq, wqe, 0);
 	}
 }
 
@@ -110,7 +110,7 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 }
 
 static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
-					    struct sk_buff *skb)
+					    struct sk_buff *skb, bool bf)
 {
 	/* Some NIC TX decisions, e.g loopback, are based on the packet
 	 * headers and occur before the data gather.
@@ -118,7 +118,7 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 	 */
 #define MLX5E_MIN_INLINE (ETH_HLEN + 2/*vlan tag*/)
 
-	if (skb_headlen(skb) <= sq->max_inline)
+	if (bf && (skb_headlen(skb) <= sq->max_inline))
 		return skb_headlen(skb);
 
 	return MLX5E_MIN_INLINE;
@@ -137,6 +137,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	u8  opcode = MLX5_OPCODE_SEND;
 	dma_addr_t dma_addr = 0;
+	bool bf = false;
 	u16 headlen;
 	u16 ds_cnt;
 	u16 ihs;
@@ -149,6 +150,11 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	else
 		sq->stats.csum_offload_none++;
 
+	if (sq->cc != sq->prev_cc) {
+		sq->prev_cc = sq->cc;
+		sq->bf_budget = (sq->cc == sq->pc) ? MLX5E_SQ_BF_BUDGET : 0;
+	}
+
 	if (skb_is_gso(skb)) {
 		u32 payload_len;
 
@@ -161,7 +167,10 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		sq->stats.tso_packets++;
 		sq->stats.tso_bytes += payload_len;
 	} else {
-		ihs = mlx5e_get_inline_hdr_size(sq, skb);
+		bf = sq->bf_budget &&
+		     !skb->xmit_more &&
+		     !skb_shinfo(skb)->nr_frags;
+		ihs = mlx5e_get_inline_hdr_size(sq, skb, bf);
 		MLX5E_TX_SKB_CB(skb)->num_bytes = max_t(unsigned int, skb->len,
 							ETH_ZLEN);
 	}
@@ -233,14 +242,21 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	}
 
 	if (!skb->xmit_more || netif_xmit_stopped(sq->txq)) {
+		int bf_sz = 0;
+
+		if (bf && sq->uar_bf_map)
+			bf_sz = MLX5E_TX_SKB_CB(skb)->num_wqebbs << 3;
+
 		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, wqe);
+		mlx5e_tx_notify_hw(sq, wqe, bf_sz);
 	}
 
 	/* fill sq edge with nops to avoid wqe wrap around */
 	while ((sq->pc & wq->sz_m1) > sq->edge)
 		mlx5e_send_nop(sq, false);
 
+	sq->bf_budget = bf ? sq->bf_budget - 1 : 0;
+
 	sq->stats.packets++;
 	return NETDEV_TX_OK;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index c34eafb..603a8b0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -654,6 +654,22 @@ static int mlx5_core_set_issi(struct mlx5_core_dev *dev)
 }
 #endif
 
+static int map_bf_area(struct mlx5_core_dev *dev)
+{
+	resource_size_t bf_start = pci_resource_start(dev->pdev, 0);
+	resource_size_t bf_len = pci_resource_len(dev->pdev, 0);
+
+	dev->priv.bf_mapping = io_mapping_create_wc(bf_start, bf_len);
+
+	return dev->priv.bf_mapping ? 0 : -ENOMEM;
+}
+
+static void unmap_bf_area(struct mlx5_core_dev *dev)
+{
+	if (dev->priv.bf_mapping)
+		io_mapping_free(dev->priv.bf_mapping);
+}
+
 static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 {
 	struct mlx5_priv *priv = &dev->priv;
@@ -808,10 +824,13 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 		goto err_stop_eqs;
 	}
 
+	if (map_bf_area(dev))
+		dev_err(&pdev->dev, "Failed to map blue flame area\n");
+
 	err = mlx5_irq_set_affinity_hints(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to alloc affinity hint cpumask\n");
-		goto err_free_comp_eqs;
+		goto err_unmap_bf_area;
 	}
 
 	MLX5_INIT_DOORBELL_LOCK(&priv->cq_uar_lock);
@@ -823,7 +842,9 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 
 	return 0;
 
-err_free_comp_eqs:
+err_unmap_bf_area:
+	unmap_bf_area(dev);
+
 	free_comp_eqs(dev);
 
 err_stop_eqs:
@@ -881,6 +902,7 @@ static void mlx5_dev_cleanup(struct mlx5_core_dev *dev)
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
 	mlx5_irq_clear_affinity_hints(dev);
+	unmap_bf_area(dev);
 	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
 	mlx5_free_uuars(dev, &priv->uuari);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index 9ef8587..eb05c84 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -32,6 +32,7 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/io-mapping.h>
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
@@ -246,6 +247,10 @@ int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
 		goto err_free_uar;
 	}
 
+	if (mdev->priv.bf_mapping)
+		uar->bf_map = io_mapping_map_wc(mdev->priv.bf_mapping,
+						uar->index << PAGE_SHIFT);
+
 	return 0;
 
 err_free_uar:
@@ -257,6 +262,7 @@ EXPORT_SYMBOL(mlx5_alloc_map_uar);
 
 void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
 {
+	io_mapping_unmap(uar->bf_map);
 	iounmap(uar->map);
 	mlx5_cmd_free_uar(mdev, uar->index);
 }
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 1c0d5d0..5fe0cae 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -380,7 +380,7 @@ struct mlx5_uar {
 	u32			index;
 	struct list_head	bf_list;
 	unsigned		free_bf_bmap;
-	void __iomem	       *wc_map;
+	void __iomem	       *bf_map;
 	void __iomem	       *map;
 };
 
@@ -435,6 +435,8 @@ struct mlx5_priv {
 	struct mlx5_uuar_info	uuari;
 	MLX5_DECLARE_DOORBELL_LOCK(cq_uar_lock);
 
+	struct io_mapping	*bf_mapping;
+
 	/* pages stuff */
 	struct workqueue_struct *pg_wq;
 	struct rb_root		page_root;
-- 
2.4.3.413.ga5fe668
