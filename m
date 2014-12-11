From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 04/10] net/mlx4: Change QP allocation scheme
Date: Thu, 11 Dec 2014 10:57:54 +0200
Message-ID: <1418288280-334-5-git-send-email-ogerlitz@mellanox.com>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40485 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934168AbaLKI7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:59:02 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

When using BF (Blue-Flame), the QPN overrides the VLAN, CV, and SV fields
in the WQE. Thus, BF may only be used for QPNs with bits 6,7 unset.

The current Ethernet driver code reserves a Tx QP range with 256b alignment.

This is wrong because if there are more than 64 Tx QPs in use,
QPNs >= base + 65 will have bits 6/7 set.

This problem is not specific for the Ethernet driver, any entity that
tries to reserve more than 64 BF-enabled QPs should fail. Also, using
ranges is not necessary here and is wasteful.

The new mechanism introduced here will support reservation for
"Eth QPs eligible for BF" for all drivers: bare-metal, multi-PF, and VFs
(when hypervisors support WC in VMs). The flow we use is:

1. In mlx4_en, allocate Tx QPs one by one instead of a range allocation,
   and request "BF enabled QPs" if BF is supported for the function

2. In the ALLOC_RES FW command, change param1 to:
a. param1[23:0]  - number of QPs
b. param1[31-24] - flags controlling QPs reservation

Bit 31 refers to Eth blueflame supported QPs. Those QPs must have
bits 6 and 7 unset in order to be used in Ethernet.

Bits 24-30 of the flags are currently reserved.

When a function tries to allocate a QP, it states the required attributes
for this QP. Those attributes are considered "best-effort". If an attribute,
such as Ethernet BF enabled QP, is a must-have attribute, the function has
to check that attribute is supported before trying to do the allocation.

In a lower layer of the code, mlx4_qp_reserve_range masks out the bits
which are unsupported. If SRIOV is used, the PF validates those attributes
and masks out unsupported attributes as well. In order to notify VFs which
attributes are supported, the VF uses QUERY_FUNC_CAP command. This command's
mailbox is filled by the PF, which notifies which QP allocation attributes
it supports.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c                  |    2 +-
 drivers/infiniband/hw/mlx4/qp.c                    |   11 +++--
 drivers/net/ethernet/mellanox/mlx4/alloc.c         |   43 +++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   10 +----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   14 +++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   20 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c          |   11 +++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    5 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |   24 +++++++++--
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    7 +++-
 include/linux/mlx4/device.h                        |   21 +++++++++-
 14 files changed, 137 insertions(+), 38 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 0c33755..57ecc5b 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2227,7 +2227,7 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 		ibdev->steer_qpn_count = MLX4_IB_UC_MAX_NUM_QPS;
 		err = mlx4_qp_reserve_range(dev, ibdev->steer_qpn_count,
 					    MLX4_IB_UC_STEER_QPN_ALIGN,
-					    &ibdev->steer_qpn_base);
+					    &ibdev->steer_qpn_base, 0);
 		if (err)
 			goto err_counter;
 
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 9c5150c..506d1bd 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -802,16 +802,19 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 			}
 		}
 	} else {
-		/* Raw packet QPNs must be aligned to 8 bits. If not, the WQE
-		 * BlueFlame setup flow wrongly causes VLAN insertion. */
+		/* Raw packet QPNs may not have bits 6,7 set in their qp_num;
+		 * otherwise, the WQE BlueFlame setup flow wrongly causes
+		 * VLAN insertion. */
 		if (init_attr->qp_type == IB_QPT_RAW_PACKET)
-			err = mlx4_qp_reserve_range(dev->dev, 1, 1 << 8, &qpn);
+			err = mlx4_qp_reserve_range(dev->dev, 1, 1, &qpn,
+						    init_attr->cap.max_send_wr ?
+						    MLX4_RESERVE_ETH_BF_QP : 0);
 		else
 			if (qp->flags & MLX4_IB_QP_NETIF)
 				err = mlx4_ib_steer_qp_alloc(dev, 1, &qpn);
 			else
 				err = mlx4_qp_reserve_range(dev->dev, 1, 1,
-							    &qpn);
+							    &qpn, 0);
 		if (err)
 			goto err_proxy;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index b0297da..91a8acc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -76,22 +76,53 @@ void mlx4_bitmap_free(struct mlx4_bitmap *bitmap, u32 obj, int use_rr)
 	mlx4_bitmap_free_range(bitmap, obj, 1, use_rr);
 }
 
