From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v1 5/8] xen-netback: add support for the control ring
Date: Fri, 12 Feb 2016 10:13:22 +0000
Message-ID: <1455272005-17144-6-git-send-email-paul.durrant@citrix.com>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:3608 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbcBLKVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 05:21:44 -0500
In-Reply-To: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My recent patch to include/xen/interface/io/netif.h defines a new shared
ring (in addition to the rx and tx rings) for passing control messages
from a VM frontend driver to a backend driver.

This patch adds the necessary code to xen-netback to map this new shared
ring, should it be created by a frontend, and process messages passed on
the ring. Note that, to avoid it becoming overly large, this patch does
not introduce an implementation of any of the control messages specified in
netif.h (that is deferred to a subsequent patch) and so all messages
elicit a 'not supported' response.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |  28 +++++++---
 drivers/net/xen-netback/interface.c | 101 +++++++++++++++++++++++++++++++++---
 drivers/net/xen-netback/netback.c   | 100 +++++++++++++++++++++++++++++++++--
 drivers/net/xen-netback/xenbus.c    |  75 ++++++++++++++++++++++----
 4 files changed, 274 insertions(+), 30 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index f44b388..093a12a 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -260,6 +260,11 @@ struct xenvif {
 	struct dentry *xenvif_dbg_root;
 #endif
 
+	struct xen_netif_ctrl_back_ring ctrl;
+	struct task_struct *ctrl_task;
+	wait_queue_head_t ctrl_wq;
+	unsigned int ctrl_irq;
+
 	/* Miscellaneous private stuff. */
 	struct net_device *dev;
 };
@@ -285,10 +290,15 @@ struct xenvif *xenvif_alloc(struct device *parent,
 int xenvif_init_queue(struct xenvif_queue *queue);
 void xenvif_deinit_queue(struct xenvif_queue *queue);
 
-int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
-		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
-		   unsigned int rx_evtchn);
-void xenvif_disconnect(struct xenvif *vif);
+int xenvif_connect_data(struct xenvif_queue *queue,
+			unsigned long tx_ring_ref,
+			unsigned long rx_ring_ref,
+			unsigned int tx_evtchn,
+			unsigned int rx_evtchn);
+void xenvif_disconnect_data(struct xenvif *vif);
+int xenvif_connect_ctrl(struct xenvif *vif, grant_ref_t ring_ref,
+			unsigned int evtchn);
+void xenvif_disconnect_ctrl(struct xenvif *vif);
 void xenvif_free(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
@@ -300,10 +310,10 @@ int xenvif_queue_stopped(struct xenvif_queue *queue);
 void xenvif_wake_queue(struct xenvif_queue *queue);
 
 /* (Un)Map communication rings. */
-void xenvif_unmap_frontend_rings(struct xenvif_queue *queue);
-int xenvif_map_frontend_rings(struct xenvif_queue *queue,
-			      grant_ref_t tx_ring_ref,
-			      grant_ref_t rx_ring_ref);
+void xenvif_unmap_frontend_data_rings(struct xenvif_queue *queue);
+int xenvif_map_frontend_data_rings(struct xenvif_queue *queue,
+				   grant_ref_t tx_ring_ref,
+				   grant_ref_t rx_ring_ref);
 
 /* Check for SKBs from frontend and schedule backend processing */
 void xenvif_napi_schedule_or_enable_events(struct xenvif_queue *queue);
@@ -318,6 +328,8 @@ void xenvif_kick_thread(struct xenvif_queue *queue);
 
 int xenvif_dealloc_kthread(void *data);
 
+int xenvif_ctrl_kthread(void *data);
+
 void xenvif_rx_queue_tail(struct xenvif_queue *queue, struct sk_buff *skb);
 
 void xenvif_carrier_on(struct xenvif *vif);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index f5231a2..1850ebb 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -128,6 +128,15 @@ irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+irqreturn_t xenvif_ctrl_interrupt(int irq, void *dev_id)
+{
+	struct xenvif *vif = dev_id;
+
+	wake_up(&vif->ctrl_wq);
+
+	return IRQ_HANDLED;
+}
+
 int xenvif_queue_stopped(struct xenvif_queue *queue)
 {
 	struct net_device *dev = queue->vif->dev;
@@ -527,9 +536,66 @@ void xenvif_carrier_on(struct xenvif *vif)
 	rtnl_unlock();
 }
 
-int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
-		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
-		   unsigned int rx_evtchn)
+int xenvif_connect_ctrl(struct xenvif *vif, grant_ref_t ring_ref,
+			unsigned int evtchn)
+{
+	struct net_device *dev = vif->dev;
+	void *addr;
+	struct xen_netif_ctrl_sring *shared;
+	struct task_struct *task;
+	int err = -ENOMEM;
+
+	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
+				     &ring_ref, 1, &addr);
+	if (err)
+		goto err;
+
+	shared = (struct xen_netif_ctrl_sring *)addr;
+	BACK_RING_INIT(&vif->ctrl, shared, XEN_PAGE_SIZE);
+
+	init_waitqueue_head(&vif->ctrl_wq);
+
+	err = bind_interdomain_evtchn_to_irqhandler(vif->domid, evtchn,
+						    xenvif_ctrl_interrupt,
+						    0, dev->name, vif);
+	if (err < 0)
+		goto err_unmap;
+
+	vif->ctrl_irq = err;
+
+	task = kthread_create(xenvif_ctrl_kthread, (void *)vif,
+			      "%s-control", dev->name);
+	if (IS_ERR(task)) {
+		pr_warn("Could not allocate kthread for %s\n", dev->name);
+		err = PTR_ERR(task);
+		goto err_unbind;
+	}
+
+	get_task_struct(task);
+	vif->ctrl_task = task;
+
+	wake_up_process(vif->ctrl_task);
+
+	return 0;
+
+err_unbind:
+	unbind_from_irqhandler(vif->ctrl_irq, vif);
+	vif->ctrl_irq = 0;
+
+err_unmap:
+	xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
+				vif->ctrl.sring);
+	vif->ctrl.sring = NULL;
+
+err:
+	return err;
+}
+
+int xenvif_connect_data(struct xenvif_queue *queue,
+			unsigned long tx_ring_ref,
+			unsigned long rx_ring_ref,
+			unsigned int tx_evtchn,
+			unsigned int rx_evtchn)
 {
 	struct task_struct *task;
 	int err = -ENOMEM;
@@ -538,7 +604,8 @@ int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 	BUG_ON(queue->task);
 	BUG_ON(queue->dealloc_task);
 
-	err = xenvif_map_frontend_rings(queue, tx_ring_ref, rx_ring_ref);
+	err = xenvif_map_frontend_data_rings(queue, tx_ring_ref,
+					     rx_ring_ref);
 	if (err < 0)
 		goto err;
 
@@ -614,7 +681,7 @@ err_tx_unbind:
 	unbind_from_irqhandler(queue->tx_irq, queue);
 	queue->tx_irq = 0;
 err_unmap:
-	xenvif_unmap_frontend_rings(queue);
+	xenvif_unmap_frontend_data_rings(queue);
 	netif_napi_del(&queue->napi);
 err:
 	module_put(THIS_MODULE);
@@ -634,7 +701,7 @@ void xenvif_carrier_off(struct xenvif *vif)
 	rtnl_unlock();
 }
 
