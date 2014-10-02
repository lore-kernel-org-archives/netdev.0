From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1] xen-netfront: always keep the Rx ring full of requests
Date: Thu, 2 Oct 2014 14:33:46 +0100
Message-ID: <1412256826-18874-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12976 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503AbaJBNeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 09:34:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A full Rx ring only requires 1 MiB of memory.  This is not enough
memory that it is useful to dynamically scale the number of Rx
requests in the ring based on traffic rates.

Keeping the ring full of Rx requests handles bursty traffic better
than trying to converges on an optimal number of requests to keep
filled.

On a 4 core host, an iperf -P 64 -t 60 run from dom0 to a 4 VCPU guest
improved from 5.1 Gbit/s to 5.6 Gbit/s.  Gains with more bursty
traffic are expected to be higher.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |  310 ++++++++------------------------------------
 1 file changed, 54 insertions(+), 256 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index ca82f54..d241aca 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -77,7 +77,9 @@ struct netfront_cb {
 
 #define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
 #define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
-#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE, 256)
+
+/* Minimum number of Rx slots (includes slot for GSO metadata). */
+#define NET_RX_SLOTS_MIN (XEN_NETIF_NR_SLOTS_MIN + 1)
 
 /* Queue name is interface name with "-qNNN" appended */
 #define QUEUE_NAME_SIZE (IFNAMSIZ + 6)
@@ -138,10 +140,6 @@ struct netfront_queue {
 	int rx_ring_ref;
 
 	/* Receive-ring batched refills. */
-#define RX_MIN_TARGET 8
-#define RX_DFL_MIN_TARGET 64
-#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	unsigned rx_min_target, rx_max_target, rx_target;
 	struct sk_buff_head rx_batch;
 
 	struct timer_list rx_refill_timer;
@@ -228,14 +226,6 @@ static grant_ref_t xennet_get_rx_ref(struct netfront_queue *queue,
 	return ref;
 }
 
-#ifdef CONFIG_SYSFS
-static int xennet_sysfs_addif(struct net_device *netdev);
-static void xennet_sysfs_delif(struct net_device *netdev);
-#else /* !CONFIG_SYSFS */
-#define xennet_sysfs_addif(dev) (0)
-#define xennet_sysfs_delif(dev) do { } while (0)
-#endif
-
 static bool xennet_can_sg(struct net_device *dev)
 {
 	return dev->features & NETIF_F_SG;
@@ -251,7 +241,7 @@ static void rx_refill_timeout(unsigned long data)
 static int netfront_tx_slot_available(struct netfront_queue *queue)
 {
 	return (queue->tx.req_prod_pvt - queue->tx.rsp_cons) <
-		(TX_MAX_TARGET - MAX_SKB_FRAGS - 2);
+		(NET_TX_RING_SIZE - MAX_SKB_FRAGS - 2);
 }
 
 static void xennet_maybe_wake_tx(struct netfront_queue *queue)
@@ -265,77 +255,55 @@ static void xennet_maybe_wake_tx(struct netfront_queue *queue)
 		netif_tx_wake_queue(netdev_get_tx_queue(dev, queue->id));
 }
 
-static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
+
+struct sk_buff *xennet_alloc_one_rx_buffer(struct netfront_queue *queue)
 {
-	unsigned short id;
 	struct sk_buff *skb;
 	struct page *page;
-	int i, batch_target, notify;
+
+	skb = __netdev_alloc_skb(queue->info->netdev,
+				 RX_COPY_THRESHOLD + NET_IP_ALIGN,
+				 GFP_ATOMIC | __GFP_NOWARN);
+	if (unlikely(!skb))
+		return NULL;
+
+	page = alloc_page(GFP_ATOMIC | __GFP_NOWARN);
+	if (!page) {
+		kfree_skb(skb);
+		return NULL;
+	}
+	skb_add_rx_frag(skb, 0, page, 0, 0, PAGE_SIZE);
+
+	/* Align ip header to a 16 bytes boundary */
+	skb_reserve(skb, NET_IP_ALIGN);
+	skb->dev = queue->info->netdev;
+
+	return skb;
+}
+	
+
+static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
+{
 	RING_IDX req_prod = queue->rx.req_prod_pvt;
-	grant_ref_t ref;
-	unsigned long pfn;
-	void *vaddr;
-	struct xen_netif_rx_request *req;
+	int notify;
 
 	if (unlikely(!netif_carrier_ok(queue->info->netdev)))
 		return;
 
-	/*
-	 * Allocate skbuffs greedily, even though we batch updates to the
-	 * receive ring. This creates a less bursty demand on the memory
-	 * allocator, so should reduce the chance of failed allocation requests
-	 * both for ourself and for other kernel subsystems.
-	 */
-	batch_target = queue->rx_target - (req_prod - queue->rx.rsp_cons);
-	for (i = skb_queue_len(&queue->rx_batch); i < batch_target; i++) {
-		skb = __netdev_alloc_skb(queue->info->netdev,
-					 RX_COPY_THRESHOLD + NET_IP_ALIGN,
-					 GFP_ATOMIC | __GFP_NOWARN);
-		if (unlikely(!skb))
-			goto no_skb;
-
-		/* Align ip header to a 16 bytes boundary */
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		page = alloc_page(GFP_ATOMIC | __GFP_NOWARN);
-		if (!page) {
-			kfree_skb(skb);
-no_skb:
-			/* Could not allocate any skbuffs. Try again later. */
-			mod_timer(&queue->rx_refill_timer,
-				  jiffies + (HZ/10));
-
-			/* Any skbuffs queued for refill? Force them out. */
-			if (i != 0)
-				goto refill;
+	for (req_prod = queue->rx.req_prod_pvt;
+	     req_prod - queue->rx.rsp_cons < NET_RX_RING_SIZE;
+	     req_prod++) {
+		struct sk_buff *skb;
+		unsigned short id;
+		grant_ref_t ref;
+		unsigned long pfn;
+		struct xen_netif_rx_request *req;
+
+		skb = xennet_alloc_one_rx_buffer(queue);
+		if (!skb)
 			break;
-		}
-
-		skb_add_rx_frag(skb, 0, page, 0, 0, PAGE_SIZE);
-		__skb_queue_tail(&queue->rx_batch, skb);
-	}
-
-	/* Is the batch large enough to be worthwhile? */
-	if (i < (queue->rx_target/2)) {
-		if (req_prod > queue->rx.sring->req_prod)
-			goto push;
-		return;
-	}
-
-	/* Adjust our fill target if we risked running out of buffers. */
-	if (((req_prod - queue->rx.sring->rsp_prod) < (queue->rx_target / 4)) &&
-	    ((queue->rx_target *= 2) > queue->rx_max_target))
-		queue->rx_target = queue->rx_max_target;
-
- refill:
-	for (i = 0; ; i++) {
-		skb = __skb_dequeue(&queue->rx_batch);
-		if (skb == NULL)
-			break;
-
-		skb->dev = queue->info->netdev;
 
-		id = xennet_rxidx(req_prod + i);
+		id = xennet_rxidx(req_prod);
 
 		BUG_ON(queue->rx_skbs[id]);
 		queue->rx_skbs[id] = skb;
@@ -345,9 +313,8 @@ no_skb:
 		queue->grant_rx_ref[id] = ref;
 
 		pfn = page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
-		vaddr = page_address(skb_frag_page(&skb_shinfo(skb)->frags[0]));
 
-		req = RING_GET_REQUEST(&queue->rx, req_prod + i);
+		req = RING_GET_REQUEST(&queue->rx, req_prod);
 		gnttab_grant_foreign_access_ref(ref,
 						queue->info->xbdev->otherend_id,
 						pfn_to_mfn(pfn),
@@ -357,11 +324,16 @@ no_skb:
 		req->gref = ref;
 	}
 
+	queue->rx.req_prod_pvt = req_prod;
+
+	/* Not enough requests? Try again later. */
+	if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
+		mod_timer(&queue->rx_refill_timer, jiffies + (HZ/10));
+		return;
+	}
+
 	wmb();		/* barrier so backend seens requests */
 
-	/* Above is a suitable barrier to ensure backend will see requests. */
-	queue->rx.req_prod_pvt = req_prod + i;
- push:
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&queue->rx, notify);
 	if (notify)
 		notify_remote_via_irq(queue->rx_irq);
@@ -1070,13 +1042,6 @@ err:
 
 	work_done -= handle_incoming_queue(queue, &rxq);
 
-	/* If we get a callback with very few responses, reduce fill target. */
-	/* NB. Note exponential increase, linear decrease. */
-	if (((queue->rx.req_prod_pvt - queue->rx.sring->rsp_prod) >
-	     ((3*queue->rx_target) / 4)) &&
-	    (--queue->rx_target < queue->rx_min_target))
-		queue->rx_target = queue->rx_min_target;
-
 	xennet_alloc_rx_buffers(queue);
 
 	if (work_done < budget) {
@@ -1396,13 +1361,6 @@ static int netfront_probe(struct xenbus_device *dev,
 		goto fail;
 	}
 
-	err = xennet_sysfs_addif(info->netdev);
-	if (err) {
-		unregister_netdev(info->netdev);
-		pr_warn("%s: add sysfs failed err=%d\n", __func__, err);
-		goto fail;
-	}
-
 	return 0;
 
  fail:
@@ -1644,9 +1602,6 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	spin_lock_init(&queue->rx_lock);
 
 	skb_queue_head_init(&queue->rx_batch);
-	queue->rx_target     = RX_DFL_MIN_TARGET;
-	queue->rx_min_target = RX_DFL_MIN_TARGET;
-	queue->rx_max_target = RX_MAX_TARGET;
 
 	init_timer(&queue->rx_refill_timer);
 	queue->rx_refill_timer.data = (unsigned long)queue;
@@ -1670,7 +1625,7 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	}
 
 	/* A grant for every tx ring slot */
-	if (gnttab_alloc_grant_references(TX_MAX_TARGET,
+	if (gnttab_alloc_grant_references(NET_TX_RING_SIZE,
 					  &queue->gref_tx_head) < 0) {
 		pr_alert("can't alloc tx grant refs\n");
 		err = -ENOMEM;
@@ -1678,7 +1633,7 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	}
 
 	/* A grant for every rx ring slot */
-	if (gnttab_alloc_grant_references(RX_MAX_TARGET,
+	if (gnttab_alloc_grant_references(NET_RX_RING_SIZE,
 					  &queue->gref_rx_head) < 0) {
 		pr_alert("can't alloc rx grant refs\n");
 		err = -ENOMEM;
@@ -2145,161 +2100,6 @@ static const struct ethtool_ops xennet_ethtool_ops =
 	.get_strings = xennet_get_strings,
 };
 
-#ifdef CONFIG_SYSFS
-static ssize_t show_rxbuf_min(struct device *dev,
-			      struct device_attribute *attr, char *buf)
-{
-	struct net_device *netdev = to_net_dev(dev);
-	struct netfront_info *info = netdev_priv(netdev);
-	unsigned int num_queues = netdev->real_num_tx_queues;
-
-	if (num_queues)
-		return sprintf(buf, "%u\n", info->queues[0].rx_min_target);
-	else
-		return sprintf(buf, "%u\n", RX_MIN_TARGET);
-}
-
-static ssize_t store_rxbuf_min(struct device *dev,
-			       struct device_attribute *attr,
-			       const char *buf, size_t len)
-{
-	struct net_device *netdev = to_net_dev(dev);
-	struct netfront_info *np = netdev_priv(netdev);
-	unsigned int num_queues = netdev->real_num_tx_queues;
-	char *endp;
-	unsigned long target;
-	unsigned int i;
-	struct netfront_queue *queue;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	target = simple_strtoul(buf, &endp, 0);
-	if (endp == buf)
-		return -EBADMSG;
-
-	if (target < RX_MIN_TARGET)
-		target = RX_MIN_TARGET;
-	if (target > RX_MAX_TARGET)
-		target = RX_MAX_TARGET;
-
-	for (i = 0; i < num_queues; ++i) {
-		queue = &np->queues[i];
-		spin_lock_bh(&queue->rx_lock);
-		if (target > queue->rx_max_target)
-			queue->rx_max_target = target;
-		queue->rx_min_target = target;
-		if (target > queue->rx_target)
-			queue->rx_target = target;
-
-		xennet_alloc_rx_buffers(queue);
-
-		spin_unlock_bh(&queue->rx_lock);
-	}
-	return len;
-}
-
-static ssize_t show_rxbuf_max(struct device *dev,
-			      struct device_attribute *attr, char *buf)
-{
-	struct net_device *netdev = to_net_dev(dev);
-	struct netfront_info *info = netdev_priv(netdev);
-	unsigned int num_queues = netdev->real_num_tx_queues;
-
-	if (num_queues)
-		return sprintf(buf, "%u\n", info->queues[0].rx_max_target);
-	else
-		return sprintf(buf, "%u\n", RX_MAX_TARGET);
-}
-
-static ssize_t store_rxbuf_max(struct device *dev,
-			       struct device_attribute *attr,
-			       const char *buf, size_t len)
-{
-	struct net_device *netdev = to_net_dev(dev);
-	struct netfront_info *np = netdev_priv(netdev);
-	unsigned int num_queues = netdev->real_num_tx_queues;
-	char *endp;
-	unsigned long target;
-	unsigned int i = 0;
-	struct netfront_queue *queue = NULL;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	target = simple_strtoul(buf, &endp, 0);
-	if (endp == buf)
-		return -EBADMSG;
-
-	if (target < RX_MIN_TARGET)
-		target = RX_MIN_TARGET;
-	if (target > RX_MAX_TARGET)
-		target = RX_MAX_TARGET;
-
-	for (i = 0; i < num_queues; ++i) {
-		queue = &np->queues[i];
-		spin_lock_bh(&queue->rx_lock);
-		if (target < queue->rx_min_target)
-			queue->rx_min_target = target;
-		queue->rx_max_target = target;
-		if (target < queue->rx_target)
-			queue->rx_target = target;
-
-		xennet_alloc_rx_buffers(queue);
-
-		spin_unlock_bh(&queue->rx_lock);
-	}
-	return len;
-}
-
-static ssize_t show_rxbuf_cur(struct device *dev,
-			      struct device_attribute *attr, char *buf)
-{
-	struct net_device *netdev = to_net_dev(dev);
-	struct netfront_info *info = netdev_priv(netdev);
-	unsigned int num_queues = netdev->real_num_tx_queues;
-
-	if (num_queues)
-		return sprintf(buf, "%u\n", info->queues[0].rx_target);
-	else
-		return sprintf(buf, "0\n");
-}
-
-static struct device_attribute xennet_attrs[] = {
-	__ATTR(rxbuf_min, S_IRUGO|S_IWUSR, show_rxbuf_min, store_rxbuf_min),
-	__ATTR(rxbuf_max, S_IRUGO|S_IWUSR, show_rxbuf_max, store_rxbuf_max),
-	__ATTR(rxbuf_cur, S_IRUGO, show_rxbuf_cur, NULL),
-};
-
-static int xennet_sysfs_addif(struct net_device *netdev)
-{
-	int i;
-	int err;
-
-	for (i = 0; i < ARRAY_SIZE(xennet_attrs); i++) {
-		err = device_create_file(&netdev->dev,
-					   &xennet_attrs[i]);
-		if (err)
-			goto fail;
-	}
-	return 0;
-
- fail:
-	while (--i >= 0)
-		device_remove_file(&netdev->dev, &xennet_attrs[i]);
-	return err;
-}
-
-static void xennet_sysfs_delif(struct net_device *netdev)
-{
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(xennet_attrs); i++)
-		device_remove_file(&netdev->dev, &xennet_attrs[i]);
-}
-
-#endif /* CONFIG_SYSFS */
-
 static const struct xenbus_device_id netfront_ids[] = {
 	{ "vif" },
 	{ "" }
@@ -2317,8 +2117,6 @@ static int xennet_remove(struct xenbus_device *dev)
 
 	xennet_disconnect_backend(info);
 
-	xennet_sysfs_delif(info->netdev);
-
 	unregister_netdev(info->netdev);
 
 	for (i = 0; i < num_queues; ++i) {
-- 
1.7.10.4
