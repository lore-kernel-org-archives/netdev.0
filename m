From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH] net: fec: remove HW IP header checksum for IPV6 frame
Date: Tue, 17 Jun 2014 16:31:35 +0800
Message-ID: <1402993895-10955-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux@arm.linux.org.uk>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0208.outbound.protection.outlook.com ([207.46.163.208]:18913
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751147AbaFQJ7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2014 05:59:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 96c50caa5148 (net: fec: Enable IP header hardware checksum)
enable HW IP header checksum for IPV4 and IPV6, which causes IPV6 TCP/UDP
cannot work. (The issue is reported by Russell King)

The reason is that FEC HW IP cannot detect the transmit frame type (can
detect received frame type), and treats all packets as IPv4, overwrites
the point in the packet which would be the IPv4 checksum field. Since IPV6
don't have IP header checksum, so this results in the frame being corrupted.

The patch just add software detect the current packet type, if it is IPV6
frame, it don't enable IP header checksum.

Cc: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   36 +++++++++++++++++++++-------
 1 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 38d9d27..c13185a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -320,6 +320,11 @@ static void *swap_buffer(void *bufaddr, int len)
 	return bufaddr;
 }
 
+static inline bool is_ipv4_pkt(struct sk_buff *skb)
+{
+	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
+}
+
 static int
 fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 {
@@ -330,7 +335,8 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(skb_cow_head(skb, 0)))
 		return -1;
 
-	ip_hdr(skb)->check = 0;
+	if (is_ipv4_pkt(skb))
+		ip_hdr(skb)->check = 0;
 	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
 
 	return 0;
@@ -391,8 +397,11 @@ fec_enet_txq_submit_frag_skb(struct sk_buff *skb, struct net_device *ndev)
 		}
 
 		if (fep->bufdesc_ex) {
-			if (skb->ip_summed == CHECKSUM_PARTIAL)
-				estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+			if (skb->ip_summed == CHECKSUM_PARTIAL) {
+				estatus |= BD_ENET_TX_PINS;
+				if (is_ipv4_pkt(skb))
+					estatus |= BD_ENET_TX_IINS;
+			}
 			ebdp->cbd_bdu = 0;
 			ebdp->cbd_esc = estatus;
 		}
@@ -518,8 +527,11 @@ static int fec_enet_txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
 			fep->hwts_tx_en))
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
-		if (skb->ip_summed == CHECKSUM_PARTIAL)
-			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			estatus |= BD_ENET_TX_PINS;
+			if (is_ipv4_pkt(skb))
+				estatus |= BD_ENET_TX_IINS;
+		}
 
 		ebdp->cbd_bdu = 0;
 		ebdp->cbd_esc = estatus;
@@ -590,8 +602,11 @@ fec_enet_txq_put_data_tso(struct sk_buff *skb, struct net_device *ndev,
 	}
 
 	if (fep->bufdesc_ex) {
-		if (skb->ip_summed == CHECKSUM_PARTIAL)
-			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			estatus |= BD_ENET_TX_PINS;
+			if (is_ipv4_pkt(skb))
+				estatus |= BD_ENET_TX_IINS;
+		}
 		ebdp->cbd_bdu = 0;
 		ebdp->cbd_esc = estatus;
 	}
@@ -652,8 +667,11 @@ fec_enet_txq_put_hdr_tso(struct sk_buff *skb, struct net_device *ndev,
 	bdp->cbd_datlen = hdr_len;
 
 	if (fep->bufdesc_ex) {
-		if (skb->ip_summed == CHECKSUM_PARTIAL)
-			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			estatus |= BD_ENET_TX_PINS;
+			if (is_ipv4_pkt(skb))
+				estatus |= BD_ENET_TX_IINS;
+		}
 		ebdp->cbd_bdu = 0;
 		ebdp->cbd_esc = estatus;
 	}
-- 
1.7.8
