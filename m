From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/9] be2net: move un-exported routines from be.h to respective src files
Date: Fri, 6 Feb 2015 08:18:35 -0500
Message-ID: <1423228723-10919-2-git-send-email-sathya.perla@emulex.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:55307 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992AbbBFNPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:15:42 -0500
In-Reply-To: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Routines that are called only inside one src file must remain in that
file itself. Including them in a header file that is used for exporting
routine/struct definitions, causes unnecessary compilation of other
src files, when such a routine is modified.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 166 ----------------------------
 drivers/net/ethernet/emulex/benet/be_cmds.c |  18 +++
 drivers/net/ethernet/emulex/benet/be_main.c | 149 +++++++++++++++++++++++++
 3 files changed, 167 insertions(+), 166 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 9fa2569..3b1d59d 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -59,26 +59,6 @@
 #define OC_SUBSYS_DEVICE_ID3	0xE612
 #define OC_SUBSYS_DEVICE_ID4	0xE652
 
-static inline char *nic_name(struct pci_dev *pdev)
-{
-	switch (pdev->device) {
-	case OC_DEVICE_ID1:
-		return OC_NAME;
-	case OC_DEVICE_ID2:
-		return OC_NAME_BE;
-	case OC_DEVICE_ID3:
-	case OC_DEVICE_ID4:
-		return OC_NAME_LANCER;
-	case BE_DEVICE_ID2:
-		return BE3_NAME;
-	case OC_DEVICE_ID5:
-	case OC_DEVICE_ID6:
-		return OC_NAME_SH;
-	default:
-		return BE_NAME;
-	}
-}
-
 /* Number of bytes of an RX frame that are copied to skb->data */
 #define BE_HDR_LEN		((u16) 64)
 /* allocate extra space to allow tunneling decapsulation without head reallocation */
@@ -734,19 +714,6 @@ static inline bool is_ipv4_pkt(struct sk_buff *skb)
 	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
 }
 
-static inline void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
-{
-	u32 addr;
-
-	addr = jhash(adapter->netdev->dev_addr, ETH_ALEN, 0);
-
-	mac[5] = (u8)(addr & 0xFF);
-	mac[4] = (u8)((addr >> 8) & 0xFF);
-	mac[3] = (u8)((addr >> 16) & 0xFF);
-	/* Use the OUI from the current MAC address */
-	memcpy(mac, adapter->netdev->dev_addr, 3);
-}
-
 static inline bool be_multi_rxq(const struct be_adapter *adapter)
 {
 	return adapter->num_rx_qs > 1;
@@ -769,129 +736,6 @@ static inline void  be_clear_all_error(struct be_adapter *adapter)
 	adapter->fw_timeout = false;
 }
 