-u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align)
+static unsigned long find_aligned_range(unsigned long *bitmap,
+					u32 start, u32 nbits,
+					int len, int align, u32 skip_mask)
+{
+	unsigned long end, i;
+
+again:
+	start = ALIGN(start, align);
+
+	while ((start < nbits) && (test_bit(start, bitmap) ||
+				   (start & skip_mask)))
+		start += align;
+
+	if (start >= nbits)
+		return -1;
+
+	end = start+len;
+	if (end > nbits)
+		return -1;
+
+	for (i = start + 1; i < end; i++) {
+		if (test_bit(i, bitmap) || ((u32)i & skip_mask)) {
+			start = i + 1;
+			goto again;
+		}
+	}
+
+	return start;
+}
+
+u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt,
+			    int align, u32 skip_mask)
 {
 	u32 obj;
 
-	if (likely(cnt == 1 && align == 1))
+	if (likely(cnt == 1 && align == 1 && !skip_mask))
 		return mlx4_bitmap_alloc(bitmap);
 
 	spin_lock(&bitmap->lock);
 
-	obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
-				bitmap->last, cnt, align - 1);
+	obj = find_aligned_range(bitmap->table, bitmap->last,
+				 bitmap->max, cnt, align, skip_mask);
 	if (obj >= bitmap->max) {
 		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
 				& bitmap->mask;
-		obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
-						0, cnt, align - 1);
+		obj = find_aligned_range(bitmap->table, 0, bitmap->max,
+					 cnt, align, skip_mask);
 	}
 
 	if (obj < bitmap->max) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index dccf0e1..c67effb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -595,7 +595,7 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 		return 0;
 	}
 
