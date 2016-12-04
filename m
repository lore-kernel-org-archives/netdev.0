From: Joe Perches <joe@perches.com>
Subject: [PATCH] mlx4: Use kernel sizeof and alloc styles
Date: Sun,  4 Dec 2016 12:11:53 -0800
Message-ID: <8b20668cb08cce8b4af872863440e149bd25fa94.1480882180.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert sizeof foo to sizeof(foo) and allocations with multiplications
to the appropriate kcalloc/kmalloc_array styles.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/mellanox/mlx4/alloc.c         |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  8 ++++----
 drivers/net/ethernet/mellanox/mlx4/en_resources.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  2 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            | 20 +++++++++---------
 drivers/net/ethernet/mellanox/mlx4/fw.c            |  2 +-
 drivers/net/ethernet/mellanox/mlx4/icm.c           |  2 +-
 drivers/net/ethernet/mellanox/mlx4/icm.h           |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/intf.c          |  2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          | 12 +++++------
 drivers/net/ethernet/mellanox/mlx4/mcg.c           | 12 +++++------
 drivers/net/ethernet/mellanox/mlx4/mr.c            | 18 ++++++++--------
 drivers/net/ethernet/mellanox/mlx4/qp.c            | 12 +++++------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 24 +++++++++++-----------
 15 files changed, 63 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index 249a4584401a..c25de2740c78 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -185,8 +185,8 @@ int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 	bitmap->avail = num - reserved_top - reserved_bot;
 	bitmap->effective_len = bitmap->avail;
 	spin_lock_init(&bitmap->lock);
-	bitmap->table = kzalloc(BITS_TO_LONGS(bitmap->max) *
-				sizeof (long), GFP_KERNEL);
+	bitmap->table = kcalloc(BITS_TO_LONGS(bitmap->max), sizeof(long),
+				GFP_KERNEL);
 	if (!bitmap->table)
 		return -ENOMEM;
 
