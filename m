From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] Return value from schedule()
Date: Thu, 4 Sep 2008 10:07:39 -0600
Message-ID: <20080904160739.GK2772@parisc-linux.org>
References: <20080827204626.4b65862f@extreme> <20080828111323.GI7908@solarflare.com> <20080903155713.7fab2e19@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>,
	Linus Torvalds <torvalds@osdl.org>,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080903155713.7fab2e19@extreme>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In some circumstances, you want to wait for an event to happen.  let's
assume that it's a hardware event, so you can't just add a notifier of
some kind, you have to poll.  Here's an example:

On Wed, Sep 03, 2008 at 03:57:13PM -0700, Stephen Hemminger wrote:
>  			return -ETIMEDOUT;
> -		udelay(10);
> +		if (signal_pending(current))
> +			return -EINTR;
> +		schedule();

If there's no other task ready to run, schedule() could return in much
less than 10 microseconds (actually, it could return in much less than
10 microseconds even if another task does run, but let's ignore that case).

If schedule() returned whether or not it had scheduled another task, we
could do something like:

		if (!schedule())
			udelay(10);

Please consider this patch:

It can be useful to know whether a call to schedule() ran another task
or not.  For example, if you're giving up the CPU while waiting for an
event to happen, you might want to delay if no other process wants the
CPU to ensure you're not just bashing away at a device that is unlikely
to have finished yet.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5270d44..39c6ef9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -329,7 +329,7 @@ extern signed long schedule_timeout(signed long timeout);
 extern signed long schedule_timeout_interruptible(signed long timeout);
 extern signed long schedule_timeout_killable(signed long timeout);
 extern signed long schedule_timeout_uninterruptible(signed long timeout);
-asmlinkage void schedule(void);
+asmlinkage int schedule(void);
 
 struct nsproxy;
 struct user_namespace;
diff --git a/kernel/sched.c b/kernel/sched.c
index 04160d2..ba3ab9a 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4337,8 +4337,9 @@ pick_next_task(struct rq *rq, struct task_struct *prev)
 
 /*
  * schedule() is the main scheduler function.
+ * It returns 1 if we scheduled a new task and 0 if no other task was chosen.
  */
-asmlinkage void __sched schedule(void)
+asmlinkage int __sched schedule(void)
 {
 	struct task_struct *prev, *next;
 	unsigned long *switch_count;
@@ -4411,6 +4412,7 @@ need_resched_nonpreemptible:
 	preempt_enable_no_resched();
 	if (unlikely(test_thread_flag(TIF_NEED_RESCHED)))
 		goto need_resched;
+	return (next != prev);
 }
 EXPORT_SYMBOL(schedule);
 

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
