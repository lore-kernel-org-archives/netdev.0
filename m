From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/10] rocker: push struct switchdev_trans down through rocker code
Date: Tue, 22 Sep 2015 15:53:47 +0200
Message-ID: <1442930031-4732-6-git-send-email-jiri@resnulli.us>
References: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33021 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933477AbbIVNyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 09:54:01 -0400
Received: by wiclk2 with SMTP id lk2so194184569wic.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 06:53:59 -0700 (PDT)
In-Reply-To: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

There will be needed to have switchdev_trans available down in the call
chain, so propagate it instead of trans phase enum. This enum will be
removed anyway. Also, use prepare/commit phase check helpers to get
information about current phase of transaction.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 460 +++++++++++++++++------------------
 1 file changed, 224 insertions(+), 236 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 45e500f..10b3bfb 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -340,7 +340,7 @@ static bool rocker_port_is_ovsed(const struct rocker_port *rocker_port)
 #define ROCKER_OP_FLAG_REFRESH		BIT(3)
 
 static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
-				     enum switchdev_trans_ph trans_ph, int flags,
+				     struct switchdev_trans *trans, int flags,
 				     size_t size)
 {
 	struct list_head *elem = NULL;
@@ -356,45 +356,39 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 	 * memory used in the commit phase.
 	 */
 
-	switch (trans_ph) {
-	case SWITCHDEV_TRANS_PREPARE:
+	if (!trans) {
+		elem = kzalloc(size + sizeof(*elem), gfp_flags);
+		if (elem)
+			INIT_LIST_HEAD(elem);
+	} else if (switchdev_trans_ph_prepare(trans)) {
 		elem = kzalloc(size + sizeof(*elem), gfp_flags);
 		if (!elem)
 			return NULL;
 		list_add_tail(elem, &rocker_port->trans_mem);
-		break;
-	case SWITCHDEV_TRANS_COMMIT:
+	} else {
 		BUG_ON(list_empty(&rocker_port->trans_mem));
 		elem = rocker_port->trans_mem.next;
 		list_del_init(elem);
-		break;
-	case SWITCHDEV_TRANS_NONE:
-		elem = kzalloc(size + sizeof(*elem), gfp_flags);
-		if (elem)
-			INIT_LIST_HEAD(elem);
-		break;
-	default:
-		break;
 	}
 
 	return elem ? elem + 1 : NULL;
 }
 
 static void *rocker_port_kzalloc(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct switchdev_trans *trans, int flags,
 				 size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans_ph, flags, size);
+	return __rocker_port_mem_alloc(rocker_port, trans, flags, size);
 }
 
 static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct switchdev_trans *trans, int flags,
 				 size_t n, size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans_ph, flags, n * size);
+	return __rocker_port_mem_alloc(rocker_port, trans, flags, n * size);
 }
 
-static void rocker_port_kfree(enum switchdev_trans_ph trans_ph, const void *mem)
+static void rocker_port_kfree(struct switchdev_trans *trans, const void *mem)
 {
 	struct list_head *elem;
 
@@ -403,7 +397,7 @@ static void rocker_port_kfree(enum switchdev_trans_ph trans_ph, const void *mem)
 	 * commit phase.
 	 */
 
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (switchdev_trans_ph_prepare(trans))
 		return;
 
 	elem = (struct list_head *)mem - 1;
@@ -430,22 +424,22 @@ static void rocker_wait_init(struct rocker_wait *wait)
 }
 
 static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
-					      enum switchdev_trans_ph trans_ph,
+					      struct switchdev_trans *trans,
 					      int flags)
 {
 	struct rocker_wait *wait;
 
-	wait = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*wait));
+	wait = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*wait));
 	if (!wait)
 		return NULL;
 	rocker_wait_init(wait);
 	return wait;
 }
 
-static void rocker_wait_destroy(enum switchdev_trans_ph trans_ph,
+static void rocker_wait_destroy(struct switchdev_trans *trans,
 				struct rocker_wait *wait)
 {
-	rocker_port_kfree(trans_ph, wait);
+	rocker_port_kfree(trans, wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -1408,7 +1402,7 @@ static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
 		wait = rocker_desc_cookie_ptr_get(desc_info);
 		if (wait->nowait) {
 			rocker_desc_gen_clear(desc_info);
-			rocker_wait_destroy(SWITCHDEV_TRANS_NONE, wait);
+			rocker_wait_destroy(NULL, wait);
 		} else {
 			rocker_wait_wake_up(wait);
 		}
@@ -1463,7 +1457,7 @@ static int rocker_event_link_change(const struct rocker *rocker,
 }
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
-			   enum switchdev_trans_ph trans_ph,
+			   struct switchdev_trans *trans,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags);
 
@@ -1496,8 +1490,7 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 	    rocker_port->stp_state != BR_STATE_FORWARDING)
 		return 0;
 
-	return rocker_port_fdb(rocker_port, SWITCHDEV_TRANS_NONE,
-			       addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, NULL, addr, vlan_id, flags);
 }
 
 static int rocker_event_process(const struct rocker *rocker,
@@ -1582,7 +1575,7 @@ typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
 				    void *priv);
 
 static int rocker_cmd_exec(struct rocker_port *rocker_port,
-			   enum switchdev_trans_ph trans_ph, int flags,
+			   struct switchdev_trans *trans, int flags,
 			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
 			   rocker_cmd_proc_cb_t process, void *process_priv)
 {
@@ -1593,7 +1586,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int err;
 
-	wait = rocker_wait_create(rocker_port, trans_ph, flags);
+	wait = rocker_wait_create(rocker_port, trans, flags);
 	if (!wait)
 		return -ENOMEM;
 	wait->nowait = nowait;
@@ -1615,7 +1608,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 
 	rocker_desc_cookie_ptr_set(desc_info, wait);
 
-	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+	if (!switchdev_trans_ph_prepare(trans))
 		rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
 
 	spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
@@ -1623,7 +1616,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 	if (nowait)
 		return 0;
 
-	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+	if (!switchdev_trans_ph_prepare(trans))
 		if (!rocker_wait_event_timeout(wait, HZ / 10))
 			return -EIO;
 
@@ -1636,7 +1629,7 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 
 	rocker_desc_gen_clear(desc_info);
 out:
-	rocker_wait_destroy(trans_ph, wait);
+	rocker_wait_destroy(trans, wait);
 	return err;
 }
 
