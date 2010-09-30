From: xiaohui.xin@intel.com
Subject: [PATCH v12 17/17]add two new ioctls for mp device.
Date: Thu, 30 Sep 2010 22:04:34 +0800
Message-ID: <1c5d7b4e649b8542f6f91b6d289622f3a7393728.1285853725.git.xiaohui.xin@intel.com>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

The patch add two ioctls for mp device.
One is for userspace to query how much memory locked to make mp device
run smoothly. Another one is for userspace to set how much meory locked
it really wants.

---
 drivers/vhost/mpassthru.c |  109 +++++++++++++++++++++++----------------------
 include/linux/mpassthru.h |    2 +
 2 files changed, 58 insertions(+), 53 deletions(-)

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
index 1a114d1..41aa59e 100644
--- a/drivers/vhost/mpassthru.c
+++ b/drivers/vhost/mpassthru.c
@@ -54,6 +54,8 @@
 #define COPY_THRESHOLD (L1_CACHE_BYTES * 4)
 #define COPY_HDR_LEN   (L1_CACHE_BYTES < 64 ? 64 : L1_CACHE_BYTES)
 
+#define DEFAULT_NEED   ((8192*2*2)*4096)
+
 struct frag {
 	u16     offset;
 	u16     size;
@@ -102,8 +104,10 @@ struct page_pool {
 	spinlock_t		read_lock;
 	/* record the orignal rlimit */
 	struct rlimit		o_rlim;
-	/* record the locked pages */
-	int			lock_pages;
+	/* userspace wants to locked */
+	int			locked_pages;
+	/* currently locked pages */
+	int                     cur_pages;
 	/* the device according to */
 	struct net_device	*dev;
 	/* the mp_port according to dev */
@@ -117,6 +121,7 @@ struct mp_struct {
 	struct net_device       *dev;
 	struct page_pool	*pool;
 	struct socket           socket;
+	struct task_struct      *user;
 };
 
 struct mp_file {
@@ -207,8 +212,8 @@ static int page_pool_attach(struct mp_struct *mp)
 	pool->port.ctor = page_ctor;
 	pool->port.sock = &mp->socket;
 	pool->port.hash = mp_lookup;
-	pool->lock_pages = 0;
-
+	pool->locked_pages = 0;
+	pool->cur_pages = 0;
 	/* locked by mp_mutex */
 	dev->mp_port = &pool->port;
 	mp->pool = pool;
@@ -236,37 +241,6 @@ struct page_info *info_dequeue(struct page_pool *pool)
 	return info;
 }
 
-static int set_memlock_rlimit(struct page_pool *pool, int resource,
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
-	pool->o_rlim.rlim_cur = old_rlim->rlim_cur;
-	pool->o_rlim.rlim_max = old_rlim->rlim_max;
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
 static void mp_ki_dtor(struct kiocb *iocb)
 {
 	struct page_info *info = (struct page_info *)(iocb->private);
@@ -286,7 +260,7 @@ static void mp_ki_dtor(struct kiocb *iocb)
 		}
 	}
 	/* Decrement the number of locked pages */
-	info->pool->lock_pages -= info->pnum;
+	info->pool->cur_pages -= info->pnum;
 	kmem_cache_free(ext_page_info_cache, info);
 
 	return;
@@ -319,6 +293,7 @@ static int page_pool_detach(struct mp_struct *mp)
 {
 	struct page_pool *pool;
 	struct page_info *info;
+	struct task_struct *tsk = mp->user;
 	int i;
 
 	/* locked by mp_mutex */
@@ -334,9 +309,9 @@ static int page_pool_detach(struct mp_struct *mp)
 		kmem_cache_free(ext_page_info_cache, info);
 	}
 
-	set_memlock_rlimit(pool, RLIMIT_MEMLOCK,
-			   pool->o_rlim.rlim_cur,
-			   pool->o_rlim.rlim_max);
+	down_write(&tsk->mm->mmap_sem);
+	tsk->mm->locked_vm -= pool->locked_pages;
+	up_write(&tsk->mm->mmap_sem);
 
 	/* locked by mp_mutex */
 	pool->dev->mp_port = NULL;
@@ -534,14 +509,11 @@ static struct page_info *alloc_page_info(struct page_pool *pool,
 	int rc;
 	int i, j, n = 0;
 	int len;
-	unsigned long base, lock_limit;
+	unsigned long base;
 	struct page_info *info = NULL;
 
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
-	lock_limit >>= PAGE_SHIFT;
-
-	if (pool->lock_pages + count > lock_limit && npages) {
-		printk(KERN_INFO "exceed the locked memory rlimit.");
+	if (pool->cur_pages + count > pool->locked_pages) {
+		printk(KERN_INFO "Exceed memory lock rlimt.");
 		return NULL;
 	}
 
@@ -603,7 +575,7 @@ static struct page_info *alloc_page_info(struct page_pool *pool,
 			mp_hash_insert(pool, info->pages[i], info);
 	}
 	/* increment the number of locked pages */
-	pool->lock_pages += j;
+	pool->cur_pages += j;
 	return info;
 
 failed:
@@ -890,7 +862,7 @@ copy:
 				info->pages[i] = NULL;
 			}
 	}
-	if (!pool->lock_pages)
+	if (!pool->cur_pages)
 		sock->sk->sk_state_change(sock->sk);
 
 	if (info != NULL) {
@@ -974,12 +946,6 @@ proceed:
 		count--;
 	}
 
-	if (!pool->lock_pages) {
-		set_memlock_rlimit(pool, RLIMIT_MEMLOCK,
-				iocb->ki_user_data * 4096 * 2,
-				iocb->ki_user_data * 4096 * 2);
-	}
-
 	/* Translate address to kernel */
 	info = alloc_page_info(pool, iocb, iov, count, frags, npages, 0);
 	if (!info)
@@ -1081,8 +1047,10 @@ static long mp_chr_ioctl(struct file *file, unsigned int cmd,
 	struct mp_struct *mp;
 	struct net_device *dev;
 	void __user* argp = (void __user *)arg;
+	unsigned long  __user *limitp = argp;
 	struct ifreq ifr;
 	struct sock *sk;
+	unsigned long limit, locked, lock_limit;
 	int ret;
 
 	ret = -EINVAL;
@@ -1122,6 +1090,7 @@ static long mp_chr_ioctl(struct file *file, unsigned int cmd,
 			goto err_dev_put;
 		}
 		mp->dev = dev;
+		mp->user = current;
 		ret = -ENOMEM;
 
 		sk = sk_alloc(mfile->net, AF_UNSPEC, GFP_KERNEL, &mp_proto);
@@ -1166,6 +1135,40 @@ err_dev_put:
 		rtnl_unlock();
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
+		mp->pool->locked_pages = limit;
+		mutex_unlock(&mp_mutex);
+
+		mp_put(mfile);
+		return 0;
+
+	case MPASSTHRU_GET_MEM_LOCKED_NEED:
+		limit = DEFAULT_NEED;
+		return copy_to_user(limitp, &limit, sizeof limit);
+
+
 	default:
 		break;
 	}
diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
index c0973b6..efd12ec 100644
--- a/include/linux/mpassthru.h
+++ b/include/linux/mpassthru.h
@@ -8,6 +8,8 @@
 /* ioctl defines */
 #define MPASSTHRU_BINDDEV      _IOW('M', 213, int)
 #define MPASSTHRU_UNBINDDEV    _IO('M', 214)
+#define MPASSTHRU_SET_MEM_LOCKED       _IOW('M', 215, unsigned long)
+#define MPASSTHRU_GET_MEM_LOCKED_NEED  _IOR('M', 216, unsigned long)
 
 #ifdef __KERNEL__
 #if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
-- 
1.7.3

