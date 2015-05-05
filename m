From: sfeldma@gmail.com
Subject: [PATCH net-next v5 05/21] switchdev: convert STP update to switchdev attr set
Date: Tue,  5 May 2015 10:34:41 -0700
Message-ID: <1430847297-15728-6-git-send-email-sfeldma@gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36216 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965334AbbEEReG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:34:06 -0400
Received: by pdea3 with SMTP id a3so203674840pde.3
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 10:34:05 -0700 (PDT)
In-Reply-To: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

STP update is just a settable port attribute, so convert
switchdev_port_stp_update to an attr set.

For rocker, support prepare-commit transaction model for setting STP state.
This requires rocker to preallocate memory needed for the commit up front
in the prepare phase.  Since rtnl_lock is held between prepare-commit,
store the allocated memory on a queue hanging off of the rocker_port.
Also, in prepare phase, do everything right up to calling into HW.  The
same code paths are tranversed in the driver for both prepare and commit
phases.  In some cases, any state modified in the prepare phase must be
reverted before returning so the commit phase makes the same decisions.

For rocker, as a consequence of holding rtnl_lock in process context for
all attr sets (and obj adds), all memory is GFP_KERNEL allocated and we
don't need to busy spin waiting for the device to complete the command.  So
the bulk of this patch is simplifying the memory allocations to only use
GFP_KERNEL and to remove the nowait flag and busy spin loop.

For DSA, the prepare phase is skipped and STP updates are only done in the
commit phase.  This is because currently the DSA drivers don't need to
allocate any memory for STP updates and the STP update will not fail to HW
(unless something horrible goes wrong on the MDIO bus, in which case the
prepare phase wouldn't have been able to predict anyway).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |  397 +++++++++++++++++++++++-----------
 include/net/switchdev.h              |   13 +-
 net/bridge/br_stp.c                  |    6 +-
 net/dsa/slave.c                      |   20 +-
 net/switchdev/switchdev.c            |   28 ---
 5 files changed, 297 insertions(+), 167 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2428299..b016c1c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -225,6 +225,8 @@ struct rocker_port {
 	struct napi_struct napi_rx;
 	struct rocker_dma_ring_info tx_ring;
 	struct rocker_dma_ring_info rx_ring;
+	enum switchdev_trans trans;
+	struct list_head trans_mem;
 };
 
 struct rocker {
@@ -325,16 +327,81 @@ static bool rocker_port_is_bridged(struct rocker_port *rocker_port)
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
+	case SWITCHDEV_TRANS_PREPARE:
+		elem = alloc(size + sizeof(*elem), flags);
+		if (!elem)
+			return NULL;
+		list_add_tail(elem, &rocker_port->trans_mem);
+		break;
+	case SWITCHDEV_TRANS_COMMIT:
+		BUG_ON(list_empty(&rocker_port->trans_mem));
+		elem = rocker_port->trans_mem.next;
+		list_del_init(elem);
+		break;
+	case SWITCHDEV_TRANS_NONE:
+		elem = alloc(size + sizeof(*elem), flags);
+		if (elem)
+			INIT_LIST_HEAD(elem);
+		break;
+	default:
+		break;
+	}
+
+	return elem ? elem + 1 : NULL;
+}
+
+static void *rocker_port_kzalloc(struct rocker_port *rocker_port, size_t size)
+{
+	return __rocker_port_alloc(rocker_port, size, GFP_KERNEL, kzalloc);
+}
+
+static void *rocker_port_kcalloc(struct rocker_port *rocker_port, size_t n,
+				 size_t size)
+{
+	return __rocker_port_alloc(rocker_port, n * size, GFP_KERNEL, kzalloc);
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
+	if (rocker_port->trans == SWITCHDEV_TRANS_PREPARE)
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
-	bool nowait;
 };
 
 static void rocker_wait_reset(struct rocker_wait *wait)
 {
 	wait->done = false;
-	wait->nowait = false;
 }
 
 static void rocker_wait_init(struct rocker_wait *wait)
