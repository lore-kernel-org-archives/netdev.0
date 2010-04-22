From: xiaohui.xin@intel.com
Subject: Re:[RFC][PATCH v3 1/3] A device for zero-copy based on KVM virtio-net.
Date: Thu, 22 Apr 2010 16:24:18 +0800
Message-ID: <1271924658-4840-1-git-send-email-xiaohui.xin@intel.com>
References: <20100415090324.GA15135@redhat.com>
Cc: arnd@arndb.de, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	jdike@linux.intel.com, Xin Xiaohui <xiaohui.xin@intel.com>
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100415090324.GA15135@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Add a device to utilize the vhost-net backend driver for
copy-less data transfer between guest FE and host NIC.
It pins the guest user space to the host memory and
provides proto_ops as sendmsg/recvmsg to vhost-net.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---

Michael,
Thanks. I have updated the patch with your suggestion.
It looks much clean now. Please have a review.

Thanks
Xiaohui

 drivers/vhost/Kconfig     |   10 +
 drivers/vhost/Makefile    |    2 +
 drivers/vhost/mpassthru.c | 1239 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mpassthru.h |   29 +
 4 files changed, 1280 insertions(+), 0 deletions(-)
 create mode 100644 drivers/vhost/mpassthru.c
 create mode 100644 include/linux/mpassthru.h

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 9f409f4..91806b1 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -9,3 +9,13 @@ config VHOST_NET
 	  To compile this driver as a module, choose M here: the module will
 	  be called vhost_net.
 
+config MEDIATE_PASSTHRU
+	tristate "mediate passthru network driver (EXPERIMENTAL)"
+	depends on VHOST_NET
+	---help---
+	  zerocopy network I/O support, we call it as mediate passthru to
+	  be distiguish with hardare passthru.
+
+	  To compile this driver as a module, choose M here: the module will
+	  be called mpassthru.
+
diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
index 72dd020..c18b9fc 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -1,2 +1,4 @@
 obj-$(CONFIG_VHOST_NET) += vhost_net.o
 vhost_net-y := vhost.o net.o
