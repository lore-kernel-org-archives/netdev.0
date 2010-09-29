From: xiaohui.xin@intel.com
Subject: Re: [PATCH v11 17/17]add two new ioctls for mp device.
Date: Wed, 29 Sep 2010 17:36:28 +0800
Message-ID: <1285752988-5219-1-git-send-email-xiaohui.xin@intel.com>
References: <20100928094800.GG12472@redhat.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100928094800.GG12472@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Michael,
>So here, current might be different from mp->user:
>many processes might share an fd. The result
>will be that you will subtract locked_vm from A but add it to B.
>
>The right thing to do IMO is to store mm on SET_MEM_LOCKED.
>Also be careful about multiple callers etc.
>
>
>> +		locked = limit + current->mm->locked_vm;
>> +		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>> +
>> +		if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
>> +			up_write(&current->mm->mmap_sem);
>> +			mp_put(mfile);
>> +			return -ENOMEM;
>> +		}
>> +		current->mm->locked_vm = locked;
>> +		up_write(&current->mm->mmap_sem);
>> +
>> +		mutex_lock(&mp_mutex);
>> +		mp->ctor->locked_pages = limit;
>
>What if a process calls SET_MEM_LOCKED multiple times
>(or many processes do)? 

How about the patch followed to fix this?

>What if it is called when
>some pages are already locked?

Though some pages are already locked, when the ioctl is called,
But I think it's not so critical, as we still can set the limit as wanted to
ctor->locked_pages, and check with the new limit with ctor->cur_pages.
maybe there are several pages more locked, but not too much, the rlimit
is still useful after that.
Or something I have missed here?

---
 drivers/vhost/mpassthru.c |   34 ++++++++++++++++++++--------------
 include/linux/mpassthru.h |    4 ++--
 2 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
index fc2a073..0965804 100644
--- a/drivers/vhost/mpassthru.c
+++ b/drivers/vhost/mpassthru.c
@@ -101,6 +101,7 @@ struct page_ctor {
 	/* record the locked pages */
 	int			locked_pages;
 	int			cur_pages;
+	unsigned long		orig_locked_vm;	
 	struct net_device	*dev;
 	struct mpassthru_port	port;
 	struct page_info	**hash_table;
@@ -111,7 +112,7 @@ struct mp_struct {
 	struct net_device       *dev;
 	struct page_ctor	*ctor;
 	struct socket           socket;
-	struct task_struct	*user;
+	struct mm_struct	*mm;
 };
 
 struct mp_file {
@@ -222,7 +223,7 @@ static int page_ctor_attach(struct mp_struct *mp)
 	ctor->port.hash = mp_lookup;
 	ctor->locked_pages = 0;
 	ctor->cur_pages = 0;
-
+	ctor->orig_locked_vm = 0;
 	/* locked by mp_mutex */
 	dev->mp_port = &ctor->port;
 	mp->ctor = ctor;
@@ -316,7 +317,6 @@ static int page_ctor_detach(struct mp_struct *mp)
 {
 	struct page_ctor *ctor;
 	struct page_info *info;
-	struct task_struct *tsk = mp->user;
 	int i;
 
 	/* locked by mp_mutex */
@@ -335,9 +335,9 @@ static int page_ctor_detach(struct mp_struct *mp)
 
 	relinquish_resource(ctor);
 
-	down_write(&tsk->mm->mmap_sem);
-	tsk->mm->locked_vm -= ctor->locked_pages;
-	up_write(&tsk->mm->mmap_sem);
+	down_write(&mp->mm->mmap_sem);
+	mp->mm->locked_vm = ctor->orig_locked_vm;
+	up_write(&mp->mm->mmap_sem);
 
 	/* locked by mp_mutex */
 	ctor->dev->mp_port = NULL;
@@ -1104,7 +1104,7 @@ static long mp_chr_ioctl(struct file *file, unsigned int cmd,
 			goto err_dev_put;
 		}
 		mp->dev = dev;
-		mp->user = current;
+		mp->mm = get_task_mm(current);
 		ret = -ENOMEM;
 
 		sk = sk_alloc(mfile->net, AF_UNSPEC, GFP_KERNEL, &mp_proto);
@@ -1154,21 +1154,27 @@ err_dev_put:
 		mp = mp_get(mfile);
 		if (!mp)
 			return -ENODEV;
-
+		mutex_lock(&mp_mutex);
+		if (mp->mm != current->mm) {
+			mutex_unlock(&mp_mutex);
+			return -EPERM;
+		}
 		limit = PAGE_ALIGN(limit) >> PAGE_SHIFT;
-		down_write(&current->mm->mmap_sem);
-		locked = limit + current->mm->locked_vm;
+		down_write(&mp->mm->mmap_sem);
+		if (!mp->ctor->locked_pages)
+			mp->ctor->orig_locked_vm = mp->mm->locked_vm;
+		locked = limit + mp->ctor->orig_locked_vm;
 		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
 		if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
-			up_write(&current->mm->mmap_sem);
+			up_write(&mp->mm->mmap_sem);
+			mutex_unlock(&mp_mutex);
 			mp_put(mfile);
 			return -ENOMEM;
 		}
-		current->mm->locked_vm = locked;
-		up_write(&current->mm->mmap_sem);
+		mp->mm->locked_vm = locked;
+		up_write(&mp->mm->mmap_sem);
 
-		mutex_lock(&mp_mutex);
 		mp->ctor->locked_pages = limit;
 		mutex_unlock(&mp_mutex);
 
-- 
1.7.3
