From: Xin Xiaohui <xiaohui.xin@intel.com>
Subject: [PATCH 1/3] A device for zero-copy based on KVM virtio-net.
Date: Wed, 10 Feb 2010 19:48:58 +0800
Message-ID: <1265802540-6122-2-git-send-email-xiaohui.xin@intel.com>
References: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>, Zhao Yu <yzhao81@gmail.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, mst@redhat.com,
	jdike@c2.user-mode-linux.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a device to utilize the vhost-net backend driver for
copy-less data transfer between guest FE and host NIC.
It pins the guest user space to the host memory and
provides proto_ops as sendmsg/recvmsg to vhost-net.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Sigend-off-by: Jeff Dike <jdike@c2.user-mode-linux.org>
---
 drivers/vhost/Kconfig      |    5 +
 drivers/vhost/Makefile     |    2 +
 drivers/vhost/mpassthru.c  | 1178 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/miscdevice.h |    1 +
 include/linux/mpassthru.h  |   17 +
 5 files changed, 1203 insertions(+), 0 deletions(-)
 create mode 100644 drivers/vhost/mpassthru.c
 create mode 100644 include/linux/mpassthru.h

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 9f409f4..ee32a3b 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -9,3 +9,8 @@ config VHOST_NET
 	  To compile this driver as a module, choose M here: the module will
 	  be called vhost_net.
 
+config VHOST_PASSTHRU
+	tristate "Zerocopy network driver (EXPERIMENTAL)"
+	depends on VHOST_NET
+	---help---
+	  zerocopy network I/O support
diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
index 72dd020..3f79c79 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -1,2 +1,4 @@
 obj-$(CONFIG_VHOST_NET) += vhost_net.o
 vhost_net-y := vhost.o net.o
