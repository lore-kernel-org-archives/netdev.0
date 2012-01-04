From: Mike Waychison <mikew@google.com>
Subject: [RFC PATCH v1 2/2] virtio_net: Don't disable napi on low memory.
Date: Wed, 04 Jan 2012 14:52:38 -0800
Message-ID: <20120104225237.18184.71853.stgit@mike2.sea.corp.google.com>
References: <20120104225223.18184.1537.stgit@mike2.sea.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120104225223.18184.1537.stgit@mike2.sea.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the virtio_net driver deals with low memory memory by kicking
off delayed work in process context to try and refill the rx queues.
This process-context filling is synchronized against the receive
bottom-half by serially:

  - disabling NAPI polling on the device,
  - allocating buffers,
  - enqueueing the buffers,
  - re-enabling napi.

Disabling NAPI just to synchronize virtio_add_buf calls is a bit
overkill, and there isn't any reason we shouldn't be able to continue
processing received packets as they come in.  In the simple case, this
does not involve allocating any memory, and in fact allows memory to be
released as the guest system receives and processes packets.

Instead of disabling NAPI, this change re-arranges the allocation and
enqueueing of buffers such that allocation of all buffers happens
separately from the enqueueing of said buffers.  In lieu of serializing
using NAPI for the refill out-of-band path, we now serialize using a
newly introduced bottom-half spinlock, vi->rx_fill_lock.

With the allocation split off from the enqueueing, we now must be a bit
more careful about how many allocations to make.  Before-hand, we were
limitting our allocations up to the point where the virtio_add_buf call
returned -ENOSPC, but with allocations done up front, we don't really
know how many allocations to perform.  Instead of grabbing the lock all
the time, we create batches of buffer allocations, as defined by the new
rx_allocate_batch module parameter.

As well, due to the way we infer the "vi->max" number of buffers the
queue can take, (as we really don't know up front), we now simply assume
that vi->max is whatever the number of successful allocations made were
at driver initialization, and update it later if we were wrong.

In empirical experiments where memory is tight, this patch allows the
out-of-band refill path to contribute to memory pressure for reclaim,
while reducing the perceived outage of the interface's receive path.
This in turn reduces network stalls that lead to congestion window
collapses.

Signed-off-by: Mike Waychison <mikew@google.com>
---
 drivers/net/virtio_net.c |  210 +++++++++++++++++++++++++++++++++++-----------
 1 files changed, 160 insertions(+), 50 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 76fe14e..90b1e6d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -34,6 +34,9 @@ static bool csum = true, gso = true;
 module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
 
+static int rx_allocate_batch = 32;
+module_param(rx_allocate_batch, int, 0644);
+
 /* FIXME: MTU in config. */
 #define MAX_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
@@ -72,6 +75,9 @@ struct virtnet_info {
 	/* Work struct for refilling if we run low on memory. */
 	struct delayed_work refill;
 
+	/* Lock used to synchronize adding buffers to the rx queue */
+	spinlock_t rx_fill_lock;
+
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
@@ -353,58 +359,82 @@ frame_err:
 	dev_kfree_skb(skb);
 }
 
-static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
+static int alloc_recvbuf_small(struct virtnet_info *vi, struct list_head *list,
+			       gfp_t gfp)
 {
 	struct sk_buff *skb;
-	struct skb_vnet_hdr *hdr;
-	int err;
 
 	skb = __netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN, gfp);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
 	skb_put(skb, MAX_PACKET_LEN);
+	list_add_tail((struct list_head *)skb, list);
+	return 0;
+}
+
+static int add_recvbuf_small(struct virtnet_info *vi, struct sk_buff *skb)
+{
+	struct skb_vnet_hdr *hdr;
+	int err;
 
 	hdr = skb_vnet_hdr(skb);
 	sg_set_buf(vi->rx_sg, &hdr->hdr, sizeof hdr->hdr);
 
 	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
 
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 2, skb, gfp);
+	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 2, skb);
 	if (err < 0)
 		dev_kfree_skb(skb);
-
 	return err;
 }
 
