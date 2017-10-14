From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 08/12] net/mlx5e: IPoIB, Use hash-table to map between QPN to child netdev
Date: Sat, 14 Oct 2017 11:48:23 -0700
Message-ID: <20171014184827.18491-9-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171014184827.18491-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

This change is needed for PKEY support, since the RQs are shared
between the child interface and the parent. The parent is responsible
for NAPI and the precessing of RX completions. Using the dqpn in the
completion descriptor we set the corresponding child IPoIB netdevice
on the SKB.
The mapping between the dqpn and the netdevice is done using a HT,
each mlx5 IPoIB interface registers its mapping on creation.

Signed-off-by: Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  20 ++-
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  |  16 +++
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h  |  12 ++
 .../ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c | 136 +++++++++++++++++++++
 5 files changed, 184 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index d9621b2152d3..100fe4ecad9b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -22,7 +22,7 @@ mlx5_core-$(CONFIG_MLX5_ESWITCH) += eswitch.o eswitch_offloads.o en_rep.o en_tc.
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
-mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib/ipoib.o ipoib/ethtool.o
+mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib/ipoib.o ipoib/ethtool.o ipoib/ipoib_vlan.o
 
 mlx5_core-$(CONFIG_MLX5_EN_IPSEC) += en_accel/ipsec.o en_accel/ipsec_rxtx.o \
 		en_accel/ipsec_stats.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 7e3bfe62ef6e..2c3f2e9b6983 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -1163,11 +1163,25 @@ static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 					 u32 cqe_bcnt,
 					 struct sk_buff *skb)
 {
-	struct net_device *netdev = rq->netdev;
+	struct net_device *netdev;
 	char *pseudo_header;
+	u32 qpn;
 	u8 *dgid;
 	u8 g;
 
+	qpn = be32_to_cpu(cqe->sop_drop_qpn) & 0xffffff;
+	netdev = mlx5i_pkey_get_netdev(rq->netdev, qpn);
+
+	/* No mapping present, cannot process SKB. This might happen if a child
+	 * interface is going down while having unprocessed CQEs on parent RQ
+	 */
+	if (unlikely(!netdev)) {
+		/* TODO: add drop counters support */
+		skb->dev = NULL;
+		pr_warn_once("Unable to map QPN %u to dev - dropping skb\n", qpn);
+		return;
+	}
+
 	g = (be32_to_cpu(cqe->flags_rqpn) >> 28) & 3;
 	dgid = skb->data + MLX5_IB_GRH_DGID_OFFSET;
 	if ((!g) || dgid[0] != 0xff)
@@ -1230,6 +1244,10 @@ void mlx5i_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		goto wq_free_wqe;
 
 	mlx5i_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+	if (unlikely(!skb->dev)) {
+		dev_kfree_skb_any(skb);
+		goto wq_free_wqe;
+	}
 	napi_gro_receive(rq->cq.napi, skb);
 
 wq_free_wqe:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 679c1f9af642..c479fe54a6ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -382,6 +382,9 @@ static int mlx5i_dev_init(struct net_device *dev)
 	dev->dev_addr[2] = (ipriv->qp.qpn >>  8) & 0xff;
 	dev->dev_addr[3] = (ipriv->qp.qpn) & 0xff;
 
+	/* Add QPN to net-device mapping to HT */
+	mlx5i_pkey_add_qpn(dev ,ipriv->qp.qpn);
+
 	return 0;
 }
 
@@ -402,8 +405,12 @@ static int mlx5i_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static void mlx5i_dev_cleanup(struct net_device *dev)
 {
 	struct mlx5e_priv    *priv   = mlx5i_epriv(dev);
+	struct mlx5i_priv    *ipriv = priv->ppriv;
 
 	mlx5i_uninit_underlay_qp(priv);
+
+	/* Delete QPN to net-device mapping from HT */
+	mlx5i_pkey_del_qpn(dev, ipriv->qp.qpn);
 }
 
 static int mlx5i_open(struct net_device *netdev)
@@ -590,6 +597,12 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 	if (!epriv->wq)
 		goto err_free_netdev;
 
+	err = mlx5i_pkey_qpn_ht_init(netdev);
+	if (err) {
+		mlx5_core_warn(mdev, "allocate qpn_to_netdev ht failed\n");
+		goto destroy_wq;
+	}
+
 	profile->init(mdev, netdev, profile, ipriv);
 
 	mlx5e_attach_netdev(epriv);
@@ -605,6 +618,8 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 
 	return netdev;
 
+destroy_wq:
+	destroy_workqueue(epriv->wq);
 err_free_netdev:
 	free_netdev(netdev);
 free_mdev_resources:
@@ -623,6 +638,7 @@ void mlx5_rdma_netdev_free(struct net_device *netdev)
 	mlx5e_detach_netdev(priv);
 	profile->cleanup(priv);
 	destroy_workqueue(priv->wq);