@@ -343,20 +410,21 @@ static void rocker_wait_init(struct rocker_wait *wait)
 	rocker_wait_reset(wait);
 }
 
-static struct rocker_wait *rocker_wait_create(gfp_t gfp)
+static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port)
 {
 	struct rocker_wait *wait;
 
-	wait = kmalloc(sizeof(*wait), gfp);
+	wait = rocker_port_kzalloc(rocker_port, sizeof(*wait));
 	if (!wait)
 		return NULL;
 	rocker_wait_init(wait);
 	return wait;
 }
 
-static void rocker_wait_destroy(struct rocker_wait *work)
+static void rocker_wait_destroy(struct rocker_port *rocker_port,
+				struct rocker_wait *wait)
 {
-	kfree(work);
+	rocker_port_kfree(rocker_port, wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -1317,12 +1385,7 @@ static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
 	spin_lock(&rocker->cmd_ring_lock);
 	while ((desc_info = rocker_desc_tail_get(&rocker->cmd_ring))) {
 		wait = rocker_desc_cookie_ptr_get(desc_info);
-		if (wait->nowait) {
-			rocker_desc_gen_clear(desc_info);
-			rocker_wait_destroy(wait);
-		} else {
-			rocker_wait_wake_up(wait);
-		}
+		rocker_wait_wake_up(wait);
 		credits++;
 	}
 	spin_unlock(&rocker->cmd_ring_lock);
@@ -1374,22 +1437,42 @@ static int rocker_event_link_change(struct rocker *rocker,
 }
 
 #define ROCKER_OP_FLAG_REMOVE		BIT(0)
-#define ROCKER_OP_FLAG_NOWAIT		BIT(1)
-#define ROCKER_OP_FLAG_LEARNED		BIT(2)
-#define ROCKER_OP_FLAG_REFRESH		BIT(3)
+#define ROCKER_OP_FLAG_LEARNED		BIT(1)
+#define ROCKER_OP_FLAG_REFRESH		BIT(2)
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags);
 
+struct rocker_mac_vlan_seen_work {
+	struct work_struct work;
+	struct rocker_port *rocker_port;
+	int flags;
+	unsigned char addr[ETH_ALEN];
+	__be16 vlan_id;
+};
+
+static void rocker_event_mac_vlan_seen_work(struct work_struct *work)
+{
+	struct rocker_mac_vlan_seen_work *sw =
+		container_of(work, struct rocker_mac_vlan_seen_work, work);
+
+	rtnl_lock();
+	rocker_port_fdb(sw->rocker_port, sw->addr, sw->vlan_id, sw->flags);
+	rtnl_unlock();
+
+	kfree(work);
+}
+
 static int rocker_event_mac_vlan_seen(struct rocker *rocker,
 				      const struct rocker_tlv *info)
 {
+	struct rocker_mac_vlan_seen_work *sw;
 	struct rocker_tlv *attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAX + 1];
 	unsigned int port_number;
 	struct rocker_port *rocker_port;
 	unsigned char *addr;
-	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_LEARNED;
+	int flags = ROCKER_OP_FLAG_LEARNED;
 	__be16 vlan_id;
 
 	rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_MAC_VLAN_MAX, info);
@@ -1411,7 +1494,20 @@ static int rocker_event_mac_vlan_seen(struct rocker *rocker,
 	    rocker_port->stp_state != BR_STATE_FORWARDING)
 		return 0;
 
