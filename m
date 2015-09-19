From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/6] switchdev: rename "trans" to "trans_ph".
Date: Sat, 19 Sep 2015 14:29:06 +0200
Message-ID: <1442665751-10949-2-git-send-email-jiri@resnulli.us>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37393 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbbISM3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 08:29:17 -0400
Received: by wicfx3 with SMTP id fx3so59351031wic.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 05:29:15 -0700 (PDT)
In-Reply-To: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is temporary, name "trans" will be used for something else and
"trans_ph" will eventually disappear.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 382 +++++++++++++++++------------------
 include/net/switchdev.h              |   6 +-
 net/dsa/slave.c                      |   8 +-
 net/switchdev/switchdev.c            |  12 +-
 4 files changed, 204 insertions(+), 204 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 34ac41a..b5f2ff8 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -340,7 +340,7 @@ static bool rocker_port_is_ovsed(const struct rocker_port *rocker_port)
 #define ROCKER_OP_FLAG_REFRESH		BIT(3)
 
 static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
-				     enum switchdev_trans trans, int flags,
+				     enum switchdev_trans_ph trans_ph, int flags,
 				     size_t size)
 {
 	struct list_head *elem = NULL;
@@ -356,7 +356,7 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 	 * memory used in the commit phase.
 	 */
 
-	switch (trans) {
+	switch (trans_ph) {
 	case SWITCHDEV_TRANS_PREPARE:
 		elem = kzalloc(size + sizeof(*elem), gfp_flags);
 		if (!elem)
@@ -381,20 +381,20 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 }
 
 static void *rocker_port_kzalloc(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans, int flags,
+				 enum switchdev_trans_ph trans_ph, int flags,
 				 size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans, flags, size);
+	return __rocker_port_mem_alloc(rocker_port, trans_ph, flags, size);
 }
 
 static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans, int flags,
+				 enum switchdev_trans_ph trans_ph, int flags,
 				 size_t n, size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans, flags, n * size);
+	return __rocker_port_mem_alloc(rocker_port, trans_ph, flags, n * size);
 }
 
-static void rocker_port_kfree(enum switchdev_trans trans, const void *mem)
+static void rocker_port_kfree(enum switchdev_trans_ph trans_ph, const void *mem)
 {
 	struct list_head *elem;
 
@@ -403,7 +403,7 @@ static void rocker_port_kfree(enum switchdev_trans trans, const void *mem)
 	 * commit phase.
 	 */
 
-	if (trans == SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
 		return;
 
 	elem = (struct list_head *)mem - 1;
@@ -430,22 +430,22 @@ static void rocker_wait_init(struct rocker_wait *wait)
 }
 
 static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
-					      enum switchdev_trans trans,
+					      enum switchdev_trans_ph trans_ph,
 					      int flags)
 {
 	struct rocker_wait *wait;
 
-	wait = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*wait));
+	wait = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*wait));
 	if (!wait)
 		return NULL;
 	rocker_wait_init(wait);
 	return wait;
 }
 
