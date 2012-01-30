From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 03/16] netback: switch to NAPI + kthread model
Date: Mon, 30 Jan 2012 14:45:21 +0000
Message-ID: <1327934734-8908-4-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63150 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352Ab2A3Opi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:45:38 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements 1:1 model netback. We utilizes NAPI and kthread
to do the weight-lifting job:

  - NAPI is used for guest side TX (host side RX)
  - kthread is used for guest side RX (host side TX)

This model provides better scheduling fairness among vifs. It also
lays the foundation for future work.

The major defect for the current implementation is that in the NAPI
poll handler we don't actually disable frontend from generating
interrupt. Any tuning with ring pointers will come in as separated
commit.

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   34 ++--
 drivers/net/xen-netback/interface.c |   92 ++++++---
 drivers/net/xen-netback/netback.c   |  367 ++++++++++-------------------------
 drivers/net/xen-netback/xenbus.c    |    1 -
 4 files changed, 186 insertions(+), 308 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 372c7f5..31c331c 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -47,7 +47,6 @@
 
 struct pending_tx_info {
 	struct xen_netif_tx_request req;
-	struct xenvif *vif;
 };
 typedef unsigned int pending_ring_idx_t;
 
@@ -61,14 +60,17 @@ struct xenvif {
 	/* Reference to netback processing backend. */
 	struct xen_netbk *netbk;
 
+	/* Use NAPI for guest TX */
+	struct napi_struct napi;
+	/* Use kthread for guest RX */
+	struct task_struct *task;
+	wait_queue_head_t wq;
+
 	u8               fe_dev_addr[6];
 
 	/* Physical parameters of the comms window. */
 	unsigned int     irq;
 
-	/* List of frontends to notify after a batch of frames sent. */
-	struct list_head notify_list;
-
 	/* The shared rings and indexes. */
 	struct xen_netif_tx_back_ring tx;
 	struct xen_netif_rx_back_ring rx;
@@ -99,11 +101,7 @@ struct xenvif {
 	unsigned long rx_gso_checksum_fixup;
 
 	/* Miscellaneous private stuff. */
-	struct list_head schedule_list;
-	atomic_t         refcnt;
 	struct net_device *dev;
-
-	wait_queue_head_t waiting_to_free;
 };
 
 static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
@@ -122,9 +120,6 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		   unsigned long rx_ring_ref, unsigned int evtchn);
 void xenvif_disconnect(struct xenvif *vif);
 
-void xenvif_get(struct xenvif *vif);
-void xenvif_put(struct xenvif *vif);
-
 int xenvif_xenbus_init(void);
 void xenvif_xenbus_exit(void);
 
@@ -140,14 +135,6 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
 				 grant_ref_t tx_ring_ref,
 				 grant_ref_t rx_ring_ref);
 
-/* (De)Register a xenvif with the netback backend. */
-void xen_netbk_add_xenvif(struct xenvif *vif);
-void xen_netbk_remove_xenvif(struct xenvif *vif);
-
-/* (De)Schedule backend processing for a xenvif */
-void xen_netbk_schedule_xenvif(struct xenvif *vif);
-void xen_netbk_deschedule_xenvif(struct xenvif *vif);
-
 /* Check for SKBs from frontend and schedule backend processing */
 void xen_netbk_check_rx_xenvif(struct xenvif *vif);
 /* Receive an SKB from the frontend */
@@ -161,4 +148,13 @@ void xenvif_notify_tx_completion(struct xenvif *vif);
 /* Returns number of ring slots required to send an skb to the frontend */
 unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
 
+/* Allocate and free xen_netbk structure */
+struct xen_netbk *xen_netbk_alloc_netbk(struct xenvif *vif);
+void xen_netbk_free_netbk(struct xen_netbk *netbk);
+
+void xen_netbk_tx_action(struct xen_netbk *netbk, int *work_done, int budget);
+void xen_netbk_rx_action(struct xen_netbk *netbk);
+
+int xen_netbk_kthread(void *data);
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 1825629..dfc04f8 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -30,6 +30,7 @@
 
 #include "common.h"
 
