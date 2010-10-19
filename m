From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Changes to use only priority codes
 allowed by f/w
Date: Tue, 19 Oct 2010 14:21:14 +0530
Message-ID: <20101019085114.GA352@emulex.com>
Reply-To: Somnath Kotur <somnath.kotur@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:49451 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755997Ab0JSQvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 12:51:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to use one of the priority codes allowed by CNA f/w for NIC traffic
from host. The driver gets the bit map of the priority codes allowed for
host traffic through a asynchronous message from the f/w that the driver
subscribes to.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be.h      |    2 +
 drivers/net/benet/be_cmds.c |   60 +++++++++++++++++++++++++++++++++++++++++-
 drivers/net/benet/be_cmds.h |   31 ++++++++++++++++++++++
 drivers/net/benet/be_main.c |   21 ++++++++++-----
 4 files changed, 105 insertions(+), 9 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 1afabb1..7ff66fb 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -264,6 +264,8 @@ struct be_adapter {
 	u16 vlans_added;
 	u16 max_vlans;	/* Number of vlans supported */
 	u8 vlan_tag[VLAN_GROUP_ARRAY_LEN];
+	u8 vlan_prio_bmap;	/* Available priority BitMap */
+	u16 recommended_prio;	/* Recommended Priority */
 	struct be_dma_mem mc_cmd_mem;
 
 	struct be_dma_mem stats_cmd;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index bf2dc26..b1728db 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -96,6 +96,50 @@ static void be_async_link_state_process(struct be_adapter *adapter,
 		evt->port_link_status == ASYNC_EVENT_LINK_UP);
 }
 
+/* Grp5 CoS Priority evt */
+static void be_async_grp5_cos_priority_process(struct be_adapter *adapter,
+		struct be_async_event_grp5_cos_priority *evt)
+{
+	if (evt->valid) {
+		adapter->vlan_prio_bmap = evt->available_priority_bmap;
+		adapter->recommended_prio =
+		evt->reco_default_priority << VLAN_PRIO_SHIFT;
+	}
+}
+
+/* Grp5 QOS Speed evt */
+static void be_async_grp5_qos_speed_process(struct be_adapter *adapter,
+		struct be_async_event_grp5_qos_link_speed *evt)
+{
+	if (evt->physical_port == adapter->port_num) {
+		/* qos_link_speed is in units of 10 Mbps */
+		adapter->link_speed = evt->qos_link_speed * 10;
+	}
+}
+
+static void be_async_grp5_evt_process(struct be_adapter *adapter,
+		u32 trailer, struct be_mcc_compl *evt)
+{
+	u8 event_type = 0;
+
+	event_type = (trailer >> ASYNC_TRAILER_EVENT_TYPE_SHIFT) &
+		ASYNC_TRAILER_EVENT_TYPE_MASK;
+
+	switch (event_type) {
+	case ASYNC_EVENT_COS_PRIORITY:
+		be_async_grp5_cos_priority_process(adapter,
+				(struct be_async_event_grp5_cos_priority *)evt);
+	break;
+	case ASYNC_EVENT_QOS_SPEED:
+		be_async_grp5_qos_speed_process(adapter,
+			(struct be_async_event_grp5_qos_link_speed *)evt);
+	break;
+	default:
+		dev_warn(&adapter->pdev->dev, "Unknown grp5 event!\n");
+	break;
+	}
+}
+
 static inline bool is_link_state_evt(u32 trailer)
 {
 	return ((trailer >> ASYNC_TRAILER_EVENT_CODE_SHIFT) &
@@ -103,6 +147,13 @@ static inline bool is_link_state_evt(u32 trailer)
 				ASYNC_EVENT_CODE_LINK_STATE;
 }
 
+static inline bool is_grp5_evt(u32 trailer)
+{
+	return (((trailer >> ASYNC_TRAILER_EVENT_CODE_SHIFT) &
+		ASYNC_TRAILER_EVENT_CODE_MASK) ==
+				ASYNC_EVENT_CODE_GRP_5);
+}
+
 static struct be_mcc_compl *be_mcc_compl_get(struct be_adapter *adapter)
 {
 	struct be_queue_info *mcc_cq = &adapter->mcc_obj.cq;
@@ -143,6 +194,9 @@ int be_process_mcc(struct be_adapter *adapter, int *status)
 			if (is_link_state_evt(compl->flags))
 				be_async_link_state_process(adapter,
 				(struct be_async_event_link_state *) compl);
+			else if (is_grp5_evt(compl->flags))
+				be_async_grp5_evt_process(adapter,
+				compl->flags, compl);
 		} else if (compl->flags & CQE_FLAGS_COMPLETED_MASK) {
 				*status = be_mcc_compl_process(adapter, compl);
 				atomic_dec(&mcc_obj->q.used);
@@ -677,10 +731,10 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 	ctxt = &req->context;
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_MCC_CREATE);
+			OPCODE_COMMON_MCC_CREATE_EXT);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			OPCODE_COMMON_MCC_CREATE, sizeof(*req));
+			OPCODE_COMMON_MCC_CREATE_EXT, sizeof(*req));
 
 	req->num_pages = cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 
@@ -688,6 +742,8 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 	AMAP_SET_BITS(struct amap_mcc_context, ring_size, ctxt,
 		be_encoded_q_len(mccq->len));
 	AMAP_SET_BITS(struct amap_mcc_context, cq_id, ctxt, cq->id);
