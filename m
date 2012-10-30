From: Jason Wang <jasowang@redhat.com>
Subject: [rfc net-next v6 2/3] virtio_net: multiqueue support
Date: Tue, 30 Oct 2012 18:03:22 +0800
Message-ID: <1351591403-23065-3-git-send-email-jasowang@redhat.com>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org
To: mst@redhat.com, davem@davemloft.net,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, krkumar2@in.ibm.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This addes multiqueue support to virtio_net driver. There's two mode supported:
single queue pair mode and multiple queue pairs mode. An obvious difference
compared with a physical mq card is that virtio-net reserve first two virtqueues
when it is working in multiqueue mode, this is used for implementing adaptive
mode switching in the future. The virtqueues that were in both mq and sq mode
were initialized and only one queue pair (single queue mode) were used at
default. User could use ethtool -L to switch to multiqueue mode withe the next
patch.

In multiple queue modes, the driver expects the number of queue paris is equal
to the number of vcpus. In the case, each vcpu would have its private virtqueue
pairs through:

- select the txq based on the smp processor id.
- smp affinity hint were set to the vcpu that owns the queue pairs.

To make sure a single vcpu is handling the packets from the same flow, driver
would let the device (usually tuntap) to use the 'rx follows tx' packet steering
rules when working in multiqueue mode. In this mode, the device would select the
rxq based on the last queue where the packet of the flow were sent.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c        |  747 ++++++++++++++++++++++++++++-----------
 include/uapi/linux/virtio_net.h |   18 +
 2 files changed, 550 insertions(+), 215 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index cbf8b06..8cc43e5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -26,6 +26,7 @@
 #include <linux/scatterlist.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
+#include <linux/interrupt.h>
 
 static int napi_weight = 128;
 module_param(napi_weight, int, 0444);
@@ -51,43 +52,70 @@ struct virtnet_stats {
 	u64 rx_packets;
 };
 
