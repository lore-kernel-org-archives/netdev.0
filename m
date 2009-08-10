From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 3/3] be2net: clear & notify residual events
	before destroying event queues
Date: Mon, 10 Aug 2009 19:13:51 +0530
Message-ID: <20090810134351.GA10874@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:43471 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754578AbZHJNoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 09:44:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any events rcvd after interrupts are disabled (in the driver unload path),
must be cleared and notified before the event queues are destroyed

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   85 ++++++++++++++++++++++++++++---------------
 1 files changed, 56 insertions(+), 29 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 49c17ed..647510f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -993,6 +993,56 @@ static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 	kfree_skb(sent_skb);
 }
 
+static inline struct be_eq_entry *event_get(struct be_eq_obj *eq_obj)
+{
+	struct be_eq_entry *eqe = queue_tail_node(&eq_obj->q);
+
+	if (!eqe->evt)
+		return NULL;
+
+	eqe->evt = le32_to_cpu(eqe->evt);
+	queue_tail_inc(&eq_obj->q);
+	return eqe;
+}
+
+static int event_handle(struct be_adapter *adapter,
+			struct be_eq_obj *eq_obj)
+{
+	struct be_eq_entry *eqe;
+	u16 num = 0;
+
+	while ((eqe = event_get(eq_obj)) != NULL) {
+		eqe->evt = 0;
+		num++;
+	}
+
+	/* Deal with any spurious interrupts that come
+	 * without events
+	 */
+	be_eq_notify(adapter, eq_obj->q.id, true, true, num);
+	if (num)
+		napi_schedule(&eq_obj->napi);
+
+	return num;
+}
+
+/* Just read and notify events without processing them.
+ * Used at the time of destroying event queues */
+static void be_eq_clean(struct be_adapter *adapter,
+			struct be_eq_obj *eq_obj)
+{
+	struct be_eq_entry *eqe;
+	u16 num = 0;
+
+	while ((eqe = event_get(eq_obj)) != NULL) {
+		eqe->evt = 0;
+		num++;
+	}
+
+	if (num)
+		be_eq_notify(adapter, eq_obj->q.id, false, true, num);
+}
+
 static void be_rx_q_clean(struct be_adapter *adapter)
 {
 	struct be_rx_page_info *page_info;
@@ -1114,6 +1164,9 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 		be_cmd_q_destroy(adapter, q, QTYPE_CQ);
 	be_queue_free(adapter, q);
 
+	/* Clear any residual events */
+	be_eq_clean(adapter, &adapter->tx_eq);
+
 	q = &adapter->tx_eq.q;
 	if (q->created)
 		be_cmd_q_destroy(adapter, q, QTYPE_EQ);
@@ -1185,6 +1238,9 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 		be_cmd_q_destroy(adapter, q, QTYPE_CQ);
 	be_queue_free(adapter, q);
 
+	/* Clear any residual events */
+	be_eq_clean(adapter, &adapter->rx_eq);
+
 	q = &adapter->rx_eq.q;
 	if (q->created)
 		be_cmd_q_destroy(adapter, q, QTYPE_EQ);
@@ -1251,35 +1307,6 @@ rx_eq_free:
 	be_queue_free(adapter, eq);
 	return rc;
 }
-static bool event_get(struct be_eq_obj *eq_obj, u16 *rid)
-{
-	struct be_eq_entry *entry = queue_tail_node(&eq_obj->q);
-	u32 evt = entry->evt;
-
-	if (!evt)
-		return false;
-
-	evt = le32_to_cpu(evt);
-	*rid = (evt >> EQ_ENTRY_RES_ID_SHIFT) & EQ_ENTRY_RES_ID_MASK;
-	entry->evt = 0;
-	queue_tail_inc(&eq_obj->q);
-	return true;
-}
-
-static int event_handle(struct be_adapter *adapter, struct be_eq_obj *eq_obj)
-{
-	u16 rid = 0, num = 0;
-
-	while (event_get(eq_obj, &rid))
-		num++;
-
-	/* We can see an interrupt and no event */
-	be_eq_notify(adapter, eq_obj->q.id, true, true, num);
-	if (num)
-		napi_schedule(&eq_obj->napi);
-
-	return num;
-}
 
 static irqreturn_t be_intx(int irq, void *dev)
 {
-- 
1.6.0.4

