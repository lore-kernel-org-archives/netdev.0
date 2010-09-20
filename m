From: xiaohui.xin@intel.com
Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
Date: Mon, 20 Sep 2010 16:08:48 +0800
Message-ID: <1284970128-7343-1-git-send-email-xiaohui.xin@intel.com>
References: <20100915112811.GB29267@redhat.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36130 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753162Ab0ITHvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Sep 2010 03:51:48 -0400
In-Reply-To: <20100915112811.GB29267@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

---
Michael,
I have move the ioctl to configure the locked memory to vhost and 
check the limit with mm->locked_vm. please have a look.

Thanks
Xiaohui

 drivers/vhost/mpassthru.c |   74 +++++++++----------------------------------
 drivers/vhost/net.c       |   78 ++++++++++++++++++++++++++++++++++++++------
 include/linux/vhost.h     |    3 ++
 3 files changed, 85 insertions(+), 70 deletions(-)

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
index d86d94c..fd3827b 100644
--- a/drivers/vhost/mpassthru.c
+++ b/drivers/vhost/mpassthru.c
@@ -109,9 +109,6 @@ struct page_ctor {
 	int			wq_len;
 	int			rq_len;
 	spinlock_t		read_lock;
-	/* record the locked pages */
-	int			lock_pages;
-	struct rlimit		o_rlim;
 	struct net_device	*dev;
 	struct mpassthru_port	port;
 	struct page_info	**hash_table;
@@ -231,7 +228,6 @@ static int page_ctor_attach(struct mp_struct *mp)
 	ctor->port.ctor = page_ctor;
 	ctor->port.sock = &mp->socket;
 	ctor->port.hash = mp_lookup;
-	ctor->lock_pages = 0;
 
 	/* locked by mp_mutex */
 	dev->mp_port = &ctor->port;
@@ -264,37 +260,6 @@ struct page_info *info_dequeue(struct page_ctor *ctor)
 	return info;
 }
 
-static int set_memlock_rlimit(struct page_ctor *ctor, int resource,
-			      unsigned long cur, unsigned long max)
-{
-	struct rlimit new_rlim, *old_rlim;
-	int retval;
-
-	if (resource != RLIMIT_MEMLOCK)
-		return -EINVAL;
-	new_rlim.rlim_cur = cur;
-	new_rlim.rlim_max = max;
-
-	old_rlim = current->signal->rlim + resource;
-
-	/* remember the old rlimit value when backend enabled */
-	ctor->o_rlim.rlim_cur = old_rlim->rlim_cur;
-	ctor->o_rlim.rlim_max = old_rlim->rlim_max;
-
-	if ((new_rlim.rlim_max > old_rlim->rlim_max) &&
-			!capable(CAP_SYS_RESOURCE))
-		return -EPERM;
-
-	retval = security_task_setrlimit(resource, &new_rlim);
-	if (retval)
-		return retval;
-
-	task_lock(current->group_leader);
-	*old_rlim = new_rlim;
-	task_unlock(current->group_leader);
-	return 0;
-}
-
 static void relinquish_resource(struct page_ctor *ctor)
 {
 	if (!(ctor->dev->flags & IFF_UP) &&
@@ -322,8 +287,6 @@ static void mp_ki_dtor(struct kiocb *iocb)
 		info->ctor->rq_len--;
 	} else
 		info->ctor->wq_len--;
-	/* Decrement the number of locked pages */
-	info->ctor->lock_pages -= info->pnum;
 	kmem_cache_free(ext_page_info_cache, info);
 	relinquish_resource(info->ctor);
 
@@ -349,7 +312,7 @@ static struct kiocb *create_iocb(struct page_info *info, int size)
 	iocb->ki_dtor(iocb);
 	iocb->private = (void *)info;
 	iocb->ki_dtor = mp_ki_dtor;
-
+	iocb->ki_user_data = info->pnum;
 	return iocb;
 }
 
@@ -375,10 +338,6 @@ static int page_ctor_detach(struct mp_struct *mp)
 
 	relinquish_resource(ctor);
 
-	set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
-			   ctor->o_rlim.rlim_cur,
-			   ctor->o_rlim.rlim_max);
-
 	/* locked by mp_mutex */
 	ctor->dev->mp_port = NULL;
 	dev_put(ctor->dev);
