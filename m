From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v4 15/18] Manipulate external buffers in mp device.
Date: Sun, 25 Apr 2010 17:20:02 +0800
Message-ID: <1272187206-18534-15-git-send-email-xiaohui.xin@intel.com>
References: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-2-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-3-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-6-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-7-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-8-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-9-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-10-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-11-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-12-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-13-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-14-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272187206-18534-14-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

How external buffer comes from, how to destroy.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 drivers/vhost/mpassthru.c |  237 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 236 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
index c5ede17..b171f21 100644
--- a/drivers/vhost/mpassthru.c
+++ b/drivers/vhost/mpassthru.c
@@ -159,6 +159,39 @@ static int mp_dev_change_flags(struct net_device *dev, unsigned flags)
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
@@ -191,7 +224,7 @@ static int page_ctor_attach(struct mp_struct *mp)
 
 	dev_hold(dev);
 	ctor->dev = dev;
-	ctor->port.ctor = NULL;
+	ctor->port.ctor = page_ctor;
 	ctor->port.sock = &mp->socket;
 	ctor->lock_pages = 0;
 	rc = netdev_mp_port_attach(dev, &ctor->port);
@@ -258,6 +291,52 @@ static int set_memlock_rlimit(struct page_ctor *ctor, int resource,
 	task_unlock(current->group_leader);
 	return 0;
 }
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
+		skb_shinfo(info->skb)->destructor_arg = &info->ext_page;
+		info->skb->destructor = NULL;
+		kfree_skb(info->skb);
+	}
+	/* Decrement the number of locked pages */
+	info->ctor->lock_pages -= info->pnum;
+	kmem_cache_free(info->ctor->cache, info);
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
 
 static int page_ctor_detach(struct mp_struct *mp)
 {
@@ -275,6 +354,7 @@ static int page_ctor_detach(struct mp_struct *mp)
 		for (i = 0; i < info->pnum; i++)
 			if (info->pages[i])
 				put_page(info->pages[i]);
+		create_iocb(info, 0);
 		kmem_cache_free(ctor->cache, info);
 	}
 	set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
@@ -328,6 +408,161 @@ static void mp_put(struct mp_file *mfile)
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
