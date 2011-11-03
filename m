From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 3/4] be2net: Prevent CQ full condition for Lancer
Date: Thu, 3 Nov 2011 17:19:55 +0530
Message-ID: <290ebf9d-a94c-411c-bcd9-4b38efe1b587@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:24424 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755789Ab1KCLuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 07:50:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Indicate to HW that the CQ is cleaned up before posting new RX buffers.
This prevents the HW to go into CQ full error condition.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2180497..30606f5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1905,6 +1905,8 @@ loop_continue:
 		be_rx_stats_update(rxo, rxcp);
 	}
 
+	be_cq_notify(adapter, rx_cq->id, false, work_done);
+
 	/* Refill the queue */
 	if (work_done && atomic_read(&rxo->q.used) < RX_FRAGS_REFILL_WM)
 		be_post_rx_frags(rxo, GFP_ATOMIC);
@@ -1912,10 +1914,8 @@ loop_continue:
 	/* All consumed */
 	if (work_done < budget) {
 		napi_complete(napi);
-		be_cq_notify(adapter, rx_cq->id, true, work_done);
-	} else {
-		/* More to be consumed; continue with interrupts disabled */
-		be_cq_notify(adapter, rx_cq->id, false, work_done);
+		/* Arm CQ */
+		be_cq_notify(adapter, rx_cq->id, true, 0);
 	}
 	return work_done;
 }
-- 
1.6.0.2