-void xenvif_disconnect(struct xenvif *vif)
+void xenvif_disconnect_data(struct xenvif *vif)
 {
 	struct xenvif_queue *queue = NULL;
 	unsigned int num_queues = vif->num_queues;
@@ -668,12 +735,32 @@ void xenvif_disconnect(struct xenvif *vif)
 			queue->tx_irq = 0;
 		}
 
-		xenvif_unmap_frontend_rings(queue);
+		xenvif_unmap_frontend_data_rings(queue);
 	}
 
 	xenvif_mcast_addr_list_free(vif);
 }
 
+void xenvif_disconnect_ctrl(struct xenvif *vif)
+{
+	if (vif->ctrl_task) {
+		kthread_stop(vif->ctrl_task);
+		put_task_struct(vif->ctrl_task);
+		vif->ctrl_task = NULL;
+	}
+
+	if (vif->ctrl_irq) {
+		unbind_from_irqhandler(vif->ctrl_irq, vif);
+		vif->ctrl_irq = 0;
+	}
+
+	if (vif->ctrl.sring) {
+		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
+					vif->ctrl.sring);
+		vif->ctrl.sring = NULL;
+	}
+}
+
 /* Reverse the relevant parts of xenvif_init_queue().
  * Used for queue teardown from xenvif_free(), and on the
  * error handling paths in xenbus.c:connect().
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index b42f260..a1f1a38 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1925,7 +1925,7 @@ static inline bool tx_dealloc_work_todo(struct xenvif_queue *queue)
 	return queue->dealloc_cons != queue->dealloc_prod;
 }
 
-void xenvif_unmap_frontend_rings(struct xenvif_queue *queue)
+void xenvif_unmap_frontend_data_rings(struct xenvif_queue *queue)
 {
 	if (queue->tx.sring)
 		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(queue->vif),
@@ -1935,9 +1935,9 @@ void xenvif_unmap_frontend_rings(struct xenvif_queue *queue)
 					queue->rx.sring);
 }
 
-int xenvif_map_frontend_rings(struct xenvif_queue *queue,
-			      grant_ref_t tx_ring_ref,
-			      grant_ref_t rx_ring_ref)
+int xenvif_map_frontend_data_rings(struct xenvif_queue *queue,
+				   grant_ref_t tx_ring_ref,
+				   grant_ref_t rx_ring_ref)
 {
 	void *addr;
 	struct xen_netif_tx_sring *txs;
@@ -1964,7 +1964,7 @@ int xenvif_map_frontend_rings(struct xenvif_queue *queue,
 	return 0;
 
 err:
-	xenvif_unmap_frontend_rings(queue);
+	xenvif_unmap_frontend_data_rings(queue);
 	return err;
 }
 
@@ -2163,6 +2163,96 @@ int xenvif_dealloc_kthread(void *data)
 	return 0;
 }
 
+static void make_ctrl_response(struct xenvif *vif,
+			       const struct xen_netif_ctrl_request *req,
+			       u32 status, u32 data)
+{
+	RING_IDX idx = vif->ctrl.rsp_prod_pvt;
+	struct xen_netif_ctrl_response rsp = {
+		.id = req->id,
+		.type = req->type,
+		.status = status,
+		.data = data,
+	};
+
+	*RING_GET_RESPONSE(&vif->ctrl, idx) = rsp;
+	vif->ctrl.rsp_prod_pvt = ++idx;
+}
+
+static void push_ctrl_response(struct xenvif *vif)
+{
+	int notify;
+
+	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->ctrl, notify);
+	if (notify)
+		notify_remote_via_irq(vif->ctrl_irq);
+}
+
+static void process_ctrl_request(struct xenvif *vif,
+				 const struct xen_netif_ctrl_request *req)
+{
+	/* There is no support for control requests yet. */
+	make_ctrl_response(vif, req,
+			   XEN_NETIF_CTRL_STATUS_NOT_SUPPORTED, 0);
+	push_ctrl_response(vif);
+}
+
+static void xenvif_ctrl_action(struct xenvif *vif)
+{
+	for (;;) {
+		RING_IDX req_prod, req_cons;
+
+		req_prod = vif->ctrl.sring->req_prod;
+		req_cons = vif->ctrl.req_cons;
+
+		/* Make sure we can see requests before we process them. */
+		rmb();
+
+		if (req_cons == req_prod)
+			break;
+
+		while (req_cons != req_prod) {
+			struct xen_netif_ctrl_request req;
+
+			RING_COPY_REQUEST(&vif->ctrl, req_cons, &req);
+			req_cons++;
+
+			process_ctrl_request(vif, &req);
+		}
+
+		vif->ctrl.req_cons = req_cons;
+		vif->ctrl.sring->req_event = req_cons + 1;
+	}
+}
+
+static bool xenvif_ctrl_work_todo(struct xenvif *vif)
+{
+	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&vif->ctrl)))
+		return 1;
+
+	return 0;
+}
+
+int xenvif_ctrl_kthread(void *data)
+{
+	struct xenvif *vif = data;
+
+	for (;;) {
+		wait_event_interruptible(vif->ctrl_wq,
+					 xenvif_ctrl_work_todo(vif) ||
+					 kthread_should_stop());
+		if (kthread_should_stop())
+			break;
+
+		while (xenvif_ctrl_work_todo(vif))
+			xenvif_ctrl_action(vif);
+
+		cond_resched();
+	}
+
+	return 0;
+}
+
 static int __init netback_init(void)
 {
 	int rc = 0;
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index bd182cd..278f67b 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -38,7 +38,8 @@ struct backend_info {
 	const char *hotplug_script;
 };
 
-static int connect_rings(struct backend_info *be, struct xenvif_queue *queue);
+static int connect_data_rings(struct backend_info *be,
+			      struct xenvif_queue *queue);
 static void connect(struct backend_info *be);
 static int read_xenbus_vif_flags(struct backend_info *be);
 static int backend_create_xenvif(struct backend_info *be);
@@ -367,6 +368,12 @@ static int netback_probe(struct xenbus_device *dev,
 	if (err)
 		pr_debug("Error writing multi-queue-max-queues\n");
 
+	err = xenbus_printf(XBT_NIL, dev->nodename,
+			    "feature-ctrl-ring",
+			    "%u", true);
+	if (err)
+		pr_debug("Error writing feature-ctrl-ring\n");
+
 	script = xenbus_read(XBT_NIL, dev->nodename, "script", NULL);
 	if (IS_ERR(script)) {
 		err = PTR_ERR(script);
@@ -457,7 +464,8 @@ static void backend_disconnect(struct backend_info *be)
 #ifdef CONFIG_DEBUG_FS
 		xenvif_debugfs_delif(be->vif);
 #endif /* CONFIG_DEBUG_FS */
-		xenvif_disconnect(be->vif);
+		xenvif_disconnect_data(be->vif);
+		xenvif_disconnect_ctrl(be->vif);
 	}
 }
 
@@ -825,6 +833,44 @@ static void hotplug_status_changed(struct xenbus_watch *watch,
 	kfree(str);
 }
 
+static int connect_ctrl_ring(struct backend_info *be)
+{
+	struct xenbus_device *dev = be->dev;
+	struct xenvif *vif = be->vif;
+	unsigned int val;
+	grant_ref_t ring_ref;
+	unsigned int evtchn;
+	int err;
+
+	err = xenbus_gather(XBT_NIL, dev->otherend,
+			    "ctrl-ring-ref", "%u", &val, NULL);
+	if (err)
+		return 0; /* The frontend does not have a control ring */
+
+	ring_ref = val;
+
+	err = xenbus_gather(XBT_NIL, dev->otherend,
+			    "event-channel-ctrl", "%u", &val, NULL);
+	if (err) {
+		xenbus_dev_fatal(dev, err,
+				 "reading %s/event-channel-ctrl",
+				 dev->otherend);
+		return err;
+	}
+
+	evtchn = val;
+
+	err = xenvif_connect_ctrl(vif, ring_ref, evtchn);
+	if (err) {
+		xenbus_dev_fatal(dev, err,
+				 "mapping shared-frame %u port %u",
+				 ring_ref, evtchn);
+		return err;
+	}
+
+	return 0;
+}
+
 static void connect(struct backend_info *be)
 {
 	int err;
@@ -861,6 +907,12 @@ static void connect(struct backend_info *be)
 	xen_register_watchers(dev, be->vif);
 	read_xenbus_vif_flags(be);
 
+	err = connect_ctrl_ring(be);
+	if (err) {
+		xenbus_dev_fatal(dev, err, "connecting control ring");
+		return;
+	}
+
 	/* Use the number of queues requested by the frontend */
 	be->vif->queues = vzalloc(requested_num_queues *
 				  sizeof(struct xenvif_queue));
@@ -896,11 +948,12 @@ static void connect(struct backend_info *be)
 		queue->remaining_credit = credit_bytes;
 		queue->credit_usec = credit_usec;
 
-		err = connect_rings(be, queue);
+		err = connect_data_rings(be, queue);
 		if (err) {
-			/* connect_rings() cleans up after itself on failure,
-			 * but we need to clean up after xenvif_init_queue() here,
-			 * and also clean up any previously initialised queues.
+			/* connect_data_rings() cleans up after itself on
+			 * failure, but we need to clean up after
+			 * xenvif_init_queue() here, and also clean up any
+			 * previously initialised queues.
 			 */
 			xenvif_deinit_queue(queue);
 			be->vif->num_queues = queue_index;
@@ -935,15 +988,17 @@ static void connect(struct backend_info *be)
 
 err:
 	if (be->vif->num_queues > 0)
-		xenvif_disconnect(be->vif); /* Clean up existing queues */
+		xenvif_disconnect_data(be->vif); /* Clean up existing queues */
 	vfree(be->vif->queues);
 	be->vif->queues = NULL;
 	be->vif->num_queues = 0;
+	xenvif_disconnect_ctrl(be->vif);
 	return;
 }
 
 
-static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
+static int connect_data_rings(struct backend_info *be,
+			      struct xenvif_queue *queue)
 {
 	struct xenbus_device *dev = be->dev;
 	unsigned int num_queues = queue->vif->num_queues;
@@ -1007,8 +1062,8 @@ static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
 	}
 
 	/* Map the shared frame, irq etc. */
-	err = xenvif_connect(queue, tx_ring_ref, rx_ring_ref,
-			     tx_evtchn, rx_evtchn);
+	err = xenvif_connect_data(queue, tx_ring_ref, rx_ring_ref,
+				  tx_evtchn, rx_evtchn);
 	if (err) {
 		xenbus_dev_fatal(dev, err,
 				 "mapping shared-frames %lu/%lu port tx %u rx %u",
-- 
2.1.4
