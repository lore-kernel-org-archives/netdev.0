From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 09/16] mlx4: generalization of multicast steering.
Date: Wed, 23 Mar 2011 10:38:17 +0200
Message-ID: <4D89B179.6050903@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:35759 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755619Ab1CWIiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The same packet steering mechanism would be used both for IB and Ethernet,
Both multicasts and unicasts.
This commit prepares the general infrastructure for this.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/infiniband/hw/mlx4/main.c |   10 ++--
 drivers/net/mlx4/en_main.c        |    2 +-
 drivers/net/mlx4/fw.c             |    2 +
 drivers/net/mlx4/fw.h             |    2 +
 drivers/net/mlx4/main.c           |    2 +
 drivers/net/mlx4/mcg.c            |  113 +++++++++++++++++++++++++-----------
 include/linux/mlx4/device.h       |   14 ++++-
 7 files changed, 102 insertions(+), 43 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 66e3eec..fbe1973 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -625,7 +625,7 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 
 	err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw,
 				    !!(mqp->flags & MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
-				    MLX4_PROTOCOL_IB);
+				    MLX4_PROT_IB_IPV6);
 	if (err)
 		return err;
 
@@ -636,7 +636,7 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	return 0;
 
 err_add:
-	mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw, MLX4_PROTOCOL_IB);
+	mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw, MLX4_PROT_IB_IPV6);
 	return err;
 }
 
@@ -666,7 +666,7 @@ static int mlx4_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	struct mlx4_ib_gid_entry *ge;
 
 	err = mlx4_multicast_detach(mdev->dev,
-				    &mqp->mqp, gid->raw, MLX4_PROTOCOL_IB);
+				    &mqp->mqp, gid->raw, MLX4_PROT_IB_IPV6);
 	if (err)
 		return err;
 