-	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
+	sw = kmalloc(sizeof(*sw), GFP_ATOMIC);
+	if (!sw)
+		return -ENOMEM;
+
+	INIT_WORK(&sw->work, rocker_event_mac_vlan_seen_work);
+
+	sw->rocker_port = rocker_port;
+	sw->flags = flags;
+	ether_addr_copy(sw->addr, addr);
+	sw->vlan_id = vlan_id;
+
+	schedule_work(&sw->work);
+
+	return 0;
 }
 
 static int rocker_event_process(struct rocker *rocker,
@@ -1495,40 +1591,42 @@ typedef int (*rocker_cmd_cb_t)(struct rocker *rocker,
 static int rocker_cmd_exec(struct rocker *rocker,
 			   struct rocker_port *rocker_port,
 			   rocker_cmd_cb_t prepare, void *prepare_priv,
-			   rocker_cmd_cb_t process, void *process_priv,
-			   bool nowait)
+			   rocker_cmd_cb_t process, void *process_priv)
 {
 	struct rocker_desc_info *desc_info;
 	struct rocker_wait *wait;
 	unsigned long flags;
 	int err;
 
-	wait = rocker_wait_create(nowait ? GFP_ATOMIC : GFP_KERNEL);
+	wait = rocker_wait_create(rocker_port);
 	if (!wait)
 		return -ENOMEM;
-	wait->nowait = nowait;
 
 	spin_lock_irqsave(&rocker->cmd_ring_lock, flags);
+
 	desc_info = rocker_desc_head_get(&rocker->cmd_ring);
 	if (!desc_info) {
 		spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
 		err = -EAGAIN;
 		goto out;
 	}
+
 	err = prepare(rocker, rocker_port, desc_info, prepare_priv);
 	if (err) {
 		spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
 		goto out;
 	}
+
 	rocker_desc_cookie_ptr_set(desc_info, wait);
-	rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
-	spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
 
-	if (nowait)
-		return 0;
+	if (rocker_port->trans != SWITCHDEV_TRANS_PREPARE)
+		rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
 
-	if (!rocker_wait_event_timeout(wait, HZ / 10))
-		return -EIO;
+	spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
+
+	if (rocker_port->trans != SWITCHDEV_TRANS_PREPARE)
+		if (!rocker_wait_event_timeout(wait, HZ / 10))
+			return -EIO;
 
 	err = rocker_desc_err(desc_info);
 	if (err)
@@ -1539,7 +1637,7 @@ static int rocker_cmd_exec(struct rocker *rocker,
 
 	rocker_desc_gen_clear(desc_info);
 out:
-	rocker_wait_destroy(wait);
+	rocker_wait_destroy(rocker_port, wait);
 	return err;
 }
 
@@ -1764,7 +1862,7 @@ static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_ethtool_proc,
-			       ecmd, false);
+			       ecmd);
 }
 
 static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
@@ -1773,7 +1871,7 @@ static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_macaddr_proc,
-			       macaddr, false);
+			       macaddr);
 }
 
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
@@ -1781,7 +1879,7 @@ static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 {
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
 			       rocker_cmd_set_port_settings_ethtool_prep,
-			       ecmd, NULL, NULL, false);
+			       ecmd, NULL, NULL);
 }
 
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
@@ -1789,14 +1887,14 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 {
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
 			       rocker_cmd_set_port_settings_macaddr_prep,
-			       macaddr, NULL, NULL, false);
+			       macaddr, NULL, NULL);
 }
 
 static int rocker_port_set_learning(struct rocker_port *rocker_port)
 {
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
 			       rocker_cmd_set_port_learning_prep,
-			       NULL, NULL, NULL, false);
+			       NULL, NULL, NULL);
 }
 
 static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
@@ -2308,8 +2406,7 @@ rocker_flow_tbl_find(struct rocker *rocker, struct rocker_flow_tbl_entry *match)
 }
 
 static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
-			       struct rocker_flow_tbl_entry *match,
-			       bool nowait)
+			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_flow_tbl_entry *found;
@@ -2324,8 +2421,9 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 
 	if (found) {
 		match->cookie = found->cookie;
-		hash_del(&found->entry);
-		kfree(found);
+		if (rocker_port->trans != SWITCHDEV_TRANS_PREPARE)
+			hash_del(&found->entry);
+		rocker_port_kfree(rocker_port, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -2334,18 +2432,18 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
 	}
 
-	hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
+	if (rocker_port->trans != SWITCHDEV_TRANS_PREPARE)
+		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
 	return rocker_cmd_exec(rocker, rocker_port,
 			       rocker_cmd_flow_tbl_add,
-			       found, NULL, NULL, nowait);
+			       found, NULL, NULL);
 }
 
 static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
