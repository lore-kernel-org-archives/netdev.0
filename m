From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 02/14] net/mlx4_en: Align tx path structures to cache lines
Date: Sun,  5 Oct 2014 12:35:10 +0300
Message-ID: <1412501722-25092-3-git-send-email-amirv@mellanox.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52666 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751019AbaJEJfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 05:35:38 -0400
In-Reply-To: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Reorganize struct mlx4_en_tx_ring to have:
- One cache line containing last_nr_txbb & cons & wake_queue, used by tx
  completion.
- One cache line containing fields dirtied by mlx4_en_xmit()
- Following part is read mostly and shared by cpus.

Align struct mlx4_en_tx_info to a cache line

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 86 +++++++++++++++-------------
 1 file changed, 46 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index e54b653..b7bde95 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -216,13 +216,13 @@ enum cq_type {
 
 struct mlx4_en_tx_info {
 	struct sk_buff *skb;
-	u32 nr_txbb;
-	u32 nr_bytes;
-	u8 linear;
-	u8 data_offset;
-	u8 inl;
-	u8 ts_requested;
-};
+	u32		nr_txbb;
+	u32		nr_bytes;
+	u8		linear;
+	u8		data_offset;
+	u8		inl;
+	u8		ts_requested;
+} ____cacheline_aligned_in_smp;
 
 
 #define MLX4_EN_BIT_DESC_OWN	0x80000000
@@ -253,40 +253,46 @@ struct mlx4_en_rx_alloc {
 };
 
 struct mlx4_en_tx_ring {
+	/* cache line used and dirtied in tx completion
+	 * (mlx4_en_free_tx_buf())
+	 */
+	u32			last_nr_txbb;
+	u32			cons;
+	unsigned long		wake_queue;
+
+	/* cache line used and dirtied in mlx4_en_xmit() */
+	u32			prod ____cacheline_aligned_in_smp;
+	unsigned long		bytes;
+	unsigned long		packets;
+	unsigned long		tx_csum;
+	unsigned long		tso_packets;
+	unsigned long		xmit_more;
+	struct mlx4_bf		bf;
+	unsigned long		queue_stopped;
+
+	/* Following part should be mostly read */
+	cpumask_t		affinity_mask;
+	struct mlx4_qp		qp;
 	struct mlx4_hwq_resources wqres;
-	u32 size ; /* number of TXBBs */
-	u32 size_mask;
-	u16 stride;
-	u16 cqn;	/* index of port CQ associated with this ring */
-	u32 prod;
-	u32 cons;
-	u32 buf_size;
-	u32 doorbell_qpn;
-	void *buf;
-	struct mlx4_en_tx_info *tx_info;
-	u8 *bounce_buf;
-	u8 queue_index;
-	cpumask_t affinity_mask;
-	u32 last_nr_txbb;
-	struct mlx4_qp qp;
-	struct mlx4_qp_context context;
-	int qpn;
-	enum mlx4_qp_state qp_state;
-	struct mlx4_srq dummy;
-	unsigned long bytes;
-	unsigned long packets;
-	unsigned long tx_csum;
-	unsigned long queue_stopped;
-	unsigned long wake_queue;
-	unsigned long tso_packets;
-	unsigned long xmit_more;
-	struct mlx4_bf bf;
-	bool bf_enabled;
-	bool bf_alloced;
-	struct netdev_queue *tx_queue;
-	int hwtstamp_tx_type;
-	int inline_thold;
-};
+	u32			size; /* number of TXBBs */
+	u32			size_mask;
+	u16			stride;
+	u16			cqn;	/* index of port CQ associated with this ring */
+	u32			buf_size;
+	u32			doorbell_qpn;
+	void			*buf;
+	struct mlx4_en_tx_info	*tx_info;
+	u8			*bounce_buf;
+	struct mlx4_qp_context	context;
+	int			qpn;
+	enum mlx4_qp_state	qp_state;
+	u8			queue_index;
+	bool			bf_enabled;
+	bool			bf_alloced;
+	struct netdev_queue	*tx_queue;
+	int			hwtstamp_tx_type;
+	int			inline_thold;
+} ____cacheline_aligned_in_smp;
 
 struct mlx4_en_rx_desc {
 	/* actual number of entries depends on rx ring stride */
-- 
1.8.3.4
