From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v3 net-next 1/2] rocker: remove unused rocker_port parameter from rocker_port_kfree
Date: Mon, 25 May 2015 14:28:35 +0900
Message-ID: <1432531716-9189-2-git-send-email-simon.horman@netronome.com>
References: <1432531716-9189-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34543 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbEYF24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 01:28:56 -0400
Received: by pdbki1 with SMTP id ki1so20841358pdb.1
        for <netdev@vger.kernel.org>; Sun, 24 May 2015 22:28:56 -0700 (PDT)
In-Reply-To: <1432531716-9189-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused rocker_port parameter from rocker_port_kfree.
Also remove the rocker_port parameter from callers of rocker_port_kfree
where the parameter it is now unused.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Acked-by: Scott Feldman <sfeldma@gmail.com>

---
v3
* Rebased

v2
* Added Scott Feldman's Ack
---
 drivers/net/ethernet/rocker/rocker.c | 54 +++++++++++++++++-------------------
 1 file changed, 25 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 701ffc200917..4818f2be036f 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -377,8 +377,7 @@ static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
 	return __rocker_port_mem_alloc(rocker_port, trans, n * size);
 }
 
-static void rocker_port_kfree(struct rocker_port *rocker_port,
-			      enum switchdev_trans trans, const void *mem)
+static void rocker_port_kfree(enum switchdev_trans trans, const void *mem)
 {
 	struct list_head *elem;
 
@@ -423,11 +422,10 @@ static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
 	return wait;
 }
 
-static void rocker_wait_destroy(struct rocker_port *rocker_port,
-				enum switchdev_trans trans,
+static void rocker_wait_destroy(enum switchdev_trans trans,
 				struct rocker_wait *wait)
 {
-	rocker_port_kfree(rocker_port, trans, wait);
+	rocker_port_kfree(trans, wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -1643,7 +1641,7 @@ static int rocker_cmd_exec(struct rocker *rocker,
 
 	rocker_desc_gen_clear(desc_info);
 out:
-	rocker_wait_destroy(rocker_port, trans, wait);
+	rocker_wait_destroy(trans, wait);
 	return err;
 }
 
@@ -2435,7 +2433,7 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		match->cookie = found->cookie;
 		if (trans != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
-		rocker_port_kfree(rocker_port, trans, found);
+		rocker_port_kfree(trans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -2478,13 +2476,13 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
-	rocker_port_kfree(rocker_port, trans, match);
+	rocker_port_kfree(trans, match);
 
 	if (found) {
 		err = rocker_cmd_exec(rocker, rocker_port, trans,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL);
-		rocker_port_kfree(rocker_port, trans, found);
+		rocker_port_kfree(trans, found);
 	}
 
 	return err;
@@ -2729,19 +2727,18 @@ rocker_group_tbl_find(struct rocker *rocker,
 	return NULL;
 }
 
-static void rocker_group_tbl_entry_free(struct rocker_port *rocker_port,
-					enum switchdev_trans trans,
+static void rocker_group_tbl_entry_free(enum switchdev_trans trans,
 					struct rocker_group_tbl_entry *entry)
 {
 	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		rocker_port_kfree(rocker_port, trans, entry->group_ids);
+		rocker_port_kfree(trans, entry->group_ids);
 		break;
 	default:
 		break;
 	}
-	rocker_port_kfree(rocker_port, trans, entry);
+	rocker_port_kfree(trans, entry);
 }
 
 static int rocker_group_tbl_add(struct rocker_port *rocker_port,
@@ -2759,7 +2756,7 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	if (found) {
 		if (trans != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
-		rocker_group_tbl_entry_free(rocker_port, trans, found);
+		rocker_group_tbl_entry_free(trans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
 	} else {
@@ -2798,13 +2795,13 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
 
-	rocker_group_tbl_entry_free(rocker_port, trans, match);
+	rocker_group_tbl_entry_free(trans, match);
 
 	if (found) {
 		err = rocker_cmd_exec(rocker, rocker_port, trans,
 				      rocker_cmd_group_tbl_del,
 				      found, NULL, NULL);
-		rocker_group_tbl_entry_free(rocker_port, trans, found);
+		rocker_group_tbl_entry_free(trans, found);
 	}
 
 	return err;
@@ -2854,7 +2851,7 @@ static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
 	entry->group_ids = rocker_port_kcalloc(rocker_port, trans, group_count,
 					       sizeof(u32));
 	if (!entry->group_ids) {
-		rocker_port_kfree(rocker_port, trans, entry);
+		rocker_port_kfree(trans, entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
@@ -2921,15 +2918,14 @@ static void _rocker_neigh_add(struct rocker *rocker,
 		 be32_to_cpu(entry->ip_addr));
 }
 
-static void _rocker_neigh_del(struct rocker_port *rocker_port,
-			      enum switchdev_trans trans,
+static void _rocker_neigh_del(enum switchdev_trans trans,
 			      struct rocker_neigh_tbl_entry *entry)
 {
 	if (trans == SWITCHDEV_TRANS_PREPARE)
 		return;
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
-		rocker_port_kfree(rocker_port, trans, entry);
+		rocker_port_kfree(trans, entry);
 	}
 }
 
@@ -2983,7 +2979,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 		_rocker_neigh_add(rocker, trans, entry);
 	} else if (removing) {
 		memcpy(entry, found, sizeof(*entry));
-		_rocker_neigh_del(rocker_port, trans, found);
+		_rocker_neigh_del(trans, found);
 	} else if (updating) {
 		_rocker_neigh_update(found, trans, eth_dst, true);
 		memcpy(entry, found, sizeof(*entry));
@@ -3032,7 +3028,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 err_out:
 	if (!adding)
-		rocker_port_kfree(rocker_port, trans, entry);
+		rocker_port_kfree(trans, entry);
 
 	return err;
 }
@@ -3100,7 +3096,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
-		_rocker_neigh_del(rocker_port, trans, found);
+		_rocker_neigh_del(trans, found);
 	} else if (updating) {
 		_rocker_neigh_update(found, trans, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
@@ -3111,7 +3107,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		rocker_port_kfree(rocker_port, trans, entry);
+		rocker_port_kfree(trans, entry);
 
 	if (err)
 		return err;
@@ -3167,7 +3163,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	rocker_port_kfree(rocker_port, trans, group_ids);
+	rocker_port_kfree(trans, group_ids);
 	return err;
 }
 
@@ -3526,7 +3522,7 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
 					 lw->rocker_port->dev, &info.info);
 
-	rocker_port_kfree(lw->rocker_port, lw->trans, work);
+	rocker_port_kfree(lw->trans, work);
 }
 
 static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
@@ -3573,7 +3569,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
 
 	if (trans == SWITCHDEV_TRANS_PREPARE)
-		rocker_port_kfree(rocker_port, trans, lw);
+		rocker_port_kfree(trans, lw);
 	else
 		schedule_work(&lw->work);
 
@@ -3618,7 +3614,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	found = rocker_fdb_tbl_find(rocker, fdb);
 
 	if (removing && found) {
-		rocker_port_kfree(rocker_port, trans, fdb);
+		rocker_port_kfree(trans, fdb);
 		if (trans != SWITCHDEV_TRANS_PREPARE)
 			hash_del(&found->entry);
 	} else if (!removing && !found) {
@@ -3630,7 +3626,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		rocker_port_kfree(rocker_port, trans, fdb);
+		rocker_port_kfree(trans, fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
-- 
2.1.4
