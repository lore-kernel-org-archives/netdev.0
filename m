From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 4/5] be2net: get rid of AMAP_SET/GET macros in TX path
Date: Thu, 27 Sep 2012 12:02:47 +0530
Message-ID: <92de1988-73db-4864-bf19-10ed11dac557@CMEXHTCAS2.ad.emulex.com>
References: <1348727568-2011-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:17101 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305Ab2I0G43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 02:56:29 -0400
In-Reply-To: <1348727568-2011-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AMAP macros are used in be2net for setting and parsing bits in HW
descriptors. The macros do this by calculating the mask & offset of each
field from the AMAP structure definition.
In the TX patch, replace the usage of these macros with code to explicitly
shift & mask each field. Doing this reduces instructions and improves
readability.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_hw.h   |   62 ++++++++-------------------
 drivers/net/ethernet/emulex/benet/be_main.c |   58 ++++++++++---------------
 2 files changed, 41 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index b755f70..32a84ab 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -273,56 +273,30 @@ struct be_eth_wrb {
 	u32 frag_len;		/* dword 3: bits 0 - 15 */
 } __packed;
 
-/* Pseudo amap definition for eth_hdr_wrb in which each bit of the
- * actual structure is defined as a byte : used to calculate
- * offset/shift/mask of each field */
-struct amap_eth_hdr_wrb {
-	u8 rsvd0[32];		/* dword 0 */
-	u8 rsvd1[32];		/* dword 1 */
-	u8 complete;		/* dword 2 */
-	u8 event;
-	u8 crc;
-	u8 forward;
-	u8 lso6;
-	u8 mgmt;
-	u8 ipcs;
-	u8 udpcs;
-	u8 tcpcs;
-	u8 lso;
-	u8 vlan;
-	u8 gso[2];
-	u8 num_wrb[5];
-	u8 lso_mss[14];
-	u8 len[16];		/* dword 3 */
-	u8 vlan_tag[16];
-} __packed;
+#define TX_HDR_WRB_COMPL		1		/* word 2 */
+#define TX_HDR_WRB_EVT			(1 << 1)	/* word 2 */
+#define TX_HDR_WRB_CRC			(1 << 2)	/* word 2 */
+#define TX_HDR_WRB_LSO6			(1 << 4)	/* word 2 */
+#define TX_HDR_WRB_IPCS			(1 << 6)	/* word 2 */
+#define TX_HDR_WRB_UDPCS		(1 << 7)	/* word 2 */
+#define TX_HDR_WRB_TCPCS		(1 << 8)	/* word 2 */
+#define TX_HDR_WRB_LSO			(1 << 9)	/* word 2 */
+#define TX_HDR_WRB_VLAN			(1 << 10)	/* word 2 */
+#define TX_HDR_WRB_NUM_SHIFT		13		/* word 2: bits 13:17 */
+#define TX_HDR_WRB_NUM_MASK		0x1F		/* word 2: bits 13:17 */
+#define TX_HDR_WRB_MSS_SHIFT		18		/* word 2: bits 18:31 */
+#define TX_HDR_WRB_MSS_MASK		0x3FFF		/* word 2: bits 18:31 */
+#define TX_HDR_WRB_LEN_MASK		0xFFFF		/* word 3: bits 0:15 */
+#define TX_HDR_WRB_VLAN_TCI_SHIFT	16		/* word 3: bits 16:31 */
+#define TX_HDR_WRB_VLAN_TCI_MASK	0xFFFF		/* word 3: bits 16:31 */
 
 struct be_eth_hdr_wrb {
 	u32 dw[4];
 };
 
 /* TX Compl Queue Descriptor */
-
-/* Pseudo amap definition for eth_tx_compl in which each bit of the
- * actual structure is defined as a byte: used to calculate
- * offset/shift/mask of each field */
-struct amap_eth_tx_compl {
-	u8 wrb_index[16];	/* dword 0 */
-	u8 ct[2]; 		/* dword 0 */
-	u8 port[2];		/* dword 0 */
-	u8 rsvd0[8];		/* dword 0 */
-	u8 status[4];		/* dword 0 */
-	u8 user_bytes[16];	/* dword 1 */
-	u8 nwh_bytes[8];	/* dword 1 */
-	u8 lso;			/* dword 1 */
-	u8 cast_enc[2];		/* dword 1 */
-	u8 rsvd1[5];		/* dword 1 */
-	u8 rsvd2[32];		/* dword 2 */
-	u8 pkts[16];		/* dword 3 */
-	u8 ringid[11];		/* dword 3 */
-	u8 hash_val[4];		/* dword 3 */
-	u8 valid;		/* dword 3 */
-} __packed;
+#define TX_COMPL_WRB_IDX_MASK		0xFFFF		/* word 0: bits 0:15 */
+#define TX_COMPL_VALID			(1 << 31)	/* word 3 */
 
 struct be_eth_tx_compl {
 	u32 dw[4];
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4855dd6..c74906d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -585,45 +585,34 @@ static int be_vlan_tag_chk(struct be_adapter *adapter, struct sk_buff *skb)
 static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		struct sk_buff *skb, u32 wrb_cnt, u32 len)
 {
-	u16 vlan_tag;
-
-	memset(hdr, 0, sizeof(*hdr));
-
-	AMAP_SET_BITS(struct amap_eth_hdr_wrb, crc, hdr, 1);
+	u32 dw2 = 0, dw3 = 0;
 
 	if (skb_is_gso(skb)) {
-		AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso, hdr, 1);
-		AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso_mss,
-			hdr, skb_shinfo(skb)->gso_size);
+		dw2 |= TX_HDR_WRB_LSO;
+		dw2 |= (skb_shinfo(skb)->gso_size & TX_HDR_WRB_MSS_MASK) <<
+			TX_HDR_WRB_MSS_SHIFT;
 		if (skb_is_gso_v6(skb) && !lancer_chip(adapter))