-	err = mlx4_qp_reserve_range(dev, 1, 1, qpn);
+	err = mlx4_qp_reserve_range(dev, 1, 1, qpn, 0);
 	en_dbg(DRV, priv, "Reserved qp %d\n", *qpn);
 	if (err) {
 		en_err(priv, "Failed to reserve qp for mac registration\n");
@@ -1974,15 +1974,8 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_port_profile *prof = priv->prof;
 	int i;
-	int err;
 	int node;
 
-	err = mlx4_qp_reserve_range(priv->mdev->dev, priv->tx_ring_num, 256, &priv->base_tx_qpn);
-	if (err) {
-		en_err(priv, "failed reserving range for TX rings\n");
-		return err;
-	}
-
 	/* Create tx Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		node = cpu_to_node(i % num_online_cpus());
@@ -1991,7 +1984,6 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 			goto err;
 
 		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i],
-					   priv->base_tx_qpn + i,
 					   prof->tx_ring_size, TXBB_SIZE,
 					   node, i))
 			goto err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 69a2e1b..a850f24 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1131,7 +1131,7 @@ int mlx4_en_create_drop_qp(struct mlx4_en_priv *priv)
 	int err;
 	u32 qpn;
 
-	err = mlx4_qp_reserve_range(priv->mdev->dev, 1, 1, &qpn);
+	err = mlx4_qp_reserve_range(priv->mdev->dev, 1, 1, &qpn, 0);
 	if (err) {
 		en_err(priv, "Failed reserving drop qpn\n");
 		return err;
@@ -1174,7 +1174,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	en_dbg(DRV, priv, "Configuring rss steering\n");
 	err = mlx4_qp_reserve_range(mdev->dev, priv->rx_ring_num,
 				    priv->rx_ring_num,
-				    &rss_map->base_qpn);
+				    &rss_map->base_qpn, 0);
 	if (err) {
 		en_err(priv, "Failed reserving %d qps\n", priv->rx_ring_num);
 		return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index d0cecbd..a308d41 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -46,7 +46,7 @@
 #include "mlx4_en.h"
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
-			   struct mlx4_en_tx_ring **pring, int qpn, u32 size,
+			   struct mlx4_en_tx_ring **pring, u32 size,
 			   u16 stride, int node, int queue_index)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -112,11 +112,17 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	       ring, ring->buf, ring->size, ring->buf_size,
 	       (unsigned long long) ring->wqres.buf.direct.map);
 
-	ring->qpn = qpn;
+	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &ring->qpn,
+				    MLX4_RESERVE_ETH_BF_QP);
+	if (err) {
+		en_err(priv, "failed reserving qp for TX ring\n");
+		goto err_map;
+	}
+
 	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->qp, GFP_KERNEL);
 	if (err) {
 		en_err(priv, "Failed allocating qp %d\n", ring->qpn);
-		goto err_map;
+		goto err_reserve;
 	}
 	ring->qp.event = mlx4_en_sqp_event;
 
@@ -143,6 +149,8 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	*pring = ring;
 	return 0;
 
+err_reserve:
+	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
 err_map:
 	mlx4_en_unmap_buffer(&ring->wqres.buf);
 err_hwq_res:
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 5089f76..1469b5b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -266,10 +266,15 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_MTT_QUOTA_OFFSET		0x64
 #define QUERY_FUNC_CAP_MCG_QUOTA_OFFSET		0x68
 
+#define QUERY_FUNC_CAP_EXTRA_FLAGS_OFFSET	0x6c
+
 #define QUERY_FUNC_CAP_FMR_FLAG			0x80
 #define QUERY_FUNC_CAP_FLAG_RDMA		0x40
 #define QUERY_FUNC_CAP_FLAG_ETH			0x80
 #define QUERY_FUNC_CAP_FLAG_QUOTAS		0x10
+#define QUERY_FUNC_CAP_FLAG_VALID_MAILBOX	0x04
+
+#define QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG	(1UL << 31)
 
 /* when opcode modifier = 1 */
 #define QUERY_FUNC_CAP_PHYS_PORT_OFFSET		0x3
@@ -339,7 +344,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 			mlx4_get_active_ports(dev, slave);
 		/* enable rdma and ethernet interfaces, and new quota locations */
 		field = (QUERY_FUNC_CAP_FLAG_ETH | QUERY_FUNC_CAP_FLAG_RDMA |
-			 QUERY_FUNC_CAP_FLAG_QUOTAS);
+			 QUERY_FUNC_CAP_FLAG_QUOTAS | QUERY_FUNC_CAP_FLAG_VALID_MAILBOX);
 		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_FLAGS_OFFSET);
 
 		field = min(
@@ -401,6 +406,8 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MCG_QUOTA_OFFSET);
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MCG_QUOTA_OFFSET_DEP);
 
+		size = QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_EXTRA_FLAGS_OFFSET);
 	} else
 		err = -EINVAL;
 
@@ -493,6 +500,17 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 		MLX4_GET(size, outbox, QUERY_FUNC_CAP_RESERVED_EQ_OFFSET);
 		func_cap->reserved_eq = size & 0xFFFFFF;
 