+#include <linux/kthread.h>
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
@@ -38,17 +39,7 @@
 #include <asm/xen/hypercall.h>
 
 #define XENVIF_QUEUE_LENGTH 32
-
-void xenvif_get(struct xenvif *vif)
-{
-	atomic_inc(&vif->refcnt);
-}
-
-void xenvif_put(struct xenvif *vif)
-{
-	if (atomic_dec_and_test(&vif->refcnt))
-		wake_up(&vif->waiting_to_free);
-}
+#define XENVIF_NAPI_WEIGHT  64
 
 int xenvif_schedulable(struct xenvif *vif)
 {
@@ -67,14 +58,37 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 	if (vif->netbk == NULL)
 		return IRQ_NONE;
 
-	xen_netbk_schedule_xenvif(vif);
-
 	if (xenvif_rx_schedulable(vif))
 		netif_wake_queue(vif->dev);
 
+	if (likely(napi_schedule_prep(&vif->napi)))
+		__napi_schedule(&vif->napi);
+
 	return IRQ_HANDLED;
 }
 
+static int xenvif_poll(struct napi_struct *napi, int budget)
+{
+	struct xenvif *vif = container_of(napi, struct xenvif, napi);
+	int work_done = 0;
+
+	xen_netbk_tx_action(vif->netbk, &work_done, budget);
+
+	if (work_done < budget) {
+		int more_to_do = 0;
+		unsigned long flag;
+		local_irq_save(flag);
+
+		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
+		if (!more_to_do)
+			__napi_complete(napi);
+
+		local_irq_restore(flag);
+	}
+
+	return work_done;
+}
+
 static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
@@ -90,7 +104,6 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Reserve ring slots for the worst-case number of fragments. */
 	vif->rx_req_cons_peek += xen_netbk_count_skb_slots(vif, skb);
-	xenvif_get(vif);
 
 	if (vif->can_queue && xen_netbk_must_stop_queue(vif))
 		netif_stop_queue(dev);
@@ -107,7 +120,7 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb)
 {
-	netif_rx_ni(skb);
+	netif_receive_skb(skb);
 }
 
 void xenvif_notify_tx_completion(struct xenvif *vif)
@@ -124,16 +137,15 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 
 static void xenvif_up(struct xenvif *vif)
 {
-	xen_netbk_add_xenvif(vif);
+	napi_enable(&vif->napi);
 	enable_irq(vif->irq);
 	xen_netbk_check_rx_xenvif(vif);
 }
 
 static void xenvif_down(struct xenvif *vif)
 {
+	napi_disable(&vif->napi);
 	disable_irq(vif->irq);
-	xen_netbk_deschedule_xenvif(vif);
-	xen_netbk_remove_xenvif(vif);
 }
 
 static int xenvif_open(struct net_device *dev)
@@ -259,14 +271,11 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif = netdev_priv(dev);
 	vif->domid  = domid;
 	vif->handle = handle;
-	vif->netbk  = NULL;
+	vif->netbk = NULL;
+
 	vif->can_sg = 1;
 	vif->csum = 1;
-	atomic_set(&vif->refcnt, 1);
-	init_waitqueue_head(&vif->waiting_to_free);
 	vif->dev = dev;
-	INIT_LIST_HEAD(&vif->schedule_list);
-	INIT_LIST_HEAD(&vif->notify_list);
 
 	vif->credit_bytes = vif->remaining_credit = ~0UL;
 	vif->credit_usec  = 0UL;
@@ -290,6 +299,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	memset(dev->dev_addr, 0xFF, ETH_ALEN);
 	dev->dev_addr[0] &= ~0x01;
 
+	netif_napi_add(dev, &vif->napi, xenvif_poll, XENVIF_NAPI_WEIGHT);
+
 	netif_carrier_off(dev);
 
 	err = register_netdev(dev);
@@ -324,7 +335,23 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	vif->irq = err;
 	disable_irq(vif->irq);
 
