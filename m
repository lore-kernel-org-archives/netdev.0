From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v2 06/10] IB/hfi-vnic: VNIC MAC table support
Date: Wed, 14 Dec 2016 23:59:38 -0800
Message-ID: <1481788782-89964-7-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HFI VNIC MAC table contains the MAC address to DLID mappings provided by
the Ethernet manager. During transmission, the MAC table provides the MAC
address to DLID translation. Implement MAC table using simple hash list.
Also provide support to update/query the MAC table by Ethernet manager.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c  | 236 +++++++++++++++++++++
 .../sw/intel/hfi_vnic/hfi_vnic_internal.h          |  53 ++++-
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c |   4 +
 3 files changed, 292 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
index 3fdfb7b..e45cff8 100644
--- a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
@@ -104,6 +104,238 @@
 
 #define HFI_VNIC_SC_MASK 0x1f
 
+/*
+ * Using a simple hash table for mac table implementation with the last octet
+ * of mac address as a key.
+ */
+static void hfi_vnic_free_mac_tbl(struct hlist_head *mactbl)
+{
+	struct hfi_vnic_mac_tbl_node *node;
+	struct hlist_node *tmp;
+	int bkt;
+
+	if (!mactbl)
+		return;
+
+	vnic_hash_for_each_safe(mactbl, bkt, tmp, node, hlist) {
+		hash_del(&node->hlist);
+		kfree(node);
+	}
+	kfree(mactbl);
+}
+
+static struct hlist_head *hfi_vnic_alloc_mac_tbl(void)
+{
+	u32 size = sizeof(struct hlist_head) * HFI_VNIC_MAC_TBL_SIZE;
+	struct hlist_head *mactbl;
+
+	mactbl = kzalloc(size, GFP_KERNEL);
+	if (!mactbl)
+		return ERR_PTR(-ENOMEM);
+
+	vnic_hash_init(mactbl);
+	return mactbl;
+}
+
+/* hfi_vnic_release_mac_tbl - empty and free the mac table */
+void hfi_vnic_release_mac_tbl(struct hfi_vnic_adapter *adapter)
+{
+	struct hlist_head *mactbl;
+
+	mutex_lock(&adapter->mactbl_lock);
+	mactbl = rcu_access_pointer(adapter->mactbl);
+	rcu_assign_pointer(adapter->mactbl, NULL);
+	synchronize_rcu();
+	hfi_vnic_free_mac_tbl(mactbl);
+	mutex_unlock(&adapter->mactbl_lock);
+}
+
+/*
+ * hfi_vnic_query_mac_tbl - query the mac table for a section
+ *
+ * This function implements query of specific function of the mac table.
+ * The function also expects the requested range to be valid.
+ */
+void hfi_vnic_query_mac_tbl(struct hfi_vnic_adapter *adapter,
+			    struct hfi_veswport_mactable *tbl)
+{
+	struct hfi_vnic_mac_tbl_node *node;
+	struct hlist_head *mactbl;
+	int bkt;
+	u16 loffset, lnum_entries;
+
+	rcu_read_lock();
+	mactbl = rcu_dereference(adapter->mactbl);
+	if (!mactbl)
+		goto get_mac_done;
+
+	loffset = be16_to_cpu(tbl->offset);
+	lnum_entries = be16_to_cpu(tbl->num_entries);
+
+	vnic_hash_for_each(mactbl, bkt, node, hlist) {
+		struct __hfi_vnic_mactable_entry *nentry = &node->entry;
+		struct hfi_veswport_mactable_entry *entry;
+
+		if ((node->index < loffset) ||
+		    (node->index >= (loffset + lnum_entries)))
+			continue;
+
+		/* populate entry in the tbl corresponding to the index */
+		entry = &tbl->tbl_entries[node->index - loffset];
+		memcpy(entry->mac_addr, nentry->mac_addr,
+		       ARRAY_SIZE(entry->mac_addr));
+		memcpy(entry->mac_addr_mask, nentry->mac_addr_mask,
+		       ARRAY_SIZE(entry->mac_addr_mask));
+		entry->dlid_sd.dw = cpu_to_be32(nentry->dlid_sd.dw);
+	}
+	tbl->mac_tbl_digest = cpu_to_be32(adapter->info.vport.mac_tbl_digest);
+get_mac_done:
+	rcu_read_unlock();
+}
+
+/*
+ * hfi_vnic_update_mac_tbl - update mac table section
+ *
+ * This function updates the specified section of the mac table.
+ * The procedure includes following steps.
+ *  - Allocate a new mac (hash) table.
+ *  - Add the specified entries to the new table.
+ *    (except the ones that are requested to be deleted).
+ *  - Add all the other entries from the old mac table.
+ *  - If there is a failure, free the new table and return.
+ *  - Switch to the new table.
+ *  - Free the old table and return.
+ *
+ * The function also expects the requested range to be valid.
+ */
+int hfi_vnic_update_mac_tbl(struct hfi_vnic_adapter *adapter,
+			    struct hfi_veswport_mactable *tbl)
+{
+	struct hfi_vnic_mac_tbl_node *node, *new_node;
+	struct hlist_head *new_mactbl, *old_mactbl;
+	int i, bkt, rc = 0;
+	u8 key;
+	u16 loffset, lnum_entries;
+
+	mutex_lock(&adapter->mactbl_lock);
+	/* allocate new mac table */
+	new_mactbl = hfi_vnic_alloc_mac_tbl();
+	if (IS_ERR(new_mactbl)) {
+		mutex_unlock(&adapter->mactbl_lock);
+		return PTR_ERR(new_mactbl);
+	}
+
+	loffset = be16_to_cpu(tbl->offset);
+	lnum_entries = be16_to_cpu(tbl->num_entries);
+
+	/* add updated entries to the new mac table */
+	for (i = 0; i < lnum_entries; i++) {
+		struct __hfi_vnic_mactable_entry *nentry;
+		struct hfi_veswport_mactable_entry *entry =
+							&tbl->tbl_entries[i];
+		u8 *mac_addr = entry->mac_addr;
+		u8 empty_mac[ETH_ALEN] = { 0 };
+
+		v_dbg("new mac entry %4d: %02x:%02x:%02x:%02x:%02x:%02x %x\n",
+		      loffset + i, mac_addr[0], mac_addr[1], mac_addr[2],
+		      mac_addr[3], mac_addr[4], mac_addr[5],
+		      entry->dlid_sd.dw);
+
+		/* if the entry is being removed, do not add it */
+		if (!memcmp(mac_addr, empty_mac, ARRAY_SIZE(empty_mac)))
+			continue;
+
+		node = kzalloc(sizeof(*node), GFP_KERNEL);
+		if (!node) {
+			rc = -ENOMEM;
+			goto updt_done;
+		}
+
+		node->index = loffset + i;
+		nentry = &node->entry;
+		memcpy(nentry->mac_addr, entry->mac_addr,
+		       ARRAY_SIZE(nentry->mac_addr));
+		memcpy(nentry->mac_addr_mask, entry->mac_addr_mask,
+		       ARRAY_SIZE(nentry->mac_addr_mask));
+		nentry->dlid_sd.dw = be32_to_cpu(entry->dlid_sd.dw);
+		key = node->entry.mac_addr[HFI_VNIC_MAC_HASH_IDX];
+		vnic_hash_add(new_mactbl, &node->hlist, key);
+	}
+
+	/* add other entries from current mac table to new mac table */
+	old_mactbl = rcu_access_pointer(adapter->mactbl);
+	if (!old_mactbl)
+		goto switch_tbl;
+
+	vnic_hash_for_each(old_mactbl, bkt, node, hlist) {
+		if ((node->index >= loffset) &&
+		    (node->index < (loffset + lnum_entries)))
+			continue;
+
+		new_node = kzalloc(sizeof(*new_node), GFP_KERNEL);
+		if (!new_node) {
+			rc = -ENOMEM;
+			goto updt_done;
+		}
+
+		new_node->index = node->index;
+		memcpy(&new_node->entry, &node->entry, sizeof(node->entry));
+		key = new_node->entry.mac_addr[HFI_VNIC_MAC_HASH_IDX];
+		vnic_hash_add(new_mactbl, &new_node->hlist, key);
+	}
+
+switch_tbl:
+	/* switch to new table */
+	rcu_assign_pointer(adapter->mactbl, new_mactbl);
+	synchronize_rcu();
+
+	adapter->info.vport.mac_tbl_digest = be32_to_cpu(tbl->mac_tbl_digest);
+updt_done:
+	/* upon failure, free the new table; otherwise, free the old table */
+	if (rc)
+		hfi_vnic_free_mac_tbl(new_mactbl);
+	else
+		hfi_vnic_free_mac_tbl(old_mactbl);
+
+	mutex_unlock(&adapter->mactbl_lock);
+	return rc;
+}
+
+/* hfi_vnic_chk_mac_tbl - check mac table for dlid */
+static uint32_t hfi_vnic_chk_mac_tbl(struct hfi_vnic_adapter *adapter,
+				     struct ethhdr *mac_hdr)
+{
+	struct hfi_vnic_mac_tbl_node *node;
+	struct hlist_head *mactbl;
+	u32 dlid = 0;
+	u8 key;
+
+	rcu_read_lock();
+	mactbl = rcu_dereference(adapter->mactbl);
+	if (!mactbl)
+		goto chk_done;
+
+	key = mac_hdr->h_dest[HFI_VNIC_MAC_HASH_IDX];
+	vnic_hash_for_each_possible(mactbl, node, hlist, key) {
+		struct __hfi_vnic_mactable_entry *entry = &node->entry;
+
+		/* if related to source mac, skip */
+		if (entry->dlid_sd.sd_is_src_mac)
+			continue;
+
+		if (!memcmp(node->entry.mac_addr, mac_hdr->h_dest,
+			    ARRAY_SIZE(node->entry.mac_addr))) {
+			/* mac address found */
+			dlid = node->entry.dlid_sd.dlid;
+			break;
+		}
+	}
+
+chk_done:
+	rcu_read_unlock();
+	return dlid;
+}
+
 /* hfi_vnic_get_dlid - find and return the DLID */
 static uint32_t hfi_vnic_get_dlid(struct hfi_vnic_adapter *adapter,
 				  struct sk_buff *skb, u8 def_port)
