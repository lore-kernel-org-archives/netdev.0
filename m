From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH net-next] be2net: Learn and program mac to avoid packet replication in nPAR mode.
Date: Thu, 4 Sep 2014 20:00:59 +0530
Message-ID: <206ffa9c-915e-4a1e-affe-68616cbef2f8@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:53659 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631AbaIDOcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:32:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a multi-channel setup, when an interface (channel/partition) is used
by a bridge or ovs, it is placed in promiscuous mode and the MAC addresses
of the VMs attached to the bridge are not configured on the base interface.
As a result of that, when a packet arrives to the port with
virtual machine's mac address, the card cannot determine which ring to
send the packet to, so replicates the packet on all the PFs of that port,
hence resulting in wastage of PCI bandwidth and CPU cycles. Packet replication
is also considered security risk as it can cause packets to reach an undesired VM.

This patch will help solve the problem by learning the mac address and
programming it in the adapter. This patch also unlearns the MAC, if the MAC is
moved out of the machine or if the MAC is inactive for more than 5 minutes.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |   45 ++++
 drivers/net/ethernet/emulex/benet/be_cmds.c |   27 +++
 drivers/net/ethernet/emulex/benet/be_cmds.h |   31 +++-
 drivers/net/ethernet/emulex/benet/be_main.c |  336 ++++++++++++++++++++++++++-
 4 files changed, 437 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a9f239a..9862ada 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -388,6 +388,9 @@ enum vf_state {
 #define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
 #define BE_FLAGS_VXLAN_OFFLOADS			(1 << 12)
 #define BE_FLAGS_SETUP_DONE			(1 << 13)
+#define BE_FLAGS_MAC_LEARNING_INITIALIZED	(1 << 14)
+#define BE_FLAGS_MAC_LEARNING_ENABLED		(1 << 15)
+#define BE_FLAGS_MAC_FILTERS_EXHAUSTED		(1 << 16)
 
 #define BE_UC_PMAC_COUNT			30
 #define BE_VF_UC_PMAC_COUNT			2
@@ -425,6 +428,45 @@ struct be_resources {
 	u32 vf_if_cap_flags;	/* VF if capability flags */
 };
 
+#define BE_MAC_AGE		300000 /* in msecs */
+#define BE_MAC_MISS		0
+#define BE_MAC_HIT		1
+#define BE_MAC_HASH_TABLE_LEN	64
+#define be_mac_matches(node, ethhdr)					\
+		(node &&						\
+		 ether_addr_equal_64bits(node->mac,			\
+					 ethhdr->h_source))		\
+
+#define be_mac_vlan_matches(node, ethhdr, vlan_tag)			\
+		(node &&						\
+		 ether_addr_equal_64bits(node->mac,			\
+					 ethhdr->h_source) &&		\
+		 (node->vlan_tag == vlan_tag))
+
+#define be_is_mac_learning_enabled(adapter)				\
+	((adapter->flags & BE_FLAGS_MAC_LEARNING_INITIALIZED) &&	\
+	 (adapter->flags & BE_FLAGS_MAC_LEARNING_ENABLED) &&		\
+	 !(adapter->flags & BE_FLAGS_MAC_FILTERS_EXHAUSTED))
+
+struct be_config_work {
+	struct work_struct work;
+	union {
+		struct be_mac_node *mac;
+	} data;
+};
+
+struct be_mac_node {
+	struct rcu_head rcu;
+	struct hlist_node list;
+	struct be_adapter *adapter;
+	u32 pmac_id;
+	u8 mac[ETH_ALEN];
+	u16 vlan_tag;
+	unsigned long jiffies;
+	u8 hashidx;
+	bool del;
+};
+
 struct rss_info {
 	u64 rss_flags;
 	u8 rsstable[RSS_INDIR_TABLE_LEN];
@@ -532,6 +574,9 @@ struct be_adapter {
 	int be_get_temp_freq;
 	u8 pf_number;
 	struct rss_info rss_info;
+	struct hlist_head *mac_table;
+	spinlock_t mac_hash_lock; /* For serializing mac addr hash entries */
+	struct workqueue_struct *config_workq;
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 5be100d..ec09bdb 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -292,6 +292,30 @@ static void be_async_grp5_pvid_state_process(struct be_adapter *adapter,
 	}
 }
 
+static void be_async_grp5_fw_control_process(struct be_adapter *adapter,
+					     struct be_mcc_compl *compl)
+{
+	struct be_async_fw_ctrl *evt = (struct be_async_fw_ctrl *)compl;
+	u8 learn_enable, learn_disable;
+
+	be_dws_le_to_cpu(&evt->context, sizeof(evt->context));
+
+	learn_enable = AMAP_GET_BITS(struct amap_be_async_fw_ctrl,
+				     learn_enable, &evt->context);
+	learn_disable = AMAP_GET_BITS(struct amap_be_async_fw_ctrl,
+				      learn_disable, &evt->context);
+
+	/* If both learn_enable and learn_disable are not set, then there's
+	 * no change in learning state
+	 */
+	if (learn_enable || learn_disable) {
+		if (learn_enable)
+			adapter->flags |= BE_FLAGS_MAC_LEARNING_ENABLED;
+		else
+			adapter->flags &= ~BE_FLAGS_MAC_LEARNING_ENABLED;
+	}
+}
+
 static void be_async_grp5_evt_process(struct be_adapter *adapter,
 				      struct be_mcc_compl *compl)
 {
@@ -308,6 +332,9 @@ static void be_async_grp5_evt_process(struct be_adapter *adapter,
 	case ASYNC_EVENT_PVID_STATE:
 		be_async_grp5_pvid_state_process(adapter, compl);
 		break;
+	case ASYNC_EVENT_FW_CONTROL:
+		be_async_grp5_fw_control_process(adapter, compl);
+		break;
 	default:
 		dev_warn(&adapter->pdev->dev, "Unknown grp5 event 0x%x!\n",
 			 event_type);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 0e11868..6f98e55 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -99,6 +99,7 @@ struct be_mcc_compl {
 #define ASYNC_EVENT_QOS_SPEED		0x1
 #define ASYNC_EVENT_COS_PRIORITY	0x2
 #define ASYNC_EVENT_PVID_STATE		0x3
+#define ASYNC_EVENT_FW_CONTROL		0x5
 #define ASYNC_EVENT_CODE_QNQ		0x6
 #define ASYNC_DEBUG_EVENT_TYPE_QNQ	1
 
@@ -168,6 +169,34 @@ struct be_async_event_qnq {
 	u32 flags;
 } __packed;
 
+/* async event indicating bmc and mac learning */
+struct amap_be_async_fw_ctrl {
+	u8 learn_enable[1];		/* dword 0 */
+	u8 learn_disable[1];		/* dword 0 */
+	u8 mgmt_enable[1];		/* dword 0 */
+	u8 mgmt_disable[1];		/* dword 0 */
+	u8 rsvd0[12];			/* dword 0 */
+	u8 vlan_tag[16];		/* dword 0 */
+	u8 arp_filter[1];		/* dword 1 */
+	u8 dhcp_client_filt[1];		/* dword 1 */
+	u8 dhcp_server_filt[1];		/* dword 1 */
+	u8 net_bios_filt[1];		/* dword 1 */
+	u8 rsvd1[3];			/* dword 1 */
+	u8 bcast_filt[1];		/* dword 1 */
+	u8 ipv6_nbr_filt[1];		/* dword 1 */
+	u8 ipv6_ra_filt[1];		/* dword 1 */
+	u8 ipv6_ras_filt[1];		/* dword 1 */
+	u8 rsvd2[4];			/* dword 1 */
+	u8 mcast_filt[1];		/* dword 1 */
+	u8 rsvd3[16];			/* dword 1 */
+	u8 evt_tag[32];			/* dword 2 */
+	u8 dword3[32];			/* dword 3 */
+} __packed;
+
+struct be_async_fw_ctrl {
+	u8 context[sizeof(struct amap_be_async_fw_ctrl) / 8];
+};
+
 struct be_mcc_mailbox {
 	struct be_mcc_wrb wrb;
 	struct be_mcc_compl compl;
@@ -1907,7 +1936,7 @@ enum mc_type {
 	UMC = 0x02,
 	FLEX10 = 0x03,
 	vNIC1 = 0x04,
-	nPAR = 0x05,
+	NPAR = 0x05,
 	UFP = 0x06,
 	vNIC2 = 0x07
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5b26c4c..b695acc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -701,6 +701,21 @@ static inline void wrb_fill(struct be_eth_wrb *wrb, u64 addr, int len)
 	wrb->rsvd0 = 0;
 }
 
+static u16 be_get_vlan(struct be_adapter *adapter,
+		       struct sk_buff *skb)
+{
+	struct vlan_ethhdr *veh = vlan_eth_hdr(skb);
+	u16 vlan_id = 0;
+
+	/* inline vlan */
+	if (veh->h_vlan_proto == htons(ETH_P_8021Q))
+		vlan_id = ntohs(veh->h_vlan_TCI) & VLAN_VID_MASK;
+	else
+		vlan_id = vlan_tx_tag_get_id(skb);
+
+	return vlan_id;
+}
+
 static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
 				     struct sk_buff *skb)
 {
@@ -998,6 +1013,249 @@ err:
 	return NULL;
 }
 
+/* Mac hash function */
+static u8 be_mac_hash(u8 mac_addr[])
+{
+	return (mac_addr[5] & 7) |
+		((mac_addr[2] & 3) << 3) |
+		((mac_addr[1] & 1) << 5);
+}
+
+static void be_free_mac_node_rcu(struct rcu_head *head)
+{
+	struct be_mac_node *node = container_of(head, struct be_mac_node, rcu);
+
+	kfree(node);
+}
+
+static void be_del_mac_node_rcu(struct be_adapter *adapter,
+				struct be_mac_node *node)
+{
+	spin_lock_bh(&adapter->mac_hash_lock);
+	hlist_del_rcu(&node->list);
+	call_rcu_bh(&node->rcu, be_free_mac_node_rcu);
+	spin_unlock_bh(&adapter->mac_hash_lock);
+}
+
+/* Worker function to unlearn macs that are learnt */
+static void be_del_mac(struct work_struct *work)
+{
+	struct be_config_work *cfg_work = container_of(work,
+						       struct be_config_work,
+						       work);
+	struct be_mac_node *node = cfg_work->data.mac;
+	struct be_adapter *adapter = node->adapter;
+	struct hlist_head *head;
+	int status;
+
+	status = be_cmd_pmac_del(adapter,
+				 adapter->if_handle,
+				 node->pmac_id, 0);
+	if (!status) {
+		adapter->flags &= ~BE_FLAGS_MAC_FILTERS_EXHAUSTED;
+		kfree(node);
+	} else {
+		head = &adapter->mac_table[node->hashidx];
+		spin_lock_bh(&adapter->mac_hash_lock);
+		hlist_add_head_rcu(&node->list, head);
+		spin_unlock_bh(&adapter->mac_hash_lock);
+	}
+	kfree(work);
+}
+
+/* Worker function to program macs that are learnt */
+static void be_add_mac(struct work_struct *work)
+{
+	struct be_config_work *cfg_work = container_of(work,
+						       struct be_config_work,
+						       work);
+	struct be_mac_node *node = cfg_work->data.mac;
+	struct be_adapter *adapter = node->adapter;
+	int status;
+
+	status = be_cmd_pmac_add(adapter, (u8 *)node->mac,
+				 adapter->if_handle,
+				 &node->pmac_id, 0);
+
+	if (addl_status(status) == MCC_ADDL_STATUS_INSUFFICIENT_RESOURCES)
+		adapter->flags |= BE_FLAGS_MAC_FILTERS_EXHAUSTED;
+	else if (status)
+		be_del_mac_node_rcu(adapter, node);
+
+	kfree(work);
+}
+
+static void be_work_del_mac(struct rcu_head *rhead)
+{
+	struct be_mac_node *node = container_of(rhead, struct be_mac_node, rcu);
+	struct be_adapter *adapter = node->adapter;
+	struct be_config_work *work = NULL;
+	struct hlist_head *head;
+
+	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work) {
+		head = &adapter->mac_table[node->hashidx];
+		spin_lock_bh(&adapter->mac_hash_lock);
+		hlist_add_head_rcu(&node->list, head);
+		spin_unlock_bh(&adapter->mac_hash_lock);
+		return;
+	}
+
+	work->data.mac = node;
+
+	INIT_WORK(&work->work, be_del_mac);
+	queue_work(node->adapter->config_workq, &work->work);
+}
+
+/* Keep checking each mac's age for every second and unlearn mac if not
+ * active for more than 5 minutes.
+ */
+static void be_check_mac_aging(struct be_adapter *adapter)
+{
+	struct be_mac_node *node = NULL;
+	unsigned int age_msecs, i;
+	struct hlist_head *head;
+	unsigned long curr_time;
+
+	rcu_read_lock_bh();
+	for (i = 0; i < BE_MAC_HASH_TABLE_LEN; i++) {
+		head = &adapter->mac_table[i];
+		hlist_for_each_entry_rcu_bh(node, head, list) {
+			curr_time = jiffies;
+			if (time_before(curr_time, node->jiffies))
+				continue;
+			age_msecs = jiffies_to_msecs(curr_time - node->jiffies);
+			if (age_msecs >= BE_MAC_AGE) {
+				spin_lock_bh(&adapter->mac_hash_lock);
+				/* Unlearn also can delete this node */
+				if (!node->del) {
+					hlist_del_rcu(&node->list);
+					node->del = true;
+					call_rcu_bh(&node->rcu,
+						    be_work_del_mac);
+				}
+				spin_unlock_bh(&adapter->mac_hash_lock);
+			}
+		}
+	}
+	rcu_read_unlock_bh();
+}
+
+static void be_unlearn_mac(struct be_adapter *adapter,
+			   struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr = eth_hdr(skb);
+	struct be_mac_node *node = NULL;
+	struct hlist_head *head;
+	u16 vlan_tag = 0;
+	u8 hashidx = 0;
+
+	vlan_tag = be_get_vlan(adapter, skb);
+	hashidx = be_mac_hash(ethhdr->h_source);
+	head = &adapter->mac_table[hashidx];
+
+	rcu_read_lock_bh();
+	hlist_for_each_entry_rcu_bh(node, head, list) {
+		if (be_mac_vlan_matches(node, ethhdr, vlan_tag)) {
+			spin_lock_bh(&adapter->mac_hash_lock);
+			/* Aging also can delete this node */
+			if (!node->del) {
+				hlist_del_rcu(&node->list);
+				node->del = true;
+				call_rcu_bh(&node->rcu, be_work_del_mac);
+			}
+			spin_unlock_bh(&adapter->mac_hash_lock);
+			break;
+		}
+	}
+	rcu_read_unlock_bh();
+}
+
+static int be_work_add_mac(struct be_adapter *adapter,
+			   struct be_mac_node *node)
+{
+	struct be_config_work *mac_work = NULL;
+
+	mac_work = kzalloc(sizeof(*mac_work), GFP_ATOMIC);
+	if (!mac_work)
+		return -ENOMEM;
+	mac_work->data.mac = node;
+
+	INIT_WORK(&mac_work->work, be_add_mac);
+	queue_work(adapter->config_workq, &mac_work->work);
+	return 0;
+}
+
+static void be_check_add_mac_node(struct be_adapter *adapter,
+				  struct sk_buff *skb,
+				  u8 hashidx)
+{
+	struct hlist_head *head = &adapter->mac_table[hashidx];
+	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
+	struct be_mac_node *node = NULL;
+	struct be_mac_node *tmp = NULL;
+	u16 vlan_tag = 0;
+	int status;
+
+	vlan_tag = be_get_vlan(adapter, skb);
+
+	rcu_read_lock_bh();
+	hlist_for_each_entry_rcu_bh(node, head, list) {
+		if (be_mac_matches(node, ethhdr)) {
+			node->jiffies = jiffies;
+			rcu_read_unlock_bh();
+			return; /* Mac found in the table */
+		}
+	}
+	rcu_read_unlock_bh();
+
+	/* Mac not found. Allocate a new node and add it to the table */
+	node = kzalloc(sizeof(*node), GFP_ATOMIC);
+	if (!node)
+		return;
+	ether_addr_copy(node->mac, ethhdr->h_source);
+	node->jiffies = jiffies;
+	node->vlan_tag = vlan_tag;
+	node->adapter = adapter;
+	node->hashidx = hashidx;
+
+	spin_lock_bh(&adapter->mac_hash_lock);
+	hlist_for_each_entry_rcu_bh(tmp, head, list) {
+		if (be_mac_matches(tmp, ethhdr)) {
+			kfree(node);
+			spin_unlock_bh(&adapter->mac_hash_lock);
+			return; /* Already added */
+		}
+	}
+	hlist_add_head_rcu(&node->list, head);
+	spin_unlock_bh(&adapter->mac_hash_lock);
+
+	status = be_work_add_mac(adapter, node);
+	if (status)
+		be_del_mac_node_rcu(adapter, node);
+}
+
+/* When hypervisor OSes configure the port in promiscuous (MAC and VLAN)
+ * mode and do not program vNIC's VLAN/MAC in the adapter, when a packet arrives
+ * in the port with a vNIC's VLAN/MAC, the card cannot determine which ring to
+ * send the packet to, so sends the packet to all the PFs of that port.
+ * Learning mac and programming it in the adapter will solve the problem.
+ */
+static void be_learn_mac(struct be_adapter *adapter,
+			 struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
+	u8 hashidx;
+
+	if (ether_addr_equal_64bits(ethhdr->h_source,
+				    adapter->netdev->dev_addr))
+		return;
+
+	hashidx = be_mac_hash(ethhdr->h_source);
+
+	be_check_add_mac_node(adapter, skb, hashidx);
+}
+
 static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 					   struct sk_buff *skb,
 					   bool *skip_hw_vlan)
@@ -1059,6 +1317,9 @@ static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 			stopped = true;
 		}
 
+		if (be_is_mac_learning_enabled(adapter))
+			be_learn_mac(adapter, skb);
+
 		be_txq_notify(adapter, txo, wrb_cnt);
 
 		be_tx_stats_update(txo, wrb_cnt, copied, gso_segs, stopped);
@@ -1689,6 +1950,12 @@ static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
 	if (rxcp->vlanf)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rxcp->vlan_tag);
 
+	/* Unlearn the mac that is already learnt just in case
+	 * the mac moves out of the machine.
+	 */
+	if (adapter->flags & BE_FLAGS_MAC_LEARNING_INITIALIZED)
+		be_unlearn_mac(adapter, skb);
+
 	netif_receive_skb(skb);
 }
 
