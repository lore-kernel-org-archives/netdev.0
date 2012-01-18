From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net] tg3: Fix single-vector MSI-X code
Date: Tue, 17 Jan 2012 17:27:23 -0800
Message-ID: <1326850043-23417-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2271 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754260Ab2ARB2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 20:28:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kdump kernels leave MSI-X interrupts (as setup by the crashed kernel)
enabled.  However, kdump only enables one CPU in the new environment,
thus causing tg3 to abort MSI-X setup.  When the driver attempts to
enable INTA or MSI interrupt modes on a kdump kernel, interrupt
delivery fails.

This patch attempts to workaround the problem by forcing the driver
to enable a single MSI-X interrupt.  In such a configuration, the
device's multivector interrupt mode must be disabled.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 076e02a..d529af9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8846,9 +8846,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	udelay(100);
 
-	if (tg3_flag(tp, USING_MSIX) && tp->irq_cnt > 1) {
+	if (tg3_flag(tp, USING_MSIX)) {
 		val = tr32(MSGINT_MODE);
-		val |= MSGINT_MODE_MULTIVEC_EN | MSGINT_MODE_ENABLE;
+		val |= MSGINT_MODE_ENABLE;
+		if (tp->irq_cnt > 1)
+			val |= MSGINT_MODE_MULTIVEC_EN;
 		if (!tg3_flag(tp, 1SHOT_MSI))
 			val |= MSGINT_MODE_ONE_SHOT_DISABLE;
 		tw32(MSGINT_MODE, val);
@@ -9548,19 +9550,18 @@ static int tg3_request_firmware(struct tg3 *tp)
 
 static bool tg3_enable_msix(struct tg3 *tp)
 {
-	int i, rc, cpus = num_online_cpus();
+	int i, rc;
 	struct msix_entry msix_ent[tp->irq_max];
 
-	if (cpus == 1)
-		/* Just fallback to the simpler MSI mode. */
-		return false;
-
-	/*
-	 * We want as many rx rings enabled as there are cpus.
-	 * The first MSIX vector only deals with link interrupts, etc,
-	 * so we add one to the number of vectors we are requesting.
-	 */
-	tp->irq_cnt = min_t(unsigned, cpus + 1, tp->irq_max);
+	tp->irq_cnt = num_online_cpus();
+	if (tp->irq_cnt > 1) {
+		/* We want as many rx rings enabled as there are cpus.
+		 * In multiqueue MSI-X mode, the first MSI-X vector
+		 * only deals with link interrupts, etc, so we add
+		 * one to the number of vectors we are requesting.
+		 */
+		tp->irq_cnt = min_t(unsigned, tp->irq_cnt + 1, tp->irq_max);
+	}
 
 	for (i = 0; i < tp->irq_max; i++) {
 		msix_ent[i].entry  = i;
-- 
1.7.3.4
