From: sfeldma@gmail.com
Subject: [PATCH net-next v7 05/24] rocker: support prepare-commit transaction model
Date: Sun, 10 May 2015 09:47:50 -0700
Message-ID: <1431276489-64199-6-git-send-email-sfeldma@gmail.com>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36569 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbbEJQrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:47:05 -0400
Received: by pdea3 with SMTP id a3so129308772pde.3
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:47:05 -0700 (PDT)
In-Reply-To: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

For rocker, support prepare-commit transaction model for setting attributes
(and for adding objects).  This requires rocker to preallocate memory
needed for the commit up front in the prepare phase.  Since rtnl_lock is
held between prepare-commit, store the allocated memory on a queue hanging
off of the rocker_port.  Also, in prepare phase, do everything right up to
calling into HW.  The same code paths are tranversed in the driver for both
prepare and commit phases.  In some cases, any state modified in the
prepare phase must be reverted before returning so the commit phase makes
the same decisions.

As a consequence of holding rtnl_lock in process context for all attr sets
(and obj adds), all memory is GFP_KERNEL allocated and we don't need to
busy spin waiting for the device to complete the command.  So the bulk of
this patch is simplifying the memory allocations to only use GFP_KERNEL and
to remove the nowait flag and busy spin loop.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |  700 ++++++++++++++++++++++------------
 1 file changed, 451 insertions(+), 249 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2428299..fa0fa54 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -225,6 +225,7 @@ struct rocker_port {
 	struct napi_struct napi_rx;
 	struct rocker_dma_ring_info tx_ring;
 	struct rocker_dma_ring_info rx_ring;
+	struct list_head trans_mem;
 };
 
 struct rocker {
@@ -325,16 +326,83 @@ static bool rocker_port_is_bridged(struct rocker_port *rocker_port)
 	return !!rocker_port->bridge_dev;
 }
 
+static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
+				     enum switchdev_trans trans, size_t size)
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
+	switch (trans) {
+	case SWITCHDEV_TRANS_PREPARE:
+		elem = kzalloc(size + sizeof(*elem), GFP_KERNEL);
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
+		elem = kzalloc(size + sizeof(*elem), GFP_KERNEL);
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
+static void *rocker_port_kzalloc(struct rocker_port *rocker_port,
+				 enum switchdev_trans trans, size_t size)
+{
+	return __rocker_port_mem_alloc(rocker_port, trans, size);
+}
+
+static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
+				 enum switchdev_trans trans, size_t n,
+				 size_t size)
+{
+	return __rocker_port_mem_alloc(rocker_port, trans, n * size);
+}
+
+static void rocker_port_kfree(struct rocker_port *rocker_port,
+			      enum switchdev_trans trans, const void *mem)
+{
+	struct list_head *elem;
+
+	/* Frees are ignored if in transaction prepare phase.  The
+	 * memory remains on the per-port list until freed in the
+	 * commit phase.
+	 */
+
+	if (trans == SWITCHDEV_TRANS_PREPARE)
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
@@ -343,20 +411,23 @@ static void rocker_wait_init(struct rocker_wait *wait)
 	rocker_wait_reset(wait);
 }
 
-static struct rocker_wait *rocker_wait_create(gfp_t gfp)
+static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
+					      enum switchdev_trans trans)
 {
 	struct rocker_wait *wait;
 
-	wait = kmalloc(sizeof(*wait), gfp);
+	wait = rocker_port_kzalloc(rocker_port, trans, sizeof(*wait));
 	if (!wait)
 		return NULL;
 	rocker_wait_init(wait);
 	return wait;
 }
 
-static void rocker_wait_destroy(struct rocker_wait *work)
+static void rocker_wait_destroy(struct rocker_port *rocker_port,
+				enum switchdev_trans trans,
+				struct rocker_wait *wait)
 {
-	kfree(work);
+	rocker_port_kfree(rocker_port, trans, wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -1317,12 +1388,7 @@ static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
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
@@ -1374,22 +1440,44 @@ static int rocker_event_link_change(struct rocker *rocker,
 }
 
 #define ROCKER_OP_FLAG_REMOVE		BIT(0)
-#define ROCKER_OP_FLAG_NOWAIT		BIT(1)
-#define ROCKER_OP_FLAG_LEARNED		BIT(2)
-#define ROCKER_OP_FLAG_REFRESH		BIT(3)
+#define ROCKER_OP_FLAG_LEARNED		BIT(1)
+#define ROCKER_OP_FLAG_REFRESH		BIT(2)
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
+			   enum switchdev_trans trans,
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
+	rocker_port_fdb(sw->rocker_port, SWITCHDEV_TRANS_NONE,
+			sw->addr, sw->vlan_id, sw->flags);
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
@@ -1411,7 +1499,20 @@ static int rocker_event_mac_vlan_seen(struct rocker *rocker,
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
@@ -1494,41 +1595,44 @@ typedef int (*rocker_cmd_cb_t)(struct rocker *rocker,
 
 static int rocker_cmd_exec(struct rocker *rocker,
 			   struct rocker_port *rocker_port,
+			   enum switchdev_trans trans,
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
+	wait = rocker_wait_create(rocker_port, trans);
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
+	if (trans != SWITCHDEV_TRANS_PREPARE)
+		rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
 
-	if (!rocker_wait_event_timeout(wait, HZ / 10))
-		return -EIO;
+	spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
+
+	if (trans != SWITCHDEV_TRANS_PREPARE)
+		if (!rocker_wait_event_timeout(wait, HZ / 10))
+			return -EIO;
 
 	err = rocker_desc_err(desc_info);
 	if (err)
@@ -1539,7 +1643,7 @@ static int rocker_cmd_exec(struct rocker *rocker,
 
 	rocker_desc_gen_clear(desc_info);
 out:
-	rocker_wait_destroy(wait);
+	rocker_wait_destroy(rocker_port, trans, wait);
 	return err;
 }
 
@@ -1762,41 +1866,46 @@ static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_ethtool_proc,
-			       ecmd, false);
+			       ecmd);
 }
 
 static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_macaddr_proc,
-			       macaddr, false);
+			       macaddr);
 }
 
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_set_port_settings_ethtool_prep,
-			       ecmd, NULL, NULL, false);
+			       ecmd, NULL, NULL);
 }
 
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_set_port_settings_macaddr_prep,
-			       macaddr, NULL, NULL, false);
+			       macaddr, NULL, NULL);
 }
 
