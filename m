From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/19] rocker: Change world_ops API and implementation to be switchdev independant
Date: Mon,  5 Jun 2017 11:20:40 +0200
Message-ID: <20170605092043.3523-17-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34086 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751360AbdFEJVJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:21:09 -0400
Received: by mail-wr0-f193.google.com with SMTP id u101so4374819wrc.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:21:07 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Currently the switchdev_trans struct is embedded in the world_ops API.
In order to add support for adding FDB via a notfication chain the API should
be switchdev independent.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h       |  11 +-
 drivers/net/ethernet/rocker/rocker_main.c  |  28 +-
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 535 +++++++++++------------------
 3 files changed, 235 insertions(+), 339 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index c25e331..a0f7782 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -105,8 +105,7 @@ struct rocker_world_ops {
 	int (*port_open)(struct rocker_port *rocker_port);
 	void (*port_stop)(struct rocker_port *rocker_port);
 	int (*port_attr_stp_state_set)(struct rocker_port *rocker_port,
-				       u8 state,
-				       struct switchdev_trans *trans);
+				       u8 state);
 	int (*port_attr_bridge_flags_set)(struct rocker_port *rocker_port,
 					  unsigned long brport_flags,
 					  struct switchdev_trans *trans);
@@ -120,18 +119,16 @@ struct rocker_world_ops {
 						u32 ageing_time,
 						struct switchdev_trans *trans);
 	int (*port_obj_vlan_add)(struct rocker_port *rocker_port,
-				 const struct switchdev_obj_port_vlan *vlan,
-				 struct switchdev_trans *trans);
+				 const struct switchdev_obj_port_vlan *vlan);
 	int (*port_obj_vlan_del)(struct rocker_port *rocker_port,
 				 const struct switchdev_obj_port_vlan *vlan);
 	int (*port_obj_vlan_dump)(const struct rocker_port *rocker_port,
 				  struct switchdev_obj_port_vlan *vlan,
 				  switchdev_obj_dump_cb_t *cb);
 	int (*port_obj_fdb_add)(struct rocker_port *rocker_port,
-				const struct switchdev_obj_port_fdb *fdb,
-				struct switchdev_trans *trans);
+				u16 vid, const unsigned char *addr);
 	int (*port_obj_fdb_del)(struct rocker_port *rocker_port,
-				const struct switchdev_obj_port_fdb *fdb);
+				u16 vid, const unsigned char *addr);
 	int (*port_obj_fdb_dump)(const struct rocker_port *rocker_port,
 				 struct switchdev_obj_port_fdb *fdb,
 				 switchdev_obj_dump_cb_t *cb);
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index a741e51..9f0154d 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1557,7 +1557,11 @@ static int rocker_world_port_attr_stp_state_set(struct rocker_port *rocker_port,
 
 	if (!wops->port_attr_stp_state_set)
 		return -EOPNOTSUPP;
-	return wops->port_attr_stp_state_set(rocker_port, state, trans);
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	return wops->port_attr_stp_state_set(rocker_port, state);
 }
 
 static int
@@ -1569,6 +1573,10 @@ rocker_world_port_attr_bridge_flags_set(struct rocker_port *rocker_port,
 
 	if (!wops->port_attr_bridge_flags_set)
 		return -EOPNOTSUPP;
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
 	return wops->port_attr_bridge_flags_set(rocker_port, brport_flags,
 						trans);
 }
@@ -1608,6 +1616,10 @@ rocker_world_port_attr_bridge_ageing_time_set(struct rocker_port *rocker_port,
 
 	if (!wops->port_attr_bridge_ageing_time_set)
 		return -EOPNOTSUPP;
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
 	return wops->port_attr_bridge_ageing_time_set(rocker_port, ageing_time,
 						      trans);
 }
@@ -1621,7 +1633,11 @@ rocker_world_port_obj_vlan_add(struct rocker_port *rocker_port,
 
 	if (!wops->port_obj_vlan_add)
 		return -EOPNOTSUPP;
-	return wops->port_obj_vlan_add(rocker_port, vlan, trans);
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	return wops->port_obj_vlan_add(rocker_port, vlan);
 }
 
 static int
@@ -1656,7 +1672,11 @@ rocker_world_port_obj_fdb_add(struct rocker_port *rocker_port,
 
 	if (!wops->port_obj_fdb_add)
 		return -EOPNOTSUPP;
-	return wops->port_obj_fdb_add(rocker_port, fdb, trans);
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	return wops->port_obj_fdb_add(rocker_port, fdb->vid, fdb->addr);
 }
 
 static int
@@ -1667,7 +1687,7 @@ rocker_world_port_obj_fdb_del(struct rocker_port *rocker_port,
 
 	if (!wops->port_obj_fdb_del)
 		return -EOPNOTSUPP;
-	return wops->port_obj_fdb_del(rocker_port, fdb);
+	return wops->port_obj_fdb_del(rocker_port, fdb->vid, fdb->addr);
 }
 
 static int
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 7528ee7..184a478 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -300,64 +300,6 @@ static bool ofdpa_flags_nowait(int flags)
 	return flags & OFDPA_OP_FLAG_NOWAIT;
 }
 
-static void *__ofdpa_mem_alloc(struct switchdev_trans *trans, int flags,
-			       size_t size)
-{
-	struct switchdev_trans_item *elem = NULL;
-	gfp_t gfp_flags = (flags & OFDPA_OP_FLAG_NOWAIT) ?
-			  GFP_ATOMIC : GFP_KERNEL;
-
-	/* If in transaction prepare phase, allocate the memory
-	 * and enqueue it on a transaction.  If in transaction
-	 * commit phase, dequeue the memory from the transaction
-	 * rather than re-allocating the memory.  The idea is the
-	 * driver code paths for prepare and commit are identical
-	 * so the memory allocated in the prepare phase is the
-	 * memory used in the commit phase.
-	 */
-
-	if (!trans) {
-		elem = kzalloc(size + sizeof(*elem), gfp_flags);
-	} else if (switchdev_trans_ph_prepare(trans)) {
-		elem = kzalloc(size + sizeof(*elem), gfp_flags);
-		if (!elem)
-			return NULL;
-		switchdev_trans_item_enqueue(trans, elem, kfree, elem);
-	} else {
-		elem = switchdev_trans_item_dequeue(trans);
-	}
-
-	return elem ? elem + 1 : NULL;
-}
-
-static void *ofdpa_kzalloc(struct switchdev_trans *trans, int flags,
-			   size_t size)
-{
-	return __ofdpa_mem_alloc(trans, flags, size);
-}
-
-static void *ofdpa_kcalloc(struct switchdev_trans *trans, int flags,
-			   size_t n, size_t size)
-{
-	return __ofdpa_mem_alloc(trans, flags, n * size);
-}
-
-static void ofdpa_kfree(struct switchdev_trans *trans, const void *mem)
-{
-	struct switchdev_trans_item *elem;
-
-	/* Frees are ignored if in transaction prepare phase.  The
-	 * memory remains on the per-port list until freed in the
-	 * commit phase.
-	 */
-
-	if (switchdev_trans_ph_prepare(trans))
-		return;
-
-	elem = (struct switchdev_trans_item *) mem - 1;
-	kfree(elem);
-}
-
 /*************************************************************
  * Flow, group, FDB, internal VLAN and neigh command prepares
  *************************************************************/
