From: Gregory Haskins <ghaskins@novell.com>
Subject: [NET PATCH 9/9] venet: add Layer-4 Reassembler Offload (L4RO) support
Date: Wed, 14 Oct 2009 11:59:33 -0400
Message-ID: <20091014155932.18864.31726.stgit@dev.haskins.net>
References: <20091014154457.18864.28382.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761969AbZJNQKr@vger.kernel.org>
In-Reply-To: <20091014154457.18864.28382.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the converse to GSO.  It lets us receive fully reassembled L4
frames from the host.  This allows us to reduce the interrupt rate of
the guest, take advantage of host-based hardware that does reassembly,
and to skip the SAR overhead for localhost (host->guest, guest->guest)
connectivity.

We accomplish this by re-using the SG support from the transmit/GSO side
and supplying a "page-queue" of free pages to use for when we need
frames larger than MTU.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/vbus-enet.c |  384 +++++++++++++++++++++++++++++++++++++++++++----
 include/linux/venet.h   |   10 +
 2 files changed, 365 insertions(+), 29 deletions(-)

diff --git a/drivers/net/vbus-enet.c b/drivers/net/vbus-enet.c
index e8a0553..6fe2241 100644
--- a/drivers/net/vbus-enet.c
+++ b/drivers/net/vbus-enet.c
@@ -47,6 +47,8 @@ module_param(sg_enabled, int, 0444);
 
 #define PDEBUG(_dev, fmt, args...) dev_dbg(&(_dev)->dev, fmt, ## args)
 
+#define SG_DESC_SIZE VSG_DESC_SIZE(MAX_SKB_FRAGS)
+
 struct vbus_enet_queue {
 	struct ioq              *queue;
 	struct ioq_notifier      notifier;
@@ -78,6 +80,14 @@ struct vbus_enet_priv {
 		struct tasklet_struct  task;
 		char                  *pool;
 	} evq;
+	struct {
+		bool                   available;
+		char                  *pool;
+		struct vbus_enet_queue pageq;
+	} l4ro;
+
+	struct sk_buff *(*import)(struct vbus_enet_priv *priv,
+				  struct ioq_ring_desc *desc);
 };
 
 static void vbus_enet_tx_reap(struct vbus_enet_priv *priv);
@@ -127,29 +137,88 @@ devcall(struct vbus_enet_priv *priv, u32 func, void *data, size_t len)
  */
 
 static void
-rxdesc_alloc(struct net_device *dev, struct ioq_ring_desc *desc, size_t len)
+rxdesc_alloc(struct vbus_enet_priv *priv, struct ioq_ring_desc *desc, size_t len)
 {
+	struct net_device *dev = priv->dev;
 	struct sk_buff *skb;
 
 	len += ETH_HLEN;
 
-	skb = netdev_alloc_skb(dev, len + 2);
+	skb = netdev_alloc_skb(dev, len + NET_IP_ALIGN);
 	BUG_ON(!skb);
 
 	skb_reserve(skb, NET_IP_ALIGN); /* align IP on 16B boundary */
 
-	desc->cookie = (u64)skb;
-	desc->ptr    = (u64)__pa(skb->data);
-	desc->len    = len; /* total length  */
+	if (priv->l4ro.available) {
+		/*
+		 * We will populate an SG descriptor initially with one
+		 * IOV filled with an MTU SKB.  If the packet needs to be
+		 * larger than MTU, the host will grab pages out of the
+		 * page-queue and populate additional IOVs
+		 */
+		struct venet_sg *vsg = (struct venet_sg *)desc->cookie;
+		struct venet_iov *iov = &vsg->iov[0];
+
+		memset(vsg, 0, SG_DESC_SIZE);
+
+		vsg->cookie  = (u64)skb;
+		vsg->count   = 1;
+
+		iov->ptr     = (u64)__pa(skb->data);
+		iov->len     = len;
+	} else {
+		desc->cookie = (u64)skb;
+		desc->ptr    = (u64)__pa(skb->data);
+		desc->len    = len; /* total length  */
+	}
+
 	desc->valid  = 1;
 }
 
 static void
