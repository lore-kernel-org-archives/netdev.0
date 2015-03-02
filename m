From: sfeldma@gmail.com
Subject: [PATCH net-next 3/4] rocker: implement IPv4 fib offloading
Date: Mon,  2 Mar 2015 01:29:14 -0800
Message-ID: <1425288555-22598-4-git-send-email-sfeldma@gmail.com>
References: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:37162 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbbCBJaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 04:30:11 -0500
Received: by pdbnh10 with SMTP id nh10so12433289pdb.4
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 01:30:11 -0800 (PST)
In-Reply-To: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The driver implements ndo_switch_fib_ipv4_add/del ops to add/del/mod IPv4
routes to/from switchdev device.  Once a route is added to the device, and the
route's nexthops are resolved to neighbor MAC address, the device will forward
matching pkts rather than the kernel.  This offloads the L3 forwarding path
from the kernel to the device.  Note that control and management planes are
still mananged by Linux; only the data plane is offloaded.  Standard routing
control protocols such as OSPF and BGP run on Linux and manage the kernel's FIB
via standard rtm netlink msgs...nothing changes here.

A new hash table is added to rocker to track neighbors.  The driver listens for
neighbor updates events using netevent notifier NETEVENT_NEIGH_UPDATE.  Any ARP
table updates for ports on this device are recorded in this table.  Routes
installed to the device with nexthops that reference neighbors in this table
are "qualified".  In the case of a route with nexthops not resolved in the
table, the kernel is asked to resolve the nexthop.

The driver uses fib_info->fib_priority for the priority field in rocker's
unicast routing table.

The device can only forward to pkts matching route dst to resolved nexthops.
Currently, the device only supports single-path routes (i.e. routes with one
nexthop).  Equal Cost Multipath (ECMP) route support will be added in followup
patches.

This patch is driver support for unicast IPv4 routing only.  Followup patches
will add driver and infrastructure for IPv6 routing and multicast routing.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c |  517 +++++++++++++++++++++++++++++++---
 net/ipv4/fib_trie.c                  |    2 +-
 2 files changed, 473 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index e5a15a4..f8d8a54 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -32,6 +32,9 @@
 #include <linux/bitops.h>
 #include <net/switchdev.h>
 #include <net/rtnetlink.h>
+#include <net/ip_fib.h>
+#include <net/netevent.h>
+#include <net/arp.h>
 #include <asm-generic/io-64-nonatomic-lo-hi.h>
 #include <generated/utsrelease.h>
 