-			AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso6, hdr, 1);
-		if (lancer_chip(adapter) && adapter->sli_family  ==
-							LANCER_A0_SLI_FAMILY) {
-			AMAP_SET_BITS(struct amap_eth_hdr_wrb, ipcs, hdr, 1);
-			if (is_tcp_pkt(skb))
-				AMAP_SET_BITS(struct amap_eth_hdr_wrb,
-								tcpcs, hdr, 1);
-			else if (is_udp_pkt(skb))
-				AMAP_SET_BITS(struct amap_eth_hdr_wrb,
-								udpcs, hdr, 1);
-		}
+			dw2 |= TX_HDR_WRB_LSO6;
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (is_tcp_pkt(skb))
-			AMAP_SET_BITS(struct amap_eth_hdr_wrb, tcpcs, hdr, 1);
+			dw2 |= TX_HDR_WRB_TCPCS;
 		else if (is_udp_pkt(skb))
-			AMAP_SET_BITS(struct amap_eth_hdr_wrb, udpcs, hdr, 1);
+			dw2 |= TX_HDR_WRB_UDPCS;
 	}
 
 	if (vlan_tx_tag_present(skb)) {
-		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan, hdr, 1);
-		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
-		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan_tag, hdr, vlan_tag);
+		dw2 |= TX_HDR_WRB_VLAN;
+		dw3 = (be_get_tx_vlan_tag(adapter, skb) & 0xFFFF) <<
+				TX_HDR_WRB_VLAN_TCI_SHIFT;
 	}
+	dw2 |= TX_HDR_WRB_CRC | TX_HDR_WRB_EVT | TX_HDR_WRB_COMPL |
+		(wrb_cnt & TX_HDR_WRB_NUM_MASK) << TX_HDR_WRB_NUM_SHIFT;
+	dw3 |= len & TX_HDR_WRB_LEN_MASK;
 
-	AMAP_SET_BITS(struct amap_eth_hdr_wrb, event, hdr, 1);
-	AMAP_SET_BITS(struct amap_eth_hdr_wrb, complete, hdr, 1);
-	AMAP_SET_BITS(struct amap_eth_hdr_wrb, num_wrb, hdr, wrb_cnt);
-	AMAP_SET_BITS(struct amap_eth_hdr_wrb, len, hdr, len);
+	hdr->dw[2] = dw2;
+	hdr->dw[3] = dw3;
+	hdr->dw[0] = 0;
+	hdr->dw[1] = 0;
 }
 
 static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
@@ -1554,13 +1543,14 @@ static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
 {
 	struct be_eth_tx_compl *txcp = queue_tail_node(tx_cq);
 
-	if (txcp->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] == 0)
+	/* valid bit is bit 31 of dw[3] */
+	if (!txcp->dw[3])
 		return NULL;
 
 	rmb();
 	be_dws_le_to_cpu(txcp, sizeof(*txcp));
 
-	txcp->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] = 0;
+	txcp->dw[3] = 0;
 
 	queue_tail_inc(tx_cq);
 	return txcp;
@@ -1686,9 +1676,7 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 		for_all_tx_queues(adapter, txo, i) {
 			txq = &txo->q;
 			while ((txcp = be_tx_compl_get(&txo->cq))) {
-				end_idx =
-					AMAP_GET_BITS(struct amap_eth_tx_compl,
-						      wrb_index, txcp);
+				end_idx = txcp->dw[0] & TX_COMPL_WRB_IDX_MASK;
 				num_wrbs += be_tx_compl_process(adapter, txo,
 								end_idx);
 				cmpl++;
@@ -2040,8 +2028,8 @@ static bool be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 		if (!txcp)
 			break;
 		num_wrbs += be_tx_compl_process(adapter, txo,
-				AMAP_GET_BITS(struct amap_eth_tx_compl,
-					wrb_index, txcp));
+						txcp->dw[0] &
+						TX_COMPL_WRB_IDX_MASK);
 	}
 
 	if (work_done) {
-- 
1.7.4
