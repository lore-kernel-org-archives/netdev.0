From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread
	workqueue attached to the current task's cgroup
Date: Thu, 27 May 2010 19:41:39 +0300
Message-ID: <20100527164139.GB21710@redhat.com>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <1274977458.10161.11.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Tejun Heo <tj@kernel.org>, Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1274977458.10161.11.camel@w-sridhar.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 27, 2010 at 09:24:18AM -0700, Sridhar Samudrala wrote:
> On Thu, 2010-05-27 at 14:44 +0200, Oleg Nesterov wrote:
> > On 05/27, Michael S. Tsirkin wrote:
> > >
> > > On Tue, May 18, 2010 at 05:04:51PM -0700, Sridhar Samudrala wrote:
> > > > Add a new kernel API to create a singlethread workqueue and attach it's
> > > > task to current task's cgroup and cpumask.
> > > >
> > > > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > >
> > > Could someone familiar with workqueue code please comment on whether
> > > this patch is suitable for 2.6.35?
> > >
> > > It is needed to fix the case where vhost user might cause a kernel
> > > thread to consume more CPU than allowed by the cgroup.
> > > Should I merge it through the vhost tree?
> > > Ack for this?
> > 
> > I don't understand the reasons for this patch, but this doesn't matter.
> > 
> > I don't really see any need to change workqueue.c,
> > 
> > > > +static struct task_struct *get_singlethread_wq_task(struct workqueue_struct *wq)
> > > > +{
> > > > +	return (per_cpu_ptr(wq->cpu_wq, singlethread_cpu))->thread;
> > > > +}
> > 
> > (Not sure this trivial static helper with the single caller makes sense, but
> >  see below)
> > 
> > > > +/* Create a singlethread workqueue and attach it's task to the current task's
> > > > + * cgroup and set it's cpumask to the current task's cpumask.
> > > > + */
> > > > +struct workqueue_struct *create_singlethread_workqueue_in_current_cg(char *name)
> > > > +{
> > > > +	struct workqueue_struct *wq;
> > > > +	struct task_struct *task;
> > > > +	cpumask_var_t mask;
> > > > +
> > > > +	wq = create_singlethread_workqueue(name);
> > > > +	if (!wq)
> > > > +		goto out;
> > > > +
> > > > +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> > > > +		goto err;
> > > > +			
> > > > +	if (sched_getaffinity(current->pid, mask))
> > > > +		goto err;
> > > > +
> > > > +	task = get_singlethread_wq_task(wq);
> > > > +	if (sched_setaffinity(task->pid, mask))
> > > > +		goto err;
> > > > +
> > > > +	if (cgroup_attach_task_current_cg(task))
> > > > +		goto err;
> > > > +out:	
> > > > +	return wq;
> > > > +err:
> > > > +	destroy_workqueue(wq);
> > > > +	wq = NULL;
> > > > +	goto out;
> > > > +}
> > 
> > Instead, cgroup.c (or whoever needs this) can do
> > 
> > 	struct move_struct {
> > 		struct work_struct work;
> > 		int ret;
> > 	};
> > 
> > 	static void move_func(struct work_struct *work)
> > 	{
> > 		struct move_struct *move = container_of(...);
> > 
> > 		if (cgroup_attach_task_current_cg(current))
> 
> We are trying to attach the task associated with workqueue to the
> current task's cgroup. So what we need is 
>    cgroup_attach_task_current_cg(wq->task);
> 
> However there is no interface currently that exports the task associated
> with a workqueue. It is hidden in cpu_workqueue_struct and is only 
> accessible within workqueue.c.
> 
> 
> > 			ret = -EANY;
> > 	}
> > 
> > 	static struct workqueue_struct *create_singlethread_workqueue_in_current_cg(char *name)
> > 	{
> > 		struct workqueue_struct *wq;
> > 		struct move_struct move = {
> > 			.work = __WORK_INITIALIZER(move_func);
> > 		};
> > 
> > 		wq = create_singlethread_workqueue(name);
> > 		if (!wq)
> > 			return NULL;
> > 
> > 		queue_work(&move.work);
> > 		flush_work(&move.work);
> > 
> > 		if (move.ret) {
> > 			destroy_workqueue(wq);
> > 			wq = NULL;
> > 		}
> > 
> > 		return wq;
> > 	}
> > 
> > Or. Just export wq_per_cpu() from workqueue.c (probably with a better name) and
> > use it like the patch does.
> This requires that struct cpu_workqueue_struct and struct
> workqueue_struct are made externally visible by moving them to
> kernel/workqueue.h.
> 
> Instead what about adding the simple helper get_singlethread_wq_task()
> in workqueue.c and exporting it.
> I can add create_singlethread_workqueue_in_current_cg() to cgroup.c
> using this helper routine.

Or to our driver, if that's more palatable.

> Thanks
> Sridhar
> 
