From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next 3/3] xen-netback: switch to NAPI + kthread 1:1 model
Date: Fri, 24 May 2013 11:32:33 +0100
Message-ID: <1369391553-16835-4-git-send-email-wei.liu2@citrix.com>
References: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:29464 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760337Ab3EXKcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 06:32:36 -0400
In-Reply-To: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements 1:1 model netback. NAPI and kthread are utilized to do
the weight-lifting job:

 - NAPI is used for guest side TX (host side RX)
 - kthread is used for guest side RX (host side TX)

Xenvif and xen_netbk are made into one structure to reduce code size.

This model provides better scheduling fairness among vifs. It is also
prerequisite for implementing multiqueue for Xen netback.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   84 +++--
 drivers/net/xen-netback/interface.c |  124 +++---
 drivers/net/xen-netback/netback.c   |  706 ++++++++++++-----------------------
 drivers/net/xen-netback/page_pool.c |   10 +-
 drivers/net/xen-netback/page_pool.h |    6 +-
 5 files changed, 374 insertions(+), 556 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 96f033d..6acdf6f 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -45,27 +45,43 @@
 #include <xen/grant_table.h>
 #include <xen/xenbus.h>
 
-struct xen_netbk;
-
 typedef unsigned int pending_ring_idx_t;
 #define INVALID_PENDING_RING_IDX (~0U)
 
 struct pending_tx_info {
 	struct xen_netif_tx_request req; /* coalesced tx request */
-	struct xenvif *vif;
 	pending_ring_idx_t head; /* head != INVALID_PENDING_RING_IDX
 				  * if it is head of one or more tx
 				  * reqs
 				  */
 };
 
+#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
+#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
+
+struct xenvif_rx_meta {
+	int id;
+	int size;
+	int gso_size;
+};
+
+/* Discriminate from any valid pending_idx value. */
+#define INVALID_PENDING_IDX 0xFFFF
+
+#define MAX_BUFFER_OFFSET PAGE_SIZE
+
+#define MAX_PENDING_REQS 256
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
 	unsigned int     handle;
 
-	/* Reference to netback processing backend. */
-	struct xen_netbk *netbk;
+	/* Use NAPI for guest TX */
+	struct napi_struct napi;
+	/* Use kthread for guest RX */
+	struct task_struct *task;
+	wait_queue_head_t wq;
 
 	u8               fe_dev_addr[6];
 
@@ -76,9 +92,6 @@ struct xenvif {
 	char tx_irq_name[IFNAMSIZ+4]; /* DEVNAME-tx */
 	char rx_irq_name[IFNAMSIZ+4]; /* DEVNAME-rx */
 
-	/* List of frontends to notify after a batch of frames sent. */
-	struct list_head notify_list;
-
 	/* The shared rings and indexes. */
 	struct xen_netif_tx_back_ring tx;
 	struct xen_netif_rx_back_ring rx;
@@ -108,12 +121,20 @@ struct xenvif {
 	/* Statistics */
 	unsigned long rx_gso_checksum_fixup;
 
+	struct sk_buff_head rx_queue;
+	struct sk_buff_head tx_queue;
+
+	int32_t mmap_pages[MAX_PENDING_REQS];
+
+	pending_ring_idx_t pending_prod;
+	pending_ring_idx_t pending_cons;
+
+	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
+
+	u16 pending_ring[MAX_PENDING_REQS];
+
 	/* Miscellaneous private stuff. */
-	struct list_head schedule_list;
-	atomic_t         refcnt;
 	struct net_device *dev;
-
-	wait_queue_head_t waiting_to_free;
 };
 
 static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
@@ -121,9 +142,6 @@ static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
 	return to_xenbus_device(vif->dev->dev.parent);
 }
 
-#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
-
 struct xenvif *xenvif_alloc(struct device *parent,
 			    domid_t domid,
 			    unsigned int handle);
@@ -133,39 +151,26 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		   unsigned int rx_evtchn);
 void xenvif_disconnect(struct xenvif *vif);
 
-void xenvif_get(struct xenvif *vif);
-void xenvif_put(struct xenvif *vif);
-
 int xenvif_xenbus_init(void);
 void xenvif_xenbus_fini(void);
 
 int xenvif_schedulable(struct xenvif *vif);
 
-int xen_netbk_rx_ring_full(struct xenvif *vif);
+int xenvif_rx_ring_full(struct xenvif *vif);
 
-int xen_netbk_must_stop_queue(struct xenvif *vif);
+int xenvif_must_stop_queue(struct xenvif *vif);
 
 /* (Un)Map communication rings. */
-void xen_netbk_unmap_frontend_rings(struct xenvif *vif);
-int xen_netbk_map_frontend_rings(struct xenvif *vif,
-				 grant_ref_t tx_ring_ref,
-				 grant_ref_t rx_ring_ref);
-
-/* (De)Register a xenvif with the netback backend. */
-void xen_netbk_add_xenvif(struct xenvif *vif);
-void xen_netbk_remove_xenvif(struct xenvif *vif);
-
-/* (De)Schedule backend processing for a xenvif */
-void xen_netbk_schedule_xenvif(struct xenvif *vif);
-void xen_netbk_deschedule_xenvif(struct xenvif *vif);
+void xenvif_unmap_frontend_rings(struct xenvif *vif);
+int xenvif_map_frontend_rings(struct xenvif *vif,
+			      grant_ref_t tx_ring_ref,
+			      grant_ref_t rx_ring_ref);
 
 /* Check for SKBs from frontend and schedule backend processing */
-void xen_netbk_check_rx_xenvif(struct xenvif *vif);
-/* Receive an SKB from the frontend */
-void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb);
+void xenvif_check_rx_xenvif(struct xenvif *vif);
 
 /* Queue an SKB for transmission to the frontend */
-void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb);
+void xenvif_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb);
 /* Notify xenvif that ring now has space to send an skb to the frontend */
 void xenvif_notify_tx_completion(struct xenvif *vif);
 
@@ -173,7 +178,12 @@ void xenvif_notify_tx_completion(struct xenvif *vif);
 void xenvif_carrier_off(struct xenvif *vif);
 
 /* Returns number of ring slots required to send an skb to the frontend */
-unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
+unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
+
+int xenvif_tx_action(struct xenvif *vif, int budget);
+void xenvif_rx_action(struct xenvif *vif);
+
+int xenvif_kthread(void *data);
 
 extern bool separate_tx_rx_irq;
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 087d2db..1d849fc 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -30,6 +30,7 @@
 
 #include "common.h"
 
+#include <linux/kthread.h>
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
@@ -37,18 +38,10 @@
 #include <xen/events.h>
 #include <asm/xen/hypercall.h>
 
-#define XENVIF_QUEUE_LENGTH 32
-
-void xenvif_get(struct xenvif *vif)
-{
-	atomic_inc(&vif->refcnt);
-}
+#include "page_pool.h"
 
