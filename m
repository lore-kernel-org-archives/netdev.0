From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 07/10] net/mlx4: Add A0 hybrid steering
Date: Thu, 11 Dec 2014 10:57:57 +0200
Message-ID: <1418288280-334-8-git-send-email-ogerlitz@mellanox.com>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40536 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934176AbaLKI7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:59:16 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

A0 hybrid steering is a form of high performance flow steering.
By using this mode, mlx4 cards use a fast limited table based steering,
in order to enable fast steering of unicast packets to a QP.

In order to implement A0 hybrid steering we allocate resources
from different zones:
(1) General range
(2) Special MAC-assigned QPs [RSS, Raw-Ethernet] each has its own region.

When we create a rss QP or a raw ethernet (A0 steerable and BF ready) QP,
we try hard to allocate the QP from range (2). Otherwise, we try hard not
to allocate from this  range. However, when the system is pushed to its
limits and one needs every resource, the allocator uses every region it can.

Meaning, when we run out of raw-eth qps, the allocator allocates from the
general range (and the special-A0 area is no longer active). If we run out
of RSS qps, the mechanism tries to allocate from the raw-eth QP zone. If that
is also exhausted, the allocator will allocate from the general range
(and the A0 region is no longer active).

Note that if a raw-eth qp is allocated from the general range, it attempts
to allocate the range such that bits 6 and 7 (blueflame bits) in the
QP number are not set.

When the feature is used in SRIOV, the VF has to notify the PF what
kind of QP attributes it needs. In order to do that, along with the
"Eth QP blueflame" bit, we reserve a new "A0 steerable QP". According
to the combination of these bits, the PF tries to allocate a suitable QP.

In order to maintain backward compatibility (with older PFs), the PF
notifies which QP attributes it supports via QUERY_FUNC_CAP command.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/qp.c                |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |    3 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    6 +-
 drivers/net/ethernet/mellanox/mlx4/main.c      |    8 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |   13 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c        |  277 ++++++++++++++++++++++--
 include/linux/mlx4/device.h                    |   10 +-
 8 files changed, 300 insertions(+), 25 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 506d1bd..cf000b7 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -807,8 +807,10 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 		 * VLAN insertion. */
 		if (init_attr->qp_type == IB_QPT_RAW_PACKET)
 			err = mlx4_qp_reserve_range(dev->dev, 1, 1, &qpn,
-						    init_attr->cap.max_send_wr ?
-						    MLX4_RESERVE_ETH_BF_QP : 0);
+						    (init_attr->cap.max_send_wr ?
+						     MLX4_RESERVE_ETH_BF_QP : 0) |
+						    (init_attr->cap.max_recv_wr ?
+						     MLX4_RESERVE_A0_QP : 0));
 		else
 			if (qp->flags & MLX4_IB_QP_NETIF)
 				err = mlx4_ib_steer_qp_alloc(dev, 1, &qpn);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c67effb..568e1f4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -595,7 +595,7 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 		return 0;
 	}
 
-	err = mlx4_qp_reserve_range(dev, 1, 1, qpn, 0);
+	err = mlx4_qp_reserve_range(dev, 1, 1, qpn, MLX4_RESERVE_A0_QP);
 	en_dbg(DRV, priv, "Reserved qp %d\n", *qpn);
 	if (err) {
 		en_err(priv, "Failed to reserve qp for mac registration\n");
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index a850f24..a0474eb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1131,7 +1131,8 @@ int mlx4_en_create_drop_qp(struct mlx4_en_priv *priv)
 	int err;
 	u32 qpn;
 
-	err = mlx4_qp_reserve_range(priv->mdev->dev, 1, 1, &qpn, 0);
+	err = mlx4_qp_reserve_range(priv->mdev->dev, 1, 1, &qpn,
+				    MLX4_RESERVE_A0_QP);
 	if (err) {
 		en_err(priv, "Failed reserving drop qpn\n");
 		return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 1469b5b..622bffa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -275,6 +275,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_FLAG_VALID_MAILBOX	0x04
 
 #define QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG	(1UL << 31)
+#define QUERY_FUNC_CAP_EXTRA_FLAGS_A0_QP_ALLOC_FLAG	(1UL << 30)
 
 /* when opcode modifier = 1 */
 #define QUERY_FUNC_CAP_PHYS_PORT_OFFSET		0x3
@@ -406,7 +407,8 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MCG_QUOTA_OFFSET);
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MCG_QUOTA_OFFSET_DEP);
 
