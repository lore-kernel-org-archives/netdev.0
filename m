From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6] be2net: changes for BE3 native mode support
Date: Fri, 11 Mar 2011 18:19:26 +0530
Message-ID: <9260707d-e902-4497-a550-a5125c46e2c4@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:16706 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753646Ab1CKMu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 07:50:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 So far be2net has been using BE3 in legacy mode. It now checks for native
 mode capability and if available it sets it. In native mode, the RX_COMPL
 structure is different from that in legacy mode.


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be.h      |   23 ++++-
 drivers/net/benet/be_cmds.c |   39 ++++++
 drivers/net/benet/be_cmds.h |   20 +++
 drivers/net/benet/be_hw.h   |   41 ++++++-
 drivers/net/benet/be_main.c |  279 ++++++++++++++++++++----------------------
 5 files changed, 252 insertions(+), 150 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 4ac0d72..62af707 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -67,7 +67,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 }
 
 /* Number of bytes of an RX frame that are copied to skb->data */
-#define BE_HDR_LEN 		64
+#define BE_HDR_LEN		((u16) 64)
 #define BE_MAX_JUMBO_FRAME_SIZE	9018
 #define BE_MIN_MTU		256
 
@@ -211,10 +211,30 @@ struct be_rx_stats {
 	u32 rx_fps;		/* Rx frags per second */
 };
 
+struct be_rx_compl_info {
+	u32 rss_hash;
+	u16 vid;
+	u16 pkt_size;
+	u16 rxq_idx;
+	u16 mac_id;
+	u8 vlanf;
+	u8 num_rcvd;
+	u8 err;
+	u8 ipf;
+	u8 tcpf;
+	u8 udpf;
+	u8 ip_csum;
+	u8 l4_csum;
+	u8 ipv6;
+	u8 vtm;
+	u8 pkt_type;
+};
+
 struct be_rx_obj {
 	struct be_adapter *adapter;
 	struct be_queue_info q;
 	struct be_queue_info cq;
+	struct be_rx_compl_info rxcp;
 	struct be_rx_page_info page_info_tbl[RX_Q_LEN];
 	struct be_eq_obj rx_eq;
 	struct be_rx_stats stats;
@@ -312,6 +332,7 @@ struct be_adapter {
 	u32 flash_status;
 	struct completion flash_compl;
 
+	bool be3_native;
 	bool sriov_enabled;
 	struct be_vf_cfg vf_cfg[BE_MAX_VF];
 	u8 is_virtfn;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index cc3a235..e1124c8 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -2014,3 +2014,42 @@ err:
 					attribs_cmd.dma);
 	return status;
 }