-	xenvif_get(vif);
+	vif->netbk = xen_netbk_alloc_netbk(vif);
+	if (!vif->netbk) {
+		pr_warn("Could not allocate xen_netbk\n");
+		err = -ENOMEM;
+		goto err_unbind;
+	}
+
+
+	init_waitqueue_head(&vif->wq);
+	vif->task = kthread_create(xen_netbk_kthread,
+				   (void *)vif,
+				   "vif%d.%d", vif->domid, vif->handle);
+	if (IS_ERR(vif->task)) {
+		pr_warn("Could not create kthread\n");
+		err = PTR_ERR(vif->task);
+		goto err_free_netbk;
+	}
 
 	rtnl_lock();
 	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
@@ -335,7 +362,13 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		xenvif_up(vif);
 	rtnl_unlock();
 
+	wake_up_process(vif->task);
+
 	return 0;
+err_free_netbk:
+	xen_netbk_free_netbk(vif->netbk);
+err_unbind:
+	unbind_from_irqhandler(vif->irq, vif);
 err_unmap:
 	xen_netbk_unmap_frontend_rings(vif);
 err:
@@ -345,17 +378,22 @@ err:
 void xenvif_disconnect(struct xenvif *vif)
 {
 	struct net_device *dev = vif->dev;
+
 	if (netif_carrier_ok(dev)) {
 		rtnl_lock();
 		netif_carrier_off(dev); /* discard queued packets */
 		if (netif_running(dev))
 			xenvif_down(vif);
 		rtnl_unlock();
-		xenvif_put(vif);
 	}
 
-	atomic_dec(&vif->refcnt);
-	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
+	if (vif->task)
+		kthread_stop(vif->task);
+
+	if (vif->netbk)
+		xen_netbk_free_netbk(vif->netbk);
+
+	netif_napi_del(&vif->napi);
 
 	del_timer_sync(&vif->credit_timeout);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 3059684..9a72993 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -61,24 +61,15 @@ struct netbk_rx_meta {
 #define MAX_BUFFER_OFFSET PAGE_SIZE
 
 struct xen_netbk {
-	wait_queue_head_t wq;
-	struct task_struct *task;
-
 	struct sk_buff_head rx_queue;
 	struct sk_buff_head tx_queue;
 
-	struct timer_list net_timer;
-
 	idx_t mmap_pages[MAX_PENDING_REQS];
 
 	pending_ring_idx_t pending_prod;
 	pending_ring_idx_t pending_cons;
-	struct list_head net_schedule_list;
-
-	/* Protect the net_schedule_list in netif. */
-	spinlock_t net_schedule_list_lock;
 
-	atomic_t netfront_count;
+	struct xenvif *vif;
 
 	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
 
@@ -93,42 +84,14 @@ struct xen_netbk {
 	struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
 };
 
-static struct xen_netbk *xen_netbk;
-static int xen_netbk_group_nr;
-
-void xen_netbk_add_xenvif(struct xenvif *vif)
-{
-	int i;
-	int min_netfront_count;
-	int min_group = 0;
-	struct xen_netbk *netbk;
-
-	min_netfront_count = atomic_read(&xen_netbk[0].netfront_count);
-	for (i = 0; i < xen_netbk_group_nr; i++) {
-		int netfront_count = atomic_read(&xen_netbk[i].netfront_count);
-		if (netfront_count < min_netfront_count) {
-			min_group = i;
-			min_netfront_count = netfront_count;
-		}
-	}
-
-	netbk = &xen_netbk[min_group];
-
-	vif->netbk = netbk;
-	atomic_inc(&netbk->netfront_count);
-}
-
-void xen_netbk_remove_xenvif(struct xenvif *vif)
-{
-	struct xen_netbk *netbk = vif->netbk;
-	vif->netbk = NULL;
-	atomic_dec(&netbk->netfront_count);
-}
-
 static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx);
 static void make_tx_response(struct xenvif *vif,
 			     struct xen_netif_tx_request *txp,
 			     s8       st);
+
+static inline int tx_work_todo(struct xen_netbk *netbk);
+static inline int rx_work_todo(struct xen_netbk *netbk);
+
 static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 					     u16      id,
 					     s8       st,
@@ -179,11 +142,6 @@ static inline pending_ring_idx_t nr_pending_reqs(struct xen_netbk *netbk)
 		netbk->pending_prod + netbk->pending_cons;
 }
 
-static void xen_netbk_kick_thread(struct xen_netbk *netbk)
-{
-	wake_up(&netbk->wq);
-}
-
 static int max_required_rx_slots(struct xenvif *vif)
 {
 	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
@@ -368,8 +326,9 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop->flags = GNTCOPY_dest_gref;
 		if (foreign) {
 			struct pending_tx_info *src_pend = to_txinfo(idx);
+			struct xen_netbk *rnetbk = to_netbk(idx);
 
-			copy_gop->source.domid = src_pend->vif->domid;
+			copy_gop->source.domid = rnetbk->vif->domid;
 			copy_gop->source.u.ref = src_pend->req.gref;
 			copy_gop->flags |= GNTCOPY_source_gref;
 		} else {
@@ -527,11 +486,18 @@ struct skb_cb_overlay {
 	int meta_slots_used;
 };
 
-static void xen_netbk_rx_action(struct xen_netbk *netbk)
+static void xen_netbk_kick_thread(struct xen_netbk *netbk)
 {
-	struct xenvif *vif = NULL, *tmp;
+	struct xenvif *vif = netbk->vif;
+
+	wake_up(&vif->wq);
+}
+
+void xen_netbk_rx_action(struct xen_netbk *netbk)
+{
+	struct xenvif *vif = NULL;
 	s8 status;
-	u16 irq, flags;
+	u16 flags;
 	struct xen_netif_rx_response *resp;
 	struct sk_buff_head rxq;
 	struct sk_buff *skb;
@@ -541,6 +507,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 	int count;
 	unsigned long offset;
 	struct skb_cb_overlay *sco;
+	int need_to_notify = 0;
 
 	struct netrx_pending_operations npo = {
 		.copy  = netbk->grant_copy_op,
@@ -641,25 +608,19 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 					 sco->meta_slots_used);
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
-		irq = vif->irq;
-		if (ret && list_empty(&vif->notify_list))
-			list_add_tail(&vif->notify_list, &notify);
+		if (ret)
+			need_to_notify = 1;
 
 		xenvif_notify_tx_completion(vif);
 
-		xenvif_put(vif);
 		npo.meta_cons += sco->meta_slots_used;
 		dev_kfree_skb(skb);
 	}
 
-	list_for_each_entry_safe(vif, tmp, &notify, notify_list) {
+	if (need_to_notify)
 		notify_remote_via_irq(vif->irq);
-		list_del_init(&vif->notify_list);
-	}
 
-	/* More work to do? */
-	if (!skb_queue_empty(&netbk->rx_queue) &&
-			!timer_pending(&netbk->net_timer))
+	if (!skb_queue_empty(&netbk->rx_queue))
 		xen_netbk_kick_thread(netbk);
 }
 
@@ -672,86 +633,17 @@ void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
 	xen_netbk_kick_thread(netbk);
 }
 
-static void xen_netbk_alarm(unsigned long data)
-{
-	struct xen_netbk *netbk = (struct xen_netbk *)data;
-	xen_netbk_kick_thread(netbk);
-}
-
-static int __on_net_schedule_list(struct xenvif *vif)
-{
-	return !list_empty(&vif->schedule_list);
-}
-
-/* Must be called with net_schedule_list_lock held */
-static void remove_from_net_schedule_list(struct xenvif *vif)
-{
-	if (likely(__on_net_schedule_list(vif))) {
-		list_del_init(&vif->schedule_list);
-		xenvif_put(vif);
-	}
-}
-
-static struct xenvif *poll_net_schedule_list(struct xen_netbk *netbk)
-{
-	struct xenvif *vif = NULL;
-
-	spin_lock_irq(&netbk->net_schedule_list_lock);
-	if (list_empty(&netbk->net_schedule_list))
-		goto out;
-
-	vif = list_first_entry(&netbk->net_schedule_list,
-			       struct xenvif, schedule_list);
-	if (!vif)
-		goto out;
-
-	xenvif_get(vif);
-
-	remove_from_net_schedule_list(vif);
-out:
-	spin_unlock_irq(&netbk->net_schedule_list_lock);
-	return vif;
-}
-
-void xen_netbk_schedule_xenvif(struct xenvif *vif)
-{
-	unsigned long flags;
-	struct xen_netbk *netbk = vif->netbk;
-
-	if (__on_net_schedule_list(vif))
-		goto kick;
-
-	spin_lock_irqsave(&netbk->net_schedule_list_lock, flags);
-	if (!__on_net_schedule_list(vif) &&
-	    likely(xenvif_schedulable(vif))) {
-		list_add_tail(&vif->schedule_list, &netbk->net_schedule_list);
-		xenvif_get(vif);
-	}
-	spin_unlock_irqrestore(&netbk->net_schedule_list_lock, flags);
-
-kick:
-	smp_mb();
-	if ((nr_pending_reqs(netbk) < (MAX_PENDING_REQS/2)) &&
-	    !list_empty(&netbk->net_schedule_list))
-		xen_netbk_kick_thread(netbk);
-}
-
-void xen_netbk_deschedule_xenvif(struct xenvif *vif)
-{
-	struct xen_netbk *netbk = vif->netbk;
-	spin_lock_irq(&netbk->net_schedule_list_lock);
-	remove_from_net_schedule_list(vif);
-	spin_unlock_irq(&netbk->net_schedule_list_lock);
-}
-
 void xen_netbk_check_rx_xenvif(struct xenvif *vif)
 {
 	int more_to_do;
 
 	RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
 
+	/* In this check function, we are supposed to do be's rx,
+	 * which means fe's tx */
+
 	if (more_to_do)
-		xen_netbk_schedule_xenvif(vif);
+		napi_schedule(&vif->napi);
 }
 
 static void tx_add_credit(struct xenvif *vif)
@@ -794,7 +686,6 @@ static void netbk_tx_err(struct xenvif *vif,
 	} while (1);
 	vif->tx.req_cons = cons;
 	xen_netbk_check_rx_xenvif(vif);
-	xenvif_put(vif);
 }
 
 static int netbk_count_requests(struct xenvif *vif,
@@ -894,8 +785,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		gop++;
 
 		memcpy(&pending_tx_info->req, txp, sizeof(*txp));
-		xenvif_get(vif);
-		pending_tx_info->vif = vif;
+
 		frag_set_pending_idx(&frags[i], pending_idx);
 	}
 
