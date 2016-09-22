From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 net-next 2/2] bnx2x: allocate mac filtering pending list in PAGE_SIZE increments
Date: Thu, 22 Sep 2016 17:12:26 -0400
Message-ID: <99fc6a1f17dc200a1de23e1c57d1f6dfb4cfcd96.1474577624.git.jbaron@akamai.com>
References: <cover.1474577624.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
        Yuval.Mintz@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:61569 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754122AbcIVVNC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 17:13:02 -0400
In-Reply-To: <cover.1474577624.git.jbaron@akamai.com>
In-Reply-To: <cover.1474577624.git.jbaron@akamai.com>
References: <cover.1474577624.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

Currently, we can have high order page allocations that specify
GFP_ATOMIC when configuring multicast MAC address filters.

For example, we have seen order 2 page allocation failures with
~500 multicast addresses configured.

Convert the allocation for the pending list to be done in PAGE_SIZE
increments.

Signed-off-by: Jason Baron <jbaron@akamai.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c | 123 +++++++++++++++++--------
 1 file changed, 86 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index d468380c2a23..4947a9cbf0c1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -2606,8 +2606,23 @@ struct bnx2x_mcast_bin_elem {
 	int type; /* BNX2X_MCAST_CMD_SET_{ADD, DEL} */
 };
 