-static int rocker_port_set_learning(struct rocker_port *rocker_port)
+static int rocker_port_set_learning(struct rocker_port *rocker_port,
+				    enum switchdev_trans trans)
 {
-	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port, trans,
 			       rocker_cmd_set_port_learning_prep,
-			       NULL, NULL, NULL, false);
+			       NULL, NULL, NULL);
 }
 
 static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
@@ -2308,8 +2417,8 @@ rocker_flow_tbl_find(struct rocker *rocker, struct rocker_flow_tbl_entry *match)
 }
 
 static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
-			       struct rocker_flow_tbl_entry *match,
-			       bool nowait)
+			       enum switchdev_trans trans,
+			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_flow_tbl_entry *found;
@@ -2324,8 +2433,9 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 
 	if (found) {
 		match->cookie = found->cookie;
-		hash_del(&found->entry);
-		kfree(found);
+		if (trans != SWITCHDEV_TRANS_PREPARE)
+			hash_del(&found->entry);
+		rocker_port_kfree(rocker_port, trans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -2334,18 +2444,19 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
 	}
 
-	hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
+	if (trans != SWITCHDEV_TRANS_PREPARE)
+		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
-	return rocker_cmd_exec(rocker, rocker_port,
+	return rocker_cmd_exec(rocker, rocker_port, trans,
 			       rocker_cmd_flow_tbl_add,
-			       found, NULL, NULL, nowait);
+			       found, NULL, NULL);
 }
 
 static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
-			       struct rocker_flow_tbl_entry *match,
-			       bool nowait)
+			       enum switchdev_trans trans,
+			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_flow_tbl_entry *found;
@@ -2360,47 +2471,43 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_flow_tbl_find(rocker, match);
 
 	if (found) {
-		hash_del(&found->entry);
+		if (trans != SWITCHDEV_TRANS_PREPARE)
+			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
-	kfree(match);
+	rocker_port_kfree(rocker_port, trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker, rocker_port,
+		err = rocker_cmd_exec(rocker, rocker_port, trans,
 				      rocker_cmd_flow_tbl_del,
-				      found, NULL, NULL, nowait);
-		kfree(found);
+				      found, NULL, NULL);
+		rocker_port_kfree(rocker_port, trans, found);
 	}
 
 	return err;
 }
 
-static gfp_t rocker_op_flags_gfp(int flags)
-{
-	return flags & ROCKER_OP_FLAG_NOWAIT ? GFP_ATOMIC : GFP_KERNEL;
-}
-
 static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
-			      int flags, struct rocker_flow_tbl_entry *entry)
+			      enum switchdev_trans trans, int flags,
+			      struct rocker_flow_tbl_entry *entry)
 {
-	bool nowait = flags & ROCKER_OP_FLAG_NOWAIT;
-
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_flow_tbl_del(rocker_port, entry, nowait);
+		return rocker_flow_tbl_del(rocker_port, trans, entry);
 	else
-		return rocker_flow_tbl_add(rocker_port, entry, nowait);
+		return rocker_flow_tbl_add(rocker_port, trans, entry);
 }
 
 static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
-				   int flags, u32 in_pport, u32 in_pport_mask,
+				   enum switchdev_trans trans, int flags,
+				   u32 in_pport, u32 in_pport_mask,
 				   enum rocker_of_dpa_table_id goto_tbl)
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2410,18 +2517,19 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 	entry->key.ig_port.in_pport_mask = in_pport_mask;
 	entry->key.ig_port.goto_tbl = goto_tbl;
 
-	return rocker_flow_tbl_do(rocker_port, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
-				int flags, u32 in_pport,
-				__be16 vlan_id, __be16 vlan_id_mask,
+				enum switchdev_trans trans, int flags,
+				u32 in_pport, __be16 vlan_id,
+				__be16 vlan_id_mask,
 				enum rocker_of_dpa_table_id goto_tbl,
 				bool untagged, __be16 new_vlan_id)
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2435,10 +2543,11 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 	entry->key.vlan.untagged = untagged;
 	entry->key.vlan.new_vlan_id = new_vlan_id;
 
