From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v5 16/19] Manipulate external buffers in mp device.
Date: Fri,  7 May 2010 17:35:03 +0800
Message-ID: <1273224906-4874-17-git-send-email-xiaohui.xin@intel.com>
References: <1273224906-4874-1-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-2-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-3-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-4-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-5-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-6-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-7-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-8-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-9-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-10-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-11-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-12-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-13-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-14-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-15-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-16-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45697 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755667Ab0EGJaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 05:30:18 -0400
In-Reply-To: <1273224906-4874-16-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

How external buffer comes from, how to destroy.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 drivers/vhost/mpassthru.c |  254 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 251 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
index 33cc123..8538a87 100644
--- a/drivers/vhost/mpassthru.c
+++ b/drivers/vhost/mpassthru.c
@@ -160,6 +160,39 @@ static int mp_dev_change_flags(struct net_device *dev, unsigned flags)
 	return ret;
 }
 
+/* The main function to allocate external buffers */
+static struct skb_external_page *page_ctor(struct mpassthru_port *port,
+		struct sk_buff *skb, int npages)
+{
+	int i;
+	unsigned long flags;
+	struct page_ctor *ctor;
+	struct page_info *info = NULL;
+
+	ctor = container_of(port, struct page_ctor, port);
+
+	spin_lock_irqsave(&ctor->read_lock, flags);
+	if (!list_empty(&ctor->readq)) {
+		info = list_first_entry(&ctor->readq, struct page_info, list);
+		list_del(&info->list);
+	}
+	spin_unlock_irqrestore(&ctor->read_lock, flags);
+	if (!info)
+		return NULL;
+
+	for (i = 0; i < info->pnum; i++) {
+		get_page(info->pages[i]);
+		info->frag[i].page = info->pages[i];
+		info->frag[i].page_offset = i ? 0 : info->offset;
+		info->frag[i].size = port->npages > 1 ? PAGE_SIZE :
+			port->data_len;
+	}
+	info->skb = skb;
+	info->ext_page.frags = info->frag;
+	info->ext_page.ushinfo = &info->ushinfo;
+	return &info->ext_page;
+}
+
 static int page_ctor_attach(struct mp_struct *mp)
 {
 	int rc;
@@ -192,7 +225,7 @@ static int page_ctor_attach(struct mp_struct *mp)
 
 	dev_hold(dev);
 	ctor->dev = dev;
-	ctor->port.ctor = NULL;
+	ctor->port.ctor = page_ctor;
 	ctor->port.sock = &mp->socket;
 	ctor->lock_pages = 0;
 	rc = netdev_mp_port_attach(dev, &ctor->port);
@@ -260,11 +293,66 @@ static int set_memlock_rlimit(struct page_ctor *ctor, int resource,
 	return 0;
 }
 
+static void relinquish_resource(struct page_ctor *ctor)
+{
+	if (!(ctor->dev->flags & IFF_UP) &&
+			!(ctor->wq_len + ctor->rq_len))
+		kmem_cache_destroy(ctor->cache);
+}
+
+static void mp_ki_dtor(struct kiocb *iocb)
+{
+	struct page_info *info = (struct page_info *)(iocb->private);
+	int i;
+
+	if (info->flags == INFO_READ) {
+		for (i = 0; i < info->pnum; i++) {
+			if (info->pages[i]) {
+				set_page_dirty_lock(info->pages[i]);
+				put_page(info->pages[i]);
+			}
+		}
+		info->skb->destructor = NULL;
+		kfree_skb(info->skb);
+		info->ctor->rq_len--;
+	} else
+		info->ctor->wq_len--;
+	/* Decrement the number of locked pages */
+	info->ctor->lock_pages -= info->pnum;
+	kmem_cache_free(info->ctor->cache, info);
+	relinquish_resource(info->ctor);
+
+	return;
+}
+
+static struct kiocb *create_iocb(struct page_info *info, int size)
+{
+	struct kiocb *iocb = NULL;
+
+	iocb = info->iocb;
+	if (!iocb)
+		return iocb;
+	iocb->ki_flags = 0;
+	iocb->ki_users = 1;
+	iocb->ki_key = 0;
+	iocb->ki_ctx = NULL;
+	iocb->ki_cancel = NULL;
+	iocb->ki_retry = NULL;
+	iocb->ki_iovec = NULL;
+	iocb->ki_eventfd = NULL;
+	iocb->ki_pos = info->desc_pos;
+	iocb->ki_nbytes = size;
+	iocb->ki_dtor(iocb);
+	iocb->private = (void *)info;
+	iocb->ki_dtor = mp_ki_dtor;
+
+	return iocb;
+}
+
 static int page_ctor_detach(struct mp_struct *mp)
 {
 	struct page_ctor *ctor;
 	struct page_info *info;
-	struct kiocb *iocb = NULL;
 	int i;
 
 	/* locked by mp_mutex */
@@ -276,12 +364,17 @@ static int page_ctor_detach(struct mp_struct *mp)
 		for (i = 0; i < info->pnum; i++)
 			if (info->pages[i])
 				put_page(info->pages[i]);
+		create_iocb(info, 0);
+		ctor->rq_len--;
 		kmem_cache_free(ctor->cache, info);
 	}
+
+	relinquish_resource(ctor);
+
 	set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
 			   ctor->o_rlim.rlim_cur,
 			   ctor->o_rlim.rlim_max);