+union bnx2x_mcast_elem {
+	struct bnx2x_mcast_bin_elem bin_elem;
+	struct bnx2x_mcast_mac_elem mac_elem;
+};
+
+struct bnx2x_mcast_elem_group {
+	struct list_head mcast_group_link;
+	union bnx2x_mcast_elem mcast_elems[];
+};
+
+#define MCAST_MAC_ELEMS_PER_PG \
+	((PAGE_SIZE - sizeof(struct bnx2x_mcast_elem_group)) / \
+	sizeof(union bnx2x_mcast_elem))
+
 struct bnx2x_pending_mcast_cmd {
 	struct list_head link;
+	struct list_head group_head;
 	int type; /* BNX2X_MCAST_CMD_X */
 	union {
 		struct list_head macs_head;
@@ -2638,16 +2653,29 @@ static int bnx2x_mcast_wait(struct bnx2x *bp,
 	return 0;
 }
 
+static void bnx2x_free_groups(struct list_head *mcast_group_list)
+{
+	struct bnx2x_mcast_elem_group *current_mcast_group;
+
+	while (!list_empty(mcast_group_list)) {
+		current_mcast_group = list_first_entry(mcast_group_list,
+				      struct bnx2x_mcast_elem_group,
+				      mcast_group_link);
+		list_del(&current_mcast_group->mcast_group_link);
+		free_page((unsigned long)current_mcast_group);
+	}
+}
+
 static int bnx2x_mcast_enqueue_cmd(struct bnx2x *bp,
 				   struct bnx2x_mcast_obj *o,
 				   struct bnx2x_mcast_ramrod_params *p,
 				   enum bnx2x_mcast_cmd cmd)
 {
-	int total_sz;
 	struct bnx2x_pending_mcast_cmd *new_cmd;
-	struct bnx2x_mcast_mac_elem *cur_mac = NULL;
 	struct bnx2x_mcast_list_elem *pos;
-	int macs_list_len = 0, macs_list_len_size;
+	struct bnx2x_mcast_elem_group *elem_group;
+	struct bnx2x_mcast_mac_elem *mac_elem;
+	int total_elems = 0, macs_list_len = 0, offset = 0;
 
 	/* When adding MACs we'll need to store their values */
 	if (cmd == BNX2X_MCAST_CMD_ADD || cmd == BNX2X_MCAST_CMD_SET)
@@ -2657,50 +2685,61 @@ static int bnx2x_mcast_enqueue_cmd(struct bnx2x *bp,
 	if (!p->mcast_list_len)
 		return 0;
 
-	/* For a set command, we need to allocate sufficient memory for all
-	 * the bins, since we can't analyze at this point how much memory would
-	 * be required.
-	 */
-	macs_list_len_size = macs_list_len *
-			     sizeof(struct bnx2x_mcast_mac_elem);
-	if (cmd == BNX2X_MCAST_CMD_SET) {
-		int bin_size = BNX2X_MCAST_BINS_NUM *
-			       sizeof(struct bnx2x_mcast_bin_elem);
-
-		if (bin_size > macs_list_len_size)
-			macs_list_len_size = bin_size;
-	}
-	total_sz = sizeof(*new_cmd) + macs_list_len_size;
-
 	/* Add mcast is called under spin_lock, thus calling with GFP_ATOMIC */
-	new_cmd = kzalloc(total_sz, GFP_ATOMIC);
-
+	new_cmd = kzalloc(sizeof(*new_cmd), GFP_ATOMIC);
 	if (!new_cmd)
 		return -ENOMEM;
 
-	DP(BNX2X_MSG_SP, "About to enqueue a new %d command. macs_list_len=%d\n",
-	   cmd, macs_list_len);
-
 	INIT_LIST_HEAD(&new_cmd->data.macs_head);
-
+	INIT_LIST_HEAD(&new_cmd->group_head);
 	new_cmd->type = cmd;
 	new_cmd->done = false;
 
+	DP(BNX2X_MSG_SP, "About to enqueue a new %d command. macs_list_len=%d\n",
+	   cmd, macs_list_len);
+
 	switch (cmd) {
 	case BNX2X_MCAST_CMD_ADD:
 	case BNX2X_MCAST_CMD_SET:
-		cur_mac = (struct bnx2x_mcast_mac_elem *)
-			  ((u8 *)new_cmd + sizeof(*new_cmd));
-
-		/* Push the MACs of the current command into the pending command
-		 * MACs list: FIFO
+		/* For a set command, we need to allocate sufficient memory for
+		 * all the bins, since we can't analyze at this point how much
+		 * memory would be required.
 		 */
+		total_elems = macs_list_len;
+		if (cmd == BNX2X_MCAST_CMD_SET) {
+			if (total_elems < BNX2X_MCAST_BINS_NUM)
+				total_elems = BNX2X_MCAST_BINS_NUM;
+		}
+		while (total_elems > 0) {
+			elem_group = (struct bnx2x_mcast_elem_group *)
+				     __get_free_page(GFP_ATOMIC | __GFP_ZERO);
+			if (!elem_group) {
+				kfree(new_cmd);
+				bnx2x_free_groups(&new_cmd->group_head);
+				return -ENOMEM;
+			}
+			total_elems -= MCAST_MAC_ELEMS_PER_PG;
+			list_add_tail(&elem_group->mcast_group_link,
+				      &new_cmd->group_head);
+		}
+		elem_group = list_first_entry(&new_cmd->group_head,
+					      struct bnx2x_mcast_elem_group,
+					      mcast_group_link);
 		list_for_each_entry(pos, &p->mcast_list, link) {
-			memcpy(cur_mac->mac, pos->mac, ETH_ALEN);
-			list_add_tail(&cur_mac->link, &new_cmd->data.macs_head);
-			cur_mac++;
+			mac_elem = &elem_group->mcast_elems[offset].mac_elem;
+			memcpy(mac_elem->mac, pos->mac, ETH_ALEN);
+			/* Push the MACs of the current command into the pending
+			 * command MACs list: FIFO
+			 */
+			list_add_tail(&mac_elem->link,
+				      &new_cmd->data.macs_head);
+			offset++;
+			if (offset == MCAST_MAC_ELEMS_PER_PG) {
+				offset = 0;
+				elem_group = list_next_entry(elem_group,
+							     mcast_group_link);
+			}
 		}
-
 		break;
 
 	case BNX2X_MCAST_CMD_DEL:
@@ -2978,7 +3017,8 @@ bnx2x_mcast_hdl_pending_set_e2_convert(struct bnx2x *bp,
 	u64 cur[BNX2X_MCAST_VEC_SZ], req[BNX2X_MCAST_VEC_SZ];
 	struct bnx2x_mcast_mac_elem *pmac_pos, *pmac_pos_n;
 	struct bnx2x_mcast_bin_elem *p_item;
-	int i, cnt = 0, mac_cnt = 0;
+	struct bnx2x_mcast_elem_group *elem_group;
+	int cnt = 0, mac_cnt = 0, offset = 0, i;
 
 	memset(req, 0, sizeof(u64) * BNX2X_MCAST_VEC_SZ);
 	memcpy(cur, o->registry.aprox_match.vec,
@@ -3001,9 +3041,10 @@ bnx2x_mcast_hdl_pending_set_e2_convert(struct bnx2x *bp,
 	 * a list that will be used to configure bins.
 	 */
 	cmd_pos->set_convert = true;
-	p_item = (struct bnx2x_mcast_bin_elem *)(cmd_pos + 1);
 	INIT_LIST_HEAD(&cmd_pos->data.macs_head);
-
+	elem_group = list_first_entry(&cmd_pos->group_head,
+				      struct bnx2x_mcast_elem_group,
+				      mcast_group_link);
 	for (i = 0; i < BNX2X_MCAST_BINS_NUM; i++) {
 		bool b_current = !!BIT_VEC64_TEST_BIT(cur, i);
 		bool b_required = !!BIT_VEC64_TEST_BIT(req, i);
@@ -3011,12 +3052,18 @@ bnx2x_mcast_hdl_pending_set_e2_convert(struct bnx2x *bp,
 		if (b_current == b_required)
 			continue;
 
+		p_item = &elem_group->mcast_elems[offset].bin_elem;
 		p_item->bin = i;
 		p_item->type = b_required ? BNX2X_MCAST_CMD_SET_ADD
 					  : BNX2X_MCAST_CMD_SET_DEL;
 		list_add_tail(&p_item->link , &cmd_pos->data.macs_head);
-		p_item++;
 		cnt++;
+		offset++;
+		if (offset == MCAST_MAC_ELEMS_PER_PG) {
+			offset = 0;
+			elem_group = list_next_entry(elem_group,
+						     mcast_group_link);
+		}
 	}
 
 	/* We now definitely know how many commands are hiding here.
@@ -3103,6 +3150,7 @@ static inline int bnx2x_mcast_handle_pending_cmds_e2(struct bnx2x *bp,
 		 */
 		if (cmd_pos->done) {
 			list_del(&cmd_pos->link);
+			bnx2x_free_groups(&cmd_pos->group_head);
 			kfree(cmd_pos);
 		}
 
@@ -3741,6 +3789,7 @@ static inline int bnx2x_mcast_handle_pending_cmds_e1(
 	}
 
 	list_del(&cmd_pos->link);
+	bnx2x_free_groups(&cmd_pos->group_head);
 	kfree(cmd_pos);
 
 	return cnt;
-- 
2.6.1