@@ -953,7 +953,7 @@ static int mlx4_ib_netdev_event(struct notifier_block *this, unsigned long event
 	mlx4_foreach_ib_transport_port(port, ibdev->dev) {
 		oldnd = iboe->netdevs[port - 1];
 		iboe->netdevs[port - 1] =
-			mlx4_get_protocol_dev(ibdev->dev, MLX4_PROTOCOL_EN, port);
+			mlx4_get_protocol_dev(ibdev->dev, MLX4_PROT_ETH, port);
 		if (oldnd != iboe->netdevs[port - 1]) {
 			if (iboe->netdevs[port - 1])
 				netdev_added(ibdev, port);
@@ -1206,7 +1206,7 @@ static struct mlx4_interface mlx4_ib_interface = {
 	.add		= mlx4_ib_add,
 	.remove		= mlx4_ib_remove,
 	.event		= mlx4_ib_event,
-	.protocol	= MLX4_PROTOCOL_IB
+	.protocol	= MLX4_PROT_IB_IPV6
 };
 
 static int __init mlx4_ib_init(void)
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 29aaa43..9317b61 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -296,7 +296,7 @@ static struct mlx4_interface mlx4_en_interface = {
 	.remove		= mlx4_en_remove,
 	.event		= mlx4_en_event,
 	.get_dev	= mlx4_en_get_netdev,
-	.protocol	= MLX4_PROTOCOL_EN,
+	.protocol	= MLX4_PROT_ETH,
 };
 
 static int __init mlx4_en_init(void)
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index fd1c51b..7813913 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -274,6 +274,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->stat_rate_support = stat_rate;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_UDP_RSS_OFFSET);
 	dev_cap->udp_rss = field & 0x1;
+	dev_cap->vep_uc_steering = field & 0x2;
+	dev_cap->vep_mc_steering = field & 0x4;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET);
 	dev_cap->loopback_support = field & 0x1;
 	dev_cap->wol = field & 0x40;
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index f7b9cc2..88003eb 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -80,6 +80,8 @@ struct mlx4_dev_cap {
 	u16 stat_rate_support;
 	int udp_rss;
 	int loopback_support;
+	int vep_uc_steering;
+	int vep_mc_steering;
 	int wol;
 	u32 flags;
 	int reserved_uars;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 5bebb88..da0da28 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -227,6 +227,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
 	dev->caps.udp_rss	     = dev_cap->udp_rss;
 	dev->caps.loopback_support   = dev_cap->loopback_support;
+	dev->caps.vep_uc_steering    = dev_cap->vep_uc_steering;
+	dev->caps.vep_mc_steering    = dev_cap->vep_mc_steering;
 	dev->caps.wol		     = dev_cap->wol;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index 79cf42d..b103ad2 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/string.h>
+#include <linux/etherdevice.h>
 
 #include <linux/mlx4/cmd.h>
 
@@ -50,28 +51,28 @@ struct mlx4_mgm {
 
 static const u8 zero_gid[16];	/* automatically initialized to 0 */
 
-static int mlx4_READ_MCG(struct mlx4_dev *dev, int index,
-			 struct mlx4_cmd_mailbox *mailbox)
+static int mlx4_READ_ENTRY(struct mlx4_dev *dev, int index,
+			   struct mlx4_cmd_mailbox *mailbox)
 {
 	return mlx4_cmd_box(dev, 0, mailbox->dma, index, 0, MLX4_CMD_READ_MCG,
 			    MLX4_CMD_TIME_CLASS_A);
 }
 
-static int mlx4_WRITE_MCG(struct mlx4_dev *dev, int index,
-			  struct mlx4_cmd_mailbox *mailbox)
+static int mlx4_WRITE_ENTRY(struct mlx4_dev *dev, int index,
+			    struct mlx4_cmd_mailbox *mailbox)
 {
 	return mlx4_cmd(dev, mailbox->dma, index, 0, MLX4_CMD_WRITE_MCG,
 			MLX4_CMD_TIME_CLASS_A);
 }
 
-static int mlx4_MGID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
-			  u16 *hash)
+static int mlx4_GID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
+			 u16 *hash, u8 op_mod)
 {
 	u64 imm;
 	int err;
 
-	err = mlx4_cmd_imm(dev, mailbox->dma, &imm, 0, 0, MLX4_CMD_MGID_HASH,
-			   MLX4_CMD_TIME_CLASS_A);
+	err = mlx4_cmd_imm(dev, mailbox->dma, &imm, 0, op_mod,
+			   MLX4_CMD_MGID_HASH, MLX4_CMD_TIME_CLASS_A);
 
 	if (!err)
 		*hash = imm;
@@ -94,15 +95,17 @@ static int mlx4_MGID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
  * If no AMGM exists for given gid, *index = -1, *prev = index of last
  * entry in hash chain and *mgm holds end of hash chain.
  */
-static int find_mgm(struct mlx4_dev *dev,
-		    u8 *gid, enum mlx4_protocol protocol,
-		    struct mlx4_cmd_mailbox *mgm_mailbox,
-		    u16 *hash, int *prev, int *index)
+static int find_entry(struct mlx4_dev *dev, u8 port,
+		      u8 *gid, enum mlx4_protocol prot,
+		      enum mlx4_steer_type steer,
+		      struct mlx4_cmd_mailbox *mgm_mailbox,
+		      u16 *hash, int *prev, int *index)
 {
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mgm *mgm = mgm_mailbox->buf;
 	u8 *mgid;
 	int err;
+	u8 op_mod = (prot == MLX4_PROT_ETH) ? !!(dev->caps.vep_mc_steering) : 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -111,7 +114,7 @@ static int find_mgm(struct mlx4_dev *dev,
 
 	memcpy(mgid, gid, 16);
 
-	err = mlx4_MGID_HASH(dev, mailbox, hash);
+	err = mlx4_GID_HASH(dev, mailbox, hash, op_mod);
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	if (err)
 		return err;
@@ -123,11 +126,11 @@ static int find_mgm(struct mlx4_dev *dev,
 	*prev  = -1;
 
 	do {
-		err = mlx4_READ_MCG(dev, *index, mgm_mailbox);
+		err = mlx4_READ_ENTRY(dev, *index, mgm_mailbox);
 		if (err)
 			return err;
 
-		if (!memcmp(mgm->gid, zero_gid, 16)) {
+		if (!(be32_to_cpu(mgm->members_count) & 0xffffff)) {
 			if (*index != *hash) {
 				mlx4_err(dev, "Found zero MGID in AMGM.\n");
 				err = -EINVAL;
@@ -136,7 +139,7 @@ static int find_mgm(struct mlx4_dev *dev,
 		}
 
 		if (!memcmp(mgm->gid, gid, 16) &&
-		    be32_to_cpu(mgm->members_count) >> 30 == protocol)
+		    be32_to_cpu(mgm->members_count) >> 30 == prot)
 			return err;
 
 		*prev = *index;
@@ -147,8 +150,9 @@ static int find_mgm(struct mlx4_dev *dev,
 	return err;
 }
 
-int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  int block_mcast_loopback, enum mlx4_protocol protocol)
+int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  int block_mcast_loopback, enum mlx4_protocol prot,
+			  enum mlx4_steer_type steer)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_cmd_mailbox *mailbox;
@@ -159,6 +163,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	int link = 0;
 	int i;
 	int err;
+	u8 port = gid[5];
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -166,13 +171,13 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	mgm = mailbox->buf;
 
 	mutex_lock(&priv->mcg_table.mutex);
-
-	err = find_mgm(dev, gid, protocol, mailbox, &hash, &prev, &index);
+	err = find_entry(dev, port, gid, prot, steer,
+			 mailbox, &hash, &prev, &index);
 	if (err)
 		goto out;
 
 	if (index != -1) {
-		if (!memcmp(mgm->gid, zero_gid, 16))
+		if (!(be32_to_cpu(mgm->members_count) & 0xffffff))
 			memcpy(mgm->gid, gid, 16);
 	} else {
 		link = 1;
@@ -209,22 +214,22 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	else
 		mgm->qp[members_count++] = cpu_to_be32(qp->qpn & MGM_QPN_MASK);
 
-	mgm->members_count = cpu_to_be32(members_count | (u32) protocol << 30);
+	mgm->members_count = cpu_to_be32(members_count | (u32) prot << 30);
 
-	err = mlx4_WRITE_MCG(dev, index, mailbox);
+	err = mlx4_WRITE_ENTRY(dev, index, mailbox);
 	if (err)
 		goto out;
 
 	if (!link)
 		goto out;
 
-	err = mlx4_READ_MCG(dev, prev, mailbox);
+	err = mlx4_READ_ENTRY(dev, prev, mailbox);
 	if (err)
 		goto out;
 
 	mgm->next_gid_index = cpu_to_be32(index << 6);
 
-	err = mlx4_WRITE_MCG(dev, prev, mailbox);
+	err = mlx4_WRITE_ENTRY(dev, prev, mailbox);
 	if (err)
 		goto out;
 
@@ -242,10 +247,9 @@ out:
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
-EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
 
-int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  enum mlx4_protocol protocol)
+int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  enum mlx4_protocol prot, enum mlx4_steer_type steer)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_cmd_mailbox *mailbox;
@@ -255,6 +259,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	int prev, index;
 	int i, loc;
 	int err;
+	u8 port = gid[5];
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -263,7 +268,8 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	err = find_mgm(dev, gid, protocol, mailbox, &hash, &prev, &index);
+	err = find_entry(dev, port, gid, prot, steer,
+			 mailbox, &hash, &prev, &index);
 	if (err)
 		goto out;
 
@@ -285,12 +291,12 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	}
 
 
-	mgm->members_count = cpu_to_be32(--members_count | (u32) protocol << 30);
+	mgm->members_count = cpu_to_be32(--members_count | (u32) prot << 30);
 	mgm->qp[loc]       = mgm->qp[i - 1];
 	mgm->qp[i - 1]     = 0;
 
 	if (i != 1) {
-		err = mlx4_WRITE_MCG(dev, index, mailbox);
+		err = mlx4_WRITE_ENTRY(dev, index, mailbox);
 		goto out;
 	}
 
@@ -298,13 +304,13 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		/* Remove entry from MGM */
 		int amgm_index = be32_to_cpu(mgm->next_gid_index) >> 6;
 		if (amgm_index) {
-			err = mlx4_READ_MCG(dev, amgm_index, mailbox);
+			err = mlx4_READ_ENTRY(dev, amgm_index, mailbox);
 			if (err)
 				goto out;
 		} else
 			memset(mgm->gid, 0, 16);
 
-		err = mlx4_WRITE_MCG(dev, index, mailbox);
+		err = mlx4_WRITE_ENTRY(dev, index, mailbox);
 		if (err)
 			goto out;
 
@@ -319,13 +325,13 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	} else {
 		/* Remove entry from AMGM */
 		int cur_next_index = be32_to_cpu(mgm->next_gid_index) >> 6;
-		err = mlx4_READ_MCG(dev, prev, mailbox);
+		err = mlx4_READ_ENTRY(dev, prev, mailbox);
 		if (err)
 			goto out;
 
 		mgm->next_gid_index = cpu_to_be32(cur_next_index << 6);
 
-		err = mlx4_WRITE_MCG(dev, prev, mailbox);
+		err = mlx4_WRITE_ENTRY(dev, prev, mailbox);
 		if (err)
 			goto out;
 
@@ -343,6 +349,43 @@ out:
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
+
+
+int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  int block_mcast_loopback, enum mlx4_protocol prot)
+{
+	enum mlx4_steer_type steer;
+
+	steer = (is_valid_ether_addr(&gid[10])) ? MLX4_UC_STEER : MLX4_MC_STEER;
+
+	if (prot == MLX4_PROT_ETH && !dev->caps.vep_mc_steering)
+		return 0;
+
+	if (prot == MLX4_PROT_ETH)
+		gid[7] |= (steer << 1);
+
+	return mlx4_qp_attach_common(dev, qp, gid,
+				     block_mcast_loopback, prot,
+				     steer);
+}
+EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
+
+int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  enum mlx4_protocol prot)
+{
+	enum mlx4_steer_type steer;
+
+	steer = (is_valid_ether_addr(&gid[10])) ? MLX4_UC_STEER : MLX4_MC_STEER;
+
+	if (prot == MLX4_PROT_ETH && !dev->caps.vep_mc_steering)
+		return 0;
+
+	if (prot == MLX4_PROT_ETH) {
+		gid[7] |= (steer << 1);
+	}
+
+	return mlx4_qp_detach_common(dev, qp, gid, prot, steer);
+}
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
 int mlx4_init_mcg_table(struct mlx4_dev *dev)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index fe2a3a3..ebda939 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -150,8 +150,10 @@ enum {
 };
 
 enum mlx4_protocol {
-	MLX4_PROTOCOL_IB,
-	MLX4_PROTOCOL_EN,
+	MLX4_PROT_IB_IPV6 = 0,
+	MLX4_PROT_ETH,
+	MLX4_PROT_IB_IPV4,
+	MLX4_PROT_FCOE
 };
 
 enum {
@@ -178,6 +180,12 @@ enum mlx4_special_vlan_idx {
 	MLX4_VLAN_REGULAR
 };
 
+enum mlx4_steer_type {
+	MLX4_MC_STEER = 0,
+	MLX4_UC_STEER,
+	MLX4_NUM_STEERS
+};
+
 enum {
 	MLX4_NUM_FEXCH          = 64 * 1024,
 };
@@ -251,6 +259,8 @@ struct mlx4_caps {
 	u16			stat_rate_support;
 	int			udp_rss;
 	int			loopback_support;
+	int			vep_uc_steering;
+	int			vep_mc_steering;
 	int			wol;
 	u8			port_width_cap[MLX4_MAX_PORTS + 1];
 	int			max_gso_sz;
-- 
1.6.0.2





