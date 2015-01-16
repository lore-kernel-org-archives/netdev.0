From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 07/12] amd-xgbe: Remove need for Tx path spinlock
Date: Fri, 16 Jan 2015 12:46:55 -0600
Message-ID: <20150116184655.18809.82347.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44026 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756795AbbAPSy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:29 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the Tx ring cleanup can run at the same time that data is being
transmitted, a spin lock was used to protect the ring. This patch
eliminates the need for Tx spinlocks by updating the current ring
position only after all ownership bits for data being transmitted have
been set. This will insure that ring operations in the Tx cleanup path
do not interfere with the ring operations in the Tx transmit path.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   17 +++++++++--------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   21 +--------------------
 2 files changed, 10 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index e424997..5dff127 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1359,6 +1359,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	unsigned int tso_context, vlan_context;
 	unsigned int tx_set_ic;
 	int start_index = ring->cur;
+	int cur_index = ring->cur;
 	int i;
 
 	DBGPR("-->xgbe_dev_xmit\n");
@@ -1401,7 +1402,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	else
 		tx_set_ic = 0;
 
-	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
+	rdata = XGBE_GET_DESC_DATA(ring, cur_index);
 	rdesc = rdata->rdesc;
 
 	/* Create a context descriptor if this is a TSO packet */
@@ -1444,8 +1445,8 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 			ring->tx.cur_vlan_ctag = packet->vlan_ctag;
 		}
 
-		ring->cur++;
-		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
+		cur_index++;
+		rdata = XGBE_GET_DESC_DATA(ring, cur_index);
 		rdesc = rdata->rdesc;
 	}
 
@@ -1473,7 +1474,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, CTXT, 0);
 
 	/* Set OWN bit if not the first descriptor */
-	if (ring->cur != start_index)
+	if (cur_index != start_index)
 		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, OWN, 1);
 
 	if (tso) {
@@ -1497,9 +1498,9 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 				  packet->length);
 	}
 
-	for (i = ring->cur - start_index + 1; i < packet->rdesc_count; i++) {
-		ring->cur++;
-		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
+	for (i = cur_index - start_index + 1; i < packet->rdesc_count; i++) {
+		cur_index++;
+		rdata = XGBE_GET_DESC_DATA(ring, cur_index);
 		rdesc = rdata->rdesc;
 
 		/* Update buffer address */
@@ -1551,7 +1552,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	/* Make sure ownership is written to the descriptor */
 	wmb();
 
-	ring->cur++;
+	ring->cur = cur_index + 1;
 	if (!packet->skb->xmit_more ||
 	    netif_xmit_stopped(netdev_get_tx_queue(pdata->netdev,
 						   channel->queue_index)))
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index e2f560f..c036a0e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -415,17 +415,13 @@ static enum hrtimer_restart xgbe_tx_timer(struct hrtimer *timer)
 	struct xgbe_channel *channel = container_of(timer,
 						    struct xgbe_channel,
 						    tx_timer);
-	struct xgbe_ring *ring = channel->tx_ring;
 	struct xgbe_prv_data *pdata = channel->pdata;
 	struct napi_struct *napi;
-	unsigned long flags;
 
 	DBGPR("-->xgbe_tx_timer\n");
 
 	napi = (pdata->per_channel_irq) ? &channel->napi : &pdata->napi;
 
-	spin_lock_irqsave(&ring->lock, flags);
-
 	if (napi_schedule_prep(napi)) {
 		/* Disable Tx and Rx interrupts */
 		if (pdata->per_channel_irq)
@@ -439,8 +435,6 @@ static enum hrtimer_restart xgbe_tx_timer(struct hrtimer *timer)
 
 	channel->tx_timer_active = 0;
 
-	spin_unlock_irqrestore(&ring->lock, flags);
-
 	DBGPR("<--xgbe_tx_timer\n");
 
 	return HRTIMER_NORESTART;
@@ -1450,7 +1444,6 @@ static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct xgbe_ring *ring;
 	struct xgbe_packet_data *packet;
 	struct netdev_queue *txq;
-	unsigned long flags;
 	int ret;
 
 	DBGPR("-->xgbe_xmit: skb->len = %d\n", skb->len);
@@ -1462,8 +1455,6 @@ static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	ret = NETDEV_TX_OK;
 
-	spin_lock_irqsave(&ring->lock, flags);
-
 	if (skb->len == 0) {
 		netdev_err(netdev, "empty skb received from stack\n");
 		dev_kfree_skb_any(skb);
@@ -1510,10 +1501,6 @@ static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
 	ret = NETDEV_TX_OK;
 
 tx_netdev_return:
-	spin_unlock_irqrestore(&ring->lock, flags);
-
-	DBGPR("<--xgbe_xmit\n");
-
 	return ret;
 }
 
@@ -1841,7 +1828,6 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 	struct xgbe_ring_desc *rdesc;
 	struct net_device *netdev = pdata->netdev;
 	struct netdev_queue *txq;
-	unsigned long flags;
 	int processed = 0;
 	unsigned int tx_packets = 0, tx_bytes = 0;
 
@@ -1853,8 +1839,6 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 
 	txq = netdev_get_tx_queue(netdev, channel->queue_index);
 
-	spin_lock_irqsave(&ring->lock, flags);
-
 	while ((processed < XGBE_TX_DESC_MAX_PROC) &&
 	       (ring->dirty != ring->cur)) {
 		rdata = XGBE_GET_DESC_DATA(ring, ring->dirty);
@@ -1885,7 +1869,7 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 	}
 
 	if (!processed)
-		goto unlock;
+		return 0;
 
 	netdev_tx_completed_queue(txq, tx_packets, tx_bytes);
 
@@ -1897,9 +1881,6 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 
 	DBGPR("<--xgbe_tx_poll: processed=%d\n", processed);
 
-unlock:
-	spin_unlock_irqrestore(&ring->lock, flags);
-
 	return processed;
 }
 