-void xenvif_put(struct xenvif *vif)
-{
-	if (atomic_dec_and_test(&vif->refcnt))
-		wake_up(&vif->waiting_to_free);
-}
+#define XENVIF_QUEUE_LENGTH 32
+#define XENVIF_NAPI_WEIGHT  64
 
 int xenvif_schedulable(struct xenvif *vif)
 {
@@ -57,28 +50,46 @@ int xenvif_schedulable(struct xenvif *vif)
 
 static int xenvif_rx_schedulable(struct xenvif *vif)
 {
-	return xenvif_schedulable(vif) && !xen_netbk_rx_ring_full(vif);
+	return xenvif_schedulable(vif) && !xenvif_rx_ring_full(vif);
 }
 
 static irqreturn_t xenvif_tx_interrupt(int irq, void *dev_id)
 {
 	struct xenvif *vif = dev_id;
 
-	if (vif->netbk == NULL)
-		return IRQ_HANDLED;
-
-	xen_netbk_schedule_xenvif(vif);
+	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
+		napi_schedule(&vif->napi);
 
 	return IRQ_HANDLED;
 }
 
+static int xenvif_poll(struct napi_struct *napi, int budget)
+{
+	struct xenvif *vif = container_of(napi, struct xenvif, napi);
+	int work_done;
+
+	work_done = xenvif_tx_action(vif, budget);
+
+	if (work_done < budget) {
+		int more_to_do = 0;
+		unsigned long flags;
+
+		local_irq_save(flags);
+
+		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
+		if (!more_to_do || work_done < 0)
+			__napi_complete(napi);
+
+		local_irq_restore(flags);
+	}
+
+	return work_done;
+}
+
 static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
 {
 	struct xenvif *vif = dev_id;
 
-	if (vif->netbk == NULL)
-		return IRQ_HANDLED;
-
 	if (xenvif_rx_schedulable(vif))
 		netif_wake_queue(vif->dev);
 
@@ -99,7 +110,8 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	BUG_ON(skb->dev != dev);
 
-	if (vif->netbk == NULL)
+	/* Drop the packet if vif is not ready */
+	if (vif->task == NULL)
 		goto drop;
 
 	/* Drop the packet if the target domain has no receive buffers. */
@@ -107,13 +119,12 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 
 	/* Reserve ring slots for the worst-case number of fragments. */
-	vif->rx_req_cons_peek += xen_netbk_count_skb_slots(vif, skb);
-	xenvif_get(vif);
+	vif->rx_req_cons_peek += xenvif_count_skb_slots(vif, skb);
 
-	if (vif->can_queue && xen_netbk_must_stop_queue(vif))
+	if (vif->can_queue && xenvif_must_stop_queue(vif))
 		netif_stop_queue(dev);
 
-	xen_netbk_queue_tx_skb(vif, skb);
+	xenvif_queue_tx_skb(vif, skb);
 
 	return NETDEV_TX_OK;
 
@@ -123,11 +134,6 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb)
-{
-	netif_rx_ni(skb);
-}
-
 void xenvif_notify_tx_completion(struct xenvif *vif)
 {
 	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif))
@@ -142,21 +148,20 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 
 static void xenvif_up(struct xenvif *vif)
 {
-	xen_netbk_add_xenvif(vif);
+	napi_enable(&vif->napi);
 	enable_irq(vif->tx_irq);
 	if (vif->tx_irq != vif->rx_irq)
 		enable_irq(vif->rx_irq);
-	xen_netbk_check_rx_xenvif(vif);
+	xenvif_check_rx_xenvif(vif);
 }
 
 static void xenvif_down(struct xenvif *vif)
 {
+	napi_disable(&vif->napi);
 	disable_irq(vif->tx_irq);
 	if (vif->tx_irq != vif->rx_irq)
 		disable_irq(vif->rx_irq);
 	del_timer_sync(&vif->credit_timeout);
-	xen_netbk_deschedule_xenvif(vif);
-	xen_netbk_remove_xenvif(vif);
 }
 
 static int xenvif_open(struct net_device *dev)
@@ -272,11 +277,13 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	struct net_device *dev;
 	struct xenvif *vif;
 	char name[IFNAMSIZ] = {};
+	int i;
 
 	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
 	dev = alloc_netdev(sizeof(struct xenvif), name, ether_setup);
 	if (dev == NULL) {
-		pr_warn("Could not allocate netdev\n");
+		printk(KERN_WARNING "xen-netback: Could not allocate netdev for vif%d.%d\n",
+		       domid, handle);
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -285,14 +292,9 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif = netdev_priv(dev);
 	vif->domid  = domid;
 	vif->handle = handle;
-	vif->netbk  = NULL;
 	vif->can_sg = 1;
 	vif->csum = 1;
-	atomic_set(&vif->refcnt, 1);
-	init_waitqueue_head(&vif->waiting_to_free);
 	vif->dev = dev;
-	INIT_LIST_HEAD(&vif->schedule_list);
-	INIT_LIST_HEAD(&vif->notify_list);
 
 	vif->credit_bytes = vif->remaining_credit = ~0UL;
 	vif->credit_usec  = 0UL;
@@ -307,6 +309,16 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 
 	dev->tx_queue_len = XENVIF_QUEUE_LENGTH;
 
+	skb_queue_head_init(&vif->rx_queue);
+	skb_queue_head_init(&vif->tx_queue);
+
+	vif->pending_cons = 0;
+	vif->pending_prod = MAX_PENDING_REQS;
+	for (i = 0; i < MAX_PENDING_REQS; i++)
+		vif->pending_ring[i] = i;
+	for (i = 0; i < MAX_PENDING_REQS; i++)
+		vif->mmap_pages[i] = PAGE_POOL_INVALID_IDX;
+
 	/*
 	 * Initialise a dummy MAC address. We choose the numerically
 	 * largest non-broadcast address to prevent the address getting
@@ -316,6 +328,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	memset(dev->dev_addr, 0xFF, ETH_ALEN);
 	dev->dev_addr[0] &= ~0x01;
 
+	netif_napi_add(dev, &vif->napi, xenvif_poll, XENVIF_NAPI_WEIGHT);
+
 	netif_carrier_off(dev);
 
 	err = register_netdev(dev);
@@ -341,7 +355,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	__module_get(THIS_MODULE);
 
-	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
+	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
 
@@ -377,7 +391,16 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		disable_irq(vif->rx_irq);
 	}
 
-	xenvif_get(vif);
+	init_waitqueue_head(&vif->wq);
+	vif->task = kthread_create(xenvif_kthread,
+				   (void *)vif,
+				   "vif%d.%d", vif->domid, vif->handle);
+	if (IS_ERR(vif->task)) {
+		printk(KERN_WARNING "xen-netback: Could not allocate kthread for vif%d.%d\n",
+		       vif->domid, vif->handle);
+		err = PTR_ERR(vif->task);
+		goto err_rx_unbind;
+	}
 
 	rtnl_lock();
 	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
@@ -388,12 +411,18 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		xenvif_up(vif);
 	rtnl_unlock();
 
+	wake_up_process(vif->task);
+
 	return 0;
+
+err_rx_unbind:
+	unbind_from_irqhandler(vif->rx_irq, vif);
+	vif->rx_irq = 0;
 err_tx_unbind:
 	unbind_from_irqhandler(vif->tx_irq, vif);
 	vif->tx_irq = 0;
 err_unmap:
-	xen_netbk_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(vif);
 err:
 	module_put(THIS_MODULE);
 	return err;
@@ -408,7 +437,6 @@ void xenvif_carrier_off(struct xenvif *vif)
 	if (netif_running(dev))
 		xenvif_down(vif);
 	rtnl_unlock();
-	xenvif_put(vif);
 }
 
 void xenvif_disconnect(struct xenvif *vif)
@@ -422,9 +450,6 @@ void xenvif_disconnect(struct xenvif *vif)
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
 
-	atomic_dec(&vif->refcnt);
-	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
-
 	if (vif->tx_irq) {
 		if (vif->tx_irq == vif->rx_irq)
 			unbind_from_irqhandler(vif->tx_irq, vif);
@@ -438,9 +463,14 @@ void xenvif_disconnect(struct xenvif *vif)
 		need_module_put = 1;
 	}
 
+	if (vif->task)
+		kthread_stop(vif->task);
+
+	netif_napi_del(&vif->napi);
+
 	unregister_netdev(vif->dev);
 
-	xen_netbk_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(vif);
 
 	free_netdev(vif->dev);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 9bdc877..a49c9e8 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -81,19 +81,6 @@ module_param(pool_entries_per_cpu, uint, 0444);
  */
 #define XEN_NETBK_LEGACY_SLOTS_MAX XEN_NETIF_NR_SLOTS_MIN
 
-struct netbk_rx_meta {
-	int id;
-	int size;
-	int gso_size;
-};
-
-#define MAX_PENDING_REQS 256
-
-/* Discriminate from any valid pending_idx value. */
-#define INVALID_PENDING_IDX 0xFFFF
-
-#define MAX_BUFFER_OFFSET PAGE_SIZE
-
 /* Coalescing tx requests before copying makes number of grant
  * copy ops greater or equal to number of slots required. In
  * worst case a tx request consumes 2 gnttab_copy. So the size
@@ -110,79 +97,27 @@ DEFINE_PER_CPU(struct gnttab_copy *, tx_copy_ops);
 #define GRANT_COPY_OP_SIZE (2*XEN_NETIF_RX_RING_SIZE)
 #define META_SIZE (2*XEN_NETIF_RX_RING_SIZE)
 DEFINE_PER_CPU(struct gnttab_copy *, grant_copy_op);
-DEFINE_PER_CPU(struct netbk_rx_meta *, meta);
-
-struct xen_netbk {
-	wait_queue_head_t wq;
-	struct task_struct *task;
-
-	struct sk_buff_head rx_queue;
-	struct sk_buff_head tx_queue;
-
-	struct timer_list net_timer;
-
-	int32_t mmap_pages[MAX_PENDING_REQS];
-
-	pending_ring_idx_t pending_prod;
-	pending_ring_idx_t pending_cons;
-	struct list_head net_schedule_list;
-
-	/* Protect the net_schedule_list in netif. */
-	spinlock_t net_schedule_list_lock;
-
-	atomic_t netfront_count;
-
-	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
-	u16 pending_ring[MAX_PENDING_REQS];
-};
-
-static struct xen_netbk *xen_netbk;
-static int xen_netbk_group_nr;
+DEFINE_PER_CPU(struct xenvif_rx_meta *, meta);
 
 /*
  * If head != INVALID_PENDING_RING_IDX, it means this tx request is head of
  * one or more merged tx requests, otherwise it is the continuation of
  * previous tx request.
  */
