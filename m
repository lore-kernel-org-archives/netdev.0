From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/13] batman-adv: kernel doc for types.h
Date: Sat, 19 Jan 2013 21:27:55 +0800
Message-ID: <1358602079-24024-10-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:58094 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab3ASNaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:30:01 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Thanks to Sven Eckelmann and Simon Wunderlich for their support.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/types.h | 463 ++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 396 insertions(+), 67 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 549ba56..03197f5 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -24,6 +24,9 @@
 #include "bitarray.h"
 #include <linux/kernel.h>
 
+/**
+ * Maximum overhead for the encapsulation for a payload packet
+ */
 #define BATADV_HEADER_LEN \
 	(ETH_HLEN + max(sizeof(struct batadv_unicast_packet), \
 			sizeof(struct batadv_bcast_packet)))
@@ -51,6 +54,21 @@ struct batadv_hard_iface_bat_iv {
 	atomic_t ogm_seqno;
 };
 
+/**
+ * struct batadv_hard_iface - network device known to batman-adv
+ * @list: list node for batadv_hardif_list
+ * @if_num: identificator of the interface
+ * @if_status: status of the interface for batman-adv
+ * @net_dev: pointer to the net_device
+ * @frag_seqno: last fragment sequence number sent by this interface
+ * @hardif_obj: kobject of the per interface sysfs "mesh" directory
+ * @refcount: number of contexts the object is used
+ * @batman_adv_ptype: packet type describing packets that should be processed by
+ *  batman-adv for this interface
+ * @soft_iface: the batman-adv interface which uses this network interface
+ * @rcu: struct used for freeing in an RCU-safe manner
+ * @bat_iv: BATMAN IV specific per hard interface data
+ */
 struct batadv_hard_iface {
 	struct list_head list;
 	int16_t if_num;
@@ -67,17 +85,47 @@ struct batadv_hard_iface {
 
 /**
  * struct batadv_orig_node - structure for orig_list maintaining nodes of mesh
+ * @orig: originator ethernet address
  * @primary_addr: hosts primary interface address
- * @last_seen: when last packet from this node was received
+ * @router: router that should be used to reach this originator
+ * @batadv_dat_addr_t:  address of the orig node in the distributed hash
+ * @bcast_own: bitfield containing the number of our OGMs this orig_node
+ *  rebroadcasted "back" to us (relative to last_real_seqno)
+ * @bcast_own_sum: counted result of bcast_own
+ * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
  * @batman_seqno_reset: time when the batman seqno window was reset
  * @gw_flags: flags related to gateway class
  * @flags: for now only VIS_SERVER flag
+ * @last_ttvn: last seen translation table version number
+ * @tt_crc: CRC of the translation table
+ * @tt_buff: last tt changeset this node received from the orig node
+ * @tt_buff_len: length of the last tt changeset this node received from the
+ *  orig node
+ * @tt_buff_lock: lock that protects tt_buff and tt_buff_len
+ * @tt_size: number of global TT entries announced by the orig node
+ * @tt_initialised: bool keeping track of whether or not this node have received
+ *  any translation table information from the orig node yet
  * @last_real_seqno: last and best known sequence number
  * @last_ttl: ttl of last received packet
+ * @bcast_bits: bitfield containing the info which payload broadcast originated
+ *  from this orig node this host already has seen (relative to
+ *  last_bcast_seqno)
  * @last_bcast_seqno: last broadcast sequence number received by this host
- * @candidates: how many candidates are available
- * @selected: next bonding candidate
+ * @neigh_list: list of potential next hop neighbor towards this orig node
+ * @frag_list: fragmentation buffer list for fragment re-assembly
+ * @last_frag_packet: time when last fragmented packet from this node was
+ *  received
+ * @neigh_list_lock: lock protecting neigh_list, router and bonding_list
+ * @hash_entry: hlist node for batadv_priv::orig_hash
+ * @bat_priv: pointer to soft_iface this orig node belongs to
+ * @ogm_cnt_lock: lock protecting bcast_own, bcast_own_sum,
+ *  neigh_node->real_bits & neigh_node->real_packet_count
+ * @bcast_seqno_lock: lock protecting bcast_bits & last_bcast_seqno
+ * @bond_candidates: how many candidates are available
+ * @bond_list: list of bonding candidates
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
  */
 struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
@@ -93,11 +141,11 @@ struct batadv_orig_node {
 	unsigned long batman_seqno_reset;
 	uint8_t gw_flags;
 	uint8_t flags;
-	atomic_t last_ttvn; /* last seen translation table version number */
+	atomic_t last_ttvn;
 	uint16_t tt_crc;
 	unsigned char *tt_buff;
 	int16_t tt_buff_len;
-	spinlock_t tt_buff_lock; /* protects tt_buff */
+	spinlock_t tt_buff_lock; /* protects tt_buff & tt_buff_len */
 	atomic_t tt_size;
 	bool tt_initialised;
 	uint32_t last_real_seqno;
@@ -106,22 +154,31 @@ struct batadv_orig_node {
 	uint32_t last_bcast_seqno;
 	struct hlist_head neigh_list;
 	struct list_head frag_list;
-	spinlock_t neigh_list_lock; /* protects neigh_list and router */
-	atomic_t refcount;
-	struct rcu_head rcu;
-	struct hlist_node hash_entry;
-	struct batadv_priv *bat_priv;
 	unsigned long last_frag_packet;
+	/* neigh_list_lock protects: neigh_list, router & bonding_list */
+	spinlock_t neigh_list_lock;
+	struct hlist_node hash_entry;
+	struct batadv_priv *bat_priv;
 	/* ogm_cnt_lock protects: bcast_own, bcast_own_sum,
-	 * neigh_node->real_bits, neigh_node->real_packet_count
+	 * neigh_node->real_bits & neigh_node->real_packet_count
 	 */
 	spinlock_t ogm_cnt_lock;
-	/* bcast_seqno_lock protects bcast_bits, last_bcast_seqno */
+	/* bcast_seqno_lock protects: bcast_bits & last_bcast_seqno */
 	spinlock_t bcast_seqno_lock;
 	atomic_t bond_candidates;
 	struct list_head bond_list;
+	atomic_t refcount;
+	struct rcu_head rcu;
 };
 
+/**
+ * struct batadv_gw_node - structure for orig nodes announcing gw capabilities
+ * @list: list node for batadv_priv_gw::list
+ * @orig_node: pointer to corresponding orig node
+ * @deleted: this struct is scheduled for deletion
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
 struct batadv_gw_node {
 	struct hlist_node list;
 	struct batadv_orig_node *orig_node;
@@ -130,13 +187,28 @@ struct batadv_gw_node {
 	struct rcu_head rcu;
 };
 
-/*	batadv_neigh_node
- *	@last_seen: when last packet via this neighbor was received
+/**
+ * struct batadv_neigh_node - structure for single hop neighbors
+ * @list: list node for batadv_orig_node::neigh_list
+ * @addr: mac address of neigh node
+ * @tq_recv: ring buffer of received TQ values from this neigh node
+ * @tq_index: ring buffer index
+ * @tq_avg: averaged tq of all tq values in the ring buffer (tq_recv)
+ * @last_ttl: last received ttl from this neigh node
+ * @bonding_list: list node for batadv_orig_node::bond_list
+ * @last_seen: when last packet via this neighbor was received
+ * @real_bits: bitfield containing the number of OGMs received from this neigh
+ *  node (relative to orig_node->last_real_seqno)
+ * @real_packet_count: counted result of real_bits
+ * @orig_node: pointer to corresponding orig_node
+ * @if_incoming: pointer to incoming hard interface
+ * @lq_update_lock: lock protecting tq_recv & tq_index
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
  */
 struct batadv_neigh_node {
 	struct hlist_node list;
 	uint8_t addr[ETH_ALEN];
-	uint8_t real_packet_count;
 	uint8_t tq_recv[BATADV_TQ_GLOBAL_WINDOW_SIZE];
 	uint8_t tq_index;
 	uint8_t tq_avg;
@@ -144,13 +216,20 @@ struct batadv_neigh_node {
 	struct list_head bonding_list;
 	unsigned long last_seen;
 	DECLARE_BITMAP(real_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
-	atomic_t refcount;
-	struct rcu_head rcu;
+	uint8_t real_packet_count;
 	struct batadv_orig_node *orig_node;
 	struct batadv_hard_iface *if_incoming;
-	spinlock_t lq_update_lock;	/* protects: tq_recv, tq_index */
+	spinlock_t lq_update_lock; /* protects tq_recv & tq_index */
+	atomic_t refcount;
+	struct rcu_head rcu;
 };
 
+/**
+ * struct batadv_bcast_duplist_entry - structure for LAN broadcast suppression
+ * @orig[ETH_ALEN]: mac address of orig node orginating the broadcast
+ * @crc: crc32 checksum of broadcast payload
+ * @entrytime: time when the broadcast packet was received
+ */
 #ifdef CONFIG_BATMAN_ADV_BLA
 struct batadv_bcast_duplist_entry {
 	uint8_t orig[ETH_ALEN];
@@ -159,6 +238,33 @@ struct batadv_bcast_duplist_entry {
 };
 #endif
 
+/**
+ * enum batadv_counters - indices for traffic counters
+ * @BATADV_CNT_TX: transmitted payload traffic packet counter
+ * @BATADV_CNT_TX_BYTES: transmitted payload traffic bytes counter
+ * @BATADV_CNT_TX_DROPPED: dropped transmission payload traffic packet counter
+ * @BATADV_CNT_RX: received payload traffic packet counter
+ * @BATADV_CNT_RX_BYTES: received payload traffic bytes counter
+ * @BATADV_CNT_FORWARD: forwarded payload traffic packet counter
+ * @BATADV_CNT_FORWARD_BYTES: forwarded payload traffic bytes counter
+ * @BATADV_CNT_MGMT_TX: transmitted routing protocol traffic packet counter
+ * @BATADV_CNT_MGMT_TX_BYTES: transmitted routing protocol traffic bytes counter
+ * @BATADV_CNT_MGMT_RX: received routing protocol traffic packet counter
+ * @BATADV_CNT_MGMT_RX_BYTES: received routing protocol traffic bytes counter
+ * @BATADV_CNT_TT_REQUEST_TX: transmitted tt req traffic packet counter
+ * @BATADV_CNT_TT_REQUEST_RX: received tt req traffic packet counter
+ * @BATADV_CNT_TT_RESPONSE_TX: transmitted tt resp traffic packet counter
+ * @BATADV_CNT_TT_RESPONSE_RX: received tt resp traffic packet counter
+ * @BATADV_CNT_TT_ROAM_ADV_TX: transmitted tt roam traffic packet counter
+ * @BATADV_CNT_TT_ROAM_ADV_RX: received tt roam traffic packet counter
+ * @BATADV_CNT_DAT_GET_TX: transmitted dht GET traffic packet counter
+ * @BATADV_CNT_DAT_GET_RX: received dht GET traffic packet counter
+ * @BATADV_CNT_DAT_PUT_TX: transmitted dht PUT traffic packet counter
+ * @BATADV_CNT_DAT_PUT_RX: received dht PUT traffic packet counter
+ * @BATADV_CNT_DAT_CACHED_REPLY_TX: transmitted dat cache reply traffic packet
+ *  counter
+ * @BATADV_CNT_NUM: number of traffic counters
+ */
 enum batadv_counters {
 	BATADV_CNT_TX,
 	BATADV_CNT_TX_BYTES,
@@ -190,14 +296,23 @@ enum batadv_counters {
 /**
  * struct batadv_priv_tt - per mesh interface translation table data
  * @vn: translation table version number
+ * @ogm_append_cnt: counter of number of OGMs containing the local tt diff
  * @local_changes: changes registered in an originator interval
- * @poss_change: Detect an ongoing roaming phase. If true, then this node
- *  received a roaming_adv and has to inspect every packet directed to it to
- *  check whether it still is the true destination or not. This flag will be
- *  reset to false as soon as the this node's ttvn is increased
  * @changes_list: tracks tt local changes within an originator interval
- * @req_list: list of pending tt_requests
+ * @local_hash: local translation table hash table
+ * @global_hash: global translation table hash table
+ * @req_list: list of pending & unanswered tt_requests
+ * @roam_list: list of the last roaming events of each client limiting the
+ *  number of roaming events to avoid route flapping
+ * @changes_list_lock: lock protecting changes_list
+ * @req_list_lock: lock protecting req_list
+ * @roam_list_lock: lock protecting roam_list
+ * @local_entry_num: number of entries in the local hash table
  * @local_crc: Checksum of the local table, recomputed before sending a new OGM
+ * @last_changeset: last tt changeset this host has generated
+ * @last_changeset_len: length of last tt changeset this host has generated
+ * @last_changeset_lock: lock protecting last_changeset & last_changeset_len
+ * @work: work queue callback item for translation table purging
  */
 struct batadv_priv_tt {
 	atomic_t vn;
@@ -215,24 +330,45 @@ struct batadv_priv_tt {
 	uint16_t local_crc;
 	unsigned char *last_changeset;
 	int16_t last_changeset_len;
-	spinlock_t last_changeset_lock; /* protects last_changeset */
+	/* protects last_changeset & last_changeset_len */
+	spinlock_t last_changeset_lock;
 	struct delayed_work work;
 };
 
+/**
+ * struct batadv_priv_bla - per mesh interface bridge loope avoidance data
+ * @num_requests; number of bla requests in flight
+ * @claim_hash: hash table containing mesh nodes this host has claimed
+ * @backbone_hash: hash table containing all detected backbone gateways
+ * @bcast_duplist: recently received broadcast packets array (for broadcast
+ *  duplicate suppression)
+ * @bcast_duplist_curr: index of last broadcast packet added to bcast_duplist
+ * @bcast_duplist_lock: lock protecting bcast_duplist & bcast_duplist_curr
+ * @claim_dest: local claim data (e.g. claim group)
+ * @work: work queue callback item for cleanups & bla announcements
+ */
 #ifdef CONFIG_BATMAN_ADV_BLA
 struct batadv_priv_bla {
-	atomic_t num_requests; /* number of bla requests in flight */
+	atomic_t num_requests;
 	struct batadv_hashtable *claim_hash;
 	struct batadv_hashtable *backbone_hash;
 	struct batadv_bcast_duplist_entry bcast_duplist[BATADV_DUPLIST_SIZE];
 	int bcast_duplist_curr;
-	/* protects bcast_duplist and bcast_duplist_curr */
+	/* protects bcast_duplist & bcast_duplist_curr */
 	spinlock_t bcast_duplist_lock;
 	struct batadv_bla_claim_dst claim_dest;
 	struct delayed_work work;
 };
 #endif
 
+/**
+ * struct batadv_debug_log - debug logging data
+ * @log_buff: buffer holding the logs (ring bufer)
+ * @log_start: index of next character to read
+ * @log_end: index of next character to write
+ * @lock: lock protecting log_buff, log_start & log_end
+ * @queue_wait: log reader's wait queue
+ */
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 struct batadv_priv_debug_log {
 	char log_buff[BATADV_LOG_BUF_LEN];
@@ -243,18 +379,34 @@ struct batadv_priv_debug_log {
 };
 #endif
 
+/**
+ * struct batadv_priv_gw - per mesh interface gateway data
+ * @list: list of available gateway nodes
+ * @list_lock: lock protecting gw_list & curr_gw
+ * @curr_gw: pointer to currently selected gateway node
+ * @reselect: bool indicating a gateway re-selection is in progress
+ */
 struct batadv_priv_gw {
 	struct hlist_head list;
-	spinlock_t list_lock; /* protects gw_list and curr_gw */
+	spinlock_t list_lock; /* protects gw_list & curr_gw */
 	struct batadv_gw_node __rcu *curr_gw;  /* rcu protected pointer */
 	atomic_t reselect;
 };
 
+/**
+ * struct batadv_priv_vis - per mesh interface vis data
+ * @send_list: list of batadv_vis_info packets to sent
+ * @hash: hash table containing vis data from other nodes in the network
+ * @hash_lock: lock protecting the hash table
+ * @list_lock: lock protecting my_info::recv_list
+ * @work: work queue callback item for vis packet sending
+ * @my_info: holds this node's vis data sent on a regular basis
+ */
 struct batadv_priv_vis {
 	struct list_head send_list;
 	struct batadv_hashtable *hash;
 	spinlock_t hash_lock; /* protects hash */
-	spinlock_t list_lock; /* protects info::recv_list */
+	spinlock_t list_lock; /* protects my_info::recv_list */
 	struct delayed_work work;
 	struct batadv_vis_info *my_info;
 };
@@ -273,28 +425,70 @@ struct batadv_priv_dat {
 };
 #endif
 
+/**
+ * struct batadv_priv - per mesh interface data
+ * @mesh_state: current status of the mesh (inactive/active/deactivating)
+ * @stats: structure holding the data for the ndo_get_stats() call
+ * @bat_counters: mesh internal traffic statistic counters (see batadv_counters)
+ * @aggregated_ogms: bool indicating whether OGM aggregation is enabled
+ * @bonding: bool indicating whether traffic bonding is enabled
+ * @fragmentation: bool indicating whether traffic fragmentation is enabled
+ * @ap_isolation: bool indicating whether ap isolation is enabled
+ * @bridge_loop_avoidance: bool indicating whether bridge loop avoidance is
+ *  enabled
+ * @distributed_arp_table: bool indicating whether distributed ARP table is
+ *  enabled
+ * @vis_mode: vis operation: client or server (see batadv_vis_packettype)
+ * @gw_mode: gateway operation: off, client or server (see batadv_gw_modes)
+ * @gw_sel_class: gateway selection class (applies if gw_mode client)
+ * @gw_bandwidth: gateway announced bandwidth (applies if gw_mode server)
+ * @orig_interval: OGM broadcast interval in milliseconds
+ * @hop_penalty: penalty which will be applied to an OGM's tq-field on every hop
+ * @log_level: configured log level (see batadv_dbg_level)
+ * @bcast_seqno: last sent broadcast packet sequence number
+ * @bcast_queue_left: number of remaining buffered broadcast packet slots
+ * @batman_queue_left: number of remaining OGM packet slots
+ * @num_ifaces: number of interfaces assigned to this mesh interface
+ * @mesh_obj: kobject for sysfs mesh subdirectory
+ * @debug_dir: dentry for debugfs batman-adv subdirectory
+ * @forw_bat_list: list of aggregated OGMs that will be forwarded
+ * @forw_bcast_list: list of broadcast packets that will be rebroadcasted
+ * @orig_hash: hash table containing mesh participants (orig nodes)
+ * @forw_bat_list_lock: lock protecting forw_bat_list
+ * @forw_bcast_list_lock: lock protecting forw_bcast_list
+ * @orig_work: work queue callback item for orig node purging
+ * @primary_if: one of the hard interfaces assigned to this mesh interface
+ *  becomes the primary interface
+ * @bat_algo_ops: routing algorithm used by this mesh interface
+ * @bla: bridge loope avoidance data
+ * @debug_log: holding debug logging relevant data
+ * @gw: gateway data
+ * @tt: translation table data
+ * @vis: vis data
+ * @dat: distributed arp table data
+ */
 struct batadv_priv {
 	atomic_t mesh_state;
 	struct net_device_stats stats;
 	uint64_t __percpu *bat_counters; /* Per cpu counters */
-	atomic_t aggregated_ogms;	/* boolean */
-	atomic_t bonding;		/* boolean */
-	atomic_t fragmentation;		/* boolean */
-	atomic_t ap_isolation;		/* boolean */
+	atomic_t aggregated_ogms;
+	atomic_t bonding;
+	atomic_t fragmentation;
+	atomic_t ap_isolation;
 #ifdef CONFIG_BATMAN_ADV_BLA
-	atomic_t bridge_loop_avoidance;	/* boolean */
+	atomic_t bridge_loop_avoidance;
 #endif
 #ifdef CONFIG_BATMAN_ADV_DAT
-	atomic_t distributed_arp_table;	/* boolean */
+	atomic_t distributed_arp_table;
 #endif
-	atomic_t vis_mode;		/* VIS_TYPE_* */
-	atomic_t gw_mode;		/* GW_MODE_* */
-	atomic_t gw_sel_class;		/* uint */
-	atomic_t gw_bandwidth;		/* gw bandwidth */
-	atomic_t orig_interval;		/* uint */
-	atomic_t hop_penalty;		/* uint */
+	atomic_t vis_mode;
+	atomic_t gw_mode;
+	atomic_t gw_sel_class;
+	atomic_t gw_bandwidth;
+	atomic_t orig_interval;
+	atomic_t hop_penalty;
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-	atomic_t log_level;		/* uint */
+	atomic_t log_level;
 #endif
 	atomic_t bcast_seqno;
 	atomic_t bcast_queue_left;
@@ -324,46 +518,97 @@ struct batadv_priv {
 #endif
 };
 
+/**
+ * struct batadv_socket_client - layer2 icmp socket client data
+ * @queue_list: packet queue for packets destined for this socket client
+ * @queue_len: number of packets in the packet queue (queue_list)
+ * @index: socket client's index in the batadv_socket_client_hash
+ * @lock: lock protecting queue_list, queue_len & index
+ * @queue_wait: socket client's wait queue
+ * @bat_priv: pointer to soft_iface this client belongs to
+ */
 struct batadv_socket_client {
 	struct list_head queue_list;
 	unsigned int queue_len;
 	unsigned char index;
-	spinlock_t lock; /* protects queue_list, queue_len, index */
+	spinlock_t lock; /* protects queue_list, queue_len & index */
 	wait_queue_head_t queue_wait;
 	struct batadv_priv *bat_priv;
 };
 
+/**
+ * struct batadv_socket_packet - layer2 icmp packet for socket client
+ * @list: list node for batadv_socket_client::queue_list
+ * @icmp_len: size of the layer2 icmp packet
+ * @icmp_packet: layer2 icmp packet
+ */
 struct batadv_socket_packet {
 	struct list_head list;
 	size_t icmp_len;
 	struct batadv_icmp_packet_rr icmp_packet;
 };
 
+/**
+ * struct batadv_bla_backbone_gw - batman-adv gateway bridged into the LAN
+ * @orig: originator address of backbone node (mac address of primary iface)
+ * @vid: vlan id this gateway was detected on
+ * @hash_entry: hlist node for batadv_priv_bla::backbone_hash
+ * @bat_priv: pointer to soft_iface this backbone gateway belongs to
+ * @lasttime: last time we heard of this backbone gw
+ * @wait_periods: grace time for bridge forward delays and bla group forming at
+ *  bootup phase - no bcast traffic is formwared until it has elapsed
+ * @request_sent: if this bool is set to true we are out of sync with this
+ *  backbone gateway - no bcast traffic is formwared until the situation was
+ *  resolved
+ * @crc: crc16 checksum over all claims
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
 #ifdef CONFIG_BATMAN_ADV_BLA
 struct batadv_bla_backbone_gw {
 	uint8_t orig[ETH_ALEN];
-	short vid;		/* used VLAN ID */
+	short vid;
 	struct hlist_node hash_entry;
 	struct batadv_priv *bat_priv;
-	unsigned long lasttime;	/* last time we heard of this backbone gw */
+	unsigned long lasttime;
 	atomic_t wait_periods;
 	atomic_t request_sent;
+	uint16_t crc;
 	atomic_t refcount;
 	struct rcu_head rcu;
-	uint16_t crc;		/* crc checksum over all claims */
 };
 
+/**
+ * struct batadv_bla_claim - claimed non-mesh client structure
+ * @addr: mac address of claimed non-mesh client
+ * @vid: vlan id this client was detected on
+ * @batadv_bla_backbone_gw: pointer to backbone gw claiming this client
+ * @lasttime: last time we heard of claim (locals only)
+ * @hash_entry: hlist node for batadv_priv_bla::claim_hash
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
 struct batadv_bla_claim {
 	uint8_t addr[ETH_ALEN];
 	short vid;
 	struct batadv_bla_backbone_gw *backbone_gw;
-	unsigned long lasttime;	/* last time we heard of claim (locals only) */
+	unsigned long lasttime;
+	struct hlist_node hash_entry;
 	struct rcu_head rcu;
 	atomic_t refcount;
-	struct hlist_node hash_entry;
 };
 #endif
 
+/**
+ * struct batadv_tt_common_entry - tt local & tt global common data
+ * @addr: mac address of non-mesh client
+ * @hash_entry: hlist node for batadv_priv_tt::local_hash or for
+ *  batadv_priv_tt::global_hash
+ * @flags: various state handling flags (see batadv_tt_client_flags)
+ * @added_at: timestamp used for purging stale tt common entries
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
 struct batadv_tt_common_entry {
 	uint8_t addr[ETH_ALEN];
 	struct hlist_node hash_entry;
@@ -373,37 +618,76 @@ struct batadv_tt_common_entry {
 	struct rcu_head rcu;
 };
 
+/**
+ * struct batadv_tt_local_entry - translation table local entry data
+ * @common: general translation table data
+ * @last_seen: timestamp used for purging stale tt local entries
+ */
 struct batadv_tt_local_entry {
 	struct batadv_tt_common_entry common;
 	unsigned long last_seen;
 };
 
+/**
+ * struct batadv_tt_global_entry - translation table global entry data
+ * @common: general translation table data
+ * @orig_list: list of orig nodes announcing this non-mesh client
+ * @list_lock: lock protecting orig_list
+ * @roam_at: time at which TT_GLOBAL_ROAM was set
+ */
 struct batadv_tt_global_entry {
 	struct batadv_tt_common_entry common;
 	struct hlist_head orig_list;
-	spinlock_t list_lock;	/* protects the list */
-	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
+	spinlock_t list_lock;	/* protects orig_list */
+	unsigned long roam_at;
 };
 
+/**
+ * struct batadv_tt_orig_list_entry - orig node announcing a non-mesh client
+ * @orig_node: pointer to orig node announcing this non-mesh client
+ * @ttvn: translation table version number which added the non-mesh client
+ * @list: list node for batadv_tt_global_entry::orig_list
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
 struct batadv_tt_orig_list_entry {
 	struct batadv_orig_node *orig_node;
 	uint8_t ttvn;
+	struct hlist_node list;
 	atomic_t refcount;
 	struct rcu_head rcu;
-	struct hlist_node list;
 };
 
+/**
+ * struct batadv_tt_change_node - structure for tt changes occured
+ * @list: list node for batadv_priv_tt::changes_list
+ * @change: holds the actual translation table diff data
+ */
 struct batadv_tt_change_node {
 	struct list_head list;
 	struct batadv_tt_change change;
 };
 
+/**
+ * struct batadv_tt_req_node - data to keep track of the tt requests in flight
+ * @addr: mac address address of the originator this request was sent to
+ * @issued_at: timestamp used for purging stale tt requests
+ * @list: list node for batadv_priv_tt::req_list
+ */
 struct batadv_tt_req_node {
 	uint8_t addr[ETH_ALEN];
 	unsigned long issued_at;
 	struct list_head list;
 };
 
+/**
+ * struct batadv_tt_roam_node - roaming client data
+ * @addr: mac address of the client in the roaming phase
+ * @counter: number of allowed roaming events per client within a single
+ *  OGM interval (changes are committed with each OGM)
+ * @first_time: timestamp used for purging stale roaming node entries
+ * @list: list node for batadv_priv_tt::roam_list
+ */
 struct batadv_tt_roam_node {
 	uint8_t addr[ETH_ALEN];
 	atomic_t counter;
@@ -411,8 +695,19 @@ struct batadv_tt_roam_node {
 	struct list_head list;
 };
 
-/*	forw_packet - structure for forw_list maintaining packets to be
- *	              send/forwarded
+/**
+ * struct batadv_forw_packet - structure for bcast packets to be sent/forwarded
+ * @list: list node for batadv_socket_client::queue_list
+ * @send_time: execution time for delayed_work (packet sending)
+ * @own: bool for locally generated packets (local OGMs are re-scheduled after
+ *  sending)
+ * @skb: bcast packet's skb buffer
+ * @packet_len: size of aggregated OGM packet inside the skb buffer
+ * @direct_link_flags: direct link flags for aggregated OGM packets
+ * @num_packets: counter for bcast packet retransmission
+ * @delayed_work: work queue callback item for packet sending
+ * @if_incoming: pointer incoming hard-iface or primary iface if locally
+ *  generated packet
  */
 struct batadv_forw_packet {
 	struct hlist_node list;
@@ -426,39 +721,69 @@ struct batadv_forw_packet {
 	struct batadv_hard_iface *if_incoming;
 };
 
+/**
+ * struct batadv_frag_packet_list_entry - storage for fragment packet
+ * @list: list node for orig_node::frag_list
+ * @seqno: sequence number of the fragment
+ * @skb: fragment's skb buffer
+ */
 struct batadv_frag_packet_list_entry {
 	struct list_head list;
 	uint16_t seqno;
 	struct sk_buff *skb;
 };
 
+/**
+ * struct batadv_vis_info - local data for vis information
+ * @first_seen: timestamp used for purging stale vis info entries
+ * @recv_list: List of server-neighbors we have received this packet from. This
+ *  packet should not be re-forward to them again. List elements are struct
+ *  batadv_vis_recvlist_node
+ * @send_list: list of packets to be forwarded
+ * @refcount: number of contexts the object is used
+ * @hash_entry: hlist node for batadv_priv_vis::hash
+ * @bat_priv: pointer to soft_iface this orig node belongs to
+ * @skb_packet: contains the vis packet
+ */
 struct batadv_vis_info {
 	unsigned long first_seen;
-	/* list of server-neighbors we received a vis-packet
-	 * from.  we should not reply to them.
-	 */
 	struct list_head recv_list;
 	struct list_head send_list;
 	struct kref refcount;
 	struct hlist_node hash_entry;
 	struct batadv_priv *bat_priv;
-	/* this packet might be part of the vis send queue. */
 	struct sk_buff *skb_packet;
-	/* vis_info may follow here */
 } __packed;
 
+/**
+ * struct batadv_vis_info_entry - contains link information for vis
+ * @src: source MAC of the link, all zero for local TT entry
+ * @dst: destination MAC of the link, client mac address for local TT entry
+ * @quality: transmission quality of the link, or 0 for local TT entry
+ */
 struct batadv_vis_info_entry {
 	uint8_t  src[ETH_ALEN];
 	uint8_t  dest[ETH_ALEN];
-	uint8_t  quality;	/* quality = 0 client */
+	uint8_t  quality;
 } __packed;
 
+/**
+ * struct batadv_vis_recvlist_node - list entry for batadv_vis_info::recv_list
+ * @list: list node for batadv_vis_info::recv_list
+ * @mac: MAC address of the originator from where the vis_info was received
+ */
 struct batadv_vis_recvlist_node {
 	struct list_head list;
 	uint8_t mac[ETH_ALEN];
 };
 
-/* While scanning for vis-entries of a particular vis-originator
+/**
+ * struct batadv_vis_if_list_entry - auxiliary data for vis data generation
+ * @addr: MAC address of the interface
+ * @primary: true if this interface is the primary interface
+ * @list: list node the interface list
+ *
+ * While scanning for vis-entries of a particular vis-originator
  * this list collects its interfaces to create a subgraph/cluster
  * out of them later
  */
@@ -468,22 +793,26 @@ struct batadv_vis_if_list_entry {
 	struct hlist_node list;
 };
 
+/**
+ * struct batadv_algo_ops - mesh algorithm callbacks
+ * @list: list node for the batadv_algo_list
+ * @name: name of the algorithm
+ * @bat_iface_enable: init routing info when hard-interface is enabled
+ * @bat_iface_disable: de-init routing info when hard-interface is disabled
+ * @bat_iface_update_mac: (re-)init mac addresses of the protocol information
+ *  belonging to this hard-interface
+ * @bat_primary_iface_set: called when primary interface is selected / changed
+ * @bat_ogm_schedule: prepare a new outgoing OGM for the send queue
+ * @bat_ogm_emit: send scheduled OGM
+ */
 struct batadv_algo_ops {
 	struct hlist_node list;
 	char *name;
-	/* init routing info when hard-interface is enabled */
 	int (*bat_iface_enable)(struct batadv_hard_iface *hard_iface);
-	/* de-init routing info when hard-interface is disabled */
 	void (*bat_iface_disable)(struct batadv_hard_iface *hard_iface);
-	/* (re-)init mac addresses of the protocol information
-	 * belonging to this hard-interface
-	 */
 	void (*bat_iface_update_mac)(struct batadv_hard_iface *hard_iface);
-	/* called when primary interface is selected / changed */
 	void (*bat_primary_iface_set)(struct batadv_hard_iface *hard_iface);
-	/* prepare a new outgoing OGM for the send queue */
 	void (*bat_ogm_schedule)(struct batadv_hard_iface *hard_iface);
-	/* send scheduled OGM */
 	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
 };
 
-- 
1.8.0.2
