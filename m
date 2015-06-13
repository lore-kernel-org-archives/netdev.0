From: sfeldma@gmail.com
Subject: [PATCH net-next 1/5] rocker: revert back to support for nowait processes
Date: Fri, 12 Jun 2015 21:35:46 -0700
Message-ID: <1434170150-63838-2-git-send-email-sfeldma@gmail.com>
References: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36738 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbbFMEeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:34:02 -0400
Received: by igbpi8 with SMTP id pi8so23268486igb.1
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 21:34:01 -0700 (PDT)
In-Reply-To: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

One of the items removed from the rocker driver in the Spring Cleanup patch
series was the ability to mark processing in the driver as "no wait" for
those contexts where we cannot sleep.  Turns out, we have "no wait"
contexts where we want to program the device.  So re-add the
ROCKER_OP_FLAG_NOWAIT flag to mark such processes, and propagate flags to
mem allocator and to the device cmd executor.  With NOWAIT, mem allocs are
GFP_ATOMIC and device cmds are queued to the device, but the driver will
not wait (sleep) for the response back from the device.

My bad for removing NOWAIT support in the first place; I thought we could
swing non-sleep contexts to process context using a work queue, for
example, but there is push-back to keep processing in original context.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |  202 +++++++++++++++++++---------------
 1 file changed, 112 insertions(+), 90 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a9d1559..c1910c1 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -326,10 +326,18 @@ static bool rocker_port_is_bridged(const struct rocker_port *rocker_port)
 	return !!rocker_port->bridge_dev;
 }
 
+#define ROCKER_OP_FLAG_REMOVE		BIT(0)
+#define ROCKER_OP_FLAG_NOWAIT		BIT(1)
+#define ROCKER_OP_FLAG_LEARNED		BIT(2)
+#define ROCKER_OP_FLAG_REFRESH		BIT(3)
+
 static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