@@ -910,7 +800,8 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	u16 pending_idx = *((u16 *)skb->data);
 	struct pending_tx_info *pending_tx_info;
 	int idx;
-	struct xenvif *vif = NULL;
+	struct xenvif *vif = netbk->vif;
+
 	struct xen_netif_tx_request *txp;
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -924,10 +815,8 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		idx = netbk->mmap_pages[index];
 		pending_tx_info = to_txinfo(idx);
 		txp = &pending_tx_info->req;
-		vif = pending_tx_info->vif;
 		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
 		netbk->pending_ring[index] = pending_idx;
-		xenvif_put(vif);
 	}
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
@@ -951,11 +840,9 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		/* Error on this fragment: respond to client with an error. */
 		idx = netbk->mmap_pages[pending_idx];
 		txp = &to_txinfo(idx)->req;
-		vif = to_txinfo(idx)->vif;
 		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
 		index = pending_index(netbk->pending_prod++);
 		netbk->pending_ring[index] = pending_idx;
-		xenvif_put(vif);
 
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
@@ -1171,10 +1058,9 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 	struct gnttab_copy *gop = netbk->tx_copy_ops, *request_gop;
 	struct sk_buff *skb;
 	int ret;
+	struct xenvif *vif = netbk->vif;
 
-	while (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) &&
-		!list_empty(&netbk->net_schedule_list)) {
-		struct xenvif *vif;
+	while ((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) {
 		struct xen_netif_tx_request txreq;
 		struct xen_netif_tx_request txfrags[MAX_SKB_FRAGS];
 		struct page *page;
@@ -1187,26 +1073,19 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		int pool_idx;
 		struct pending_tx_info *pending_tx_info;
 
-		/* Get a netif from the list with work to do. */
-		vif = poll_net_schedule_list(netbk);
-		if (!vif)
-			continue;
-
 		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, work_to_do);
 		if (!work_to_do) {
-			xenvif_put(vif);
-			continue;
+			break;
 		}
 
 		idx = vif->tx.req_cons;
 		rmb(); /* Ensure that we see the request before we copy it. */
 		memcpy(&txreq, RING_GET_REQUEST(&vif->tx, idx), sizeof(txreq));
 
-		/* Credit-based scheduling. */
+		/* Credit-based traffic shaping. */
 		if (txreq.size > vif->remaining_credit &&
 		    tx_credit_exceeded(vif, txreq.size)) {
-			xenvif_put(vif);
-			continue;
+			break;
 		}
 
 		vif->remaining_credit -= txreq.size;
@@ -1221,14 +1100,14 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 			idx = vif->tx.req_cons;
 			if (unlikely(work_to_do < 0)) {
 				netbk_tx_err(vif, &txreq, idx);
-				continue;
+				break;
 			}
 		}
 
 		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do);
 		if (unlikely(ret < 0)) {
 			netbk_tx_err(vif, &txreq, idx - ret);
-			continue;
+			break;
 		}
 		idx += ret;
 