-struct virtnet_info {
-	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq, *cvq;
-	struct net_device *dev;
+/* Internal representation of a send virtqueue */
+struct send_queue {
+	/* Virtqueue associated with this send _queue */
+	struct virtqueue *vq;
+
+	/* TX: fragments + linear part + virtio header */
+	struct scatterlist sg[MAX_SKB_FRAGS + 2];
+};
+
+/* Internal representation of a receive virtqueue */
+struct receive_queue {
+	/* Virtqueue associated with this receive_queue */
+	struct virtqueue *vq;
+
+	/* Back pointer to the virtnet_info */
+	struct virtnet_info *vi;
+
 	struct napi_struct napi;
-	unsigned int status;
 
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
 
+	/* Work struct for refilling if we run low on memory. */
+	struct delayed_work refill;
+
+	/* Chain pages by the private ptr. */
+	struct page *pages;
+
+	/* RX: fragments + linear part + virtio header */
+	struct scatterlist sg[MAX_SKB_FRAGS + 2];
+};
+
+struct virtnet_info {
+	u16 num_queue_pairs;		/* # of RX/TX vq pairs */
+	u16 total_queue_pairs;
+
+	struct send_queue *sq;
+	struct receive_queue *rq;
+	struct virtqueue *cvq;
+
+	struct virtio_device *vdev;
+	struct net_device *dev;
+	unsigned int status;
+
 	/* I like... big packets and I cannot lie! */
 	bool big_packets;
 
 	/* Host will merge rx buffers for big packets (shake it! shake it!) */
 	bool mergeable_rx_bufs;
 
+	/* Has control virtqueue */
+	bool has_cvq;
+
 	/* enable config space updates */
 	bool config_enable;
 
 	/* Active statistics */
 	struct virtnet_stats __percpu *stats;
 
-	/* Work struct for refilling if we run low on memory. */
-	struct delayed_work refill;
-
 	/* Work struct for config space updates */
 	struct work_struct config_work;
 
 	/* Lock for config space updates */
 	struct mutex config_lock;
-
-	/* Chain pages by the private ptr. */
-	struct page *pages;
-
-	/* fragments + linear part + virtio header */
-	struct scatterlist rx_sg[MAX_SKB_FRAGS + 2];
-	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
 };
 
 struct skb_vnet_hdr {
@@ -108,6 +136,30 @@ struct padded_vnet_hdr {
 	char padding[6];
 };
 
+static const struct ethtool_ops virtnet_ethtool_ops;
+
+static inline int vq2txq(struct virtqueue *vq)
+{
+	int index = virtqueue_get_queue_index(vq);
+	return index == 1 ? 0 : (index - 3) / 2;
+}
+
+static inline int txq2vq(int txq)
+{
+	return txq ? 2 * txq + 3 : 1;
+}
+
+static inline int vq2rxq(struct virtqueue *vq)
+{
+	int index = virtqueue_get_queue_index(vq);
+	return index ? (index - 2) / 2 : 0;
+}
+
+static inline int rxq2vq(int rxq)
+{
+	return rxq ? 2 * rxq + 2 : 0;
+}
+
 static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
 {
 	return (struct skb_vnet_hdr *)skb->cb;
@@ -117,22 +169,22 @@ static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
  * private is used to chain pages for big packets, put the whole
  * most recent used list in the beginning for reuse
  */
-static void give_pages(struct virtnet_info *vi, struct page *page)
+static void give_pages(struct receive_queue *rq, struct page *page)
 {
 	struct page *end;
 
 	/* Find end of list, sew whole thing into vi->pages. */
 	for (end = page; end->private; end = (struct page *)end->private);
-	end->private = (unsigned long)vi->pages;
-	vi->pages = page;
+	end->private = (unsigned long)rq->pages;
+	rq->pages = page;
 }
 
-static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
+static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
 {
-	struct page *p = vi->pages;
+	struct page *p = rq->pages;
 
 	if (p) {
-		vi->pages = (struct page *)p->private;
+		rq->pages = (struct page *)p->private;
 		/* clear private here, it is used to chain pages */
 		p->private = 0;
 	} else
@@ -140,15 +192,15 @@ static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 	return p;
 }
 
-static void skb_xmit_done(struct virtqueue *svq)
+static void skb_xmit_done(struct virtqueue *vq)
 {
-	struct virtnet_info *vi = svq->vdev->priv;
+	struct virtnet_info *vi = vq->vdev->priv;
 
 	/* Suppress further interrupts. */
-	virtqueue_disable_cb(svq);
+	virtqueue_disable_cb(vq);
 
 	/* We were probably waiting for more output buffers. */
-	netif_wake_queue(vi->dev);
+	netif_wake_subqueue(vi->dev, vq2txq(vq));
 }
 
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
@@ -167,9 +219,10 @@ static void set_skb_frag(struct sk_buff *skb, struct page *page,
 }
 
 /* Called from bottom half context */
-static struct sk_buff *page_to_skb(struct virtnet_info *vi,
+static struct sk_buff *page_to_skb(struct receive_queue *rq,
 				   struct page *page, unsigned int len)
 {
+	struct virtnet_info *vi = rq->vi;
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	unsigned int copy, hdr_len, offset;
@@ -225,12 +278,12 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	}
 
 	if (page)
-		give_pages(vi, page);
+		give_pages(rq, page);
 
 	return skb;
 }
 
-static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
+static int receive_mergeable(struct receive_queue *rq, struct sk_buff *skb)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	struct page *page;
@@ -244,7 +297,7 @@ static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
 			skb->dev->stats.rx_length_errors++;
 			return -EINVAL;
 		}
-		page = virtqueue_get_buf(vi->rvq, &len);
+		page = virtqueue_get_buf(rq->vq, &len);
 		if (!page) {
 			pr_debug("%s: rx error: %d buffers missing\n",
 				 skb->dev->name, hdr->mhdr.num_buffers);
@@ -257,13 +310,14 @@ static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
 
 		set_skb_frag(skb, page, 0, &len);
 
-		--vi->num;
+		--rq->num;
 	}
 	return 0;
 }
 
-static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
+static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 {
+	struct net_device *dev = rq->vi->dev;
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 	struct sk_buff *skb;
@@ -274,7 +328,7 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
 		if (vi->mergeable_rx_bufs || vi->big_packets)
-			give_pages(vi, buf);
+			give_pages(rq, buf);
 		else
 			dev_kfree_skb(buf);
 		return;
@@ -286,14 +340,14 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 		skb_trim(skb, len);
 	} else {
 		page = buf;
-		skb = page_to_skb(vi, page, len);
+		skb = page_to_skb(rq, page, len);
 		if (unlikely(!skb)) {
 			dev->stats.rx_dropped++;
-			give_pages(vi, page);
+			give_pages(rq, page);
 			return;
 		}
 		if (vi->mergeable_rx_bufs)
-			if (receive_mergeable(vi, skb)) {
+			if (receive_mergeable(rq, skb)) {
 				dev_kfree_skb(skb);
 				return;
 			}
@@ -363,90 +417,91 @@ frame_err:
 	dev_kfree_skb(skb);
 }
 
-static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_small(struct receive_queue *rq, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	int err;
 
-	skb = __netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN, gfp);
+	skb = __netdev_alloc_skb_ip_align(rq->vi->dev, MAX_PACKET_LEN, gfp);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
 	skb_put(skb, MAX_PACKET_LEN);
 
 	hdr = skb_vnet_hdr(skb);
-	sg_set_buf(vi->rx_sg, &hdr->hdr, sizeof hdr->hdr);
+	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
+
+	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
 
-	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
+	err = virtqueue_add_buf(rq->vq, rq->sg, 0, 2, skb, gfp);
 
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 2, skb, gfp);
 	if (err < 0)
 		dev_kfree_skb(skb);
 
 	return err;
 }
 
