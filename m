From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 4/4] be2net: receive asynchronous link status
	notifications from BE
Date: Thu, 18 Jun 2009 15:40:27 +0530
Message-ID: <20090618101027.GA12762@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:14536 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753874AbZFRKKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 06:10:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rcv and process ansync link status notifications from BE instead of polling
 for link status in the be_worker thread.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |    6 +++++-
 drivers/net/benet/be_cmds.c |   34 +++++++++++++++++++++++++++-------
 drivers/net/benet/be_cmds.h |   36 +++++++++++++++++++++++++++++-------
 drivers/net/benet/be_main.c |   37 +++++++++++++++++++------------------
 4 files changed, 80 insertions(+), 33 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 94b75cb..f703758 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -163,6 +163,10 @@ struct be_ctrl_info {
 	struct be_mcc_obj mcc_obj;
 	spinlock_t mcc_lock;	/* For serializing mcc cmds to BE card */
 	spinlock_t mcc_cq_lock;
+
+	/* MCC Async callback */
+	void (*async_cb)(void *adapter, bool link_up);
+	void *adapter_ctxt;
 };
 
 #include "be_cmds.h"
@@ -272,7 +276,7 @@ struct be_adapter {
 	u32 if_handle;		/* Used to configure filtering */
 	u32 pmac_id;		/* MAC addr handle used by BE card */
 
-	struct be_link_info link;
+	bool link_up;
 	u32 port_num;
 	bool promiscuous;
 };
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index dad2d2b..a6fd457 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -69,6 +69,20 @@ static int be_mcc_compl_process(struct be_ctrl_info *ctrl,
 	return 0;
 }
 
