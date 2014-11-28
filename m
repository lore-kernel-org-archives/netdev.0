From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 16/21] rocker: implement rocker ofdpa flow table manipulation
Date: Fri, 28 Nov 2014 14:34:27 +0100
Message-ID: <1417181672-11531-17-git-send-email-jiri@resnulli.us>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:56412 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaK1Ney (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:34:54 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so8893654wgh.34
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:34:53 -0800 (PST)
In-Reply-To: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The rocker driver maintains 4 hash tables: flows, groups, FDB, and VLANs.

Flow and group tables track the entries installed to OF-DPA tables,
per the OF-DPA spec.  See OF-DPA spec for full description of fields
in each flow and group table.  New table entries are pushed to the
device with ADD cmd.  Updated entries are pushed to the device with
MOD cmd.  For flow table entries, a crc32 key is made from fields of
the particular field.  For group table entries, the group_id is used
as the key.

The FDB table tracks fdb entries learned by the device or manually
pushed to the bridge by the user.  A crc32 key is made from the
port/mac/vlan tuple for the fdb entry.

The VLAN table tracks the ifindex-to-internal-vlan mapping for
untagged pkts.  On ingress, an untagged pkt is inserted with an
internal VLAN ID based on the input port's current internal VLAN ID.
The input port's internal VLAN will either be referenced by the port's
ifindex, if not bridged, or the containing bridge's ifindex, if
bridged.  Since the ifindex space isn't within a fixed range, uses a
hash table (with ifindex as key) to track internal VLAN ID for a given
ifindex.  The internal VLAN ID range is fixed and currently uses the
upper 255 VLAN IDs, starting at 0xf00.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v1->v2->v3->v4->v5:
-no change
---
 drivers/net/ethernet/rocker/rocker.c | 1469 +++++++++++++++++++++++++++++++++-
 1 file changed, 1467 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a53011c..6345f60 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -16,6 +16,7 @@
 #include <linux/sched.h>
 #include <linux/wait.h>
 #include <linux/spinlock.h>
+#include <linux/hashtable.h>
 #include <linux/crc32.h>
 #include <linux/sort.h>
 #include <linux/random.h>
@@ -27,6 +28,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/bitops.h>
 #include <net/switchdev.h>
 #include <net/rtnetlink.h>
 #include <asm-generic/io-64-nonatomic-lo-hi.h>
@@ -41,6 +43,123 @@ static const struct pci_device_id rocker_pci_id_table[] = {
 	{0, }
 };
 
+struct rocker_flow_tbl_key {
+	u32 priority;
+	enum rocker_of_dpa_table_id tbl_id;
+	union {
+		struct {
+			u32 in_lport;
+			u32 in_lport_mask;
+			enum rocker_of_dpa_table_id goto_tbl;
+		} ig_port;
+		struct {
+			u32 in_lport;
+			__be16 vlan_id;
+			__be16 vlan_id_mask;
+			enum rocker_of_dpa_table_id goto_tbl;
+			bool untagged;
+			__be16 new_vlan_id;
+		} vlan;
+		struct {
+			u32 in_lport;
+			u32 in_lport_mask;
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
+			u32 in_lport;
+			u32 in_lport_mask;
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
+struct rocker_flow_tbl_entry {
+	struct hlist_node entry;
+	u32 ref_count;
+	u64 cookie;
+	struct rocker_flow_tbl_key key;
+	u32 key_crc32; /* key */
+};
+
+struct rocker_group_tbl_entry {
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
+struct rocker_fdb_tbl_entry {
+	struct hlist_node entry;
+	u32 key_crc32; /* key */
+	bool learned;
+	struct rocker_fdb_tbl_key {
+		u32 lport;
+		u8 addr[ETH_ALEN];
+		__be16 vlan_id;
+	} key;
+};
+
+struct rocker_internal_vlan_tbl_entry {
+	struct hlist_node entry;
+	int ifindex; /* key */
+	u32 ref_count;
+	__be16 vlan_id;
+};
+
 struct rocker_desc_info {
 	char *data; /* mapped */
 	size_t data_size;
@@ -61,11 +180,28 @@ struct rocker_dma_ring_info {
 
 struct rocker;
 
+enum {
+	ROCKER_CTRL_LINK_LOCAL_MCAST,
+	ROCKER_CTRL_LOCAL_ARP,
+	ROCKER_CTRL_IPV4_MCAST,
+	ROCKER_CTRL_IPV6_MCAST,
+	ROCKER_CTRL_DFLT_BRIDGING,
+	ROCKER_CTRL_MAX,
+};
+
+#define ROCKER_INTERNAL_VLAN_ID_BASE	0x0f00
+#define ROCKER_N_INTERNAL_VLANS		255
+#define ROCKER_VLAN_BITMAP_LEN		BITS_TO_LONGS(VLAN_N_VID)
+#define ROCKER_INTERNAL_VLAN_BITMAP_LEN	BITS_TO_LONGS(ROCKER_N_INTERNAL_VLANS)
+
 struct rocker_port {
 	struct net_device *dev;
 	struct rocker *rocker;
 	unsigned int port_number;
 	u32 lport;
+	__be16 internal_vlan_id;
+	bool ctrls[ROCKER_CTRL_MAX];
+	unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
 	struct napi_struct napi_tx;
 	struct napi_struct napi_rx;
 	struct rocker_dma_ring_info tx_ring;
@@ -84,8 +220,76 @@ struct rocker {
 	spinlock_t cmd_ring_lock;
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
+	DECLARE_HASHTABLE(flow_tbl, 16);
+	spinlock_t flow_tbl_lock;
+	u64 flow_tbl_next_cookie;
+	DECLARE_HASHTABLE(group_tbl, 16);
+	spinlock_t group_tbl_lock;
+	DECLARE_HASHTABLE(fdb_tbl, 16);
+	spinlock_t fdb_tbl_lock;
+	unsigned long internal_vlan_bitmap[ROCKER_INTERNAL_VLAN_BITMAP_LEN];
+	DECLARE_HASHTABLE(internal_vlan_tbl, 8);
+	spinlock_t internal_vlan_tbl_lock;
+};
+
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
+	ROCKER_PRIORITY_UNKNOWN = 0,
+	ROCKER_PRIORITY_IG_PORT = 1,
+	ROCKER_PRIORITY_VLAN = 1,
+	ROCKER_PRIORITY_TERM_MAC_UCAST = 0,
+	ROCKER_PRIORITY_TERM_MAC_MCAST = 1,
+	ROCKER_PRIORITY_UNICAST_ROUTING = 1,
+	ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT = 1,
+	ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD = 2,
+	ROCKER_PRIORITY_BRIDGING_VLAN = 3,
+	ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_EXACT = 1,
+	ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_WILD = 2,
+	ROCKER_PRIORITY_BRIDGING_TENANT = 3,
+	ROCKER_PRIORITY_ACL_CTRL = 3,
+	ROCKER_PRIORITY_ACL_NORMAL = 2,
+	ROCKER_PRIORITY_ACL_DFLT = 1,
 };
 
+static bool rocker_vlan_id_is_internal(__be16 vlan_id)
+{
+	u16 start = ROCKER_INTERNAL_VLAN_ID_BASE;
+	u16 end = 0xffe;
+	u16 _vlan_id = ntohs(vlan_id);
+
+	return (_vlan_id >= start && _vlan_id <= end);
+}
+
+static __be16 rocker_port_vid_to_vlan(struct rocker_port *rocker_port,
+				      u16 vid, bool *pop_vlan)
+{
+	__be16 vlan_id;
+
+	if (pop_vlan)
+		*pop_vlan = false;
+	vlan_id = htons(vid);
+	if (!vlan_id) {
+		vlan_id = rocker_port->internal_vlan_id;
+		if (pop_vlan)
+			*pop_vlan = true;
+	}
+
+	return vlan_id;
+}
+
 struct rocker_wait {
 	wait_queue_head_t wait;
 	bool done;
@@ -1094,6 +1298,10 @@ static int rocker_event_link_change(struct rocker *rocker,
 	return 0;
 }
 
+#define ROCKER_OP_FLAG_REMOVE		BIT(0)
+#define ROCKER_OP_FLAG_NOWAIT		BIT(1)
+#define ROCKER_OP_FLAG_LEARNED		BIT(2)
+
 static int rocker_event_process(struct rocker *rocker,
 				struct rocker_desc_info *desc_info)
 {
@@ -1399,6 +1607,1240 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 			       macaddr, NULL, NULL, false);
 }
 
+static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
+					   struct rocker_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
+			       entry->key.ig_port.in_lport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
+			       entry->key.ig_port.in_lport_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.ig_port.goto_tbl))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
+					struct rocker_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
+			       entry->key.vlan.in_lport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->key.vlan.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+			       entry->key.vlan.vlan_id_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.vlan.goto_tbl))
+		return -EMSGSIZE;
+	if (entry->key.vlan.untagged &&
+	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_NEW_VLAN_ID,
+			       entry->key.vlan.new_vlan_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int rocker_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
+					    struct rocker_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
+			       entry->key.term_mac.in_lport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
+			       entry->key.term_mac.in_lport_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+			       entry->key.term_mac.eth_type))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
+			   ETH_ALEN, entry->key.term_mac.eth_dst))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
+			   ETH_ALEN, entry->key.term_mac.eth_dst_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->key.term_mac.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+			       entry->key.term_mac.vlan_id_mask))
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
+rocker_cmd_flow_tbl_add_ucast_routing(struct rocker_desc_info *desc_info,
+				      struct rocker_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+			       entry->key.ucast_routing.eth_type))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_DST_IP,
+			       entry->key.ucast_routing.dst4))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_DST_IP_MASK,
+			       entry->key.ucast_routing.dst4_mask))
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
+static int rocker_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
+					  struct rocker_flow_tbl_entry *entry)
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
+	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->key.bridge.vlan_id))
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
+static int rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
+				       struct rocker_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
+			       entry->key.acl.in_lport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
+			       entry->key.acl.in_lport_mask))
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
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+			       entry->key.acl.eth_type))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->key.acl.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+			       entry->key.acl.vlan_id_mask))
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
+static int rocker_cmd_flow_tbl_add(struct rocker *rocker,
+				   struct rocker_port *rocker_port,
+				   struct rocker_desc_info *desc_info,
+				   void *priv)
+{
+	struct rocker_flow_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+	int err = 0;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD))
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
+		err = rocker_cmd_flow_tbl_add_ig_port(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_VLAN:
+		err = rocker_cmd_flow_tbl_add_vlan(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC:
+		err = rocker_cmd_flow_tbl_add_term_mac(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING:
+		err = rocker_cmd_flow_tbl_add_ucast_routing(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_BRIDGING:
+		err = rocker_cmd_flow_tbl_add_bridge(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_ACL_POLICY:
+		err = rocker_cmd_flow_tbl_add_acl(desc_info, entry);
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
+static int rocker_cmd_flow_tbl_del(struct rocker *rocker,
+				   struct rocker_port *rocker_port,
+				   struct rocker_desc_info *desc_info,
+				   void *priv)
+{
+	const struct rocker_flow_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL))
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
+rocker_cmd_group_tbl_add_l2_interface(struct rocker_desc_info *desc_info,
+				      struct rocker_group_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_OUT_LPORT,
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
+rocker_cmd_group_tbl_add_l2_rewrite(struct rocker_desc_info *desc_info,
+				    struct rocker_group_tbl_entry *entry)
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
+	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->l2_rewrite.vlan_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+rocker_cmd_group_tbl_add_group_ids(struct rocker_desc_info *desc_info,
+				   struct rocker_group_tbl_entry *entry)
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
+rocker_cmd_group_tbl_add_l3_unicast(struct rocker_desc_info *desc_info,
+				    struct rocker_group_tbl_entry *entry)
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
+	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->l3_unicast.vlan_id))
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
+static int rocker_cmd_group_tbl_add(struct rocker *rocker,
+				    struct rocker_port *rocker_port,
+				    struct rocker_desc_info *desc_info,
+				    void *priv)
+{
+	struct rocker_group_tbl_entry *entry = priv;
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
+		err = rocker_cmd_group_tbl_add_l2_interface(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_REWRITE:
+		err = rocker_cmd_group_tbl_add_l2_rewrite(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
+		err = rocker_cmd_group_tbl_add_group_ids(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_GROUP_TYPE_L3_UCAST:
+		err = rocker_cmd_group_tbl_add_l3_unicast(desc_info, entry);
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
+static int rocker_cmd_group_tbl_del(struct rocker *rocker,
+				    struct rocker_port *rocker_port,
+				    struct rocker_desc_info *desc_info,
+				    void *priv)
+{
+	const struct rocker_group_tbl_entry *entry = priv;
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
+/*****************************************
+ * Flow, group, FDB, internal VLAN tables
+ *****************************************/
+
+static int rocker_init_tbls(struct rocker *rocker)
+{
+	hash_init(rocker->flow_tbl);
+	spin_lock_init(&rocker->flow_tbl_lock);
+
+	hash_init(rocker->group_tbl);
+	spin_lock_init(&rocker->group_tbl_lock);
+
+	hash_init(rocker->fdb_tbl);
+	spin_lock_init(&rocker->fdb_tbl_lock);
+
+	hash_init(rocker->internal_vlan_tbl);
+	spin_lock_init(&rocker->internal_vlan_tbl_lock);
+
+	return 0;
+}
+
+static void rocker_free_tbls(struct rocker *rocker)
+{
+	unsigned long flags;
+	struct rocker_flow_tbl_entry *flow_entry;
+	struct rocker_group_tbl_entry *group_entry;
+	struct rocker_fdb_tbl_entry *fdb_entry;
+	struct rocker_internal_vlan_tbl_entry *internal_vlan_entry;
+	struct hlist_node *tmp;
+	int bkt;
+
+	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+	hash_for_each_safe(rocker->flow_tbl, bkt, tmp, flow_entry, entry)
+		hash_del(&flow_entry->entry);
+	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+
+	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+	hash_for_each_safe(rocker->group_tbl, bkt, tmp, group_entry, entry)
+		hash_del(&group_entry->entry);
+	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+
+	spin_lock_irqsave(&rocker->fdb_tbl_lock, flags);
+	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, fdb_entry, entry)
+		hash_del(&fdb_entry->entry);
+	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, flags);
+
+	spin_lock_irqsave(&rocker->internal_vlan_tbl_lock, flags);
+	hash_for_each_safe(rocker->internal_vlan_tbl, bkt,
+			   tmp, internal_vlan_entry, entry)
+		hash_del(&internal_vlan_entry->entry);
+	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, flags);
+}
+
+static struct rocker_flow_tbl_entry *
+rocker_flow_tbl_find(struct rocker *rocker, struct rocker_flow_tbl_entry *match)
+{
+	struct rocker_flow_tbl_entry *found;
+
+	hash_for_each_possible(rocker->flow_tbl, found,
+			       entry, match->key_crc32) {
+		if (memcmp(&found->key, &match->key, sizeof(found->key)) == 0)
+			return found;
+	}
+
+	return NULL;
+}
+
+static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
+			       struct rocker_flow_tbl_entry *match,
+			       bool nowait)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_flow_tbl_entry *found;
+	unsigned long flags;
+	bool add_to_hw = false;
+	int err = 0;
+
+	match->key_crc32 = crc32(~0, &match->key, sizeof(match->key));
+
+	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+
+	found = rocker_flow_tbl_find(rocker, match);
+
+	if (found) {
+		kfree(match);
+	} else {
+		found = match;
+		found->cookie = rocker->flow_tbl_next_cookie++;
+		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
+		add_to_hw = true;
+	}
+
+	found->ref_count++;
+
+	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+
+	if (add_to_hw) {
+		err = rocker_cmd_exec(rocker, rocker_port,
+				      rocker_cmd_flow_tbl_add,
+				      found, NULL, NULL, nowait);
+		if (err) {
+			spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+			hash_del(&found->entry);
+			spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+			kfree(found);
+		}
+	}
+
+	return err;
+}
+
+static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
+			       struct rocker_flow_tbl_entry *match,
+			       bool nowait)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_flow_tbl_entry *found;
+	unsigned long flags;
+	bool del_from_hw = false;
+	int err = 0;
+
+	match->key_crc32 = crc32(~0, &match->key, sizeof(match->key));
+
+	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+
+	found = rocker_flow_tbl_find(rocker, match);
+
+	if (found) {
+		found->ref_count--;
+		if (found->ref_count == 0) {
+			hash_del(&found->entry);
+			del_from_hw = true;
+		}
+	}
+
+	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+
+	kfree(match);
+
+	if (del_from_hw) {
+		err = rocker_cmd_exec(rocker, rocker_port,
+				      rocker_cmd_flow_tbl_del,
+				      found, NULL, NULL, nowait);
+		kfree(found);
+	}
+
+	return err;
+}
+
+static gfp_t rocker_op_flags_gfp(int flags)
+{
+	return flags & ROCKER_OP_FLAG_NOWAIT ? GFP_ATOMIC : GFP_KERNEL;
+}
+
+static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
+			      int flags, struct rocker_flow_tbl_entry *entry)
+{
+	bool nowait = flags & ROCKER_OP_FLAG_NOWAIT;
+
+	if (flags & ROCKER_OP_FLAG_REMOVE)
+		return rocker_flow_tbl_del(rocker_port, entry, nowait);
+	else
+		return rocker_flow_tbl_add(rocker_port, entry, nowait);
+}
+
+static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
+				   int flags, u32 in_lport, u32 in_lport_mask,
+				   enum rocker_of_dpa_table_id goto_tbl)
+{
+	struct rocker_flow_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.priority = ROCKER_PRIORITY_IG_PORT;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT;
+	entry->key.ig_port.in_lport = in_lport;
+	entry->key.ig_port.in_lport_mask = in_lport_mask;
+	entry->key.ig_port.goto_tbl = goto_tbl;
+
+	return rocker_flow_tbl_do(rocker_port, flags, entry);
+}
+
+static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
+				int flags, u32 in_lport,
+				__be16 vlan_id, __be16 vlan_id_mask,
+				enum rocker_of_dpa_table_id goto_tbl,
+				bool untagged, __be16 new_vlan_id)
+{
+	struct rocker_flow_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.priority = ROCKER_PRIORITY_VLAN;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_VLAN;
+	entry->key.vlan.in_lport = in_lport;
+	entry->key.vlan.vlan_id = vlan_id;
+	entry->key.vlan.vlan_id_mask = vlan_id_mask;
+	entry->key.vlan.goto_tbl = goto_tbl;
+
+	entry->key.vlan.untagged = untagged;
+	entry->key.vlan.new_vlan_id = new_vlan_id;
+
+	return rocker_flow_tbl_do(rocker_port, flags, entry);
+}
+
+static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
+				    u32 in_lport, u32 in_lport_mask,
+				    __be16 eth_type, const u8 *eth_dst,
+				    const u8 *eth_dst_mask, __be16 vlan_id,
+				    __be16 vlan_id_mask, bool copy_to_cpu,
+				    int flags)
+{
+	struct rocker_flow_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	if (is_multicast_ether_addr(eth_dst)) {
+		entry->key.priority = ROCKER_PRIORITY_TERM_MAC_MCAST;
+		entry->key.term_mac.goto_tbl =
+			 ROCKER_OF_DPA_TABLE_ID_MULTICAST_ROUTING;
+	} else {
+		entry->key.priority = ROCKER_PRIORITY_TERM_MAC_UCAST;
+		entry->key.term_mac.goto_tbl =
+			 ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING;
+	}
+
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
+	entry->key.term_mac.in_lport = in_lport;
+	entry->key.term_mac.in_lport_mask = in_lport_mask;
+	entry->key.term_mac.eth_type = eth_type;
+	ether_addr_copy(entry->key.term_mac.eth_dst, eth_dst);
+	ether_addr_copy(entry->key.term_mac.eth_dst_mask, eth_dst_mask);
+	entry->key.term_mac.vlan_id = vlan_id;
+	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
+	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
+
+	return rocker_flow_tbl_do(rocker_port, flags, entry);
+}
+
+static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
+				  int flags,
+				  const u8 *eth_dst, const u8 *eth_dst_mask,
+				  __be16 vlan_id, u32 tunnel_id,
+				  enum rocker_of_dpa_table_id goto_tbl,
+				  u32 group_id, bool copy_to_cpu)
+{
+	struct rocker_flow_tbl_entry *entry;
+	u32 priority;
+	bool vlan_bridging = !!vlan_id;
+	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
+	bool wild = false;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
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
+		if (memcmp(eth_dst_mask, ff_mac, ETH_ALEN))
+			wild = true;
+	}
+
+	priority = ROCKER_PRIORITY_UNKNOWN;
+	if (vlan_bridging & dflt & wild)
+		priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD;
+	else if (vlan_bridging & dflt & !wild)
+		priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT;
+	else if (vlan_bridging & !dflt)
+		priority = ROCKER_PRIORITY_BRIDGING_VLAN;
+	else if (!vlan_bridging & dflt & wild)
+		priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_WILD;
+	else if (!vlan_bridging & dflt & !wild)
+		priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_EXACT;
+	else if (!vlan_bridging & !dflt)
+		priority = ROCKER_PRIORITY_BRIDGING_TENANT;
+
+	entry->key.priority = priority;
+	entry->key.bridge.vlan_id = vlan_id;
+	entry->key.bridge.tunnel_id = tunnel_id;
+	entry->key.bridge.goto_tbl = goto_tbl;
+	entry->key.bridge.group_id = group_id;
+	entry->key.bridge.copy_to_cpu = copy_to_cpu;
+
+	return rocker_flow_tbl_do(rocker_port, flags, entry);
+}
+
+static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
+			       int flags, u32 in_lport,
+			       u32 in_lport_mask,
+			       const u8 *eth_src, const u8 *eth_src_mask,
+			       const u8 *eth_dst, const u8 *eth_dst_mask,
+			       __be16 eth_type,
+			       __be16 vlan_id, __be16 vlan_id_mask,
+			       u8 ip_proto, u8 ip_proto_mask,
+			       u8 ip_tos, u8 ip_tos_mask,
+			       u32 group_id)
+{
+	u32 priority;
+	struct rocker_flow_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	priority = ROCKER_PRIORITY_ACL_NORMAL;
+	if (eth_dst && eth_dst_mask) {
+		if (memcmp(eth_dst_mask, mcast_mac, ETH_ALEN) == 0)
+			priority = ROCKER_PRIORITY_ACL_DFLT;
+		else if (is_link_local_ether_addr(eth_dst))
+			priority = ROCKER_PRIORITY_ACL_CTRL;
+	}
+
+	entry->key.priority = priority;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	entry->key.acl.in_lport = in_lport;
+	entry->key.acl.in_lport_mask = in_lport_mask;
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
+	return rocker_flow_tbl_do(rocker_port, flags, entry);
+}
+
+static struct rocker_group_tbl_entry *
+rocker_group_tbl_find(struct rocker *rocker,
+		      struct rocker_group_tbl_entry *match)
+{
+	struct rocker_group_tbl_entry *found;
+
+	hash_for_each_possible(rocker->group_tbl, found,
+			       entry, match->group_id) {
+		if (found->group_id == match->group_id)
+			return found;
+	}
+
+	return NULL;
+}
+
+static void rocker_group_tbl_entry_free(struct rocker_group_tbl_entry *entry)
+{
+	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
+		kfree(entry->group_ids);
+		break;
+	default:
+		break;
+	}
+	kfree(entry);
+}
+
+static int rocker_group_tbl_add(struct rocker_port *rocker_port,
+				struct rocker_group_tbl_entry *match,
+				bool nowait)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_group_tbl_entry *found;
+	unsigned long flags;
+	int err = 0;
+
+	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+
+	found = rocker_group_tbl_find(rocker, match);
+
+	if (found) {
+		hash_del(&found->entry);
+		rocker_group_tbl_entry_free(found);
+		found = match;
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD;
+	} else {
+		found = match;
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD;
+	}
+
+	hash_add(rocker->group_tbl, &found->entry, found->group_id);
+
+	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+
+	if (found->cmd)
+		err = rocker_cmd_exec(rocker, rocker_port,
+				      rocker_cmd_group_tbl_add,
+				      found, NULL, NULL, nowait);
+
+	return err;
+}
+
+static int rocker_group_tbl_del(struct rocker_port *rocker_port,
+				struct rocker_group_tbl_entry *match,
+				bool nowait)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_group_tbl_entry *found;
+	unsigned long flags;
+	int err = 0;
+
+	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+
+	found = rocker_group_tbl_find(rocker, match);
+
+	if (found) {
+		hash_del(&found->entry);
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL;
+	}
+
+	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+
+	rocker_group_tbl_entry_free(match);
+
+	if (found) {
+		err = rocker_cmd_exec(rocker, rocker_port,
+				      rocker_cmd_group_tbl_del,
+				      found, NULL, NULL, nowait);
+		rocker_group_tbl_entry_free(found);
+	}
+
+	return err;
+}
+
+static int rocker_group_tbl_do(struct rocker_port *rocker_port,
+			       int flags, struct rocker_group_tbl_entry *entry)
+{
+	bool nowait = flags & ROCKER_OP_FLAG_NOWAIT;
+
+	if (flags & ROCKER_OP_FLAG_REMOVE)
+		return rocker_group_tbl_del(rocker_port, entry, nowait);
+	else
+		return rocker_group_tbl_add(rocker_port, entry, nowait);
+}
+
+static int rocker_group_l2_interface(struct rocker_port *rocker_port,
+				     int flags, __be16 vlan_id,
+				     u32 out_lport, int pop_vlan)
+{
+	struct rocker_group_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
+	entry->l2_interface.pop_vlan = pop_vlan;
+
+	return rocker_group_tbl_do(rocker_port, flags, entry);
+}
+
+static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
+				   int flags, u8 group_count,
+				   u32 *group_ids, u32 group_id)
+{
+	struct rocker_group_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->group_id = group_id;
+	entry->group_count = group_count;
+
+	entry->group_ids = kcalloc(group_count, sizeof(u32),
+				   rocker_op_flags_gfp(flags));
+	if (!entry->group_ids) {
+		kfree(entry);
+		return -ENOMEM;
+	}
+	memcpy(entry->group_ids, group_ids, group_count * sizeof(u32));
+
+	return rocker_group_tbl_do(rocker_port, flags, entry);
+}
+
+static int rocker_group_l2_flood(struct rocker_port *rocker_port,
+				 int flags, __be16 vlan_id,
+				 u8 group_count, u32 *group_ids,
+				 u32 group_id)
+{
+	return rocker_group_l2_fan_out(rocker_port, flags,
+				       group_count, group_ids,
+				       group_id);
+}
+
+static struct rocker_ctrl {
+	const u8 *eth_dst;
+	const u8 *eth_dst_mask;
+	u16 eth_type;
+	bool acl;
+	bool bridge;
+	bool term;
+	bool copy_to_cpu;
+} rocker_ctrls[] = {
+	[ROCKER_CTRL_LINK_LOCAL_MCAST] = {
+		/* pass link local multicast pkts up to CPU for filtering */
+		.eth_dst = ll_mac,
+		.eth_dst_mask = ll_mask,
+		.acl = true,
+	},
+	[ROCKER_CTRL_LOCAL_ARP] = {
+		/* pass local ARP pkts up to CPU */
+		.eth_dst = zero_mac,
+		.eth_dst_mask = zero_mac,
+		.eth_type = htons(ETH_P_ARP),
+		.acl = true,
+	},
+	[ROCKER_CTRL_IPV4_MCAST] = {
+		/* pass IPv4 mcast pkts up to CPU, RFC 1112 */
+		.eth_dst = ipv4_mcast,
+		.eth_dst_mask = ipv4_mask,
+		.eth_type = htons(ETH_P_IP),
+		.term  = true,
+		.copy_to_cpu = true,
+	},
+	[ROCKER_CTRL_IPV6_MCAST] = {
+		/* pass IPv6 mcast pkts up to CPU, RFC 2464 */
+		.eth_dst = ipv6_mcast,
+		.eth_dst_mask = ipv6_mask,
+		.eth_type = htons(ETH_P_IPV6),
+		.term  = true,
+		.copy_to_cpu = true,
+	},
+	[ROCKER_CTRL_DFLT_BRIDGING] = {
+		/* flood any pkts on vlan */
+		.bridge = true,
+		.copy_to_cpu = true,
+	},
+};
+
+static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
+				     int flags, struct rocker_ctrl *ctrl,
+				     __be16 vlan_id)
+{
+	u32 in_lport = rocker_port->lport;
+	u32 in_lport_mask = 0xffffffff;
+	u32 out_lport = 0;
+	u8 *eth_src = NULL;
+	u8 *eth_src_mask = NULL;
+	__be16 vlan_id_mask = htons(0xffff);
+	u8 ip_proto = 0;
+	u8 ip_proto_mask = 0;
+	u8 ip_tos = 0;
+	u8 ip_tos_mask = 0;
+	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
+	int err;
+
+	err = rocker_flow_tbl_acl(rocker_port, flags,
+				  in_lport, in_lport_mask,
+				  eth_src, eth_src_mask,
+				  ctrl->eth_dst, ctrl->eth_dst_mask,
+				  ctrl->eth_type,
+				  vlan_id, vlan_id_mask,
+				  ip_proto, ip_proto_mask,
+				  ip_tos, ip_tos_mask,
+				  group_id);
+
+	if (err)
+		netdev_err(rocker_port->dev, "Error (%d) ctrl ACL\n", err);
+
+	return err;
+}
+
+static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
+				      int flags, struct rocker_ctrl *ctrl,
+				      __be16 vlan_id)
+{
+	u32 in_lport_mask = 0xffffffff;
+	__be16 vlan_id_mask = htons(0xffff);
+	int err;
+
+	if (ntohs(vlan_id) == 0)
+		vlan_id = rocker_port->internal_vlan_id;
+
+	err = rocker_flow_tbl_term_mac(rocker_port,
+				       rocker_port->lport, in_lport_mask,
+				       ctrl->eth_type, ctrl->eth_dst,
+				       ctrl->eth_dst_mask, vlan_id,
+				       vlan_id_mask, ctrl->copy_to_cpu,
+				       flags);
+
+	if (err)
+		netdev_err(rocker_port->dev, "Error (%d) ctrl term\n", err);
+
+	return err;
+}
+
+static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port, int flags,
+				 struct rocker_ctrl *ctrl, __be16 vlan_id)
+{
+	if (ctrl->acl)
+		return rocker_port_ctrl_vlan_acl(rocker_port, flags,
+						 ctrl, vlan_id);
+
+	if (ctrl->term)
+		return rocker_port_ctrl_vlan_term(rocker_port, flags,
+						  ctrl, vlan_id);
+
+	return -EOPNOTSUPP;
+}
+
+static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
+				     int flags, __be16 vlan_id)
+{
+	int err = 0;
+	int i;
+
+	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
+		if (rocker_port->ctrls[i]) {
+			err = rocker_port_ctrl_vlan(rocker_port, flags,
+						    &rocker_ctrls[i], vlan_id);
+			if (err)
+				return err;
+		}
+	}
+
+	return err;
+}
+
+static int rocker_port_ctrl(struct rocker_port *rocker_port, int flags,
+			    struct rocker_ctrl *ctrl)
+{
+	u16 vid;
+	int err = 0;
+
+	for (vid = 1; vid < VLAN_N_VID; vid++) {
+		if (!test_bit(vid, rocker_port->vlan_bitmap))
+			continue;
+		err = rocker_port_ctrl_vlan(rocker_port, flags,
+					    ctrl, htons(vid));
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
+{
+	enum rocker_of_dpa_table_id goto_tbl;
+	u32 in_lport;
+	u32 in_lport_mask;
+	int err;
+
+	/* Normal Ethernet Frames.  Matches pkts from any local physical
+	 * ports.  Goto VLAN tbl.
+	 */
+
+	in_lport = 0;
+	in_lport_mask = 0xffff0000;
+	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
+
+	err = rocker_flow_tbl_ig_port(rocker_port, flags,
+				      in_lport, in_lport_mask,
+				      goto_tbl);
+	if (err)
+		netdev_err(rocker_port->dev,
+			   "Error (%d) ingress port table entry\n", err);
+
+	return err;
+}
+
+static int rocker_port_router_mac(struct rocker_port *rocker_port,
+				  int flags, __be16 vlan_id)
+{
+	u32 in_lport_mask = 0xffffffff;
+	__be16 eth_type;
+	const u8 *dst_mac_mask = ff_mac;
+	__be16 vlan_id_mask = htons(0xffff);
+	bool copy_to_cpu = false;
+	int err;
+
+	if (ntohs(vlan_id) == 0)
+		vlan_id = rocker_port->internal_vlan_id;
+
+	eth_type = htons(ETH_P_IP);
+	err = rocker_flow_tbl_term_mac(rocker_port,
+				       rocker_port->lport, in_lport_mask,
+				       eth_type, rocker_port->dev->dev_addr,
+				       dst_mac_mask, vlan_id, vlan_id_mask,
+				       copy_to_cpu, flags);
+	if (err)
+		return err;
+
+	eth_type = htons(ETH_P_IPV6);
+	err = rocker_flow_tbl_term_mac(rocker_port,
+				       rocker_port->lport, in_lport_mask,
+				       eth_type, rocker_port->dev->dev_addr,
+				       dst_mac_mask, vlan_id, vlan_id_mask,
+				       copy_to_cpu, flags);
+
+	return err;
+}
+
+static struct rocker_internal_vlan_tbl_entry *
+rocker_internal_vlan_tbl_find(struct rocker *rocker, int ifindex)
+{
+	struct rocker_internal_vlan_tbl_entry *found;
+
+	hash_for_each_possible(rocker->internal_vlan_tbl, found,
+			       entry, ifindex) {
+		if (found->ifindex == ifindex)
+			return found;
+	}
+
+	return NULL;
+}
+
+static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
+					       int ifindex)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_internal_vlan_tbl_entry *entry;
+	struct rocker_internal_vlan_tbl_entry *found;
+	unsigned long lock_flags;
+	int i;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return 0;
+
+	entry->ifindex = ifindex;
+
+	spin_lock_irqsave(&rocker->internal_vlan_tbl_lock, lock_flags);
+
+	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
+	if (found) {
+		kfree(entry);
+		goto found;
+	}
+
+	found = entry;
+	hash_add(rocker->internal_vlan_tbl, &found->entry, found->ifindex);
+
+	for (i = 0; i < ROCKER_N_INTERNAL_VLANS; i++) {
+		if (test_and_set_bit(i, rocker->internal_vlan_bitmap))
+			continue;
+		found->vlan_id = htons(ROCKER_INTERNAL_VLAN_ID_BASE + i);
+		goto found;
+	}
+
+	netdev_err(rocker_port->dev, "Out of internal VLAN IDs\n");
+
+found:
+	found->ref_count++;
+	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, lock_flags);
+
+	return found->vlan_id;
+}
+
+static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
+					     int ifindex)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_internal_vlan_tbl_entry *found;
+	unsigned long lock_flags;
+	unsigned long bit;
+
+	spin_lock_irqsave(&rocker->internal_vlan_tbl_lock, lock_flags);
+
+	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
+	if (!found) {
+		netdev_err(rocker_port->dev,
+			   "ifindex (%d) not found in internal VLAN tbl\n",
+			   ifindex);
+		goto not_found;
+	}
+
+	if (--found->ref_count <= 0) {
+		bit = ntohs(found->vlan_id) - ROCKER_INTERNAL_VLAN_ID_BASE;
+		clear_bit(bit, rocker->internal_vlan_bitmap);
+		hash_del(&found->entry);
+		kfree(found);
+	}
+
+not_found:
+	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, lock_flags);
+}
+
 /*****************
  * Net device ops
  *****************/
