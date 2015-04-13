From: sfeldma@gmail.com
Subject: [PATCH net-next v4 03/24] switchdev: convert STP update to swdev attr set
Date: Sun, 12 Apr 2015 23:16:57 -0700
Message-ID: <1428905838-14920-4-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34724 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbbDMGQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:36 -0400
Received: by pacyx8 with SMTP id yx8so91983587pac.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:35 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

STP update is just a writable port attribute, so convert swdev_port_stp_update
to an attr set.

For rocker, support prepare-commit transaction model for setting STP state.
This requires rocker to preallocate memory needed for the commit up front in
the prepare phase.  Since rtnl_lock is held between prepare-commit, store the
allocated memory on a queue hanging off of the rocker_port.  Also, in prepare
phase, do everything right up to calling into HW.  The same code paths are
tranversed in the driver for both prepare and commit phases.  In some cases,
any state modified in the prepare phase must be reverted before returning
so the commit phase makes the same decisions.

For DSA, the prepare phase is skipped and STP updates are only done in the
commit phase.  This is because currently the DSA drivers don't need to allocate
any memory for STP updates and the STP update will not fail to HW (unless
something horrible goes wrong on the MDIO bus, in which case the prepare phase
wouldn't have been able to predict anyway).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |  244 ++++++++++++++++++++++++++--------
 include/net/switchdev.h              |   13 +-
 net/bridge/br_stp.c                  |    6 +-
 net/dsa/slave.c                      |   20 ++-
 net/switchdev/switchdev.c            |   28 ----
 5 files changed, 216 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 1c468df..80c7f6f 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -225,6 +225,8 @@ struct rocker_port {
 	struct napi_struct napi_rx;
 	struct rocker_dma_ring_info tx_ring;
 	struct rocker_dma_ring_info rx_ring;
+	enum swdev_trans trans;
+	struct list_head trans_mem;
 };
 
 struct rocker {
@@ -325,6 +327,72 @@ static bool rocker_port_is_bridged(struct rocker_port *rocker_port)
 	return !!rocker_port->bridge_dev;
 }
 
+static void *__rocker_port_alloc(struct rocker_port *rocker_port,
+				 size_t size, gfp_t flags,
+				 void *(*alloc)(size_t size, gfp_t flags))
+{
+	struct list_head *elem = NULL;
+
+	/* If in transaction prepare phase, allocate the memory
+	 * and enqueue it on a per-port list.  If in transaction
+	 * commit phase, dequeue the memory from the per-port list
+	 * rather than re-allocating the memory.  The idea is the
+	 * driver code paths for prepare and commit are identical
+	 * so the memory allocated in the prepare phase is the
+	 * memory used in the commit phase.
+	 */
+
+	switch (rocker_port->trans) {
+	case SWDEV_TRANS_PREPARE:
+		elem = alloc(size + sizeof(*elem), flags);
+		if (!elem)
+			return NULL;
+		list_add_tail(elem, &rocker_port->trans_mem);
+		break;
+	case SWDEV_TRANS_COMMIT:
+		BUG_ON(list_empty(&rocker_port->trans_mem));
+		elem = rocker_port->trans_mem.next;
+		list_del_init(elem);
+		break;
+	case SWDEV_TRANS_NONE:
+		elem = alloc(size + sizeof(*elem), flags);
+		if (elem)
+			INIT_LIST_HEAD(elem);
+		break;
+	}
+
+	return elem ? elem + 1 : NULL;
+}
+
+static void *rocker_port_kzalloc(struct rocker_port *rocker_port,
+				 size_t size, gfp_t flags)
+{
+	return __rocker_port_alloc(rocker_port, size, flags, kzalloc);
+}
+
+static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
+				 size_t n, size_t size, gfp_t flags)
+{
+	return __rocker_port_alloc(rocker_port, n * size, flags, kzalloc);
+}
+
+static void rocker_port_kfree(struct rocker_port *rocker_port, const void *mem)
+{
+	struct list_head *elem;
+
+	/* Frees are ignored if in transaction prepare phase.  The
+	 * memory remains on the per-port list until freed in the
+	 * commit phase.
+	 */
+
+	if (rocker_port->trans == SWDEV_TRANS_PREPARE)
+		return;
+
+	elem = (struct list_head *)mem - 1;
+	BUG_ON(!list_empty(elem));
+	kfree(elem);
+}
+
 struct rocker_wait {
 	wait_queue_head_t wait;
 	bool done;
@@ -354,9 +422,9 @@ static struct rocker_wait *rocker_wait_create(gfp_t gfp)
 	return wait;
 }
 
