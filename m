From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH V2 2/2] bpf: control a set of perf events by creating a
 new ioctl PERF_EVENT_IOC_SET_ENABLER
Date: Wed, 14 Oct 2015 14:28:55 -0700
Message-ID: <561EC917.8090001@plumgrid.com>
References: <1444826277-94060-1-git-send-email-xiakaixu@huawei.com>
 <1444826277-94060-3-git-send-email-xiakaixu@huawei.com>
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
In-Reply-To: <1444826277-94060-3-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/15 5:37 AM, Kaixu Xia wrote:
> +	event->p_sample_disable = &enabler_event->sample_disable;

I don't like it as a concept and it's buggy implementation.
What happens here when enabler is alive, but other event is destroyed?

> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -221,9 +221,12 @@ static u64 bpf_perf_event_sample_control(u64 r1, u64 index, u64 flag, u64 r4, u6
>   	struct bpf_array *array = container_of(map, struct bpf_array, map);
>   	struct perf_event *event;
>
> -	if (unlikely(index >= array->map.max_entries))
> +	if (unlikely(index > array->map.max_entries))
>   		return -E2BIG;
>
> +	if (index == array->map.max_entries)
> +		index = 0;

what is this hack for ?

Either use notification and user space disable or
call bpf_perf_event_sample_control() manually for each cpu.
