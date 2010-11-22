From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6] be2net: adding support for Lancer family of
 CNAs
Date: Mon, 22 Nov 2010 14:55:50 +0530
Message-ID: <20101122092550.GA11076@emulex.com>
Reply-To: Sathya Perla <sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:39751 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752759Ab0KVJ2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 04:28:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Key changes are:
- EQ ids are not assigned consecutively in Lancer. So, fix mapping of MSIx
  vector to EQ-id.
- BAR mapping and some req locations different for Lancer.
- TCP,UDP,IP checksum fields must be compulsorily set in TX wrb for TSO in
  Lancer.
- CEV_IST reg not present in Lancer; so, peek into event queue to check for
  new entries
- cq_create and mcc_create cmd interface is different for Lancer; handle
  accordingly

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be.h      |   35 ++++++--
 drivers/net/benet/be_cmds.c |   96 +++++++++++++++++------
 drivers/net/benet/be_cmds.h |   42 +++++++++--
 drivers/net/benet/be_hw.h   |   39 ++++++++-
 drivers/net/benet/be_main.c |  181 +++++++++++++++++++++++++++++++------------
 5 files changed, 301 insertions(+), 92 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 4594a28..b61a1df 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -38,14 +38,17 @@
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
 #define OC_NAME			"Emulex OneConnect 10Gbps NIC"
-#define OC_NAME1		"Emulex OneConnect 10Gbps NIC (be3)"
+#define OC_NAME_BE		OC_NAME	"(be3)"
+#define OC_NAME_LANCER		OC_NAME "(Lancer)"
 #define DRV_DESC		"ServerEngines BladeEngine 10Gbps NIC Driver"
 
 #define BE_VENDOR_ID 		0x19a2
+#define EMULEX_VENDOR_ID	0x10df
 #define BE_DEVICE_ID1		0x211
 #define BE_DEVICE_ID2		0x221