-static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 {
 	struct page *first, *list = NULL;
 	char *p;
 	int i, err, offset;
 
-	/* page in vi->rx_sg[MAX_SKB_FRAGS + 1] is list tail */
+	/* page in rq->sg[MAX_SKB_FRAGS + 1] is list tail */
 	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
-		first = get_a_page(vi, gfp);
+		first = get_a_page(rq, gfp);
 		if (!first) {
 			if (list)
-				give_pages(vi, list);
+				give_pages(rq, list);
 			return -ENOMEM;
 		}
-		sg_set_buf(&vi->rx_sg[i], page_address(first), PAGE_SIZE);
+		sg_set_buf(&rq->sg[i], page_address(first), PAGE_SIZE);
 
 		/* chain new page in list head to match sg */
 		first->private = (unsigned long)list;
 		list = first;
 	}
 
-	first = get_a_page(vi, gfp);
+	first = get_a_page(rq, gfp);
 	if (!first) {
-		give_pages(vi, list);
+		give_pages(rq, list);
 		return -ENOMEM;
 	}
 	p = page_address(first);
 
-	/* vi->rx_sg[0], vi->rx_sg[1] share the same page */
-	/* a separated vi->rx_sg[0] for virtio_net_hdr only due to QEMU bug */
-	sg_set_buf(&vi->rx_sg[0], p, sizeof(struct virtio_net_hdr));
+	/* rq->sg[0], rq->sg[1] share the same page */
+	/* a separated rq->sg[0] for virtio_net_hdr only due to QEMU bug */
+	sg_set_buf(&rq->sg[0], p, sizeof(struct virtio_net_hdr));
 
-	/* vi->rx_sg[1] for data packet, from offset */
+	/* rq->sg[1] for data packet, from offset */
 	offset = sizeof(struct padded_vnet_hdr);
-	sg_set_buf(&vi->rx_sg[1], p + offset, PAGE_SIZE - offset);
+	sg_set_buf(&rq->sg[1], p + offset, PAGE_SIZE - offset);
 
 	/* chain first in list head */
 	first->private = (unsigned long)list;
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
+	err = virtqueue_add_buf(rq->vq, rq->sg, 0, MAX_SKB_FRAGS + 2,
 				first, gfp);
 	if (err < 0)
-		give_pages(vi, first);
+		give_pages(rq, first);
 
 	return err;
 }
 
-static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 {
 	struct page *page;
 	int err;
 
-	page = get_a_page(vi, gfp);
+	page = get_a_page(rq, gfp);
 	if (!page)
 		return -ENOMEM;
 
-	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
+	sg_init_one(rq->sg, page_address(page), PAGE_SIZE);
 
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 1, page, gfp);
+	err = virtqueue_add_buf(rq->vq, rq->sg, 0, 1, page, gfp);
 	if (err < 0)
-		give_pages(vi, page);
+		give_pages(rq, page);
 
 	return err;
 }
@@ -458,97 +513,104 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
  * before we're receiving packets, or from refill_work which is
  * careful to disable receiving (using napi_disable).
  */
-static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
+static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
 {
+	struct virtnet_info *vi = rq->vi;
 	int err;
 	bool oom;
 
 	do {
 		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(vi, gfp);
+			err = add_recvbuf_mergeable(rq, gfp);
 		else if (vi->big_packets)
-			err = add_recvbuf_big(vi, gfp);
+			err = add_recvbuf_big(rq, gfp);
 		else
-			err = add_recvbuf_small(vi, gfp);
+			err = add_recvbuf_small(rq, gfp);
 
 		oom = err == -ENOMEM;
 		if (err < 0)
 			break;
-		++vi->num;
+		++rq->num;
 	} while (err > 0);
-	if (unlikely(vi->num > vi->max))
-		vi->max = vi->num;
-	virtqueue_kick(vi->rvq);
+	if (unlikely(rq->num > rq->max))
+		rq->max = rq->num;
+	virtqueue_kick(rq->vq);
 	return !oom;
 }
 
