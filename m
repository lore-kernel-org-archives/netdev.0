From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 10/17]  mlx4: Add support for promiscuous mode in the new
 steering model.
Date: Mon, 7 Mar 2011 12:17:42 +0200
Message-ID: <4D74B0C6.2060101@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<vlad@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:52286 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752021Ab1CGOk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 09:40:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For Ethernet mode only,
When we want to register QP as promiscuous, it must be added to all the
existing steering entries and also to the default one.
The promiscuous QP might also be on of "real" QPs,
which means we need to monitor every entry to avoid duplicates and ensure
we close an entry when all it has is promiscuous QPs.
Same mechanism both for unicast and multicast.

Signed-off-by: Vladimir Sokolovsky <vlad@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/main.c |   63 ++++++-
 drivers/net/mlx4/mcg.c  |  535 ++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/mlx4/mlx4.h |   33 +++
 3 files changed, 620 insertions(+), 11 deletions(-)

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index da0da28..c8e2761 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1063,6 +1063,59 @@ static void mlx4_cleanup_port_info(struct mlx4_port_info *info)
 	device_remove_file(&info->dev->pdev->dev, &info->port_attr);
 }
 
+static int mlx4_init_steering(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int num_entries = dev->caps.num_ports;
+	int i, j;
+
+	priv->steer = kzalloc(sizeof(struct mlx4_steer) * num_entries, GFP_KERNEL);
+	if (!priv->steer)
+		return -ENOMEM;
+
+	for (i = 0; i < num_entries; i++) {
+		for (j = 0; j < MLX4_NUM_STEERS; j++) {
+			INIT_LIST_HEAD(&priv->steer[i].promisc_qps[j]);
+			INIT_LIST_HEAD(&priv->steer[i].steer_entries[j]);
+		}
+		INIT_LIST_HEAD(&priv->steer[i].high_prios);
+	}
+	return 0;
+}
+
+static void mlx4_clear_steering(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_steer_index *entry, *tmp_entry;
+	struct mlx4_promisc_qp *pqp, *tmp_pqp;
+	int num_entries = dev->caps.num_ports;
+	int i, j;
+
+	for (i = 0; i < num_entries; i++) {
+		for (j = 0; j < MLX4_NUM_STEERS; j++) {
+			list_for_each_entry_safe(pqp, tmp_pqp,
+						 &priv->steer[i].promisc_qps[j],
+						 list) {
+				list_del(&pqp->list);
+				kfree(pqp);
+			}
+			list_for_each_entry_safe(entry, tmp_entry,
+						 &priv->steer[i].steer_entries[j],
+						 list) {
+				list_del(&entry->list);
+				list_for_each_entry_safe(pqp, tmp_pqp,
+							 &entry->duplicates,
+							 list) {
+					list_del(&pqp->list);
+					kfree(pqp);
+				}
+				kfree(entry);
+			}
+		}
+	}
+	kfree(priv->steer);
+}
+
 static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct mlx4_priv *priv;
@@ -1172,6 +1225,10 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	mlx4_enable_msi_x(dev);
 
