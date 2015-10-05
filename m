From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 01/13] rocker: remove unused rocker_port param from alloc funcs and shorten their names
Date: Mon,  5 Oct 2015 19:43:54 +0200
Message-ID: <1444067046-27825-2-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36257 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbbJERoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:09 -0400
Received: by wicgb1 with SMTP id gb1so130421683wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:08 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

No need to pass rocker_port around to alloc/free rocker functions,
since they now use switchdev_trans for memory management storage.
With the param removal, shorten the name of the functions since they now
has nothing to do with rocker port.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 87 +++++++++++++++++-------------------
 1 file changed, 42 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index cf91ffc..23c8d1e 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -341,9 +341,8 @@ static bool rocker_port_is_ovsed(const struct rocker_port *rocker_port)
 #define ROCKER_OP_FLAG_LEARNED		BIT(2)
 #define ROCKER_OP_FLAG_REFRESH		BIT(3)
 
-static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
-				     struct switchdev_trans *trans, int flags,
-				     size_t size)
+static void *__rocker_mem_alloc(struct switchdev_trans *trans, int flags,
+				size_t size)
 {
 	struct switchdev_trans_item *elem = NULL;
 	gfp_t gfp_flags = (flags & ROCKER_OP_FLAG_NOWAIT) ?
@@ -372,21 +371,19 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 	return elem ? elem + 1 : NULL;
 }
 
-static void *rocker_port_kzalloc(struct rocker_port *rocker_port,
-				 struct switchdev_trans *trans, int flags,
-				 size_t size)
+static void *rocker_kzalloc(struct switchdev_trans *trans, int flags,
+			    size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans, flags, size);
+	return __rocker_mem_alloc(trans, flags, size);
 }
 
-static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
-				 struct switchdev_trans *trans, int flags,
-				 size_t n, size_t size)
+static void *rocker_kcalloc(struct switchdev_trans *trans, int flags,
+			    size_t n, size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans, flags, n * size);
+	return __rocker_mem_alloc(trans, flags, n * size);
 }
 
-static void rocker_port_kfree(struct switchdev_trans *trans, const void *mem)
+static void rocker_kfree(struct switchdev_trans *trans, const void *mem)
 {
 	struct switchdev_trans_item *elem;
 
@@ -426,7 +423,7 @@ static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
 {
 	struct rocker_wait *wait;
 
-	wait = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*wait));
+	wait = rocker_kzalloc(trans, flags, sizeof(*wait));
 	if (!wait)
 		return NULL;
 	rocker_wait_init(wait);
@@ -436,7 +433,7 @@ static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
 static void rocker_wait_destroy(struct switchdev_trans *trans,
 				struct rocker_wait *wait)
 {
-	rocker_port_kfree(trans, wait);
+	rocker_kfree(trans, wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -2441,7 +2438,7 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		match->cookie = found->cookie;
 		if (!switchdev_trans_ph_prepare(trans))
 			hash_del(&found->entry);
-		rocker_port_kfree(trans, found);
+		rocker_kfree(trans, found);
 		found = match;
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
@@ -2483,13 +2480,13 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	rocker_port_kfree(trans, match);
+	rocker_kfree(trans, match);
 
 	if (found) {
 		err = rocker_cmd_exec(rocker_port, trans, flags,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL);
-		rocker_port_kfree(trans, found);
+		rocker_kfree(trans, found);
 	}
 
 	return err;
@@ -2512,7 +2509,7 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2534,7 +2531,7 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2561,7 +2558,7 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2601,7 +2598,7 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2651,7 +2648,7 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2681,7 +2678,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	u32 priority;
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2740,12 +2737,12 @@ static void rocker_group_tbl_entry_free(struct switchdev_trans *trans,
 	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
 	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		rocker_port_kfree(trans, entry->group_ids);
+		rocker_kfree(trans, entry->group_ids);
 		break;
 	default:
 		break;
 	}
-	rocker_port_kfree(trans, entry);
+	rocker_kfree(trans, entry);
 }
 
 static int rocker_group_tbl_add(struct rocker_port *rocker_port,
@@ -2830,7 +2827,7 @@ static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2847,17 +2844,17 @@ static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = rocker_port_kcalloc(rocker_port, trans, flags,
-					       group_count, sizeof(u32));
+	entry->group_ids = rocker_kcalloc(trans, flags,
+					  group_count, sizeof(u32));
 	if (!entry->group_ids) {
-		rocker_port_kfree(trans, entry);
+		rocker_kfree(trans, entry);
 		return -ENOMEM;
 	}
 	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
@@ -2882,7 +2879,7 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2931,7 +2928,7 @@ static void _rocker_neigh_del(struct switchdev_trans *trans,
 		return;
 	if (--entry->ref_count == 0) {
 		hash_del(&entry->entry);
-		rocker_port_kfree(trans, entry);
+		rocker_kfree(trans, entry);
 	}
 }
 
@@ -2965,7 +2962,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	bool removing;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -3034,7 +3031,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 
 err_out:
 	if (!adding)
-		rocker_port_kfree(trans, entry);
+		rocker_kfree(trans, entry);
 
 	return err;
 }
@@ -3082,7 +3079,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	bool resolved = true;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
+	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -3114,7 +3111,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
 
 	if (!adding)
-		rocker_port_kfree(trans, entry);
+		rocker_kfree(trans, entry);
 
 	if (err)
 		return err;
@@ -3139,8 +3136,8 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	int err = 0;
 	int i;
 
-	group_ids = rocker_port_kcalloc(rocker_port, trans, flags,
-					rocker->port_count, sizeof(u32));
+	group_ids = rocker_kcalloc(trans, flags,
+				   rocker->port_count, sizeof(u32));
 	if (!group_ids)
 		return -ENOMEM;
 
@@ -3172,7 +3169,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
 no_ports_in_vlan:
-	rocker_port_kfree(trans, group_ids);
+	rocker_kfree(trans, group_ids);
 	return err;
 }
 
@@ -3538,7 +3535,7 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
 					 lw->rocker_port->dev, &info.info);
 
-	rocker_port_kfree(lw->trans, work);
+	rocker_kfree(lw->trans, work);
 }
 
 static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
@@ -3572,7 +3569,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	lw = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*lw));
+	lw = rocker_kzalloc(trans, flags, sizeof(*lw));
 	if (!lw)
 		return -ENOMEM;
 
@@ -3585,7 +3582,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
 
 	if (switchdev_trans_ph_prepare(trans))
-		rocker_port_kfree(trans, lw);
+		rocker_kfree(trans, lw);
 	else
 		schedule_work(&lw->work);
 
@@ -3616,7 +3613,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*fdb));
+	fdb = rocker_kzalloc(trans, flags, sizeof(*fdb));
 	if (!fdb)
 		return -ENOMEM;
 
@@ -3634,7 +3631,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	if (found) {
 		found->touched = jiffies;
 		if (removing) {
-			rocker_port_kfree(trans, fdb);
+			rocker_kfree(trans, fdb);
 			if (!switchdev_trans_ph_prepare(trans))
 				hash_del(&found->entry);
 		}
@@ -3648,7 +3645,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	/* Check if adding and already exists, or removing and can't find */
 	if (!found != !removing) {
-		rocker_port_kfree(trans, fdb);
+		rocker_kfree(trans, fdb);
 		if (!found && removing)
 			return 0;
 		/* Refreshing existing to update aging timers */
-- 
1.9.3