-static void skb_recv_done(struct virtqueue *rvq)
+static void skb_recv_done(struct virtqueue *vq)
 {
-	struct virtnet_info *vi = rvq->vdev->priv;
+	struct virtnet_info *vi = vq->vdev->priv;
+	struct napi_struct *napi = &vi->rq[vq2rxq(vq)].napi;
+
 	/* Schedule NAPI, Suppress further interrupts if successful. */
-	if (napi_schedule_prep(&vi->napi)) {
-		virtqueue_disable_cb(rvq);
-		__napi_schedule(&vi->napi);
+	if (napi_schedule_prep(napi)) {
+		virtqueue_disable_cb(vq);
+		__napi_schedule(napi);
 	}
 }
 
-static void virtnet_napi_enable(struct virtnet_info *vi)
+static void virtnet_napi_enable(struct receive_queue *rq)
 {
-	napi_enable(&vi->napi);
+	napi_enable(&rq->napi);
 
 	/* If all buffers were filled by other side before we napi_enabled, we
 	 * won't get another interrupt, so process any outstanding packets
 	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
 	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (napi_schedule_prep(&vi->napi)) {
-		virtqueue_disable_cb(vi->rvq);
+	if (napi_schedule_prep(&rq->napi)) {
+		virtqueue_disable_cb(rq->vq);
 		local_bh_disable();
-		__napi_schedule(&vi->napi);
+		__napi_schedule(&rq->napi);
 		local_bh_enable();
 	}
 }
 
 static void refill_work(struct work_struct *work)
 {
-	struct virtnet_info *vi;
+	struct napi_struct *napi;
+	struct receive_queue *rq;
 	bool still_empty;
 
-	vi = container_of(work, struct virtnet_info, refill.work);
-	napi_disable(&vi->napi);
-	still_empty = !try_fill_recv(vi, GFP_KERNEL);
-	virtnet_napi_enable(vi);
+	rq = container_of(work, struct receive_queue, refill.work);
+	napi = &rq->napi;
+
+	napi_disable(napi);
+	still_empty = !try_fill_recv(rq, GFP_KERNEL);
+	virtnet_napi_enable(rq);
 
 	/* In theory, this can happen: if we don't get any buffers in
 	 * we will *never* try to fill again. */
 	if (still_empty)
-		schedule_delayed_work(&vi->refill, HZ/2);
+		schedule_delayed_work(&rq->refill, HZ/2);
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
-	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
+	struct receive_queue *rq = container_of(napi, struct receive_queue,
+						napi);
 	void *buf;
 	unsigned int len, received = 0;
 
 again:
 	while (received < budget &&
-	       (buf = virtqueue_get_buf(vi->rvq, &len)) != NULL) {
-		receive_buf(vi->dev, buf, len);
-		--vi->num;
+	       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
+		receive_buf(rq, buf, len);
+		--rq->num;
 		received++;
 	}
 
-	if (vi->num < vi->max / 2) {
-		if (!try_fill_recv(vi, GFP_ATOMIC))
-			schedule_delayed_work(&vi->refill, 0);
+	if (rq->num < rq->max / 2) {
+		if (!try_fill_recv(rq, GFP_ATOMIC))
+			schedule_delayed_work(&rq->refill, 0);
 	}
 
 	/* Out of packets? */
 	if (received < budget) {
 		napi_complete(napi);
-		if (unlikely(!virtqueue_enable_cb(vi->rvq)) &&
+		if (unlikely(!virtqueue_enable_cb(rq->vq)) &&
 		    napi_schedule_prep(napi)) {
-			virtqueue_disable_cb(vi->rvq);
+			virtqueue_disable_cb(rq->vq);
 			__napi_schedule(napi);
 			goto again;
 		}
@@ -557,13 +619,14 @@ again:
 	return received;
 }
 
-static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
+static unsigned int free_old_xmit_skbs(struct virtnet_info *vi,
+				       struct virtqueue *vq)
 {
 	struct sk_buff *skb;
 	unsigned int len, tot_sgs = 0;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	while ((skb = virtqueue_get_buf(vq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 
 		u64_stats_update_begin(&stats->tx_syncp);
@@ -577,7 +640,8 @@ static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
 	return tot_sgs;
 }
 
-static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
+static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb,
+		    struct virtqueue *vq, struct scatterlist *sg)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
@@ -615,44 +679,47 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 
 	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
+		sg_set_buf(sg, &hdr->mhdr, sizeof hdr->mhdr);
 	else
-		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
+		sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
 
-	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
-	return virtqueue_add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
+	hdr->num_sg = skb_to_sgvec(skb, sg + 1, 0, skb->len) + 1;
+	return virtqueue_add_buf(vq, sg, hdr->num_sg,
 				 0, skb, GFP_ATOMIC);
 }
 
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int qnum = skb_get_queue_mapping(skb);
+	struct virtqueue *vq = vi->sq[qnum].vq;
 	int capacity;
 
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	free_old_xmit_skbs(vi, vq);
 
 	/* Try to transmit */
-	capacity = xmit_skb(vi, skb);
+	capacity = xmit_skb(vi, skb, vq, vi->sq[qnum].sg);
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
 		if (likely(capacity == -ENOMEM)) {
 			if (net_ratelimit())
 				dev_warn(&dev->dev,
-					 "TX queue failure: out of memory\n");
+					"TXQ (%d) failure: out of memory\n",
+					qnum);
 		} else {
 			dev->stats.tx_fifo_errors++;
 			if (net_ratelimit())
 				dev_warn(&dev->dev,
-					 "Unexpected TX queue failure: %d\n",
-					 capacity);
+					"Unexpected TXQ (%d) failure: %d\n",
+					qnum, capacity);
 		}
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	virtqueue_kick(vi->svq);
+	virtqueue_kick(vq);
 
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
@@ -661,13 +728,13 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Apparently nice girls don't return TX_BUSY; stop the queue
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (capacity < 2+MAX_SKB_FRAGS) {
-		netif_stop_queue(dev);
-		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
+		netif_stop_subqueue(dev, qnum);
+		if (unlikely(!virtqueue_enable_cb_delayed(vq))) {
 			/* More just got used, free them then recheck. */
-			capacity += free_old_xmit_skbs(vi);
+			capacity += free_old_xmit_skbs(vi, vq);
 			if (capacity >= 2+MAX_SKB_FRAGS) {
-				netif_start_queue(dev);
-				virtqueue_disable_cb(vi->svq);
+				netif_start_subqueue(dev, qnum);
+				virtqueue_disable_cb(vq);
 			}
 		}
 	}
@@ -700,7 +767,8 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 	unsigned int start;
 
 	for_each_possible_cpu(cpu) {
-		struct virtnet_stats *stats = per_cpu_ptr(vi->stats, cpu);
+		struct virtnet_stats __percpu *stats
+			= per_cpu_ptr(vi->stats, cpu);
 		u64 tpackets, tbytes, rpackets, rbytes;
 
 		do {
@@ -734,23 +802,13 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 static void virtnet_netpoll(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
-	napi_schedule(&vi->napi);
+	for (i = 0; i < vi->num_queue_pairs; i++)
+		napi_schedule(&vi->rq[i].napi);
 }
 #endif
 
-static int virtnet_open(struct net_device *dev)
-{
-	struct virtnet_info *vi = netdev_priv(dev);
-
-	/* Make sure we have some buffers: if oom use wq. */
-	if (!try_fill_recv(vi, GFP_KERNEL))
-		schedule_delayed_work(&vi->refill, 0);
-
-	virtnet_napi_enable(vi);
-	return 0;
-}
-
 /*
  * Send command via the control virtqueue and check status.  Commands
  * supported by the hypervisor, as indicated by feature bits, should
@@ -806,13 +864,63 @@ static void virtnet_ack_link_announce(struct virtnet_info *vi)
 	rtnl_unlock();
 }
 
+static int virtnet_set_queues(struct virtnet_info *vi)
+{
+	struct scatterlist sg;
+	struct virtio_net_ctrl_steering s;
+	struct net_device *dev = vi->dev;
+
+	if (vi->num_queue_pairs == 1) {
+		s.current_steering_rule = VIRTIO_NET_CTRL_STEERING_SINGLE;
+		s.current_steering_param = 1;
+	} else {
+		s.current_steering_rule =
+			VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX;
+		s.current_steering_param = vi->num_queue_pairs;
+	}
+	sg_init_one(&sg, &s, sizeof(s));
+
+	if (!vi->has_cvq)
+		return -EINVAL;
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_STEERING,
+				  VIRTIO_NET_CTRL_STEERING_SET, &sg, 1, 0)){
+		dev_warn(&dev->dev, "Fail to set the number of queue pairs to"
+			 " %d\n", vi->num_queue_pairs);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int virtnet_open(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		/* Make sure we have some buffers: if oom use wq. */
+		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+			schedule_delayed_work(&vi->rq[i].refill, 0);
+		virtnet_napi_enable(&vi->rq[i]);
+	}
+
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_MULTIQUEUE))
+		virtnet_set_queues(vi);
+
+	return 0;
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
 	/* Make sure refill_work doesn't re-enable napi! */
-	cancel_delayed_work_sync(&vi->refill);
-	napi_disable(&vi->napi);
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		cancel_delayed_work_sync(&vi->rq[i].refill);
+		napi_disable(&vi->rq[i].napi);
+	}
 
 	return 0;
 }
