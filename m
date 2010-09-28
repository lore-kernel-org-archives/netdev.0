From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next-2.6] bnx2x: Moved enabling of MSI to the
 bnx2x_set_num_queues()
Date: Tue, 28 Sep 2010 16:42:20 +0200
Message-ID: <1285684941.31967.21.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1646 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754781Ab0I1Omd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 10:42:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moved enabling of MSI to the bnx2x_set_num_queues() - the same functions that
handles the initialization of the MSI-X.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---

This patch is required for the integration of Ben Hutchings bnx2x patch from
the "netif_set_real_num_{rx,tx}_queues" patch series.

 drivers/net/bnx2x/bnx2x_cmn.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index efc7be4..453d3b6 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1185,8 +1185,10 @@ static int bnx2x_set_num_queues(struct bnx2x *bp)
 	int rc = 0;
 
 	switch (bp->int_mode) {
-	case INT_MODE_INTx:
 	case INT_MODE_MSI:
+		bnx2x_enable_msi(bp);
+		/* falling through... */
+	case INT_MODE_INTx:
 		bp->num_queues = 1;
 		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
 		break;
@@ -1202,9 +1204,16 @@ static int bnx2x_set_num_queues(struct bnx2x *bp)
 		 * and fallback to MSI or legacy INTx with one fp
 		 */
 		rc = bnx2x_enable_msix(bp);
-		if (rc)
+		if (rc) {
 			/* failed to enable MSI-X */
 			bp->num_queues = 1;
+
+			/* Fall to INTx if failed to enable MSI-X due to lack of
+			 * memory (in bnx2x_set_num_queues()) */
+			if ((rc != -ENOMEM) && (bp->int_mode != INT_MODE_INTx))
+				bnx2x_enable_msi(bp);
+		}
+
 		break;
 	}
 	bp->dev->real_num_tx_queues = bp->num_queues;
@@ -1263,10 +1272,6 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			goto load_error1;
 		}
 	} else {
-		/* Fall to INTx if failed to enable MSI-X due to lack of
-		   memory (in bnx2x_set_num_queues()) */
-		if ((rc != -ENOMEM) && (bp->int_mode != INT_MODE_INTx))
-			bnx2x_enable_msi(bp);
 		bnx2x_ack_int(bp);
 		rc = bnx2x_req_irq(bp);
 		if (rc) {
-- 
1.7.0.4




