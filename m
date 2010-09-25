From: xiaohui.xin@intel.com
Subject: [PATCH v11 17/17]add two new ioctls for mp device.
Date: Sat, 25 Sep 2010 12:27:35 +0800
Message-ID: <b74412a16bc32fe2550461f25156e5b2563c5a2c.1285385607.git.xiaohui.xin@intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

The patch add two ioctls for mp device.
One is for userspace to query how much memory locked to make mp device
run smoothly. Another one is for userspace to set how much meory locked
it really wants.

---
 drivers/vhost/mpassthru.c |  103 +++++++++++++++++++++++----------------------
 include/linux/mpassthru.h |    2 +
 2 files changed, 54 insertions(+), 51 deletions(-)

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
index d86d94c..e3a0199 100644
--- a/drivers/vhost/mpassthru.c
+++ b/drivers/vhost/mpassthru.c
@@ -67,6 +67,8 @@ static int debug;
 #define COPY_THRESHOLD (L1_CACHE_BYTES * 4)
 #define COPY_HDR_LEN   (L1_CACHE_BYTES < 64 ? 64 : L1_CACHE_BYTES)
 
+#define DEFAULT_NEED	((8192*2*2)*4096)
+
 struct frag {
 	u16     offset;
 	u16     size;
@@ -110,7 +112,8 @@ struct page_ctor {
 	int			rq_len;
 	spinlock_t		read_lock;
 	/* record the locked pages */
-	int			lock_pages;
+	int			locked_pages;
+	int			cur_pages;
 	struct rlimit		o_rlim;
 	struct net_device	*dev;
 	struct mpassthru_port	port;
@@ -122,6 +125,7 @@ struct mp_struct {
 	struct net_device       *dev;
 	struct page_ctor	*ctor;
 	struct socket           socket;
+	struct task_struct	*user;
 
 #ifdef MPASSTHRU_DEBUG
 	int debug;
@@ -231,7 +235,8 @@ static int page_ctor_attach(struct mp_struct *mp)
 	ctor->port.ctor = page_ctor;
 	ctor->port.sock = &mp->socket;
 	ctor->port.hash = mp_lookup;
-	ctor->lock_pages = 0;
+	ctor->locked_pages = 0;
+	ctor->cur_pages = 0;
 
 	/* locked by mp_mutex */
 	dev->mp_port = &ctor->port;
@@ -264,37 +269,6 @@ struct page_info *info_dequeue(struct page_ctor *ctor)
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
@@ -323,7 +297,7 @@ static void mp_ki_dtor(struct kiocb *iocb)
 	} else
 		info->ctor->wq_len--;
 	/* Decrement the number of locked pages */
-	info->ctor->lock_pages -= info->pnum;
+	info->ctor->cur_pages -= info->pnum;
 	kmem_cache_free(ext_page_info_cache, info);
 	relinquish_resource(info->ctor);
 
@@ -357,6 +331,7 @@ static int page_ctor_detach(struct mp_struct *mp)
 {
 	struct page_ctor *ctor;
 	struct page_info *info;
+	struct task_struct *tsk = mp->user;
 	int i;
 
 	/* locked by mp_mutex */
@@ -375,9 +350,9 @@ static int page_ctor_detach(struct mp_struct *mp)
 
 	relinquish_resource(ctor);
 
-	set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
-			   ctor->o_rlim.rlim_cur,
-			   ctor->o_rlim.rlim_max);
+	down_write(&tsk->mm->mmap_sem);
+	tsk->mm->locked_vm -= ctor->locked_pages;
+	up_write(&tsk->mm->mmap_sem);
 
 	/* locked by mp_mutex */
 	ctor->dev->mp_port = NULL;
@@ -514,7 +489,6 @@ static struct page_info *mp_hash_delete(struct page_ctor *ctor,
 {
 	key_mp_t key = mp_hash(info->pages[0], HASH_BUCKETS);
 	struct page_info *tmp = NULL;
-	int i;
 
 	tmp = ctor->hash_table[key];
 	while (tmp) {
@@ -565,14 +539,11 @@ static struct page_info *alloc_page_info(struct page_ctor *ctor,
 	int rc;
 	int i, j, n = 0;
 	int len;
-	unsigned long base, lock_limit;
+	unsigned long base;
 	struct page_info *info = NULL;
 
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
-	lock_limit >>= PAGE_SHIFT;
-
-	if (ctor->lock_pages + count > lock_limit && npages) {
-		printk(KERN_INFO "exceed the locked memory rlimit.");
+	if (ctor->cur_pages + count > ctor->locked_pages) {
+		printk(KERN_INFO "Exceed memory lock rlimt.");
 		return NULL;
 	}
 
@@ -634,7 +605,7 @@ static struct page_info *alloc_page_info(struct page_ctor *ctor,
 			mp_hash_insert(ctor, info->pages[i], info);
 	}
 	/* increment the number of locked pages */
-	ctor->lock_pages += j;
+	ctor->cur_pages += j;
 	return info;
 
 failed:
@@ -1006,12 +977,6 @@ proceed:
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
@@ -1115,8 +1080,10 @@ static long mp_chr_ioctl(struct file *file, unsigned int cmd,
 	struct mp_struct *mp;
 	struct net_device *dev;
 	void __user* argp = (void __user *)arg;
+	unsigned long  __user *limitp = argp;
 	struct ifreq ifr;
 	struct sock *sk;
+	unsigned long limit, locked, lock_limit;
 	int ret;
 
 	ret = -EINVAL;
@@ -1152,6 +1119,7 @@ static long mp_chr_ioctl(struct file *file, unsigned int cmd,
 			goto err_dev_put;
 		}
 		mp->dev = dev;
+		mp->user = current;
 		ret = -ENOMEM;
 
 		sk = sk_alloc(mfile->net, AF_UNSPEC, GFP_KERNEL, &mp_proto);
@@ -1193,6 +1161,39 @@ err_dev_put:
 		ret = do_unbind(mfile);
 		break;
 
+	case MPASSTHRU_SET_MEM_LOCKED:
+		ret = copy_from_user(&limit, limitp, sizeof limit);
+		if (ret < 0)
+			return ret;
+
+		mp = mp_get(mfile);
+		if (!mp)
+			return -ENODEV;
+
+		limit = PAGE_ALIGN(limit) >> PAGE_SHIFT;
+		down_write(&current->mm->mmap_sem);
+		locked = limit + current->mm->locked_vm;
+		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+
+		if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
+			up_write(&current->mm->mmap_sem);
+			mp_put(mfile);
+			return -ENOMEM;
+		}
+		current->mm->locked_vm = locked;
+		up_write(&current->mm->mmap_sem);
+
+		mutex_lock(&mp_mutex);
+		mp->ctor->locked_pages = limit;
+		mutex_unlock(&mp_mutex);
+
+		mp_put(mfile);
+		return 0;
+
+	case MPASSTHRU_GET_MEM_LOCKED_NEED:
+		limit = DEFAULT_NEED;
+		return copy_to_user(limitp, &limit, sizeof limit);
+
 	default:
 		break;
 	}
diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
index ba8f320..083e9f7 100644
--- a/include/linux/mpassthru.h
+++ b/include/linux/mpassthru.h
@@ -7,6 +7,8 @@
 /* ioctl defines */
 #define MPASSTHRU_BINDDEV      _IOW('M', 213, int)
 #define MPASSTHRU_UNBINDDEV    _IO('M', 214)
+#define MPASSTHRU_SET_MEM_LOCKED	_IOW('M', 215, unsigned long)
+#define MPASSTHRU_GET_MEM_LOCKED_NEED	_IOR('M', 216, unsigned long)
 
 #ifdef __KERNEL__
 #if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
-- 
1.7.3
