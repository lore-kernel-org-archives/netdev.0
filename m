From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: fix unconditionally returning IRQ_HANDLED in INTx
Date: Sat, 12 Jan 2013 14:17:02 +0530
Message-ID: <ac9920f8-3e7c-4920-8323-510e648822c8@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:10526 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941Ab3ALIog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 03:44:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e49cc34f introduced an unconditional IRQ_HANDLED return in be_intx()
to workaround Lancer and BE2 HW issues. This is bad as it prevents the kernel
from detecting interrupt storms due to broken HW.

The BE2/Lancer HW issues are:
1) In Lancer, there is no means for the driver to detect if the interrupt
belonged to device, other than counting and notifying events.
2) In Lancer de-asserting INTx takes a while, causing the INTx irq handler
to be called multiple times till the de-assert happens.
3) In BE2, we see an occasional interrupt even when EQs are unarmed.

Issue (1) can cause the notified events to be orphaned, if NAPI was already
running.
This patch fixes this issue by scheduling NAPI only if it is not scheduled
already. Doing this also takes care of possible events_get() race that may be
caused due to issue (2) and (3). Also, IRQ_HANDLED is returned only the first
time zero events are detected.
(Thanks Ben H. for the feedback and suggestions.)

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |   29 ++++++++++++++++++--------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 3bc1912..4eba17b 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -190,6 +190,7 @@ struct be_eq_obj {
 
 	u8 idx;			/* array index */
 	u16 tx_budget;
+	u16 spurious_intr;
 	struct napi_struct napi;
 	struct be_adapter *adapter;
 } ____cacheline_aligned_in_smp;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9dca22b..5c99570 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2026,19 +2026,30 @@ static irqreturn_t be_intx(int irq, void *dev)
 	struct be_adapter *adapter = eqo->adapter;
 	int num_evts = 0;
 
-	/* On Lancer, clear-intr bit of the EQ DB does not work.
-	 * INTx is de-asserted only on notifying num evts.
+	/* IRQ is not expected when NAPI is scheduled as the EQ
+	 * will not be armed.
+	 * But, this can happen on Lancer INTx where it takes
+	 * a while to de-assert INTx or in BE2 where occasionaly
+	 * an interrupt may be raised even when EQ is unarmed.
+	 * If NAPI is already scheduled, then counting & notifying
+	 * events will orphan them.
 	 */
-	if (lancer_chip(adapter))
+	if (napi_schedule_prep(&eqo->napi)) {
 		num_evts = events_get(eqo);
+		__napi_schedule(&eqo->napi);
+		if (num_evts)
+			eqo->spurious_intr = 0;
+	}
+	be_eq_notify(adapter, eqo->q.id, false, true, num_evts);
 
-	/* The EQ-notify may not de-assert INTx rightaway, causing
-	 * the ISR to be invoked again. So, return HANDLED even when
-	 * num_evts is zero.
+	/* Return IRQ_HANDLED only for the the first spurious intr
+	 * after a valid intr to stop the kernel from branding
+	 * this irq as a bad one!
 	 */
-	be_eq_notify(adapter, eqo->q.id, false, true, num_evts);
-	napi_schedule(&eqo->napi);
-	return IRQ_HANDLED;
+	if (num_evts || eqo->spurious_intr++ == 0)
+		return IRQ_HANDLED;
+	else
+		return IRQ_NONE;
 }
 
 static irqreturn_t be_msix(int irq, void *dev)
-- 
1.7.1
