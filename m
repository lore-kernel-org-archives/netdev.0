From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 2/3] be2net: fix a Tx stall bug caused by a specific ipv6
 packet
Date: Wed, 24 Apr 2013 16:52:50 -0500
Message-ID: <20130424215250.GA5812@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:57826 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757864Ab3DXVwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 17:52:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ASIC could lockup in the transmit path when it tries
to insert VLAN in a specific ipv6 packet.
1) Identify the packet which can cause this.
2) Check if the firmware provides a workaround to prevent this.
3) If workaround is not present, drop the packet.
4) If the firmware provides a workaround, insert the VLAN tag in the
packet and inform the firmware to skip further VLAN insertions.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    7 ++
 drivers/net/ethernet/emulex/benet/be_cmds.c |   32 +++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |   13 ++++
 drivers/net/ethernet/emulex/benet/be_main.c |   99 +++++++++++++++++++++++++--
 4 files changed, 144 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 29aff55..941aa1f 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -328,6 +328,7 @@ enum vf_state {
 #define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
 #define BE_UC_PMAC_COUNT		30
 #define BE_VF_UC_PMAC_COUNT		2
+#define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
 
 struct phy_info {
 	u8 transceiver;
@@ -434,6 +435,7 @@ struct be_adapter {
 	u8 wol_cap;
 	bool wol;
 	u32 uc_macs;		/* Count of secondary UC MAC programmed */
+	u16 qnq_vid;
 	u32 msg_enable;
 	int be_get_temp_freq;
 	u16 max_mcast_mac;
@@ -648,6 +650,11 @@ static inline bool be_is_wol_excluded(struct be_adapter *adapter)
 	}
 }
 
+static inline int qnq_async_evt_rcvd(struct be_adapter *adapter)
+{
+	return adapter->flags & BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
+}
+
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, u8 link_status);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 3c9b4f1..ce5af9b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -263,6 +263,27 @@ static void be_async_grp5_evt_process(struct be_adapter *adapter,
 	}
 }
 
+static void be_async_dbg_evt_process(struct be_adapter *adapter,
+		u32 trailer, struct be_mcc_compl *cmp)
+{
+	u8 event_type = 0;
+	struct be_async_event_qnq *evt = (struct be_async_event_qnq *) cmp;
+
+	event_type = (trailer >> ASYNC_TRAILER_EVENT_TYPE_SHIFT) &
+		ASYNC_TRAILER_EVENT_TYPE_MASK;
+
+	switch (event_type) {
+	case ASYNC_DEBUG_EVENT_TYPE_QNQ:
+		if (evt->valid)
+			adapter->qnq_vid = le16_to_cpu(evt->vlan_tag);
+		adapter->flags |= BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
+	break;
+	default:
+		dev_warn(&adapter->pdev->dev, "Unknown debug event\n");
+	break;
+	}
+}
+
 static inline bool is_link_state_evt(u32 trailer)
 {
 	return ((trailer >> ASYNC_TRAILER_EVENT_CODE_SHIFT) &
@@ -277,6 +298,13 @@ static inline bool is_grp5_evt(u32 trailer)
 				ASYNC_EVENT_CODE_GRP_5);
 }
 
