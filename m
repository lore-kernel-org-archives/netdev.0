From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/4] bpf: add helper bpf_perf_read_counter_time
 for perf event array map
Date: Fri, 1 Sep 2017 13:29:17 -0700
Message-ID: <a1905aeb-b49f-d4e8-91ee-a28a92869da1@fb.com>
References: <20170901165357.465121-1-yhs@fb.com>
 <20170901165357.465121-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>
To: Yonghong Song <yhs@fb.com>, <peterz@infradead.org>,
        <rostedt@goodmis.org>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49590 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752328AbdIAUaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 16:30:08 -0400
In-Reply-To: <20170901165357.465121-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/1/17 9:53 AM, Yonghong Song wrote:
> Hardware pmu counters are limited resources. When there are more
> pmu based perf events opened than available counters, kernel will
> multiplex these events so each event gets certain percentage
> (but not 100%) of the pmu time. In case that multiplexing happens,
> the number of samples or counter value will not reflect the
> case compared to no multiplexing. This makes comparison between
> different runs difficult.
>
> Typically, the number of samples or counter value should be
> normalized before comparing to other experiments. The typical
> normalization is done like:
>   normalized_num_samples = num_samples * time_enabled / time_running
>   normalized_counter_value = counter_value * time_enabled / time_running
> where time_enabled is the time enabled for event and time_running is
> the time running for event since last normalization.
>
> This patch adds helper bpf_perf_read_counter_time for kprobed based perf
> event array map, to read perf counter and enabled/running time.
> The enabled/running time is accumulated since the perf event open.
> To achieve scaling factor between two bpf invocations, users
> can can use cpu_id as the key (which is typical for perf array usage model)
> to remember the previous value and do the calculation inside the
> bpf program.
>
> Signed-off-by: Yonghong Song <yhs@fb.com>

...

> +BPF_CALL_4(bpf_perf_read_counter_time, struct bpf_map *, map, u64, flags,
> +	struct bpf_perf_counter_time *, buf, u32, size)
> +{
> +	struct perf_event *pe;
> +	u64 now;
> +	int err;
> +
> +	if (unlikely(size != sizeof(struct bpf_perf_counter_time)))
> +		return -EINVAL;
> +	err = get_map_perf_counter(map, flags, &buf->counter, &pe);
> +	if (err)
> +		return err;
> +
> +	calc_timer_values(pe, &now, &buf->time.enabled, &buf->time.running);
> +	return 0;
> +}

Peter,
I believe we're doing it correctly above.
It's a copy paste of the same logic as in total_time_enabled/running.
We cannot expose total_time_enabled/running to bpf, since they are
different counters. The above two are specific to bpf usage.
See commit log.

for the whole set:
Acked-by: Alexei Starovoitov <ast@kernel.org>
