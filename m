From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 1/3 net-next] sunvnet: Fix race between vnet_start_xmit() and
 vnet_ack()
Date: Sat, 8 Nov 2014 20:41:53 -0500
Message-ID: <20141109014153.GC31217@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, david.stevens@oracle.com
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34854 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaKIBly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2014 20:41:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When vnet_start_xmit() is concurrent with vnet_ack(), we may
have a race that looks like:

    thread 1                              thread 2
    vnet_start_xmit                       vnet_event_napi -> vnet_rx

__vnet_tx_trigger for some desc X
at this point dr->prod == X
                                        peer sends back a stopped ack for X
                                        we process X, but X == dr->prod
                                        so we bail out in vnet_ack with
                                        !idx_is_pending
update dr->prod

As a result of the fact that we never processed the stopped ack for X,
the Tx path is led to incorrectly believe that the peer is still
"started" and reading, but the peer has stopped reading, which will
ultimately end in flow-control assertions.

The fix is to synchronize the above 2 paths  on the netif_tx_lock.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 5c5fb59..deb395a 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -559,15 +559,17 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 		return 0;
 
 	end = pkt->end_idx;
-	if (unlikely(!idx_is_pending(dr, end)))
-		return 0;
-
 	vp = port->vp;
 	dev = vp->dev;
+	netif_tx_lock(dev);
+	if (unlikely(!idx_is_pending(dr, end))) {
+		netif_tx_unlock(dev);
+		return 0;
+	}
+
 	/* sync for race conditions with vnet_start_xmit() and tell xmit it
 	 * is time to send a trigger.
 	 */
-	netif_tx_lock(dev);
 	dr->cons = next_idx(end, dr);
 	desc = vio_dring_entry(dr, dr->cons);
 	if (desc->hdr.state == VIO_DESC_READY && port->start_cons) {
-- 
1.8.4.2
