From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 1/2] bnx2x: add CSUM and TSO support for
 encapsulation protocols
Date: Mon, 18 Mar 2013 18:51:03 +0200
Message-ID: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2997 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753898Ab3CRQvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 12:51:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch utilizes FW offload capabilities for
encapsulation protocols.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   29 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  196 ++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    7 +
 3 files changed, 204 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 9e8d195..a4729c7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -612,9 +612,10 @@ struct bnx2x_fastpath {
  * START_BD		- describes packed
  * START_BD(splitted)	- includes unpaged data segment for GSO
  * PARSING_BD		- for TSO and CSUM data
+ * PARSING_BD2		- for encapsulation data
  * Frag BDs		- decribes pages for frags
  */
-#define BDS_PER_TX_PKT		3
+#define BDS_PER_TX_PKT		4
 #define MAX_BDS_PER_TX_PKT	(MAX_SKB_FRAGS + BDS_PER_TX_PKT)
 /* max BDs per tx packet including next pages */
 #define MAX_DESC_PER_TX_PKT	(MAX_BDS_PER_TX_PKT + \
@@ -731,16 +732,22 @@ struct bnx2x_fastpath {
 
 #define pbd_tcp_flags(tcp_hdr)	(ntohl(tcp_flag_word(tcp_hdr))>>16 & 0xff)
 
-#define XMIT_PLAIN			0
-#define XMIT_CSUM_V4			0x1
-#define XMIT_CSUM_V6			0x2
-#define XMIT_CSUM_TCP			0x4
-#define XMIT_GSO_V4			0x8
-#define XMIT_GSO_V6			0x10
-
-#define XMIT_CSUM			(XMIT_CSUM_V4 | XMIT_CSUM_V6)
-#define XMIT_GSO			(XMIT_GSO_V4 | XMIT_GSO_V6)
-
+#define XMIT_PLAIN		0
+#define XMIT_CSUM_V4		(1 << 0)
+#define XMIT_CSUM_V6		(1 << 1)
+#define XMIT_CSUM_TCP		(1 << 2)
+#define XMIT_GSO_V4		(1 << 3)
+#define XMIT_GSO_V6		(1 << 4)
+#define XMIT_CSUM_ENC_V4	(1 << 5)
+#define XMIT_CSUM_ENC_V6	(1 << 6)
+#define XMIT_GSO_ENC_V4		(1 << 7)
+#define XMIT_GSO_ENC_V6		(1 << 8)
+
+#define XMIT_CSUM_ENC		(XMIT_CSUM_ENC_V4 | XMIT_CSUM_ENC_V6)
+#define XMIT_GSO_ENC		(XMIT_GSO_ENC_V4 | XMIT_GSO_ENC_V6)
+
+#define XMIT_CSUM		(XMIT_CSUM_V4 | XMIT_CSUM_V6 | XMIT_CSUM_ENC)
+#define XMIT_GSO		(XMIT_GSO_V4 | XMIT_GSO_V6 | XMIT_GSO_ENC)
 
 /* stuff added to make the code fit 80Col */
 #define CQE_TYPE(cqe_fp_flags)	 ((cqe_fp_flags) & ETH_FAST_PATH_RX_CQE_TYPE)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9f7a379..8091de7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3148,27 +3148,44 @@ static __le16 bnx2x_csum_fix(unsigned char *t_header, u16 csum, s8 fix)
 static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 {
 	u32 rc;
+	__u8 prot = 0;
+	__be16 protocol;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		rc = XMIT_PLAIN;
+		return XMIT_PLAIN;
 
-	else {
-		if (vlan_get_protocol(skb) == htons(ETH_P_IPV6)) {
-			rc = XMIT_CSUM_V6;
-			if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
-				rc |= XMIT_CSUM_TCP;
+	protocol = vlan_get_protocol(skb);
+	if (protocol == htons(ETH_P_IPV6)) {
+		rc = XMIT_CSUM_V6;
+		prot = ipv6_hdr(skb)->nexthdr;
+	} else {
+		rc = XMIT_CSUM_V4;
+		prot = ip_hdr(skb)->protocol;
+	}
 
+	if (!CHIP_IS_E1x(bp) && skb->encapsulation) {
+		if (inner_ip_hdr(skb)->version == 6) {
+			rc |= XMIT_CSUM_ENC_V6;
+			if (inner_ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+				rc |= XMIT_CSUM_TCP;
 		} else {
-			rc = XMIT_CSUM_V4;
-			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+			rc |= XMIT_CSUM_ENC_V4;
+			if (inner_ip_hdr(skb)->protocol == IPPROTO_TCP)
 				rc |= XMIT_CSUM_TCP;
 		}
 	}
+	if (prot == IPPROTO_TCP)
+		rc |= XMIT_CSUM_TCP;
 
-	if (skb_is_gso_v6(skb))
-		rc |= XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6;
-	else if (skb_is_gso(skb))
-		rc |= XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP;
+	if (skb_is_gso_v6(skb)) {
+		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
+		if (rc & XMIT_CSUM_ENC)
+			rc |= XMIT_GSO_ENC_V6;
+	} else if (skb_is_gso(skb)) {
+		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
+		if (rc & XMIT_CSUM_ENC)
+			rc |= XMIT_GSO_ENC_V4;
+	}
 
 	return rc;
 }
@@ -3256,11 +3273,20 @@ exit_lbl:
 static void bnx2x_set_pbd_gso_e2(struct sk_buff *skb, u32 *parsing_data,
 				 u32 xmit_type)
 {
+	struct ipv6hdr *ipv6;
+
 	*parsing_data |= (skb_shinfo(skb)->gso_size <<
 			      ETH_TX_PARSE_BD_E2_LSO_MSS_SHIFT) &
 			      ETH_TX_PARSE_BD_E2_LSO_MSS;
-	if ((xmit_type & XMIT_GSO_V6) &&
-	    (ipv6_hdr(skb)->nexthdr == NEXTHDR_IPV6))
+
+	if (xmit_type & XMIT_GSO_ENC_V6)
+		ipv6 = inner_ipv6_hdr(skb);
+	else if (xmit_type & XMIT_GSO_V6)
+		ipv6 = ipv6_hdr(skb);
+	else
+		ipv6 = NULL;
+
+	if (ipv6 && ipv6->nexthdr == NEXTHDR_IPV6)
 		*parsing_data |= ETH_TX_PARSE_BD_E2_IPV6_WITH_EXT_HDR;
 }
 
@@ -3297,6 +3323,40 @@ static void bnx2x_set_pbd_gso(struct sk_buff *skb,
 }
 
 /**
+ * bnx2x_set_pbd_csum_enc - update PBD with checksum and return header length
+ *
+ * @bp:			driver handle
+ * @skb:		packet skb
+ * @parsing_data:	data to be updated
+ * @xmit_type:		xmit flags
+ *
+ * 57712/578xx related, when skb has encapsulation
+ */
+static u8 bnx2x_set_pbd_csum_enc(struct bnx2x *bp, struct sk_buff *skb,
+				 u32 *parsing_data, u32 xmit_type)
+{
+	*parsing_data |=
+		((((u8 *)skb_inner_transport_header(skb) - skb->data) >> 1) <<
+		ETH_TX_PARSE_BD_E2_L4_HDR_START_OFFSET_W_SHIFT) &
+		ETH_TX_PARSE_BD_E2_L4_HDR_START_OFFSET_W;
+
+	if (xmit_type & XMIT_CSUM_TCP) {
+		*parsing_data |= ((inner_tcp_hdrlen(skb) / 4) <<
+			ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW_SHIFT) &
+			ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW;
+
+		return skb_inner_transport_header(skb) +
+			inner_tcp_hdrlen(skb) - skb->data;
+	}
+
+	/* We support checksum offload for TCP and UDP only.
+	 * No need to pass the UDP header length - it's a constant.
+	 */
+	return skb_inner_transport_header(skb) +
+		sizeof(struct udphdr) - skb->data;
+}
+
+/**
  * bnx2x_set_pbd_csum_e2 - update PBD with checksum and return header length
  *
  * @bp:			driver handle
@@ -3327,13 +3387,14 @@ static u8 bnx2x_set_pbd_csum_e2(struct bnx2x *bp, struct sk_buff *skb,
 	return skb_transport_header(skb) + sizeof(struct udphdr) - skb->data;
 }
 
+/* set FW indication according to inner or outer protocols if tunneled */
 static void bnx2x_set_sbd_csum(struct bnx2x *bp, struct sk_buff *skb,
 			       struct eth_tx_start_bd *tx_start_bd,
 			       u32 xmit_type)
 {
 	tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_L4_CSUM;
 
-	if (xmit_type & XMIT_CSUM_V6)
+	if (xmit_type & (XMIT_CSUM_ENC_V6 | XMIT_CSUM_V6))
 		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_IPV6;
 
 	if (!(xmit_type & XMIT_CSUM_TCP))
@@ -3396,6 +3457,72 @@ static u8 bnx2x_set_pbd_csum(struct bnx2x *bp, struct sk_buff *skb,
 	return hlen;
 }
 
+static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
+				      struct eth_tx_parse_bd_e2 *pbd_e2,
+				      struct eth_tx_parse_2nd_bd *pbd2,
+				      u16 *global_data,
+				      u32 xmit_type)
+{
+	u16 inner_hlen_w = 0;
+	u8 outerip_off, outerip_len = 0;
+
+	/* IP len */
+	inner_hlen_w = (skb_inner_transport_header(skb) -
+			skb_inner_network_header(skb)) >> 1;
+
+	/* transport len */
+	if (xmit_type & XMIT_CSUM_TCP)
+		inner_hlen_w += inner_tcp_hdrlen(skb) >> 1;
+	else
+		inner_hlen_w += sizeof(struct udphdr) >> 1;
+
+	pbd2->fw_ip_hdr_to_payload_w = inner_hlen_w;
+
+	if (xmit_type & XMIT_CSUM_ENC_V4) {
+		struct iphdr *iph = inner_ip_hdr(skb);
+
+		pbd2->fw_ip_csum_wo_len_flags_frag =
+			bswab16(csum_fold((~iph->check) -
+					  iph->tot_len - iph->frag_off));
+	} else {
+		pbd2->fw_ip_hdr_to_payload_w =
+			inner_hlen_w - ((sizeof(struct ipv6hdr)) >> 1);
+	}
+
+	pbd2->tcp_send_seq = bswab32(inner_tcp_hdr(skb)->seq);
+
+	pbd2->tcp_flags = pbd_tcp_flags(inner_tcp_hdr(skb));
+
+	if (xmit_type & XMIT_GSO_V4) {
+		pbd2->hw_ip_id = bswab16(ip_hdr(skb)->id);
+
+		pbd_e2->data.tunnel_data.pseudo_csum =
+			bswab16(~csum_tcpudp_magic(
+					inner_ip_hdr(skb)->saddr,
+					inner_ip_hdr(skb)->daddr,
+					0, IPPROTO_TCP, 0));
+
+		outerip_len = ip_hdr(skb)->ihl << 1;
+	} else {
+		pbd_e2->data.tunnel_data.pseudo_csum =
+			bswab16(~csum_ipv6_magic(
+					&inner_ipv6_hdr(skb)->saddr,
+					&inner_ipv6_hdr(skb)->daddr,
+					0, IPPROTO_TCP, 0));
+	}
+
+	outerip_off = (skb_network_header(skb) - skb->data) >> 1;
+
+	*global_data |=
+		outerip_off |
+		(!!(xmit_type & XMIT_CSUM_V6) <<
+			ETH_TX_PARSE_2ND_BD_IP_HDR_TYPE_OUTER_SHIFT) |
+		(outerip_len <<
+			ETH_TX_PARSE_2ND_BD_IP_HDR_LEN_OUTER_W_SHIFT) |
+		((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
+			ETH_TX_PARSE_2ND_BD_LLC_SNAP_EN_SHIFT);
+}
+
 /* called with netif_tx_lock
  * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue()
@@ -3411,6 +3538,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
 	struct eth_tx_parse_bd_e1x *pbd_e1x = NULL;
 	struct eth_tx_parse_bd_e2 *pbd_e2 = NULL;
+	struct eth_tx_parse_2nd_bd *pbd2 = NULL;
 	u32 pbd_e2_parsing_data = 0;
 	u16 pkt_prod, bd_prod;
 	int nbd, txq_index;
@@ -3567,12 +3695,46 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!CHIP_IS_E1x(bp)) {
 		pbd_e2 = &txdata->tx_desc_ring[bd_prod].parse_bd_e2;
 		memset(pbd_e2, 0, sizeof(struct eth_tx_parse_bd_e2));
-		/* Set PBD in checksum offload case */
-		if (xmit_type & XMIT_CSUM)
+
+		if (xmit_type & XMIT_CSUM_ENC) {
+			u16 global_data = 0;
+
+			/* Set PBD in enc checksum offload case */
+			hlen = bnx2x_set_pbd_csum_enc(bp, skb,
+						      &pbd_e2_parsing_data,
+						      xmit_type);
+
+			/* turn on 2nd parsing and get a BD */
+			bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+
+			pbd2 = &txdata->tx_desc_ring[bd_prod].parse_2nd_bd;
+
+			memset(pbd2, 0, sizeof(*pbd2));
+
+			pbd_e2->data.tunnel_data.ip_hdr_start_inner_w =
+				(skb_inner_network_header(skb) -
+				 skb->data) >> 1;
+
+			if (xmit_type & XMIT_GSO_ENC)
+				bnx2x_update_pbds_gso_enc(skb, pbd_e2, pbd2,
+							  &global_data,
+							  xmit_type);
+
+			pbd2->global_data = cpu_to_le16(global_data);
+
+			/* add addition parse BD indication to start BD */
+			SET_FLAG(tx_start_bd->general_data,
+				 ETH_TX_START_BD_PARSE_NBDS, 1);
+			/* set encapsulation flag in start BD */
+			SET_FLAG(tx_start_bd->general_data,
+				 ETH_TX_START_BD_TUNNEL_EXIST, 1);
+			nbd++;
+		} else if (xmit_type & XMIT_CSUM) {
 			/* Set PBD in checksum offload case w/o encapsulation */
 			hlen = bnx2x_set_pbd_csum_e2(bp, skb,
 						     &pbd_e2_parsing_data,
 						     xmit_type);
+		}
 
 		/* Add the macs to the parsing BD this is a vf */
 		if (IS_VF(bp)) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 04d123f..4902d1e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11965,6 +11965,13 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO |
 		NETIF_F_RXHASH | NETIF_F_HW_VLAN_TX;
+	if (!CHIP_IS_E1x(bp)) {
+		dev->hw_features |= NETIF_F_GSO_GRE;
+		dev->hw_enc_features =
+			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
+			NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
+			NETIF_F_GSO_GRE;
+	}
 
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
-- 
1.7.7.2