-static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
+static int alloc_recvbuf_big(struct virtnet_info *vi, struct list_head *list,
+			     gfp_t gfp)
 {
-	struct page *first, *list = NULL;
-	char *p;
-	int i, err, offset;
+	struct page *first, *tail = NULL;
+	int i;
 
 	/* page in vi->rx_sg[MAX_SKB_FRAGS + 1] is list tail */
 	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
 		first = get_a_page(vi, gfp);
 		if (!first) {
-			if (list)
-				give_pages(vi, list);
+			if (tail)
+				give_pages(vi, tail);
 			return -ENOMEM;
 		}
 		sg_set_buf(&vi->rx_sg[i], page_address(first), PAGE_SIZE);
 
 		/* chain new page in list head to match sg */
-		first->private = (unsigned long)list;
-		list = first;
+		first->private = (unsigned long)tail;
+		tail = first;
 	}
 
 	first = get_a_page(vi, gfp);
 	if (!first) {
-		give_pages(vi, list);
+		give_pages(vi, tail);
 		return -ENOMEM;
 	}
-	p = page_address(first);
 
+	/* chain first in list head */
+	first->private = (unsigned long)tail;
+
+	list_add_tail(&first->lru, list);
+
+	return 0;
+}
+
+/*
+ *  Add a big page threaded through first->private to the rx queue.
+ *
+ *  Consumes the page list, even in case of failure.
+ */
+static int add_recvbuf_big(struct virtnet_info *vi, struct page *first)
+{
+	char *p;
+	int err, offset;
+
+	p = page_address(first);
 	/* vi->rx_sg[0], vi->rx_sg[1] share the same page */
 	/* a separated vi->rx_sg[0] for virtio_net_hdr only due to QEMU bug */
 	sg_set_buf(&vi->rx_sg[0], p, sizeof(struct virtio_net_hdr));
@@ -413,65 +443,140 @@ static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 	offset = sizeof(struct padded_vnet_hdr);
 	sg_set_buf(&vi->rx_sg[1], p + offset, PAGE_SIZE - offset);
 
-	/* chain first in list head */
-	first->private = (unsigned long)list;
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
-				    first, gfp);
+	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
+				first);
 	if (err < 0)
 		give_pages(vi, first);
-
 	return err;
 }
 
-static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
+static int alloc_recvbuf_mergeable(struct virtnet_info *vi,
+				   struct list_head *list, gfp_t gfp)
 {
 	struct page *page;
-	int err;
 
 	page = get_a_page(vi, gfp);
 	if (!page)
 		return -ENOMEM;
 
-	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
+	list_add_tail(&page->lru, list);
+	return 0;
+}
 
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 1, page, gfp);
+/* Add a page to the rx queue.  Consumes the page even in failure. */
+static int add_recvbuf_mergeable(struct virtnet_info *vi, struct page *page)
+{
+	int err;
+	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
+	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 1, page);
 	if (err < 0)
 		give_pages(vi, page);
-
 	return err;
 }
 