@@ -1875,7 +1868,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, NULL, 0,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_ethtool_proc,
 			       ecmd);
@@ -1884,7 +1877,7 @@ static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, NULL, 0,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_macaddr_proc,
 			       macaddr);
@@ -1893,7 +1886,7 @@ static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, NULL, 0,
 			       rocker_cmd_set_port_settings_ethtool_prep,
 			       ecmd, NULL, NULL);
 }
@@ -1901,7 +1894,7 @@ static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, NULL, 0,
 			       rocker_cmd_set_port_settings_macaddr_prep,
 			       macaddr, NULL, NULL);
 }
@@ -1909,15 +1902,15 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
 					    int mtu)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, NULL, 0,
 			       rocker_cmd_set_port_settings_mtu_prep,
 			       &mtu, NULL, NULL);
 }
 
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
-				    enum switchdev_trans_ph trans_ph)
+				    struct switchdev_trans *trans)
 {
-	return rocker_cmd_exec(rocker_port, trans_ph, 0,
+	return rocker_cmd_exec(rocker_port, trans, 0,
 			       rocker_cmd_set_port_learning_prep,
 			       NULL, NULL, NULL);
 }
@@ -2433,7 +2426,7 @@ rocker_flow_tbl_find(const struct rocker *rocker,
 }
 
 static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct switchdev_trans *trans, int flags,
 			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2449,9 +2442,9 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 
 	if (found) {
 		match->cookie = found->cookie;
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (!switchdev_trans_ph_prepare(trans))
 			hash_del(&found->entry);
-		rocker_port_kfree(trans_ph, found);
+		rocker_port_kfree(trans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -2460,17 +2453,17 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
 	}
 
-	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+	if (!switchdev_trans_ph_prepare(trans))
 		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans_ph, flags,
+	return rocker_cmd_exec(rocker_port, trans, flags,
 			       rocker_cmd_flow_tbl_add, found, NULL, NULL);
 }
 
 static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct switchdev_trans *trans, int flags,
 			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2486,43 +2479,43 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_flow_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (!switchdev_trans_ph_prepare(trans))
 			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	rocker_port_kfree(trans_ph, match);
+	rocker_port_kfree(trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans_ph, flags,
+		err = rocker_cmd_exec(rocker_port, trans, flags,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL);
-		rocker_port_kfree(trans_ph, found);
+		rocker_port_kfree(trans, found);
 	}
 
 	return err;
 }
 
 static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
