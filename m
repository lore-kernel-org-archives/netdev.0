From: xiaohui.xin@intel.com
Subject: [RFC] [PATCH v2 3/3] Let host NIC driver to DMA to guest user space.
Date: Fri,  2 Apr 2010 15:30:10 +0800
Message-ID: <1270193410-6877-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, mst@redhat.com,
	jdike@c2.user-mode-linux.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53272 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759309Ab0DBH10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 03:27:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

The patch let host NIC driver to receive user space skb,
then the driver has chance to directly DMA to guest user
space buffers thru single ethX interface.
We want it to be more generic as a zero copy framework.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Sigend-off-by: Jeff Dike <jdike@c2.user-mode-linux.org>
---

We consider 2 way to utilize the user buffres, but not sure which one
is better. Please give any comments.

One:    Modify __alloc_skb() function a bit, it can only allocate a
        structure of sk_buff, and the data pointer is pointing to a
        user buffer which is coming from a page constructor API.
        Then the shinfo of the skb is also from guest.
        When packet is received from hardware, the skb->data is filled
        directly by h/w. What we have done is in this way.

        Pros:   We can avoid any copy here.
        Cons:   Guest virtio-net driver needs to allocate skb as almost
                the same method with the host NIC drivers, say the size
                of netdev_alloc_skb() and the same reserved space in the
                head of skb. Many NIC drivers are the same with guest and
                ok for this. But some lastest NIC drivers reserves special
                room in skb head. To deal with it, we suggest to provide
                a method in guest virtio-net driver to ask for parameter
                we interest from the NIC driver when we know which device
                we have bind to do zero-copy. Then we ask guest to do so.
                Is that reasonable?

Two:    Modify driver to get user buffer allocated from a page constructor
        API(to substitute alloc_page()), the user buffer are used as payload
        buffers and filled by h/w directly when packet is received. Driver
        should associate the pages with skb (skb_shinfo(skb)->frags). For
        the head buffer side, let host allocates skb, and h/w fills it.
        After that, the data filled in host skb header will be copied into
        guest header buffer which is submitted together with the payload buffer.

        Pros:   We could less care the way how guest or host allocates their
                buffers.
        Cons:   We still need a bit copy here for the skb header.

We are not sure which way is the better here. This is the first thing we want
to get comments from the community. We wish the modification to the network
part will be generic which not used by vhost-net backend only, but a user
application may use it as well when the zero-copy device may provides async
read/write operations later.


Thanks
Xiaohui

 include/linux/netdevice.h |   69 ++++++++++++++++++++++++++++++++++++++++-
 include/linux/skbuff.h    |   30 ++++++++++++++++--
 net/core/dev.c            |   63 ++++++++++++++++++++++++++++++++++++++
 net/core/skbuff.c         |   74 ++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 224 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 94958c1..ba48eb0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -485,6 +485,17 @@ struct netdev_queue {
 	unsigned long		tx_dropped;
 } ____cacheline_aligned_in_smp;
 
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+struct mpassthru_port	{
+	int		hdr_len;
+	int		data_len;
+	int		npages;
+	unsigned	flags;
+	struct socket	*sock;
+	struct skb_user_page	*(*ctor)(struct mpassthru_port *,
+				struct sk_buff *, int);
+};
+#endif
 
 /*
  * This structure defines the management hooks for network devices.
@@ -636,6 +647,10 @@ struct net_device_ops {
 	int			(*ndo_fcoe_ddp_done)(struct net_device *dev,
 						     u16 xid);
 #endif
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	int			(*ndo_mp_port_prep)(struct net_device *dev,
+						struct mpassthru_port *port);
+#endif
 };
 
 /*
@@ -891,7 +906,8 @@ struct net_device
 	struct macvlan_port	*macvlan_port;
 	/* GARP */
 	struct garp_port	*garp_port;
-
+	/* mpassthru */
+	struct mpassthru_port	*mp_port;
 	/* class/net/name entry */
 	struct device		dev;
 	/* space for optional statistics and wireless sysfs groups */
@@ -2013,6 +2029,55 @@ static inline u32 dev_ethtool_get_flags(struct net_device *dev)
 		return 0;
 	return dev->ethtool_ops->get_flags(dev);
 }
-#endif /* __KERNEL__ */
 