-#define OC_DEVICE_ID1		0x700
-#define OC_DEVICE_ID2		0x710
+#define OC_DEVICE_ID1		0x700	/* Device Id for BE2 cards */
+#define OC_DEVICE_ID2		0x710	/* Device Id for BE3 cards */
+#define OC_DEVICE_ID3		0xe220	/* Device id for Lancer cards */
 
 static inline char *nic_name(struct pci_dev *pdev)
 {
@@ -53,7 +56,9 @@ static inline char *nic_name(struct pci_dev *pdev)
 	case OC_DEVICE_ID1:
 		return OC_NAME;
 	case OC_DEVICE_ID2:
-		return OC_NAME1;
+		return OC_NAME_BE;
+	case OC_DEVICE_ID3:
+		return OC_NAME_LANCER;
 	case BE_DEVICE_ID2:
 		return BE3_NAME;
 	default:
@@ -149,6 +154,7 @@ struct be_eq_obj {
 	u16 min_eqd;		/* in usecs */
 	u16 max_eqd;		/* in usecs */
 	u16 cur_eqd;		/* in usecs */
+	u8  msix_vec_idx;
 
 	struct napi_struct napi;
 };
@@ -260,6 +266,8 @@ struct be_adapter {
 	u32 num_rx_qs;
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
 
+	u8 msix_vec_next_idx;
+
 	struct vlan_group *vlan_grp;
 	u16 vlans_added;
 	u16 max_vlans;	/* Number of vlans supported */
@@ -299,8 +307,8 @@ struct be_adapter {
 
 	bool sriov_enabled;
 	struct be_vf_cfg vf_cfg[BE_MAX_VF];
-	u8 base_eq_id;
 	u8 is_virtfn;
+	u32 sli_family;
 };
 
 #define be_physfn(adapter) (!adapter->is_virtfn)
@@ -309,6 +317,8 @@ struct be_adapter {
 #define BE_GEN2 2
 #define BE_GEN3 3
 
+#define lancer_chip(adapter)		(adapter->pdev->device == OC_DEVICE_ID3)
+
 extern const struct ethtool_ops be_ethtool_ops;
 
 #define tx_stats(adapter)		(&adapter->tx_stats)
@@ -416,10 +426,17 @@ static inline u8 is_udp_pkt(struct sk_buff *skb)
 static inline void be_check_sriov_fn_type(struct be_adapter *adapter)
 {
 	u8 data;
-
-	pci_write_config_byte(adapter->pdev, 0xFE, 0xAA);
-	pci_read_config_byte(adapter->pdev, 0xFE, &data);
-	adapter->is_virtfn = (data != 0xAA);
+	u32 sli_intf;
+
+	if (lancer_chip(adapter)) {
+		pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET,
+								&sli_intf);
+		adapter->is_virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
+	} else {
+		pci_write_config_byte(adapter->pdev, 0xFE, 0xAA);
+		pci_read_config_byte(adapter->pdev, 0xFE, &data);
+		adapter->is_virtfn = (data != 0xAA);
+	}
 }
 
 static inline void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 36eca1c..3865b2b 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -323,7 +323,12 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
 
 static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 {
-	u32 sem = ioread32(adapter->csr + MPU_EP_SEMAPHORE_OFFSET);
+	u32 sem;
+
+	if (lancer_chip(adapter))
+		sem  = ioread32(adapter->db + MPU_EP_SEMAPHORE_IF_TYPE2_OFFSET);
+	else
+		sem  = ioread32(adapter->csr + MPU_EP_SEMAPHORE_OFFSET);
 
 	*stage = sem & EP_SEMAPHORE_POST_STAGE_MASK;
 	if ((sem >> EP_SEMAPHORE_POST_ERR_SHIFT) & EP_SEMAPHORE_POST_ERR_MASK)
@@ -465,14 +470,25 @@ int be_cmd_fw_init(struct be_adapter *adapter)
 	spin_lock(&adapter->mbox_lock);
 
 	wrb = (u8 *)wrb_from_mbox(adapter);
-	*wrb++ = 0xFF;
-	*wrb++ = 0x12;
-	*wrb++ = 0x34;
-	*wrb++ = 0xFF;
-	*wrb++ = 0xFF;
-	*wrb++ = 0x56;
-	*wrb++ = 0x78;
-	*wrb = 0xFF;
+	if (lancer_chip(adapter)) {
+		*wrb++ = 0xFF;
+		*wrb++ = 0x34;
+		*wrb++ = 0x12;
+		*wrb++ = 0xFF;
+		*wrb++ = 0xFF;
+		*wrb++ = 0x78;
+		*wrb++ = 0x56;
+		*wrb = 0xFF;
+	} else {
+		*wrb++ = 0xFF;
+		*wrb++ = 0x12;
+		*wrb++ = 0x34;
+		*wrb++ = 0xFF;
+		*wrb++ = 0xFF;
+		*wrb++ = 0x56;
+		*wrb++ = 0x78;
+		*wrb = 0xFF;
+	}
 
 	status = be_mbox_notify_wait(adapter);
 
@@ -680,16 +696,36 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 		OPCODE_COMMON_CQ_CREATE, sizeof(*req));
 
 	req->num_pages =  cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
+	if (lancer_chip(adapter)) {
+		req->hdr.version = 1;
+		req->page_size = 1; /* 1 for 4K */
+		AMAP_SET_BITS(struct amap_cq_context_lancer, coalescwm, ctxt,
+								coalesce_wm);
+		AMAP_SET_BITS(struct amap_cq_context_lancer, nodelay, ctxt,
+								no_delay);
+		AMAP_SET_BITS(struct amap_cq_context_lancer, count, ctxt,
+						__ilog2_u32(cq->len/256));
+		AMAP_SET_BITS(struct amap_cq_context_lancer, valid, ctxt, 1);
+		AMAP_SET_BITS(struct amap_cq_context_lancer, eventable,
+								ctxt, 1);
+		AMAP_SET_BITS(struct amap_cq_context_lancer, eqid,
+								ctxt, eq->id);
+		AMAP_SET_BITS(struct amap_cq_context_lancer, armed, ctxt, 1);
+	} else {
+		AMAP_SET_BITS(struct amap_cq_context_be, coalescwm, ctxt,
+								coalesce_wm);
+		AMAP_SET_BITS(struct amap_cq_context_be, nodelay,
+								ctxt, no_delay);
+		AMAP_SET_BITS(struct amap_cq_context_be, count, ctxt,
+						__ilog2_u32(cq->len/256));
+		AMAP_SET_BITS(struct amap_cq_context_be, valid, ctxt, 1);
+		AMAP_SET_BITS(struct amap_cq_context_be, solevent,
+								ctxt, sol_evts);
+		AMAP_SET_BITS(struct amap_cq_context_be, eventable, ctxt, 1);
+		AMAP_SET_BITS(struct amap_cq_context_be, eqid, ctxt, eq->id);
+		AMAP_SET_BITS(struct amap_cq_context_be, armed, ctxt, 1);
+	}
 
-	AMAP_SET_BITS(struct amap_cq_context, coalescwm, ctxt, coalesce_wm);
-	AMAP_SET_BITS(struct amap_cq_context, nodelay, ctxt, no_delay);
-	AMAP_SET_BITS(struct amap_cq_context, count, ctxt,
-			__ilog2_u32(cq->len/256));
-	AMAP_SET_BITS(struct amap_cq_context, valid, ctxt, 1);
-	AMAP_SET_BITS(struct amap_cq_context, solevent, ctxt, sol_evts);
-	AMAP_SET_BITS(struct amap_cq_context, eventable, ctxt, 1);
-	AMAP_SET_BITS(struct amap_cq_context, eqid, ctxt, eq->id);
-	AMAP_SET_BITS(struct amap_cq_context, armed, ctxt, 1);
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
@@ -737,13 +773,27 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 			OPCODE_COMMON_MCC_CREATE_EXT, sizeof(*req));
 
 	req->num_pages = cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
+	if (lancer_chip(adapter)) {
+		req->hdr.version = 1;
+		req->cq_id = cpu_to_le16(cq->id);
+
+		AMAP_SET_BITS(struct amap_mcc_context_lancer, ring_size, ctxt,
+						be_encoded_q_len(mccq->len));
+		AMAP_SET_BITS(struct amap_mcc_context_lancer, valid, ctxt, 1);
+		AMAP_SET_BITS(struct amap_mcc_context_lancer, async_cq_id,
+								ctxt, cq->id);
+		AMAP_SET_BITS(struct amap_mcc_context_lancer, async_cq_valid,
+								 ctxt, 1);
+
+	} else {
+		AMAP_SET_BITS(struct amap_mcc_context_be, valid, ctxt, 1);
+		AMAP_SET_BITS(struct amap_mcc_context_be, ring_size, ctxt,
+						be_encoded_q_len(mccq->len));
+		AMAP_SET_BITS(struct amap_mcc_context_be, cq_id, ctxt, cq->id);
+	}
 
-	AMAP_SET_BITS(struct amap_mcc_context, valid, ctxt, 1);
-	AMAP_SET_BITS(struct amap_mcc_context, ring_size, ctxt,
-		be_encoded_q_len(mccq->len));
-	AMAP_SET_BITS(struct amap_mcc_context, cq_id, ctxt, cq->id);
 	/* Subscribe to Link State and Group 5 Events(bits 1 and 5 set) */
-	req->async_event_bitmap[0] |= 0x00000022;
+	req->async_event_bitmap[0] = cpu_to_le32(0x00000022);
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 8469ff0..83d15c8 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -309,7 +309,7 @@ struct be_cmd_req_pmac_del {
 /******************** Create CQ ***************************/
 /* Pseudo amap definition in which each bit of the actual structure is defined
  * as a byte: used to calculate offset/shift/mask of each field */
-struct amap_cq_context {
+struct amap_cq_context_be {
 	u8 cidx[11];		/* dword 0*/
 	u8 rsvd0;		/* dword 0*/
 	u8 coalescwm[2];	/* dword 0*/
@@ -332,14 +332,32 @@ struct amap_cq_context {
 	u8 rsvd5[32];		/* dword 3*/
 } __packed;
 
+struct amap_cq_context_lancer {
+	u8 rsvd0[12];		/* dword 0*/
+	u8 coalescwm[2];	/* dword 0*/
+	u8 nodelay;		/* dword 0*/
+	u8 rsvd1[12];		/* dword 0*/
+	u8 count[2];		/* dword 0*/
+	u8 valid;		/* dword 0*/
+	u8 rsvd2;		/* dword 0*/
+	u8 eventable;		/* dword 0*/
+	u8 eqid[16];		/* dword 1*/
+	u8 rsvd3[15];		/* dword 1*/
+	u8 armed;		/* dword 1*/
+	u8 rsvd4[32];		/* dword 2*/
+	u8 rsvd5[32];		/* dword 3*/
+} __packed;
+
 struct be_cmd_req_cq_create {
 	struct be_cmd_req_hdr hdr;
 	u16 num_pages;
-	u16 rsvd0;
-	u8 context[sizeof(struct amap_cq_context) / 8];
+	u8 page_size;
+	u8 rsvd0;
+	u8 context[sizeof(struct amap_cq_context_be) / 8];
 	struct phys_addr pages[8];
 } __packed;
 
+
 struct be_cmd_resp_cq_create {
 	struct be_cmd_resp_hdr hdr;
 	u16 cq_id;
@@ -349,7 +367,7 @@ struct be_cmd_resp_cq_create {
 /******************** Create MCCQ ***************************/
 /* Pseudo amap definition in which each bit of the actual structure is defined
  * as a byte: used to calculate offset/shift/mask of each field */
-struct amap_mcc_context {
+struct amap_mcc_context_be {
 	u8 con_index[14];
 	u8 rsvd0[2];
 	u8 ring_size[4];
@@ -364,12 +382,23 @@ struct amap_mcc_context {
 	u8 rsvd2[32];
 } __packed;
 
+struct amap_mcc_context_lancer {
+	u8 async_cq_id[16];
+	u8 ring_size[4];
+	u8 rsvd0[12];
+	u8 rsvd1[31];
+	u8 valid;
+	u8 async_cq_valid[1];
+	u8 rsvd2[31];
+	u8 rsvd3[32];
+} __packed;
+
 struct be_cmd_req_mcc_create {
 	struct be_cmd_req_hdr hdr;
 	u16 num_pages;
-	u16 rsvd0;
+	u16 cq_id;
 	u32 async_event_bitmap[1];
-	u8 context[sizeof(struct amap_mcc_context) / 8];
+	u8 context[sizeof(struct amap_mcc_context_be) / 8];
 	struct phys_addr pages[8];
 } __packed;
 
@@ -605,6 +634,7 @@ struct be_hw_stats {
 	struct be_rxf_stats rxf;
 	u32 rsvd[48];
 	struct be_erx_stats erx;
+	u32 rsvd1[6];
 };
 
 struct be_cmd_req_get_stats {
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index a2ec5df..4096d97 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -32,10 +32,12 @@
 #define MPU_EP_CONTROL 		0
 
 /********** MPU semphore ******************/
-#define MPU_EP_SEMAPHORE_OFFSET 	0xac
-#define EP_SEMAPHORE_POST_STAGE_MASK	0x0000FFFF
-#define EP_SEMAPHORE_POST_ERR_MASK	0x1
-#define EP_SEMAPHORE_POST_ERR_SHIFT	31
+#define MPU_EP_SEMAPHORE_OFFSET		0xac
+#define MPU_EP_SEMAPHORE_IF_TYPE2_OFFSET	0x400
+#define EP_SEMAPHORE_POST_STAGE_MASK		0x0000FFFF
+#define EP_SEMAPHORE_POST_ERR_MASK		0x1
+#define EP_SEMAPHORE_POST_ERR_SHIFT		31
+
 /* MPU semphore POST stage values */
 #define POST_STAGE_AWAITING_HOST_RDY 	0x1 /* FW awaiting goahead from host */
 #define POST_STAGE_HOST_RDY 		0x2 /* Host has given go-ahed to FW */
@@ -66,6 +68,28 @@
 #define PCICFG_UE_STATUS_LOW_MASK		0xA8
 #define PCICFG_UE_STATUS_HI_MASK		0xAC
 
+/******** SLI_INTF ***********************/
+#define SLI_INTF_REG_OFFSET			0x58
+#define SLI_INTF_VALID_MASK			0xE0000000
+#define SLI_INTF_VALID				0xC0000000
+#define SLI_INTF_HINT2_MASK			0x1F000000
+#define SLI_INTF_HINT2_SHIFT			24
+#define SLI_INTF_HINT1_MASK			0x00FF0000
+#define SLI_INTF_HINT1_SHIFT			16
+#define SLI_INTF_FAMILY_MASK			0x00000F00
+#define SLI_INTF_FAMILY_SHIFT			8
+#define SLI_INTF_IF_TYPE_MASK			0x0000F000
+#define SLI_INTF_IF_TYPE_SHIFT			12
+#define SLI_INTF_REV_MASK			0x000000F0
+#define SLI_INTF_REV_SHIFT			4
+#define SLI_INTF_FT_MASK			0x00000001
+
+
+/* SLI family */
+#define BE_SLI_FAMILY		0x0
+#define LANCER_A0_SLI_FAMILY	0xA
+
+
 /********* ISR0 Register offset **********/
 #define CEV_ISR0_OFFSET 			0xC18
 #define CEV_ISR_SIZE				4
@@ -73,6 +97,9 @@
 /********* Event Q door bell *************/
 #define DB_EQ_OFFSET			DB_CQ_OFFSET
 #define DB_EQ_RING_ID_MASK		0x1FF	/* bits 0 - 8 */
+#define DB_EQ_RING_ID_EXT_MASK		0x3e00  /* bits 9-13 */
+#define DB_EQ_RING_ID_EXT_MASK_SHIFT	(2) /* qid bits 9-13 placing at 11-15 */
+
 /* Clear the interrupt for this eq */
 #define DB_EQ_CLR_SHIFT			(9)	/* bit 9 */
 /* Must be 1 */
@@ -85,6 +112,10 @@
 /********* Compl Q door bell *************/
 #define DB_CQ_OFFSET 			0x120
 #define DB_CQ_RING_ID_MASK		0x3FF	/* bits 0 - 9 */
+#define DB_CQ_RING_ID_EXT_MASK		0x7C00	/* bits 10-14 */
+#define DB_CQ_RING_ID_EXT_MASK_SHIFT	(1)	/* qid bits 10-14
+						 placing at 11-15 */
+
 /* Number of event entries processed */
 #define DB_CQ_NUM_POPPED_SHIFT		(16) 	/* bits 16 - 28 */
 /* Rearm bit */
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 93354ee..102567e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -41,6 +41,7 @@ static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID2) },
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID1) },
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID2) },
+	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID3)},
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -188,6 +189,8 @@ static void be_eq_notify(struct be_adapter *adapter, u16 qid,
 {
 	u32 val = 0;
 	val |= qid & DB_EQ_RING_ID_MASK;
+	val |= ((qid & DB_EQ_RING_ID_EXT_MASK) <<
+			DB_EQ_RING_ID_EXT_MASK_SHIFT);
 
 	if (adapter->eeh_err)
 		return;
@@ -205,6 +208,8 @@ void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm, u16 num_popped)
 {
 	u32 val = 0;
 	val |= qid & DB_CQ_RING_ID_MASK;
+	val |= ((qid & DB_CQ_RING_ID_EXT_MASK) <<
+			DB_CQ_RING_ID_EXT_MASK_SHIFT);
 
 	if (adapter->eeh_err)
 		return;
@@ -404,7 +409,8 @@ static void be_tx_stats_update(struct be_adapter *adapter,
 }
 
 /* Determine number of WRB entries needed to xmit data in an skb */
-static u32 wrb_cnt_for_skb(struct sk_buff *skb, bool *dummy)
+static u32 wrb_cnt_for_skb(struct be_adapter *adapter, struct sk_buff *skb,
+								bool *dummy)
 {
 	int cnt = (skb->len > skb->data_len);
 
@@ -412,12 +418,13 @@ static u32 wrb_cnt_for_skb(struct sk_buff *skb, bool *dummy)
 
 	/* to account for hdr wrb */
 	cnt++;
-	if (cnt & 1) {
+	if (lancer_chip(adapter) || !(cnt & 1)) {
+		*dummy = false;
+	} else {
 		/* add a dummy to make it an even num */
 		cnt++;
 		*dummy = true;
-	} else
-		*dummy = false;
+	}
 	BUG_ON(cnt > BE_MAX_TX_FRAG_COUNT);
 	return cnt;
 }
@@ -443,8 +450,18 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso, hdr, 1);
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso_mss,
 			hdr, skb_shinfo(skb)->gso_size);
-		if (skb_is_gso_v6(skb))
+		if (skb_is_gso_v6(skb) && !lancer_chip(adapter))
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso6, hdr, 1);
+		if (lancer_chip(adapter) && adapter->sli_family  ==
+							LANCER_A0_SLI_FAMILY) {
+			AMAP_SET_BITS(struct amap_eth_hdr_wrb, ipcs, hdr, 1);
+			if (is_tcp_pkt(skb))
+				AMAP_SET_BITS(struct amap_eth_hdr_wrb,
+								tcpcs, hdr, 1);
+			else if (is_udp_pkt(skb))
+				AMAP_SET_BITS(struct amap_eth_hdr_wrb,
+								udpcs, hdr, 1);
+		}
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (is_tcp_pkt(skb))
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, tcpcs, hdr, 1);
@@ -566,7 +583,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	u32 start = txq->head;
 	bool dummy_wrb, stopped = false;
 