-			       struct rocker_flow_tbl_entry *match,
-			       bool nowait)
+			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_flow_tbl_entry *found;
@@ -2360,38 +2458,32 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_flow_tbl_find(rocker, match);
 
 	if (found) {
-		hash_del(&found->entry);
+		if (rocker_port->trans != SWITCHDEV_TRANS_PREPARE)
+			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
-	kfree(match);
+	rocker_port_kfree(rocker_port, match);
 
 	if (found) {
 		err = rocker_cmd_exec(rocker, rocker_port,
 				      rocker_cmd_flow_tbl_del,
-				      found, NULL, NULL, nowait);
-		kfree(found);
+				      found, NULL, NULL);
+		rocker_port_kfree(rocker_port, found);
 	}
 
 	return err;
 }
 
-static gfp_t rocker_op_flags_gfp(int flags)
-{
-	return flags & ROCKER_OP_FLAG_NOWAIT ? GFP_ATOMIC : GFP_KERNEL;
-}
-
 static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
 			      int flags, struct rocker_flow_tbl_entry *entry)
 {
-	bool nowait = flags & ROCKER_OP_FLAG_NOWAIT;
-
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_flow_tbl_del(rocker_port, entry, nowait);
+		return rocker_flow_tbl_del(rocker_port, entry);
 	else
-		return rocker_flow_tbl_add(rocker_port, entry, nowait);
+		return rocker_flow_tbl_add(rocker_port, entry);
 }
 
 static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
@@ -2400,7 +2492,7 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2421,7 +2513,7 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2447,7 +2539,7 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2487,7 +2579,7 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2536,7 +2628,7 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2567,7 +2659,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	u32 priority;
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2620,22 +2712,22 @@ rocker_group_tbl_find(struct rocker *rocker,
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
-				struct rocker_group_tbl_entry *match,
-				bool nowait)
+				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_group_tbl_entry *found;
@@ -2646,8 +2738,9 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		hash_del(&found->entry);
-		rocker_group_tbl_entry_free(found);
+		if (rocker_port->trans != SWITCHDEV_TRANS_PREPARE)
+			hash_del(&found->entry);
+		rocker_group_tbl_entry_free(rocker_port, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
 	} else {
@@ -2655,18 +2748,18 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
 	}
 
-	hash_add(rocker->group_tbl, &found->entry, found->group_id);
+	if (rocker_port->trans != SWITCHDEV_TRANS_PREPARE)
+		hash_add(rocker->group_tbl, &found->entry, found->group_id);
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
 
 	return rocker_cmd_exec(rocker, rocker_port,
 			       rocker_cmd_group_tbl_add,
-			       found, NULL, NULL, nowait);
+			       found, NULL, NULL);
 }
 
 static int rocker_group_tbl_del(struct rocker_port *rocker_port,
-				struct rocker_group_tbl_entry *match,
-				bool nowait)
+				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_group_tbl_entry *found;
@@ -2678,19 +2771,20 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		hash_del(&found->entry);
+		if (rocker_port->trans != SWITCHDEV_TRANS_PREPARE)
+			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
 
-	rocker_group_tbl_entry_free(match);
+	rocker_group_tbl_entry_free(rocker_port, match);
 
 	if (found) {
 		err = rocker_cmd_exec(rocker, rocker_port,
 				      rocker_cmd_group_tbl_del,
-				      found, NULL, NULL, nowait);
-		rocker_group_tbl_entry_free(found);
+				      found, NULL, NULL);
+		rocker_group_tbl_entry_free(rocker_port, found);
 	}
 
 	return err;
