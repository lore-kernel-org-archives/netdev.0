From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2/3] cxgb - fix NAPI
Date: Tue, 27 Nov 2007 13:30:15 -0800
Message-ID: <20071127213015.823.85994.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greearb@candelatech.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31517 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758767AbXK0VaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 16:30:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

netif_rx_complete() should be called only 
when work_done < budget.

Signed-off-by: Divy Le ray <divy@chelsio.com>
---

 drivers/net/chelsio/sge.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
old mode 100755
new mode 100644
index e8b1036..4b6258f
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1625,11 +1625,9 @@ int t1_poll(struct napi_struct *napi, int budget)
 {
 	struct adapter *adapter = container_of(napi, struct adapter, napi);
 	struct net_device *dev = adapter->port[0].dev;
-	int work_done;
-
-	work_done = process_responses(adapter, budget);
+	int work_done = process_responses(adapter, budget);
 
-	if (likely(!responses_pending(adapter))) {
+	if (likely(work_done < budget)) {
 		netif_rx_complete(dev, napi);
 		writel(adapter->sge->respQ.cidx,
 		       adapter->regs + A_SG_SLEEPING);