-static inline int pending_tx_is_head(struct xen_netbk *netbk, RING_IDX idx)
+static inline int pending_tx_is_head(struct xenvif *vif, RING_IDX idx)
 {
-	return netbk->pending_tx_info[idx].head != INVALID_PENDING_RING_IDX;
+	return vif->pending_tx_info[idx].head != INVALID_PENDING_RING_IDX;
 }
 
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
-static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
-				  u8 status);
+static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
+			       u8 status);
 static void make_tx_response(struct xenvif *vif,
 			     struct xen_netif_tx_request *txp,
 			     s8       st);
+
+static inline int tx_work_todo(struct xenvif *vif);
+static inline int rx_work_todo(struct xenvif *vif);
+
 static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 					     u16      id,
 					     s8       st,
@@ -190,16 +125,16 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 					     u16      size,
 					     u16      flags);
 
-static inline unsigned long idx_to_pfn(struct xen_netbk *netbk,
+static inline unsigned long idx_to_pfn(struct xenvif *vif,
 				       u16 idx)
 {
-	return page_to_pfn(to_page(netbk->mmap_pages[idx]));
+	return page_to_pfn(to_page(vif->mmap_pages[idx]));
 }
 
-static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
+static inline unsigned long idx_to_kaddr(struct xenvif *vif,
 					 u16 idx)
 {
-	return (unsigned long)pfn_to_kaddr(idx_to_pfn(netbk, idx));
+	return (unsigned long)pfn_to_kaddr(idx_to_pfn(vif, idx));
 }
 
 /*
@@ -227,15 +162,10 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 	return i & (MAX_PENDING_REQS-1);
 }
 
-static inline pending_ring_idx_t nr_pending_reqs(struct xen_netbk *netbk)
+static inline pending_ring_idx_t nr_pending_reqs(struct xenvif *vif)
 {
 	return MAX_PENDING_REQS -
-		netbk->pending_prod + netbk->pending_cons;
-}
-
-static void xen_netbk_kick_thread(struct xen_netbk *netbk)
-{
-	wake_up(&netbk->wq);
+		vif->pending_prod + vif->pending_cons;
 }
 
 static int max_required_rx_slots(struct xenvif *vif)
@@ -249,7 +179,7 @@ static int max_required_rx_slots(struct xenvif *vif)
 	return max;
 }
 
-int xen_netbk_rx_ring_full(struct xenvif *vif)
+int xenvif_rx_ring_full(struct xenvif *vif)
 {
 	RING_IDX peek   = vif->rx_req_cons_peek;
 	RING_IDX needed = max_required_rx_slots(vif);
@@ -258,16 +188,16 @@ int xen_netbk_rx_ring_full(struct xenvif *vif)
 	       ((vif->rx.rsp_prod_pvt + XEN_NETIF_RX_RING_SIZE - peek) < needed);
 }
 
-int xen_netbk_must_stop_queue(struct xenvif *vif)
+int xenvif_must_stop_queue(struct xenvif *vif)
 {
-	if (!xen_netbk_rx_ring_full(vif))
+	if (!xenvif_rx_ring_full(vif))
 		return 0;
 
 	vif->rx.sring->req_event = vif->rx_req_cons_peek +
 		max_required_rx_slots(vif);
 	mb(); /* request notification /then/ check the queue */
 
-	return xen_netbk_rx_ring_full(vif);
+	return xenvif_rx_ring_full(vif);
 }
 
 /*
@@ -313,9 +243,9 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
 /*
  * Figure out how many ring slots we're going to need to send @skb to
  * the guest. This function is essentially a dry run of
- * netbk_gop_frag_copy.
+ * xenvif_gop_frag_copy.
  */
-unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
+unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
 {
 	unsigned int count;
 	int i, copy_off;
@@ -367,15 +297,15 @@ struct netrx_pending_operations {
 	unsigned copy_prod, copy_cons;
 	unsigned meta_prod, meta_cons;
 	struct gnttab_copy *copy;
-	struct netbk_rx_meta *meta;
+	struct xenvif_rx_meta *meta;
 	int copy_off;
 	grant_ref_t copy_gref;
 };
 
-static struct netbk_rx_meta *get_next_rx_buffer(struct xenvif *vif,
-						struct netrx_pending_operations *npo)
+static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
+						 struct netrx_pending_operations *npo)
 {
-	struct netbk_rx_meta *meta;
+	struct xenvif_rx_meta *meta;
 	struct xen_netif_rx_request *req;
 
 	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
@@ -395,13 +325,13 @@ static struct netbk_rx_meta *get_next_rx_buffer(struct xenvif *vif,
  * Set up the grant operations for this fragment. If it's a flipping
  * interface, we also set up the unmap request from here.
  */
-static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
-				struct netrx_pending_operations *npo,
-				struct page *page, unsigned long size,
-				unsigned long offset, int *head)
+static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
+				 struct netrx_pending_operations *npo,
+				 struct page *page, unsigned long size,
+				 unsigned long offset, int *head)
 {
 	struct gnttab_copy *copy_gop;
-	struct netbk_rx_meta *meta;
+	struct xenvif_rx_meta *meta;
 	/*
 	 * These variables are used iff get_page_ext returns true,
 	 * in which case they are guaranteed to be initialized.
@@ -444,12 +374,12 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop = npo->copy + npo->copy_prod++;
 		copy_gop->flags = GNTCOPY_dest_gref;
 		if (foreign) {
-			struct xen_netbk *netbk = to_netbk(idx);
+			struct xenvif *vif = to_vif(idx);
 			struct pending_tx_info *src_pend;
 
-			src_pend = &netbk->pending_tx_info[*to_pending_ring_idx(idx)];
+			src_pend = &vif->pending_tx_info[*to_pending_ring_idx(idx)];
 
-			copy_gop->source.domid = src_pend->vif->domid;
+			copy_gop->source.domid = vif->domid;
 			copy_gop->source.u.ref = src_pend->req.gref;
 			copy_gop->flags |= GNTCOPY_source_gref;
 		} else {
@@ -498,14 +428,14 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
  * zero GSO descriptors (for non-GSO packets) or one descriptor (for
  * frontend-side LRO).
  */
-static int netbk_gop_skb(struct sk_buff *skb,
-			 struct netrx_pending_operations *npo)
+static int xenvif_gop_skb(struct sk_buff *skb,
+			  struct netrx_pending_operations *npo)
 {
 	struct xenvif *vif = netdev_priv(skb->dev);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int i;
 	struct xen_netif_rx_request *req;
-	struct netbk_rx_meta *meta;
+	struct xenvif_rx_meta *meta;
 	unsigned char *data;
 	int head = 1;
 	int old_meta_prod;
@@ -542,30 +472,30 @@ static int netbk_gop_skb(struct sk_buff *skb,
 		if (data + len > skb_tail_pointer(skb))
 			len = skb_tail_pointer(skb) - data;
 
-		netbk_gop_frag_copy(vif, skb, npo,
-				    virt_to_page(data), len, offset, &head);
+		xenvif_gop_frag_copy(vif, skb, npo,
+				     virt_to_page(data), len, offset, &head);
 		data += len;
 	}
 
 	for (i = 0; i < nr_frags; i++) {
-		netbk_gop_frag_copy(vif, skb, npo,
-				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
-				    skb_frag_size(&skb_shinfo(skb)->frags[i]),
-				    skb_shinfo(skb)->frags[i].page_offset,
-				    &head);
+		xenvif_gop_frag_copy(vif, skb, npo,
+				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
+				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
+				     skb_shinfo(skb)->frags[i].page_offset,
+				     &head);
 	}
 
 	return npo->meta_prod - old_meta_prod;
 }
 
 /*
- * This is a twin to netbk_gop_skb.  Assume that netbk_gop_skb was
+ * This is a twin to xenvif_gop_skb.  Assume that xenvif_gop_skb was
  * used to set up the operations on the top of
  * netrx_pending_operations, which have since been done.  Check that
  * they didn't give any errors and advance over them.
  */
-static int netbk_check_gop(struct xenvif *vif, int nr_meta_slots,
-			   struct netrx_pending_operations *npo)
+static int xenvif_check_gop(struct xenvif *vif, int nr_meta_slots,
+			    struct netrx_pending_operations *npo)
 {
 	struct gnttab_copy     *copy_op;
 	int status = XEN_NETIF_RSP_OKAY;
@@ -584,9 +514,9 @@ static int netbk_check_gop(struct xenvif *vif, int nr_meta_slots,
 	return status;
 }
 
-static void netbk_add_frag_responses(struct xenvif *vif, int status,
-				     struct netbk_rx_meta *meta,
-				     int nr_meta_slots)
+static void xenvif_add_frag_responses(struct xenvif *vif, int status,
+				      struct xenvif_rx_meta *meta,
+				      int nr_meta_slots)
 {
 	int i;
 	unsigned long offset;
@@ -614,9 +544,13 @@ struct skb_cb_overlay {
 	int meta_slots_used;
 };
 
-static void xen_netbk_rx_action(struct xen_netbk *netbk)
+static void xenvif_kick_thread(struct xenvif *vif)
+{
+	wake_up(&vif->wq);
+}
+
+void xenvif_rx_action(struct xenvif *vif)
 {
-	struct xenvif *vif = NULL, *tmp;
 	s8 status;
 	u16 flags;
 	struct xen_netif_rx_response *resp;
@@ -629,8 +563,9 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 	unsigned long offset;
 	struct skb_cb_overlay *sco;
 	struct gnttab_copy *gco = get_cpu_var(grant_copy_op);
-	struct netbk_rx_meta *m = get_cpu_var(meta);
+	struct xenvif_rx_meta *m = get_cpu_var(meta);
 	static int unusable_count;
+	int need_to_notify = 0;
 
 	struct netrx_pending_operations npo = {
 		.copy = gco,
@@ -644,9 +579,9 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 			printk(KERN_ALERT
 			       "xen-netback: "
 			       "CPU %d scratch space is not available,"
-			       " not doing any TX work for netback/%d\n",
+			       " not doing any TX work for vif%d.%d\n",
 			       smp_processor_id(),
-			       (int)(netbk - xen_netbk));
+			       vif->domid, vif->handle);
 			unusable_count = 0;
 		} else
 			unusable_count++;
@@ -657,12 +592,12 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 	count = 0;
 
-	while ((skb = skb_dequeue(&netbk->rx_queue)) != NULL) {
+	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
 		vif = netdev_priv(skb->dev);
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
 		sco = (struct skb_cb_overlay *)skb->cb;
-		sco->meta_slots_used = netbk_gop_skb(skb, &npo);
+		sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
 
 		count += nr_frags + 1;
 
@@ -708,7 +643,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 		vif->dev->stats.tx_bytes += skb->len;
 		vif->dev->stats.tx_packets++;
 
-		status = netbk_check_gop(vif, sco->meta_slots_used, &npo);
+		status = xenvif_check_gop(vif, sco->meta_slots_used, &npo);
 
 		if (sco->meta_slots_used == 1)
 			flags = 0;
@@ -744,124 +679,46 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 			gso->flags = 0;
 		}
 
-		netbk_add_frag_responses(vif, status,
-					 m + npo.meta_cons + 1,
-					 sco->meta_slots_used);
+		xenvif_add_frag_responses(vif, status,
+					  m + npo.meta_cons + 1,
+					  sco->meta_slots_used);
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
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
 		notify_remote_via_irq(vif->rx_irq);
-		list_del_init(&vif->notify_list);
-	}
 
 	/* More work to do? */
-	if (!skb_queue_empty(&netbk->rx_queue) &&
-			!timer_pending(&netbk->net_timer))
-		xen_netbk_kick_thread(netbk);
+	if (!skb_queue_empty(&vif->rx_queue))
+		xenvif_kick_thread(vif);
 
 	put_cpu_var(grant_copy_op);
 	put_cpu_var(meta);
 }
 
-void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
-{
-	struct xen_netbk *netbk = vif->netbk;
-
-	skb_queue_tail(&netbk->rx_queue, skb);
-
-	xen_netbk_kick_thread(netbk);
-}
-
-static void xen_netbk_alarm(unsigned long data)
-{
-	struct xen_netbk *netbk = (struct xen_netbk *)data;
-	xen_netbk_kick_thread(netbk);
-}
-
-static int __on_net_schedule_list(struct xenvif *vif)
+void xenvif_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
 {
-	return !list_empty(&vif->schedule_list);
-}
+	skb_queue_tail(&vif->rx_queue, skb);
 
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
+	xenvif_kick_thread(vif);
 }
 
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
-void xen_netbk_check_rx_xenvif(struct xenvif *vif)
+void xenvif_check_rx_xenvif(struct xenvif *vif)
 {
 	int more_to_do;
 
 	RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
 
 	if (more_to_do)
-		xen_netbk_schedule_xenvif(vif);
+		napi_schedule(&vif->napi);
 }
 
 static void tx_add_credit(struct xenvif *vif)
@@ -888,11 +745,11 @@ static void tx_credit_callback(unsigned long data)
 {
 	struct xenvif *vif = (struct xenvif *)data;
 	tx_add_credit(vif);
-	xen_netbk_check_rx_xenvif(vif);
+	xenvif_check_rx_xenvif(vif);
 }
 
-static void netbk_tx_err(struct xenvif *vif,
-			 struct xen_netif_tx_request *txp, RING_IDX end)
+static void xenvif_tx_err(struct xenvif *vif,
+			  struct xen_netif_tx_request *txp, RING_IDX end)
 {
 	RING_IDX cons = vif->tx.req_cons;
 
@@ -903,21 +760,18 @@ static void netbk_tx_err(struct xenvif *vif,
 		txp = RING_GET_REQUEST(&vif->tx, cons++);
 	} while (1);
 	vif->tx.req_cons = cons;
-	xen_netbk_check_rx_xenvif(vif);
-	xenvif_put(vif);
 }
 
