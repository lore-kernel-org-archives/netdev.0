From: Xin Xiaohui <xiaohui.xin@intel.com>
Subject: [PATCH 3/3] Let host NIC driver to DMA to guest user space.
Date: Wed, 10 Feb 2010 19:49:00 +0800
Message-ID: <1265802540-6122-4-git-send-email-xiaohui.xin@intel.com>
References: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
 <1265802540-6122-2-git-send-email-xiaohui.xin@intel.com>
 <1265802540-6122-3-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>, Zhao Yu <yzhao81@gmail.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, mst@redhat.com,
	jdike@c2.user-mode-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51624 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321Ab0BJLsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 06:48:39 -0500
In-Reply-To: <1265802540-6122-3-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch let host NIC driver to receive user space skb,
then the driver has chance to directly DMA to guest user
space buffers thru single ethX interface.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Sigend-off-by: Jeff Dike <jdike@c2.user-mode-linux.org>
---
 include/linux/netdevice.h |   72 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/skbuff.h    |   32 ++++++++++++++++++--
 net/core/dev.c            |   27 +++++++++++++++++
 net/core/skbuff.c         |   62 +++++++++++++++++++++++++++++++++++----
 4 files changed, 184 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 94958c1..0de8688 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -486,6 +486,16 @@ struct netdev_queue {
 } ____cacheline_aligned_in_smp;
 
 
+struct netdev_page_ctor	{
+	int		hdr_len;
+	int		data_len;
+	int		npages;
+	unsigned	flags;
+	struct socket	*sock;
+	struct skb_user_page	*(*ctor)(struct netdev_page_ctor *,
+				struct sk_buff *, int);
+};
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -636,6 +646,8 @@ struct net_device_ops {
 	int			(*ndo_fcoe_ddp_done)(struct net_device *dev,
 						     u16 xid);
 #endif
+	int			(*ndo_page_ctor_prep)(struct net_device *dev,
+						struct netdev_page_ctor *ctor);
 };
 
 /*
@@ -916,6 +928,7 @@ struct net_device
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
+	struct netdev_page_ctor		*page_ctor;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -2013,6 +2026,65 @@ static inline u32 dev_ethtool_get_flags(struct net_device *dev)
 		return 0;
 	return dev->ethtool_ops->get_flags(dev);
 }
+
+static inline int netdev_page_ctor_prep(struct net_device *dev,
+		struct netdev_page_ctor *ctor)
+{
+	int rc;
+	int npages, data_len;
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	/* needed by packet split */
+	if (ops->ndo_page_ctor_prep) {
+		rc = ops->ndo_page_ctor_prep(dev, ctor);
+		if (rc)
+			return rc;
+	} else {  /* should be temp */
+		ctor->hdr_len = 128;
+		ctor->data_len = 2048;
+		ctor->npages = 1;
+	}
+
+	if (ctor->hdr_len <= 0)
+		goto err;
+
+	npages = ctor->npages;
+	data_len = ctor->data_len;
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
+static inline int netdev_page_ctor_attach(struct net_device *dev,
+		struct netdev_page_ctor *ctor)
+{
+	if (dev->flags & IFF_UP)
+		return -EBUSY;
+
+	if (rcu_dereference(dev->page_ctor))
+		return -EBUSY;
+
+	rcu_assign_pointer(dev->page_ctor, ctor);
+
+	return 0;
+}
+
+static inline void netdev_page_ctor_detach(struct net_device *dev)
+{
+	if (!rcu_dereference(dev->page_ctor))
+		return;
+
+	rcu_assign_pointer(dev->page_ctor, NULL);
+	synchronize_rcu();
+}
+
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_NETDEVICE_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index df7b23a..c77837e 100644
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
@@ -1509,6 +1517,24 @@ static inline void netdev_free_page(struct net_device *dev, struct page *page)
 	__free_page(page);
 }
 
