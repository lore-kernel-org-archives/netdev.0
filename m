From: divy@chelsio.com
Subject: [PATCH 2/5] cxgb3 - fix netpoll hanlder
Date: Wed, 30 May 2007 10:01:34 -0700
Message-ID: <20070530170134.22807.94226.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:4879 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755250AbXE3RBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 13:01:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Fix netpoll handler to work with line interrupt, msi and msi-x.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   16 +++++++++++++---
 drivers/net/cxgb3/sge.c        |    1 -
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 67b4b21..dd3710f 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2076,10 +2076,20 @@ static void vlan_rx_kill_vid(struct net_
 static void cxgb_netpoll(struct net_device *dev)
 {
 	struct adapter *adapter = dev->priv;
-	struct sge_qset *qs = dev2qset(dev);
+	struct port_info *pi = netdev_priv(dev);
+	int qidx;
 
-	t3_intr_handler(adapter, qs->rspq.polling) (adapter->pdev->irq,
-						    adapter);
+	for (qidx = pi->first_qset; qidx < pi->first_qset + pi->nqsets; qidx++) {
+		struct sge_qset *qs = &adapter->sge.qs[qidx];
+		void *source;
+		
+		if (adapter->flags & USING_MSIX)
+			source = qs;
+		else
+			source = adapter;
+
+		t3_intr_handler(adapter, qs->rspq.polling) (0, source);
+	}
 }
 #endif
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index eaa7dac..a60ec4d 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2217,7 +2217,6 @@ irqreturn_t t3_sge_intr_msix_napi(int ir
 	struct sge_rspq *q = &qs->rspq;
 
 	spin_lock(&q->lock);
-	BUG_ON(napi_is_scheduled(qs->netdev));
 
 	if (handle_responses(adap, q) < 0)
 		q->unhandled_irqs++;
