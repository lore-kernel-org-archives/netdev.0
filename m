From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] connector: add an event for monitoring process tracers
Date: Wed, 13 Jul 2011 17:09:42 +0200
Message-ID: <20110713150942.GA4850@redhat.com>
References: <1310502757-32103-1-git-send-email-vzapolskiy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"David S. Miller" <davem@davemloft.net>,
	Roland McGrath <roland@redhat.com>, netdev@vger.kernel.org
To: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755093Ab1GMPME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 11:12:04 -0400
Content-Disposition: inline
In-Reply-To: <1310502757-32103-1-git-send-email-vzapolskiy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12, Vladimir Zapolskiy wrote:
>
> Note, a detach signal is not emitted, if a tracer process terminates
> without explicit PTRACE_DETACH request. Such cases can be covered
> listening to PROC_EVENT_EXIT connector events.

Hmm. More and more reasons to make the implicit detach sleepable...

But. There is another case. The (dead) tracee can be detached via
do_wait(). Perhaps this falls into "covered listening to EXIT" too,
but imho makes sense to document in the changelog. Oh, and probably
we will add the ability to detach a zombie...

I don't really understand why do you need this, but I won't argue.

As for the patch,

> +void proc_ptrace_connector(struct task_struct *task)
> +{
> +	struct cn_msg *msg;
> +	struct proc_event *ev;
> +	struct timespec ts;
> +	__u8 buffer[CN_PROC_MSG_SIZE];
> +	struct task_struct *tracer;
> +
> +	if (atomic_read(&proc_event_num_listeners) < 1)
> +		return;
> +
> +	msg = (struct cn_msg *)buffer;
> +	ev = (struct proc_event *)msg->data;
> +	get_seq(&msg->seq, &ev->cpu);
> +	ktime_get_ts(&ts); /* get high res monotonic timestamp */
> +	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
> +	ev->what = PROC_EVENT_PTRACE;
> +	ev->event_data.ptrace.process_pid  = task->pid;
> +	ev->event_data.ptrace.process_tgid = task->tgid;
> +
> +	rcu_read_lock();
> +	tracer = tracehook_tracer_task(task);
> +	if (tracer) {
> +		ev->event_data.ptrace.tracer_pid  = tracer->pid;
> +		ev->event_data.ptrace.tracer_tgid = tracer->tgid;
> +	} else {
> +		ev->event_data.ptrace.tracer_pid  = 0;
> +		ev->event_data.ptrace.tracer_tgid = 0;
> +	}

This doesn't look right. The code uses tracehook_tracer_task() to
figure out whether this task traced or not. But this is racy.

ptrace_attach:

	...attach...

	/* WINDOW */

	proc_ptrace_connector(task);

The task can exit in between, and the caller's subthread can do
wait4() and release it. In this case proc_ptrace_connector() will
see tracehook_tracer_task() == NULL and report "detach".

The similar race in ptrace_detach() path. Another tracer can attach
to this task before we proc_ptrace_connector().

I think proc_ptrace_connector() needs the explicit "task_struct *tracer"
argument, NULL if ptrace_detach(). Or a simple boolean, the tracer is
current.

If you think this is fine - I won't argue.



But in any case, please rediff against

	git://git.kernel.org/pub/scm/linux/kernel/git/oleg/misc.git ptrace

tracehook_tracer_task() was removed, and

> @@ -260,6 +261,9 @@ out:
>  	if (wait_trap)
>  		wait_event(current->signal->wait_chldexit,
>  			   !(task->group_stop & GROUP_STOP_TRAPPING));
> +	if (!retval)
> +		proc_ptrace_connector(task);
> +
>  	return retval;
>  }

this chunk probably should be updated.

Oleg.

