From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [PATCH 06/11] IB/opa-vnic: VNIC MAC table support
Date: Wed, 22 Feb 2017 23:06:41 -0800
Message-ID: <1487833606-57917-7-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1487833606-57917-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>,
        Sadanand Warrier <sadanand.warrier@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20308 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751170AbdBWHIT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 02:08:19 -0500
In-Reply-To: <1487833606-57917-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OPA VNIC MAC table contains the MAC address to DLID mappings provided by
the Ethernet manager. During transmission, the MAC table provides the MAC
address to DLID translation. Implement MAC table using simple hash list.
Also provide support to update/query the MAC table by Ethernet manager.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
Signed-off-by: Sadanand Warrier <sadanand.warrier@intel.com>
---
 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c   | 236 +++++++++++++++++++++
 .../infiniband/ulp/opa_vnic/opa_vnic_internal.h    |  51 +++++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c  |   4 +
 3 files changed, 291 insertions(+)

diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
index c74d02a..2e8fee9 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
@@ -96,6 +96,238 @@ static inline void opa_vnic_make_header(u8 *hdr, u32 slid, u32 dlid, u16 len,
 	memcpy(hdr, h, OPA_VNIC_HDR_LEN);
 }
 
+/*
+ * Using a simple hash table for mac table implementation with the last octet
+ * of mac address as a key.
+ */
+static void opa_vnic_free_mac_tbl(struct hlist_head *mactbl)
+{
+	struct opa_vnic_mac_tbl_node *node;
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
+static struct hlist_head *opa_vnic_alloc_mac_tbl(void)
+{
+	u32 size = sizeof(struct hlist_head) * OPA_VNIC_MAC_TBL_SIZE;
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
+/* opa_vnic_release_mac_tbl - empty and free the mac table */
+void opa_vnic_release_mac_tbl(struct opa_vnic_adapter *adapter)
+{
+	struct hlist_head *mactbl;
+
+	mutex_lock(&adapter->mactbl_lock);
+	mactbl = rcu_access_pointer(adapter->mactbl);
+	rcu_assign_pointer(adapter->mactbl, NULL);
+	synchronize_rcu();
+	opa_vnic_free_mac_tbl(mactbl);
+	mutex_unlock(&adapter->mactbl_lock);
+}
+
+/*
+ * opa_vnic_query_mac_tbl - query the mac table for a section
+ *
+ * This function implements query of specific function of the mac table.
+ * The function also expects the requested range to be valid.
+ */
+void opa_vnic_query_mac_tbl(struct opa_vnic_adapter *adapter,
+			    struct opa_veswport_mactable *tbl)
+{
+	struct opa_vnic_mac_tbl_node *node;
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
+		struct __opa_vnic_mactable_entry *nentry = &node->entry;
+		struct opa_veswport_mactable_entry *entry;
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
+		entry->dlid_sd = cpu_to_be32(nentry->dlid_sd);
+	}
+	tbl->mac_tbl_digest = cpu_to_be32(adapter->info.vport.mac_tbl_digest);
+get_mac_done:
+	rcu_read_unlock();
+}
+
+/*
+ * opa_vnic_update_mac_tbl - update mac table section
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
+int opa_vnic_update_mac_tbl(struct opa_vnic_adapter *adapter,
+			    struct opa_veswport_mactable *tbl)
+{
+	struct opa_vnic_mac_tbl_node *node, *new_node;
+	struct hlist_head *new_mactbl, *old_mactbl;
+	int i, bkt, rc = 0;
+	u8 key;
+	u16 loffset, lnum_entries;
+
+	mutex_lock(&adapter->mactbl_lock);
+	/* allocate new mac table */
+	new_mactbl = opa_vnic_alloc_mac_tbl();
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
+		struct __opa_vnic_mactable_entry *nentry;
+		struct opa_veswport_mactable_entry *entry =
+							&tbl->tbl_entries[i];
+		u8 *mac_addr = entry->mac_addr;
+		u8 empty_mac[ETH_ALEN] = { 0 };
+
+		v_dbg("new mac entry %4d: %02x:%02x:%02x:%02x:%02x:%02x %x\n",
+		      loffset + i, mac_addr[0], mac_addr[1], mac_addr[2],
+		      mac_addr[3], mac_addr[4], mac_addr[5],
+		      entry->dlid_sd);
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
+		nentry->dlid_sd = be32_to_cpu(entry->dlid_sd);
+		key = node->entry.mac_addr[OPA_VNIC_MAC_HASH_IDX];
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
+		key = new_node->entry.mac_addr[OPA_VNIC_MAC_HASH_IDX];
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
+		opa_vnic_free_mac_tbl(new_mactbl);
+	else
+		opa_vnic_free_mac_tbl(old_mactbl);
+
+	mutex_unlock(&adapter->mactbl_lock);
+	return rc;
+}
+
+/* opa_vnic_chk_mac_tbl - check mac table for dlid */
+static uint32_t opa_vnic_chk_mac_tbl(struct opa_vnic_adapter *adapter,
+				     struct ethhdr *mac_hdr)
+{
+	struct opa_vnic_mac_tbl_node *node;
+	struct hlist_head *mactbl;
+	u32 dlid = 0;
+	u8 key;
+
+	rcu_read_lock();
+	mactbl = rcu_dereference(adapter->mactbl);
+	if (unlikely(!mactbl))
+		goto chk_done;
+
+	key = mac_hdr->h_dest[OPA_VNIC_MAC_HASH_IDX];
+	vnic_hash_for_each_possible(mactbl, node, hlist, key) {
+		struct __opa_vnic_mactable_entry *entry = &node->entry;
+
+		/* if related to source mac, skip */
+		if (unlikely(OPA_VNIC_DLID_SD_IS_SRC_MAC(entry->dlid_sd)))
+			continue;
+
+		if (!memcmp(node->entry.mac_addr, mac_hdr->h_dest,
+			    ARRAY_SIZE(node->entry.mac_addr))) {
+			/* mac address found */
+			dlid = OPA_VNIC_DLID_SD_GET_DLID(node->entry.dlid_sd);
+			break;
+		}
+	}
+
+chk_done:
+	rcu_read_unlock();
+	return dlid;
+}
+
 /* opa_vnic_get_dlid - find and return the DLID */
 static uint32_t opa_vnic_get_dlid(struct opa_vnic_adapter *adapter,
 				  struct sk_buff *skb, u8 def_port)