@@ -2699,12 +2793,10 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 static int rocker_group_tbl_do(struct rocker_port *rocker_port,
 			       int flags, struct rocker_group_tbl_entry *entry)
 {
-	bool nowait = flags & ROCKER_OP_FLAG_NOWAIT;
-
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_group_tbl_del(rocker_port, entry, nowait);
+		return rocker_group_tbl_del(rocker_port, entry);
 	else
-		return rocker_group_tbl_add(rocker_port, entry, nowait);
+		return rocker_group_tbl_add(rocker_port, entry);
 }
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
@@ -2713,7 +2805,7 @@ static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2729,17 +2821,17 @@ static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = kcalloc(group_count, sizeof(u32),
-				   rocker_op_flags_gfp(flags));
+	entry->group_ids = rocker_port_kcalloc(rocker_port, group_count,
+					       sizeof(u32));
 	if (!entry->group_ids) {
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
@@ -2764,7 +2856,7 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2802,17 +2894,16 @@ static void _rocker_neigh_add(struct rocker *rocker,
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
@@ -2840,7 +2931,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	bool removing;
 	int err = 0;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2860,9 +2951,9 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
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
@@ -2909,7 +3000,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 err_out:
 	if (!adding)
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 
 	return err;
 }
@@ -2952,7 +3043,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 	bool resolved = true;
 	int err = 0;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2973,9 +3064,9 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
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
@@ -2984,7 +3075,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 
 	if (err)
 		return err;
@@ -3008,8 +3099,8 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	int err = 0;
 	int i;
 
-	group_ids = kcalloc(rocker->port_count, sizeof(u32),
-			    rocker_op_flags_gfp(flags));
+	group_ids = rocker_port_kcalloc(rocker_port, rocker->port_count,
+					sizeof(u32));
 	if (!group_ids)
 		return -ENOMEM;
 
@@ -3040,7 +3131,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	kfree(group_ids);
+	rocker_port_kfree(rocker_port, group_ids);
 	return err;
 }
 
@@ -3365,7 +3456,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
 
 struct rocker_fdb_learn_work {
 	struct work_struct work;
-	struct net_device *dev;
+	struct rocker_port *rocker_port;
 	int flags;
 	u8 addr[ETH_ALEN];
 	u16 vid;
@@ -3384,12 +3475,12 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 
 	if (learned && removing)
 		call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
-					 lw->dev, &info.info);
+					 lw->rocker_port->dev, &info.info);
 	else if (learned && !removing)
 		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
-					 lw->dev, &info.info);
+					 lw->rocker_port->dev, &info.info);
 
-	kfree(work);
+	rocker_port_kfree(lw->rocker_port, work);
 }
 
 static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
@@ -3422,18 +3513,21 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	lw = kmalloc(sizeof(*lw), rocker_op_flags_gfp(flags));
+	lw = rocker_port_kzalloc(rocker_port, sizeof(*lw));
 	if (!lw)
 		return -ENOMEM;
 
 	INIT_WORK(&lw->work, rocker_port_fdb_learn_work);
 
-	lw->dev = rocker_port->dev;
+	lw->rocker_port = rocker_port;
 	lw->flags = flags;
 	ether_addr_copy(lw->addr, addr);
 	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
 
-	schedule_work(&lw->work);
+	if (rocker_port->trans == SWITCHDEV_TRANS_PREPARE)
+		rocker_port_kfree(rocker_port, lw);
+	else
+		schedule_work(&lw->work);
 
 	return 0;
 }
@@ -3460,7 +3554,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = kzalloc(sizeof(*fdb), rocker_op_flags_gfp(flags));
+	fdb = rocker_port_kzalloc(rocker_port, sizeof(*fdb));
 	if (!fdb)
 		return -ENOMEM;
 