-		size = QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG;
+		size = QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG |
+			QUERY_FUNC_CAP_EXTRA_FLAGS_A0_QP_ALLOC_FLAG;
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_EXTRA_FLAGS_OFFSET);
 	} else
 		err = -EINVAL;
@@ -509,6 +511,8 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 			MLX4_GET(size, outbox, QUERY_FUNC_CAP_EXTRA_FLAGS_OFFSET);
 			if (size & QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG)
 				func_cap->extra_flags |= MLX4_QUERY_FUNC_FLAGS_BF_RES_QP;
+			if (size & QUERY_FUNC_CAP_EXTRA_FLAGS_A0_QP_ALLOC_FLAG)
+				func_cap->extra_flags |= MLX4_QUERY_FUNC_FLAGS_A0_RES_QP;
 		}
 
 		goto out;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 6a9a941..3bfe90b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -436,6 +436,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		(1 << dev->caps.log_num_vlans) *
 		dev->caps.num_ports;
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_EXCH] = MLX4_NUM_FEXCH;
+	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_RSS_RAW_ETH] =
+		MLX4_A0_STEERING_TABLE_SIZE;
 
 	dev->caps.reserved_qps = dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW] +
 		dev->caps.reserved_qps_cnt[MLX4_QP_REGION_ETH_ADDR] +
@@ -469,7 +471,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	if (!mlx4_is_slave(dev)) {
 		mlx4_enable_cqe_eqe_stride(dev);
 		dev->caps.alloc_res_qp_mask =
-			(dev->caps.bf_reg_size ? MLX4_RESERVE_ETH_BF_QP : 0);
+			(dev->caps.bf_reg_size ? MLX4_RESERVE_ETH_BF_QP : 0) |
+			MLX4_RESERVE_A0_QP;
 	} else {
 		dev->caps.alloc_res_qp_mask = 0;
 	}
@@ -826,6 +829,9 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	    dev->caps.bf_reg_size)
 		dev->caps.alloc_res_qp_mask |= MLX4_RESERVE_ETH_BF_QP;
 
+	if (func_cap.extra_flags & MLX4_QUERY_FUNC_FLAGS_A0_RES_QP)
+		dev->caps.alloc_res_qp_mask |= MLX4_RESERVE_A0_QP;
+
 	return 0;
 
 err_mem:
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index bc1505e..cebd118 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -682,8 +682,19 @@ struct mlx4_srq_table {
 	struct mlx4_icm_table	cmpt_table;
 };
 
+enum mlx4_qp_table_zones {
+	MLX4_QP_TABLE_ZONE_GENERAL,
+	MLX4_QP_TABLE_ZONE_RSS,
+	MLX4_QP_TABLE_ZONE_RAW_ETH,
+	MLX4_QP_TABLE_ZONE_NUM
+};
+
+#define MLX4_A0_STEERING_TABLE_SIZE    256
+
 struct mlx4_qp_table {
-	struct mlx4_bitmap	bitmap;
+	struct mlx4_bitmap	*bitmap_gen;
+	struct mlx4_zone_allocator *zones;
+	u32			zones_uids[MLX4_QP_TABLE_ZONE_NUM];
 	u32			rdmarc_base;
 	int			rdmarc_shift;
 	spinlock_t		lock;
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 8720428..d8d040c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -213,6 +213,7 @@ EXPORT_SYMBOL_GPL(mlx4_qp_modify);
 int __mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align,
 			    int *base, u8 flags)
 {
+	u32 uid;
 	int bf_qp = !!(flags & (u8)MLX4_RESERVE_ETH_BF_QP);
 
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -221,8 +222,16 @@ int __mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align,
 	if (cnt > MLX4_MAX_BF_QP_RANGE && bf_qp)
 		return -ENOMEM;
 
-	*base = mlx4_bitmap_alloc_range(&qp_table->bitmap, cnt, align,
-					bf_qp ? MLX4_BF_QP_SKIP_MASK : 0);
+	uid = MLX4_QP_TABLE_ZONE_GENERAL;
+	if (flags & (u8)MLX4_RESERVE_A0_QP) {
+		if (bf_qp)
+			uid = MLX4_QP_TABLE_ZONE_RAW_ETH;
+		else
+			uid = MLX4_QP_TABLE_ZONE_RSS;
+	}
+
+	*base = mlx4_zone_alloc_entries(qp_table->zones, uid, cnt, align,
+					bf_qp ? MLX4_BF_QP_SKIP_MASK : 0, NULL);
 	if (*base == -1)
 		return -ENOMEM;
 
@@ -263,7 +272,7 @@ void __mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt)
 
 	if (mlx4_is_qp_reserved(dev, (u32) base_qpn))
 		return;
