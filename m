From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 1/2] be2net: Fix to reap TX compls till HW doesn't respond for some time
Date: Mon, 14 Apr 2014 16:12:40 +0530
Message-ID: <1397472161-28685-2-git-send-email-sathya.perla@emulex.com>
References: <1397472161-28685-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:37622 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbaDNKjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 06:39:07 -0400
In-Reply-To: <1397472161-28685-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

be_close() currently waits for a max of 200ms to receive all pending
TX compls. This timeout value was roughly calculated based on 10G
transmission speeds and the TX queue depth. This timeout may not be
enough when the link is operating at lower speeds or in multi-channel/SR-IOV
configs with TX-rate limiting setting.

It is hard to calculate a "proper timeout value" that works in all
configurations.  This patch solves this problem by continuing to reap
TX completions till the HW is completely silent for a period of 10ms or
a HW error is detected.

v2: implements the new scheme (as suggested by David Laight) instead of
just waiting longer than 200ms for reaping all completions.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3e6df47..80f754d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2033,11 +2033,13 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 	bool dummy_wrb;
 	int i, pending_txqs;
 
-	/* Wait for a max of 200ms for all the tx-completions to arrive. */
+	/* Stop polling for compls when HW has been silent for 10ms */
 	do {
 		pending_txqs = adapter->num_tx_qs;
 
 		for_all_tx_queues(adapter, txo, i) {
+			cmpl = 0;
+			num_wrbs = 0;
 			txq = &txo->q;
 			while ((txcp = be_tx_compl_get(&txo->cq))) {
 				end_idx =
@@ -2050,14 +2052,13 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 			if (cmpl) {
 				be_cq_notify(adapter, txo->cq.id, false, cmpl);
 				atomic_sub(num_wrbs, &txq->used);
-				cmpl = 0;
-				num_wrbs = 0;
+				timeo = 0;
 			}
 			if (atomic_read(&txq->used) == 0)
 				pending_txqs--;
 		}
 
-		if (pending_txqs == 0 || ++timeo > 200)
+		if (pending_txqs == 0 || ++timeo > 10 || be_hw_error(adapter))
 			break;
 
 		mdelay(1);
-- 
1.7.1