@@ -565,21 +524,23 @@ static struct page_info *alloc_page_info(struct page_ctor *ctor,
 	int rc;
 	int i, j, n = 0;
 	int len;
-	unsigned long base, lock_limit;
+	unsigned long base, lock_limit, locked;
 	struct page_info *info = NULL;
 
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
-	lock_limit >>= PAGE_SHIFT;
+	down_write(&current->mm->mmap_sem);
+	locked     = count + current->mm->locked_vm;
+	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
-	if (ctor->lock_pages + count > lock_limit && npages) {
-		printk(KERN_INFO "exceed the locked memory rlimit.");
-		return NULL;
-	}
+	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK))
+		goto out;
 
 	info = kmem_cache_alloc(ext_page_info_cache, GFP_KERNEL);
 	
 	if (!info)
-		return NULL;
+		goto out;
+
+	up_write(&current->mm->mmap_sem);
+
 	info->skb = NULL;
 	info->next = info->prev = NULL;
 
@@ -633,8 +594,7 @@ static struct page_info *alloc_page_info(struct page_ctor *ctor,
 		for (i = 0; i < j; i++)
 			mp_hash_insert(ctor, info->pages[i], info);
 	}
-	/* increment the number of locked pages */
-	ctor->lock_pages += j;
+
 	return info;
 
 failed:
@@ -642,7 +602,9 @@ failed:
 		put_page(info->pages[i]);
 
 	kmem_cache_free(ext_page_info_cache, info);
-
+	return NULL;
+out:
+	up(&current->mm->mmap_sem);
 	return NULL;
 }
 
@@ -1006,12 +968,6 @@ proceed:
 		count--;
 	}
 
-	if (!ctor->lock_pages || !ctor->rq_len) {
-		set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
-				iocb->ki_user_data * 4096 * 2,
-				iocb->ki_user_data * 4096 * 2);
-	}
-
 	/* Translate address to kernel */
 	info = alloc_page_info(ctor, iocb, iov, count, frags, npages, 0);
 	if (!info)
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index c4bc815..da78837 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -42,6 +42,7 @@ enum {
 };
 
 static struct kmem_cache *notify_cache;
