From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 5/10] bnx2x: SMP-safe inter_sem
Date: Tue, 21 Jul 2009 18:47:41 +0300
Message-ID: <1248191261.18195.48.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vlad Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4396 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755238AbZGUPrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 11:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vlad Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f20df6d..18c3803 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -706,6 +706,8 @@ static void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 
 	/* disable interrupt handling */
 	atomic_inc(&bp->intr_sem);
+	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
+
 	if (disable_hw)
 		/* prevent the HW from sending interrupts */
 		bnx2x_int_disable(bp);
@@ -6642,7 +6644,12 @@ static void bnx2x_napi_disable(struct bnx2x *bp)
 
 static void bnx2x_netif_start(struct bnx2x *bp)
 {
-	if (atomic_dec_and_test(&bp->intr_sem)) {
+	int intr_sem;
+
+	intr_sem = atomic_dec_and_test(&bp->intr_sem);
+	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
+
+	if (intr_sem) {
 		if (netif_running(bp->dev)) {
 			bnx2x_napi_enable(bp);
 			bnx2x_int_enable(bp);
@@ -8229,6 +8236,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	/* Disable interrupt handling until HW is initialized */
 	atomic_set(&bp->intr_sem, 1);
+	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
 
 	mutex_init(&bp->port.phy_mutex);
 
-- 
1.5.4.3