@@ -3073,6 +3340,31 @@ done:
 	adapter->flags &= ~BE_FLAGS_SRIOV_ENABLED;
 }
 
+static void be_clear_mac_learning(struct be_adapter *adapter)
+{
+	int j;
+	struct hlist_node *n;
+	struct hlist_head *head;
+	struct be_mac_node *node = NULL;
+
+	if (adapter->flags & BE_FLAGS_MAC_LEARNING_INITIALIZED) {
+		adapter->flags &= ~BE_FLAGS_MAC_LEARNING_INITIALIZED;
+		/* Flush all the pending rcu callbacks */
+		rcu_barrier();
+
+		for (j = 0; j < BE_MAC_HASH_TABLE_LEN; j++) {
+			head = &adapter->mac_table[j];
+			hlist_for_each_entry_safe(node, n, head, list) {
+				be_cmd_pmac_del(adapter,
+						adapter->if_handle,
+						node->pmac_id, 0);
+				kfree(node);
+			}
+		}
+		kfree(adapter->mac_table);
+	}
+}
+
 static void be_clear_queues(struct be_adapter *adapter)
 {
 	be_mcc_queues_destroy(adapter);
@@ -3121,6 +3413,14 @@ static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 
 static int be_clear(struct be_adapter *adapter)
 {
+	if (adapter->config_workq) {
+		flush_workqueue(adapter->config_workq);
+		destroy_workqueue(adapter->config_workq);
+	}
+
+	if (adapter->mc_type == NPAR)
+		be_clear_mac_learning(adapter);
+
 	be_cancel_worker(adapter);
 
 	if (sriov_enabled(adapter))
@@ -3514,6 +3814,27 @@ static int be_get_config(struct be_adapter *adapter)
 	return 0;
 }
 
+static void be_setup_mac_learning(struct be_adapter *adapter)
+{
+	int i;
+
+	adapter->mac_table = kcalloc(BE_MAC_HASH_TABLE_LEN,
+				     sizeof(struct hlist_head),
+				     GFP_KERNEL);
+	if (!adapter->mac_table) {
+		dev_err(&adapter->pdev->dev,
+			"Mac hash table alloc failed\n");
+		return;
+	}
+
+	spin_lock_init(&adapter->mac_hash_lock);
+
+	for (i = 0; i < BE_MAC_HASH_TABLE_LEN; i++)
+		INIT_HLIST_HEAD(&adapter->mac_table[i]);
+
+	adapter->flags |= BE_FLAGS_MAC_LEARNING_INITIALIZED;
+}
+
 static int be_mac_setup(struct be_adapter *adapter)
 {
 	u8 mac[ETH_ALEN];
@@ -3653,6 +3974,16 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_cmd_get_fn_privileges(adapter, &adapter->cmd_privileges, 0);
 
+	adapter->config_workq = create_singlethread_workqueue("be_config");
+	if (!adapter->config_workq) {
+		status = -ENOMEM;
+		dev_err(dev, "Cannot create be_config workqueue\n");
+		goto err;
+	}
+
+	if (adapter->mc_type == NPAR)
+		be_setup_mac_learning(adapter);
+
 	status = be_mac_setup(adapter);
 	if (status)
 		goto err;
@@ -4784,6 +5115,9 @@ static void be_worker(struct work_struct *work)
 
 	be_eqd_update(adapter);
 
+	if (adapter->flags & BE_FLAGS_MAC_LEARNING_INITIALIZED)
+		be_check_mac_aging(adapter);
+
 reschedule:
 	adapter->work_counter++;
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
@@ -4809,7 +5143,7 @@ static char *mc_name(struct be_adapter *adapter)
 	case vNIC1:
 		str = "vNIC-1";
 		break;
-	case nPAR:
+	case NPAR:
 		str = "nPAR";
 		break;
 	case UFP:
-- 
1.7.1
