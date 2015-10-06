From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 13/14] rocker: move OF-DPA stuff into separate file
Date: Tue,  6 Oct 2015 09:51:52 +0200
Message-ID: <1444117913-10386-14-git-send-email-jiri@resnulli.us>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33092 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbbJFHwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 03:52:15 -0400
Received: by wiclk2 with SMTP id lk2so153988390wic.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 00:52:13 -0700 (PDT)
In-Reply-To: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Carve out OF-DPA would specific code from the common file to the world
file. This change required struct rocker and struct rocker_port split
into world specific struct ofdpa and struct ofdpa_port. Along with this
the world specific functions and defines were renamed from prefix
"rocker_" to "ofdpa_".

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h       |   23 +
 drivers/net/ethernet/rocker/rocker_main.c  | 3117 ++--------------------------
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 2900 ++++++++++++++++++++++++++
 3 files changed, 3066 insertions(+), 2974 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 496fe8f..8b99d55 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -29,8 +29,31 @@ struct rocker_desc_info {
 };
 
 struct rocker;
+
+unsigned int rocker_port_count_get(struct rocker *rocker);
+struct rocker_port *rocker_port_get(struct rocker *rocker, int port_index);
+
 struct rocker_port;
 
+struct net_device *rocker_port_netdev_get(struct rocker_port *rocker_port);
+void *rocker_port_world_priv_get(struct rocker_port *rocker_port);
+u32 rocker_port_pport_get(struct rocker_port *rocker_port);
+
+typedef int (*rocker_cmd_prep_cb_t)(const struct rocker_port *rocker_port,
+				    struct rocker_desc_info *desc_info,
+				    void *priv);
+
+typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
+				    const struct rocker_desc_info *desc_info,
+				    void *priv);
+
+int rocker_cmd_exec(struct rocker_port *rocker_port, bool nowait,
+		    rocker_cmd_prep_cb_t prepare, void *prepare_priv,
+		    rocker_cmd_proc_cb_t process, void *process_priv);
+
+int rocker_port_set_learning(struct rocker_port *rocker_port,
+			     bool learning);
+
 struct rocker_world_ops {
 	const char *kind;
 	size_t priv_size;
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index a1ad954..a2fd7a6 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1,6 +1,6 @@
 /*
  * drivers/net/ethernet/rocker/rocker_main.c - Rocker switch device driver
- * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014-2015 Jiri Pirko <jiri@resnulli.us>
  * Copyright (c) 2014 Scott Feldman <sfeldma@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -16,12 +16,9 @@
 #include <linux/sched.h>
 #include <linux/wait.h>
 #include <linux/spinlock.h>
-#include <linux/hashtable.h>
-#include <linux/crc32.h>
 #include <linux/sort.h>
 #include <linux/random.h>
 #include <linux/netdevice.h>
-#include <linux/inetdevice.h>
 #include <linux/skbuff.h>
 #include <linux/socket.h>
 #include <linux/etherdevice.h>
@@ -33,7 +30,6 @@
 #include <linux/ctype.h>
 #include <net/switchdev.h>
 #include <net/rtnetlink.h>
-#include <net/ip_fib.h>
 #include <net/netevent.h>
 #include <net/arp.h>
 #include <asm-generic/io-64-nonatomic-lo-hi.h>
@@ -50,135 +46,6 @@ static const struct pci_device_id rocker_pci_id_table[] = {
 	{0, }
 };
 
-struct rocker_flow_tbl_key {
-	u32 priority;
-	enum rocker_of_dpa_table_id tbl_id;
-	union {
-		struct {
-			u32 in_pport;
-			u32 in_pport_mask;
-			enum rocker_of_dpa_table_id goto_tbl;
-		} ig_port;
-		struct {
-			u32 in_pport;
-			__be16 vlan_id;
-			__be16 vlan_id_mask;
-			enum rocker_of_dpa_table_id goto_tbl;
-			bool untagged;
-			__be16 new_vlan_id;
-		} vlan;
-		struct {
-			u32 in_pport;
-			u32 in_pport_mask;
-			__be16 eth_type;
-			u8 eth_dst[ETH_ALEN];
-			u8 eth_dst_mask[ETH_ALEN];
-			__be16 vlan_id;
-			__be16 vlan_id_mask;
-			enum rocker_of_dpa_table_id goto_tbl;
-			bool copy_to_cpu;
-		} term_mac;
-		struct {
-			__be16 eth_type;
-			__be32 dst4;
-			__be32 dst4_mask;
-			enum rocker_of_dpa_table_id goto_tbl;
-			u32 group_id;
-		} ucast_routing;
-		struct {
-			u8 eth_dst[ETH_ALEN];
-			u8 eth_dst_mask[ETH_ALEN];
-			int has_eth_dst;
-			int has_eth_dst_mask;
-			__be16 vlan_id;
-			u32 tunnel_id;
-			enum rocker_of_dpa_table_id goto_tbl;
-			u32 group_id;
-			bool copy_to_cpu;
-		} bridge;
-		struct {
-			u32 in_pport;
-			u32 in_pport_mask;
-			u8 eth_src[ETH_ALEN];
-			u8 eth_src_mask[ETH_ALEN];
-			u8 eth_dst[ETH_ALEN];
-			u8 eth_dst_mask[ETH_ALEN];
-			__be16 eth_type;
-			__be16 vlan_id;
-			__be16 vlan_id_mask;
-			u8 ip_proto;
-			u8 ip_proto_mask;
-			u8 ip_tos;
-			u8 ip_tos_mask;
-			u32 group_id;
-		} acl;
-	};
-};
-
-struct rocker_flow_tbl_entry {
-	struct hlist_node entry;
-	u32 cmd;
-	u64 cookie;
-	struct rocker_flow_tbl_key key;
-	size_t key_len;
-	u32 key_crc32; /* key */
-};
-
-struct rocker_group_tbl_entry {
-	struct hlist_node entry;
-	u32 cmd;
-	u32 group_id; /* key */
-	u16 group_count;
-	u32 *group_ids;
-	union {
-		struct {
-			u8 pop_vlan;
-		} l2_interface;
-		struct {
-			u8 eth_src[ETH_ALEN];
-			u8 eth_dst[ETH_ALEN];
-			__be16 vlan_id;
-			u32 group_id;
-		} l2_rewrite;
-		struct {
-			u8 eth_src[ETH_ALEN];
-			u8 eth_dst[ETH_ALEN];
-			__be16 vlan_id;
-			bool ttl_check;
-			u32 group_id;
-		} l3_unicast;
-	};
-};
-
-struct rocker_fdb_tbl_entry {
-	struct hlist_node entry;
-	u32 key_crc32; /* key */
-	bool learned;
-	unsigned long touched;
-	struct rocker_fdb_tbl_key {
-		struct rocker_port *rocker_port;
-		u8 addr[ETH_ALEN];
-		__be16 vlan_id;
-	} key;
-};
-
-struct rocker_internal_vlan_tbl_entry {
-	struct hlist_node entry;
-	int ifindex; /* key */
-	u32 ref_count;
-	__be16 vlan_id;
-};
-
-struct rocker_neigh_tbl_entry {
-	struct hlist_node entry;
-	__be32 ip_addr; /* key */
-	struct net_device *dev;
-	u32 ref_count;
-	u32 index;
-	u8 eth_dst[ETH_ALEN];
-	bool ttl_check;
-};
-
 struct rocker_dma_ring_info {
 	size_t size;
 	u32 head;
@@ -189,43 +56,34 @@ struct rocker_dma_ring_info {
 	unsigned int type;
 };
 
-struct rocker;
-
-enum {
-	ROCKER_CTRL_LINK_LOCAL_MCAST,
-	ROCKER_CTRL_LOCAL_ARP,
-	ROCKER_CTRL_IPV4_MCAST,
-	ROCKER_CTRL_IPV6_MCAST,
-	ROCKER_CTRL_DFLT_BRIDGING,
-	ROCKER_CTRL_DFLT_OVS,
-	ROCKER_CTRL_MAX,
-};
-
-#define ROCKER_INTERNAL_VLAN_ID_BASE	0x0f00
-#define ROCKER_N_INTERNAL_VLANS		255
-#define ROCKER_VLAN_BITMAP_LEN		BITS_TO_LONGS(VLAN_N_VID)
-#define ROCKER_INTERNAL_VLAN_BITMAP_LEN	BITS_TO_LONGS(ROCKER_N_INTERNAL_VLANS)
-
 struct rocker_port {
 	struct net_device *dev;
-	struct net_device *bridge_dev;
 	struct rocker *rocker;
 	struct rocker_world *world;
 	void *world_port_priv;
 	unsigned int port_number;
 	u32 pport;
-	__be16 internal_vlan_id;
-	int stp_state;
-	u32 brport_flags;
-	unsigned long ageing_time;
-	bool ctrls[ROCKER_CTRL_MAX];
-	unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
 	struct napi_struct napi_tx;
 	struct napi_struct napi_rx;
 	struct rocker_dma_ring_info tx_ring;
 	struct rocker_dma_ring_info rx_ring;
 };
 
+struct net_device *rocker_port_netdev_get(struct rocker_port *rocker_port)
+{
+	return rocker_port->dev;
+}
+
+void *rocker_port_world_priv_get(struct rocker_port *rocker_port)
+{
+	return rocker_port->world_port_priv;
+}
+
+u32 rocker_port_pport_get(struct rocker_port *rocker_port)
+{
+	return rocker_port->pport;
+}
+
 struct rocker {
 	struct pci_dev *pdev;
 	u8 __iomem *hw_addr;
@@ -239,166 +97,16 @@ struct rocker {
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
 	struct list_head worlds;
-	DECLARE_HASHTABLE(flow_tbl, 16);
-	spinlock_t flow_tbl_lock;		/* for flow tbl accesses */
-	u64 flow_tbl_next_cookie;
-	DECLARE_HASHTABLE(group_tbl, 16);
-	spinlock_t group_tbl_lock;		/* for group tbl accesses */
-	struct timer_list fdb_cleanup_timer;
-	DECLARE_HASHTABLE(fdb_tbl, 16);
-	spinlock_t fdb_tbl_lock;		/* for fdb tbl accesses */
-	unsigned long internal_vlan_bitmap[ROCKER_INTERNAL_VLAN_BITMAP_LEN];
-	DECLARE_HASHTABLE(internal_vlan_tbl, 8);
-	spinlock_t internal_vlan_tbl_lock;	/* for vlan tbl accesses */
-	DECLARE_HASHTABLE(neigh_tbl, 16);
-	spinlock_t neigh_tbl_lock;		/* for neigh tbl accesses */
-	u32 neigh_tbl_next_index;
-};
-
-static const u8 zero_mac[ETH_ALEN]   = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
-static const u8 ff_mac[ETH_ALEN]     = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
-static const u8 ll_mac[ETH_ALEN]     = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
-static const u8 ll_mask[ETH_ALEN]    = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0 };
-static const u8 mcast_mac[ETH_ALEN]  = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
-static const u8 ipv4_mcast[ETH_ALEN] = { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x00 };
-static const u8 ipv4_mask[ETH_ALEN]  = { 0xff, 0xff, 0xff, 0x80, 0x00, 0x00 };
-static const u8 ipv6_mcast[ETH_ALEN] = { 0x33, 0x33, 0x00, 0x00, 0x00, 0x00 };
-static const u8 ipv6_mask[ETH_ALEN]  = { 0xff, 0xff, 0x00, 0x00, 0x00, 0x00 };
-
-/* Rocker priority levels for flow table entries.  Higher
- * priority match takes precedence over lower priority match.
- */
-
-enum {
-	ROCKER_PRIORITY_UNKNOWN = 0,
-	ROCKER_PRIORITY_IG_PORT = 1,
-	ROCKER_PRIORITY_VLAN = 1,
-	ROCKER_PRIORITY_TERM_MAC_UCAST = 0,
-	ROCKER_PRIORITY_TERM_MAC_MCAST = 1,
-	ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT = 1,
-	ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD = 2,
-	ROCKER_PRIORITY_BRIDGING_VLAN = 3,
-	ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_EXACT = 1,
-	ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_WILD = 2,
-	ROCKER_PRIORITY_BRIDGING_TENANT = 3,
-	ROCKER_PRIORITY_ACL_CTRL = 3,
-	ROCKER_PRIORITY_ACL_NORMAL = 2,
-	ROCKER_PRIORITY_ACL_DFLT = 1,
 };
 
-static bool rocker_vlan_id_is_internal(__be16 vlan_id)
-{
-	u16 start = ROCKER_INTERNAL_VLAN_ID_BASE;
-	u16 end = 0xffe;
-	u16 _vlan_id = ntohs(vlan_id);
-
-	return (_vlan_id >= start && _vlan_id <= end);
-}
-
-static __be16 rocker_port_vid_to_vlan(const struct rocker_port *rocker_port,
-				      u16 vid, bool *pop_vlan)
-{
-	__be16 vlan_id;
-
-	if (pop_vlan)
-		*pop_vlan = false;
-	vlan_id = htons(vid);
-	if (!vlan_id) {
-		vlan_id = rocker_port->internal_vlan_id;
-		if (pop_vlan)
-			*pop_vlan = true;
-	}
-
-	return vlan_id;
-}
-
-static u16 rocker_port_vlan_to_vid(const struct rocker_port *rocker_port,
-				   __be16 vlan_id)
-{
-	if (rocker_vlan_id_is_internal(vlan_id))
-		return 0;
-
-	return ntohs(vlan_id);
-}
-
-static bool rocker_port_is_bridged(const struct rocker_port *rocker_port)
-{
-	return rocker_port->bridge_dev &&
-	       netif_is_bridge_master(rocker_port->bridge_dev);
-}
-
-static bool rocker_port_is_ovsed(const struct rocker_port *rocker_port)
-{
-	return rocker_port->bridge_dev &&
-	       netif_is_ovs_master(rocker_port->bridge_dev);
-}
-
-#define ROCKER_OP_FLAG_REMOVE		BIT(0)
-#define ROCKER_OP_FLAG_NOWAIT		BIT(1)
-#define ROCKER_OP_FLAG_LEARNED		BIT(2)
-#define ROCKER_OP_FLAG_REFRESH		BIT(3)
-
-static bool rocker_flags_nowait(int flags)
-{
-	return flags & ROCKER_OP_FLAG_NOWAIT;
-}
-
-static void *__rocker_mem_alloc(struct switchdev_trans *trans, int flags,
-				size_t size)
-{
-	struct switchdev_trans_item *elem = NULL;
-	gfp_t gfp_flags = (flags & ROCKER_OP_FLAG_NOWAIT) ?
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
-static void *rocker_kzalloc(struct switchdev_trans *trans, int flags,
-			    size_t size)
-{
-	return __rocker_mem_alloc(trans, flags, size);
-}
-
-static void *rocker_kcalloc(struct switchdev_trans *trans, int flags,
-			    size_t n, size_t size)
+unsigned int rocker_port_count_get(struct rocker *rocker)
 {
-	return __rocker_mem_alloc(trans, flags, n * size);
+	return rocker->port_count;
 }
 
-static void rocker_kfree(struct switchdev_trans *trans, const void *mem)
+struct rocker_port *rocker_port_get(struct rocker *rocker, int port_index)
 {
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
+	return rocker->ports[port_index];
 }
 
 struct rocker_wait {
@@ -1291,10 +999,6 @@ static int rocker_event_link_change(const struct rocker *rocker,
 	return 0;
 }
 
-static int rocker_port_fdb(struct rocker_port *rocker_port,
-			   struct switchdev_trans *trans,
-			   const unsigned char *addr,
-			   __be16 vlan_id, int flags);
 static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
 					      const unsigned char *addr,
 					      __be16 vlan_id);
@@ -1306,9 +1010,7 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 	unsigned int port_number;
 	struct rocker_port *rocker_port;
 	const unsigned char *addr;
-	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_LEARNED;
 	__be16 vlan_id;
-	int err;
 
 	rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_MAC_VLAN_MAX, info);
 	if (!attrs[ROCKER_TLV_EVENT_MAC_VLAN_PPORT] ||
@@ -1324,16 +1026,7 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 		return -EINVAL;
 
 	rocker_port = rocker->ports[port_number];
-
-	err = rocker_world_port_ev_mac_vlan_seen(rocker_port, addr, vlan_id);
-	if (err)
-		return err;
-
-	if (rocker_port->stp_state != BR_STATE_LEARNING &&
-	    rocker_port->stp_state != BR_STATE_FORWARDING)
-		return 0;
-
-	return rocker_port_fdb(rocker_port, NULL, addr, vlan_id, flags);
+	return rocker_world_port_ev_mac_vlan_seen(rocker_port, addr, vlan_id);
 }
 
 static int rocker_event_process(const struct rocker *rocker,
@@ -1409,17 +1102,9 @@ static irqreturn_t rocker_rx_irq_handler(int irq, void *dev_id)
  * Command interface
  ********************/
 
-typedef int (*rocker_cmd_prep_cb_t)(const struct rocker_port *rocker_port,
-				    struct rocker_desc_info *desc_info,
-				    void *priv);
-
-typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
-				    const struct rocker_desc_info *desc_info,
-				    void *priv);
-
-static int rocker_cmd_exec(struct rocker_port *rocker_port, bool nowait,
-			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
-			   rocker_cmd_proc_cb_t process, void *process_priv)
+int rocker_cmd_exec(struct rocker_port *rocker_port, bool nowait,
+		    rocker_cmd_prep_cb_t prepare, void *prepare_priv,
+		    rocker_cmd_proc_cb_t process, void *process_priv)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_desc_info *desc_info;
@@ -1765,8 +1450,8 @@ static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
 			       &mtu, NULL, NULL);
 }
 
-static int rocker_port_set_learning(struct rocker_port *rocker_port,
-				    bool learning)
+int rocker_port_set_learning(struct rocker_port *rocker_port,
+			     bool learning)
 {
 	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_set_port_learning_prep,
@@ -1781,542 +1466,110 @@ static int rocker_cmd_set_port_settings_mode(struct rocker_port *rocker_port,
 			       &mode, NULL, NULL);
 }
 
-static int
-rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
-				const struct rocker_flow_tbl_entry *entry)
-{
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
-			       entry->key.ig_port.in_pport))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
-			       entry->key.ig_port.in_pport_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
-			       entry->key.ig_port.goto_tbl))
-		return -EMSGSIZE;
+/**********************
+ * Worlds manipulation
+ **********************/
 
-	return 0;
-}
+static struct rocker_world_ops *rocker_world_ops[] = {
+	&rocker_ofdpa_ops,
+};
 
-static int
-rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
-			     const struct rocker_flow_tbl_entry *entry)
-{
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
-			       entry->key.vlan.in_pport))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-				entry->key.vlan.vlan_id))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
-				entry->key.vlan.vlan_id_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
-			       entry->key.vlan.goto_tbl))
-		return -EMSGSIZE;
-	if (entry->key.vlan.untagged &&
-	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_NEW_VLAN_ID,
-				entry->key.vlan.new_vlan_id))
-		return -EMSGSIZE;
+#define ROCKER_WORLD_OPS_LEN ARRAY_SIZE(rocker_world_ops)
+#define ROCKER_DEFAULT_WORLD_OPS rocker_world_ops[0]
 
-	return 0;
-}
+struct rocker_world {
+	struct list_head list;
+	const struct rocker_world_ops *ops;
+	unsigned int ref;
+	unsigned long priv[0];
+};
 
-static int
-rocker_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
-				 const struct rocker_flow_tbl_entry *entry)
+static struct rocker_world *__rocker_world_find(struct rocker *rocker,
+						const struct rocker_world_ops *ops)
 {
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
-			       entry->key.term_mac.in_pport))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
-			       entry->key.term_mac.in_pport_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
-				entry->key.term_mac.eth_type))
-		return -EMSGSIZE;
-	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
-			   ETH_ALEN, entry->key.term_mac.eth_dst))
-		return -EMSGSIZE;
-	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
-			   ETH_ALEN, entry->key.term_mac.eth_dst_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-				entry->key.term_mac.vlan_id))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
-				entry->key.term_mac.vlan_id_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
-			       entry->key.term_mac.goto_tbl))
-		return -EMSGSIZE;
-	if (entry->key.term_mac.copy_to_cpu &&
-	    rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_COPY_CPU_ACTION,
-			      entry->key.term_mac.copy_to_cpu))
-		return -EMSGSIZE;
+	struct rocker_world *world;
 
-	return 0;
+	list_for_each_entry(world, &rocker->worlds, list) {
+		if (world->ops == ops)
+			return world;
+	}
+	return NULL;
 }
 
-static int
-rocker_cmd_flow_tbl_add_ucast_routing(struct rocker_desc_info *desc_info,
-				      const struct rocker_flow_tbl_entry *entry)
+static int rocker_world_init(struct rocker *rocker, struct rocker_world *world)
 {
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
-				entry->key.ucast_routing.eth_type))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be32(desc_info, ROCKER_TLV_OF_DPA_DST_IP,
-				entry->key.ucast_routing.dst4))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be32(desc_info, ROCKER_TLV_OF_DPA_DST_IP_MASK,
-				entry->key.ucast_routing.dst4_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
-			       entry->key.ucast_routing.goto_tbl))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
-			       entry->key.ucast_routing.group_id))
-		return -EMSGSIZE;
-
-	return 0;
+	if (!world->ops->init)
+		return 0;
+	return world->ops->init(rocker, world->priv);
 }
 
-static int
-rocker_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
-			       const struct rocker_flow_tbl_entry *entry)
+static void rocker_world_fini(struct rocker *rocker, struct rocker_world *world)
 {
-	if (entry->key.bridge.has_eth_dst &&
-	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
-			   ETH_ALEN, entry->key.bridge.eth_dst))
-		return -EMSGSIZE;
-	if (entry->key.bridge.has_eth_dst_mask &&
-	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
-			   ETH_ALEN, entry->key.bridge.eth_dst_mask))
-		return -EMSGSIZE;
-	if (entry->key.bridge.vlan_id &&
-	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-				entry->key.bridge.vlan_id))
-		return -EMSGSIZE;
-	if (entry->key.bridge.tunnel_id &&
-	    rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_TUNNEL_ID,
-			       entry->key.bridge.tunnel_id))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
-			       entry->key.bridge.goto_tbl))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
-			       entry->key.bridge.group_id))
-		return -EMSGSIZE;
-	if (entry->key.bridge.copy_to_cpu &&
-	    rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_COPY_CPU_ACTION,
-			      entry->key.bridge.copy_to_cpu))
-		return -EMSGSIZE;
-
-	return 0;
+	if (!world->ops->fini)
+		return;
+	return world->ops->fini(world->priv);
 }
 
-static int
-rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
-			    const struct rocker_flow_tbl_entry *entry)
+static int rocker_world_get(struct rocker_port *rocker_port,
+			    const struct rocker_world_ops *ops)
 {
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
-			       entry->key.acl.in_pport))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
-			       entry->key.acl.in_pport_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
-			   ETH_ALEN, entry->key.acl.eth_src))
-		return -EMSGSIZE;
-	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC_MASK,
-			   ETH_ALEN, entry->key.acl.eth_src_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
-			   ETH_ALEN, entry->key.acl.eth_dst))
-		return -EMSGSIZE;
-	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
-			   ETH_ALEN, entry->key.acl.eth_dst_mask))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
-				entry->key.acl.eth_type))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-				entry->key.acl.vlan_id))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
-				entry->key.acl.vlan_id_mask))
-		return -EMSGSIZE;
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_world *world = __rocker_world_find(rocker, ops);
+	int err;
 
-	switch (ntohs(entry->key.acl.eth_type)) {
-	case ETH_P_IP:
-	case ETH_P_IPV6:
-		if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_IP_PROTO,
-				      entry->key.acl.ip_proto))
-			return -EMSGSIZE;
-		if (rocker_tlv_put_u8(desc_info,
-				      ROCKER_TLV_OF_DPA_IP_PROTO_MASK,
-				      entry->key.acl.ip_proto_mask))
-			return -EMSGSIZE;
-		if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_IP_DSCP,
-				      entry->key.acl.ip_tos & 0x3f))
-			return -EMSGSIZE;
-		if (rocker_tlv_put_u8(desc_info,
-				      ROCKER_TLV_OF_DPA_IP_DSCP_MASK,
-				      entry->key.acl.ip_tos_mask & 0x3f))
-			return -EMSGSIZE;
-		if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_IP_ECN,
-				      (entry->key.acl.ip_tos & 0xc0) >> 6))
-			return -EMSGSIZE;
-		if (rocker_tlv_put_u8(desc_info,
-				      ROCKER_TLV_OF_DPA_IP_ECN_MASK,
-				      (entry->key.acl.ip_tos_mask & 0xc0) >> 6))
-			return -EMSGSIZE;
-		break;
-	}
+	if (world)
+		goto ref_inc;
+	world = kzalloc(sizeof(*world) + ops->priv_size, GFP_KERNEL);
+	if (!world)
+		return -ENOMEM;
+	world->ops = ops;
 
-	if (entry->key.acl.group_id != ROCKER_GROUP_NONE &&
-	    rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
-			       entry->key.acl.group_id))
-		return -EMSGSIZE;
+	err = rocker_world_init(rocker, world);
+	if (err)
+		goto err_world_init;
 
+	list_add_tail(&world->list, &rocker->worlds);
+ref_inc:
+	world->ref++;
+	rocker_port->world = world;
 	return 0;
+
+err_world_init:
+	kfree(world);
+	return err;
 }
 
-static int rocker_cmd_flow_tbl_add(const struct rocker_port *rocker_port,
-				   struct rocker_desc_info *desc_info,
-				   void *priv)
+static void rocker_world_put(struct rocker_port *rocker_port)
 {
-	const struct rocker_flow_tbl_entry *entry = priv;
-	struct rocker_tlv *cmd_info;
-	int err = 0;
-
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
-		return -EMSGSIZE;
-	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
-	if (!cmd_info)
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_TABLE_ID,
-			       entry->key.tbl_id))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_PRIORITY,
-			       entry->key.priority))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_HARDTIME, 0))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u64(desc_info, ROCKER_TLV_OF_DPA_COOKIE,
-			       entry->cookie))
-		return -EMSGSIZE;
-
-	switch (entry->key.tbl_id) {
-	case ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT:
-		err = rocker_cmd_flow_tbl_add_ig_port(desc_info, entry);
-		break;
-	case ROCKER_OF_DPA_TABLE_ID_VLAN:
-		err = rocker_cmd_flow_tbl_add_vlan(desc_info, entry);
-		break;
-	case ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC:
-		err = rocker_cmd_flow_tbl_add_term_mac(desc_info, entry);
-		break;
-	case ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING:
-		err = rocker_cmd_flow_tbl_add_ucast_routing(desc_info, entry);
-		break;
-	case ROCKER_OF_DPA_TABLE_ID_BRIDGING:
-		err = rocker_cmd_flow_tbl_add_bridge(desc_info, entry);
-		break;
-	case ROCKER_OF_DPA_TABLE_ID_ACL_POLICY:
-		err = rocker_cmd_flow_tbl_add_acl(desc_info, entry);
-		break;
-	default:
-		err = -ENOTSUPP;
-		break;
-	}
-
-	if (err)
-		return err;
-
-	rocker_tlv_nest_end(desc_info, cmd_info);
+	struct rocker_world *world = rocker_port->world;
+	struct rocker *rocker = rocker_port->rocker;
 