-	return rocker_flow_tbl_do(rocker_port, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
+				    enum switchdev_trans trans,
 				    u32 in_pport, u32 in_pport_mask,
 				    __be16 eth_type, const u8 *eth_dst,
 				    const u8 *eth_dst_mask, __be16 vlan_id,
@@ -2447,7 +2556,7 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2471,11 +2580,11 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
 	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
 
-	return rocker_flow_tbl_do(rocker_port, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
-				  int flags,
+				  enum switchdev_trans trans, int flags,
 				  const u8 *eth_dst, const u8 *eth_dst_mask,
 				  __be16 vlan_id, u32 tunnel_id,
 				  enum rocker_of_dpa_table_id goto_tbl,
@@ -2487,7 +2596,7 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2525,10 +2634,11 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	entry->key.bridge.group_id = group_id;
 	entry->key.bridge.copy_to_cpu = copy_to_cpu;
 
-	return rocker_flow_tbl_do(rocker_port, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
+					  enum switchdev_trans trans,
 					  __be16 eth_type, __be32 dst,
 					  __be32 dst_mask, u32 priority,
 					  enum rocker_of_dpa_table_id goto_tbl,
@@ -2536,7 +2646,7 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2550,24 +2660,23 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 	entry->key_len = offsetof(struct rocker_flow_tbl_key,
 				  ucast_routing.group_id);
 
-	return rocker_flow_tbl_do(rocker_port, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
-			       int flags, u32 in_pport,
-			       u32 in_pport_mask,
+			       enum switchdev_trans trans, int flags,
+			       u32 in_pport, u32 in_pport_mask,
 			       const u8 *eth_src, const u8 *eth_src_mask,
 			       const u8 *eth_dst, const u8 *eth_dst_mask,
-			       __be16 eth_type,
-			       __be16 vlan_id, __be16 vlan_id_mask,
-			       u8 ip_proto, u8 ip_proto_mask,
-			       u8 ip_tos, u8 ip_tos_mask,
+			       __be16 eth_type, __be16 vlan_id,
+			       __be16 vlan_id_mask, u8 ip_proto,
+			       u8 ip_proto_mask, u8 ip_tos, u8 ip_tos_mask,
 			       u32 group_id)
 {
 	u32 priority;
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2602,7 +2711,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	entry->key.acl.ip_tos_mask = ip_tos_mask;
 	entry->key.acl.group_id = group_id;
 
-	return rocker_flow_tbl_do(rocker_port, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static struct rocker_group_tbl_entry *
@@ -2620,22 +2729,24 @@ rocker_group_tbl_find(struct rocker *rocker,
 	return NULL;
 }
 
-static void rocker_group_tbl_entry_free(struct rocker_group_tbl_entry *entry)
+static void rocker_group_tbl_entry_free(struct rocker_port *rocker_port,
+					enum switchdev_trans trans,
+					struct rocker_group_tbl_entry *entry)
 {
 	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		kfree(entry->group_ids);
+		rocker_port_kfree(rocker_port, trans, entry->group_ids);
 		break;
 	default:
 		break;
 	}
-	kfree(entry);
+	rocker_port_kfree(rocker_port, trans, entry);
 }
 
 static int rocker_group_tbl_add(struct rocker_port *rocker_port,
-				struct rocker_group_tbl_entry *match,
-				bool nowait)
+				enum switchdev_trans trans,
+				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_group_tbl_entry *found;
@@ -2646,8 +2757,9 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		hash_del(&found->entry);
-		rocker_group_tbl_entry_free(found);
+		if (trans != SWITCHDEV_TRANS_PREPARE)
+			hash_del(&found->entry);
+		rocker_group_tbl_entry_free(rocker_port, trans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
 	} else {
@@ -2655,18 +2767,19 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
 	}
 
-	hash_add(rocker->group_tbl, &found->entry, found->group_id);
+	if (trans != SWITCHDEV_TRANS_PREPARE)
+		hash_add(rocker->group_tbl, &found->entry, found->group_id);
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
 
-	return rocker_cmd_exec(rocker, rocker_port,
+	return rocker_cmd_exec(rocker, rocker_port, trans,
 			       rocker_cmd_group_tbl_add,
-			       found, NULL, NULL, nowait);
+			       found, NULL, NULL);
 }
 
 static int rocker_group_tbl_del(struct rocker_port *rocker_port,
-				struct rocker_group_tbl_entry *match,
-				bool nowait)
+				enum switchdev_trans trans,
+				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_group_tbl_entry *found;
@@ -2678,93 +2791,95 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		hash_del(&found->entry);
+		if (trans != SWITCHDEV_TRANS_PREPARE)
+			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
 
-	rocker_group_tbl_entry_free(match);
+	rocker_group_tbl_entry_free(rocker_port, trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker, rocker_port,
+		err = rocker_cmd_exec(rocker, rocker_port, trans,
 				      rocker_cmd_group_tbl_del,
-				      found, NULL, NULL, nowait);
-		rocker_group_tbl_entry_free(found);
+				      found, NULL, NULL);
+		rocker_group_tbl_entry_free(rocker_port, trans, found);
 	}
 
 	return err;
 }
 
 static int rocker_group_tbl_do(struct rocker_port *rocker_port,
-			       int flags, struct rocker_group_tbl_entry *entry)
+			       enum switchdev_trans trans, int flags,
+			       struct rocker_group_tbl_entry *entry)
 {
-	bool nowait = flags & ROCKER_OP_FLAG_NOWAIT;
-
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_group_tbl_del(rocker_port, entry, nowait);
+		return rocker_group_tbl_del(rocker_port, trans, entry);
 	else
-		return rocker_group_tbl_add(rocker_port, entry, nowait);
+		return rocker_group_tbl_add(rocker_port, trans, entry);
 }
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
-				     int flags, __be16 vlan_id,
-				     u32 out_pport, int pop_vlan)
+				     enum switchdev_trans trans, int flags,
+				     __be16 vlan_id, u32 out_pport,
+				     int pop_vlan)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	entry->l2_interface.pop_vlan = pop_vlan;
 
-	return rocker_group_tbl_do(rocker_port, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
+				   enum switchdev_trans trans,
 				   int flags, u8 group_count,
 				   u32 *group_ids, u32 group_id)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = kcalloc(group_count, sizeof(u32),
-				   rocker_op_flags_gfp(flags));
+	entry->group_ids = rocker_port_kcalloc(rocker_port, trans, group_count,
+					       sizeof(u32));
 	if (!entry->group_ids) {
-		kfree(entry);
+		rocker_port_kfree(rocker_port, trans, entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
 
-	return rocker_group_tbl_do(rocker_port, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_group_l2_flood(struct rocker_port *rocker_port,
-				 int flags, __be16 vlan_id,
-				 u8 group_count, u32 *group_ids,
-				 u32 group_id)
+				 enum switchdev_trans trans, int flags,
+				 __be16 vlan_id, u8 group_count,
+				 u32 *group_ids, u32 group_id)
 {
-	return rocker_group_l2_fan_out(rocker_port, flags,
+	return rocker_group_l2_fan_out(rocker_port, trans, flags,
 				       group_count, group_ids,
 				       group_id);
 }
 
 static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
-				   int flags, u32 index, u8 *src_mac,
-				   u8 *dst_mac, __be16 vlan_id,
-				   bool ttl_check, u32 pport)
+				   enum switchdev_trans trans, int flags,
+				   u32 index, u8 *src_mac, u8 *dst_mac,
+				   __be16 vlan_id, bool ttl_check, u32 pport)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2777,7 +2892,7 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 	entry->l3_unicast.ttl_check = ttl_check;
 	entry->l3_unicast.group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, pport);
 