@@ -112,6 +344,10 @@ static uint32_t hfi_vnic_get_dlid(struct hfi_vnic_adapter *adapter,
 	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
 	u32 dlid;
 
+	dlid = hfi_vnic_chk_mac_tbl(adapter, mac_hdr);
+	if (dlid)
+		return dlid;
+
 	if (is_multicast_ether_addr(mac_hdr->h_dest)) {
 		dlid = info->vesw.u_mcast_dlid;
 	} else {
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
index af3ff0e..6d5c5f8 100644
--- a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
@@ -262,6 +262,8 @@ struct hfi_vnic_rx_queue {
  * @lock: adapter lock
  * @rxq: receive queue array
  * @info: virtual ethernet switch port information
+ * @mactbl: hash table of MAC entries
+ * @mactbl_lock: mac table lock
  * @stats_lock: statistics lock
  * @flow_tbl: flow to default port redirection table
  * @q_sum_cntrs: per queue EM summary counters
@@ -284,7 +286,11 @@ struct hfi_vnic_adapter {
 
 	struct hfi_vnic_rx_queue  rxq[HFI_VNIC_MAX_QUEUE];
 
-	struct __hfi_veswport_info info;
+	struct __hfi_veswport_info  info;
+	struct hlist_head  __rcu   *mactbl;
+
+	/* Lock used to protect updates to mac table */
+	struct mutex mactbl_lock;
 
 	/* Lock used to protect access to vnic counters */
 	struct mutex stats_lock;
@@ -304,6 +310,25 @@ struct hfi_vnic_adapter {
 	struct __hfi_vnic_error_counters    err_cntrs;
 };
 
+/* Same as hfi_veswport_mactable_entry, but without bitwise attribute */
+struct __hfi_vnic_mactable_entry {
+	u8                         mac_addr[ETH_ALEN];
+	u8                         mac_addr_mask[ETH_ALEN];
+	union __hfi_vnic_dlid_sd   dlid_sd;
+} __packed;
+
+/**
+ * struct hfi_vnic_mac_tbl_node - HFI VNIC mac table node
+ * @hlist: hash list handle
+ * @index: index of entry in the mac table
+ * @entry: entry in the table
+ */
+struct hfi_vnic_mac_tbl_node {
+	struct hlist_node                    hlist;
+	u16                                  index;
+	struct __hfi_vnic_mactable_entry     entry;
+};
+
 #define v_dbg(format, arg...) \
 	netdev_dbg(adapter->netdev, format, ## arg)
 #define v_err(format, arg...) \
@@ -325,12 +350,38 @@ struct hfi_vnic_adapter {
 #define HFI_VNIC_MAC_TBL_HASH_BITS    8
 #define HFI_VNIC_MAC_TBL_SIZE  BIT(HFI_VNIC_MAC_TBL_HASH_BITS)
 
+/* VNIC HASH MACROS */
+#define vnic_hash_init(hashtable) __hash_init(hashtable, HFI_VNIC_MAC_TBL_SIZE)
+
+#define vnic_hash_add(hashtable, node, key)                                   \
+	hlist_add_head(node,                                                  \
+		&hashtable[hash_min(key, ilog2(HFI_VNIC_MAC_TBL_SIZE))])
+
+#define vnic_hash_for_each_safe(name, bkt, tmp, obj, member)                  \
+	for ((bkt) = 0, obj = NULL;                                           \
+		    !obj && (bkt) < HFI_VNIC_MAC_TBL_SIZE; (bkt)++)           \
+		hlist_for_each_entry_safe(obj, tmp, &name[bkt], member)
+
+#define vnic_hash_for_each_possible(name, obj, member, key)                   \
+	hlist_for_each_entry(obj,                                             \
+		&name[hash_min(key, ilog2(HFI_VNIC_MAC_TBL_SIZE))], member)
+
+#define vnic_hash_for_each(name, bkt, obj, member)                            \
+	for ((bkt) = 0, obj = NULL;                                           \
+		    !obj && (bkt) < HFI_VNIC_MAC_TBL_SIZE; (bkt)++)           \
+		hlist_for_each_entry(obj, &name[bkt], member)
+
 struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct hfi_vnic_port *vport,
 					     struct device *parent);
 void hfi_vnic_rem_netdev(struct hfi_vnic_port *vport);
 int hfi_vnic_encap_skb(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
 int hfi_vnic_decap_skb(struct hfi_vnic_rx_queue *rxq, struct sk_buff *skb);
 u8 hfi_vnic_calc_entropy(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
+void hfi_vnic_release_mac_tbl(struct hfi_vnic_adapter *adapter);
+void hfi_vnic_query_mac_tbl(struct hfi_vnic_adapter *adapter,
+			    struct hfi_veswport_mactable *tbl);
+int hfi_vnic_update_mac_tbl(struct hfi_vnic_adapter *adapter,
+			    struct hfi_veswport_mactable *tbl);
 void hfi_vnic_update_stats(struct net_device *netdev);
 void hfi_vnic_set_ethtool_ops(struct net_device *netdev);
 
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
index 1626e44..04edafa 100644
--- a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
@@ -616,6 +616,7 @@ struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct hfi_vnic_port *vport,
 	netdev->netdev_ops = &hfi_netdev_ops;
 	netdev->hard_header_len += HFI_VNIC_SKB_HEADROOM;
 	mutex_init(&adapter->lock);
+	mutex_init(&adapter->mactbl_lock);
 	mutex_init(&adapter->stats_lock);
 	strcpy(netdev->name, "veth%d");
 
@@ -638,6 +639,7 @@ struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct hfi_vnic_port *vport,
 	return adapter;
 netdev_err:
 	mutex_destroy(&adapter->lock);
+	mutex_destroy(&adapter->mactbl_lock);
 	mutex_destroy(&adapter->stats_lock);
 	free_netdev(netdev);
 
@@ -651,7 +653,9 @@ void hfi_vnic_rem_netdev(struct hfi_vnic_port *vport)
 
 	v_info("removing\n");
 	unregister_netdev(vport->netdev);
+	hfi_vnic_release_mac_tbl(adapter);
 	mutex_destroy(&adapter->lock);
+	mutex_destroy(&adapter->mactbl_lock);
 	mutex_destroy(&adapter->stats_lock);
 	free_netdev(vport->netdev);
 }
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
