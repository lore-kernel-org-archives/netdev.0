From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 17/34]bnx2x: First slow path interrupt race
Date: Wed, 14 Jan 2009 18:43:33 +0200
Message-ID: <1231951413.11301.138.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763608AbZANQo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "read for interrupts" flag must be set before enabling slow-path interrupts
as well (and not just before fast-path interrupts)

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f4d3c23..c416772 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4825,6 +4825,15 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_context(bp);
 	bnx2x_init_internal(bp, load_code);
 	bnx2x_init_ind_table(bp);
+	bnx2x_stats_init(bp);
+
+	/* At this point, we are ready for interrupts */
+	atomic_set(&bp->intr_sem, 0);
+
+	/* flush all before enabling interrupts */
+	mb();
+	mmiowb();
+
 	bnx2x_int_enable(bp);
 }
 
@@ -6433,17 +6442,8 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 	}
 
-	bnx2x_stats_init(bp);
-
 	bp->state = BNX2X_STATE_OPENING_WAIT4_PORT;
 
-	/* Enable Rx interrupt handling before sending the ramrod
-	   as it's completed on Rx FP queue */
-	bnx2x_napi_enable(bp);
-
-	/* Enable interrupt handling */
-	atomic_set(&bp->intr_sem, 0);
-
 	rc = bnx2x_setup_leading(bp);
 	if (rc) {
 		BNX2X_ERR("Setup leading failed!\n");
-- 
1.5.4.3