+
+/* Uses mbox */
+int be_cmd_check_native_mode(struct be_adapter *adapter)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_set_func_cap *req;
+	int status;
+
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+
+	wrb = wrb_from_mbox(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+		OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP, sizeof(*req));
+
+	req->valid_cap_flags = cpu_to_le32(CAPABILITY_SW_TIMESTAMPS |
+				CAPABILITY_BE3_NATIVE_ERX_API);
+	req->cap_flags = cpu_to_le32(CAPABILITY_BE3_NATIVE_ERX_API);
+
+	status = be_mbox_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_set_func_cap *resp = embedded_payload(wrb);
+		adapter->be3_native = le32_to_cpu(resp->cap_flags) &
+					CAPABILITY_BE3_NATIVE_ERX_API;
+	}
+err:
+	mutex_unlock(&adapter->mbox_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index b4ac393..e41fcba 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -190,6 +190,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_BEACON_STATE			70
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
+#define OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP		103
 #define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
 
 #define OPCODE_ETH_RSS_CONFIG				1
@@ -1042,6 +1043,24 @@ struct be_cmd_resp_cntl_attribs {
 	struct mgmt_controller_attrib attribs;
 };
 
+/*********************** Set driver function ***********************/
+#define CAPABILITY_SW_TIMESTAMPS	2
+#define CAPABILITY_BE3_NATIVE_ERX_API	4
+
+struct be_cmd_req_set_func_cap {
+	struct be_cmd_req_hdr hdr;
+	u32 valid_cap_flags;
+	u32 cap_flags;
+	u8 rsvd[212];
+};
+
+struct be_cmd_resp_set_func_cap {
+	struct be_cmd_resp_hdr hdr;
+	u32 valid_cap_flags;
+	u32 cap_flags;
+	u8 rsvd[212];
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -1128,4 +1147,5 @@ extern int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain);
 extern void be_detect_dump_ue(struct be_adapter *adapter);
 extern int be_cmd_get_die_temperature(struct be_adapter *adapter);
 extern int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
+extern int be_cmd_check_native_mode(struct be_adapter *adapter);
 
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index dbe67f3..e06aa15 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -301,10 +301,10 @@ struct be_eth_rx_d {
 
 /* RX Compl Queue Descriptor */
 
-/* Pseudo amap definition for eth_rx_compl in which each bit of the
- * actual structure is defined as a byte: used to calculate
+/* Pseudo amap definition for BE2 and BE3 legacy mode eth_rx_compl in which
+ * each bit of the actual structure is defined as a byte: used to calculate
  * offset/shift/mask of each field */
-struct amap_eth_rx_compl {
+struct amap_eth_rx_compl_v0 {
 	u8 vlan_tag[16];	/* dword 0 */
 	u8 pktsize[14];		/* dword 0 */
 	u8 port;		/* dword 0 */
@@ -335,6 +335,41 @@ struct amap_eth_rx_compl {
 	u8 rsshash[32];		/* dword 3 */
 } __packed;
 
+/* Pseudo amap definition for BE3 native mode eth_rx_compl in which
+ * each bit of the actual structure is defined as a byte: used to calculate
+ * offset/shift/mask of each field */
+struct amap_eth_rx_compl_v1 {
+	u8 vlan_tag[16];	/* dword 0 */
+	u8 pktsize[14];		/* dword 0 */
+	u8 vtp;			/* dword 0 */
+	u8 ip_opt;		/* dword 0 */
+	u8 err;			/* dword 1 */
+	u8 rsshp;		/* dword 1 */
+	u8 ipf;			/* dword 1 */
+	u8 tcpf;		/* dword 1 */
+	u8 udpf;		/* dword 1 */
+	u8 ipcksm;		/* dword 1 */
+	u8 l4_cksm;		/* dword 1 */
+	u8 ip_version;		/* dword 1 */
+	u8 macdst[7];		/* dword 1 */
+	u8 rsvd0;		/* dword 1 */
+	u8 fragndx[10];		/* dword 1 */
+	u8 ct[2];		/* dword 1 */
+	u8 sw;			/* dword 1 */
+	u8 numfrags[3];		/* dword 1 */
+	u8 rss_flush;		/* dword 2 */
+	u8 cast_enc[2];		/* dword 2 */
+	u8 vtm;			/* dword 2 */
+	u8 rss_bank;		/* dword 2 */
+	u8 port[2];		/* dword 2 */
+	u8 vntagp;		/* dword 2 */
+	u8 header_len[8];	/* dword 2 */
+	u8 header_split[2];	/* dword 2 */
+	u8 rsvd1[13];		/* dword 2 */
+	u8 valid;		/* dword 2 */
+	u8 rsshash[32];		/* dword 3 */
+} __packed;
+
 struct be_eth_rx_compl {
 	u32 dw[4];
 };
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 68f1078..3cb5f4e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -25,9 +25,9 @@ MODULE_DESCRIPTION(DRV_DESC " " DRV_VER);
 MODULE_AUTHOR("ServerEngines Corporation");
 MODULE_LICENSE("GPL");
 
-static unsigned int rx_frag_size = 2048;
+static ushort rx_frag_size = 2048;
 static unsigned int num_vfs;
-module_param(rx_frag_size, uint, S_IRUGO);
+module_param(rx_frag_size, ushort, S_IRUGO);
 module_param(num_vfs, uint, S_IRUGO);
 MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 MODULE_PARM_DESC(num_vfs, "Number of PCI VFs to initialize");
@@ -851,31 +851,26 @@ static void be_rx_rate_update(struct be_rx_obj *rxo)
 }
 
 static void be_rx_stats_update(struct be_rx_obj *rxo,
-		u32 pktsize, u16 numfrags, u8 pkt_type)
+		struct be_rx_compl_info *rxcp)
 {
 	struct be_rx_stats *stats = &rxo->stats;
 
 	stats->rx_compl++;
-	stats->rx_frags += numfrags;
-	stats->rx_bytes += pktsize;
+	stats->rx_frags += rxcp->num_rcvd;
+	stats->rx_bytes += rxcp->pkt_size;
 	stats->rx_pkts++;
-	if (pkt_type == BE_MULTICAST_PACKET)
+	if (rxcp->pkt_type == BE_MULTICAST_PACKET)
 		stats->rx_mcast_pkts++;
+	if (rxcp->err)
+		stats->rxcp_err++;
 }
 
-static inline bool csum_passed(struct be_eth_rx_compl *rxcp)
+static inline bool csum_passed(struct be_rx_compl_info *rxcp)
 {
-	u8 l4_cksm, ipv6, ipcksm, tcpf, udpf;
-
-	l4_cksm = AMAP_GET_BITS(struct amap_eth_rx_compl, l4_cksm, rxcp);
-	ipcksm = AMAP_GET_BITS(struct amap_eth_rx_compl, ipcksm, rxcp);
-	ipv6 = AMAP_GET_BITS(struct amap_eth_rx_compl, ip_version, rxcp);
-	tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl, tcpf, rxcp);
-	udpf = AMAP_GET_BITS(struct amap_eth_rx_compl, udpf, rxcp);
-
 	/* L4 checksum is not reliable for non TCP/UDP packets.
 	 * Also ignore ipcksm for ipv6 pkts */
-	return (tcpf || udpf) && l4_cksm && (ipcksm || ipv6);
+	return (rxcp->tcpf || rxcp->udpf) && rxcp->l4_csum &&
+				(rxcp->ip_csum || rxcp->ipv6);
 }
 
 static struct be_rx_page_info *
@@ -903,20 +898,17 @@ get_rx_page_info(struct be_adapter *adapter,
 /* Throwaway the data in the Rx completion */
 static void be_rx_compl_discard(struct be_adapter *adapter,
 		struct be_rx_obj *rxo,
-		struct be_eth_rx_compl *rxcp)
+		struct be_rx_compl_info *rxcp)
 {
 	struct be_queue_info *rxq = &rxo->q;
 	struct be_rx_page_info *page_info;
-	u16 rxq_idx, i, num_rcvd;
-
-	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
-	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
+	u16 i, num_rcvd = rxcp->num_rcvd;
 
 	for (i = 0; i < num_rcvd; i++) {
-		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
+		page_info = get_rx_page_info(adapter, rxo, rxcp->rxq_idx);
 		put_page(page_info->page);
 		memset(page_info, 0, sizeof(*page_info));
-		index_inc(&rxq_idx, rxq->len);
+		index_inc(&rxcp->rxq_idx, rxq->len);
 	}
 }
 
@@ -925,30 +917,23 @@ static void be_rx_compl_discard(struct be_adapter *adapter,
  * indicated by rxcp.
  */
 static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
-			struct sk_buff *skb, struct be_eth_rx_compl *rxcp,
-			u16 num_rcvd)
+			struct sk_buff *skb, struct be_rx_compl_info *rxcp)
 {
 	struct be_queue_info *rxq = &rxo->q;
 	struct be_rx_page_info *page_info;
-	u16 rxq_idx, i, j;
-	u32 pktsize, hdr_len, curr_frag_len, size;
+	u16 i, j;
+	u16 hdr_len, curr_frag_len, remaining;
 	u8 *start;
-	u8 pkt_type;
-
-	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
-	pktsize = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
-	pkt_type = AMAP_GET_BITS(struct amap_eth_rx_compl, cast_enc, rxcp);
-
-	page_info = get_rx_page_info(adapter, rxo, rxq_idx);
 
+	page_info = get_rx_page_info(adapter, rxo, rxcp->rxq_idx);
 	start = page_address(page_info->page) + page_info->page_offset;
 	prefetch(start);
 
 	/* Copy data in the first descriptor of this completion */
-	curr_frag_len = min(pktsize, rx_frag_size);
+	curr_frag_len = min(rxcp->pkt_size, rx_frag_size);
 
 	/* Copy the header portion into skb_data */
-	hdr_len = min((u32)BE_HDR_LEN, curr_frag_len);
+	hdr_len = min(BE_HDR_LEN, curr_frag_len);
 	memcpy(skb->data, start, hdr_len);
 	skb->len = curr_frag_len;
 	if (curr_frag_len <= BE_HDR_LEN) { /* tiny packet */
@@ -967,19 +952,17 @@ static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 	}
 	page_info->page = NULL;
 
-	if (pktsize <= rx_frag_size) {
-		BUG_ON(num_rcvd != 1);
-		goto done;
+	if (rxcp->pkt_size <= rx_frag_size) {
+		BUG_ON(rxcp->num_rcvd != 1);
+		return;
 	}
 
 	/* More frags present for this completion */
-	size = pktsize;
-	for (i = 1, j = 0; i < num_rcvd; i++) {
-		size -= curr_frag_len;
-		index_inc(&rxq_idx, rxq->len);
-		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
-
-		curr_frag_len = min(size, rx_frag_size);
+	index_inc(&rxcp->rxq_idx, rxq->len);
+	remaining = rxcp->pkt_size - curr_frag_len;
+	for (i = 1, j = 0; i < rxcp->num_rcvd; i++) {
+		page_info = get_rx_page_info(adapter, rxo, rxcp->rxq_idx);
+		curr_frag_len = min(remaining, rx_frag_size);
 
 		/* Coalesce all frags from the same physical page in one slot */
 		if (page_info->page_offset == 0) {
@@ -998,25 +981,19 @@ static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 		skb->len += curr_frag_len;
 		skb->data_len += curr_frag_len;
 
+		remaining -= curr_frag_len;
+		index_inc(&rxcp->rxq_idx, rxq->len);
 		page_info->page = NULL;
 	}
 	BUG_ON(j > MAX_SKB_FRAGS);
-
-done:
-	be_rx_stats_update(rxo, pktsize, num_rcvd, pkt_type);
 }
 
 /* Process the RX completion indicated by rxcp when GRO is disabled */
 static void be_rx_compl_process(struct be_adapter *adapter,
 			struct be_rx_obj *rxo,
-			struct be_eth_rx_compl *rxcp)
+			struct be_rx_compl_info *rxcp)
 {
 	struct sk_buff *skb;
-	u32 vlanf, vid;
-	u16 num_rcvd;
-	u8 vtm;
-
-	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 
 	skb = netdev_alloc_skb_ip_align(adapter->netdev, BE_HDR_LEN);
 	if (unlikely(!skb)) {
@@ -1026,7 +1003,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 		return;
 	}
 
-	skb_fill_rx_data(adapter, rxo, skb, rxcp, num_rcvd);
+	skb_fill_rx_data(adapter, rxo, skb, rxcp);
 
 	if (likely(adapter->rx_csum && csum_passed(rxcp)))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -1036,26 +1013,12 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
 
-	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
-	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
-
-	/* vlanf could be wrongly set in some cards.
-	 * ignore if vtm is not set */
-	if ((adapter->function_mode & 0x400) && !vtm)
-		vlanf = 0;
-
-	if ((adapter->pvid == vlanf) && !adapter->vlan_tag[vlanf])
-		vlanf = 0;
-
-	if (unlikely(vlanf)) {
+	if (unlikely(rxcp->vlanf)) {
 		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
 			kfree_skb(skb);
 			return;
 		}
-		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
-		if (!lancer_chip(adapter))
-			vid = swab16(vid);
-		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, vid);
+		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, rxcp->vid);
 	} else {
 		netif_receive_skb(skb);
 	}
@@ -1064,31 +1027,14 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 /* Process the RX completion indicated by rxcp when GRO is enabled */
 static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		struct be_rx_obj *rxo,
-		struct be_eth_rx_compl *rxcp)
+		struct be_rx_compl_info *rxcp)
 {
 	struct be_rx_page_info *page_info;
 	struct sk_buff *skb = NULL;
 	struct be_queue_info *rxq = &rxo->q;
 	struct be_eq_obj *eq_obj =  &rxo->rx_eq;
-	u32 num_rcvd, pkt_size, remaining, vlanf, curr_frag_len;
-	u16 i, rxq_idx = 0, vid, j;
-	u8 vtm;
-	u8 pkt_type;
-
-	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
-	pkt_size = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
-	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
-	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
-	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
-	pkt_type = AMAP_GET_BITS(struct amap_eth_rx_compl, cast_enc, rxcp);
-
-	/* vlanf could be wrongly set in some cards.
-	 * ignore if vtm is not set */
-	if ((adapter->function_mode & 0x400) && !vtm)
-		vlanf = 0;
-
-	if ((adapter->pvid == vlanf) && !adapter->vlan_tag[vlanf])
-		vlanf = 0;
+	u16 remaining, curr_frag_len;
+	u16 i, j;
 
 	skb = napi_get_frags(&eq_obj->napi);
 	if (!skb) {
@@ -1096,9 +1042,9 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		return;
 	}
 
-	remaining = pkt_size;
-	for (i = 0, j = -1; i < num_rcvd; i++) {
-		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
+	remaining = rxcp->pkt_size;
+	for (i = 0, j = -1; i < rxcp->num_rcvd; i++) {
+		page_info = get_rx_page_info(adapter, rxo, rxcp->rxq_idx);
 
 		curr_frag_len = min(remaining, rx_frag_size);
 
@@ -1116,56 +1062,109 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		skb_shinfo(skb)->frags[j].size += curr_frag_len;
 
 		remaining -= curr_frag_len;
-		index_inc(&rxq_idx, rxq->len);
+		index_inc(&rxcp->rxq_idx, rxq->len);
 		memset(page_info, 0, sizeof(*page_info));
 	}
 	BUG_ON(j > MAX_SKB_FRAGS);
 
 	skb_shinfo(skb)->nr_frags = j + 1;
-	skb->len = pkt_size;
-	skb->data_len = pkt_size;
-	skb->truesize += pkt_size;
+	skb->len = rxcp->pkt_size;
+	skb->data_len = rxcp->pkt_size;
+	skb->truesize += rxcp->pkt_size;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	if (likely(!vlanf)) {
+	if (likely(!rxcp->vlanf))
 		napi_gro_frags(&eq_obj->napi);
-	} else {
-		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
-		if (!lancer_chip(adapter))
-			vid = swab16(vid);
+	else
+		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp, rxcp->vid);
+}
+
+static void be_parse_rx_compl_v1(struct be_adapter *adapter,
+				struct be_eth_rx_compl *compl,
+				struct be_rx_compl_info *rxcp)
+{
+	rxcp->pkt_size =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, pktsize, compl);
+	rxcp->vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vtp, compl);
+	rxcp->err = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, err, compl);
+	rxcp->tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, tcpf, compl);
+	rxcp->ip_csum =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, ipcksm, compl);
+	rxcp->l4_csum =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, l4_cksm, compl);
+	rxcp->ipv6 =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, ip_version, compl);
+	rxcp->rxq_idx =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, fragndx, compl);
+	rxcp->num_rcvd =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, numfrags, compl);
+	rxcp->pkt_type =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, cast_enc, compl);
+	rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vtm, compl);
+	rxcp->vid = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vlan_tag, compl);
+}
+
+static void be_parse_rx_compl_v0(struct be_adapter *adapter,
+				struct be_eth_rx_compl *compl,
+				struct be_rx_compl_info *rxcp)
+{
+	rxcp->pkt_size =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, pktsize, compl);
+	rxcp->vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vtp, compl);
+	rxcp->err = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, err, compl);
+	rxcp->tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, tcpf, compl);
+	rxcp->ip_csum =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, ipcksm, compl);
+	rxcp->l4_csum =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, l4_cksm, compl);
+	rxcp->ipv6 =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, ip_version, compl);
+	rxcp->rxq_idx =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, fragndx, compl);
+	rxcp->num_rcvd =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, numfrags, compl);
+	rxcp->pkt_type =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, cast_enc, compl);
+	rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vtm, compl);
+	rxcp->vid = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vlan_tag, compl);
+}
+
+static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
+{
+	struct be_eth_rx_compl *compl = queue_tail_node(&rxo->cq);
+	struct be_rx_compl_info *rxcp = &rxo->rxcp;
+	struct be_adapter *adapter = rxo->adapter;
 
-		if (!adapter->vlan_grp || adapter->vlans_added == 0)
-			return;
+	/* For checking the valid bit it is Ok to use either definition as the
+	 * valid bit is at the same position in both v0 and v1 Rx compl */
+	if (compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) / 32] == 0)
+		return NULL;
 
