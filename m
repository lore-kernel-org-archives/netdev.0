From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread
	workqueue attached to the current task's cgroup
Date: Thu, 27 May 2010 19:30:29 +0200
Message-ID: <20100527173029.GB18284@redhat.com>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <1274977458.10161.11.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>,
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

What I am actually worried about is Tejun's rework, I am not sure
cmwq has the "this thread services that wq" property...

On 05/27, Sridhar Samudrala wrote:
>
> On Thu, 2010-05-27 at 14:44 +0200, Oleg Nesterov wrote:
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

I do not see cgroup_attach_task_current_cg() in Linus's tree and thus I do
not now what exactly it does, and of course the code above is only template.

But I think this is easy. Just add "struct cgroup *cgrp" into move_struct
and then move_func() can do cgroup_attach_task(move->cgrp, current) ?

> > Or. Just export wq_per_cpu() from workqueue.c (probably with a better name) and
> > use it like the patch does.
> This requires that struct cpu_workqueue_struct and struct
> workqueue_struct are made externally visible by moving them to
> kernel/workqueue.h.

no, no,

> Instead what about adding the simple helper get_singlethread_wq_task()
> in workqueue.c and exporting it.

Indeed, this is what I meant.

But. I disagree with get_singlethread_wq_task(). If we add this helper,
it should work with the multi-threaded wq's too, and needs the "int cpu"
parameter, ignored when is_wq_single_threaded().

So. Either rename wq_per_cpu() and export it (once again, I do not
mean we should move the body to workqueue.h!), or create the new
helper which just calls wq_per_cpu().

> I can add create_singlethread_workqueue_in_current_cg() to cgroup.c
> using this helper routine.

Imho, this is better.

But please note that it is possible to do without any changes in
workqueue.[ch] afaics, see above.

Oleg.