@@ -1236,7 +1115,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 			netdev_dbg(vif->dev,
 				   "Bad packet size: %d\n", txreq.size);
 			netbk_tx_err(vif, &txreq, idx);
-			continue;
+			break;
 		}
 
 		/* No crossing a page as the payload mustn't fragment. */
@@ -1246,7 +1125,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 				   txreq.offset, txreq.size,
 				   (txreq.offset&~PAGE_MASK) + txreq.size);
 			netbk_tx_err(vif, &txreq, idx);
-			continue;
+			break;
 		}
 
 		index = pending_index(netbk->pending_cons);
@@ -1275,7 +1154,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 			if (netbk_set_skb_gso(vif, skb, gso)) {
 				kfree_skb(skb);
 				netbk_tx_err(vif, &txreq, idx);
-				continue;
+				break;
 			}
 		}
 
@@ -1284,7 +1163,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		if (!page) {
 			kfree_skb(skb);
 			netbk_tx_err(vif, &txreq, idx);
-			continue;
+			break;
 		}
 
 		gop->source.u.ref = txreq.gref;
@@ -1305,7 +1184,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 
 		memcpy(&pending_tx_info->req,
 		       &txreq, sizeof(txreq));
-		pending_tx_info->vif = vif;
+
 		*((u16 *)skb->data) = pending_idx;
 
 		__skb_put(skb, data_len);