@@ -1768,10 +3210,14 @@ static void rocker_carrier_init(struct rocker_port *rocker_port)
 
 static void rocker_remove_ports(struct rocker *rocker)
 {
+	struct rocker_port *rocker_port;
 	int i;
 
-	for (i = 0; i < rocker->port_count; i++)
-		unregister_netdev(rocker->ports[i]->dev);
+	for (i = 0; i < rocker->port_count; i++) {
+		rocker_port = rocker->ports[i];
+		rocker_port_ig_tbl(rocker_port, ROCKER_OP_FLAG_REMOVE);
+		unregister_netdev(rocker_port->dev);
+	}
 	kfree(rocker->ports);
 }
 
@@ -1823,8 +3269,18 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	}
 	rocker->ports[port_number] = rocker_port;
 
+	rocker_port->internal_vlan_id =
+		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
+	err = rocker_port_ig_tbl(rocker_port, 0);
+	if (err) {
+		dev_err(&pdev->dev, "install ig port table failed\n");
+		goto err_port_ig_tbl;
+	}
+
 	return 0;
 
+err_port_ig_tbl:
+	unregister_netdev(dev);
 err_register_netdev:
 	free_netdev(dev);
 	return err;
@@ -1981,6 +3437,12 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	rocker->hw.id = rocker_read64(rocker, SWITCH_ID);
 
+	err = rocker_init_tbls(rocker);
+	if (err) {
+		dev_err(&pdev->dev, "cannot init rocker tables\n");
+		goto err_init_tbls;
+	}
+
 	err = rocker_probe_ports(rocker);
 	if (err) {
 		dev_err(&pdev->dev, "failed to probe ports\n");
@@ -1992,6 +3454,8 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	return 0;
 
 err_probe_ports:
+	rocker_free_tbls(rocker);
+err_init_tbls:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
 err_request_event_irq:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD), rocker);
@@ -2017,6 +3481,7 @@ static void rocker_remove(struct pci_dev *pdev)
 {
 	struct rocker *rocker = pci_get_drvdata(pdev);
 
+	rocker_free_tbls(rocker);
 	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
 	rocker_remove_ports(rocker);
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
-- 
1.9.3
