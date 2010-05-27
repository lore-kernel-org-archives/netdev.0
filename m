From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread
	workqueue attached to the current task's cgroup
Date: Thu, 27 May 2010 14:44:48 +0200
Message-ID: <20100527124448.GA4241@redhat.com>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Tejun Heo <tj@kernel.org>, Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100527091426.GA6308@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/27, Michael S. Tsirkin wrote:
>
> On Tue, May 18, 2010 at 05:04:51PM -0700, Sridhar Samudrala wrote:
> > Add a new kernel API to create a singlethread workqueue and attach it's
> > task to current task's cgroup and cpumask.
> >
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>
> Could someone familiar with workqueue code please comment on whether
> this patch is suitable for 2.6.35?
>
> It is needed to fix the case where vhost user might cause a kernel
> thread to consume more CPU than allowed by the cgroup.
> Should I merge it through the vhost tree?
> Ack for this?

I don't understand the reasons for this patch, but this doesn't matter.

I don't really see any need to change workqueue.c,

> > +static struct task_struct *get_singlethread_wq_task(struct workqueue_struct *wq)
> > +{
> > +	return (per_cpu_ptr(wq->cpu_wq, singlethread_cpu))->thread;
> > +}

(Not sure this trivial static helper with the single caller makes sense, but
 see below)

> > +/* Create a singlethread workqueue and attach it's task to the current task's
> > + * cgroup and set it's cpumask to the current task's cpumask.
> > + */
> > +struct workqueue_struct *create_singlethread_workqueue_in_current_cg(char *name)
> > +{
> > +	struct workqueue_struct *wq;
> > +	struct task_struct *task;
> > +	cpumask_var_t mask;
> > +
> > +	wq = create_singlethread_workqueue(name);
> > +	if (!wq)
> > +		goto out;
> > +
> > +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> > +		goto err;
> > +			
> > +	if (sched_getaffinity(current->pid, mask))
> > +		goto err;
> > +
> > +	task = get_singlethread_wq_task(wq);
> > +	if (sched_setaffinity(task->pid, mask))
> > +		goto err;
> > +
> > +	if (cgroup_attach_task_current_cg(task))
> > +		goto err;
> > +out:	
> > +	return wq;
> > +err:
> > +	destroy_workqueue(wq);
> > +	wq = NULL;
> > +	goto out;
> > +}

Instead, cgroup.c (or whoever needs this) can do

	struct move_struct {
		struct work_struct work;
		int ret;
	};

	static void move_func(struct work_struct *work)
	{
		struct move_struct *move = container_of(...);

		if (cgroup_attach_task_current_cg(current))
			ret = -EANY;
	}

	static struct workqueue_struct *create_singlethread_workqueue_in_current_cg(char *name)
	{
		struct workqueue_struct *wq;
		struct move_struct move = {
			.work = __WORK_INITIALIZER(move_func);
		};

		wq = create_singlethread_workqueue(name);
		if (!wq)
			return NULL;

		queue_work(&move.work);
		flush_work(&move.work);

		if (move.ret) {
			destroy_workqueue(wq);
			wq = NULL;
		}

		return wq;
	}

Or. Just export wq_per_cpu() from workqueue.c (probably with a better name) and
use it like the patch does.

But, imho, create_singlethread_workqueue_in_current_cg() does not belong
to  workqueue.c.

Oleg.
