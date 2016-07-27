From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 4/4] be2net: replace polling with sleeping in the FW completion path
Date: Wed, 27 Jul 2016 05:26:18 -0400
Message-ID: <1469611578-29665-5-git-send-email-sathya.perla@broadcom.com>
References: <1469611578-29665-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:1984 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754789AbcG0J0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 05:26:40 -0400
In-Reply-To: <1469611578-29665-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ndo_set_rx_mode() and ndo_add/del_vxlan_port() calls may be called with
BHs disabled. The driver currently issues the required cmds to the FW in
these contexts and polls on completions from the FW, while BHs remain
disabled.  This can cause either packet loss or packet reception to be
delayed on that CPU.

This patch defers processing of the above cmds to a separate workqueue.
With this change, FW cmds are now issued only in process context.
Now that the FW cmds are issued only in process context, they can sleep
waiting for a completion instead of polling. All the spin_lock_bh(mcc_lock)
calls are now replaced with mutex calls.

Also a new rx_filter_lock is now needed to protect the RX filtering fields
like vids[] between be_vlan_add/rem_vid() and __be_set_rx_mode() contexts.

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  19 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c | 202 ++++++++++-----------
 drivers/net/ethernet/emulex/benet/be_main.c | 264 ++++++++++++++++++++++------
 3 files changed, 327 insertions(+), 158 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 6868712..86780b5 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -508,6 +508,10 @@ struct be_wrb_params {
 	u16 lso_mss;	/* MSS for LSO */
 };
 
+struct be_eth_addr {
+	unsigned char mac[ETH_ALEN];
+};
+
 struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