+
+obj-$(CONFIG_MEDIATE_PASSTHRU) += mpassthru.o
diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
new file mode 100644
index 0000000..cc99b14
--- /dev/null
+++ b/drivers/vhost/mpassthru.c
@@ -0,0 +1,1239 @@
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
+struct page_ctor {
+	struct list_head        readq;
+	int 			w_len;
+	int 			r_len;
+	spinlock_t      	read_lock;
+	struct kmem_cache   	*cache;
+	/* record the locked pages */
+	int			lock_pages;
+	struct rlimit		o_rlim;
+	struct net_device   	*dev;
+	struct mpassthru_port	port;
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
+
+	struct kiocb		*iocb;
+	unsigned int    	desc_pos;
+	unsigned int 		log;
+	struct iovec 		hdr[MAX_SKB_FRAGS + 2];
+	struct iovec 		iov[MAX_SKB_FRAGS + 2];
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
+/* The main function to allocate user space buffers */
+static struct skb_user_page *page_ctor(struct mpassthru_port *port,
+					struct sk_buff *skb, int npages)
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
+	info->user.frags = info->frag;
+	info->user.ushinfo = &info->ushinfo;
+	return &info->user;
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
+		skb_shinfo(info->skb)->destructor_arg = &info->user;
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
+	iocb->ki_user_data = info->log;
+	iocb->ki_dtor(iocb);
+	iocb->private = (void *)info;
+	iocb->ki_dtor = mp_ki_dtor;
+
+	return iocb;
+}
+
+/* The callback to destruct the user space buffers or skb */
+static void page_dtor(struct skb_user_page *user)
+{
+	struct page_info *info;
+	struct page_ctor *ctor;
+	struct sock *sk;
+	struct sk_buff *skb;
+	struct kiocb *iocb = NULL;
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
+static int page_ctor_attach(struct mp_struct *mp)
+{
+	int rc;
+	struct page_ctor *ctor;
+	struct net_device *dev = mp->dev;
+
+	/* locked by mp_mutex */
+	if (rcu_dereference(mp->ctor))
+		return -EBUSY;
+
+	ctor = kzalloc(sizeof(*ctor), GFP_KERNEL);
+	if (!ctor)
+		return -ENOMEM;
+	rc = netdev_mp_port_prep(dev, &ctor->port);
+	if (rc)
+		goto fail;
+
+	ctor->cache = kmem_cache_create("skb_page_info",
+			sizeof(struct page_info), 0,
+			SLAB_HWCACHE_ALIGN, NULL);
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
+	ctor->port.ctor = page_ctor;
+	ctor->port.sock = &mp->socket;
+	ctor->lock_pages = 0;
+	rc = netdev_mp_port_attach(dev, &ctor->port);
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
+static int page_ctor_detach(struct mp_struct *mp)
+{
+	struct page_ctor *ctor;
+	struct page_info *info;
+	struct kiocb *iocb = NULL;
+	int i;
+	unsigned long flags;
+
+	/* locked by mp_mutex */
+	ctor = rcu_dereference(mp->ctor);
+	if (!ctor)
+		return -ENODEV;
+
+	while ((info = info_dequeue(ctor))) {
+		for (i = 0; i < info->pnum; i++)
+			if (info->pages[i])
+				put_page(info->pages[i]);
+		iocb = create_iocb(info, 0);
+		kmem_cache_free(ctor->cache, info);
+	}
+	set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
+			   ctor->o_rlim.rlim_cur,
+			   ctor->o_rlim.rlim_max);
+	kmem_cache_destroy(ctor->cache);
+	netdev_mp_port_detach(ctor->dev);
+	dev_put(ctor->dev);
+
+	/* locked by mp_mutex */
+	rcu_assign_pointer(mp->ctor, NULL);
+	synchronize_rcu();
+
+	kfree(ctor);
+	return 0;
+}
+
+/* For small user space buffers transmit, we don't need to call
+ * get_user_pages().
+ */
+static struct page_info *alloc_small_page_info(struct page_ctor *ctor,
+						struct kiocb *iocb, int total)
+{
+	struct page_info *info = kmem_cache_zalloc(ctor->cache, GFP_KERNEL);
+
+	if (!info)
+		return NULL;
+	info->total = total;
+	info->user.dtor = page_dtor;
+	info->ctor = ctor;
+	info->flags = INFO_WRITE;
+	info->iocb = iocb;
+	return info;
+}
+
+/* The main function to transform the guest user space address
+ * to host kernel address via get_user_pages(). Thus the hardware
+ * can do DMA directly to the user space address.
+ */
+static struct page_info *alloc_page_info(struct page_ctor *ctor,
+					struct kiocb *iocb, struct iovec *iov,
+					int count, struct frag *frags,
+					int npages, int total)
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
+		printk(KERN_INFO "exceed the locked memory rlimit %d!",
+		       lock_limit);
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
+						&info->pages[j]);
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
+	info->user.dtor = page_dtor;
+	info->ctor = ctor;
+	info->pnum = j;
+	info->iocb = iocb;
+	if (!npages)
+		info->flags = INFO_WRITE;
+	if (info->flags == INFO_READ) {
+		info->user.start = (u8 *)(((unsigned long)
+				(pfn_to_kaddr(page_to_pfn(info->pages[0]))) +
+				frags[0].offset));
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+		info->user.size = SKB_DATA_ALIGN(
+				  iov[0].iov_len + NET_IP_ALIGN + NET_SKB_PAD);
+#else
+		info->user.size = SKB_DATA_ALIGN(
+				  iov[0].iov_len + NET_IP_ALIGN + NET_SKB_PAD) -
+				  NET_IP_ALIGN - NET_SKB_PAD;
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
+static int mp_sendmsg(struct kiocb *iocb, struct socket *sock,
+			struct msghdr *m, size_t total_len)
+{
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor;
+	struct iovec *iov = m->msg_iov;
+	struct page_info *info = NULL;
+	struct frag frags[MAX_SKB_FRAGS];
+	struct sk_buff *skb;
+	int count = m->msg_iovlen;
+	int total = 0, header, n, i, len, rc;
+	unsigned long base;
+
+	ctor = rcu_dereference(mp->ctor);
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
+		skb_shinfo(skb)->destructor_arg = &info->user;
+		skb->dev = mp->dev;
+		dev_queue_xmit(skb);
+		return 0;
+	}
+drop:
+	kfree_skb(skb);
+	if (info) {
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		kmem_cache_free(info->ctor->cache, info);
+	}
+	mp->dev->stats.tx_dropped++;
+	return -ENOMEM;
+}
+
+static int mp_recvmsg(struct kiocb *iocb, struct socket *sock,
+			struct msghdr *m, size_t total_len,
+			int flags)
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
+	ctor = rcu_dereference(mp->ctor);
+	if (!ctor)
+		return -EINVAL;
+
+	/* Error detections in case invalid user space buffer */
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
+	iov++;
+	count--;
+
+	if (!ctor->lock_pages)
+		set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
+				 (((1UL << 32) -1) & iocb->ki_user_data) * 4096,
+				 (((1UL << 32) -1) & iocb->ki_user_data) * 4096);
+
+	/* Translate address to kernel */
+	info = alloc_page_info(ctor, iocb, iov, count, frags, npages, 0);
+	if (!info)
+		return -ENOMEM;
+	info->len = total_len;
+	info->hdr[0].iov_base = iocb->ki_iovec[0].iov_base;
+	info->hdr[0].iov_len = iocb->ki_iovec[0].iov_len;
+	info->offset = frags[0].offset;
+	info->desc_pos = iocb->ki_pos;
+	info->log = iocb->ki_user_data;
+
+	iov--;
+	count++;
+
+	memcpy(info->iov, iov, sizeof(struct iovec) * count);
+	
+	spin_lock_irqsave(&ctor->read_lock, flag);
+	list_add_tail(&info->list, &ctor->readq);
+	spin_unlock_irqrestore(&ctor->read_lock, flag);
+
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
+static void mp_put(struct mp_file *mfile)
+{
+	if (atomic_dec_and_test(&mfile->count))
+		mp_detach(mfile->mp);
+}
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
+static void mp_sock_state_change(struct sock *sk)
+{
+	if (sk_has_sleeper(sk))
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN);
+}
+
+static void mp_sock_data_ready(struct sock *sk, int coming)
+{
+	struct mp_struct *mp = container_of(sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor = NULL;
+	struct sk_buff *skb = NULL;
+	struct page_info *info = NULL;
+	struct ethhdr *eth;
+	struct kiocb *iocb = NULL;
+	int len, i;
+	unsigned long flags;
+
+	struct virtio_net_hdr hdr = {
+		.flags = 0,
+		.gso_type = VIRTIO_NET_HDR_GSO_NONE
+	};
+
+	ctor = rcu_dereference(mp->ctor);
+	if (!ctor)
+		return;
+
+	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
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
+				skb_queue_head(&sk->sk_receive_queue,
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
+
+		iocb = create_iocb(info, skb->len + sizeof(hdr));
+		continue;
+
+clean:
+		kfree_skb(skb);
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		kmem_cache_free(ctor->cache, info);
+	}
+	return;
+}
+
+static void mp_sock_write_space(struct sock *sk)
+{
+	if (sk_has_sleeper(sk))
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT);
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
+
+		ifr.ifr_flags |= IFF_MPASSTHRU_EXCL;
+		mp_dev_change_flags(mp->dev, mp->dev->flags | IFF_UP);
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
+	ssize_t result;
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
+static const struct file_operations mp_fops = {
+	.owner  = THIS_MODULE,
+	.llseek = no_llseek,
+	.write  = do_sync_write,
+	.aio_write = mp_chr_aio_write,
+	.poll   = mp_chr_poll,
+	.unlocked_ioctl = mp_chr_ioctl,
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
+
+	port = dev->mp_port;
+	if (port == NULL)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_UNREGISTER:
+			sock = dev->mp_port->sock;
+			mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+			do_unbind(mp->mfile);
+			break;
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
+	int ret = 0;
+
+	ret = misc_register(&mp_miscdev);
+	if (ret)
+		printk(KERN_ERR "mp: Can't register misc device\n");
+	else {
+		printk(KERN_INFO "Registering mp misc device - minor = %d\n",
+			mp_miscdev.minor);
+		register_netdevice_notifier(&mp_notifier_block);
+	}
+	return ret;
+}
+
+void mp_cleanup(void)
+{
+	unregister_netdevice_notifier(&mp_notifier_block);
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
diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
new file mode 100644
index 0000000..e3983d3
--- /dev/null
+++ b/include/linux/mpassthru.h
@@ -0,0 +1,29 @@
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
+#ifdef __KERNEL__
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+struct socket *mp_get_socket(struct file *);
+#else
+#include <linux/err.h>
+#include <linux/errno.h>
+struct file;
+struct socket;
+static inline struct socket *mp_get_socket(struct file *f)
+{
+	return ERR_PTR(-EINVAL);
+}
+#endif /* CONFIG_MEDIATE_PASSTHRU */
+#endif /* __KERNEL__ */
+#endif /* __MPASSTHRU_H */
-- 
1.5.4.4