@@ -924,11 +1032,10 @@ static void virtnet_get_ringparam(struct net_device *dev,
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	ring->rx_max_pending = virtqueue_get_vring_size(vi->rvq);
-	ring->tx_max_pending = virtqueue_get_vring_size(vi->svq);
+	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq[0].vq);
+	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq[0].vq);
 	ring->rx_pending = ring->rx_max_pending;
 	ring->tx_pending = ring->tx_max_pending;
-
 }
 
 
@@ -944,12 +1051,6 @@ static void virtnet_get_drvinfo(struct net_device *dev,
 
 }
 
-static const struct ethtool_ops virtnet_ethtool_ops = {
-	.get_drvinfo = virtnet_get_drvinfo,
-	.get_link = ethtool_op_get_link,
-	.get_ringparam = virtnet_get_ringparam,
-};
-
 #define MIN_MTU 68
 #define MAX_MTU 65535
 
@@ -961,6 +1062,22 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+/* To avoid contending a lock hold by a vcpu who would exit to host, select the
+ * txq based on the processor id.
+ */
+static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
+		  smp_processor_id();
+	int limit = dev->real_num_tx_queues - 1;
+
+	while (unlikely(txq >= limit))
+		txq -= limit;
+
+	/* queue 0 is reserved for single queue mode */
+	return txq + 1;
+}
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -972,6 +1089,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_get_stats64     = virtnet_stats,
 	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
+	.ndo_select_queue     = virtnet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
@@ -1007,10 +1125,10 @@ static void virtnet_config_changed_work(struct work_struct *work)
 
 	if (vi->status & VIRTIO_NET_S_LINK_UP) {
 		netif_carrier_on(vi->dev);
-		netif_wake_queue(vi->dev);
+		netif_tx_wake_all_queues(vi->dev);
 	} else {
 		netif_carrier_off(vi->dev);
-		netif_stop_queue(vi->dev);
+		netif_tx_stop_all_queues(vi->dev);
 	}
 done:
 	mutex_unlock(&vi->config_lock);
@@ -1023,41 +1141,216 @@ static void virtnet_config_changed(struct virtio_device *vdev)
 	schedule_work(&vi->config_work);
 }
 
