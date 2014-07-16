From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 5/5] net/mlx4_core: Remove MCG in case it is attached to promiscuous QPs only
Date: Wed, 16 Jul 2014 11:57:51 +0300
Message-ID: <1405501071-9340-6-git-send-email-amirv@mellanox.com>
References: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50772 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761174AbaGPI6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 04:58:13 -0400
In-Reply-To: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

In B0 steering mode if promiscuous QP asks to be detached from MCG entry,
and it is the only one in this entry then the entry will never be deleted.
This is a wrong behavior since we don't want to keep those entries after
the promiscuous QP becomes non-promiscuous. Therefore remove steering
entry containing only promiscuous QP.


Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 88 ++++++++++++++++++++++----------
 1 file changed, 62 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 9d92bc2..d80e7a6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -270,7 +270,7 @@ static int existing_steering_entry(struct mlx4_dev *dev, u8 port,
 	 * we need to add it as a duplicate to this entry
 	 * for future references */
 	list_for_each_entry(dqp, &entry->duplicates, list) {
-		if (qpn == pqp->qpn)
+		if (qpn == dqp->qpn)
 			return 0; /* qp is already duplicated */
 	}
 
@@ -324,24 +324,22 @@ static bool check_duplicate_entry(struct mlx4_dev *dev, u8 port,
 	return true;
 }
 
-/* I a steering entry contains only promisc QPs, it can be removed. */
-static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
-				      enum mlx4_steer_type steer,
-				      unsigned int index, u32 tqpn)
+/* Returns true if all the QPs != tqpn contained in this entry
+ * are Promisc QPs. Returns false otherwise.
+ */
+static bool promisc_steering_entry(struct mlx4_dev *dev, u8 port,
+				   enum mlx4_steer_type steer,
+				   unsigned int index, u32 tqpn,
+				   u32 *members_count)
 {
-	struct mlx4_steer *s_steer;
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mgm *mgm;
-	struct mlx4_steer_index *entry = NULL, *tmp_entry;
-	u32 qpn;
-	u32 members_count;
+	u32 m_count;
 	bool ret = false;
 	int i;
 
 	if (port < 1 || port > dev->caps.num_ports)
-		return NULL;
-
-	s_steer = &mlx4_priv(dev)->steer[port - 1];
+		return false;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -350,15 +348,43 @@ static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
 
 	if (mlx4_READ_ENTRY(dev, index, mailbox))
 		goto out;
-	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
-	for (i = 0;  i < members_count; i++) {
-		qpn = be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK;
+	m_count = be32_to_cpu(mgm->members_count) & 0xffffff;
+	if (members_count)
+		*members_count = m_count;
+
+	for (i = 0;  i < m_count; i++) {
+		u32 qpn = be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK;
 		if (!get_promisc_qp(dev, port, steer, qpn) && qpn != tqpn) {
 			/* the qp is not promisc, the entry can't be removed */
 			goto out;
 		}
 	}
-	 /* All the qps currently registered for this entry are promiscuous,
+	ret = true;
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return ret;
+}
+
+/* IF a steering entry contains only promisc QPs, it can be removed. */
+static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
+				      enum mlx4_steer_type steer,
+				      unsigned int index, u32 tqpn)
+{
+	struct mlx4_steer *s_steer;
+	struct mlx4_steer_index *entry = NULL, *tmp_entry;
+	u32 members_count;
+	bool ret = false;
+
+	if (port < 1 || port > dev->caps.num_ports)
+		return NULL;
+
+	s_steer = &mlx4_priv(dev)->steer[port - 1];
+
+	if (!promisc_steering_entry(dev, port, steer, index,
+				    tqpn, &members_count))
+		goto out;
+
+	/* All the qps currently registered for this entry are promiscuous,
 	  * Checking for duplicates */
 	ret = true;
 	list_for_each_entry_safe(entry, tmp_entry, &s_steer->steer_entries[steer], list) {
@@ -387,7 +413,6 @@ static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
 	}
 
 out:
-	mlx4_free_cmd_mailbox(dev, mailbox);
 	return ret;
 }
 
@@ -528,7 +553,7 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 	struct mlx4_steer *s_steer;
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mgm *mgm;
-	struct mlx4_steer_index *entry;
+	struct mlx4_steer_index *entry, *tmp_entry;
 	struct mlx4_promisc_qp *pqp;
 	struct mlx4_promisc_qp *dqp;
 	u32 members_count;
@@ -572,10 +597,10 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 		goto out_mailbox;
 
 	if (!(mlx4_is_mfunc(dev) && steer == MLX4_UC_STEER)) {
-		/* remove the qp from all the steering entries*/
-		list_for_each_entry(entry,
-				    &s_steer->steer_entries[steer],
-				    list) {
+		/* Remove the QP from all the steering entries */
+		list_for_each_entry_safe(entry, tmp_entry,
+					 &s_steer->steer_entries[steer],
+					 list) {
 			found = false;
 			list_for_each_entry(dqp, &entry->duplicates, list) {
 				if (dqp->qpn == qpn) {
@@ -600,6 +625,14 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 				members_count =
 					be32_to_cpu(mgm->members_count) &
 					0xffffff;
+				if (!members_count) {
+					mlx4_warn(dev, "QP %06x wasn't found in entry %x mcount=0. deleting entry...\n",
+						  qpn, entry->index);
+					list_del(&entry->list);
+					kfree(entry);
+					continue;
+				}
+
 				for (i = 0; i < members_count; ++i)
 					if ((be32_to_cpu(mgm->qp[i]) &
 					     MGM_QPN_MASK) == qpn) {
@@ -614,7 +647,7 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 					goto out_mailbox;
 				}
 
-				/* copy the last QP in this MGM
+				/* Copy the last QP in this MGM
 				 * over removed QP
 				 */
 				mgm->qp[loc] = mgm->qp[members_count - 1];
@@ -1144,10 +1177,13 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		goto out;
 	}
 
-	/* if this pq is also a promisc qp, it shouldn't be removed */
+	/* If this QP is also a promisc QP, it shouldn't be removed only if
+	 * at least one none promisc QP is also attached to this MCG
+	 */
 	if (prot == MLX4_PROT_ETH &&
-	    check_duplicate_entry(dev, port, steer, index, qp->qpn))
-		goto out;
+	    check_duplicate_entry(dev, port, steer, index, qp->qpn) &&
+	    !promisc_steering_entry(dev, port, steer, index, qp->qpn, NULL))
+			goto out;
 
 	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
 	for (i = 0; i < members_count; ++i)
-- 
1.8.3.4
