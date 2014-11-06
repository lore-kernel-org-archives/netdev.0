From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 2/2 net-next] sunvnet: Return from vnet_napi_event() if no
 packets to read
Date: Thu, 6 Nov 2014 14:51:08 -0500
Message-ID: <20141106195108.GF6238@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com,
	david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27732 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaKFTvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:51:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


vnet_event_napi() may be called as part of the NAPI ->poll,
to resume reading descriptor rings. When no data is available,
descriptor ring state (e.g., rcv_nxt) needs to be reset
carefully to stay in lock-step with ldc_read(). In the interest
of simplicity, the best way to do this is to return from 
vnet_event_napi() when there are no more packets to read.
The next trip through ldc_rx will correctly set up the dring state.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: David Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 2688b19..5c5fb59 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -691,7 +691,6 @@ ldc_ctrl:
 			pkt->end_idx = -1;
 			goto napi_resume;
 		}
-ldc_read:
 		err = ldc_read(vio->lp, &msgbuf, sizeof(msgbuf));
 		if (unlikely(err < 0)) {
 			if (err == -ECONNRESET)
@@ -722,8 +721,8 @@ napi_resume:
 				err = vnet_rx(port, &msgbuf, &npkts, budget);
 				if (npkts >= budget)
 					break;
-				if (npkts == 0 && err != -ECONNRESET)
-					goto ldc_read;
+				if (npkts == 0)
+					break;
 			} else if (msgbuf.tag.stype == VIO_SUBTYPE_ACK) {
 				err = vnet_ack(port, &msgbuf);
 				if (err > 0)
-- 
1.8.4.2