+	mlx5i_pkey_qpn_ht_cleanup(netdev);
 	free_netdev(netdev);
 
 	mlx5e_destroy_mdev_resources(mdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
index 9a729883c3b3..e313f6d90729 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
@@ -51,9 +51,21 @@ struct mlx5i_priv {
 	struct mlx5_core_qp qp;
 	u32    qkey;
 	u16    pkey_index;
+	struct mlx5i_pkey_qpn_ht *qpn_htbl;
 	char  *mlx5e_priv[0];
 };
 
+/* Allocate/Free underlay QPN to net-device hash table */
+int mlx5i_pkey_qpn_ht_init(struct net_device *netdev);
+void mlx5i_pkey_qpn_ht_cleanup(struct net_device *netdev);
+
+/* Add/Remove an underlay QPN to net-device mapping to/from the hash table */
+int mlx5i_pkey_add_qpn(struct net_device *netdev, u32 qpn);
+int mlx5i_pkey_del_qpn(struct net_device *netdev, u32 qpn);
+
+/* Get the net-device corresponding to the given underlay QPN */
+struct net_device *mlx5i_pkey_get_netdev(struct net_device *netdev, u32 qpn);
+
 /* Extract mlx5e_priv from IPoIB netdev */
 #define mlx5i_epriv(netdev) ((void *)(((struct mlx5i_priv *)netdev_priv(netdev))->mlx5e_priv))
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
new file mode 100644
index 000000000000..e4d39aa1f552
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
@@ -0,0 +1,136 @@
+/*
+ * Copyright (c) 2017, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/hash.h>
+#include "ipoib.h"
+
+#define MLX5I_MAX_LOG_PKEY_SUP 7
+
+struct qpn_to_netdev {
+	struct net_device *netdev;
+	struct hlist_node hlist;
+	u32 underlay_qpn;
+};
+
+struct mlx5i_pkey_qpn_ht {
+	struct hlist_head buckets[1 << MLX5I_MAX_LOG_PKEY_SUP];
+	spinlock_t ht_lock; /* Synchronise with NAPI */
+};
+
+int mlx5i_pkey_qpn_ht_init(struct net_device *netdev)
+{
+	struct mlx5i_priv *ipriv = netdev_priv(netdev);
+	struct mlx5i_pkey_qpn_ht *qpn_htbl;
+
+	qpn_htbl = kzalloc(sizeof(*qpn_htbl), GFP_KERNEL);
+	if (!qpn_htbl)
+		return -ENOMEM;
+
+	ipriv->qpn_htbl = qpn_htbl;
+	spin_lock_init(&qpn_htbl->ht_lock);
+
+	return 0;
+}
+
+void mlx5i_pkey_qpn_ht_cleanup(struct net_device *netdev)
+{
+	struct mlx5i_priv *ipriv = netdev_priv(netdev);
+
+	kfree(ipriv->qpn_htbl);
+}
+
+static struct qpn_to_netdev *mlx5i_find_qpn_to_netdev_node(struct hlist_head *buckets,
+							   u32 qpn)
+{
+	struct hlist_head *h = &buckets[hash_32(qpn, MLX5I_MAX_LOG_PKEY_SUP)];
+	struct qpn_to_netdev *node;
+
+	hlist_for_each_entry(node, h, hlist) {
+		if (node->underlay_qpn == qpn)
+			return node;
+	}
+
+	return NULL;
+}
+
+int mlx5i_pkey_add_qpn(struct net_device *netdev, u32 qpn)
+{
+	struct mlx5i_priv *ipriv = netdev_priv(netdev);
+	struct mlx5i_pkey_qpn_ht *ht = ipriv->qpn_htbl;
+	u8 key = hash_32(qpn, MLX5I_MAX_LOG_PKEY_SUP);
+	struct qpn_to_netdev *new_node;
+
+	new_node = kzalloc(sizeof(*new_node), GFP_KERNEL);
+	if (!new_node)
+		return -ENOMEM;
+
+	new_node->netdev = netdev;
+	new_node->underlay_qpn = qpn;
+	spin_lock_bh(&ht->ht_lock);
+	hlist_add_head(&new_node->hlist, &ht->buckets[key]);
+	spin_unlock_bh(&ht->ht_lock);
+
+	return 0;
+}
+
+int mlx5i_pkey_del_qpn(struct net_device *netdev, u32 qpn)
+{
+	struct mlx5e_priv *epriv = mlx5i_epriv(netdev);
+	struct mlx5i_priv *ipriv = epriv->ppriv;
+	struct mlx5i_pkey_qpn_ht *ht = ipriv->qpn_htbl;
+	struct qpn_to_netdev *node;
+
+	node = mlx5i_find_qpn_to_netdev_node(ht->buckets, qpn);
+	if (!node) {
+		mlx5_core_warn(epriv->mdev, "QPN to netdev delete from HT failed\n");
+		return -EINVAL;
+	}
+
+	spin_lock_bh(&ht->ht_lock);
+	hlist_del_init(&node->hlist);
+	spin_unlock_bh(&ht->ht_lock);
+	kfree(node);
+
+	return 0;
+}
+
+struct net_device *mlx5i_pkey_get_netdev(struct net_device *netdev, u32 qpn)
+{
+	struct mlx5i_priv *ipriv = netdev_priv(netdev);
+	struct qpn_to_netdev *node;
+
+	node = mlx5i_find_qpn_to_netdev_node(ipriv->qpn_htbl->buckets, qpn);
+	if (!node)
+		return NULL;
+
+	return node->netdev;
+}
-- 
2.14.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