-/*
- * Returns false if we couldn't fill entirely (OOM).
- *
- * Normally run in the receive path, but can also be run from ndo_open
- * before we're receiving packets, or from refill_work which is
- * careful to disable receiving (using napi_disable).
- */
-static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
+/* Returns false if we couldn't fill entirely (OOM). */
+static inline bool try_fill_recv_pages(struct virtnet_info *vi, gfp_t gfp,
+		int (*alloc)(struct virtnet_info *, struct list_head *, gfp_t),
+		int (*add)(struct virtnet_info *, struct page *))
 {
+	LIST_HEAD(local_list);
+	struct page *page, *nextpage;
 	int err;
 	bool oom;
 
-	do {
-		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(vi, gfp);
-		else if (vi->big_packets)
-			err = add_recvbuf_big(vi, gfp);
-		else
-			err = add_recvbuf_small(vi, gfp);
+	while (1) {
+		int count = rx_allocate_batch;
+		do {
+			err = alloc(vi, &local_list, gfp);
+			oom |= err == -ENOMEM;
+			if (err < 0)
+				break;
+		} while (err >= 0 && --count);
+
+		spin_lock_bh(&vi->rx_fill_lock);
+		list_for_each_entry_safe(page, nextpage, &local_list, lru) {
+			list_del(&page->lru);
+			err = add(vi, page);
+			oom |= err == -ENOMEM;
+			if (err >= 0)
+				++vi->num;
+		}
+		if (unlikely(vi->num > vi->max))
+			vi->max = vi->num;
+		if (err < 0 || vi->num == vi->max)
+			break;
+		spin_unlock_bh(&vi->rx_fill_lock);
+	}
+	virtqueue_kick(vi->rvq);
+	spin_unlock_bh(&vi->rx_fill_lock);
+	return !oom;
+}
+
+static bool try_fill_recv_mergeable(struct virtnet_info *vi, gfp_t gfp)
+{
+	return try_fill_recv_pages(vi, gfp, alloc_recvbuf_mergeable,
+				   add_recvbuf_mergeable);
+}
+
+static bool try_fill_recv_big(struct virtnet_info *vi, gfp_t gfp)
+{
+	return try_fill_recv_pages(vi, gfp, alloc_recvbuf_big, add_recvbuf_big);
+}
+
+static bool try_fill_recv_small(struct virtnet_info *vi, gfp_t gfp)
+{
+	LIST_HEAD(local_list);
+	struct list_head *pos, *n;
+	int err;
+	bool oom;
 
-		oom = err == -ENOMEM;
-		if (err < 0)
+	while (1) {
+		int count = rx_allocate_batch;
+		do {
+			err = alloc_recvbuf_small(vi, &local_list, gfp);
+			oom |= err == -ENOMEM;
+			/* In case of error, still process the local_list */
+			if (err < 0)
+				break;
+		} while (err >= 0 && --count);
+
+		spin_lock_bh(&vi->rx_fill_lock);
+		list_for_each_safe(pos, n, &local_list) {
+			struct sk_buff *skb = (struct sk_buff *)pos;
+			list_del(pos);
+			err = add_recvbuf_small(vi, skb);
+			oom |= err == -ENOMEM;
+			if (err >= 0)
+				++vi->num;
+		}
+		if (unlikely(vi->num > vi->max))
+			vi->max = vi->num;
+		if (err < 0 || vi->num == vi->max)
 			break;
-		++vi->num;
-	} while (err > 0);
-	if (unlikely(vi->num > vi->max))
-		vi->max = vi->num;
+		spin_unlock_bh(&vi->rx_fill_lock);
+	}
 	virtqueue_kick(vi->rvq);
+	spin_unlock_bh(&vi->rx_fill_lock);
 	return !oom;
 }
 
+/*
+ * Returns false if we couldn't fill entirely (OOM).
+ *
+ * Normally run in the receive path, but can also be run from ndo_open
+ * before we're receiving packets, or from refill_work.  Serializes
+ * access to the virtioqueue using vi->rx_fill_lock.
+ */
+static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
+{
+	if (vi->mergeable_rx_bufs)
+		return try_fill_recv_mergeable(vi, gfp);
+	else if (vi->big_packets)
+		return try_fill_recv_big(vi, gfp);
+	else
+		return try_fill_recv_small(vi, gfp);
+}
+
 static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
@@ -502,9 +607,7 @@ static void refill_work(struct work_struct *work)
 	bool still_empty;
 
 	vi = container_of(work, struct virtnet_info, refill.work);
-	napi_disable(&vi->napi);
 	still_empty = !try_fill_recv(vi, GFP_KERNEL);
-	virtnet_napi_enable(vi);
 
 	/* In theory, this can happen: if we don't get any buffers in
 	 * we will *never* try to fill again. */
@@ -519,12 +622,15 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 	unsigned int len, received = 0;
 
 again:
+	/* We must serialize access to the queue from any concurrent refills. */
+	spin_lock(&vi->rx_fill_lock);
 	while (received < budget &&
 	       (buf = virtqueue_get_buf(vi->rvq, &len)) != NULL) {
 		receive_buf(vi->dev, buf, len);
 		--vi->num;
 		received++;
 	}
+	spin_unlock(&vi->rx_fill_lock);
 
 	if (vi->num < vi->max / 2) {
 		if (!try_fill_recv(vi, GFP_ATOMIC))
@@ -675,7 +781,7 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
 		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
-		                  dev->dev_addr, dev->addr_len);
+				  dev->dev_addr, dev->addr_len);
 
 	return 0;
 }
@@ -1053,6 +1159,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free;
 
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
+	spin_lock_init(&vi->rx_fill_lock);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
 	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
@@ -1089,8 +1196,11 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free_vqs;
 	}
 
-	/* Last of all, set up some receive buffers. */
+	/* Last of all, set up some receive buffers.
+	 * Start off with a huge max, and then clamp it down to the real max */
+	vi->max = ~0U;
 	try_fill_recv(vi, GFP_KERNEL);
+	vi->max = vi->num;
 
 	/* If we didn't even get one input buffer, we're useless. */
 	if (vi->num == 0) {