@@ -104,6 +336,10 @@ static uint32_t opa_vnic_get_dlid(struct opa_vnic_adapter *adapter,
 	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
 	u32 dlid;
 
+	dlid = opa_vnic_chk_mac_tbl(adapter, mac_hdr);
+	if (dlid)
+		return dlid;
+
 	if (is_multicast_ether_addr(mac_hdr->h_dest)) {
 		dlid = info->vesw.u_mcast_dlid;
 	} else {
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h b/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
index 1c10dc2..bec4866 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
@@ -169,6 +169,8 @@ struct __opa_veswport_trap {
  * @vport_num: vesw port number
  * @lock: adapter lock
  * @info: virtual ethernet switch port information
+ * @mactbl: hash table of MAC entries
+ * @mactbl_lock: mac table lock
  * @stats_lock: statistics lock
  * @flow_tbl: flow to default port redirection table
  */
@@ -184,6 +186,10 @@ struct opa_vnic_adapter {
 	struct mutex lock;
 
 	struct __opa_veswport_info  info;
+	struct hlist_head  __rcu   *mactbl;
+
+	/* Lock used to protect updates to mac table */
+	struct mutex mactbl_lock;
 
 	/* Lock used to protect access to vnic counters */
 	struct mutex stats_lock;
@@ -191,6 +197,25 @@ struct opa_vnic_adapter {
 	u8 flow_tbl[OPA_VNIC_FLOW_TBL_SIZE];
 };
 
+/* Same as opa_veswport_mactable_entry, but without bitwise attribute */
+struct __opa_vnic_mactable_entry {
+	u8  mac_addr[ETH_ALEN];
+	u8  mac_addr_mask[ETH_ALEN];
+	u32 dlid_sd;
+} __packed;
+
+/**
+ * struct opa_vnic_mac_tbl_node - OPA VNIC mac table node
+ * @hlist: hash list handle
+ * @index: index of entry in the mac table
+ * @entry: entry in the table
+ */
+struct opa_vnic_mac_tbl_node {
+	struct hlist_node                    hlist;
+	u16                                  index;
+	struct __opa_vnic_mactable_entry     entry;
+};
+
 #define v_dbg(format, arg...) \
 	netdev_dbg(adapter->netdev, format, ## arg)
 #define v_err(format, arg...) \
@@ -212,12 +237,38 @@ struct opa_vnic_adapter {
 #define OPA_VNIC_MAC_TBL_HASH_BITS    8
 #define OPA_VNIC_MAC_TBL_SIZE  BIT(OPA_VNIC_MAC_TBL_HASH_BITS)
 
+/* VNIC HASH MACROS */
+#define vnic_hash_init(hashtable) __hash_init(hashtable, OPA_VNIC_MAC_TBL_SIZE)
+
+#define vnic_hash_add(hashtable, node, key)                                   \
+	hlist_add_head(node,                                                  \
+		&hashtable[hash_min(key, ilog2(OPA_VNIC_MAC_TBL_SIZE))])
+
+#define vnic_hash_for_each_safe(name, bkt, tmp, obj, member)                  \
+	for ((bkt) = 0, obj = NULL;                                           \
+		    !obj && (bkt) < OPA_VNIC_MAC_TBL_SIZE; (bkt)++)           \
+		hlist_for_each_entry_safe(obj, tmp, &name[bkt], member)
+
+#define vnic_hash_for_each_possible(name, obj, member, key)                   \
+	hlist_for_each_entry(obj,                                             \
+		&name[hash_min(key, ilog2(OPA_VNIC_MAC_TBL_SIZE))], member)
+
+#define vnic_hash_for_each(name, bkt, obj, member)                            \
+	for ((bkt) = 0, obj = NULL;                                           \
+		    !obj && (bkt) < OPA_VNIC_MAC_TBL_SIZE; (bkt)++)           \
+		hlist_for_each_entry(obj, &name[bkt], member)
+
 struct opa_vnic_adapter *opa_vnic_add_netdev(struct ib_device *ibdev,
 					     u8 port_num, u8 vport_num);
 void opa_vnic_rem_netdev(struct opa_vnic_adapter *adapter);
 void opa_vnic_encap_skb(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
 u8 opa_vnic_get_vl(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
 u8 opa_vnic_calc_entropy(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
+void opa_vnic_release_mac_tbl(struct opa_vnic_adapter *adapter);
+void opa_vnic_query_mac_tbl(struct opa_vnic_adapter *adapter,
+			    struct opa_veswport_mactable *tbl);
+int opa_vnic_update_mac_tbl(struct opa_vnic_adapter *adapter,
+			    struct opa_veswport_mactable *tbl);
 void opa_vnic_set_ethtool_ops(struct net_device *netdev);
 
 #endif /* _OPA_VNIC_INTERNAL_H */
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
index ef08e69..ab54c29 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
@@ -206,6 +206,7 @@ struct opa_vnic_adapter *opa_vnic_add_netdev(struct ib_device *ibdev,
 	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	netdev->hard_header_len += OPA_VNIC_SKB_HEADROOM;
 	mutex_init(&adapter->lock);
+	mutex_init(&adapter->mactbl_lock);
 	mutex_init(&adapter->stats_lock);
 
 	SET_NETDEV_DEV(netdev, ibdev->dma_device);
@@ -222,6 +223,7 @@ struct opa_vnic_adapter *opa_vnic_add_netdev(struct ib_device *ibdev,
 	return adapter;
 netdev_err:
 	mutex_destroy(&adapter->lock);
+	mutex_destroy(&adapter->mactbl_lock);
 	mutex_destroy(&adapter->stats_lock);
 	kfree(adapter);
 adapter_err:
@@ -238,7 +240,9 @@ void opa_vnic_rem_netdev(struct opa_vnic_adapter *adapter)
 
 	v_info("removing\n");
 	unregister_netdev(netdev);
+	opa_vnic_release_mac_tbl(adapter);
 	mutex_destroy(&adapter->lock);
+	mutex_destroy(&adapter->mactbl_lock);
 	mutex_destroy(&adapter->stats_lock);
 	kfree(adapter);
 	ibdev->free_rdma_netdev(netdev);
-- 
1.8.3.1