-static void rocker_wait_destroy(struct rocker_wait *work)
+static void rocker_wait_destroy(struct rocker_wait *wait)
 {
-	kfree(work);
+	kfree(wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -2325,7 +2393,7 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 	if (found) {
 		match->cookie = found->cookie;
 		hash_del(&found->entry);
-		kfree(found);
+		rocker_port_kfree(rocker_port, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -2366,13 +2434,13 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
-	kfree(match);
+	rocker_port_kfree(rocker_port, match);
 
 	if (found) {
 		err = rocker_cmd_exec(rocker, rocker_port,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL, nowait);
-		kfree(found);
+		rocker_port_kfree(rocker_port, found);
 	}
 
 	return err;
@@ -2388,6 +2456,9 @@ static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
 {
 	bool nowait = flags & ROCKER_OP_FLAG_NOWAIT;
 
+	if (rocker_port->trans == SWDEV_TRANS_PREPARE)
+		return 0;
+
 	if (flags & ROCKER_OP_FLAG_REMOVE)
 		return rocker_flow_tbl_del(rocker_port, entry, nowait);
 	else
@@ -2400,7 +2471,8 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2421,7 +2493,8 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2447,7 +2520,8 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2487,7 +2561,8 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2536,7 +2611,8 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2567,7 +2643,8 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	u32 priority;
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2620,17 +2697,18 @@ rocker_group_tbl_find(struct rocker *rocker,
 	return NULL;
 }
 
-static void rocker_group_tbl_entry_free(struct rocker_group_tbl_entry *entry)
+static void rocker_group_tbl_entry_free(struct rocker_port *rocker_port,
+					struct rocker_group_tbl_entry *entry)
 {
 	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		kfree(entry->group_ids);
+		rocker_port_kfree(rocker_port, entry->group_ids);
 		break;
 	default:
 		break;
 	}
-	kfree(entry);
+	rocker_port_kfree(rocker_port, entry);
 }
 
 static int rocker_group_tbl_add(struct rocker_port *rocker_port,
@@ -2647,7 +2725,7 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 
 	if (found) {
 		hash_del(&found->entry);
-		rocker_group_tbl_entry_free(found);
+		rocker_group_tbl_entry_free(rocker_port, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
 	} else {
@@ -2684,13 +2762,13 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
 
-	rocker_group_tbl_entry_free(match);
+	rocker_group_tbl_entry_free(rocker_port, match);
 
 	if (found) {
 		err = rocker_cmd_exec(rocker, rocker_port,
 				      rocker_cmd_group_tbl_del,
 				      found, NULL, NULL, nowait);
-		rocker_group_tbl_entry_free(found);
+		rocker_group_tbl_entry_free(rocker_port, found);
 	}
 
 	return err;
@@ -2701,6 +2779,9 @@ static int rocker_group_tbl_do(struct rocker_port *rocker_port,
 {
 	bool nowait = flags & ROCKER_OP_FLAG_NOWAIT;
 
+	if (rocker_port->trans == SWDEV_TRANS_PREPARE)
+		return 0;
+
 	if (flags & ROCKER_OP_FLAG_REMOVE)
 		return rocker_group_tbl_del(rocker_port, entry, nowait);
 	else
@@ -2713,7 +2794,8 @@ static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2729,17 +2811,19 @@ static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = kcalloc(group_count, sizeof(u32),
-				   rocker_op_flags_gfp(flags));
+	entry->group_ids = rocker_port_kcalloc(rocker_port, group_count,
+					       sizeof(u32),
+					       rocker_op_flags_gfp(flags));
 	if (!entry->group_ids) {
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
@@ -2764,7 +2848,8 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2802,17 +2887,16 @@ static void _rocker_neigh_add(struct rocker *rocker,
 		 be32_to_cpu(entry->ip_addr));
 }
 
-static void _rocker_neigh_del(struct rocker *rocker,
+static void _rocker_neigh_del(struct rocker_port *rocker_port,
 			      struct rocker_neigh_tbl_entry *entry)
 {
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 	}
 }
 
-static void _rocker_neigh_update(struct rocker *rocker,
-				 struct rocker_neigh_tbl_entry *entry,
+static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
 				 u8 *eth_dst, bool ttl_check)
 {
 	if (eth_dst) {
@@ -2840,7 +2924,8 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	bool removing;
 	int err = 0;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2860,9 +2945,9 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 		_rocker_neigh_add(rocker, entry);
 	} else if (removing) {
 		memcpy(entry, found, sizeof(*entry));
-		_rocker_neigh_del(rocker, found);
+		_rocker_neigh_del(rocker_port, found);
 	} else if (updating) {
-		_rocker_neigh_update(rocker, found, eth_dst, true);
+		_rocker_neigh_update(found, eth_dst, true);
 		memcpy(entry, found, sizeof(*entry));
 	} else {
 		err = -ENOENT;
@@ -2909,7 +2994,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 err_out:
 	if (!adding)
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 
 	return err;
 }
@@ -2952,7 +3037,8 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 	bool resolved = true;
 	int err = 0;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry),
+				    rocker_op_flags_gfp(flags));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2973,9 +3059,9 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
-		_rocker_neigh_del(rocker, found);
+		_rocker_neigh_del(rocker_port, found);
 	} else if (updating) {
-		_rocker_neigh_update(rocker, found, NULL, false);
+		_rocker_neigh_update(found, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
 	} else {
 		err = -ENOENT;
@@ -2984,7 +3070,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 
 	if (err)
 		return err;
@@ -3008,8 +3094,9 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	int err = 0;
 	int i;
 
-	group_ids = kcalloc(rocker->port_count, sizeof(u32),
-			    rocker_op_flags_gfp(flags));
+	group_ids = rocker_port_kcalloc(rocker_port, rocker->port_count,
+					sizeof(u32),
+					rocker_op_flags_gfp(flags));
 	if (!group_ids)
 		return -ENOMEM;
 
@@ -3040,7 +3127,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	kfree(group_ids);
+	rocker_port_kfree(rocker_port, group_ids);
 	return err;
 }
 
@@ -3460,7 +3547,8 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = kzalloc(sizeof(*fdb), rocker_op_flags_gfp(flags));
+	fdb = rocker_port_kzalloc(rocker_port, sizeof(*fdb),
+				  rocker_op_flags_gfp(flags));
 	if (!fdb)
 		return -ENOMEM;
 
@@ -3475,7 +3563,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	found = rocker_fdb_tbl_find(rocker, fdb);
 
 	if (removing && found) {
-		kfree(fdb);
+		rocker_port_kfree(rocker_port, fdb);
 		hash_del(&found->entry);
 	} else if (!removing && !found) {
 		hash_add(rocker->fdb_tbl, &fdb->entry, fdb->key_crc32);
@@ -3485,7 +3573,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		kfree(fdb);
+		rocker_port_kfree(rocker_port, fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
@@ -3500,7 +3588,7 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port)
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_tbl_entry *found;
 	unsigned long lock_flags;
-	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
+	int flags = ROCKER_OP_FLAG_REMOVE;
 	struct hlist_node *tmp;
 	int bkt;
 	int err = 0;
@@ -3568,7 +3656,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 	u32 out_pport;
 	__be16 vlan_id;
 	u16 vid;
-	int flags = ROCKER_OP_FLAG_NOWAIT;
+	int flags = 0;
 	int err;
 
 	/* Port will be forwarding-enabled if its STP state is LEARNING
@@ -3605,10 +3693,17 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
 {
 	bool want[ROCKER_CTRL_MAX] = { 0, };
+	bool prev_ctrls[ROCKER_CTRL_MAX];
+	u8 prev_state;
 	int flags;
 	int err;
 	int i;
 
+	if (rocker_port->trans == SWDEV_TRANS_PREPARE) {
+		memcpy(prev_ctrls, rocker_port->ctrls, sizeof(prev_ctrls));
+		prev_state = rocker_port->stp_state;
+	}
+
 	if (rocker_port->stp_state == state)
 		return 0;
 
@@ -3636,21 +3731,28 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
 
 	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
 		if (want[i] != rocker_port->ctrls[i]) {
-			flags = ROCKER_OP_FLAG_NOWAIT |
-				(want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
+			flags = (want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
 			err = rocker_port_ctrl(rocker_port, flags,
 					       &rocker_ctrls[i]);
 			if (err)
-				return err;
+				goto err_out;
 			rocker_port->ctrls[i] = want[i];
 		}
 	}
 
 	err = rocker_port_fdb_flush(rocker_port);
 	if (err)
-		return err;
+		goto err_out;
 
-	return rocker_port_fwding(rocker_port);
+	err = rocker_port_fwding(rocker_port);
+
+err_out:
+	if (rocker_port->trans == SWDEV_TRANS_PREPARE) {
+		memcpy(rocker_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
+		rocker_port->stp_state = prev_state;
+	}
+
+	return err;
 }
 
 static int rocker_port_fwd_enable(struct rocker_port *rocker_port)
@@ -3696,7 +3798,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int i;
 
-	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return 0;
 
@@ -3706,7 +3808,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 
 	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
 	if (found) {
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 		goto found;
 	}
 
@@ -3751,7 +3853,7 @@ static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
 		bit = ntohs(found->vlan_id) - ROCKER_INTERNAL_VLAN_ID_BASE;
 		clear_bit(bit, rocker->internal_vlan_bitmap);
 		hash_del(&found->entry);
-		kfree(found);
+		rocker_port_kfree(rocker_port, found);
 	}
 
 not_found:
@@ -4237,11 +4339,44 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
 	return 0;
 }
 
-static int rocker_port_swdev_port_stp_update(struct net_device *dev, u8 state)
+static void rocker_port_trans_abort(struct rocker_port *rocker_port)
+{
+	struct list_head *mem, *tmp;
+
+	list_for_each_safe(mem, tmp, &rocker_port->trans_mem) {
+		list_del(mem);
+		kfree(mem);
+	}
+}
+
+static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	rocker_port->trans = attr->trans;
+
+	switch (rocker_port->trans) {
+	case SWDEV_TRANS_PREPARE:
+		BUG_ON(!list_empty(&rocker_port->trans_mem));
+		break;
+	case SWDEV_TRANS_ABORT:
+		rocker_port_trans_abort(rocker_port);
+		return 0;
+	}
 
-	return rocker_port_stp_update(rocker_port, state);
+	switch (attr->id) {
+	case SWDEV_ATTR_PORT_STP_STATE:
+		err = rocker_port_stp_update(rocker_port, attr->stp_state);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	rocker_port->trans = SWDEV_TRANS_NONE;
+
+	return err;
 }
 
 static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
@@ -4271,7 +4406,7 @@ static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
 
 static const struct swdev_ops rocker_port_swdev_ops = {
 	.swdev_port_attr_get		= rocker_port_attr_get,
-	.swdev_port_stp_update		= rocker_port_swdev_port_stp_update,
+	.swdev_port_attr_set		= rocker_port_attr_set,
 	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
 	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
 };
@@ -4624,6 +4759,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->port_number = port_number;
 	rocker_port->pport = port_number + 1;
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
+	INIT_LIST_HEAD(&rocker_port->trans_mem);
 
 	rocker_port_dev_addr_init(rocker, rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index dcacd54..fa553ee 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -26,6 +26,7 @@ enum swdev_trans {
 enum swdev_attr_id {
 	SWDEV_ATTR_UNDEFINED,
 	SWDEV_ATTR_PORT_PARENT_ID,
+	SWDEV_ATTR_PORT_STP_STATE,
 };
 
 struct swdev_attr {
@@ -34,6 +35,7 @@ struct swdev_attr {
 	u32 flags;
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
+		u8 stp_state;				/* PORT_STP_STATE */
 	};
 };
 
@@ -46,9 +48,6 @@ struct fib_info;
  *
  * @swdev_port_attr_set: Set a port attribute (see swdev_attr).
  *
- * @swdev_port_stp_update: Called to notify switch device port of bridge
- *   port STP state change.
- *
  * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
  * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
@@ -58,7 +57,6 @@ struct swdev_ops {
 				       struct swdev_attr *attr);
 	int	(*swdev_port_attr_set)(struct net_device *dev,
 				       struct swdev_attr *attr);
-	int	(*swdev_port_stp_update)(struct net_device *dev, u8 state);
 	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 				      int dst_len, struct fib_info *fi,
 				      u8 tos, u8 type, u32 nlflags,
@@ -93,7 +91,6 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
-int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
@@ -126,12 +123,6 @@ static inline int swdev_port_attr_set(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int netdev_switch_port_stp_update(struct net_device *dev,
-						u8 state)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int register_netdev_switch_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index fb3ebe6..f888dbc 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -39,10 +39,14 @@ void br_log_state(const struct net_bridge_port *p)
 
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
+	struct swdev_attr attr = {
+		.id = SWDEV_ATTR_PORT_STP_STATE,
+		.stp_state = state,
+	};
 	int err;
 
 	p->state = state;
-	err = netdev_switch_port_stp_update(p->dev, state);
+	err = swdev_port_attr_set(p->dev, &attr);
 	if (err && err != -EOPNOTSUPP)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6ff2261..04baa8a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -345,6 +345,24 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 	return ret;
 }
 
+static int dsa_slave_port_attr_set(struct net_device *dev,
+				   struct swdev_attr *attr)
+{
+	int ret = 0;
+
+	switch (attr->id) {
+	case SWDEV_ATTR_PORT_STP_STATE:
+		if (attr->trans == SWDEV_TRANS_COMMIT)
+			ret = dsa_slave_stp_update(dev, attr->stp_state);
+		break;
+	default:
+		ret = -EOPNOTSUPP;
+		break;
+	}
+
+	return ret;
+}
+
 static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
@@ -683,7 +701,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 
 static const struct swdev_ops dsa_slave_swdev_ops = {
 	.swdev_port_attr_get = dsa_slave_port_attr_get,
-	.swdev_port_stp_update = dsa_slave_stp_update,
+	.swdev_port_attr_set = dsa_slave_port_attr_set,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 7d94724..6f81cbf 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -194,34 +194,6 @@ int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(swdev_port_attr_set);
 
-/**
- *	netdev_switch_port_stp_update - Notify switch device port of STP
- *					state change
- *	@dev: port device
- *	@state: port STP state
- *
- *	Notify switch device port of bridge port STP state change.
- */
-int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
-{
-	const struct swdev_ops *ops = dev->swdev_ops;
-	struct net_device *lower_dev;
-	struct list_head *iter;
-	int err = -EOPNOTSUPP;
-
-	if (ops && ops->swdev_port_stp_update)
-		return ops->swdev_port_stp_update(dev, state);
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = netdev_switch_port_stp_update(lower_dev, state);
-		if (err && err != -EOPNOTSUPP)
-			return err;
-	}
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
-
 static DEFINE_MUTEX(netdev_switch_mutex);
 static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
 
-- 
1.7.10.4