-static int init_vqs(struct virtnet_info *vi)
+static void free_receive_bufs(struct virtnet_info *vi)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { skb_recv_done, skb_xmit_done, NULL};
-	const char *names[] = { "input", "output", "control" };
-	int nvqs, err;
+	int i;
 
-	/* We expect two virtqueues, receive then send,
-	 * and optionally control. */
-	nvqs = virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ? 3 : 2;
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		while (vi->rq[i].pages)
+			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
+	}
+}
 
-	err = vi->vdev->config->find_vqs(vi->vdev, nvqs, vqs, callbacks, names);
-	if (err)
-		return err;
+/* Free memory allocated for send and receive queues */
+static void virtnet_free_queues(struct virtnet_info *vi)
+{
+	kfree(vi->rq);
+	vi->rq = NULL;
+	kfree(vi->sq);
+	vi->sq = NULL;
+}
+
+static void free_unused_bufs(struct virtnet_info *vi)
+{
+	void *buf;
+	int i;
+
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		struct virtqueue *vq = vi->sq[i].vq;
+
+		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL)
+			dev_kfree_skb(buf);
+	}
+
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		struct virtqueue *vq = vi->rq[i].vq;
+
+		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
+			if (vi->mergeable_rx_bufs || vi->big_packets)
+				give_pages(&vi->rq[i], buf);
+			else
+				dev_kfree_skb(buf);
+			--vi->rq[i].num;
+		}
+		BUG_ON(vi->rq[i].num != 0);
+	}
+}
+
+static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
+{
+	int i;
+
+	for (i = 1; i < vi->total_queue_pairs; i++) {
+		int cpu = set ? i - 1 : -1;
+		virtqueue_set_affinity(vi->rq[i].vq, cpu);
+		virtqueue_set_affinity(vi->sq[i].vq, cpu);
+	}
+}
+
+static void virtnet_del_vqs(struct virtnet_info *vi)
+{
+	struct virtio_device *vdev = vi->vdev;
+
+	virtnet_set_affinity(vi, false);
+
+	vdev->config->del_vqs(vdev);
+
+	virtnet_free_queues(vi);
+}
+
+static int virtnet_find_vqs(struct virtnet_info *vi)
+{
+	vq_callback_t **callbacks;
+	struct virtqueue **vqs;
+	int ret = -ENOMEM;
+	int i, total_vqs;
+	char **names;
 
-	vi->rvq = vqs[0];
-	vi->svq = vqs[1];
+	/*
+	 * We expect 1 RX virtqueue followed by 1 TX virtqueue, followd by
+	 * possible control virtqueue, followed by 1 reserved vq, followed
+	 * by RX/TX queue pairs used in multiqueue mode.
+	 */
+	if (vi->total_queue_pairs == 1)
+		total_vqs = 2 + virtio_has_feature(vi->vdev,
+						   VIRTIO_NET_F_CTRL_VQ);
+	else
+		total_vqs = 2 * vi->total_queue_pairs + 2;
+
+	/* Allocate space for find_vqs parameters */
+	vqs = kzalloc(total_vqs * sizeof(*vqs), GFP_KERNEL);
+	callbacks = kzalloc(total_vqs * sizeof(*callbacks), GFP_KERNEL);
+	if (!vqs || !callbacks)
+		goto err_mem;
+	names = kzalloc(total_vqs * sizeof(*names), GFP_KERNEL);
+	if (!names)
+		goto err_mem;
+
+	/* Parameters for control virtqueue, if any */
+	if (vi->has_cvq) {
+		callbacks[2] = NULL;
+		names[2] = kasprintf(GFP_KERNEL, "control");
+	}
 
-	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
+	/* Allocate/initialize parameters for send/receive virtqueues */
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		callbacks[rxq2vq(i)] = skb_recv_done;
+		callbacks[txq2vq(i)] = skb_xmit_done;
+		names[rxq2vq(i)] = kasprintf(GFP_KERNEL, "input.%d", i);
+		names[txq2vq(i)] = kasprintf(GFP_KERNEL, "output.%d", i);
+	}
+
+	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
+					 (const char **)names);
+	if (ret)
+		goto err_names;
+
+	if (vi->has_cvq)
 		vi->cvq = vqs[2];
 
-		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
-			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		vi->rq[i].vq = vqs[rxq2vq(i)];
+		vi->sq[i].vq = vqs[txq2vq(i)];
 	}
+
+	kfree(callbacks);
+	kfree(vqs);
+
 	return 0;