-			      enum switchdev_trans_ph trans_ph, int flags,
+			      struct switchdev_trans *trans, int flags,
 			      struct rocker_flow_tbl_entry *entry)
 {
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_flow_tbl_del(rocker_port, trans_ph, flags, entry);
+		return rocker_flow_tbl_del(rocker_port, trans, flags, entry);
 	else
-		return rocker_flow_tbl_add(rocker_port, trans_ph, flags, entry);
+		return rocker_flow_tbl_add(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
-				   enum switchdev_trans_ph trans_ph, int flags,
+				   struct switchdev_trans *trans, int flags,
 				   u32 in_pport, u32 in_pport_mask,
 				   enum rocker_of_dpa_table_id goto_tbl)
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2532,11 +2525,11 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 	entry->key.ig_port.in_pport_mask = in_pport_mask;
 	entry->key.ig_port.goto_tbl = goto_tbl;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, int flags,
+				struct switchdev_trans *trans, int flags,
 				u32 in_pport, __be16 vlan_id,
 				__be16 vlan_id_mask,
 				enum rocker_of_dpa_table_id goto_tbl,
@@ -2544,7 +2537,7 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2558,11 +2551,11 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 	entry->key.vlan.untagged = untagged;
 	entry->key.vlan.new_vlan_id = new_vlan_id;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
-				    enum switchdev_trans_ph trans_ph,
+				    struct switchdev_trans *trans,
 				    u32 in_pport, u32 in_pport_mask,
 				    __be16 eth_type, const u8 *eth_dst,
 				    const u8 *eth_dst_mask, __be16 vlan_id,
@@ -2571,7 +2564,7 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2595,11 +2588,11 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
 	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph, int flags,
+				  struct switchdev_trans *trans, int flags,
 				  const u8 *eth_dst, const u8 *eth_dst_mask,
 				  __be16 vlan_id, u32 tunnel_id,
 				  enum rocker_of_dpa_table_id goto_tbl,
@@ -2611,7 +2604,7 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2649,11 +2642,11 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	entry->key.bridge.group_id = group_id;
 	entry->key.bridge.copy_to_cpu = copy_to_cpu;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
-					  enum switchdev_trans_ph trans_ph,
+					  struct switchdev_trans *trans,
 					  __be16 eth_type, __be32 dst,
 					  __be32 dst_mask, u32 priority,
 					  enum rocker_of_dpa_table_id goto_tbl,
@@ -2661,7 +2654,7 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2675,11 +2668,11 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 	entry->key_len = offsetof(struct rocker_flow_tbl_key,
 				  ucast_routing.group_id);
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct switchdev_trans *trans, int flags,
 			       u32 in_pport, u32 in_pport_mask,
 			       const u8 *eth_src, const u8 *eth_src_mask,
 			       const u8 *eth_dst, const u8 *eth_dst_mask,
@@ -2691,7 +2684,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	u32 priority;
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2726,7 +2719,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	entry->key.acl.ip_tos_mask = ip_tos_mask;
 	entry->key.acl.group_id = group_id;
 
-	return rocker_flow_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static struct rocker_group_tbl_entry *
@@ -2744,22 +2737,22 @@ rocker_group_tbl_find(const struct rocker *rocker,
 	return NULL;
 }
 
-static void rocker_group_tbl_entry_free(enum switchdev_trans_ph trans_ph,
+static void rocker_group_tbl_entry_free(struct switchdev_trans *trans,
 					struct rocker_group_tbl_entry *entry)
 {
 	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		rocker_port_kfree(trans_ph, entry->group_ids);
+		rocker_port_kfree(trans, entry->group_ids);
 		break;
 	default:
 		break;
 	}
-	rocker_port_kfree(trans_ph, entry);
+	rocker_port_kfree(trans, entry);
 }
 
 static int rocker_group_tbl_add(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, int flags,
+				struct switchdev_trans *trans, int flags,
 				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2771,9 +2764,9 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (!switchdev_trans_ph_prepare(trans))
 			hash_del(&found->entry);
-		rocker_group_tbl_entry_free(trans_ph, found);
+		rocker_group_tbl_entry_free(trans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
 	} else {
@@ -2781,17 +2774,17 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
 	}
 
-	if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+	if (!switchdev_trans_ph_prepare(trans))
 		hash_add(rocker->group_tbl, &found->entry, found->group_id);
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans_ph, flags,
+	return rocker_cmd_exec(rocker_port, trans, flags,
 			       rocker_cmd_group_tbl_add, found, NULL, NULL);
 }
 
 static int rocker_group_tbl_del(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, int flags,
+				struct switchdev_trans *trans, int flags,
 				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2804,95 +2797,95 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 	found = rocker_group_tbl_find(rocker, match);
 
 	if (found) {
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (!switchdev_trans_ph_prepare(trans))
 			hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
-	rocker_group_tbl_entry_free(trans_ph, match);
+	rocker_group_tbl_entry_free(trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans_ph, flags,
+		err = rocker_cmd_exec(rocker_port, trans, flags,
 				      rocker_cmd_group_tbl_del,
 				      found, NULL, NULL);
-		rocker_group_tbl_entry_free(trans_ph, found);
+		rocker_group_tbl_entry_free(trans, found);
 	}
 
 	return err;
 }
 
 static int rocker_group_tbl_do(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct switchdev_trans *trans, int flags,
 			       struct rocker_group_tbl_entry *entry)
 {
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_group_tbl_del(rocker_port, trans_ph, flags, entry);
+		return rocker_group_tbl_del(rocker_port, trans, flags, entry);
 	else
-		return rocker_group_tbl_add(rocker_port, trans_ph, flags, entry);
+		return rocker_group_tbl_add(rocker_port, trans, flags, entry);
 }
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
-				     enum switchdev_trans_ph trans_ph, int flags,
+				     struct switchdev_trans *trans, int flags,
 				     __be16 vlan_id, u32 out_pport,
 				     int pop_vlan)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	entry->l2_interface.pop_vlan = pop_vlan;
 
-	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
-				   enum switchdev_trans_ph trans_ph,
+				   struct switchdev_trans *trans,
 				   int flags, u8 group_count,
 				   const u32 *group_ids, u32 group_id)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = rocker_port_kcalloc(rocker_port, trans_ph, flags,
+	entry->group_ids = rocker_port_kcalloc(rocker_port, trans, flags,
 					       group_count, sizeof(u32));
 	if (!entry->group_ids) {
-		rocker_port_kfree(trans_ph, entry);
+		rocker_port_kfree(trans, entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
 
-	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static int rocker_group_l2_flood(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct switchdev_trans *trans, int flags,
 				 __be16 vlan_id, u8 group_count,
 				 const u32 *group_ids, u32 group_id)
 {
-	return rocker_group_l2_fan_out(rocker_port, trans_ph, flags,
+	return rocker_group_l2_fan_out(rocker_port, trans, flags,
 				       group_count, group_ids,
 				       group_id);
 }
 
 static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
-				   enum switchdev_trans_ph trans_ph, int flags,
+				   struct switchdev_trans *trans, int flags,
 				   u32 index, const u8 *src_mac, const u8 *dst_mac,
 				   __be16 vlan_id, bool ttl_check, u32 pport)
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2905,7 +2898,7 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 	entry->l3_unicast.ttl_check = ttl_check;
 	entry->l3_unicast.group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, pport);
 
-	return rocker_group_tbl_do(rocker_port, trans_ph, flags, entry);
+	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
 }
 
 static struct rocker_neigh_tbl_entry *
@@ -2922,43 +2915,43 @@ rocker_neigh_tbl_find(const struct rocker *rocker, __be32 ip_addr)
 }
 
 static void _rocker_neigh_add(struct rocker *rocker,
-			      enum switchdev_trans_ph trans_ph,
+			      struct switchdev_trans *trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
-	if (trans_ph != SWITCHDEV_TRANS_COMMIT)
+	if (!switchdev_trans_ph_commit(trans))
 		entry->index = rocker->neigh_tbl_next_index++;
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (switchdev_trans_ph_prepare(trans))
 		return;
 	entry->ref_count++;
 	hash_add(rocker->neigh_tbl, &entry->entry,
 		 be32_to_cpu(entry->ip_addr));
 }
 
-static void _rocker_neigh_del(enum switchdev_trans_ph trans_ph,
+static void _rocker_neigh_del(struct switchdev_trans *trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (switchdev_trans_ph_prepare(trans))
 		return;
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
-		rocker_port_kfree(trans_ph, entry);
+		rocker_port_kfree(trans, entry);
 	}
 }
 
 static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
-				 enum switchdev_trans_ph trans_ph,
+				 struct switchdev_trans *trans,
 				 const u8 *eth_dst, bool ttl_check)
 {
 	if (eth_dst) {
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = ttl_check;
-	} else if (trans_ph != SWITCHDEV_TRANS_PREPARE) {
+	} else if (!switchdev_trans_ph_prepare(trans)) {
 		entry->ref_count++;
 	}
 }
 
 static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph,
