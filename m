From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Wed, 14 Jul 2010 16:26:36 -0700
Message-ID: <1279149996.32374.5.camel@w-sridhar.beaverton.ibm.com>
References: <20100701133956.GD32223@redhat.com>
	 <4C2CA5C5.4040402@kernel.org> <20100701144624.GA11171@redhat.com>
	 <4C2CABF2.2020801@kernel.org> <1277996135.1917.198.camel@laptop>
	 <4C2E2987.9040702@us.ibm.com> <1278094270.1917.288.camel@laptop>
	 <20100702210637.GA12433@redhat.com> <20100704090005.GA8078@redhat.com>
	 <4C3C0EBC.40305@us.ibm.com>  <20100713110939.GA3446@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100713110939.GA3446@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-07-13 at 14:09 +0300, Michael S. Tsirkin wrote: 
> On Mon, Jul 12, 2010 at 11:59:08PM -0700, Sridhar Samudrala wrote:
> > On 7/4/2010 2:00 AM, Michael S. Tsirkin wrote:
> > >On Fri, Jul 02, 2010 at 11:06:37PM +0200, Oleg Nesterov wrote:
> > >>On 07/02, Peter Zijlstra wrote:
> > >>>On Fri, 2010-07-02 at 11:01 -0700, Sridhar Samudrala wrote:
> > >>>>  Does  it (Tejun's kthread_clone() patch) also  inherit the
> > >>>>cgroup of the caller?
> > >>>Of course, its a simple do_fork() which inherits everything just as you
> > >>>would expect from a similar sys_clone()/sys_fork() call.
> > >>Yes. And I'm afraid it can inherit more than we want. IIUC, this is called
> > >>from ioctl(), right?
> > >>
> > >>Then the new thread becomes the natural child of the caller, and it shares
> > >>->mm with the parent. And files, dup_fd() without CLONE_FS.
> > >>
> > >>Signals. Say, if you send SIGKILL to this new thread, it can't sleep in
> > >>TASK_INTERRUPTIBLE or KILLABLE after that. And this SIGKILL can be sent
> > >>just because the parent gets SIGQUIT or abother coredumpable signal.
> > >>Or the new thread can recieve SIGSTOP via ^Z.
> > >>
> > >>Perhaps this is OK, I do not know. Just to remind that kernel_thread()
> > >>is merely clone(CLONE_VM).
> > >>
> > >>Oleg.
> > >
> > >Right. Doing this might break things like flush.  The signal and exit
> > >behaviour needs to be examined carefully. I am also unsure whether
> > >using such threads might be more expensive than inheriting kthreadd.
> > >
> > Should we just leave it to the userspace to set the cgroup/cpumask
> > after qemu starts the guest and
> > the vhost threads?
> > 
> > Thanks
> > Sridhar
> 
> Yes but we can't trust userspace to do this. It's important
> to do it on thread creation: if we don't, malicious userspace
> can create large amount of work exceeding the cgroup limits.
> 
> And the same applies so the affinity: if the qemu process
> is limited to a set of CPUs, it's important to make
> the kernel thread that does work our behalf limited to the same
> set of CPUs.
> 
> This is not unique to vhost, it's just that virt scenarious are affected
> by this more: people seem to run untrusted applications and expect the
> damage to be contained.

OK. So we want to create a thread that is a child of kthreadd, but inherits the cgroup/cpumask
from the caller. How about an exported kthread function kthread_create_in_current_cg() 
that does this?

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index aabc8a1..e0616f0 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -9,6 +9,9 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 				   const char namefmt[], ...)
 	__attribute__((format(printf, 3, 4)));
 
+struct task_struct *kthread_create_in_current_cg(int (*threadfn)(void *data),
+						 void *data, char *name);
+
 /**
  * kthread_run - create and wake a thread.
  * @threadfn: the function to run until signal_pending(current).
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 83911c7..ea4e737 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <trace/events/sched.h>
+#include <linux/cgroup.h>
 
 static DEFINE_SPINLOCK(kthread_create_lock);
 static LIST_HEAD(kthread_create_list);
@@ -149,6 +150,42 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 }
 EXPORT_SYMBOL(kthread_create);
 
+struct task_struct *kthread_create_in_current_cg(int (*threadfn)(void *data),
+						 void *data, char *name)
+{
+	struct task_struct *worker;
+	cpumask_var_t mask;
+	int ret = -ENOMEM;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		goto out_free_mask;
+
+	worker = kthread_create(threadfn, data, "%s-%d", name, current->pid);
+	if (IS_ERR(worker))
+		goto out_free_mask;
+
+	ret = sched_getaffinity(current->pid, mask);
+	if (ret)
+		goto out_stop_worker;
+
+	ret = sched_setaffinity(worker->pid, mask);
+	if (ret)
+		goto out_stop_worker;
+
+	ret = cgroup_attach_task_current_cg(worker);
+	if (ret)
+		goto out_stop_worker;
+
+	return worker;
+
+out_stop_worker:
+	kthread_stop(worker);
+out_free_mask:
+	free_cpumask_var(mask);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(kthread_create_in_current_cg);
+
 /**
  * kthread_bind - bind a just-created kthread to a cpu.
  * @p: thread created by kthread_create().


Thanks
Sridhar