@@ -111,9 +114,10 @@ struct rocker_flow_tbl_key {
 
 struct rocker_flow_tbl_entry {
 	struct hlist_node entry;
-	u32 ref_count;
+	u32 cmd;
 	u64 cookie;
 	struct rocker_flow_tbl_key key;
+	size_t key_len;
 	u32 key_crc32; /* key */
 };
 
@@ -161,6 +165,16 @@ struct rocker_internal_vlan_tbl_entry {
 	__be16 vlan_id;
 };
 
+struct rocker_neigh_tbl_entry {
+	struct hlist_node entry;
+	__be32 ip_addr; /* key */
+	struct net_device *dev;
+	u32 ref_count;
+	u32 index;
+	u8 eth_dst[ETH_ALEN];
+	bool ttl_check;
+};
+
 struct rocker_desc_info {
 	char *data; /* mapped */
 	size_t data_size;
@@ -234,6 +248,9 @@ struct rocker {
 	unsigned long internal_vlan_bitmap[ROCKER_INTERNAL_VLAN_BITMAP_LEN];
 	DECLARE_HASHTABLE(internal_vlan_tbl, 8);
 	spinlock_t internal_vlan_tbl_lock;
+	DECLARE_HASHTABLE(neigh_tbl, 16);
+	spinlock_t neigh_tbl_lock;
+	u32 neigh_tbl_next_index;
 };
 
 static const u8 zero_mac[ETH_ALEN]   = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
@@ -256,7 +273,6 @@ enum {
 	ROCKER_PRIORITY_VLAN = 1,
 	ROCKER_PRIORITY_TERM_MAC_UCAST = 0,
 	ROCKER_PRIORITY_TERM_MAC_MCAST = 1,
-	ROCKER_PRIORITY_UNICAST_ROUTING = 1,
 	ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT = 1,
 	ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD = 2,
 	ROCKER_PRIORITY_BRIDGING_VLAN = 3,
@@ -1940,8 +1956,7 @@ static int rocker_cmd_flow_tbl_add(struct rocker *rocker,
 	struct rocker_tlv *cmd_info;
 	int err = 0;
 
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
-			       ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD))
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
 		return -EMSGSIZE;
 	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
 	if (!cmd_info)
@@ -1998,8 +2013,7 @@ static int rocker_cmd_flow_tbl_del(struct rocker *rocker,
 	const struct rocker_flow_tbl_entry *entry = priv;
 	struct rocker_tlv *cmd_info;
 
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
-			       ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL))
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
 		return -EMSGSIZE;
 	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
 	if (!cmd_info)
@@ -2168,9 +2182,9 @@ static int rocker_cmd_group_tbl_del(struct rocker *rocker,
 	return 0;
 }
 
-/*****************************************
- * Flow, group, FDB, internal VLAN tables
- *****************************************/
+/***************************************************
+ * Flow, group, FDB, internal VLAN and neigh tables
+ ***************************************************/
 
 static int rocker_init_tbls(struct rocker *rocker)
 {
@@ -2186,6 +2200,9 @@ static int rocker_init_tbls(struct rocker *rocker)
 	hash_init(rocker->internal_vlan_tbl);
 	spin_lock_init(&rocker->internal_vlan_tbl_lock);
 
+	hash_init(rocker->neigh_tbl);
+	spin_lock_init(&rocker->neigh_tbl_lock);
+
 	return 0;
 }
 
@@ -2196,6 +2213,7 @@ static void rocker_free_tbls(struct rocker *rocker)
 	struct rocker_group_tbl_entry *group_entry;
 	struct rocker_fdb_tbl_entry *fdb_entry;
 	struct rocker_internal_vlan_tbl_entry *internal_vlan_entry;
+	struct rocker_neigh_tbl_entry *neigh_entry;
 	struct hlist_node *tmp;
 	int bkt;
 
@@ -2219,16 +2237,22 @@ static void rocker_free_tbls(struct rocker *rocker)
 			   tmp, internal_vlan_entry, entry)
 		hash_del(&internal_vlan_entry->entry);
 	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, flags);
+
+	spin_lock_irqsave(&rocker->neigh_tbl_lock, flags);
+	hash_for_each_safe(rocker->neigh_tbl, bkt, tmp, neigh_entry, entry)
+		hash_del(&neigh_entry->entry);
+	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, flags);
 }
 
 static struct rocker_flow_tbl_entry *
 rocker_flow_tbl_find(struct rocker *rocker, struct rocker_flow_tbl_entry *match)
 {
 	struct rocker_flow_tbl_entry *found;
+	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
 
 	hash_for_each_possible(rocker->flow_tbl, found,
 			       entry, match->key_crc32) {
-		if (memcmp(&found->key, &match->key, sizeof(found->key)) == 0)
+		if (memcmp(&found->key, &match->key, key_len) == 0)
 			return found;
 	}
 
@@ -2241,42 +2265,34 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_flow_tbl_entry *found;
+	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
 	unsigned long flags;
-	bool add_to_hw = false;
-	int err = 0;
 
-	match->key_crc32 = crc32(~0, &match->key, sizeof(match->key));
+	match->key_crc32 = crc32(~0, &match->key, key_len);
 
 	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
 
 	found = rocker_flow_tbl_find(rocker, match);
 
 	if (found) {
-		kfree(match);
+		match->cookie = found->cookie;
+		hash_del(&found->entry);
+		kfree(found);
+		found = match;
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
 	} else {
 		found = match;
 		found->cookie = rocker->flow_tbl_next_cookie++;
-		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
-		add_to_hw = true;
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
 	}
 
-	found->ref_count++;
+	hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
-	if (add_to_hw) {
-		err = rocker_cmd_exec(rocker, rocker_port,
-				      rocker_cmd_flow_tbl_add,
-				      found, NULL, NULL, nowait);
-		if (err) {
-			spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
-			hash_del(&found->entry);
-			spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
-			kfree(found);
-		}
-	}
-
-	return err;
+	return rocker_cmd_exec(rocker, rocker_port,
+			       rocker_cmd_flow_tbl_add,
+			       found, NULL, NULL, nowait);
 }
 
 static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