-static void netbk_fatal_tx_err(struct xenvif *vif)
+static void xenvif_fatal_tx_err(struct xenvif *vif)
 {
 	netdev_err(vif->dev, "fatal error; disabling device\n");
 	xenvif_carrier_off(vif);
-	xenvif_put(vif);
 }
 
-static int netbk_count_requests(struct xenvif *vif,
-				struct xen_netif_tx_request *first,
-				struct xen_netif_tx_request *txp,
-				int work_to_do)
+static int xenvif_count_requests(struct xenvif *vif,
+				 struct xen_netif_tx_request *first,
+				 struct xen_netif_tx_request *txp,
+				 int work_to_do)
 {
 	RING_IDX cons = vif->tx.req_cons;
 	int slots = 0;
@@ -934,7 +788,7 @@ static int netbk_count_requests(struct xenvif *vif,
 			netdev_err(vif->dev,
 				   "Asked for %d slots but exceeds this limit\n",
 				   work_to_do);
-			netbk_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(vif);
 			return -ENODATA;
 		}
 
@@ -945,7 +799,7 @@ static int netbk_count_requests(struct xenvif *vif,
 			netdev_err(vif->dev,
 				   "Malicious frontend using %d slots, threshold %u\n",
 				   slots, fatal_skb_slots);
-			netbk_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(vif);
 			return -E2BIG;
 		}
 
@@ -993,7 +847,7 @@ static int netbk_count_requests(struct xenvif *vif,
 		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
 			netdev_err(vif->dev, "Cross page boundary, txp->offset: %x, size: %u\n",
 				 txp->offset, txp->size);
-			netbk_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(vif);
 			return -EINVAL;
 		}
 
@@ -1005,30 +859,30 @@ static int netbk_count_requests(struct xenvif *vif,
 	} while (more_data);
 
 	if (drop_err) {
-		netbk_tx_err(vif, first, cons + slots);
+		xenvif_tx_err(vif, first, cons + slots);
 		return drop_err;
 	}
 
 	return slots;
 }
 
-static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
-					 u16 pending_idx)
+static struct page *xenvif_alloc_page(struct xenvif *vif,
+				      u16 pending_idx)
 {
 	struct page *page;
 	int32_t idx;
-	page = page_pool_get(netbk, &idx);
+
+	page = page_pool_get(vif, &idx);
 	if (!page)
 		return NULL;
-	netbk->mmap_pages[pending_idx] = idx;
+	vif->mmap_pages[pending_idx] = idx;
 	return page;
 }
 
-static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
-						  struct xenvif *vif,
-						  struct sk_buff *skb,
-						  struct xen_netif_tx_request *txp,
-						  struct gnttab_copy *gop)
+static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
+					       struct sk_buff *skb,
+					       struct xen_netif_tx_request *txp,
+					       struct gnttab_copy *gop)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
@@ -1051,15 +905,15 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 
 	/* Coalesce tx requests, at this point the packet passed in
 	 * should be <= 64K. Any packets larger than 64K have been
-	 * handled in netbk_count_requests().
+	 * handled in xenvif_count_requests().
 	 */
 	for (shinfo->nr_frags = slot = start; slot < nr_slots;
 	     shinfo->nr_frags++) {
 		struct pending_tx_info *pending_tx_info =
-			netbk->pending_tx_info;
+			vif->pending_tx_info;
 		int32_t idx;
 
-		page = page_pool_get(netbk, &idx);
+		page = page_pool_get(vif, &idx);
 		if (!page)
 			goto err;
 
@@ -1094,21 +948,18 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 				gop->len = txp->size;
 				dst_offset += gop->len;
 
-				index = pending_index(netbk->pending_cons++);
+				index = pending_index(vif->pending_cons++);
 
-				pending_idx = netbk->pending_ring[index];
+				pending_idx = vif->pending_ring[index];
 
 				memcpy(&pending_tx_info[pending_idx].req, txp,
 				       sizeof(*txp));
-				xenvif_get(vif);
-
-				pending_tx_info[pending_idx].vif = vif;
 
 				/* Poison these fields, corresponding
 				 * fields for head tx req will be set
 				 * to correct values after the loop.
 				 */
-				netbk->mmap_pages[pending_idx] = PAGE_POOL_INVALID_IDX;
+				vif->mmap_pages[pending_idx] = PAGE_POOL_INVALID_IDX;
 				pending_tx_info[pending_idx].head =
 					INVALID_PENDING_RING_IDX;
 
@@ -1128,7 +979,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		first->req.offset = 0;
 		first->req.size = dst_offset;
 		first->head = start_idx;
-		netbk->mmap_pages[head_idx] = idx;
+		vif->mmap_pages[head_idx] = idx;
 		*to_pending_ring_idx(idx) = start_idx;
 		frag_set_pending_idx(&frags[shinfo->nr_frags], head_idx);
 	}
@@ -1139,20 +990,20 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 err:
 	/* Unwind, freeing all pages and sending error responses. */
 	while (shinfo->nr_frags-- > start) {
-		xen_netbk_idx_release(netbk,
+		xenvif_idx_release(vif,
 				frag_get_pending_idx(&frags[shinfo->nr_frags]),
 				XEN_NETIF_RSP_ERROR);
 	}
 	/* The head too, if necessary. */
 	if (start)
-		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_ERROR);
+		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
 
 	return NULL;
 }
 
-static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
-				  struct sk_buff *skb,
-				  struct gnttab_copy **gopp)
+static int xenvif_tx_check_gop(struct xenvif *vif,
+			       struct sk_buff *skb,
+			       struct gnttab_copy **gopp)
 {
 	struct gnttab_copy *gop = *gopp;
 	u16 pending_idx = *((u16 *)skb->data);
@@ -1165,7 +1016,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	/* Check status of header. */
 	err = gop->status;
 	if (unlikely(err))
-		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_ERROR);
+		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
@@ -1175,7 +1026,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		pending_ring_idx_t head;
 
 		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
-		tx_info = &netbk->pending_tx_info[pending_idx];
+		tx_info = &vif->pending_tx_info[pending_idx];
 		head = tx_info->head;
 
 		/* Check error status: if okay then remember grant handle. */
@@ -1183,18 +1034,18 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 			newerr = (++gop)->status;
 			if (newerr)
 				break;
-			peek = netbk->pending_ring[pending_index(++head)];
-		} while (!pending_tx_is_head(netbk, peek));
+			peek = vif->pending_ring[pending_index(++head)];
+		} while (!pending_tx_is_head(vif, peek));
 
 		if (likely(!newerr)) {
 			/* Had a previous error? Invalidate this fragment. */
 			if (unlikely(err))
-				xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
+				xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
 			continue;
 		}
 
 		/* Error on this fragment: respond to client with an error. */
-		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_ERROR);
+		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
 
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
@@ -1202,10 +1053,10 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 
 		/* First error: invalidate header and preceding fragments. */
 		pending_idx = *((u16 *)skb->data);
-		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
+		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
-			xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
+			xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
 		}
 
 		/* Remember the error: invalidate all subsequent fragments. */
@@ -1216,7 +1067,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	return err;
 }
 
-static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
+static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -1230,20 +1081,20 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 
 		pending_idx = frag_get_pending_idx(frag);
 
-		txp = &netbk->pending_tx_info[pending_idx].req;
-		page = virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		txp = &vif->pending_tx_info[pending_idx].req;
+		page = virt_to_page(idx_to_kaddr(vif, pending_idx));
 		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
 		skb->len += txp->size;
 		skb->data_len += txp->size;
 		skb->truesize += txp->size;
 