+	/* Subscribe to Link State and Group 5 Events(bits 1 and 5 set) */
+	req->async_event_bitmap[0] |= 0x00000022;
 
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index b7a40b1..93c721a 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -82,7 +82,12 @@ struct be_mcc_compl {
  */
 #define ASYNC_TRAILER_EVENT_CODE_SHIFT	8	/* bits 8 - 15 */
 #define ASYNC_TRAILER_EVENT_CODE_MASK	0xFF
+#define ASYNC_TRAILER_EVENT_TYPE_SHIFT	16	/* bits 16 - 23 */
+#define ASYNC_TRAILER_EVENT_TYPE_MASK	0xFF
 #define ASYNC_EVENT_CODE_LINK_STATE	0x1
+#define ASYNC_EVENT_CODE_GRP_5		0x5
+#define ASYNC_EVENT_QOS_SPEED		0x1
+#define ASYNC_EVENT_COS_PRIORITY	0x2
 struct be_async_event_trailer {
 	u32 code;
 };
@@ -105,6 +110,30 @@ struct be_async_event_link_state {
 	struct be_async_event_trailer trailer;
 } __packed;
 
+/* When the event code of an async trailer is GRP-5 and event_type is QOS_SPEED
+ * the mcc_compl must be interpreted as follows
+ */
+struct be_async_event_grp5_qos_link_speed {
+	u8 physical_port;
+	u8 rsvd[5];
+	u16 qos_link_speed;
+	u32 event_tag;
+	struct be_async_event_trailer trailer;
+} __packed;
+
+/* When the event code of an async trailer is GRP5 and event type is
+ * CoS-Priority, the mcc_compl must be interpreted as follows
+ */
+struct be_async_event_grp5_cos_priority {
+	u8 physical_port;
+	u8 available_priority_bmap;
+	u8 reco_default_priority;
+	u8 valid;
+	u8 rsvd0;
+	u8 event_tag;
+	struct be_async_event_trailer trailer;
+} __packed;
+
 struct be_mcc_mailbox {
 	struct be_mcc_wrb wrb;
 	struct be_mcc_compl compl;
@@ -125,6 +154,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_EQ_CREATE				13
 #define OPCODE_COMMON_MCC_CREATE        		21
 #define OPCODE_COMMON_SET_QOS				28
+#define OPCODE_COMMON_MCC_CREATE_EXT			90
 #define OPCODE_COMMON_SEEPROM_READ			30
 #define OPCODE_COMMON_NTWK_RX_FILTER    		34
 #define OPCODE_COMMON_GET_FW_VERSION			35
@@ -338,6 +368,7 @@ struct be_cmd_req_mcc_create {
 	struct be_cmd_req_hdr hdr;
 	u16 num_pages;
 	u16 rsvd0;
+	u32 async_event_bitmap[1];
 	u8 context[sizeof(struct amap_mcc_context) / 8];
 	struct phys_addr pages[8];
 } __packed;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9a1cd28..5374be1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -429,9 +429,12 @@ static inline void wrb_fill(struct be_eth_wrb *wrb, u64 addr, int len)
 	wrb->frag_len = len & ETH_WRB_FRAG_LEN_MASK;
 }
 
-static void wrb_fill_hdr(struct be_eth_hdr_wrb *hdr, struct sk_buff *skb,
-		bool vlan, u32 wrb_cnt, u32 len)
+static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
+		struct sk_buff *skb, u32 wrb_cnt, u32 len)
 {
+	u8 vlan_prio = 0;
+	u16 vlan_tag = 0;
+
 	memset(hdr, 0, sizeof(*hdr));
 
 	AMAP_SET_BITS(struct amap_eth_hdr_wrb, crc, hdr, 1);
@@ -449,10 +452,15 @@ static void wrb_fill_hdr(struct be_eth_hdr_wrb *hdr, struct sk_buff *skb,
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, udpcs, hdr, 1);
 	}
 
-	if (vlan && vlan_tx_tag_present(skb)) {
+	if (adapter->vlan_grp && vlan_tx_tag_present(skb)) {
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan, hdr, 1);
-		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan_tag,
-			hdr, vlan_tx_tag_get(skb));
+		vlan_tag = vlan_tx_tag_get(skb);
+		vlan_prio = (vlan_tag & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+		/* If vlan priority provided by OS is NOT in available bmap */
+		if (!(adapter->vlan_prio_bmap & (1 << vlan_prio)))
+			vlan_tag = (vlan_tag & ~VLAN_PRIO_MASK) |
+					adapter->recommended_prio;
+		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan_tag, hdr, vlan_tag);
 	}
 
 	AMAP_SET_BITS(struct amap_eth_hdr_wrb, event, hdr, 1);
@@ -532,8 +540,7 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 		queue_head_inc(txq);
 	}
 
-	wrb_fill_hdr(hdr, first_skb, adapter->vlan_grp ? true : false,
-		wrb_cnt, copied);
+	wrb_fill_hdr(adapter, hdr, first_skb, wrb_cnt, copied);
 	be_dws_cpu_to_le(hdr, sizeof(*hdr));
 
 	return copied;
-- 
1.5.6.1

