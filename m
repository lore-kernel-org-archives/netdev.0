From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH V2 1/2] bpf: control the trace data output on current cpu
 when perf sampling
Date: Wed, 14 Oct 2015 14:21:11 -0700
Message-ID: <561EC747.8070608@plumgrid.com>
References: <1444826277-94060-1-git-send-email-xiakaixu@huawei.com>
 <1444826277-94060-2-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444826277-94060-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/15 5:37 AM, Kaixu Xia wrote:
> This patch adds the flag sample_disable to control the trace data
> output process when perf sampling. By setting this flag and
> integrating with ebpf, we can control the data output process and
> get the samples we are most interested in.
>
> The bpf helper bpf_perf_event_sample_control() can control the
> perf_event on current cpu.
>
> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
...
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
>   		irq_work_queue(&event->pending);
>   	}
>
> +	if (!atomic_read(&event->sample_disable))
> +		return ret;
> +

the condition check and the name are inconsistent.
It's either
if (!enabled) return
or
if (disabled) return

>   	if (event->overflow_handler)
>   		event->overflow_handler(event, data, regs);
>   	else
> @@ -7709,6 +7712,14 @@ static void account_event(struct perf_event *event)
>   	account_event_cpu(event, event->cpu);
>   }
>
> +static void perf_event_check_sample_flag(struct perf_event *event)
> +{
> +	if (event->attr.sample_disable == 1)
> +		atomic_set(&event->sample_disable, 0);
> +	else
> +		atomic_set(&event->sample_disable, 1);
> +}

why introduce new attribute for this?
we already have 'disabled' flag.

> +static u64 bpf_perf_event_sample_control(u64 r1, u64 index, u64 flag, u64 r4, u64 r5)
> +{
> +	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
> +	struct bpf_array *array = container_of(map, struct bpf_array, map);
> +	struct perf_event *event;
> +
> +	if (unlikely(index >= array->map.max_entries))
> +		return -E2BIG;
> +
> +	event = (struct perf_event *)array->ptrs[index];
> +	if (!event)
> +		return -ENOENT;
> +
> +	if (flag)

please check only bit 0 and check that all other bits are zero as well
for future extensibility.

> +		atomic_dec(&event->sample_disable);

it should be atomic_dec_if_positive();

> +	else
> +		atomic_inc(&event->sample_disable);

and atomic_add_unless()
to make sure we don't wrap on either side.

> +const struct bpf_func_proto bpf_perf_event_sample_control_proto = {

static.