+/* To support zero-copy between user space application and NIC driver,
+ * we'd better ask NIC driver for the capability it can provide, especially
+ * for packet split mode, now we only ask for the header size, and the
+ * payload once a descriptor may carry.
+ */
+
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+static inline int netdev_mp_port_prep(struct net_device *dev,
+		struct mpassthru_port *port)
+{
+	int rc;
+	int npages, data_len;
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	/* needed by packet split */
+	if (ops->ndo_mp_port_prep) {
+		rc = ops->ndo_mp_port_prep(dev, port);
+		if (rc)
+			return rc;
+	} else {
+		/* If the NIC driver did not report this,
+		 * then we try to use it as igb driver.
+		 */
+		port->hdr_len = 128;
+		port->data_len = 2048;
+		port->npages = 1;
+	}
+
+	if (port->hdr_len <= 0)
+		goto err;
+
+	npages = port->npages;
+	data_len = port->data_len;
+	if (npages <= 0 || npages > MAX_SKB_FRAGS ||
+			(data_len < PAGE_SIZE * (npages - 1) ||
+			 data_len > PAGE_SIZE * npages))
+		goto err;
+
+	return 0;
+err:
+	dev_warn(&dev->dev, "invalid page constructor parameters\n");
+
+	return -EINVAL;
+}
+
+extern int netdev_mp_port_attach(struct net_device *dev,
+				struct mpassthru_port *port);
+extern void netdev_mp_port_detach(struct net_device *dev);
+#endif /* CONFIG_VHOST_PASSTHRU */
+#endif /* __KERNEL__ */
 #endif	/* _LINUX_NETDEVICE_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index df7b23a..e59fa57 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -209,6 +209,13 @@ struct skb_shared_info {
 	void *		destructor_arg;
 };
 
+struct skb_user_page {
+	u8              *start;
+	int             size;
+	struct skb_frag_struct *frags;
+	struct skb_shared_info *ushinfo;
+	void		(*dtor)(struct skb_user_page *);
+};
 /* We divide dataref into two halves.  The higher 16 bits hold references
  * to the payload part of skb->data.  The lower 16 bits hold references to
  * the entire skb->data.  A clone of a headerless skb holds the length of
@@ -441,17 +448,18 @@ extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone, int node);
+				   gfp_t priority, int fclone,
+				   int node, struct net_device *dev);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
-	return __alloc_skb(size, priority, 0, -1);
+	return __alloc_skb(size, priority, 0, -1, NULL);
 }
 
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, 1, -1, NULL);
 }
 
 extern int skb_recycle_check(struct sk_buff *skb, int skb_size);
@@ -1509,6 +1517,22 @@ static inline void netdev_free_page(struct net_device *dev, struct page *page)
 	__free_page(page);
 }
 
+extern struct skb_user_page *netdev_alloc_user_pages(struct net_device *dev,
+			struct sk_buff *skb, int npages);
+
+static inline struct skb_user_page *netdev_alloc_user_page(
+		struct net_device *dev,
+		struct sk_buff *skb, unsigned int size)
+{
+	struct skb_user_page *user;
+	int npages = (size < PAGE_SIZE) ? 1 : (size / PAGE_SIZE);
+
+	user = netdev_alloc_user_pages(dev, skb, npages);
+	if (likely(user))
+		return user;
+	return NULL;
+}
+
 /**
  *	skb_clone_writable - is the header of a clone writable
  *	@skb: buffer to check
diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..b50bdcb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2265,6 +2265,61 @@ void netif_nit_deliver(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
+/* Add a hook to intercept zero-copy packets, and insert it
+ * to the socket queue specially.
+ */
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+int netdev_mp_port_attach(struct net_device *dev,
+			struct mpassthru_port *port)
+{
+	/* locked by mp_mutex */
+	if (rcu_dereference(dev->mp_port))
+		return -EBUSY;
+
+	rcu_assign_pointer(dev->mp_port, port);
+
+	return 0;
+}
+EXPORT_SYMBOL(netdev_mp_port_attach);
+
+void netdev_mp_port_detach(struct net_device *dev)
+{
+	/* locked by mp_mutex */
+	if (!rcu_dereference(dev->mp_port))
+		return;
+
+	rcu_assign_pointer(dev->mp_port, NULL);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(netdev_mp_port_detach);
+
+static inline struct sk_buff *handle_mpassthru(struct sk_buff *skb,
+					struct packet_type **pt_prev,
+					int *ret, struct net_device *orig_dev)
+{
+	struct mpassthru_port *mp_port = NULL;
+	struct sock *sk = NULL;
+
+	if (skb->dev)
+		mp_port = skb->dev->mp_port;
+	if (!mp_port)
+		return skb;
+
+	if (*pt_prev) {
+		*ret = deliver_skb(skb, *pt_prev, orig_dev);
+		*pt_prev = NULL;
+	}
+
+	sk = mp_port->sock->sk;
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+	sk->sk_data_ready(sk, skb->len);
+
+	return NULL;
+}
+#else
+#define handle_mpassthru(skb, pt_prev, ret, orig_dev)      (skb)
+#endif
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
@@ -2342,6 +2397,9 @@ int netif_receive_skb(struct sk_buff *skb)
 		goto out;
 ncls:
 #endif
+	skb = handle_mpassthru(skb, &pt_prev, &ret, orig_dev);
+	if (!skb)
+		goto out;
 
 	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
@@ -2455,6 +2513,11 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	if (skb_is_gso(skb) || skb_has_frags(skb))
 		goto normal;
 
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	if (skb->dev && skb->dev->mp_port)
+		goto normal;
+#endif
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
 		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 80a9616..e684898 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -170,13 +170,15 @@ EXPORT_SYMBOL(skb_under_panic);
  *	%GFP_ATOMIC.
  */
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
-			    int fclone, int node)
+			    int fclone, int node, struct net_device *dev)
 {
 	struct kmem_cache *cache;
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	u8 *data;
-
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	struct skb_user_page *user = NULL;
+#endif
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
 
 	/* Get the HEAD */
@@ -185,8 +187,26 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		goto out;
 
 	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask, node);
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	if (!dev || !dev->mp_port) { /* Legacy alloc func */
+#endif
+		data = kmalloc_node_track_caller(
+				size + sizeof(struct skb_shared_info),
+				gfp_mask, node);
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	} else { /* Allocation may from page constructor of device */
+		user = netdev_alloc_user_page(dev, skb, size);
+		if (!user) {
+			data = kmalloc_node_track_caller(
+				size + sizeof(struct skb_shared_info),
+				gfp_mask, node);
+			printk(KERN_INFO "can't alloc user buffer.\n");
+		} else {
+			data = user->start;
+			size = SKB_DATA_ALIGN(user->size);
+		}
+	}
+#endif
 	if (!data)
 		goto nodata;
 