+static inline bool is_dbg_evt(u32 trailer)
+{
+	return (((trailer >> ASYNC_TRAILER_EVENT_CODE_SHIFT) &
+		ASYNC_TRAILER_EVENT_CODE_MASK) ==
+				ASYNC_EVENT_CODE_QNQ);
+}
+
 static struct be_mcc_compl *be_mcc_compl_get(struct be_adapter *adapter)
 {
 	struct be_queue_info *mcc_cq = &adapter->mcc_obj.cq;
@@ -325,6 +353,9 @@ int be_process_mcc(struct be_adapter *adapter)
 			else if (is_grp5_evt(compl->flags))
 				be_async_grp5_evt_process(adapter,
 				compl->flags, compl);
+			else if (is_dbg_evt(compl->flags))
+				be_async_dbg_evt_process(adapter,
+				compl->flags, compl);
 		} else if (compl->flags & CQE_FLAGS_COMPLETED_MASK) {
 				status = be_mcc_compl_process(adapter, compl);
 				atomic_dec(&mcc_obj->q.used);
@@ -1022,6 +1053,7 @@ int be_cmd_mccq_ext_create(struct be_adapter *adapter,
 
 	/* Subscribe to Link State and Group 5 Events(bits 1 and 5 set) */
 	req->async_event_bitmap[0] = cpu_to_le32(0x00000022);
+	req->async_event_bitmap[0] |= cpu_to_le32(1 << ASYNC_EVENT_CODE_QNQ);
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 9697086..07fd927 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -84,6 +84,9 @@ struct be_mcc_compl {
 #define ASYNC_EVENT_QOS_SPEED		0x1
 #define ASYNC_EVENT_COS_PRIORITY	0x2
 #define ASYNC_EVENT_PVID_STATE		0x3
+#define ASYNC_EVENT_CODE_QNQ		0x6
+#define ASYNC_DEBUG_EVENT_TYPE_QNQ	1
+
 struct be_async_event_trailer {
 	u32 code;
 };
@@ -144,6 +147,16 @@ struct be_async_event_grp5_pvid_state {
 	struct be_async_event_trailer trailer;
 } __packed;
 
+/* async event indicating outer VLAN tag in QnQ */
+struct be_async_event_qnq {
+	u8 valid;	/* Indicates if outer VLAN is valid */
+	u8 rsvd0;
+	u16 vlan_tag;
+	u32 event_tag;
+	u8 rsvd1[4];
+	struct be_async_event_trailer trailer;
+} __packed;
+
 struct be_mcc_mailbox {
 	struct be_mcc_wrb wrb;
 	struct be_mcc_compl compl;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a254942..21109b5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -627,7 +627,7 @@ static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
 }
 
 static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
-		struct sk_buff *skb, u32 wrb_cnt, u32 len)
+		struct sk_buff *skb, u32 wrb_cnt, u32 len, bool skip_hw_vlan)
 {
 	u16 vlan_tag;
 
@@ -654,8 +654,9 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan_tag, hdr, vlan_tag);
 	}
 
+	/* To skip HW VLAN tagging: evt = 1, compl = 0 */
+	AMAP_SET_BITS(struct amap_eth_hdr_wrb, complete, hdr, !skip_hw_vlan);
 	AMAP_SET_BITS(struct amap_eth_hdr_wrb, event, hdr, 1);
-	AMAP_SET_BITS(struct amap_eth_hdr_wrb, complete, hdr, 1);
 	AMAP_SET_BITS(struct amap_eth_hdr_wrb, num_wrb, hdr, wrb_cnt);
 	AMAP_SET_BITS(struct amap_eth_hdr_wrb, len, hdr, len);
 }
@@ -678,7 +679,8 @@ static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
 }
 
 static int make_tx_wrbs(struct be_adapter *adapter, struct be_queue_info *txq,
-		struct sk_buff *skb, u32 wrb_cnt, bool dummy_wrb)
+		struct sk_buff *skb, u32 wrb_cnt, bool dummy_wrb,
+		bool skip_hw_vlan)
 {
 	dma_addr_t busaddr;
 	int i, copied = 0;
@@ -727,7 +729,7 @@ static int make_tx_wrbs(struct be_adapter *adapter, struct be_queue_info *txq,
 		queue_head_inc(txq);
 	}
 
-	wrb_fill_hdr(adapter, hdr, first_skb, wrb_cnt, copied);
+	wrb_fill_hdr(adapter, hdr, first_skb, wrb_cnt, copied, skip_hw_vlan);
 	be_dws_cpu_to_le(hdr, sizeof(*hdr));
 
 	return copied;
@@ -744,7 +746,8 @@ dma_err:
 }
 
 static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
-					     struct sk_buff *skb)
+					     struct sk_buff *skb,
+					     bool *skip_hw_vlan)
 {
 	u16 vlan_tag = 0;
 
@@ -759,9 +762,67 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 			skb->vlan_tci = 0;
 	}
 