-	wrb_cnt = wrb_cnt_for_skb(skb, &dummy_wrb);
+	wrb_cnt = wrb_cnt_for_skb(adapter, skb, &dummy_wrb);
 
 	copied = make_tx_wrbs(adapter, skb, wrb_cnt, dummy_wrb);
 	if (copied) {
@@ -1035,7 +1052,8 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 			return;
 		}
 		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
-		vid = swab16(vid);
+		if (!lancer_chip(adapter))
+			vid = swab16(vid);
 		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, vid);
 	} else {
 		netif_receive_skb(skb);
@@ -1113,7 +1131,8 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		napi_gro_frags(&eq_obj->napi);
 	} else {
 		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
-		vid = swab16(vid);
+		if (!lancer_chip(adapter))
+			vid = swab16(vid);
 
 		if (!adapter->vlan_grp || adapter->vlans_added == 0)
 			return;
@@ -1381,7 +1400,8 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 		sent_skb = sent_skbs[txq->tail];
 		end_idx = txq->tail;
 		index_adv(&end_idx,
-			wrb_cnt_for_skb(sent_skb, &dummy_wrb) - 1, txq->len);
+			wrb_cnt_for_skb(adapter, sent_skb, &dummy_wrb) - 1,
+			txq->len);
 		be_tx_compl_process(adapter, end_idx);
 	}
 }