-static inline bool be_is_wol_excluded(struct be_adapter *adapter)
-{
-	struct pci_dev *pdev = adapter->pdev;
-
-	if (!be_physfn(adapter))
-		return true;
-
-	switch (pdev->subsystem_device) {
-	case OC_SUBSYS_DEVICE_ID1:
-	case OC_SUBSYS_DEVICE_ID2:
-	case OC_SUBSYS_DEVICE_ID3:
-	case OC_SUBSYS_DEVICE_ID4:
-		return true;
-	default:
-		return false;
-	}
-}
-
-static inline int qnq_async_evt_rcvd(struct be_adapter *adapter)
-{
-	return adapter->flags & BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
-}
-
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static inline bool be_lock_napi(struct be_eq_obj *eqo)
-{
-	bool status = true;
-
-	spin_lock(&eqo->lock); /* BH is already disabled */
-	if (eqo->state & BE_EQ_LOCKED) {
-		WARN_ON(eqo->state & BE_EQ_NAPI);
-		eqo->state |= BE_EQ_NAPI_YIELD;
-		status = false;
-	} else {
-		eqo->state = BE_EQ_NAPI;
-	}
-	spin_unlock(&eqo->lock);
-	return status;
-}
-
-static inline void be_unlock_napi(struct be_eq_obj *eqo)
-{
-	spin_lock(&eqo->lock); /* BH is already disabled */
-
-	WARN_ON(eqo->state & (BE_EQ_POLL | BE_EQ_NAPI_YIELD));
-	eqo->state = BE_EQ_IDLE;
-
-	spin_unlock(&eqo->lock);
-}
-
-static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
-{
-	bool status = true;
-
-	spin_lock_bh(&eqo->lock);
-	if (eqo->state & BE_EQ_LOCKED) {
-		eqo->state |= BE_EQ_POLL_YIELD;
-		status = false;
-	} else {
-		eqo->state |= BE_EQ_POLL;
-	}
-	spin_unlock_bh(&eqo->lock);
-	return status;
-}
-
-static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
-{
-	spin_lock_bh(&eqo->lock);
-
-	WARN_ON(eqo->state & (BE_EQ_NAPI));
-	eqo->state = BE_EQ_IDLE;
-
-	spin_unlock_bh(&eqo->lock);
-}
-
-static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
-{
-	spin_lock_init(&eqo->lock);
-	eqo->state = BE_EQ_IDLE;
-}
-
-static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
-{
-	local_bh_disable();
-
-	/* It's enough to just acquire napi lock on the eqo to stop
-	 * be_busy_poll() from processing any queueus.
-	 */
-	while (!be_lock_napi(eqo))
-		mdelay(1);
-
-	local_bh_enable();
-}
-
-#else /* CONFIG_NET_RX_BUSY_POLL */
-
-static inline bool be_lock_napi(struct be_eq_obj *eqo)
-{
-	return true;
-}
-
-static inline void be_unlock_napi(struct be_eq_obj *eqo)
-{
-}
-
-static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
-{
-	return false;
-}
-
-static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
-{
-}
-
-static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
-{
-}
-
-static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
-{
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		  u16 num_popped);
 void be_link_status_update(struct be_adapter *adapter, u8 link_status);
@@ -900,16 +744,6 @@ int be_load_fw(struct be_adapter *adapter, u8 *func);
 bool be_is_wol_supported(struct be_adapter *adapter);
 bool be_pause_supported(struct be_adapter *adapter);
 u32 be_get_fw_log_level(struct be_adapter *adapter);
-
-static inline int fw_major_num(const char *fw_ver)
-{
-	int fw_major = 0;
-
-	sscanf(fw_ver, "%d.", &fw_major);
-
-	return fw_major;
-}
-
 int be_update_queues(struct be_adapter *adapter);
 int be_poll(struct napi_struct *napi, int budget);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 4bd425e..3a10145 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3241,6 +3241,24 @@ err:
 	return status;
 }
 
+static bool be_is_wol_excluded(struct be_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	if (!be_physfn(adapter))
+		return true;
+
+	switch (pdev->subsystem_device) {
+	case OC_SUBSYS_DEVICE_ID1:
+	case OC_SUBSYS_DEVICE_ID2:
+	case OC_SUBSYS_DEVICE_ID3:
+	case OC_SUBSYS_DEVICE_ID4:
+		return true;
+	default:
+		return false;
+	}
+}
+
 int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter)
 {
 	struct be_mcc_wrb *wrb;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 598c507..4231a70 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -854,6 +854,11 @@ dma_err:
 	return 0;
 }
 
+static inline int qnq_async_evt_rcvd(struct be_adapter *adapter)
+{
+	return adapter->flags & BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
+}
+
 static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 					     struct sk_buff *skb,
 					     bool *skip_hw_vlan)