-				     enum switchdev_trans trans, size_t size)
+				     enum switchdev_trans trans, int flags,
+				     size_t size)
 {
 	struct list_head *elem = NULL;
+	gfp_t gfp_flags = (flags & ROCKER_OP_FLAG_NOWAIT) ?
+			  GFP_ATOMIC : GFP_KERNEL;
 
 	/* If in transaction prepare phase, allocate the memory
 	 * and enqueue it on a per-port list.  If in transaction
@@ -342,7 +350,7 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 
 	switch (trans) {
 	case SWITCHDEV_TRANS_PREPARE:
-		elem = kzalloc(size + sizeof(*elem), GFP_KERNEL);
+		elem = kzalloc(size + sizeof(*elem), gfp_flags);
 		if (!elem)
 			return NULL;
 		list_add_tail(elem, &rocker_port->trans_mem);
@@ -353,7 +361,7 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 		list_del_init(elem);
 		break;
 	case SWITCHDEV_TRANS_NONE:
-		elem = kzalloc(size + sizeof(*elem), GFP_KERNEL);
+		elem = kzalloc(size + sizeof(*elem), gfp_flags);
 		if (elem)
 			INIT_LIST_HEAD(elem);
 		break;
@@ -365,16 +373,17 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 }
 
 static void *rocker_port_kzalloc(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans, size_t size)
+				 enum switchdev_trans trans, int flags,
+				 size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans, size);
+	return __rocker_port_mem_alloc(rocker_port, trans, flags, size);
 }
 
 static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans, size_t n,
-				 size_t size)
+				 enum switchdev_trans trans, int flags,
+				 size_t n, size_t size)
 {
-	return __rocker_port_mem_alloc(rocker_port, trans, n * size);
+	return __rocker_port_mem_alloc(rocker_port, trans, flags, n * size);
 }
 
 static void rocker_port_kfree(enum switchdev_trans trans, const void *mem)
@@ -397,11 +406,13 @@ static void rocker_port_kfree(enum switchdev_trans trans, const void *mem)
 struct rocker_wait {
 	wait_queue_head_t wait;
 	bool done;
+	bool nowait;
 };
 
 static void rocker_wait_reset(struct rocker_wait *wait)
 {
 	wait->done = false;
+	wait->nowait = false;
 }
 
 static void rocker_wait_init(struct rocker_wait *wait)
@@ -411,11 +422,12 @@ static void rocker_wait_init(struct rocker_wait *wait)
 }
 
 static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
-					      enum switchdev_trans trans)
+					      enum switchdev_trans trans,
+					      int flags)
 {
 	struct rocker_wait *wait;
 
-	wait = rocker_port_kzalloc(rocker_port, trans, sizeof(*wait));
+	wait = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*wait));
 	if (!wait)
 		return NULL;
 	rocker_wait_init(wait);
@@ -1386,7 +1398,12 @@ static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
 	spin_lock(&rocker->cmd_ring_lock);
 	while ((desc_info = rocker_desc_tail_get(&rocker->cmd_ring))) {
 		wait = rocker_desc_cookie_ptr_get(desc_info);
-		rocker_wait_wake_up(wait);
+		if (wait->nowait) {
+			rocker_desc_gen_clear(desc_info);
+			rocker_wait_destroy(SWITCHDEV_TRANS_NONE, wait);
+		} else {
+			rocker_wait_wake_up(wait);
+		}
 		credits++;
 	}
 	spin_unlock(&rocker->cmd_ring_lock);
@@ -1437,10 +1454,6 @@ static int rocker_event_link_change(const struct rocker *rocker,
 	return 0;
 }
 
-#define ROCKER_OP_FLAG_REMOVE		BIT(0)
-#define ROCKER_OP_FLAG_LEARNED		BIT(1)
-#define ROCKER_OP_FLAG_REFRESH		BIT(2)
-
 static int rocker_port_fdb(struct rocker_port *rocker_port,
 			   enum switchdev_trans trans,
 			   const unsigned char *addr,
@@ -1595,32 +1608,34 @@ typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
 				    void *priv);
 
 static int rocker_cmd_exec(struct rocker_port *rocker_port,
-			   enum switchdev_trans trans,
+			   enum switchdev_trans trans, int flags,
 			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
 			   rocker_cmd_proc_cb_t process, void *process_priv)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_desc_info *desc_info;
 	struct rocker_wait *wait;
-	unsigned long flags;
+	bool nowait = !!(flags & ROCKER_OP_FLAG_NOWAIT);
+	unsigned long lock_flags;
 	int err;
 
-	wait = rocker_wait_create(rocker_port, trans);
+	wait = rocker_wait_create(rocker_port, trans, flags);
 	if (!wait)
 		return -ENOMEM;
+	wait->nowait = nowait;
 
-	spin_lock_irqsave(&rocker->cmd_ring_lock, flags);
+	spin_lock_irqsave(&rocker->cmd_ring_lock, lock_flags);
 
 	desc_info = rocker_desc_head_get(&rocker->cmd_ring);
 	if (!desc_info) {
-		spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
+		spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
 		err = -EAGAIN;
 		goto out;
 	}
 
 	err = prepare(rocker_port, desc_info, prepare_priv);
 	if (err) {
-		spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
+		spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
 		goto out;
 	}
 
@@ -1629,7 +1644,10 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 	if (trans != SWITCHDEV_TRANS_PREPARE)
 		rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
 
-	spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
+	spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
+
+	if (nowait)
+		return 0;
 
 	if (trans != SWITCHDEV_TRANS_PREPARE)
 		if (!rocker_wait_event_timeout(wait, HZ / 10))
@@ -1859,7 +1877,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_ethtool_proc,
 			       ecmd);
@@ -1868,7 +1886,7 @@ static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_macaddr_proc,
 			       macaddr);
@@ -1877,7 +1895,7 @@ static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
 			       rocker_cmd_set_port_settings_ethtool_prep,
 			       ecmd, NULL, NULL);
 }
@@ -1885,7 +1903,7 @@ static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
 			       rocker_cmd_set_port_settings_macaddr_prep,
 			       macaddr, NULL, NULL);
 }
@@ -1893,7 +1911,7 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
 				    enum switchdev_trans trans)
 {
-	return rocker_cmd_exec(rocker_port, trans,
+	return rocker_cmd_exec(rocker_port, trans, 0,
 			       rocker_cmd_set_port_learning_prep,
 			       NULL, NULL, NULL);
 }
@@ -2409,17 +2427,17 @@ rocker_flow_tbl_find(const struct rocker *rocker,
 }
 
 static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans,
+			       enum switchdev_trans trans, int flags,
 			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_flow_tbl_entry *found;
 	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
-	unsigned long flags;
+	unsigned long lock_flags;
 
 	match->key_crc32 = crc32(~0, &match->key, key_len);
 
-	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+	spin_lock_irqsave(&rocker->flow_tbl_lock, lock_flags);
 
 	found = rocker_flow_tbl_find(rocker, match);
 
@@ -2439,25 +2457,25 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 	if (trans != SWITCHDEV_TRANS_PREPARE)
 		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 
-	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans, rocker_cmd_flow_tbl_add,
-			       found, NULL, NULL);
+	return rocker_cmd_exec(rocker_port, trans, flags,
+			       rocker_cmd_flow_tbl_add, found, NULL, NULL);
 }
 
 static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
-			       enum switchdev_trans trans,
+			       enum switchdev_trans trans, int flags,
 			       struct rocker_flow_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_flow_tbl_entry *found;
 	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
-	unsigned long flags;
+	unsigned long lock_flags;
 	int err = 0;
 
 	match->key_crc32 = crc32(~0, &match->key, key_len);
 
-	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+	spin_lock_irqsave(&rocker->flow_tbl_lock, lock_flags);
 
 	found = rocker_flow_tbl_find(rocker, match);
 
@@ -2467,12 +2485,12 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
 	}
 
-	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
 	rocker_port_kfree(trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans,
+		err = rocker_cmd_exec(rocker_port, trans, flags,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL);
 		rocker_port_kfree(trans, found);
@@ -2486,9 +2504,9 @@ static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
 			      struct rocker_flow_tbl_entry *entry)
 {
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_flow_tbl_del(rocker_port, trans, entry);
+		return rocker_flow_tbl_del(rocker_port, trans, flags, entry);
 	else
-		return rocker_flow_tbl_add(rocker_port, trans, entry);
+		return rocker_flow_tbl_add(rocker_port, trans, flags, entry);
 }
 
 static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
@@ -2498,7 +2516,7 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2520,7 +2538,7 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2547,7 +2565,7 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2587,7 +2605,7 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
 	bool wild = false;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2637,7 +2655,7 @@ static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
 {
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2667,7 +2685,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	u32 priority;
 	struct rocker_flow_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2735,14 +2753,14 @@ static void rocker_group_tbl_entry_free(enum switchdev_trans trans,
 }
 
 static int rocker_group_tbl_add(struct rocker_port *rocker_port,
-				enum switchdev_trans trans,
+				enum switchdev_trans trans, int flags,
 				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_group_tbl_entry *found;
-	unsigned long flags;
+	unsigned long lock_flags;
 
-	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+	spin_lock_irqsave(&rocker->group_tbl_lock, lock_flags);
 
 	found = rocker_group_tbl_find(rocker, match);
 
@@ -2760,22 +2778,22 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	if (trans != SWITCHDEV_TRANS_PREPARE)
 		hash_add(rocker->group_tbl, &found->entry, found->group_id);
 
-	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans, rocker_cmd_group_tbl_add,
-			       found, NULL, NULL);
+	return rocker_cmd_exec(rocker_port, trans, flags,
+			       rocker_cmd_group_tbl_add, found, NULL, NULL);
 }
 
 static int rocker_group_tbl_del(struct rocker_port *rocker_port,
-				enum switchdev_trans trans,
+				enum switchdev_trans trans, int flags,
 				struct rocker_group_tbl_entry *match)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_group_tbl_entry *found;
-	unsigned long flags;
+	unsigned long lock_flags;
 	int err = 0;
 
-	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+	spin_lock_irqsave(&rocker->group_tbl_lock, lock_flags);
 
 	found = rocker_group_tbl_find(rocker, match);
 
@@ -2785,12 +2803,12 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
 	}
 
-	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
 	rocker_group_tbl_entry_free(trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans,
+		err = rocker_cmd_exec(rocker_port, trans, flags,
 				      rocker_cmd_group_tbl_del,
 				      found, NULL, NULL);
 		rocker_group_tbl_entry_free(trans, found);
@@ -2804,9 +2822,9 @@ static int rocker_group_tbl_do(struct rocker_port *rocker_port,
 			       struct rocker_group_tbl_entry *entry)
 {
 	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_group_tbl_del(rocker_port, trans, entry);
+		return rocker_group_tbl_del(rocker_port, trans, flags, entry);
 	else
-		return rocker_group_tbl_add(rocker_port, trans, entry);
+		return rocker_group_tbl_add(rocker_port, trans, flags, entry);
 }
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
@@ -2816,7 +2834,7 @@ static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2833,15 +2851,15 @@ static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = rocker_port_kcalloc(rocker_port, trans, group_count,
-					       sizeof(u32));
+	entry->group_ids = rocker_port_kcalloc(rocker_port, trans, flags,
+					       group_count, sizeof(u32));
 	if (!entry->group_ids) {
 		rocker_port_kfree(trans, entry);
 		return -ENOMEM;
@@ -2868,7 +2886,7 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 {
 	struct rocker_group_tbl_entry *entry;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -2951,7 +2969,7 @@ static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 	bool removing;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -3067,7 +3085,7 @@ static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
 	bool resolved = true;
 	int err = 0;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*entry));
 	if (!entry)
 		return -ENOMEM;
 
@@ -3124,8 +3142,8 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	int err = 0;
 	int i;
 
-	group_ids = rocker_port_kcalloc(rocker_port, trans, rocker->port_count,
-					sizeof(u32));
+	group_ids = rocker_port_kcalloc(rocker_port, trans, flags,
+					rocker->port_count, sizeof(u32));
 	if (!group_ids)
 		return -ENOMEM;
 
@@ -3550,7 +3568,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	lw = rocker_port_kzalloc(rocker_port, trans, sizeof(*lw));
+	lw = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*lw));
 	if (!lw)
 		return -ENOMEM;
 
@@ -3594,7 +3612,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
 	unsigned long lock_flags;
 
-	fdb = rocker_port_kzalloc(rocker_port, trans, sizeof(*fdb));
+	fdb = rocker_port_kzalloc(rocker_port, trans, flags, sizeof(*fdb));
 	if (!fdb)
 		return -ENOMEM;
 
@@ -3632,12 +3650,11 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
-				 enum switchdev_trans trans)
+				 enum switchdev_trans trans, int flags)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_tbl_entry *found;
 	unsigned long lock_flags;
-	int flags = ROCKER_OP_FLAG_REMOVE;
 	struct hlist_node *tmp;
 	int bkt;
 	int err = 0;
@@ -3646,6 +3663,8 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
 	    rocker_port->stp_state == BR_STATE_FORWARDING)
 		return 0;
 
+	flags |= ROCKER_OP_FLAG_REMOVE;
+
 	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
 
 	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
@@ -3702,13 +3721,12 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_fwding(struct rocker_port *rocker_port,
-			      enum switchdev_trans trans)
+			      enum switchdev_trans trans, int flags)
 {
 	bool pop_vlan;
 	u32 out_pport;
 	__be16 vlan_id;
 	u16 vid;
-	int flags = 0;
 	int err;
 
 	/* Port will be forwarding-enabled if its STP state is LEARNING
@@ -3742,12 +3760,12 @@ static int rocker_port_fwding(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_stp_update(struct rocker_port *rocker_port,
-				  enum switchdev_trans trans, u8 state)
+				  enum switchdev_trans trans, int flags,
+				  u8 state)
 {
 	bool want[ROCKER_CTRL_MAX] = { 0, };
 	bool prev_ctrls[ROCKER_CTRL_MAX];
 	u8 prev_state;
-	int flags;
 	int err;
 	int i;
 
@@ -3783,8 +3801,9 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 
 	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
 		if (want[i] != rocker_port->ctrls[i]) {
-			flags = (want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
-			err = rocker_port_ctrl(rocker_port, trans, flags,
+			int ctrl_flags = flags |
+					 (want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
+			err = rocker_port_ctrl(rocker_port, trans, ctrl_flags,
 					       &rocker_ctrls[i]);
 			if (err)
 				goto err_out;
@@ -3792,11 +3811,11 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 		}
 	}
 
-	err = rocker_port_fdb_flush(rocker_port, trans);
+	err = rocker_port_fdb_flush(rocker_port, trans, flags);
 	if (err)
 		goto err_out;
 
-	err = rocker_port_fwding(rocker_port, trans);
+	err = rocker_port_fwding(rocker_port, trans, flags);
 
 err_out:
 	if (trans == SWITCHDEV_TRANS_PREPARE) {
@@ -3808,25 +3827,27 @@ err_out:
 }
 
 static int rocker_port_fwd_enable(struct rocker_port *rocker_port,
-				  enum switchdev_trans trans)
+				  enum switchdev_trans trans, int flags)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will enable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to FORWARDING state */
-	return rocker_port_stp_update(rocker_port, trans, BR_STATE_FORWARDING);
+	return rocker_port_stp_update(rocker_port, trans, flags,
+				      BR_STATE_FORWARDING);
 }
 
 static int rocker_port_fwd_disable(struct rocker_port *rocker_port,
-				   enum switchdev_trans trans)
+				   enum switchdev_trans trans, int flags)
 {
 	if (rocker_port_is_bridged(rocker_port))
 		/* bridge STP will disable port */
 		return 0;
 
 	/* port is not bridged, so simulate going to DISABLED state */
-	return rocker_port_stp_update(rocker_port, trans, BR_STATE_DISABLED);
+	return rocker_port_stp_update(rocker_port, trans, flags,
+				      BR_STATE_DISABLED);
 }
 
 static struct rocker_internal_vlan_tbl_entry *
@@ -3990,7 +4011,7 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
-	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE);
+	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
 	if (err)
 		goto err_fwd_enable;
 
@@ -4017,7 +4038,7 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
-	rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE);
+	rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
 	rocker_port_dma_rings_fini(rocker_port);
@@ -4171,7 +4192,7 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	struct port_name name = { .buf = buf, .len = len };
 	int err;
 
-	err = rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
+	err = rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
 			      &name);
@@ -4265,7 +4286,7 @@ static int rocker_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, attr->trans,
+		err = rocker_port_stp_update(rocker_port, attr->trans, 0,
 					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
@@ -4618,7 +4639,7 @@ rocker_cmd_get_port_stats_ethtool_proc(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
 					     void *priv)
 {
-	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
 			       rocker_cmd_get_port_stats_prep, NULL,
 			       rocker_cmd_get_port_stats_ethtool_proc,
 			       priv);
@@ -5170,7 +5191,8 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 		return err;
 
 	if (rocker_port->dev->flags & IFF_UP)
-		err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE);
+		err = rocker_port_fwd_enable(rocker_port,
+					     SWITCHDEV_TRANS_NONE, 0);
 
 	return err;
 }
-- 
1.7.10.4