@@ -208,6 +228,11 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->mac_header = ~0U;
 #endif
 
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	if (user)
+		memcpy(user->ushinfo, skb_shinfo(skb),
+				sizeof(struct skb_shared_info));
+#endif
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
@@ -231,6 +256,10 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	shinfo->destructor_arg = user;
+#endif
+
 out:
 	return skb;
 nodata:
@@ -259,7 +288,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node, dev);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -278,6 +307,24 @@ struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(__netdev_alloc_page);
 
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+struct skb_user_page *netdev_alloc_user_pages(struct net_device *dev,
+			struct sk_buff *skb, int npages)
+{
+	struct mpassthru_port *ctor;
+	struct skb_user_page *user = NULL;
+
+	ctor = rcu_dereference(dev->mp_port);
+	if (!ctor)
+		goto out;
+	BUG_ON(npages > ctor->npages);
+	user = ctor->ctor(ctor, skb, npages);
+out:
+	return user;
+}
+EXPORT_SYMBOL(netdev_alloc_user_pages);
+#endif
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
@@ -338,6 +385,10 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 
 static void skb_release_data(struct sk_buff *skb)
 {
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	struct skb_user_page *user = skb_shinfo(skb)->destructor_arg;
+#endif
+
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
@@ -349,7 +400,10 @@ static void skb_release_data(struct sk_buff *skb)
 
 		if (skb_has_frags(skb))
 			skb_drop_fraglist(skb);
-
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+		if (skb->dev && skb->dev->mp_port && user && user->dtor)
+			user->dtor(user);
+#endif
 		kfree(skb->head);
 	}
 }
@@ -503,8 +557,14 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	if (skb_shared(skb) || skb_cloned(skb))
 		return 0;
 
-	skb_release_head_state(skb);
+#if defined(CONFIG_VHOST_PASSTHRU) || defined(CONFIG_VHOST_PASSTHRU_MODULE)
+	if (skb->dev && skb->dev->mp_port)
+		return 0;
+#endif
+
 	shinfo = skb_shinfo(skb);
+
+	skb_release_head_state(skb);
 	atomic_set(&shinfo->dataref, 1);
 	shinfo->nr_frags = 0;
 	shinfo->gso_size = 0;
-- 
1.5.4.4

