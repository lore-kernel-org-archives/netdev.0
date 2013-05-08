From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 3/4] be2net: fix EQ from getting full while cleaning RX CQ
Date: Wed, 8 May 2013 17:35:49 +0530
Message-ID: <1368014750-25065-4-git-send-email-sathya.perla@emulex.com>
References: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:10930 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165Ab3EHMD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 08:03:26 -0400
In-Reply-To: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While cleaning RX queues, the CQ DB may be rung several times (with rearm)
while waiting for the flush compl. Each CQ-notify with rearm can result in
an event. The EQ may get full resulting in a HW error.

Fix this by not re-arming the CQ while notifying a valid completion.
Also, there's no need to wait for 1ms after destroying RXQ, as the code in
be_rx_cq_clean() waits for the flush compl to arrive.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b304b83..792d838 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1827,7 +1827,7 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 			mdelay(1);
 		} else {
 			be_rx_compl_discard(rxo, rxcp);
-			be_cq_notify(adapter, rx_cq->id, true, 1);
+			be_cq_notify(adapter, rx_cq->id, false, 1);
 			if (rxcp->num_rcvd == 0)
 				break;
 		}
@@ -2533,11 +2533,6 @@ static void be_rx_qs_destroy(struct be_adapter *adapter)
 		q = &rxo->q;
 		if (q->created) {
 			be_cmd_rxq_destroy(adapter, q);
-			/* After the rxq is invalidated, wait for a grace time
-			 * of 1ms for all dma to end and the flush compl to
-			 * arrive
-			 */
-			mdelay(1);
 			be_rx_cq_clean(rxo);
 		}
 		be_queue_free(adapter, q);
-- 
1.7.1