+
+err_names:
+	for (i = 0; i < total_vqs * 2; i ++)
+		kfree(names[i]);
+	kfree(names);
+
+err_mem:
+	kfree(callbacks);
+	kfree(vqs);
+
+	return ret;
+}
+
+static int virtnet_alloc_queues(struct virtnet_info *vi)
+{
+	int i;
+
+	vi->sq = kzalloc(sizeof(vi->sq[0]) * vi->total_queue_pairs, GFP_KERNEL);
+	vi->rq = kzalloc(sizeof(vi->rq[0]) * vi->total_queue_pairs, GFP_KERNEL);
+	if (!vi->rq || !vi->sq)
+		goto err;
+
+	/* setup initial receive and send queue parameters */
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		vi->rq[i].vi = vi;
+		vi->rq[i].pages = NULL;
+		INIT_DELAYED_WORK(&vi->rq[i].refill, refill_work);
+		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
+			       napi_weight);
+
+		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
+		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
+	}
+
+
+	return 0;
+
+err:
+	virtnet_free_queues(vi);
+	return -ENOMEM;
+}
+
+static int virtnet_setup_vqs(struct virtnet_info *vi)
+{
+	int ret;
+
+	/* Allocate send & receive queues */
+	ret = virtnet_alloc_queues(vi);
+	if (ret)
+		goto err;
+
+	ret = virtnet_find_vqs(vi);
+	if (ret)
+		goto err_free;
+
+	virtnet_set_affinity(vi, true);
+	return 0;
+
+err_free:
+	virtnet_free_queues(vi);
+err:
+	return ret;
 }
 
 static int virtnet_probe(struct virtio_device *vdev)
 {
-	int err;
+	int i, err;
 	struct net_device *dev;
 	struct virtnet_info *vi;
+	u16 num_queue_pairs;
+
+	/* Find if host supports multiqueue virtio_net device */
+	err = virtio_config_val(vdev, VIRTIO_NET_F_MULTIQUEUE,
+				offsetof(struct virtio_net_config,
+				max_virtqueue_pairs), &num_queue_pairs);
+
+	/* We need at least 2 queue's */
+	if (err)
+		num_queue_pairs = 1;
+	if (num_queue_pairs > 1)
+		num_queue_pairs ++;
 
 	/* Allocate ourselves a network device with room for our info */
-	dev = alloc_etherdev(sizeof(struct virtnet_info));
+	dev = alloc_etherdev_mq(sizeof(struct virtnet_info), num_queue_pairs);
 	if (!dev)
 		return -ENOMEM;
 
@@ -1103,22 +1396,17 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
-	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
 	vi->dev = dev;
 	vi->vdev = vdev;
 	vdev->priv = vi;
-	vi->pages = NULL;
 	vi->stats = alloc_percpu(struct virtnet_stats);
 	err = -ENOMEM;
 	if (vi->stats == NULL)
-		goto free;
+		goto free_netdev;
 
-	INIT_DELAYED_WORK(&vi->refill, refill_work);
 	mutex_init(&vi->config_lock);
 	vi->config_enable = true;
 	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
-	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
-	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -1129,10 +1417,25 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
-	err = init_vqs(vi);
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
+		vi->has_cvq = true;
+
+	/* Use single tx/rx queue pair as default */
+	vi->num_queue_pairs = 1;
+	vi->total_queue_pairs = num_queue_pairs;
+
+	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
+	err = virtnet_setup_vqs(vi);
 	if (err)
 		goto free_stats;
 
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) &&
+	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
+		dev->features |= NETIF_F_HW_VLAN_FILTER;
+
+	netif_set_real_num_tx_queues(dev, 1);
+	netif_set_real_num_rx_queues(dev, 1);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
@@ -1140,12 +1443,15 @@ static int virtnet_probe(struct virtio_device *vdev)
 	}
 
 	/* Last of all, set up some receive buffers. */
-	try_fill_recv(vi, GFP_KERNEL);
-
-	/* If we didn't even get one input buffer, we're useless. */
-	if (vi->num == 0) {
-		err = -ENOMEM;
-		goto unregister;
+	for (i = 0; i < vi->total_queue_pairs; i++) {
+		try_fill_recv(&vi->rq[i], GFP_KERNEL);
+
+		/* If we didn't even get one input buffer, we're useless. */
+		if (vi->rq[i].num == 0) {
+			free_unused_bufs(vi);
+			err = -ENOMEM;
+			goto free_recv_bufs;
+		}
 	}
 
 	/* Assume link up if device can't report link status,
@@ -1158,42 +1464,28 @@ static int virtnet_probe(struct virtio_device *vdev)
 		netif_carrier_on(dev);
 	}
 
-	pr_debug("virtnet: registered device %s\n", dev->name);
+	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
+		 dev->name, num_queue_pairs);
+
 	return 0;
 
-unregister:
+free_recv_bufs:
+	free_receive_bufs(vi);
 	unregister_netdev(dev);
+
 free_vqs:
-	vdev->config->del_vqs(vdev);
+	for (i = 0; i <num_queue_pairs; i++)
+		cancel_delayed_work_sync(&vi->rq[i].refill);
+	virtnet_del_vqs(vi);
+
 free_stats:
 	free_percpu(vi->stats);
-free:
+
+free_netdev:
 	free_netdev(dev);
 	return err;
 }
 
-static void free_unused_bufs(struct virtnet_info *vi)
-{
-	void *buf;
-	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->svq);
-		if (!buf)
-			break;
-		dev_kfree_skb(buf);
-	}
-	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->rvq);
-		if (!buf)
-			break;
-		if (vi->mergeable_rx_bufs || vi->big_packets)
-			give_pages(vi, buf);
-		else
-			dev_kfree_skb(buf);
-		--vi->num;
-	}
-	BUG_ON(vi->num != 0);
-}
-
 static void remove_vq_common(struct virtnet_info *vi)
 {
 	vi->vdev->config->reset(vi->vdev);
@@ -1201,10 +1493,9 @@ static void remove_vq_common(struct virtnet_info *vi)
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
 
-	vi->vdev->config->del_vqs(vi->vdev);
+	free_receive_bufs(vi);
 
-	while (vi->pages)
-		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
+	virtnet_del_vqs(vi);
 }
 
 static void __devexit virtnet_remove(struct virtio_device *vdev)
@@ -1226,10 +1517,9 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 	free_netdev(vi->dev);
 }
 
-#ifdef CONFIG_PM
-static int virtnet_freeze(struct virtio_device *vdev)
+static void virtnet_stop(struct virtnet_info *vi)
 {
-	struct virtnet_info *vi = vdev->priv;
+	int i;
 
 	/* Prevent config work handler from accessing the device */
 	mutex_lock(&vi->config_lock);
@@ -1237,34 +1527,32 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	mutex_unlock(&vi->config_lock);
 
 	netif_device_detach(vi->dev);
-	cancel_delayed_work_sync(&vi->refill);
+	for (i = 0; i < vi->total_queue_pairs; i++)
+		cancel_delayed_work_sync(&vi->rq[i].refill);
 
 	if (netif_running(vi->dev))
-		napi_disable(&vi->napi);
-
-	remove_vq_common(vi);
+		for (i = 0; i < vi->total_queue_pairs; i++)
+			napi_disable(&vi->rq[i].napi);
 
-	flush_work(&vi->config_work);
-
-	return 0;
 }
 