+rx_pageq_refill(struct vbus_enet_priv *priv)
+{
+	struct ioq *ioq = priv->l4ro.pageq.queue;
+	struct ioq_iterator iter;
+	int ret;
+
+	if (ioq_full(ioq, ioq_idxtype_inuse))
+		/* nothing to do if the pageq is already fully populated */
+		return;
+
+	ret = ioq_iter_init(ioq, &iter, ioq_idxtype_inuse, 0);
+	BUG_ON(ret < 0); /* will never fail unless seriously broken */
+
+	ret = ioq_iter_seek(&iter, ioq_seek_tail, 0, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * Now populate each descriptor with an empty page
+	 */
+	while (!iter.desc->sown) {
+		struct page *page;
+
+		page = alloc_page(GFP_KERNEL);
+		BUG_ON(!page);
+
+		iter.desc->cookie = (u64)page;
+		iter.desc->ptr    = (u64)__pa(page_address(page));
+		iter.desc->len    = PAGE_SIZE;
+
+		ret = ioq_iter_push(&iter, 0);
+		BUG_ON(ret < 0);
+	}
+
+	ioq_signal(ioq, 0);
+}
+
+static void
 rx_setup(struct vbus_enet_priv *priv)
 {
 	struct ioq *ioq = priv->rxq.queue;
 	struct ioq_iterator iter;
 	int ret;
+	int i = 0;
 
 	/*
 	 * We want to iterate on the "valid" index.  By default the iterator
@@ -170,10 +239,19 @@ rx_setup(struct vbus_enet_priv *priv)
 	BUG_ON(ret < 0);
 
 	/*
-	 * Now populate each descriptor with an empty SKB and mark it valid
+	 * Now populate each descriptor with an empty buffer and mark it valid
 	 */
 	while (!iter.desc->valid) {
-		rxdesc_alloc(priv->dev, iter.desc, priv->dev->mtu);
+		if (priv->l4ro.available) {
+			size_t offset = (i * SG_DESC_SIZE);
+			void *addr = &priv->l4ro.pool[offset];
+
+			iter.desc->ptr    = (u64)offset;
+			iter.desc->cookie = (u64)addr;
+			iter.desc->len    = SG_DESC_SIZE;
+		}
+
+		rxdesc_alloc(priv, iter.desc, priv->dev->mtu);
 
 		/*
 		 * This push operation will simultaneously advance the
@@ -182,11 +260,16 @@ rx_setup(struct vbus_enet_priv *priv)
 		 */
 		ret = ioq_iter_push(&iter, 0);
 		BUG_ON(ret < 0);
+
+		i++;
 	}
+
+	if (priv->l4ro.available)
+		rx_pageq_refill(priv);
 }
 
 static void
-rx_teardown(struct vbus_enet_priv *priv)
+rx_rxq_teardown(struct vbus_enet_priv *priv)
 {
 	struct ioq *ioq = priv->rxq.queue;
 	struct ioq_iterator iter;
@@ -202,7 +285,25 @@ rx_teardown(struct vbus_enet_priv *priv)
 	 * free each valid descriptor
 	 */
 	while (iter.desc->valid) {
-		struct sk_buff *skb = (struct sk_buff *)iter.desc->cookie;
+		struct sk_buff *skb;
+
+		if (priv->l4ro.available) {
+			struct venet_sg *vsg;
+			int i;
+
+			vsg = (struct venet_sg *)iter.desc->cookie;
+
+			/* skip i=0, since that is the skb->data IOV */
+			for (i = 1; i < vsg->count; i++) {
+				struct venet_iov *iov = &vsg->iov[i];
+				struct page *page = (struct page *)iov->ptr;
+
+				put_page(page);
+			}
+
+			skb = (struct sk_buff *)vsg->cookie;
+		} else
+			skb = (struct sk_buff *)iter.desc->cookie;
 
 		iter.desc->valid = 0;
 		wmb();
@@ -217,12 +318,54 @@ rx_teardown(struct vbus_enet_priv *priv)
 	}
 }
 
+static void
+rx_l4ro_teardown(struct vbus_enet_priv *priv)
+{
+	struct ioq *ioq = priv->l4ro.pageq.queue;
+	struct ioq_iterator iter;
+	int ret;
+
+	ret = ioq_iter_init(ioq, &iter, ioq_idxtype_inuse, 0);
+	BUG_ON(ret < 0);
+
+	ret = ioq_iter_seek(&iter, ioq_seek_head, 0, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * free each valid descriptor
+	 */
+	while (iter.desc->sown) {
+		struct page *page = (struct page *)iter.desc->cookie;
+
+		iter.desc->valid = 0;
+		wmb();
+
+		iter.desc->ptr = 0;
+		iter.desc->cookie = 0;
+
+		ret = ioq_iter_pop(&iter, 0);
+		BUG_ON(ret < 0);
+
+		put_page(page);
+	}
+
+	ioq_put(ioq);
+	kfree(priv->l4ro.pool);
+}
+
+static void
+rx_teardown(struct vbus_enet_priv *priv)
+{
+	rx_rxq_teardown(priv);
+
+	if (priv->l4ro.available)
+		rx_l4ro_teardown(priv);
+}
+
 static int
 tx_setup(struct vbus_enet_priv *priv)
 {
 	struct ioq *ioq    = priv->tx.veq.queue;
-	size_t      iovlen = sizeof(struct venet_iov) * (MAX_SKB_FRAGS-1);
-	size_t      len    = sizeof(struct venet_sg) + iovlen;
 	struct ioq_iterator iter;
 	int i;
 	int ret;
@@ -237,7 +380,7 @@ tx_setup(struct vbus_enet_priv *priv)
 	/* pre-allocate our descriptor pool if pmtd is enabled */
 	if (priv->pmtd.enabled) {
 		struct vbus_device_proxy *dev = priv->vdev;
-		size_t poollen = len * priv->tx.veq.count;
+		size_t poollen = SG_DESC_SIZE * priv->tx.veq.count;
 		char *pool;
 		int shmid;
 
@@ -270,12 +413,12 @@ tx_setup(struct vbus_enet_priv *priv)
 		struct venet_sg *vsg;
 
 		if (priv->pmtd.enabled) {
-			size_t offset = (i * len);
+			size_t offset = (i * SG_DESC_SIZE);
 
 			vsg = (struct venet_sg *)&priv->pmtd.pool[offset];
 			iter.desc->ptr = (u64)offset;
 		} else {
-			vsg = kzalloc(len, GFP_KERNEL);
+			vsg = kzalloc(SG_DESC_SIZE, GFP_KERNEL);
 			if (!vsg)
 				return -ENOMEM;
 
@@ -283,7 +426,7 @@ tx_setup(struct vbus_enet_priv *priv)
 		}
 
 		iter.desc->cookie = (u64)vsg;
-		iter.desc->len    = len;
+		iter.desc->len    = SG_DESC_SIZE;
 
 		ret = ioq_iter_seek(&iter, ioq_seek_next, 0, 0);
 		BUG_ON(ret < 0);
@@ -444,6 +587,120 @@ vbus_enet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static struct sk_buff *
+vbus_enet_l4ro_import(struct vbus_enet_priv *priv, struct ioq_ring_desc *desc)
+{
+	struct venet_sg *vsg = (struct venet_sg *)desc->cookie;
+	struct sk_buff *skb = (struct sk_buff *)vsg->cookie;
+	struct skb_shared_info *sinfo = skb_shinfo(skb);
+	int i;
+
+	rx_pageq_refill(priv);
+
+	if (!vsg->len)
+		/*
+		 * the device may send a zero-length packet when its
+		 * flushing references on the ring.  We can just drop
+		 * these on the floor
+		 */
+		goto fail;
+
+	/* advance only by the linear portion in IOV[0] */
+	skb_put(skb, vsg->iov[0].len);
+
+	/* skip i=0, since that is the skb->data IOV */
+	for (i = 1; i < vsg->count; i++) {
+		struct venet_iov *iov = &vsg->iov[i];
+		struct page *page = (struct page *)iov->ptr;
+		skb_frag_t *f = &sinfo->frags[i-1];
+
+		f->page        = page;
+		f->page_offset = 0;
+		f->size        = iov->len;
+
+		PDEBUG(priv->dev, "SG: Importing %d byte page[%i]\n",
+		       f->size, i);
+
+		skb->data_len += f->size;
+		skb->len      += f->size;
+		skb->truesize += f->size;
+		sinfo->nr_frags++;
+	}
+
+	if (vsg->flags & VENET_SG_FLAG_NEEDS_CSUM
+	    && !skb_partial_csum_set(skb, vsg->csum.start,
+				     vsg->csum.offset)) {
+		priv->dev->stats.rx_frame_errors++;
+		goto fail;
+	}
+
+	if (vsg->flags & VENET_SG_FLAG_GSO) {
+		PDEBUG(priv->dev, "L4RO packet detected\n");
+
+		switch (vsg->gso.type) {
+		case VENET_GSO_TYPE_TCPV4:
+			sinfo->gso_type = SKB_GSO_TCPV4;
+			break;
+		case VENET_GSO_TYPE_TCPV6:
+			sinfo->gso_type = SKB_GSO_TCPV6;
+			break;
+		case VENET_GSO_TYPE_UDP:
+			sinfo->gso_type = SKB_GSO_UDP;
+			break;
+		default:
+			PDEBUG(priv->dev, "Illegal L4RO type: %d\n",
+			       vsg->gso.type);
+			priv->dev->stats.rx_frame_errors++;
+			goto fail;
+		}
+
+		if (vsg->flags & VENET_SG_FLAG_ECN)
+			sinfo->gso_type |= SKB_GSO_TCP_ECN;
+
+		sinfo->gso_size = vsg->gso.size;
+		if (sinfo->gso_size == 0) {
+			PDEBUG(priv->dev, "Illegal L4RO size: %d\n",
+			       vsg->gso.size);
+			priv->dev->stats.rx_frame_errors++;
+			goto fail;
+		}
+
+		/*
+		 * Header must be checked, and gso_segs
+		 * computed.
+		 */
+		sinfo->gso_type |= SKB_GSO_DODGY;
+		sinfo->gso_segs = 0;
+	}
+
+	return skb;
+
+fail:
+	dev_kfree_skb(skb);
+
+	return NULL;
+}
+
+static struct sk_buff *
+vbus_enet_flat_import(struct vbus_enet_priv *priv, struct ioq_ring_desc *desc)
+{
+	struct sk_buff *skb = (struct sk_buff *)desc->cookie;
+
+	if (!desc->len) {
+		/*
+		 * the device may send a zero-length packet when its
+		 * flushing references on the ring.  We can just drop
+		 * these on the floor
+		 */
+		dev_kfree_skb(skb);
+		return NULL;
+	}
+
+	skb_put(skb, desc->len);
+
+	return skb;
+}
+
 /*
  * The poll implementation.
  */
@@ -471,15 +728,14 @@ vbus_enet_poll(struct napi_struct *napi, int budget)
 	 * the south side
 	 */
 	while ((npackets < budget) && (!iter.desc->sown)) {
-		struct sk_buff *skb = (struct sk_buff *)iter.desc->cookie;
-
-		if (iter.desc->len) {
-			skb_put(skb, iter.desc->len);
+		struct sk_buff *skb;
 
+		skb = priv->import(priv, iter.desc);
+		if (skb) {
 			/* Maintain stats */
 			npackets++;
 			priv->dev->stats.rx_packets++;
-			priv->dev->stats.rx_bytes += iter.desc->len;
+			priv->dev->stats.rx_bytes += skb->len;
 
 			/* Pass the buffer up to the stack */
 			skb->dev      = priv->dev;
@@ -487,16 +743,10 @@ vbus_enet_poll(struct napi_struct *napi, int budget)
 			netif_receive_skb(skb);
 
 			mb();
-		} else
-			/*
-			 * the device may send a zero-length packet when its
-			 * flushing references on the ring.  We can just drop
-			 * these on the floor
-			 */
-			dev_kfree_skb(skb);
+		}
 
 		/* Grab a new buffer to put in the ring */
-		rxdesc_alloc(priv->dev, iter.desc, priv->dev->mtu);
+		rxdesc_alloc(priv, iter.desc, priv->dev->mtu);
 
 		/* Advance the in-use tail */
 		ret = ioq_iter_pop(&iter, 0);
@@ -1014,6 +1264,69 @@ vbus_enet_evq_negcap(struct vbus_enet_priv *priv, unsigned long count)
 }
 
 static int
+vbus_enet_l4ro_negcap(struct vbus_enet_priv *priv, unsigned long count)
+{
+	struct venet_capabilities caps;
+	int ret;
+
+	memset(&caps, 0, sizeof(caps));
+
+	caps.gid = VENET_CAP_GROUP_L4RO;
+	caps.bits |= (VENET_CAP_SG|VENET_CAP_TSO4|VENET_CAP_TSO6
+		      |VENET_CAP_ECN);
+
+	ret = devcall(priv, VENET_FUNC_NEGCAP, &caps, sizeof(caps));
+	if (ret < 0) {
+		printk(KERN_ERR "Error negotiating L4RO: %d\n", ret);
+		return ret;
+	}
+
+	if (caps.bits & VENET_CAP_SG) {
+		struct vbus_device_proxy *dev = priv->vdev;
+		size_t                    poollen = SG_DESC_SIZE * count;
+		struct venet_l4ro_query    query;
+		char                     *pool;
+
+		memset(&query, 0, sizeof(query));
+
+		ret = devcall(priv, VENET_FUNC_L4ROQUERY, &query, sizeof(query));
+		if (ret < 0) {
+			printk(KERN_ERR "Error querying L4RO: %d\n", ret);
+			return ret;
+		}
+
+		pool = kzalloc(poollen, GFP_KERNEL | GFP_DMA);
+		if (!pool)
+			return -ENOMEM;
+
+		/*
+		 * pre-mapped descriptor pool
+		 */
+		ret = dev->ops->shm(dev, query.dpid, 0,
+				    pool, poollen, 0, NULL, 0);
+		if (ret < 0) {
+			printk(KERN_ERR "Error registering L4RO pool: %d\n",
+			       ret);
+			kfree(pool);
+			return ret;
+		}
+
+		/*
+		 * page-queue: contains a ring of arbitrary pages for
+		 * consumption by the host for when the SG::IOV count exceeds
+		 * one MTU frame.  All we need to do is keep it populated
+		 * with free pages.
+		 */
+		queue_init(priv, &priv->l4ro.pageq, query.pqid, count, NULL);
+
+		priv->l4ro.pool      = pool;
+		priv->l4ro.available = true;
+	}
+
+	return 0;
+}
+
+static int
 vbus_enet_negcap(struct vbus_enet_priv *priv)
 {
 	int ret;
@@ -1022,7 +1335,15 @@ vbus_enet_negcap(struct vbus_enet_priv *priv)
 	if (ret < 0)
 		return ret;
 
-	return vbus_enet_evq_negcap(priv, tx_ringlen);
+	ret = vbus_enet_evq_negcap(priv, tx_ringlen);
+	if (ret < 0)
+		return ret;
+
+	ret = vbus_enet_l4ro_negcap(priv, rx_ringlen);
+	if (ret < 0)
+		return ret;
+
+	return 0;
 }
 
 static int vbus_enet_set_tx_csum(struct net_device *dev, u32 data)
@@ -1088,6 +1409,11 @@ vbus_enet_probe(struct vbus_device_proxy *vdev)
 		goto out_free;
 	}
 
+	if (priv->l4ro.available)
+		priv->import = &vbus_enet_l4ro_import;
+	else
+		priv->import = &vbus_enet_flat_import;
+
 	skb_queue_head_init(&priv->tx.outstanding);
 
 	queue_init(priv, &priv->rxq, VENET_QUEUE_RX, rx_ringlen, rx_isr);
diff --git a/include/linux/venet.h b/include/linux/venet.h
index b6bfd91..0578d79 100644
--- a/include/linux/venet.h
+++ b/include/linux/venet.h
@@ -39,6 +39,7 @@ struct venet_capabilities {
 
 #define VENET_CAP_GROUP_SG     0
 #define VENET_CAP_GROUP_EVENTQ 1
+#define VENET_CAP_GROUP_L4RO    2 /* layer-4 reassem offloading */
 
 /* CAPABILITIES-GROUP SG */
 #define VENET_CAP_SG     (1 << 0)
@@ -109,6 +110,14 @@ struct venet_event_txc {
 	__u64                     cookie;
 };
 
+struct venet_l4ro_query {
+	__u32 flags;
+	__u32 dpid;    /* descriptor pool-id */
+	__u32 pqid;    /* page queue-id */
+	__u8  pad[20];
+};
+
+
 #define VSG_DESC_SIZE(count) (sizeof(struct venet_sg) + \
 			      sizeof(struct venet_iov) * ((count) - 1))
 
@@ -119,5 +128,6 @@ struct venet_event_txc {
 #define VENET_FUNC_FLUSHRX   4
 #define VENET_FUNC_PMTDQUERY 5
 #define VENET_FUNC_EVQQUERY  6
+#define VENET_FUNC_L4ROQUERY  7
 
 #endif /* _LINUX_VENET_H */