+		func_cap->extra_flags = 0;
+
+		/* Mailbox data from 0x6c and onward should only be treated if
+		 * QUERY_FUNC_CAP_FLAG_VALID_MAILBOX is set in func_cap->flags
+		 */
+		if (func_cap->flags & QUERY_FUNC_CAP_FLAG_VALID_MAILBOX) {
+			MLX4_GET(size, outbox, QUERY_FUNC_CAP_EXTRA_FLAGS_OFFSET);
+			if (size & QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG)
+				func_cap->extra_flags |= MLX4_QUERY_FUNC_FLAGS_BF_RES_QP;
+		}
+
 		goto out;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 475215e..0e910a4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -144,6 +144,7 @@ struct mlx4_func_cap {
 	u8	port_flags;
 	u8	flags1;
 	u64	phys_port_id;
+	u32	extra_flags;
 };
 
 struct mlx4_func {
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 3044f9e..6a9a941 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -466,8 +466,13 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	    mlx4_is_master(dev))
 		dev->caps.function_caps |= MLX4_FUNC_CAP_64B_EQE_CQE;
 
-	if (!mlx4_is_slave(dev))
+	if (!mlx4_is_slave(dev)) {
 		mlx4_enable_cqe_eqe_stride(dev);
+		dev->caps.alloc_res_qp_mask =
+			(dev->caps.bf_reg_size ? MLX4_RESERVE_ETH_BF_QP : 0);
+	} else {
+		dev->caps.alloc_res_qp_mask = 0;
+	}
 
 	return 0;
 }
@@ -817,6 +822,10 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 
 	slave_adjust_steering_mode(dev, &dev_cap, &hca_param);
 
+	if (func_cap.extra_flags & MLX4_QUERY_FUNC_FLAGS_BF_RES_QP &&
+	    dev->caps.bf_reg_size)
+		dev->caps.alloc_res_qp_mask |= MLX4_RESERVE_ETH_BF_QP;
+
 	return 0;
 
 err_mem:
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index b67ef48..6834da6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -884,7 +884,8 @@ extern struct workqueue_struct *mlx4_wq;
 
 u32 mlx4_bitmap_alloc(struct mlx4_bitmap *bitmap);
 void mlx4_bitmap_free(struct mlx4_bitmap *bitmap, u32 obj, int use_rr);
-u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align);
+u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt,
+			    int align, u32 skip_mask);
 void mlx4_bitmap_free_range(struct mlx4_bitmap *bitmap, u32 obj, int cnt,
 			    int use_rr);
 u32 mlx4_bitmap_avail(struct mlx4_bitmap *bitmap);
@@ -970,7 +971,7 @@ int mlx4_DMA_wrapper(struct mlx4_dev *dev, int slave,
 		     struct mlx4_cmd_mailbox *outbox,
 		     struct mlx4_cmd_info *cmd);
 int __mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align,
-			    int *base);
+			    int *base, u8 flags);
 void __mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt);
 int __mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac);
 void __mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index ac48a8d..944a112 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -778,7 +778,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_tx_ring **pring,
-			   int qpn, u32 size, u16 stride,
+			   u32 size, u16 stride,
 			   int node, int queue_index);
 void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring **pring);
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 2301365..40e82ed 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -42,6 +42,10 @@
 #include "mlx4.h"
 #include "icm.h"
 
+/* QP to support BF should have bits 6,7 cleared */
+#define MLX4_BF_QP_SKIP_MASK	0xc0
+#define MLX4_MAX_BF_QP_RANGE	0x40
+
 void mlx4_qp_event(struct mlx4_dev *dev, u32 qpn, int event_type)
 {
 	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
@@ -207,26 +211,36 @@ int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 EXPORT_SYMBOL_GPL(mlx4_qp_modify);
 
 int __mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align,
-				   int *base)
+			    int *base, u8 flags)
 {
+	int bf_qp = !!(flags & (u8)MLX4_RESERVE_ETH_BF_QP);
+
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
 
-	*base = mlx4_bitmap_alloc_range(&qp_table->bitmap, cnt, align);
+	if (cnt > MLX4_MAX_BF_QP_RANGE && bf_qp)
+		return -ENOMEM;
+
+	*base = mlx4_bitmap_alloc_range(&qp_table->bitmap, cnt, align,
+					bf_qp ? MLX4_BF_QP_SKIP_MASK : 0);
 	if (*base == -1)
 		return -ENOMEM;
 
 	return 0;
 }
 