-	return 0;
+	world->ref--;
+	if (world->ref)
+		return;
+	list_del(&world->list);
+	rocker_world_fini(rocker, world);
+	kfree(world);
+	rocker_port->world = NULL;
 }
 
-static int rocker_cmd_flow_tbl_del(const struct rocker_port *rocker_port,
-				   struct rocker_desc_info *desc_info,
-				   void *priv)
+static int rocker_world_port_init(struct rocker_port *rocker_port)
 {
-	const struct rocker_flow_tbl_entry *entry = priv;
-	struct rocker_tlv *cmd_info;
-
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
-		return -EMSGSIZE;
-	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
-	if (!cmd_info)
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u64(desc_info, ROCKER_TLV_OF_DPA_COOKIE,
-			       entry->cookie))
-		return -EMSGSIZE;
-	rocker_tlv_nest_end(desc_info, cmd_info);
+	struct rocker_world *world = rocker_port->world;
 
-	return 0;
+	if (!world->ops->port_init)
+		return 0;
+	return world->ops->port_init(rocker_port, world->priv,
+				     rocker_port->world_port_priv);
 }
 
-static int
-rocker_cmd_group_tbl_add_l2_interface(struct rocker_desc_info *desc_info,
-				      struct rocker_group_tbl_entry *entry)
+static void rocker_world_port_fini(struct rocker_port *rocker_port)
 {
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_OUT_PPORT,
-			       ROCKER_GROUP_PORT_GET(entry->group_id)))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_POP_VLAN,
-			      entry->l2_interface.pop_vlan))
-		return -EMSGSIZE;
+	struct rocker_world *world = rocker_port->world;
 
-	return 0;
-}
-
-static int
-rocker_cmd_group_tbl_add_l2_rewrite(struct rocker_desc_info *desc_info,
-				    const struct rocker_group_tbl_entry *entry)
-{
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID_LOWER,
-			       entry->l2_rewrite.group_id))
-		return -EMSGSIZE;
-	if (!is_zero_ether_addr(entry->l2_rewrite.eth_src) &&
-	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
-			   ETH_ALEN, entry->l2_rewrite.eth_src))
-		return -EMSGSIZE;
-	if (!is_zero_ether_addr(entry->l2_rewrite.eth_dst) &&
-	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
-			   ETH_ALEN, entry->l2_rewrite.eth_dst))
-		return -EMSGSIZE;
-	if (entry->l2_rewrite.vlan_id &&
-	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-				entry->l2_rewrite.vlan_id))
-		return -EMSGSIZE;
-
-	return 0;
-}
-
-static int
-rocker_cmd_group_tbl_add_group_ids(struct rocker_desc_info *desc_info,
-				   const struct rocker_group_tbl_entry *entry)
-{
-	int i;
-	struct rocker_tlv *group_ids;
-
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GROUP_COUNT,
-			       entry->group_count))
-		return -EMSGSIZE;
-
-	group_ids = rocker_tlv_nest_start(desc_info,
-					  ROCKER_TLV_OF_DPA_GROUP_IDS);
-	if (!group_ids)
-		return -EMSGSIZE;
-
-	for (i = 0; i < entry->group_count; i++)
-		/* Note TLV array is 1-based */
-		if (rocker_tlv_put_u32(desc_info, i + 1, entry->group_ids[i]))
-			return -EMSGSIZE;
-
-	rocker_tlv_nest_end(desc_info, group_ids);
-
-	return 0;
-}
-
-static int
-rocker_cmd_group_tbl_add_l3_unicast(struct rocker_desc_info *desc_info,
-				    const struct rocker_group_tbl_entry *entry)
-{
-	if (!is_zero_ether_addr(entry->l3_unicast.eth_src) &&
-	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
-			   ETH_ALEN, entry->l3_unicast.eth_src))
-		return -EMSGSIZE;
-	if (!is_zero_ether_addr(entry->l3_unicast.eth_dst) &&
-	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
-			   ETH_ALEN, entry->l3_unicast.eth_dst))
-		return -EMSGSIZE;
-	if (entry->l3_unicast.vlan_id &&
-	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-				entry->l3_unicast.vlan_id))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_TTL_CHECK,
-			      entry->l3_unicast.ttl_check))
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID_LOWER,
-			       entry->l3_unicast.group_id))
-		return -EMSGSIZE;
-
-	return 0;
-}
-
-static int rocker_cmd_group_tbl_add(const struct rocker_port *rocker_port,
-				    struct rocker_desc_info *desc_info,
-				    void *priv)
-{
-	struct rocker_group_tbl_entry *entry = priv;
-	struct rocker_tlv *cmd_info;
-	int err = 0;
-
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
-		return -EMSGSIZE;
-	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
-	if (!cmd_info)
-		return -EMSGSIZE;
-
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
-			       entry->group_id))
-		return -EMSGSIZE;
-
-	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
-	case ROCKER_OF_DPA_GROUP_TYPE_L2_INTERFACE:
-		err = rocker_cmd_group_tbl_add_l2_interface(desc_info, entry);
-		break;
-	case ROCKER_OF_DPA_GROUP_TYPE_L2_REWRITE:
-		err = rocker_cmd_group_tbl_add_l2_rewrite(desc_info, entry);
-		break;
-	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
-	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		err = rocker_cmd_group_tbl_add_group_ids(desc_info, entry);
-		break;
-	case ROCKER_OF_DPA_GROUP_TYPE_L3_UCAST:
-		err = rocker_cmd_group_tbl_add_l3_unicast(desc_info, entry);
-		break;
-	default:
-		err = -ENOTSUPP;
-		break;
-	}
-
-	if (err)
-		return err;
-
-	rocker_tlv_nest_end(desc_info, cmd_info);
-
-	return 0;
-}
-
-static int rocker_cmd_group_tbl_del(const struct rocker_port *rocker_port,
-				    struct rocker_desc_info *desc_info,
-				    void *priv)
-{
-	const struct rocker_group_tbl_entry *entry = priv;
-	struct rocker_tlv *cmd_info;
-
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
-		return -EMSGSIZE;
-	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
-	if (!cmd_info)
-		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
-			       entry->group_id))
-		return -EMSGSIZE;
-	rocker_tlv_nest_end(desc_info, cmd_info);
-
-	return 0;
-}
-
-/**********************
- * Worlds manipulation
- **********************/
-
-static struct rocker_world_ops *rocker_world_ops[] = {
-	&rocker_ofdpa_ops,
-};
-
-#define ROCKER_WORLD_OPS_LEN ARRAY_SIZE(rocker_world_ops)
-#define ROCKER_DEFAULT_WORLD_OPS rocker_world_ops[0]
-
-struct rocker_world {
-	struct list_head list;
-	const struct rocker_world_ops *ops;
-	unsigned int ref;
-	unsigned long priv[0];
-};
-
-static struct rocker_world *__rocker_world_find(struct rocker *rocker,
-						const struct rocker_world_ops *ops)
-{
-	struct rocker_world *world;
-
-	list_for_each_entry(world, &rocker->worlds, list) {
-		if (world->ops == ops)
-			return world;
-	}
-	return NULL;
-}
-
-static int rocker_world_init(struct rocker *rocker, struct rocker_world *world)
-{
-	if (!world->ops->init)
-		return 0;
-	return world->ops->init(rocker, world->priv);
-}
-
-static void rocker_world_fini(struct rocker *rocker, struct rocker_world *world)
-{
-	if (!world->ops->fini)
-		return;
-	return world->ops->fini(world->priv);
-}
-
-static int rocker_world_get(struct rocker_port *rocker_port,
-			    const struct rocker_world_ops *ops)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_world *world = __rocker_world_find(rocker, ops);
-	int err;
-
-	if (world)
-		goto ref_inc;
-	world = kzalloc(sizeof(*world) + ops->priv_size, GFP_KERNEL);
-	if (!world)
-		return -ENOMEM;
-	world->ops = ops;
-
-	err = rocker_world_init(rocker, world);
-	if (err)
-		goto err_world_init;
-
-	list_add_tail(&world->list, &rocker->worlds);
-ref_inc:
-	world->ref++;
-	rocker_port->world = world;
-	return 0;
-
-err_world_init:
-	kfree(world);
-	return err;
-}
-
-static void rocker_world_put(struct rocker_port *rocker_port)
-{
-	struct rocker_world *world = rocker_port->world;
-	struct rocker *rocker = rocker_port->rocker;
-
-	world->ref--;
-	if (world->ref)
-		return;
-	list_del(&world->list);
-	rocker_world_fini(rocker, world);
-	kfree(world);
-	rocker_port->world = NULL;
-}
-
-static int rocker_world_port_init(struct rocker_port *rocker_port)
-{
-	struct rocker_world *world = rocker_port->world;
-
-	if (!world->ops->port_init)
-		return 0;
-	return world->ops->port_init(rocker_port, world->priv,
-				     rocker_port->world_port_priv);
-}
-
-static void rocker_world_port_fini(struct rocker_port *rocker_port)
-{
-	struct rocker_world *world = rocker_port->world;
-
-	if (!world->ops->port_fini)
-		return;
-	world->ops->port_fini(rocker_port->world_port_priv);
+	if (!world->ops->port_fini)
+		return;
+	world->ops->port_fini(rocker_port->world_port_priv);
 }
 
 static int rocker_world_port_join(struct rocker_port *rocker_port,
@@ -2514,1768 +1767,71 @@ rocker_world_port_obj_fdb_del(struct rocker_port *rocker_port,
 					    fdb);
 }
 