-	return rocker_group_tbl_do(rocker_port, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static struct rocker_neigh_tbl_entry *
@@ -2802,17 +2917,17 @@ static void _rocker_neigh_add(struct rocker *rocker,
 		 be32_to_cpu(entry->ip_addr));
 }
 
-static void _rocker_neigh_del(struct rocker *rocker,
+static void _rocker_neigh_del(struct rocker_port *rocker_port,
+			      enum switchdev_trans trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
-		kfree(entry);
+		rocker_port_kfree(rocker_port, trans, entry);
 	}
 }
 
-static void _rocker_neigh_update(struct rocker *rocker,
-				 struct rocker_neigh_tbl_entry *entry,
+static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
 				 u8 *eth_dst, bool ttl_check)
 {
 	if (eth_dst) {
@@ -2824,6 +2939,7 @@ static void _rocker_neigh_update(struct rocker *rocker,
 }
 
 static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
+				  enum switchdev_trans trans,
 				  int flags, __be32 ip_addr, u8 *eth_dst)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2840,7 +2956,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	bool removing;
 	int err = 0;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2860,9 +2976,9 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 		_rocker_neigh_add(rocker, entry);
 	} else if (removing) {
 		memcpy(entry, found, sizeof(*entry));
-		_rocker_neigh_del(rocker, found);
+		_rocker_neigh_del(rocker_port, trans, found);
 	} else if (updating) {
-		_rocker_neigh_update(rocker, found, eth_dst, true);
+		_rocker_neigh_update(found, eth_dst, true);
 		memcpy(entry, found, sizeof(*entry));
 	} else {
 		err = -ENOENT;
@@ -2879,7 +2995,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	 * other routes' nexthops.
 	 */
 
-	err = rocker_group_l3_unicast(rocker_port, flags,
+	err = rocker_group_l3_unicast(rocker_port, trans, flags,
 				      entry->index,
 				      rocker_port->dev->dev_addr,
 				      entry->eth_dst,
@@ -2895,7 +3011,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 	if (adding || removing) {
 		group_id = ROCKER_GROUP_L3_UNICAST(entry->index);
-		err = rocker_flow_tbl_ucast4_routing(rocker_port,
+		err = rocker_flow_tbl_ucast4_routing(rocker_port, trans,
 						     eth_type, ip_addr,
 						     inet_make_mask(32),
 						     priority, goto_tbl,
@@ -2909,13 +3025,13 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 err_out:
 	if (!adding)
-		kfree(entry);
+		rocker_port_kfree(rocker_port, trans, entry);
 
 	return err;
 }
 
 static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
-				    __be32 ip_addr)
+				    enum switchdev_trans trans, __be32 ip_addr)
 {
 	struct net_device *dev = rocker_port->dev;
 	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
@@ -2932,14 +3048,16 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 	 */
 
 	if (n->nud_state & NUD_VALID)
-		err = rocker_port_ipv4_neigh(rocker_port, 0, ip_addr, n->ha);
+		err = rocker_port_ipv4_neigh(rocker_port, trans, 0,
+					     ip_addr, n->ha);
 	else
 		neigh_event_send(n, NULL);
 
 	return err;
 }
 
-static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
+static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
+			       enum switchdev_trans trans, int flags,
 			       __be32 ip_addr, u32 *index)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2952,7 +3070,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 	bool resolved = true;
 	int err = 0;
 
-	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2973,9 +3091,9 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
-		_rocker_neigh_del(rocker, found);
+		_rocker_neigh_del(rocker_port, trans, found);
 	} else if (updating) {
-		_rocker_neigh_update(rocker, found, NULL, false);
+		_rocker_neigh_update(found, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
 	} else {
 		err = -ENOENT;
@@ -2984,7 +3102,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		kfree(entry);
+		rocker_port_kfree(rocker_port, trans, entry);
 
 	if (err)
 		return err;
@@ -2992,12 +3110,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
 	/* Resolved means neigh ip_addr is resolved to neigh mac. */
 
 	if (!resolved)
-		err = rocker_port_ipv4_resolve(rocker_port, ip_addr);
+		err = rocker_port_ipv4_resolve(rocker_port, trans, ip_addr);
 
 	return err;
 }
 
 static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
+					enum switchdev_trans trans,
 					int flags, __be16 vlan_id)
 {
 	struct rocker_port *p;
@@ -3008,8 +3127,8 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	int err = 0;
 	int i;
 
-	group_ids = kcalloc(rocker->port_count, sizeof(u32),
-			    rocker_op_flags_gfp(flags));
+	group_ids = rocker_port_kcalloc(rocker_port, trans, rocker->port_count,
+					sizeof(u32));
 	if (!group_ids)
 		return -ENOMEM;
 
@@ -3032,21 +3151,20 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	if (group_count == 0)
 		goto no_ports_in_vlan;
 
-	err = rocker_group_l2_flood(rocker_port, flags, vlan_id,
-				    group_count, group_ids,
-				    group_id);
+	err = rocker_group_l2_flood(rocker_port, trans, flags, vlan_id,
+				    group_count, group_ids, group_id);
 	if (err)
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	kfree(group_ids);
+	rocker_port_kfree(rocker_port, trans, group_ids);
 	return err;
 }
 
 static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
-				      int flags, __be16 vlan_id,
-				      bool pop_vlan)
+				      enum switchdev_trans trans, int flags,
+				      __be16 vlan_id, bool pop_vlan)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_port *p;
@@ -3063,9 +3181,8 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 	if (rocker_port->stp_state == BR_STATE_LEARNING ||
 	    rocker_port->stp_state == BR_STATE_FORWARDING) {
 		out_pport = rocker_port->pport;
-		err = rocker_group_l2_interface(rocker_port, flags,
-						vlan_id, out_pport,
-						pop_vlan);
+		err = rocker_group_l2_interface(rocker_port, trans, flags,
+						vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
 				   "Error (%d) port VLAN l2 group for pport %d\n",
@@ -3089,9 +3206,8 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 		return 0;
 
 	out_pport = 0;
-	err = rocker_group_l2_interface(rocker_port, flags,
-					vlan_id, out_pport,
-					pop_vlan);
+	err = rocker_group_l2_interface(rocker_port, trans, flags,
+					vlan_id, out_pport, pop_vlan);
 	if (err) {
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 group for CPU port\n", err);
@@ -3147,8 +3263,8 @@ static struct rocker_ctrl {
 };
 
 static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
-				     int flags, struct rocker_ctrl *ctrl,
-				     __be16 vlan_id)
+				     enum switchdev_trans trans, int flags,
+				     struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport = rocker_port->pport;
 	u32 in_pport_mask = 0xffffffff;
@@ -3163,7 +3279,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	int err;
 
-	err = rocker_flow_tbl_acl(rocker_port, flags,
+	err = rocker_flow_tbl_acl(rocker_port, trans, flags,
 				  in_pport, in_pport_mask,
 				  eth_src, eth_src_mask,
 				  ctrl->eth_dst, ctrl->eth_dst_mask,
@@ -3180,7 +3296,8 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
-					int flags, struct rocker_ctrl *ctrl,
+					enum switchdev_trans trans, int flags,
+					struct rocker_ctrl *ctrl,
 					__be16 vlan_id)
 {
 	enum rocker_of_dpa_table_id goto_tbl =
@@ -3192,7 +3309,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	err = rocker_flow_tbl_bridge(rocker_port, flags,
+	err = rocker_flow_tbl_bridge(rocker_port, trans, flags,
 				     ctrl->eth_dst, ctrl->eth_dst_mask,
 				     vlan_id, tunnel_id,
 				     goto_tbl, group_id, ctrl->copy_to_cpu);
@@ -3204,8 +3321,8 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
-				      int flags, struct rocker_ctrl *ctrl,
-				      __be16 vlan_id)
+				      enum switchdev_trans trans, int flags,
+				      struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
 	__be16 vlan_id_mask = htons(0xffff);
@@ -3214,7 +3331,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 	if (ntohs(vlan_id) == 0)
 		vlan_id = rocker_port->internal_vlan_id;
 
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans,
 				       rocker_port->pport, in_pport_mask,
 				       ctrl->eth_type, ctrl->eth_dst,
 				       ctrl->eth_dst_mask, vlan_id,
@@ -3227,32 +3344,34 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 	return err;
 }
 
-static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port, int flags,
+static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port,
+				 enum switchdev_trans trans, int flags,
 				 struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	if (ctrl->acl)
-		return rocker_port_ctrl_vlan_acl(rocker_port, flags,
+		return rocker_port_ctrl_vlan_acl(rocker_port, trans, flags,
 						 ctrl, vlan_id);
 	if (ctrl->bridge)
-		return rocker_port_ctrl_vlan_bridge(rocker_port, flags,
+		return rocker_port_ctrl_vlan_bridge(rocker_port, trans, flags,
 						    ctrl, vlan_id);
 
 	if (ctrl->term)
-		return rocker_port_ctrl_vlan_term(rocker_port, flags,
+		return rocker_port_ctrl_vlan_term(rocker_port, trans, flags,
 						  ctrl, vlan_id);
 
 	return -EOPNOTSUPP;
 }
 
 static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
-				     int flags, __be16 vlan_id)
+				     enum switchdev_trans trans, int flags,
+				     __be16 vlan_id)
 {
 	int err = 0;
 	int i;
 
 	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
 		if (rocker_port->ctrls[i]) {
-			err = rocker_port_ctrl_vlan(rocker_port, flags,
+			err = rocker_port_ctrl_vlan(rocker_port, trans, flags,
 						    &rocker_ctrls[i], vlan_id);
 			if (err)
 				return err;
@@ -3262,7 +3381,8 @@ static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
 	return err;
 }
 
-static int rocker_port_ctrl(struct rocker_port *rocker_port, int flags,
+static int rocker_port_ctrl(struct rocker_port *rocker_port,
+			    enum switchdev_trans trans, int flags,
 			    struct rocker_ctrl *ctrl)
 {
 	u16 vid;
@@ -3271,7 +3391,7 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port, int flags,
 	for (vid = 1; vid < VLAN_N_VID; vid++) {
 		if (!test_bit(vid, rocker_port->vlan_bitmap))
 			continue;
-		err = rocker_port_ctrl_vlan(rocker_port, flags,
+		err = rocker_port_ctrl_vlan(rocker_port, trans, flags,
 					    ctrl, htons(vid));
 		if (err)
 			break;
@@ -3280,8 +3400,8 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port, int flags,
 	return err;
 }
 
-static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
-			    u16 vid)
+static int rocker_port_vlan(struct rocker_port *rocker_port,
+			    enum switchdev_trans trans, int flags, u16 vid)
 {
 	enum rocker_of_dpa_table_id goto_tbl =
 		ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
@@ -3303,7 +3423,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 			return 0; /* already removed */
 
 	if (adding) {
-		err = rocker_port_ctrl_vlan_add(rocker_port, flags,
+		err = rocker_port_ctrl_vlan_add(rocker_port, trans, flags,
 						internal_vlan_id);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3312,7 +3432,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 		}
 	}
 
-	err = rocker_port_vlan_l2_groups(rocker_port, flags,
+	err = rocker_port_vlan_l2_groups(rocker_port, trans, flags,
 					 internal_vlan_id, untagged);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3320,7 +3440,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 		return err;
 	}
 
-	err = rocker_port_vlan_flood_group(rocker_port, flags,
+	err = rocker_port_vlan_flood_group(rocker_port, trans, flags,
 					   internal_vlan_id);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3328,7 +3448,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 		return err;
 	}
 
-	err = rocker_flow_tbl_vlan(rocker_port, flags,
+	err = rocker_flow_tbl_vlan(rocker_port, trans, flags,
 				   in_pport, vlan_id, vlan_id_mask,
 				   goto_tbl, untagged, internal_vlan_id);
 	if (err)
@@ -3338,7 +3458,8 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 	return err;
 }
 
-static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
+static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
+			      enum switchdev_trans trans, int flags)
 {
 	enum rocker_of_dpa_table_id goto_tbl;
 	u32 in_pport;
@@ -3353,7 +3474,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
 	in_pport_mask = 0xffff0000;
 	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
 
-	err = rocker_flow_tbl_ig_port(rocker_port, flags,
+	err = rocker_flow_tbl_ig_port(rocker_port, trans, flags,
 				      in_pport, in_pport_mask,
 				      goto_tbl);
 	if (err)
@@ -3365,7 +3486,8 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
 
 struct rocker_fdb_learn_work {
 	struct work_struct work;
-	struct net_device *dev;
+	struct rocker_port *rocker_port;
+	enum switchdev_trans trans;
 	int flags;
 	u8 addr[ETH_ALEN];
 	u16 vid;
@@ -3384,16 +3506,17 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 
 	if (learned && removing)
 		call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
-					 lw->dev, &info.info);
+					 lw->rocker_port->dev, &info.info);
 	else if (learned && !removing)
 		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
-					 lw->dev, &info.info);
+					 lw->rocker_port->dev, &info.info);
 
-	kfree(work);
+	rocker_port_kfree(lw->rocker_port, lw->trans, work);
 }
 
 static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
-				 int flags, const u8 *addr, __be16 vlan_id)
+				 enum switchdev_trans trans, int flags,
+				 const u8 *addr, __be16 vlan_id)
 {
 	struct rocker_fdb_learn_work *lw;
 	enum rocker_of_dpa_table_id goto_tbl =
@@ -3409,8 +3532,8 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 
 	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
-		err = rocker_flow_tbl_bridge(rocker_port, flags, addr, NULL,
-					     vlan_id, tunnel_id, goto_tbl,
+		err = rocker_flow_tbl_bridge(rocker_port, trans, flags, addr,
+					     NULL, vlan_id, tunnel_id, goto_tbl,
 					     group_id, copy_to_cpu);
 		if (err)
 			return err;
@@ -3422,18 +3545,22 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	lw = kmalloc(sizeof(*lw), rocker_op_flags_gfp(flags));
+	lw = rocker_port_kzalloc(rocker_port, trans, sizeof(*lw));
 	if (!lw)
 		return -ENOMEM;
 
 	INIT_WORK(&lw->work, rocker_port_fdb_learn_work);
 
-	lw->dev = rocker_port->dev;
+	lw->rocker_port = rocker_port;
+	lw->trans = trans;
 	lw->flags = flags;
 	ether_addr_copy(lw->addr, addr);
 	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
 
-	schedule_work(&lw->work);
+	if (trans == SWITCHDEV_TRANS_PREPARE)
+		rocker_port_kfree(rocker_port, trans, lw);
+	else
+		schedule_work(&lw->work);
 
 	return 0;
 }
@@ -3451,6 +3578,7 @@ rocker_fdb_tbl_find(struct rocker *rocker, struct rocker_fdb_tbl_entry *match)
 }
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
+			   enum switchdev_trans trans,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags)
 {
@@ -3460,7 +3588,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = kzalloc(sizeof(*fdb), rocker_op_flags_gfp(flags));
+	fdb = rocker_port_kzalloc(rocker_port, trans, sizeof(*fdb));
 	if (!fdb)
 		return -ENOMEM;
 
@@ -3475,7 +3603,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	found = rocker_fdb_tbl_find(rocker, fdb);
 
 	if (removing && found) {
-		kfree(fdb);
+		rocker_port_kfree(rocker_port, trans, fdb);
 		hash_del(&found->entry);
 	} else if (!removing && !found) {
 		hash_add(rocker->fdb_tbl, &fdb->entry, fdb->key_crc32);
@@ -3485,22 +3613,23 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		kfree(fdb);
+		rocker_port_kfree(rocker_port, trans, fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
 		flags |= ROCKER_OP_FLAG_REFRESH;
 	}
 
-	return rocker_port_fdb_learn(rocker_port, flags, addr, vlan_id);
+	return rocker_port_fdb_learn(rocker_port, trans, flags, addr, vlan_id);
 }
 
-static int rocker_port_fdb_flush(struct rocker_port *rocker_port)
+static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
+				 enum switchdev_trans trans)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_tbl_entry *found;
 	unsigned long lock_flags;
-	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
+	int flags = ROCKER_OP_FLAG_REMOVE;
 	struct hlist_node *tmp;
 	int bkt;
 	int err = 0;
@@ -3516,7 +3645,7 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port)
 			continue;
 		if (!found->learned)
 			continue;
-		err = rocker_port_fdb_learn(rocker_port, flags,
+		err = rocker_port_fdb_learn(rocker_port, trans, flags,
 					    found->key.addr,
 					    found->key.vlan_id);
 		if (err)
@@ -3531,7 +3660,8 @@ err_out:
 }
 
 static int rocker_port_router_mac(struct rocker_port *rocker_port,
-				  int flags, __be16 vlan_id)
+				  enum switchdev_trans trans, int flags,
+				  __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
 	__be16 eth_type;
@@ -3544,7 +3674,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		vlan_id = rocker_port->internal_vlan_id;
 
 	eth_type = htons(ETH_P_IP);
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans,
 				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3553,7 +3683,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		return err;
 
 	eth_type = htons(ETH_P_IPV6);
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans,
 				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3562,13 +3692,14 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 	return err;
 }
 
