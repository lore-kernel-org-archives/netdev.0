From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 2/2] amd-xgbe: Fix napi Rx budget accounting
Date: Wed, 22 Oct 2014 11:26:17 -0500
Message-ID: <20141022162617.31495.96409.stgit@tlendack-t1.amdoffice.net>
References: <20141022162605.31495.98889.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0130.outbound.protection.outlook.com ([157.56.110.130]:21108
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751513AbaJVQlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 12:41:00 -0400
In-Reply-To: <20141022162605.31495.98889.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the amd-xgbe driver increments the packets processed counter
each time a descriptor is processed.  Since a packet can be represented
by more than one descriptor incrementing the counter in this way is not
appropriate.  Also, since multiple descriptors cause the budget check
to be short circuited, sometimes the returned value from the poll
function would be larger than the budget value resulting in a WARN_ONCE
being triggered.

Update the polling logic to properly account for the number of packets
processed and exit when the budget value is reached.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index a480b23..2349ea9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1598,7 +1598,8 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 	struct skb_shared_hwtstamps *hwtstamps;
 	unsigned int incomplete, error, context_next, context;
 	unsigned int len, put_len, max_len;
-	int received = 0;
+	unsigned int received = 0;
+	int packet_count = 0;
 
 	DBGPR("-->xgbe_rx_poll: budget=%d\n", budget);
 
@@ -1608,7 +1609,7 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 
 	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 	packet = &ring->packet_data;
-	while (received < budget) {
+	while (packet_count < budget) {
 		DBGPR("  cur = %d\n", ring->cur);
 
 		/* First time in loop see if we need to restore state */
@@ -1662,7 +1663,7 @@ read_again:
 			if (packet->errors)
 				DBGPR("Error in received packet\n");
 			dev_kfree_skb(skb);
-			continue;
+			goto next_packet;
 		}
 
 		if (!context) {
@@ -1677,7 +1678,7 @@ read_again:
 					}
 
 					dev_kfree_skb(skb);
-					continue;
+					goto next_packet;
 				}
 				memcpy(skb_tail_pointer(skb), rdata->skb->data,
 				       put_len);
@@ -1694,7 +1695,7 @@ read_again:
 
 		/* Stray Context Descriptor? */
 		if (!skb)
-			continue;
+			goto next_packet;
 
 		/* Be sure we don't exceed the configured MTU */
 		max_len = netdev->mtu + ETH_HLEN;
@@ -1705,7 +1706,7 @@ read_again:
 		if (skb->len > max_len) {
 			DBGPR("packet length exceeds configured MTU\n");
 			dev_kfree_skb(skb);
-			continue;
+			goto next_packet;
 		}
 
 #ifdef XGMAC_ENABLE_RX_PKT_DUMP
@@ -1739,6 +1740,9 @@ read_again:
 
 		netdev->last_rx = jiffies;
 		napi_gro_receive(&pdata->napi, skb);
+
+next_packet:
+		packet_count++;
 	}
 
 	/* Check if we need to save state before leaving */
@@ -1752,9 +1756,9 @@ read_again:
 		rdata->state.error = error;
 	}
 
-	DBGPR("<--xgbe_rx_poll: received = %d\n", received);
+	DBGPR("<--xgbe_rx_poll: packet_count = %d\n", packet_count);
 
-	return received;
+	return packet_count;
 }
 
 static int xgbe_poll(struct napi_struct *napi, int budget)