-static int
-rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
-			       struct switchdev_obj_port_fdb *fdb,
-			       switchdev_obj_dump_cb_t *cb)
-{
-	struct rocker_world *world = rocker_port->world;
-
-	if (!world->ops->port_obj_fdb_dump)
-		return 0;
-	return world->ops->port_obj_fdb_dump(rocker_port->world_port_priv,
-					     fdb, cb);
-}
-
-static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
-					   struct net_device *master)
-{
-	struct rocker_world *world = rocker_port->world;
-
-	if (!world->ops->port_master_linked)
-		return 0;
-	return world->ops->port_master_linked(rocker_port->world_port_priv,
-					      master);
-}
-
-static int rocker_world_port_master_unlinked(struct rocker_port *rocker_port,
-					     struct net_device *master)
-{
-	struct rocker_world *world = rocker_port->world;
-
-	if (!world->ops->port_master_unlinked)
-		return 0;
-	return world->ops->port_master_unlinked(rocker_port->world_port_priv,
-						master);
-}
-
-static int rocker_world_port_neigh_update(struct rocker_port *rocker_port,
-					  struct neighbour *n)
-{
-	struct rocker_world *world = rocker_port->world;
-
-	if (!world->ops->port_neigh_update)
-		return 0;
-	return world->ops->port_neigh_update(rocker_port->world_port_priv, n);
-}
-
-static int rocker_world_port_neigh_destroy(struct rocker_port *rocker_port,
-					   struct neighbour *n)
-{
-	struct rocker_world *world = rocker_port->world;
-
-	if (!world->ops->port_neigh_destroy)
-		return 0;
-	return world->ops->port_neigh_destroy(rocker_port->world_port_priv, n);
-}
-
-static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
-					      const unsigned char *addr,
-					      __be16 vlan_id)
-{
-	struct rocker_world *world = rocker_port->world;
-
-	if (!world->ops->port_ev_mac_vlan_seen)
-		return 0;
-	return world->ops->port_ev_mac_vlan_seen(rocker_port->world_port_priv,
-						 addr, vlan_id);
-}
-
-/***************************************************
- * Flow, group, FDB, internal VLAN and neigh tables
- ***************************************************/
-
-static int rocker_init_tbls(struct rocker *rocker)
-{
-	hash_init(rocker->flow_tbl);
-	spin_lock_init(&rocker->flow_tbl_lock);
-
-	hash_init(rocker->group_tbl);
-	spin_lock_init(&rocker->group_tbl_lock);
-
-	hash_init(rocker->fdb_tbl);
-	spin_lock_init(&rocker->fdb_tbl_lock);
-
-	hash_init(rocker->internal_vlan_tbl);
-	spin_lock_init(&rocker->internal_vlan_tbl_lock);
-
-	hash_init(rocker->neigh_tbl);
-	spin_lock_init(&rocker->neigh_tbl_lock);
-
-	return 0;
-}
-
-static void rocker_free_tbls(struct rocker *rocker)
-{
-	unsigned long flags;
-	struct rocker_flow_tbl_entry *flow_entry;
-	struct rocker_group_tbl_entry *group_entry;
-	struct rocker_fdb_tbl_entry *fdb_entry;
-	struct rocker_internal_vlan_tbl_entry *internal_vlan_entry;
-	struct rocker_neigh_tbl_entry *neigh_entry;
-	struct hlist_node *tmp;
-	int bkt;
-
-	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
-	hash_for_each_safe(rocker->flow_tbl, bkt, tmp, flow_entry, entry)
-		hash_del(&flow_entry->entry);
-	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
-
-	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
-	hash_for_each_safe(rocker->group_tbl, bkt, tmp, group_entry, entry)
-		hash_del(&group_entry->entry);
-	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
-
-	spin_lock_irqsave(&rocker->fdb_tbl_lock, flags);
-	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, fdb_entry, entry)
-		hash_del(&fdb_entry->entry);
-	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, flags);
-
-	spin_lock_irqsave(&rocker->internal_vlan_tbl_lock, flags);
-	hash_for_each_safe(rocker->internal_vlan_tbl, bkt,
-			   tmp, internal_vlan_entry, entry)
-		hash_del(&internal_vlan_entry->entry);
-	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, flags);
-
-	spin_lock_irqsave(&rocker->neigh_tbl_lock, flags);
-	hash_for_each_safe(rocker->neigh_tbl, bkt, tmp, neigh_entry, entry)
-		hash_del(&neigh_entry->entry);
-	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, flags);
-}
-
-static struct rocker_flow_tbl_entry *
-rocker_flow_tbl_find(const struct rocker *rocker,
-		     const struct rocker_flow_tbl_entry *match)
-{
-	struct rocker_flow_tbl_entry *found;
-	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
-
-	hash_for_each_possible(rocker->flow_tbl, found,
-			       entry, match->key_crc32) {
-		if (memcmp(&found->key, &match->key, key_len) == 0)
-			return found;
-	}
-
-	return NULL;
-}
-
-static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
-			       struct switchdev_trans *trans, int flags,
-			       struct rocker_flow_tbl_entry *match)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_flow_tbl_entry *found;
-	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
-	unsigned long lock_flags;
-
-	match->key_crc32 = crc32(~0, &match->key, key_len);
-
-	spin_lock_irqsave(&rocker->flow_tbl_lock, lock_flags);
-
-	found = rocker_flow_tbl_find(rocker, match);
-
-	if (found) {
-		match->cookie = found->cookie;
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
-		rocker_kfree(trans, found);
-		found = match;
-		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
-	} else {
-		found = match;
-		found->cookie = rocker->flow_tbl_next_cookie++;
-		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
-	}
-
-	if (!switchdev_trans_ph_prepare(trans))
-		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
-
-	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
-
-	if (!switchdev_trans_ph_prepare(trans))
-		return rocker_cmd_exec(rocker_port,
-				       rocker_flags_nowait(flags),
-				       rocker_cmd_flow_tbl_add,
-				       found, NULL, NULL);
-	return 0;
-}
-
-static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
-			       struct switchdev_trans *trans, int flags,
-			       struct rocker_flow_tbl_entry *match)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_flow_tbl_entry *found;
-	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
-	unsigned long lock_flags;
-	int err = 0;
-
-	match->key_crc32 = crc32(~0, &match->key, key_len);
-
-	spin_lock_irqsave(&rocker->flow_tbl_lock, lock_flags);
-
-	found = rocker_flow_tbl_find(rocker, match);
-
-	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
-		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
-	}
-
-	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
-
-	rocker_kfree(trans, match);
-
-	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			err = rocker_cmd_exec(rocker_port,
-					      rocker_flags_nowait(flags),
-					      rocker_cmd_flow_tbl_del,
-					      found, NULL, NULL);
-		rocker_kfree(trans, found);
-	}
-
-	return err;
-}
-
-static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
-			      struct switchdev_trans *trans, int flags,
-			      struct rocker_flow_tbl_entry *entry)
-{
-	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_flow_tbl_del(rocker_port, trans, flags, entry);
-	else
-		return rocker_flow_tbl_add(rocker_port, trans, flags, entry);
-}
-
-static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
-				   struct switchdev_trans *trans, int flags,
-				   u32 in_pport, u32 in_pport_mask,
-				   enum rocker_of_dpa_table_id goto_tbl)
-{
-	struct rocker_flow_tbl_entry *entry;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	entry->key.priority = ROCKER_PRIORITY_IG_PORT;
-	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT;
-	entry->key.ig_port.in_pport = in_pport;
-	entry->key.ig_port.in_pport_mask = in_pport_mask;
-	entry->key.ig_port.goto_tbl = goto_tbl;
-
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
-				struct switchdev_trans *trans, int flags,
-				u32 in_pport, __be16 vlan_id,
-				__be16 vlan_id_mask,
-				enum rocker_of_dpa_table_id goto_tbl,
-				bool untagged, __be16 new_vlan_id)
-{
-	struct rocker_flow_tbl_entry *entry;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	entry->key.priority = ROCKER_PRIORITY_VLAN;
-	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_VLAN;
-	entry->key.vlan.in_pport = in_pport;
-	entry->key.vlan.vlan_id = vlan_id;
-	entry->key.vlan.vlan_id_mask = vlan_id_mask;
-	entry->key.vlan.goto_tbl = goto_tbl;
-
-	entry->key.vlan.untagged = untagged;
-	entry->key.vlan.new_vlan_id = new_vlan_id;
-
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
-				    struct switchdev_trans *trans,
-				    u32 in_pport, u32 in_pport_mask,
-				    __be16 eth_type, const u8 *eth_dst,
-				    const u8 *eth_dst_mask, __be16 vlan_id,
-				    __be16 vlan_id_mask, bool copy_to_cpu,
-				    int flags)
-{
-	struct rocker_flow_tbl_entry *entry;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	if (is_multicast_ether_addr(eth_dst)) {
-		entry->key.priority = ROCKER_PRIORITY_TERM_MAC_MCAST;
-		entry->key.term_mac.goto_tbl =
-			 ROCKER_OF_DPA_TABLE_ID_MULTICAST_ROUTING;
-	} else {
-		entry->key.priority = ROCKER_PRIORITY_TERM_MAC_UCAST;
-		entry->key.term_mac.goto_tbl =
-			 ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING;
-	}
-
-	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
-	entry->key.term_mac.in_pport = in_pport;
-	entry->key.term_mac.in_pport_mask = in_pport_mask;
-	entry->key.term_mac.eth_type = eth_type;
-	ether_addr_copy(entry->key.term_mac.eth_dst, eth_dst);
-	ether_addr_copy(entry->key.term_mac.eth_dst_mask, eth_dst_mask);
-	entry->key.term_mac.vlan_id = vlan_id;
-	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
-	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
-
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
-				  struct switchdev_trans *trans, int flags,
-				  const u8 *eth_dst, const u8 *eth_dst_mask,
-				  __be16 vlan_id, u32 tunnel_id,
-				  enum rocker_of_dpa_table_id goto_tbl,
-				  u32 group_id, bool copy_to_cpu)
-{
-	struct rocker_flow_tbl_entry *entry;
-	u32 priority;
-	bool vlan_bridging = !!vlan_id;
-	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
-	bool wild = false;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_BRIDGING;
-
-	if (eth_dst) {
-		entry->key.bridge.has_eth_dst = 1;
-		ether_addr_copy(entry->key.bridge.eth_dst, eth_dst);
-	}
-	if (eth_dst_mask) {
-		entry->key.bridge.has_eth_dst_mask = 1;
-		ether_addr_copy(entry->key.bridge.eth_dst_mask, eth_dst_mask);
-		if (!ether_addr_equal(eth_dst_mask, ff_mac))
-			wild = true;
-	}
-
-	priority = ROCKER_PRIORITY_UNKNOWN;
-	if (vlan_bridging && dflt && wild)
-		priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD;
-	else if (vlan_bridging && dflt && !wild)
-		priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT;
-	else if (vlan_bridging && !dflt)
-		priority = ROCKER_PRIORITY_BRIDGING_VLAN;
-	else if (!vlan_bridging && dflt && wild)
-		priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_WILD;
-	else if (!vlan_bridging && dflt && !wild)
-		priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_EXACT;
-	else if (!vlan_bridging && !dflt)
-		priority = ROCKER_PRIORITY_BRIDGING_TENANT;
-
-	entry->key.priority = priority;
-	entry->key.bridge.vlan_id = vlan_id;
-	entry->key.bridge.tunnel_id = tunnel_id;
-	entry->key.bridge.goto_tbl = goto_tbl;
-	entry->key.bridge.group_id = group_id;
-	entry->key.bridge.copy_to_cpu = copy_to_cpu;
-
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static int rocker_flow_tbl_ucast4_routing(struct rocker_port *rocker_port,
-					  struct switchdev_trans *trans,
-					  __be16 eth_type, __be32 dst,
-					  __be32 dst_mask, u32 priority,
-					  enum rocker_of_dpa_table_id goto_tbl,
-					  u32 group_id, int flags)
-{
-	struct rocker_flow_tbl_entry *entry;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING;
-	entry->key.priority = priority;
-	entry->key.ucast_routing.eth_type = eth_type;
-	entry->key.ucast_routing.dst4 = dst;
-	entry->key.ucast_routing.dst4_mask = dst_mask;
-	entry->key.ucast_routing.goto_tbl = goto_tbl;
-	entry->key.ucast_routing.group_id = group_id;
-	entry->key_len = offsetof(struct rocker_flow_tbl_key,
-				  ucast_routing.group_id);
-
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
-			       struct switchdev_trans *trans, int flags,
-			       u32 in_pport, u32 in_pport_mask,
-			       const u8 *eth_src, const u8 *eth_src_mask,
-			       const u8 *eth_dst, const u8 *eth_dst_mask,
-			       __be16 eth_type, __be16 vlan_id,
-			       __be16 vlan_id_mask, u8 ip_proto,
-			       u8 ip_proto_mask, u8 ip_tos, u8 ip_tos_mask,
-			       u32 group_id)
-{
-	u32 priority;
-	struct rocker_flow_tbl_entry *entry;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	priority = ROCKER_PRIORITY_ACL_NORMAL;
-	if (eth_dst && eth_dst_mask) {
-		if (ether_addr_equal(eth_dst_mask, mcast_mac))
-			priority = ROCKER_PRIORITY_ACL_DFLT;
-		else if (is_link_local_ether_addr(eth_dst))
-			priority = ROCKER_PRIORITY_ACL_CTRL;
-	}
-
-	entry->key.priority = priority;
-	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
-	entry->key.acl.in_pport = in_pport;
-	entry->key.acl.in_pport_mask = in_pport_mask;
-
-	if (eth_src)
-		ether_addr_copy(entry->key.acl.eth_src, eth_src);
-	if (eth_src_mask)
-		ether_addr_copy(entry->key.acl.eth_src_mask, eth_src_mask);
-	if (eth_dst)
-		ether_addr_copy(entry->key.acl.eth_dst, eth_dst);
-	if (eth_dst_mask)
-		ether_addr_copy(entry->key.acl.eth_dst_mask, eth_dst_mask);
-
-	entry->key.acl.eth_type = eth_type;
-	entry->key.acl.vlan_id = vlan_id;
-	entry->key.acl.vlan_id_mask = vlan_id_mask;
-	entry->key.acl.ip_proto = ip_proto;
-	entry->key.acl.ip_proto_mask = ip_proto_mask;
-	entry->key.acl.ip_tos = ip_tos;
-	entry->key.acl.ip_tos_mask = ip_tos_mask;
-	entry->key.acl.group_id = group_id;
-
-	return rocker_flow_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static struct rocker_group_tbl_entry *
-rocker_group_tbl_find(const struct rocker *rocker,
-		      const struct rocker_group_tbl_entry *match)
-{
-	struct rocker_group_tbl_entry *found;
-
-	hash_for_each_possible(rocker->group_tbl, found,
-			       entry, match->group_id) {
-		if (found->group_id == match->group_id)
-			return found;
-	}
-
-	return NULL;
-}
-
-static void rocker_group_tbl_entry_free(struct switchdev_trans *trans,
-					struct rocker_group_tbl_entry *entry)
-{
-	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
-	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
-	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
-		rocker_kfree(trans, entry->group_ids);
-		break;
-	default:
-		break;
-	}
-	rocker_kfree(trans, entry);
-}
-
-static int rocker_group_tbl_add(struct rocker_port *rocker_port,
-				struct switchdev_trans *trans, int flags,
-				struct rocker_group_tbl_entry *match)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_group_tbl_entry *found;
-	unsigned long lock_flags;
-
-	spin_lock_irqsave(&rocker->group_tbl_lock, lock_flags);
-
-	found = rocker_group_tbl_find(rocker, match);
-
-	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
-		rocker_group_tbl_entry_free(trans, found);
-		found = match;
-		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
-	} else {
-		found = match;
-		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
-	}
-
-	if (!switchdev_trans_ph_prepare(trans))
-		hash_add(rocker->group_tbl, &found->entry, found->group_id);
-
-	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
-
-	if (!switchdev_trans_ph_prepare(trans))
-		return rocker_cmd_exec(rocker_port,
-				       rocker_flags_nowait(flags),
-				       rocker_cmd_group_tbl_add,
-				       found, NULL, NULL);
-	return 0;
-}
-
-static int rocker_group_tbl_del(struct rocker_port *rocker_port,
-				struct switchdev_trans *trans, int flags,
-				struct rocker_group_tbl_entry *match)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_group_tbl_entry *found;
-	unsigned long lock_flags;
-	int err = 0;
-
-	spin_lock_irqsave(&rocker->group_tbl_lock, lock_flags);
-
-	found = rocker_group_tbl_find(rocker, match);
-
-	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
-		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
-	}
-
-	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
-
-	rocker_group_tbl_entry_free(trans, match);
-
-	if (found) {
-		if (!switchdev_trans_ph_prepare(trans))
-			err = rocker_cmd_exec(rocker_port,
-					      rocker_flags_nowait(flags),
-					      rocker_cmd_group_tbl_del,
-					      found, NULL, NULL);
-		rocker_group_tbl_entry_free(trans, found);
-	}
-
-	return err;
-}
-
-static int rocker_group_tbl_do(struct rocker_port *rocker_port,
-			       struct switchdev_trans *trans, int flags,
-			       struct rocker_group_tbl_entry *entry)
-{
-	if (flags & ROCKER_OP_FLAG_REMOVE)
-		return rocker_group_tbl_del(rocker_port, trans, flags, entry);
-	else
-		return rocker_group_tbl_add(rocker_port, trans, flags, entry);
-}
-
-static int rocker_group_l2_interface(struct rocker_port *rocker_port,
-				     struct switchdev_trans *trans, int flags,
-				     __be16 vlan_id, u32 out_pport,
-				     int pop_vlan)
-{
-	struct rocker_group_tbl_entry *entry;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
-	entry->l2_interface.pop_vlan = pop_vlan;
-
-	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
-				   struct switchdev_trans *trans,
-				   int flags, u8 group_count,
-				   const u32 *group_ids, u32 group_id)
-{
-	struct rocker_group_tbl_entry *entry;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	entry->group_id = group_id;
-	entry->group_count = group_count;
-
-	entry->group_ids = rocker_kcalloc(trans, flags,
-					  group_count, sizeof(u32));
-	if (!entry->group_ids) {
-		rocker_kfree(trans, entry);
-		return -ENOMEM;
-	}
-	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
-
-	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static int rocker_group_l2_flood(struct rocker_port *rocker_port,
-				 struct switchdev_trans *trans, int flags,
-				 __be16 vlan_id, u8 group_count,
-				 const u32 *group_ids, u32 group_id)
-{
-	return rocker_group_l2_fan_out(rocker_port, trans, flags,
-				       group_count, group_ids,
-				       group_id);
-}
-
-static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
-				   struct switchdev_trans *trans, int flags,
-				   u32 index, const u8 *src_mac, const u8 *dst_mac,
-				   __be16 vlan_id, bool ttl_check, u32 pport)
-{
-	struct rocker_group_tbl_entry *entry;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	entry->group_id = ROCKER_GROUP_L3_UNICAST(index);
-	if (src_mac)
-		ether_addr_copy(entry->l3_unicast.eth_src, src_mac);
-	if (dst_mac)
-		ether_addr_copy(entry->l3_unicast.eth_dst, dst_mac);
-	entry->l3_unicast.vlan_id = vlan_id;
-	entry->l3_unicast.ttl_check = ttl_check;
-	entry->l3_unicast.group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, pport);
-
-	return rocker_group_tbl_do(rocker_port, trans, flags, entry);
-}
-
-static struct rocker_neigh_tbl_entry *
-rocker_neigh_tbl_find(const struct rocker *rocker, __be32 ip_addr)
-{
-	struct rocker_neigh_tbl_entry *found;
-
-	hash_for_each_possible(rocker->neigh_tbl, found,
-			       entry, be32_to_cpu(ip_addr))
-		if (found->ip_addr == ip_addr)
-			return found;
-
-	return NULL;
-}
-
-static void _rocker_neigh_add(struct rocker *rocker,
-			      struct switchdev_trans *trans,
-			      struct rocker_neigh_tbl_entry *entry)
-{
-	if (!switchdev_trans_ph_commit(trans))
-		entry->index = rocker->neigh_tbl_next_index++;
-	if (switchdev_trans_ph_prepare(trans))
-		return;
-	entry->ref_count++;
-	hash_add(rocker->neigh_tbl, &entry->entry,
-		 be32_to_cpu(entry->ip_addr));
-}
-
-static void _rocker_neigh_del(struct switchdev_trans *trans,
-			      struct rocker_neigh_tbl_entry *entry)
-{
-	if (switchdev_trans_ph_prepare(trans))
-		return;
-	if (--entry->ref_count == 0) {
-		hash_del(&entry->entry);
-		rocker_kfree(trans, entry);
-	}
-}
-
-static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
-				 struct switchdev_trans *trans,
-				 const u8 *eth_dst, bool ttl_check)
-{
-	if (eth_dst) {
-		ether_addr_copy(entry->eth_dst, eth_dst);
-		entry->ttl_check = ttl_check;
-	} else if (!switchdev_trans_ph_prepare(trans)) {
-		entry->ref_count++;
-	}
-}
-
-static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
-				  struct switchdev_trans *trans,
-				  int flags, __be32 ip_addr, const u8 *eth_dst)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_neigh_tbl_entry *entry;
-	struct rocker_neigh_tbl_entry *found;
-	unsigned long lock_flags;
-	__be16 eth_type = htons(ETH_P_IP);
-	enum rocker_of_dpa_table_id goto_tbl =
-		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
-	u32 group_id;
-	u32 priority = 0;
-	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
-	bool updating;
-	bool removing;
-	int err = 0;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	spin_lock_irqsave(&rocker->neigh_tbl_lock, lock_flags);
-
-	found = rocker_neigh_tbl_find(rocker, ip_addr);
-
-	updating = found && adding;
-	removing = found && !adding;
-	adding = !found && adding;
-
-	if (adding) {
-		entry->ip_addr = ip_addr;
-		entry->dev = rocker_port->dev;
-		ether_addr_copy(entry->eth_dst, eth_dst);
-		entry->ttl_check = true;
-		_rocker_neigh_add(rocker, trans, entry);
-	} else if (removing) {
-		memcpy(entry, found, sizeof(*entry));
-		_rocker_neigh_del(trans, found);
-	} else if (updating) {
-		_rocker_neigh_update(found, trans, eth_dst, true);
-		memcpy(entry, found, sizeof(*entry));
-	} else {
-		err = -ENOENT;
-	}
-
-	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
-
-	if (err)
-		goto err_out;
-
-	/* For each active neighbor, we have an L3 unicast group and
-	 * a /32 route to the neighbor, which uses the L3 unicast
-	 * group.  The L3 unicast group can also be referred to by
-	 * other routes' nexthops.
-	 */
-
-	err = rocker_group_l3_unicast(rocker_port, trans, flags,
-				      entry->index,
-				      rocker_port->dev->dev_addr,
-				      entry->eth_dst,
-				      rocker_port->internal_vlan_id,
-				      entry->ttl_check,
-				      rocker_port->pport);
-	if (err) {
-		netdev_err(rocker_port->dev,
-			   "Error (%d) L3 unicast group index %d\n",
-			   err, entry->index);
-		goto err_out;
-	}
-
-	if (adding || removing) {
-		group_id = ROCKER_GROUP_L3_UNICAST(entry->index);
-		err = rocker_flow_tbl_ucast4_routing(rocker_port, trans,
-						     eth_type, ip_addr,
-						     inet_make_mask(32),
-						     priority, goto_tbl,
-						     group_id, flags);
-
-		if (err)
-			netdev_err(rocker_port->dev,
-				   "Error (%d) /32 unicast route %pI4 group 0x%08x\n",
-				   err, &entry->ip_addr, group_id);
-	}
-
-err_out:
-	if (!adding)
-		rocker_kfree(trans, entry);
-
-	return err;
-}
-
-static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
-				    struct switchdev_trans *trans,
-				    __be32 ip_addr)
-{
-	struct net_device *dev = rocker_port->dev;
-	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
-	int err = 0;
-
-	if (!n) {
-		n = neigh_create(&arp_tbl, &ip_addr, dev);
-		if (IS_ERR(n))
-			return IS_ERR(n);
-	}
-
-	/* If the neigh is already resolved, then go ahead and
-	 * install the entry, otherwise start the ARP process to
-	 * resolve the neigh.
-	 */
-
-	if (n->nud_state & NUD_VALID)
-		err = rocker_port_ipv4_neigh(rocker_port, trans, 0,
-					     ip_addr, n->ha);
-	else
-		neigh_event_send(n, NULL);
-
-	neigh_release(n);
-	return err;
-}
-
-static int rocker_port_ipv4_nh(struct rocker_port *rocker_port,
-			       struct switchdev_trans *trans, int flags,
-			       __be32 ip_addr, u32 *index)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_neigh_tbl_entry *entry;
-	struct rocker_neigh_tbl_entry *found;
-	unsigned long lock_flags;
-	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
-	bool updating;
-	bool removing;
-	bool resolved = true;
-	int err = 0;
-
-	entry = rocker_kzalloc(trans, flags, sizeof(*entry));
-	if (!entry)
-		return -ENOMEM;
-
-	spin_lock_irqsave(&rocker->neigh_tbl_lock, lock_flags);
-
-	found = rocker_neigh_tbl_find(rocker, ip_addr);
-	if (found)
-		*index = found->index;
-
-	updating = found && adding;
-	removing = found && !adding;
-	adding = !found && adding;
-
-	if (adding) {
-		entry->ip_addr = ip_addr;
-		entry->dev = rocker_port->dev;
-		_rocker_neigh_add(rocker, trans, entry);
-		*index = entry->index;
-		resolved = false;
-	} else if (removing) {
-		_rocker_neigh_del(trans, found);
-	} else if (updating) {
-		_rocker_neigh_update(found, trans, NULL, false);
-		resolved = !is_zero_ether_addr(found->eth_dst);
-	} else {
-		err = -ENOENT;
-	}
-
-	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, lock_flags);
-
-	if (!adding)
-		rocker_kfree(trans, entry);
-
-	if (err)
-		return err;
-
-	/* Resolved means neigh ip_addr is resolved to neigh mac. */
-
-	if (!resolved)
-		err = rocker_port_ipv4_resolve(rocker_port, trans, ip_addr);
-
-	return err;
-}
-
-static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
-					struct switchdev_trans *trans,
-					int flags, __be16 vlan_id)
-{
-	struct rocker_port *p;
-	const struct rocker *rocker = rocker_port->rocker;
-	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
-	u32 *group_ids;
-	u8 group_count = 0;
-	int err = 0;
-	int i;
-
-	group_ids = rocker_kcalloc(trans, flags,
-				   rocker->port_count, sizeof(u32));
-	if (!group_ids)
-		return -ENOMEM;
-
-	/* Adjust the flood group for this VLAN.  The flood group
-	 * references an L2 interface group for each port in this
-	 * VLAN.
-	 */
-
-	for (i = 0; i < rocker->port_count; i++) {
-		p = rocker->ports[i];
-		if (!p)
-			continue;
-		if (!rocker_port_is_bridged(p))
-			continue;
-		if (test_bit(ntohs(vlan_id), p->vlan_bitmap)) {
-			group_ids[group_count++] =
-				ROCKER_GROUP_L2_INTERFACE(vlan_id, p->pport);
-		}
-	}
-
-	/* If there are no bridged ports in this VLAN, we're done */
-	if (group_count == 0)
-		goto no_ports_in_vlan;
-
-	err = rocker_group_l2_flood(rocker_port, trans, flags, vlan_id,
-				    group_count, group_ids, group_id);
-	if (err)
-		netdev_err(rocker_port->dev,
-			   "Error (%d) port VLAN l2 flood group\n", err);
-
-no_ports_in_vlan:
-	rocker_kfree(trans, group_ids);
-	return err;
-}
-
-static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
-				      struct switchdev_trans *trans, int flags,
-				      __be16 vlan_id, bool pop_vlan)
-{
-	const struct rocker *rocker = rocker_port->rocker;
-	struct rocker_port *p;
-	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
-	u32 out_pport;
-	int ref = 0;
-	int err;
-	int i;
-
-	/* An L2 interface group for this port in this VLAN, but
-	 * only when port STP state is LEARNING|FORWARDING.
-	 */
-
-	if (rocker_port->stp_state == BR_STATE_LEARNING ||
-	    rocker_port->stp_state == BR_STATE_FORWARDING) {
-		out_pport = rocker_port->pport;
-		err = rocker_group_l2_interface(rocker_port, trans, flags,
-						vlan_id, out_pport, pop_vlan);
-		if (err) {
-			netdev_err(rocker_port->dev,
-				   "Error (%d) port VLAN l2 group for pport %d\n",
-				   err, out_pport);
-			return err;
-		}
-	}
-
-	/* An L2 interface group for this VLAN to CPU port.
-	 * Add when first port joins this VLAN and destroy when
-	 * last port leaves this VLAN.
-	 */
-
-	for (i = 0; i < rocker->port_count; i++) {
-		p = rocker->ports[i];
-		if (p && test_bit(ntohs(vlan_id), p->vlan_bitmap))
-			ref++;
-	}
-
-	if ((!adding || ref != 1) && (adding || ref != 0))
-		return 0;
-
-	out_pport = 0;
-	err = rocker_group_l2_interface(rocker_port, trans, flags,
-					vlan_id, out_pport, pop_vlan);
-	if (err) {
-		netdev_err(rocker_port->dev,
-			   "Error (%d) port VLAN l2 group for CPU port\n", err);
-		return err;
-	}
-
-	return 0;
-}
-
-static struct rocker_ctrl {
-	const u8 *eth_dst;
-	const u8 *eth_dst_mask;
-	__be16 eth_type;
-	bool acl;
-	bool bridge;
-	bool term;
-	bool copy_to_cpu;
-} rocker_ctrls[] = {
-	[ROCKER_CTRL_LINK_LOCAL_MCAST] = {
-		/* pass link local multicast pkts up to CPU for filtering */
-		.eth_dst = ll_mac,
-		.eth_dst_mask = ll_mask,
-		.acl = true,
-	},
-	[ROCKER_CTRL_LOCAL_ARP] = {
-		/* pass local ARP pkts up to CPU */
-		.eth_dst = zero_mac,
-		.eth_dst_mask = zero_mac,
-		.eth_type = htons(ETH_P_ARP),
-		.acl = true,
-	},
-	[ROCKER_CTRL_IPV4_MCAST] = {
-		/* pass IPv4 mcast pkts up to CPU, RFC 1112 */
-		.eth_dst = ipv4_mcast,
-		.eth_dst_mask = ipv4_mask,
-		.eth_type = htons(ETH_P_IP),
-		.term  = true,
-		.copy_to_cpu = true,
-	},
-	[ROCKER_CTRL_IPV6_MCAST] = {
-		/* pass IPv6 mcast pkts up to CPU, RFC 2464 */
-		.eth_dst = ipv6_mcast,
-		.eth_dst_mask = ipv6_mask,
-		.eth_type = htons(ETH_P_IPV6),
-		.term  = true,
-		.copy_to_cpu = true,
-	},
-	[ROCKER_CTRL_DFLT_BRIDGING] = {
-		/* flood any pkts on vlan */
-		.bridge = true,
-		.copy_to_cpu = true,
-	},
-	[ROCKER_CTRL_DFLT_OVS] = {
-		/* pass all pkts up to CPU */
-		.eth_dst = zero_mac,
-		.eth_dst_mask = zero_mac,
-		.acl = true,
-	},
-};
-
-static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
-				     struct switchdev_trans *trans, int flags,
-				     const struct rocker_ctrl *ctrl, __be16 vlan_id)
-{
-	u32 in_pport = rocker_port->pport;
-	u32 in_pport_mask = 0xffffffff;
-	u32 out_pport = 0;
-	const u8 *eth_src = NULL;
-	const u8 *eth_src_mask = NULL;
-	__be16 vlan_id_mask = htons(0xffff);
-	u8 ip_proto = 0;
-	u8 ip_proto_mask = 0;
-	u8 ip_tos = 0;
-	u8 ip_tos_mask = 0;
-	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
-	int err;
-
-	err = rocker_flow_tbl_acl(rocker_port, trans, flags,
-				  in_pport, in_pport_mask,
-				  eth_src, eth_src_mask,
-				  ctrl->eth_dst, ctrl->eth_dst_mask,
-				  ctrl->eth_type,
-				  vlan_id, vlan_id_mask,
-				  ip_proto, ip_proto_mask,
-				  ip_tos, ip_tos_mask,
-				  group_id);
-
-	if (err)
-		netdev_err(rocker_port->dev, "Error (%d) ctrl ACL\n", err);
-
-	return err;
-}
-
-static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
-					struct switchdev_trans *trans,
-					int flags,
-					const struct rocker_ctrl *ctrl,
-					__be16 vlan_id)
-{
-	enum rocker_of_dpa_table_id goto_tbl =
-		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
-	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
-	u32 tunnel_id = 0;
-	int err;
-
-	if (!rocker_port_is_bridged(rocker_port))
-		return 0;
-
-	err = rocker_flow_tbl_bridge(rocker_port, trans, flags,
-				     ctrl->eth_dst, ctrl->eth_dst_mask,
-				     vlan_id, tunnel_id,
-				     goto_tbl, group_id, ctrl->copy_to_cpu);
-
-	if (err)
-		netdev_err(rocker_port->dev, "Error (%d) ctrl FLOOD\n", err);
-
-	return err;
-}
-
-static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
-				      struct switchdev_trans *trans, int flags,
-				      const struct rocker_ctrl *ctrl, __be16 vlan_id)
-{
-	u32 in_pport_mask = 0xffffffff;
-	__be16 vlan_id_mask = htons(0xffff);
-	int err;
-
-	if (ntohs(vlan_id) == 0)
-		vlan_id = rocker_port->internal_vlan_id;
-
-	err = rocker_flow_tbl_term_mac(rocker_port, trans,
-				       rocker_port->pport, in_pport_mask,
-				       ctrl->eth_type, ctrl->eth_dst,
-				       ctrl->eth_dst_mask, vlan_id,
-				       vlan_id_mask, ctrl->copy_to_cpu,
-				       flags);
-
-	if (err)
-		netdev_err(rocker_port->dev, "Error (%d) ctrl term\n", err);
-
-	return err;
-}
-
-static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port,
-				 struct switchdev_trans *trans, int flags,
-				 const struct rocker_ctrl *ctrl, __be16 vlan_id)
-{
-	if (ctrl->acl)
-		return rocker_port_ctrl_vlan_acl(rocker_port, trans, flags,
-						 ctrl, vlan_id);
-	if (ctrl->bridge)
-		return rocker_port_ctrl_vlan_bridge(rocker_port, trans, flags,
-						    ctrl, vlan_id);
-
-	if (ctrl->term)
-		return rocker_port_ctrl_vlan_term(rocker_port, trans, flags,
-						  ctrl, vlan_id);
-
-	return -EOPNOTSUPP;
-}
-
-static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
-				     struct switchdev_trans *trans, int flags,
-				     __be16 vlan_id)
-{
-	int err = 0;
-	int i;
-
-	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
-		if (rocker_port->ctrls[i]) {
-			err = rocker_port_ctrl_vlan(rocker_port, trans, flags,
-						    &rocker_ctrls[i], vlan_id);
-			if (err)
-				return err;
-		}
-	}
-
-	return err;
-}
-
-static int rocker_port_ctrl(struct rocker_port *rocker_port,
-			    struct switchdev_trans *trans, int flags,
-			    const struct rocker_ctrl *ctrl)
-{
-	u16 vid;
-	int err = 0;
-
-	for (vid = 1; vid < VLAN_N_VID; vid++) {
-		if (!test_bit(vid, rocker_port->vlan_bitmap))
-			continue;
-		err = rocker_port_ctrl_vlan(rocker_port, trans, flags,
-					    ctrl, htons(vid));
-		if (err)
-			break;
-	}
-
-	return err;
-}
-
-static int rocker_port_vlan(struct rocker_port *rocker_port,
-			    struct switchdev_trans *trans, int flags, u16 vid)
-{
-	enum rocker_of_dpa_table_id goto_tbl =
-		ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
-	u32 in_pport = rocker_port->pport;
-	__be16 vlan_id = htons(vid);
-	__be16 vlan_id_mask = htons(0xffff);
-	__be16 internal_vlan_id;
-	bool untagged;
-	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
-	int err;
-
-	internal_vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, &untagged);
-
-	if (adding && test_bit(ntohs(internal_vlan_id),
-			       rocker_port->vlan_bitmap))
-			return 0; /* already added */
-	else if (!adding && !test_bit(ntohs(internal_vlan_id),
-				      rocker_port->vlan_bitmap))
-			return 0; /* already removed */
-
-	change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
-
-	if (adding) {
-		err = rocker_port_ctrl_vlan_add(rocker_port, trans, flags,
-						internal_vlan_id);
-		if (err) {
-			netdev_err(rocker_port->dev,
-				   "Error (%d) port ctrl vlan add\n", err);
-			goto err_out;
-		}
-	}
-
-	err = rocker_port_vlan_l2_groups(rocker_port, trans, flags,
-					 internal_vlan_id, untagged);
-	if (err) {
-		netdev_err(rocker_port->dev,
-			   "Error (%d) port VLAN l2 groups\n", err);
-		goto err_out;
-	}
-
-	err = rocker_port_vlan_flood_group(rocker_port, trans, flags,
-					   internal_vlan_id);
-	if (err) {
-		netdev_err(rocker_port->dev,
-			   "Error (%d) port VLAN l2 flood group\n", err);
-		goto err_out;
-	}
-
-	err = rocker_flow_tbl_vlan(rocker_port, trans, flags,
-				   in_pport, vlan_id, vlan_id_mask,
-				   goto_tbl, untagged, internal_vlan_id);
-	if (err)
-		netdev_err(rocker_port->dev,
-			   "Error (%d) port VLAN table\n", err);
-
-err_out:
-	if (switchdev_trans_ph_prepare(trans))
-		change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
-
-	return err;
-}
-
-static int rocker_port_ig_tbl(struct rocker_port *rocker_port,
-			      struct switchdev_trans *trans, int flags)
-{
-	enum rocker_of_dpa_table_id goto_tbl;
-	u32 in_pport;
-	u32 in_pport_mask;
-	int err;
-
-	/* Normal Ethernet Frames.  Matches pkts from any local physical
-	 * ports.  Goto VLAN tbl.
-	 */
-
-	in_pport = 0;
-	in_pport_mask = 0xffff0000;
-	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
-
-	err = rocker_flow_tbl_ig_port(rocker_port, trans, flags,
-				      in_pport, in_pport_mask,
-				      goto_tbl);
-	if (err)
-		netdev_err(rocker_port->dev,
-			   "Error (%d) ingress port table entry\n", err);
-
-	return err;
-}
-
-struct rocker_fdb_learn_work {
-	struct work_struct work;
-	struct rocker_port *rocker_port;
-	struct switchdev_trans *trans;
-	int flags;
-	u8 addr[ETH_ALEN];
-	u16 vid;
-};
-
-static void rocker_port_fdb_learn_work(struct work_struct *work)
-{
-	const struct rocker_fdb_learn_work *lw =
-		container_of(work, struct rocker_fdb_learn_work, work);
-	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
-	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
-	struct switchdev_notifier_fdb_info info;
-
-	info.addr = lw->addr;
-	info.vid = lw->vid;
-
-	if (learned && removing)
-		call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
-					 lw->rocker_port->dev, &info.info);
-	else if (learned && !removing)
-		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
-					 lw->rocker_port->dev, &info.info);
-
-	rocker_kfree(lw->trans, work);
-}
-
-static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
-				 struct switchdev_trans *trans, int flags,
-				 const u8 *addr, __be16 vlan_id)
-{
-	struct rocker_fdb_learn_work *lw;
-	enum rocker_of_dpa_table_id goto_tbl =
-		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
-	u32 out_pport = rocker_port->pport;
-	u32 tunnel_id = 0;
-	u32 group_id = ROCKER_GROUP_NONE;
-	bool syncing = !!(rocker_port->brport_flags & BR_LEARNING_SYNC);
-	bool copy_to_cpu = false;
-	int err;
-
-	if (rocker_port_is_bridged(rocker_port))
-		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
-
-	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
-		err = rocker_flow_tbl_bridge(rocker_port, trans, flags, addr,
-					     NULL, vlan_id, tunnel_id, goto_tbl,
-					     group_id, copy_to_cpu);
-		if (err)
-			return err;
-	}
-
-	if (!syncing)
-		return 0;
-
-	if (!rocker_port_is_bridged(rocker_port))
-		return 0;
-
-	lw = rocker_kzalloc(trans, flags, sizeof(*lw));
-	if (!lw)
-		return -ENOMEM;
-
-	INIT_WORK(&lw->work, rocker_port_fdb_learn_work);
-
-	lw->rocker_port = rocker_port;
-	lw->trans = trans;
-	lw->flags = flags;
-	ether_addr_copy(lw->addr, addr);
-	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
-
-	if (switchdev_trans_ph_prepare(trans))
-		rocker_kfree(trans, lw);
-	else
-		schedule_work(&lw->work);
-
-	return 0;
-}
-
-static struct rocker_fdb_tbl_entry *
-rocker_fdb_tbl_find(const struct rocker *rocker,
-		    const struct rocker_fdb_tbl_entry *match)
-{
-	struct rocker_fdb_tbl_entry *found;
-
-	hash_for_each_possible(rocker->fdb_tbl, found, entry, match->key_crc32)
-		if (memcmp(&found->key, &match->key, sizeof(found->key)) == 0)
-			return found;
-
-	return NULL;
-}
-
-static int rocker_port_fdb(struct rocker_port *rocker_port,
-			   struct switchdev_trans *trans,
-			   const unsigned char *addr,
-			   __be16 vlan_id, int flags)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_fdb_tbl_entry *fdb;
-	struct rocker_fdb_tbl_entry *found;
-	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
-	unsigned long lock_flags;
-
-	fdb = rocker_kzalloc(trans, flags, sizeof(*fdb));
-	if (!fdb)
-		return -ENOMEM;
-
-	fdb->learned = (flags & ROCKER_OP_FLAG_LEARNED);
-	fdb->touched = jiffies;
-	fdb->key.rocker_port = rocker_port;
-	ether_addr_copy(fdb->key.addr, addr);
-	fdb->key.vlan_id = vlan_id;
-	fdb->key_crc32 = crc32(~0, &fdb->key, sizeof(fdb->key));
-
-	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
-
-	found = rocker_fdb_tbl_find(rocker, fdb);
-
-	if (found) {
-		found->touched = jiffies;
-		if (removing) {
-			rocker_kfree(trans, fdb);
-			if (!switchdev_trans_ph_prepare(trans))
-				hash_del(&found->entry);
-		}
-	} else if (!removing) {
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_add(rocker->fdb_tbl, &fdb->entry,
-				 fdb->key_crc32);
-	}
-
-	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
-
-	/* Check if adding and already exists, or removing and can't find */
-	if (!found != !removing) {
-		rocker_kfree(trans, fdb);
-		if (!found && removing)
-			return 0;
-		/* Refreshing existing to update aging timers */
-		flags |= ROCKER_OP_FLAG_REFRESH;
-	}
-
-	return rocker_port_fdb_learn(rocker_port, trans, flags, addr, vlan_id);
-}
-
-static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
-				 struct switchdev_trans *trans, int flags)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_fdb_tbl_entry *found;
-	unsigned long lock_flags;
-	struct hlist_node *tmp;
-	int bkt;
-	int err = 0;
-
-	if (rocker_port->stp_state == BR_STATE_LEARNING ||
-	    rocker_port->stp_state == BR_STATE_FORWARDING)
-		return 0;
-
-	flags |= ROCKER_OP_FLAG_REMOVE;
-
-	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
-
-	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
-		if (found->key.rocker_port != rocker_port)
-			continue;
-		if (!found->learned)
-			continue;
-		err = rocker_port_fdb_learn(rocker_port, trans, flags,
-					    found->key.addr,
-					    found->key.vlan_id);
-		if (err)
-			goto err_out;
-		if (!switchdev_trans_ph_prepare(trans))
-			hash_del(&found->entry);
-	}
-
-err_out:
-	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
-
-	return err;
-}
-
-static void rocker_fdb_cleanup(unsigned long data)
-{
-	struct rocker *rocker = (struct rocker *)data;
-	struct rocker_port *rocker_port;
-	struct rocker_fdb_tbl_entry *entry;
-	struct hlist_node *tmp;
-	unsigned long next_timer = jiffies + BR_MIN_AGEING_TIME;
-	unsigned long expires;
-	unsigned long lock_flags;
-	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE |
-		    ROCKER_OP_FLAG_LEARNED;
-	int bkt;
-
-	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
-
-	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, entry, entry) {
-		if (!entry->learned)
-			continue;
-		rocker_port = entry->key.rocker_port;
-		expires = entry->touched + rocker_port->ageing_time;
-		if (time_before_eq(expires, jiffies)) {
-			rocker_port_fdb_learn(rocker_port, NULL,
-					      flags, entry->key.addr,
-					      entry->key.vlan_id);
-			hash_del(&entry->entry);
-		} else if (time_before(expires, next_timer)) {
-			next_timer = expires;
-		}
-	}
-
-	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
-
-	mod_timer(&rocker->fdb_cleanup_timer, round_jiffies_up(next_timer));
-}
-
-static int rocker_port_router_mac(struct rocker_port *rocker_port,
-				  struct switchdev_trans *trans, int flags,
-				  __be16 vlan_id)
-{
-	u32 in_pport_mask = 0xffffffff;
-	__be16 eth_type;
-	const u8 *dst_mac_mask = ff_mac;
-	__be16 vlan_id_mask = htons(0xffff);
-	bool copy_to_cpu = false;
-	int err;
-
-	if (ntohs(vlan_id) == 0)
-		vlan_id = rocker_port->internal_vlan_id;
-
-	eth_type = htons(ETH_P_IP);
-	err = rocker_flow_tbl_term_mac(rocker_port, trans,
-				       rocker_port->pport, in_pport_mask,
-				       eth_type, rocker_port->dev->dev_addr,
-				       dst_mac_mask, vlan_id, vlan_id_mask,
-				       copy_to_cpu, flags);
-	if (err)
-		return err;
-
-	eth_type = htons(ETH_P_IPV6);
-	err = rocker_flow_tbl_term_mac(rocker_port, trans,
-				       rocker_port->pport, in_pport_mask,
-				       eth_type, rocker_port->dev->dev_addr,
-				       dst_mac_mask, vlan_id, vlan_id_mask,
-				       copy_to_cpu, flags);
-
-	return err;
-}
-
-static int rocker_port_fwding(struct rocker_port *rocker_port,
-			      struct switchdev_trans *trans, int flags)
-{
-	bool pop_vlan;
-	u32 out_pport;
-	__be16 vlan_id;
-	u16 vid;
-	int err;
-
-	/* Port will be forwarding-enabled if its STP state is LEARNING
-	 * or FORWARDING.  Traffic from CPU can still egress, regardless of
-	 * port STP state.  Use L2 interface group on port VLANs as a way
-	 * to toggle port forwarding: if forwarding is disabled, L2
-	 * interface group will not exist.
-	 */
-
-	if (rocker_port->stp_state != BR_STATE_LEARNING &&
-	    rocker_port->stp_state != BR_STATE_FORWARDING)
-		flags |= ROCKER_OP_FLAG_REMOVE;
-
-	out_pport = rocker_port->pport;
-	for (vid = 1; vid < VLAN_N_VID; vid++) {
-		if (!test_bit(vid, rocker_port->vlan_bitmap))
-			continue;
-		vlan_id = htons(vid);
-		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
-		err = rocker_group_l2_interface(rocker_port, trans, flags,
-						vlan_id, out_pport, pop_vlan);
-		if (err) {
-			netdev_err(rocker_port->dev,
-				   "Error (%d) port VLAN l2 group for pport %d\n",
-				   err, out_pport);
-			return err;
-		}
-	}
-
-	return 0;
-}
-
-static int rocker_port_stp_update(struct rocker_port *rocker_port,
-				  struct switchdev_trans *trans, int flags,
-				  u8 state)
-{
-	bool want[ROCKER_CTRL_MAX] = { 0, };
-	bool prev_ctrls[ROCKER_CTRL_MAX];
-	u8 uninitialized_var(prev_state);
-	int err;
-	int i;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		memcpy(prev_ctrls, rocker_port->ctrls, sizeof(prev_ctrls));
-		prev_state = rocker_port->stp_state;
-	}
-
-	if (rocker_port->stp_state == state)
-		return 0;
-
-	rocker_port->stp_state = state;
-
-	switch (state) {
-	case BR_STATE_DISABLED:
-		/* port is completely disabled */
-		break;
-	case BR_STATE_LISTENING:
-	case BR_STATE_BLOCKING:
-		want[ROCKER_CTRL_LINK_LOCAL_MCAST] = true;
-		break;
-	case BR_STATE_LEARNING:
-	case BR_STATE_FORWARDING:
-		if (!rocker_port_is_ovsed(rocker_port))
-			want[ROCKER_CTRL_LINK_LOCAL_MCAST] = true;
-		want[ROCKER_CTRL_IPV4_MCAST] = true;
-		want[ROCKER_CTRL_IPV6_MCAST] = true;
-		if (rocker_port_is_bridged(rocker_port))
-			want[ROCKER_CTRL_DFLT_BRIDGING] = true;
-		else if (rocker_port_is_ovsed(rocker_port))
-			want[ROCKER_CTRL_DFLT_OVS] = true;
-		else
-			want[ROCKER_CTRL_LOCAL_ARP] = true;
-		break;
-	}
-
-	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
-		if (want[i] != rocker_port->ctrls[i]) {
-			int ctrl_flags = flags |
-					 (want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
-			err = rocker_port_ctrl(rocker_port, trans, ctrl_flags,
-					       &rocker_ctrls[i]);
-			if (err)
-				goto err_out;
-			rocker_port->ctrls[i] = want[i];
-		}
-	}
-
-	err = rocker_port_fdb_flush(rocker_port, trans, flags);
-	if (err)
-		goto err_out;
-
-	err = rocker_port_fwding(rocker_port, trans, flags);
-
-err_out:
-	if (switchdev_trans_ph_prepare(trans)) {
-		memcpy(rocker_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
-		rocker_port->stp_state = prev_state;
-	}
-
-	return err;
-}
-
-static int rocker_port_fwd_enable(struct rocker_port *rocker_port,
-				  struct switchdev_trans *trans, int flags)
+static int
+rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
+			       struct switchdev_obj_port_fdb *fdb,
+			       switchdev_obj_dump_cb_t *cb)
 {
-	if (rocker_port_is_bridged(rocker_port))
-		/* bridge STP will enable port */
-		return 0;
+	struct rocker_world *world = rocker_port->world;
 
-	/* port is not bridged, so simulate going to FORWARDING state */
-	return rocker_port_stp_update(rocker_port, trans, flags,
-				      BR_STATE_FORWARDING);
+	if (!world->ops->port_obj_fdb_dump)
+		return 0;
+	return world->ops->port_obj_fdb_dump(rocker_port->world_port_priv,
+					     fdb, cb);
 }
 
