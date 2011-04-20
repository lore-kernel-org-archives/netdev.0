From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH] bnx2x: dont dereference tcp header on non tcp
 frames
Date: Wed, 20 Apr 2011 12:40:10 +0300
Message-ID: <1303292410.1813.23.camel@lb-tlvb-dmitry>
References: <1303229503.3480.386.camel@edumazet-laptop>
 <1303284713.3186.13.camel@edumazet-laptop>
 <20110420.014657.232735224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2418 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792Ab1DTJl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 05:41:26 -0400
In-Reply-To: <20110420.014657.232735224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-20 at 01:46 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 20 Apr 2011 09:31:53 +0200
> 
> > [PATCH] bnx2x: dont dereference tcp header on non tcp frames
> > 
> > bnx2x_set_pbd_csum() & bnx2x_set_pbd_csum_e2() use 
> > tcp_hdrlen(skb) even for non TCP frames
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Broadcom folks please review.
> 

Following patch fixes udp checksum offload flow and also addresses
issues raised by Eric. We are testing it now.

From: Vladislav Zolotarov <vladz@broadcom.com>

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




