From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 5/8] amd-xgbe: Add BQL support
Date: Thu, 20 Nov 2014 11:03:50 -0600
Message-ID: <20141120170350.15397.41042.stgit@tlendack-t1.amdoffice.net>
References: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0106.outbound.protection.outlook.com ([157.56.110.106]:28192
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758000AbaKTRDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 12:03:55 -0500
In-Reply-To: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call the appropriate BQL functions to track the number of bytes queued
during Tx processing and to track the number of packets and bytes
that have been transmitted during Tx complete processing.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    4 +++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   43 +++++++++++++++++++++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    5 +++
 3 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 2908ad1..78db5a6 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1500,6 +1500,10 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	/* Set LAST bit for the last descriptor */
 	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, LD, 1);
 
+	/* Save the Tx info to report back during cleanup */
+	rdata->tx.packets = packet->tx_packets;
+	rdata->tx.bytes = packet->tx_bytes;
+
 	/* In case the Tx DMA engine is running, make sure everything
 	 * is written to the descriptor(s) before setting the OWN bit
 	 * for the first descriptor
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 46ea423..f963528 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -876,7 +876,10 @@ static int xgbe_start(struct xgbe_prv_data *pdata)
 static void xgbe_stop(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_channel *channel;
 	struct net_device *netdev = pdata->netdev;
+	struct netdev_queue *txq;
+	unsigned int i;
 
 	DBGPR("-->xgbe_stop\n");
 
@@ -890,6 +893,15 @@ static void xgbe_stop(struct xgbe_prv_data *pdata)
 	hw_if->disable_tx(pdata);
 	hw_if->disable_rx(pdata);
 
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			continue;
+
+		txq = netdev_get_tx_queue(netdev, channel->queue_index);
+		netdev_tx_reset_queue(txq);
+	}
+
 	DBGPR("<--xgbe_stop\n");
 }
 
@@ -1156,6 +1168,12 @@ static int xgbe_prep_tso(struct sk_buff *skb, struct xgbe_packet_data *packet)
 	      packet->tcp_header_len, packet->tcp_payload_len);
 	DBGPR("  packet->mss=%u\n", packet->mss);
 
+	/* Update the number of packets that will ultimately be transmitted
+	 * along with the extra bytes for each extra packet
+	 */
+	packet->tx_packets = skb_shinfo(skb)->gso_segs;
+	packet->tx_bytes += (packet->tx_packets - 1) * packet->header_len;
+
 	return 0;
 }
 
@@ -1184,6 +1202,9 @@ static void xgbe_packet_info(struct xgbe_prv_data *pdata,
 	context_desc = 0;
 	packet->rdesc_count = 0;
 
+	packet->tx_packets = 1;
+	packet->tx_bytes = skb->len;
+
 	if (xgbe_is_tso(skb)) {
 		/* TSO requires an extra descriptor if mss is different */
 		if (skb_shinfo(skb)->gso_size != ring->tx.cur_mss) {
@@ -1400,12 +1421,14 @@ static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct xgbe_channel *channel;
 	struct xgbe_ring *ring;
 	struct xgbe_packet_data *packet;
+	struct netdev_queue *txq;
 	unsigned long flags;
 	int ret;
 
 	DBGPR("-->xgbe_xmit: skb->len = %d\n", skb->len);
 
 	channel = pdata->channel + skb->queue_mapping;
+	txq = netdev_get_tx_queue(netdev, channel->queue_index);
 	ring = channel->tx_ring;
 	packet = &ring->packet_data;
 
@@ -1447,6 +1470,9 @@ static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	xgbe_prep_tx_tstamp(pdata, skb, packet);
 
+	/* Report on the actual number of bytes (to be) sent */
+	netdev_tx_sent_queue(txq, packet->tx_bytes);
+
 	/* Configure required descriptor fields for transmission */
 	hw_if->dev_xmit(channel);
 
@@ -1772,8 +1798,10 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 	struct xgbe_ring_data *rdata;
 	struct xgbe_ring_desc *rdesc;
 	struct net_device *netdev = pdata->netdev;
+	struct netdev_queue *txq;
 	unsigned long flags;
 	int processed = 0;
+	unsigned int tx_packets = 0, tx_bytes = 0;
 
 	DBGPR("-->xgbe_tx_poll\n");
 
@@ -1781,6 +1809,8 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 	if (!ring)
 		return 0;
 
+	txq = netdev_get_tx_queue(netdev, channel->queue_index);
+
 	spin_lock_irqsave(&ring->lock, flags);
 
 	while ((processed < XGBE_TX_DESC_MAX_PROC) &&
@@ -1799,6 +1829,11 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 		xgbe_dump_tx_desc(ring, ring->dirty, 1, 0);
 #endif
 
+		if (hw_if->is_last_desc(rdesc)) {
+			tx_packets += rdata->tx.packets;
+			tx_bytes += rdata->tx.bytes;
+		}
+
 		/* Free the SKB and reset the descriptor for re-use */
 		desc_if->unmap_rdata(pdata, rdata);
 		hw_if->tx_desc_reset(rdata);
@@ -1807,14 +1842,20 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 		ring->dirty++;
 	}
 
+	if (!processed)
+		goto unlock;
+
+	netdev_tx_completed_queue(txq, tx_packets, tx_bytes);
+
 	if ((ring->tx.queue_stopped == 1) &&
 	    (xgbe_tx_avail_desc(ring) > XGBE_TX_DESC_MIN_FREE)) {
 		ring->tx.queue_stopped = 0;
-		netif_wake_subqueue(netdev, channel->queue_index);
+		netif_tx_wake_queue(txq);
 	}
 
 	DBGPR("<--xgbe_tx_poll: processed=%d\n", processed);
 
+unlock:
 	spin_unlock_irqrestore(&ring->lock, flags);
 
 	return processed;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 41ce6e3..98504f1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -243,6 +243,9 @@ struct xgbe_packet_data {
 
 	u32 rss_hash;
 	enum pkt_hash_types rss_hash_type;
+
+	unsigned int tx_packets;
+	unsigned int tx_bytes;
 };
 
 /* Common Rx and Tx descriptor mapping */
@@ -274,6 +277,8 @@ struct xgbe_buffer_data {
 /* Tx-related ring data */
 struct xgbe_tx_ring_data {
 	unsigned int tso_header;	/* TSO header indicator */
+	unsigned int packets;		/* BQL packet count */
+	unsigned int bytes;		/* BQL byte count */
 };
 
 /* Rx-related ring data */