-	mlx4_bitmap_free_range(&qp_table->bitmap, base_qpn, cnt, MLX4_USE_RR);
+	mlx4_zone_free_entries_unique(qp_table->zones, base_qpn, cnt);
 }
 
 void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt)
@@ -473,6 +482,227 @@ static int mlx4_CONF_SPECIAL_QP(struct mlx4_dev *dev, u32 base_qpn)
 			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 }
 
+#define MLX4_QP_TABLE_RSS_ETH_PRIORITY 2
+#define MLX4_QP_TABLE_RAW_ETH_PRIORITY 1
+#define MLX4_QP_TABLE_RAW_ETH_SIZE     256
+
+static int mlx4_create_zones(struct mlx4_dev *dev,
+			     u32 reserved_bottom_general,
+			     u32 reserved_top_general,
+			     u32 reserved_bottom_rss,
+			     u32 start_offset_rss,
+			     u32 max_table_offset)
+{
+	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
+	struct mlx4_bitmap (*bitmap)[MLX4_QP_TABLE_ZONE_NUM] = NULL;
+	int bitmap_initialized = 0;
+	u32 last_offset;
+	int k;
+	int err;
+
+	qp_table->zones = mlx4_zone_allocator_create(MLX4_ZONE_ALLOC_FLAGS_NO_OVERLAP);
+
+	if (NULL == qp_table->zones)
+		return -ENOMEM;
+
+	bitmap = kmalloc(sizeof(*bitmap), GFP_KERNEL);
+
+	if (NULL == bitmap) {
+		err = -ENOMEM;
+		goto free_zone;
+	}
+
+	err = mlx4_bitmap_init(*bitmap + MLX4_QP_TABLE_ZONE_GENERAL, dev->caps.num_qps,
+			       (1 << 23) - 1, reserved_bottom_general,
+			       reserved_top_general);
+
+	if (err)
+		goto free_bitmap;
+
+	++bitmap_initialized;
+
+	err = mlx4_zone_add_one(qp_table->zones, *bitmap + MLX4_QP_TABLE_ZONE_GENERAL,
+				MLX4_ZONE_FALLBACK_TO_HIGHER_PRIO |
+				MLX4_ZONE_USE_RR, 0,
+				0, qp_table->zones_uids + MLX4_QP_TABLE_ZONE_GENERAL);
+
+	if (err)
+		goto free_bitmap;
+
+	err = mlx4_bitmap_init(*bitmap + MLX4_QP_TABLE_ZONE_RSS,
+			       reserved_bottom_rss,
+			       reserved_bottom_rss - 1,
+			       dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW],
+			       reserved_bottom_rss - start_offset_rss);
+
+	if (err)
+		goto free_bitmap;
+
+	++bitmap_initialized;
+
+	err = mlx4_zone_add_one(qp_table->zones, *bitmap + MLX4_QP_TABLE_ZONE_RSS,
+				MLX4_ZONE_ALLOW_ALLOC_FROM_LOWER_PRIO |
+				MLX4_ZONE_ALLOW_ALLOC_FROM_EQ_PRIO |
+				MLX4_ZONE_USE_RR, MLX4_QP_TABLE_RSS_ETH_PRIORITY,
+				0, qp_table->zones_uids + MLX4_QP_TABLE_ZONE_RSS);
+
+	if (err)
+		goto free_bitmap;
+
+	last_offset = dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW];
+	/*  We have a single zone for the A0 steering QPs area of the FW. This area
+	 *  needs to be split into subareas. One set of subareas is for RSS QPs
+	 *  (in which qp number bits 6 and/or 7 are set); the other set of subareas
+	 *  is for RAW_ETH QPs, which require that both bits 6 and 7 are zero.
+	 *  Currently, the values returned by the FW (A0 steering area starting qp number
+	 *  and A0 steering area size) are such that there are only two subareas -- one
+	 *  for RSS and one for RAW_ETH.
+	 */
+	for (k = MLX4_QP_TABLE_ZONE_RSS + 1; k < sizeof(*bitmap)/sizeof((*bitmap)[0]);
+	     k++) {
+		int size;
+		u32 offset = start_offset_rss;
+		u32 bf_mask;
+		u32 requested_size;
+
+		/* Assuming MLX4_BF_QP_SKIP_MASK is consecutive ones, this calculates
+		 * a mask of all LSB bits set until (and not including) the first
+		 * set bit of  MLX4_BF_QP_SKIP_MASK. For example, if MLX4_BF_QP_SKIP_MASK
+		 * is 0xc0, bf_mask will be 0x3f.
+		 */
+		bf_mask = (MLX4_BF_QP_SKIP_MASK & ~(MLX4_BF_QP_SKIP_MASK - 1)) - 1;
+		requested_size = min((u32)MLX4_QP_TABLE_RAW_ETH_SIZE, bf_mask + 1);
+
+		if (((last_offset & MLX4_BF_QP_SKIP_MASK) &&
+		     ((int)(max_table_offset - last_offset)) >=
+		     roundup_pow_of_two(MLX4_BF_QP_SKIP_MASK)) ||
+		    (!(last_offset & MLX4_BF_QP_SKIP_MASK) &&
+		     !((last_offset + requested_size - 1) &
+		       MLX4_BF_QP_SKIP_MASK)))
+			size = requested_size;
+		else {
+			u32 candidate_offset =
+				(last_offset | MLX4_BF_QP_SKIP_MASK | bf_mask) + 1;
+
+			if (last_offset & MLX4_BF_QP_SKIP_MASK)
+				last_offset = candidate_offset;
+
+			/* From this point, the BF bits are 0 */
+
+			if (last_offset > max_table_offset) {
+				/* need to skip */
+				size = -1;
+			} else {
+				size = min3(max_table_offset - last_offset,
+					    bf_mask - (last_offset & bf_mask),
+					    requested_size);
+				if (size < requested_size) {
+					int candidate_size;
+
+					candidate_size = min3(
+						max_table_offset - candidate_offset,
+						bf_mask - (last_offset & bf_mask),
+						requested_size);
+
+					/*  We will not take this path if last_offset was
+					 *  already set above to candidate_offset
+					 */
+					if (candidate_size > size) {
+						last_offset = candidate_offset;
+						size = candidate_size;
+					}
+				}
+			}
+		}
+
+		if (size > 0) {
+			/* mlx4_bitmap_alloc_range will find a contiguous range of "size"
+			 * QPs in which both bits 6 and 7 are zero, because we pass it the
+			 * MLX4_BF_SKIP_MASK).
+			 */
+			offset = mlx4_bitmap_alloc_range(
+					*bitmap + MLX4_QP_TABLE_ZONE_RSS,
+					size, 1,
+					MLX4_BF_QP_SKIP_MASK);
+
+			if (offset == (u32)-1) {
+				err = -ENOMEM;
+				break;
+			}
+
+			last_offset = offset + size;
+
+			err = mlx4_bitmap_init(*bitmap + k, roundup_pow_of_two(size),
+					       roundup_pow_of_two(size) - 1, 0,
+					       roundup_pow_of_two(size) - size);
+		} else {
+			/* Add an empty bitmap, we'll allocate from different zones (since
+			 * at least one is reserved)
+			 */
+			err = mlx4_bitmap_init(*bitmap + k, 1,
+					       MLX4_QP_TABLE_RAW_ETH_SIZE - 1, 0,
+					       0);
+			mlx4_bitmap_alloc_range(*bitmap + k, 1, 1, 0);
+		}
+
+		if (err)
+			break;
+
+		++bitmap_initialized;
+
+		err = mlx4_zone_add_one(qp_table->zones, *bitmap + k,
+					MLX4_ZONE_ALLOW_ALLOC_FROM_LOWER_PRIO |
+					MLX4_ZONE_ALLOW_ALLOC_FROM_EQ_PRIO |
+					MLX4_ZONE_USE_RR, MLX4_QP_TABLE_RAW_ETH_PRIORITY,
+					offset, qp_table->zones_uids + k);
+
+		if (err)
+			break;
+	}
+
+	if (err)
+		goto free_bitmap;
+
+	qp_table->bitmap_gen = *bitmap;
+
+	return err;
+
+free_bitmap:
+	for (k = 0; k < bitmap_initialized; k++)
+		mlx4_bitmap_cleanup(*bitmap + k);
+	kfree(bitmap);
+free_zone:
+	mlx4_zone_allocator_destroy(qp_table->zones);
+	return err;
+}
+
+static void mlx4_cleanup_qp_zones(struct mlx4_dev *dev)
+{
+	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
+
+	if (qp_table->zones) {
+		int i;
+
+		for (i = 0;
+		     i < sizeof(qp_table->zones_uids)/sizeof(qp_table->zones_uids[0]);
+		     i++) {
+			struct mlx4_bitmap *bitmap =
+				mlx4_zone_get_bitmap(qp_table->zones,
+						     qp_table->zones_uids[i]);
+
+			mlx4_zone_remove_one(qp_table->zones, qp_table->zones_uids[i]);
+			if (NULL == bitmap)
+				continue;
+
+			mlx4_bitmap_cleanup(bitmap);
+		}
+		mlx4_zone_allocator_destroy(qp_table->zones);
+		kfree(qp_table->bitmap_gen);
+		qp_table->bitmap_gen = NULL;
+		qp_table->zones = NULL;
+	}
+}
+
 int mlx4_init_qp_table(struct mlx4_dev *dev)
 {
 	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
@@ -480,22 +710,33 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 	int reserved_from_top = 0;
 	int reserved_from_bot;
 	int k;
+	int fixed_reserved_from_bot_rv = 0;
+	int bottom_reserved_for_rss_bitmap;
+	u32 max_table_offset = dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW] +
+		MLX4_A0_STEERING_TABLE_SIZE;
 
 	spin_lock_init(&qp_table->lock);
 	INIT_RADIX_TREE(&dev->qp_table_tree, GFP_ATOMIC);
 	if (mlx4_is_slave(dev))
 		return 0;
 
