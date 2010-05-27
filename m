From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread
	workqueue attached to the current task's cgroup
Date: Thu, 27 May 2010 12:14:26 +0300
Message-ID: <20100527091426.GA6308@redhat.com>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Tejun Heo <tj@kernel.org>, Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Andi Kleen <ak@linux.intel.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 18, 2010 at 05:04:51PM -0700, Sridhar Samudrala wrote:
> Add a new kernel API to create a singlethread workqueue and attach it's
> task to current task's cgroup and cpumask.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Could someone familiar with workqueue code please comment on whether
this patch is suitable for 2.6.35?

It is needed to fix the case where vhost user might cause a kernel
thread to consume more CPU than allowed by the cgroup.
Should I merge it through the vhost tree?
Ack for this?

Thanks!

> diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
> index 9466e86..6d6f301 100644
> --- a/include/linux/workqueue.h
> +++ b/include/linux/workqueue.h
> @@ -211,6 +211,7 @@ __create_workqueue_key(const char *name, int singlethread,
>  #define create_freezeable_workqueue(name) __create_workqueue((name), 1, 1, 0)
>  #define create_singlethread_workqueue(name) __create_workqueue((name), 1, 0, 0)
>  
> +extern struct workqueue_struct *create_singlethread_workqueue_in_current_cg(char *name); 
>  extern void destroy_workqueue(struct workqueue_struct *wq);
>  
>  extern int queue_work(struct workqueue_struct *wq, struct work_struct *work);
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 5bfb213..6ba226e 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -35,6 +35,7 @@
>  #include <linux/lockdep.h>
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/workqueue.h>
> +#include <linux/cgroup.h>
>  
>  /*
>   * The per-CPU workqueue (if single thread, we always use the first
> @@ -193,6 +194,45 @@ static const struct cpumask *cpu_singlethread_map __read_mostly;
>   */
>  static cpumask_var_t cpu_populated_map __read_mostly;
>  
> +static struct task_struct *get_singlethread_wq_task(struct workqueue_struct *wq)
> +{
> +	return (per_cpu_ptr(wq->cpu_wq, singlethread_cpu))->thread;
> +}
> +
> +/* Create a singlethread workqueue and attach it's task to the current task's
> + * cgroup and set it's cpumask to the current task's cpumask.
> + */
> +struct workqueue_struct *create_singlethread_workqueue_in_current_cg(char *name)
> +{
> +	struct workqueue_struct *wq;
> +	struct task_struct *task;
> +	cpumask_var_t mask;
> +
> +	wq = create_singlethread_workqueue(name);
> +	if (!wq)
> +		goto out;
> +
> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> +		goto err;
> +			
> +	if (sched_getaffinity(current->pid, mask))
> +		goto err;
> +
> +	task = get_singlethread_wq_task(wq);
> +	if (sched_setaffinity(task->pid, mask))
> +		goto err;
> +
> +	if (cgroup_attach_task_current_cg(task))
> +		goto err;
> +out:	
> +	return wq;
> +err:
> +	destroy_workqueue(wq);
> +	wq = NULL;
> +	goto out;
> +}
> +EXPORT_SYMBOL_GPL(create_singlethread_workqueue_in_current_cg);
> +
>  /* If it's single threaded, it isn't in the list of workqueues. */
>  static inline int is_wq_single_threaded(struct workqueue_struct *wq)
>  {
> 	