@@ -1329,7 +1208,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		if (request_gop == NULL) {
 			kfree_skb(skb);
 			netbk_tx_err(vif, &txreq, idx);
-			continue;
+			break;
 		}
 		gop = request_gop;
 
@@ -1343,14 +1222,16 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 	return gop - netbk->tx_copy_ops;
 }
 
-static void xen_netbk_tx_submit(struct xen_netbk *netbk)
+static void xen_netbk_tx_submit(struct xen_netbk *netbk,
+				int *work_done, int budget)
 {
 	struct gnttab_copy *gop = netbk->tx_copy_ops;
 	struct sk_buff *skb;
+	struct xenvif *vif = netbk->vif;
 
-	while ((skb = __skb_dequeue(&netbk->tx_queue)) != NULL) {
+	while ((*work_done < budget) &&
+	       (skb = __skb_dequeue(&netbk->tx_queue)) != NULL) {
 		struct xen_netif_tx_request *txp;
-		struct xenvif *vif;
 		u16 pending_idx;
 		unsigned data_len;
 		int idx;
@@ -1361,7 +1242,6 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
 		idx = netbk->mmap_pages[pending_idx];
 		pending_tx_info = to_txinfo(idx);
 
-		vif = pending_tx_info->vif;
 		txp = &pending_tx_info->req;
 
 		/* Check the remap error code. */
@@ -1415,16 +1295,21 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
 		vif->dev->stats.rx_bytes += skb->len;
 		vif->dev->stats.rx_packets++;
 
+		(*work_done)++;
+
 		xenvif_receive_skb(vif, skb);
 	}
 }
 
 /* Called after netfront has transmitted */
-static void xen_netbk_tx_action(struct xen_netbk *netbk)
+void xen_netbk_tx_action(struct xen_netbk *netbk, int *work_done, int budget)
 {
 	unsigned nr_gops;
 	int ret;
 
+	if (unlikely(!tx_work_todo(netbk)))
+		return;
+
 	nr_gops = xen_netbk_tx_build_gops(netbk);
 
 	if (nr_gops == 0)
@@ -1433,13 +1318,12 @@ static void xen_netbk_tx_action(struct xen_netbk *netbk)
 					netbk->tx_copy_ops, nr_gops);
 	BUG_ON(ret);
 
-	xen_netbk_tx_submit(netbk);
-
+	xen_netbk_tx_submit(netbk, work_done, budget);
 }
 
 static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
 {
-	struct xenvif *vif;
+	struct xenvif *vif = netbk->vif;
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t index;
 	int idx;
@@ -1451,15 +1335,11 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
 	idx = netbk->mmap_pages[pending_idx];
 	pending_tx_info = to_txinfo(idx);
 
-	vif = pending_tx_info->vif;
-
 	make_tx_response(vif, &pending_tx_info->req, XEN_NETIF_RSP_OKAY);
 
 	index = pending_index(netbk->pending_prod++);
 	netbk->pending_ring[index] = pending_idx;
 
-	xenvif_put(vif);
-
 	page_pool_put(netbk->mmap_pages[pending_idx]);
 
 	netbk->mmap_pages[pending_idx] = INVALID_ENTRY;
@@ -1516,37 +1396,13 @@ static inline int rx_work_todo(struct xen_netbk *netbk)
 
 static inline int tx_work_todo(struct xen_netbk *netbk)
 {
-
-	if (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) &&
-			!list_empty(&netbk->net_schedule_list))
+	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&netbk->vif->tx)) &&
+	    (nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS)
 		return 1;
 
 	return 0;
 }
 
