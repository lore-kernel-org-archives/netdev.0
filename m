From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: fix a possible events_get() race on BE2
Date: Fri, 23 Nov 2012 15:57:18 +0530
Message-ID: <669f16b7-59f2-4587-af3e-0b6e83f8f68c@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:43906 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161082Ab2KWKYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 05:24:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On BE2 chip, an interrupt being raised even when EQ is in un-armed state has
been observed a few times.  This is not expected and has never been
observed on BE3/Lancer chips.

As a consequence, be_msix()::events_get() and be_poll()::events_get()
can race and notify an EQ wrongly causing a CEV UE. The other possible
side-effect would be traffic stalling because after notifying EQ,
napi_schedule() is ignored as NAPI is already running.

This patch fixes this issue by counting events only in be_poll().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c365722..adef536 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2029,7 +2029,8 @@ static irqreturn_t be_msix(int irq, void *dev)
 {
 	struct be_eq_obj *eqo = dev;
 
-	event_handle(eqo);
+	be_eq_notify(eqo->adapter, eqo->q.id, false, true, 0);
+	napi_schedule(&eqo->napi);
 	return IRQ_HANDLED;
 }
 
@@ -2125,9 +2126,11 @@ int be_poll(struct napi_struct *napi, int budget)
 {
 	struct be_eq_obj *eqo = container_of(napi, struct be_eq_obj, napi);
 	struct be_adapter *adapter = eqo->adapter;
-	int max_work = 0, work, i;
+	int max_work = 0, work, i, num_evts;
 	bool tx_done;
 
+	num_evts = events_get(eqo);
+
 	/* Process all TXQs serviced by this EQ */
 	for (i = eqo->idx; i < adapter->num_tx_qs; i += adapter->num_evt_qs) {
 		tx_done = be_process_tx(adapter, &adapter->tx_obj[i],
@@ -2150,10 +2153,10 @@ int be_poll(struct napi_struct *napi, int budget)
 
 	if (max_work < budget) {
 		napi_complete(napi);
-		be_eq_notify(adapter, eqo->q.id, true, false, 0);
+		be_eq_notify(adapter, eqo->q.id, true, false, num_evts);
 	} else {
 		/* As we'll continue in polling mode, count and clear events */
-		be_eq_notify(adapter, eqo->q.id, false, false, events_get(eqo));
+		be_eq_notify(adapter, eqo->q.id, false, false, num_evts);
 	}
 	return max_work;
 }
-- 
1.7.1