-		/* Take an extra reference to offset xen_netbk_idx_release */
-		get_page(to_page(netbk->mmap_pages[pending_idx]));
-		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
+		/* Take an extra reference to offset xenvif_idx_release */
+		get_page(to_page(vif->mmap_pages[pending_idx]));
+		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
 	}
 }
 
-static int xen_netbk_get_extras(struct xenvif *vif,
+static int xenvif_get_extras(struct xenvif *vif,
 				struct xen_netif_extra_info *extras,
 				int work_to_do)
 {
@@ -1253,7 +1104,7 @@ static int xen_netbk_get_extras(struct xenvif *vif,
 	do {
 		if (unlikely(work_to_do-- <= 0)) {
 			netdev_err(vif->dev, "Missing extra info\n");
-			netbk_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(vif);
 			return -EBADR;
 		}
 
@@ -1264,7 +1115,7 @@ static int xen_netbk_get_extras(struct xenvif *vif,
 			vif->tx.req_cons = ++cons;
 			netdev_err(vif->dev,
 				   "Invalid extra type: %d\n", extra.type);
-			netbk_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(vif);
 			return -EINVAL;
 		}
 
@@ -1275,20 +1126,20 @@ static int xen_netbk_get_extras(struct xenvif *vif,
 	return work_to_do;
 }
 
-static int netbk_set_skb_gso(struct xenvif *vif,
-			     struct sk_buff *skb,
-			     struct xen_netif_extra_info *gso)
+static int xenvif_set_skb_gso(struct xenvif *vif,
+			      struct sk_buff *skb,
+			      struct xen_netif_extra_info *gso)
 {
 	if (!gso->u.gso.size) {
 		netdev_err(vif->dev, "GSO size must not be zero.\n");
-		netbk_fatal_tx_err(vif);
+		xenvif_fatal_tx_err(vif);
 		return -EINVAL;
 	}
 
 	/* Currently only TCPv4 S.O. is supported. */
 	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4) {
 		netdev_err(vif->dev, "Bad GSO type %d.\n", gso->u.gso.type);
-		netbk_fatal_tx_err(vif);
+		xenvif_fatal_tx_err(vif);
 		return -EINVAL;
 	}
 
@@ -1399,17 +1250,15 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	return false;
 }
 
-static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
-					struct gnttab_copy *tco)
+static unsigned xenvif_tx_build_gops(struct xenvif *vif,
+				     struct gnttab_copy *tco)
 {
 	struct gnttab_copy *gop = tco, *request_gop;
 	struct sk_buff *skb;
 	int ret;
 
-	while ((nr_pending_reqs(netbk) + XEN_NETBK_LEGACY_SLOTS_MAX
-		< MAX_PENDING_REQS) &&
-		!list_empty(&netbk->net_schedule_list)) {
-		struct xenvif *vif;
+	while ((nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
+		< MAX_PENDING_REQS)) {
 		struct xen_netif_tx_request txreq;
 		struct xen_netif_tx_request txfrags[XEN_NETBK_LEGACY_SLOTS_MAX];
 		struct page *page;
@@ -1420,16 +1269,6 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 		unsigned int data_len;
 		pending_ring_idx_t index;
 
-		/* Get a netif from the list with work to do. */
-		vif = poll_net_schedule_list(netbk);
-		/* This can sometimes happen because the test of
-		 * list_empty(net_schedule_list) at the top of the
-		 * loop is unlocked.  Just go back and have another
-		 * look.
-		 */
-		if (!vif)
-			continue;
-
 		if (vif->tx.sring->req_prod - vif->tx.req_cons >
 		    XEN_NETIF_TX_RING_SIZE) {
 			netdev_err(vif->dev,
@@ -1437,15 +1276,13 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 				   "req_prod %d, req_cons %d, size %ld\n",
 				   vif->tx.sring->req_prod, vif->tx.req_cons,
 				   XEN_NETIF_TX_RING_SIZE);
-			netbk_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(vif);
 			continue;
 		}
 
 		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, work_to_do);
-		if (!work_to_do) {
-			xenvif_put(vif);
-			continue;
-		}
+		if (!work_to_do)
+			break;
 
 		idx = vif->tx.req_cons;
 		rmb(); /* Ensure that we see the request before we copy it. */
@@ -1453,10 +1290,8 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 
 		/* Credit-based scheduling. */
 		if (txreq.size > vif->remaining_credit &&
-		    tx_credit_exceeded(vif, txreq.size)) {
-			xenvif_put(vif);
-			continue;
-		}
+		    tx_credit_exceeded(vif, txreq.size))
+			break;
 
 		vif->remaining_credit -= txreq.size;
 
@@ -1465,24 +1300,24 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 
 		memset(extras, 0, sizeof(extras));
 		if (txreq.flags & XEN_NETTXF_extra_info) {
-			work_to_do = xen_netbk_get_extras(vif, extras,
+			work_to_do = xenvif_get_extras(vif, extras,
 							  work_to_do);
 			idx = vif->tx.req_cons;
 			if (unlikely(work_to_do < 0))
-				continue;
+				break;
 		}
 
-		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do);
+		ret = xenvif_count_requests(vif, &txreq, txfrags, work_to_do);
 		if (unlikely(ret < 0))
-			continue;
+			break;
 
 		idx += ret;
 
 		if (unlikely(txreq.size < ETH_HLEN)) {
 			netdev_dbg(vif->dev,
 				   "Bad packet size: %d\n", txreq.size);
-			netbk_tx_err(vif, &txreq, idx);
-			continue;
+			xenvif_tx_err(vif, &txreq, idx);
+			break;
 		}
 
 		/* No crossing a page as the payload mustn't fragment. */
@@ -1491,12 +1326,12 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 				   "txreq.offset: %x, size: %u, end: %lu\n",
 				   txreq.offset, txreq.size,
 				   (txreq.offset&~PAGE_MASK) + txreq.size);
-			netbk_fatal_tx_err(vif);
-			continue;
+			xenvif_fatal_tx_err(vif);
+			break;
 		}
 
-		index = pending_index(netbk->pending_cons);
-		pending_idx = netbk->pending_ring[index];
+		index = pending_index(vif->pending_cons);
+		pending_idx = vif->pending_ring[index];
 
 		data_len = (txreq.size > PKT_PROT_LEN &&
 			    ret < XEN_NETBK_LEGACY_SLOTS_MAX) ?
@@ -1507,7 +1342,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 		if (unlikely(skb == NULL)) {
 			netdev_dbg(vif->dev,
 				   "Can't allocate a skb in start_xmit.\n");
-			netbk_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(vif, &txreq, idx);
 			break;
 		}
 
@@ -1518,19 +1353,20 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 			struct xen_netif_extra_info *gso;
 			gso = &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
 
-			if (netbk_set_skb_gso(vif, skb, gso)) {
-				/* Failure in netbk_set_skb_gso is fatal. */
+			if (xenvif_set_skb_gso(vif, skb, gso)) {
+				/* Failure in xenvif_set_skb_gso is fatal. */
 				kfree_skb(skb);
-				continue;
+				/* XXX ???? break or continue ?*/
+				break;
 			}
 		}
 
 		/* XXX could copy straight to head */
-		page = xen_netbk_alloc_page(netbk, pending_idx);
+		page = xenvif_alloc_page(vif, pending_idx);
 		if (!page) {
 			kfree_skb(skb);
-			netbk_tx_err(vif, &txreq, idx);
-			continue;
+			xenvif_tx_err(vif, &txreq, idx);
+			break;
 		}
 
 		gop->source.u.ref = txreq.gref;
@@ -1546,10 +1382,9 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 
 		gop++;
 
-		memcpy(&netbk->pending_tx_info[pending_idx].req,
+		memcpy(&vif->pending_tx_info[pending_idx].req,
 		       &txreq, sizeof(txreq));
-		netbk->pending_tx_info[pending_idx].vif = vif;
-		netbk->pending_tx_info[pending_idx].head = index;
+		vif->pending_tx_info[pending_idx].head = index;
 		*((u16 *)skb->data) = pending_idx;
 
 		__skb_put(skb, data_len);
@@ -1564,21 +1399,19 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 					     INVALID_PENDING_IDX);
 		}
 