@@ -3475,7 +3569,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	found = rocker_fdb_tbl_find(rocker, fdb);
 
 	if (removing && found) {
-		kfree(fdb);
+		rocker_port_kfree(rocker_port, fdb);
 		hash_del(&found->entry);
 	} else if (!removing && !found) {
 		hash_add(rocker->fdb_tbl, &fdb->entry, fdb->key_crc32);
@@ -3485,7 +3579,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		kfree(fdb);
+		rocker_port_kfree(rocker_port, fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
@@ -3500,7 +3594,7 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port)
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_tbl_entry *found;
 	unsigned long lock_flags;
-	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
+	int flags = ROCKER_OP_FLAG_REMOVE;
 	struct hlist_node *tmp;
 	int bkt;
 	int err = 0;
@@ -3568,7 +3662,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 	u32 out_pport;
 	__be16 vlan_id;
 	u16 vid;
-	int flags = ROCKER_OP_FLAG_NOWAIT;
+	int flags = 0;
 	int err;
 
 	/* Port will be forwarding-enabled if its STP state is LEARNING
@@ -3605,10 +3699,17 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
 {
 	bool want[ROCKER_CTRL_MAX] = { 0, };
+	bool prev_ctrls[ROCKER_CTRL_MAX];
+	u8 prev_state;
 	int flags;
 	int err;
 	int i;
 
+	if (rocker_port->trans == SWITCHDEV_TRANS_PREPARE) {
+		memcpy(prev_ctrls, rocker_port->ctrls, sizeof(prev_ctrls));
+		prev_state = rocker_port->stp_state;
+	}
+
 	if (rocker_port->stp_state == state)
 		return 0;
 
@@ -3636,21 +3737,28 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
 
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
+
+	err = rocker_port_fwding(rocker_port);
 
-	return rocker_port_fwding(rocker_port);
+err_out:
+	if (rocker_port->trans == SWITCHDEV_TRANS_PREPARE) {
+		memcpy(rocker_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
+		rocker_port->stp_state = prev_state;
+	}
+
+	return err;
 }
 
 static int rocker_port_fwd_enable(struct rocker_port *rocker_port)
@@ -3696,7 +3804,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int i;
 
-	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	entry = rocker_port_kzalloc(rocker_port, sizeof(*entry));
 	if (!entry)
 		return 0;
 
@@ -3706,7 +3814,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 
 	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
 	if (found) {
-		kfree(entry);
+		rocker_port_kfree(rocker_port, entry);
 		goto found;
 	}
 
@@ -3751,7 +3859,7 @@ static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
 		bit = ntohs(found->vlan_id) - ROCKER_INTERNAL_VLAN_ID_BASE;
 		clear_bit(bit, rocker->internal_vlan_bitmap);
 		hash_del(&found->entry);
-		kfree(found);
+		rocker_port_kfree(rocker_port, found);
 	}
 
 not_found:
@@ -4197,7 +4305,7 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	err = rocker_cmd_exec(rocker_port->rocker, rocker_port,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
-			      &name, false);
+			      &name);
 
 	return err ? -EOPNOTSUPP : 0;
 }
@@ -4239,12 +4347,48 @@ static int rocker_port_attr_get(struct net_device *dev,
 	return 0;
 }
 
-static int rocker_port_switchdev_port_stp_update(struct net_device *dev,
-						 u8 state)
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
+static int rocker_port_attr_set(struct net_device *dev,
+				struct switchdev_attr *attr)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 
-	return rocker_port_stp_update(rocker_port, state);
+	int err = 0;
+
+	rocker_port->trans = attr->trans;
+
+	switch (rocker_port->trans) {
+	case SWITCHDEV_TRANS_PREPARE:
+		BUG_ON(!list_empty(&rocker_port->trans_mem));
+		break;
+	case SWITCHDEV_TRANS_ABORT:
+		rocker_port_trans_abort(rocker_port);
+		return 0;
+	default:
+		break;
+	}
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_PORT_STP_STATE:
+		err = rocker_port_stp_update(rocker_port, attr->stp_state);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	rocker_port->trans = SWITCHDEV_TRANS_NONE;
+
+	return err;
 }
 
 static int rocker_port_switchdev_fib_ipv4_add(struct net_device *dev,
@@ -4274,7 +4418,7 @@ static int rocker_port_switchdev_fib_ipv4_del(struct net_device *dev,
 
 static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_attr_get	= rocker_port_attr_get,
-	.switchdev_port_stp_update	= rocker_port_switchdev_port_stp_update,
+	.switchdev_port_attr_set	= rocker_port_attr_set,
 	.switchdev_fib_ipv4_add		= rocker_port_switchdev_fib_ipv4_add,
 	.switchdev_fib_ipv4_del		= rocker_port_switchdev_fib_ipv4_del,
 };
@@ -4409,7 +4553,7 @@ static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
 			       rocker_cmd_get_port_stats_prep, NULL,
 			       rocker_cmd_get_port_stats_ethtool_proc,
-			       priv, false);
+			       priv);
 }
 
 static void rocker_port_get_stats(struct net_device *dev,
@@ -4627,6 +4771,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->port_number = port_number;
 	rocker_port->pport = port_number + 1;
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
+	INIT_LIST_HEAD(&rocker_port->trans_mem);
 
 	rocker_port_dev_addr_init(rocker, rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 93316e7..aec5e49 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -26,6 +26,7 @@ enum switchdev_trans {
 enum switchdev_attr_id {
 	SWITCHDEV_ATTR_UNDEFINED,
 	SWITCHDEV_ATTR_PORT_PARENT_ID,
+	SWITCHDEV_ATTR_PORT_STP_STATE,
 };
 
 struct switchdev_attr {
@@ -34,6 +35,7 @@ struct switchdev_attr {
 	u32 flags;
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
+		u8 stp_state;				/* PORT_STP_STATE */
 	};
 };
 