@@ -2285,29 +2301,26 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_flow_tbl_entry *found;
+	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
 	unsigned long flags;
-	bool del_from_hw = false;
 	int err = 0;
 
-	match->key_crc32 = crc32(~0, &match->key, sizeof(match->key));
+	match->key_crc32 = crc32(~0, &match->key, key_len);
 
 	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
 
 	found = rocker_flow_tbl_find(rocker, match);
 
 	if (found) {
-		found->ref_count--;
-		if (found->ref_count == 0) {
-			hash_del(&found->entry);
-			del_from_hw = true;
-		}
+		hash_del(&found->entry);
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
 	}
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
 	kfree(match);
 
-	if (del_from_hw) {
+	if (found) {
 		err = rocker_cmd_exec(rocker, rocker_port,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL, nowait);
@@ -2467,6 +2480,31 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	return rocker_flow_tbl_do(rocker_port, flags, entry);
 }
 
+static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
+					  __be16 eth_type, __be32 dst,
+					  __be32 dst_mask, u32 priority,
+					  enum rocker_of_dpa_table_id goto_tbl,
+					  u32 group_id, int flags)
+{
+	struct rocker_flow_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING;
+	entry->key.priority = priority;
+	entry->key.ucast_routing.eth_type = eth_type;
+	entry->key.ucast_routing.dst4 = dst;
+	entry->key.ucast_routing.dst4_mask = dst_mask;
+	entry->key.ucast_routing.goto_tbl = goto_tbl;
+	entry->key.ucast_routing.group_id = group_id;
+	entry->key_len = offsetof(struct rocker_flow_tbl_key,
+				  ucast_routing.group_id);
+
+	return rocker_flow_tbl_do(rocker_port, flags, entry);
+}
+
 static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 			       int flags, u32 in_pport,
 			       u32 in_pport_mask,
@@ -2554,7 +2592,6 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_group_tbl_entry *found;
 	unsigned long flags;
-	int err = 0;
 
 	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
 
@@ -2574,12 +2611,9 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
 
-	if (found->cmd)
-		err = rocker_cmd_exec(rocker, rocker_port,
-				      rocker_cmd_group_tbl_add,
-				      found, NULL, NULL, nowait);
-
-	return err;
+	return rocker_cmd_exec(rocker, rocker_port,
+			       rocker_cmd_group_tbl_add,
+			       found, NULL, NULL, nowait);
 }
 
 static int rocker_group_tbl_del(struct rocker_port *rocker_port,
@@ -2675,6 +2709,244 @@ static int rocker_group_l2_flood(struct rocker_port *rocker_port,
 				       group_id);
 }
 