+	if (qnq_async_evt_rcvd(adapter) && adapter->pvid) {
+		if (!vlan_tag)
+			vlan_tag = adapter->pvid;
+		if (skip_hw_vlan)
+			*skip_hw_vlan = true;
+	}
+
+	if (vlan_tag) {
+		skb = __vlan_put_tag(skb, vlan_tag);
+		if (unlikely(!skb))
+			return skb;
+
+		skb->vlan_tci = 0;
+	}
+
+	/* Insert the outer VLAN, if any */
+	if (adapter->qnq_vid) {
+		vlan_tag = adapter->qnq_vid;
+		skb = __vlan_put_tag(skb, vlan_tag);
+		if (unlikely(!skb))
+			return skb;
+		if (skip_hw_vlan)
+			*skip_hw_vlan = true;
+	}
+
 	return skb;
 }
 
+static bool be_ipv6_exthdr_check(struct sk_buff *skb)
+{
+	struct ethhdr *eh = (struct ethhdr *)skb->data;
+	u16 offset = ETH_HLEN;
+
+	if (eh->h_proto == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ip6h = (struct ipv6hdr *)(skb->data + offset);
+
+		offset += sizeof(struct ipv6hdr);
+		if (ip6h->nexthdr != NEXTHDR_TCP &&
+		    ip6h->nexthdr != NEXTHDR_UDP) {
+			struct ipv6_opt_hdr *ehdr =
+				(struct ipv6_opt_hdr *) (skb->data + offset);
+
+			/* offending pkt: 2nd byte following IPv6 hdr is 0xff */
+			if (ehdr->hdrlen == 0xff)
+				return true;
+		}
+	}
+	return false;
+}
+
+static int be_vlan_tag_tx_chk(struct be_adapter *adapter, struct sk_buff *skb)
+{
+	return vlan_tx_tag_present(skb) || adapter->pvid || adapter->qnq_vid;
+}
+
+static int be_ipv6_tx_stall_chk(struct be_adapter *adapter, struct sk_buff *skb)
+{
+	return BE3_chip(adapter) &&
+		be_ipv6_exthdr_check(skb);
+}
+
 static netdev_tx_t be_xmit(struct sk_buff *skb,
 			struct net_device *netdev)
 {
@@ -772,6 +833,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	u32 wrb_cnt = 0, copied = 0;
 	u32 start = txq->head, eth_hdr_len;
 	bool dummy_wrb, stopped = false;
+	bool skip_hw_vlan = false;
 
 	eth_hdr_len = ntohs(skb->protocol) == ETH_P_8021Q ?
 		VLAN_ETH_HLEN : ETH_HLEN;
@@ -790,14 +852,37 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	 */
 	if (skb->ip_summed != CHECKSUM_PARTIAL &&
 			vlan_tx_tag_present(skb)) {
-		skb = be_insert_vlan_in_pkt(adapter, skb);
+		skb = be_insert_vlan_in_pkt(adapter, skb, &skip_hw_vlan);
+		if (unlikely(!skb))
+			goto tx_drop;
+	}
+
+	/* HW may lockup when VLAN HW tagging is requested on
+	 * certain ipv6 packets. Drop such pkts if the HW workaround to
+	 * skip HW tagging is not enabled by FW.
+	 */
+	if (unlikely(be_ipv6_tx_stall_chk(adapter, skb) &&
+		     (adapter->pvid || adapter->qnq_vid) &&
+		     !qnq_async_evt_rcvd(adapter)))
+		goto tx_drop;
+
+	/* Manual VLAN tag insertion to prevent:
+	 * ASIC lockup when the ASIC inserts VLAN tag into
+	 * certain ipv6 packets. Insert VLAN tags in driver,
+	 * and set event, completion, vlan bits accordingly
+	 * in the Tx WRB.
+	 */
+	if (be_ipv6_tx_stall_chk(adapter, skb) &&
+	    be_vlan_tag_tx_chk(adapter, skb)) {
+		skb = be_insert_vlan_in_pkt(adapter, skb, &skip_hw_vlan);
 		if (unlikely(!skb))
 			goto tx_drop;
 	}
 
 	wrb_cnt = wrb_cnt_for_skb(adapter, skb, &dummy_wrb);
 
-	copied = make_tx_wrbs(adapter, txq, skb, wrb_cnt, dummy_wrb);
+	copied = make_tx_wrbs(adapter, txq, skb, wrb_cnt, dummy_wrb,
+			      skip_hw_vlan);
 	if (copied) {
 		int gso_segs = skb_shinfo(skb)->gso_segs;
 
-- 
1.7.1
