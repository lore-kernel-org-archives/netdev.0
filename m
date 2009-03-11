From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/4] qlge: bugfix: Increase filter on inbound csum.
Date: Wed, 11 Mar 2009 14:55:40 -0700
Message-ID: <1236808543-11165-2-git-send-email-ron.mercer@qlogic.com>
References: <1236808543-11165-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:2059 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017AbZCKV7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:59:33 -0400
In-Reply-To: <1236808543-11165-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chip does not do UDP checksum when fragmentation occurs.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    1 +
 drivers/net/qlge/qlge_main.c |   38 ++++++++++++++++++++++++++------------
 2 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index e6fdce9..aff9c5f 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -927,6 +927,7 @@ struct ib_mac_iocb_rsp {
 	u8 flags1;
 #define IB_MAC_IOCB_RSP_OI	0x01	/* Overide intr delay */
 #define IB_MAC_IOCB_RSP_I	0x02	/* Disble Intr Generation */
+#define IB_MAC_CSUM_ERR_MASK 0x1c	/* A mask to use for csum errs */
 #define IB_MAC_IOCB_RSP_TE	0x04	/* Checksum error */
 #define IB_MAC_IOCB_RSP_NU	0x08	/* No checksum rcvd */
 #define IB_MAC_IOCB_RSP_IE	0x10	/* IPv4 checksum error */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 8ea72dc..87787b1 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1436,18 +1436,32 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_P) {
 		QPRINTK(qdev, RX_STATUS, DEBUG, "Promiscuous Packet.\n");
 	}
-	if (ib_mac_rsp->flags1 & (IB_MAC_IOCB_RSP_IE | IB_MAC_IOCB_RSP_TE)) {
-		QPRINTK(qdev, RX_STATUS, ERR,
-			"Bad checksum for this %s packet.\n",
-			((ib_mac_rsp->
-			  flags2 & IB_MAC_IOCB_RSP_T) ? "TCP" : "UDP"));
-		skb->ip_summed = CHECKSUM_NONE;
-	} else if (qdev->rx_csum &&
-		   ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) ||
-		    ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) &&
-		     !(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_NU)))) {
-		QPRINTK(qdev, RX_STATUS, DEBUG, "RX checksum done!\n");
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	skb->protocol = eth_type_trans(skb, ndev);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* If rx checksum is on, and there are no
+	 * csum or frame errors.
+	 */
+	if (qdev->rx_csum &&
+		!(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) &&
+		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
+		/* TCP frame. */
+		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
+			QPRINTK(qdev, RX_STATUS, DEBUG,
+					"TCP checksum done!\n");
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		} else if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) &&
+				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
+		/* Unfragmented ipv4 UDP frame. */
+			struct iphdr *iph = (struct iphdr *) skb->data;
+			if (!(iph->frag_off &
+				cpu_to_be16(IP_MF|IP_OFFSET))) {
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				QPRINTK(qdev, RX_STATUS, DEBUG,
+						"TCP checksum done!\n");
+			}
+		}
 	}
 	qdev->stats.rx_packets++;
 	qdev->stats.rx_bytes += skb->len;
-- 
1.6.0.2