+static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
+				   int flags, u32 index, u8 *src_mac,
+				   u8 *dst_mac, __be16 vlan_id,
+				   bool ttl_check, u32 pport)
+{
+	struct rocker_group_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->group_id = ROCKER_GROUP_L3_UNICAST(index);
+	if (src_mac)
+		ether_addr_copy(entry->l3_unicast.eth_src, src_mac);
+	if (dst_mac)
+		ether_addr_copy(entry->l3_unicast.eth_dst, dst_mac);
+	entry->l3_unicast.vlan_id = vlan_id;
+	entry->l3_unicast.ttl_check = ttl_check;
+	entry->l3_unicast.group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, pport);
+
+	return rocker_group_tbl_do(rocker_port, flags, entry);
+}
+
+static struct rocker_neigh_tbl_entry *
+	rocker_neigh_tbl_find(struct rocker *rocker, __be32 ip_addr)
+{
+	struct rocker_neigh_tbl_entry *found;
+
+	hash_for_each_possible(rocker->neigh_tbl, found, entry, ip_addr)
+		if (found->ip_addr == ip_addr)
+			return found;
+
+	return NULL;
+}
+
+static void _rocker_neigh_add(struct rocker *rocker,
+			      struct rocker_neigh_tbl_entry *entry)
+{
+	entry->index = rocker->neigh_tbl_next_index++;
+	entry->ref_count++;
+	hash_add(rocker->neigh_tbl, &entry->entry, entry->ip_addr);
+}
+
+static void _rocker_neigh_del(struct rocker *rocker,
+			      struct rocker_neigh_tbl_entry *entry)
+{
+	if (--entry->ref_count == 0) {
+		hash_del(&entry->entry);
+		kfree(entry);
+	}
+}
+
+static void _rocker_neigh_update(struct rocker *rocker,
+				 struct rocker_neigh_tbl_entry *entry,
+				 u8 *eth_dst, bool ttl_check)
+{
+	if (eth_dst) {
+		ether_addr_copy(entry->eth_dst, eth_dst);
+		entry->ttl_check = ttl_check;
+	} else {
+		entry->ref_count++;
+	}
+}
+
+static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
+				  int flags, __be32 ip_addr, u8 *eth_dst)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_neigh_tbl_entry *entry;
+	struct rocker_neigh_tbl_entry *found;
+	unsigned long lock_flags;
+	__be16 eth_type = htons(ETH_P_IP);
+	enum rocker_of_dpa_table_id goto_tbl =
+		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	u32 group_id;
+	u32 priority = 0;
+	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
+	bool updating;
+	bool removing;
+	int err = 0;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&rocker->neigh_tbl_lock, lock_flags);
+
+	found = rocker_neigh_tbl_find(rocker, ip_addr);
+
+	updating = found && adding;
+	removing = found && !adding;
+	adding = !found && adding;
+
+	if (adding) {
+		entry->ip_addr = ip_addr;
+		entry->dev = rocker_port->dev;
+		ether_addr_copy(entry->eth_dst, eth_dst);
+		entry->ttl_check = true;
+		_rocker_neigh_add(rocker, entry);
+	} else if (removing) {
+		memcpy(entry, found, sizeof(*entry));
+		_rocker_neigh_del(rocker, found);
+	} else if (updating) {
+		_rocker_neigh_update(rocker, found, eth_dst, true);
+		memcpy(entry, found, sizeof(*entry));
+	} else {
+		err = -ENOENT;
+	}
+
+	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
+
+	if (err)
+		goto err_out;
+
+	/* For each active neighbor, we have an L3 unicast group and
+	 * a /32 route to the neighbor, which uses the L3 unicast
+	 * group.  The L3 unicast group can also be referred to by
+	 * other routes' nexthops.
+	 */
+
+	err = rocker_group_l3_unicast(rocker_port, flags,
+				      entry->index,
+				      rocker_port->dev->dev_addr,
+				      entry->eth_dst,
+				      rocker_port->internal_vlan_id,
+				      entry->ttl_check,
+				      rocker_port->pport);
+	if (err) {
+		netdev_err(rocker_port->dev,
+			   "Error (%d) L3 unicast group index %d\n",
+			   err, entry->index);
+		goto err_out;
+	}
+
+	if (adding || removing) {
+		group_id = ROCKER_GROUP_L3_UNICAST(entry->index);
+		err = rocker_flow_tbl_ucast4_routing(rocker_port,
+						     eth_type, ip_addr,
+						     inet_make_mask(32),
+						     priority, goto_tbl,
+						     group_id, flags);
+
+		if (err)
+			netdev_err(rocker_port->dev,
+				   "Error (%d) /32 unicast route %pI4 group 0x%08x\n",
+				   err, &entry->ip_addr, group_id);
+	}
+
+err_out:
+	if (!adding)
+		kfree(entry);
+
+	return err;
+}
+
+static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
+				    __be32 ip_addr)
+{
+	struct net_device *dev = rocker_port->dev;
+	struct neighbour *n = __ipv4_neigh_lookup(dev, ip_addr);
+	int err = 0;
+
+	if (!n)
+		n = neigh_create(&arp_tbl, &ip_addr, dev);
+	if (!n)
+		return -ENOMEM;
+
+	/* If the neigh is already resolved, then go ahead and
+	 * install the entry, otherwise start the ARP process to
+	 * resolve the neigh.
+	 */
+
+	if (n->nud_state & NUD_VALID)
+		err = rocker_port_ipv4_neigh(rocker_port, 0, ip_addr, n->ha);
+	else
+		neigh_event_send(n, NULL);
+
+	return err;
+}
+
+static int rocker_port_ipv4_nh(struct rocker_port *rocker_port, int flags,
+			       __be32 ip_addr, u32 *index)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_neigh_tbl_entry *entry;
+	struct rocker_neigh_tbl_entry *found;
+	unsigned long lock_flags;
+	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
+	bool updating;
+	bool removing;
+	bool resolved = true;
+	int err = 0;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&rocker->neigh_tbl_lock, lock_flags);
+
+	found = rocker_neigh_tbl_find(rocker, ip_addr);
+	if (found)
+		*index = found->index;
+
+	updating = found && adding;
+	removing = found && !adding;
+	adding = !found && adding;
+
+	if (adding) {
+		entry->ip_addr = ip_addr;
+		entry->dev = rocker_port->dev;
+		_rocker_neigh_add(rocker, entry);
+		*index = entry->index;
+		resolved = false;
+	} else if (removing) {
+		_rocker_neigh_del(rocker, found);
+	} else if (updating) {
+		_rocker_neigh_update(rocker, found, NULL, false);
+		resolved = !is_zero_ether_addr(found->eth_dst);
+	} else {
+		err = -ENOENT;
+	}
+
+	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
+
+	if (!adding)
+		kfree(entry);
+
+	if (err)
+		return err;
+
+	/* Resolved means neigh ip_addr is resolved to neigh mac. */
+
+	if (!resolved)
+		err = rocker_port_ipv4_resolve(rocker_port, ip_addr);
+
+	return err;
+}
+
 static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 					int flags, __be16 vlan_id)
 {
@@ -3429,6 +3701,84 @@ not_found:
 	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, lock_flags);
 }
 