@@ -46,9 +48,6 @@ struct fib_info;
  *
  * @switchdev_port_attr_set: Set a port attribute (see switchdev_attr).
  *
- * @switchdev_port_stp_update: Called to notify switch device port of bridge
- *   port STP state change.
- *
  * @switchdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
  * @switchdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
@@ -58,7 +57,6 @@ struct switchdev_ops {
 					   struct switchdev_attr *attr);
 	int	(*switchdev_port_attr_set)(struct net_device *dev,
 					   struct switchdev_attr *attr);
-	int	(*switchdev_port_stp_update)(struct net_device *dev, u8 state);
 	int	(*switchdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 					  int dst_len, struct fib_info *fi,
 					  u8 tos, u8 type, u32 nlflags,
@@ -95,7 +93,6 @@ int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
-int switchdev_port_stp_update(struct net_device *dev, u8 state);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
@@ -128,12 +125,6 @@ static inline int switchdev_port_attr_set(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int switchdev_port_stp_update(struct net_device *dev,
-					    u8 state)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 28e3f4b..b9300da 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -39,10 +39,14 @@ void br_log_state(const struct net_bridge_port *p)
 
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_PORT_STP_STATE,
+		.stp_state = state,
+	};
 	int err;
 
 	p->state = state;
-	err = switchdev_port_stp_update(p->dev, state);
+	err = switchdev_port_attr_set(p->dev, &attr);
 	if (err && err != -EOPNOTSUPP)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b465d7c..1546d9e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -345,6 +345,24 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 	return ret;
 }
 
+static int dsa_slave_port_attr_set(struct net_device *dev,
+				   struct switchdev_attr *attr)
+{
+	int ret = 0;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_PORT_STP_STATE:
+		if (attr->trans == SWITCHDEV_TRANS_COMMIT)
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
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_attr_get	= dsa_slave_port_attr_get,
-	.switchdev_port_stp_update	= dsa_slave_stp_update,
+	.switchdev_port_attr_set	= dsa_slave_port_attr_set,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 117fd07..a3c3590 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -187,34 +187,6 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
-/**
- *	switchdev_port_stp_update - Notify switch device port of STP
- *					state change
- *	@dev: port device
- *	@state: port STP state
- *
- *	Notify switch device port of bridge port STP state change.
- */
-int switchdev_port_stp_update(struct net_device *dev, u8 state)
-{
-	const struct switchdev_ops *ops = dev->switchdev_ops;
-	struct net_device *lower_dev;
-	struct list_head *iter;
-	int err = -EOPNOTSUPP;
-
-	if (ops && ops->switchdev_port_stp_update)
-		return ops->switchdev_port_stp_update(dev, state);
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_stp_update(lower_dev, state);
-		if (err && err != -EOPNOTSUPP)
-			return err;
-	}
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(switchdev_port_stp_update);
-
 static DEFINE_MUTEX(switchdev_mutex);
 static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
 
-- 
1.7.10.4
