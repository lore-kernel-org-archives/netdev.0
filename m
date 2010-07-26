From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Mon, 26 Jul 2010 20:12:30 +0300
Message-ID: <20100726171230.GA27644@redhat.com>
References: <20100701130816.GB32223@redhat.com>
 <1277991024.1917.108.camel@laptop>
 <20100701133956.GD32223@redhat.com>
 <4C2CA5C5.4040402@kernel.org>
 <20100701144624.GA11171@redhat.com>
 <4C2CABF2.2020801@kernel.org>
 <1277996135.1917.198.camel@laptop>
 <4C2E2987.9040702@us.ibm.com>
 <1278094270.1917.288.camel@laptop>
 <20100702210637.GA12433@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	Sridhar Samudrala <sri@us.ibm.com>, Tejun Heo <tj@kernel.org>,
	Ingo Molnar <mingo@elte.hu>, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100702210637.GA12433@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 02, 2010 at 11:06:37PM +0200, Oleg Nesterov wrote:
> On 07/02, Peter Zijlstra wrote:
> >
> > On Fri, 2010-07-02 at 11:01 -0700, Sridhar Samudrala wrote:
> > >
> > >  Does  it (Tejun's kthread_clone() patch) also  inherit the
> > > cgroup of the caller?
> >
> > Of course, its a simple do_fork() which inherits everything just as you
> > would expect from a similar sys_clone()/sys_fork() call.
> 
> Yes. And I'm afraid it can inherit more than we want. IIUC, this is called
> from ioctl(), right?
> 
> Then the new thread becomes the natural child of the caller, and it shares
> ->mm with the parent. And files, dup_fd() without CLONE_FS.
> 
> Signals. Say, if you send SIGKILL to this new thread, it can't sleep in
> TASK_INTERRUPTIBLE or KILLABLE after that. And this SIGKILL can be sent
> just because the parent gets SIGQUIT or abother coredumpable signal.
> Or the new thread can recieve SIGSTOP via ^Z.
> 
> Perhaps this is OK, I do not know. Just to remind that kernel_thread()
> is merely clone(CLONE_VM).
> 
> Oleg.

With some machinery to stop it later, yes.
Oleg, how does the below look to you?

Here I explicitly drop the fds so we don't share them.
CLONE_VM takes care of sharing the mm I think.
About signals - for the vhost-net use this is OK as we use
uninterruptible sleep anyway (like the new kthread_worker does).

This code seems to work fine for me so far - any comments?

---

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index aabc8a1..72c7b17 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -9,6 +9,11 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 				   const char namefmt[], ...)
 	__attribute__((format(printf, 3, 4)));
 
+struct task_struct *kthread_create_inherit(int (*threadfn)(void *data),
+					   void *data,
+					   const char namefmt[], ...)
+	__attribute__((format(printf, 3, 4)));
+
 /**
  * kthread_run - create and wake a thread.
  * @threadfn: the function to run until signal_pending(current).
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 83911c7..b81588c 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -149,6 +149,38 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 }
 EXPORT_SYMBOL(kthread_create);
 
+/* Same as kthread_create, but inherit attributes (cgroups, priority, CPU mask)
+ * from current. */
+struct task_struct *kthread_create_inherit(int (*threadfn)(void *data),
+					   void *data,
+					   const char namefmt[],
+					   ...)
+{
+	struct kthread_create_info create;
+
+	create.threadfn = threadfn;
+	create.data = data;
+	init_completion(&create.done);
+
+	create_kthread(&create);
+	wait_for_completion(&create.done);
+
+	if (!IS_ERR(create.result)) {
+		va_list args;
+
+		/* Don't share files with parent as drivers use release for
+		 * close on exit, etc. */
+		exit_files(create.result);
+
+		va_start(args, namefmt);
+		vsnprintf(create.result->comm, sizeof(create.result->comm),
+			  namefmt, args);
+		va_end(args);
+	}
+	return create.result;
+}
+EXPORT_SYMBOL(kthread_create_inherit);
+
 /**
  * kthread_bind - bind a just-created kthread to a cpu.
  * @p: thread created by kthread_create().