-static int virtnet_restore(struct virtio_device *vdev)
+static int virtnet_start(struct virtnet_info *vi)
 {
-	struct virtnet_info *vi = vdev->priv;
-	int err;
+	int err, i;
 
-	err = init_vqs(vi);
+	err = virtnet_setup_vqs(vi);
 	if (err)
 		return err;
 
 	if (netif_running(vi->dev))
-		virtnet_napi_enable(vi);
+		for (i = 0; i < vi->total_queue_pairs; i++)
+			virtnet_napi_enable(&vi->rq[i]);
 
 	netif_device_attach(vi->dev);
 
-	if (!try_fill_recv(vi, GFP_KERNEL))
-		schedule_delayed_work(&vi->refill, 0);
+	for (i = 0; i < vi->total_queue_pairs; i++)
+		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+			schedule_delayed_work(&vi->rq[i].refill, 0);
 
 	mutex_lock(&vi->config_lock);
 	vi->config_enable = true;
@@ -1272,6 +1560,29 @@ static int virtnet_restore(struct virtio_device *vdev)
 
 	return 0;
 }
+
+#ifdef CONFIG_PM
+static int virtnet_freeze(struct virtio_device *vdev)
+{
+	struct virtnet_info *vi = vdev->priv;
+
+	virtnet_stop(vi);
+
+	remove_vq_common(vi);
+
+	flush_work(&vi->config_work);
+
+	return 0;
+}
+
+static int virtnet_restore(struct virtio_device *vdev)
+{
+	struct virtnet_info *vi = vdev->priv;
+
+	virtnet_start(vi);
+
+	return 0;
+}
 #endif
 
 static struct virtio_device_id id_table[] = {
@@ -1287,7 +1598,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
-	VIRTIO_NET_F_GUEST_ANNOUNCE,
+	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MULTIQUEUE,
 };
 
 static struct virtio_driver virtio_net_driver = {
@@ -1305,6 +1616,12 @@ static struct virtio_driver virtio_net_driver = {
 #endif
 };
 
+static const struct ethtool_ops virtnet_ethtool_ops = {
+	.get_drvinfo = virtnet_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_ringparam = virtnet_get_ringparam,
+};
+
 static int __init init(void)
 {
 	return register_virtio_driver(&virtio_net_driver);
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 1bc7e30..a43caeb 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -61,6 +61,8 @@ struct virtio_net_config {
 	__u8 mac[6];
 	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
 	__u16 status;
+	/* Total number of RX/TX queues */
+	__u16 max_virtqueue_pairs;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
@@ -167,4 +169,20 @@ struct virtio_net_ctrl_mac {
 #define VIRTIO_NET_CTRL_ANNOUNCE       3
  #define VIRTIO_NET_CTRL_ANNOUNCE_ACK         0
 
+/*
+ * Control multiqueue
+ *
+ */
+#define VIRTIO_NET_CTRL_STEERING       4
+ #define VIRTIO_NET_CTRL_STEERING_SET         0
+
+#define VIRTIO_NET_CTRL_STEERING_SINGLE 0
+#define VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX 1
+
+struct virtio_net_ctrl_steering {
+	u8 current_steering_rule;
+	u8 reserved;
+	u16 current_steering_param;
+};
+
 #endif /* _LINUX_VIRTIO_NET_H */
-- 
1.7.1