+static int rocker_port_fib_ipv4(struct rocker_port *rocker_port, __be32 dst,
+				int dst_len, struct fib_info *fi, u32 tb_id,
+				int flags)
+{
+	struct fib_nh *nh;
+	__be16 eth_type = htons(ETH_P_IP);
+	__be32 dst_mask = inet_make_mask(dst_len);
+	__be16 internal_vlan_id = rocker_port->internal_vlan_id;
+	u32 priority = fi->fib_priority;
+	enum rocker_of_dpa_table_id goto_tbl =
+		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	u32 group_id;
+	bool nh_on_port;
+	bool has_gw;
+	u32 index;
+	int err;
+
+	/* XXX support ECMP */
+
+	nh = fi->fib_nh;
+	nh_on_port = (fi->fib_dev == rocker_port->dev);
+	has_gw = !!nh->nh_gw;
+
+	if (has_gw && nh_on_port) {
+		err = rocker_port_ipv4_nh(rocker_port, flags,
+					  nh->nh_gw, &index);
+		if (err)
+			return err;
+
+		group_id = ROCKER_GROUP_L3_UNICAST(index);
+	} else {
+		/* Send to CPU for processing */
+		group_id = ROCKER_GROUP_L2_INTERFACE(internal_vlan_id, 0);
+	}
+
+	err = rocker_flow_tbl_ucast4_routing(rocker_port, eth_type, dst,
+					     dst_mask, priority, goto_tbl,
+					     group_id, flags);
+	if (err)
+		netdev_err(rocker_port->dev, "Error (%d) IPv4 route %pI4\n",
+			   err, &dst);
+
+	return err;
+}
+
+static int rocker_port_fib_ipv4_skip(struct net_device *dev,
+				     __be32 dst, int dst_len,
+				     struct fib_info *fi,
+				     u8 tos, u8 type, u32 tb_id)
+{
+	if (fi->fib_flags & RTM_F_CLONED)
+		return -EOPNOTSUPP;
+
+	if (tb_id != RT_TABLE_MAIN && tb_id != RT_TABLE_LOCAL)
+		return -EOPNOTSUPP;
+
+	if (type != RTN_UNICAST && type != RTN_BLACKHOLE &&
+	    type != RTN_UNREACHABLE && type != RTN_LOCAL &&
+	    type != RTN_BROADCAST)
+		return -EOPNOTSUPP;
+
+	if (tb_id == RT_TABLE_MAIN && type != RTN_UNICAST &&
+	    type != RTN_BLACKHOLE && type != RTN_UNREACHABLE)
+		return -EOPNOTSUPP;
+
+	if (tos != 0)
+		return -EOPNOTSUPP;
+
+	if (ipv4_is_loopback(dst))
+		return -EOPNOTSUPP;
+
+	/* XXX not handling ECMP right now */
+	if (fi->fib_nhs != 1)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
 /*****************
  * Net device ops
  *****************/
@@ -3830,6 +4180,36 @@ static int rocker_port_switch_port_stp_update(struct net_device *dev, u8 state)
 	return rocker_port_stp_update(rocker_port, state);
 }
 
