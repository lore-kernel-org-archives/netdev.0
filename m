From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 2/3] gianfar: Make FCB access endian safe
Date: Fri, 13 Mar 2015 10:36:29 +0200
Message-ID: <1426235790-7011-3-git-send-email-claudiu.manoil@freescale.com>
References: <1426235790-7011-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0119.outbound.protection.outlook.com ([157.56.110.119]:38359
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751247AbbCMIhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 04:37:16 -0400
In-Reply-To: <1426235790-7011-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use conversion macros to correctly access the BE
fields of the Rx and Tx Frame Control Block on LE CPUs.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 17 +++++++++--------
 drivers/net/ethernet/freescale/gianfar.h |  8 ++++----
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index af063d8..5d6883d 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2169,16 +2169,16 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
 	 */
 	if (ip_hdr(skb)->protocol == IPPROTO_UDP) {
 		flags |= TXFCB_UDP;
-		fcb->phcs = udp_hdr(skb)->check;
+		fcb->phcs = (__force __be16)(udp_hdr(skb)->check);
 	} else
-		fcb->phcs = tcp_hdr(skb)->check;
+		fcb->phcs = (__force __be16)(tcp_hdr(skb)->check);
 
 	/* l3os is the distance between the start of the
 	 * frame (skb->data) and the start of the IP hdr.
 	 * l4os is the distance between the start of the
 	 * l3 hdr and the l4 hdr
 	 */
-	fcb->l3os = (u16)(skb_network_offset(skb) - fcb_length);
+	fcb->l3os = (u8)(skb_network_offset(skb) - fcb_length);
 	fcb->l4os = skb_network_header_len(skb);
 
 	fcb->flags = flags;
@@ -2187,7 +2187,7 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
 void inline gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
 {
 	fcb->flags |= TXFCB_VLN;
-	fcb->vlctl = skb_vlan_tag_get(skb);
+	fcb->vlctl = cpu_to_be16(skb_vlan_tag_get(skb));
 }
 
 static inline struct txbd8 *skip_txbd(struct txbd8 *bdp, int stride,
@@ -2812,13 +2812,13 @@ static inline void gfar_rx_checksum(struct sk_buff *skb, struct rxfcb *fcb)
 	 * were verified, then we tell the kernel that no
 	 * checksumming is necessary.  Otherwise, it is [FIXME]
 	 */
-	if ((fcb->flags & RXFCB_CSUM_MASK) == (RXFCB_CIP | RXFCB_CTU))
+	if ((be16_to_cpu(fcb->flags) & RXFCB_CSUM_MASK) ==
+	    (RXFCB_CIP | RXFCB_CTU))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	else
 		skb_checksum_none_assert(skb);
 }
 
-
 /* gfar_process_frame() -- handle one incoming packet if skb isn't NULL. */
 static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 			       int amount_pull, struct napi_struct *napi)
@@ -2860,8 +2860,9 @@ static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	 * RXFCB_VLN is pseudo randomly set.
 	 */
 	if (dev->features & NETIF_F_HW_VLAN_CTAG_RX &&
-	    fcb->flags & RXFCB_VLN)
-		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), fcb->vlctl);
+	    be16_to_cpu(fcb->flags) & RXFCB_VLN)
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       be16_to_cpu(fcb->vlctl));
 
 	/* Send the packet up the stack */
 	napi_gro_receive(napi, skb);
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index f792c79..daa1d37 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -557,8 +557,8 @@ struct txfcb {
 	u8	ptp;    /* Flag to enable tx timestamping */
 	u8	l4os;	/* Level 4 Header Offset */
 	u8	l3os; 	/* Level 3 Header Offset */
-	u16	phcs;	/* Pseudo-header Checksum */
-	u16	vlctl;	/* VLAN control word */
+	__be16	phcs;	/* Pseudo-header Checksum */
+	__be16	vlctl;	/* VLAN control word */
 };
 
 struct rxbd8
@@ -574,11 +574,11 @@ struct rxbd8
 };
 
 struct rxfcb {
-	u16	flags;
+	__be16	flags;
 	u8	rq;	/* Receive Queue index */
 	u8	pro;	/* Layer 4 Protocol */
 	u16	reserved;
-	u16	vlctl;	/* VLAN control word */
+	__be16	vlctl;	/* VLAN control word */
 };
 
 struct gianfar_skb_cb {
-- 
1.7.11.7
