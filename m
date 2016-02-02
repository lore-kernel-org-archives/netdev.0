From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/2] sunvnet: perf tracepoint invocations to trace LDC state machine
Date: Tue,  2 Feb 2016 10:41:56 -0800
Message-ID: <8234ebc9d20a7a42bb664d1db25913cb7c34dbfb.1454416592.git.sowmini.varadhan@oracle.com>
References: <cover.1454416592.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
	david.stevens@oracle.com, aaron.young@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30405 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbcBBSmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:42:37 -0500
In-Reply-To: <cover.1454416592.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1454416592.git.sowmini.varadhan@oracle.com>
References: <cover.1454416592.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use sunvnet perf trace macros to monitor LDC message exchange state.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 23fa298..942a95d 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -17,6 +17,8 @@
 #include <linux/mutex.h>
 #include <linux/highmem.h>
 #include <linux/if_vlan.h>
+#define CREATE_TRACE_POINTS
+#include <trace/events/sunvnet.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <linux/icmpv6.h>
@@ -540,6 +542,8 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 	err = vnet_rx_one(port, desc);
 	if (err == -ECONNRESET)
 		return err;
+	trace_vnet_rx_one(port->vio._local_sid, port->vio._peer_sid,
+			  index, desc->hdr.ack);
 	desc->hdr.state = VIO_DESC_DONE;
 	err = put_rx_desc(port, dr, desc, index);
 	if (err < 0)
@@ -587,9 +591,15 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
 		ack_start = ack_end = vio_dring_prev(dr, start);
 	if (send_ack) {
 		port->napi_resume = false;
+		trace_vnet_tx_send_stopped_ack(port->vio._local_sid,
+					       port->vio._peer_sid,
+					       ack_end, *npkts);
 		return vnet_send_ack(port, dr, ack_start, ack_end,
 				     VIO_DRING_STOPPED);
 	} else  {
+		trace_vnet_tx_defer_stopped_ack(port->vio._local_sid,
+						port->vio._peer_sid,
+						ack_end, *npkts);
 		port->napi_resume = true;
 		port->napi_stop_idx = ack_end;
 		return 1;
@@ -663,6 +673,8 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	/* sync for race conditions with vnet_start_xmit() and tell xmit it
 	 * is time to send a trigger.
 	 */
+	trace_vnet_rx_stopped_ack(port->vio._local_sid,
+				  port->vio._peer_sid, end);
 	dr->cons = vio_dring_next(dr, end);
 	desc = vio_dring_entry(dr, dr->cons);
 	if (desc->hdr.state == VIO_DESC_READY && !port->start_cons) {
@@ -886,6 +898,9 @@ static int __vnet_tx_trigger(struct vnet_port *port, u32 start)
 	int retries = 0;
 
 	if (port->stop_rx) {
+		trace_vnet_tx_pending_stopped_ack(port->vio._local_sid,
+						  port->vio._peer_sid,
+						  port->stop_rx_idx, -1);
 		err = vnet_send_ack(port,
 				    &port->vio.drings[VIO_DRIVER_RX_RING],
 				    port->stop_rx_idx, -1,
@@ -908,6 +923,8 @@ static int __vnet_tx_trigger(struct vnet_port *port, u32 start)
 		if (retries++ > VNET_MAX_RETRIES)
 			break;
 	} while (err == -EAGAIN);
+	trace_vnet_tx_trigger(port->vio._local_sid,
+			      port->vio._peer_sid, start, err);
 
 	return err;
 }
@@ -1414,8 +1431,11 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * producer to consumer announcement that work is available to the
 	 * consumer
 	 */
-	if (!port->start_cons)
-		goto ldc_start_done; /* previous trigger suffices */
+	if (!port->start_cons) { /* previous trigger suffices */
+		trace_vnet_skip_tx_trigger(port->vio._local_sid,
+					   port->vio._peer_sid, dr->cons);
+		goto ldc_start_done;
+	}
 
 	err = __vnet_tx_trigger(port, dr->cons);
 	if (unlikely(err < 0)) {
-- 
1.7.1