-static int rocker_port_fwding(struct rocker_port *rocker_port)
+static int rocker_port_fwding(struct rocker_port *rocker_port,
+			      enum switchdev_trans trans)
 {
 	bool pop_vlan;
 	u32 out_pport;
 	__be16 vlan_id;
 	u16 vid;
-	int flags = ROCKER_OP_FLAG_NOWAIT;
+	int flags = 0;
 	int err;
 
 	/* Port will be forwarding-enabled if its STP state is LEARNING
@@ -3588,9 +3719,8 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 			continue;
 		vlan_id = htons(vid);
 		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
-		err = rocker_group_l2_interface(rocker_port, flags,
-						vlan_id, out_pport,
-						pop_vlan);
+		err = rocker_group_l2_interface(rocker_port, trans, flags,
+						vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
 				   "Error (%d) port VLAN l2 group for pport %d\n",
@@ -3602,13 +3732,21 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 	return 0;
 }
 
-static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
+static int rocker_port_stp_update(struct rocker_port *rocker_port,
+				  enum switchdev_trans trans, u8 state)
 {
 	bool want[ROCKER_CTRL_MAX] = { 0, };
+	bool prev_ctrls[ROCKER_CTRL_MAX];
+	u8 prev_state;
 	int flags;
 	int err;
 	int i;
 
+	if (trans == SWITCHDEV_TRANS_PREPARE) {
+		memcpy(prev_ctrls, rocker_port->ctrls, sizeof(prev_ctrls));
+		prev_state = rocker_port->stp_state;
+	}
+
 	if (rocker_port->stp_state == state)
 		return 0;
 
@@ -3636,41 +3774,50 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
 
 	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
 		if (want[i] != rocker_port->ctrls[i]) {
-			flags = ROCKER_OP_FLAG_NOWAIT |
-				(want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
-			err = rocker_port_ctrl(rocker_port, flags,
+			flags = (want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
+			err = rocker_port_ctrl(rocker_port, trans, flags,
 					       &rocker_ctrls[i]);
 			if (err)
-				return err;
+				goto err_out;
 			rocker_port->ctrls[i] = want[i];
 		}
 	}
 
-	err = rocker_port_fdb_flush(rocker_port);
+	err = rocker_port_fdb_flush(rocker_port, trans);
 	if (err)
-		return err;
+		goto err_out;
 
-	return rocker_port_fwding(rocker_port);
+	err = rocker_port_fwding(rocker_port, trans);
+
+err_out:
+	if (trans == SWITCHDEV_TRANS_PREPARE) {
+		memcpy(rocker_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
+		rocker_port->stp_state = prev_state;
+	}
+
+	return err;
 }
 
-static int rocker_port_fwd_enable(struct rocker_port *rocker_port)
+static int rocker_port_fwd_enable(struct rocker_port *rocker_port,
+				  enum switchdev_trans trans)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will enable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to FORWARDING state */
-	return rocker_port_stp_update(rocker_port, BR_STATE_FORWARDING);
+	return rocker_port_stp_update(rocker_port, trans, BR_STATE_FORWARDING);
 }
 