-	kmem_cache_destroy(ctor->cache);
+
 	netdev_mp_port_detach(ctor->dev);
 	dev_put(ctor->dev);
 
@@ -329,6 +422,161 @@ static void mp_put(struct mp_file *mfile)
 		mp_detach(mfile->mp);
 }
 
+/* The callback to destruct the external buffers or skb */
+static void page_dtor(struct skb_external_page *ext_page)
+{
+	struct page_info *info;
+	struct page_ctor *ctor;
+	struct sock *sk;
+	struct sk_buff *skb;
+	struct kiocb *iocb = NULL;
+	unsigned long flags;
+
+	if (!ext_page)
+		return;
+	info = container_of(ext_page, struct page_info, ext_page);
+	if (!info)
+		return;
+	ctor = info->ctor;
+	skb = info->skb;
+
+	if ((info->flags == INFO_READ) && info->skb)
+		info->skb->head = NULL;
+
+	/* If the info->total is 0, make it to be reused */
+	if (!info->total) {
+		spin_lock_irqsave(&ctor->read_lock, flags);
+		list_add(&info->list, &ctor->readq);
+		spin_unlock_irqrestore(&ctor->read_lock, flags);
+		return;
+	}
+
+	if (info->flags == INFO_READ)
+		return;
+
+	/* For transmit, we should wait for the DMA finish by hardware.
+	 * Queue the notifier to wake up the backend driver
+	 */
+
+	iocb = create_iocb(info, info->total);
+
+	sk = ctor->port.sock->sk;
+	sk->sk_write_space(sk);
+
+	return;
+}
+
+/* For small exteranl buffers transmit, we don't need to call
+ * get_user_pages().
+ */
+static struct page_info *alloc_small_page_info(struct page_ctor *ctor,
+		struct kiocb *iocb, int total)
+{
+	struct page_info *info = kmem_cache_zalloc(ctor->cache, GFP_KERNEL);
+
+	if (!info)
+		return NULL;
+	info->total = total;
+	info->ext_page.dtor = page_dtor;
+	info->ctor = ctor;
+	info->flags = INFO_WRITE;
+	info->iocb = iocb;
+	return info;
+}
+
+/* The main function to transform the guest user space address
+ * to host kernel address via get_user_pages(). Thus the hardware
+ * can do DMA directly to the external buffer address.
+ */
+static struct page_info *alloc_page_info(struct page_ctor *ctor,
+		struct kiocb *iocb, struct iovec *iov,
+		int count, struct frag *frags,
+		int npages, int total)
+{
+	int rc;
+	int i, j, n = 0;
+	int len;
+	unsigned long base, lock_limit;
+	struct page_info *info = NULL;
+
+	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+	lock_limit >>= PAGE_SHIFT;
+
+	if (ctor->lock_pages + count > lock_limit) {
+		printk(KERN_INFO "exceed the locked memory rlimit.");
+		return NULL;
+	}
+
+	info = kmem_cache_zalloc(ctor->cache, GFP_KERNEL);
+
+	if (!info)
+		return NULL;
+
+	for (i = j = 0; i < count; i++) {
+		base = (unsigned long)iov[i].iov_base;
+		len = iov[i].iov_len;
+
+		if (!len)
+			continue;
+		n = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+
+		rc = get_user_pages_fast(base, n, npages ? 1 : 0,
+				&info->pages[j]);
+		if (rc != n)
+			goto failed;
+
+		while (n--) {
+			frags[j].offset = base & ~PAGE_MASK;
+			frags[j].size = min_t(int, len,
+					PAGE_SIZE - frags[j].offset);
+			len -= frags[j].size;
+			base += frags[j].size;
+			j++;
+		}
+	}
+
+#ifdef CONFIG_HIGHMEM
+	if (npages && !(dev->features & NETIF_F_HIGHDMA)) {
+		for (i = 0; i < j; i++) {
+			if (PageHighMem(info->pages[i]))
+				goto failed;
+		}
+	}
+#endif
+
+	info->total = total;
+	info->ext_page.dtor = page_dtor;
+	info->ctor = ctor;
+	info->pnum = j;
+	info->iocb = iocb;
+	if (!npages)
+		info->flags = INFO_WRITE;
+	if (info->flags == INFO_READ) {
+		info->ext_page.start = (u8 *)(((unsigned long)
+				(pfn_to_kaddr(page_to_pfn(info->pages[0]))) +
+				frags[0].offset));
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+		info->ext_page.size = SKB_DATA_ALIGN(
+				iov[0].iov_len + NET_IP_ALIGN + NET_SKB_PAD);
+#else
+		info->ext_page.size = SKB_DATA_ALIGN(
+				iov[0].iov_len + NET_IP_ALIGN + NET_SKB_PAD) -
+			NET_IP_ALIGN - NET_SKB_PAD;
+#endif
+	}
+	/* increment the number of locked pages */
+	ctor->lock_pages += j;
+	return info;
+
+failed:
+	for (i = 0; i < j; i++)
+		put_page(info->pages[i]);
+
+	kmem_cache_free(ctor->cache, info);
+
+	return NULL;
+}
+
 /* Ops structure to mimic raw sockets with mp device */
 static const struct proto_ops mp_socket_ops = {
 };
-- 
1.5.4.4