+				  struct switchdev_trans *trans,
 				  int flags, __be32 ip_addr, const u8 *eth_dst)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -2975,7 +2968,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	bool removing;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2992,12 +2985,12 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 		entry->dev = rocker_port->dev;
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = true;
-		_rocker_neigh_add(rocker, trans_ph, entry);
+		_rocker_neigh_add(rocker, trans, entry);
 	} else if (removing) {
 		memcpy(entry, found, sizeof(*entry));
-		_rocker_neigh_del(trans_ph, found);
+		_rocker_neigh_del(trans, found);
 	} else if (updating) {
-		_rocker_neigh_update(found, trans_ph, eth_dst, true);
+		_rocker_neigh_update(found, trans, eth_dst, true);
 		memcpy(entry, found, sizeof(*entry));
 	} else {
 		err = -ENOENT;
@@ -3014,7 +3007,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	 * other routes' nexthops.
 	 */
 
-	err = rocker_group_l3_unicast(rocker_port, trans_ph, flags,
+	err = rocker_group_l3_unicast(rocker_port, trans, flags,
 				      entry->index,
 				      rocker_port->dev->dev_addr,
 				      entry->eth_dst,
@@ -3030,7 +3023,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 	if (adding || removing) {
 		group_id = ROCKER_GROUP_L3_UNICAST(entry->index);
-		err = rocker_flow_tbl_ucast4_routing(rocker_port, trans_ph,
+		err = rocker_flow_tbl_ucast4_routing(rocker_port, trans,
 						     eth_type, ip_addr,
 						     inet_make_mask(32),
 						     priority, goto_tbl,
@@ -3044,13 +3037,14 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 err_out:
 	if (!adding)
-		rocker_port_kfree(trans_ph, entry);
+		rocker_port_kfree(trans, entry);
 
 	return err;
 }
 
 static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
-				    enum switchdev_trans_ph trans_ph, __be32 ip_addr)
+				    struct switchdev_trans *trans,
+				    __be32 ip_addr)
 {
 	struct net_device *dev = rocker_port->dev;
 	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
@@ -3068,7 +3062,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 	 */
 
 	if (n->nud_state & NUD_VALID)
-		err = rocker_port_ipv4_neigh(rocker_port, trans_ph, 0,
+		err = rocker_port_ipv4_neigh(rocker_port, trans, 0,
 					     ip_addr, n->ha);
 	else
 		neigh_event_send(n, NULL);
@@ -3078,7 +3072,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph, int flags,
+			       struct switchdev_trans *trans, int flags,
 			       __be32 ip_addr, u32 *index)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3091,7 +3085,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	bool resolved = true;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -3108,13 +3102,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	if (adding) {
 		entry->ip_addr = ip_addr;
 		entry->dev = rocker_port->dev;
-		_rocker_neigh_add(rocker, trans_ph, entry);
+		_rocker_neigh_add(rocker, trans, entry);
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
-		_rocker_neigh_del(trans_ph, found);
+		_rocker_neigh_del(trans, found);
 	} else if (updating) {
-		_rocker_neigh_update(found, trans_ph, NULL, false);
+		_rocker_neigh_update(found, trans, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
 	} else {
 		err = -ENOENT;
@@ -3123,7 +3117,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		rocker_port_kfree(trans_ph, entry);
+		rocker_port_kfree(trans, entry);
 
 	if (err)
 		return err;
@@ -3131,13 +3125,13 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	/* Resolved means neigh ip_addr is resolved to neigh mac. */
 
 	if (!resolved)
-		err = rocker_port_ipv4_resolve(rocker_port, trans_ph, ip_addr);
+		err = rocker_port_ipv4_resolve(rocker_port, trans, ip_addr);
 
 	return err;
 }
 
 static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
-					enum switchdev_trans_ph trans_ph,
+					struct switchdev_trans *trans,
 					int flags, __be16 vlan_id)
 {
 	struct rocker_port *p;
@@ -3148,7 +3142,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	int err = 0;
 	int i;
 
-	group_ids = rocker_port_kcalloc(rocker_port, trans_ph, flags,
+	group_ids = rocker_port_kcalloc(rocker_port, trans, flags,
 					rocker->port_count, sizeof(u32));
 	if (!group_ids)
 		return -ENOMEM;
@@ -3174,19 +3168,19 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	if (group_count == 0)
 		goto no_ports_in_vlan;
 
-	err = rocker_group_l2_flood(rocker_port, trans_ph, flags, vlan_id,
+	err = rocker_group_l2_flood(rocker_port, trans, flags, vlan_id,
 				    group_count, group_ids, group_id);
 	if (err)
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	rocker_port_kfree(trans_ph, group_ids);
+	rocker_port_kfree(trans, group_ids);
 	return err;
 }
 
 static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
-				      enum switchdev_trans_ph trans_ph, int flags,
+				      struct switchdev_trans *trans, int flags,
 				      __be16 vlan_id, bool pop_vlan)
 {
 	const struct rocker *rocker = rocker_port->rocker;
@@ -3204,7 +3198,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 	if (rocker_port->stp_state == BR_STATE_LEARNING ||
 	    rocker_port->stp_state == BR_STATE_FORWARDING) {
 		out_pport = rocker_port->pport;
-		err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
+		err = rocker_group_l2_interface(rocker_port, trans, flags,
 						vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3229,7 +3223,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 		return 0;
 
 	out_pport = 0;
-	err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
+	err = rocker_group_l2_interface(rocker_port, trans, flags,
 					vlan_id, out_pport, pop_vlan);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3292,7 +3286,7 @@ static struct rocker_ctrl {
 };
 
 static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
-				     enum switchdev_trans_ph trans_ph, int flags,
+				     struct switchdev_trans *trans, int flags,
 				     const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport = rocker_port->pport;
@@ -3308,7 +3302,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	int err;
 
-	err = rocker_flow_tbl_acl(rocker_port, trans_ph, flags,
+	err = rocker_flow_tbl_acl(rocker_port, trans, flags,
 				  in_pport, in_pport_mask,
 				  eth_src, eth_src_mask,
 				  ctrl->eth_dst, ctrl->eth_dst_mask,
@@ -3325,7 +3319,8 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
-					enum switchdev_trans_ph trans_ph, int flags,
+					struct switchdev_trans *trans,
+					int flags,
 					const struct rocker_ctrl *ctrl,
 					__be16 vlan_id)
 {
@@ -3338,7 +3333,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	err = rocker_flow_tbl_bridge(rocker_port, trans_ph, flags,
+	err = rocker_flow_tbl_bridge(rocker_port, trans, flags,
 				     ctrl->eth_dst, ctrl->eth_dst_mask,
 				     vlan_id, tunnel_id,
 				     goto_tbl, group_id, ctrl->copy_to_cpu);
@@ -3350,7 +3345,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
-				      enum switchdev_trans_ph trans_ph, int flags,
+				      struct switchdev_trans *trans, int flags,
 				      const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
@@ -3360,7 +3355,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 	if (ntohs(vlan_id) == 0)
 		vlan_id = rocker_port->internal_vlan_id;
 
-	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans,
 				       rocker_port->pport, in_pport_mask,
 				       ctrl->eth_type, ctrl->eth_dst,
 				       ctrl->eth_dst_mask, vlan_id,
@@ -3374,25 +3369,25 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct switchdev_trans *trans, int flags,
 				 const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	if (ctrl->acl)
-		return rocker_port_ctrl_vlan_acl(rocker_port, trans_ph, flags,
+		return rocker_port_ctrl_vlan_acl(rocker_port, trans, flags,
 						 ctrl, vlan_id);
 	if (ctrl->bridge)
-		return rocker_port_ctrl_vlan_bridge(rocker_port, trans_ph, flags,
+		return rocker_port_ctrl_vlan_bridge(rocker_port, trans, flags,
 						    ctrl, vlan_id);
 
 	if (ctrl->term)
-		return rocker_port_ctrl_vlan_term(rocker_port, trans_ph, flags,
+		return rocker_port_ctrl_vlan_term(rocker_port, trans, flags,
 						  ctrl, vlan_id);
 
 	return -EOPNOTSUPP;
 }
 
 static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
-				     enum switchdev_trans_ph trans_ph, int flags,
+				     struct switchdev_trans *trans, int flags,
 				     __be16 vlan_id)
 {
 	int err = 0;
@@ -3400,7 +3395,7 @@ static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
 
 	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
 		if (rocker_port->ctrls[i]) {
-			err = rocker_port_ctrl_vlan(rocker_port, trans_ph, flags,
+			err = rocker_port_ctrl_vlan(rocker_port, trans, flags,
 						    &rocker_ctrls[i], vlan_id);
 			if (err)
 				return err;
@@ -3411,7 +3406,7 @@ static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_ctrl(struct rocker_port *rocker_port,
-			    enum switchdev_trans_ph trans_ph, int flags,
+			    struct switchdev_trans *trans, int flags,
 			    const struct rocker_ctrl *ctrl)
 {
 	u16 vid;
@@ -3420,7 +3415,7 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port,
 	for (vid = 1; vid < VLAN_N_VID; vid++) {
 		if (!test_bit(vid, rocker_port->vlan_bitmap))
 			continue;
-		err = rocker_port_ctrl_vlan(rocker_port, trans_ph, flags,
+		err = rocker_port_ctrl_vlan(rocker_port, trans, flags,
 					    ctrl, htons(vid));
 		if (err)
 			break;
@@ -3430,7 +3425,7 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlan(struct rocker_port *rocker_port,
-			    enum switchdev_trans_ph trans_ph, int flags, u16 vid)
+			    struct switchdev_trans *trans, int flags, u16 vid)
 {
 	enum rocker_of_dpa_table_id goto_tbl =
 		ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
@@ -3454,7 +3449,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 	change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
 
 	if (adding) {
-		err = rocker_port_ctrl_vlan_add(rocker_port, trans_ph, flags,
+		err = rocker_port_ctrl_vlan_add(rocker_port, trans, flags,
 						internal_vlan_id);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3463,7 +3458,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		}
 	}
 
-	err = rocker_port_vlan_l2_groups(rocker_port, trans_ph, flags,
+	err = rocker_port_vlan_l2_groups(rocker_port, trans, flags,
 					 internal_vlan_id, untagged);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3471,7 +3466,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		goto err_out;
 	}
 
-	err = rocker_port_vlan_flood_group(rocker_port, trans_ph, flags,
+	err = rocker_port_vlan_flood_group(rocker_port, trans, flags,
 					   internal_vlan_id);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -3479,7 +3474,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 		goto err_out;
 	}
 
-	err = rocker_flow_tbl_vlan(rocker_port, trans_ph, flags,
+	err = rocker_flow_tbl_vlan(rocker_port, trans, flags,
 				   in_pport, vlan_id, vlan_id_mask,
 				   goto_tbl, untagged, internal_vlan_id);
 	if (err)
@@ -3487,14 +3482,14 @@ static int rocker_port_vlan(struct rocker_port *rocker_port,
 			   "Error (%d) port VLAN table\n", err);
 
 err_out:
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (switchdev_trans_ph_prepare(trans))
 		change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
 
 	return err;
 }
 
 static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
-			      enum switchdev_trans_ph trans_ph, int flags)
+			      struct switchdev_trans *trans, int flags)
 {
 	enum rocker_of_dpa_table_id goto_tbl;
 	u32 in_pport;
@@ -3509,7 +3504,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
 	in_pport_mask = 0xffff0000;
 	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
 
-	err = rocker_flow_tbl_ig_port(rocker_port, trans_ph, flags,
+	err = rocker_flow_tbl_ig_port(rocker_port, trans, flags,
 				      in_pport, in_pport_mask,
 				      goto_tbl);
 	if (err)
@@ -3522,7 +3517,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
 struct rocker_fdb_learn_work {
 	struct work_struct work;
 	struct rocker_port *rocker_port;
-	enum switchdev_trans_ph trans_ph;
+	struct switchdev_trans *trans;
 	int flags;
 	u8 addr[ETH_ALEN];
 	u16 vid;
@@ -3546,11 +3541,11 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
 					 lw->rocker_port->dev, &info.info);
 
-	rocker_port_kfree(lw->trans_ph, work);
+	rocker_port_kfree(lw->trans, work);
 }
 
 static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags,
+				 struct switchdev_trans *trans, int flags,
 				 const u8 *addr, __be16 vlan_id)
 {
 	struct rocker_fdb_learn_work *lw;
@@ -3567,7 +3562,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 
 	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
-		err = rocker_flow_tbl_bridge(rocker_port, trans_ph, flags, addr,
+		err = rocker_flow_tbl_bridge(rocker_port, trans, flags, addr,
 					     NULL, vlan_id, tunnel_id, goto_tbl,
 					     group_id, copy_to_cpu);
 		if (err)
@@ -3580,20 +3575,20 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	lw = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*lw));
+	lw = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*lw));
 	if (!lw)
 		return -ENOMEM;
 
 	INIT_WORK(&lw->work, rocker_port_fdb_learn_work);
 
 	lw->rocker_port = rocker_port;
-	lw->trans_ph = trans_ph;
+	lw->trans = trans;
 	lw->flags = flags;
 	ether_addr_copy(lw->addr, addr);
 	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
 
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
-		rocker_port_kfree(trans_ph, lw);
+	if (switchdev_trans_ph_prepare(trans))
+		rocker_port_kfree(trans, lw);
 	else
 		schedule_work(&lw->work);
 
@@ -3614,7 +3609,7 @@ rocker_fdb_tbl_find(const struct rocker *rocker,
 }
 
 static int rocker_port_fdb(struct rocker_port *rocker_port,
-			   enum switchdev_trans_ph trans_ph,
+			   struct switchdev_trans *trans,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags)
 {
@@ -3624,7 +3619,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = rocker_port_kzalloc(rocker_port, trans_ph, flags, sizeof(*fdb));
+	fdb = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*fdb));
 	if (!fdb)
 		return -ENOMEM;
 
@@ -3639,11 +3634,11 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	found = rocker_fdb_tbl_find(rocker, fdb);
 
 	if (removing && found) {
-		rocker_port_kfree(trans_ph, fdb);
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		rocker_port_kfree(trans, fdb);
+		if (!switchdev_trans_ph_prepare(trans))
 			hash_del(&found->entry);
 	} else if (!removing && !found) {
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (!switchdev_trans_ph_prepare(trans))
 			hash_add(rocker->fdb_tbl, &fdb->entry, fdb->key_crc32);
 	}
 
@@ -3651,18 +3646,18 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		rocker_port_kfree(trans_ph, fdb);
+		rocker_port_kfree(trans, fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
 		flags |= ROCKER_OP_FLAG_REFRESH;
 	}
 
-	return rocker_port_fdb_learn(rocker_port, trans_ph, flags, addr, vlan_id);
+	return rocker_port_fdb_learn(rocker_port, trans, flags, addr, vlan_id);
 }
 
 static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph, int flags)
+				 struct switchdev_trans *trans, int flags)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_tbl_entry *found;
@@ -3684,12 +3679,12 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
 			continue;
 		if (!found->learned)
 			continue;
-		err = rocker_port_fdb_learn(rocker_port, trans_ph, flags,
+		err = rocker_port_fdb_learn(rocker_port, trans, flags,
 					    found->key.addr,
 					    found->key.vlan_id);
 		if (err)
 			goto err_out;
-		if (trans_ph != SWITCHDEV_TRANS_PREPARE)
+		if (!switchdev_trans_ph_prepare(trans))
 			hash_del(&found->entry);
 	}
 
@@ -3700,7 +3695,7 @@ err_out:
 }
 
 static int rocker_port_router_mac(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph, int flags,
+				  struct switchdev_trans *trans, int flags,
 				  __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
@@ -3714,7 +3709,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		vlan_id = rocker_port->internal_vlan_id;
 
 	eth_type = htons(ETH_P_IP);
-	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans,
 				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3723,7 +3718,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		return err;
 
 	eth_type = htons(ETH_P_IPV6);
-	err = rocker_flow_tbl_term_mac(rocker_port, trans_ph,
+	err = rocker_flow_tbl_term_mac(rocker_port, trans,
 				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3733,7 +3728,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fwding(struct rocker_port *rocker_port,
-			      enum switchdev_trans_ph trans_ph, int flags)
+			      struct switchdev_trans *trans, int flags)
 {
 	bool pop_vlan;
 	u32 out_pport;
@@ -3758,7 +3753,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port,
 			continue;
 		vlan_id = htons(vid);
 		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
-		err = rocker_group_l2_interface(rocker_port, trans_ph, flags,
+		err = rocker_group_l2_interface(rocker_port, trans, flags,
 						vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
@@ -3772,16 +3767,16 @@ static int rocker_port_fwding(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_stp_update(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph, int flags,
+				  struct switchdev_trans *trans, int flags,
 				  u8 state)
 {
 	bool want[ROCKER_CTRL_MAX] = { 0, };
 	bool prev_ctrls[ROCKER_CTRL_MAX];
-	u8 prev_state;
+	u8 uninitialized_var(prev_state);
 	int err;
 	int i;
 
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE) {
+	if (switchdev_trans_ph_prepare(trans)) {
 		memcpy(prev_ctrls, rocker_port->ctrls, sizeof(prev_ctrls));
 		prev_state = rocker_port->stp_state;
 	}
@@ -3818,7 +3813,7 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 		if (want[i] != rocker_port->ctrls[i]) {
 			int ctrl_flags = flags |
 					 (want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
-			err = rocker_port_ctrl(rocker_port, trans_ph, ctrl_flags,
+			err = rocker_port_ctrl(rocker_port, trans, ctrl_flags,
 					       &rocker_ctrls[i]);
 			if (err)
 				goto err_out;
@@ -3826,14 +3821,14 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 		}
 	}
 
-	err = rocker_port_fdb_flush(rocker_port, trans_ph, flags);
+	err = rocker_port_fdb_flush(rocker_port, trans, flags);
 	if (err)
 		goto err_out;
 
-	err = rocker_port_fwding(rocker_port, trans_ph, flags);
+	err = rocker_port_fwding(rocker_port, trans, flags);
 
 err_out:
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE) {
+	if (switchdev_trans_ph_prepare(trans)) {
 		memcpy(rocker_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
 		rocker_port->stp_state = prev_state;
 	}
@@ -3842,26 +3837,26 @@ err_out:
 }
 
 static int rocker_port_fwd_enable(struct rocker_port *rocker_port,
-				  enum switchdev_trans_ph trans_ph, int flags)
+				  struct switchdev_trans *trans, int flags)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will enable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to FORWARDING state */
-	return rocker_port_stp_update(rocker_port, trans_ph, flags,
+	return rocker_port_stp_update(rocker_port, trans, flags,
 				      BR_STATE_FORWARDING);
 }
 
 static int rocker_port_fwd_disable(struct rocker_port *rocker_port,
-				   enum switchdev_trans_ph trans_ph, int flags)
+				   struct switchdev_trans *trans, int flags)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will disable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to DISABLED state */
-	return rocker_port_stp_update(rocker_port, trans_ph, flags,
+	return rocker_port_stp_update(rocker_port, trans, flags,
 				      BR_STATE_DISABLED);
 }
 
@@ -3952,7 +3947,7 @@ not_found:
 }
 
 static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, __be32 dst,
+				struct switchdev_trans *trans, __be32 dst,
 				int dst_len, const struct fib_info *fi,
 				u32 tb_id, int flags)
 {
@@ -3976,7 +3971,7 @@ static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
 	has_gw = !!nh->nh_gw;
 
 	if (has_gw && nh_on_port) {
-		err = rocker_port_ipv4_nh(rocker_port, trans_ph, flags,
+		err = rocker_port_ipv4_nh(rocker_port, trans, flags,
 					  nh->nh_gw, &index);
 		if (err)
 			return err;
@@ -3987,7 +3982,7 @@ static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(internal_vlan_id, 0);
 	}
 
-	err = rocker_flow_tbl_ucast4_routing(rocker_port, trans_ph, eth_type, dst,
+	err = rocker_flow_tbl_ucast4_routing(rocker_port, trans, eth_type, dst,
 					     dst_mask, priority, goto_tbl,
 					     group_id, flags);
 	if (err)
@@ -4026,7 +4021,7 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
-	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	err = rocker_port_fwd_enable(rocker_port, NULL, 0);
 	if (err)
 		goto err_fwd_enable;
 
@@ -4054,7 +4049,7 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
-	rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_fwd_disable(rocker_port, NULL,
 				ROCKER_OP_FLAG_NOWAIT);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
@@ -4240,7 +4235,7 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	struct port_name name = { .buf = buf, .len = len };
 	int err;
 
-	err = rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	err = rocker_cmd_exec(rocker_port, NULL, 0,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
 			      &name);
@@ -4265,7 +4260,7 @@ static void rocker_port_neigh_destroy(struct neighbour *n)
 	int flags = ROCKER_OP_FLAG_REMOVE | ROCKER_OP_FLAG_NOWAIT;
 	__be32 ip_addr = *(__be32 *)n->primary_key;
 
-	rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_ipv4_neigh(rocker_port, NULL,
 			       flags, ip_addr, n->ha);
 }
 
@@ -4322,7 +4317,7 @@ static void rocker_port_trans_abort(const struct rocker_port *rocker_port)
 }
 
 static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
-					enum switchdev_trans_ph trans_ph,
+					struct switchdev_trans *trans,
 					unsigned long brport_flags)
 {
 	unsigned long orig_flags;
@@ -4331,9 +4326,9 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	orig_flags = rocker_port->brport_flags;
 	rocker_port->brport_flags = brport_flags;
 	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
-		err = rocker_port_set_learning(rocker_port, trans_ph);
+		err = rocker_port_set_learning(rocker_port, trans);
 
-	if (trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (switchdev_trans_ph_prepare(trans))
 		rocker_port->brport_flags = orig_flags;
 
 	return err;
@@ -4359,12 +4354,12 @@ static int rocker_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, trans->ph,
+		err = rocker_port_stp_update(rocker_port, trans,
 					     ROCKER_OP_FLAG_NOWAIT,
 					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
-		err = rocker_port_brport_flags_set(rocker_port, trans->ph,
+		err = rocker_port_brport_flags_set(rocker_port, trans,
 						   attr->u.brport_flags);
 		break;
 	default:
@@ -4376,33 +4371,34 @@ static int rocker_port_attr_set(struct net_device *dev,
 }
 
 static int rocker_port_vlan_add(struct rocker_port *rocker_port,
-				enum switchdev_trans_ph trans_ph, u16 vid, u16 flags)
+				struct switchdev_trans *trans,
+				u16 vid, u16 flags)
 {
 	int err;
 
 	/* XXX deal with flags for PVID and untagged */
 
-	err = rocker_port_vlan(rocker_port, trans_ph, 0, vid);
+	err = rocker_port_vlan(rocker_port, trans, 0, vid);
 	if (err)
 		return err;
 
-	err = rocker_port_router_mac(rocker_port, trans_ph, 0, htons(vid));
+	err = rocker_port_router_mac(rocker_port, trans, 0, htons(vid));
 	if (err)
-		rocker_port_vlan(rocker_port, trans_ph,
+		rocker_port_vlan(rocker_port, trans,
 				 ROCKER_OP_FLAG_REMOVE, vid);
 
 	return err;
 }
 
 static int rocker_port_vlans_add(struct rocker_port *rocker_port,
-				 enum switchdev_trans_ph trans_ph,
+				 struct switchdev_trans *trans,
 				 const struct switchdev_obj_vlan *vlan)
 {
 	u16 vid;
 	int err;
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = rocker_port_vlan_add(rocker_port, trans_ph,
+		err = rocker_port_vlan_add(rocker_port, trans,
 					   vid, vlan->flags);
 		if (err)
 			return err;
@@ -4412,7 +4408,7 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_add(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph,
+			       struct switchdev_trans *trans,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
@@ -4421,7 +4417,7 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, trans_ph, fdb->addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, trans, fdb->addr, vlan_id, flags);
 }
 
 static int rocker_port_obj_add(struct net_device *dev,
@@ -4445,17 +4441,17 @@ static int rocker_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, trans->ph,
+		err = rocker_port_vlans_add(rocker_port, trans,
 					    &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
-		err = rocker_port_fib_ipv4(rocker_port, trans->ph,
+		err = rocker_port_fib_ipv4(rocker_port, trans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, trans->ph, &obj->u.fdb);
+		err = rocker_port_fdb_add(rocker_port, trans, &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4470,12 +4466,12 @@ static int rocker_port_vlan_del(struct rocker_port *rocker_port,
 {
 	int err;
 
-	err = rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
+	err = rocker_port_router_mac(rocker_port, NULL,
 				     ROCKER_OP_FLAG_REMOVE, htons(vid));
 	if (err)
 		return err;
 
-	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_port_vlan(rocker_port, NULL,
 				ROCKER_OP_FLAG_REMOVE, vid);
 }
 
@@ -4495,7 +4491,7 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_del(struct rocker_port *rocker_port,
-			       enum switchdev_trans_ph trans_ph,
+			       struct switchdev_trans *trans,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
@@ -4504,7 +4500,7 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
 
-	return rocker_port_fdb(rocker_port, trans_ph, fdb->addr, vlan_id, flags);
+	return rocker_port_fdb(rocker_port, trans, fdb->addr, vlan_id, flags);
 }
 
 static int rocker_port_obj_del(struct net_device *dev,
@@ -4520,14 +4516,13 @@ static int rocker_port_obj_del(struct net_device *dev,
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
-		err = rocker_port_fib_ipv4(rocker_port, SWITCHDEV_TRANS_NONE,
+		err = rocker_port_fib_ipv4(rocker_port, NULL,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_del(rocker_port, SWITCHDEV_TRANS_NONE,
-					  &obj->u.fdb);
+		err = rocker_port_fdb_del(rocker_port, NULL, &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4741,7 +4736,7 @@ rocker_cmd_get_port_stats_ethtool_proc(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
 					     void *priv)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+	return rocker_cmd_exec(rocker_port, NULL, 0,
 			       rocker_cmd_get_port_stats_prep, NULL,
 			       rocker_cmd_get_port_stats_ethtool_proc,
 			       priv);
@@ -4933,8 +4928,7 @@ static void rocker_remove_ports(const struct rocker *rocker)
 		rocker_port = rocker->ports[i];
 		if (!rocker_port)
 			continue;
-		rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
-				   ROCKER_OP_FLAG_REMOVE);
+		rocker_port_ig_tbl(rocker_port, NULL, ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
 		free_netdev(rocker_port->dev);
 	}
@@ -4995,9 +4989,9 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
 
-	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
+	rocker_port_set_learning(rocker_port, NULL);
 
-	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	err = rocker_port_ig_tbl(rocker_port, NULL, 0);
 	if (err) {
 		netdev_err(rocker_port->dev, "install ig port table failed\n");
 		goto err_port_ig_tbl;
@@ -5006,8 +5000,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
 
-	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
-				   untagged_vid, 0);
+	err = rocker_port_vlan_add(rocker_port, NULL, untagged_vid, 0);
 	if (err) {
 		netdev_err(rocker_port->dev, "install untagged VLAN failed\n");
 		goto err_untagged_vlan;
@@ -5016,8 +5009,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	return 0;
 
 err_untagged_vlan:
-	rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
-			   ROCKER_OP_FLAG_REMOVE);
+	rocker_port_ig_tbl(rocker_port, NULL, ROCKER_OP_FLAG_REMOVE);
 err_port_ig_tbl:
 	rocker->ports[port_number] = NULL;
 	unregister_netdev(dev);
@@ -5278,8 +5270,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 	rocker_port->bridge_dev = bridge;
 	switchdev_port_fwd_mark_set(rocker_port->dev, bridge, true);
 
-	return rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
-				    untagged_vid, 0);
+	return rocker_port_vlan_add(rocker_port, NULL, untagged_vid, 0);
 }
 
 static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
@@ -5301,14 +5292,12 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 				    false);
 	rocker_port->bridge_dev = NULL;
 
-	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
-				   untagged_vid, 0);
+	err = rocker_port_vlan_add(rocker_port, NULL, untagged_vid, 0);
 	if (err)
 		return err;
 
 	if (rocker_port->dev->flags & IFF_UP)
-		err = rocker_port_fwd_enable(rocker_port,
-					     SWITCHDEV_TRANS_NONE, 0);
+		err = rocker_port_fwd_enable(rocker_port, NULL, 0);
 
 	return err;
 }
@@ -5321,10 +5310,10 @@ static int rocker_port_ovs_changed(struct rocker_port *rocker_port,
 
 	rocker_port->bridge_dev = master;
 
-	err = rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	err = rocker_port_fwd_disable(rocker_port, NULL, 0);
 	if (err)
 		return err;
-	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	err = rocker_port_fwd_enable(rocker_port, NULL, 0);
 
 	return err;
 }
@@ -5402,8 +5391,7 @@ static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
 		    ROCKER_OP_FLAG_NOWAIT;
 	__be32 ip_addr = *(__be32 *)n->primary_key;
 
-	return rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
-				      flags, ip_addr, n->ha);
+	return rocker_port_ipv4_neigh(rocker_port, NULL, flags, ip_addr, n->ha);
 }
 
 static int rocker_netevent_event(struct notifier_block *unused,
-- 
1.9.3
