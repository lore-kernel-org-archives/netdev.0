From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Tue, 2 Sep 2014 12:20:29 -0400
Message-ID: <20140902162029.GC31516@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, raghuram.kothakota@oracle.com,
	sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26065 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbaIBQUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:20:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Upon encountering the first !VIO_DESC_READY in vnet_walk_rx(),
it is frequently worthwhile to re-check the descriptor status
after a short microsecond delay, as a bursty sender could
be actively populating the descriptors, and the short udelay()
is far less expensive than rolling back to ldc_rx() and having
to wake up and read data on another LDC message.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>
---
changes since v1: moved label `again', variable `retries' to this patchset.

 drivers/net/ethernet/sun/sunvnet.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 8f90b57..7b1f320 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -390,11 +390,28 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
 	viodbg(DATA, "vnet_walk_rx start[%08x] end[%08x]\n", start, end);
 
 	while (start != end) {
-		int ack = 0, err = vnet_walk_rx_one(port, dr, start, &ack);
+		int retries;
+		int ack = 0, err;
+
+		retries = 0;
+again:
+		err = vnet_walk_rx_one(port, dr, start, &ack);
 		if (err == -ECONNRESET)
 			return err;
-		if (err != 0)
-			break;
+		if (err != 0)  {
+			/* The descriptor was not READY. Retry with a
+			 * small delay, in case we have a bursty sender
+			 * that is actively populating the descriptors, to
+			 * reduce the overhead of stopping and re-entering
+			 * which would involve expensive LDC messages.
+			 */
+			if (retries++ < 3) {
+				udelay(4);
+				goto again;
+			} else {
+				break;
+			}
+		}
 		if (ack_start == -1)
 			ack_start = start;
 		ack_end = start;
-- 
1.8.4.2
