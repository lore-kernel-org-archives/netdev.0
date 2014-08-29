From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/2] sunvnet: Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Fri, 29 Aug 2014 16:18:09 -0400
Message-ID: <20140829201809.GH14753@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40788 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbaH2USR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 16:18:17 -0400
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
 drivers/net/ethernet/sun/sunvnet.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index fc13b9c..7b1f320 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -398,6 +398,20 @@ again:
 		err = vnet_walk_rx_one(port, dr, start, &ack);
 		if (err == -ECONNRESET)
 			return err;
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
