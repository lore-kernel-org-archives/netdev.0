From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-2.6 1/3] bnx2x: LSO code was broken on BE platforms
Date: Sun, 12 Dec 2010 16:11:45 +0200
Message-ID: <1292163105.20811.160.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2934 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557Ab0LLOMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 09:12:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the LSO code work on BE platforms: parsing_data field of 
a parsing BD (PBD) for 57712 was improperly composed which made FW read wrong 
values for TCP header's length and offset and, as a result, the corresponding 
PCI device was performing bad DMA reads triggering EEH.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   42 +++++++++++++++++++++++++---------------
 1 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 94d5f59..0af361e 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1782,15 +1782,15 @@ exit_lbl:
 }
 #endif
 
-static inline void bnx2x_set_pbd_gso_e2(struct sk_buff *skb,
-				     struct eth_tx_parse_bd_e2 *pbd,
-				     u32 xmit_type)
+static inline void bnx2x_set_pbd_gso_e2(struct sk_buff *skb, u32 *parsing_data,
+					u32 xmit_type)
 {
-	pbd->parsing_data |= cpu_to_le16(skb_shinfo(skb)->gso_size) <<
-		ETH_TX_PARSE_BD_E2_LSO_MSS_SHIFT;
+	*parsing_data |= (skb_shinfo(skb)->gso_size <<
+			      ETH_TX_PARSE_BD_E2_LSO_MSS_SHIFT) &
+			      ETH_TX_PARSE_BD_E2_LSO_MSS;
 	if ((xmit_type & XMIT_GSO_V6) &&
 	    (ipv6_hdr(skb)->nexthdr == NEXTHDR_IPV6))
-		pbd->parsing_data |= ETH_TX_PARSE_BD_E2_IPV6_WITH_EXT_HDR;
+		*parsing_data |= ETH_TX_PARSE_BD_E2_IPV6_WITH_EXT_HDR;
 }
 
 /**
@@ -1835,15 +1835,15 @@ static inline void bnx2x_set_pbd_gso(struct sk_buff *skb,
  * @return header len
  */
 static inline  u8 bnx2x_set_pbd_csum_e2(struct bnx2x *bp, struct sk_buff *skb,
-	struct eth_tx_parse_bd_e2 *pbd,
-	u32 xmit_type)
+	u32 *parsing_data, u32 xmit_type)
 {
-	pbd->parsing_data |= cpu_to_le16(tcp_hdrlen(skb)/4) <<
-		ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW_SHIFT;
+	*parsing_data |= ((tcp_hdrlen(skb)/4) <<
+		ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW_SHIFT) &
+		ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW;
 
-	pbd->parsing_data |= cpu_to_le16(((unsigned char *)tcp_hdr(skb) -
-					  skb->data) / 2) <<
-		ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W_SHIFT;
+	*parsing_data |= ((((u8 *)tcp_hdr(skb) - skb->data) / 2) <<
+		ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W_SHIFT) &
+		ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W;
 
 	return skb_transport_header(skb) + tcp_hdrlen(skb) - skb->data;
 }
@@ -1912,6 +1912,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
 	struct eth_tx_parse_bd_e1x *pbd_e1x = NULL;
 	struct eth_tx_parse_bd_e2 *pbd_e2 = NULL;
+	u32 pbd_e2_parsing_data = 0;
 	u16 pkt_prod, bd_prod;
 	int nbd, fp_index;
 	dma_addr_t mapping;
@@ -2033,8 +2034,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		memset(pbd_e2, 0, sizeof(struct eth_tx_parse_bd_e2));
 		/* Set PBD in checksum offload case */
 		if (xmit_type & XMIT_CSUM)
-			hlen = bnx2x_set_pbd_csum_e2(bp,
-						     skb, pbd_e2, xmit_type);
+			hlen = bnx2x_set_pbd_csum_e2(bp, skb,
+						     &pbd_e2_parsing_data,
+						     xmit_type);
 	} else {
 		pbd_e1x = &fp->tx_desc_ring[bd_prod].parse_bd_e1x;
 		memset(pbd_e1x, 0, sizeof(struct eth_tx_parse_bd_e1x));
@@ -2076,10 +2078,18 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			bd_prod = bnx2x_tx_split(bp, fp, tx_buf, &tx_start_bd,
 						 hlen, bd_prod, ++nbd);
 		if (CHIP_IS_E2(bp))
-			bnx2x_set_pbd_gso_e2(skb, pbd_e2, xmit_type);
+			bnx2x_set_pbd_gso_e2(skb, &pbd_e2_parsing_data,
+					     xmit_type);
 		else
 			bnx2x_set_pbd_gso(skb, pbd_e1x, xmit_type);
 	}
+
+	/* Set the PBD's parsing_data field if not zero
+	 * (for the chips newer than 57711).
+	 */
+	if (pbd_e2_parsing_data)
+		pbd_e2->parsing_data = cpu_to_le32(pbd_e2_parsing_data);
+
 	tx_data_bd = (struct eth_tx_bd *)tx_start_bd;
 
 	/* Handle fragmented skb */
-- 
1.7.0.4




