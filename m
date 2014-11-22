From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 1/2] enic: use napi_schedule_irqoff()
Date: Sun, 23 Nov 2014 01:22:51 +0530
Message-ID: <1416685972-1368-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:55896 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbaKVTyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 14:54:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic_isr_legacy(), enic_isr_msix() & enic_isr_msi() run from hard
interrupt context.

They can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index b9cda2f..b42a480 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -283,12 +283,10 @@ static irqreturn_t enic_isr_legacy(int irq, void *data)
 		return IRQ_HANDLED;
 	}
 
-	if (ENIC_TEST_INTR(pba, io_intr)) {
-		if (napi_schedule_prep(&enic->napi[0]))
-			__napi_schedule(&enic->napi[0]);
-	} else {
+	if (ENIC_TEST_INTR(pba, io_intr))
+		napi_schedule_irqoff(&enic->napi[0]);
+	else
 		vnic_intr_unmask(&enic->intr[io_intr]);
-	}
 
 	return IRQ_HANDLED;
 }
@@ -313,7 +311,7 @@ static irqreturn_t enic_isr_msi(int irq, void *data)
 	 * writes).
 	 */
 
-	napi_schedule(&enic->napi[0]);
+	napi_schedule_irqoff(&enic->napi[0]);
 
 	return IRQ_HANDLED;
 }
@@ -322,7 +320,7 @@ static irqreturn_t enic_isr_msix(int irq, void *data)
 {
 	struct napi_struct *napi = data;
 
-	napi_schedule(napi);
+	napi_schedule_irqoff(napi);
 
 	return IRQ_HANDLED;
 }
-- 
2.1.0