@@ -2526,6 +2531,106 @@ static void be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 	}
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static inline bool be_lock_napi(struct be_eq_obj *eqo)
+{
+	bool status = true;
+
+	spin_lock(&eqo->lock); /* BH is already disabled */
+	if (eqo->state & BE_EQ_LOCKED) {
+		WARN_ON(eqo->state & BE_EQ_NAPI);
+		eqo->state |= BE_EQ_NAPI_YIELD;
+		status = false;
+	} else {
+		eqo->state = BE_EQ_NAPI;
+	}
+	spin_unlock(&eqo->lock);
+	return status;
+}
+
+static inline void be_unlock_napi(struct be_eq_obj *eqo)
+{
+	spin_lock(&eqo->lock); /* BH is already disabled */
+
+	WARN_ON(eqo->state & (BE_EQ_POLL | BE_EQ_NAPI_YIELD));
+	eqo->state = BE_EQ_IDLE;
+
+	spin_unlock(&eqo->lock);
+}
+
+static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
+{
+	bool status = true;
+
+	spin_lock_bh(&eqo->lock);
+	if (eqo->state & BE_EQ_LOCKED) {
+		eqo->state |= BE_EQ_POLL_YIELD;
+		status = false;
+	} else {
+		eqo->state |= BE_EQ_POLL;
+	}
+	spin_unlock_bh(&eqo->lock);
+	return status;
+}
+
+static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
+{
+	spin_lock_bh(&eqo->lock);
+
+	WARN_ON(eqo->state & (BE_EQ_NAPI));
+	eqo->state = BE_EQ_IDLE;
+
+	spin_unlock_bh(&eqo->lock);
+}
+
+static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
+{
+	spin_lock_init(&eqo->lock);
+	eqo->state = BE_EQ_IDLE;
+}
+
+static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
+{
+	local_bh_disable();
+
+	/* It's enough to just acquire napi lock on the eqo to stop
+	 * be_busy_poll() from processing any queueus.
+	 */
+	while (!be_lock_napi(eqo))
+		mdelay(1);
+
+	local_bh_enable();
+}
+
+#else /* CONFIG_NET_RX_BUSY_POLL */
+
+static inline bool be_lock_napi(struct be_eq_obj *eqo)
+{
+	return true;
+}
+
+static inline void be_unlock_napi(struct be_eq_obj *eqo)
+{
+}
+
+static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
+{
+	return false;
+}
+
+static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
+{
+}
+
+static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
+{
+}
+
+static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
+{
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 int be_poll(struct napi_struct *napi, int budget)
 {
 	struct be_eq_obj *eqo = container_of(napi, struct be_eq_obj, napi);
@@ -3020,6 +3125,19 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 	return status;
 }
 
+static void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
+{
+	u32 addr;
+
+	addr = jhash(adapter->netdev->dev_addr, ETH_ALEN, 0);
+
+	mac[5] = (u8)(addr & 0xFF);
+	mac[4] = (u8)((addr >> 8) & 0xFF);
+	mac[3] = (u8)((addr >> 16) & 0xFF);
+	/* Use the OUI from the current MAC address */
+	memcpy(mac, adapter->netdev->dev_addr, 3);
+}
+
 /*
  * Generate a seed MAC address from the PF MAC Address using jhash.
  * MAC Address for VFs are assigned incrementally starting from the seed.
@@ -3664,6 +3782,17 @@ int be_update_queues(struct be_adapter *adapter)
 	return status;
 }
 
+static inline int fw_major_num(const char *fw_ver)
+{
+	int fw_major = 0, i;
+
+	i = sscanf(fw_ver, "%d.", &fw_major);
+	if (i != 1)
+		return 0;
+
+	return fw_major;
+}
+
 static int be_setup(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
@@ -4939,6 +5068,26 @@ static inline char *func_name(struct be_adapter *adapter)
 	return be_physfn(adapter) ? "PF" : "VF";
 }
 
+static inline char *nic_name(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	case OC_DEVICE_ID1:
+		return OC_NAME;
+	case OC_DEVICE_ID2:
+		return OC_NAME_BE;
+	case OC_DEVICE_ID3:
+	case OC_DEVICE_ID4:
+		return OC_NAME_LANCER;
+	case BE_DEVICE_ID2:
+		return BE3_NAME;
+	case OC_DEVICE_ID5:
+	case OC_DEVICE_ID6:
+		return OC_NAME_SH;
+	default:
+		return BE_NAME;
+	}
+}
+
 static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 {
 	int status = 0;
-- 
2.2.0
