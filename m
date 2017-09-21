From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: avoid stall while shutting down the adapter
Date: Thu, 21 Sep 2017 12:50:47 +0530
Message-ID: <1505978447-14944-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:40816 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751528AbdIUHWl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:22:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

do not wait for completion while deleting the filters
when the adapter is shutting down because we may not get
the response as interrupts will be disabled.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        | 1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c | 7 ++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   | 4 ++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index ea72d2d..c4e997f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -549,6 +549,7 @@ enum {                                 /* adapter flags */
 	MASTER_PF          = (1 << 7),
 	FW_OFLD_CONN       = (1 << 9),
 	ROOT_NO_RELAXED_ORDERING = (1 << 10),
+	SHUTTING_DOWN	   = (1 << 11),
 };
 
 enum {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index 45b5853..97ead2c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -191,7 +191,8 @@ static int del_filter_wr(struct adapter *adapter, int fidx)
 		return -ENOMEM;
 
 	fwr = __skb_put(skb, len);
-	t4_mk_filtdelwr(f->tid, fwr, adapter->sge.fw_evtq.abs_id);
+	t4_mk_filtdelwr(f->tid, fwr, (adapter->flags & SHUTTING_DOWN) ? -1
+			: adapter->sge.fw_evtq.abs_id);
 
 	/* Mark the filter as "pending" and ship off the Filter Work Request.
 	 * When we get the Work Request Reply we'll clear the pending status.
@@ -636,6 +637,10 @@ int cxgb4_del_filter(struct net_device *dev, int filter_id)
 	struct filter_ctx ctx;
 	int ret;
 
+	/* If we are shutting down the adapter do not wait for completion */
+	if (netdev2adap(dev)->flags & SHUTTING_DOWN)
+		return __cxgb4_del_filter(dev, filter_id, NULL);
+
 	init_completion(&ctx.completion);
 
 	ret = __cxgb4_del_filter(dev, filter_id, &ctx);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 92d9d79..5fe81a4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5254,6 +5254,8 @@ static void remove_one(struct pci_dev *pdev)
 		return;
 	}
 
+	adapter->flags |= SHUTTING_DOWN;
+
 	if (adapter->pf == 4) {
 		int i;
 
@@ -5339,6 +5341,8 @@ static void shutdown_one(struct pci_dev *pdev)
 		return;
 	}
 
+	adapter->flags |= SHUTTING_DOWN;
+
 	if (adapter->pf == 4) {
 		int i;
 
-- 
2.1.0