@@ -1476,7 +1496,9 @@ static int be_tx_queues_create(struct be_adapter *adapter)
 	/* Ask BE to create Tx Event queue */
 	if (be_cmd_eq_create(adapter, eq, adapter->tx_eq.cur_eqd))
 		goto tx_eq_free;
-	adapter->base_eq_id = adapter->tx_eq.q.id;
+
+	adapter->tx_eq.msix_vec_idx = adapter->msix_vec_next_idx++;
+
 
 	/* Alloc TX eth compl queue */
 	cq = &adapter->tx_obj.cq;
@@ -1568,6 +1590,8 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 		if (rc)
 			goto err;
 
+		rxo->rx_eq.msix_vec_idx = adapter->msix_vec_next_idx++;
+
 		/* CQ */
 		cq = &rxo->cq;
 		rc = be_queue_alloc(adapter, cq, RX_CQ_LEN,
@@ -1578,7 +1602,6 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 		rc = be_cmd_cq_create(adapter, cq, eq, false, false, 3);
 		if (rc)
 			goto err;
-
 		/* Rx Q */
 		q = &rxo->q;
 		rc = be_queue_alloc(adapter, q, RX_Q_LEN,
@@ -1611,29 +1634,45 @@ err:
 	return -1;
 }
 
-/* There are 8 evt ids per func. Retruns the evt id's bit number */
-static inline int be_evt_bit_get(struct be_adapter *adapter, u32 eq_id)
+static bool event_peek(struct be_eq_obj *eq_obj)
 {
-	return eq_id - adapter->base_eq_id;
+	struct be_eq_entry *eqe = queue_tail_node(&eq_obj->q);
+	if (!eqe->evt)
+		return false;
+	else
+		return true;
 }
 
 static irqreturn_t be_intx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
 	struct be_rx_obj *rxo;
-	int isr, i;
+	int isr, i, tx = 0 , rx = 0;
 
-	isr = ioread32(adapter->csr + CEV_ISR0_OFFSET +
-		(adapter->tx_eq.q.id/ 8) * CEV_ISR_SIZE);
-	if (!isr)
-		return IRQ_NONE;
+	if (lancer_chip(adapter)) {
+		if (event_peek(&adapter->tx_eq))
+			tx = event_handle(adapter, &adapter->tx_eq);
+		for_all_rx_queues(adapter, rxo, i) {
+			if (event_peek(&rxo->rx_eq))
+				rx |= event_handle(adapter, &rxo->rx_eq);
+		}
 
-	if ((1 << be_evt_bit_get(adapter, adapter->tx_eq.q.id) & isr))
-		event_handle(adapter, &adapter->tx_eq);
+		if (!(tx || rx))
+			return IRQ_NONE;
 
-	for_all_rx_queues(adapter, rxo, i) {
-		if ((1 << be_evt_bit_get(adapter, rxo->rx_eq.q.id) & isr))
-			event_handle(adapter, &rxo->rx_eq);
+	} else {
+		isr = ioread32(adapter->csr + CEV_ISR0_OFFSET +
+			(adapter->tx_eq.q.id / 8) * CEV_ISR_SIZE);
+		if (!isr)
+			return IRQ_NONE;
+
+		if ((1 << adapter->tx_eq.msix_vec_idx & isr))
+			event_handle(adapter, &adapter->tx_eq);
+
+		for_all_rx_queues(adapter, rxo, i) {
+			if ((1 << rxo->rx_eq.msix_vec_idx & isr))
+				event_handle(adapter, &rxo->rx_eq);
+		}
 	}
 
 	return IRQ_HANDLED;
@@ -1830,8 +1869,7 @@ static void be_worker(struct work_struct *work)
 			be_post_rx_frags(rxo);
 		}
 	}
