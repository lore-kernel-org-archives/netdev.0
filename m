From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 4/7] be2net: Fix traffic stall INTx mode
Date: Wed, 25 Apr 2012 17:16:39 +0530
Message-ID: <8a647610-8688-4c36-bca4-ccd1ddff7705@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:29215 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759069Ab2DYLrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 07:47:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EQ is getting armed wrongly in INTx mode as INTx interrupt is taking
some time to deassert. This can cause another interrupt while NAPI is
scheduled and scheduling a NAPI in interrupt does not take effect.
This causes interrupt to be missed and traffic stalls. Fixing this by
preventing wrong arming of EQ.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a9a11d4..9d42fab 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1571,7 +1571,9 @@ static int event_handle(struct be_eq_obj *eqo)
 	if (!num)
 		rearm = true;
 
-	be_eq_notify(eqo->adapter, eqo->q.id, rearm, true, num);
+	if (num || msix_enabled(eqo->adapter))
+		be_eq_notify(eqo->adapter, eqo->q.id, rearm, true, num);
+
 	if (num)
 		napi_schedule(&eqo->napi);
 
-- 
1.6.0.2
