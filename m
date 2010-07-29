From: xiaohui.xin@intel.com
Subject: [RFC PATCH v8 12/16] Add mp(mediate passthru) device.
Date: Thu, 29 Jul 2010 19:14:45 +0800
Message-ID: <1280402088-5849-14-git-send-email-xiaohui.xin@intel.com>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-2-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-3-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-4-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-5-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-6-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-7-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-8-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-9-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-10-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-11-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-12-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-13-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1280402088-5849-13-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

The patch add mp(mediate passthru) device, which now
based on vhost-net backend driver and provides proto_ops
to send/receive guest buffers data from/to guest vitio-net
driver.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 drivers/vhost/mpassthru.c | 1394 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 1394 insertions(+), 0 deletions(-)
 create mode 100644 drivers/vhost/mpassthru.c

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
new file mode 100644
index 0000000..012ebda
--- /dev/null
+++ b/drivers/vhost/mpassthru.c
@@ -0,0 +1,1394 @@
+/*
+ *  MPASSTHRU - Mediate passthrough device.
+ *  Copyright (C) 2009 ZhaoYu, XinXiaohui, Dike, Jeffery G
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ *  GNU General Public License for more details.
+ *
+ */
+
+#define DRV_NAME        "mpassthru"
+#define DRV_DESCRIPTION "Mediate passthru device driver"
+#define DRV_COPYRIGHT   "(C) 2009 ZhaoYu, XinXiaohui, Dike, Jeffery G"
+
+#include <linux/compat.h>
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/major.h>
+#include <linux/slab.h>
+#include <linux/smp_lock.h>
+#include <linux/poll.h>
+#include <linux/fcntl.h>
+#include <linux/init.h>
+#include <linux/aio.h>
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/miscdevice.h>
+#include <linux/ethtool.h>
+#include <linux/rtnetlink.h>
+#include <linux/if.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/crc32.h>
+#include <linux/nsproxy.h>
+#include <linux/uaccess.h>
+#include <linux/virtio_net.h>
+#include <linux/mpassthru.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/rtnetlink.h>
+#include <net/sock.h>
+
+#include <asm/system.h>
+
+/* Uncomment to enable debugging */
+/* #define MPASSTHRU_DEBUG 1 */
+
+#ifdef MPASSTHRU_DEBUG
+static int debug;
+
+#define DBG  if (mp->debug) printk
+#define DBG1 if (debug == 2) printk
+#else
+#define DBG(a...)
+#define DBG1(a...)
+#endif
+
+#define COPY_THRESHOLD (L1_CACHE_BYTES * 4)
+#define COPY_HDR_LEN   (L1_CACHE_BYTES < 64 ? 64 : L1_CACHE_BYTES)
+
+struct frag {
+	u16     offset;
+	u16     size;
+};
+
+#define	HASH_BUCKETS	(8192*2)
+
+struct page_info {
+	struct list_head        list;
+	struct page_info	*next;
+	struct page_info	*prev;
+	int                     header;
+	/* indicate the actual length of bytes
+	 * send/recv in the external buffers
+	 */
+	int                     total;
+	int                     offset;
+	struct page             *pages[MAX_SKB_FRAGS+1];
+	struct skb_frag_struct  frag[MAX_SKB_FRAGS+1];
+	struct sk_buff          *skb;
+	struct page_ctor        *ctor;
+
+	/* The pointer relayed to skb, to indicate
+	 * it's a external allocated skb or kernel
+	 */
+	struct skb_ext_page    ext_page;
+	struct skb_shared_info  ushinfo;
+
+#define INFO_READ                      0
+#define INFO_WRITE                     1
+	unsigned                flags;
+	unsigned                pnum;
+
+	/* It's meaningful for receive, means
+	 * the max length allowed
+	 */
+	size_t                  len;
+
+	/* The fields after that is for backend
+	 * driver, now for vhost-net.
+	 */
+
+	struct kiocb            *iocb;
+	unsigned int            desc_pos;
+	struct iovec            hdr[MAX_SKB_FRAGS + 2];
+	struct iovec            iov[MAX_SKB_FRAGS + 2];
+};
+
+static struct kmem_cache *ext_page_info_cache;
+
+struct page_ctor {
+	struct list_head        readq;
+	int			wq_len;
+	int			rq_len;
+	spinlock_t		read_lock;
+	/* record the locked pages */
+	int			lock_pages;
+	struct rlimit		o_rlim;
+	struct net_device	*dev;
+	struct mpassthru_port	port;
+	struct page_info	**hash_table;
+};
+
+struct mp_struct {
+	struct mp_file		*mfile;
+	struct net_device       *dev;
+	struct page_ctor	*ctor;
+	struct socket           socket;
+
+#ifdef MPASSTHRU_DEBUG
+	int debug;
+#endif
+};
+
+struct mp_file {
+	atomic_t count;
+	struct mp_struct *mp;
+	struct net *net;
+};
+
+struct mp_sock {
+	struct sock		sk;
+	struct mp_struct	*mp;
+};
+
+static int mp_dev_change_flags(struct net_device *dev, unsigned flags)
+{
+	int ret = 0;
+
+	rtnl_lock();
+	ret = dev_change_flags(dev, flags);
+	rtnl_unlock();
+
+	if (ret < 0)
+		printk(KERN_ERR "failed to change dev state of %s", dev->name);
+
+	return ret;
+}
+
+/* The main function to allocate external buffers */
+static struct skb_ext_page *page_ctor(struct mpassthru_port *port,
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
+		ctor->rq_len--;
+	}
+	spin_unlock_irqrestore(&ctor->read_lock, flags);
+	if (!info)
+		return NULL;
+
+	for (i = 0; i < info->pnum; i++)
+		get_page(info->pages[i]);
+	info->skb = skb;
+	return &info->ext_page;
+}
+
+static struct page_info *mp_hash_lookup(struct page_ctor *ctor,
+					struct page *page);
+
+static struct skb_ext_page *mp_lookup(struct net_device *dev,
+				      struct page *page)
+{
+	struct mp_struct *mp =
+		container_of(dev->mp_port->sock->sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor = mp->ctor;
+	struct page_info *info;
+
+	info = mp_hash_lookup(ctor, page);
+	if (!info)
+		return NULL;
+	return &info->ext_page;
+}
+
+static int page_ctor_attach(struct mp_struct *mp)
+{
+	int rc;
+	struct page_ctor *ctor;
+	struct net_device *dev = mp->dev;
+
+	/* locked by mp_mutex */
+	if (mp->ctor)
+		return -EBUSY;
+
+	ctor = kzalloc(sizeof(*ctor), GFP_KERNEL);
+	if (!ctor)
+		return -ENOMEM;
+	rc = netdev_mp_port_prep(dev, &ctor->port);
+	if (rc)
+		goto fail;
+
+	INIT_LIST_HEAD(&ctor->readq);
+	spin_lock_init(&ctor->read_lock);
+	ctor->hash_table = kzalloc(sizeof(struct page_info *) * HASH_BUCKETS,
+			GFP_KERNEL);
+	if (!ctor->hash_table)
+		goto fail_hash;
+
+	ctor->rq_len = 0;
+	ctor->wq_len = 0;
+
+	dev_hold(dev);
+	ctor->dev = dev;
+	ctor->port.ctor = page_ctor;
+	ctor->port.sock = &mp->socket;
+	ctor->port.hash = mp_lookup;
+	ctor->lock_pages = 0;
+
+	/* locked by mp_mutex */
+	dev->mp_port = &ctor->port;
+	mp->ctor = ctor;
+
+	return 0;
+
+fail_hash:
+	kfree(ctor->hash_table);
+
+fail:
+	kfree(ctor);
+	dev_put(dev);
+
+	return rc;
+}
+
+struct page_info *info_dequeue(struct page_ctor *ctor)
+{
+	unsigned long flags;
+	struct page_info *info = NULL;
+	spin_lock_irqsave(&ctor->read_lock, flags);
+	if (!list_empty(&ctor->readq)) {
+		info = list_first_entry(&ctor->readq,
+				struct page_info, list);
+		list_del(&info->list);
+		ctor->rq_len--;
+	}
+	spin_unlock_irqrestore(&ctor->read_lock, flags);
+	return info;
+}
+
+static int set_memlock_rlimit(struct page_ctor *ctor, int resource,
+			      unsigned long cur, unsigned long max)
+{
+	struct rlimit new_rlim, *old_rlim;
+	int retval;
+
+	if (resource != RLIMIT_MEMLOCK)
+		return -EINVAL;
+	new_rlim.rlim_cur = cur;
+	new_rlim.rlim_max = max;
+
+	old_rlim = current->signal->rlim + resource;
+
+	/* remember the old rlimit value when backend enabled */
+	ctor->o_rlim.rlim_cur = old_rlim->rlim_cur;
+	ctor->o_rlim.rlim_max = old_rlim->rlim_max;
+
+	if ((new_rlim.rlim_max > old_rlim->rlim_max) &&
+			!capable(CAP_SYS_RESOURCE))
+		return -EPERM;
+
+	retval = security_task_setrlimit(resource, &new_rlim);
+	if (retval)
+		return retval;
+
+	task_lock(current->group_leader);
+	*old_rlim = new_rlim;
+	task_unlock(current->group_leader);
+	return 0;
+}
+
+static void relinquish_resource(struct page_ctor *ctor)
+{
+	if (!(ctor->dev->flags & IFF_UP) &&
+			!(ctor->wq_len + ctor->rq_len))
+		printk(KERN_INFO "relinquish_resource\n");
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
+		if (info->skb) {
+			info->skb->destructor = NULL;
+			kfree_skb(info->skb);
+		}
+		info->ctor->rq_len--;
+	} else
+		info->ctor->wq_len--;
+	/* Decrement the number of locked pages */
+	info->ctor->lock_pages -= info->pnum;
+	kmem_cache_free(ext_page_info_cache, info);
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
+static int page_ctor_detach(struct mp_struct *mp)
+{
+	struct page_ctor *ctor;
+	struct page_info *info;
+	int i;
+
+	/* locked by mp_mutex */
+	ctor = mp->ctor;
+	if (!ctor)
+		return -ENODEV;
+
+	while ((info = info_dequeue(ctor))) {
+		for (i = 0; i < info->pnum; i++)
+			if (info->pages[i])
+				put_page(info->pages[i]);
+		create_iocb(info, 0);
+		ctor->rq_len--;
+		kmem_cache_free(ext_page_info_cache, info);
+	}
+
+	relinquish_resource(ctor);
+
+	set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
+			   ctor->o_rlim.rlim_cur,
+			   ctor->o_rlim.rlim_max);
+
+	/* locked by mp_mutex */
+	ctor->dev->mp_port = NULL;
+	dev_put(ctor->dev);
+
+	mp->ctor = NULL;
+	kfree(ctor->hash_table);
+	kfree(ctor);
+	return 0;
+}
+
+static void __mp_detach(struct mp_struct *mp)
+{
+	mp->mfile = NULL;
+
+	mp_dev_change_flags(mp->dev, mp->dev->flags & ~IFF_UP);
+	page_ctor_detach(mp);
+	mp_dev_change_flags(mp->dev, mp->dev->flags | IFF_UP);
+
+	/* Drop the extra count on the net device */
+	dev_put(mp->dev);
+}
+
+static DEFINE_MUTEX(mp_mutex);
+
+static void mp_detach(struct mp_struct *mp)
+{
+	mutex_lock(&mp_mutex);
+	__mp_detach(mp);
+	mutex_unlock(&mp_mutex);
+}
+
+static struct mp_struct *mp_get(struct mp_file *mfile)
+{
+	struct mp_struct *mp = NULL;
+	if (atomic_inc_not_zero(&mfile->count))
+		mp = mfile->mp;
+
+	return mp;
+}
+
+static void mp_put(struct mp_file *mfile)
+{
+	if (atomic_dec_and_test(&mfile->count))
+		mp_detach(mfile->mp);
+}
+
+static void iocb_tag(struct kiocb *iocb)
+{
+	iocb->ki_flags = 1;
+}
+
+/* The callback to destruct the external buffers or skb */
+static void page_dtor(struct skb_ext_page *ext_page)
+{
+	struct page_info *info;
+	struct page_ctor *ctor;
+	struct sock *sk;
+	struct sk_buff *skb;
+
+	if (!ext_page)
+		return;
+	info = container_of(ext_page, struct page_info, ext_page);
+	if (!info)
+		return;
+	ctor = info->ctor;
+	skb = info->skb;
+
+	if (info->flags == INFO_READ) {
+		create_iocb(info, 0);
+		return;
+	}
+
+	/* For transmit, we should wait for the DMA finish by hardware.
+	 * Queue the notifier to wake up the backend driver
+	 */
+
+	iocb_tag(info->iocb);
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
+	struct page_info *info =
+		kmem_cache_zalloc(ext_page_info_cache, GFP_KERNEL);
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
+typedef u32 key_mp_t;
+static inline key_mp_t mp_hash(struct page *page, int buckets)
+{
+	key_mp_t k;
+
+	k = ((((unsigned long)page << 32UL) >> 32UL) / 0x38) % buckets ;
+	return k;
+}
+
+static void mp_hash_insert(struct page_ctor *ctor,
+		struct page *page, struct page_info *page_info)
+{
+	struct page_info *tmp;
+	key_mp_t key = mp_hash(page, HASH_BUCKETS);
+	if (!ctor->hash_table[key]) {
+		ctor->hash_table[key] = page_info;
+		return;
+	}
+
+	tmp = ctor->hash_table[key];
+	while (tmp->next)
+		tmp = tmp->next;
+
+	tmp->next = page_info;
+	page_info->prev = tmp;
+	return;
+}
+
+static struct page_info *mp_hash_lookup(struct page_ctor *ctor,
+					struct page *page)
+{
+	key_mp_t key = mp_hash(page, HASH_BUCKETS);
+	struct page_info *tmp = NULL;
+	int i;
+
+	tmp = ctor->hash_table[key];
+	while (tmp) {
+		for (i = 0; i < tmp->pnum; i++) {
+			if (tmp->pages[i] == page) {
+				if (!tmp->prev) {
+					ctor->hash_table[key] = tmp->next;
+					if (tmp->next)
+						tmp->next->prev = NULL;
+				} else {
+					tmp->prev->next = tmp->next;
+					if (tmp->next)
+						tmp->next->prev = tmp->prev;
+				}
+				return tmp;
+			}
+		}
+		tmp = tmp->next;
+	}
+	return tmp;
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
+	if (ctor->lock_pages + count > lock_limit && npages) {
+		printk(KERN_INFO "exceed the locked memory rlimit.");
+		return NULL;
+	}
+
+	info = kmem_cache_zalloc(ext_page_info_cache, GFP_KERNEL);
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
+	info->ext_page.page = info->pages[0];
+	info->ctor = ctor;
+	info->pnum = j;
+	info->iocb = iocb;
+	if (!npages)
+		info->flags = INFO_WRITE;
+	if (info->flags == INFO_READ) {
+		if (frags[0].offset == 0 && iocb->ki_iovec[0].iov_len) {
+			frags[0].offset = iocb->ki_iovec[0].iov_len;
+			ctor->port.vnet_hlen = iocb->ki_iovec[0].iov_len;
+		}
+		for (i = 0; i < j; i++)
+			mp_hash_insert(ctor, info->pages[i], info);
+	}
+	/* increment the number of locked pages */
+	ctor->lock_pages += j;
+	return info;
+
+failed:
+	for (i = 0; i < j; i++)
+		put_page(info->pages[i]);
+
+	kmem_cache_free(ext_page_info_cache, info);
+
+	return NULL;
+}
+
+static void mp_sock_destruct(struct sock *sk)
+{
+	struct mp_struct *mp = container_of(sk, struct mp_sock, sk)->mp;
+	kfree(mp);
+}
+
+static void mp_sock_state_change(struct sock *sk)
+{
+	if (sk_has_sleeper(sk))
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN);
+}
+
+static void mp_sock_write_space(struct sock *sk)
+{
+	if (sk_has_sleeper(sk))
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT);
+}
+
+static void mp_sock_data_ready(struct sock *sk, int coming)
+{
+	struct mp_struct *mp = container_of(sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor = NULL;
+	struct sk_buff *skb = NULL;
+	struct page_info *info = NULL;
+	int len;
+
+	struct virtio_net_hdr_mrg_rxbuf hdr = {
+		.hdr.flags = 0,
+		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
+	};
+
+	ctor = mp->ctor;
+	if (!ctor)
+		return;
+
+	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
+		struct page *page;
+		int off;
+		int size = 0, i = 0;
+		struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			DBG(KERN_INFO "csum %d\n", skb->ip_summed);
+
+		if (shinfo->nr_frags)
+			hdr.num_buffers = shinfo->nr_frags;
+		else
+			goto clean;
+
+		info = mp_hash_lookup(ctor, shinfo->frags[0].page);
+
+		skb_push(skb, ETH_HLEN);
+
+		if (skb_is_gso(skb)) {
+			hdr.hdr.hdr_len = skb_headlen(skb);
+			hdr.hdr.gso_size = shinfo->gso_size;
+			if (shinfo->gso_type & SKB_GSO_TCPV4)
+				hdr.hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+			else if (shinfo->gso_type & SKB_GSO_TCPV6)
+				hdr.hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (shinfo->gso_type & SKB_GSO_UDP)
+				hdr.hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
+			else
+				BUG();
+			if (shinfo->gso_type & SKB_GSO_TCP_ECN)
+				hdr.hdr.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+
+		} else
+			hdr.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			hdr.hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+			hdr.hdr.csum_start =
+				skb->csum_start - skb_headroom(skb);
+			hdr.hdr.csum_offset = skb->csum_offset;
+		}
+
+		info->skb = NULL;
+		off = info->hdr[0].iov_len;
+		len = memcpy_toiovec(info->iov, (unsigned char *)&hdr, off);
+		if (len) {
+			DBG(KERN_INFO
+				"Unable to write vnet_hdr at addr %p: %d\n",
+				info->iov_base, len);
+			goto clean;
+		}
+
+		memcpy_toiovec(info->iov, skb->data, skb_headlen(skb));
+
+		info->iocb->ki_left = hdr.num_buffers;
+		size = shinfo->frags[0].size +
+			shinfo->frags[0].page_offset - off;
+
+		create_iocb(info, off + size);
+
+		if (shinfo->nr_frags == 1)
+			info->skb = skb;
+		for (i = 1; i < shinfo->nr_frags; i++) {
+			page = shinfo->frags[i].page;
+			info = mp_hash_lookup(ctor, shinfo->frags[i].page);
+			info->skb = NULL;
+			create_iocb(info, shinfo->frags[i].size);
+			if (i == shinfo->nr_frags - 1)
+				info->skb = skb;
+		}
+
+		shinfo->nr_frags = 0;
+		shinfo->destructor_arg = NULL;
+		continue;
+clean:
+		kfree_skb(skb);
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		kmem_cache_free(ext_page_info_cache, info);
+	}
+	return;
+}
+
+static inline struct sk_buff *mp_alloc_skb(struct sock *sk, size_t prepad,
+					   size_t len, size_t linear,
+					   int noblock, int *err)
+{
+	struct sk_buff *skb;
+
+	/* Under a page?  Don't bother with paged skb. */
+	if (prepad + len < PAGE_SIZE || !linear)
+		linear = len;
+
+	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
+			err);
+	if (!skb)
+		return NULL;
+
+	skb_reserve(skb, prepad);
+	skb_put(skb, linear);
+	skb->data_len = len - linear;
+	skb->len += len - linear;
+
+	return skb;
+}
+
+static int mp_skb_from_vnet_hdr(struct sk_buff *skb,
+		struct virtio_net_hdr *vnet_hdr)
+{
+	unsigned short gso_type = 0;
+	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		switch (vnet_hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+		case VIRTIO_NET_HDR_GSO_TCPV4:
+			gso_type = SKB_GSO_TCPV4;
+			break;
+		case VIRTIO_NET_HDR_GSO_TCPV6:
+			gso_type = SKB_GSO_TCPV6;
+			break;
+		case VIRTIO_NET_HDR_GSO_UDP:
+			gso_type = SKB_GSO_UDP;
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		if (vnet_hdr->gso_type & VIRTIO_NET_HDR_GSO_ECN)
+			gso_type |= SKB_GSO_TCP_ECN;
+
+		if (vnet_hdr->gso_size == 0)
+			return -EINVAL;
+	}
+
+	if (vnet_hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+		if (!skb_partial_csum_set(skb, vnet_hdr->csum_start,
+					vnet_hdr->csum_offset))
+			return -EINVAL;
+	}
+
+	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		skb_shinfo(skb)->gso_size = vnet_hdr->gso_size;
+		skb_shinfo(skb)->gso_type = gso_type;
+
+		/* Header must be checked, and gso_segs computed. */
+		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+		skb_shinfo(skb)->gso_segs = 0;
+	}
+	return 0;
+}
+
+static int mp_sendmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *m, size_t total_len)
+{
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct virtio_net_hdr vnet_hdr = {0};
+	int hdr_len = 0;
+	struct page_ctor *ctor;
+	struct iovec *iov = m->msg_iov;
+	struct page_info *info = NULL;
+	struct frag frags[MAX_SKB_FRAGS];
+	struct sk_buff *skb;
+	int count = m->msg_iovlen;
+	int total = 0, header, n, i, len, rc;
+	unsigned long base;
+
+	ctor = mp->ctor;
+	if (!ctor)
+		return -ENODEV;
+
+	total = iov_length(iov, count);
+
+	if (total < ETH_HLEN)
+		return -EINVAL;
+
+	if (total <= COPY_THRESHOLD)
+		goto copy;
+
+	n = 0;
+	for (i = 0; i < count; i++) {
+		base = (unsigned long)iov[i].iov_base;
+		len = iov[i].iov_len;
+		if (!len)
+			continue;
+		n += ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+		if (n > MAX_SKB_FRAGS)
+			return -EINVAL;
+	}
+
+copy:
+	hdr_len = sizeof(vnet_hdr);
+	if ((total - iocb->ki_iovec[0].iov_len) < 0)
+		return -EINVAL;
+
+	rc = memcpy_fromiovecend((void *)&vnet_hdr, iocb->ki_iovec, 0, hdr_len);
+	if (rc < 0)
+		return -EINVAL;
+
+	if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
+			vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 >
+			vnet_hdr.hdr_len)
+		vnet_hdr.hdr_len = vnet_hdr.csum_start +
+			vnet_hdr.csum_offset + 2;
+
+	if (vnet_hdr.hdr_len > total)
+		return -EINVAL;
+
+	header = total > COPY_THRESHOLD ? COPY_HDR_LEN : total;
+
+	skb = mp_alloc_skb(sock->sk, NET_IP_ALIGN, header,
+			   iocb->ki_iovec[0].iov_len, 1, &rc);
+
+	if (!skb)
+		goto drop;
+
+	skb_set_network_header(skb, ETH_HLEN);
+	memcpy_fromiovec(skb->data, iov, header);
+
+	skb_reset_mac_header(skb);
+	skb->protocol = eth_hdr(skb)->h_proto;
+
+	rc = mp_skb_from_vnet_hdr(skb, &vnet_hdr);
+	if (rc)
+		goto drop;
+
+	if (header == total) {
+		rc = total;
+		info = alloc_small_page_info(ctor, iocb, total);
+	} else {
+		info = alloc_page_info(ctor, iocb, iov, count, frags, 0, total);
+		if (info)
+			for (i = 0; info->pages[i]; i++) {
+				skb_add_rx_frag(skb, i, info->pages[i],
+						frags[i].offset, frags[i].size);
+				info->pages[i] = NULL;
+			}
+	}
+	if (info != NULL) {
+		info->desc_pos = iocb->ki_pos;
+		info->total = total;
+		info->skb = skb;
+		skb_shinfo(skb)->destructor_arg = &info->ext_page;
+		skb->dev = mp->dev;
+		ctor->wq_len++;
+		create_iocb(info, info->total);
+		dev_queue_xmit(skb);
+		if (!ctor->rq_len)
+			sock->sk->sk_state_change(sock->sk);
+		return 0;
+	}
+drop:
+	kfree_skb(skb);
+	if (info) {
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		kmem_cache_free(ext_page_info_cache, info);
+	}
+	mp->dev->stats.tx_dropped++;
+	return -ENOMEM;
+}
+
+static int mp_recvmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *m, size_t total_len,
+		int flags)
+{
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor;
+	struct iovec *iov = m->msg_iov;
+	int count = m->msg_iovlen;
+	int npages, payload;
+	struct page_info *info;
+	struct frag frags[MAX_SKB_FRAGS];
+	unsigned long base;
+	int i, len;
+	unsigned long flag;
+
+	if (!(flags & MSG_DONTWAIT))
+		return -EINVAL;
+
+	ctor = mp->ctor;
+	if (!ctor)
+		return -EINVAL;
+
+	/* Error detections in case invalid external buffer */
+	if (count > 2 && iov[1].iov_len < ctor->port.hdr_len &&
+			mp->dev->features & NETIF_F_SG) {
+		return -EINVAL;
+	}
+
+	npages = ctor->port.npages;
+	payload = ctor->port.data_len;
+
+	/* If KVM guest virtio-net FE driver use SG feature */
+	if (count > 2) {
+		for (i = 2; i < count; i++) {
+			base = (unsigned long)iov[i].iov_base & ~PAGE_MASK;
+			len = iov[i].iov_len;
+			if (npages == 1)
+				len = min_t(int, len, PAGE_SIZE - base);
+			else if (base)
+				break;
+			payload -= len;
+			if (payload <= 0)
+				goto proceed;
+			if (npages == 1 || (len & ~PAGE_MASK))
+				break;
+		}
+	}
+
+	if ((((unsigned long)iov[1].iov_base & ~PAGE_MASK)
+				- NET_SKB_PAD - NET_IP_ALIGN) >= 0)
+		goto proceed;
+
+	return -EINVAL;
+
+proceed:
+	/* skip the virtnet head */
+	if (count > 1) {
+		iov++;
+		count--;
+	}
+
+	if (!ctor->lock_pages || !ctor->rq_len) {
+		set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
+				iocb->ki_user_data * 4096 * 2,
+				iocb->ki_user_data * 4096 * 2);
+	}
+
+	/* Translate address to kernel */
+	info = alloc_page_info(ctor, iocb, iov, count, frags, npages, 0);
+	if (!info)
+		return -ENOMEM;
+	info->len = total_len;
+	info->hdr[0].iov_base = iocb->ki_iovec[0].iov_base;
+	info->hdr[0].iov_len = iocb->ki_iovec[0].iov_len;
+	iocb->ki_iovec[0].iov_len = 0;
+	iocb->ki_left = 0;
+	info->offset = frags[0].offset;
+	info->desc_pos = iocb->ki_pos;
+
+	if (count > 1) {
+		iov--;
+		count++;
+	}
+
+	memcpy(info->iov, iov, sizeof(struct iovec) * count);
+
+	spin_lock_irqsave(&ctor->read_lock, flag);
+	list_add_tail(&info->list, &ctor->readq);
+	spin_unlock_irqrestore(&ctor->read_lock, flag);
+
+	ctor->rq_len++;
+
+	return 0;
+}
+
+/* Ops structure to mimic raw sockets with mp device */
+static const struct proto_ops mp_socket_ops = {
+	.sendmsg = mp_sendmsg,
+	.recvmsg = mp_recvmsg,
+};
+
+static struct proto mp_proto = {
+	.name           = "mp",
+	.owner          = THIS_MODULE,
+	.obj_size       = sizeof(struct mp_sock),
+};
+
+static int mp_chr_open(struct inode *inode, struct file * file)
+{
+	struct mp_file *mfile;
+	cycle_kernel_lock();
+	DBG1(KERN_INFO "mp: mp_chr_open\n");
+
+	mfile = kzalloc(sizeof(*mfile), GFP_KERNEL);
+	if (!mfile)
+		return -ENOMEM;
+	atomic_set(&mfile->count, 0);
+	mfile->mp = NULL;
+	mfile->net = get_net(current->nsproxy->net_ns);
+	file->private_data = mfile;
+	return 0;
+}
+
+static int mp_attach(struct mp_struct *mp, struct file *file)
+{
+	struct mp_file *mfile = file->private_data;
+	int err;
+
+	netif_tx_lock_bh(mp->dev);
+
+	err = -EINVAL;
+
+	if (mfile->mp)
+		goto out;
+
+	err = -EBUSY;
+	if (mp->mfile)
+		goto out;
+
+	err = 0;
+	mfile->mp = mp;
+	mp->mfile = mfile;
+	mp->socket.file = file;
+	dev_hold(mp->dev);
+	sock_hold(mp->socket.sk);
+	atomic_inc(&mfile->count);
+
+out:
+	netif_tx_unlock_bh(mp->dev);
+	return err;
+}
+
+static int do_unbind(struct mp_file *mfile)
+{
+	struct mp_struct *mp = mp_get(mfile);
+
+	if (!mp)
+		return -EINVAL;
+
+	mp_detach(mp);
+	sock_put(mp->socket.sk);
+	mp_put(mfile);
+	return 0;
+}
+
+static long mp_chr_ioctl(struct file *file, unsigned int cmd,
+		unsigned long arg)
+{
+	struct mp_file *mfile = file->private_data;
+	struct mp_struct *mp;
+	struct net_device *dev;
+	void __user* argp = (void __user *)arg;
+	struct ifreq ifr;
+	struct sock *sk;
+	int ret;
+
+	ret = -EINVAL;
+
+	switch (cmd) {
+	case MPASSTHRU_BINDDEV:
+		ret = -EFAULT;
+		if (copy_from_user(&ifr, argp, sizeof ifr))
+			break;
+
+		ifr.ifr_name[IFNAMSIZ-1] = '\0';
+
+		ret = -ENODEV;
+		dev = dev_get_by_name(mfile->net, ifr.ifr_name);
+		if (!dev)
+			break;
+
+		mutex_lock(&mp_mutex);
+
+		ret = -EBUSY;
+
+		/* the device can be only bind once */
+		if (dev_is_mpassthru(dev))
+			goto err_dev_put;
+
+		mp = mfile->mp;
+		if (mp)
+			goto err_dev_put;
+
+		mp = kzalloc(sizeof(*mp), GFP_KERNEL);
+		if (!mp) {
+			ret = -ENOMEM;
+			goto err_dev_put;
+		}
+		mp->dev = dev;
+		ret = -ENOMEM;
+
+		sk = sk_alloc(mfile->net, AF_UNSPEC, GFP_KERNEL, &mp_proto);
+		if (!sk)
+			goto err_free_mp;
+
+		init_waitqueue_head(&mp->socket.wait);
+		mp->socket.ops = &mp_socket_ops;
+		sock_init_data(&mp->socket, sk);
+		sk->sk_sndbuf = INT_MAX;
+		container_of(sk, struct mp_sock, sk)->mp = mp;
+
+		sk->sk_destruct = mp_sock_destruct;
+		sk->sk_data_ready = mp_sock_data_ready;
+		sk->sk_write_space = mp_sock_write_space;
+		sk->sk_state_change = mp_sock_state_change;
+		ret = mp_attach(mp, file);
+		if (ret < 0)
+			goto err_free_sk;
+
+		ret = page_ctor_attach(mp);
+		if (ret < 0)
+			goto err_free_sk;
+		mp_dev_change_flags(mp->dev, mp->dev->flags & (~IFF_UP));
+		mp_dev_change_flags(mp->dev, mp->dev->flags | IFF_UP);
+		sk->sk_state_change(sk);
+out:
+		mutex_unlock(&mp_mutex);
+		break;
+err_free_sk:
+		sk_free(sk);
+err_free_mp:
+		kfree(mp);
+err_dev_put:
+		dev_put(dev);
+		goto out;
+
+	case MPASSTHRU_UNBINDDEV:
+		ret = do_unbind(mfile);
+		break;
+
+	default:
+		break;
+	}
+	return ret;
+}
+
+static unsigned int mp_chr_poll(struct file *file, poll_table * wait)
+{
+	struct mp_file *mfile = file->private_data;
+	struct mp_struct *mp = mp_get(mfile);
+	struct sock *sk;
+	unsigned int mask = 0;
+
+	if (!mp)
+		return POLLERR;
+
+	sk = mp->socket.sk;
+
+	poll_wait(file, &mp->socket.wait, wait);
+
+	if (!skb_queue_empty(&sk->sk_receive_queue))
+		mask |= POLLIN | POLLRDNORM;
+
+	if (sock_writeable(sk) ||
+		(!test_and_set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
+			 sock_writeable(sk)))
+		mask |= POLLOUT | POLLWRNORM;
+
+	if (mp->dev->reg_state != NETREG_REGISTERED)
+		mask = POLLERR;
+
+	mp_put(mfile);
+	return mask;
+}
+
+static ssize_t mp_chr_aio_write(struct kiocb *iocb, const struct iovec *iov,
+				unsigned long count, loff_t pos)
+{
+	struct file *file = iocb->ki_filp;
+	struct mp_struct *mp = mp_get(file->private_data);
+	struct sock *sk = mp->socket.sk;
+	struct sk_buff *skb;
+	int len, err;
+	ssize_t result = 0;
+
+	if (!mp)
+		return -EBADFD;
+
+	/* currently, async is not supported.
+	 * but we may support real async aio from user application,
+	 * maybe qemu virtio-net backend.
+	 */
+	if (!is_sync_kiocb(iocb))
+		return -EFAULT;
+
+	len = iov_length(iov, count);
+
+	if (unlikely(len) < ETH_HLEN)
+		return -EINVAL;
+
+	skb = sock_alloc_send_skb(sk, len + NET_IP_ALIGN,
+				  file->f_flags & O_NONBLOCK, &err);
+
+	if (!skb)
+		return -EFAULT;
+
+	skb_reserve(skb, NET_IP_ALIGN);
+	skb_put(skb, len);
+
+	if (skb_copy_datagram_from_iovec(skb, 0, iov, 0, len)) {
+		kfree_skb(skb);
+		return -EAGAIN;
+	}
+
+	skb->protocol = eth_type_trans(skb, mp->dev);
+	skb->dev = mp->dev;
+
+	dev_queue_xmit(skb);
+
+	mp_put(file->private_data);
+	return result;
+}
+
+static int mp_chr_close(struct inode *inode, struct file *file)
+{
+	struct mp_file *mfile = file->private_data;
+
+	/*
+	 * Ignore return value since an error only means there was nothing to
+	 * do
+	 */
+	do_unbind(mfile);
+
+	put_net(mfile->net);
+	kfree(mfile);
+
+	return 0;
+}
+
+#ifdef CONFIG_COMPAT
+static long mp_chr_compat_ioctl(struct file *f, unsigned int ioctl,
+				unsigned long arg)
+{
+	return mp_chr_ioctl(f, ioctl, (unsigned long)compat_ptr(arg));
+}
+#endif
+
+static const struct file_operations mp_fops = {
+	.owner  = THIS_MODULE,
+	.llseek = no_llseek,
+	.write  = do_sync_write,
+	.aio_write = mp_chr_aio_write,
+	.poll   = mp_chr_poll,
+	.unlocked_ioctl = mp_chr_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl = mp_chr_compat_ioctl,
+#endif
+	.open   = mp_chr_open,
+	.release = mp_chr_close,
+};
+
+static struct miscdevice mp_miscdev = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name = "mp",
+	.nodename = "net/mp",
+	.fops = &mp_fops,
+};
+
+static int mp_device_event(struct notifier_block *unused,
+		unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct mpassthru_port *port;
+	struct mp_struct *mp = NULL;
+	struct socket *sock = NULL;
+	struct sock *sk;
+
+	port = dev->mp_port;
+	if (port == NULL)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_UNREGISTER:
+		sock = dev->mp_port->sock;
+		mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+		do_unbind(mp->mfile);
+		break;
+	case NETDEV_CHANGE:
+		sk = dev->mp_port->sock->sk;
+		sk->sk_state_change(sk);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block mp_notifier_block __read_mostly = {
+	.notifier_call  = mp_device_event,
+};
+
+static int mp_init(void)
+{
+	int err = 0;
+
+	ext_page_info_cache = kmem_cache_create("skb_page_info",
+						sizeof(struct page_info),
+						0, SLAB_HWCACHE_ALIGN, NULL);
+	if (!ext_page_info_cache)
+		return -ENOMEM;
+
+	err = misc_register(&mp_miscdev);
+	if (err) {
+		printk(KERN_ERR "mp: Can't register misc device\n");
+		kmem_cache_destroy(ext_page_info_cache);
+	} else {
+		printk(KERN_INFO "Registering mp misc device - minor = %d\n",
+				mp_miscdev.minor);
+		register_netdevice_notifier(&mp_notifier_block);
+	}
+	return err;
+}
+
+void mp_exit(void)
+{
+	unregister_netdevice_notifier(&mp_notifier_block);
+	misc_deregister(&mp_miscdev);
+	kmem_cache_destroy(ext_page_info_cache);
+}
+
+/* Get an underlying socket object from mp file.  Returns error unless file is
+ * attached to a device.  The returned object works like a packet socket, it
+ * can be used for sock_sendmsg/sock_recvmsg.  The caller is responsible for
+ * holding a reference to the file for as long as the socket is in use. */
+struct socket *mp_get_socket(struct file *file)
+{
+	struct mp_file *mfile = file->private_data;
+	struct mp_struct *mp;
+
+	if (file->f_op != &mp_fops)
+		return ERR_PTR(-EINVAL);
+	mp = mp_get(mfile);
+	if (!mp)
+		return ERR_PTR(-EBADFD);
+	mp_put(mfile);
+	return &mp->socket;
+}
+EXPORT_SYMBOL_GPL(mp_get_socket);
+
+module_init(mp_init);
+module_exit(mp_exit);
+MODULE_AUTHOR(DRV_COPYRIGHT);
+MODULE_DESCRIPTION(DRV_DESCRIPTION);
+MODULE_LICENSE("GPL v2");
-- 
1.5.4.4

