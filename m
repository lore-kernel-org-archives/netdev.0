From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 21/25] mlx4: Adding protocol fields to multicast group
Date: Wed, 04 Nov 2009 17:32:01 +0200
Message-ID: <4AF19E71.5080308@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The multicast attachment mechanism will be used both by
IB and Ethernet, so we need to specify for each multicast
address (whether it is gid or mac) its protocol.

Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/main.c |    6 +++-
 drivers/net/mlx4/mcg.c            |   41 +++++++++++++++++++++---------------
 include/linux/mlx4/device.h       |   12 +++++++++-
 3 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 3cb3f47..5b67a31 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -450,13 +450,15 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	return mlx4_multicast_attach(to_mdev(ibqp->device)->dev,
 				     &to_mqp(ibqp)->mqp, gid->raw,
 				     !!(to_mqp(ibqp)->flags &
-					MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK));
+					MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
+				     MLX4_PROT_IB_IPV6);
 }
 
 static int mlx4_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
 	return mlx4_multicast_detach(to_mdev(ibqp->device)->dev,
-				     &to_mqp(ibqp)->mqp, gid->raw);
+				     &to_mqp(ibqp)->mqp, gid->raw,
+				     MLX4_PROT_IB_IPV6);
 }
 
 static int init_node_data(struct mlx4_ib_dev *dev)
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index daa08f1..c4f928a 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -96,7 +96,8 @@ static int mlx4_MGID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
  * entry in hash chain and *mgm holds end of hash chain.
  */
 static int find_mgm(struct mlx4_dev *dev,
-		    u8 *gid, struct mlx4_cmd_mailbox *mgm_mailbox,
+		    u8 *gid, enum mlx4_protocol prot,
+		    struct mlx4_cmd_mailbox *mgm_mailbox,
 		    u16 *hash, int *prev, int *index)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -135,8 +136,9 @@ static int find_mgm(struct mlx4_dev *dev,
 			return err;
 		}
 
-		if (!memcmp(mgm->gid, gid, 16))
-			return err;
+		if (!memcmp(mgm->gid, gid, 16) &&
+				(prot == be32_to_cpu(mgm->members_count) >> 30))
+				return err;
 
 		*prev = *index;
 		*index = be32_to_cpu(mgm->next_gid_index) >> 6;
@@ -154,14 +156,17 @@ int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
 
 	qp.qpn = vhcr->in_modifier & 0xffffff;
 	if (vhcr->op_modifier)
-		return mlx4_multicast_attach(dev, &qp, inbox->buf, vhcr->in_modifier >> 31);
+		return mlx4_multicast_attach(dev, &qp, inbox->buf,
+					     vhcr->in_modifier >> 31,
+					     (vhcr->in_modifier >> 28) & 0x7);
 	else
-		return mlx4_multicast_detach(dev, &qp, inbox->buf);
+		return mlx4_multicast_detach(dev, &qp, inbox->buf,
+					     (vhcr->in_modifier >> 28) & 0x7);
 }
 
 static int mlx4_MCAST(struct mlx4_dev *dev, struct mlx4_qp *qp,
-					    u8 gid[16], u8 attach,
-					    u8 block_loopback)
+		      u8 gid[16], u8 attach, u8 block_loopback,
+		      enum mlx4_protocol prot)
 {
 	struct mlx4_cmd_mailbox *mailbox;
 	int err;
@@ -176,6 +181,7 @@ static int mlx4_MCAST(struct mlx4_dev *dev, struct mlx4_qp *qp,
 
 	memcpy(mailbox->buf, gid, 16);
 	qpn = qp->qpn;
+	qpn |= (prot << 28);
 	if (attach && block_loopback)
 		qpn |= (1 << 31);
 
@@ -186,7 +192,7 @@ static int mlx4_MCAST(struct mlx4_dev *dev, struct mlx4_qp *qp,
 }
 
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  int block_mcast_loopback)
+			  int block_mcast_loopback, enum mlx4_protocol prot)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_cmd_mailbox *mailbox;
@@ -199,7 +205,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	int err;
 
 	if (mlx4_is_slave(dev))
-		return mlx4_MCAST(dev, qp, gid, 1, block_mcast_loopback);
+		return mlx4_MCAST(dev, qp, gid, 1, block_mcast_loopback, prot);
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -208,7 +214,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	err = find_mgm(dev, gid, mailbox, &hash, &prev, &index);
+	err = find_mgm(dev, gid, prot, mailbox, &hash, &prev, &index);
 	if (err)
 		goto out;
 
@@ -230,7 +236,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		memcpy(mgm->gid, gid, 16);
 	}
 
-	members_count = be32_to_cpu(mgm->members_count);
+	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
 	if (members_count == MLX4_QP_PER_MGM) {
 		mlx4_err(dev, "MGM at index %x is full.\n", index);
 		err = -ENOMEM;
@@ -250,7 +256,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	else
 		mgm->qp[members_count++] = cpu_to_be32(qp->qpn & MGM_QPN_MASK);
 
-	mgm->members_count       = cpu_to_be32(members_count);
+	mgm->members_count       = cpu_to_be32(members_count | ((u32) prot << 30));
 
 	err = mlx4_WRITE_MCG(dev, index, mailbox);
 	if (err)
@@ -285,7 +291,8 @@ out:
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
 
-int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
+int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+						enum mlx4_protocol prot)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_cmd_mailbox *mailbox;
@@ -297,7 +304,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 	int err;
 
 	if (mlx4_is_slave(dev))
-		return mlx4_MCAST(dev, qp, gid, 0, 0);
+		return mlx4_MCAST(dev, qp, gid, 0, 0, prot);
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -306,7 +313,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	err = find_mgm(dev, gid, mailbox, &hash, &prev, &index);
+	err = find_mgm(dev, gid, prot, mailbox, &hash, &prev, &index);
 	if (err)
 		goto out;
 
@@ -316,7 +323,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 		goto out;
 	}
 
-	members_count = be32_to_cpu(mgm->members_count);
+	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
 	for (loc = -1, i = 0; i < members_count; ++i)
 		if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qp->qpn)
 			loc = i;
@@ -328,7 +335,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 	}
 
 
-	mgm->members_count = cpu_to_be32(--members_count);
+	mgm->members_count = cpu_to_be32(--members_count | ((u32) prot << 30));
 	mgm->qp[loc]       = mgm->qp[i - 1];
 	mgm->qp[i - 1]     = 0;
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 246b7bc..3d74198 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -171,6 +171,13 @@ enum mlx4_special_vlan_idx {
 	MLX4_VLAN_REGULAR
 };
 
+enum mlx4_protocol {
+	MLX4_PROT_IB_IPV6 = 0,
+	MLX4_PROT_ETH,
+	MLX4_PROT_IB_IPV4,
+	MLX4_PROT_FCOE
+};
+
 enum {
 	MLX4_NUM_FEXCH          = 64 * 1024,
 };
@@ -488,8 +495,9 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port);
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port);
 
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  int block_mcast_loopback);
-int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16]);
+			  int block_mcast_loopback, enum mlx4_protocol prot);
+int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  enum mlx4_protocol prot);
 
 int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
 void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn);
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