@@ -815,8 +757,7 @@ ofdpa_flow_tbl_find(const struct ofdpa *ofdpa,
 }
 
 static int ofdpa_flow_tbl_add(struct ofdpa_port *ofdpa_port,
-			      struct switchdev_trans *trans, int flags,
-			      struct ofdpa_flow_tbl_entry *match)
+			      int flags, struct ofdpa_flow_tbl_entry *match)
 {
 	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
 	struct ofdpa_flow_tbl_entry *found;
@@ -831,9 +772,8 @@ static int ofdpa_flow_tbl_add(struct ofdpa_port *ofdpa_port,
 
 	if (found) {
 		match->cookie = found->cookie;
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
-		ofdpa_kfree(trans, found);
+		hash_del(&found->entry);
+		kfree(found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -842,22 +782,18 @@ static int ofdpa_flow_tbl_add(struct ofdpa_port *ofdpa_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
 	}
 
-	if (!switchdev_trans_ph_prepare(trans))
-		hash_add(ofdpa->flow_tbl, &found->entry, found->key_crc32);
-
+	hash_add(ofdpa->flow_tbl, &found->entry, found->key_crc32);
 	spin_unlock_irqrestore(&ofdpa->flow_tbl_lock, lock_flags);
 
-	if (!switchdev_trans_ph_prepare(trans))
-		return rocker_cmd_exec(ofdpa_port->rocker_port,
-				       ofdpa_flags_nowait(flags),
-				       ofdpa_cmd_flow_tbl_add,
-				       found, NULL, NULL);
+	return rocker_cmd_exec(ofdpa_port->rocker_port,
+			       ofdpa_flags_nowait(flags),
+			       ofdpa_cmd_flow_tbl_add,
+			       found, NULL, NULL);
 	return 0;
 }
 
 static int ofdpa_flow_tbl_del(struct ofdpa_port *ofdpa_port,
-			      struct switchdev_trans *trans, int flags,
-			      struct ofdpa_flow_tbl_entry *match)
+			      int flags, struct ofdpa_flow_tbl_entry *match)
 {
 	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
 	struct ofdpa_flow_tbl_entry *found;
@@ -872,45 +808,41 @@ static int ofdpa_flow_tbl_del(struct ofdpa_port *ofdpa_port,
 	found = ofdpa_flow_tbl_find(ofdpa, match);
 
 	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
+		hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
 	}
 
 	spin_unlock_irqrestore(&ofdpa->flow_tbl_lock, lock_flags);
 
-	ofdpa_kfree(trans, match);
+	kfree(match);
 
 	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			err = rocker_cmd_exec(ofdpa_port->rocker_port,
-					      ofdpa_flags_nowait(flags),
-					      ofdpa_cmd_flow_tbl_del,
-					      found, NULL, NULL);
-		ofdpa_kfree(trans, found);
+		err = rocker_cmd_exec(ofdpa_port->rocker_port,
+				      ofdpa_flags_nowait(flags),
+				      ofdpa_cmd_flow_tbl_del,
+				      found, NULL, NULL);
+		kfree(found);
 	}
 
 	return err;
 }
 
-static int ofdpa_flow_tbl_do(struct ofdpa_port *ofdpa_port,
-			     struct switchdev_trans *trans, int flags,
+static int ofdpa_flow_tbl_do(struct ofdpa_port *ofdpa_port, int flags,
 			     struct ofdpa_flow_tbl_entry *entry)
 {
 	if (flags & OFDPA_OP_FLAG_REMOVE)
-		return ofdpa_flow_tbl_del(ofdpa_port, trans, flags, entry);
+		return ofdpa_flow_tbl_del(ofdpa_port, flags, entry);
 	else
-		return ofdpa_flow_tbl_add(ofdpa_port, trans, flags, entry);
+		return ofdpa_flow_tbl_add(ofdpa_port, flags, entry);
 }
 
-static int ofdpa_flow_tbl_ig_port(struct ofdpa_port *ofdpa_port,
-				  struct switchdev_trans *trans, int flags,
+static int ofdpa_flow_tbl_ig_port(struct ofdpa_port *ofdpa_port, int flags,
 				  u32 in_pport, u32 in_pport_mask,
 				  enum rocker_of_dpa_table_id goto_tbl)
 {
 	struct ofdpa_flow_tbl_entry *entry;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
@@ -920,11 +852,11 @@ static int ofdpa_flow_tbl_ig_port(struct ofdpa_port *ofdpa_port,
 	entry->key.ig_port.in_pport_mask = in_pport_mask;
 	entry->key.ig_port.goto_tbl = goto_tbl;
 
-	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_flow_tbl_do(ofdpa_port, flags, entry);
 }
 
 static int ofdpa_flow_tbl_vlan(struct ofdpa_port *ofdpa_port,
-			       struct switchdev_trans *trans, int flags,
+			       int flags,
 			       u32 in_pport, __be16 vlan_id,
 			       __be16 vlan_id_mask,
 			       enum rocker_of_dpa_table_id goto_tbl,
@@ -932,7 +864,7 @@ static int ofdpa_flow_tbl_vlan(struct ofdpa_port *ofdpa_port,
 {
 	struct ofdpa_flow_tbl_entry *entry;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
@@ -946,11 +878,10 @@ static int ofdpa_flow_tbl_vlan(struct ofdpa_port *ofdpa_port,
 	entry->key.vlan.untagged = untagged;
 	entry->key.vlan.new_vlan_id = new_vlan_id;
 
-	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_flow_tbl_do(ofdpa_port, flags, entry);
 }
 
 static int ofdpa_flow_tbl_term_mac(struct ofdpa_port *ofdpa_port,
-				   struct switchdev_trans *trans,
 				   u32 in_pport, u32 in_pport_mask,
 				   __be16 eth_type, const u8 *eth_dst,
 				   const u8 *eth_dst_mask, __be16 vlan_id,
@@ -959,7 +890,7 @@ static int ofdpa_flow_tbl_term_mac(struct ofdpa_port *ofdpa_port,
 {
 	struct ofdpa_flow_tbl_entry *entry;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
@@ -983,13 +914,13 @@ static int ofdpa_flow_tbl_term_mac(struct ofdpa_port *ofdpa_port,
 	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
 	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
 
-	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_flow_tbl_do(ofdpa_port, flags, entry);
 }
 
 static int ofdpa_flow_tbl_bridge(struct ofdpa_port *ofdpa_port,
-				 struct switchdev_trans *trans, int flags,
-				 const u8 *eth_dst, const u8 *eth_dst_mask,
-				 __be16 vlan_id, u32 tunnel_id,
+				 int flags, const u8 *eth_dst,
+				 const u8 *eth_dst_mask,  __be16 vlan_id,
+				 u32 tunnel_id,
 				 enum rocker_of_dpa_table_id goto_tbl,
 				 u32 group_id, bool copy_to_cpu)
 {
@@ -999,7 +930,7 @@ static int ofdpa_flow_tbl_bridge(struct ofdpa_port *ofdpa_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (!entry)
 		return -ENOMEM;
 
@@ -1037,11 +968,10 @@ static int ofdpa_flow_tbl_bridge(struct ofdpa_port *ofdpa_port,
 	entry->key.bridge.group_id = group_id;
 	entry->key.bridge.copy_to_cpu = copy_to_cpu;
 
-	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_flow_tbl_do(ofdpa_port, flags, entry);
 }
 
 static int ofdpa_flow_tbl_ucast4_routing(struct ofdpa_port *ofdpa_port,
-					 struct switchdev_trans *trans,
 					 __be16 eth_type, __be32 dst,
 					 __be32 dst_mask, u32 priority,
 					 enum rocker_of_dpa_table_id goto_tbl,
@@ -1050,7 +980,7 @@ static int ofdpa_flow_tbl_ucast4_routing(struct ofdpa_port *ofdpa_port,
 {
 	struct ofdpa_flow_tbl_entry *entry;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
@@ -1065,11 +995,10 @@ static int ofdpa_flow_tbl_ucast4_routing(struct ofdpa_port *ofdpa_port,
 				  ucast_routing.group_id);
 	entry->fi = fi;
 
-	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_flow_tbl_do(ofdpa_port, flags, entry);
 }
 
-static int ofdpa_flow_tbl_acl(struct ofdpa_port *ofdpa_port,
-			      struct switchdev_trans *trans, int flags,
+static int ofdpa_flow_tbl_acl(struct ofdpa_port *ofdpa_port, int flags,
 			      u32 in_pport, u32 in_pport_mask,
 			      const u8 *eth_src, const u8 *eth_src_mask,
 			      const u8 *eth_dst, const u8 *eth_dst_mask,
@@ -1081,7 +1010,7 @@ static int ofdpa_flow_tbl_acl(struct ofdpa_port *ofdpa_port,
 	u32 priority;
 	struct ofdpa_flow_tbl_entry *entry;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
@@ -1116,7 +1045,7 @@ static int ofdpa_flow_tbl_acl(struct ofdpa_port *ofdpa_port,
 	entry->key.acl.ip_tos_mask = ip_tos_mask;
 	entry->key.acl.group_id = group_id;
 
-	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_flow_tbl_do(ofdpa_port, flags, entry);
 }
 
 static struct ofdpa_group_tbl_entry *
@@ -1134,22 +1063,20 @@ ofdpa_group_tbl_find(const struct ofdpa *ofdpa,
 	return NULL;
 }
 
-static void ofdpa_group_tbl_entry_free(struct switchdev_trans *trans,
-				       struct ofdpa_group_tbl_entry *entry)
+static void ofdpa_group_tbl_entry_free(struct ofdpa_group_tbl_entry *entry)
 {
 	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		ofdpa_kfree(trans, entry->group_ids);
+		kfree(entry->group_ids);
 		break;
 	default:
 		break;
 	}
-	ofdpa_kfree(trans, entry);
+	kfree(entry);
 }
 
-static int ofdpa_group_tbl_add(struct ofdpa_port *ofdpa_port,
-			       struct switchdev_trans *trans, int flags,
+static int ofdpa_group_tbl_add(struct ofdpa_port *ofdpa_port, int flags,
 			       struct ofdpa_group_tbl_entry *match)
 {
 	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
@@ -1161,9 +1088,8 @@ static int ofdpa_group_tbl_add(struct ofdpa_port *ofdpa_port,
 	found = ofdpa_group_tbl_find(ofdpa, match);
 
 	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
-		ofdpa_group_tbl_entry_free(trans, found);
+		hash_del(&found->entry);
+		ofdpa_group_tbl_entry_free(found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
 	} else {
@@ -1171,21 +1097,17 @@ static int ofdpa_group_tbl_add(struct ofdpa_port *ofdpa_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
 	}
 
-	if (!switchdev_trans_ph_prepare(trans))
-		hash_add(ofdpa->group_tbl, &found->entry, found->group_id);
+	hash_add(ofdpa->group_tbl, &found->entry, found->group_id);
 
 	spin_unlock_irqrestore(&ofdpa->group_tbl_lock, lock_flags);
 
-	if (!switchdev_trans_ph_prepare(trans))
-		return rocker_cmd_exec(ofdpa_port->rocker_port,
-				       ofdpa_flags_nowait(flags),
-				       ofdpa_cmd_group_tbl_add,
-				       found, NULL, NULL);
-	return 0;
+	return rocker_cmd_exec(ofdpa_port->rocker_port,
+			       ofdpa_flags_nowait(flags),
+			       ofdpa_cmd_group_tbl_add,
+			       found, NULL, NULL);
 }
 
-static int ofdpa_group_tbl_del(struct ofdpa_port *ofdpa_port,
-			       struct switchdev_trans *trans, int flags,
+static int ofdpa_group_tbl_del(struct ofdpa_port *ofdpa_port, int flags,
 			       struct ofdpa_group_tbl_entry *match)
 {
 	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
@@ -1198,97 +1120,90 @@ static int ofdpa_group_tbl_del(struct ofdpa_port *ofdpa_port,
 	found = ofdpa_group_tbl_find(ofdpa, match);
 
 	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
+		hash_del(&found->entry);
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
 	}
 
 	spin_unlock_irqrestore(&ofdpa->group_tbl_lock, lock_flags);
 
-	ofdpa_group_tbl_entry_free(trans, match);
+	ofdpa_group_tbl_entry_free(match);
 
 	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			err = rocker_cmd_exec(ofdpa_port->rocker_port,
-					      ofdpa_flags_nowait(flags),
-					      ofdpa_cmd_group_tbl_del,
-					      found, NULL, NULL);
-		ofdpa_group_tbl_entry_free(trans, found);
+		err = rocker_cmd_exec(ofdpa_port->rocker_port,
+				      ofdpa_flags_nowait(flags),
+				      ofdpa_cmd_group_tbl_del,
+				      found, NULL, NULL);
+		ofdpa_group_tbl_entry_free(found);
 	}
 
 	return err;
 }
 
-static int ofdpa_group_tbl_do(struct ofdpa_port *ofdpa_port,
-			      struct switchdev_trans *trans, int flags,
+static int ofdpa_group_tbl_do(struct ofdpa_port *ofdpa_port, int flags,
 			      struct ofdpa_group_tbl_entry *entry)
 {
 	if (flags & OFDPA_OP_FLAG_REMOVE)
-		return ofdpa_group_tbl_del(ofdpa_port, trans, flags, entry);
+		return ofdpa_group_tbl_del(ofdpa_port, flags, entry);
 	else
-		return ofdpa_group_tbl_add(ofdpa_port, trans, flags, entry);
+		return ofdpa_group_tbl_add(ofdpa_port, flags, entry);
 }
 
 static int ofdpa_group_l2_interface(struct ofdpa_port *ofdpa_port,
-				    struct switchdev_trans *trans, int flags,
-				    __be16 vlan_id, u32 out_pport,
-				    int pop_vlan)
+				    int flags, __be16 vlan_id,
+				    u32 out_pport, int pop_vlan)
 {
 	struct ofdpa_group_tbl_entry *entry;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	entry->l2_interface.pop_vlan = pop_vlan;
 
-	return ofdpa_group_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_group_tbl_do(ofdpa_port, flags, entry);
 }
 
 static int ofdpa_group_l2_fan_out(struct ofdpa_port *ofdpa_port,
-				  struct switchdev_trans *trans,
 				  int flags, u8 group_count,
 				  const u32 *group_ids, u32 group_id)
 {
 	struct ofdpa_group_tbl_entry *entry;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = ofdpa_kcalloc(trans, flags,
-					 group_count, sizeof(u32));
+	entry->group_ids = kcalloc(flags, group_count, sizeof(u32));
 	if (!entry->group_ids) {
-		ofdpa_kfree(trans, entry);
+		kfree(entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
 
-	return ofdpa_group_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_group_tbl_do(ofdpa_port, flags, entry);
 }
 
 static int ofdpa_group_l2_flood(struct ofdpa_port *ofdpa_port,
-				struct switchdev_trans *trans, int flags,
-				__be16 vlan_id, u8 group_count,
-				const u32 *group_ids, u32 group_id)
+				int flags, __be16 vlan_id,
+				u8 group_count,	const u32 *group_ids,
+				u32 group_id)
 {
-	return ofdpa_group_l2_fan_out(ofdpa_port, trans, flags,
+	return ofdpa_group_l2_fan_out(ofdpa_port, flags,
 				      group_count, group_ids,
 				      group_id);
 }
 
-static int ofdpa_group_l3_unicast(struct ofdpa_port *ofdpa_port,
-				  struct switchdev_trans *trans, int flags,
+static int ofdpa_group_l3_unicast(struct ofdpa_port *ofdpa_port, int flags,
 				  u32 index, const u8 *src_mac, const u8 *dst_mac,
 				  __be16 vlan_id, bool ttl_check, u32 pport)
 {
 	struct ofdpa_group_tbl_entry *entry;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
@@ -1301,7 +1216,7 @@ static int ofdpa_group_l3_unicast(struct ofdpa_port *ofdpa_port,
 	entry->l3_unicast.ttl_check = ttl_check;
 	entry->l3_unicast.group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, pport);
 
-	return ofdpa_group_tbl_do(ofdpa_port, trans, flags, entry);
+	return ofdpa_group_tbl_do(ofdpa_port, flags, entry);
 }
 
 static struct ofdpa_neigh_tbl_entry *
@@ -1318,43 +1233,34 @@ ofdpa_neigh_tbl_find(const struct ofdpa *ofdpa, __be32 ip_addr)
 }
 
 static void ofdpa_neigh_add(struct ofdpa *ofdpa,
-			    struct switchdev_trans *trans,
 			    struct ofdpa_neigh_tbl_entry *entry)
 {
-	if (!switchdev_trans_ph_commit(trans))
-		entry->index = ofdpa->neigh_tbl_next_index++;
-	if (switchdev_trans_ph_prepare(trans))
-		return;
+	entry->index = ofdpa->neigh_tbl_next_index++;
 	entry->ref_count++;
 	hash_add(ofdpa->neigh_tbl, &entry->entry,
 		 be32_to_cpu(entry->ip_addr));
 }
 
-static void ofdpa_neigh_del(struct switchdev_trans *trans,
-			    struct ofdpa_neigh_tbl_entry *entry)
+static void ofdpa_neigh_del(struct ofdpa_neigh_tbl_entry *entry)
 {
-	if (switchdev_trans_ph_prepare(trans))
-		return;
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
-		ofdpa_kfree(trans, entry);
+		kfree(entry);
 	}
 }
 
 static void ofdpa_neigh_update(struct ofdpa_neigh_tbl_entry *entry,
-			       struct switchdev_trans *trans,
 			       const u8 *eth_dst, bool ttl_check)
 {
 	if (eth_dst) {
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = ttl_check;
-	} else if (!switchdev_trans_ph_prepare(trans)) {
+	} else {
 		entry->ref_count++;
 	}
 }
 
 static int ofdpa_port_ipv4_neigh(struct ofdpa_port *ofdpa_port,
-				 struct switchdev_trans *trans,
 				 int flags, __be32 ip_addr, const u8 *eth_dst)
 {
 	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
@@ -1371,7 +1277,7 @@ static int ofdpa_port_ipv4_neigh(struct ofdpa_port *ofdpa_port,
 	bool removing;
 	int err = 0;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
@@ -1388,12 +1294,12 @@ static int ofdpa_port_ipv4_neigh(struct ofdpa_port *ofdpa_port,
 		entry->dev = ofdpa_port->dev;
 		ether_addr_copy(entry->eth_dst, eth_dst);
 		entry->ttl_check = true;
-		ofdpa_neigh_add(ofdpa, trans, entry);
+		ofdpa_neigh_add(ofdpa, entry);
 	} else if (removing) {
 		memcpy(entry, found, sizeof(*entry));
-		ofdpa_neigh_del(trans, found);
+		ofdpa_neigh_del(found);
 	} else if (updating) {
-		ofdpa_neigh_update(found, trans, eth_dst, true);
+		ofdpa_neigh_update(found, eth_dst, true);
 		memcpy(entry, found, sizeof(*entry));
 	} else {
 		err = -ENOENT;
@@ -1410,7 +1316,7 @@ static int ofdpa_port_ipv4_neigh(struct ofdpa_port *ofdpa_port,
 	 * other routes' nexthops.
 	 */
 
-	err = ofdpa_group_l3_unicast(ofdpa_port, trans, flags,
+	err = ofdpa_group_l3_unicast(ofdpa_port, flags,
 				     entry->index,
 				     ofdpa_port->dev->dev_addr,
 				     entry->eth_dst,
@@ -1425,7 +1331,7 @@ static int ofdpa_port_ipv4_neigh(struct ofdpa_port *ofdpa_port,
 
 	if (adding || removing) {
 		group_id = ROCKER_GROUP_L3_UNICAST(entry->index);
-		err = ofdpa_flow_tbl_ucast4_routing(ofdpa_port, trans,
+		err = ofdpa_flow_tbl_ucast4_routing(ofdpa_port,
 						    eth_type, ip_addr,
 						    inet_make_mask(32),
 						    priority, goto_tbl,
@@ -1438,13 +1344,12 @@ static int ofdpa_port_ipv4_neigh(struct ofdpa_port *ofdpa_port,
 
 err_out:
 	if (!adding)
-		ofdpa_kfree(trans, entry);
+		kfree(entry);
 
 	return err;
 }
 
 static int ofdpa_port_ipv4_resolve(struct ofdpa_port *ofdpa_port,
-				   struct switchdev_trans *trans,
 				   __be32 ip_addr)
 {
 	struct net_device *dev = ofdpa_port->dev;
@@ -1463,7 +1368,7 @@ static int ofdpa_port_ipv4_resolve(struct ofdpa_port *ofdpa_port,
 	 */
 
 	if (n->nud_state & NUD_VALID)
-		err = ofdpa_port_ipv4_neigh(ofdpa_port, trans, 0,
+		err = ofdpa_port_ipv4_neigh(ofdpa_port, 0,
 					    ip_addr, n->ha);
 	else
 		neigh_event_send(n, NULL);
@@ -1473,8 +1378,7 @@ static int ofdpa_port_ipv4_resolve(struct ofdpa_port *ofdpa_port,
 }
 
 static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
-			      struct switchdev_trans *trans, int flags,
-			      __be32 ip_addr, u32 *index)
+			      int flags, __be32 ip_addr, u32 *index)
 {
 	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
 	struct ofdpa_neigh_tbl_entry *entry;
@@ -1486,7 +1390,7 @@ static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
 	bool resolved = true;
 	int err = 0;
 
-	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
 
@@ -1501,14 +1405,14 @@ static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
 	if (adding) {
 		entry->ip_addr = ip_addr;
 		entry->dev = ofdpa_port->dev;
-		ofdpa_neigh_add(ofdpa, trans, entry);
+		ofdpa_neigh_add(ofdpa, entry);
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
-		ofdpa_neigh_del(trans, found);
+		ofdpa_neigh_del(found);
 		*index = found->index;
 	} else if (updating) {
-		ofdpa_neigh_update(found, trans, NULL, false);
+		ofdpa_neigh_update(found, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
 		*index = found->index;
 	} else {
@@ -1518,7 +1422,7 @@ static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
 	spin_unlock_irqrestore(&ofdpa->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		ofdpa_kfree(trans, entry);
+		kfree(entry);
 
 	if (err)
 		return err;
@@ -1526,7 +1430,7 @@ static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
 	/* Resolved means neigh ip_addr is resolved to neigh mac. */
 
 	if (!resolved)
-		err = ofdpa_port_ipv4_resolve(ofdpa_port, trans, ip_addr);
+		err = ofdpa_port_ipv4_resolve(ofdpa_port, ip_addr);
 
 	return err;
 }
@@ -1541,7 +1445,6 @@ static struct ofdpa_port *ofdpa_port_get(const struct ofdpa *ofdpa,
 }
 
 static int ofdpa_port_vlan_flood_group(struct ofdpa_port *ofdpa_port,
-				       struct switchdev_trans *trans,
 				       int flags, __be16 vlan_id)
 {
 	struct ofdpa_port *p;
@@ -1553,7 +1456,7 @@ static int ofdpa_port_vlan_flood_group(struct ofdpa_port *ofdpa_port,
 	int err = 0;
 	int i;
 
-	group_ids = ofdpa_kcalloc(trans, flags, port_count, sizeof(u32));
+	group_ids = kcalloc(flags, port_count, sizeof(u32));
 	if (!group_ids)
 		return -ENOMEM;
 
@@ -1578,18 +1481,17 @@ static int ofdpa_port_vlan_flood_group(struct ofdpa_port *ofdpa_port,
 	if (group_count == 0)
 		goto no_ports_in_vlan;
 
-	err = ofdpa_group_l2_flood(ofdpa_port, trans, flags, vlan_id,
+	err = ofdpa_group_l2_flood(ofdpa_port, flags, vlan_id,
 				   group_count, group_ids, group_id);
 	if (err)
 		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	ofdpa_kfree(trans, group_ids);
+	kfree(group_ids);
 	return err;
 }
 
-static int ofdpa_port_vlan_l2_groups(struct ofdpa_port *ofdpa_port,
-				     struct switchdev_trans *trans, int flags,
+static int ofdpa_port_vlan_l2_groups(struct ofdpa_port *ofdpa_port, int flags,
 				     __be16 vlan_id, bool pop_vlan)
 {
 	const struct ofdpa *ofdpa = ofdpa_port->ofdpa;
@@ -1608,7 +1510,7 @@ static int ofdpa_port_vlan_l2_groups(struct ofdpa_port *ofdpa_port,
 	if (ofdpa_port->stp_state == BR_STATE_LEARNING ||
 	    ofdpa_port->stp_state == BR_STATE_FORWARDING) {
 		out_pport = ofdpa_port->pport;
-		err = ofdpa_group_l2_interface(ofdpa_port, trans, flags,
+		err = ofdpa_group_l2_interface(ofdpa_port, flags,
 					       vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 group for pport %d\n",
@@ -1632,7 +1534,7 @@ static int ofdpa_port_vlan_l2_groups(struct ofdpa_port *ofdpa_port,
 		return 0;
 
 	out_pport = 0;
-	err = ofdpa_group_l2_interface(ofdpa_port, trans, flags,
+	err = ofdpa_group_l2_interface(ofdpa_port, flags,
 				       vlan_id, out_pport, pop_vlan);
 	if (err) {
 		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 group for CPU port\n", err);
@@ -1693,8 +1595,7 @@ static struct ofdpa_ctrl {
 	},
 };
 
-static int ofdpa_port_ctrl_vlan_acl(struct ofdpa_port *ofdpa_port,
-				    struct switchdev_trans *trans, int flags,
+static int ofdpa_port_ctrl_vlan_acl(struct ofdpa_port *ofdpa_port, int flags,
 				    const struct ofdpa_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport = ofdpa_port->pport;
@@ -1710,7 +1611,7 @@ static int ofdpa_port_ctrl_vlan_acl(struct ofdpa_port *ofdpa_port,
 	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	int err;
 
-	err = ofdpa_flow_tbl_acl(ofdpa_port, trans, flags,
+	err = ofdpa_flow_tbl_acl(ofdpa_port, flags,
 				 in_pport, in_pport_mask,
 				 eth_src, eth_src_mask,
 				 ctrl->eth_dst, ctrl->eth_dst_mask,
@@ -1727,9 +1628,7 @@ static int ofdpa_port_ctrl_vlan_acl(struct ofdpa_port *ofdpa_port,
 }
 
 static int ofdpa_port_ctrl_vlan_bridge(struct ofdpa_port *ofdpa_port,
-				       struct switchdev_trans *trans,
-				       int flags,
-				       const struct ofdpa_ctrl *ctrl,
+				       int flags, const struct ofdpa_ctrl *ctrl,
 				       __be16 vlan_id)
 {
 	enum rocker_of_dpa_table_id goto_tbl =
@@ -1741,7 +1640,7 @@ static int ofdpa_port_ctrl_vlan_bridge(struct ofdpa_port *ofdpa_port,
 	if (!ofdpa_port_is_bridged(ofdpa_port))
 		return 0;
 
-	err = ofdpa_flow_tbl_bridge(ofdpa_port, trans, flags,
+	err = ofdpa_flow_tbl_bridge(ofdpa_port, flags,
 				    ctrl->eth_dst, ctrl->eth_dst_mask,
 				    vlan_id, tunnel_id,
 				    goto_tbl, group_id, ctrl->copy_to_cpu);
@@ -1752,8 +1651,7 @@ static int ofdpa_port_ctrl_vlan_bridge(struct ofdpa_port *ofdpa_port,
 	return err;
 }
 
-static int ofdpa_port_ctrl_vlan_term(struct ofdpa_port *ofdpa_port,
-				     struct switchdev_trans *trans, int flags,
+static int ofdpa_port_ctrl_vlan_term(struct ofdpa_port *ofdpa_port, int flags,
 				     const struct ofdpa_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
@@ -1763,8 +1661,7 @@ static int ofdpa_port_ctrl_vlan_term(struct ofdpa_port *ofdpa_port,
 	if (ntohs(vlan_id) == 0)
 		vlan_id = ofdpa_port->internal_vlan_id;
 
-	err = ofdpa_flow_tbl_term_mac(ofdpa_port, trans,
-				      ofdpa_port->pport, in_pport_mask,
+	err = ofdpa_flow_tbl_term_mac(ofdpa_port, ofdpa_port->pport, in_pport_mask,
 				      ctrl->eth_type, ctrl->eth_dst,
 				      ctrl->eth_dst_mask, vlan_id,
 				      vlan_id_mask, ctrl->copy_to_cpu,
@@ -1776,26 +1673,24 @@ static int ofdpa_port_ctrl_vlan_term(struct ofdpa_port *ofdpa_port,
 	return err;
 }
 
-static int ofdpa_port_ctrl_vlan(struct ofdpa_port *ofdpa_port,
-				struct switchdev_trans *trans, int flags,
+static int ofdpa_port_ctrl_vlan(struct ofdpa_port *ofdpa_port, int flags,
 				const struct ofdpa_ctrl *ctrl, __be16 vlan_id)
 {
 	if (ctrl->acl)
-		return ofdpa_port_ctrl_vlan_acl(ofdpa_port, trans, flags,
+		return ofdpa_port_ctrl_vlan_acl(ofdpa_port, flags,
 						ctrl, vlan_id);
 	if (ctrl->bridge)
-		return ofdpa_port_ctrl_vlan_bridge(ofdpa_port, trans, flags,
+		return ofdpa_port_ctrl_vlan_bridge(ofdpa_port, flags,
 						   ctrl, vlan_id);
 
 	if (ctrl->term)
-		return ofdpa_port_ctrl_vlan_term(ofdpa_port, trans, flags,
+		return ofdpa_port_ctrl_vlan_term(ofdpa_port, flags,
 						 ctrl, vlan_id);
 
 	return -EOPNOTSUPP;
 }
 
-static int ofdpa_port_ctrl_vlan_add(struct ofdpa_port *ofdpa_port,
-				    struct switchdev_trans *trans, int flags,
+static int ofdpa_port_ctrl_vlan_add(struct ofdpa_port *ofdpa_port, int flags,
 				    __be16 vlan_id)
 {
 	int err = 0;
@@ -1803,7 +1698,7 @@ static int ofdpa_port_ctrl_vlan_add(struct ofdpa_port *ofdpa_port,
 
 	for (i = 0; i < OFDPA_CTRL_MAX; i++) {
 		if (ofdpa_port->ctrls[i]) {
-			err = ofdpa_port_ctrl_vlan(ofdpa_port, trans, flags,
+			err = ofdpa_port_ctrl_vlan(ofdpa_port, flags,
 						   &ofdpa_ctrls[i], vlan_id);
 			if (err)
 				return err;
@@ -1813,8 +1708,7 @@ static int ofdpa_port_ctrl_vlan_add(struct ofdpa_port *ofdpa_port,
 	return err;
 }
 
-static int ofdpa_port_ctrl(struct ofdpa_port *ofdpa_port,
-			   struct switchdev_trans *trans, int flags,
+static int ofdpa_port_ctrl(struct ofdpa_port *ofdpa_port, int flags,
 			   const struct ofdpa_ctrl *ctrl)
 {
 	u16 vid;
@@ -1823,7 +1717,7 @@ static int ofdpa_port_ctrl(struct ofdpa_port *ofdpa_port,
 	for (vid = 1; vid < VLAN_N_VID; vid++) {
 		if (!test_bit(vid, ofdpa_port->vlan_bitmap))
 			continue;
-		err = ofdpa_port_ctrl_vlan(ofdpa_port, trans, flags,
+		err = ofdpa_port_ctrl_vlan(ofdpa_port, flags,
 					   ctrl, htons(vid));
 		if (err)
 			break;
@@ -1832,8 +1726,8 @@ static int ofdpa_port_ctrl(struct ofdpa_port *ofdpa_port,
 	return err;
 }
 
-static int ofdpa_port_vlan(struct ofdpa_port *ofdpa_port,
-			   struct switchdev_trans *trans, int flags, u16 vid)
+static int ofdpa_port_vlan(struct ofdpa_port *ofdpa_port, int flags,
+			   u16 vid)
 {
 	enum rocker_of_dpa_table_id goto_tbl =
 			ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
@@ -1857,43 +1751,44 @@ static int ofdpa_port_vlan(struct ofdpa_port *ofdpa_port,
 	change_bit(ntohs(internal_vlan_id), ofdpa_port->vlan_bitmap);
 
 	if (adding) {
-		err = ofdpa_port_ctrl_vlan_add(ofdpa_port, trans, flags,
+		err = ofdpa_port_ctrl_vlan_add(ofdpa_port, flags,
 					       internal_vlan_id);
 		if (err) {
 			netdev_err(ofdpa_port->dev, "Error (%d) port ctrl vlan add\n", err);
-			goto err_out;
+			goto err_vlan_add;
 		}
 	}
 
-	err = ofdpa_port_vlan_l2_groups(ofdpa_port, trans, flags,
+	err = ofdpa_port_vlan_l2_groups(ofdpa_port, flags,
 					internal_vlan_id, untagged);
 	if (err) {
 		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 groups\n", err);
-		goto err_out;
+		goto err_vlan_l2_groups;
 	}
 
-	err = ofdpa_port_vlan_flood_group(ofdpa_port, trans, flags,
+	err = ofdpa_port_vlan_flood_group(ofdpa_port, flags,
 					  internal_vlan_id);
 	if (err) {
 		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 flood group\n", err);
-		goto err_out;
+		goto err_flood_group;
 	}
 
-	err = ofdpa_flow_tbl_vlan(ofdpa_port, trans, flags,
+	err = ofdpa_flow_tbl_vlan(ofdpa_port, flags,
 				  in_pport, vlan_id, vlan_id_mask,
 				  goto_tbl, untagged, internal_vlan_id);
 	if (err)
 		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN table\n", err);
 
-err_out:
-	if (switchdev_trans_ph_prepare(trans))
-		change_bit(ntohs(internal_vlan_id), ofdpa_port->vlan_bitmap);
+	return 0;
 
+err_vlan_add:
+err_vlan_l2_groups:
+err_flood_group:
+	change_bit(ntohs(internal_vlan_id), ofdpa_port->vlan_bitmap);
 	return err;
 }
 
-static int ofdpa_port_ig_tbl(struct ofdpa_port *ofdpa_port,
-			     struct switchdev_trans *trans, int flags)
+static int ofdpa_port_ig_tbl(struct ofdpa_port *ofdpa_port, int flags)
 {
 	enum rocker_of_dpa_table_id goto_tbl;
 	u32 in_pport;
@@ -1908,7 +1803,7 @@ static int ofdpa_port_ig_tbl(struct ofdpa_port *ofdpa_port,
 	in_pport_mask = 0xffff0000;
 	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
 
-	err = ofdpa_flow_tbl_ig_port(ofdpa_port, trans, flags,
+	err = ofdpa_flow_tbl_ig_port(ofdpa_port, flags,
 				     in_pport, in_pport_mask,
 				     goto_tbl);
 	if (err)
@@ -1920,7 +1815,6 @@ static int ofdpa_port_ig_tbl(struct ofdpa_port *ofdpa_port,
 struct ofdpa_fdb_learn_work {
 	struct work_struct work;
 	struct ofdpa_port *ofdpa_port;
-	struct switchdev_trans *trans;
 	int flags;
 	u8 addr[ETH_ALEN];
 	u16 vid;
@@ -1946,12 +1840,11 @@ static void ofdpa_port_fdb_learn_work(struct work_struct *work)
 					 lw->ofdpa_port->dev, &info.info);
 	rtnl_unlock();
 
-	ofdpa_kfree(lw->trans, work);
+	kfree(work);
 }
 
 static int ofdpa_port_fdb_learn(struct ofdpa_port *ofdpa_port,
-				struct switchdev_trans *trans, int flags,
-				const u8 *addr, __be16 vlan_id)
+				int flags, const u8 *addr, __be16 vlan_id)
 {
 	struct ofdpa_fdb_learn_work *lw;
 	enum rocker_of_dpa_table_id goto_tbl =
@@ -1966,7 +1859,7 @@ static int ofdpa_port_fdb_learn(struct ofdpa_port *ofdpa_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 
 	if (!(flags & OFDPA_OP_FLAG_REFRESH)) {
-		err = ofdpa_flow_tbl_bridge(ofdpa_port, trans, flags, addr,
+		err = ofdpa_flow_tbl_bridge(ofdpa_port, flags, addr,
 					    NULL, vlan_id, tunnel_id, goto_tbl,
 					    group_id, copy_to_cpu);
 		if (err)
@@ -1976,23 +1869,18 @@ static int ofdpa_port_fdb_learn(struct ofdpa_port *ofdpa_port,
 	if (!ofdpa_port_is_bridged(ofdpa_port))
 		return 0;
 
-	lw = ofdpa_kzalloc(trans, flags, sizeof(*lw));
+	lw = kzalloc(sizeof(*lw), GFP_ATOMIC);
 	if (!lw)
 		return -ENOMEM;
 
 	INIT_WORK(&lw->work, ofdpa_port_fdb_learn_work);
 
 	lw->ofdpa_port = ofdpa_port;
-	lw->trans = trans;
 	lw->flags = flags;
 	ether_addr_copy(lw->addr, addr);
 	lw->vid = ofdpa_port_vlan_to_vid(ofdpa_port, vlan_id);
 
-	if (switchdev_trans_ph_prepare(trans))
-		ofdpa_kfree(trans, lw);
-	else
-		schedule_work(&lw->work);
-
+	schedule_work(&lw->work);
 	return 0;
 }
 
@@ -2010,7 +1898,6 @@ ofdpa_fdb_tbl_find(const struct ofdpa *ofdpa,
 }
 
 static int ofdpa_port_fdb(struct ofdpa_port *ofdpa_port,
-			  struct switchdev_trans *trans,
 			  const unsigned char *addr,
 			  __be16 vlan_id, int flags)
 {
@@ -2020,7 +1907,7 @@ static int ofdpa_port_fdb(struct ofdpa_port *ofdpa_port,
 	bool removing = (flags & OFDPA_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = ofdpa_kzalloc(trans, flags, sizeof(*fdb));
+	fdb = kzalloc(sizeof(*fdb), GFP_KERNEL);
 	if (!fdb)
 		return -ENOMEM;
 
@@ -2038,32 +1925,29 @@ static int ofdpa_port_fdb(struct ofdpa_port *ofdpa_port,
 	if (found) {
 		found->touched = jiffies;
 		if (removing) {
-			ofdpa_kfree(trans, fdb);
-			if (!switchdev_trans_ph_prepare(trans))
-				hash_del(&found->entry);
+			kfree(fdb);
+			hash_del(&found->entry);
 		}
 	} else if (!removing) {
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_add(ofdpa->fdb_tbl, &fdb->entry,
-				 fdb->key_crc32);
+		hash_add(ofdpa->fdb_tbl, &fdb->entry,
+			 fdb->key_crc32);
 	}
 
 	spin_unlock_irqrestore(&ofdpa->fdb_tbl_lock, lock_flags);
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		ofdpa_kfree(trans, fdb);
+		kfree(fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
 		flags |= OFDPA_OP_FLAG_REFRESH;
 	}
 
-	return ofdpa_port_fdb_learn(ofdpa_port, trans, flags, addr, vlan_id);
+	return ofdpa_port_fdb_learn(ofdpa_port, flags, addr, vlan_id);
 }
 
-static int ofdpa_port_fdb_flush(struct ofdpa_port *ofdpa_port,
-				struct switchdev_trans *trans, int flags)
+static int ofdpa_port_fdb_flush(struct ofdpa_port *ofdpa_port, int flags)
 {
 	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
 	struct ofdpa_fdb_tbl_entry *found;
@@ -2085,13 +1969,12 @@ static int ofdpa_port_fdb_flush(struct ofdpa_port *ofdpa_port,
 			continue;
 		if (!found->learned)
 			continue;
-		err = ofdpa_port_fdb_learn(ofdpa_port, trans, flags,
+		err = ofdpa_port_fdb_learn(ofdpa_port, flags,
 					   found->key.addr,
 					   found->key.vlan_id);
 		if (err)
 			goto err_out;
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
+		hash_del(&found->entry);
 	}
 
 err_out:
@@ -2121,8 +2004,8 @@ static void ofdpa_fdb_cleanup(unsigned long data)
 		ofdpa_port = entry->key.ofdpa_port;
 		expires = entry->touched + ofdpa_port->ageing_time;
 		if (time_before_eq(expires, jiffies)) {
-			ofdpa_port_fdb_learn(ofdpa_port, NULL,
-					     flags, entry->key.addr,
+			ofdpa_port_fdb_learn(ofdpa_port, flags,
+					     entry->key.addr,
 					     entry->key.vlan_id);
 			hash_del(&entry->entry);
 		} else if (time_before(expires, next_timer)) {
@@ -2136,8 +2019,7 @@ static void ofdpa_fdb_cleanup(unsigned long data)
 }
 
 static int ofdpa_port_router_mac(struct ofdpa_port *ofdpa_port,
-				 struct switchdev_trans *trans, int flags,
-				 __be16 vlan_id)
+				 int flags, __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
 	__be16 eth_type;
@@ -2150,26 +2032,25 @@ static int ofdpa_port_router_mac(struct ofdpa_port *ofdpa_port,
 		vlan_id = ofdpa_port->internal_vlan_id;
 
 	eth_type = htons(ETH_P_IP);
-	err = ofdpa_flow_tbl_term_mac(ofdpa_port, trans,
-				      ofdpa_port->pport, in_pport_mask,
-				      eth_type, ofdpa_port->dev->dev_addr,
+	err = ofdpa_flow_tbl_term_mac(ofdpa_port, ofdpa_port->pport,
+				      in_pport_mask, eth_type,
+				      ofdpa_port->dev->dev_addr,
 				      dst_mac_mask, vlan_id, vlan_id_mask,
 				      copy_to_cpu, flags);
 	if (err)
 		return err;
 
 	eth_type = htons(ETH_P_IPV6);
-	err = ofdpa_flow_tbl_term_mac(ofdpa_port, trans,
-				      ofdpa_port->pport, in_pport_mask,
-				      eth_type, ofdpa_port->dev->dev_addr,
+	err = ofdpa_flow_tbl_term_mac(ofdpa_port, ofdpa_port->pport,
+				      in_pport_mask, eth_type,
+				      ofdpa_port->dev->dev_addr,
 				      dst_mac_mask, vlan_id, vlan_id_mask,
 				      copy_to_cpu, flags);
 
 	return err;
 }
 
-static int ofdpa_port_fwding(struct ofdpa_port *ofdpa_port,
-			     struct switchdev_trans *trans, int flags)
+static int ofdpa_port_fwding(struct ofdpa_port *ofdpa_port, int flags)
 {
 	bool pop_vlan;
 	u32 out_pport;
@@ -2194,7 +2075,7 @@ static int ofdpa_port_fwding(struct ofdpa_port *ofdpa_port,
 			continue;
 		vlan_id = htons(vid);
 		pop_vlan = ofdpa_vlan_id_is_internal(vlan_id);
-		err = ofdpa_group_l2_interface(ofdpa_port, trans, flags,
+		err = ofdpa_group_l2_interface(ofdpa_port, flags,
 					       vlan_id, out_pport, pop_vlan);
 		if (err) {
 			netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 group for pport %d\n",
@@ -2207,7 +2088,6 @@ static int ofdpa_port_fwding(struct ofdpa_port *ofdpa_port,
 }
 
 static int ofdpa_port_stp_update(struct ofdpa_port *ofdpa_port,
-				 struct switchdev_trans *trans,
 				 int flags, u8 state)
 {
 	bool want[OFDPA_CTRL_MAX] = { 0, };
@@ -2216,11 +2096,12 @@ static int ofdpa_port_stp_update(struct ofdpa_port *ofdpa_port,
 	int err;
 	int i;
 
+	memcpy(prev_ctrls, ofdpa_port->ctrls, sizeof(prev_ctrls));
 	prev_state = ofdpa_port->stp_state;
-	if (prev_state == state)
+
+	if (ofdpa_port->stp_state == state)
 		return 0;
 
-	memcpy(prev_ctrls, ofdpa_port->ctrls, sizeof(prev_ctrls));
 	ofdpa_port->stp_state = state;
 
 	switch (state) {
@@ -2250,26 +2131,29 @@ static int ofdpa_port_stp_update(struct ofdpa_port *ofdpa_port,
 		if (want[i] != ofdpa_port->ctrls[i]) {
 			int ctrl_flags = flags |
 					 (want[i] ? 0 : OFDPA_OP_FLAG_REMOVE);
-			err = ofdpa_port_ctrl(ofdpa_port, trans, ctrl_flags,
+			err = ofdpa_port_ctrl(ofdpa_port, ctrl_flags,
 					      &ofdpa_ctrls[i]);
 			if (err)
-				goto err_out;
+				goto err_port_ctrl;
 			ofdpa_port->ctrls[i] = want[i];
 		}
 	}
 
-	err = ofdpa_port_fdb_flush(ofdpa_port, trans, flags);
+	err = ofdpa_port_fdb_flush(ofdpa_port, flags);
 	if (err)
-		goto err_out;
+		goto err_fdb_flush;
 
-	err = ofdpa_port_fwding(ofdpa_port, trans, flags);
+	err = ofdpa_port_fwding(ofdpa_port, flags);
+	if (err)
+		goto err_port_fwding;
 
-err_out:
-	if (switchdev_trans_ph_prepare(trans)) {
-		memcpy(ofdpa_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
-		ofdpa_port->stp_state = prev_state;
-	}
+	return 0;
 
+err_port_ctrl:
+err_fdb_flush:
+err_port_fwding:
+	memcpy(ofdpa_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
+	ofdpa_port->stp_state = prev_state;
 	return err;
 }
 
@@ -2280,7 +2164,7 @@ static int ofdpa_port_fwd_enable(struct ofdpa_port *ofdpa_port, int flags)
 		return 0;
 
 	/* port is not bridged, so simulate going to FORWARDING state */
-	return ofdpa_port_stp_update(ofdpa_port, NULL, flags,
+	return ofdpa_port_stp_update(ofdpa_port, flags,
 				     BR_STATE_FORWARDING);
 }
 
@@ -2291,25 +2175,24 @@ static int ofdpa_port_fwd_disable(struct ofdpa_port *ofdpa_port, int flags)
 		return 0;
 
 	/* port is not bridged, so simulate going to DISABLED state */
-	return ofdpa_port_stp_update(ofdpa_port, NULL, flags,
+	return ofdpa_port_stp_update(ofdpa_port, flags,
 				     BR_STATE_DISABLED);
 }
 
 static int ofdpa_port_vlan_add(struct ofdpa_port *ofdpa_port,
-			       struct switchdev_trans *trans,
 			       u16 vid, u16 flags)
 {
 	int err;
 
 	/* XXX deal with flags for PVID and untagged */
 
-	err = ofdpa_port_vlan(ofdpa_port, trans, 0, vid);
+	err = ofdpa_port_vlan(ofdpa_port, 0, vid);
 	if (err)
 		return err;
 
-	err = ofdpa_port_router_mac(ofdpa_port, trans, 0, htons(vid));
+	err = ofdpa_port_router_mac(ofdpa_port, 0, htons(vid));
 	if (err)
-		ofdpa_port_vlan(ofdpa_port, trans,
+		ofdpa_port_vlan(ofdpa_port,
 				OFDPA_OP_FLAG_REMOVE, vid);
 
 	return err;
@@ -2320,13 +2203,13 @@ static int ofdpa_port_vlan_del(struct ofdpa_port *ofdpa_port,
 {
 	int err;
 
-	err = ofdpa_port_router_mac(ofdpa_port, NULL,
-				    OFDPA_OP_FLAG_REMOVE, htons(vid));
+	err = ofdpa_port_router_mac(ofdpa_port, OFDPA_OP_FLAG_REMOVE,
+				    htons(vid));
 	if (err)
 		return err;
 
-	return ofdpa_port_vlan(ofdpa_port, NULL,
-			       OFDPA_OP_FLAG_REMOVE, vid);
+	return ofdpa_port_vlan(ofdpa_port, OFDPA_OP_FLAG_REMOVE,
+			       vid);
 }
 
 static struct ofdpa_internal_vlan_tbl_entry *
@@ -2385,10 +2268,9 @@ static __be16 ofdpa_port_internal_vlan_id_get(struct ofdpa_port *ofdpa_port,
 	return found->vlan_id;
 }
 
-static int ofdpa_port_fib_ipv4(struct ofdpa_port *ofdpa_port,
-			       struct switchdev_trans *trans, __be32 dst,
-			       int dst_len, struct fib_info *fi,
-			       u32 tb_id, int flags)
+static int ofdpa_port_fib_ipv4(struct ofdpa_port *ofdpa_port,  __be32 dst,
+			       int dst_len, struct fib_info *fi, u32 tb_id,
+			       int flags)
 {
 	const struct fib_nh *nh;
 	__be16 eth_type = htons(ETH_P_IP);
@@ -2410,7 +2292,7 @@ static int ofdpa_port_fib_ipv4(struct ofdpa_port *ofdpa_port,
 	has_gw = !!nh->nh_gw;
 
 	if (has_gw && nh_on_port) {
-		err = ofdpa_port_ipv4_nh(ofdpa_port, trans, flags,
+		err = ofdpa_port_ipv4_nh(ofdpa_port, flags,
 					 nh->nh_gw, &index);
 		if (err)
 			return err;
@@ -2421,7 +2303,7 @@ static int ofdpa_port_fib_ipv4(struct ofdpa_port *ofdpa_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(internal_vlan_id, 0);
 	}
 
-	err = ofdpa_flow_tbl_ucast4_routing(ofdpa_port, trans, eth_type, dst,
+	err = ofdpa_flow_tbl_ucast4_routing(ofdpa_port, eth_type, dst,
 					    dst_mask, priority, goto_tbl,
 					    group_id, fi, flags);
 	if (err)
@@ -2559,7 +2441,7 @@ static int ofdpa_port_init(struct rocker_port *rocker_port)
 	rocker_port_set_learning(rocker_port,
 				 !!(ofdpa_port->brport_flags & BR_LEARNING));
 
-	err = ofdpa_port_ig_tbl(ofdpa_port, NULL, 0);
+	err = ofdpa_port_ig_tbl(ofdpa_port, 0);
 	if (err) {
 		netdev_err(ofdpa_port->dev, "install ig port table failed\n");
 		return err;
@@ -2569,7 +2451,7 @@ static int ofdpa_port_init(struct rocker_port *rocker_port)
 		ofdpa_port_internal_vlan_id_get(ofdpa_port,
 						ofdpa_port->dev->ifindex);
 
-	err = ofdpa_port_vlan_add(ofdpa_port, NULL, OFDPA_UNTAGGED_VID, 0);
+	err = ofdpa_port_vlan_add(ofdpa_port, OFDPA_UNTAGGED_VID, 0);
 	if (err) {
 		netdev_err(ofdpa_port->dev, "install untagged VLAN failed\n");
 		goto err_untagged_vlan;
@@ -2577,7 +2459,7 @@ static int ofdpa_port_init(struct rocker_port *rocker_port)
 	return 0;
 
 err_untagged_vlan:
-	ofdpa_port_ig_tbl(ofdpa_port, NULL, OFDPA_OP_FLAG_REMOVE);
+	ofdpa_port_ig_tbl(ofdpa_port, OFDPA_OP_FLAG_REMOVE);
 	return err;
 }
 
@@ -2585,7 +2467,7 @@ static void ofdpa_port_fini(struct rocker_port *rocker_port)
 {
 	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
 
-	ofdpa_port_ig_tbl(ofdpa_port, NULL, OFDPA_OP_FLAG_REMOVE);
+	ofdpa_port_ig_tbl(ofdpa_port, OFDPA_OP_FLAG_REMOVE);
 }
 
 static int ofdpa_port_open(struct rocker_port *rocker_port)
@@ -2603,12 +2485,11 @@ static void ofdpa_port_stop(struct rocker_port *rocker_port)
 }
 
 static int ofdpa_port_attr_stp_state_set(struct rocker_port *rocker_port,
-					 u8 state,
-					 struct switchdev_trans *trans)
+					 u8 state)
 {
 	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
 
-	return ofdpa_port_stp_update(ofdpa_port, trans, 0, state);
+	return ofdpa_port_stp_update(ofdpa_port, 0, state);
 }
 
 static int ofdpa_port_attr_bridge_flags_set(struct rocker_port *rocker_port,
@@ -2671,15 +2552,14 @@ ofdpa_port_attr_bridge_ageing_time_set(struct rocker_port *rocker_port,
 }
 
 static int ofdpa_port_obj_vlan_add(struct rocker_port *rocker_port,
-				   const struct switchdev_obj_port_vlan *vlan,
-				   struct switchdev_trans *trans)
+				   const struct switchdev_obj_port_vlan *vlan)
 {
 	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
 	u16 vid;
 	int err;
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = ofdpa_port_vlan_add(ofdpa_port, trans, vid, vlan->flags);
+		err = ofdpa_port_vlan_add(ofdpa_port, vid, vlan->flags);
 		if (err)
 			return err;
 	}
@@ -2727,29 +2607,28 @@ static int ofdpa_port_obj_vlan_dump(const struct rocker_port *rocker_port,
 }
 
 static int ofdpa_port_obj_fdb_add(struct rocker_port *rocker_port,
-				  const struct switchdev_obj_port_fdb *fdb,
-				  struct switchdev_trans *trans)
+				  u16 vid, const unsigned char *addr)
 {
 	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
-	__be16 vlan_id = ofdpa_port_vid_to_vlan(ofdpa_port, fdb->vid, NULL);
+	__be16 vlan_id = ofdpa_port_vid_to_vlan(ofdpa_port, vid, NULL);
 
 	if (!ofdpa_port_is_bridged(ofdpa_port))
 		return -EINVAL;
 
-	return ofdpa_port_fdb(ofdpa_port, trans, fdb->addr, vlan_id, 0);
+	return ofdpa_port_fdb(ofdpa_port, addr, vlan_id, 0);
 }
 
 static int ofdpa_port_obj_fdb_del(struct rocker_port *rocker_port,
-				  const struct switchdev_obj_port_fdb *fdb)
+				  u16 vid, const unsigned char *addr)
 {
 	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
-	__be16 vlan_id = ofdpa_port_vid_to_vlan(ofdpa_port, fdb->vid, NULL);
+	__be16 vlan_id = ofdpa_port_vid_to_vlan(ofdpa_port, vid, NULL);
 	int flags = OFDPA_OP_FLAG_REMOVE;
 
 	if (!ofdpa_port_is_bridged(ofdpa_port))
 		return -EINVAL;
 
-	return ofdpa_port_fdb(ofdpa_port, NULL, fdb->addr, vlan_id, flags);
+	return ofdpa_port_fdb(ofdpa_port, addr, vlan_id, flags);
 }
 
 static int ofdpa_port_obj_fdb_dump(const struct rocker_port *rocker_port,
@@ -2803,7 +2682,7 @@ static int ofdpa_port_bridge_join(struct ofdpa_port *ofdpa_port,
 
 	ofdpa_port->bridge_dev = bridge;
 
-	return ofdpa_port_vlan_add(ofdpa_port, NULL, OFDPA_UNTAGGED_VID, 0);
+	return ofdpa_port_vlan_add(ofdpa_port, OFDPA_UNTAGGED_VID, 0);
 }
 
 static int ofdpa_port_bridge_leave(struct ofdpa_port *ofdpa_port)
@@ -2822,7 +2701,7 @@ static int ofdpa_port_bridge_leave(struct ofdpa_port *ofdpa_port)
 
 	ofdpa_port->bridge_dev = NULL;
 
-	err = ofdpa_port_vlan_add(ofdpa_port, NULL, OFDPA_UNTAGGED_VID, 0);
+	err = ofdpa_port_vlan_add(ofdpa_port, OFDPA_UNTAGGED_VID, 0);
 	if (err)
 		return err;
 
@@ -2881,7 +2760,7 @@ static int ofdpa_port_neigh_update(struct rocker_port *rocker_port,
 						    OFDPA_OP_FLAG_NOWAIT;
 	__be32 ip_addr = *(__be32 *) n->primary_key;
 
-	return ofdpa_port_ipv4_neigh(ofdpa_port, NULL, flags, ip_addr, n->ha);
+	return ofdpa_port_ipv4_neigh(ofdpa_port, flags, ip_addr, n->ha);
 }
 
 static int ofdpa_port_neigh_destroy(struct rocker_port *rocker_port,
@@ -2891,7 +2770,7 @@ static int ofdpa_port_neigh_destroy(struct rocker_port *rocker_port,
 	int flags = OFDPA_OP_FLAG_REMOVE | OFDPA_OP_FLAG_NOWAIT;
 	__be32 ip_addr = *(__be32 *) n->primary_key;
 
-	return ofdpa_port_ipv4_neigh(ofdpa_port, NULL, flags, ip_addr, n->ha);
+	return ofdpa_port_ipv4_neigh(ofdpa_port, flags, ip_addr, n->ha);
 }
 
 static int ofdpa_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
@@ -2905,7 +2784,7 @@ static int ofdpa_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
 	    ofdpa_port->stp_state != BR_STATE_FORWARDING)
 		return 0;
 
-	return ofdpa_port_fdb(ofdpa_port, NULL, addr, vlan_id, flags);
+	return ofdpa_port_fdb(ofdpa_port, addr, vlan_id, flags);
 }
 
 static struct ofdpa_port *ofdpa_port_dev_lower_find(struct net_device *dev,
@@ -2929,7 +2808,7 @@ static int ofdpa_fib4_add(struct rocker *rocker,
 	ofdpa_port = ofdpa_port_dev_lower_find(fen_info->fi->fib_dev, rocker);
 	if (!ofdpa_port)
 		return 0;
-	err = ofdpa_port_fib_ipv4(ofdpa_port, NULL, htonl(fen_info->dst),
+	err = ofdpa_port_fib_ipv4(ofdpa_port, htonl(fen_info->dst),
 				  fen_info->dst_len, fen_info->fi,
 				  fen_info->tb_id, 0);
 	if (err)
@@ -2950,7 +2829,7 @@ static int ofdpa_fib4_del(struct rocker *rocker,
 	if (!ofdpa_port)
 		return 0;
 	fib_info_offload_dec(fen_info->fi);
-	return ofdpa_port_fib_ipv4(ofdpa_port, NULL, htonl(fen_info->dst),
+	return ofdpa_port_fib_ipv4(ofdpa_port, htonl(fen_info->dst),
 				   fen_info->dst_len, fen_info->fi,
 				   fen_info->tb_id, OFDPA_OP_FLAG_REMOVE);
 }
@@ -2977,7 +2856,7 @@ static void ofdpa_fib4_abort(struct rocker *rocker)
 		if (!ofdpa_port)
 			continue;
 		fib_info_offload_dec(flow_entry->fi);
-		ofdpa_flow_tbl_del(ofdpa_port, NULL, OFDPA_OP_FLAG_REMOVE,
+		ofdpa_flow_tbl_del(ofdpa_port, OFDPA_OP_FLAG_REMOVE,
 				   flow_entry);
 	}
 	spin_unlock_irqrestore(&ofdpa->flow_tbl_lock, flags);
-- 
2.9.3
