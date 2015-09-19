From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 3/6] rocker: switch to local transaction phase enum
Date: Sat, 19 Sep 2015 14:29:08 +0200
Message-ID: <1442665751-10949-4-git-send-email-jiri@resnulli.us>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35590 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbbISM3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 08:29:21 -0400
Received: by wicge5 with SMTP id ge5so62471649wic.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 05:29:19 -0700 (PDT)
In-Reply-To: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since switchdev_trans_ph anum is going to be removed, and rocker code is
way too complicated in this matter to be converted, just introduce local
enum for transaction phase. Pass it around in local transaction
structure.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 469 ++++++++++++++++++-----------------
 1 file changed, 245 insertions(+), 224 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 92e1520..de1a367 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -339,8 +339,19 @@ static bool rocker_port_is_ovsed(const struct rocker_port *rocker_port)
 #define ROCKER_OP_FLAG_LEARNED		BIT(2)
 #define ROCKER_OP_FLAG_REFRESH		BIT(3)
 
+enum rocker_trans_ph {
+	ROCKER_TRANS_PH_NONE,
+	ROCKER_TRANS_PH_PREPARE,
+	ROCKER_TRANS_PH_ABORT,
+	ROCKER_TRANS_PH_COMMIT,
+};
+
+struct rocker_trans {
+	enum rocker_trans_ph ph;
+};
+
 static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
-				     enum switchdev_trans_ph trans_ph, int flags,
+				     struct rocker_trans *rtrans, int flags,
 				     size_t size)
 {
 	struct list_head *elem = NULL;
@@ -356,19 +367,19 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 	 * memory used in the commit phase.
 	 */
 
-	switch (trans_ph) {
-	case SWITCHDEV_TRANS_PREPARE:
+	switch (rtrans->ph) {
+	case ROCKER_TRANS_PH_PREPARE:
 		elem = kzalloc(size + sizeof(*elem), gfp_flags);
 		if (!elem)
 			return NULL;
 		list_add_tail(elem, &rocker_port->trans_mem);
 		break;
-	case SWITCHDEV_TRANS_COMMIT:
+	case ROCKER_TRANS_PH_COMMIT:
 		BUG_ON(list_empty(&rocker_port->trans_mem));
 		elem = rocker_port->trans_mem.next;
 		list_del_init(elem);
 		break;
-	case SWITCHDEV_TRANS_NONE:
+	case ROCKER_TRANS_PH_NONE:
 		elem = kzalloc(size + sizeof(*elem), gfp_flags);
 		if (elem)
 			INIT_LIST_HEAD(elem);
@@ -381,20 +392,20 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 }
 
 static void *rocker_port_kzalloc(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct rocker_trans *rtrans, int flags,
 				 size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans_ph, flags, size);
+	return __rocker_port_mem_alloc(rocker_port, rtrans, flags, size);
 }
 
 static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct rocker_trans *rtrans, int flags,
 				 size_t n, size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans_ph, flags, n * size);
+	return __rocker_port_mem_alloc(rocker_port, rtrans, flags, n * size);
 }
 
-static void rocker_port_kfree(enum switchdev_trans_ph trans_ph, const void *mem)
+static void rocker_port_kfree(struct rocker_trans *rtrans, const void *mem)
 {
 	struct list_head *elem;
 
@@ -403,7 +414,7 @@ static void rocker_port_kfree(enum switchdev_trans_ph trans_ph, const void *mem)
 	 * commit phase.
 	 */
 
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE)
 		return;
 
 	elem = (struct list_head *)mem - 1;
@@ -430,22 +441,22 @@ static void rocker_wait_init(struct rocker_wait *wait)
 }
 
 static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
-					      enum switchdev_trans_ph trans_ph,
+					      struct rocker_trans *rtrans,
 					      int flags)
 {
 	struct rocker_wait *wait;
 
-	wait = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*wait));
+	wait = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*wait));
 	if (!wait)
 		return NULL;
 	rocker_wait_init(wait);
 	return wait;
 }
 
-static void rocker_wait_destroy(enum switchdev_trans_ph trans_ph,
+static void rocker_wait_destroy(struct rocker_trans *rtrans,
 				struct rocker_wait *wait)
 {
-	rocker_port_kfree(trans_ph, wait);
+	rocker_port_kfree(rtrans, wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -1408,7 +1419,7 @@ static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
 		wait = rocker_desc_cookie_ptr_get(desc_info);
 		if (wait->nowait) {
 			rocker_desc_gen_clear(desc_info);
-			rocker_wait_destroy(SWITCHDEV_TRANS_NONE, wait);
+			rocker_wait_destroy(ROCKER_TRANS_PH_NONE, wait);
 		} else {
 			rocker_wait_wake_up(wait);
 		}
@@ -1463,7 +1474,7 @@ static int rocker_event_link_change(const struct rocker *rocker,
 }
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
-			   enum switchdev_trans_ph trans_ph,
+			   struct rocker_trans *rtrans,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags);
 
@@ -1496,7 +1507,7 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 	    rocker_port->stp_state != BR_STATE_FORWARDING)
 		return 0;
 
-	return rocker_port_fdb(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_port_fdb(rocker_port, ROCKER_TRANS_PH_NONE,
 			       addr, vlan_id, flags);
 }
 
@@ -1582,7 +1593,7 @@ typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
 				    void *priv);
 
 static int rocker_cmd_exec(struct rocker_port *rocker_port,
-			   enum switchdev_trans_ph trans_ph, int flags,
+			   struct rocker_trans *rtrans, int flags,
 			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
 			   rocker_cmd_proc_cb_t process, void *process_priv)
 {
@@ -1593,7 +1604,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int err;
 
-	wait = rocker_wait_create(rocker_port, trans_ph, flags);
+	wait = rocker_wait_create(rocker_port, rtrans, flags);
 	if (!wait)
 		return -ENOMEM;
 	wait->nowait = nowait;
@@ -1615,7 +1626,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 
 	rocker_desc_cookie_ptr_set(desc_info, wait);
 
-	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 		rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
 
 	spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
@@ -1623,7 +1634,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 	if (nowait)
 		return 0;
 
-	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 		if (!rocker_wait_event_timeout(wait, HZ / 10))
 			return -EIO;
 
@@ -1636,7 +1647,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 
 	rocker_desc_gen_clear(desc_info);
 out:
-	rocker_wait_destroy(trans_ph, wait);
+	rocker_wait_destroy(rtrans, wait);
 	return err;
 }
 