-		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp, vid);
-	}
+	rmb();
+	be_dws_le_to_cpu(compl, sizeof(*compl));
 
-	be_rx_stats_update(rxo, pkt_size, num_rcvd, pkt_type);
-}
+	if (adapter->be3_native)
+		be_parse_rx_compl_v1(adapter, compl, rxcp);
+	else
+		be_parse_rx_compl_v0(adapter, compl, rxcp);
 
-static struct be_eth_rx_compl *be_rx_compl_get(struct be_rx_obj *rxo)
-{
-	struct be_eth_rx_compl *rxcp = queue_tail_node(&rxo->cq);
+	/* vlanf could be wrongly set in some cards. ignore if vtm is not set */
+	if ((adapter->function_mode & 0x400) && !rxcp->vtm)
+		rxcp->vlanf = 0;
 
-	if (rxcp->dw[offsetof(struct amap_eth_rx_compl, valid) / 32] == 0)
-		return NULL;
+	if (!lancer_chip(adapter))
+		rxcp->vid = swab16(rxcp->vid);
 
-	rmb();
-	be_dws_le_to_cpu(rxcp, sizeof(*rxcp));
+	if ((adapter->pvid == rxcp->vid) && !adapter->vlan_tag[rxcp->vid])
+		rxcp->vlanf = 0;
+
+	/* As the compl has been parsed, reset it; we wont touch it again */
+	compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) / 32] = 0;
 
 	queue_tail_inc(&rxo->cq);
 	return rxcp;
 }
 