+	err = mlx4_init_steering(dev);
+	if (err)
+		goto err_free_eq;
+
 	err = mlx4_setup_hca(dev);
 	if (err == -EBUSY && (dev->flags & MLX4_FLAG_MSI_X)) {
 		dev->flags &= ~MLX4_FLAG_MSI_X;
@@ -1180,7 +1237,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	if (err)
-		goto err_free_eq;
+		goto err_steer;
 
 	for (port = 1; port <= dev->caps.num_ports; port++) {
 		err = mlx4_init_port_info(dev, port);
@@ -1213,6 +1270,9 @@ err_port:
 	mlx4_cleanup_pd_table(dev);
 	mlx4_cleanup_uar_table(dev);
 
+err_steer:
+	mlx4_clear_steering(dev);
+
 err_free_eq:
 	mlx4_free_eq_table(dev);
 
@@ -1272,6 +1332,7 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 		iounmap(priv->kar);
 		mlx4_uar_free(dev, &priv->driver_uar);
 		mlx4_cleanup_uar_table(dev);
+		mlx4_clear_steering(dev);
 		mlx4_free_eq_table(dev);
 		mlx4_close_hca(dev);
 		mlx4_cmd_cleanup(dev);
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index b103ad2..e71372a 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -41,14 +41,6 @@
 #define MGM_QPN_MASK       0x00FFFFFF
 #define MGM_BLCK_LB_BIT    30
 
-struct mlx4_mgm {
-	__be32			next_gid_index;
-	__be32			members_count;
-	u32			reserved[2];
-	u8			gid[16];
-	__be32			qp[MLX4_QP_PER_MGM];
-};
-
 static const u8 zero_gid[16];	/* automatically initialized to 0 */
 
 static int mlx4_READ_ENTRY(struct mlx4_dev *dev, int index,
@@ -65,6 +57,16 @@ static int mlx4_WRITE_ENTRY(struct mlx4_dev *dev, int index,
 			MLX4_CMD_TIME_CLASS_A);
 }
 
+static int mlx4_WRITE_PROMISC(struct mlx4_dev *dev, u8 vep_num, u8 port, u8 steer,
+			      struct mlx4_cmd_mailbox *mailbox)
+{
+	u32 in_mod;
+
+	in_mod = (u32) vep_num << 24 | (u32) port << 16 | steer << 1;
+	return mlx4_cmd(dev, mailbox->dma, in_mod, 0x1,
+			MLX4_CMD_WRITE_MCG, MLX4_CMD_TIME_CLASS_A);
+}
+
 static int mlx4_GID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 u16 *hash, u8 op_mod)
 {
@@ -80,6 +82,457 @@ static int mlx4_GID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 	return err;
 }
 
+static struct mlx4_promisc_qp *get_promisc_qp(struct mlx4_dev *dev, u8 pf_num,
+					      enum mlx4_steer_type steer,
+					      u32 qpn)
+{
+	struct mlx4_steer *s_steer = &mlx4_priv(dev)->steer[pf_num];
+	struct mlx4_promisc_qp *pqp;
+
+	list_for_each_entry(pqp, &s_steer->promisc_qps[steer], list) {
+		if (pqp->qpn == qpn)
+			return pqp;
+	}
+	/* not found */
+	return NULL;
+}
+
+/*
+ * Add new entry to steering data structure.
+ * All promisc QPs should be added as well
+ */
+static int new_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+			      enum mlx4_steer_type steer,
+			      unsigned int index, u32 qpn)
+{
+	struct mlx4_steer *s_steer;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_mgm *mgm;
+	u32 members_count;
+	struct mlx4_steer_index *new_entry;
+	struct mlx4_promisc_qp *pqp;
+	struct mlx4_promisc_qp *dqp;
+	u32 prot;
+	int err;
+	u8 pf_num;
+
+	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
+	s_steer = &mlx4_priv(dev)->steer[pf_num];
+	new_entry = kzalloc(sizeof *new_entry, GFP_KERNEL);
+	if (!new_entry)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&new_entry->duplicates);
+	new_entry->index = index;
+	list_add_tail(&new_entry->list, &s_steer->steer_entries[steer]);
+
+	/* If the given qpn is also a promisc qp,
+	 * it should be inserted to duplicates list
+	 */
+	pqp = get_promisc_qp(dev, pf_num, steer, qpn);
+	if (pqp) {
+		dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
+		if (!dqp) {
+			err = -ENOMEM;
+			goto out_alloc;
+		}
+		dqp->qpn = qpn;
+		list_add_tail(&dqp->list, &new_entry->duplicates);
+	}
+
+	/* if no promisc qps for this vep, we are done */
+	if (list_empty(&s_steer->promisc_qps[steer]))
+		return 0;
+
+	/* now need to add all the promisc qps to the new
+	 * steering entry, as they should also receive the packets
+	 * destined to this address */
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox)) {
+		err = -ENOMEM;
+		goto out_alloc;
+	}
+	mgm = mailbox->buf;
+
+	err = mlx4_READ_ENTRY(dev, index, mailbox);
+	if (err)
+		goto out_mailbox;
+
+	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
+	prot = be32_to_cpu(mgm->members_count) >> 30;
+	list_for_each_entry(pqp, &s_steer->promisc_qps[steer], list) {
+		/* don't add already existing qpn */
+		if (pqp->qpn == qpn)
+			continue;
+		if (members_count == MLX4_QP_PER_MGM) {
+			/* out of space */
+			err = -ENOMEM;
+			goto out_mailbox;
+		}
+
+		/* add the qpn */
+		mgm->qp[members_count++] = cpu_to_be32(pqp->qpn & MGM_QPN_MASK);
+	}
+	/* update the qps count and update the entry with all the promisc qps*/
+	mgm->members_count = cpu_to_be32(members_count | (prot << 30));
+	err = mlx4_WRITE_ENTRY(dev, index, mailbox);
+
+out_mailbox:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	if (!err)
+		return 0;
+out_alloc:
+	if (dqp) {
+		list_del(&dqp->list);
+		kfree(&dqp);
+	}
+	list_del(&new_entry->list);
+	kfree(new_entry);
+	return err;
+}
+
+/* update the data structures with existing steering entry */
+static int existing_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+				   enum mlx4_steer_type steer,
+				   unsigned int index, u32 qpn)
+{
+	struct mlx4_steer *s_steer;
+	struct mlx4_steer_index *tmp_entry, *entry = NULL;
+	struct mlx4_promisc_qp *pqp;
+	struct mlx4_promisc_qp *dqp;
+	u8 pf_num;
+
+	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
+	s_steer = &mlx4_priv(dev)->steer[pf_num];
+
+	pqp = get_promisc_qp(dev, pf_num, steer, qpn);
+	if (!pqp)
+		return 0; /* nothing to do */
+
+	list_for_each_entry(tmp_entry, &s_steer->steer_entries[steer], list) {
+		if (tmp_entry->index == index) {
+			entry = tmp_entry;
+			break;
+		}
+	}
+	if (unlikely(!entry)) {
+		mlx4_warn(dev, "Steering entry at index %x is not registered\n", index);
+		return -EINVAL;
+	}
+
+	/* the given qpn is listed as a promisc qpn
+	 * we need to add it as a duplicate to this entry
+	 * for future refernce */
+	list_for_each_entry(dqp, &entry->duplicates, list) {
+		if (qpn == dqp->qpn)
+			return 0; /* qp is already duplicated */
+	}
+
+	/* add the qp as a duplicate on this index */
+	dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
+	if (!dqp)
+		return -ENOMEM;
+	dqp->qpn = qpn;
+	list_add_tail(&dqp->list, &entry->duplicates);
+
+	return 0;
+}
+
+/* Check whether a qpn is a duplicate on steering entry
+ * If so, it should not be removed from mgm */
+static bool check_duplicate_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+				  enum mlx4_steer_type steer,
+				  unsigned int index, u32 qpn)
+{
+	struct mlx4_steer *s_steer;
+	struct mlx4_steer_index *tmp_entry, *entry = NULL;
+	struct mlx4_promisc_qp *dqp, *tmp_dqp;
+	u8 pf_num;
+
+	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
+	s_steer = &mlx4_priv(dev)->steer[pf_num];
+
+	/* if qp is not promisc, it cannot be duplicated */
+	if (!get_promisc_qp(dev, pf_num, steer, qpn))
+		return false;
+
+	/* The qp is promisc qp so it is a duplicate on this index
+	 * Find the index entry, and remove the duplicate */
+	list_for_each_entry(tmp_entry, &s_steer->steer_entries[steer], list) {
+		if (tmp_entry->index == index) {
+			entry = tmp_entry;
+			break;
+		}
+	}
+	if (unlikely(!entry)) {
+		mlx4_warn(dev, "Steering entry for index %x is not registered\n", index);
+		return false;
+	}
+	list_for_each_entry_safe(dqp, tmp_dqp, &entry->duplicates, list) {
+		if (dqp->qpn == qpn) {
+			list_del(&dqp->list);
+			kfree(dqp);
+		}
+	}
+	return true;
+}
+
+/* I a steering entry contains only promisc QPs, it can be removed. */
+static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+				      enum mlx4_steer_type steer,
+				      unsigned int index, u32 tqpn)
+{
+	struct mlx4_steer *s_steer;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_mgm *mgm;
+	struct mlx4_steer_index *entry = NULL, *tmp_entry;
+	u32 qpn;
+	u32 members_count;
+	bool ret = false;
+	int i;
+	u8 pf_num;
+
+	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
+	s_steer = &mlx4_priv(dev)->steer[pf_num];
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return false;
+	mgm = mailbox->buf;
+
+	if (mlx4_READ_ENTRY(dev, index, mailbox))
+		goto out;
+	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
+	for (i = 0;  i < members_count; i++) {
+		qpn = be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK;
+		if (!get_promisc_qp(dev, pf_num, steer, qpn) && qpn != tqpn) {
+			/* the qp is not promisc, the entry can't be removed */
+			goto out;
+		}
+	}
+	 /* All the qps currently registered for this entry are promiscuous,
+	  * Checking for duplicates */
+	ret = true;
+	list_for_each_entry_safe(entry, tmp_entry, &s_steer->steer_entries[steer], list) {
+		if (entry->index == index) {
+			if (list_empty(&entry->duplicates)) {
+				list_del(&entry->list);
+				kfree(entry);
+			} else {
+				/* This entry contains duplicates so it shouldn't be removed */
+				ret = false;
+				goto out;
+			}
+		}
+	}
+
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return ret;
+}
+
+static int add_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
+			  enum mlx4_steer_type steer, u32 qpn)
+{
+	struct mlx4_steer *s_steer;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_mgm *mgm;
+	struct mlx4_steer_index *entry;
+	struct mlx4_promisc_qp *pqp;
+	struct mlx4_promisc_qp *dqp;
+	u32 members_count;
+	u32 prot;
+	int i;
+	bool found;
+	int last_index;
+	int err;
+	u8 pf_num;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
+	s_steer = &mlx4_priv(dev)->steer[pf_num];
+
+	mutex_lock(&priv->mcg_table.mutex);
+
+	if (get_promisc_qp(dev, pf_num, steer, qpn)) {
+		err = 0;  /* Noting to do, already exists */
+		goto out_mutex;
+	}
+
+	pqp = kmalloc(sizeof *pqp, GFP_KERNEL);
+	if (!pqp) {
+		err = -ENOMEM;
+		goto out_mutex;
+	}
+	pqp->qpn = qpn;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox)) {
+		err = -ENOMEM;
+		goto out_alloc;
+	}
+	mgm = mailbox->buf;
+
+	/* the promisc qp needs to be added for each one of the steering
+	 * entries, if it already exists, needs to be added as a duplicate
+	 * for this entry */
+	list_for_each_entry(entry, &s_steer->steer_entries[steer], list) {
+		err = mlx4_READ_ENTRY(dev, entry->index, mailbox);
+		if (err)
+			goto out_mailbox;
+
+		members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
+		prot = be32_to_cpu(mgm->members_count) >> 30;
+		found = false;
+		for (i = 0; i < members_count; i++) {
+			if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qpn) {
+				/* Entry already exists, add to duplicates */
+				dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
+				if (!dqp)
+					goto out_mailbox;
+				dqp->qpn = qpn;
+				list_add_tail(&dqp->list, &entry->duplicates);
+				found = true;
+			}
+		}
+		if (!found) {
+			/* Need to add the qpn to mgm */
+			if (members_count == MLX4_QP_PER_MGM) {
+				/* entry is full */
+				err = -ENOMEM;
+				goto out_mailbox;
+			}
+			mgm->qp[members_count++] = cpu_to_be32(qpn & MGM_QPN_MASK);
+			mgm->members_count = cpu_to_be32(members_count | (prot << 30));
+			err = mlx4_WRITE_ENTRY(dev, entry->index, mailbox);
+			if (err)
+				goto out_mailbox;
+		}
+		last_index = entry->index;
+	}
+
+	/* add the new qpn to list of promisc qps */
+	list_add_tail(&pqp->list, &s_steer->promisc_qps[steer]);
+	/* now need to add all the promisc qps to default entry */
+	memset(mgm, 0, sizeof *mgm);
+	members_count = 0;
+	list_for_each_entry(dqp, &s_steer->promisc_qps[steer], list)
+		mgm->qp[members_count++] = cpu_to_be32(dqp->qpn & MGM_QPN_MASK);
+	mgm->members_count = cpu_to_be32(members_count | MLX4_PROT_ETH << 30);
+
+	err = mlx4_WRITE_PROMISC(dev, vep_num, port, steer, mailbox);
+	if (err)
+		goto out_list;
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	mutex_unlock(&priv->mcg_table.mutex);
+	return 0;
+
+out_list:
+	list_del(&pqp->list);
+out_mailbox:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+out_alloc:
+	kfree(pqp);
+out_mutex:
+	mutex_unlock(&priv->mcg_table.mutex);
+	return err;
+}
+
+static int remove_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
+			     enum mlx4_steer_type steer, u32 qpn)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_steer *s_steer;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_mgm *mgm;
+	struct mlx4_steer_index *entry;
+	struct mlx4_promisc_qp *pqp;
+	struct mlx4_promisc_qp *dqp;
+	u32 members_count;
+	bool found;
+	bool back_to_list = false;
+	int loc, i;
+	int err;
+	u8 pf_num;
+
+	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
+	s_steer = &mlx4_priv(dev)->steer[pf_num];
+	mutex_lock(&priv->mcg_table.mutex);
+
+	pqp = get_promisc_qp(dev, pf_num, steer, qpn);
+	if (unlikely(!pqp)) {
+		mlx4_warn(dev, "QP %x is not promiscuous QP\n", qpn);
+		/* nothing to do */
+		err = 0;
+		goto out_mutex;
+	}
+
+	/*remove from list of promisc qps */
+	list_del(&pqp->list);
+	kfree(pqp);
+
+	/* set the default entry not to include the removed one */
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox)) {
+		err = -ENOMEM;
+		back_to_list = true;
+		goto out_list;
+	}
+	mgm = mailbox->buf;
+	members_count = 0;
+	list_for_each_entry(dqp, &s_steer->promisc_qps[steer], list)
+		mgm->qp[members_count++] = cpu_to_be32(dqp->qpn & MGM_QPN_MASK);
+	mgm->members_count = cpu_to_be32(members_count | MLX4_PROT_ETH << 30);
+
+	err = mlx4_WRITE_PROMISC(dev, vep_num, port, steer, mailbox);
+	if (err)
+		goto out_mailbox;
+
+	/* remove the qp from all the steering entries*/
+	list_for_each_entry(entry, &s_steer->steer_entries[steer], list) {
+		found = false;
+		list_for_each_entry(dqp, &entry->duplicates, list) {
+			if (dqp->qpn == qpn) {
+				found = true;
+				break;
+			}
+		}
+		if (found) {
+			/* a duplicate, no need to change the mgm,
+			 * only update the duplicates list */
+			list_del(&dqp->list);
+			kfree(dqp);
+		} else {
+			err = mlx4_READ_ENTRY(dev, entry->index, mailbox);
+				if (err)
+					goto out_mailbox;
+			members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
+			for (loc = -1, i = 0; i < members_count; ++i)
+				if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qpn)
+					loc = i;
+
+			mgm->members_count = cpu_to_be32(--members_count |
+							 (MLX4_PROT_ETH << 30));
+			mgm->qp[loc] = mgm->qp[i - 1];
+			mgm->qp[i - 1] = 0;
+
+			err = mlx4_WRITE_ENTRY(dev, entry->index, mailbox);
+				if (err)
+					goto out_mailbox;
+		}
+
+	}
+
+out_mailbox:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+out_list:
+	if (back_to_list)
+		list_add_tail(&pqp->list, &s_steer->promisc_qps[steer]);
+out_mutex:
+	mutex_unlock(&priv->mcg_table.mutex);
+	return err;
+}
+
 /*
  * Caller must hold MCG table semaphore.  gid and mgm parameters must
  * be properly aligned for command interface.
@@ -164,6 +617,7 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	int i;
 	int err;
 	u8 port = gid[5];
+	u8 new_entry = 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -177,8 +631,10 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		goto out;
 
 	if (index != -1) {
-		if (!(be32_to_cpu(mgm->members_count) & 0xffffff))
+		if (!(be32_to_cpu(mgm->members_count) & 0xffffff)) {
+			new_entry = 1;
 			memcpy(mgm->gid, gid, 16);
+		}
 	} else {
 		link = 1;
 
@@ -234,6 +690,14 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		goto out;
 
 out:
+	if (prot == MLX4_PROT_ETH) {
+		/* manage the steering entry for promisc mode */
+		if (new_entry)
+			new_steering_entry(dev, 0, port, steer, index, qp->qpn);
+		else
+			existing_steering_entry(dev, 0, port, steer,
+						index, qp->qpn);
+	}
 	if (err && link && index != -1) {
 		if (index < dev->caps.num_mgms)
 			mlx4_warn(dev, "Got AMGM index %d < %d",
@@ -260,6 +724,7 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	int i, loc;
 	int err;
 	u8 port = gid[5];
+	bool removed_entry = false;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -279,6 +744,11 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		goto out;
 	}
 
+	/* if this pq is also a promisc qp, it shouldn't be removed */
+	if (prot == MLX4_PROT_ETH &&
+	    check_duplicate_entry(dev, 0, port, steer, index, qp->qpn))
+		goto out;
+
 	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
 	for (loc = -1, i = 0; i < members_count; ++i)
 		if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qp->qpn)
