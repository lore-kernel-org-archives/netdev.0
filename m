From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list in PAGE_SIZE increments
Date: Fri, 16 Sep 2016 17:30:34 -0400
Message-ID: <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
References: <cover.1474060371.git.jbaron@akamai.com>
Cc: Yuval.Mintz@qlogic.com, netdev@vger.kernel.org
To: davem@davemloft.net, Ariel.Elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:52349 "EHLO
        prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752001AbcIPVkD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 17:40:03 -0400
In-Reply-To: <cover.1474060371.git.jbaron@akamai.com>
In-Reply-To: <cover.1474060371.git.jbaron@akamai.com>
References: <cover.1474060371.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we can have high order page allocations that specify
GFP_ATOMIC when configuring multicast MAC address filters.

For example, we have seen order 2 page allocation failures with
~500 multicast addresses configured.

Convert the allocation for the pending list to be done in PAGE_SIZE
increments.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c | 131 ++++++++++++++++++-------
 1 file changed, 94 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index d468380c2a23..6db8dd252d7c 100644
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
@@ -2638,16 +2653,30 @@ static int bnx2x_mcast_wait(struct bnx2x *bp,
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
+		kfree(current_mcast_group);
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
+	int i = 0, offset = 0, macs_list_len = 0;
+	int total_elems, alloc_size;
 
 	/* When adding MACs we'll need to store their values */
 	if (cmd == BNX2X_MCAST_CMD_ADD || cmd == BNX2X_MCAST_CMD_SET)
@@ -2657,50 +2686,68 @@ static int bnx2x_mcast_enqueue_cmd(struct bnx2x *bp,
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
+		i = total_elems;
+		while (i) {
+			if (i < MCAST_MAC_ELEMS_PER_PG) {
+				alloc_size = sizeof(struct list_head) +
+					     i * sizeof(union bnx2x_mcast_elem);
+				i = 0;
+			} else {
+				alloc_size = PAGE_SIZE;
+				i -= MCAST_MAC_ELEMS_PER_PG;
+			}
+			elem_group = kzalloc(alloc_size, GFP_ATOMIC);
+			if (!elem_group) {
+				bnx2x_free_groups(&new_cmd->group_head);
+				kfree(new_cmd);
+				return -ENOMEM;
+			}
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
+				elem_group = (struct bnx2x_mcast_elem_group *)
+					     elem_group->mcast_group_link.next;
+			}
 		}
-
 		break;
 
 	case BNX2X_MCAST_CMD_DEL:
@@ -2978,7 +3025,8 @@ bnx2x_mcast_hdl_pending_set_e2_convert(struct bnx2x *bp,
 	u64 cur[BNX2X_MCAST_VEC_SZ], req[BNX2X_MCAST_VEC_SZ];
 	struct bnx2x_mcast_mac_elem *pmac_pos, *pmac_pos_n;
 	struct bnx2x_mcast_bin_elem *p_item;
-	int i, cnt = 0, mac_cnt = 0;
+	struct bnx2x_mcast_elem_group *elem_group;
+	int cnt = 0, mac_cnt = 0, offset = 0, i;
 
 	memset(req, 0, sizeof(u64) * BNX2X_MCAST_VEC_SZ);
 	memcpy(cur, o->registry.aprox_match.vec,
@@ -3001,9 +3049,10 @@ bnx2x_mcast_hdl_pending_set_e2_convert(struct bnx2x *bp,
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
@@ -3011,12 +3060,18 @@ bnx2x_mcast_hdl_pending_set_e2_convert(struct bnx2x *bp,
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
+			elem_group = (struct bnx2x_mcast_elem_group *)
+				     elem_group->mcast_group_link.next;
+		}
 	}
 
 	/* We now definitely know how many commands are hiding here.
@@ -3103,6 +3158,7 @@ static inline int bnx2x_mcast_handle_pending_cmds_e2(struct bnx2x *bp,
 		 */
 		if (cmd_pos->done) {
 			list_del(&cmd_pos->link);
+			bnx2x_free_groups(&cmd_pos->group_head);
 			kfree(cmd_pos);
 		}
 
@@ -3741,6 +3797,7 @@ static inline int bnx2x_mcast_handle_pending_cmds_e1(
 	}
 
 	list_del(&cmd_pos->link);
+	bnx2x_free_groups(&cmd_pos->group_head);
 	kfree(cmd_pos);
 
 	return cnt;
-- 
2.6.1
