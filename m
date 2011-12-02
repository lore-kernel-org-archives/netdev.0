From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next V0 14/21] mlx4: Traffic steering management support
 for SRIOV
Date: Fri, 2 Dec 2011 12:18:29 +0200
Message-ID: <4ED8A5F5.1080303@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<roland@purestorage.com>, <yevgenyp@mellanox.co.il>,
	<liranl@mellanox.co.il>, <jackm@dev.mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:43680 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756487Ab1LBNAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 08:00:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

Let multicast/unicast attaching flow go through resource tracker.
The PF is the one responsible for managing all the steering entries.
Define and use module parameter that determines the number of qps
per multicast group.
Minor changes in function calls according to changed prototype.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c     |    9 +
 drivers/net/ethernet/mellanox/mlx4/main.c    |   18 ++-
 drivers/net/ethernet/mellanox/mlx4/mcg.c     |  216 ++++++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h    |   22 +--
 drivers/net/ethernet/mellanox/mlx4/profile.c |    5 +-
 5 files changed, 201 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index abdb99d..923cef6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -997,6 +997,15 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.wrapper = mlx4_QP_ATTACH_wrapper
 	},
 	{
+		.opcode = MLX4_CMD_PROMISC,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_PROMISC_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_INFORM_FLR_DONE,
 		.has_inbox = false,
 		.has_outbox = false,
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 64d03f8..68cabc2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -75,6 +75,19 @@ MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 
 #endif /* CONFIG_PCI_MSI */
 
+#ifdef CONFIG_PCI_IOV
+int mlx4_log_num_mgm_entry_size = 10;
+module_param_named(log_num_mgm_entry_size,
+			mlx4_log_num_mgm_entry_size, int, 0444);
+MODULE_PARM_DESC(log_num_mgm_entry_size, "log mgm size, that defines the num"
+					 " of qp per mcg, for example:"
+					 " 10 gives 248.range: 9<="
+					 " log_num_mgm_entry_size <= 12");
+
+#else /* CONFIG_PCI_IOV */
+int mlx4_log_num_mgm_entry_size = 9;
+#endif /* CONFIG_PCI_IOV */
+
 static char mlx4_version[] __devinitdata =
 	DRV_NAME ": Mellanox ConnectX core driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
@@ -205,7 +218,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.reserved_srqs	     = dev_cap->reserved_srqs;
 	dev->caps.max_sq_desc_sz     = dev_cap->max_sq_desc_sz;
 	dev->caps.max_rq_desc_sz     = dev_cap->max_rq_desc_sz;
-	dev->caps.num_qp_per_mgm     = MLX4_QP_PER_MGM;
+	dev->caps.num_qp_per_mgm     = mlx4_get_qp_per_mgm(dev);
 	/*
 	 * Subtract 1 from the limit because we need to allocate a
 	 * spare CQE so the HCA HW can tell the difference between an
@@ -648,7 +661,8 @@ static int mlx4_init_icm(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap,
 	 * and it's a lot easier than trying to track ref counts.
 	 */
 	err = mlx4_init_icm_table(dev, &priv->mcg_table.table,
-				  init_hca->mc_base, MLX4_MGM_ENTRY_SIZE,
+				  init_hca->mc_base,
+				  mlx4_get_mgm_entry_size(dev),
 				  dev->caps.num_mgms + dev->caps.num_amgms,
 				  dev->caps.num_mgms + dev->caps.num_amgms,
 				  0, 0);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index e12d101..2b9e085 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -44,6 +44,24 @@
 
 static const u8 zero_gid[16];	/* automatically initialized to 0 */
 
+struct mlx4_mgm {
+	__be32			next_gid_index;
+	__be32			members_count;
+	u32			reserved[2];
+	u8			gid[16];
+	__be32			qp[MLX4_MAX_QP_PER_MGM];
+};
+
+int mlx4_get_mgm_entry_size(struct mlx4_dev *dev)
+{
+	return min((1 << mlx4_log_num_mgm_entry_size), MLX4_MAX_MGM_ENTRY_SIZE);
+}
+
+int mlx4_get_qp_per_mgm(struct mlx4_dev *dev)
+{
+	return 4 * (mlx4_get_mgm_entry_size(dev) / 16 - 2);
+}
+
 static int mlx4_READ_ENTRY(struct mlx4_dev *dev, int index,
 			   struct mlx4_cmd_mailbox *mailbox)
 {
@@ -58,12 +76,12 @@ static int mlx4_WRITE_ENTRY(struct mlx4_dev *dev, int index,
 			MLX4_CMD_TIME_CLASS_A, 1);
 }
 
-static int mlx4_WRITE_PROMISC(struct mlx4_dev *dev, u8 vep_num, u8 port, u8 steer,
+static int mlx4_WRITE_PROMISC(struct mlx4_dev *dev, u8 port, u8 steer,
 			      struct mlx4_cmd_mailbox *mailbox)
 {
 	u32 in_mod;
 
-	in_mod = (u32) vep_num << 24 | (u32) port << 16 | steer << 1;
+	in_mod = (u32) port << 16 | steer << 1;
 	return mlx4_cmd(dev, mailbox->dma, in_mod, 0x1,
 			MLX4_CMD_WRITE_MCG, MLX4_CMD_TIME_CLASS_A, 1);
 }
@@ -102,7 +120,7 @@ static struct mlx4_promisc_qp *get_promisc_qp(struct mlx4_dev *dev, u8 pf_num,
  * Add new entry to steering data structure.
  * All promisc QPs should be added as well
  */
-static int new_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+static int new_steering_entry(struct mlx4_dev *dev, u8 port,
 			      enum mlx4_steer_type steer,
 			      unsigned int index, u32 qpn)
 {
@@ -115,10 +133,8 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	struct mlx4_promisc_qp *dqp = NULL;
 	u32 prot;
 	int err;
-	u8 pf_num;
 
-	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
-	s_steer = &mlx4_priv(dev)->steer[pf_num];
+	s_steer = &mlx4_priv(dev)->steer[0];
 	new_entry = kzalloc(sizeof *new_entry, GFP_KERNEL);
 	if (!new_entry)
 		return -ENOMEM;
@@ -130,7 +146,7 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	/* If the given qpn is also a promisc qp,
 	 * it should be inserted to duplicates list
 	 */
-	pqp = get_promisc_qp(dev, pf_num, steer, qpn);
+	pqp = get_promisc_qp(dev, 0, steer, qpn);
 	if (pqp) {
 		dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
 		if (!dqp) {
@@ -165,7 +181,7 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 		/* don't add already existing qpn */
 		if (pqp->qpn == qpn)
 			continue;
-		if (members_count == MLX4_QP_PER_MGM) {
+		if (members_count == dev->caps.num_qp_per_mgm) {
 			/* out of space */
 			err = -ENOMEM;
 			goto out_mailbox;
@@ -193,7 +209,7 @@ out_alloc:
 }
 
 /* update the data structures with existing steering entry */
-static int existing_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+static int existing_steering_entry(struct mlx4_dev *dev, u8 port,
 				   enum mlx4_steer_type steer,
 				   unsigned int index, u32 qpn)
 {
@@ -201,12 +217,10 @@ static int existing_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	struct mlx4_steer_index *tmp_entry, *entry = NULL;
 	struct mlx4_promisc_qp *pqp;
 	struct mlx4_promisc_qp *dqp;
-	u8 pf_num;
 
-	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
-	s_steer = &mlx4_priv(dev)->steer[pf_num];
+	s_steer = &mlx4_priv(dev)->steer[0];
 
-	pqp = get_promisc_qp(dev, pf_num, steer, qpn);
+	pqp = get_promisc_qp(dev, 0, steer, qpn);
 	if (!pqp)
 		return 0; /* nothing to do */
 
@@ -225,7 +239,7 @@ static int existing_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	 * we need to add it as a duplicate to this entry
 	 * for future references */
 	list_for_each_entry(dqp, &entry->duplicates, list) {
-		if (qpn == dqp->qpn)
+		if (qpn == pqp->qpn)
 			return 0; /* qp is already duplicated */
 	}
 
@@ -241,20 +255,18 @@ static int existing_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 
 /* Check whether a qpn is a duplicate on steering entry
  * If so, it should not be removed from mgm */
-static bool check_duplicate_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+static bool check_duplicate_entry(struct mlx4_dev *dev, u8 port,
 				  enum mlx4_steer_type steer,
 				  unsigned int index, u32 qpn)
 {
 	struct mlx4_steer *s_steer;
 	struct mlx4_steer_index *tmp_entry, *entry = NULL;
 	struct mlx4_promisc_qp *dqp, *tmp_dqp;
-	u8 pf_num;
 
-	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
-	s_steer = &mlx4_priv(dev)->steer[pf_num];
+	s_steer = &mlx4_priv(dev)->steer[0];
 
 	/* if qp is not promisc, it cannot be duplicated */
-	if (!get_promisc_qp(dev, pf_num, steer, qpn))
+	if (!get_promisc_qp(dev, 0, steer, qpn))
 		return false;
 
 	/* The qp is promisc qp so it is a duplicate on this index
@@ -279,7 +291,7 @@ static bool check_duplicate_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 }
 
 /* I a steering entry contains only promisc QPs, it can be removed. */
-static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
 				      enum mlx4_steer_type steer,
 				      unsigned int index, u32 tqpn)
 {
@@ -291,10 +303,8 @@ static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	u32 members_count;
 	bool ret = false;
 	int i;
-	u8 pf_num;
 
-	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
-	s_steer = &mlx4_priv(dev)->steer[pf_num];
+	s_steer = &mlx4_priv(dev)->steer[0];
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -306,7 +316,7 @@ static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
 	for (i = 0;  i < members_count; i++) {
 		qpn = be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK;
-		if (!get_promisc_qp(dev, pf_num, steer, qpn) && qpn != tqpn) {
+		if (!get_promisc_qp(dev, 0, steer, qpn) && qpn != tqpn) {
 			/* the qp is not promisc, the entry can't be removed */
 			goto out;
 		}
@@ -332,7 +342,7 @@ out:
 	return ret;
 }
 
-static int add_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
+static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 			  enum mlx4_steer_type steer, u32 qpn)
 {
 	struct mlx4_steer *s_steer;
@@ -347,14 +357,13 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	bool found;
 	int last_index;
 	int err;
-	u8 pf_num;
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
-	s_steer = &mlx4_priv(dev)->steer[pf_num];
+
+	s_steer = &mlx4_priv(dev)->steer[0];
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	if (get_promisc_qp(dev, pf_num, steer, qpn)) {
+	if (get_promisc_qp(dev, 0, steer, qpn)) {
 		err = 0;  /* Noting to do, already exists */
 		goto out_mutex;
 	}
@@ -397,7 +406,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
 		}
 		if (!found) {
 			/* Need to add the qpn to mgm */
-			if (members_count == MLX4_QP_PER_MGM) {
+			if (members_count == dev->caps.num_qp_per_mgm) {
 				/* entry is full */
 				err = -ENOMEM;
 				goto out_mailbox;
@@ -420,7 +429,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
 		mgm->qp[members_count++] = cpu_to_be32(dqp->qpn & MGM_QPN_MASK);
 	mgm->members_count = cpu_to_be32(members_count | MLX4_PROT_ETH << 30);
 
-	err = mlx4_WRITE_PROMISC(dev, vep_num, port, steer, mailbox);
+	err = mlx4_WRITE_PROMISC(dev, port, steer, mailbox);
 	if (err)
 		goto out_list;
 
@@ -439,7 +448,7 @@ out_mutex:
 	return err;
 }
 
-static int remove_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
+static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 			     enum mlx4_steer_type steer, u32 qpn)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -454,13 +463,11 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	bool back_to_list = false;
 	int loc, i;
 	int err;
-	u8 pf_num;
 
-	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
-	s_steer = &mlx4_priv(dev)->steer[pf_num];
+	s_steer = &mlx4_priv(dev)->steer[0];
 	mutex_lock(&priv->mcg_table.mutex);
 
-	pqp = get_promisc_qp(dev, pf_num, steer, qpn);
+	pqp = get_promisc_qp(dev, 0, steer, qpn);
 	if (unlikely(!pqp)) {
 		mlx4_warn(dev, "QP %x is not promiscuous QP\n", qpn);
 		/* nothing to do */
@@ -479,12 +486,13 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
 		goto out_list;
 	}
 	mgm = mailbox->buf;
+	memset(mgm, 0, sizeof *mgm);
 	members_count = 0;
 	list_for_each_entry(dqp, &s_steer->promisc_qps[steer], list)
 		mgm->qp[members_count++] = cpu_to_be32(dqp->qpn & MGM_QPN_MASK);
 	mgm->members_count = cpu_to_be32(members_count | MLX4_PROT_ETH << 30);
 
-	err = mlx4_WRITE_PROMISC(dev, vep_num, port, steer, mailbox);
+	err = mlx4_WRITE_PROMISC(dev, port, steer, mailbox);
 	if (err)
 		goto out_mailbox;
 
@@ -649,12 +657,13 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		}
 		index += dev->caps.num_mgms;
 
+		new_entry = 1;
 		memset(mgm, 0, sizeof *mgm);
 		memcpy(mgm->gid, gid, 16);
 	}
 
 	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
-	if (members_count == MLX4_QP_PER_MGM) {
+	if (members_count == dev->caps.num_qp_per_mgm) {
 		mlx4_err(dev, "MGM at index %x is full.\n", index);
 		err = -ENOMEM;
 		goto out;
@@ -696,9 +705,9 @@ out:
 	if (prot == MLX4_PROT_ETH) {
 		/* manage the steering entry for promisc mode */
 		if (new_entry)
-			new_steering_entry(dev, 0, port, steer, index, qp->qpn);
+			new_steering_entry(dev, port, steer, index, qp->qpn);
 		else
-			existing_steering_entry(dev, 0, port, steer,
+			existing_steering_entry(dev, port, steer,
 						index, qp->qpn);
 	}
 	if (err && link && index != -1) {
@@ -749,7 +758,7 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 
 	/* if this pq is also a promisc qp, it shouldn't be removed */
 	if (prot == MLX4_PROT_ETH &&
-	    check_duplicate_entry(dev, 0, port, steer, index, qp->qpn))
+	    check_duplicate_entry(dev, port, steer, index, qp->qpn))
 		goto out;
 
 	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
@@ -769,7 +778,8 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	mgm->qp[i - 1]     = 0;
 
 	if (prot == MLX4_PROT_ETH)
-		removed_entry = can_remove_steering_entry(dev, 0, port, steer, index, qp->qpn);
+		removed_entry = can_remove_steering_entry(dev, port, steer,
+								index, qp->qpn);
 	if (i != 1 && (prot != MLX4_PROT_ETH || !removed_entry)) {
 		err = mlx4_WRITE_ENTRY(dev, index, mailbox);
 		goto out;
@@ -828,6 +838,33 @@ out:
 	return err;
 }
 
+static int mlx4_QP_ATTACH(struct mlx4_dev *dev, struct mlx4_qp *qp,
+			  u8 gid[16], u8 attach, u8 block_loopback,
+			  enum mlx4_protocol prot)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	int err = 0;
+	int qpn;
+
+	if (!mlx4_is_mfunc(dev))
+		return -EBADF;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	memcpy(mailbox->buf, gid, 16);
+	qpn = qp->qpn;
+	qpn |= (prot << 28);
+	if (attach && block_loopback)
+		qpn |= (1 << 31);
+
+	err = mlx4_cmd(dev, mailbox->dma, qpn, attach,
+		       MLX4_CMD_QP_ATTACH, MLX4_CMD_TIME_CLASS_A, 0);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
 
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol prot)
@@ -843,9 +880,12 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	if (prot == MLX4_PROT_ETH)
 		gid[7] |= (steer << 1);
 
-	return mlx4_qp_attach_common(dev, qp, gid,
-				     block_mcast_loopback, prot,
-				     steer);
+	if (mlx4_is_mfunc(dev))
+		return mlx4_QP_ATTACH(dev, qp, gid, 1,
+					block_mcast_loopback, prot);
+
+	return mlx4_qp_attach_common(dev, qp, gid, block_mcast_loopback,
+					prot, steer);
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
 
@@ -860,22 +900,89 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
 		return 0;
 
-	if (prot == MLX4_PROT_ETH) {
+	if (prot == MLX4_PROT_ETH)
 		gid[7] |= (steer << 1);
-	}
+
+	if (mlx4_is_mfunc(dev))
+		return mlx4_QP_ATTACH(dev, qp, gid, 0, 0, prot);
 
 	return mlx4_qp_detach_common(dev, qp, gid, prot, steer);
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
+static int mlx4_unicast_attach(struct mlx4_dev *dev,
+			struct mlx4_qp *qp, u8 gid[16],
+			int block_mcast_loopback, enum mlx4_protocol prot)
+{
+	if (prot == MLX4_PROT_ETH &&
+			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
+		return 0;
+
+	if (prot == MLX4_PROT_ETH)
+		gid[7] |= (MLX4_UC_STEER << 1);
+
+	if (mlx4_is_mfunc(dev))
+		return mlx4_QP_ATTACH(dev, qp, gid, 1,
+					block_mcast_loopback, prot);
+
+	return mlx4_qp_attach_common(dev, qp, gid, block_mcast_loopback,
+					prot, MLX4_UC_STEER);
+}
+EXPORT_SYMBOL_GPL(mlx4_unicast_attach);
+
+static int mlx4_unicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp,
+			       u8 gid[16], enum mlx4_protocol prot)
+{
+	if (prot == MLX4_PROT_ETH &&
+			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
+		return 0;
+
+	if (prot == MLX4_PROT_ETH)
+		gid[7] |= (MLX4_UC_STEER << 1);
+
+	if (mlx4_is_mfunc(dev))
+		return mlx4_QP_ATTACH(dev, qp, gid, 0, 0, prot);
+
+	return mlx4_qp_detach_common(dev, qp, gid, prot, MLX4_UC_STEER);
+}
+EXPORT_SYMBOL_GPL(mlx4_unicast_detach);
+
+int mlx4_PROMISC_wrapper(struct mlx4_dev *dev, int slave,
+			 struct mlx4_vhcr *vhcr,
+			 struct mlx4_cmd_mailbox *inbox,
+			 struct mlx4_cmd_mailbox *outbox,
+			 struct mlx4_cmd_info *cmd)
+{
+	u32 qpn = (u32) vhcr->in_param & 0xffffffff;
+	u8 port = vhcr->in_param >> 62;
+	enum mlx4_steer_type steer = vhcr->in_modifier;
+
+	/* Promiscuous unicast is not allowed in mfunc */
+	if (mlx4_is_mfunc(dev) && steer == MLX4_UC_STEER)
+		return 0;
+
+	if (vhcr->op_modifier)
+		return add_promisc_qp(dev, port, steer, qpn);
+	else
+		return remove_promisc_qp(dev, port, steer, qpn);
+}
+
+static int mlx4_PROMISC(struct mlx4_dev *dev, u32 qpn,
+			enum mlx4_steer_type steer, u8 add, u8 port)
+{
+	return mlx4_cmd(dev, (u64) qpn | (u64) port << 62, (u32) steer, add,
+			MLX4_CMD_PROMISC, MLX4_CMD_TIME_CLASS_A, 0);
+}
 
 int mlx4_multicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port)
 {
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
 		return 0;
 
+	if (mlx4_is_mfunc(dev))
+		return mlx4_PROMISC(dev, qpn, MLX4_MC_STEER, 1, port);
 
-	return add_promisc_qp(dev, 0, port, MLX4_MC_STEER, qpn);
+	return add_promisc_qp(dev, port, MLX4_MC_STEER, qpn);
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_promisc_add);
 
@@ -884,8 +991,10 @@ int mlx4_multicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port)
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
 		return 0;
 
+	if (mlx4_is_mfunc(dev))
+		return mlx4_PROMISC(dev, qpn, MLX4_MC_STEER, 0, port);
 
-	return remove_promisc_qp(dev, 0, port, MLX4_MC_STEER, qpn);
+	return remove_promisc_qp(dev, port, MLX4_MC_STEER, qpn);
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_promisc_remove);
 
@@ -894,8 +1003,10 @@ int mlx4_unicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port)
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
 		return 0;
 
+	if (mlx4_is_mfunc(dev))
+		return mlx4_PROMISC(dev, qpn, MLX4_UC_STEER, 1, port);
 
-	return add_promisc_qp(dev, 0, port, MLX4_UC_STEER, qpn);
+	return add_promisc_qp(dev, port, MLX4_UC_STEER, qpn);
 }
 EXPORT_SYMBOL_GPL(mlx4_unicast_promisc_add);
 
@@ -904,7 +1015,10 @@ int mlx4_unicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port)
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
 		return 0;
 
-	return remove_promisc_qp(dev, 0, port, MLX4_UC_STEER, qpn);
+	if (mlx4_is_mfunc(dev))
+		return mlx4_PROMISC(dev, qpn, MLX4_UC_STEER, 0, port);
+
+	return remove_promisc_qp(dev, port, MLX4_UC_STEER, qpn);
 }
 EXPORT_SYMBOL_GPL(mlx4_unicast_promisc_remove);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 2488be8..a38ffc9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -61,9 +61,9 @@ enum {
 };
 
 enum {
-	MLX4_MGM_ENTRY_SIZE	=  0x100,
-	MLX4_QP_PER_MGM		= 4 * (MLX4_MGM_ENTRY_SIZE / 16 - 2),
-	MLX4_MTT_ENTRY_PER_SEG	= 8
+	MLX4_MAX_MGM_ENTRY_SIZE = 0x1000,
+	MLX4_MAX_QP_PER_MGM	= 4 * (MLX4_MAX_MGM_ENTRY_SIZE / 16 - 2),
+	MLX4_MTT_ENTRY_PER_SEG	= 8,
 };
 
 enum {
@@ -190,6 +190,8 @@ do {									\
 #define mlx4_warn(mdev, format, arg...) \
 	dev_warn(&mdev->pdev->dev, format, ##arg)
 
+extern int mlx4_log_num_mgm_entry_size;
+
 #define MLX4_MAX_NUM_SLAVES	(MLX4_MAX_NUM_PF + MLX4_MAX_NUM_VF)
 #define ALL_SLAVES 0xff
 
@@ -417,9 +419,6 @@ struct mlx4_comm {
 	u32			slave_read;
 };
 
-#define MGM_QPN_MASK       0x00FFFFFF
-#define MGM_BLCK_LB_BIT    30
-
 #define VLAN_FLTR_SIZE	128
 
 struct mlx4_vlan_fltr {
@@ -437,14 +436,6 @@ struct mlx4_steer_index {
 	struct list_head duplicates;
 };
 
-struct mlx4_mgm {
-	__be32			next_gid_index;
-	__be32			members_count;
-	u32			reserved[2];
-	u8			gid[16];
-	__be32			qp[MLX4_QP_PER_MGM];
-};
-
 struct mlx4_slave_state {
 	u8 comm_toggle;
 	u8 last_cmd;
@@ -1021,6 +1012,9 @@ int mlx4_QUERY_IF_STAT_wrapper(struct mlx4_dev *dev, int slave,
 			       struct mlx4_cmd_mailbox *outbox,
 			       struct mlx4_cmd_info *cmd);
 
+int mlx4_get_mgm_entry_size(struct mlx4_dev *dev);
+int mlx4_get_qp_per_mgm(struct mlx4_dev *dev);
+
 static inline void set_param_l(u64 *arg, u32 val)
 {
 	*((u32 *)arg) = val;
diff --git a/drivers/net/ethernet/mellanox/mlx4/profile.c b/drivers/net/ethernet/mellanox/mlx4/profile.c
index b967647..771c460 100644
--- a/drivers/net/ethernet/mellanox/mlx4/profile.c
+++ b/drivers/net/ethernet/mellanox/mlx4/profile.c
@@ -99,7 +99,7 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	profile[MLX4_RES_DMPT].size   = dev_cap->dmpt_entry_sz;
 	profile[MLX4_RES_CMPT].size   = dev_cap->cmpt_entry_sz;
 	profile[MLX4_RES_MTT].size    = dev->caps.mtts_per_seg * dev_cap->mtt_entry_sz;
-	profile[MLX4_RES_MCG].size    = MLX4_MGM_ENTRY_SIZE;
+	profile[MLX4_RES_MCG].size    = mlx4_get_mgm_entry_size(dev);
 
 	profile[MLX4_RES_QP].num      = request->num_qp;
 	profile[MLX4_RES_RDMARC].num  = request->num_qp * request->rdmarc_per_qp;
@@ -218,7 +218,8 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 			dev->caps.num_mgms	  = profile[i].num >> 1;
 			dev->caps.num_amgms	  = profile[i].num >> 1;
 			init_hca->mc_base	  = profile[i].start;
-			init_hca->log_mc_entry_sz = ilog2(MLX4_MGM_ENTRY_SIZE);
+			init_hca->log_mc_entry_sz =
+					ilog2(mlx4_get_mgm_entry_size(dev));
 			init_hca->log_mc_table_sz = profile[i].log_num;
 			init_hca->log_mc_hash_sz  = profile[i].log_num - 1;
 			break;
-- 
1.7.7