-		netbk->pending_cons++;
+		vif->pending_cons++;
 
-		request_gop = xen_netbk_get_requests(netbk, vif,
-						     skb, txfrags, gop);
+		request_gop = xenvif_get_requests(vif, skb, txfrags, gop);
 		if (request_gop == NULL) {
 			kfree_skb(skb);
-			netbk_tx_err(vif, &txreq, idx);
-			continue;
+			xenvif_tx_err(vif, &txreq, idx);
+			break;
 		}
 		gop = request_gop;
 
-		__skb_queue_tail(&netbk->tx_queue, skb);
+		__skb_queue_tail(&vif->tx_queue, skb);
 
 		vif->tx.req_cons = idx;
-		xen_netbk_check_rx_xenvif(vif);
 
 		if ((gop-tco) >= TX_COPY_OPS_SIZE)
 			break;
@@ -1587,24 +1420,25 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 	return gop - tco;
 }
 
-static void xen_netbk_tx_submit(struct xen_netbk *netbk,
-				struct gnttab_copy *tco)
+static int xenvif_tx_submit(struct xenvif *vif,
+			    struct gnttab_copy *tco,
+			    int budget)
 {
 	struct gnttab_copy *gop = tco;
 	struct sk_buff *skb;
+	int work_done = 0;
 
-	while ((skb = __skb_dequeue(&netbk->tx_queue)) != NULL) {
+	while (work_done < budget &&
+	       (skb = __skb_dequeue(&vif->tx_queue)) != NULL) {
 		struct xen_netif_tx_request *txp;
-		struct xenvif *vif;
 		u16 pending_idx;
 		unsigned data_len;
 
 		pending_idx = *((u16 *)skb->data);
-		vif = netbk->pending_tx_info[pending_idx].vif;
-		txp = &netbk->pending_tx_info[pending_idx].req;
+		txp = &vif->pending_tx_info[pending_idx].req;
 
 		/* Check the remap error code. */
-		if (unlikely(xen_netbk_tx_check_gop(netbk, skb, &gop))) {
+		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop))) {
 			netdev_dbg(vif->dev, "netback grant failed.\n");
 			skb_shinfo(skb)->nr_frags = 0;
 			kfree_skb(skb);
@@ -1613,7 +1447,7 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk,
 
 		data_len = skb->len;
 		memcpy(skb->data,
-		       (void *)(idx_to_kaddr(netbk, pending_idx)|txp->offset),
+		       (void *)(idx_to_kaddr(vif, pending_idx)|txp->offset),
 		       data_len);
 		if (data_len < txp->size) {
 			/* Append the packet payload as a fragment. */
@@ -1621,7 +1455,7 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk,
 			txp->size -= data_len;
 		} else {
 			/* Schedule a response immediately. */
-			xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
+			xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
 		}
 
 		if (txp->flags & XEN_NETTXF_csum_blank)
@@ -1629,7 +1463,7 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk,
 		else if (txp->flags & XEN_NETTXF_data_validated)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		xen_netbk_fill_frags(netbk, skb);
+		xenvif_fill_frags(vif, skb);
 
 		/*
 		 * If the initial fragment was < PKT_PROT_LEN then
@@ -1657,14 +1491,19 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk,
 		vif->dev->stats.rx_bytes += skb->len;
 		vif->dev->stats.rx_packets++;
 
-		xenvif_receive_skb(vif, skb);
+		work_done++;
+
+		netif_receive_skb(skb);
 	}
+
+	return work_done;
 }
 
 /* Called after netfront has transmitted */
-static void xen_netbk_tx_action(struct xen_netbk *netbk)
+int xenvif_tx_action(struct xenvif *vif, int budget)
 {
 	unsigned nr_gops;
+	int work_done;
 	struct gnttab_copy *tco;
 	static int unusable_count;
 
@@ -1676,52 +1515,58 @@ static void xen_netbk_tx_action(struct xen_netbk *netbk)
 			printk(KERN_ALERT
 			       "xen-netback: "
 			       "CPU %d scratch space is not available,"
-			       " not doing any RX work for netback/%d\n",
+			       " not doing any RX work for vif%d.%d\n",
 			       smp_processor_id(),
-			       (int)(netbk - xen_netbk));
+			       vif->domid, vif->handle);
 		} else
 			unusable_count++;
-		return;
+		return 0;
+	}
+
+	if (unlikely(!tx_work_todo(vif))) {
+		put_cpu_var(tx_copy_ops);
+		return 0;
 	}
 
-	nr_gops = xen_netbk_tx_build_gops(netbk, tco);
+
+	nr_gops = xenvif_tx_build_gops(vif, tco);
 
 	if (nr_gops == 0) {
 		put_cpu_var(tx_copy_ops);
-		return;
+		return 0;
 	}
 
 	gnttab_batch_copy(tco, nr_gops);
 
-	xen_netbk_tx_submit(netbk, tco);
+	work_done = xenvif_tx_submit(vif, tco, nr_gops);
 
 	put_cpu_var(tx_copy_ops);
+
+	return work_done;
 }
 
-static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
+static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
 				  u8 status)
 {
-	struct xenvif *vif;
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t head;
 	u16 peek; /* peek into next tx request */
 
-	BUG_ON(netbk->mmap_pages[pending_idx] == PAGE_POOL_INVALID_IDX);
+	BUG_ON(vif->mmap_pages[pending_idx] == PAGE_POOL_INVALID_IDX);
 
-	pending_tx_info = &netbk->pending_tx_info[pending_idx];
+	pending_tx_info = &vif->pending_tx_info[pending_idx];
 
-	vif = pending_tx_info->vif;
 	head = pending_tx_info->head;
 
-	BUG_ON(!pending_tx_is_head(netbk, head));
-	BUG_ON(netbk->pending_ring[pending_index(head)] != pending_idx);
+	BUG_ON(!pending_tx_is_head(vif, head));
+	BUG_ON(vif->pending_ring[pending_index(head)] != pending_idx);
 
 	do {
 		pending_ring_idx_t index;
 		pending_ring_idx_t idx = pending_index(head);
-		u16 info_idx = netbk->pending_ring[idx];
+		u16 info_idx = vif->pending_ring[idx];
 
-		pending_tx_info = &netbk->pending_tx_info[info_idx];
+		pending_tx_info = &vif->pending_tx_info[info_idx];
 		make_tx_response(vif, &pending_tx_info->req, status);
 
 		/* Setting any number other than
@@ -1730,17 +1575,15 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
 		 */
 		pending_tx_info->head = 0;
 
-		index = pending_index(netbk->pending_prod++);
-		netbk->pending_ring[index] = netbk->pending_ring[info_idx];
+		index = pending_index(vif->pending_prod++);
+		vif->pending_ring[index] = vif->pending_ring[info_idx];
 
-		xenvif_put(vif);
+		peek = vif->pending_ring[pending_index(++head)];
 
-		peek = netbk->pending_ring[pending_index(++head)];
+	} while (!pending_tx_is_head(vif, peek));
 
-	} while (!pending_tx_is_head(netbk, peek));
-
-	page_pool_put(netbk->mmap_pages[pending_idx]);
-	netbk->mmap_pages[pending_idx] = PAGE_POOL_INVALID_IDX;
+	page_pool_put(vif->mmap_pages[pending_idx]);
+	vif->mmap_pages[pending_idx] = PAGE_POOL_INVALID_IDX;
 }
 
 
@@ -1788,45 +1631,22 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 	return resp;
 }
 