-static int rocker_port_fwd_disable(struct rocker_port *rocker_port)
+static int rocker_port_fwd_disable(struct rocker_port *rocker_port,
+				   enum switchdev_trans trans)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will disable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to DISABLED state */
-	return rocker_port_stp_update(rocker_port, BR_STATE_DISABLED);
+	return rocker_port_stp_update(rocker_port, trans, BR_STATE_DISABLED);
 }
 
 static struct rocker_internal_vlan_tbl_entry *
@@ -3688,6 +3835,7 @@ rocker_internal_vlan_tbl_find(struct rocker *rocker, int ifindex)
 }
 
 static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
+					       enum switchdev_trans trans,
 					       int ifindex)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3696,7 +3844,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int i;
 
-	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
 	if (!entry)
 		return 0;
 
@@ -3706,7 +3854,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 
 	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
 	if (found) {
-		kfree(entry);
+		rocker_port_kfree(rocker_port, trans, entry);
 		goto found;
 	}
 
@@ -3730,6 +3878,7 @@ found:
 }
 
 static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
+					     enum switchdev_trans trans,
 					     int ifindex)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3751,14 +3900,15 @@ static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
 		bit = ntohs(found->vlan_id) - ROCKER_INTERNAL_VLAN_ID_BASE;
 		clear_bit(bit, rocker->internal_vlan_bitmap);
 		hash_del(&found->entry);