+extern struct skb_user_page *netdev_alloc_user_pages(struct net_device *dev,
+			struct sk_buff *skb, int npages);
+
+extern int netdev_use_ps_feature(struct net_device *dev);
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
index b8f74cf..9d2c2ba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2265,6 +2265,27 @@ void netif_nit_deliver(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
+static inline struct sk_buff *handle_user_space_buf(struct sk_buff *skb,
+					struct packet_type **pt_prev,
+					int *ret, struct net_device *orig_dev)
+{
+	struct netdev_page_ctor *ctor = NULL;
+	struct sock *sk = NULL;
+
+	if (skb->dev)
+		ctor = skb->dev->page_ctor;
+	if (!ctor)
+		return skb;
+
+	sk = ctor->sock->sk;
+
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+
+	sk->sk_data_ready(sk, skb->len);
+	return NULL;
+}
+
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
@@ -2342,6 +2363,9 @@ int netif_receive_skb(struct sk_buff *skb)
 		goto out;
 ncls:
 #endif
+	skb = handle_user_space_buf(skb, &pt_prev, &ret, orig_dev);
+	if (!skb)
+		goto out;
 
 	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
@@ -2455,6 +2479,9 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	if (skb_is_gso(skb) || skb_has_frags(skb))
 		goto normal;
 
+	if (skb->dev && skb->dev->page_ctor)
+		goto normal;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
 		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 80a9616..40461d5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -170,12 +170,13 @@ EXPORT_SYMBOL(skb_under_panic);
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
+	struct skb_user_page *user = NULL;
 
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
 
@@ -185,8 +186,22 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		goto out;
 
 	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask, node);
+
+	if (!dev || !dev->page_ctor) { /* Legacy alloc func */
+		data = kmalloc_node_track_caller(
+				size + sizeof(struct skb_shared_info),
+				gfp_mask, node);
+	} else { /* Allocation may from page constructor of device */
+		user = netdev_alloc_user_page(dev, skb, size);
+		if (!user)
+			data = kmalloc_node_track_caller(
+				size + sizeof(struct skb_shared_info),
+				gfp_mask, node);
+		else {
+			data = user->start;
+			size = SKB_DATA_ALIGN(user->size);
+		}
+	}
 	if (!data)
 		goto nodata;
 
@@ -208,6 +223,10 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->mac_header = ~0U;
 #endif
 
+	if (user)
+		memcpy(user->ushinfo, skb_shinfo(skb),
+				sizeof(struct skb_shared_info));
+
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
@@ -231,6 +250,9 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
+
+	shinfo->destructor_arg = user;
+
 out:
 	return skb;
 nodata:
@@ -259,7 +281,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node, dev);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -278,6 +300,27 @@ struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(__netdev_alloc_page);
 
+struct skb_user_page *netdev_alloc_user_pages(struct net_device *dev,
+			struct sk_buff *skb, int npages)
+{
+	struct netdev_page_ctor *ctor;
+	struct skb_user_page *user = NULL;
+
+	rcu_read_lock();
+	ctor = rcu_dereference(dev->page_ctor);
+	if (!ctor)
+		goto out;
+
+	BUG_ON(npages > ctor->npages);
+
+	user = ctor->ctor(ctor, skb, npages);
+out:
+	rcu_read_unlock();
+
+	return user;
+}
+EXPORT_SYMBOL(netdev_alloc_user_pages);
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
@@ -338,6 +381,8 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 
 static void skb_release_data(struct sk_buff *skb)
 {
+	struct skb_user_page *user = skb_shinfo(skb)->destructor_arg;
+
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
@@ -349,7 +394,8 @@ static void skb_release_data(struct sk_buff *skb)
 
 		if (skb_has_frags(skb))
 			skb_drop_fraglist(skb);
-
+		if (skb->dev && skb->dev->page_ctor && user && user->dtor)
+			user->dtor(user);
 		kfree(skb->head);
 	}
 }
@@ -503,8 +549,12 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	if (skb_shared(skb) || skb_cloned(skb))
 		return 0;
 
-	skb_release_head_state(skb);
+	if (skb->dev && skb->dev->page_ctor)
+		return 0;
+
 	shinfo = skb_shinfo(skb);
+
+	skb_release_head_state(skb);
 	atomic_set(&shinfo->dataref, 1);
 	shinfo->nr_frags = 0;
 	shinfo->gso_size = 0;
-- 
1.5.4.4

