From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Mon, 26 Jul 2010 10:51:28 -0700
Message-ID: <1280166688.3375.5.camel@localhost>
References: <20100701130816.GB32223@redhat.com>
	 <1277991024.1917.108.camel@laptop> <20100701133956.GD32223@redhat.com>
	 <4C2CA5C5.4040402@kernel.org> <20100701144624.GA11171@redhat.com>
	 <4C2CABF2.2020801@kernel.org> <1277996135.1917.198.camel@laptop>
	 <4C2E2987.9040702@us.ibm.com> <1278094270.1917.288.camel@laptop>
	 <20100702210637.GA12433@redhat.com>  <20100726171230.GA27644@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:37946 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab0GZRvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 13:51:47 -0400
In-Reply-To: <20100726171230.GA27644@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-07-26 at 20:12 +0300, Michael S. Tsirkin wrote:
> On Fri, Jul 02, 2010 at 11:06:37PM +0200, Oleg Nesterov wrote:
> > On 07/02, Peter Zijlstra wrote:
> > >
> > > On Fri, 2010-07-02 at 11:01 -0700, Sridhar Samudrala wrote:
> > > >
> > > >  Does  it (Tejun's kthread_clone() patch) also  inherit the
> > > > cgroup of the caller?
> > >
> > > Of course, its a simple do_fork() which inherits everything just as you
> > > would expect from a similar sys_clone()/sys_fork() call.
> > 
> > Yes. And I'm afraid it can inherit more than we want. IIUC, this is called
> > from ioctl(), right?
> > 
> > Then the new thread becomes the natural child of the caller, and it shares
> > ->mm with the parent. And files, dup_fd() without CLONE_FS.
> > 
> > Signals. Say, if you send SIGKILL to this new thread, it can't sleep in
> > TASK_INTERRUPTIBLE or KILLABLE after that. And this SIGKILL can be sent
> > just because the parent gets SIGQUIT or abother coredumpable signal.
> > Or the new thread can recieve SIGSTOP via ^Z.
> > 
> > Perhaps this is OK, I do not know. Just to remind that kernel_thread()
> > is merely clone(CLONE_VM).
> > 
> > Oleg.
> 
> With some machinery to stop it later, yes.
> Oleg, how does the below look to you?
> 
> Here I explicitly drop the fds so we don't share them.
> CLONE_VM takes care of sharing the mm I think.
> About signals - for the vhost-net use this is OK as we use
> uninterruptible sleep anyway (like the new kthread_worker does).
> 
> This code seems to work fine for me so far - any comments?
> 
> ---
> 
> diff --git a/include/linux/kthread.h b/include/linux/kthread.h
> index aabc8a1..72c7b17 100644
> --- a/include/linux/kthread.h
> +++ b/include/linux/kthread.h
> @@ -9,6 +9,11 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
>  				   const char namefmt[], ...)
>  	__attribute__((format(printf, 3, 4)));
> 
> +struct task_struct *kthread_create_inherit(int (*threadfn)(void *data),
> +					   void *data,
> +					   const char namefmt[], ...)
> +	__attribute__((format(printf, 3, 4)));
> +
>  /**
>   * kthread_run - create and wake a thread.
>   * @threadfn: the function to run until signal_pending(current).
> diff --git a/kernel/kthread.c b/kernel/kthread.c
> index 83911c7..b81588c 100644
> --- a/kernel/kthread.c
> +++ b/kernel/kthread.c
> @@ -149,6 +149,38 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
>  }
>  EXPORT_SYMBOL(kthread_create);
> 
> +/* Same as kthread_create, but inherit attributes (cgroups, priority, CPU mask)
> + * from current. */
> +struct task_struct *kthread_create_inherit(int (*threadfn)(void *data),
> +					   void *data,
> +					   const char namefmt[],
> +					   ...)
> +{
> +	struct kthread_create_info create;
> +
> +	create.threadfn = threadfn;
> +	create.data = data;
> +	init_completion(&create.done);
> +
> +	create_kthread(&create);
> +	wait_for_completion(&create.done);
> +
> +	if (!IS_ERR(create.result)) {
> +		va_list args;
> +
> +		/* Don't share files with parent as drivers use release for
> +		 * close on exit, etc. */
> +		exit_files(create.result);
> +
> +		va_start(args, namefmt);
> +		vsnprintf(create.result->comm, sizeof(create.result->comm),
> +			  namefmt, args);
> +		va_end(args);
> +	}
> +	return create.result;
> +}
> +EXPORT_SYMBOL(kthread_create_inherit);
> +
>  /**
>   * kthread_bind - bind a just-created kthread to a cpu.
>   * @p: thread created by kthread_create().


I have been testing out a similar patch that uses kernel_thread() without CLONE_FILES
flag rather than create_kthread() and then closing the files.
Either version should be fine.

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index aabc8a1..634eaf7 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -9,6 +9,11 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 				   const char namefmt[], ...)
 	__attribute__((format(printf, 3, 4)));
 
+struct task_struct *kthread_clone(int (*threadfn)(void *data),
+				  void *data,
+				  const char namefmt[], ...)
+	__attribute__((format(printf, 3, 4)));
+
 /**
  * kthread_run - create and wake a thread.
  * @threadfn: the function to run until signal_pending(current).
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 83911c7..806dae5 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -149,6 +149,38 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 }
 EXPORT_SYMBOL(kthread_create);
 
+struct task_struct *kthread_clone(int (*threadfn)(void *data),
+				  void *data,
+				  const char namefmt[],
+				  ...)
+{
+	struct kthread_create_info create;
+	int pid;
+
+	create.threadfn = threadfn;
+	create.data = data;
+	init_completion(&create.done);
+	INIT_LIST_HEAD(&create.list);
+
+	pid = kernel_thread(kthread, &create, CLONE_FS);
+	if (pid < 0) {
+		create.result = ERR_PTR(pid);
+		complete(&create.done);
+	}
+	wait_for_completion(&create.done);
+
+	if (!IS_ERR(create.result)) {
+		va_list args;
+		va_start(args, namefmt);
+		vsnprintf(create.result->comm, sizeof(create.result->comm),
+			  namefmt, args);
+		va_end(args);
+	}
+
+	return create.result;
+}
+EXPORT_SYMBOL(kthread_clone);
+
 /**
  * kthread_bind - bind a just-created kthread to a cpu.
  * @p: thread created by kthread_create().