-		kfree(found);
+		rocker_port_kfree(rocker_port, trans, found);
 	}
 
 not_found:
 	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, lock_flags);
 }
 
-static int rocker_port_fib_ipv4(struct rocker_port *rocker_port, __be32 dst,
+static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
+				enum switchdev_trans trans, __be32 dst,
 				int dst_len, struct fib_info *fi, u32 tb_id,
 				int flags)
 {
@@ -3782,7 +3932,7 @@ static int rocker_port_fib_ipv4(struct rocker_port *rocker_port, __be32 dst,
 	has_gw = !!nh->nh_gw;
 
 	if (has_gw && nh_on_port) {
-		err = rocker_port_ipv4_nh(rocker_port, flags,
+		err = rocker_port_ipv4_nh(rocker_port, trans, flags,
 					  nh->nh_gw, &index);
 		if (err)
 			return err;
@@ -3793,7 +3943,7 @@ static int rocker_port_fib_ipv4(struct rocker_port *rocker_port, __be32 dst,
 		group_id = ROCKER_GROUP_L2_INTERFACE(internal_vlan_id, 0);
 	}
 
-	err = rocker_flow_tbl_ucast4_routing(rocker_port, eth_type, dst,
+	err = rocker_flow_tbl_ucast4_routing(rocker_port, trans, eth_type, dst,
 					     dst_mask, priority, goto_tbl,
 					     group_id, flags);
 	if (err)
@@ -3832,7 +3982,7 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
-	err = rocker_port_fwd_enable(rocker_port);
+	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE);
 	if (err)
 		goto err_fwd_enable;
 
@@ -3859,7 +4009,7 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
-	rocker_port_fwd_disable(rocker_port);
+	rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
 	rocker_port_dma_rings_fini(rocker_port);
@@ -4012,11 +4162,12 @@ static int rocker_port_vlan_rx_add_vid(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int err;
 
-	err = rocker_port_vlan(rocker_port, 0, vid);
+	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, vid);
 	if (err)
 		return err;
 
-	return rocker_port_router_mac(rocker_port, 0, htons(vid));
+	return rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
+				      0, htons(vid));
 }
 
 static int rocker_port_vlan_rx_kill_vid(struct net_device *dev,
@@ -4025,12 +4176,13 @@ static int rocker_port_vlan_rx_kill_vid(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int err;
 
-	err = rocker_port_router_mac(rocker_port, ROCKER_OP_FLAG_REMOVE,
-				     htons(vid));
+	err = rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
+				     ROCKER_OP_FLAG_REMOVE, htons(vid));
 	if (err)
 		return err;
 
-	return rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, vid);
+	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
+				ROCKER_OP_FLAG_REMOVE, vid);
 }
 
 static int rocker_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