+static struct rlimit orig_rlim;
 
 enum vhost_net_poll_state {
 	VHOST_NET_POLL_DISABLED = 0,
@@ -136,13 +137,7 @@ static void handle_async_rx_events_notify(struct vhost_net *net,
 	struct vhost_log *vq_log = NULL;
 	int rx_total_len = 0;
 	unsigned int head, log, in, out;
-	int size;
-	int count;
-
-	struct virtio_net_hdr_mrg_rxbuf hdr = {
-		.hdr.flags = 0,
-		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
-	};
+	int size, free = 0;
 
 	if (!is_async_vq(vq))
 		return;
@@ -160,7 +155,7 @@ static void handle_async_rx_events_notify(struct vhost_net *net,
 			size = iocb->ki_nbytes;
 			head = iocb->ki_pos;
 			rx_total_len += iocb->ki_nbytes;
-
+			free += iocb->ki_user_data;
 			if (iocb->ki_dtor)
 				iocb->ki_dtor(iocb);
 			kmem_cache_free(net->cache, iocb);
@@ -192,6 +187,7 @@ static void handle_async_rx_events_notify(struct vhost_net *net,
 					size = iocb->ki_nbytes;
 					head = iocb->ki_pos;
 					rx_total_len += iocb->ki_nbytes;
+					free += iocb->ki_user_data;
 
 					if (iocb->ki_dtor)
 						iocb->ki_dtor(iocb);
@@ -211,7 +207,6 @@ static void handle_async_rx_events_notify(struct vhost_net *net,
 					break;
 
 				i++;
-				iocb == NULL;
 				if (count)
 					iocb = notify_dequeue(vq);
 			}
@@ -219,6 +214,10 @@ static void handle_async_rx_events_notify(struct vhost_net *net,
 					&net->dev, vq, vq->heads, hc);
 		}
 	}
+	/* record locked memroy */
+	down_write(&current->mm->mmap_sem);
+	current->mm->locked_vm -= free;
+	up_write(&current->mm->mmap_sem);
 }
 
 static void handle_async_tx_events_notify(struct vhost_net *net,
@@ -227,7 +226,7 @@ static void handle_async_tx_events_notify(struct vhost_net *net,
 	struct kiocb *iocb = NULL;
 	struct list_head *entry, *tmp;
 	unsigned long flags;
-	int tx_total_len = 0;
+	int tx_total_len = 0, free = 0;
 
 	if (!is_async_vq(vq))
 		return;
@@ -242,7 +241,7 @@ static void handle_async_tx_events_notify(struct vhost_net *net,
 		vhost_add_used_and_signal(&net->dev, vq,
 				iocb->ki_pos, 0);
 		tx_total_len += iocb->ki_nbytes;
-
+		free += iocb->ki_user_data;
 		if (iocb->ki_dtor)
 			iocb->ki_dtor(iocb);
 
@@ -253,6 +252,10 @@ static void handle_async_tx_events_notify(struct vhost_net *net,
 		}
 	}
 	spin_unlock_irqrestore(&vq->notify_lock, flags);
+	/* record locked memroy */
+	down_write(&current->mm->mmap_sem);
+	current->mm->locked_vm -= free;
+	up_write(&current->mm->mmap_sem);
 }
 
 static struct kiocb *create_iocb(struct vhost_net *net,
@@ -581,6 +584,7 @@ static void handle_rx_net(struct work_struct *work)
 static int vhost_net_open(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
+	struct rlimit *old_rlim;
 	int r;
 	if (!n)
 		return -ENOMEM;
@@ -597,6 +601,12 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
 	n->cache = NULL;
 
+	old_rlim = current->signal->rlim + RLIMIT_MEMLOCK;
+
+	/* remember the old rlimit value when backend enabled */
+	orig_rlim.rlim_cur = old_rlim->rlim_cur;
+	orig_rlim.rlim_max = old_rlim->rlim_max;
+
 	f->private_data = n;
 
 	return 0;
@@ -659,6 +669,39 @@ static void vhost_net_flush(struct vhost_net *n)
 	vhost_net_flush_vq(n, VHOST_NET_VQ_RX);
 }
 
+static long vhost_net_set_mem_locked(struct vhost_net *n,
+				     unsigned long cur,
+				     unsigned long max)
+{
+	struct rlimit new_rlim, *old_rlim;
+	int retval = 0;
+
+	mutex_lock(&n->dev.mutex);
+	new_rlim.rlim_cur = cur;
+	new_rlim.rlim_max = max;
+
+	old_rlim = current->signal->rlim + RLIMIT_MEMLOCK;
+
+	if ((new_rlim.rlim_max > old_rlim->rlim_max) &&
+			!capable(CAP_SYS_RESOURCE)) {
+		retval = -EPERM;
+		goto err;
+	}
+
+	retval = security_task_setrlimit(RLIMIT_MEMLOCK, &new_rlim);
+	if (retval) {
+		retval = retval;
+		goto err;
+	}
+
+	task_lock(current->group_leader);
+	*old_rlim = new_rlim;
+	task_unlock(current->group_leader);
+err:
+	mutex_unlock(&n->dev.mutex);
+	return retval;
+}
+
 static void vhost_async_cleanup(struct vhost_net *n)
 {
 	/* clean the notifier */
@@ -691,6 +734,10 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
 	vhost_async_cleanup(n);
+	/* return back the rlimit */
+	vhost_net_set_mem_locked(n,
+				 orig_rlim.rlim_cur,
+				 orig_rlim.rlim_max);
 	kfree(n);
 	return 0;
 }
@@ -846,6 +893,7 @@ err:
 	return r;
 }
 
+
 static long vhost_net_reset_owner(struct vhost_net *n)
 {
 	struct socket *tx_sock = NULL;
@@ -913,6 +961,7 @@ static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
 	void __user *argp = (void __user *)arg;
 	u64 __user *featurep = argp;
 	struct vhost_vring_file backend;
+	struct rlimit rlim;
 	u64 features;
 	int r;
 	switch (ioctl) {
@@ -933,6 +982,13 @@ static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
 		return vhost_net_set_features(n, features);
 	case VHOST_RESET_OWNER:
 		return vhost_net_reset_owner(n);
+	case VHOST_SET_MEM_LOCKED:
+		r = copy_from_user(&rlim, argp, sizeof rlim);
+		if (r < 0)
+			return r;
+		return vhost_net_set_mem_locked(n,
+						rlim.rlim_cur,
+						rlim.rlim_max);
 	default:
 		mutex_lock(&n->dev.mutex);
 		r = vhost_dev_ioctl(&n->dev, ioctl, arg);
diff --git a/include/linux/vhost.h b/include/linux/vhost.h
index e847f1e..df93f5a 100644
--- a/include/linux/vhost.h
+++ b/include/linux/vhost.h
@@ -92,6 +92,9 @@ struct vhost_memory {
 /* Specify an eventfd file descriptor to signal on log write. */
 #define VHOST_SET_LOG_FD _IOW(VHOST_VIRTIO, 0x07, int)
 
+/* Specify how much locked memory can be used */
+#define VHOST_SET_MEM_LOCKED	_IOW(VHOST_VIRTIO, 0x08, struct rlimit)
+
 /* Ring setup. */
 /* Set number of descriptors in ring. This parameter can not
  * be modified while ring is running (bound to a device). */
-- 
1.5.4.4