@@ -1875,7 +1886,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, ROCKER_TRANS_PH_NONE, 0,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_ethtool_proc,
 			       ecmd);
@@ -1884,7 +1895,7 @@ static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, ROCKER_TRANS_PH_NONE, 0,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_macaddr_proc,
 			       macaddr);
@@ -1893,7 +1904,7 @@ static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, ROCKER_TRANS_PH_NONE, 0,
 			       rocker_cmd_set_port_settings_ethtool_prep,
 			       ecmd, NULL, NULL);
 }
@@ -1901,7 +1912,7 @@ static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, ROCKER_TRANS_PH_NONE, 0,
 			       rocker_cmd_set_port_settings_macaddr_prep,
 			       macaddr, NULL, NULL);
 }
@@ -1909,15 +1920,15 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
 					    int mtu)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, ROCKER_TRANS_PH_NONE, 0,
 			       rocker_cmd_set_port_settings_mtu_prep,
 			       &mtu, NULL, NULL);
 }
 
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
-				    enum switchdev_trans_ph trans_ph)
+				    struct rocker_trans *rtrans)
 {
-	return rocker_cmd_exec(rocker_port, trans_ph, 0,
+	return rocker_cmd_exec(rocker_port, rtrans, 0,
 			       rocker_cmd_set_port_learning_prep,
 			       NULL, NULL, NULL);
 }
@@ -2433,7 +2444,7 @@ rocker_flow_tbl_find(const struct rocker *rocker,
 }
 
 static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct rocker_trans *rtrans, int flags,
 			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2449,9 +2460,9 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 
 	if (found) {
 		match->cookie = found->cookie;
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 			hash_del(&found->entry);
-		rocker_port_kfree(trans_ph, found);
+		rocker_port_kfree(rtrans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -2460,17 +2471,17 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
 	}
 
-	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans_ph, flags,
+	return rocker_cmd_exec(rocker_port, rtrans, flags,
 			       rocker_cmd_flow_tbl_add, found, NULL, NULL);
 }
 
 static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct rocker_trans *rtrans, int flags,
 			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2486,43 +2497,43 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_flow_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	rocker_port_kfree(trans_ph, match);
+	rocker_port_kfree(rtrans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans_ph, flags,
+		err = rocker_cmd_exec(rocker_port, rtrans, flags,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL);
-		rocker_port_kfree(trans_ph, found);
+		rocker_port_kfree(rtrans, found);
 	}
 
 	return err;
 }
 
 static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