@@ -668,7 +668,7 @@ static struct mlx4_db_pgdir *mlx4_alloc_db_pgdir(struct device *dma_device,
 {
 	struct mlx4_db_pgdir *pgdir;
 
-	pgdir = kzalloc(sizeof *pgdir, gfp);
+	pgdir = kzalloc(sizeof(*pgdir), gfp);
 	if (!pgdir)
 		return NULL;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index e36bebcab3f2..86e03e47ca47 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2616,9 +2616,9 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev)
 	int i;
 	int err = 0;
 
-	priv->cmd.context = kmalloc(priv->cmd.max_cmds *
-				   sizeof (struct mlx4_cmd_context),
-				   GFP_KERNEL);
+	priv->cmd.context = kmalloc_array(priv->cmd.max_cmds,
+					  sizeof(struct mlx4_cmd_context),
+					  GFP_KERNEL);
 	if (!priv->cmd.context)
 		return -ENOMEM;
 
@@ -2675,7 +2675,7 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
 {
 	struct mlx4_cmd_mailbox *mailbox;
 
-	mailbox = kmalloc(sizeof *mailbox, GFP_KERNEL);
+	mailbox = kmalloc(sizeof(*mailbox), GFP_KERNEL);
 	if (!mailbox)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index a6b0db0e0383..10966dc5792c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -44,7 +44,7 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct net_device *dev = priv->dev;
 
-	memset(context, 0, sizeof *context);
+	memset(context, 0, sizeof(*context));
 	context->flags = cpu_to_be32(7 << 16 | rss << MLX4_RSS_QPC_FLAG_OFFSET);
 	context->pd = cpu_to_be32(mdev->priv_pdn);
 	context->mtu_msgmax = 0xff;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6562f78b07f4..616d3febe7ce 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1235,7 +1235,7 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
 	}
 	qp->event = mlx4_en_sqp_event;
 
-	memset(context, 0, sizeof *context);
+	memset(context, 0, sizeof(*context));
 	mlx4_en_fill_qp_context(priv, ring->actual_size, ring->stride, 0, 0,
 				qpn, ring->cqn, -1, context);
 	context->db_rec_addr = cpu_to_be64(ring->wqres.db.dma);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 5de3cbe24f2b..233317e5fe72 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -660,7 +660,7 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
 			     void *fragptr)
 {
 	struct mlx4_wqe_inline_seg *inl = &tx_desc->inl;
-	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof *inl;
+	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof(*inl);
 	unsigned int hlen = skb_headlen(skb);
 
 	if (skb->len <= spc) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index cd3638e6fe25..01210cb044ed 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -259,7 +259,7 @@ int mlx4_gen_pkey_eqe(struct mlx4_dev *dev, int slave, u8 port)
 	if (!s_slave->active)
 		return 0;
 
-	memset(&eqe, 0, sizeof eqe);
+	memset(&eqe, 0, sizeof(eqe));
 
 	eqe.type = MLX4_EVENT_TYPE_PORT_MNG_CHG_EVENT;
 	eqe.subtype = MLX4_DEV_PMC_SUBTYPE_PKEY_TABLE;
@@ -276,7 +276,7 @@ int mlx4_gen_guid_change_eqe(struct mlx4_dev *dev, int slave, u8 port)
 	/*don't send if we don't have the that slave */
 	if (dev->persist->num_vfs < slave)
 		return 0;
-	memset(&eqe, 0, sizeof eqe);
+	memset(&eqe, 0, sizeof(eqe));
 
 	eqe.type = MLX4_EVENT_TYPE_PORT_MNG_CHG_EVENT;
 	eqe.subtype = MLX4_DEV_PMC_SUBTYPE_GUID_INFO;
@@ -295,7 +295,7 @@ int mlx4_gen_port_state_change_eqe(struct mlx4_dev *dev, int slave, u8 port,
 	/*don't send if we don't have the that slave */
 	if (dev->persist->num_vfs < slave)
 		return 0;
-	memset(&eqe, 0, sizeof eqe);
+	memset(&eqe, 0, sizeof(eqe));
 
 	eqe.type = MLX4_EVENT_TYPE_PORT_CHANGE;
 	eqe.subtype = port_subtype_change;
@@ -432,7 +432,7 @@ int mlx4_gen_slaves_port_mgt_ev(struct mlx4_dev *dev, u8 port, int attr)
 {
 	struct mlx4_eqe eqe;
 
-	memset(&eqe, 0, sizeof eqe);
+	memset(&eqe, 0, sizeof(eqe));
 
 	eqe.type = MLX4_EVENT_TYPE_PORT_MNG_CHG_EVENT;
 	eqe.subtype = MLX4_DEV_PMC_SUBTYPE_PORT_INFO;
@@ -721,7 +721,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 			}
 			memcpy(&priv->mfunc.master.comm_arm_bit_vector,
 			       eqe->event.comm_channel_arm.bit_vec,
-			       sizeof eqe->event.comm_channel_arm.bit_vec);
+			       sizeof(eqe->event.comm_channel_arm.bit_vec));
 			queue_work(priv->mfunc.master.comm_wq,
 				   &priv->mfunc.master.comm_work);
 			break;
@@ -986,15 +986,15 @@ static int mlx4_create_eq(struct mlx4_dev *dev, int nent,
 	 */
 	npages = PAGE_ALIGN(eq->nent * dev->caps.eqe_size) / PAGE_SIZE;
 
-	eq->page_list = kmalloc(npages * sizeof *eq->page_list,
-				GFP_KERNEL);
+	eq->page_list = kmalloc_array(npages, sizeof(*eq->page_list),
+				      GFP_KERNEL);
 	if (!eq->page_list)
 		goto err_out;
 
 	for (i = 0; i < npages; ++i)
 		eq->page_list[i].buf = NULL;
 
-	dma_list = kmalloc(npages * sizeof *dma_list, GFP_KERNEL);
+	dma_list = kmalloc_array(npages, sizeof(*dma_list), GFP_KERNEL);
 	if (!dma_list)
 		goto err_out_free;
 
@@ -1163,7 +1163,7 @@ int mlx4_alloc_eq_table(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
 	priv->eq_table.eq = kcalloc(dev->caps.num_eqs - dev->caps.reserved_eqs,
-				    sizeof *priv->eq_table.eq, GFP_KERNEL);
+				    sizeof(*priv->eq_table.eq), GFP_KERNEL);
 	if (!priv->eq_table.eq)
 		return -ENOMEM;
 
@@ -1182,7 +1182,7 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 	int i;
 
 	priv->eq_table.uar_map = kcalloc(mlx4_num_eq_uar(dev),
-					 sizeof *priv->eq_table.uar_map,
+					 sizeof(*priv->eq_table.uar_map),
 					 GFP_KERNEL);
 	if (!priv->eq_table.uar_map) {
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 84bab9f0732e..2be6f0518baf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -57,7 +57,7 @@ MODULE_PARM_DESC(enable_qos, "Enable Enhanced QoS support (default: off)");
 	do {							      \
 		void *__p = (char *) (source) + (offset);	      \
 		u64 val;                                              \
-		switch (sizeof (dest)) {			      \
+		switch (sizeof(dest)) {				      \
 		case 1: (dest) = *(u8 *) __p;	    break;	      \
 		case 2: (dest) = be16_to_cpup(__p); break;	      \
 		case 4: (dest) = be32_to_cpup(__p); break;	      \
diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
index 2a9dd460a95f..84fe587d5dfe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -396,7 +396,7 @@ int mlx4_init_icm_table(struct mlx4_dev *dev, struct mlx4_icm_table *table,
 	obj_per_chunk = MLX4_TABLE_CHUNK_SIZE / obj_size;
 	num_icm = (nobj + obj_per_chunk - 1) / obj_per_chunk;
 
-	table->icm      = kcalloc(num_icm, sizeof *table->icm, GFP_KERNEL);
+	table->icm      = kcalloc(num_icm, sizeof(*table->icm), GFP_KERNEL);
 	if (!table->icm)
 		return -ENOMEM;
 	table->virt     = virt;
diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.h b/drivers/net/ethernet/mellanox/mlx4/icm.h
index 0c7364550150..304f2f1d26a5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.h
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.h
@@ -39,8 +39,8 @@
 #include <linux/mutex.h>
 
 #define MLX4_ICM_CHUNK_LEN						\
-	((256 - sizeof (struct list_head) - 2 * sizeof (int)) /		\
-	 (sizeof (struct scatterlist)))
+	((256 - sizeof(struct list_head) - 2 * sizeof(int)) /		\
+	 (sizeof(struct scatterlist)))
 
 enum {
 	MLX4_ICM_PAGE_SHIFT	= 12,
diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index 0e8b7c44931f..968b4b4ee5ca 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -53,7 +53,7 @@ static void mlx4_add_device(struct mlx4_interface *intf, struct mlx4_priv *priv)
 {
 	struct mlx4_device_context *dev_ctx;
 
-	dev_ctx = kmalloc(sizeof *dev_ctx, GFP_KERNEL);
+	dev_ctx = kmalloc(sizeof(*dev_ctx), GFP_KERNEL);
 	if (!dev_ctx)
 		return;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 6f4e67bc3538..932cd312d131 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -907,10 +907,10 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	mlx4_replace_zero_macs(dev);
 
 	dev->caps.qp0_qkey = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-	dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-	dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-	dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-	dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
+	dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
+	dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
+	dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
+	dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
 
 	if (!dev->caps.qp0_tunnel || !dev->caps.qp0_proxy ||
 	    !dev->caps.qp1_tunnel || !dev->caps.qp1_proxy ||
@@ -2373,7 +2373,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		dev->caps.rx_checksum_flags_port[2] = params.rx_csum_flags_port_2;
 	}
 	priv->eq_table.inta_pin = adapter.inta_pin;
-	memcpy(dev->board_id, adapter.board_id, sizeof dev->board_id);
+	memcpy(dev->board_id, adapter.board_id, sizeof(dev->board_id));
 
 	return 0;
 
@@ -2845,7 +2845,7 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 		if (nreq > MAX_MSIX)
 			nreq = MAX_MSIX;
 
-		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
+		entries = kcalloc(nreq, sizeof(*entries), GFP_KERNEL);
 		if (!entries)
 			goto no_msi;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 94b891c118c1..53841aa994b7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -161,7 +161,7 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 port,
 		return -EINVAL;
 
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
-	new_entry = kzalloc(sizeof *new_entry, GFP_KERNEL);
+	new_entry = kzalloc(sizeof(*new_entry), GFP_KERNEL);
 	if (!new_entry)
 		return -ENOMEM;
 
@@ -174,7 +174,7 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 port,
 	 */
 	pqp = get_promisc_qp(dev, port, steer, qpn);
 	if (pqp) {
-		dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
+		dqp = kmalloc(sizeof(*dqp), GFP_KERNEL);
 		if (!dqp) {
 			err = -ENOMEM;
 			goto out_alloc;
@@ -273,7 +273,7 @@ static int existing_steering_entry(struct mlx4_dev *dev, u8 port,
 	}
 
 	/* add the qp as a duplicate on this index */
-	dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
+	dqp = kmalloc(sizeof(*dqp), GFP_KERNEL);
 	if (!dqp)
 		return -ENOMEM;
 	dqp->qpn = qpn;
@@ -442,7 +442,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 		goto out_mutex;
 	}
 
-	pqp = kmalloc(sizeof *pqp, GFP_KERNEL);
+	pqp = kmalloc(sizeof(*pqp), GFP_KERNEL);
 	if (!pqp) {
 		err = -ENOMEM;
 		goto out_mutex;
@@ -513,7 +513,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 	/* add the new qpn to list of promisc qps */
 	list_add_tail(&pqp->list, &s_steer->promisc_qps[steer]);
 	/* now need to add all the promisc qps to default entry */
-	memset(mgm, 0, sizeof *mgm);
+	memset(mgm, 0, sizeof(*mgm));
 	members_count = 0;
 	list_for_each_entry(dqp, &s_steer->promisc_qps[steer], list) {
 		if (members_count == dev->caps.num_qp_per_mgm) {
@@ -1137,7 +1137,7 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		index += dev->caps.num_mgms;
 
 		new_entry = 1;
-		memset(mgm, 0, sizeof *mgm);
+		memset(mgm, 0, sizeof(*mgm));
 		memcpy(mgm->gid, gid, 16);
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 395b5463cfd9..f490a29b6203 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -106,16 +106,15 @@ static int mlx4_buddy_init(struct mlx4_buddy *buddy, int max_order)
 	buddy->max_order = max_order;
 	spin_lock_init(&buddy->lock);
 
-	buddy->bits = kcalloc(buddy->max_order + 1, sizeof (long *),
-			      GFP_KERNEL);
-	buddy->num_free = kcalloc((buddy->max_order + 1), sizeof *buddy->num_free,
-				  GFP_KERNEL);
+	buddy->bits = kcalloc(buddy->max_order + 1, sizeof(long *), GFP_KERNEL);
+	buddy->num_free = kcalloc(buddy->max_order + 1,
+				  sizeof(*buddy->num_free), GFP_KERNEL);
 	if (!buddy->bits || !buddy->num_free)
 		goto err_out;
 
 	for (i = 0; i <= buddy->max_order; ++i) {
 		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
-		buddy->bits[i] = kcalloc(s, sizeof (long), GFP_KERNEL | __GFP_NOWARN);
+		buddy->bits[i] = kcalloc(s, sizeof(long), GFP_KERNEL | __GFP_NOWARN);
 		if (!buddy->bits[i]) {
 			buddy->bits[i] = vzalloc(s * sizeof(long));
 			if (!buddy->bits[i])
@@ -706,13 +705,13 @@ static int mlx4_write_mtt_chunk(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		return -ENOMEM;
 
 	dma_sync_single_for_cpu(&dev->persist->pdev->dev, dma_handle,
-				npages * sizeof (u64), DMA_TO_DEVICE);
+				npages * sizeof(u64), DMA_TO_DEVICE);
 
 	for (i = 0; i < npages; ++i)
 		mtts[i] = cpu_to_be64(page_list[i] | MLX4_MTT_FLAG_PRESENT);
 
 	dma_sync_single_for_device(&dev->persist->pdev->dev, dma_handle,
-				   npages * sizeof (u64), DMA_TO_DEVICE);
+				   npages * sizeof(u64), DMA_TO_DEVICE);
 
 	return 0;
 }
@@ -796,8 +795,7 @@ int mlx4_buf_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 	int err;
 	int i;
 
-	page_list = kmalloc(buf->npages * sizeof *page_list,
-			    gfp);
+	page_list = kmalloc_array(buf->npages, sizeof(*page_list), gfp);
 	if (!page_list)
 		return -ENOMEM;
 
@@ -1056,7 +1054,7 @@ int mlx4_fmr_alloc(struct mlx4_dev *dev, u32 pd, u32 access, int max_pages,
 		return -EINVAL;
 
 	/* All MTTs must fit in the same page */
-	if (max_pages * sizeof *fmr->mtts > PAGE_SIZE)
+	if (max_pages * sizeof(*fmr->mtts) > PAGE_SIZE)
 		return -EINVAL;
 
 	fmr->page_shift = page_shift;
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index d1cd9c32a9ae..ded4109865a0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -174,7 +174,7 @@ static int __mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 			cpu_to_be16(mlx4_qp_roce_entropy(dev, qp->qpn));
 
 	*(__be32 *) mailbox->buf = cpu_to_be32(optpar);
-	memcpy(mailbox->buf + 8, context, sizeof *context);
+	memcpy(mailbox->buf + 8, context, sizeof(*context));
 
 	((struct mlx4_qp_context *) (mailbox->buf + 8))->local_qpn =
 		cpu_to_be32(qp->qpn);
@@ -825,10 +825,10 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 
 		/* In mfunc, calculate proxy and tunnel qp offsets for the PF here,
 		 * since the PF does not call mlx4_slave_caps */
-		dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-		dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-		dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-		dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
+		dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
+		dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
+		dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
+		dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
 
 		if (!dev->caps.qp0_tunnel || !dev->caps.qp0_proxy ||
 		    !dev->caps.qp1_tunnel || !dev->caps.qp1_proxy) {
@@ -888,7 +888,7 @@ int mlx4_qp_query(struct mlx4_dev *dev, struct mlx4_qp *qp,
 			   MLX4_CMD_QUERY_QP, MLX4_CMD_TIME_CLASS_A,
 			   MLX4_CMD_WRAPPED);
 	if (!err)
-		memcpy(context, mailbox->buf + 8, sizeof *context);
+		memcpy(context, mailbox->buf + 8, sizeof(*context));
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index c548beaaf910..ff11dc01c2d5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -999,7 +999,7 @@ static struct res_common *alloc_qp_tr(int id)
 {
 	struct res_qp *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1017,7 +1017,7 @@ static struct res_common *alloc_mtt_tr(int id, int order)
 {
 	struct res_mtt *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1033,7 +1033,7 @@ static struct res_common *alloc_mpt_tr(int id, int key)
 {
 	struct res_mpt *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1048,7 +1048,7 @@ static struct res_common *alloc_eq_tr(int id)
 {
 	struct res_eq *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1062,7 +1062,7 @@ static struct res_common *alloc_cq_tr(int id)
 {
 	struct res_cq *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1077,7 +1077,7 @@ static struct res_common *alloc_srq_tr(int id)
 {
 	struct res_srq *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1092,7 +1092,7 @@ static struct res_common *alloc_counter_tr(int id, int port)
 {
 	struct res_counter *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1107,7 +1107,7 @@ static struct res_common *alloc_xrcdn_tr(int id)
 {
 	struct res_xrcdn *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1121,7 +1121,7 @@ static struct res_common *alloc_fs_rule_tr(u64 id, int qpn)
 {
 	struct res_fs_rule *ret;
 
-	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
 	if (!ret)
 		return NULL;
 
@@ -1233,7 +1233,7 @@ static int add_res_range(struct mlx4_dev *dev, int slave, u64 base, int count,
 	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
 	struct rb_root *root = &tracker->res_tree[type];
 
-	res_arr = kzalloc(count * sizeof *res_arr, GFP_KERNEL);
+	res_arr = kcalloc(count, sizeof(*res_arr), GFP_KERNEL);
 	if (!res_arr)
 		return -ENOMEM;
 
@@ -1986,7 +1986,7 @@ static int mac_add_to_slave(struct mlx4_dev *dev, int slave, u64 mac, int port,
 
 	if (mlx4_grant_resource(dev, slave, RES_MAC, 1, port))
 		return -EINVAL;
-	res = kzalloc(sizeof *res, GFP_KERNEL);
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
 	if (!res) {
 		mlx4_release_resource(dev, slave, RES_MAC, 1, port);
 		return -ENOMEM;
@@ -3978,7 +3978,7 @@ static int add_mcg_res(struct mlx4_dev *dev, int slave, struct res_qp *rqp,
 	struct res_gid *res;
 	int err;
 
-	res = kzalloc(sizeof *res, GFP_KERNEL);
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
 	if (!res)
 		return -ENOMEM;
 
-- 
2.10.0.rc2.1.g053435c