-static void rocker_wait_destroy(enum switchdev_trans trans,
+static void rocker_wait_destroy(enum switchdev_trans_ph trans_ph,
 				struct rocker_wait *wait)
 {
-	rocker_port_kfree(trans, wait);
+	rocker_port_kfree(trans_ph, wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -1463,7 +1463,7 @@ static int rocker_event_link_change(const struct rocker *rocker,
 }
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
-			   enum switchdev_trans trans,
+			   enum switchdev_trans_ph trans_ph,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags);
 
@@ -1582,7 +1582,7 @@ typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
 				    void *priv);
 
 static int rocker_cmd_exec(struct rocker_port *rocker_port,
-			   enum switchdev_trans trans, int flags,
+			   enum switchdev_trans_ph trans_ph, int flags,
 			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
 			   rocker_cmd_proc_cb_t process, void *process_priv)
 {
@@ -1593,7 +1593,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int err;
 
-	wait = rocker_wait_create(rocker_port, trans, flags);
+	wait = rocker_wait_create(rocker_port, trans_ph, flags);
 	if (!wait)
 		return -ENOMEM;
 	wait->nowait = nowait;
@@ -1615,7 +1615,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 
 	rocker_desc_cookie_ptr_set(desc_info, wait);
 
-	if (trans != SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 		rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
 
 	spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
@@ -1623,7 +1623,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 	if (nowait)
 		return 0;
 
-	if (trans != SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 		if (!rocker_wait_event_timeout(wait, HZ / 10))
 			return -EIO;
 
@@ -1636,7 +1636,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 
 	rocker_desc_gen_clear(desc_info);
 out:
-	rocker_wait_destroy(trans, wait);
+	rocker_wait_destroy(trans_ph, wait);
 	return err;
 }
 
@@ -1915,9 +1915,9 @@ static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
-				    enum switchdev_trans trans)
+				    enum switchdev_trans_ph trans_ph)
 {
-	return rocker_cmd_exec(rocker_port, trans, 0,
+	return rocker_cmd_exec(rocker_port, trans_ph, 0,
 			       rocker_cmd_set_port_learning_prep,
 			       NULL, NULL, NULL);
 }
@@ -2433,7 +2433,7 @@ rocker_flow_tbl_find(const struct rocker *rocker,
 }
 
 static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans, int flags,
+			       enum switchdev_trans_ph trans_ph, int flags,
 			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2449,9 +2449,9 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 
 	if (found) {
 		match->cookie = found->cookie;
-		if (trans != SWITCHDEV_TRANS_PREPARE)
+		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
-		rocker_port_kfree(trans, found);
+		rocker_port_kfree(trans_ph, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -2460,17 +2460,17 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
 	}
 
-	if (trans != SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans, flags,
+	return rocker_cmd_exec(rocker_port, trans_ph, flags,
 			       rocker_cmd_flow_tbl_add, found, NULL, NULL);
 }
 
 static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans, int flags,
+			       enum switchdev_trans_ph trans_ph, int flags,
 			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2486,43 +2486,43 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_flow_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans != SWITCHDEV_TRANS_PREPARE)
+		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	rocker_port_kfree(trans, match);
+	rocker_port_kfree(trans_ph, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans, flags,
+		err = rocker_cmd_exec(rocker_port, trans_ph, flags,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL);
-		rocker_port_kfree(trans, found);
+		rocker_port_kfree(trans_ph, found);
 	}
 
 	return err;
 }
 
 static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
-			      enum switchdev_trans trans, int flags,
+			      enum switchdev_trans_ph trans_ph, int flags,
 			      struct rocker_flow_tbl_entry *entry)
 {
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_flow_tbl_del(rocker_port, trans, flags, entry);
+		return rocker_flow_tbl_del(rocker_port, trans_ph, flags, entry);
 	else
-		return rocker_flow_tbl_add(rocker_port, trans, flags, entry);
+		return rocker_flow_tbl_add(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
-				   enum switchdev_trans trans, int flags,
+				   enum switchdev_trans_ph trans_ph, int flags,
 				   u32 in_pport, u32 in_pport_mask,
 				   enum rocker_of_dpa_table_id goto_tbl)
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2532,11 +2532,11 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 	entry->key.ig_port.in_pport_mask = in_pport_mask;
 	entry->key.ig_port.goto_tbl = goto_tbl;
 
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
-				enum switchdev_trans trans, int flags,
+				enum switchdev_trans_ph trans_ph, int flags,
 				u32 in_pport, __be16 vlan_id,
 				__be16 vlan_id_mask,
 				enum rocker_of_dpa_table_id goto_tbl,
@@ -2544,7 +2544,7 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2558,11 +2558,11 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 	entry->key.vlan.untagged = untagged;
 	entry->key.vlan.new_vlan_id = new_vlan_id;
 
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
-				    enum switchdev_trans trans,
+				    enum switchdev_trans_ph trans_ph,
 				    u32 in_pport, u32 in_pport_mask,
 				    __be16 eth_type, const u8 *eth_dst,
 				    const u8 *eth_dst_mask, __be16 vlan_id,
@@ -2571,7 +2571,7 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2595,11 +2595,11 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
 	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
 
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
-				  enum switchdev_trans trans, int flags,
+				  enum switchdev_trans_ph trans_ph, int flags,
 				  const u8 *eth_dst, const u8 *eth_dst_mask,
 				  __be16 vlan_id, u32 tunnel_id,
 				  enum rocker_of_dpa_table_id goto_tbl,
@@ -2611,7 +2611,7 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2649,11 +2649,11 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	entry->key.bridge.group_id = group_id;
 	entry->key.bridge.copy_to_cpu = copy_to_cpu;
 
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
-					  enum switchdev_trans trans,
+					  enum switchdev_trans_ph trans_ph,
 					  __be16 eth_type, __be32 dst,
 					  __be32 dst_mask, u32 priority,
 					  enum rocker_of_dpa_table_id goto_tbl,
@@ -2661,7 +2661,7 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2675,11 +2675,11 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 	entry->key_len = offsetof(struct rocker_flow_tbl_key,
 				  ucast_routing.group_id);
 
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans, int flags,
+			       enum switchdev_trans_ph trans_ph, int flags,
 			       u32 in_pport, u32 in_pport_mask,
 			       const u8 *eth_src, const u8 *eth_src_mask,
 			       const u8 *eth_dst, const u8 *eth_dst_mask,
@@ -2691,7 +2691,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	u32 priority;
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2726,7 +2726,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	entry->key.acl.ip_tos_mask = ip_tos_mask;
 	entry->key.acl.group_id = group_id;
 
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static struct rocker_group_tbl_entry *
@@ -2744,22 +2744,22 @@ rocker_group_tbl_find(const struct rocker *rocker,
 	return NULL;
 }
 
-static void rocker_group_tbl_entry_free(enum switchdev_trans trans,
+static void rocker_group_tbl_entry_free(enum switchdev_trans_ph trans_ph,
 					struct rocker_group_tbl_entry *entry)
 {
 	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		rocker_port_kfree(trans, entry->group_ids);
+		rocker_port_kfree(trans_ph, entry->group_ids);
 		break;
 	default:
 		break;
 	}
-	rocker_port_kfree(trans, entry);
+	rocker_port_kfree(trans_ph, entry);
 }
 
 static int rocker_group_tbl_add(struct rocker_port *rocker_port,
-				enum switchdev_trans trans, int flags,
+				enum switchdev_trans_ph trans_ph, int flags,
 				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2771,9 +2771,9 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans != SWITCHDEV_TRANS_PREPARE)
+		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
-		rocker_group_tbl_entry_free(trans, found);
+		rocker_group_tbl_entry_free(trans_ph, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
 	} else {
@@ -2781,17 +2781,17 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
 	}
 
-	if (trans != SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 		hash_add(rocker->group_tbl, &found->entry, found->group_id);
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans, flags,
+	return rocker_cmd_exec(rocker_port, trans_ph, flags,
 			       rocker_cmd_group_tbl_add, found, NULL, NULL);
 }
 
 static int rocker_group_tbl_del(struct rocker_port *rocker_port,
-				enum switchdev_trans trans, int flags,
+				enum switchdev_trans_ph trans_ph, int flags,
 				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2804,95 +2804,95 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans != SWITCHDEV_TRANS_PREPARE)
+		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
-	rocker_group_tbl_entry_free(trans, match);
+	rocker_group_tbl_entry_free(trans_ph, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans, flags,
+		err = rocker_cmd_exec(rocker_port, trans_ph, flags,
 				      rocker_cmd_group_tbl_del,
 				      found, NULL, NULL);
-		rocker_group_tbl_entry_free(trans, found);
+		rocker_group_tbl_entry_free(trans_ph, found);
 	}
 
 	return err;
 }
 
 static int rocker_group_tbl_do(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans, int flags,
+			       enum switchdev_trans_ph trans_ph, int flags,
 			       struct rocker_group_tbl_entry *entry)
 {
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_group_tbl_del(rocker_port, trans, flags, entry);
+		return rocker_group_tbl_del(rocker_port, trans_ph, flags, entry);
 	else
-		return rocker_group_tbl_add(rocker_port, trans, flags, entry);
+		return rocker_group_tbl_add(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
-				     enum switchdev_trans trans, int flags,
+				     enum switchdev_trans_ph trans_ph, int flags,
 				     __be16 vlan_id, u32 out_pport,
 				     int pop_vlan)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	entry->l2_interface.pop_vlan = pop_vlan;
 
-	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
-				   enum switchdev_trans trans,
+				   enum switchdev_trans_ph trans_ph,
 				   int flags, u8 group_count,
 				   const u32 *group_ids, u32 group_id)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = rocker_port_kcalloc(rocker_port, trans, flags,
+	entry->group_ids = rocker_port_kcalloc(rocker_port, trans_ph, flags,
 					       group_count, sizeof(u32));
 	if (!entry->group_ids) {
-		rocker_port_kfree(trans, entry);
+		rocker_port_kfree(trans_ph, entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
 
-	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static int rocker_group_l2_flood(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans, int flags,
+				 enum switchdev_trans_ph trans_ph, int flags,
 				 __be16 vlan_id, u8 group_count,
 				 const u32 *group_ids, u32 group_id)
 {
-	return rocker_group_l2_fan_out(rocker_port, trans, flags,
+	return rocker_group_l2_fan_out(rocker_port, trans_ph, flags,
 				       group_count, group_ids,
 				       group_id);
 }
 
 static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
-				   enum switchdev_trans trans, int flags,
+				   enum switchdev_trans_ph trans_ph, int flags,
 				   u32 index, const u8 *src_mac, const u8 *dst_mac,
 				   __be16 vlan_id, bool ttl_check, u32 pport)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2905,7 +2905,7 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 	entry->l3_unicast.ttl_check = ttl_check;
 	entry->l3_unicast.group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, pport);
 
-	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
 }
 
 static struct rocker_neigh_tbl_entry *
@@ -2922,43 +2922,43 @@ rocker_neigh_tbl_find(const struct rocker *rocker, __be32 ip_addr)
 }
 
 static void _rocker_neigh_add(struct rocker *rocker,
-			      enum switchdev_trans trans,
+			      enum switchdev_trans_ph trans_ph,
 			      struct rocker_neigh_tbl_entry *entry)
 {
-	if (trans != SWITCHDEV_TRANS_COMMIT)
+	if (trans_ph != SWITCHDEV_TRANS_COMMIT)
 		entry->index = rocker->neigh_tbl_next_index++;
-	if (trans == SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
 		return;
 	entry->ref_count++;
 	hash_add(rocker->neigh_tbl, &entry->entry,
 		 be32_to_cpu(entry->ip_addr));
 }
 
-static void _rocker_neigh_del(enum switchdev_trans trans,
+static void _rocker_neigh_del(enum switchdev_trans_ph trans_ph,
 			      struct rocker_neigh_tbl_entry *entry)
 {
-	if (trans == SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
 		return;
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
-		rocker_port_kfree(trans, entry);
+		rocker_port_kfree(trans_ph, entry);
 	}
 }
 
 static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
-				 enum switchdev_trans trans,
+				 enum switchdev_trans_ph trans_ph,
 				 const u8 *eth_dst, bool ttl_check)
 {
 	if (eth_dst) {
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = ttl_check;
-	} else if (trans != SWITCHDEV_TRANS_PREPARE) {
+	} else if (trans_ph != SWITCHDEV_TRANS_PREPARE) {
 		entry->ref_count++;
 	}
 }
 
 static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
-				  enum switchdev_trans trans,
+				  enum switchdev_trans_ph trans_ph,
 				  int flags, __be32 ip_addr, const u8 *eth_dst)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2975,7 +2975,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	bool removing;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2992,12 +2992,12 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 		entry->dev = rocker_port->dev;
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = true;
-		_rocker_neigh_add(rocker, trans, entry);
+		_rocker_neigh_add(rocker, trans_ph, entry);
 	} else if (removing) {
 		memcpy(entry, found, sizeof(*entry));
-		_rocker_neigh_del(trans, found);
+		_rocker_neigh_del(trans_ph, found);
 	} else if (updating) {
-		_rocker_neigh_update(found, trans, eth_dst, true);
+		_rocker_neigh_update(found, trans_ph, eth_dst, true);
 		memcpy(entry, found, sizeof(*entry));
 	} else {
 		err = -ENOENT;
@@ -3014,7 +3014,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	 * other routes' nexthops.
 	 */
 
-	err = rocker_group_l3_unicast(rocker_port, trans, flags,
+	err = rocker_group_l3_unicast(rocker_port, trans_ph, flags,
 				      entry->index,
 				      rocker_port->dev->dev_addr,
 				      entry->eth_dst,
@@ -3030,7 +3030,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 	if (adding || removing) {
 		group_id = ROCKER_GROUP_L3_UNICAST(entry->index);
-		err = rocker_flow_tbl_ucast4_routing(rocker_port, trans,
+		err = rocker_flow_tbl_ucast4_routing(rocker_port, trans_ph,
 						     eth_type, ip_addr,
 						     inet_make_mask(32),
 						     priority, goto_tbl,
@@ -3044,13 +3044,13 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 err_out:
 	if (!adding)
-		rocker_port_kfree(trans, entry);
+		rocker_port_kfree(trans_ph, entry);
 
 	return err;
 }
 
 static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
-				    enum switchdev_trans trans, __be32 ip_addr)
+				    enum switchdev_trans_ph trans_ph, __be32 ip_addr)
 {
 	struct net_device *dev = rocker_port->dev;
 	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
@@ -3068,7 +3068,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 	 */
 
 	if (n->nud_state & NUD_VALID)
-		err = rocker_port_ipv4_neigh(rocker_port, trans, 0,
+		err = rocker_port_ipv4_neigh(rocker_port, trans_ph, 0,
 					     ip_addr, n->ha);
 	else
 		neigh_event_send(n, NULL);
@@ -3078,7 +3078,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans, int flags,
+			       enum switchdev_trans_ph trans_ph, int flags,
 			       __be32 ip_addr, u32 *index)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3091,7 +3091,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	bool resolved = true;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -3108,13 +3108,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	if (adding) {
 		entry->ip_addr = ip_addr;
 		entry->dev = rocker_port->dev;
-		_rocker_neigh_add(rocker, trans, entry);
+		_rocker_neigh_add(rocker, trans_ph, entry);
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
-		_rocker_neigh_del(trans, found);
+		_rocker_neigh_del(trans_ph, found);
 	} else if (updating) {
-		_rocker_neigh_update(found, trans, NULL, false);
+		_rocker_neigh_update(found, trans_ph, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
 	} else {
 		err = -ENOENT;
@@ -3123,7 +3123,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		rocker_port_kfree(trans, entry);
+		rocker_port_kfree(trans_ph, entry);
 
 	if (err)
 		return err;
@@ -3131,13 +3131,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	/* Resolved means neigh ip_addr is resolved to neigh mac. */
 
 	if (!resolved)
-		err = rocker_port_ipv4_resolve(rocker_port, trans, ip_addr);
+		err = rocker_port_ipv4_resolve(rocker_port, trans_ph, ip_addr);
 
 	return err;
 }
 
 static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
-					enum switchdev_trans trans,
+					enum switchdev_trans_ph trans_ph,
 					int flags, __be16 vlan_id)
 {
 	struct rocker_port *p;
@@ -3148,7 +3148,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	int err = 0;
 	int i;
 
-	group_ids = rocker_port_kcalloc(rocker_port, trans, flags,
+	group_ids = rocker_port_kcalloc(rocker_port, trans_ph, flags,
 					rocker->port_count, sizeof(u32));
 	if (!group_ids)
 		return -ENOMEM;
@@ -3174,19 +3174,19 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	if (group_count == 0)
 		goto no_ports_in_vlan;
 
-	err = rocker_group_l2_flood(rocker_port, trans, flags, vlan_id,
+	err = rocker_group_l2_flood(rocker_port, trans_ph, flags, vlan_id,
 				    group_count, group_ids, group_id);
 	if (err)
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	rocker_port_kfree(trans, group_ids);
+	rocker_port_kfree(trans_ph, group_ids);
 	return err;
 }
 
 static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
-				      enum switchdev_trans trans, int flags,
+				      enum switchdev_trans_ph trans_ph, int flags,
 				      __be16 vlan_id, bool pop_vlan)
 {
 	const struct rocker *rocker = rocker_port->rocker;
@@ -3204,7 +3204,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 	if (rocker_port->stp_state == BR_STATE_LEARNING ||
 	    rocker_port->stp_state == BR_STATE_FORWARDING) {
 		out_pport = rocker_port->pport;
-		err = rocker_group_l2_interface(rocker_port, trans, flags,
+		err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
 						vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3229,7 +3229,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 		return 0;
 
 	out_pport = 0;
-	err = rocker_group_l2_interface(rocker_port, trans, flags,
+	err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
 					vlan_id, out_pport, pop_vlan);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3292,7 +3292,7 @@ static struct rocker_ctrl {
 };
 
 static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
-				     enum switchdev_trans trans, int flags,
+				     enum switchdev_trans_ph trans_ph, int flags,
 				     const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport = rocker_port->pport;
@@ -3308,7 +3308,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	int err;
 
-	err = rocker_flow_tbl_acl(rocker_port, trans, flags,
+	err = rocker_flow_tbl_acl(rocker_port, trans_ph, flags,
 				  in_pport, in_pport_mask,
 				  eth_src, eth_src_mask,
 				  ctrl->eth_dst, ctrl->eth_dst_mask,
@@ -3325,7 +3325,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
-					enum switchdev_trans trans, int flags,
+					enum switchdev_trans_ph trans_ph, int flags,
 					const struct rocker_ctrl *ctrl,
 					__be16 vlan_id)
 {
@@ -3338,7 +3338,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	err = rocker_flow_tbl_bridge(rocker_port, trans, flags,
+	err = rocker_flow_tbl_bridge(rocker_port, trans_ph, flags,
 				     ctrl->eth_dst, ctrl->eth_dst_mask,
 				     vlan_id, tunnel_id,
 				     goto_tbl, group_id, ctrl->copy_to_cpu);
@@ -3350,7 +3350,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
-				      enum switchdev_trans trans, int flags,
+				      enum switchdev_trans_ph trans_ph, int flags,
 				      const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
@@ -3360,7 +3360,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 	if (ntohs(vlan_id) == 0)
 		vlan_id = rocker_port->internal_vlan_id;
 
-	err = rocker_flow_tbl_term_mac(rocker_port, trans,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
 				       rocker_port->pport, in_pport_mask,
 				       ctrl->eth_type, ctrl->eth_dst,
 				       ctrl->eth_dst_mask, vlan_id,
@@ -3374,25 +3374,25 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans, int flags,
+				 enum switchdev_trans_ph trans_ph, int flags,
 				 const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	if (ctrl->acl)
-		return rocker_port_ctrl_vlan_acl(rocker_port, trans, flags,
+		return rocker_port_ctrl_vlan_acl(rocker_port, trans_ph, flags,
 						 ctrl, vlan_id);
 	if (ctrl->bridge)
-		return rocker_port_ctrl_vlan_bridge(rocker_port, trans, flags,
+		return rocker_port_ctrl_vlan_bridge(rocker_port, trans_ph, flags,
 						    ctrl, vlan_id);
 
 	if (ctrl->term)
-		return rocker_port_ctrl_vlan_term(rocker_port, trans, flags,
+		return rocker_port_ctrl_vlan_term(rocker_port, trans_ph, flags,
 						  ctrl, vlan_id);
 
 	return -EOPNOTSUPP;
 }
 
 static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
-				     enum switchdev_trans trans, int flags,
+				     enum switchdev_trans_ph trans_ph, int flags,
 				     __be16 vlan_id)
 {
 	int err = 0;
@@ -3400,7 +3400,7 @@ static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
 
 	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
 		if (rocker_port->ctrls[i]) {
-			err = rocker_port_ctrl_vlan(rocker_port, trans, flags,
+			err = rocker_port_ctrl_vlan(rocker_port, trans_ph, flags,
 						    &rocker_ctrls[i], vlan_id);
 			if (err)
 				return err;
@@ -3411,7 +3411,7 @@ static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl(struct rocker_port *rocker_port,
-			    enum switchdev_trans trans, int flags,
+			    enum switchdev_trans_ph trans_ph, int flags,
 			    const struct rocker_ctrl *ctrl)
 {
 	u16 vid;
@@ -3420,7 +3420,7 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port,
 	for (vid = 1; vid < VLAN_N_VID; vid++) {
 		if (!test_bit(vid, rocker_port->vlan_bitmap))
 			continue;
-		err = rocker_port_ctrl_vlan(rocker_port, trans, flags,
+		err = rocker_port_ctrl_vlan(rocker_port, trans_ph, flags,
 					    ctrl, htons(vid));
 		if (err)
 			break;
@@ -3430,7 +3430,7 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlan(struct rocker_port *rocker_port,
-			    enum switchdev_trans trans, int flags, u16 vid)
+			    enum switchdev_trans_ph trans_ph, int flags, u16 vid)
 {
 	enum rocker_of_dpa_table_id goto_tbl =
 		ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
@@ -3454,7 +3454,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 	change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
 
 	if (adding) {
-		err = rocker_port_ctrl_vlan_add(rocker_port, trans, flags,
+		err = rocker_port_ctrl_vlan_add(rocker_port, trans_ph, flags,
 						internal_vlan_id);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3463,7 +3463,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		}
 	}
 
-	err = rocker_port_vlan_l2_groups(rocker_port, trans, flags,
+	err = rocker_port_vlan_l2_groups(rocker_port, trans_ph, flags,
 					 internal_vlan_id, untagged);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3471,7 +3471,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		goto err_out;
 	}
 
-	err = rocker_port_vlan_flood_group(rocker_port, trans, flags,
+	err = rocker_port_vlan_flood_group(rocker_port, trans_ph, flags,
 					   internal_vlan_id);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3479,7 +3479,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		goto err_out;
 	}
 
-	err = rocker_flow_tbl_vlan(rocker_port, trans, flags,
+	err = rocker_flow_tbl_vlan(rocker_port, trans_ph, flags,
 				   in_pport, vlan_id, vlan_id_mask,
 				   goto_tbl, untagged, internal_vlan_id);
 	if (err)
@@ -3487,14 +3487,14 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 			   "Error (%d) port VLAN table\n", err);
 
 err_out:
-	if (trans == SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
 		change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
 
 	return err;
 }
 
 static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
-			      enum switchdev_trans trans, int flags)
+			      enum switchdev_trans_ph trans_ph, int flags)
 {
 	enum rocker_of_dpa_table_id goto_tbl;
 	u32 in_pport;
@@ -3509,7 +3509,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
 	in_pport_mask = 0xffff0000;
 	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
 
-	err = rocker_flow_tbl_ig_port(rocker_port, trans, flags,
+	err = rocker_flow_tbl_ig_port(rocker_port, trans_ph, flags,
 				      in_pport, in_pport_mask,
 				      goto_tbl);
 	if (err)
@@ -3522,7 +3522,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
 struct rocker_fdb_learn_work {
 	struct work_struct work;
 	struct rocker_port *rocker_port;
-	enum switchdev_trans trans;
+	enum switchdev_trans_ph trans_ph;
 	int flags;
 	u8 addr[ETH_ALEN];
 	u16 vid;
@@ -3546,11 +3546,11 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
 					 lw->rocker_port->dev, &info.info);
 
-	rocker_port_kfree(lw->trans, work);
+	rocker_port_kfree(lw->trans_ph, work);
 }
 
 static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans, int flags,
+				 enum switchdev_trans_ph trans_ph, int flags,
 				 const u8 *addr, __be16 vlan_id)
 {
 	struct rocker_fdb_learn_work *lw;
@@ -3567,7 +3567,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 
 	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
-		err = rocker_flow_tbl_bridge(rocker_port, trans, flags, addr,
+		err = rocker_flow_tbl_bridge(rocker_port, trans_ph, flags, addr,
 					     NULL, vlan_id, tunnel_id, goto_tbl,
 					     group_id, copy_to_cpu);
 		if (err)
@@ -3580,20 +3580,20 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	lw = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*lw));
+	lw = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*lw));
 	if (!lw)
 		return -ENOMEM;
 
 	INIT_WORK(&lw->work, rocker_port_fdb_learn_work);
 
 	lw->rocker_port = rocker_port;
-	lw->trans = trans;
+	lw->trans_ph = trans_ph;
 	lw->flags = flags;
 	ether_addr_copy(lw->addr, addr);
 	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
 
-	if (trans == SWITCHDEV_TRANS_PREPARE)
-		rocker_port_kfree(trans, lw);
+	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+		rocker_port_kfree(trans_ph, lw);
 	else
 		schedule_work(&lw->work);
 
@@ -3614,7 +3614,7 @@ rocker_fdb_tbl_find(const struct rocker *rocker,
 }
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
-			   enum switchdev_trans trans,
+			   enum switchdev_trans_ph trans_ph,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags)
 {
@@ -3624,7 +3624,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*fdb));
+	fdb = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*fdb));
 	if (!fdb)
 		return -ENOMEM;
 
@@ -3639,11 +3639,11 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	found = rocker_fdb_tbl_find(rocker, fdb);
 
 	if (removing && found) {
-		rocker_port_kfree(trans, fdb);
-		if (trans != SWITCHDEV_TRANS_PREPARE)
+		rocker_port_kfree(trans_ph, fdb);
+		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
 	} else if (!removing && !found) {
-		if (trans != SWITCHDEV_TRANS_PREPARE)
+		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 			hash_add(rocker->fdb_tbl, &fdb->entry, fdb->key_crc32);
 	}
 
@@ -3651,18 +3651,18 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		rocker_port_kfree(trans, fdb);
+		rocker_port_kfree(trans_ph, fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
 		flags |= ROCKER_OP_FLAG_REFRESH;
 	}
 
-	return rocker_port_fdb_learn(rocker_port, trans, flags, addr, vlan_id);
+	return rocker_port_fdb_learn(rocker_port, trans_ph, flags, addr, vlan_id);
 }
 
 static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans, int flags)
+				 enum switchdev_trans_ph trans_ph, int flags)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_tbl_entry *found;
@@ -3684,12 +3684,12 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
 			continue;
 		if (!found->learned)
 			continue;
-		err = rocker_port_fdb_learn(rocker_port, trans, flags,
+		err = rocker_port_fdb_learn(rocker_port, trans_ph, flags,
 					    found->key.addr,
 					    found->key.vlan_id);
 		if (err)
 			goto err_out;
-		if (trans != SWITCHDEV_TRANS_PREPARE)
+		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
 	}
 
@@ -3700,7 +3700,7 @@ err_out:
 }
 
 static int rocker_port_router_mac(struct rocker_port *rocker_port,
-				  enum switchdev_trans trans, int flags,
+				  enum switchdev_trans_ph trans_ph, int flags,
 				  __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
@@ -3714,7 +3714,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		vlan_id = rocker_port->internal_vlan_id;
 
 	eth_type = htons(ETH_P_IP);
-	err = rocker_flow_tbl_term_mac(rocker_port, trans,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
 				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3723,7 +3723,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		return err;
 
 	eth_type = htons(ETH_P_IPV6);
-	err = rocker_flow_tbl_term_mac(rocker_port, trans,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
 				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3733,7 +3733,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fwding(struct rocker_port *rocker_port,
-			      enum switchdev_trans trans, int flags)
+			      enum switchdev_trans_ph trans_ph, int flags)
 {
 	bool pop_vlan;
 	u32 out_pport;
@@ -3758,7 +3758,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port,
 			continue;
 		vlan_id = htons(vid);
 		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
-		err = rocker_group_l2_interface(rocker_port, trans, flags,
+		err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
 						vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3772,7 +3772,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_stp_update(struct rocker_port *rocker_port,
-				  enum switchdev_trans trans, int flags,
+				  enum switchdev_trans_ph trans_ph, int flags,
 				  u8 state)
 {
 	bool want[ROCKER_CTRL_MAX] = { 0, };
@@ -3781,7 +3781,7 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 	int err;
 	int i;
 
-	if (trans == SWITCHDEV_TRANS_PREPARE) {
+	if (trans_ph == SWITCHDEV_TRANS_PREPARE) {
 		memcpy(prev_ctrls, rocker_port->ctrls, sizeof(prev_ctrls));
 		prev_state = rocker_port->stp_state;
 	}
@@ -3818,7 +3818,7 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 		if (want[i] != rocker_port->ctrls[i]) {
 			int ctrl_flags = flags |
 					 (want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
-			err = rocker_port_ctrl(rocker_port, trans, ctrl_flags,
+			err = rocker_port_ctrl(rocker_port, trans_ph, ctrl_flags,
 					       &rocker_ctrls[i]);
 			if (err)
 				goto err_out;
@@ -3826,14 +3826,14 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 		}
 	}
 
-	err = rocker_port_fdb_flush(rocker_port, trans, flags);
+	err = rocker_port_fdb_flush(rocker_port, trans_ph, flags);
 	if (err)
 		goto err_out;
 
-	err = rocker_port_fwding(rocker_port, trans, flags);
+	err = rocker_port_fwding(rocker_port, trans_ph, flags);
 
 err_out:
-	if (trans == SWITCHDEV_TRANS_PREPARE) {
+	if (trans_ph == SWITCHDEV_TRANS_PREPARE) {
 		memcpy(rocker_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
 		rocker_port->stp_state = prev_state;
 	}
@@ -3842,26 +3842,26 @@ err_out:
 }
 
 static int rocker_port_fwd_enable(struct rocker_port *rocker_port,
-				  enum switchdev_trans trans, int flags)
+				  enum switchdev_trans_ph trans_ph, int flags)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will enable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to FORWARDING state */
-	return rocker_port_stp_update(rocker_port, trans, flags,
+	return rocker_port_stp_update(rocker_port, trans_ph, flags,
 				      BR_STATE_FORWARDING);
 }
 
 static int rocker_port_fwd_disable(struct rocker_port *rocker_port,
-				   enum switchdev_trans trans, int flags)
+				   enum switchdev_trans_ph trans_ph, int flags)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will disable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to DISABLED state */
-	return rocker_port_stp_update(rocker_port, trans, flags,
+	return rocker_port_stp_update(rocker_port, trans_ph, flags,
 				      BR_STATE_DISABLED);
 }
 
@@ -3952,7 +3952,7 @@ not_found:
 }
 
 static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
-				enum switchdev_trans trans, __be32 dst,
+				enum switchdev_trans_ph trans_ph, __be32 dst,
 				int dst_len, const struct fib_info *fi,
 				u32 tb_id, int flags)
 {
@@ -3976,7 +3976,7 @@ static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
 	has_gw = !!nh->nh_gw;
 
 	if (has_gw && nh_on_port) {
-		err = rocker_port_ipv4_nh(rocker_port, trans, flags,
+		err = rocker_port_ipv4_nh(rocker_port, trans_ph, flags,
 					  nh->nh_gw, &index);
 		if (err)
 			return err;
@@ -3987,7 +3987,7 @@ static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(internal_vlan_id, 0);
 	}
 
-	err = rocker_flow_tbl_ucast4_routing(rocker_port, trans, eth_type, dst,
+	err = rocker_flow_tbl_ucast4_routing(rocker_port, trans_ph, eth_type, dst,
 					     dst_mask, priority, goto_tbl,
 					     group_id, flags);
 	if (err)
@@ -4322,7 +4322,7 @@ static void rocker_port_trans_abort(const struct rocker_port *rocker_port)
 }
 
 static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
-					enum switchdev_trans trans,
+					enum switchdev_trans_ph trans_ph,
 					unsigned long brport_flags)
 {
 	unsigned long orig_flags;
@@ -4331,9 +4331,9 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	orig_flags = rocker_port->brport_flags;
 	rocker_port->brport_flags = brport_flags;
 	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
-		err = rocker_port_set_learning(rocker_port, trans);
+		err = rocker_port_set_learning(rocker_port, trans_ph);
 
-	if (trans == SWITCHDEV_TRANS_PREPARE)
+	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
 		rocker_port->brport_flags = orig_flags;
 
 	return err;
@@ -4345,7 +4345,7 @@ static int rocker_port_attr_set(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
 
-	switch (attr->trans) {
+	switch (attr->trans_ph) {
 	case SWITCHDEV_TRANS_PREPARE:
 		BUG_ON(!list_empty(&rocker_port->trans_mem));
 		break;
@@ -4358,12 +4358,12 @@ static int rocker_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, attr->trans,
+		err = rocker_port_stp_update(rocker_port, attr->trans_ph,
 					     ROCKER_OP_FLAG_NOWAIT,
 					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
-		err = rocker_port_brport_flags_set(rocker_port, attr->trans,
+		err = rocker_port_brport_flags_set(rocker_port, attr->trans_ph,
 						   attr->u.brport_flags);
 		break;
 	default:
@@ -4375,33 +4375,33 @@ static int rocker_port_attr_set(struct net_device *dev,
 }
 
 static int rocker_port_vlan_add(struct rocker_port *rocker_port,
-				enum switchdev_trans trans, u16 vid, u16 flags)
+				enum switchdev_trans_ph trans_ph, u16 vid, u16 flags)
 {
 	int err;
 
 	/* XXX deal with flags for PVID and untagged */
 
-	err = rocker_port_vlan(rocker_port, trans, 0, vid);
+	err = rocker_port_vlan(rocker_port, trans_ph, 0, vid);
 	if (err)
 		return err;
 
-	err = rocker_port_router_mac(rocker_port, trans, 0, htons(vid));
+	err = rocker_port_router_mac(rocker_port, trans_ph, 0, htons(vid));
 	if (err)
-		rocker_port_vlan(rocker_port, trans,
+		rocker_port_vlan(rocker_port, trans_ph,
 				 ROCKER_OP_FLAG_REMOVE, vid);
 
 	return err;
 }
 
 static int rocker_port_vlans_add(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans,
+				 enum switchdev_trans_ph trans_ph,
 				 const struct switchdev_obj_vlan *vlan)
 {
 	u16 vid;
 	int err;
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = rocker_port_vlan_add(rocker_port, trans,
+		err = rocker_port_vlan_add(rocker_port, trans_ph,
 					   vid, vlan->flags);
 		if (err)
 			return err;
@@ -4411,7 +4411,7 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_add(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans,
+			       enum switchdev_trans_ph trans_ph,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
@@ -4420,7 +4420,7 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, trans, fdb->addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, trans_ph, fdb->addr, vlan_id, flags);
 }
 
 static int rocker_port_obj_add(struct net_device *dev,
@@ -4430,7 +4430,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (obj->trans) {
+	switch (obj->trans_ph) {
 	case SWITCHDEV_TRANS_PREPARE:
 		BUG_ON(!list_empty(&rocker_port->trans_mem));
 		break;
@@ -4443,17 +4443,17 @@ static int rocker_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, obj->trans,
+		err = rocker_port_vlans_add(rocker_port, obj->trans_ph,
 					    &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
-		err = rocker_port_fib_ipv4(rocker_port, obj->trans,
+		err = rocker_port_fib_ipv4(rocker_port, obj->trans_ph,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, obj->trans, &obj->u.fdb);
+		err = rocker_port_fdb_add(rocker_port, obj->trans_ph, &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4493,7 +4493,7 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_del(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans,
+			       enum switchdev_trans_ph trans_ph,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
@@ -4502,7 +4502,7 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, trans, fdb->addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, trans_ph, fdb->addr, vlan_id, flags);
 }
 
 static int rocker_port_obj_del(struct net_device *dev,
@@ -4524,7 +4524,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_del(rocker_port, obj->trans, &obj->u.fdb);
+		err = rocker_port_fdb_del(rocker_port, obj->trans_ph, &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 319baab..494f510 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -16,7 +16,7 @@
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 
-enum switchdev_trans {
+enum switchdev_trans_ph {
 	SWITCHDEV_TRANS_NONE,
 	SWITCHDEV_TRANS_PREPARE,
 	SWITCHDEV_TRANS_ABORT,
@@ -32,7 +32,7 @@ enum switchdev_attr_id {
 
 struct switchdev_attr {
 	enum switchdev_attr_id id;
-	enum switchdev_trans trans;
+	enum switchdev_trans_ph trans_ph;
 	u32 flags;
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
@@ -52,7 +52,7 @@ enum switchdev_obj_id {
 
 struct switchdev_obj {
 	enum switchdev_obj_id id;
-	enum switchdev_trans trans;
+	enum switchdev_trans_ph trans_ph;
 	int (*cb)(struct net_device *dev, struct switchdev_obj *obj);
 	union {
 		struct switchdev_obj_vlan {		/* PORT_VLAN */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index cce9738..7f50b74 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -250,7 +250,7 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 	u16 vid;
 	int err;
 
-	switch (obj->trans) {
+	switch (obj->trans_ph) {
 	case SWITCHDEV_TRANS_PREPARE:
 		if (!ds->drv->port_vlan_add || !ds->drv->port_pvid_set)
 			return -EOPNOTSUPP;
@@ -354,9 +354,9 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (obj->trans == SWITCHDEV_TRANS_PREPARE)
+	if (obj->trans_ph == SWITCHDEV_TRANS_PREPARE)
 		ret = ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
-	else if (obj->trans == SWITCHDEV_TRANS_COMMIT)
+	else if (obj->trans_ph == SWITCHDEV_TRANS_COMMIT)
 		ret = ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
 
 	return ret;
@@ -462,7 +462,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		if (attr->trans == SWITCHDEV_TRANS_COMMIT)
+		if (attr->trans_ph == SWITCHDEV_TRANS_COMMIT)
 			ret = dsa_slave_stp_update(dev, attr->u.stp_state);
 		break;
 	default:
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index fda38f8..df5a544 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -163,7 +163,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * but should not commit the attr.
 	 */
 
-	attr->trans = SWITCHDEV_TRANS_PREPARE;
+	attr->trans_ph = SWITCHDEV_TRANS_PREPARE;
 	err = __switchdev_port_attr_set(dev, attr);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
@@ -172,7 +172,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 		 */
 
 		if (err != -EOPNOTSUPP) {
-			attr->trans = SWITCHDEV_TRANS_ABORT;
+			attr->trans_ph = SWITCHDEV_TRANS_ABORT;
 			__switchdev_port_attr_set(dev, attr);
 		}
 
@@ -184,7 +184,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	attr->trans = SWITCHDEV_TRANS_COMMIT;
+	attr->trans_ph = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_attr_set(dev, attr);
 	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
 	     dev->name, attr->id);
@@ -243,7 +243,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * but should not commit the obj.
 	 */
 
-	obj->trans = SWITCHDEV_TRANS_PREPARE;
+	obj->trans_ph = SWITCHDEV_TRANS_PREPARE;
 	err = __switchdev_port_obj_add(dev, obj);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
@@ -252,7 +252,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 		 */
 
 		if (err != -EOPNOTSUPP) {
-			obj->trans = SWITCHDEV_TRANS_ABORT;
+			obj->trans_ph = SWITCHDEV_TRANS_ABORT;
 			__switchdev_port_obj_add(dev, obj);
 		}
 
@@ -264,7 +264,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	obj->trans = SWITCHDEV_TRANS_COMMIT;
+	obj->trans_ph = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_obj_add(dev, obj);
 	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
 
-- 
1.9.3