-static int rocker_port_fwd_disable(struct rocker_port *rocker_port,
-				   struct switchdev_trans *trans, int flags)
+static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
+					   struct net_device *master)
 {
-	if (rocker_port_is_bridged(rocker_port))
-		/* bridge STP will disable port */
-		return 0;
+	struct rocker_world *world = rocker_port->world;
 
-	/* port is not bridged, so simulate going to DISABLED state */
-	return rocker_port_stp_update(rocker_port, trans, flags,
-				      BR_STATE_DISABLED);
+	if (!world->ops->port_master_linked)
+		return 0;
+	return world->ops->port_master_linked(rocker_port->world_port_priv,
+					      master);
 }
 
-static struct rocker_internal_vlan_tbl_entry *
-rocker_internal_vlan_tbl_find(const struct rocker *rocker, int ifindex)
+static int rocker_world_port_master_unlinked(struct rocker_port *rocker_port,
+					     struct net_device *master)
 {
-	struct rocker_internal_vlan_tbl_entry *found;
-
-	hash_for_each_possible(rocker->internal_vlan_tbl, found,
-			       entry, ifindex) {
-		if (found->ifindex == ifindex)
-			return found;
-	}
+	struct rocker_world *world = rocker_port->world;
 
-	return NULL;
+	if (!world->ops->port_master_unlinked)
+		return 0;
+	return world->ops->port_master_unlinked(rocker_port->world_port_priv,
+						master);
 }
 
-static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
-					       int ifindex)
+static int rocker_world_port_neigh_update(struct rocker_port *rocker_port,
+					  struct neighbour *n)
 {
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_internal_vlan_tbl_entry *entry;
-	struct rocker_internal_vlan_tbl_entry *found;
-	unsigned long lock_flags;
-	int i;
+	struct rocker_world *world = rocker_port->world;
 
-	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
-	if (!entry)
+	if (!world->ops->port_neigh_update)
 		return 0;
-
-	entry->ifindex = ifindex;
-
-	spin_lock_irqsave(&rocker->internal_vlan_tbl_lock, lock_flags);
-
-	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
-	if (found) {
-		kfree(entry);
-		goto found;
-	}
-
-	found = entry;
-	hash_add(rocker->internal_vlan_tbl, &found->entry, found->ifindex);
-
-	for (i = 0; i < ROCKER_N_INTERNAL_VLANS; i++) {
-		if (test_and_set_bit(i, rocker->internal_vlan_bitmap))
-			continue;
-		found->vlan_id = htons(ROCKER_INTERNAL_VLAN_ID_BASE + i);
-		goto found;
-	}
-
-	netdev_err(rocker_port->dev, "Out of internal VLAN IDs\n");
-
-found:
-	found->ref_count++;
-	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, lock_flags);
-
-	return found->vlan_id;
+	return world->ops->port_neigh_update(rocker_port->world_port_priv, n);
 }
 
-static void
-rocker_port_internal_vlan_id_put(const struct rocker_port *rocker_port,
-				 int ifindex)
+static int rocker_world_port_neigh_destroy(struct rocker_port *rocker_port,
+					   struct neighbour *n)
 {
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_internal_vlan_tbl_entry *found;
-	unsigned long lock_flags;
-	unsigned long bit;
-
-	spin_lock_irqsave(&rocker->internal_vlan_tbl_lock, lock_flags);
-
-	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
-	if (!found) {
-		netdev_err(rocker_port->dev,
-			   "ifindex (%d) not found in internal VLAN tbl\n",
-			   ifindex);
-		goto not_found;
-	}
-
-	if (--found->ref_count <= 0) {
-		bit = ntohs(found->vlan_id) - ROCKER_INTERNAL_VLAN_ID_BASE;
-		clear_bit(bit, rocker->internal_vlan_bitmap);
-		hash_del(&found->entry);
-		kfree(found);
-	}
-
-not_found:
-	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, lock_flags);
-}
-
-static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
-				struct switchdev_trans *trans, __be32 dst,
-				int dst_len, const struct fib_info *fi,
-				u32 tb_id, int flags)
-{
-	const struct fib_nh *nh;
-	__be16 eth_type = htons(ETH_P_IP);
-	__be32 dst_mask = inet_make_mask(dst_len);
-	__be16 internal_vlan_id = rocker_port->internal_vlan_id;
-	u32 priority = fi->fib_priority;
-	enum rocker_of_dpa_table_id goto_tbl =
-		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
-	u32 group_id;
-	bool nh_on_port;
-	bool has_gw;
-	u32 index;
-	int err;
-
-	/* XXX support ECMP */
-
-	nh = fi->fib_nh;
-	nh_on_port = (fi->fib_dev == rocker_port->dev);
-	has_gw = !!nh->nh_gw;
-
-	if (has_gw && nh_on_port) {
-		err = rocker_port_ipv4_nh(rocker_port, trans, flags,
-					  nh->nh_gw, &index);
-		if (err)
-			return err;
+	struct rocker_world *world = rocker_port->world;
 
-		group_id = ROCKER_GROUP_L3_UNICAST(index);
-	} else {
-		/* Send to CPU for processing */
-		group_id = ROCKER_GROUP_L2_INTERFACE(internal_vlan_id, 0);
-	}
+	if (!world->ops->port_neigh_destroy)
+		return 0;
+	return world->ops->port_neigh_destroy(rocker_port->world_port_priv, n);
+}
 