@@ -523,7 +527,7 @@ struct be_adapter {
 	struct be_dma_mem mbox_mem_alloced;
 
 	struct be_mcc_obj mcc_obj;
-	spinlock_t mcc_lock;	/* For serializing mcc cmds to BE card */
+	struct mutex mcc_lock;	/* For serializing mcc cmds to BE card */
 	spinlock_t mcc_cq_lock;
 
 	u16 cfg_num_rx_irqs;		/* configured via set-channels */
@@ -570,11 +574,15 @@ struct be_adapter {
 	int if_handle;		/* Used to configure filtering */
 	u32 if_flags;		/* Interface filtering flags */
 	u32 *pmac_id;		/* MAC addr handle used by BE card */
+	struct be_eth_addr *uc_list;/* list of uc-addrs programmed (not perm) */
 	u32 uc_macs;		/* Count of secondary UC MAC programmed */
+	struct be_eth_addr *mc_list;/* list of mcast addrs programmed */
+	u32 mc_count;
 	unsigned long vids[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 vlans_added;
 	bool update_uc_list;
 	bool update_mc_list;
+	struct mutex rx_filter_lock;/* For protecting vids[] & mc/uc_list[] */
 
 	u32 beacon_state;	/* for set_phys_id */
 
@@ -628,6 +636,15 @@ struct be_adapter {
 	u8 phy_state; /* state of sfp optics (functional, faulted, etc.,) */
 };
 
+/* Used for defered FW config cmds. Add fields to this struct as reqd */
+struct be_cmd_work {
+	struct work_struct work;
+	struct be_adapter *adapter;
+	union {
+		__be16 vxlan_port;
+	} info;
+};
+
 #define be_physfn(adapter)		(!adapter->virtfn)
 #define be_virtfn(adapter)		(adapter->virtfn)
 #define sriov_enabled(adapter)		(adapter->flags &	\
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 2cc1175..fa11a5a 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -571,7 +571,7 @@ int be_process_mcc(struct be_adapter *adapter)
 /* Wait till no more pending mcc requests are present */
 static int be_mcc_wait_compl(struct be_adapter *adapter)
 {
-#define mcc_timeout		120000 /* 12s timeout */
+#define mcc_timeout		12000 /* 12s timeout */
 	int i, status = 0;
 	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 
@@ -585,7 +585,7 @@ static int be_mcc_wait_compl(struct be_adapter *adapter)
 
 		if (atomic_read(&mcc_obj->q.used) == 0)
 			break;
-		udelay(100);
+		usleep_range(500, 1000);
 	}
 	if (i == mcc_timeout) {
 		dev_err(&adapter->pdev->dev, "FW not responding\n");
@@ -863,7 +863,7 @@ static bool use_mcc(struct be_adapter *adapter)
 static int be_cmd_lock(struct be_adapter *adapter)
 {
 	if (use_mcc(adapter)) {
-		spin_lock_bh(&adapter->mcc_lock);
+		mutex_lock(&adapter->mcc_lock);
 		return 0;
 	} else {
 		return mutex_lock_interruptible(&adapter->mbox_lock);
@@ -874,7 +874,7 @@ static int be_cmd_lock(struct be_adapter *adapter)
 static void be_cmd_unlock(struct be_adapter *adapter)
 {
 	if (use_mcc(adapter))
-		spin_unlock_bh(&adapter->mcc_lock);
+		return mutex_unlock(&adapter->mcc_lock);
 	else
 		return mutex_unlock(&adapter->mbox_lock);
 }
@@ -1044,7 +1044,7 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 	struct be_cmd_req_mac_query *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1073,7 +1073,7 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1085,7 +1085,7 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 	struct be_cmd_req_pmac_add *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1110,7 +1110,7 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 
 	 if (status == MCC_STATUS_UNAUTHORIZED_REQUEST)
 		status = -EPERM;
@@ -1128,7 +1128,7 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, int pmac_id, u32 dom)
 	if (pmac_id == -1)
 		return 0;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1148,7 +1148,7 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, int pmac_id, u32 dom)
 	status = be_mcc_notify_wait(adapter);
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1411,7 +1411,7 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 	struct be_dma_mem *q_mem = &rxq->dma_mem;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1441,7 +1441,7 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1505,7 +1505,7 @@ int be_cmd_rxq_destroy(struct be_adapter *adapter, struct be_queue_info *q)
 	struct be_cmd_req_q_destroy *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1522,7 +1522,7 @@ int be_cmd_rxq_destroy(struct be_adapter *adapter, struct be_queue_info *q)
 	q->created = false;
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1590,7 +1590,7 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	struct be_cmd_req_hdr *hdr;
 	int status = 0;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1618,7 +1618,7 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	adapter->stats_cmd_sent = true;
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1634,7 +1634,7 @@ int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 			    CMD_SUBSYSTEM_ETH))
 		return -EPERM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1657,7 +1657,7 @@ int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 	adapter->stats_cmd_sent = true;
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1694,7 +1694,7 @@ int be_cmd_link_status_query(struct be_adapter *adapter, u16 *link_speed,
 	struct be_cmd_req_link_status *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	if (link_status)
 		*link_status = LINK_DOWN;
@@ -1733,7 +1733,7 @@ int be_cmd_link_status_query(struct be_adapter *adapter, u16 *link_speed,
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1744,7 +1744,7 @@ int be_cmd_get_die_temperature(struct be_adapter *adapter)
 	struct be_cmd_req_get_cntl_addnl_attribs *req;
 	int status = 0;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1759,7 +1759,7 @@ int be_cmd_get_die_temperature(struct be_adapter *adapter)
 
 	status = be_mcc_notify(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1808,7 +1808,7 @@ int be_cmd_get_fat_dump(struct be_adapter *adapter, u32 buf_len, void *buf)
 	if (!get_fat_cmd.va)
 		return -ENOMEM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	while (total_size) {
 		buf_size = min(total_size, (u32)60*1024);
@@ -1848,7 +1848,7 @@ int be_cmd_get_fat_dump(struct be_adapter *adapter, u32 buf_len, void *buf)
 err:
 	dma_free_coherent(&adapter->pdev->dev, get_fat_cmd.size,
 			  get_fat_cmd.va, get_fat_cmd.dma);
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1859,7 +1859,7 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter)
 	struct be_cmd_req_get_fw_version *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1882,7 +1882,7 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter)
 			sizeof(adapter->fw_on_flash));
 	}
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1896,7 +1896,7 @@ static int __be_cmd_modify_eqd(struct be_adapter *adapter,
 	struct be_cmd_req_modify_eq_delay *req;
 	int status = 0, i;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1919,7 +1919,7 @@ static int __be_cmd_modify_eqd(struct be_adapter *adapter,
 
 	status = be_mcc_notify(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1946,7 +1946,7 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 	struct be_cmd_req_vlan_config *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1968,7 +1968,7 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1979,7 +1979,7 @@ static int __be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 	struct be_cmd_req_rx_filter *req = mem->va;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1996,8 +1996,7 @@ static int __be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 	req->if_flags = (value == ON) ? req->if_flags_mask : 0;
 
 	if (flags & BE_IF_FLAGS_MULTICAST) {
-		struct netdev_hw_addr *ha;
-		int i = 0;
+		int i;
 
 		/* Reset mcast promisc mode if already set by setting mask
 		 * and not setting flags field
@@ -2005,14 +2004,15 @@ static int __be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 		req->if_flags_mask |=
 			cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS &
 				    be_if_cap_flags(adapter));
-		req->mcast_num = cpu_to_le32(netdev_mc_count(adapter->netdev));
-		netdev_for_each_mc_addr(ha, adapter->netdev)
-			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
+		req->mcast_num = cpu_to_le32(adapter->mc_count);
+		for (i = 0; i < adapter->mc_count; i++)
+			ether_addr_copy(req->mcast_mac[i].byte,
+					adapter->mc_list[i].mac);
 	}
 
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2043,7 +2043,7 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 			    CMD_SUBSYSTEM_COMMON))
 		return -EPERM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2063,7 +2063,7 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 	status = be_mcc_notify_wait(adapter);
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 
 	if (base_status(status) == MCC_STATUS_FEATURE_NOT_SUPPORTED)
 		return  -EOPNOTSUPP;
@@ -2082,7 +2082,7 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 			    CMD_SUBSYSTEM_COMMON))
 		return -EPERM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2105,7 +2105,7 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2186,7 +2186,7 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
 	if (!(be_if_cap_flags(adapter) & BE_IF_FLAGS_RSS))
 		return 0;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2211,7 +2211,7 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
 
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2223,7 +2223,7 @@ int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num,
 	struct be_cmd_req_enable_disable_beacon *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2244,7 +2244,7 @@ int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num,
 	status = be_mcc_notify_wait(adapter);
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2255,7 +2255,7 @@ int be_cmd_get_beacon_state(struct be_adapter *adapter, u8 port_num, u32 *state)
 	struct be_cmd_req_get_beacon_state *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2279,7 +2279,7 @@ int be_cmd_get_beacon_state(struct be_adapter *adapter, u8 port_num, u32 *state)
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2303,7 +2303,7 @@ int be_cmd_read_port_transceiver_data(struct be_adapter *adapter,
 		return -ENOMEM;
 	}
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2325,7 +2325,7 @@ int be_cmd_read_port_transceiver_data(struct be_adapter *adapter,
 		memcpy(data, resp->page_data, PAGE_DATA_LEN);
 	}
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
 	return status;
 }
@@ -2342,7 +2342,7 @@ static int lancer_cmd_write_object(struct be_adapter *adapter,
 	void *ctxt = NULL;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 	adapter->flash_status = 0;
 
 	wrb = wrb_from_mccq(adapter);
@@ -2384,7 +2384,7 @@ static int lancer_cmd_write_object(struct be_adapter *adapter,
 	if (status)
 		goto err_unlock;
 
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 
 	if (!wait_for_completion_timeout(&adapter->et_cmd_compl,
 					 msecs_to_jiffies(60000)))
@@ -2403,7 +2403,7 @@ static int lancer_cmd_write_object(struct be_adapter *adapter,
 	return status;
 
 err_unlock:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2457,7 +2457,7 @@ static int lancer_cmd_delete_object(struct be_adapter *adapter,
 	struct be_mcc_wrb *wrb;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2475,7 +2475,7 @@ static int lancer_cmd_delete_object(struct be_adapter *adapter,
 
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2488,7 +2488,7 @@ int lancer_cmd_read_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	struct lancer_cmd_resp_read_object *resp;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2522,7 +2522,7 @@ int lancer_cmd_read_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	}
 
 err_unlock:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2534,7 +2534,7 @@ static int be_cmd_write_flashrom(struct be_adapter *adapter,
 	struct be_cmd_write_flashrom *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 	adapter->flash_status = 0;
 
 	wrb = wrb_from_mccq(adapter);
@@ -2559,7 +2559,7 @@ static int be_cmd_write_flashrom(struct be_adapter *adapter,
 	if (status)
 		goto err_unlock;
 
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 
 	if (!wait_for_completion_timeout(&adapter->et_cmd_compl,
 					 msecs_to_jiffies(40000)))
@@ -2570,7 +2570,7 @@ static int be_cmd_write_flashrom(struct be_adapter *adapter,
 	return status;
 
 err_unlock:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -2581,7 +2581,7 @@ static int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 	struct be_mcc_wrb *wrb;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -2608,7 +2608,7 @@ static int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 		memcpy(flashed_crc, req->crc, 4);
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3192,7 +3192,7 @@ int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 	struct be_cmd_req_acpi_wol_magic_config *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3209,7 +3209,7 @@ int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 	status = be_mcc_notify_wait(adapter);
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3224,7 +3224,7 @@ int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 			    CMD_SUBSYSTEM_LOWLEVEL))
 		return -EPERM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3247,7 +3247,7 @@ int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 	if (status)
 		goto err_unlock;
 
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 
 	if (!wait_for_completion_timeout(&adapter->et_cmd_compl,
 					 msecs_to_jiffies(SET_LB_MODE_TIMEOUT)))
@@ -3256,7 +3256,7 @@ int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 	return status;
 
 err_unlock:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3273,7 +3273,7 @@ int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 			    CMD_SUBSYSTEM_LOWLEVEL))
 		return -EPERM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3299,7 +3299,7 @@ int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 	if (status)
 		goto err;
 
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 
 	wait_for_completion(&adapter->et_cmd_compl);
 	resp = embedded_payload(wrb);
@@ -3307,7 +3307,7 @@ int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 
 	return status;
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3323,7 +3323,7 @@ int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
 			    CMD_SUBSYSTEM_LOWLEVEL))
 		return -EPERM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3357,7 +3357,7 @@ int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3368,7 +3368,7 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 	struct be_cmd_req_seeprom_read *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3384,7 +3384,7 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 	status = be_mcc_notify_wait(adapter);
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3399,7 +3399,7 @@ int be_cmd_get_phy_info(struct be_adapter *adapter)
 			    CMD_SUBSYSTEM_COMMON))
 		return -EPERM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3444,7 +3444,7 @@ int be_cmd_get_phy_info(struct be_adapter *adapter)
 	}
 	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3454,7 +3454,7 @@ static int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain)
 	struct be_cmd_req_set_qos *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3474,7 +3474,7 @@ static int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain)
 	status = be_mcc_notify_wait(adapter);
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3581,7 +3581,7 @@ int be_cmd_get_fn_privileges(struct be_adapter *adapter, u32 *privilege,
 	struct be_cmd_req_get_fn_privileges *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3613,7 +3613,7 @@ int be_cmd_get_fn_privileges(struct be_adapter *adapter, u32 *privilege,
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3625,7 +3625,7 @@ int be_cmd_set_fn_privileges(struct be_adapter *adapter, u32 privileges,
 	struct be_cmd_req_set_fn_privileges *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3645,7 +3645,7 @@ int be_cmd_set_fn_privileges(struct be_adapter *adapter, u32 privileges,
 
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3677,7 +3677,7 @@ int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
 		return -ENOMEM;
 	}
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3741,7 +3741,7 @@ int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
 	}
 
 out:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	dma_free_coherent(&adapter->pdev->dev, get_mac_list_cmd.size,
 			  get_mac_list_cmd.va, get_mac_list_cmd.dma);
 	return status;
@@ -3801,7 +3801,7 @@ int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array,
 	if (!cmd.va)
 		return -ENOMEM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3823,7 +3823,7 @@ int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array,
 
 err:
 	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3859,7 +3859,7 @@ int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 			    CMD_SUBSYSTEM_COMMON))
 		return -EPERM;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3900,7 +3900,7 @@ int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 	status = be_mcc_notify_wait(adapter);
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -3914,7 +3914,7 @@ int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid,
 	int status;
 	u16 vid;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -3961,7 +3961,7 @@ int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid,
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -4156,7 +4156,7 @@ int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 	struct be_cmd_req_set_ext_fat_caps *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -4172,7 +4172,7 @@ int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -4650,7 +4650,7 @@ int be_cmd_manage_iface(struct be_adapter *adapter, u32 iface, u8 op)
 	if (iface == 0xFFFFFFFF)
 		return -1;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -4667,7 +4667,7 @@ int be_cmd_manage_iface(struct be_adapter *adapter, u32 iface, u8 op)
 
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -4701,7 +4701,7 @@ int be_cmd_get_if_id(struct be_adapter *adapter, struct be_vf_cfg *vf_cfg,
 	struct be_cmd_resp_get_iface_list *resp;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -4722,7 +4722,7 @@ int be_cmd_get_if_id(struct be_adapter *adapter, struct be_vf_cfg *vf_cfg,
 	}
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -4816,7 +4816,7 @@ int be_cmd_enable_vf(struct be_adapter *adapter, u8 domain)
 	if (BEx_chip(adapter))
 		return 0;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -4834,7 +4834,7 @@ int be_cmd_enable_vf(struct be_adapter *adapter, u8 domain)
 	req->enable = 1;
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -4905,7 +4905,7 @@ int __be_cmd_set_logical_link_config(struct be_adapter *adapter,
 	struct be_cmd_req_set_ll_link *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -4931,7 +4931,7 @@ int __be_cmd_set_logical_link_config(struct be_adapter *adapter,
 
 	status = be_mcc_notify_wait(adapter);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 
@@ -4964,7 +4964,7 @@ int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 	struct be_cmd_resp_hdr *resp;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
+	mutex_lock(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -4987,7 +4987,7 @@ int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 	memcpy(wrb_payload, resp, sizeof(*resp) + resp->response_length);
 	be_dws_le_to_cpu(wrb_payload, sizeof(*resp) + resp->response_length);
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	mutex_unlock(&adapter->mcc_lock);
 	return status;
 }
 EXPORT_SYMBOL(be_roce_mcc_cmd);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4cf4997..70b117a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -53,6 +53,10 @@ static const struct pci_device_id be_dev_ids[] = {
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
+
+/* Workqueue used by all functions for defering cmd calls to the adapter */
+struct workqueue_struct *be_wq;
+
 /* UE Status Low CSR */
 static const char * const ue_status_low_desc[] = {
 	"CEV",
@@ -1453,34 +1457,45 @@ static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
 
+	mutex_lock(&adapter->rx_filter_lock);
+
 	/* Packets with VID 0 are always received by Lancer by default */
 	if (lancer_chip(adapter) && vid == 0)
-		return status;
+		goto done;
 
 	if (test_bit(vid, adapter->vids))
-		return status;
+		goto done;
 
 	set_bit(vid, adapter->vids);
 	adapter->vlans_added++;
 
-	return be_vid_config(adapter);
+	status = be_vid_config(adapter);
+done:
+	mutex_unlock(&adapter->rx_filter_lock);
+	return status;
 }
 
 static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	int status = 0;
+
+	mutex_lock(&adapter->rx_filter_lock);
 
 	/* Packets with VID 0 are always received by Lancer by default */
 	if (lancer_chip(adapter) && vid == 0)
-		return 0;
+		goto done;
 
 	if (!test_bit(vid, adapter->vids))
-		return 0;
+		goto done;
 
 	clear_bit(vid, adapter->vids);
 	adapter->vlans_added--;
 
-	return be_vid_config(adapter);
+	status = be_vid_config(adapter);
+done:
+	mutex_unlock(&adapter->rx_filter_lock);
+	return status;
 }
 
 static void be_set_all_promisc(struct be_adapter *adapter)
@@ -1551,9 +1566,11 @@ static int be_mc_list_update(struct net_device *netdev,
 static void be_set_mc_list(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct netdev_hw_addr *ha;
 	bool mc_promisc = false;
 	int status;
 
+	netif_addr_lock_bh(netdev);
 	__dev_mc_sync(netdev, be_mc_list_update, be_mc_list_update);
 
 	if (netdev->flags & IFF_PROMISC) {
@@ -1572,6 +1589,18 @@ static void be_set_mc_list(struct be_adapter *adapter)
 		adapter->update_mc_list = true;
 	}
 
+	if (adapter->update_mc_list) {
+		int i = 0;
+
+		/* cache the mc-list in adapter */
+		netdev_for_each_mc_addr(ha, netdev) {
+			ether_addr_copy(adapter->mc_list[i].mac, ha->addr);
+			i++;
+		}
+		adapter->mc_count = netdev_mc_count(netdev);
+	}
+	netif_addr_unlock_bh(netdev);
+
 	if (mc_promisc) {
 		be_set_mc_promisc(adapter);
 	} else if (adapter->update_mc_list) {
@@ -1591,6 +1620,7 @@ static void be_clear_mc_list(struct be_adapter *adapter)
 
 	__dev_mc_unsync(netdev, NULL);
 	be_cmd_rx_filter(adapter, BE_IF_FLAGS_MULTICAST, OFF);
+	adapter->mc_count = 0;
 }
 
 static void be_set_uc_list(struct be_adapter *adapter)
@@ -1598,8 +1628,9 @@ static void be_set_uc_list(struct be_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct netdev_hw_addr *ha;
 	bool uc_promisc = false;
-	int i = 1; /* First slot is claimed by the Primary MAC */
+	int curr_uc_macs = 0, i;
 
+	netif_addr_lock_bh(netdev);
 	__dev_uc_sync(netdev, be_uc_list_update, be_uc_list_update);
 
 	if (netdev->flags & IFF_PROMISC) {
@@ -1614,21 +1645,32 @@ static void be_set_uc_list(struct be_adapter *adapter)
 		adapter->update_uc_list = true;
 	}
 
+	if (adapter->update_uc_list) {
+		i = 1; /* First slot is claimed by the Primary MAC */
+
+		/* cache the uc-list in adapter array */
+		netdev_for_each_uc_addr(ha, netdev) {
+			ether_addr_copy(adapter->uc_list[i].mac, ha->addr);
+			i++;
+		}
+		curr_uc_macs = netdev_uc_count(netdev);
+	}
+	netif_addr_unlock_bh(netdev);
+
 	if (uc_promisc) {
 		be_set_uc_promisc(adapter);
 	} else if (adapter->update_uc_list) {
 		be_clear_uc_promisc(adapter);
 
-		for (; adapter->uc_macs > 0; adapter->uc_macs--, i++)
+		for (i = 0; i < adapter->uc_macs; i++)
 			be_cmd_pmac_del(adapter, adapter->if_handle,
-					adapter->pmac_id[i], 0);
+					adapter->pmac_id[i + 1], 0);
 
-		netdev_for_each_uc_addr(ha, adapter->netdev) {
-			adapter->uc_macs++; /* First slot is for Primary MAC */
-			be_cmd_pmac_add(adapter,
-					(u8 *)ha->addr, adapter->if_handle,
-					&adapter->pmac_id[adapter->uc_macs], 0);
-		}
+		for (i = 0; i < curr_uc_macs; i++)
+			be_cmd_pmac_add(adapter, adapter->uc_list[i].mac,
+					adapter->if_handle,
+					&adapter->pmac_id[i + 1], 0);
+		adapter->uc_macs = curr_uc_macs;
 		adapter->update_uc_list = false;
 	}
 }
@@ -1639,15 +1681,17 @@ static void be_clear_uc_list(struct be_adapter *adapter)
 	int i;
 
 	__dev_uc_unsync(netdev, NULL);
-	for (i = 1; i < (adapter->uc_macs + 1); i++)
+	for (i = 0; i < adapter->uc_macs; i++)
 		be_cmd_pmac_del(adapter, adapter->if_handle,
-				adapter->pmac_id[i], 0);
+				adapter->pmac_id[i + 1], 0);
 	adapter->uc_macs = 0;
 }
 
-static void be_set_rx_mode(struct net_device *netdev)
+static void __be_set_rx_mode(struct be_adapter *adapter)
 {
-	struct be_adapter *adapter = netdev_priv(netdev);
+	struct net_device *netdev = adapter->netdev;
+
+	mutex_lock(&adapter->rx_filter_lock);
 
 	if (netdev->flags & IFF_PROMISC) {
 		if (!be_in_all_promisc(adapter))
@@ -1662,6 +1706,17 @@ static void be_set_rx_mode(struct net_device *netdev)
 
 	be_set_uc_list(adapter);
 	be_set_mc_list(adapter);
+
+	mutex_unlock(&adapter->rx_filter_lock);
+}
+
+static void be_work_set_rx_mode(struct work_struct *work)
+{
+	struct be_cmd_work *cmd_work =
+				container_of(work, struct be_cmd_work, work);
+
+	__be_set_rx_mode(cmd_work->adapter);
+	kfree(cmd_work);
 }
 
 static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
@@ -3546,6 +3601,11 @@ static int be_close(struct net_device *netdev)
 	if (!(adapter->flags & BE_FLAGS_SETUP_DONE))
 		return 0;
 
+	/* Before attempting cleanup ensure all the pending cmds in the
+	 * config_wq have finished execution
+	 */
+	flush_workqueue(be_wq);
+
 	be_disable_if_filters(adapter);
 
 	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
@@ -3670,7 +3730,7 @@ static int be_enable_if_filters(struct be_adapter *adapter)
 	if (adapter->vlans_added)
 		be_vid_config(adapter);
 
-	be_set_rx_mode(adapter->netdev);
+	__be_set_rx_mode(adapter);
 
 	return 0;
 }
@@ -3944,6 +4004,20 @@ static void be_calculate_vf_res(struct be_adapter *adapter, u16 num_vfs,
 		vft_res->max_mcc_count = res.max_mcc_count / (num_vfs + 1);
 }
 
+static void be_if_destroy(struct be_adapter *adapter)
+{
+	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
+
+	kfree(adapter->pmac_id);
+	adapter->pmac_id = NULL;
+
+	kfree(adapter->mc_list);
+	adapter->mc_list = NULL;
+
+	kfree(adapter->uc_list);
+	adapter->uc_list = NULL;
+}
+
 static int be_clear(struct be_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
@@ -3951,6 +4025,8 @@ static int be_clear(struct be_adapter *adapter)
 
 	be_cancel_worker(adapter);
 
+	flush_workqueue(be_wq);
+
 	if (sriov_enabled(adapter))
 		be_vf_clear(adapter);
 
@@ -3968,10 +4044,8 @@ static int be_clear(struct be_adapter *adapter)
 	}
 
 	be_disable_vxlan_offloads(adapter);
-	kfree(adapter->pmac_id);
-	adapter->pmac_id = NULL;
 
-	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
+	be_if_destroy(adapter);
 
 	be_clear_queues(adapter);
 
@@ -4425,7 +4499,7 @@ static int be_mac_setup(struct be_adapter *adapter)
 
 static void be_schedule_worker(struct be_adapter *adapter)
 {
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
+	queue_delayed_work(be_wq, &adapter->work, msecs_to_jiffies(1000));
 	adapter->flags |= BE_FLAGS_WORKER_SCHEDULED;
 }
 
@@ -4477,6 +4551,22 @@ static int be_if_create(struct be_adapter *adapter)
 	u32 cap_flags = be_if_cap_flags(adapter);
 	int status;
 
+	/* alloc required memory for other filtering fields */
+	adapter->pmac_id = kcalloc(be_max_uc(adapter),
+				   sizeof(*adapter->pmac_id), GFP_KERNEL);
+	if (!adapter->pmac_id)
+		return -ENOMEM;
+
+	adapter->mc_list = kcalloc(be_max_mc(adapter),
+				   sizeof(*adapter->mc_list), GFP_KERNEL);
+	if (!adapter->mc_list)
+		return -ENOMEM;
+
+	adapter->uc_list = kcalloc(be_max_uc(adapter),
+				   sizeof(*adapter->uc_list), GFP_KERNEL);
+	if (!adapter->uc_list)
+		return -ENOMEM;
+
 	if (adapter->cfg_num_rx_irqs == 1)
 		cap_flags &= ~(BE_IF_FLAGS_DEFQ_RSS | BE_IF_FLAGS_RSS);
 
@@ -4485,7 +4575,10 @@ static int be_if_create(struct be_adapter *adapter)
 	status = be_cmd_if_create(adapter, be_if_cap_flags(adapter), en_flags,
 				  &adapter->if_handle, 0);
 
-	return status;
+	if (status)
+		return status;
+
+	return 0;
 }
 
 int be_update_queues(struct be_adapter *adapter)
@@ -4614,11 +4707,6 @@ static int be_setup(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	adapter->pmac_id = kcalloc(be_max_uc(adapter),
-				   sizeof(*adapter->pmac_id), GFP_KERNEL);
-	if (!adapter->pmac_id)
-		return -ENOMEM;
-
 	status = be_msix_enable(adapter);
 	if (status)
 		goto err;
@@ -4812,6 +4900,23 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       0, 0, nlflags, filter_mask, NULL);
 }
 
+static struct be_cmd_work *be_alloc_work(struct be_adapter *adapter,
+					 void (*func)(struct work_struct *))
+{
+	struct be_cmd_work *work;
+
+	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work) {
+		dev_err(&adapter->pdev->dev,
+			"be_work memory allocation failed\n");
+		return NULL;
+	}
+
+	INIT_WORK(&work->work, func);
+	work->adapter = adapter;
+	return work;
+}
+
 /* VxLAN offload Notes:
  *
  * The stack defines tunnel offload flags (hw_enc_features) for IP and doesn't
@@ -4826,23 +4931,19 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
  * adds more than one port, disable offloads and don't re-enable them again
  * until after all the tunnels are removed.
  */
-static void be_add_vxlan_port(struct net_device *netdev,
-			      struct udp_tunnel_info *ti)
+static void be_work_add_vxlan_port(struct work_struct *work)
 {
-	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_cmd_work *cmd_work =
+				container_of(work, struct be_cmd_work, work);
+	struct be_adapter *adapter = cmd_work->adapter;
+	struct net_device *netdev = adapter->netdev;
 	struct device *dev = &adapter->pdev->dev;
-	__be16 port = ti->port;
+	__be16 port = cmd_work->info.vxlan_port;
 	int status;
 
-	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
-		return;
-
-	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
-		return;
-
 	if (adapter->vxlan_port == port && adapter->vxlan_port_count) {
 		adapter->vxlan_port_aliases++;
-		return;
+		goto done;
 	}
 
 	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
@@ -4854,7 +4955,7 @@ static void be_add_vxlan_port(struct net_device *netdev,
 	}
 
 	if (adapter->vxlan_port_count++ >= 1)
-		return;
+		goto done;
 
 	status = be_cmd_manage_iface(adapter, adapter->if_handle,
 				     OP_CONVERT_NORMAL_TO_TUNNEL);
@@ -4879,29 +4980,26 @@ static void be_add_vxlan_port(struct net_device *netdev,
 
 	dev_info(dev, "Enabled VxLAN offloads for UDP port %d\n",
 		 be16_to_cpu(port));
-	return;
+	goto done;
 err:
 	be_disable_vxlan_offloads(adapter);
+done:
+	kfree(cmd_work);
 }
 
-static void be_del_vxlan_port(struct net_device *netdev,
-			      struct udp_tunnel_info *ti)
+static void be_work_del_vxlan_port(struct work_struct *work)
 {
-	struct be_adapter *adapter = netdev_priv(netdev);
-	__be16 port = ti->port;
-
-	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
-		return;
-
-	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
-		return;
+	struct be_cmd_work *cmd_work =
+				container_of(work, struct be_cmd_work, work);
+	struct be_adapter *adapter = cmd_work->adapter;
+	__be16 port = cmd_work->info.vxlan_port;
 
 	if (adapter->vxlan_port != port)
 		goto done;
 
 	if (adapter->vxlan_port_aliases) {
 		adapter->vxlan_port_aliases--;
-		return;
+		goto out;
 	}
 
 	be_disable_vxlan_offloads(adapter);
@@ -4911,6 +5009,40 @@ static void be_del_vxlan_port(struct net_device *netdev,
 		 be16_to_cpu(port));
 done:
 	adapter->vxlan_port_count--;
+out:
+	kfree(cmd_work);
+}
+
+static void be_cfg_vxlan_port(struct net_device *netdev,
+			      struct udp_tunnel_info *ti,
+			      void (*func)(struct work_struct *))
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_cmd_work *cmd_work;
+
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
+	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
+		return;
+
+	cmd_work = be_alloc_work(adapter, func);
+	if (cmd_work) {
+		cmd_work->info.vxlan_port = ti->port;
+		queue_work(be_wq, &cmd_work->work);
+	}
+}
+
+static void be_del_vxlan_port(struct net_device *netdev,
+			      struct udp_tunnel_info *ti)
+{
+	be_cfg_vxlan_port(netdev, ti, be_work_del_vxlan_port);
+}
+
+static void be_add_vxlan_port(struct net_device *netdev,
+			      struct udp_tunnel_info *ti)
+{
+	be_cfg_vxlan_port(netdev, ti, be_work_add_vxlan_port);
 }
 
 static netdev_features_t be_features_check(struct sk_buff *skb,
@@ -4975,6 +5107,16 @@ static int be_get_phys_port_id(struct net_device *dev,
 	return 0;
 }
 
+static void be_set_rx_mode(struct net_device *dev)
+{
+	struct be_adapter *adapter = netdev_priv(dev);
+	struct be_cmd_work *work;
+
+	work = be_alloc_work(adapter, be_work_set_rx_mode);
+	if (work)
+		queue_work(be_wq, &work->work);
+}
+
 static const struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
@@ -5200,7 +5342,7 @@ static void be_worker(struct work_struct *work)
 
 reschedule:
 	adapter->work_counter++;
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
+	queue_delayed_work(be_wq, &adapter->work, msecs_to_jiffies(1000));
 }
 
 static void be_unmap_pci_bars(struct be_adapter *adapter)
@@ -5340,7 +5482,8 @@ static int be_drv_init(struct be_adapter *adapter)
 	}
 
 	mutex_init(&adapter->mbox_lock);
-	spin_lock_init(&adapter->mcc_lock);
+	mutex_init(&adapter->mcc_lock);
+	mutex_init(&adapter->rx_filter_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
 	init_completion(&adapter->et_cmd_compl);
 
@@ -5796,6 +5939,12 @@ static int __init be_init_module(void)
 		pr_info(DRV_NAME " : Use sysfs method to enable VFs\n");
 	}
 
+	be_wq = create_singlethread_workqueue("be_wq");
+	if (!be_wq) {
+		pr_warn(DRV_NAME "workqueue creation failed\n");
+		return -1;
+	}
+
 	return pci_register_driver(&be_driver);
 }
 module_init(be_init_module);
@@ -5803,5 +5952,8 @@ module_init(be_init_module);
 static void __exit be_exit_module(void)
 {
 	pci_unregister_driver(&be_driver);
+
+	if (be_wq)
+		destroy_workqueue(be_wq);
 }
 module_exit(be_exit_module);
-- 
2.4.1