-int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align, int *base)
+int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align,
+			  int *base, u8 flags)
 {
 	u64 in_param = 0;
 	u64 out_param;
 	int err;
 
+	/* Turn off all unsupported QP allocation flags */
+	flags &= dev->caps.alloc_res_qp_mask;
+
 	if (mlx4_is_mfunc(dev)) {
-		set_param_l(&in_param, cnt);
+		set_param_l(&in_param, (((u32)flags) << 24) | (u32)cnt);
 		set_param_h(&in_param, align);
 		err = mlx4_cmd_imm(dev, in_param, &out_param,
 				   RES_QP, RES_OP_RESERVE,
@@ -238,7 +252,7 @@ int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align, int *base)
 		*base = get_param_l(&out_param);
 		return 0;
 	}
-	return __mlx4_qp_reserve_range(dev, cnt, align, base);
+	return __mlx4_qp_reserve_range(dev, cnt, align, base, flags);
 }
 EXPORT_SYMBOL_GPL(mlx4_qp_reserve_range);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 16f617b..4efbd1e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1543,16 +1543,21 @@ static int qp_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	int align;
 	int base;
 	int qpn;
+	u8 flags;
 
 	switch (op) {
 	case RES_OP_RESERVE:
 		count = get_param_l(&in_param) & 0xffffff;
+		/* Turn off all unsupported QP allocation flags that the
+		 * slave tries to set.
+		 */
+		flags = (get_param_l(&in_param) >> 24) & dev->caps.alloc_res_qp_mask;
 		align = get_param_h(&in_param);
 		err = mlx4_grant_resource(dev, slave, RES_QP, count, 0);
 		if (err)
 			return err;
 
-		err = __mlx4_qp_reserve_range(dev, count, align, &base);
+		err = __mlx4_qp_reserve_range(dev, count, align, &base, flags);
 		if (err) {
 			mlx4_release_resource(dev, slave, RES_QP, count, 0);
 			return err;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 3951b53..272aa25 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -195,6 +195,22 @@ enum {
 };
 
 enum {
+	MLX4_QUERY_FUNC_FLAGS_BF_RES_QP		= 1LL << 0
+};
+
+/* bit enums for an 8-bit flags field indicating special use
+ * QPs which require special handling in qp_reserve_range.
+ * Currently, this only includes QPs used by the ETH interface,
+ * where we expect to use blueflame.  These QPs must not have
+ * bits 6 and 7 set in their qp number.
+ *
+ * This enum may use only bits 0..7.
+ */
+enum {
+	MLX4_RESERVE_ETH_BF_QP	= 1 << 7,
+};
+
+enum {
 	MLX4_DEV_CAP_64B_EQE_ENABLED	= 1LL << 0,
 	MLX4_DEV_CAP_64B_CQE_ENABLED	= 1LL << 1,
 	MLX4_DEV_CAP_CQE_STRIDE_ENABLED	= 1LL << 2,
@@ -501,6 +517,7 @@ struct mlx4_caps {
 	u64			phys_port_id[MLX4_MAX_PORTS + 1];
 	int			tunnel_offload_mode;
 	u8			rx_checksum_flags_port[MLX4_MAX_PORTS + 1];
+	u8			alloc_res_qp_mask;
 };
 
 struct mlx4_buf_list {
@@ -950,8 +967,8 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 		  struct mlx4_uar *uar, u64 db_rec, struct mlx4_cq *cq,
 		  unsigned vector, int collapsed, int timestamp_en);
 void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq);
-
-int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align, int *base);
+int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align,
+			  int *base, u8 flags);
 void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt);
 
 int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp,
-- 
1.7.1
