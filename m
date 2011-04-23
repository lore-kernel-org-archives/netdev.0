From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6] bnx2x: fix UDP csum offload
Date: Sat, 23 Apr 2011 20:44:46 +0300
Message-ID: <1303580687.2708.40.camel@lb-tlvb-dmitry.il.broadcom.com>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3629 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab1DWRpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Apr 2011 13:45:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

Fixed packets parameters for FW in UDP checksum offload flow.

Do not dereference TCP headers on non TCP frames.
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>  

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   34 ++++++++++++++++++++++++----------
 1 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index e83ac6d..16581df 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2019,15 +2019,23 @@ static inline void bnx2x_set_pbd_gso(struct sk_buff *skb,
 static inline  u8 bnx2x_set_pbd_csum_e2(struct bnx2x *bp, struct sk_buff *skb,
 	u32 *parsing_data, u32 xmit_type)
 {
-	*parsing_data |= ((tcp_hdrlen(skb)/4) <<
-		ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW_SHIFT) &
-		ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW;
+	*parsing_data |=
+			((((u8 *)skb_transport_header(skb) - skb->data) >> 1) <<
+			ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W_SHIFT) &
+			ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W;
 
-	*parsing_data |= ((((u8 *)tcp_hdr(skb) - skb->data) / 2) <<
-		ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W_SHIFT) &
-		ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W;
+	if (xmit_type & XMIT_CSUM_TCP) {
+		*parsing_data |= ((tcp_hdrlen(skb) / 4) <<
+			ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW_SHIFT) &
+			ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW;
 
-	return skb_transport_header(skb) + tcp_hdrlen(skb) - skb->data;
+		return skb_transport_header(skb) + tcp_hdrlen(skb) - skb->data;
+	} else
+		/* We support checksum offload for TCP and UDP only.
+		 * No need to pass the UDP header length - it's a constant.
+		 */
+		return skb_transport_header(skb) +
+				sizeof(struct udphdr) - skb->data;
 }
 
 /**
@@ -2043,7 +2051,7 @@ static inline u8 bnx2x_set_pbd_csum(struct bnx2x *bp, struct sk_buff *skb,
 	struct eth_tx_parse_bd_e1x *pbd,
 	u32 xmit_type)
 {
-	u8 hlen = (skb_network_header(skb) - skb->data) / 2;
+	u8 hlen = (skb_network_header(skb) - skb->data) >> 1;
 
 	/* for now NS flag is not used in Linux */
 	pbd->global_data =
@@ -2051,9 +2059,15 @@ static inline u8 bnx2x_set_pbd_csum(struct bnx2x *bp, struct sk_buff *skb,
 			 ETH_TX_PARSE_BD_E1X_LLC_SNAP_EN_SHIFT));
 
 	pbd->ip_hlen_w = (skb_transport_header(skb) -
-			skb_network_header(skb)) / 2;
+			skb_network_header(skb)) >> 1;
 
-	hlen += pbd->ip_hlen_w + tcp_hdrlen(skb) / 2;
+	hlen += pbd->ip_hlen_w;
+
+	/* We support checksum offload for TCP and UDP only */
+	if (xmit_type & XMIT_CSUM_TCP)
+		hlen += tcp_hdrlen(skb) / 2;
+	else
+		hlen += sizeof(struct udphdr) / 2;
 
 	pbd->total_hlen_w = cpu_to_le16(hlen);
 	hlen = hlen*2;
-- 
1.7.2.2