-			      enum switchdev_trans_ph trans_ph, int flags,
+			      struct rocker_trans *rtrans, int flags,
 			      struct rocker_flow_tbl_entry *entry)
 {
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_flow_tbl_del(rocker_port, trans_ph, flags, entry);
+		return rocker_flow_tbl_del(rocker_port, rtrans, flags, entry);
 	else
-		return rocker_flow_tbl_add(rocker_port, trans_ph, flags, entry);
+		return rocker_flow_tbl_add(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
-				   enum switchdev_trans_ph trans_ph, int flags,
+				   struct rocker_trans *rtrans, int flags,
 				   u32 in_pport, u32 in_pport_mask,
 				   enum rocker_of_dpa_table_id goto_tbl)
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2532,11 +2543,11 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 	entry->key.ig_port.in_pport_mask = in_pport_mask;
 	entry->key.ig_port.goto_tbl = goto_tbl;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, int flags,
+				struct rocker_trans *rtrans, int flags,
 				u32 in_pport, __be16 vlan_id,
 				__be16 vlan_id_mask,
 				enum rocker_of_dpa_table_id goto_tbl,
@@ -2544,7 +2555,7 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2558,11 +2569,11 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 	entry->key.vlan.untagged = untagged;
 	entry->key.vlan.new_vlan_id = new_vlan_id;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
-				    enum switchdev_trans_ph trans_ph,
+				    struct rocker_trans *rtrans,
 				    u32 in_pport, u32 in_pport_mask,
 				    __be16 eth_type, const u8 *eth_dst,
 				    const u8 *eth_dst_mask, __be16 vlan_id,
@@ -2571,7 +2582,7 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2595,11 +2606,11 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
 	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph, int flags,
+				  struct rocker_trans *rtrans, int flags,
 				  const u8 *eth_dst, const u8 *eth_dst_mask,
 				  __be16 vlan_id, u32 tunnel_id,
 				  enum rocker_of_dpa_table_id goto_tbl,
@@ -2611,7 +2622,7 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2649,11 +2660,11 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	entry->key.bridge.group_id = group_id;
 	entry->key.bridge.copy_to_cpu = copy_to_cpu;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
-					  enum switchdev_trans_ph trans_ph,
+					  struct rocker_trans *rtrans,
 					  __be16 eth_type, __be32 dst,
 					  __be32 dst_mask, u32 priority,
 					  enum rocker_of_dpa_table_id goto_tbl,
@@ -2661,7 +2672,7 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2675,11 +2686,11 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 	entry->key_len = offsetof(struct rocker_flow_tbl_key,
 				  ucast_routing.group_id);
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct rocker_trans *rtrans, int flags,
 			       u32 in_pport, u32 in_pport_mask,
 			       const u8 *eth_src, const u8 *eth_src_mask,
 			       const u8 *eth_dst, const u8 *eth_dst_mask,
@@ -2691,7 +2702,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	u32 priority;
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2726,7 +2737,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	entry->key.acl.ip_tos_mask = ip_tos_mask;
 	entry->key.acl.group_id = group_id;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static struct rocker_group_tbl_entry *
@@ -2744,22 +2755,22 @@ rocker_group_tbl_find(const struct rocker *rocker,
 	return NULL;
 }
 
-static void rocker_group_tbl_entry_free(enum switchdev_trans_ph trans_ph,
+static void rocker_group_tbl_entry_free(struct rocker_trans *rtrans,
 					struct rocker_group_tbl_entry *entry)
 {
 	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		rocker_port_kfree(trans_ph, entry->group_ids);
+		rocker_port_kfree(rtrans, entry->group_ids);
 		break;
 	default:
 		break;
 	}
-	rocker_port_kfree(trans_ph, entry);
+	rocker_port_kfree(rtrans, entry);
 }
 
 static int rocker_group_tbl_add(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, int flags,
+				struct rocker_trans *rtrans, int flags,
 				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2771,9 +2782,9 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 			hash_del(&found->entry);
-		rocker_group_tbl_entry_free(trans_ph, found);
+		rocker_group_tbl_entry_free(rtrans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
 	} else {
@@ -2781,17 +2792,17 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
 	}
 
-	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 		hash_add(rocker->group_tbl, &found->entry, found->group_id);
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans_ph, flags,
+	return rocker_cmd_exec(rocker_port, rtrans, flags,
 			       rocker_cmd_group_tbl_add, found, NULL, NULL);
 }
 
 static int rocker_group_tbl_del(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, int flags,
+				struct rocker_trans *rtrans, int flags,
 				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2804,95 +2815,95 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
-	rocker_group_tbl_entry_free(trans_ph, match);
+	rocker_group_tbl_entry_free(rtrans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans_ph, flags,
+		err = rocker_cmd_exec(rocker_port, rtrans, flags,
 				      rocker_cmd_group_tbl_del,
 				      found, NULL, NULL);
-		rocker_group_tbl_entry_free(trans_ph, found);
+		rocker_group_tbl_entry_free(rtrans, found);
 	}
 
 	return err;
 }
 
 static int rocker_group_tbl_do(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct rocker_trans *rtrans, int flags,
 			       struct rocker_group_tbl_entry *entry)
 {
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_group_tbl_del(rocker_port, trans_ph, flags, entry);
+		return rocker_group_tbl_del(rocker_port, rtrans, flags, entry);
 	else
-		return rocker_group_tbl_add(rocker_port, trans_ph, flags, entry);
+		return rocker_group_tbl_add(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
-				     enum switchdev_trans_ph trans_ph, int flags,
+				     struct rocker_trans *rtrans, int flags,
 				     __be16 vlan_id, u32 out_pport,
 				     int pop_vlan)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	entry->l2_interface.pop_vlan = pop_vlan;
 
-	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_group_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
-				   enum switchdev_trans_ph trans_ph,
+				   struct rocker_trans *rtrans,
 				   int flags, u8 group_count,
 				   const u32 *group_ids, u32 group_id)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = rocker_port_kcalloc(rocker_port, trans_ph, flags,
+	entry->group_ids = rocker_port_kcalloc(rocker_port, rtrans, flags,
 					       group_count, sizeof(u32));
 	if (!entry->group_ids) {
-		rocker_port_kfree(trans_ph, entry);
+		rocker_port_kfree(rtrans, entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
 
-	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_group_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static int rocker_group_l2_flood(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct rocker_trans *rtrans, int flags,
 				 __be16 vlan_id, u8 group_count,
 				 const u32 *group_ids, u32 group_id)
 {
-	return rocker_group_l2_fan_out(rocker_port, trans_ph, flags,
+	return rocker_group_l2_fan_out(rocker_port, rtrans, flags,
 				       group_count, group_ids,
 				       group_id);
 }
 
 static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
-				   enum switchdev_trans_ph trans_ph, int flags,
+				   struct rocker_trans *rtrans, int flags,
 				   u32 index, const u8 *src_mac, const u8 *dst_mac,
 				   __be16 vlan_id, bool ttl_check, u32 pport)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2905,7 +2916,7 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 	entry->l3_unicast.ttl_check = ttl_check;
 	entry->l3_unicast.group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, pport);
 
-	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_group_tbl_do(rocker_port, rtrans, flags, entry);
 }
 
 static struct rocker_neigh_tbl_entry *
@@ -2922,43 +2933,43 @@ rocker_neigh_tbl_find(const struct rocker *rocker, __be32 ip_addr)
 }
 
 static void _rocker_neigh_add(struct rocker *rocker,
-			      enum switchdev_trans_ph trans_ph,
+			      struct rocker_trans *rtrans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
-	if (trans_ph != SWITCHDEV_TRANS_COMMIT)
+	if (rtrans->ph != ROCKER_TRANS_PH_COMMIT)
 		entry->index = rocker->neigh_tbl_next_index++;
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE)
 		return;
 	entry->ref_count++;
 	hash_add(rocker->neigh_tbl, &entry->entry,
 		 be32_to_cpu(entry->ip_addr));
 }
 
-static void _rocker_neigh_del(enum switchdev_trans_ph trans_ph,
+static void _rocker_neigh_del(struct rocker_trans *rtrans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE)
 		return;
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
-		rocker_port_kfree(trans_ph, entry);
+		rocker_port_kfree(rtrans, entry);
 	}
 }
 
 static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
-				 enum switchdev_trans_ph trans_ph,
+				 struct rocker_trans *rtrans,
 				 const u8 *eth_dst, bool ttl_check)
 {
 	if (eth_dst) {
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = ttl_check;
-	} else if (trans_ph != SWITCHDEV_TRANS_PREPARE) {
+	} else if (rtrans->ph != ROCKER_TRANS_PH_PREPARE) {
 		entry->ref_count++;
 	}
 }
 
 static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph,
