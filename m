From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 07/12] cxgb4: correct formatting of MSI-X interrupt names
Date: Tue, 14 Dec 2010 23:36:50 -0800
Message-ID: <1292398615-26527-8-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
 <1292398615-26527-2-git-send-email-dm@chelsio.com>
 <1292398615-26527-3-git-send-email-dm@chelsio.com>
 <1292398615-26527-4-git-send-email-dm@chelsio.com>
 <1292398615-26527-5-git-send-email-dm@chelsio.com>
 <1292398615-26527-6-git-send-email-dm@chelsio.com>
 <1292398615-26527-7-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3447 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICQ004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:19 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7avvj026601
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:57 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7ave7026600
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:57 -0800
In-Reply-To: <1292398615-26527-7-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last byte of the buffer for MSI-X names could not be used due to a
bogus -1.  Also do not explicitly clear the last byte, snprintf will do
the right thing.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 089b753..7e26fe5 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -522,39 +522,32 @@ static irqreturn_t t4_nondata_intr(int irq, void *cookie)
  */
 static void name_msix_vecs(struct adapter *adap)
 {
-	int i, j, msi_idx = 2, n = sizeof(adap->msix_info[0].desc) - 1;
+	int i, j, msi_idx = 2, n = sizeof(adap->msix_info[0].desc);
 
 	/* non-data interrupts */
 	snprintf(adap->msix_info[0].desc, n, "%s", adap->name);
-	adap->msix_info[0].desc[n] = 0;
 
 	/* FW events */
 	snprintf(adap->msix_info[1].desc, n, "%s-FWeventq", adap->name);
-	adap->msix_info[1].desc[n] = 0;
 
 	/* Ethernet queues */
 	for_each_port(adap, j) {
 		struct net_device *d = adap->port[j];
 		const struct port_info *pi = netdev_priv(d);
 
-		for (i = 0; i < pi->nqsets; i++, msi_idx++) {
+		for (i = 0; i < pi->nqsets; i++, msi_idx++)
 			snprintf(adap->msix_info[msi_idx].desc, n, "%s-Rx%d",
 				 d->name, i);
-			adap->msix_info[msi_idx].desc[n] = 0;
-		}
 	}
 
 	/* offload queues */
-	for_each_ofldrxq(&adap->sge, i) {
-		snprintf(adap->msix_info[msi_idx].desc, n, "%s-ofld%d",
+	for_each_ofldrxq(&adap->sge, i)
+		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-ofld%d",
 			 adap->name, i);
-		adap->msix_info[msi_idx++].desc[n] = 0;
-	}
-	for_each_rdmarxq(&adap->sge, i) {
-		snprintf(adap->msix_info[msi_idx].desc, n, "%s-rdma%d",
+
+	for_each_rdmarxq(&adap->sge, i)
+		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-rdma%d",
 			 adap->name, i);
-		adap->msix_info[msi_idx++].desc[n] = 0;
-	}
 }
 
 static int request_msix_queue_irqs(struct adapter *adap)
-- 
1.5.4