-	/*
-	 * We reserve 2 extra QPs per port for the special QPs.  The
+	/* We reserve 2 extra QPs per port for the special QPs.  The
 	 * block of special QPs must be aligned to a multiple of 8, so
 	 * round up.
 	 *
 	 * We also reserve the MSB of the 24-bit QP number to indicate
 	 * that a QP is an XRC QP.
 	 */
-	dev->phys_caps.base_sqpn =
-		ALIGN(dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW], 8);
+	for (k = 0; k <= MLX4_QP_REGION_BOTTOM; k++)
+		fixed_reserved_from_bot_rv += dev->caps.reserved_qps_cnt[k];
+
+	if (fixed_reserved_from_bot_rv < max_table_offset)
+		fixed_reserved_from_bot_rv = max_table_offset;
+
+	/* We reserve at least 1 extra for bitmaps that we don't have enough space for*/
+	bottom_reserved_for_rss_bitmap =
+		roundup_pow_of_two(fixed_reserved_from_bot_rv + 1);
+	dev->phys_caps.base_sqpn = ALIGN(bottom_reserved_for_rss_bitmap, 8);
 
 	{
 		int sort[MLX4_NUM_QP_REGION];
@@ -505,8 +746,8 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 		for (i = 1; i < MLX4_NUM_QP_REGION; ++i)
 			sort[i] = i;
 
-		for (i = MLX4_NUM_QP_REGION; i > 0; --i) {
-			for (j = 2; j < i; ++j) {
+		for (i = MLX4_NUM_QP_REGION; i > MLX4_QP_REGION_BOTTOM; --i) {
+			for (j = MLX4_QP_REGION_BOTTOM + 2; j < i; ++j) {
 				if (dev->caps.reserved_qps_cnt[sort[j]] >
 				    dev->caps.reserved_qps_cnt[sort[j - 1]]) {
 					tmp             = sort[j];
@@ -516,13 +757,12 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 			}
 		}
 
-		for (i = 1; i < MLX4_NUM_QP_REGION; ++i) {
+		for (i = MLX4_QP_REGION_BOTTOM + 1; i < MLX4_NUM_QP_REGION; ++i) {
 			last_base -= dev->caps.reserved_qps_cnt[sort[i]];
 			dev->caps.reserved_qps_base[sort[i]] = last_base;
 			reserved_from_top +=
 				dev->caps.reserved_qps_cnt[sort[i]];
 		}
-
 	}
 
        /* Reserve 8 real SQPs in both native and SRIOV modes.
@@ -541,9 +781,11 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 		return -EINVAL;
 	}
 
-	err = mlx4_bitmap_init(&qp_table->bitmap, dev->caps.num_qps,
-			       (1 << 23) - 1, reserved_from_bot,
-			       reserved_from_top);
+	err = mlx4_create_zones(dev, reserved_from_bot, reserved_from_bot,
+				bottom_reserved_for_rss_bitmap,
+				fixed_reserved_from_bot_rv,
+				max_table_offset);
+
 	if (err)
 		return err;
 
@@ -579,7 +821,8 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 	err = mlx4_CONF_SPECIAL_QP(dev, dev->phys_caps.base_sqpn);
 	if (err)
 		goto err_mem;
-	return 0;
+
+	return err;
 
 err_mem:
 	kfree(dev->caps.qp0_tunnel);
@@ -588,6 +831,7 @@ err_mem:
 	kfree(dev->caps.qp1_proxy);
 	dev->caps.qp0_tunnel = dev->caps.qp0_proxy =
 		dev->caps.qp1_tunnel = dev->caps.qp1_proxy = NULL;
+	mlx4_cleanup_qp_zones(dev);
 	return err;
 }
 
@@ -597,7 +841,8 @@ void mlx4_cleanup_qp_table(struct mlx4_dev *dev)
 		return;
 
 	mlx4_CONF_SPECIAL_QP(dev, 0);
-	mlx4_bitmap_cleanup(&mlx4_priv(dev)->qp_table.bitmap);
+
+	mlx4_cleanup_qp_zones(dev);
 }
 
 int mlx4_qp_query(struct mlx4_dev *dev, struct mlx4_qp *qp,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 272aa25..39890cd 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -195,7 +195,8 @@ enum {
 };
 
 enum {
-	MLX4_QUERY_FUNC_FLAGS_BF_RES_QP		= 1LL << 0
+	MLX4_QUERY_FUNC_FLAGS_BF_RES_QP		= 1LL << 0,
+	MLX4_QUERY_FUNC_FLAGS_A0_RES_QP		= 1LL << 1
 };
 
 /* bit enums for an 8-bit flags field indicating special use
@@ -207,6 +208,7 @@ enum {
  * This enum may use only bits 0..7.
  */
 enum {
+	MLX4_RESERVE_A0_QP	= 1 << 6,
 	MLX4_RESERVE_ETH_BF_QP	= 1 << 7,
 };
 
@@ -349,6 +351,8 @@ enum {
 
 enum mlx4_qp_region {
 	MLX4_QP_REGION_FW = 0,
+	MLX4_QP_REGION_RSS_RAW_ETH,
+	MLX4_QP_REGION_BOTTOM = MLX4_QP_REGION_RSS_RAW_ETH,
 	MLX4_QP_REGION_ETH_ADDR,
 	MLX4_QP_REGION_FC_ADDR,
 	MLX4_QP_REGION_FC_EXCH,
@@ -891,7 +895,9 @@ static inline int mlx4_num_reserved_sqps(struct mlx4_dev *dev)
 static inline int mlx4_is_qp_reserved(struct mlx4_dev *dev, u32 qpn)
 {
 	return (qpn < dev->phys_caps.base_sqpn + 8 +
-		16 * MLX4_MFUNC_MAX * !!mlx4_is_master(dev));
+		16 * MLX4_MFUNC_MAX * !!mlx4_is_master(dev) &&
+		qpn >= dev->phys_caps.base_sqpn) ||
+	       (qpn < dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW]);
 }
 
 static inline int mlx4_is_guest_proxy(struct mlx4_dev *dev, int slave, u32 qpn)
-- 
1.7.1