-/* To reset the valid bit, we need to reset the whole word as
- * when walking the queue the valid entries are little-endian
- * and invalid entries are host endian
- */
-static inline void be_rx_compl_reset(struct be_eth_rx_compl *rxcp)
-{
-	rxcp->dw[offsetof(struct amap_eth_rx_compl, valid) / 32] = 0;
-}
-
 static inline struct page *be_alloc_pages(u32 size, gfp_t gfp)
 {
 	u32 order = get_order(size);
@@ -1342,13 +1341,12 @@ static void be_rx_q_clean(struct be_adapter *adapter, struct be_rx_obj *rxo)
 	struct be_rx_page_info *page_info;
 	struct be_queue_info *rxq = &rxo->q;
 	struct be_queue_info *rx_cq = &rxo->cq;
-	struct be_eth_rx_compl *rxcp;
+	struct be_rx_compl_info *rxcp;
 	u16 tail;
 
 	/* First cleanup pending rx completions */
 	while ((rxcp = be_rx_compl_get(rxo)) != NULL) {
 		be_rx_compl_discard(adapter, rxo, rxcp);
-		be_rx_compl_reset(rxcp);
 		be_cq_notify(adapter, rx_cq->id, false, 1);
 	}
 
@@ -1697,15 +1695,9 @@ static irqreturn_t be_msix_tx_mcc(int irq, void *dev)
 	return IRQ_HANDLED;
 }
 
