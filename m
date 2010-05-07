From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v5 15/19] Add basic funcs and ioctl to mp device.
Date: Fri,  7 May 2010 17:35:02 +0800
Message-ID: <1273224906-4874-16-git-send-email-xiaohui.xin@intel.com>
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
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1273224906-4874-15-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

The ioctl is used by mp device to bind an underlying
NIC, it will query hardware capability and declare the
NIC to use external buffers.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---

	memory leak fixed,
	kconfig made,
	do_unbind() made,
	mp_chr_ioctl() cleanup

	by Jeff Dike <jdike@linux.intel.com>

 drivers/vhost/mpassthru.c |  682 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 682 insertions(+), 0 deletions(-)
 create mode 100644 drivers/vhost/mpassthru.c

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
new file mode 100644
index 0000000..33cc123
--- /dev/null
+++ b/drivers/vhost/mpassthru.c
@@ -0,0 +1,682 @@
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
+struct page_info {
+	struct list_head        list;
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
+	struct skb_external_page    ext_page;
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
+struct page_ctor {
+	struct list_head        readq;
+	int 			wq_len;
+	int 			rq_len;
+	spinlock_t      	read_lock;
+	struct kmem_cache   	*cache;
+	/* record the locked pages */
+	int			lock_pages;
+	struct rlimit		o_rlim;
+	struct net_device   	*dev;
+	struct mpassthru_port	port;
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
+	ctor->rq_len = 0;
+	ctor->wq_len = 0;
+
+	dev_hold(dev);
+	ctor->dev = dev;
+	ctor->port.ctor = NULL;
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
+/* Ops structure to mimic raw sockets with mp device */
+static const struct proto_ops mp_socket_ops = {
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
+		sk->sk_destruct = NULL;
+		sk->sk_data_ready = NULL;
+		sk->sk_write_space = NULL;
+		sk->sk_state_change = NULL;
+		ret = mp_attach(mp, file);
+		if (ret < 0)
+			goto err_free_sk;
+
+		ret = page_ctor_attach(mp);
+		if (ret < 0)
+			goto err_free_sk;
+
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
-- 
1.5.4.4