-static inline int rx_work_todo(struct xen_netbk *netbk)
+static inline int rx_work_todo(struct xenvif *vif)
 {
-	return !skb_queue_empty(&netbk->rx_queue);
+	return !skb_queue_empty(&vif->rx_queue);
 }
 
-static inline int tx_work_todo(struct xen_netbk *netbk)
+static inline int tx_work_todo(struct xenvif *vif)
 {
 
-	if ((nr_pending_reqs(netbk) + XEN_NETBK_LEGACY_SLOTS_MAX
-	     < MAX_PENDING_REQS) &&
-	     !list_empty(&netbk->net_schedule_list))
+	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&vif->tx)) &&
+	    (nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
+	     < MAX_PENDING_REQS))
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
 static int __create_percpu_scratch_space(unsigned int cpu)
 {
 	if (per_cpu(tx_copy_ops, cpu) ||
@@ -1843,7 +1663,7 @@ static int __create_percpu_scratch_space(unsigned int cpu)
 			     cpu_to_node(cpu));
 
 	per_cpu(meta, cpu) =
-		vzalloc_node(sizeof(struct netbk_rx_meta) * META_SIZE,
+		vzalloc_node(sizeof(struct xenvif_rx_meta) * META_SIZE,
 			     cpu_to_node(cpu));
 
 	if (!per_cpu(tx_copy_ops, cpu) ||
@@ -1914,7 +1734,7 @@ static struct notifier_block netback_notifier_block = {
 	.notifier_call = __netback_percpu_callback,
 };
 
-void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
+void xenvif_unmap_frontend_rings(struct xenvif *vif)
 {
 	if (vif->tx.sring)
 		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
@@ -1924,9 +1744,9 @@ void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
 					vif->rx.sring);
 }
 
-int xen_netbk_map_frontend_rings(struct xenvif *vif,
-				 grant_ref_t tx_ring_ref,
-				 grant_ref_t rx_ring_ref)
+int xenvif_map_frontend_rings(struct xenvif *vif,
+			      grant_ref_t tx_ring_ref,
+			      grant_ref_t rx_ring_ref)
 {
 	void *addr;
 	struct xen_netif_tx_sring *txs;
@@ -1955,15 +1775,33 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
 	return 0;
 
 err:
-	xen_netbk_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(vif);
 	return err;
 }
 
+int xenvif_kthread(void *data)
+{
+	struct xenvif *vif = data;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(vif->wq,
+					 rx_work_todo(vif) ||
+					 kthread_should_stop());
+		cond_resched();
+
+		if (kthread_should_stop())
+			break;
+
+		if (rx_work_todo(vif))
+			xenvif_rx_action(vif);
+	}
+
+	return 0;
+}
+
 static int __init netback_init(void)
 {
-	int i;
 	int rc = 0;
-	int group;
 	unsigned int pool_size;
 	int cpu;
 
@@ -1986,54 +1824,10 @@ static int __init netback_init(void)
 	}
 	register_hotcpu_notifier(&netback_notifier_block);
 
-	xen_netbk_group_nr = num_online_cpus();
-	xen_netbk = vzalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
-	if (!xen_netbk) {
-		goto failed_init;
-		rc = -ENOMEM;
-	}
-
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
-
-		kthread_bind(netbk->task, group);
-
-		INIT_LIST_HEAD(&netbk->net_schedule_list);
-
-		spin_lock_init(&netbk->net_schedule_list_lock);
-
-		atomic_set(&netbk->netfront_count, 0);
-
-		wake_up_process(netbk->task);
-	}
-
 	pool_size = num_online_cpus() * pool_entries_per_cpu;
 	rc = page_pool_init(pool_size);
 	if (rc)
-		goto failed_init_destroy_kthreads;
+		goto failed_init;
 
 	rc = xenvif_xenbus_init();
 	if (rc)
@@ -2043,13 +1837,6 @@ static int __init netback_init(void)
 
 failed_init_destroy_pool:
 	page_pool_destroy();
-failed_init_destroy_kthreads:
-	while (--group >= 0) {
-		struct xen_netbk *netbk = &xen_netbk[group];
-		del_timer(&netbk->net_timer);
-		kthread_stop(netbk->task);
-	}
-	vfree(xen_netbk);
 failed_init:
 	for_each_online_cpu(cpu)
 		__free_percpu_scratch_space(cpu);
@@ -2064,15 +1851,6 @@ static void __exit netback_fini(void)
 	int i;
 
 	xenvif_xenbus_fini();
-
-	for (i = 0; i < xen_netbk_group_nr; i++) {
-		struct xen_netbk *netbk = &xen_netbk[i];
-		del_timer_sync(&netbk->net_timer);
-		kthread_stop(netbk->task);
-	}
-
-	vfree(xen_netbk);
-
 	page_pool_destroy();
 
 	unregister_hotcpu_notifier(&netback_notifier_block);
diff --git a/drivers/net/xen-netback/page_pool.c b/drivers/net/xen-netback/page_pool.c
index ae1224b..9652a8f 100644
--- a/drivers/net/xen-netback/page_pool.c
+++ b/drivers/net/xen-netback/page_pool.c
@@ -103,7 +103,7 @@ int is_in_pool(struct page *page, int32_t *pidx)
 	return get_page_ext(page, pidx);
 }
 
-struct page *page_pool_get(struct xen_netbk *netbk, int32_t *pidx)
+struct page *page_pool_get(struct xenvif *vif, int32_t *pidx)
 {
 	int32_t idx;
 	struct page *page;
@@ -121,7 +121,7 @@ struct page *page_pool_get(struct xen_netbk *netbk, int32_t *pidx)
 	}
 
 	set_page_ext(page, idx);
-	pool[idx].u.netbk = netbk;
+	pool[idx].u.vif = vif;
 	pool[idx].page = page;
 
 	*pidx = idx;
@@ -134,7 +134,7 @@ void page_pool_put(int32_t idx)
 	struct page *page = pool[idx].page;
 
 	pool[idx].page = NULL;
-	pool[idx].u.netbk = NULL;
+	pool[idx].u.vif = NULL;
 	page->mapping = NULL;
 	put_page(page);
 	put_free_entry(idx);
@@ -175,9 +175,9 @@ struct page *to_page(int32_t idx)
 	return pool[idx].page;
 }
 
-struct xen_netbk *to_netbk(int32_t idx)
+struct xenvif *to_vif(int32_t idx)
 {
-	return pool[idx].u.netbk;
+	return pool[idx].u.vif;
 }
 
 pending_ring_idx_t *to_pending_ring_idx(int32_t idx)
diff --git a/drivers/net/xen-netback/page_pool.h b/drivers/net/xen-netback/page_pool.h
index b8c10f6..5518cac 100644
--- a/drivers/net/xen-netback/page_pool.h
+++ b/drivers/net/xen-netback/page_pool.h
@@ -36,7 +36,7 @@ struct page_pool_entry {
 	struct page *page;
 	pending_ring_idx_t pending_ring_idx;
 	union {
-		struct xen_netbk *netbk;
+		struct xenvif *vif;
 		int32_t link;
 	} u;
 };
@@ -49,12 +49,12 @@ union page_ext {
 int page_pool_init(unsigned int size);
 void page_pool_destroy(void);
 
-struct page *page_pool_get(struct xen_netbk *netbk, int32_t *pidx);
+struct page *page_pool_get(struct xenvif *vif, int32_t *pidx);
 void page_pool_put(int32_t idx);
 int is_in_pool(struct page *page, int32_t *pidx);
 
 struct page *to_page(int32_t idx);
-struct xen_netbk *to_netbk(int32_t idx);
+struct xenvif *to_vif(int32_t idx);
 pending_ring_idx_t *to_pending_ring_idx(int32_t idx);
 
 #endif /* __NETBK_PAGE_POOL_H__ */
-- 
1.7.10.4