@@ -4045,7 +4197,8 @@ static int rocker_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, SWITCHDEV_TRANS_NONE,
+			       addr, vlan_id, flags);
 }
 
 static int rocker_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
@@ -4059,7 +4212,8 @@ static int rocker_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, SWITCHDEV_TRANS_NONE,
+			       addr, vlan_id, flags);
 }
 
 static int rocker_fdb_fill_info(struct sk_buff *skb,
@@ -4155,7 +4309,8 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
 				rocker_port->brport_flags |= BR_LEARNING;
 			else
 				rocker_port->brport_flags &= ~BR_LEARNING;
-			err = rocker_port_set_learning(rocker_port);
+			err = rocker_port_set_learning(rocker_port,
+						       SWITCHDEV_TRANS_NONE);
 			if (err)
 				return err;
 		}
@@ -4195,9 +4350,10 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	int err;
 
 	err = rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			      SWITCHDEV_TRANS_NONE,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
-			      &name, false);
+			      &name);
 
 	return err ? -EOPNOTSUPP : 0;
 }
@@ -4244,7 +4400,43 @@ static int rocker_port_switchdev_port_stp_update(struct net_device *dev,
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 
-	return rocker_port_stp_update(rocker_port, state);
+	return rocker_port_stp_update(rocker_port, SWITCHDEV_TRANS_NONE, state);
+}
+
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
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (attr->trans) {
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
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
 }
 
 static int rocker_port_switchdev_fib_ipv4_add(struct net_device *dev,
@@ -4256,8 +4448,8 @@ static int rocker_port_switchdev_fib_ipv4_add(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int flags = 0;
 
-	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
-				    fi, tb_id, flags);
+	return rocker_port_fib_ipv4(rocker_port, SWITCHDEV_TRANS_NONE,
+				    dst, dst_len, fi, tb_id, flags);
 }
 
 static int rocker_port_switchdev_fib_ipv4_del(struct net_device *dev,
@@ -4268,8 +4460,8 @@ static int rocker_port_switchdev_fib_ipv4_del(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int flags = ROCKER_OP_FLAG_REMOVE;
 
-	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
-				    fi, tb_id, flags);
+	return rocker_port_fib_ipv4(rocker_port, SWITCHDEV_TRANS_NONE,
+				    dst, dst_len, fi, tb_id, flags);
 }
 
 static const struct switchdev_ops rocker_port_switchdev_ops = {
@@ -4407,9 +4599,10 @@ static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
 					     void *priv)
 {
 	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_get_port_stats_prep, NULL,
 			       rocker_cmd_get_port_stats_ethtool_proc,
-			       priv, false);
+			       priv);
 }
 
 static void rocker_port_get_stats(struct net_device *dev,
@@ -4591,7 +4784,8 @@ static void rocker_remove_ports(struct rocker *rocker)
 
 	for (i = 0; i < rocker->port_count; i++) {
 		rocker_port = rocker->ports[i];
-		rocker_port_ig_tbl(rocker_port, ROCKER_OP_FLAG_REMOVE);
+		rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
+				   ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
 	}
 	kfree(rocker->ports);
@@ -4627,6 +4821,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->port_number = port_number;
 	rocker_port->pport = port_number + 1;
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
+	INIT_LIST_HEAD(&rocker_port->trans_mem);
 
 	rocker_port_dev_addr_init(rocker, rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
@@ -4649,11 +4844,13 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	}
 	rocker->ports[port_number] = rocker_port;
 
-	rocker_port_set_learning(rocker_port);
+	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
 
 	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
-	err = rocker_port_ig_tbl(rocker_port, 0);
+		rocker_port_internal_vlan_id_get(rocker_port,
+						 SWITCHDEV_TRANS_NONE,
+						 dev->ifindex);
+	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
 	if (err) {
 		dev_err(&pdev->dev, "install ig port table failed\n");
 		goto err_port_ig_tbl;
@@ -4900,43 +5097,47 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 {
 	int err;
 
-	rocker_port_internal_vlan_id_put(rocker_port,
+	rocker_port_internal_vlan_id_put(rocker_port, SWITCHDEV_TRANS_NONE,
 					 rocker_port->dev->ifindex);
 
 	rocker_port->bridge_dev = bridge;
 
 	/* Use bridge internal VLAN ID for untagged pkts */
-	err = rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, 0);
+	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
+			       ROCKER_OP_FLAG_REMOVE, 0);
 	if (err)
 		return err;
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port,
+						 SWITCHDEV_TRANS_NONE,
 						 bridge->ifindex);
-	return rocker_port_vlan(rocker_port, 0, 0);
+	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
 }
 
 static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 {
 	int err;
 
-	rocker_port_internal_vlan_id_put(rocker_port,
+	rocker_port_internal_vlan_id_put(rocker_port, SWITCHDEV_TRANS_NONE,
 					 rocker_port->bridge_dev->ifindex);
 
 	rocker_port->bridge_dev = NULL;
 
 	/* Use port internal VLAN ID for untagged pkts */
-	err = rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, 0);
+	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
+			       ROCKER_OP_FLAG_REMOVE, 0);
 	if (err)
 		return err;
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port,
+						 SWITCHDEV_TRANS_NONE,
 						 rocker_port->dev->ifindex);
-	err = rocker_port_vlan(rocker_port, 0, 0);
+	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
 	if (err)
 		return err;
 
 	if (rocker_port->dev->flags & IFF_UP)
-		err = rocker_port_fwd_enable(rocker_port);
+		err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE);
 
 	return err;
 }
@@ -4998,7 +5199,8 @@ static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
 	int flags = (n->nud_state & NUD_VALID) ? 0 : ROCKER_OP_FLAG_REMOVE;
 	__be32 ip_addr = *(__be32 *)n->primary_key;
 
-	return rocker_port_ipv4_neigh(rocker_port, flags, ip_addr, n->ha);
+	return rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
+				      flags, ip_addr, n->ha);
 }
 
 static int rocker_netevent_event(struct notifier_block *unused,
-- 
1.7.10.4
