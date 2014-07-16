From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/5] net/mlx4_core: In SR-IOV mode host should add promisc QP to default entry only
Date: Wed, 16 Jul 2014 11:57:50 +0300
Message-ID: <1405501071-9340-5-git-send-email-amirv@mellanox.com>
References: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:35191 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759732AbaGPI6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 04:58:12 -0400
In-Reply-To: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

In current situation host is adding the promiscuous QP to all steering
entries and the default entry as well. In this case when having PV
and SR-IOV on the same setup bridge will receive all traffic that is
targeted to the other VMs. This is bad.
Solution: In SR-IOV mode host can add promiscuous QP to default entry only.
The above problem and fix are relevant for B0 steering mode only.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 169 ++++++++++++++++++-------------
 1 file changed, 99 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 39ab85a..9d92bc2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -433,43 +433,58 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 	}
 	mgm = mailbox->buf;
 
-	/* the promisc qp needs to be added for each one of the steering
-	 * entries, if it already exists, needs to be added as a duplicate
-	 * for this entry */
-	list_for_each_entry(entry, &s_steer->steer_entries[steer], list) {
-		err = mlx4_READ_ENTRY(dev, entry->index, mailbox);
-		if (err)
-			goto out_mailbox;
+	if (!(mlx4_is_mfunc(dev) && steer == MLX4_UC_STEER)) {
+		/* The promisc QP needs to be added for each one of the steering
+		 * entries. If it already exists, needs to be added as
+		 * a duplicate for this entry.
+		 */
+		list_for_each_entry(entry,
+				    &s_steer->steer_entries[steer],
+				    list) {
+			err = mlx4_READ_ENTRY(dev, entry->index, mailbox);
+			if (err)
+				goto out_mailbox;
 
-		members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
-		prot = be32_to_cpu(mgm->members_count) >> 30;
-		found = false;
-		for (i = 0; i < members_count; i++) {
-			if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qpn) {
-				/* Entry already exists, add to duplicates */
-				dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
-				if (!dqp) {
+			members_count = be32_to_cpu(mgm->members_count) &
+					0xffffff;
+			prot = be32_to_cpu(mgm->members_count) >> 30;
+			found = false;
+			for (i = 0; i < members_count; i++) {
+				if ((be32_to_cpu(mgm->qp[i]) &
+				     MGM_QPN_MASK) == qpn) {
+					/* Entry already exists.
+					 * Add to duplicates.
+					 */
+					dqp = kmalloc(sizeof(*dqp), GFP_KERNEL);
+					if (!dqp) {
+						err = -ENOMEM;
+						goto out_mailbox;
+					}
+					dqp->qpn = qpn;
+					list_add_tail(&dqp->list,
+						      &entry->duplicates);
+					found = true;
+				}
+			}
+			if (!found) {
+				/* Need to add the qpn to mgm */
+				if (members_count ==
+				    dev->caps.num_qp_per_mgm) {
+					/* entry is full */
 					err = -ENOMEM;
 					goto out_mailbox;
 				}
-				dqp->qpn = qpn;
-				list_add_tail(&dqp->list, &entry->duplicates);
-				found = true;
+				mgm->qp[members_count++] =
+					cpu_to_be32(qpn & MGM_QPN_MASK);
+				mgm->members_count =
+					cpu_to_be32(members_count |
+						    (prot << 30));
+				err = mlx4_WRITE_ENTRY(dev, entry->index,
+						       mailbox);
+				if (err)
+					goto out_mailbox;
 			}
 		}
-		if (!found) {
-			/* Need to add the qpn to mgm */
-			if (members_count == dev->caps.num_qp_per_mgm) {
-				/* entry is full */
-				err = -ENOMEM;
-				goto out_mailbox;
-			}
-			mgm->qp[members_count++] = cpu_to_be32(qpn & MGM_QPN_MASK);
-			mgm->members_count = cpu_to_be32(members_count | (prot << 30));
-			err = mlx4_WRITE_ENTRY(dev, entry->index, mailbox);
-			if (err)
-				goto out_mailbox;
-		}
 	}
 
 	/* add the new qpn to list of promisc qps */
@@ -556,51 +571,65 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 	if (err)
 		goto out_mailbox;
 
-	/* remove the qp from all the steering entries*/
-	list_for_each_entry(entry, &s_steer->steer_entries[steer], list) {
-		found = false;
-		list_for_each_entry(dqp, &entry->duplicates, list) {
-			if (dqp->qpn == qpn) {
-				found = true;
-				break;
+	if (!(mlx4_is_mfunc(dev) && steer == MLX4_UC_STEER)) {
+		/* remove the qp from all the steering entries*/
+		list_for_each_entry(entry,
+				    &s_steer->steer_entries[steer],
+				    list) {
+			found = false;
+			list_for_each_entry(dqp, &entry->duplicates, list) {
+				if (dqp->qpn == qpn) {
+					found = true;
+					break;
+				}
 			}
-		}
-		if (found) {
-			/* a duplicate, no need to change the mgm,
-			 * only update the duplicates list */
-			list_del(&dqp->list);
-			kfree(dqp);
-		} else {
-			int loc = -1;
-			err = mlx4_READ_ENTRY(dev, entry->index, mailbox);
-				if (err)
+			if (found) {
+				/* A duplicate, no need to change the MGM,
+				 * only update the duplicates list
+				 */
+				list_del(&dqp->list);
+				kfree(dqp);
+			} else {
+				int loc = -1;
+
+				err = mlx4_READ_ENTRY(dev,
+						      entry->index,
+						      mailbox);
+					if (err)
+						goto out_mailbox;
+				members_count =
+					be32_to_cpu(mgm->members_count) &
+					0xffffff;
+				for (i = 0; i < members_count; ++i)
+					if ((be32_to_cpu(mgm->qp[i]) &
+					     MGM_QPN_MASK) == qpn) {
+						loc = i;
+						break;
+					}
+
+				if (loc < 0) {
+					mlx4_err(dev, "QP %06x wasn't found in entry %d\n",
+						 qpn, entry->index);
+					err = -EINVAL;
 					goto out_mailbox;
-			members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
-			for (i = 0; i < members_count; ++i)
-				if ((be32_to_cpu(mgm->qp[i]) &
-				     MGM_QPN_MASK) == qpn) {
-					loc = i;
-					break;
 				}
 
-			if (loc < 0) {
-				mlx4_err(dev, "QP %06x wasn't found in entry %d\n",
-					 qpn, entry->index);
-				err = -EINVAL;
-				goto out_mailbox;
+				/* copy the last QP in this MGM
+				 * over removed QP
+				 */
+				mgm->qp[loc] = mgm->qp[members_count - 1];
+				mgm->qp[members_count - 1] = 0;
+				mgm->members_count =
+					cpu_to_be32(--members_count |
+						    (MLX4_PROT_ETH << 30));
+
+				err = mlx4_WRITE_ENTRY(dev,
+						       entry->index,
+						       mailbox);
+					if (err)
+						goto out_mailbox;
 			}
-
-			/* copy the last QP in this MGM over removed QP */
-			mgm->qp[loc] = mgm->qp[members_count - 1];
-			mgm->qp[members_count - 1] = 0;
-			mgm->members_count = cpu_to_be32(--members_count |
-							 (MLX4_PROT_ETH << 30));
-
-			err = mlx4_WRITE_ENTRY(dev, entry->index, mailbox);
-				if (err)
-					goto out_mailbox;
 		}
-
 	}
 
 out_mailbox:
-- 
1.8.3.4