-
-	if (!adapter->ue_detected)
+	if (!adapter->ue_detected && !lancer_chip(adapter))
 		be_detect_dump_ue(adapter);
 
 reschedule:
@@ -1910,10 +1948,10 @@ static void be_sriov_disable(struct be_adapter *adapter)
 #endif
 }
 
-static inline int be_msix_vec_get(struct be_adapter *adapter, u32 eq_id)
+static inline int be_msix_vec_get(struct be_adapter *adapter,
+					struct be_eq_obj *eq_obj)
 {
-	return adapter->msix_entries[
-			be_evt_bit_get(adapter, eq_id)].vector;
+	return adapter->msix_entries[eq_obj->msix_vec_idx].vector;
 }
 
 static int be_request_irq(struct be_adapter *adapter,
@@ -1924,14 +1962,14 @@ static int be_request_irq(struct be_adapter *adapter,
 	int vec;
 
 	sprintf(eq_obj->desc, "%s-%s", netdev->name, desc);
-	vec = be_msix_vec_get(adapter, eq_obj->q.id);
+	vec = be_msix_vec_get(adapter, eq_obj);
 	return request_irq(vec, handler, 0, eq_obj->desc, context);
 }
 
 static void be_free_irq(struct be_adapter *adapter, struct be_eq_obj *eq_obj,
 			void *context)
 {
-	int vec = be_msix_vec_get(adapter, eq_obj->q.id);
+	int vec = be_msix_vec_get(adapter, eq_obj);
 	free_irq(vec, context);
 }
 
@@ -2036,14 +2074,15 @@ static int be_close(struct net_device *netdev)
 	netif_carrier_off(netdev);
 	adapter->link_up = false;
 
-	be_intr_set(adapter, false);
+	if (!lancer_chip(adapter))
+		be_intr_set(adapter, false);
 
 	if (adapter->msix_enabled) {
-		vec = be_msix_vec_get(adapter, tx_eq->q.id);
+		vec = be_msix_vec_get(adapter, tx_eq);
 		synchronize_irq(vec);
 
 		for_all_rx_queues(adapter, rxo, i) {
-			vec = be_msix_vec_get(adapter, rxo->rx_eq.q.id);
+			vec = be_msix_vec_get(adapter, &rxo->rx_eq);
 			synchronize_irq(vec);
 		}
 	} else {
@@ -2082,7 +2121,8 @@ static int be_open(struct net_device *netdev)
 
 	be_irq_register(adapter);
 
-	be_intr_set(adapter, true);
+	if (!lancer_chip(adapter))
+		be_intr_set(adapter, true);
 
 	/* The evt queues are created in unarmed state; arm them */
 	for_all_rx_queues(adapter, rxo, i) {
@@ -2548,6 +2588,9 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_HW_CSUM;
 
+	if (lancer_chip(adapter))
+		netdev->vlan_features |= NETIF_F_TSO6;
+
 	netdev->flags |= IFF_MULTICAST;
 
 	adapter->rx_csum = true;
@@ -2587,6 +2630,15 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 	u8 __iomem *addr;
 	int pcicfg_reg, db_reg;
 
+	if (lancer_chip(adapter)) {
+		addr = ioremap_nocache(pci_resource_start(adapter->pdev, 0),
+			pci_resource_len(adapter->pdev, 0));
+		if (addr == NULL)
+			return -ENOMEM;
+		adapter->db = addr;
+		return 0;
+	}
+
 	if (be_physfn(adapter)) {
 		addr = ioremap_nocache(pci_resource_start(adapter->pdev, 2),
 				pci_resource_len(adapter->pdev, 2));
@@ -2783,6 +2835,44 @@ static int be_get_config(struct be_adapter *adapter)
 	return 0;
 }
 
+static int be_dev_family_check(struct be_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	u32 sli_intf = 0, if_type;
+
+	switch (pdev->device) {
+	case BE_DEVICE_ID1:
+	case OC_DEVICE_ID1:
+		adapter->generation = BE_GEN2;
+		break;
+	case BE_DEVICE_ID2:
+	case OC_DEVICE_ID2:
+		adapter->generation = BE_GEN3;
+		break;
+	case OC_DEVICE_ID3:
+		pci_read_config_dword(pdev, SLI_INTF_REG_OFFSET, &sli_intf);
+		if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
+						SLI_INTF_IF_TYPE_SHIFT;
+
+		if (((sli_intf & SLI_INTF_VALID_MASK) != SLI_INTF_VALID) ||
+			if_type != 0x02) {
+			dev_err(&pdev->dev, "SLI_INTF reg val is not valid\n");
+			return -EINVAL;
+		}
+		if (num_vfs > 0) {
+			dev_err(&pdev->dev, "VFs not supported\n");
+			return -EINVAL;
+		}
+		adapter->sli_family = ((sli_intf & SLI_INTF_FAMILY_MASK) >>
+					 SLI_INTF_FAMILY_SHIFT);
+		adapter->generation = BE_GEN3;
+		break;
+	default:
+		adapter->generation = 0;
+	}
+	return 0;
+}
+
 static int __devinit be_probe(struct pci_dev *pdev,
 			const struct pci_device_id *pdev_id)
 {
@@ -2805,22 +2895,13 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		goto rel_reg;
 	}
 	adapter = netdev_priv(netdev);
-
-	switch (pdev->device) {
-	case BE_DEVICE_ID1:
-	case OC_DEVICE_ID1:
-		adapter->generation = BE_GEN2;
-		break;
-	case BE_DEVICE_ID2:
-	case OC_DEVICE_ID2:
-		adapter->generation = BE_GEN3;
-		break;
-	default:
-		adapter->generation = 0;
-	}
-
 	adapter->pdev = pdev;
 	pci_set_drvdata(pdev, adapter);
+
+	status = be_dev_family_check(adapter);
+	if (!status)
+		goto free_netdev;
+
 	adapter->netdev = netdev;
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
@@ -2895,7 +2976,7 @@ ctrl_clean:
 	be_ctrl_cleanup(adapter);
 free_netdev:
 	be_sriov_disable(adapter);
-	free_netdev(adapter->netdev);
+	free_netdev(netdev);
 	pci_set_drvdata(pdev, NULL);
 rel_reg:
 	pci_release_regions(pdev);
-- 
1.6.5.2