+/* Link state evt is a string of bytes; no need for endian swapping */
+static void be_async_link_state_process(struct be_ctrl_info *ctrl,
+		struct be_async_event_link_state *evt)
+{
+	ctrl->async_cb(ctrl->adapter_ctxt,
+		evt->port_link_status == ASYNC_EVENT_LINK_UP ? true : false);
+}
+
+static inline bool is_link_state_evt(u32 trailer)
+{
+	return (((trailer >> ASYNC_TRAILER_EVENT_CODE_SHIFT) &
+		ASYNC_TRAILER_EVENT_CODE_MASK) ==
+				ASYNC_EVENT_CODE_LINK_STATE);
+}
 
 static struct be_mcc_cq_entry *be_mcc_compl_get(struct be_ctrl_info *ctrl)
 {
@@ -89,7 +103,14 @@ void be_process_mcc(struct be_ctrl_info *ctrl)
 
 	spin_lock_bh(&ctrl->mcc_cq_lock);
 	while ((compl = be_mcc_compl_get(ctrl))) {
-		if (!(compl->flags & CQE_FLAGS_ASYNC_MASK)) {
+		if (compl->flags & CQE_FLAGS_ASYNC_MASK) {
+			/* Interpret flags as an async trailer */
+			BUG_ON(!is_link_state_evt(compl->flags));
+
+			/* Interpret compl as a async link evt */
+			be_async_link_state_process(ctrl,
+				(struct be_async_event_link_state *) compl);
+		} else {
 			be_mcc_compl_process(ctrl, compl);
 			atomic_dec(&ctrl->mcc_obj.q.used);
 		}
@@ -786,13 +807,15 @@ int be_cmd_get_stats(struct be_ctrl_info *ctrl, struct be_dma_mem *nonemb_cmd)
 }
 
 int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
-			struct be_link_info *link)
+			bool *link_up)
 {
 	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
 	struct be_cmd_req_link_status *req = embedded_payload(wrb);
 	int status;
 
 	spin_lock(&ctrl->mbox_lock);
+
+	*link_up = false;
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -803,11 +826,8 @@ int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
 	status = be_mbox_db_ring(ctrl);
 	if (!status) {
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
-		link->speed = resp->mac_speed;
-		link->duplex = resp->mac_duplex;
-		link->fault = resp->mac_fault;
-	} else {
-		link->speed = PHY_LINK_SPEED_ZERO;
+		if (resp->mac_speed != PHY_LINK_SPEED_ZERO)
+			*link_up = true;
 	}
 
 	spin_unlock(&ctrl->mbox_lock);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index a567aa4..747626d 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -76,6 +76,34 @@ struct be_mcc_cq_entry {
 	u32 flags;		/* dword 3 */
 };
 
+/* When the async bit of mcc_compl is set, the last 4 bytes of
+ * mcc_compl is interpreted as follows:
+ */
+#define ASYNC_TRAILER_EVENT_CODE_SHIFT	8	/* bits 8 - 15 */
+#define ASYNC_TRAILER_EVENT_CODE_MASK	0xFF
+#define ASYNC_EVENT_CODE_LINK_STATE	0x1
+struct be_async_event_trailer {
+	u32 code;
+};
+
+enum {
+	ASYNC_EVENT_LINK_DOWN 	= 0x0,
+	ASYNC_EVENT_LINK_UP 	= 0x1
+};
+
+/* When the event code of an async trailer is link-state, the mcc_compl
+ * must be interpreted as follows
+ */
+struct be_async_event_link_state {
+	u8 physical_port;
+	u8 port_link_status;
+	u8 port_duplex;
+	u8 port_speed;
+	u8 port_fault;
+	u8 rsvd0[7];
+	struct be_async_event_trailer trailer;
+} __packed;
+
 struct be_mcc_mailbox {
 	struct be_mcc_wrb wrb;
 	struct be_mcc_cq_entry cqe;
@@ -580,12 +608,6 @@ struct be_cmd_req_link_status {
 	u32 rsvd;
 };
 
-struct be_link_info {
-	u8 duplex;
-	u8 speed;
-	u8 fault;
-};
-
 enum {
 	PHY_LINK_DUPLEX_NONE = 0x0,
 	PHY_LINK_DUPLEX_HALF = 0x1,
@@ -704,7 +726,7 @@ extern int be_cmd_rxq_create(struct be_ctrl_info *ctrl,
 extern int be_cmd_q_destroy(struct be_ctrl_info *ctrl, struct be_queue_info *q,
 			int type);
 extern int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
-			struct be_link_info *link);
+			bool *link_up);
 extern int be_cmd_reset(struct be_ctrl_info *ctrl);
 extern int be_cmd_get_stats(struct be_ctrl_info *ctrl,
 			struct be_dma_mem *nonemb_cmd);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 3dc6803..e133ff1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -214,28 +214,24 @@ static void netdev_stats_update(struct be_adapter *adapter)
 	dev_stats->tx_window_errors = 0;
 }
 
-static void be_link_status_update(struct be_adapter *adapter)
+void be_link_status_update(void *ctxt, bool link_up)
 {
-	struct be_link_info *prev = &adapter->link;
-	struct be_link_info now = { 0 };
+	struct be_adapter *adapter = ctxt;
 	struct net_device *netdev = adapter->netdev;
 
-	be_cmd_link_status_query(&adapter->ctrl, &now);
-
 	/* If link came up or went down */
-	if (now.speed != prev->speed && (now.speed == PHY_LINK_SPEED_ZERO ||
-			prev->speed == PHY_LINK_SPEED_ZERO)) {
-		if (now.speed == PHY_LINK_SPEED_ZERO) {
-			netif_stop_queue(netdev);
-			netif_carrier_off(netdev);
-			printk(KERN_INFO "%s: Link down\n", netdev->name);
-		} else {
+	if (adapter->link_up != link_up) {
+		if (link_up) {
 			netif_start_queue(netdev);
 			netif_carrier_on(netdev);
 			printk(KERN_INFO "%s: Link up\n", netdev->name);
+		} else {
+			netif_stop_queue(netdev);
+			netif_carrier_off(netdev);
+			printk(KERN_INFO "%s: Link down\n", netdev->name);
 		}
+		adapter->link_up = link_up;
 	}
-	*prev = now;
 }
 
 /* Update the EQ delay n BE based on the RX frags consumed / sec */
@@ -1395,9 +1391,6 @@ static void be_worker(struct work_struct *work)
 		container_of(work, struct be_adapter, work.work);
 	int status;
 
-	/* Check link */
-	be_link_status_update(adapter);
-
 	/* Get Stats */
 	status = be_cmd_get_stats(&adapter->ctrl, &adapter->stats.cmd);
 	if (!status)
@@ -1522,6 +1515,8 @@ static int be_open(struct net_device *netdev)
 	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
+	bool link_up;
+	int status;
 
 	/* First time posting */
 	be_post_rx_frags(adapter);
@@ -1540,7 +1535,10 @@ static int be_open(struct net_device *netdev)
 	/* Rx compl queue may be in unarmed state; rearm it */
 	be_cq_notify(ctrl, adapter->rx_obj.cq.id, true, 0);
 
-	be_link_status_update(adapter);
+	status = be_cmd_link_status_query(ctrl, &link_up);
+	if (status)
+		return status;
+	be_link_status_update(adapter, link_up);
 
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
@@ -1617,7 +1615,7 @@ static int be_close(struct net_device *netdev)
 
 	netif_stop_queue(netdev);
 	netif_carrier_off(netdev);
-	adapter->link.speed = PHY_LINK_SPEED_ZERO;
+	adapter->link_up = false;
 
 	be_intr_set(ctrl, false);
 
@@ -1808,6 +1806,9 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	spin_lock_init(&ctrl->mcc_lock);
 	spin_lock_init(&ctrl->mcc_cq_lock);
 
+	ctrl->async_cb = be_link_status_update;
+	ctrl->adapter_ctxt = adapter;
+
 	val = ioread32(ctrl->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET);
 	ctrl->pci_func = (val >> MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT) &
 					MEMBAR_CTRL_INT_CTRL_PFUNC_MASK;
-- 
1.6.0.4

