From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 12:49:17 +0800
Message-ID: <56286ACD.3060604@huawei.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	"Daniel Borkmann" <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445468283-4592-1-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After applying this patch I'm unable to use perf passing perf_event 
again like this:

  # perf record -a -e evt=cycles -e 
./test_config_map.c/maps.pmu_map.event=evt/ --exclude-perf ls

With -v it output:

...
adding perf_bpf_probe:func_write
adding perf_bpf_probe:func_write to 0x367d6a0
add bpf event perf_bpf_probe:func_write_return and attach bpf program 6
adding perf_bpf_probe:func_write_return
adding perf_bpf_probe:func_write_return to 0x3a7fc40
mmap size 528384B
ERROR: failed to insert value to pmu_map[0]
ERROR: Apply config to BPF failed: Invalid option for map, add -v to see 
detail
Opening /sys/kernel/debug/tracing//kprobe_events write=
...

Looks like perf sets attr.inherit for cycles? I'll look into this problem.

Thank you.

On 2015/10/22 6:58, Alexei Starovoitov wrote:
> Fix safety checks for bpf_perf_event_read():
> - only non-inherited events can be added to perf_event_array map
>    (do this check statically at map insertion time)
> - dynamically check that event is local and !pmu->count
> Otherwise buggy bpf program can cause kernel splat.
>
> Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
> v1->v2: fix compile in case of !CONFIG_PERF_EVENTS
>
> This patch is on top of
> http://patchwork.ozlabs.org/patch/533585/
> to avoid conflicts.
> Even in the worst case the crash is not possible.
> Only warn_on_once, so imo net-next is ok.
>
>   kernel/bpf/arraymap.c |    9 +++++----
>   kernel/events/core.c  |   16 ++++++++++------
>   2 files changed, 15 insertions(+), 10 deletions(-)
>
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index e3cfe46b074f..75529cc94304 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -294,10 +294,11 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
>   	if (IS_ERR(attr))
>   		return (void *)attr;
>   
> -	if (attr->type != PERF_TYPE_RAW &&
> -	    !(attr->type == PERF_TYPE_SOFTWARE &&
> -	      attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
> -	    attr->type != PERF_TYPE_HARDWARE) {
> +	if ((attr->type != PERF_TYPE_RAW &&
> +	     !(attr->type == PERF_TYPE_SOFTWARE &&
> +	       attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
> +	     attr->type != PERF_TYPE_HARDWARE) ||
> +	    attr->inherit) {
>   		perf_event_release_kernel(event);
>   		return ERR_PTR(-EINVAL);
>   	}
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 64754bfecd70..0b6333265872 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -3258,7 +3258,7 @@ static inline u64 perf_event_count(struct perf_event *event)
>   u64 perf_event_read_local(struct perf_event *event)
>   {
>   	unsigned long flags;
> -	u64 val;
> +	u64 val = -EINVAL;
>   
>   	/*
>   	 * Disabling interrupts avoids all counter scheduling (context
> @@ -3267,12 +3267,14 @@ u64 perf_event_read_local(struct perf_event *event)
>   	local_irq_save(flags);
>   
>   	/* If this is a per-task event, it must be for current */
> -	WARN_ON_ONCE((event->attach_state & PERF_ATTACH_TASK) &&
> -		     event->hw.target != current);
> +	if ((event->attach_state & PERF_ATTACH_TASK) &&
> +	    event->hw.target != current)
> +		goto out;
>   
>   	/* If this is a per-CPU event, it must be for this CPU */
> -	WARN_ON_ONCE(!(event->attach_state & PERF_ATTACH_TASK) &&
> -		     event->cpu != smp_processor_id());
> +	if (!(event->attach_state & PERF_ATTACH_TASK) &&
> +	    event->cpu != smp_processor_id())
> +		goto out;
>   
>   	/*
>   	 * It must not be an event with inherit set, we cannot read
> @@ -3284,7 +3286,8 @@ u64 perf_event_read_local(struct perf_event *event)
>   	 * It must not have a pmu::count method, those are not
>   	 * NMI safe.
>   	 */
> -	WARN_ON_ONCE(event->pmu->count);
> +	if (event->pmu->count)
> +		goto out;
>   
>   	/*
>   	 * If the event is currently on this CPU, its either a per-task event,
> @@ -3295,6 +3298,7 @@ u64 perf_event_read_local(struct perf_event *event)
>   		event->pmu->read(event);
>   
>   	val = local64_read(&event->count);
> +out:
>   	local_irq_restore(flags);
>   
>   	return val;
