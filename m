From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Tue, 30 May 2017 08:52:14 -0700
Message-ID: <a6bf362c-9df9-f387-bac3-ab5516e4cb68@fb.com>
References: <20170526055549.557818-1-ast@fb.com>
 <20170526055549.557818-2-ast@fb.com>
 <20170529091253.lopsd33qticsbgii@hirez.programming.kicks-ass.net>
 <20170529093918.xmbijgozjrfi22ru@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170529093918.xmbijgozjrfi22ru@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/29/17 2:39 AM, Peter Zijlstra wrote:
>
>
> Do we want something like the below to replace much of the above?
>
> 	if (!perf_event_valid_local(event, NULL, cpu))
> 		goto err_out;
>
> Seems to be roughly what you're after, although I suppose @cpu might be
> hard to determine a priory, so maybe we should allow a magic value to
> short-circuit that test.
>
> ---
>  kernel/events/core.c | 30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
>
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 8d6acaeeea17..a7dc34f19568 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -3630,6 +3630,36 @@ static inline u64 perf_event_count(struct perf_event *event)
>  }
>
>  /*
> + * perf_event_valid_local() - validates if the event is usable by perf_event_read_local()
> + * event: the event to validate
> + * task:  the task the @event will be used in
> + * cpu:   the cpu the @event will be used on
> + *
> + * In case one wants to disallow all per-task events, use @task = NULL.
> + * In case one wants to disallow all per-cpu events, use @cpu = -1.
> + */
> +bool perf_event_valid_local(struct perf_event *event, struct task_struct *task, int cpu)
> +{
> +	/* See perf_event_read_local() for the reasons for these tests */
> +
> +	if ((event->attach_state & PERF_ATTACH_TASK) &&
> +	    event->hw.target != task)
> +		return false;
> +
> +	if (!(event->attach_state & PERF_ATTACH_TASK) &&
> +	    event->cpu != cpu)
> +		return false;

we do if (unlikely(event->oncpu != cpu))
as dynamic check inside bpf_perf_event_read(), since we cannot do it
statically at perf_event_array update time.
If we drop the above 'if' and keep 'task==null' trick,
then indeed we can use this function as static check.

Right now we're trying to keep as many checks as possible as
static checks to make bpf_perf_event_read() faster.
I guess we can drop that approach and do perf_event_valid_local()
check for every read since perf_event_read_local() does all the
same checks anyway.
So how about converting all WARN_ON in perf_event_read_local()
into 'return -EINVAL' and change func proto into:
int perf_event_read_local(struct perf_event *even, u64 *counter_val)

 > I cannot find reason for this comment. That is, why would
 > perf_event_read_local() not support those two types?

I don't know. What is the meaning of
reading tracepoint/breakpoint counter?
Because of 'event->oncpu != cpu' dynamic check all counters are
expected to be per-cpu. I'm not sure how uncore counters work.
What do they have in event->oncpu? -1? I guess they have pmu->count?
So we cannot read them from bpf program anyway?

If we change warn_ons in perf_event_read_local() to returns
them we can make per-task counters working.
User side will open per-task counter and bpf program will
do current->pid != expected_pid check before calling
bpf_perf_event_read(). bpf scripts often do that already.

int perf_event_read_local(struct perf_event *even, u64 *counter_val)
{
   local_irq_save(flags);
   if ((event->attach_state & PERF_ATTACH_TASK) &&
        event->hw.target != current)
     return -EINVAL;

   if (!(event->attach_state & PERF_ATTACH_TASK) &&
       event->cpu != smp_processor_id()
     return -EINVAL;
   ... inherit and pmu->count checks here ...
   *counter_val = local64_read(&event->count)
   local_irq_restore(flags);
   return 0;
}

thoughts?