+				  struct rocker_trans *rtrans,
 				  int flags, __be32 ip_addr, const u8 *eth_dst)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2975,7 +2986,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	bool removing;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2992,12 +3003,12 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 		entry->dev = rocker_port->dev;
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = true;
-		_rocker_neigh_add(rocker, trans_ph, entry);
+		_rocker_neigh_add(rocker, rtrans, entry);
 	} else if (removing) {
 		memcpy(entry, found, sizeof(*entry));
-		_rocker_neigh_del(trans_ph, found);
+		_rocker_neigh_del(rtrans, found);
 	} else if (updating) {
-		_rocker_neigh_update(found, trans_ph, eth_dst, true);
+		_rocker_neigh_update(found, rtrans, eth_dst, true);
 		memcpy(entry, found, sizeof(*entry));
 	} else {
 		err = -ENOENT;
@@ -3014,7 +3025,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	 * other routes' nexthops.
 	 */
 
-	err = rocker_group_l3_unicast(rocker_port, trans_ph, flags,
+	err = rocker_group_l3_unicast(rocker_port, rtrans, flags,
 				      entry->index,
 				      rocker_port->dev->dev_addr,
 				      entry->eth_dst,
@@ -3030,7 +3041,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 	if (adding || removing) {
 		group_id = ROCKER_GROUP_L3_UNICAST(entry->index);
-		err = rocker_flow_tbl_ucast4_routing(rocker_port, trans_ph,
+		err = rocker_flow_tbl_ucast4_routing(rocker_port, rtrans,
 						     eth_type, ip_addr,
 						     inet_make_mask(32),
 						     priority, goto_tbl,
@@ -3044,13 +3055,13 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 err_out:
 	if (!adding)
-		rocker_port_kfree(trans_ph, entry);
+		rocker_port_kfree(rtrans, entry);
 
 	return err;
 }
 
 static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
-				    enum switchdev_trans_ph trans_ph, __be32 ip_addr)
+				    struct rocker_trans *rtrans, __be32 ip_addr)
 {
 	struct net_device *dev = rocker_port->dev;
 	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
@@ -3068,7 +3079,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 	 */
 
 	if (n->nud_state & NUD_VALID)
-		err = rocker_port_ipv4_neigh(rocker_port, trans_ph, 0,
+		err = rocker_port_ipv4_neigh(rocker_port, rtrans, 0,
 					     ip_addr, n->ha);
 	else
 		neigh_event_send(n, NULL);
@@ -3078,7 +3089,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct rocker_trans *rtrans, int flags,
 			       __be32 ip_addr, u32 *index)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3091,7 +3102,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	bool resolved = true;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -3108,13 +3119,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	if (adding) {
 		entry->ip_addr = ip_addr;
 		entry->dev = rocker_port->dev;
-		_rocker_neigh_add(rocker, trans_ph, entry);
+		_rocker_neigh_add(rocker, rtrans, entry);
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
-		_rocker_neigh_del(trans_ph, found);
+		_rocker_neigh_del(rtrans, found);
 	} else if (updating) {
-		_rocker_neigh_update(found, trans_ph, NULL, false);
+		_rocker_neigh_update(found, rtrans, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
 	} else {
 		err = -ENOENT;
@@ -3123,7 +3134,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		rocker_port_kfree(trans_ph, entry);
+		rocker_port_kfree(rtrans, entry);
 
 	if (err)
 		return err;
@@ -3131,13 +3142,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	/* Resolved means neigh ip_addr is resolved to neigh mac. */
 
 	if (!resolved)
-		err = rocker_port_ipv4_resolve(rocker_port, trans_ph, ip_addr);
+		err = rocker_port_ipv4_resolve(rocker_port, rtrans, ip_addr);
 
 	return err;
 }
 
 static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
-					enum switchdev_trans_ph trans_ph,
+					struct rocker_trans *rtrans,
 					int flags, __be16 vlan_id)
 {
 	struct rocker_port *p;
@@ -3148,7 +3159,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	int err = 0;
 	int i;
 
-	group_ids = rocker_port_kcalloc(rocker_port, trans_ph, flags,
+	group_ids = rocker_port_kcalloc(rocker_port, rtrans, flags,
 					rocker->port_count, sizeof(u32));
 	if (!group_ids)
 		return -ENOMEM;
@@ -3174,19 +3185,19 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	if (group_count == 0)
 		goto no_ports_in_vlan;
 
-	err = rocker_group_l2_flood(rocker_port, trans_ph, flags, vlan_id,
+	err = rocker_group_l2_flood(rocker_port, rtrans, flags, vlan_id,
 				    group_count, group_ids, group_id);
 	if (err)
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	rocker_port_kfree(trans_ph, group_ids);
+	rocker_port_kfree(rtrans, group_ids);
 	return err;
 }
 
 static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
-				      enum switchdev_trans_ph trans_ph, int flags,
+				      struct rocker_trans *rtrans, int flags,
 				      __be16 vlan_id, bool pop_vlan)
 {
 	const struct rocker *rocker = rocker_port->rocker;
@@ -3204,7 +3215,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 	if (rocker_port->stp_state == BR_STATE_LEARNING ||
 	    rocker_port->stp_state == BR_STATE_FORWARDING) {
 		out_pport = rocker_port->pport;
-		err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
+		err = rocker_group_l2_interface(rocker_port, rtrans, flags,
 						vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3229,7 +3240,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 		return 0;
 
 	out_pport = 0;
-	err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
+	err = rocker_group_l2_interface(rocker_port, rtrans, flags,
 					vlan_id, out_pport, pop_vlan);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3292,7 +3303,7 @@ static struct rocker_ctrl {
 };
 
 static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
-				     enum switchdev_trans_ph trans_ph, int flags,
+				     struct rocker_trans *rtrans, int flags,
 				     const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport = rocker_port->pport;
@@ -3308,7 +3319,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	int err;
 
-	err = rocker_flow_tbl_acl(rocker_port, trans_ph, flags,
+	err = rocker_flow_tbl_acl(rocker_port, rtrans, flags,
 				  in_pport, in_pport_mask,
 				  eth_src, eth_src_mask,
 				  ctrl->eth_dst, ctrl->eth_dst_mask,
@@ -3325,7 +3336,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
-					enum switchdev_trans_ph trans_ph, int flags,
+					struct rocker_trans *rtrans, int flags,
 					const struct rocker_ctrl *ctrl,
 					__be16 vlan_id)
 {
@@ -3338,7 +3349,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	err = rocker_flow_tbl_bridge(rocker_port, trans_ph, flags,
+	err = rocker_flow_tbl_bridge(rocker_port, rtrans, flags,
 				     ctrl->eth_dst, ctrl->eth_dst_mask,
 				     vlan_id, tunnel_id,
 				     goto_tbl, group_id, ctrl->copy_to_cpu);
@@ -3350,7 +3361,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
-				      enum switchdev_trans_ph trans_ph, int flags,
+				      struct rocker_trans *rtrans, int flags,
 				      const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
@@ -3360,7 +3371,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 	if (ntohs(vlan_id) == 0)
 		vlan_id = rocker_port->internal_vlan_id;
 
-	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
+	err = rocker_flow_tbl_term_mac(rocker_port, rtrans,
 				       rocker_port->pport, in_pport_mask,
 				       ctrl->eth_type, ctrl->eth_dst,
 				       ctrl->eth_dst_mask, vlan_id,
@@ -3374,25 +3385,25 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct rocker_trans *rtrans, int flags,
 				 const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	if (ctrl->acl)
-		return rocker_port_ctrl_vlan_acl(rocker_port, trans_ph, flags,
+		return rocker_port_ctrl_vlan_acl(rocker_port, rtrans, flags,
 						 ctrl, vlan_id);
 	if (ctrl->bridge)
-		return rocker_port_ctrl_vlan_bridge(rocker_port, trans_ph, flags,
+		return rocker_port_ctrl_vlan_bridge(rocker_port, rtrans, flags,
 						    ctrl, vlan_id);
 
 	if (ctrl->term)
-		return rocker_port_ctrl_vlan_term(rocker_port, trans_ph, flags,
+		return rocker_port_ctrl_vlan_term(rocker_port, rtrans, flags,
 						  ctrl, vlan_id);
 
 	return -EOPNOTSUPP;
 }
 
 static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
-				     enum switchdev_trans_ph trans_ph, int flags,
+				     struct rocker_trans *rtrans, int flags,
 				     __be16 vlan_id)
 {
 	int err = 0;
@@ -3400,7 +3411,7 @@ static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
 
 	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
 		if (rocker_port->ctrls[i]) {
-			err = rocker_port_ctrl_vlan(rocker_port, trans_ph, flags,
+			err = rocker_port_ctrl_vlan(rocker_port, rtrans, flags,
 						    &rocker_ctrls[i], vlan_id);
 			if (err)
 				return err;
@@ -3411,7 +3422,7 @@ static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl(struct rocker_port *rocker_port,
-			    enum switchdev_trans_ph trans_ph, int flags,
+			    struct rocker_trans *rtrans, int flags,
 			    const struct rocker_ctrl *ctrl)
 {
 	u16 vid;
@@ -3420,7 +3431,7 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port,
 	for (vid = 1; vid < VLAN_N_VID; vid++) {
 		if (!test_bit(vid, rocker_port->vlan_bitmap))
 			continue;
-		err = rocker_port_ctrl_vlan(rocker_port, trans_ph, flags,
+		err = rocker_port_ctrl_vlan(rocker_port, rtrans, flags,
 					    ctrl, htons(vid));
 		if (err)
 			break;
@@ -3430,7 +3441,7 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlan(struct rocker_port *rocker_port,
-			    enum switchdev_trans_ph trans_ph, int flags, u16 vid)
+			    struct rocker_trans *rtrans, int flags, u16 vid)
 {
 	enum rocker_of_dpa_table_id goto_tbl =
 		ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
@@ -3454,7 +3465,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 	change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
 
 	if (adding) {
-		err = rocker_port_ctrl_vlan_add(rocker_port, trans_ph, flags,
+		err = rocker_port_ctrl_vlan_add(rocker_port, rtrans, flags,
 						internal_vlan_id);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3463,7 +3474,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		}
 	}
 
-	err = rocker_port_vlan_l2_groups(rocker_port, trans_ph, flags,
+	err = rocker_port_vlan_l2_groups(rocker_port, rtrans, flags,
 					 internal_vlan_id, untagged);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3471,7 +3482,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		goto err_out;
 	}
 
-	err = rocker_port_vlan_flood_group(rocker_port, trans_ph, flags,
+	err = rocker_port_vlan_flood_group(rocker_port, rtrans, flags,
 					   internal_vlan_id);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3479,7 +3490,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		goto err_out;
 	}
 
-	err = rocker_flow_tbl_vlan(rocker_port, trans_ph, flags,
+	err = rocker_flow_tbl_vlan(rocker_port, rtrans, flags,
 				   in_pport, vlan_id, vlan_id_mask,
 				   goto_tbl, untagged, internal_vlan_id);
 	if (err)
@@ -3487,14 +3498,14 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 			   "Error (%d) port VLAN table\n", err);
 
 err_out:
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE)
 		change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
 
 	return err;
 }
 
 static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
-			      enum switchdev_trans_ph trans_ph, int flags)
+			      struct rocker_trans *rtrans, int flags)
 {
 	enum rocker_of_dpa_table_id goto_tbl;
 	u32 in_pport;
@@ -3509,7 +3520,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
 	in_pport_mask = 0xffff0000;
 	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
 
-	err = rocker_flow_tbl_ig_port(rocker_port, trans_ph, flags,
+	err = rocker_flow_tbl_ig_port(rocker_port, rtrans, flags,
 				      in_pport, in_pport_mask,
 				      goto_tbl);
 	if (err)
@@ -3522,7 +3533,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
 struct rocker_fdb_learn_work {
 	struct work_struct work;
 	struct rocker_port *rocker_port;
-	enum switchdev_trans_ph trans_ph;
+	struct rocker_trans *rtrans;
 	int flags;
 	u8 addr[ETH_ALEN];
 	u16 vid;
@@ -3546,11 +3557,11 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
 					 lw->rocker_port->dev, &info.info);
 
-	rocker_port_kfree(lw->trans_ph, work);
+	rocker_port_kfree(lw->rtrans, work);
 }
 
 static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct rocker_trans *rtrans, int flags,
 				 const u8 *addr, __be16 vlan_id)
 {
 	struct rocker_fdb_learn_work *lw;
@@ -3567,7 +3578,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 
 	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
-		err = rocker_flow_tbl_bridge(rocker_port, trans_ph, flags, addr,
+		err = rocker_flow_tbl_bridge(rocker_port, rtrans, flags, addr,
 					     NULL, vlan_id, tunnel_id, goto_tbl,
 					     group_id, copy_to_cpu);
 		if (err)
@@ -3580,20 +3591,20 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	lw = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*lw));
+	lw = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*lw));
 	if (!lw)
 		return -ENOMEM;
 
 	INIT_WORK(&lw->work, rocker_port_fdb_learn_work);
 
 	lw->rocker_port = rocker_port;
-	lw->trans_ph = trans_ph;
+	lw->rtrans = rtrans;
 	lw->flags = flags;
 	ether_addr_copy(lw->addr, addr);
 	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
 
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
-		rocker_port_kfree(trans_ph, lw);
+	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE)
+		rocker_port_kfree(rtrans, lw);
 	else
 		schedule_work(&lw->work);
 
@@ -3614,7 +3625,7 @@ rocker_fdb_tbl_find(const struct rocker *rocker,
 }
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
-			   enum switchdev_trans_ph trans_ph,
+			   struct rocker_trans *rtrans,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags)
 {
@@ -3624,7 +3635,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*fdb));
+	fdb = rocker_port_kzalloc(rocker_port, rtrans, flags, sizeof(*fdb));
 	if (!fdb)
 		return -ENOMEM;
 
@@ -3639,11 +3650,11 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	found = rocker_fdb_tbl_find(rocker, fdb);
 
 	if (removing && found) {
-		rocker_port_kfree(trans_ph, fdb);
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		rocker_port_kfree(rtrans, fdb);
+		if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 			hash_del(&found->entry);
 	} else if (!removing && !found) {
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 			hash_add(rocker->fdb_tbl, &fdb->entry, fdb->key_crc32);
 	}
 
@@ -3651,18 +3662,18 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		rocker_port_kfree(trans_ph, fdb);
+		rocker_port_kfree(rtrans, fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
 		flags |= ROCKER_OP_FLAG_REFRESH;
 	}
 
-	return rocker_port_fdb_learn(rocker_port, trans_ph, flags, addr, vlan_id);
+	return rocker_port_fdb_learn(rocker_port, rtrans, flags, addr, vlan_id);
 }
 
 static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags)
+				 struct rocker_trans *rtrans, int flags)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_tbl_entry *found;
@@ -3684,12 +3695,12 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
 			continue;
 		if (!found->learned)
 			continue;
-		err = rocker_port_fdb_learn(rocker_port, trans_ph, flags,
+		err = rocker_port_fdb_learn(rocker_port, rtrans, flags,
 					    found->key.addr,
 					    found->key.vlan_id);
 		if (err)
 			goto err_out;
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (rtrans->ph != ROCKER_TRANS_PH_PREPARE)
 			hash_del(&found->entry);
 	}
 
@@ -3700,7 +3711,7 @@ err_out:
 }
 
 static int rocker_port_router_mac(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph, int flags,
+				  struct rocker_trans *rtrans, int flags,
 				  __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
@@ -3714,7 +3725,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		vlan_id = rocker_port->internal_vlan_id;
 
 	eth_type = htons(ETH_P_IP);
-	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
+	err = rocker_flow_tbl_term_mac(rocker_port, rtrans,
 				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3723,7 +3734,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		return err;
 
 	eth_type = htons(ETH_P_IPV6);
-	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
+	err = rocker_flow_tbl_term_mac(rocker_port, rtrans,
 				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3733,7 +3744,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fwding(struct rocker_port *rocker_port,
-			      enum switchdev_trans_ph trans_ph, int flags)
+			      struct rocker_trans *rtrans, int flags)
 {
 	bool pop_vlan;
 	u32 out_pport;
@@ -3758,7 +3769,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port,
 			continue;
 		vlan_id = htons(vid);
 		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
-		err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
+		err = rocker_group_l2_interface(rocker_port, rtrans, flags,
 						vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3772,7 +3783,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_stp_update(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph, int flags,
+				  struct rocker_trans *rtrans, int flags,
 				  u8 state)
 {
 	bool want[ROCKER_CTRL_MAX] = { 0, };
@@ -3781,7 +3792,7 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 	int err;
 	int i;
 
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE) {
+	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE) {
 		memcpy(prev_ctrls, rocker_port->ctrls, sizeof(prev_ctrls));
 		prev_state = rocker_port->stp_state;
 	}
@@ -3818,7 +3829,7 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 		if (want[i] != rocker_port->ctrls[i]) {
 			int ctrl_flags = flags |
 					 (want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
-			err = rocker_port_ctrl(rocker_port, trans_ph, ctrl_flags,
+			err = rocker_port_ctrl(rocker_port, rtrans, ctrl_flags,
 					       &rocker_ctrls[i]);
 			if (err)
 				goto err_out;
@@ -3826,14 +3837,14 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 		}
 	}
 
-	err = rocker_port_fdb_flush(rocker_port, trans_ph, flags);
+	err = rocker_port_fdb_flush(rocker_port, rtrans, flags);
 	if (err)
 		goto err_out;
 
-	err = rocker_port_fwding(rocker_port, trans_ph, flags);
+	err = rocker_port_fwding(rocker_port, rtrans, flags);
 
 err_out:
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE) {
+	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE) {
 		memcpy(rocker_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
 		rocker_port->stp_state = prev_state;
 	}
@@ -3842,26 +3853,26 @@ err_out:
 }
 
 static int rocker_port_fwd_enable(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph, int flags)
+				  struct rocker_trans *rtrans, int flags)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will enable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to FORWARDING state */
-	return rocker_port_stp_update(rocker_port, trans_ph, flags,
+	return rocker_port_stp_update(rocker_port, rtrans, flags,
 				      BR_STATE_FORWARDING);
 }
 
 static int rocker_port_fwd_disable(struct rocker_port *rocker_port,
-				   enum switchdev_trans_ph trans_ph, int flags)
+				   struct rocker_trans *rtrans, int flags)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will disable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to DISABLED state */
-	return rocker_port_stp_update(rocker_port, trans_ph, flags,
+	return rocker_port_stp_update(rocker_port, rtrans, flags,
 				      BR_STATE_DISABLED);
 }
 
@@ -3952,7 +3963,7 @@ not_found:
 }
 
 static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, __be32 dst,
+				struct rocker_trans *rtrans, __be32 dst,
 				int dst_len, const struct fib_info *fi,
 				u32 tb_id, int flags)
 {
@@ -3976,7 +3987,7 @@ static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
 	has_gw = !!nh->nh_gw;
 
 	if (has_gw && nh_on_port) {
-		err = rocker_port_ipv4_nh(rocker_port, trans_ph, flags,
+		err = rocker_port_ipv4_nh(rocker_port, rtrans, flags,
 					  nh->nh_gw, &index);
 		if (err)
 			return err;
@@ -3987,7 +3998,7 @@ static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(internal_vlan_id, 0);
 	}
 
-	err = rocker_flow_tbl_ucast4_routing(rocker_port, trans_ph, eth_type, dst,
+	err = rocker_flow_tbl_ucast4_routing(rocker_port, rtrans, eth_type, dst,
 					     dst_mask, priority, goto_tbl,
 					     group_id, flags);
 	if (err)
@@ -4026,7 +4037,7 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
-	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	err = rocker_port_fwd_enable(rocker_port, ROCKER_TRANS_PH_NONE, 0);
 	if (err)
 		goto err_fwd_enable;
 
@@ -4054,7 +4065,7 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
-	rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_fwd_disable(rocker_port, ROCKER_TRANS_PH_NONE,
 				ROCKER_OP_FLAG_NOWAIT);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
@@ -4240,7 +4251,7 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	struct port_name name = { .buf = buf, .len = len };
 	int err;
 
-	err = rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	err = rocker_cmd_exec(rocker_port, ROCKER_TRANS_PH_NONE, 0,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
 			      &name);
@@ -4265,7 +4276,7 @@ static void rocker_port_neigh_destroy(struct neighbour *n)
 	int flags = ROCKER_OP_FLAG_REMOVE | ROCKER_OP_FLAG_NOWAIT;
 	__be32 ip_addr = *(__be32 *)n->primary_key;
 
-	rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_ipv4_neigh(rocker_port, ROCKER_TRANS_PH_NONE,
 			       flags, ip_addr, n->ha);
 }
 
@@ -4322,7 +4333,7 @@ static void rocker_port_trans_abort(const struct rocker_port *rocker_port)
 }
 
 static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
-					enum switchdev_trans_ph trans_ph,
+					struct rocker_trans *rtrans,
 					unsigned long brport_flags)
 {
 	unsigned long orig_flags;
@@ -4331,9 +4342,9 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	orig_flags = rocker_port->brport_flags;
 	rocker_port->brport_flags = brport_flags;
 	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
-		err = rocker_port_set_learning(rocker_port, trans_ph);
+		err = rocker_port_set_learning(rocker_port, rtrans);
 
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE)
 		rocker_port->brport_flags = orig_flags;
 
 	return err;
@@ -4344,13 +4355,16 @@ static int rocker_port_attr_set(struct net_device *dev,
 				struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_trans rtrans = {
+		.ph = attr->trans_ph,
+	};
 	int err = 0;
 
-	switch (attr->trans_ph) {
-	case SWITCHDEV_TRANS_PREPARE:
+	switch (rtrans.ph) {
+	case ROCKER_TRANS_PH_PREPARE:
 		BUG_ON(!list_empty(&rocker_port->trans_mem));
 		break;
-	case SWITCHDEV_TRANS_ABORT:
+	case ROCKER_TRANS_PH_ABORT:
 		rocker_port_trans_abort(rocker_port);
 		return 0;
 	default:
@@ -4359,12 +4373,12 @@ static int rocker_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, attr->trans_ph,
+		err = rocker_port_stp_update(rocker_port, &rtrans,
 					     ROCKER_OP_FLAG_NOWAIT,
 					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
-		err = rocker_port_brport_flags_set(rocker_port, attr->trans_ph,
+		err = rocker_port_brport_flags_set(rocker_port, &rtrans,
 						   attr->u.brport_flags);
 		break;
 	default:
@@ -4376,33 +4390,33 @@ static int rocker_port_attr_set(struct net_device *dev,
 }
 
 static int rocker_port_vlan_add(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, u16 vid, u16 flags)
+				struct rocker_trans *rtrans, u16 vid, u16 flags)
 {
 	int err;
 
 	/* XXX deal with flags for PVID and untagged */
 
-	err = rocker_port_vlan(rocker_port, trans_ph, 0, vid);
+	err = rocker_port_vlan(rocker_port, rtrans, 0, vid);
 	if (err)
 		return err;
 
-	err = rocker_port_router_mac(rocker_port, trans_ph, 0, htons(vid));
+	err = rocker_port_router_mac(rocker_port, rtrans, 0, htons(vid));
 	if (err)
-		rocker_port_vlan(rocker_port, trans_ph,
+		rocker_port_vlan(rocker_port, rtrans,
 				 ROCKER_OP_FLAG_REMOVE, vid);
 
 	return err;
 }
 
 static int rocker_port_vlans_add(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph,
+				 struct rocker_trans *rtrans,
 				 const struct switchdev_obj_vlan *vlan)
 {
 	u16 vid;
 	int err;
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = rocker_port_vlan_add(rocker_port, trans_ph,
+		err = rocker_port_vlan_add(rocker_port, rtrans,
 					   vid, vlan->flags);
 		if (err)
 			return err;
@@ -4412,7 +4426,7 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_add(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph,
+			       struct rocker_trans *rtrans,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
@@ -4421,7 +4435,7 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, trans_ph, fdb->addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, rtrans, fdb->addr, vlan_id, flags);
 }
 
 static int rocker_port_obj_add(struct net_device *dev,
@@ -4429,14 +4443,17 @@ static int rocker_port_obj_add(struct net_device *dev,
 			       struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_trans rtrans = {
+		.ph = obj->trans_ph,
+	};
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (obj->trans_ph) {
-	case SWITCHDEV_TRANS_PREPARE:
+	switch (rtrans.ph) {
+	case ROCKER_TRANS_PH_PREPARE:
 		BUG_ON(!list_empty(&rocker_port->trans_mem));
 		break;
-	case SWITCHDEV_TRANS_ABORT:
+	case ROCKER_TRANS_PH_ABORT:
 		rocker_port_trans_abort(rocker_port);
 		return 0;
 	default:
@@ -4445,17 +4462,17 @@ static int rocker_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, obj->trans_ph,
+		err = rocker_port_vlans_add(rocker_port, &rtrans,
 					    &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
-		err = rocker_port_fib_ipv4(rocker_port, obj->trans_ph,
+		err = rocker_port_fib_ipv4(rocker_port, &rtrans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, obj->trans_ph, &obj->u.fdb);
+		err = rocker_port_fdb_add(rocker_port, &rtrans, &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4470,12 +4487,12 @@ static int rocker_port_vlan_del(struct rocker_port *rocker_port,
 {
 	int err;
 
-	err = rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
+	err = rocker_port_router_mac(rocker_port, ROCKER_TRANS_PH_NONE,
 				     ROCKER_OP_FLAG_REMOVE, htons(vid));
 	if (err)
 		return err;
 
-	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_port_vlan(rocker_port, ROCKER_TRANS_PH_NONE,
 				ROCKER_OP_FLAG_REMOVE, vid);
 }
 
@@ -4495,7 +4512,7 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_del(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph,
+			       struct rocker_trans *rtrans,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
@@ -4504,13 +4521,16 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, trans_ph, fdb->addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, rtrans, fdb->addr, vlan_id, flags);
 }
 
 static int rocker_port_obj_del(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_trans rtrans = {
+		.ph = ROCKER_TRANS_PH_NONE,
+	};
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
@@ -4520,13 +4540,14 @@ static int rocker_port_obj_del(struct net_device *dev,
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
-		err = rocker_port_fib_ipv4(rocker_port, SWITCHDEV_TRANS_NONE,
+		err = rocker_port_fib_ipv4(rocker_port, &rtrans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_del(rocker_port, obj->trans_ph, &obj->u.fdb);
+		err = rocker_port_fdb_del(rocker_port, &rtrans,
+					  &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4740,7 +4761,7 @@ rocker_cmd_get_port_stats_ethtool_proc(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
 					     void *priv)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, ROCKER_TRANS_PH_NONE, 0,
 			       rocker_cmd_get_port_stats_prep, NULL,
 			       rocker_cmd_get_port_stats_ethtool_proc,
 			       priv);
@@ -4932,7 +4953,7 @@ static void rocker_remove_ports(const struct rocker *rocker)
 		rocker_port = rocker->ports[i];
 		if (!rocker_port)
 			continue;
-		rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
+		rocker_port_ig_tbl(rocker_port, ROCKER_TRANS_PH_NONE,
 				   ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
 		free_netdev(rocker_port->dev);
@@ -4994,9 +5015,9 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
 
-	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
+	rocker_port_set_learning(rocker_port, ROCKER_TRANS_PH_NONE);
 
-	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	err = rocker_port_ig_tbl(rocker_port, ROCKER_TRANS_PH_NONE, 0);
 	if (err) {
 		netdev_err(rocker_port->dev, "install ig port table failed\n");
 		goto err_port_ig_tbl;
@@ -5005,7 +5026,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
 
-	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
+	err = rocker_port_vlan_add(rocker_port, ROCKER_TRANS_PH_NONE,
 				   untagged_vid, 0);
 	if (err) {
 		netdev_err(rocker_port->dev, "install untagged VLAN failed\n");
@@ -5015,7 +5036,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	return 0;
 
 err_untagged_vlan:
-	rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_ig_tbl(rocker_port, ROCKER_TRANS_PH_NONE,
 			   ROCKER_OP_FLAG_REMOVE);
 err_port_ig_tbl:
 	rocker->ports[port_number] = NULL;
@@ -5277,7 +5298,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 	rocker_port->bridge_dev = bridge;
 	switchdev_port_fwd_mark_set(rocker_port->dev, bridge, true);
 
-	return rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_port_vlan_add(rocker_port, ROCKER_TRANS_PH_NONE,
 				    untagged_vid, 0);
 }
 
@@ -5300,14 +5321,14 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 				    false);
 	rocker_port->bridge_dev = NULL;
 
-	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
+	err = rocker_port_vlan_add(rocker_port, ROCKER_TRANS_PH_NONE,
 				   untagged_vid, 0);
 	if (err)
 		return err;
 
 	if (rocker_port->dev->flags & IFF_UP)
 		err = rocker_port_fwd_enable(rocker_port,
-					     SWITCHDEV_TRANS_NONE, 0);
+					     ROCKER_TRANS_PH_NONE, 0);
 
 	return err;
 }
@@ -5320,10 +5341,10 @@ static int rocker_port_ovs_changed(struct rocker_port *rocker_port,
 
 	rocker_port->bridge_dev = master;
 
-	err = rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	err = rocker_port_fwd_disable(rocker_port, ROCKER_TRANS_PH_NONE, 0);
 	if (err)
 		return err;
-	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	err = rocker_port_fwd_enable(rocker_port, ROCKER_TRANS_PH_NONE, 0);
 
 	return err;
 }
@@ -5401,7 +5422,7 @@ static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
 		    ROCKER_OP_FLAG_NOWAIT;
 	__be32 ip_addr = *(__be32 *)n->primary_key;
 
-	return rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_port_ipv4_neigh(rocker_port, ROCKER_TRANS_PH_NONE,
 				      flags, ip_addr, n->ha);
 }
 
-- 
1.9.3