-static int xen_netbk_kthread(void *data)
-{
-	struct xen_netbk *netbk = data;
-	while (!kthread_should_stop()) {
-		wait_event_interruptible(netbk->wq,
-				rx_work_todo(netbk) ||
-				tx_work_todo(netbk) ||
-				kthread_should_stop());
-		cond_resched();
-
-		if (kthread_should_stop())
-			break;
-
-		if (rx_work_todo(netbk))
-			xen_netbk_rx_action(netbk);
-
-		if (tx_work_todo(netbk))
-			xen_netbk_tx_action(netbk);
-	}
-
-	return 0;
-}
-
 void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
 {
 	if (vif->tx.sring)
@@ -1592,78 +1448,74 @@ err:
 	return err;
 }
 
-static int __init netback_init(void)
+struct xen_netbk *xen_netbk_alloc_netbk(struct xenvif *vif)
 {
 	int i;
-	int rc = 0;
-	int group;
-
-	if (!xen_domain())
-		return -ENODEV;
+	struct xen_netbk *netbk;
 
-	xen_netbk_group_nr = num_online_cpus();
-	xen_netbk = vzalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
-	if (!xen_netbk) {
+	netbk = vzalloc(sizeof(struct xen_netbk));
+	if (!netbk) {
 		printk(KERN_ALERT "%s: out of memory\n", __func__);
-		return -ENOMEM;
+		return NULL;
 	}
 
-	for (group = 0; group < xen_netbk_group_nr; group++) {
-		struct xen_netbk *netbk = &xen_netbk[group];
-		skb_queue_head_init(&netbk->rx_queue);
-		skb_queue_head_init(&netbk->tx_queue);
-
-		init_timer(&netbk->net_timer);
-		netbk->net_timer.data = (unsigned long)netbk;
-		netbk->net_timer.function = xen_netbk_alarm;
-
-		netbk->pending_cons = 0;
-		netbk->pending_prod = MAX_PENDING_REQS;
-		for (i = 0; i < MAX_PENDING_REQS; i++)
-			netbk->pending_ring[i] = i;
-
-		init_waitqueue_head(&netbk->wq);
-		netbk->task = kthread_create(xen_netbk_kthread,
-					     (void *)netbk,
-					     "netback/%u", group);
-
-		if (IS_ERR(netbk->task)) {
-			printk(KERN_ALERT "kthread_create() fails at netback\n");
-			del_timer(&netbk->net_timer);
-			rc = PTR_ERR(netbk->task);
-			goto failed_init;
-		}
+	netbk->vif = vif;
 
-		kthread_bind(netbk->task, group);
+	skb_queue_head_init(&netbk->rx_queue);
+	skb_queue_head_init(&netbk->tx_queue);
 
-		INIT_LIST_HEAD(&netbk->net_schedule_list);
+	netbk->pending_cons = 0;
+	netbk->pending_prod = MAX_PENDING_REQS;
+	for (i = 0; i < MAX_PENDING_REQS; i++)
+		netbk->pending_ring[i] = i;
 
-		spin_lock_init(&netbk->net_schedule_list_lock);
+	for (i = 0; i < MAX_PENDING_REQS; i++)
+		netbk->mmap_pages[i] = INVALID_ENTRY;
 
-		atomic_set(&netbk->netfront_count, 0);
+	return netbk;
+}
 
-		wake_up_process(netbk->task);
+void xen_netbk_free_netbk(struct xen_netbk *netbk)
+{
+	vfree(netbk);
+}
+
+int xen_netbk_kthread(void *data)
+{
+	struct xenvif *vif = data;
+	struct xen_netbk *netbk = vif->netbk;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(vif->wq,
+					 rx_work_todo(netbk) ||
+					 kthread_should_stop());
+		cond_resched();
+
+		if (kthread_should_stop())
+			break;
+
+		if (rx_work_todo(netbk))
+			xen_netbk_rx_action(netbk);
 	}
 
+	return 0;
+}
+
+
+static int __init netback_init(void)
+{
+	int rc = 0;
+
+	if (!xen_domain())
+		return -ENODEV;
+
 	rc = page_pool_init();
 	if (rc)
 		goto failed_init;
 
-	rc = xenvif_xenbus_init();
-	if (rc)
-		goto pool_failed_init;
-
-	return 0;
+	return xenvif_xenbus_init();
 
-pool_failed_init:
-	page_pool_destroy();
 failed_init:
-	while (--group >= 0) {
-		struct xen_netbk *netbk = &xen_netbk[group];
-		del_timer(&netbk->net_timer);
-		kthread_stop(netbk->task);
-	}
-	vfree(xen_netbk);
 	return rc;
 
 }
@@ -1672,14 +1524,7 @@ module_init(netback_init);
 
 static void __exit netback_exit(void)
 {
-	int i;
 	xenvif_xenbus_exit();
-	for (i = 0; i < xen_netbk_group_nr; i++) {
-		struct xen_netbk *netbk = &xen_netbk[i];
-		del_timer_sync(&netbk->net_timer);
-		kthread_stop(netbk->task);
-	}
-	vfree(xen_netbk);
 	page_pool_destroy();
 }
 module_exit(netback_exit);
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 65d14f2..f1e89ca 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -387,7 +387,6 @@ static void connect(struct backend_info *be)
 	netif_wake_queue(be->vif->dev);
 }
 
-
 static int connect_rings(struct backend_info *be)
 {
 	struct xenvif *vif = be->vif;
-- 
1.7.2.5