+
+obj-$(CONFIG_VHOST_PASSTHRU) += mpassthru.o
diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
new file mode 100644
index 0000000..d8d153f
--- /dev/null
+++ b/drivers/vhost/mpassthru.c
@@ -0,0 +1,1178 @@
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
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/major.h>
+#include <linux/slab.h>
+#include <linux/smp_lock.h>
+#include <linux/poll.h>
+#include <linux/fcntl.h>
+#include <linux/init.h>
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
+#include "vhost.h"
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
+struct page_ctor {
+	struct list_head        readq;
+	int 			w_len;
+	int 			r_len;
+	spinlock_t      	read_lock;
+	atomic_t        	refcnt;
+	struct kmem_cache   	*cache;
+	struct net_device   	*dev;
+	struct netdev_page_ctor ctor;
+	void 			*sendctrl;
+	void 			*recvctrl;
+};
+
+struct page_info {
+	struct list_head    	list;
+	int         		header;
+	/* indicate the actual length of bytes
+	 * send/recv in the user space buffers
+	 */
+	int         		total;
+	int         		offset;
+	struct page     	*pages[MAX_SKB_FRAGS+1];
+	struct skb_frag_struct 	frag[MAX_SKB_FRAGS+1];
+	struct sk_buff      	*skb;
+	struct page_ctor   	*ctor;
+
+	/* The pointer relayed to skb, to indicate
+	 * it's a user space allocated skb or kernel
+	 */
+	struct skb_user_page    user;
+	struct skb_shared_info	ushinfo;
+
+#define INFO_READ      		0
+#define INFO_WRITE     		1
+	unsigned        	flags;
+	unsigned        	pnum;
+
+	/* It's meaningful for receive, means
+	 * the max length allowed
+	 */
+	size_t          	len;
+
+	/* The fields after that is for backend
+	 * driver, now for vhost-net.
+	 */
+	struct vhost_notifier	notifier;
+	unsigned int    	desc_pos;
+	unsigned int 		log;
+	struct iovec 		hdr[VHOST_NET_MAX_SG];
+	struct iovec 		iov[VHOST_NET_MAX_SG];
+	void 			*ctl;
+};
+
+struct mp_struct {
+	struct mp_file   	*mfile;
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
+	struct sock            	sk;
+	struct mp_struct       	*mp;
+};
+
+/* The main function to allocate user space buffers */
+static struct skb_user_page *page_ctor(struct netdev_page_ctor *page_ctor,
+		struct sk_buff *skb, int npages)
+{
+	int i;
+	unsigned long flags;
+	struct page_ctor *ctor;
+	struct page_info *info = NULL;
+
+	ctor = container_of(page_ctor, struct page_ctor, ctor);
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
+		info->frag[i].size = page_ctor->npages > 1 ? PAGE_SIZE :
+			page_ctor->data_len;
+	}
+	info->skb = skb;
+	info->user.frags = info->frag;
+	info->user.ushinfo = &info->ushinfo;
+	return &info->user;
+}
+
+static struct vhost_notifier *create_vhost_notifier(struct vhost_virtqueue *vq,
+			struct page_info *info, int size);
+
+static void mp_vhost_notifier_dtor(struct vhost_notifier *vnotify)
+{
+	struct page_info *info = (struct page_info *)(vnotify->ctrl);
+	int i;
+
+	for (i = 0; i < info->pnum; i++) {
+		if (i <= skb_shinfo(info->skb)->nr_frags &&
+				info->flags == INFO_WRITE)
+			info->pages[i] = NULL;
+		if (info->pages[i])
+			put_page(info->pages[i]);
+	}
+
+	if (info->flags == INFO_READ) {
+		skb_shinfo(info->skb)->destructor_arg = &info->user;
+		info->skb->destructor = NULL;
+		kfree(info->skb);
+	}
+
+	kmem_cache_free(info->ctor->cache, info);
+
+	return;
+}
+
+/* A helper to clean the skb before the kfree_skb() */
+
+static void page_dtor_prepare(struct page_info *info)
+{
+	if (info->flags == INFO_READ)
+		if (info->skb)
+			info->skb->head = NULL;
+}
+
+/* The callback to destruct the user space buffers or skb */
+static void page_dtor(struct skb_user_page *user)
+{
+	struct page_info *info;
+	struct page_ctor *ctor;
+	struct sock *sk;
+	struct sk_buff *skb;
+	struct vhost_notifier *vnotify;
+	struct vhost_virtqueue *vq = NULL;
+	unsigned long flags;
+	int i;
+
+	if (!user)
+		return;
+	info = container_of(user, struct page_info, user);
+	if (!info)
+		return;
+	ctor = info->ctor;
+	skb = info->skb;
+
+	page_dtor_prepare(info);
+
+	/* If the info->total is 0, make it to be reused */
+	if (!info->total) {
+		spin_lock_irqsave(&ctor->read_lock, flags);
+		list_add(&info->list, &ctor->readq);
+		spin_unlock_irqrestore(&ctor->read_lock, flags);
+		return;
+	}
+
+	/* Receive buffers, should be destructed */
+	if (info->flags == INFO_READ) {
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		info->skb = NULL;
+		return;
+	}
+
+	/* For transmit, we should wait for the DMA finish by hardware.
+	 * Queue the notifier to wake up the backend driver
+	 */
+	vq = (struct vhost_virtqueue *)info->ctl;
+	vnotify = create_vhost_notifier(vq, info, info->total);
+
+	spin_lock_irqsave(&vq->notify_lock, flags);
+	list_add_tail(&vnotify->list, &vq->notifier);
+	spin_unlock_irqrestore(&vq->notify_lock, flags);
+
+	sk = ctor->ctor.sock->sk;
+	sk->sk_write_space(sk);
+
+	return;
+}
+
+static int page_ctor_attach(struct mp_struct *mp)
+{
+	int rc;
+	struct page_ctor *ctor;
+	struct net_device *dev = mp->dev;
+
+	rcu_read_lock();
+	if (rcu_dereference(mp->ctor)) {
+		rcu_read_unlock();
+		return -EBUSY;
+	}
+	rcu_read_unlock();
+
+	ctor = kzalloc(sizeof(*ctor), GFP_KERNEL);
+	if (!ctor)
+		return -ENOMEM;
+	rc = netdev_page_ctor_prep(dev, &ctor->ctor);
+	if (rc)
+		goto fail;
+
+	ctor->cache = kmem_cache_create("skb_page_info",
+			sizeof(struct page_info), 0,
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+
+	if (!ctor->cache)
+		goto cache_fail;
+
+	INIT_LIST_HEAD(&ctor->readq);
+	spin_lock_init(&ctor->read_lock);
+
+	ctor->w_len = 0;
+	ctor->r_len = 0;
+
+	dev_hold(dev);
+	ctor->dev = dev;
+	ctor->ctor.ctor = page_ctor;
+	ctor->ctor.sock = &mp->socket;
+	atomic_set(&ctor->refcnt, 1);
+
+	rc = netdev_page_ctor_attach(dev, &ctor->ctor);
+	if (rc)
+		goto fail;
+
+	/* locked by mp_mutex */
+	rcu_assign_pointer(mp->ctor, ctor);
+
+	/* XXX:Need we do set_offload here ? */
+
+	return 0;
+
+fail:
+	kmem_cache_destroy(ctor->cache);
+cache_fail:
+	kfree(ctor);
+	dev_put(dev);
+
+	return rc;
+}
+
+
+static inline void get_page_ctor(struct page_ctor *ctor)
+{
+       atomic_inc(&ctor->refcnt);
+}
+
+static inline void put_page_ctor(struct page_ctor *ctor)
+{
+	if (atomic_dec_and_test(&ctor->refcnt))
+		kfree(ctor);
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
+	}
+	spin_unlock_irqrestore(&ctor->read_lock, flags);
+	return info;
+}
+
+static int page_ctor_detach(struct mp_struct *mp)
+{
+	struct page_ctor *ctor;
+	struct page_info *info;
+	int i;
+
+	rcu_read_lock();
+	ctor = rcu_dereference(mp->ctor);
+	rcu_read_unlock();
+
+	if (!ctor)
+		return -ENODEV;
+
+	while ((info = info_dequeue(ctor))) {
+		for (i = 0; i < info->pnum; i++)
+			if (info->pages[i])
+				put_page(info->pages[i]);
+		kmem_cache_free(ctor->cache, info);
+	}
+	kmem_cache_destroy(ctor->cache);
+	netdev_page_ctor_detach(ctor->dev);
+	dev_put(ctor->dev);
+
+	/* locked by mp_mutex */
+	rcu_assign_pointer(mp->ctor, NULL);
+	synchronize_rcu();
+
+	put_page_ctor(ctor);
+
+	return 0;
+}
+
+/* For small user space buffers transmit, we don't need to call
+ * get_user_pages().
+ */
+static struct page_info *alloc_small_page_info(struct page_ctor *ctor,
+		int total)
+{
+	struct page_info *info = kmem_cache_alloc(ctor->cache, GFP_KERNEL);
+
+	if (!info)
+		return NULL;
+	memset(info, 0, sizeof(struct page_info));
+	memset(info->pages, 0, sizeof(info->pages));
+
+	info->header = 0;
+	info->total = total;
+	info->skb = NULL;
+	info->user.dtor = page_dtor;
+	info->ctor = ctor;
+	info->flags = INFO_WRITE;
+	info->pnum = 0;
+	return info;
+}
+
+/* The main function to transform the guest user space address
+ * to host kernel address via get_user_pages(). Thus the hardware
+ * can do DMA directly to the user space address.
+ */
+static struct page_info *alloc_page_info(struct page_ctor *ctor,
+			struct iovec *iov, int count, struct frag *frags,
+			int npages, int total)
+{
+	int rc;
+	int i, j, n = 0;
+	int len;
+	unsigned long base;
+	struct page_info *info = kmem_cache_alloc(ctor->cache, GFP_KERNEL);
+
+	if (!info)
+		return NULL;
+	memset(info, 0, sizeof(struct page_info));
+	memset(info->pages, 0, sizeof(info->pages));
+
+	down_read(&current->mm->mmap_sem);
+	for (i = j = 0; i < count; i++) {
+		base = (unsigned long)iov[i].iov_base;
+		len = iov[i].iov_len;
+
+		if (!len)
+			continue;
+		n = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+
+		rc = get_user_pages(current, current->mm, base, n,
+				npages ? 1 : 0, 0, &info->pages[j], NULL);
+		if (rc != n) {
+			up_read(&current->mm->mmap_sem);
+			goto failed;
+		}
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
+	up_read(&current->mm->mmap_sem);
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
+	info->header = 0;
+	info->total = total;
+	info->skb = NULL;
+	info->user.dtor = page_dtor;
+	info->ctor = ctor;
+	info->pnum = j;
+
+	if (!npages)
+		info->flags = INFO_WRITE;
+	if (info->flags == INFO_READ) {
+		info->user.start = (u8 *)(((unsigned long)
+				(pfn_to_kaddr(page_to_pfn(info->pages[0]))) +
+				frags[0].offset) - NET_IP_ALIGN - NET_SKB_PAD);
+		info->user.size = iov[0].iov_len + NET_IP_ALIGN + NET_SKB_PAD;
+	}
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
+struct page_ctor *mp_rcu_get_ctor(struct page_ctor *ctor)
+{
+	struct page_ctor *_ctor = NULL;
+
+	rcu_read_lock();
+	_ctor = rcu_dereference(ctor);
+	rcu_read_unlock();
+
+	if (!_ctor) {
+		DBG(KERN_INFO "Device %s cannot do mediate passthru.\n",
+				ctor->dev->name);
+		return NULL;
+	}
+	if (_ctor)
+		get_page_ctor(_ctor);
+	return _ctor;
+}
+
+static int mp_sendmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *m, size_t total_len)
+{
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor;
+	struct vhost_virtqueue *vq = (struct vhost_virtqueue *)(m->msg_control);
+	struct iovec *iov = m->msg_iov;
+	struct page_info *info = NULL;
+	struct frag frags[MAX_SKB_FRAGS];
+	struct sk_buff *skb;
+	int count = m->msg_iovlen;
+	int total = 0, header, n, i, len, rc;
+	unsigned long base;
+
+	ctor = mp_rcu_get_ctor(mp->ctor);
+	if (!ctor)
+		return -ENODEV;
+
+	ctor->sendctrl = vq;
+
+	total = iov_length(iov, count);
+
+	if (total < ETH_HLEN) {
+		put_page_ctor(ctor);
+		return -EINVAL;
+	}
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
+		if (n > MAX_SKB_FRAGS) {
+			put_page_ctor(ctor);
+			return -EINVAL;
+		}
+	}
+
+copy:
+	header = total > COPY_THRESHOLD ? COPY_HDR_LEN : total;
+
+	skb = alloc_skb(header + NET_IP_ALIGN, GFP_ATOMIC);
+	if (!skb)
+		goto drop;
+
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	skb_set_network_header(skb, ETH_HLEN);
+
+	memcpy_fromiovec(skb->data, iov, header);
+	skb_put(skb, header);
+	skb->protocol = *((__be16 *)(skb->data) + ETH_ALEN);
+
+	if (header == total) {
+		rc = total;
+		info = alloc_small_page_info(ctor, total);
+	} else {
+		info = alloc_page_info(ctor, iov, count, frags, 0, total);
+		if (info)
+			for (i = 0; info->pages[i]; i++) {
+				skb_add_rx_frag(skb, i, info->pages[i],
+						frags[i].offset, frags[i].size);
+				info->pages[i] = NULL;
+			}
+	}
+	if (info != NULL) {
+		info->desc_pos = vq->head;
+		info->ctl = vq;
+		info->total = total;
+		info->skb = skb;
+		skb_shinfo(skb)->destructor_arg = &info->user;
+		skb->dev = mp->dev;
+		dev_queue_xmit(skb);
+		mp->dev->stats.tx_packets++;
+		mp->dev->stats.tx_bytes += total;
+		put_page_ctor(ctor);
+		return 0;
+	}
+drop:
+	kfree(skb);
+	if (info) {
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		kmem_cache_free(info->ctor->cache, info);
+	}
+	mp->dev->stats.tx_dropped++;
+	put_page_ctor(ctor);
+	return -ENOMEM;
+}
+
+
+static struct vhost_notifier *create_vhost_notifier(struct vhost_virtqueue *vq,
+			struct page_info *info, int size)
+{
+	struct vhost_notifier *vnotify = NULL;
+
+	vnotify = &info->notifier;
+	memset(vnotify, 0, sizeof(struct vhost_notifier));
+	vnotify->vq = vq;
+	vnotify->head = info->desc_pos;
+	vnotify->size = size;
+	vnotify->log = info->log;
+	vnotify->ctrl = (void *)info;
+	vnotify->dtor = mp_vhost_notifier_dtor;
+	return vnotify;
+}
+
+static void mp_recvmsg_notify(struct vhost_virtqueue *vq)
+{
+	struct socket *sock = vq->private_data;
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor = NULL;
+	struct sk_buff *skb = NULL;
+	struct page_info *info = NULL;
+	struct ethhdr *eth;
+	struct vhost_notifier *vnotify = NULL;
+	int len, i;
+	unsigned long flags;
+
+	struct virtio_net_hdr hdr = {
+		.flags = 0,
+		.gso_type = VIRTIO_NET_HDR_GSO_NONE
+	};
+
+	ctor = mp_rcu_get_ctor(mp->ctor);
+	if (!ctor)
+		return;
+
+	while ((skb = skb_dequeue(&sock->sk->sk_receive_queue)) != NULL) {
+		if (skb_shinfo(skb)->destructor_arg) {
+			info = container_of(skb_shinfo(skb)->destructor_arg,
+					struct page_info, user);
+			info->skb = skb;
+			if (skb->len > info->len) {
+				mp->dev->stats.rx_dropped++;
+				DBG(KERN_INFO "Discarded truncated rx packet: "
+					" len %d > %zd\n", skb->len, info->len);
+				info->total = skb->len;
+				goto clean;
+			} else {
+				int i;
+				struct skb_shared_info *gshinfo =
+				(struct skb_shared_info *)(&info->ushinfo);
+				struct skb_shared_info *hshinfo =
+						skb_shinfo(skb);
+
+				if (gshinfo->nr_frags < hshinfo->nr_frags)
+					goto clean;
+				eth = eth_hdr(skb);
+				skb_push(skb, ETH_HLEN);
+
+				hdr.hdr_len = skb_headlen(skb);
+				info->total = skb->len;
+
+				for (i = 0; i < gshinfo->nr_frags; i++)
+					gshinfo->frags[i].size = 0;
+				for (i = 0; i < hshinfo->nr_frags; i++)
+					gshinfo->frags[i].size =
+						hshinfo->frags[i].size;
+				memcpy(skb_shinfo(skb), &info->ushinfo,
+						sizeof(struct skb_shared_info));
+			}
+		} else {
+			/* The skb composed with kernel buffers
+			 * in case user space buffers are not sufficent.
+			 * The case should be rare.
+			 */
+			unsigned long flags;
+			int i;
+			struct skb_shared_info *gshinfo = NULL;
+
+			info = NULL;
+
+			spin_lock_irqsave(&ctor->read_lock, flags);
+			if (!list_empty(&ctor->readq)) {
+				info = list_first_entry(&ctor->readq,
+						struct page_info, list);
+				list_del(&info->list);
+			}
+			spin_unlock_irqrestore(&ctor->read_lock, flags);
+			if (!info) {
+				DBG(KERN_INFO "No user buffer avaliable %p\n",
+									skb);
+				skb_queue_head(&sock->sk->sk_receive_queue,
+									skb);
+				break;
+			}
+			info->skb = skb;
+			/* compute the guest skb frags info */
+			gshinfo = (struct skb_shared_info *)(info->user.start +
+					SKB_DATA_ALIGN(info->user.size));
+
+			if (gshinfo->nr_frags < skb_shinfo(skb)->nr_frags)
+				goto clean;
+
+			eth = eth_hdr(skb);
+			skb_push(skb, ETH_HLEN);
+			info->total = skb->len;
+
+			for (i = 0; i < gshinfo->nr_frags; i++)
+				gshinfo->frags[i].size = 0;
+			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+				gshinfo->frags[i].size =
+					skb_shinfo(skb)->frags[i].size;
+			hdr.hdr_len = min_t(int, skb->len,
+						info->iov[1].iov_len);
+			skb_copy_datagram_iovec(skb, 0, info->iov, skb->len);
+		}
+
+		len = memcpy_toiovec(info->hdr, (unsigned char *)&hdr,
+								 sizeof hdr);
+		if (len) {
+			DBG(KERN_INFO
+				"Unable to write vnet_hdr at addr %p: %d\n",
+				info->hdr->iov_base, len);
+			goto clean;
+		}
+		vnotify = create_vhost_notifier(vq, info,
+				skb->len + sizeof(hdr));
+
+		spin_lock_irqsave(&vq->notify_lock, flags);
+		list_add_tail(&vnotify->list, &vq->notifier);
+		spin_unlock_irqrestore(&vq->notify_lock, flags);
+		continue;
+
+clean:
+		kfree_skb(skb);
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		kmem_cache_free(ctor->cache, info);
+	}
+	put_page_ctor(ctor);
+	return;
+}
+
+static int mp_recvmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *m, size_t total_len,
+		int flags)
+{
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor;
+	struct vhost_virtqueue *vq = (struct vhost_virtqueue *)(m->msg_control);
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
+	ctor = mp_rcu_get_ctor(mp->ctor);
+	if (!ctor)
+		return -EINVAL;
+
+	ctor->recvctrl = vq;
+
+	/* Error detections in case invalid user space buffer */
+	if (count > 2 && iov[1].iov_len < ctor->ctor.hdr_len &&
+			mp->dev->features & NETIF_F_SG) {
+		put_page_ctor(ctor);
+		return -EINVAL;
+	}
+
+	npages = ctor->ctor.npages;
+	payload = ctor->ctor.data_len;
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
+	put_page_ctor(ctor);
+	return -EINVAL;
+
+proceed:
+	/* skip the virtnet head */
+	iov++;
+	count--;
+
+	/* Translate address to kernel */
+	info = alloc_page_info(ctor, iov, count, frags, npages, 0);
+	if (!info) {
+		put_page_ctor(ctor);
+		return -ENOMEM;
+	}
+
+	info->len = total_len;
+	info->hdr[0].iov_base = vq->hdr[0].iov_base;
+	info->hdr[0].iov_len = vq->hdr[0].iov_len;
+	info->offset = frags[0].offset;
+	info->desc_pos = vq->head;
+	info->log = vq->_log;
+	info->ctl = NULL;
+
+	iov--;
+	count++;
+
+	memcpy(info->iov, vq->iov, sizeof(struct iovec) * count);
+
+	spin_lock_irqsave(&ctor->read_lock, flag);
+	list_add_tail(&info->list, &ctor->readq);
+	spin_unlock_irqrestore(&ctor->read_lock, flag);
+
+	if (!vq->receiver)
+		vq->receiver = mp_recvmsg_notify;
+
+	put_page_ctor(ctor);
+	return 0;
+}
+
+static void mp_put(struct mp_file *mfile);
+
+static int mp_release(struct socket *sock)
+{
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct mp_file *mfile = mp->mfile;
+
+	mp_put(mfile);
+	sock_put(mp->socket.sk);
+	put_net(mfile->net);
+
+	return 0;
+}
+
+/* Ops structure to mimic raw sockets with mp device */
+static const struct proto_ops mp_socket_ops = {
+	.sendmsg = mp_sendmsg,
+	.recvmsg = mp_recvmsg,
+	.release = mp_release,
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
+static void __mp_detach(struct mp_struct *mp)
+{
+	int up = 0;
+
+	mp->mfile = NULL;
+
+	/* stop the driver to clean all the user space buffers */
+	if (mp->dev->flags & IFF_UP) {
+		up = 1;
+		mp->dev->netdev_ops->ndo_stop(mp->dev);
+	}
+	page_ctor_detach(mp);
+	if (up)
+		mp->dev->netdev_ops->ndo_open(mp->dev);
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
+static void mp_sock_destruct(struct sock *sk)
+{
+	struct mp_struct *mp = container_of(sk, struct mp_sock, sk)->mp;
+	kfree(mp);
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
+static void mp_sock_data_ready(struct sock *sk, int len)
+{
+	read_lock(&sk->sk_callback_lock);
+	if (sk_has_sleeper(sk))
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN);
+	read_unlock(&sk->sk_callback_lock);
+}
+
+static void mp_sock_write_space(struct sock *sk)
+{
+	read_lock(&sk->sk_callback_lock);
+	if (sk_has_sleeper(sk))
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT);
+	read_unlock(&sk->sk_callback_lock);
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
+		ret = -EBUSY;
+
+		if (ifr.ifr_flags & IFF_MPASSTHRU_EXCL)
+			break;
+
+		ret = -ENODEV;
+		dev = dev_get_by_name(mfile->net, ifr.ifr_name);
+		if (!dev)
+			break;
+
+		mutex_lock(&mp_mutex);
+
+		ret = -EBUSY;
+		mp = mfile->mp;
+		if (mp)
+			goto out;
+
+		mp = kzalloc(sizeof(*mp), GFP_KERNEL);
+		if (!mp) {
+			ret = -ENOMEM;
+			goto out;
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
+
+		ret = mp_attach(mp, file);
+		if (ret < 0)
+			goto err_free_sk;
+		ifr.ifr_flags |= IFF_MPASSTHRU_EXCL;
+		ret = page_ctor_attach(mp);
+out:
+		mutex_unlock(&mp_mutex);
+		break;
+err_free_sk:
+		sk_free(sk);
+err_free_mp:
+		kfree(mp);
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
+static int count;
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
+	if (!skb_queue_empty(&sk->sk_receive_queue) || !count)
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
+static const struct file_operations mp_fops = {
+	.owner  = THIS_MODULE,
+	.llseek = no_llseek,
+	.poll   = mp_chr_poll,
+	.unlocked_ioctl = mp_chr_ioctl,
+	.open   = mp_chr_open,
+	.release = mp_chr_close,
+};
+
+static struct miscdevice mp_miscdev = {
+	.minor = MPASSTHRU_MINOR,
+	.name = "mp",
+	.nodename = "net/mp",
+	.fops = &mp_fops,
+};
+
+static int mp_init(void)
+{
+	int ret = 0;
+	ret = misc_register(&mp_miscdev);
+	if (ret)
+		printk(KERN_ERR "mp: Can't register misc device\n");
+	return ret;
+}
+
+void mp_cleanup(void)
+{
+	misc_deregister(&mp_miscdev);
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
+module_exit(mp_cleanup);
+MODULE_AUTHOR(DRV_COPYRIGHT);
+MODULE_DESCRIPTION(DRV_DESCRIPTION);
+MODULE_LICENSE("GPL v2");
diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
index 8b5f7cc..8f5211e 100644
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -31,6 +31,7 @@
 #define FUSE_MINOR		229
 #define KVM_MINOR		232
 #define VHOST_NET_MINOR		233
+#define MPASSTHRU_MINOR		234
 #define MISC_DYNAMIC_MINOR	255
 
 struct device;
diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
new file mode 100644
index 0000000..7b71365
--- /dev/null
+++ b/include/linux/mpassthru.h
@@ -0,0 +1,17 @@
+#ifndef __MPASSTHRU_H
+#define __MPASSTHRU_H
+
+#include <linux/types.h>
+#include <linux/if_ether.h>
+
+/* ioctl defines */
+#define MPASSTHRU_BINDDEV      _IOW('M', 213, int)
+#define MPASSTHRU_UNBINDDEV    _IOW('M', 214, int)
+
+/* MPASSTHRU ifc flags */
+#define IFF_MPASSTHRU		0x0001
+#define IFF_MPASSTHRU_EXCL	0x0002
+
+struct socket *mp_get_socket(struct file *);
+
+#endif /* __MPASSTHRU_H */
-- 
1.5.4.4