-static inline bool do_gro(struct be_rx_obj *rxo,
-			struct be_eth_rx_compl *rxcp, u8 err)
+static inline bool do_gro(struct be_rx_compl_info *rxcp)
 {
-	int tcp_frame = AMAP_GET_BITS(struct amap_eth_rx_compl, tcpf, rxcp);
-
-	if (err)
-		rxo->stats.rxcp_err++;
-
-	return (tcp_frame && !err) ? true : false;
+	return (rxcp->tcpf && !rxcp->err) ? true : false;
 }
 
 static int be_poll_rx(struct napi_struct *napi, int budget)
@@ -1714,10 +1706,8 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 	struct be_rx_obj *rxo = container_of(rx_eq, struct be_rx_obj, rx_eq);
 	struct be_adapter *adapter = rxo->adapter;
 	struct be_queue_info *rx_cq = &rxo->cq;
-	struct be_eth_rx_compl *rxcp;
+	struct be_rx_compl_info *rxcp;
 	u32 work_done;
-	u16 num_rcvd;
-	u8 err;
 
 	rxo->stats.rx_polls++;
 	for (work_done = 0; work_done < budget; work_done++) {
@@ -1725,18 +1715,14 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 		if (!rxcp)
 			break;
 
-		err = AMAP_GET_BITS(struct amap_eth_rx_compl, err, rxcp);
-		num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags,
-								rxcp);
 		/* Ignore flush completions */
-		if (num_rcvd) {
-			if (do_gro(rxo, rxcp, err))
+		if (rxcp->num_rcvd) {
+			if (do_gro(rxcp))
 				be_rx_compl_process_gro(adapter, rxo, rxcp);
 			else
 				be_rx_compl_process(adapter, rxo, rxcp);
 		}
-
-		be_rx_compl_reset(rxcp);
+		be_rx_stats_update(rxo, rxcp);
 	}
 
 	/* Refill the queue */
@@ -2868,6 +2854,7 @@ static int be_get_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 
+	be_cmd_check_native_mode(adapter);
 	return 0;
 }
 
-- 
1.6.5.2

