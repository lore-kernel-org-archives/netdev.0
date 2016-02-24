From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/6] qede: Linearize SKBs when needed
Date: Wed, 24 Feb 2016 16:52:46 +0200
Message-ID: <1456325570-1514-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:58289 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753475AbcBXOxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 09:53:05 -0500
In-Reply-To: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a corner-case in HW where an SKB queued for transmission that
contains too many frags will cause FW to assert.
This patch solves this by linearizing the SKB if necessary.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 38 ++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 76fa5d7..f07b9a9 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -380,6 +380,28 @@ static int map_frag_to_bd(struct qede_dev *edev,
 	return 0;
 }
 
+/* +2 for 1st BD for headers and 2nd BD for headlen (if required) */
+#if ((MAX_SKB_FRAGS + 2) > ETH_TX_MAX_BDS_PER_NON_LSO_PACKET)
+static bool qede_pkt_req_lin(struct qede_dev *edev, struct sk_buff *skb,
+			     u8 xmit_type)
+{
+	int allowed_frags = ETH_TX_MAX_BDS_PER_NON_LSO_PACKET - 1;
+
+	if (xmit_type & XMIT_LSO) {
+		int hlen;
+
+		hlen = skb_transport_header(skb) +
+		       tcp_hdrlen(skb) - skb->data;
+
+		/* linear payload would require its own BD */
+		if (skb_headlen(skb) > hlen)
+			allowed_frags--;
+	}
+
+	return (skb_shinfo(skb)->nr_frags > allowed_frags);
+}
+#endif
+
 /* Main transmit function */
 static
 netdev_tx_t qede_start_xmit(struct sk_buff *skb,
@@ -407,16 +429,22 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 	txq = QEDE_TX_QUEUE(edev, txq_index);
 	netdev_txq = netdev_get_tx_queue(ndev, txq_index);
 
-	/* Current code doesn't support SKB linearization, since the max number
-	 * of skb frags can be passed in the FW HSI.
-	 */
-	BUILD_BUG_ON(MAX_SKB_FRAGS > ETH_TX_MAX_BDS_PER_NON_LSO_PACKET);
-
 	WARN_ON(qed_chain_get_elem_left(&txq->tx_pbl) <
 			       (MAX_SKB_FRAGS + 1));
 
 	xmit_type = qede_xmit_type(edev, skb, &ipv6_ext);
 
+#if ((MAX_SKB_FRAGS + 2) > ETH_TX_MAX_BDS_PER_NON_LSO_PACKET)
+	if (qede_pkt_req_lin(edev, skb, xmit_type)) {
+		if (skb_linearize(skb)) {
+			DP_NOTICE(edev,
+				  "SKB linearization failed - silently dropping this SKB\n");
+			dev_kfree_skb_any(skb);
+			return NETDEV_TX_OK;
+		}
+	}
+#endif
+
 	/* Fill the entry in the SW ring and the BDs in the FW ring */
 	idx = txq->sw_tx_prod & NUM_TX_BDS_MAX;
 	txq->sw_tx_ring[idx].skb = skb;
-- 
1.9.3
