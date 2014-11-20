From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 7/8] amd-xgbe: Perform Tx coalescing on a packet
 basis
Date: Thu, 20 Nov 2014 11:04:02 -0600
Message-ID: <20141120170402.15397.62300.stgit@tlendack-t1.amdoffice.net>
References: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0144.outbound.protection.outlook.com ([157.56.111.144]:63360
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758000AbaKTREK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 12:04:10 -0500
In-Reply-To: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current form of Tx coalescing works on a descriptor basis instead
of on a packet basis and doesn't take into account TSO packets. Update
the Tx coalescing support to work on a packet basis, taking into
account the number of packets associated with a TSO transmit. Also,
only activate the Tx timer if a timer value is set.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   46 +++++++++++++++++-------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 78db5a6..b3d2433 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1334,7 +1334,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	struct xgbe_packet_data *packet = &ring->packet_data;
 	unsigned int csum, tso, vlan;
 	unsigned int tso_context, vlan_context;
-	unsigned int tx_coalesce, tx_frames;
+	unsigned int tx_set_ic;
 	int start_index = ring->cur;
 	int i;
 
@@ -1357,10 +1357,26 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	else
 		vlan_context = 0;
 
-	tx_coalesce = (pdata->tx_usecs || pdata->tx_frames) ? 1 : 0;
-	tx_frames = pdata->tx_frames;
-	if (tx_coalesce && !channel->tx_timer_active)
-		ring->coalesce_count = 0;
+	/* Determine if an interrupt should be generated for this Tx:
+	 *   Interrupt:
+	 *     - Tx frame count exceeds the frame count setting
+	 *     - Addition of Tx frame count to the frame count since the
+	 *       last interrupt was set exceeds the frame count setting
+	 *   No interrupt:
+	 *     - No frame count setting specified (ethtool -C ethX tx-frames 0)
+	 *     - Addition of Tx frame count to the frame count since the
+	 *       last interrupt was set does not exceed the frame count setting
+	 */
+	ring->coalesce_count += packet->tx_packets;
+	if (!pdata->tx_frames)
+		tx_set_ic = 0;
+	else if (packet->tx_packets > pdata->tx_frames)
+		tx_set_ic = 1;
+	else if ((ring->coalesce_count % pdata->tx_frames) <
+		 packet->tx_packets)
+		tx_set_ic = 1;
+	else
+		tx_set_ic = 0;
 
 	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 	rdesc = rdata->rdesc;
@@ -1427,13 +1443,6 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	if (XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES, PTP))
 		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, TTSE, 1);
 
-	/* Set IC bit based on Tx coalescing settings */
-	XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 1);
-	if (tx_coalesce && (!tx_frames ||
-			    (++ring->coalesce_count % tx_frames)))
-		/* Clear IC bit */
-		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 0);
-
 	/* Mark it as First Descriptor */
 	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, FD, 1);
 
@@ -1478,13 +1487,6 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, HL_B1L,
 				  rdata->skb_dma_len);
 
-		/* Set IC bit based on Tx coalescing settings */
-		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 1);
-		if (tx_coalesce && (!tx_frames ||
-				    (++ring->coalesce_count % tx_frames)))
-			/* Clear IC bit */
-			XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 0);
-
 		/* Set OWN bit */
 		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, OWN, 1);
 
@@ -1500,6 +1502,10 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	/* Set LAST bit for the last descriptor */
 	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, LD, 1);
 
+	/* Set IC bit based on Tx coalescing settings */
+	if (tx_set_ic)
+		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 1);
+
 	/* Save the Tx info to report back during cleanup */
 	rdata->tx.packets = packet->tx_packets;
 	rdata->tx.bytes = packet->tx_bytes;
@@ -1530,7 +1536,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 			  lower_32_bits(rdata->rdesc_dma));
 
 	/* Start the Tx coalescing timer */
-	if (tx_coalesce && !channel->tx_timer_active) {
+	if (pdata->tx_usecs && !channel->tx_timer_active) {
 		channel->tx_timer_active = 1;
 		hrtimer_start(&channel->tx_timer,
 			      ktime_set(0, pdata->tx_usecs * NSEC_PER_USEC),