@@ -295,11 +765,16 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	mgm->qp[loc]       = mgm->qp[i - 1];
 	mgm->qp[i - 1]     = 0;
 
-	if (i != 1) {
+	if (prot == MLX4_PROT_ETH)
+		removed_entry = can_remove_steering_entry(dev, 0, port, steer, index, qp->qpn);
+	if (i != 1 && (prot != MLX4_PROT_ETH || !removed_entry)) {
 		err = mlx4_WRITE_ENTRY(dev, index, mailbox);
 		goto out;
 	}
 
+	/* We are going to delete the entry, members count should be 0 */
+	mgm->members_count = cpu_to_be32((u32) prot << 30);
+
 	if (prev == -1) {
 		/* Remove entry from MGM */
 		int amgm_index = be32_to_cpu(mgm->next_gid_index) >> 6;
@@ -388,6 +863,46 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
+
+int mlx4_multicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port)
+{
+	if (!dev->caps.vep_mc_steering)
+		return 0;
+
+
+	return add_promisc_qp(dev, 0, port, MLX4_MC_STEER, qpn);
+}
+EXPORT_SYMBOL_GPL(mlx4_multicast_promisc_add);
+
+int mlx4_multicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port)
+{
+	if (!dev->caps.vep_mc_steering)
+		return 0;
+
+
+	return remove_promisc_qp(dev, 0, port, MLX4_MC_STEER, qpn);
+}
+EXPORT_SYMBOL_GPL(mlx4_multicast_promisc_remove);
+
+int mlx4_unicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port)
+{
+	if (!dev->caps.vep_mc_steering)
+		return 0;
+
+
+	return add_promisc_qp(dev, 0, port, MLX4_UC_STEER, qpn);
+}
+EXPORT_SYMBOL_GPL(mlx4_unicast_promisc_add);
+
+int mlx4_unicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port)
+{
+	if (!dev->caps.vep_mc_steering)
+		return 0;
+
+	return remove_promisc_qp(dev, 0, port, MLX4_UC_STEER, qpn);
+}
+EXPORT_SYMBOL_GPL(mlx4_unicast_promisc_remove);
+
 int mlx4_init_mcg_table(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 67ee8da..1513a91 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -162,6 +162,27 @@ struct mlx4_fw {
 	u8			catas_bar;
 };
 
+#define MGM_QPN_MASK       0x00FFFFFF
+#define MGM_BLCK_LB_BIT    30
+
+struct mlx4_promisc_qp {
+	struct list_head list;
+	u32 qpn;
+};
+
+struct mlx4_steer_index {
+	struct list_head list;
+	unsigned int index;
+	struct list_head duplicates;
+};
+
+struct mlx4_mgm {
+	__be32			next_gid_index;
+	__be32			members_count;
+	u32			reserved[2];
+	u8			gid[16];
+	__be32			qp[MLX4_QP_PER_MGM];
+};
 struct mlx4_cmd {
 	struct pci_pool	       *pool;
 	void __iomem	       *hcr;
@@ -287,6 +308,12 @@ struct mlx4_msix_ctl {
 	spinlock_t	pool_lock;
 };
 
+struct mlx4_steer {
+	struct list_head promisc_qps[MLX4_NUM_STEERS];
+	struct list_head steer_entries[MLX4_NUM_STEERS];
+	struct list_head high_prios;
+};
+
 struct mlx4_priv {
 	struct mlx4_dev		dev;
 
@@ -319,6 +346,7 @@ struct mlx4_priv {
 	struct mlx4_sense       sense;
 	struct mutex		port_mutex;
 	struct mlx4_msix_ctl	msix_ctl;
+	struct mlx4_steer	*steer;
 };
 
 static inline struct mlx4_priv *mlx4_priv(struct mlx4_dev *dev)
@@ -409,4 +437,9 @@ void mlx4_init_vlan_table(struct mlx4_dev *dev, struct mlx4_vlan_table *table);
 int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port);
 int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps);
 
+int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  enum mlx4_protocol prot, enum mlx4_steer_type steer);
+int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  int block_mcast_loopback, enum mlx4_protocol prot,
+			  enum mlx4_steer_type steer);
 #endif /* MLX4_H */
-- 
1.6.0.2