-	err = rocker_flow_tbl_ucast4_routing(rocker_port, trans, eth_type, dst,
-					     dst_mask, priority, goto_tbl,
-					     group_id, flags);
-	if (err)
-		netdev_err(rocker_port->dev, "Error (%d) IPv4 route %pI4\n",
-			   err, &dst);
+static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
+					      const unsigned char *addr,
+					      __be16 vlan_id)
+{
+	struct rocker_world *world = rocker_port->world;
 
-	return err;
+	if (!world->ops->port_ev_mac_vlan_seen)
+		return 0;
+	return world->ops->port_ev_mac_vlan_seen(rocker_port->world_port_priv,
+						 addr, vlan_id);
 }
 
 /*****************
@@ -4318,10 +1874,6 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_world_port_open;
 	}
 
-	err = rocker_port_fwd_enable(rocker_port, NULL, 0);
-	if (err)
-		goto err_fwd_enable;
-
 	napi_enable(&rocker_port->napi_tx);
 	napi_enable(&rocker_port->napi_rx);
 	if (!dev->proto_down)
@@ -4329,7 +1881,6 @@ static int rocker_port_open(struct net_device *dev)
 	netif_start_queue(dev);
 	return 0;
 
-err_fwd_enable:
 err_world_port_open:
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 err_request_rx_irq:
@@ -4348,8 +1899,6 @@ static int rocker_port_stop(struct net_device *dev)
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
 	rocker_world_port_stop(rocker_port);
-	rocker_port_fwd_disable(rocker_port, NULL,
-				ROCKER_OP_FLAG_NOWAIT);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
 	rocker_port_dma_rings_fini(rocker_port);
@@ -4556,12 +2105,8 @@ static int rocker_port_change_proto_down(struct net_device *dev,
 static void rocker_port_neigh_destroy(struct neighbour *n)
 {
 	struct rocker_port *rocker_port = netdev_priv(n->dev);
-	int flags = ROCKER_OP_FLAG_REMOVE | ROCKER_OP_FLAG_NOWAIT;
-	__be32 ip_addr = *(__be32 *)n->primary_key;
 	int err;
 
-	rocker_port_ipv4_neigh(rocker_port, NULL,
-			       flags, ip_addr, n->ha);
 	err = rocker_world_port_neigh_destroy(rocker_port, n);
 	if (err)
 		netdev_warn(rocker_port->dev, "failed to handle neigh destroy (err %d)\n",
@@ -4602,7 +2147,6 @@ static int rocker_port_attr_get(struct net_device *dev,
 		memcpy(&attr->u.ppid.id, &rocker->hw.id, attr->u.ppid.id_len);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
-		attr->u.brport_flags = rocker_port->brport_flags;
 		err = rocker_world_port_attr_bridge_flags_get(rocker_port,
 							      &attr->u.brport_flags);
 		break;
@@ -4613,26 +2157,6 @@ static int rocker_port_attr_get(struct net_device *dev,
 	return err;
 }
 
-static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
-					struct switchdev_trans *trans,
-					unsigned long brport_flags)
-{
-	unsigned long orig_flags;
-	int err = 0;
-
-	orig_flags = rocker_port->brport_flags;
-	rocker_port->brport_flags = brport_flags;
-	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING &&
-	    !switchdev_trans_ph_prepare(trans))
-		err = rocker_port_set_learning(rocker_port,
-					       !!(rocker_port->brport_flags & BR_LEARNING));
-
-	if (switchdev_trans_ph_prepare(trans))
-		rocker_port->brport_flags = orig_flags;
-
-	return err;
-}
-
 static int rocker_port_attr_set(struct net_device *dev,
 				struct switchdev_attr *attr,
 				struct switchdev_trans *trans)
@@ -4642,20 +2166,11 @@ static int rocker_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, trans,
-					     ROCKER_OP_FLAG_NOWAIT,
-					     attr->u.stp_state);
-		if (err)
-			break;
 		err = rocker_world_port_attr_stp_state_set(rocker_port,
 							   attr->u.stp_state,
 							   trans);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
-		err = rocker_port_brport_flags_set(rocker_port, trans,
-						   attr->u.brport_flags);
-		if (err)
-			break;
 		err = rocker_world_port_attr_bridge_flags_set(rocker_port,
 							      attr->u.brport_flags,
 							      trans);
@@ -4668,90 +2183,25 @@ static int rocker_port_attr_set(struct net_device *dev,
 	return err;
 }
 
-static int rocker_port_vlan_add(struct rocker_port *rocker_port,
-				struct switchdev_trans *trans,
-				u16 vid, u16 flags)
-{
-	int err;
-
-	/* XXX deal with flags for PVID and untagged */
-
-	err = rocker_port_vlan(rocker_port, trans, 0, vid);
-	if (err)
-		return err;
-
-	err = rocker_port_router_mac(rocker_port, trans, 0, htons(vid));
-	if (err)
-		rocker_port_vlan(rocker_port, trans,
-				 ROCKER_OP_FLAG_REMOVE, vid);
-
-	return err;
-}
-
-static int rocker_port_vlans_add(struct rocker_port *rocker_port,
-				 struct switchdev_trans *trans,
-				 const struct switchdev_obj_port_vlan *vlan)
-{
-	u16 vid;
-	int err;
-
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = rocker_port_vlan_add(rocker_port, trans,
-					   vid, vlan->flags);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
-
-static int rocker_port_fdb_add(struct rocker_port *rocker_port,
-			       struct switchdev_trans *trans,
-			       const struct switchdev_obj_port_fdb *fdb)
-{
-	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
-	int flags = 0;
-
-	if (!rocker_port_is_bridged(rocker_port))
-		return -EINVAL;
-
-	return rocker_port_fdb(rocker_port, trans, fdb->addr, vlan_id, flags);
-}
-
 static int rocker_port_obj_add(struct net_device *dev,
 			       const struct switchdev_obj *obj,
 			       struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, trans,
-					    SWITCHDEV_OBJ_PORT_VLAN(obj));
-		if (err)
-			break;
 		err = rocker_world_port_obj_vlan_add(rocker_port,
 						     SWITCHDEV_OBJ_PORT_VLAN(obj),
 						     trans);
 		break;
 	case SWITCHDEV_OBJ_ID_IPV4_FIB:
-		fib4 = SWITCHDEV_OBJ_IPV4_FIB(obj);
-		err = rocker_port_fib_ipv4(rocker_port, trans,
-					   htonl(fib4->dst), fib4->dst_len,
-					   fib4->fi, fib4->tb_id, 0);
-		if (err)
-			break;
 		err = rocker_world_port_obj_fib4_add(rocker_port,
 						     SWITCHDEV_OBJ_IPV4_FIB(obj),
 						     trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, trans,
-					  SWITCHDEV_OBJ_PORT_FDB(obj));
-		if (err)
-			break;
 		err = rocker_world_port_obj_fdb_add(rocker_port,
 						    SWITCHDEV_OBJ_PORT_FDB(obj),
 						    trans);
@@ -4764,80 +2214,22 @@ static int rocker_port_obj_add(struct net_device *dev,
 	return err;
 }
 
-static int rocker_port_vlan_del(struct rocker_port *rocker_port,
-				u16 vid, u16 flags)
-{
-	int err;
-
-	err = rocker_port_router_mac(rocker_port, NULL,
-				     ROCKER_OP_FLAG_REMOVE, htons(vid));
-	if (err)
-		return err;
-
-	return rocker_port_vlan(rocker_port, NULL,
-				ROCKER_OP_FLAG_REMOVE, vid);
-}
-
-static int rocker_port_vlans_del(struct rocker_port *rocker_port,
-				 const struct switchdev_obj_port_vlan *vlan)
-{
-	u16 vid;
-	int err;
-
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		err = rocker_port_vlan_del(rocker_port, vid, vlan->flags);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
-
-static int rocker_port_fdb_del(struct rocker_port *rocker_port,
-			       struct switchdev_trans *trans,
-			       const struct switchdev_obj_port_fdb *fdb)
-{
-	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
-	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
-
-	if (!rocker_port_is_bridged(rocker_port))
-		return -EINVAL;
-
-	return rocker_port_fdb(rocker_port, trans, fdb->addr, vlan_id, flags);
-}
-
 static int rocker_port_obj_del(struct net_device *dev,
 			       const struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = rocker_port_vlans_del(rocker_port,
-					    SWITCHDEV_OBJ_PORT_VLAN(obj));
-		if (err)
-			break;
 		err = rocker_world_port_obj_vlan_del(rocker_port,
 						     SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_IPV4_FIB:
-		fib4 = SWITCHDEV_OBJ_IPV4_FIB(obj);
-		err = rocker_port_fib_ipv4(rocker_port, NULL,
-					   htonl(fib4->dst), fib4->dst_len,
-					   fib4->fi, fib4->tb_id,
-					   ROCKER_OP_FLAG_REMOVE);
-		if (err)
-			break;
 		err = rocker_world_port_obj_fib4_del(rocker_port,
 						     SWITCHDEV_OBJ_IPV4_FIB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = rocker_port_fdb_del(rocker_port, NULL,
-					  SWITCHDEV_OBJ_PORT_FDB(obj));
-		if (err)
-			break;
 		err = rocker_world_port_obj_fdb_del(rocker_port,
 						    SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
@@ -4849,56 +2241,6 @@ static int rocker_port_obj_del(struct net_device *dev,
 	return err;
 }
 
-static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
-				struct switchdev_obj_port_fdb *fdb,
-				switchdev_obj_dump_cb_t *cb)
-{
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_fdb_tbl_entry *found;
-	struct hlist_node *tmp;
-	unsigned long lock_flags;
-	int bkt;
-	int err = 0;
-
-	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
-	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
-		if (found->key.rocker_port != rocker_port)
-			continue;
-		fdb->addr = found->key.addr;
-		fdb->ndm_state = NUD_REACHABLE;
-		fdb->vid = rocker_port_vlan_to_vid(rocker_port,
-						   found->key.vlan_id);
-		err = cb(&fdb->obj);
-		if (err)
-			break;
-	}
-	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
-
-	return err;
-}
-
-static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
-				 struct switchdev_obj_port_vlan *vlan,
-				 switchdev_obj_dump_cb_t *cb)
-{
-	u16 vid;
-	int err = 0;
-
-	for (vid = 1; vid < VLAN_N_VID; vid++) {
-		if (!test_bit(vid, rocker_port->vlan_bitmap))
-			continue;
-		vlan->flags = 0;
-		if (rocker_vlan_id_is_internal(htons(vid)))
-			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-		vlan->vid_begin = vlan->vid_end = vid;
-		err = cb(&vlan->obj);
-		if (err)
-			break;
-	}
-
-	return err;
-}
-
 static int rocker_port_obj_dump(struct net_device *dev,
 				struct switchdev_obj *obj,
 				switchdev_obj_dump_cb_t *cb)
@@ -4908,19 +2250,11 @@ static int rocker_port_obj_dump(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = rocker_port_fdb_dump(rocker_port,
-					   SWITCHDEV_OBJ_PORT_FDB(obj), cb);
-		if (err)
-			break;
 		err = rocker_world_port_obj_fdb_dump(rocker_port,
 						     SWITCHDEV_OBJ_PORT_FDB(obj),
 						     cb);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = rocker_port_vlan_dump(rocker_port,
-					    SWITCHDEV_OBJ_PORT_VLAN(obj), cb);
-		if (err)
-			break;
 		err = rocker_world_port_obj_vlan_dump(rocker_port,
 						      SWITCHDEV_OBJ_PORT_VLAN(obj),
 						      cb);
@@ -5258,7 +2592,6 @@ static void rocker_remove_ports(const struct rocker *rocker)
 		rocker_port = rocker->ports[i];
 		if (!rocker_port)
 			continue;
-		rocker_port_ig_tbl(rocker_port, NULL, ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
 		rocker_port_change_world(rocker_port, NULL);
 		free_netdev(rocker_port->dev);
@@ -5285,7 +2618,6 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	const struct pci_dev *pdev = rocker->pdev;
 	struct rocker_port *rocker_port;
 	struct net_device *dev;
-	u16 untagged_vid = 0;
 	int err;
 
 	dev = alloc_etherdev(sizeof(struct rocker_port));
@@ -5296,8 +2628,6 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->rocker = rocker;
 	rocker_port->port_number = port_number;
 	rocker_port->pport = port_number + 1;
-	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
-	rocker_port->ageing_time = BR_DEFAULT_AGEING_TIME;
 
 	rocker_port_dev_addr_init(rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
@@ -5323,34 +2653,8 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 		goto err_register_netdev;
 	}
 	rocker->ports[port_number] = rocker_port;
-
-	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
-
-	rocker_port_set_learning(rocker_port,
-				 !!(rocker_port->brport_flags & BR_LEARNING));
-
-	err = rocker_port_ig_tbl(rocker_port, NULL, 0);
-	if (err) {
-		netdev_err(rocker_port->dev, "install ig port table failed\n");
-		goto err_port_ig_tbl;
-	}
-
-	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
-
-	err = rocker_port_vlan_add(rocker_port, NULL, untagged_vid, 0);
-	if (err) {
-		netdev_err(rocker_port->dev, "install untagged VLAN failed\n");
-		goto err_untagged_vlan;
-	}
-
 	return 0;
 
-err_untagged_vlan:
-	rocker_port_ig_tbl(rocker_port, NULL, ROCKER_OP_FLAG_REMOVE);
-err_port_ig_tbl:
-	rocker->ports[port_number] = NULL;
-	unregister_netdev(dev);
 err_register_netdev:
 	rocker_port_change_world(rocker_port, NULL);
 err_port_change_world:
@@ -5513,16 +2817,6 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	rocker->hw.id = rocker_read64(rocker, SWITCH_ID);
 
-	err = rocker_init_tbls(rocker);
-	if (err) {
-		dev_err(&pdev->dev, "cannot init rocker tables\n");
-		goto err_init_tbls;
-	}
-
-	setup_timer(&rocker->fdb_cleanup_timer, rocker_fdb_cleanup,
-		    (unsigned long) rocker);
-	mod_timer(&rocker->fdb_cleanup_timer, jiffies);
-
 	err = rocker_probe_ports(rocker);
 	if (err) {
 		dev_err(&pdev->dev, "failed to probe ports\n");
@@ -5535,9 +2829,6 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	return 0;
 
 err_probe_ports:
-	del_timer_sync(&rocker->fdb_cleanup_timer);
-	rocker_free_tbls(rocker);
-err_init_tbls:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
 err_request_event_irq:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD), rocker);
@@ -5563,8 +2854,6 @@ static void rocker_remove(struct pci_dev *pdev)
 {
 	struct rocker *rocker = pci_get_drvdata(pdev);
 
-	del_timer_sync(&rocker->fdb_cleanup_timer);
-	rocker_free_tbls(rocker);
 	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
 	rocker_remove_ports(rocker);
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
@@ -5593,101 +2882,6 @@ static bool rocker_port_dev_check(const struct net_device *dev)
 	return dev->netdev_ops == &rocker_port_netdev_ops;
 }
 
-static int rocker_port_bridge_join(struct rocker_port *rocker_port,
-				   struct net_device *bridge)
-{
-	u16 untagged_vid = 0;
-	int err;
-
-	/* Port is joining bridge, so the internal VLAN for the
-	 * port is going to change to the bridge internal VLAN.
-	 * Let's remove untagged VLAN (vid=0) from port and
-	 * re-add once internal VLAN has changed.
-	 */
-
-	err = rocker_port_vlan_del(rocker_port, untagged_vid, 0);
-	if (err)
-		return err;
-
-	rocker_port_internal_vlan_id_put(rocker_port,
-					 rocker_port->dev->ifindex);
-	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port, bridge->ifindex);
-
-	rocker_port->bridge_dev = bridge;
-	switchdev_port_fwd_mark_set(rocker_port->dev, bridge, true);
-
-	return rocker_port_vlan_add(rocker_port, NULL, untagged_vid, 0);
-}
-
-static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
-{
-	u16 untagged_vid = 0;
-	int err;
-
-	err = rocker_port_vlan_del(rocker_port, untagged_vid, 0);
-	if (err)
-		return err;
-
-	rocker_port_internal_vlan_id_put(rocker_port,
-					 rocker_port->bridge_dev->ifindex);
-	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port,
-						 rocker_port->dev->ifindex);
-
-	switchdev_port_fwd_mark_set(rocker_port->dev, rocker_port->bridge_dev,
-				    false);
-	rocker_port->bridge_dev = NULL;
-
-	err = rocker_port_vlan_add(rocker_port, NULL, untagged_vid, 0);
-	if (err)
-		return err;
-
-	if (rocker_port->dev->flags & IFF_UP)
-		err = rocker_port_fwd_enable(rocker_port, NULL, 0);
-
-	return err;
-}
-
-
-static int rocker_port_ovs_changed(struct rocker_port *rocker_port,
-				   struct net_device *master)
-{
-	int err;
-
-	rocker_port->bridge_dev = master;
-
-	err = rocker_port_fwd_disable(rocker_port, NULL, 0);
-	if (err)
-		return err;
-	err = rocker_port_fwd_enable(rocker_port, NULL, 0);
-
-	return err;
-}
-
-static int rocker_port_master_linked(struct rocker_port *rocker_port,
-				     struct net_device *master)
-{
-	int err = 0;
-
-	if (netif_is_bridge_master(master))
-		err = rocker_port_bridge_join(rocker_port, master);
-	else if (netif_is_ovs_master(master))
-		err = rocker_port_ovs_changed(rocker_port, master);
-	return err;
-}
-
-static int rocker_port_master_unlinked(struct rocker_port *rocker_port)
-{
-	int err = 0;
-
-	if (rocker_port_is_bridged(rocker_port))
-		err = rocker_port_bridge_leave(rocker_port);
-	else if (rocker_port_is_ovsed(rocker_port))
-		err = rocker_port_ovs_changed(rocker_port, NULL);
-	return err;
-}
-
 static int rocker_netdevice_event(struct notifier_block *unused,
 				  unsigned long event, void *ptr)
 {
@@ -5711,23 +2905,13 @@ static int rocker_netdevice_event(struct notifier_block *unused,
 			if (err)
 				netdev_warn(dev, "failed to reflect master linked (err %d)\n",
 					    err);
-			err = rocker_port_master_linked(rocker_port,
-							info->upper_dev);
-			if (err)
-				netdev_warn(dev, "failed to reflect master linked (err %d)\n",
-					    err);
 		} else {
 			err = rocker_world_port_master_unlinked(rocker_port,
 								info->upper_dev);
 			if (err)
 				netdev_warn(dev, "failed to reflect master unlinked (err %d)\n",
 					    err);
-			err = rocker_port_master_unlinked(rocker_port);
-			if (err)
-				netdev_warn(dev, "failed to reflect master unlinked (err %d)\n",
-					    err);
 		}
-		break;
 	}
 out:
 	return NOTIFY_DONE;
@@ -5741,16 +2925,6 @@ static struct notifier_block rocker_netdevice_nb __read_mostly = {
  * Net event notifier event handler
  ************************************/
 
-static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = (n->nud_state & NUD_VALID ? 0 : ROCKER_OP_FLAG_REMOVE) |
-		    ROCKER_OP_FLAG_NOWAIT;
-	__be32 ip_addr = *(__be32 *)n->primary_key;
-
-	return rocker_port_ipv4_neigh(rocker_port, NULL, flags, ip_addr, n->ha);
-}
-
 static int rocker_netevent_event(struct notifier_block *unused,
 				 unsigned long event, void *ptr)
 {
@@ -5771,11 +2945,6 @@ static int rocker_netevent_event(struct notifier_block *unused,
 		if (err)
 			netdev_warn(dev, "failed to handle neigh update (err %d)\n",
 				    err);
-		err = rocker_neigh_update(dev, n);
-		if (err)
-			netdev_warn(dev,
-				    "failed to handle neigh update (err %d)\n",
-				    err);
 		break;
 	}
 
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index e048b8b..16aeabe 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -11,17 +11,2917 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/spinlock.h>
+#include <linux/hashtable.h>
+#include <linux/crc32.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/if_bridge.h>
+#include <net/neighbour.h>
+#include <net/switchdev.h>
+#include <net/ip_fib.h>
+#include <net/arp.h>
+
 #include "rocker.h"
+#include "rocker_tlv.h"
+
+struct ofdpa_flow_tbl_key {
+	u32 priority;
+	enum rocker_of_dpa_table_id tbl_id;
+	union {
+		struct {
+			u32 in_pport;
+			u32 in_pport_mask;
+			enum rocker_of_dpa_table_id goto_tbl;
+		} ig_port;
+		struct {
+			u32 in_pport;
+			__be16 vlan_id;
+			__be16 vlan_id_mask;
+			enum rocker_of_dpa_table_id goto_tbl;
+			bool untagged;
+			__be16 new_vlan_id;
+		} vlan;
+		struct {
+			u32 in_pport;
+			u32 in_pport_mask;
+			__be16 eth_type;
+			u8 eth_dst[ETH_ALEN];
+			u8 eth_dst_mask[ETH_ALEN];
+			__be16 vlan_id;
+			__be16 vlan_id_mask;
+			enum rocker_of_dpa_table_id goto_tbl;
+			bool copy_to_cpu;
+		} term_mac;
+		struct {
+			__be16 eth_type;
+			__be32 dst4;
+			__be32 dst4_mask;
+			enum rocker_of_dpa_table_id goto_tbl;
+			u32 group_id;
+		} ucast_routing;
+		struct {
+			u8 eth_dst[ETH_ALEN];
+			u8 eth_dst_mask[ETH_ALEN];
+			int has_eth_dst;
+			int has_eth_dst_mask;
+			__be16 vlan_id;
+			u32 tunnel_id;
+			enum rocker_of_dpa_table_id goto_tbl;
+			u32 group_id;
+			bool copy_to_cpu;
+		} bridge;
+		struct {
+			u32 in_pport;
+			u32 in_pport_mask;
+			u8 eth_src[ETH_ALEN];
+			u8 eth_src_mask[ETH_ALEN];
+			u8 eth_dst[ETH_ALEN];
+			u8 eth_dst_mask[ETH_ALEN];
+			__be16 eth_type;
+			__be16 vlan_id;
+			__be16 vlan_id_mask;
+			u8 ip_proto;
+			u8 ip_proto_mask;
+			u8 ip_tos;
+			u8 ip_tos_mask;
+			u32 group_id;
+		} acl;
+	};
+};
+
+struct ofdpa_flow_tbl_entry {
+	struct hlist_node entry;
+	u32 cmd;
+	u64 cookie;
+	struct ofdpa_flow_tbl_key key;
+	size_t key_len;
+	u32 key_crc32; /* key */
+};
+
+struct ofdpa_group_tbl_entry {
+	struct hlist_node entry;
+	u32 cmd;
+	u32 group_id; /* key */
+	u16 group_count;
+	u32 *group_ids;
+	union {
+		struct {
+			u8 pop_vlan;
+		} l2_interface;
+		struct {
+			u8 eth_src[ETH_ALEN];
+			u8 eth_dst[ETH_ALEN];
+			__be16 vlan_id;
+			u32 group_id;
+		} l2_rewrite;
+		struct {
+			u8 eth_src[ETH_ALEN];
+			u8 eth_dst[ETH_ALEN];
+			__be16 vlan_id;
+			bool ttl_check;
+			u32 group_id;
+		} l3_unicast;
+	};
+};
+
+struct ofdpa_fdb_tbl_entry {
+	struct hlist_node entry;
+	u32 key_crc32; /* key */
+	bool learned;
+	unsigned long touched;
+	struct ofdpa_fdb_tbl_key {
+		struct ofdpa_port *ofdpa_port;
+		u8 addr[ETH_ALEN];
+		__be16 vlan_id;
+	} key;
+};
+
+struct ofdpa_internal_vlan_tbl_entry {
+	struct hlist_node entry;
+	int ifindex; /* key */
+	u32 ref_count;
+	__be16 vlan_id;
+};
+
+struct ofdpa_neigh_tbl_entry {
+	struct hlist_node entry;
+	__be32 ip_addr; /* key */
+	struct net_device *dev;
+	u32 ref_count;
+	u32 index;
+	u8 eth_dst[ETH_ALEN];
+	bool ttl_check;
+};
+
+enum {
+	OFDPA_CTRL_LINK_LOCAL_MCAST,
+	OFDPA_CTRL_LOCAL_ARP,
+	OFDPA_CTRL_IPV4_MCAST,
+	OFDPA_CTRL_IPV6_MCAST,
+	OFDPA_CTRL_DFLT_BRIDGING,
+	OFDPA_CTRL_DFLT_OVS,
+	OFDPA_CTRL_MAX,
+};
+
+#define OFDPA_INTERNAL_VLAN_ID_BASE	0x0f00
+#define OFDPA_N_INTERNAL_VLANS		255
+#define OFDPA_VLAN_BITMAP_LEN		BITS_TO_LONGS(VLAN_N_VID)
+#define OFDPA_INTERNAL_VLAN_BITMAP_LEN	BITS_TO_LONGS(OFDPA_N_INTERNAL_VLANS)
+#define OFDPA_UNTAGGED_VID 0
 
 struct ofdpa {
+	struct rocker *rocker;
+	DECLARE_HASHTABLE(flow_tbl, 16);
+	spinlock_t flow_tbl_lock;		/* for flow tbl accesses */
+	u64 flow_tbl_next_cookie;
+	DECLARE_HASHTABLE(group_tbl, 16);
+	spinlock_t group_tbl_lock;		/* for group tbl accesses */
+	struct timer_list fdb_cleanup_timer;
+	DECLARE_HASHTABLE(fdb_tbl, 16);
+	spinlock_t fdb_tbl_lock;		/* for fdb tbl accesses */
+	unsigned long internal_vlan_bitmap[OFDPA_INTERNAL_VLAN_BITMAP_LEN];
+	DECLARE_HASHTABLE(internal_vlan_tbl, 8);
+	spinlock_t internal_vlan_tbl_lock;	/* for vlan tbl accesses */
+	DECLARE_HASHTABLE(neigh_tbl, 16);
+	spinlock_t neigh_tbl_lock;		/* for neigh tbl accesses */
+	u32 neigh_tbl_next_index;
 };
 
 struct ofdpa_port {
+	struct ofdpa *ofdpa;
+	struct rocker_port *rocker_port;
+	struct net_device *dev;
+	u32 pport;
+	struct net_device *bridge_dev;
+	__be16 internal_vlan_id;
+	int stp_state;
+	u32 brport_flags;
+	unsigned long ageing_time;
+	bool ctrls[OFDPA_CTRL_MAX];
+	unsigned long vlan_bitmap[OFDPA_VLAN_BITMAP_LEN];
 };
 
+static const u8 zero_mac[ETH_ALEN]   = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
+static const u8 ff_mac[ETH_ALEN]     = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+static const u8 ll_mac[ETH_ALEN]     = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
+static const u8 ll_mask[ETH_ALEN]    = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0 };
+static const u8 mcast_mac[ETH_ALEN]  = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
+static const u8 ipv4_mcast[ETH_ALEN] = { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x00 };
+static const u8 ipv4_mask[ETH_ALEN]  = { 0xff, 0xff, 0xff, 0x80, 0x00, 0x00 };
+static const u8 ipv6_mcast[ETH_ALEN] = { 0x33, 0x33, 0x00, 0x00, 0x00, 0x00 };
+static const u8 ipv6_mask[ETH_ALEN]  = { 0xff, 0xff, 0x00, 0x00, 0x00, 0x00 };
+
+/* Rocker priority levels for flow table entries.  Higher
+ * priority match takes precedence over lower priority match.
+ */
+
+enum {
+	OFDPA_PRIORITY_UNKNOWN = 0,
+	OFDPA_PRIORITY_IG_PORT = 1,
+	OFDPA_PRIORITY_VLAN = 1,
+	OFDPA_PRIORITY_TERM_MAC_UCAST = 0,
+	OFDPA_PRIORITY_TERM_MAC_MCAST = 1,
+	OFDPA_PRIORITY_BRIDGING_VLAN_DFLT_EXACT = 1,
+	OFDPA_PRIORITY_BRIDGING_VLAN_DFLT_WILD = 2,
+	OFDPA_PRIORITY_BRIDGING_VLAN = 3,
+	OFDPA_PRIORITY_BRIDGING_TENANT_DFLT_EXACT = 1,
+	OFDPA_PRIORITY_BRIDGING_TENANT_DFLT_WILD = 2,
+	OFDPA_PRIORITY_BRIDGING_TENANT = 3,
+	OFDPA_PRIORITY_ACL_CTRL = 3,
+	OFDPA_PRIORITY_ACL_NORMAL = 2,
+	OFDPA_PRIORITY_ACL_DFLT = 1,
+};
+
+static bool ofdpa_vlan_id_is_internal(__be16 vlan_id)
+{
+	u16 start = OFDPA_INTERNAL_VLAN_ID_BASE;
+	u16 end = 0xffe;
+	u16 _vlan_id = ntohs(vlan_id);
+
+	return (_vlan_id >= start && _vlan_id <= end);
+}
+
+static __be16 ofdpa_port_vid_to_vlan(const struct ofdpa_port *ofdpa_port,
+				     u16 vid, bool *pop_vlan)
+{
+	__be16 vlan_id;
+
+	if (pop_vlan)
+		*pop_vlan = false;
+	vlan_id = htons(vid);
+	if (!vlan_id) {
+		vlan_id = ofdpa_port->internal_vlan_id;
+		if (pop_vlan)
+			*pop_vlan = true;
+	}
+
+	return vlan_id;
+}
+
+static u16 ofdpa_port_vlan_to_vid(const struct ofdpa_port *ofdpa_port,
+				  __be16 vlan_id)
+{
+	if (ofdpa_vlan_id_is_internal(vlan_id))
+		return 0;
+
+	return ntohs(vlan_id);
+}
+
+static bool ofdpa_port_is_slave(const struct ofdpa_port *ofdpa_port,
+				const char *kind)
+{
+	return ofdpa_port->bridge_dev &&
+		!strcmp(ofdpa_port->bridge_dev->rtnl_link_ops->kind, kind);
+}
+
+static bool ofdpa_port_is_bridged(const struct ofdpa_port *ofdpa_port)
+{
+	return ofdpa_port_is_slave(ofdpa_port, "bridge");
+}
+
+static bool ofdpa_port_is_ovsed(const struct ofdpa_port *ofdpa_port)
+{
+	return ofdpa_port_is_slave(ofdpa_port, "openvswitch");
+}
+
+#define OFDPA_OP_FLAG_REMOVE		BIT(0)
+#define OFDPA_OP_FLAG_NOWAIT		BIT(1)
+#define OFDPA_OP_FLAG_LEARNED		BIT(2)
+#define OFDPA_OP_FLAG_REFRESH		BIT(3)
+
+static bool ofdpa_flags_nowait(int flags)
+{
+	return flags & OFDPA_OP_FLAG_NOWAIT;
+}
+
+static void *__ofdpa_mem_alloc(struct switchdev_trans *trans, int flags,
+			       size_t size)
+{
+	struct switchdev_trans_item *elem = NULL;
+	gfp_t gfp_flags = (flags & OFDPA_OP_FLAG_NOWAIT) ?
+			  GFP_ATOMIC : GFP_KERNEL;
+
+	/* If in transaction prepare phase, allocate the memory
+	 * and enqueue it on a transaction.  If in transaction
+	 * commit phase, dequeue the memory from the transaction
+	 * rather than re-allocating the memory.  The idea is the
+	 * driver code paths for prepare and commit are identical
+	 * so the memory allocated in the prepare phase is the
+	 * memory used in the commit phase.
+	 */
+
+	if (!trans) {
+		elem = kzalloc(size + sizeof(*elem), gfp_flags);
+	} else if (switchdev_trans_ph_prepare(trans)) {
+		elem = kzalloc(size + sizeof(*elem), gfp_flags);
+		if (!elem)
+			return NULL;
+		switchdev_trans_item_enqueue(trans, elem, kfree, elem);
+	} else {
+		elem = switchdev_trans_item_dequeue(trans);
+	}
+
+	return elem ? elem + 1 : NULL;
+}
+
+static void *ofdpa_kzalloc(struct switchdev_trans *trans, int flags,
+			   size_t size)
+{
+	return __ofdpa_mem_alloc(trans, flags, size);
+}
+
+static void *ofdpa_kcalloc(struct switchdev_trans *trans, int flags,
+			   size_t n, size_t size)
+{
+	return __ofdpa_mem_alloc(trans, flags, n * size);
+}
+
+static void ofdpa_kfree(struct switchdev_trans *trans, const void *mem)
+{
+	struct switchdev_trans_item *elem;
+
+	/* Frees are ignored if in transaction prepare phase.  The
+	 * memory remains on the per-port list until freed in the
+	 * commit phase.
+	 */
+
+	if (switchdev_trans_ph_prepare(trans))
+		return;
+
+	elem = (struct switchdev_trans_item *) mem - 1;
+	kfree(elem);
+}
+
+/*************************************************************
+ * Flow, group, FDB, internal VLAN and neigh command prepares
+ *************************************************************/
+
+static int
+ofdpa_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
+			       const struct ofdpa_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
+			       entry->key.ig_port.in_pport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
+			       entry->key.ig_port.in_pport_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.ig_port.goto_tbl))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
+			    const struct ofdpa_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
+			       entry->key.vlan.in_pport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->key.vlan.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+				entry->key.vlan.vlan_id_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.vlan.goto_tbl))
+		return -EMSGSIZE;
+	if (entry->key.vlan.untagged &&
+	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_NEW_VLAN_ID,
+				entry->key.vlan.new_vlan_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
+				const struct ofdpa_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
+			       entry->key.term_mac.in_pport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
+			       entry->key.term_mac.in_pport_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+				entry->key.term_mac.eth_type))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
+			   ETH_ALEN, entry->key.term_mac.eth_dst))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
+			   ETH_ALEN, entry->key.term_mac.eth_dst_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->key.term_mac.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+				entry->key.term_mac.vlan_id_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.term_mac.goto_tbl))
+		return -EMSGSIZE;
+	if (entry->key.term_mac.copy_to_cpu &&
+	    rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_COPY_CPU_ACTION,
+			      entry->key.term_mac.copy_to_cpu))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_flow_tbl_add_ucast_routing(struct rocker_desc_info *desc_info,
+				     const struct ofdpa_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+				entry->key.ucast_routing.eth_type))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be32(desc_info, ROCKER_TLV_OF_DPA_DST_IP,
+				entry->key.ucast_routing.dst4))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be32(desc_info, ROCKER_TLV_OF_DPA_DST_IP_MASK,
+				entry->key.ucast_routing.dst4_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.ucast_routing.goto_tbl))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->key.ucast_routing.group_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
+			      const struct ofdpa_flow_tbl_entry *entry)
+{
+	if (entry->key.bridge.has_eth_dst &&
+	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
+			   ETH_ALEN, entry->key.bridge.eth_dst))
+		return -EMSGSIZE;
+	if (entry->key.bridge.has_eth_dst_mask &&
+	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
+			   ETH_ALEN, entry->key.bridge.eth_dst_mask))
+		return -EMSGSIZE;
+	if (entry->key.bridge.vlan_id &&
+	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->key.bridge.vlan_id))
+		return -EMSGSIZE;
+	if (entry->key.bridge.tunnel_id &&
+	    rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_TUNNEL_ID,
+			       entry->key.bridge.tunnel_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.bridge.goto_tbl))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->key.bridge.group_id))
+		return -EMSGSIZE;
+	if (entry->key.bridge.copy_to_cpu &&
+	    rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_COPY_CPU_ACTION,
+			      entry->key.bridge.copy_to_cpu))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
+			   const struct ofdpa_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
+			       entry->key.acl.in_pport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
+			       entry->key.acl.in_pport_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
+			   ETH_ALEN, entry->key.acl.eth_src))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC_MASK,
+			   ETH_ALEN, entry->key.acl.eth_src_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
+			   ETH_ALEN, entry->key.acl.eth_dst))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
+			   ETH_ALEN, entry->key.acl.eth_dst_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+				entry->key.acl.eth_type))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->key.acl.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+				entry->key.acl.vlan_id_mask))
+		return -EMSGSIZE;
+
+	switch (ntohs(entry->key.acl.eth_type)) {
+	case ETH_P_IP:
+	case ETH_P_IPV6:
+		if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_IP_PROTO,
+				      entry->key.acl.ip_proto))
+			return -EMSGSIZE;
+		if (rocker_tlv_put_u8(desc_info,
+				      ROCKER_TLV_OF_DPA_IP_PROTO_MASK,
+				      entry->key.acl.ip_proto_mask))
+			return -EMSGSIZE;
+		if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_IP_DSCP,
+				      entry->key.acl.ip_tos & 0x3f))
+			return -EMSGSIZE;
+		if (rocker_tlv_put_u8(desc_info,
+				      ROCKER_TLV_OF_DPA_IP_DSCP_MASK,
+				      entry->key.acl.ip_tos_mask & 0x3f))
+			return -EMSGSIZE;
+		if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_IP_ECN,
+				      (entry->key.acl.ip_tos & 0xc0) >> 6))
+			return -EMSGSIZE;
+		if (rocker_tlv_put_u8(desc_info,
+				      ROCKER_TLV_OF_DPA_IP_ECN_MASK,
+				      (entry->key.acl.ip_tos_mask & 0xc0) >> 6))
+			return -EMSGSIZE;
+		break;
+	}
+
+	if (entry->key.acl.group_id != ROCKER_GROUP_NONE &&
+	    rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->key.acl.group_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int ofdpa_cmd_flow_tbl_add(const struct rocker_port *rocker_port,
+				  struct rocker_desc_info *desc_info,
+				  void *priv)
+{
+	const struct ofdpa_flow_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+	int err = 0;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_TABLE_ID,
+			       entry->key.tbl_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_PRIORITY,
+			       entry->key.priority))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_HARDTIME, 0))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u64(desc_info, ROCKER_TLV_OF_DPA_COOKIE,
+			       entry->cookie))
+		return -EMSGSIZE;
+
+	switch (entry->key.tbl_id) {
+	case ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT:
+		err = ofdpa_cmd_flow_tbl_add_ig_port(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_VLAN:
+		err = ofdpa_cmd_flow_tbl_add_vlan(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC:
+		err = ofdpa_cmd_flow_tbl_add_term_mac(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING:
+		err = ofdpa_cmd_flow_tbl_add_ucast_routing(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_BRIDGING:
+		err = ofdpa_cmd_flow_tbl_add_bridge(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_ACL_POLICY:
+		err = ofdpa_cmd_flow_tbl_add_acl(desc_info, entry);
+		break;
+	default:
+		err = -ENOTSUPP;
+		break;
+	}
+
+	if (err)
+		return err;
+
+	rocker_tlv_nest_end(desc_info, cmd_info);
+
+	return 0;
+}
+
+static int ofdpa_cmd_flow_tbl_del(const struct rocker_port *rocker_port,
+				  struct rocker_desc_info *desc_info,
+				  void *priv)
+{
+	const struct ofdpa_flow_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u64(desc_info, ROCKER_TLV_OF_DPA_COOKIE,
+			       entry->cookie))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_group_tbl_add_l2_interface(struct rocker_desc_info *desc_info,
+				     struct ofdpa_group_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_OUT_PPORT,
+			       ROCKER_GROUP_PORT_GET(entry->group_id)))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_POP_VLAN,
+			      entry->l2_interface.pop_vlan))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_group_tbl_add_l2_rewrite(struct rocker_desc_info *desc_info,
+				   const struct ofdpa_group_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID_LOWER,
+			       entry->l2_rewrite.group_id))
+		return -EMSGSIZE;
+	if (!is_zero_ether_addr(entry->l2_rewrite.eth_src) &&
+	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
+			   ETH_ALEN, entry->l2_rewrite.eth_src))
+		return -EMSGSIZE;
+	if (!is_zero_ether_addr(entry->l2_rewrite.eth_dst) &&
+	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
+			   ETH_ALEN, entry->l2_rewrite.eth_dst))
+		return -EMSGSIZE;
+	if (entry->l2_rewrite.vlan_id &&
+	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->l2_rewrite.vlan_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_group_tbl_add_group_ids(struct rocker_desc_info *desc_info,
+				  const struct ofdpa_group_tbl_entry *entry)
+{
+	int i;
+	struct rocker_tlv *group_ids;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GROUP_COUNT,
+			       entry->group_count))
+		return -EMSGSIZE;
+
+	group_ids = rocker_tlv_nest_start(desc_info,
+					  ROCKER_TLV_OF_DPA_GROUP_IDS);
+	if (!group_ids)
+		return -EMSGSIZE;
+
+	for (i = 0; i < entry->group_count; i++)
+		/* Note TLV array is 1-based */
+		if (rocker_tlv_put_u32(desc_info, i + 1, entry->group_ids[i]))
+			return -EMSGSIZE;
+
+	rocker_tlv_nest_end(desc_info, group_ids);
+
+	return 0;
+}
+
+static int
+ofdpa_cmd_group_tbl_add_l3_unicast(struct rocker_desc_info *desc_info,
+				   const struct ofdpa_group_tbl_entry *entry)
+{
+	if (!is_zero_ether_addr(entry->l3_unicast.eth_src) &&
+	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
+			   ETH_ALEN, entry->l3_unicast.eth_src))
+		return -EMSGSIZE;
+	if (!is_zero_ether_addr(entry->l3_unicast.eth_dst) &&
+	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
+			   ETH_ALEN, entry->l3_unicast.eth_dst))
+		return -EMSGSIZE;
+	if (entry->l3_unicast.vlan_id &&
+	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->l3_unicast.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_TTL_CHECK,
+			      entry->l3_unicast.ttl_check))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID_LOWER,
+			       entry->l3_unicast.group_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int ofdpa_cmd_group_tbl_add(const struct rocker_port *rocker_port,
+				   struct rocker_desc_info *desc_info,
+				   void *priv)
+{
+	struct ofdpa_group_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+	int err = 0;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->group_id))
+		return -EMSGSIZE;
+
+	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_INTERFACE:
+		err = ofdpa_cmd_group_tbl_add_l2_interface(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_REWRITE:
+		err = ofdpa_cmd_group_tbl_add_l2_rewrite(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
+		err = ofdpa_cmd_group_tbl_add_group_ids(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_GROUP_TYPE_L3_UCAST:
+		err = ofdpa_cmd_group_tbl_add_l3_unicast(desc_info, entry);
+		break;
+	default:
+		err = -ENOTSUPP;
+		break;
+	}
+
+	if (err)
+		return err;
+
+	rocker_tlv_nest_end(desc_info, cmd_info);
+
+	return 0;
+}
+
+static int ofdpa_cmd_group_tbl_del(const struct rocker_port *rocker_port,
+				   struct rocker_desc_info *desc_info,
+				   void *priv)
+{
+	const struct ofdpa_group_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE, entry->cmd))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->group_id))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+
+	return 0;
+}
+
+/***************************************************
+ * Flow, group, FDB, internal VLAN and neigh tables
+ ***************************************************/
+
+static struct ofdpa_flow_tbl_entry *
+ofdpa_flow_tbl_find(const struct ofdpa *ofdpa,
+		    const struct ofdpa_flow_tbl_entry *match)
+{
+	struct ofdpa_flow_tbl_entry *found;
+	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
+
+	hash_for_each_possible(ofdpa->flow_tbl, found,
+			       entry, match->key_crc32) {
+		if (memcmp(&found->key, &match->key, key_len) == 0)
+			return found;
+	}
+
+	return NULL;
+}
+
+static int ofdpa_flow_tbl_add(struct ofdpa_port *ofdpa_port,
+			      struct switchdev_trans *trans, int flags,
+			      struct ofdpa_flow_tbl_entry *match)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_flow_tbl_entry *found;
+	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
+	unsigned long lock_flags;
+
+	match->key_crc32 = crc32(~0, &match->key, key_len);
+
+	spin_lock_irqsave(&ofdpa->flow_tbl_lock, lock_flags);
+
+	found = ofdpa_flow_tbl_find(ofdpa, match);
+
+	if (found) {
+		match->cookie = found->cookie;
+		if (!switchdev_trans_ph_prepare(trans))
+			hash_del(&found->entry);
+		ofdpa_kfree(trans, found);
+		found = match;
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD;
+	} else {
+		found = match;
+		found->cookie = ofdpa->flow_tbl_next_cookie++;
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD;
+	}
+
+	if (!switchdev_trans_ph_prepare(trans))
+		hash_add(ofdpa->flow_tbl, &found->entry, found->key_crc32);
+
+	spin_unlock_irqrestore(&ofdpa->flow_tbl_lock, lock_flags);
+
+	if (!switchdev_trans_ph_prepare(trans))
+		return rocker_cmd_exec(ofdpa_port->rocker_port,
+				       ofdpa_flags_nowait(flags),
+				       ofdpa_cmd_flow_tbl_add,
+				       found, NULL, NULL);
+	return 0;
+}
+
+static int ofdpa_flow_tbl_del(struct ofdpa_port *ofdpa_port,
+			      struct switchdev_trans *trans, int flags,
+			      struct ofdpa_flow_tbl_entry *match)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_flow_tbl_entry *found;
+	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
+	unsigned long lock_flags;
+	int err = 0;
+
+	match->key_crc32 = crc32(~0, &match->key, key_len);
+
+	spin_lock_irqsave(&ofdpa->flow_tbl_lock, lock_flags);
+
+	found = ofdpa_flow_tbl_find(ofdpa, match);
+
+	if (found) {
+		if (!switchdev_trans_ph_prepare(trans))
+			hash_del(&found->entry);
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL;
+	}
+
+	spin_unlock_irqrestore(&ofdpa->flow_tbl_lock, lock_flags);
+
+	ofdpa_kfree(trans, match);
+
+	if (found) {
+		if (!switchdev_trans_ph_prepare(trans))
+			err = rocker_cmd_exec(ofdpa_port->rocker_port,
+					      ofdpa_flags_nowait(flags),
+					      ofdpa_cmd_flow_tbl_del,
+					      found, NULL, NULL);
+		ofdpa_kfree(trans, found);
+	}
+
+	return err;
+}
+
+static int ofdpa_flow_tbl_do(struct ofdpa_port *ofdpa_port,
+			     struct switchdev_trans *trans, int flags,
+			     struct ofdpa_flow_tbl_entry *entry)
+{
+	if (flags & OFDPA_OP_FLAG_REMOVE)
+		return ofdpa_flow_tbl_del(ofdpa_port, trans, flags, entry);
+	else
+		return ofdpa_flow_tbl_add(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_flow_tbl_ig_port(struct ofdpa_port *ofdpa_port,
+				  struct switchdev_trans *trans, int flags,
+				  u32 in_pport, u32 in_pport_mask,
+				  enum rocker_of_dpa_table_id goto_tbl)
+{
+	struct ofdpa_flow_tbl_entry *entry;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.priority = OFDPA_PRIORITY_IG_PORT;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT;
+	entry->key.ig_port.in_pport = in_pport;
+	entry->key.ig_port.in_pport_mask = in_pport_mask;
+	entry->key.ig_port.goto_tbl = goto_tbl;
+
+	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_flow_tbl_vlan(struct ofdpa_port *ofdpa_port,
+			       struct switchdev_trans *trans, int flags,
+			       u32 in_pport, __be16 vlan_id,
+			       __be16 vlan_id_mask,
+			       enum rocker_of_dpa_table_id goto_tbl,
+			       bool untagged, __be16 new_vlan_id)
+{
+	struct ofdpa_flow_tbl_entry *entry;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.priority = OFDPA_PRIORITY_VLAN;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_VLAN;
+	entry->key.vlan.in_pport = in_pport;
+	entry->key.vlan.vlan_id = vlan_id;
+	entry->key.vlan.vlan_id_mask = vlan_id_mask;
+	entry->key.vlan.goto_tbl = goto_tbl;
+
+	entry->key.vlan.untagged = untagged;
+	entry->key.vlan.new_vlan_id = new_vlan_id;
+
+	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_flow_tbl_term_mac(struct ofdpa_port *ofdpa_port,
+				   struct switchdev_trans *trans,
+				   u32 in_pport, u32 in_pport_mask,
+				   __be16 eth_type, const u8 *eth_dst,
+				   const u8 *eth_dst_mask, __be16 vlan_id,
+				   __be16 vlan_id_mask, bool copy_to_cpu,
+				   int flags)
+{
+	struct ofdpa_flow_tbl_entry *entry;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	if (is_multicast_ether_addr(eth_dst)) {
+		entry->key.priority = OFDPA_PRIORITY_TERM_MAC_MCAST;
+		entry->key.term_mac.goto_tbl =
+			 ROCKER_OF_DPA_TABLE_ID_MULTICAST_ROUTING;
+	} else {
+		entry->key.priority = OFDPA_PRIORITY_TERM_MAC_UCAST;
+		entry->key.term_mac.goto_tbl =
+			 ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING;
+	}
+
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
+	entry->key.term_mac.in_pport = in_pport;
+	entry->key.term_mac.in_pport_mask = in_pport_mask;
+	entry->key.term_mac.eth_type = eth_type;
+	ether_addr_copy(entry->key.term_mac.eth_dst, eth_dst);
+	ether_addr_copy(entry->key.term_mac.eth_dst_mask, eth_dst_mask);
+	entry->key.term_mac.vlan_id = vlan_id;
+	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
+	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
+
+	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_flow_tbl_bridge(struct ofdpa_port *ofdpa_port,
+				 struct switchdev_trans *trans, int flags,
+				 const u8 *eth_dst, const u8 *eth_dst_mask,
+				 __be16 vlan_id, u32 tunnel_id,
+				 enum rocker_of_dpa_table_id goto_tbl,
+				 u32 group_id, bool copy_to_cpu)
+{
+	struct ofdpa_flow_tbl_entry *entry;
+	u32 priority;
+	bool vlan_bridging = !!vlan_id;
+	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
+	bool wild = false;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_BRIDGING;
+
+	if (eth_dst) {
+		entry->key.bridge.has_eth_dst = 1;
+		ether_addr_copy(entry->key.bridge.eth_dst, eth_dst);
+	}
+	if (eth_dst_mask) {
+		entry->key.bridge.has_eth_dst_mask = 1;
+		ether_addr_copy(entry->key.bridge.eth_dst_mask, eth_dst_mask);
+		if (!ether_addr_equal(eth_dst_mask, ff_mac))
+			wild = true;
+	}
+
+	priority = OFDPA_PRIORITY_UNKNOWN;
+	if (vlan_bridging && dflt && wild)
+		priority = OFDPA_PRIORITY_BRIDGING_VLAN_DFLT_WILD;
+	else if (vlan_bridging && dflt && !wild)
+		priority = OFDPA_PRIORITY_BRIDGING_VLAN_DFLT_EXACT;
+	else if (vlan_bridging && !dflt)
+		priority = OFDPA_PRIORITY_BRIDGING_VLAN;
+	else if (!vlan_bridging && dflt && wild)
+		priority = OFDPA_PRIORITY_BRIDGING_TENANT_DFLT_WILD;
+	else if (!vlan_bridging && dflt && !wild)
+		priority = OFDPA_PRIORITY_BRIDGING_TENANT_DFLT_EXACT;
+	else if (!vlan_bridging && !dflt)
+		priority = OFDPA_PRIORITY_BRIDGING_TENANT;
+
+	entry->key.priority = priority;
+	entry->key.bridge.vlan_id = vlan_id;
+	entry->key.bridge.tunnel_id = tunnel_id;
+	entry->key.bridge.goto_tbl = goto_tbl;
+	entry->key.bridge.group_id = group_id;
+	entry->key.bridge.copy_to_cpu = copy_to_cpu;
+
+	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_flow_tbl_ucast4_routing(struct ofdpa_port *ofdpa_port,
+					 struct switchdev_trans *trans,
+					 __be16 eth_type, __be32 dst,
+					 __be32 dst_mask, u32 priority,
+					 enum rocker_of_dpa_table_id goto_tbl,
+					 u32 group_id, int flags)
+{
+	struct ofdpa_flow_tbl_entry *entry;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
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
+	entry->key_len = offsetof(struct ofdpa_flow_tbl_key,
+				  ucast_routing.group_id);
+
+	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_flow_tbl_acl(struct ofdpa_port *ofdpa_port,
+			      struct switchdev_trans *trans, int flags,
+			      u32 in_pport, u32 in_pport_mask,
+			      const u8 *eth_src, const u8 *eth_src_mask,
+			      const u8 *eth_dst, const u8 *eth_dst_mask,
+			      __be16 eth_type, __be16 vlan_id,
+			      __be16 vlan_id_mask, u8 ip_proto,
+			      u8 ip_proto_mask, u8 ip_tos, u8 ip_tos_mask,
+			      u32 group_id)
+{
+	u32 priority;
+	struct ofdpa_flow_tbl_entry *entry;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	priority = OFDPA_PRIORITY_ACL_NORMAL;
+	if (eth_dst && eth_dst_mask) {
+		if (ether_addr_equal(eth_dst_mask, mcast_mac))
+			priority = OFDPA_PRIORITY_ACL_DFLT;
+		else if (is_link_local_ether_addr(eth_dst))
+			priority = OFDPA_PRIORITY_ACL_CTRL;
+	}
+
+	entry->key.priority = priority;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	entry->key.acl.in_pport = in_pport;
+	entry->key.acl.in_pport_mask = in_pport_mask;
+
+	if (eth_src)
+		ether_addr_copy(entry->key.acl.eth_src, eth_src);
+	if (eth_src_mask)
+		ether_addr_copy(entry->key.acl.eth_src_mask, eth_src_mask);
+	if (eth_dst)
+		ether_addr_copy(entry->key.acl.eth_dst, eth_dst);
+	if (eth_dst_mask)
+		ether_addr_copy(entry->key.acl.eth_dst_mask, eth_dst_mask);
+
+	entry->key.acl.eth_type = eth_type;
+	entry->key.acl.vlan_id = vlan_id;
+	entry->key.acl.vlan_id_mask = vlan_id_mask;
+	entry->key.acl.ip_proto = ip_proto;
+	entry->key.acl.ip_proto_mask = ip_proto_mask;
+	entry->key.acl.ip_tos = ip_tos;
+	entry->key.acl.ip_tos_mask = ip_tos_mask;
+	entry->key.acl.group_id = group_id;
+
+	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static struct ofdpa_group_tbl_entry *
+ofdpa_group_tbl_find(const struct ofdpa *ofdpa,
+		     const struct ofdpa_group_tbl_entry *match)
+{
+	struct ofdpa_group_tbl_entry *found;
+
+	hash_for_each_possible(ofdpa->group_tbl, found,
+			       entry, match->group_id) {
+		if (found->group_id == match->group_id)
+			return found;
+	}
+
+	return NULL;
+}
+
+static void ofdpa_group_tbl_entry_free(struct switchdev_trans *trans,
+				       struct ofdpa_group_tbl_entry *entry)
+{
+	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
+		ofdpa_kfree(trans, entry->group_ids);
+		break;
+	default:
+		break;
+	}
+	ofdpa_kfree(trans, entry);
+}
+
+static int ofdpa_group_tbl_add(struct ofdpa_port *ofdpa_port,
+			       struct switchdev_trans *trans, int flags,
+			       struct ofdpa_group_tbl_entry *match)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_group_tbl_entry *found;
+	unsigned long lock_flags;
+
+	spin_lock_irqsave(&ofdpa->group_tbl_lock, lock_flags);
+
+	found = ofdpa_group_tbl_find(ofdpa, match);
+
+	if (found) {
+		if (!switchdev_trans_ph_prepare(trans))
+			hash_del(&found->entry);
+		ofdpa_group_tbl_entry_free(trans, found);
+		found = match;
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
+	} else {
+		found = match;
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
+	}
+
+	if (!switchdev_trans_ph_prepare(trans))
+		hash_add(ofdpa->group_tbl, &found->entry, found->group_id);
+
+	spin_unlock_irqrestore(&ofdpa->group_tbl_lock, lock_flags);
+
+	if (!switchdev_trans_ph_prepare(trans))
+		return rocker_cmd_exec(ofdpa_port->rocker_port,
+				       ofdpa_flags_nowait(flags),
+				       ofdpa_cmd_group_tbl_add,
+				       found, NULL, NULL);
+	return 0;
+}
+
+static int ofdpa_group_tbl_del(struct ofdpa_port *ofdpa_port,
+			       struct switchdev_trans *trans, int flags,
+			       struct ofdpa_group_tbl_entry *match)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_group_tbl_entry *found;
+	unsigned long lock_flags;
+	int err = 0;
+
+	spin_lock_irqsave(&ofdpa->group_tbl_lock, lock_flags);
+
+	found = ofdpa_group_tbl_find(ofdpa, match);
+
+	if (found) {
+		if (!switchdev_trans_ph_prepare(trans))
+			hash_del(&found->entry);
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
+	}
+
+	spin_unlock_irqrestore(&ofdpa->group_tbl_lock, lock_flags);
+
+	ofdpa_group_tbl_entry_free(trans, match);
+
+	if (found) {
+		if (!switchdev_trans_ph_prepare(trans))
+			err = rocker_cmd_exec(ofdpa_port->rocker_port,
+					      ofdpa_flags_nowait(flags),
+					      ofdpa_cmd_group_tbl_del,
+					      found, NULL, NULL);
+		ofdpa_group_tbl_entry_free(trans, found);
+	}
+
+	return err;
+}
+
+static int ofdpa_group_tbl_do(struct ofdpa_port *ofdpa_port,
+			      struct switchdev_trans *trans, int flags,
+			      struct ofdpa_group_tbl_entry *entry)
+{
+	if (flags & OFDPA_OP_FLAG_REMOVE)
+		return ofdpa_group_tbl_del(ofdpa_port, trans, flags, entry);
+	else
+		return ofdpa_group_tbl_add(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_group_l2_interface(struct ofdpa_port *ofdpa_port,
+				    struct switchdev_trans *trans, int flags,
+				    __be16 vlan_id, u32 out_pport,
+				    int pop_vlan)
+{
+	struct ofdpa_group_tbl_entry *entry;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
+	entry->l2_interface.pop_vlan = pop_vlan;
+
+	return ofdpa_group_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_group_l2_fan_out(struct ofdpa_port *ofdpa_port,
+				  struct switchdev_trans *trans,
+				  int flags, u8 group_count,
+				  const u32 *group_ids, u32 group_id)
+{
+	struct ofdpa_group_tbl_entry *entry;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->group_id = group_id;
+	entry->group_count = group_count;
+
+	entry->group_ids = ofdpa_kcalloc(trans, flags,
+					 group_count, sizeof(u32));
+	if (!entry->group_ids) {
+		ofdpa_kfree(trans, entry);
+		return -ENOMEM;
+	}
+	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
+
+	return ofdpa_group_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_group_l2_flood(struct ofdpa_port *ofdpa_port,
+				struct switchdev_trans *trans, int flags,
+				__be16 vlan_id, u8 group_count,
+				const u32 *group_ids, u32 group_id)
+{
+	return ofdpa_group_l2_fan_out(ofdpa_port, trans, flags,
+				      group_count, group_ids,
+				      group_id);
+}
+
+static int ofdpa_group_l3_unicast(struct ofdpa_port *ofdpa_port,
+				  struct switchdev_trans *trans, int flags,
+				  u32 index, const u8 *src_mac, const u8 *dst_mac,
+				  __be16 vlan_id, bool ttl_check, u32 pport)
+{
+	struct ofdpa_group_tbl_entry *entry;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
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
+	return ofdpa_group_tbl_do(ofdpa_port, trans, flags, entry);
+}
+
+static struct ofdpa_neigh_tbl_entry *
+ofdpa_neigh_tbl_find(const struct ofdpa *ofdpa, __be32 ip_addr)
+{
+	struct ofdpa_neigh_tbl_entry *found;
+
+	hash_for_each_possible(ofdpa->neigh_tbl, found,
+			       entry, be32_to_cpu(ip_addr))
+		if (found->ip_addr == ip_addr)
+			return found;
+
+	return NULL;
+}
+
+static void ofdpa_neigh_add(struct ofdpa *ofdpa,
+			    struct switchdev_trans *trans,
+			    struct ofdpa_neigh_tbl_entry *entry)
+{
+	if (!switchdev_trans_ph_commit(trans))
+		entry->index = ofdpa->neigh_tbl_next_index++;
+	if (switchdev_trans_ph_prepare(trans))
+		return;
+	entry->ref_count++;
+	hash_add(ofdpa->neigh_tbl, &entry->entry,
+		 be32_to_cpu(entry->ip_addr));
+}
+
+static void ofdpa_neigh_del(struct switchdev_trans *trans,
+			    struct ofdpa_neigh_tbl_entry *entry)
+{
+	if (switchdev_trans_ph_prepare(trans))
+		return;
+	if (--entry->ref_count == 0) {
+		hash_del(&entry->entry);
+		ofdpa_kfree(trans, entry);
+	}
+}
+
+static void ofdpa_neigh_update(struct ofdpa_neigh_tbl_entry *entry,
+			       struct switchdev_trans *trans,
+			       const u8 *eth_dst, bool ttl_check)
+{
+	if (eth_dst) {
+		ether_addr_copy(entry->eth_dst, eth_dst);
+		entry->ttl_check = ttl_check;
+	} else if (!switchdev_trans_ph_prepare(trans)) {
+		entry->ref_count++;
+	}
+}
+
+static int ofdpa_port_ipv4_neigh(struct ofdpa_port *ofdpa_port,
+				 struct switchdev_trans *trans,
+				 int flags, __be32 ip_addr, const u8 *eth_dst)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_neigh_tbl_entry *entry;
+	struct ofdpa_neigh_tbl_entry *found;
+	unsigned long lock_flags;
+	__be16 eth_type = htons(ETH_P_IP);
+	enum rocker_of_dpa_table_id goto_tbl =
+			ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	u32 group_id;
+	u32 priority = 0;
+	bool adding = !(flags & OFDPA_OP_FLAG_REMOVE);
+	bool updating;
+	bool removing;
+	int err = 0;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&ofdpa->neigh_tbl_lock, lock_flags);
+
+	found = ofdpa_neigh_tbl_find(ofdpa, ip_addr);
+
+	updating = found && adding;
+	removing = found && !adding;
+	adding = !found && adding;
+
+	if (adding) {
+		entry->ip_addr = ip_addr;
+		entry->dev = ofdpa_port->dev;
+		ether_addr_copy(entry->eth_dst, eth_dst);
+		entry->ttl_check = true;
+		ofdpa_neigh_add(ofdpa, trans, entry);
+	} else if (removing) {
+		memcpy(entry, found, sizeof(*entry));
+		ofdpa_neigh_del(trans, found);
+	} else if (updating) {
+		ofdpa_neigh_update(found, trans, eth_dst, true);
+		memcpy(entry, found, sizeof(*entry));
+	} else {
+		err = -ENOENT;
+	}
+
+	spin_unlock_irqrestore(&ofdpa->neigh_tbl_lock, lock_flags);
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
+	err = ofdpa_group_l3_unicast(ofdpa_port, trans, flags,
+				     entry->index,
+				     ofdpa_port->dev->dev_addr,
+				     entry->eth_dst,
+				     ofdpa_port->internal_vlan_id,
+				     entry->ttl_check,
+				     ofdpa_port->pport);
+	if (err) {
+		netdev_err(ofdpa_port->dev, "Error (%d) L3 unicast group index %d\n",
+			   err, entry->index);
+		goto err_out;
+	}
+
+	if (adding || removing) {
+		group_id = ROCKER_GROUP_L3_UNICAST(entry->index);
+		err = ofdpa_flow_tbl_ucast4_routing(ofdpa_port, trans,
+						    eth_type, ip_addr,
+						    inet_make_mask(32),
+						    priority, goto_tbl,
+						    group_id, flags);
+
+		if (err)
+			netdev_err(ofdpa_port->dev, "Error (%d) /32 unicast route %pI4 group 0x%08x\n",
+				   err, &entry->ip_addr, group_id);
+	}
+
+err_out:
+	if (!adding)
+		ofdpa_kfree(trans, entry);
+
+	return err;
+}
+
+static int ofdpa_port_ipv4_resolve(struct ofdpa_port *ofdpa_port,
+				   struct switchdev_trans *trans,
+				   __be32 ip_addr)
+{
+	struct net_device *dev = ofdpa_port->dev;
+	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
+	int err = 0;
+
+	if (!n) {
+		n = neigh_create(&arp_tbl, &ip_addr, dev);
+		if (IS_ERR(n))
+			return IS_ERR(n);
+	}
+
+	/* If the neigh is already resolved, then go ahead and
+	 * install the entry, otherwise start the ARP process to
+	 * resolve the neigh.
+	 */
+
+	if (n->nud_state & NUD_VALID)
+		err = ofdpa_port_ipv4_neigh(ofdpa_port, trans, 0,
+					    ip_addr, n->ha);
+	else
+		neigh_event_send(n, NULL);
+
+	neigh_release(n);
+	return err;
+}
+
+static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
+			      struct switchdev_trans *trans, int flags,
+			      __be32 ip_addr, u32 *index)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_neigh_tbl_entry *entry;
+	struct ofdpa_neigh_tbl_entry *found;
+	unsigned long lock_flags;
+	bool adding = !(flags & OFDPA_OP_FLAG_REMOVE);
+	bool updating;
+	bool removing;
+	bool resolved = true;
+	int err = 0;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&ofdpa->neigh_tbl_lock, lock_flags);
+
+	found = ofdpa_neigh_tbl_find(ofdpa, ip_addr);
+	if (found)
+		*index = found->index;
+
+	updating = found && adding;
+	removing = found && !adding;
+	adding = !found && adding;
+
+	if (adding) {
+		entry->ip_addr = ip_addr;
+		entry->dev = ofdpa_port->dev;
+		ofdpa_neigh_add(ofdpa, trans, entry);
+		*index = entry->index;
+		resolved = false;
+	} else if (removing) {
+		ofdpa_neigh_del(trans, found);
+	} else if (updating) {
+		ofdpa_neigh_update(found, trans, NULL, false);
+		resolved = !is_zero_ether_addr(found->eth_dst);
+	} else {
+		err = -ENOENT;
+	}
+
+	spin_unlock_irqrestore(&ofdpa->neigh_tbl_lock, lock_flags);
+
+	if (!adding)
+		ofdpa_kfree(trans, entry);
+
+	if (err)
+		return err;
+
+	/* Resolved means neigh ip_addr is resolved to neigh mac. */
+
+	if (!resolved)
+		err = ofdpa_port_ipv4_resolve(ofdpa_port, trans, ip_addr);
+
+	return err;
+}
+
+static struct ofdpa_port *ofdpa_port_get(const struct ofdpa *ofdpa,
+					 int port_index)
+{
+	struct rocker_port *rocker_port;
+
+	rocker_port = rocker_port_get(ofdpa->rocker, port_index);
+	return rocker_port ? rocker_port_world_priv_get(rocker_port) : NULL;
+}
+
+static int ofdpa_port_vlan_flood_group(struct ofdpa_port *ofdpa_port,
+				       struct switchdev_trans *trans,
+				       int flags, __be16 vlan_id)
+{
+	struct ofdpa_port *p;
+	const struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	unsigned int port_count = rocker_port_count_get(ofdpa->rocker);
+	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
+	u32 *group_ids;
+	u8 group_count = 0;
+	int err = 0;
+	int i;
+
+	group_ids = ofdpa_kcalloc(trans, flags, port_count, sizeof(u32));
+	if (!group_ids)
+		return -ENOMEM;
+
+	/* Adjust the flood group for this VLAN.  The flood group
+	 * references an L2 interface group for each port in this
+	 * VLAN.
+	 */
+
+	for (i = 0; i < port_count; i++) {
+		p = ofdpa_port_get(ofdpa, i);
+		if (!p)
+			continue;
+		if (!ofdpa_port_is_bridged(p))
+			continue;
+		if (test_bit(ntohs(vlan_id), p->vlan_bitmap)) {
+			group_ids[group_count++] =
+				ROCKER_GROUP_L2_INTERFACE(vlan_id, p->pport);
+		}
+	}
+
+	/* If there are no bridged ports in this VLAN, we're done */
+	if (group_count == 0)
+		goto no_ports_in_vlan;
+
+	err = ofdpa_group_l2_flood(ofdpa_port, trans, flags, vlan_id,
+				   group_count, group_ids, group_id);
+	if (err)
+		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 flood group\n", err);
+
+no_ports_in_vlan:
+	ofdpa_kfree(trans, group_ids);
+	return err;
+}
+
+static int ofdpa_port_vlan_l2_groups(struct ofdpa_port *ofdpa_port,
+				     struct switchdev_trans *trans, int flags,
+				     __be16 vlan_id, bool pop_vlan)
+{
+	const struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	unsigned int port_count = rocker_port_count_get(ofdpa->rocker);
+	struct ofdpa_port *p;
+	bool adding = !(flags & OFDPA_OP_FLAG_REMOVE);
+	u32 out_pport;
+	int ref = 0;
+	int err;
+	int i;
+
+	/* An L2 interface group for this port in this VLAN, but
+	 * only when port STP state is LEARNING|FORWARDING.
+	 */
+
+	if (ofdpa_port->stp_state == BR_STATE_LEARNING ||
+	    ofdpa_port->stp_state == BR_STATE_FORWARDING) {
+		out_pport = ofdpa_port->pport;
+		err = ofdpa_group_l2_interface(ofdpa_port, trans, flags,
+					       vlan_id, out_pport, pop_vlan);
+		if (err) {
+			netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 group for pport %d\n",
+				   err, out_pport);
+			return err;
+		}
+	}
+
+	/* An L2 interface group for this VLAN to CPU port.
+	 * Add when first port joins this VLAN and destroy when
+	 * last port leaves this VLAN.
+	 */
+
+	for (i = 0; i < port_count; i++) {
+		p = ofdpa_port_get(ofdpa, i);
+		if (p && test_bit(ntohs(vlan_id), p->vlan_bitmap))
+			ref++;
+	}
+
+	if ((!adding || ref != 1) && (adding || ref != 0))
+		return 0;
+
+	out_pport = 0;
+	err = ofdpa_group_l2_interface(ofdpa_port, trans, flags,
+				       vlan_id, out_pport, pop_vlan);
+	if (err) {
+		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 group for CPU port\n", err);
+		return err;
+	}
+
+	return 0;
+}
+
+static struct ofdpa_ctrl {
+	const u8 *eth_dst;
+	const u8 *eth_dst_mask;
+	__be16 eth_type;
+	bool acl;
+	bool bridge;
+	bool term;
+	bool copy_to_cpu;
+} ofdpa_ctrls[] = {
+	[OFDPA_CTRL_LINK_LOCAL_MCAST] = {
+		/* pass link local multicast pkts up to CPU for filtering */
+		.eth_dst = ll_mac,
+		.eth_dst_mask = ll_mask,
+		.acl = true,
+	},
+	[OFDPA_CTRL_LOCAL_ARP] = {
+		/* pass local ARP pkts up to CPU */
+		.eth_dst = zero_mac,
+		.eth_dst_mask = zero_mac,
+		.eth_type = htons(ETH_P_ARP),
+		.acl = true,
+	},
+	[OFDPA_CTRL_IPV4_MCAST] = {
+		/* pass IPv4 mcast pkts up to CPU, RFC 1112 */
+		.eth_dst = ipv4_mcast,
+		.eth_dst_mask = ipv4_mask,
+		.eth_type = htons(ETH_P_IP),
+		.term  = true,
+		.copy_to_cpu = true,
+	},
+	[OFDPA_CTRL_IPV6_MCAST] = {
+		/* pass IPv6 mcast pkts up to CPU, RFC 2464 */
+		.eth_dst = ipv6_mcast,
+		.eth_dst_mask = ipv6_mask,
+		.eth_type = htons(ETH_P_IPV6),
+		.term  = true,
+		.copy_to_cpu = true,
+	},
+	[OFDPA_CTRL_DFLT_BRIDGING] = {
+		/* flood any pkts on vlan */
+		.bridge = true,
+		.copy_to_cpu = true,
+	},
+	[OFDPA_CTRL_DFLT_OVS] = {
+		/* pass all pkts up to CPU */
+		.eth_dst = zero_mac,
+		.eth_dst_mask = zero_mac,
+		.acl = true,
+	},
+};
+
+static int ofdpa_port_ctrl_vlan_acl(struct ofdpa_port *ofdpa_port,
+				    struct switchdev_trans *trans, int flags,
+				    const struct ofdpa_ctrl *ctrl, __be16 vlan_id)
+{
+	u32 in_pport = ofdpa_port->pport;
+	u32 in_pport_mask = 0xffffffff;
+	u32 out_pport = 0;
+	const u8 *eth_src = NULL;
+	const u8 *eth_src_mask = NULL;
+	__be16 vlan_id_mask = htons(0xffff);
+	u8 ip_proto = 0;
+	u8 ip_proto_mask = 0;
+	u8 ip_tos = 0;
+	u8 ip_tos_mask = 0;
+	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
+	int err;
+
+	err = ofdpa_flow_tbl_acl(ofdpa_port, trans, flags,
+				 in_pport, in_pport_mask,
+				 eth_src, eth_src_mask,
+				 ctrl->eth_dst, ctrl->eth_dst_mask,
+				 ctrl->eth_type,
+				 vlan_id, vlan_id_mask,
+				 ip_proto, ip_proto_mask,
+				 ip_tos, ip_tos_mask,
+				 group_id);
+
+	if (err)
+		netdev_err(ofdpa_port->dev, "Error (%d) ctrl ACL\n", err);
+
+	return err;
+}
+
+static int ofdpa_port_ctrl_vlan_bridge(struct ofdpa_port *ofdpa_port,
+				       struct switchdev_trans *trans,
+				       int flags,
+				       const struct ofdpa_ctrl *ctrl,
+				       __be16 vlan_id)
+{
+	enum rocker_of_dpa_table_id goto_tbl =
+			ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
+	u32 tunnel_id = 0;
+	int err;
+
+	if (!ofdpa_port_is_bridged(ofdpa_port))
+		return 0;
+
+	err = ofdpa_flow_tbl_bridge(ofdpa_port, trans, flags,
+				    ctrl->eth_dst, ctrl->eth_dst_mask,
+				    vlan_id, tunnel_id,
+				    goto_tbl, group_id, ctrl->copy_to_cpu);
+
+	if (err)
+		netdev_err(ofdpa_port->dev, "Error (%d) ctrl FLOOD\n", err);
+
+	return err;
+}
+
+static int ofdpa_port_ctrl_vlan_term(struct ofdpa_port *ofdpa_port,
+				     struct switchdev_trans *trans, int flags,
+				     const struct ofdpa_ctrl *ctrl, __be16 vlan_id)
+{
+	u32 in_pport_mask = 0xffffffff;
+	__be16 vlan_id_mask = htons(0xffff);
+	int err;
+
+	if (ntohs(vlan_id) == 0)
+		vlan_id = ofdpa_port->internal_vlan_id;
+
+	err = ofdpa_flow_tbl_term_mac(ofdpa_port, trans,
+				      ofdpa_port->pport, in_pport_mask,
+				      ctrl->eth_type, ctrl->eth_dst,
+				      ctrl->eth_dst_mask, vlan_id,
+				      vlan_id_mask, ctrl->copy_to_cpu,
+				      flags);
+
+	if (err)
+		netdev_err(ofdpa_port->dev, "Error (%d) ctrl term\n", err);
+
+	return err;
+}
+
+static int ofdpa_port_ctrl_vlan(struct ofdpa_port *ofdpa_port,
+				struct switchdev_trans *trans, int flags,
+				const struct ofdpa_ctrl *ctrl, __be16 vlan_id)
+{
+	if (ctrl->acl)
+		return ofdpa_port_ctrl_vlan_acl(ofdpa_port, trans, flags,
+						ctrl, vlan_id);
+	if (ctrl->bridge)
+		return ofdpa_port_ctrl_vlan_bridge(ofdpa_port, trans, flags,
+						   ctrl, vlan_id);
+
+	if (ctrl->term)
+		return ofdpa_port_ctrl_vlan_term(ofdpa_port, trans, flags,
+						 ctrl, vlan_id);
+
+	return -EOPNOTSUPP;
+}
+
+static int ofdpa_port_ctrl_vlan_add(struct ofdpa_port *ofdpa_port,
+				    struct switchdev_trans *trans, int flags,
+				    __be16 vlan_id)
+{
+	int err = 0;
+	int i;
+
+	for (i = 0; i < OFDPA_CTRL_MAX; i++) {
+		if (ofdpa_port->ctrls[i]) {
+			err = ofdpa_port_ctrl_vlan(ofdpa_port, trans, flags,
+						   &ofdpa_ctrls[i], vlan_id);
+			if (err)
+				return err;
+		}
+	}
+
+	return err;
+}
+
+static int ofdpa_port_ctrl(struct ofdpa_port *ofdpa_port,
+			   struct switchdev_trans *trans, int flags,
+			   const struct ofdpa_ctrl *ctrl)
+{
+	u16 vid;
+	int err = 0;
+
+	for (vid = 1; vid < VLAN_N_VID; vid++) {
+		if (!test_bit(vid, ofdpa_port->vlan_bitmap))
+			continue;
+		err = ofdpa_port_ctrl_vlan(ofdpa_port, trans, flags,
+					   ctrl, htons(vid));
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+static int ofdpa_port_vlan(struct ofdpa_port *ofdpa_port,
+			   struct switchdev_trans *trans, int flags, u16 vid)
+{
+	enum rocker_of_dpa_table_id goto_tbl =
+			ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
+	u32 in_pport = ofdpa_port->pport;
+	__be16 vlan_id = htons(vid);
+	__be16 vlan_id_mask = htons(0xffff);
+	__be16 internal_vlan_id;
+	bool untagged;
+	bool adding = !(flags & OFDPA_OP_FLAG_REMOVE);
+	int err;
+
+	internal_vlan_id = ofdpa_port_vid_to_vlan(ofdpa_port, vid, &untagged);
+
+	if (adding &&
+	    test_bit(ntohs(internal_vlan_id), ofdpa_port->vlan_bitmap))
+		return 0; /* already added */
+	else if (!adding &&
+		 !test_bit(ntohs(internal_vlan_id), ofdpa_port->vlan_bitmap))
+		return 0; /* already removed */
+
+	change_bit(ntohs(internal_vlan_id), ofdpa_port->vlan_bitmap);
+
+	if (adding) {
+		err = ofdpa_port_ctrl_vlan_add(ofdpa_port, trans, flags,
+					       internal_vlan_id);
+		if (err) {
+			netdev_err(ofdpa_port->dev, "Error (%d) port ctrl vlan add\n", err);
+			goto err_out;
+		}
+	}
+
+	err = ofdpa_port_vlan_l2_groups(ofdpa_port, trans, flags,
+					internal_vlan_id, untagged);
+	if (err) {
+		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 groups\n", err);
+		goto err_out;
+	}
+
+	err = ofdpa_port_vlan_flood_group(ofdpa_port, trans, flags,
+					  internal_vlan_id);
+	if (err) {
+		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 flood group\n", err);
+		goto err_out;
+	}
+
+	err = ofdpa_flow_tbl_vlan(ofdpa_port, trans, flags,
+				  in_pport, vlan_id, vlan_id_mask,
+				  goto_tbl, untagged, internal_vlan_id);
+	if (err)
+		netdev_err(ofdpa_port->dev, "Error (%d) port VLAN table\n", err);
+
+err_out:
+	if (switchdev_trans_ph_prepare(trans))
+		change_bit(ntohs(internal_vlan_id), ofdpa_port->vlan_bitmap);
+
+	return err;
+}
+
+static int ofdpa_port_ig_tbl(struct ofdpa_port *ofdpa_port,
+			     struct switchdev_trans *trans, int flags)
+{
+	enum rocker_of_dpa_table_id goto_tbl;
+	u32 in_pport;
+	u32 in_pport_mask;
+	int err;
+
+	/* Normal Ethernet Frames.  Matches pkts from any local physical
+	 * ports.  Goto VLAN tbl.
+	 */
+
+	in_pport = 0;
+	in_pport_mask = 0xffff0000;
+	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
+
+	err = ofdpa_flow_tbl_ig_port(ofdpa_port, trans, flags,
+				     in_pport, in_pport_mask,
+				     goto_tbl);
+	if (err)
+		netdev_err(ofdpa_port->dev, "Error (%d) ingress port table entry\n", err);
+
+	return err;
+}
+
+struct ofdpa_fdb_learn_work {
+	struct work_struct work;
+	struct ofdpa_port *ofdpa_port;
+	struct switchdev_trans *trans;
+	int flags;
+	u8 addr[ETH_ALEN];
+	u16 vid;
+};
+
+static void ofdpa_port_fdb_learn_work(struct work_struct *work)
+{
+	const struct ofdpa_fdb_learn_work *lw =
+		container_of(work, struct ofdpa_fdb_learn_work, work);
+	bool removing = (lw->flags & OFDPA_OP_FLAG_REMOVE);
+	bool learned = (lw->flags & OFDPA_OP_FLAG_LEARNED);
+	struct switchdev_notifier_fdb_info info;
+
+	info.addr = lw->addr;
+	info.vid = lw->vid;
+
+	if (learned && removing)
+		call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
+					 lw->ofdpa_port->dev, &info.info);
+	else if (learned && !removing)
+		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
+					 lw->ofdpa_port->dev, &info.info);
+
+	ofdpa_kfree(lw->trans, work);
+}
+
+static int ofdpa_port_fdb_learn(struct ofdpa_port *ofdpa_port,
+				struct switchdev_trans *trans, int flags,
+				const u8 *addr, __be16 vlan_id)
+{
+	struct ofdpa_fdb_learn_work *lw;
+	enum rocker_of_dpa_table_id goto_tbl =
+			ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	u32 out_pport = ofdpa_port->pport;
+	u32 tunnel_id = 0;
+	u32 group_id = ROCKER_GROUP_NONE;
+	bool syncing = !!(ofdpa_port->brport_flags & BR_LEARNING_SYNC);
+	bool copy_to_cpu = false;
+	int err;
+
+	if (ofdpa_port_is_bridged(ofdpa_port))
+		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
+
+	if (!(flags & OFDPA_OP_FLAG_REFRESH)) {
+		err = ofdpa_flow_tbl_bridge(ofdpa_port, trans, flags, addr,
+					    NULL, vlan_id, tunnel_id, goto_tbl,
+					    group_id, copy_to_cpu);
+		if (err)
+			return err;
+	}
+
+	if (!syncing)
+		return 0;
+
+	if (!ofdpa_port_is_bridged(ofdpa_port))
+		return 0;
+
+	lw = ofdpa_kzalloc(trans, flags, sizeof(*lw));
+	if (!lw)
+		return -ENOMEM;
+
+	INIT_WORK(&lw->work, ofdpa_port_fdb_learn_work);
+
+	lw->ofdpa_port = ofdpa_port;
+	lw->trans = trans;
+	lw->flags = flags;
+	ether_addr_copy(lw->addr, addr);
+	lw->vid = ofdpa_port_vlan_to_vid(ofdpa_port, vlan_id);
+
+	if (switchdev_trans_ph_prepare(trans))
+		ofdpa_kfree(trans, lw);
+	else
+		schedule_work(&lw->work);
+
+	return 0;
+}
+
+static struct ofdpa_fdb_tbl_entry *
+ofdpa_fdb_tbl_find(const struct ofdpa *ofdpa,
+		   const struct ofdpa_fdb_tbl_entry *match)
+{
+	struct ofdpa_fdb_tbl_entry *found;
+
+	hash_for_each_possible(ofdpa->fdb_tbl, found, entry, match->key_crc32)
+		if (memcmp(&found->key, &match->key, sizeof(found->key)) == 0)
+			return found;
+
+	return NULL;
+}
+
+static int ofdpa_port_fdb(struct ofdpa_port *ofdpa_port,
+			  struct switchdev_trans *trans,
+			  const unsigned char *addr,
+			  __be16 vlan_id, int flags)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_fdb_tbl_entry *fdb;
+	struct ofdpa_fdb_tbl_entry *found;
+	bool removing = (flags & OFDPA_OP_FLAG_REMOVE);
+	unsigned long lock_flags;
+
+	fdb = ofdpa_kzalloc(trans, flags, sizeof(*fdb));
+	if (!fdb)
+		return -ENOMEM;
+
+	fdb->learned = (flags & OFDPA_OP_FLAG_LEARNED);
+	fdb->touched = jiffies;
+	fdb->key.ofdpa_port = ofdpa_port;
+	ether_addr_copy(fdb->key.addr, addr);
+	fdb->key.vlan_id = vlan_id;
+	fdb->key_crc32 = crc32(~0, &fdb->key, sizeof(fdb->key));
+
+	spin_lock_irqsave(&ofdpa->fdb_tbl_lock, lock_flags);
+
+	found = ofdpa_fdb_tbl_find(ofdpa, fdb);
+
+	if (found) {
+		found->touched = jiffies;
+		if (removing) {
+			ofdpa_kfree(trans, fdb);
+			if (!switchdev_trans_ph_prepare(trans))
+				hash_del(&found->entry);
+		}
+	} else if (!removing) {
+		if (!switchdev_trans_ph_prepare(trans))
+			hash_add(ofdpa->fdb_tbl, &fdb->entry,
+				 fdb->key_crc32);
+	}
+
+	spin_unlock_irqrestore(&ofdpa->fdb_tbl_lock, lock_flags);
+
+	/* Check if adding and already exists, or removing and can't find */
+	if (!found != !removing) {
+		ofdpa_kfree(trans, fdb);
+		if (!found && removing)
+			return 0;
+		/* Refreshing existing to update aging timers */
+		flags |= OFDPA_OP_FLAG_REFRESH;
+	}
+
+	return ofdpa_port_fdb_learn(ofdpa_port, trans, flags, addr, vlan_id);
+}
+
+static int ofdpa_port_fdb_flush(struct ofdpa_port *ofdpa_port,
+				struct switchdev_trans *trans, int flags)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_fdb_tbl_entry *found;
+	unsigned long lock_flags;
+	struct hlist_node *tmp;
+	int bkt;
+	int err = 0;
+
+	if (ofdpa_port->stp_state == BR_STATE_LEARNING ||
+	    ofdpa_port->stp_state == BR_STATE_FORWARDING)
+		return 0;
+
+	flags |= OFDPA_OP_FLAG_REMOVE;
+
+	spin_lock_irqsave(&ofdpa->fdb_tbl_lock, lock_flags);
+
+	hash_for_each_safe(ofdpa->fdb_tbl, bkt, tmp, found, entry) {
+		if (found->key.ofdpa_port != ofdpa_port)
+			continue;
+		if (!found->learned)
+			continue;
+		err = ofdpa_port_fdb_learn(ofdpa_port, trans, flags,
+					   found->key.addr,
+					   found->key.vlan_id);
+		if (err)
+			goto err_out;
+		if (!switchdev_trans_ph_prepare(trans))
+			hash_del(&found->entry);
+	}
+
+err_out:
+	spin_unlock_irqrestore(&ofdpa->fdb_tbl_lock, lock_flags);
+
+	return err;
+}
+
+static void ofdpa_fdb_cleanup(unsigned long data)
+{
+	struct ofdpa *ofdpa = (struct ofdpa *)data;
+	struct ofdpa_port *ofdpa_port;
+	struct ofdpa_fdb_tbl_entry *entry;
+	struct hlist_node *tmp;
+	unsigned long next_timer = jiffies + BR_MIN_AGEING_TIME;
+	unsigned long expires;
+	unsigned long lock_flags;
+	int flags = OFDPA_OP_FLAG_NOWAIT | OFDPA_OP_FLAG_REMOVE |
+		    OFDPA_OP_FLAG_LEARNED;
+	int bkt;
+
+	spin_lock_irqsave(&ofdpa->fdb_tbl_lock, lock_flags);
+
+	hash_for_each_safe(ofdpa->fdb_tbl, bkt, tmp, entry, entry) {
+		if (!entry->learned)
+			continue;
+		ofdpa_port = entry->key.ofdpa_port;
+		expires = entry->touched + ofdpa_port->ageing_time;
+		if (time_before_eq(expires, jiffies)) {
+			ofdpa_port_fdb_learn(ofdpa_port, NULL,
+					     flags, entry->key.addr,
+					     entry->key.vlan_id);
+			hash_del(&entry->entry);
+		} else if (time_before(expires, next_timer)) {
+			next_timer = expires;
+		}
+	}
+
+	spin_unlock_irqrestore(&ofdpa->fdb_tbl_lock, lock_flags);
+
+	mod_timer(&ofdpa->fdb_cleanup_timer, round_jiffies_up(next_timer));
+}
+
+static int ofdpa_port_router_mac(struct ofdpa_port *ofdpa_port,
+				 struct switchdev_trans *trans, int flags,
+				 __be16 vlan_id)
+{
+	u32 in_pport_mask = 0xffffffff;
+	__be16 eth_type;
+	const u8 *dst_mac_mask = ff_mac;
+	__be16 vlan_id_mask = htons(0xffff);
+	bool copy_to_cpu = false;
+	int err;
+
+	if (ntohs(vlan_id) == 0)
+		vlan_id = ofdpa_port->internal_vlan_id;
+
+	eth_type = htons(ETH_P_IP);
+	err = ofdpa_flow_tbl_term_mac(ofdpa_port, trans,
+				      ofdpa_port->pport, in_pport_mask,
+				      eth_type, ofdpa_port->dev->dev_addr,
+				      dst_mac_mask, vlan_id, vlan_id_mask,
+				      copy_to_cpu, flags);
+	if (err)
+		return err;
+
+	eth_type = htons(ETH_P_IPV6);
+	err = ofdpa_flow_tbl_term_mac(ofdpa_port, trans,
+				      ofdpa_port->pport, in_pport_mask,
+				      eth_type, ofdpa_port->dev->dev_addr,
+				      dst_mac_mask, vlan_id, vlan_id_mask,
+				      copy_to_cpu, flags);
+
+	return err;
+}
+
+static int ofdpa_port_fwding(struct ofdpa_port *ofdpa_port,
+			     struct switchdev_trans *trans, int flags)
+{
+	bool pop_vlan;
+	u32 out_pport;
+	__be16 vlan_id;
+	u16 vid;
+	int err;
+
+	/* Port will be forwarding-enabled if its STP state is LEARNING
+	 * or FORWARDING.  Traffic from CPU can still egress, regardless of
+	 * port STP state.  Use L2 interface group on port VLANs as a way
+	 * to toggle port forwarding: if forwarding is disabled, L2
+	 * interface group will not exist.
+	 */
+
+	if (ofdpa_port->stp_state != BR_STATE_LEARNING &&
+	    ofdpa_port->stp_state != BR_STATE_FORWARDING)
+		flags |= OFDPA_OP_FLAG_REMOVE;
+
+	out_pport = ofdpa_port->pport;
+	for (vid = 1; vid < VLAN_N_VID; vid++) {
+		if (!test_bit(vid, ofdpa_port->vlan_bitmap))
+			continue;
+		vlan_id = htons(vid);
+		pop_vlan = ofdpa_vlan_id_is_internal(vlan_id);
+		err = ofdpa_group_l2_interface(ofdpa_port, trans, flags,
+					       vlan_id, out_pport, pop_vlan);
+		if (err) {
+			netdev_err(ofdpa_port->dev, "Error (%d) port VLAN l2 group for pport %d\n",
+				   err, out_pport);
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+static int ofdpa_port_stp_update(struct ofdpa_port *ofdpa_port,
+				 struct switchdev_trans *trans,
+				 int flags, u8 state)
+{
+	bool want[OFDPA_CTRL_MAX] = { 0, };
+	bool prev_ctrls[OFDPA_CTRL_MAX];
+	u8 uninitialized_var(prev_state);
+	int err;
+	int i;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		memcpy(prev_ctrls, ofdpa_port->ctrls, sizeof(prev_ctrls));
+		prev_state = ofdpa_port->stp_state;
+	}
+
+	if (ofdpa_port->stp_state == state)
+		return 0;
+
+	ofdpa_port->stp_state = state;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		/* port is completely disabled */
+		break;
+	case BR_STATE_LISTENING:
+	case BR_STATE_BLOCKING:
+		want[OFDPA_CTRL_LINK_LOCAL_MCAST] = true;
+		break;
+	case BR_STATE_LEARNING:
+	case BR_STATE_FORWARDING:
+		if (!ofdpa_port_is_ovsed(ofdpa_port))
+			want[OFDPA_CTRL_LINK_LOCAL_MCAST] = true;
+		want[OFDPA_CTRL_IPV4_MCAST] = true;
+		want[OFDPA_CTRL_IPV6_MCAST] = true;
+		if (ofdpa_port_is_bridged(ofdpa_port))
+			want[OFDPA_CTRL_DFLT_BRIDGING] = true;
+		else if (ofdpa_port_is_ovsed(ofdpa_port))
+			want[OFDPA_CTRL_DFLT_OVS] = true;
+		else
+			want[OFDPA_CTRL_LOCAL_ARP] = true;
+		break;
+	}
+
+	for (i = 0; i < OFDPA_CTRL_MAX; i++) {
+		if (want[i] != ofdpa_port->ctrls[i]) {
+			int ctrl_flags = flags |
+					 (want[i] ? 0 : OFDPA_OP_FLAG_REMOVE);
+			err = ofdpa_port_ctrl(ofdpa_port, trans, ctrl_flags,
+					      &ofdpa_ctrls[i]);
+			if (err)
+				goto err_out;
+			ofdpa_port->ctrls[i] = want[i];
+		}
+	}
+
+	err = ofdpa_port_fdb_flush(ofdpa_port, trans, flags);
+	if (err)
+		goto err_out;
+
+	err = ofdpa_port_fwding(ofdpa_port, trans, flags);
+
+err_out:
+	if (switchdev_trans_ph_prepare(trans)) {
+		memcpy(ofdpa_port->ctrls, prev_ctrls, sizeof(prev_ctrls));
+		ofdpa_port->stp_state = prev_state;
+	}
+
+	return err;
+}
+
+static int ofdpa_port_fwd_enable(struct ofdpa_port *ofdpa_port, int flags)
+{
+	if (ofdpa_port_is_bridged(ofdpa_port))
+		/* bridge STP will enable port */
+		return 0;
+
+	/* port is not bridged, so simulate going to FORWARDING state */
+	return ofdpa_port_stp_update(ofdpa_port, NULL, flags,
+				     BR_STATE_FORWARDING);
+}
+
+static int ofdpa_port_fwd_disable(struct ofdpa_port *ofdpa_port, int flags)
+{
+	if (ofdpa_port_is_bridged(ofdpa_port))
+		/* bridge STP will disable port */
+		return 0;
+
+	/* port is not bridged, so simulate going to DISABLED state */
+	return ofdpa_port_stp_update(ofdpa_port, NULL, flags,
+				     BR_STATE_DISABLED);
+}
+
+static int ofdpa_port_vlan_add(struct ofdpa_port *ofdpa_port,
+			       struct switchdev_trans *trans,
+			       u16 vid, u16 flags)
+{
+	int err;
+
+	/* XXX deal with flags for PVID and untagged */
+
+	err = ofdpa_port_vlan(ofdpa_port, trans, 0, vid);
+	if (err)
+		return err;
+
+	err = ofdpa_port_router_mac(ofdpa_port, trans, 0, htons(vid));
+	if (err)
+		ofdpa_port_vlan(ofdpa_port, trans,
+				OFDPA_OP_FLAG_REMOVE, vid);
+
+	return err;
+}
+
+static int ofdpa_port_vlan_del(struct ofdpa_port *ofdpa_port,
+			       u16 vid, u16 flags)
+{
+	int err;
+
+	err = ofdpa_port_router_mac(ofdpa_port, NULL,
+				    OFDPA_OP_FLAG_REMOVE, htons(vid));
+	if (err)
+		return err;
+
+	return ofdpa_port_vlan(ofdpa_port, NULL,
+			       OFDPA_OP_FLAG_REMOVE, vid);
+}
+
+static struct ofdpa_internal_vlan_tbl_entry *
+ofdpa_internal_vlan_tbl_find(const struct ofdpa *ofdpa, int ifindex)
+{
+	struct ofdpa_internal_vlan_tbl_entry *found;
+
+	hash_for_each_possible(ofdpa->internal_vlan_tbl, found,
+			       entry, ifindex) {
+		if (found->ifindex == ifindex)
+			return found;
+	}
+
+	return NULL;
+}
+
+static __be16 ofdpa_port_internal_vlan_id_get(struct ofdpa_port *ofdpa_port,
+					      int ifindex)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_internal_vlan_tbl_entry *entry;
+	struct ofdpa_internal_vlan_tbl_entry *found;
+	unsigned long lock_flags;
+	int i;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return 0;
+
+	entry->ifindex = ifindex;
+
+	spin_lock_irqsave(&ofdpa->internal_vlan_tbl_lock, lock_flags);
+
+	found = ofdpa_internal_vlan_tbl_find(ofdpa, ifindex);
+	if (found) {
+		kfree(entry);
+		goto found;
+	}
+
+	found = entry;
+	hash_add(ofdpa->internal_vlan_tbl, &found->entry, found->ifindex);
+
+	for (i = 0; i < OFDPA_N_INTERNAL_VLANS; i++) {
+		if (test_and_set_bit(i, ofdpa->internal_vlan_bitmap))
+			continue;
+		found->vlan_id = htons(OFDPA_INTERNAL_VLAN_ID_BASE + i);
+		goto found;
+	}
+
+	netdev_err(ofdpa_port->dev, "Out of internal VLAN IDs\n");
+
+found:
+	found->ref_count++;
+	spin_unlock_irqrestore(&ofdpa->internal_vlan_tbl_lock, lock_flags);
+
+	return found->vlan_id;
+}
+
+static int ofdpa_port_fib_ipv4(struct ofdpa_port *ofdpa_port,
+			       struct switchdev_trans *trans, __be32 dst,
+			       int dst_len, const struct fib_info *fi,
+			       u32 tb_id, int flags)
+{
+	const struct fib_nh *nh;
+	__be16 eth_type = htons(ETH_P_IP);
+	__be32 dst_mask = inet_make_mask(dst_len);
+	__be16 internal_vlan_id = ofdpa_port->internal_vlan_id;
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
+	nh_on_port = (fi->fib_dev == ofdpa_port->dev);
+	has_gw = !!nh->nh_gw;
+
+	if (has_gw && nh_on_port) {
+		err = ofdpa_port_ipv4_nh(ofdpa_port, trans, flags,
+					 nh->nh_gw, &index);
+		if (err)
+			return err;
+
+		group_id = ROCKER_GROUP_L3_UNICAST(index);
+	} else {
+		/* Send to CPU for processing */
+		group_id = ROCKER_GROUP_L2_INTERFACE(internal_vlan_id, 0);
+	}
+
+	err = ofdpa_flow_tbl_ucast4_routing(ofdpa_port, trans, eth_type, dst,
+					    dst_mask, priority, goto_tbl,
+					    group_id, flags);
+	if (err)
+		netdev_err(ofdpa_port->dev, "Error (%d) IPv4 route %pI4\n",
+			   err, &dst);
+
+	return err;
+}
+
+static void
+ofdpa_port_internal_vlan_id_put(const struct ofdpa_port *ofdpa_port,
+				int ifindex)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_internal_vlan_tbl_entry *found;
+	unsigned long lock_flags;
+	unsigned long bit;
+
+	spin_lock_irqsave(&ofdpa->internal_vlan_tbl_lock, lock_flags);
+
+	found = ofdpa_internal_vlan_tbl_find(ofdpa, ifindex);
+	if (!found) {
+		netdev_err(ofdpa_port->dev,
+			   "ifindex (%d) not found in internal VLAN tbl\n",
+			   ifindex);
+		goto not_found;
+	}
+
+	if (--found->ref_count <= 0) {
+		bit = ntohs(found->vlan_id) - OFDPA_INTERNAL_VLAN_ID_BASE;
+		clear_bit(bit, ofdpa->internal_vlan_bitmap);
+		hash_del(&found->entry);
+		kfree(found);
+	}
+
+not_found:
+	spin_unlock_irqrestore(&ofdpa->internal_vlan_tbl_lock, lock_flags);
+}
+
+/**********************************
+ * Rocker world ops implementation
+ **********************************/
+
+static int ofdpa_init(struct rocker *rocker, void *priv)
+{
+	struct ofdpa *ofdpa = priv;
+
+	ofdpa->rocker = rocker;
+
+	hash_init(ofdpa->flow_tbl);
+	spin_lock_init(&ofdpa->flow_tbl_lock);
+
+	hash_init(ofdpa->group_tbl);
+	spin_lock_init(&ofdpa->group_tbl_lock);
+
+	hash_init(ofdpa->fdb_tbl);
+	spin_lock_init(&ofdpa->fdb_tbl_lock);
+
+	hash_init(ofdpa->internal_vlan_tbl);
+	spin_lock_init(&ofdpa->internal_vlan_tbl_lock);
+
+	hash_init(ofdpa->neigh_tbl);
+	spin_lock_init(&ofdpa->neigh_tbl_lock);
+
+	setup_timer(&ofdpa->fdb_cleanup_timer, ofdpa_fdb_cleanup,
+		    (unsigned long) ofdpa);
+	mod_timer(&ofdpa->fdb_cleanup_timer, jiffies);
+
+	return 0;
+}
+
+static void ofdpa_fini(void *priv)
+{
+	struct ofdpa *ofdpa = priv;
+
+	unsigned long flags;
+	struct ofdpa_flow_tbl_entry *flow_entry;
+	struct ofdpa_group_tbl_entry *group_entry;
+	struct ofdpa_fdb_tbl_entry *fdb_entry;
+	struct ofdpa_internal_vlan_tbl_entry *internal_vlan_entry;
+	struct ofdpa_neigh_tbl_entry *neigh_entry;
+	struct hlist_node *tmp;
+	int bkt;
+
+	del_timer_sync(&ofdpa->fdb_cleanup_timer);
+
+	spin_lock_irqsave(&ofdpa->flow_tbl_lock, flags);
+	hash_for_each_safe(ofdpa->flow_tbl, bkt, tmp, flow_entry, entry)
+		hash_del(&flow_entry->entry);
+	spin_unlock_irqrestore(&ofdpa->flow_tbl_lock, flags);
+
+	spin_lock_irqsave(&ofdpa->group_tbl_lock, flags);
+	hash_for_each_safe(ofdpa->group_tbl, bkt, tmp, group_entry, entry)
+		hash_del(&group_entry->entry);
+	spin_unlock_irqrestore(&ofdpa->group_tbl_lock, flags);
+
+	spin_lock_irqsave(&ofdpa->fdb_tbl_lock, flags);
+	hash_for_each_safe(ofdpa->fdb_tbl, bkt, tmp, fdb_entry, entry)
+		hash_del(&fdb_entry->entry);
+	spin_unlock_irqrestore(&ofdpa->fdb_tbl_lock, flags);
+
+	spin_lock_irqsave(&ofdpa->internal_vlan_tbl_lock, flags);
+	hash_for_each_safe(ofdpa->internal_vlan_tbl, bkt,
+			   tmp, internal_vlan_entry, entry)
+		hash_del(&internal_vlan_entry->entry);
+	spin_unlock_irqrestore(&ofdpa->internal_vlan_tbl_lock, flags);
+
+	spin_lock_irqsave(&ofdpa->neigh_tbl_lock, flags);
+	hash_for_each_safe(ofdpa->neigh_tbl, bkt, tmp, neigh_entry, entry)
+		hash_del(&neigh_entry->entry);
+	spin_unlock_irqrestore(&ofdpa->neigh_tbl_lock, flags);
+}
+
+static int ofdpa_port_init(struct rocker_port *rocker_port,
+			   void *priv, void *port_priv)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	int err;
+
+	ofdpa_port->ofdpa = priv;
+	ofdpa_port->rocker_port = rocker_port;
+	ofdpa_port->dev = rocker_port_netdev_get(rocker_port);
+	ofdpa_port->pport = rocker_port_pport_get(rocker_port);
+
+	ofdpa_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
+	ofdpa_port->ageing_time = BR_DEFAULT_AGEING_TIME;
+
+	switchdev_port_fwd_mark_set(ofdpa_port->dev, NULL, false);
+
+	rocker_port_set_learning(rocker_port,
+				 !!(ofdpa_port->brport_flags & BR_LEARNING));
+
+	err = ofdpa_port_ig_tbl(ofdpa_port, NULL, 0);
+	if (err) {
+		netdev_err(ofdpa_port->dev, "install ig port table failed\n");
+		return err;
+	}
+
+	ofdpa_port->internal_vlan_id =
+		ofdpa_port_internal_vlan_id_get(ofdpa_port,
+						ofdpa_port->dev->ifindex);
+
+	err = ofdpa_port_vlan_add(ofdpa_port, NULL, OFDPA_UNTAGGED_VID, 0);
+	if (err) {
+		netdev_err(ofdpa_port->dev, "install untagged VLAN failed\n");
+		goto err_untagged_vlan;
+	}
+	return 0;
+
+err_untagged_vlan:
+	ofdpa_port_ig_tbl(ofdpa_port, NULL, OFDPA_OP_FLAG_REMOVE);
+	return err;
+}
+
+static void ofdpa_port_fini(void *port_priv)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+
+	ofdpa_port_ig_tbl(ofdpa_port, NULL, OFDPA_OP_FLAG_REMOVE);
+}
+
+static int ofdpa_port_open(void *port_priv)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+
+	return ofdpa_port_fwd_enable(ofdpa_port, 0);
+}
+
+static void ofdpa_port_stop(void *port_priv)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+
+	ofdpa_port_fwd_disable(ofdpa_port, OFDPA_OP_FLAG_NOWAIT);
+}
+
+static int ofdpa_port_attr_stp_state_set(void *port_priv, u8 state,
+					 struct switchdev_trans *trans)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+
+	return ofdpa_port_stp_update(ofdpa_port, trans,
+				     OFDPA_OP_FLAG_NOWAIT, state);
+}
+
+static int ofdpa_port_attr_bridge_flags_set(void *port_priv,
+					    unsigned long brport_flags,
+					    struct switchdev_trans *trans)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	unsigned long orig_flags;
+	int err = 0;
+
+	orig_flags = ofdpa_port->brport_flags;
+	ofdpa_port->brport_flags = brport_flags;
+	if ((orig_flags ^ ofdpa_port->brport_flags) & BR_LEARNING &&
+	    !switchdev_trans_ph_prepare(trans))
+		err = rocker_port_set_learning(ofdpa_port->rocker_port,
+					       !!(ofdpa_port->brport_flags & BR_LEARNING));
+
+	if (switchdev_trans_ph_prepare(trans))
+		ofdpa_port->brport_flags = orig_flags;
+
+	return err;
+}
+
+static int ofdpa_port_attr_bridge_flags_get(void *port_priv,
+					    unsigned long *p_brport_flags)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+
+	*p_brport_flags = ofdpa_port->brport_flags;
+	return 0;
+}
+
+static int ofdpa_port_obj_vlan_add(void *port_priv,
+				   const struct switchdev_obj_port_vlan *vlan,
+				   struct switchdev_trans *trans)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	u16 vid;
+	int err;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
+		err = ofdpa_port_vlan_add(ofdpa_port, trans, vid, vlan->flags);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int ofdpa_port_obj_vlan_del(void *port_priv,
+				   const struct switchdev_obj_port_vlan *vlan)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	u16 vid;
+	int err;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
+		err = ofdpa_port_vlan_del(ofdpa_port, vid, vlan->flags);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int ofdpa_port_obj_vlan_dump(void *port_priv,
+				    struct switchdev_obj_port_vlan *vlan,
+				    switchdev_obj_dump_cb_t *cb)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	u16 vid;
+	int err = 0;
+
+	for (vid = 1; vid < VLAN_N_VID; vid++) {
+		if (!test_bit(vid, ofdpa_port->vlan_bitmap))
+			continue;
+		vlan->flags = 0;
+		if (ofdpa_vlan_id_is_internal(htons(vid)))
+			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
+		vlan->vid_begin = vlan->vid_end = vid;
+		err = cb(&vlan->obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+static int ofdpa_port_obj_fib4_add(void *port_priv,
+				   const struct switchdev_obj_ipv4_fib *fib4,
+				   struct switchdev_trans *trans)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+
+	return ofdpa_port_fib_ipv4(ofdpa_port, trans,
+				   htonl(fib4->dst), fib4->dst_len,
+				   fib4->fi, fib4->tb_id, 0);
+}
+
+static int ofdpa_port_obj_fib4_del(void *port_priv,
+				   const struct switchdev_obj_ipv4_fib *fib4)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+
+	return ofdpa_port_fib_ipv4(ofdpa_port, NULL,
+				   htonl(fib4->dst), fib4->dst_len,
+				   fib4->fi, fib4->tb_id,
+				   OFDPA_OP_FLAG_REMOVE);
+}
+
+static int ofdpa_port_obj_fdb_add(void *port_priv,
+				  const struct switchdev_obj_port_fdb *fdb,
+				  struct switchdev_trans *trans)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	__be16 vlan_id = ofdpa_port_vid_to_vlan(ofdpa_port, fdb->vid, NULL);
+
+	if (!ofdpa_port_is_bridged(ofdpa_port))
+		return -EINVAL;
+
+	return ofdpa_port_fdb(ofdpa_port, trans, fdb->addr, vlan_id, 0);
+}
+
+static int ofdpa_port_obj_fdb_del(void *port_priv,
+				  const struct switchdev_obj_port_fdb *fdb)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	__be16 vlan_id = ofdpa_port_vid_to_vlan(ofdpa_port, fdb->vid, NULL);
+	int flags = OFDPA_OP_FLAG_NOWAIT | OFDPA_OP_FLAG_REMOVE;
+
+	if (!ofdpa_port_is_bridged(ofdpa_port))
+		return -EINVAL;
+
+	return ofdpa_port_fdb(ofdpa_port, NULL, fdb->addr, vlan_id, flags);
+}
+
+static int ofdpa_port_obj_fdb_dump(void *port_priv,
+				   struct switchdev_obj_port_fdb *fdb,
+				   switchdev_obj_dump_cb_t *cb)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_fdb_tbl_entry *found;
+	struct hlist_node *tmp;
+	unsigned long lock_flags;
+	int bkt;
+	int err = 0;
+
+	spin_lock_irqsave(&ofdpa->fdb_tbl_lock, lock_flags);
+	hash_for_each_safe(ofdpa->fdb_tbl, bkt, tmp, found, entry) {
+		if (found->key.ofdpa_port != ofdpa_port)
+			continue;
+		fdb->addr = found->key.addr;
+		fdb->ndm_state = NUD_REACHABLE;
+		fdb->vid = ofdpa_port_vlan_to_vid(ofdpa_port,
+						  found->key.vlan_id);
+		err = cb(&fdb->obj);
+		if (err)
+			break;
+	}
+	spin_unlock_irqrestore(&ofdpa->fdb_tbl_lock, lock_flags);
+
+	return err;
+}
+
+static int ofdpa_port_bridge_join(struct ofdpa_port *ofdpa_port,
+				  struct net_device *bridge)
+{
+	int err;
+
+	/* Port is joining bridge, so the internal VLAN for the
+	 * port is going to change to the bridge internal VLAN.
+	 * Let's remove untagged VLAN (vid=0) from port and
+	 * re-add once internal VLAN has changed.
+	 */
+
+	err = ofdpa_port_vlan_del(ofdpa_port, OFDPA_UNTAGGED_VID, 0);
+	if (err)
+		return err;
+
+	ofdpa_port_internal_vlan_id_put(ofdpa_port,
+					ofdpa_port->dev->ifindex);
+	ofdpa_port->internal_vlan_id =
+		ofdpa_port_internal_vlan_id_get(ofdpa_port, bridge->ifindex);
+
+	ofdpa_port->bridge_dev = bridge;
+	switchdev_port_fwd_mark_set(ofdpa_port->dev, bridge, true);
+
+	return ofdpa_port_vlan_add(ofdpa_port, NULL, OFDPA_UNTAGGED_VID, 0);
+}
+
+static int ofdpa_port_bridge_leave(struct ofdpa_port *ofdpa_port)
+{
+	int err;
+
+	err = ofdpa_port_vlan_del(ofdpa_port, OFDPA_UNTAGGED_VID, 0);
+	if (err)
+		return err;
+
+	ofdpa_port_internal_vlan_id_put(ofdpa_port,
+					ofdpa_port->bridge_dev->ifindex);
+	ofdpa_port->internal_vlan_id =
+		ofdpa_port_internal_vlan_id_get(ofdpa_port,
+						ofdpa_port->dev->ifindex);
+
+	switchdev_port_fwd_mark_set(ofdpa_port->dev, ofdpa_port->bridge_dev,
+				    false);
+	ofdpa_port->bridge_dev = NULL;
+
+	err = ofdpa_port_vlan_add(ofdpa_port, NULL, OFDPA_UNTAGGED_VID, 0);
+	if (err)
+		return err;
+
+	if (ofdpa_port->dev->flags & IFF_UP)
+		err = ofdpa_port_fwd_enable(ofdpa_port, 0);
+
+	return err;
+}
+
+static int ofdpa_port_ovs_changed(struct ofdpa_port *ofdpa_port,
+				  struct net_device *master)
+{
+	int err;
+
+	ofdpa_port->bridge_dev = master;
+
+	err = ofdpa_port_fwd_disable(ofdpa_port, 0);
+	if (err)
+		return err;
+	err = ofdpa_port_fwd_enable(ofdpa_port, 0);
+
+	return err;
+}
+
+static int ofdpa_port_master_linked(void *port_priv,
+				    struct net_device *master)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	int err = 0;
+
+	if (netif_is_bridge_master(master))
+		err = ofdpa_port_bridge_join(ofdpa_port, master);
+	else if (netif_is_ovs_master(master))
+		err = ofdpa_port_ovs_changed(ofdpa_port, master);
+	return err;
+}
+
+static int ofdpa_port_master_unlinked(void *port_priv,
+				      struct net_device *master)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	int err = 0;
+
+	if (ofdpa_port_is_bridged(ofdpa_port))
+		err = ofdpa_port_bridge_leave(ofdpa_port);
+	else if (ofdpa_port_is_ovsed(ofdpa_port))
+		err = ofdpa_port_ovs_changed(ofdpa_port, NULL);
+	return err;
+}
+
+static int ofdpa_port_neigh_update(void *port_priv, struct neighbour *n)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	int flags = (n->nud_state & NUD_VALID ? 0 : OFDPA_OP_FLAG_REMOVE) |
+						    OFDPA_OP_FLAG_NOWAIT;
+	__be32 ip_addr = *(__be32 *) n->primary_key;
+
+	return ofdpa_port_ipv4_neigh(ofdpa_port, NULL, flags, ip_addr, n->ha);
+}
+
+static int ofdpa_port_neigh_destroy(void *port_priv, struct neighbour *n)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	int flags = OFDPA_OP_FLAG_REMOVE | OFDPA_OP_FLAG_NOWAIT;
+	__be32 ip_addr = *(__be32 *) n->primary_key;
+
+	return ofdpa_port_ipv4_neigh(ofdpa_port, NULL, flags, ip_addr, n->ha);
+}
+
+static int ofdpa_port_ev_mac_vlan_seen(void *port_priv,
+				       const unsigned char *addr,
+				       __be16 vlan_id)
+{
+	struct ofdpa_port *ofdpa_port = port_priv;
+	int flags = OFDPA_OP_FLAG_NOWAIT | OFDPA_OP_FLAG_LEARNED;
+
+	if (ofdpa_port->stp_state != BR_STATE_LEARNING &&
+	    ofdpa_port->stp_state != BR_STATE_FORWARDING)
+		return 0;
+
+	return ofdpa_port_fdb(ofdpa_port, NULL, addr, vlan_id, flags);
+}
+
 struct rocker_world_ops rocker_ofdpa_ops = {
 	.kind = "ofdpa",
 	.priv_size = sizeof(struct ofdpa),
 	.port_priv_size = sizeof(struct ofdpa_port),
 	.mode = ROCKER_PORT_MODE_OF_DPA,
+	.init = ofdpa_init,
+	.fini = ofdpa_fini,
+	.port_init = ofdpa_port_init,
+	.port_fini = ofdpa_port_fini,
+	.port_open = ofdpa_port_open,
+	.port_stop = ofdpa_port_stop,
+	.port_attr_stp_state_set = ofdpa_port_attr_stp_state_set,
+	.port_attr_bridge_flags_set = ofdpa_port_attr_bridge_flags_set,
+	.port_attr_bridge_flags_get = ofdpa_port_attr_bridge_flags_get,
+	.port_obj_vlan_add = ofdpa_port_obj_vlan_add,
+	.port_obj_vlan_del = ofdpa_port_obj_vlan_del,
+	.port_obj_vlan_dump = ofdpa_port_obj_vlan_dump,
+	.port_obj_fib4_add = ofdpa_port_obj_fib4_add,
+	.port_obj_fib4_del = ofdpa_port_obj_fib4_del,
+	.port_obj_fdb_add = ofdpa_port_obj_fdb_add,
+	.port_obj_fdb_del = ofdpa_port_obj_fdb_del,
+	.port_obj_fdb_dump = ofdpa_port_obj_fdb_dump,
+	.port_master_linked = ofdpa_port_master_linked,
+	.port_master_unlinked = ofdpa_port_master_unlinked,
+	.port_neigh_update = ofdpa_port_neigh_update,
+	.port_neigh_destroy = ofdpa_port_neigh_destroy,
+	.port_ev_mac_vlan_seen = ofdpa_port_ev_mac_vlan_seen,
 };
-- 
1.9.3