+static int rocker_port_switch_fib_ipv4_add(struct net_device *dev,
+					   __be32 dst, int dst_len,
+					   struct fib_info *fi,
+					   u8 tos, u8 type, u32 tb_id)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int flags = 0;
+	int err;
+
+	err = rocker_port_fib_ipv4_skip(dev, dst, dst_len, fi,
+					tos, type, tb_id);
+	if (err)
+		return err;
+
+	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
+				    fi, tb_id, flags);
+}
+
+static int rocker_port_switch_fib_ipv4_del(struct net_device *dev,
+					   __be32 dst, int dst_len,
+					   struct fib_info *fi,
+					   u8 tos, u8 type, u32 tb_id)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int flags = ROCKER_OP_FLAG_REMOVE;
+
+	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
+				    fi, tb_id, flags);
+}
+
 static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_open			= rocker_port_open,
 	.ndo_stop			= rocker_port_stop,
@@ -3844,6 +4224,8 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
 	.ndo_switch_parent_id_get	= rocker_port_switch_parent_id_get,
 	.ndo_switch_port_stp_update	= rocker_port_switch_port_stp_update,
+	.ndo_switch_fib_ipv4_add	= rocker_port_switch_fib_ipv4_add,
+	.ndo_switch_fib_ipv4_del	= rocker_port_switch_fib_ipv4_del,
 };
 
 /********************
@@ -4544,6 +4926,48 @@ static struct notifier_block rocker_netdevice_nb __read_mostly = {
 	.notifier_call = rocker_netdevice_event,
 };
 
+/************************************
+ * Net event notifier event handler
+ ************************************/
+
+static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int flags = (n->nud_state & NUD_VALID) ? 0 : ROCKER_OP_FLAG_REMOVE;
+	__be32 ip_addr = *(__be32 *)n->primary_key;
+
+	return rocker_port_ipv4_neigh(rocker_port, flags, ip_addr, n->ha);
+}
+
+static int rocker_netevent_event(struct notifier_block *unused,
+				 unsigned long event, void *ptr)
+{
+	struct net_device *dev;
+	struct neighbour *n = ptr;
+	int err;
+
+	switch (event) {
+	case NETEVENT_NEIGH_UPDATE:
+		if (n->tbl != &arp_tbl)
+			return NOTIFY_DONE;
+		dev = n->dev;
+		if (!rocker_port_dev_check(dev))
+			return NOTIFY_DONE;
+		err = rocker_neigh_update(dev, n);
+		if (err)
+			netdev_warn(dev,
+				    "failed to handle neigh update (err %d)\n",
+				    err);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rocker_netevent_nb __read_mostly = {
+	.notifier_call = rocker_netevent_event,
+};
+
 /***********************
  * Module init and exit
  ***********************/
@@ -4553,18 +4977,21 @@ static int __init rocker_module_init(void)
 	int err;
 
 	register_netdevice_notifier(&rocker_netdevice_nb);
+	register_netevent_notifier(&rocker_netevent_nb);
 	err = pci_register_driver(&rocker_pci_driver);
 	if (err)
 		goto err_pci_register_driver;
 	return 0;
 
 err_pci_register_driver:
+	unregister_netdevice_notifier(&rocker_netevent_nb);
 	unregister_netdevice_notifier(&rocker_netdevice_nb);
 	return err;
 }
 
 static void __exit rocker_module_exit(void)
 {
+	unregister_netevent_notifier(&rocker_netevent_nb);
 	unregister_netdevice_notifier(&rocker_netdevice_nb);
 	pci_unregister_driver(&rocker_pci_driver);
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b834e9c..90cd812 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1166,7 +1166,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 							 new_fa->fa_tos,
 							 cfg->fc_type,
 							 tb->tb_id);
-			if (err && err != -EOPNOTSUPP) {
+			if (err) {
 				kmem_cache_free(fn_alias_kmem, new_fa);
 				goto out;
 			}
-- 
1.7.10.4
