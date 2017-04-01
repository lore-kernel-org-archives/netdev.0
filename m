From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next 1/6] bpf: introduce BPF_PROG_TEST_RUN
 command
Date: Sat, 1 Apr 2017 09:14:23 +0200
Message-ID: <20170401091423.4ce1ef3b@redhat.com>
References: <20170331044543.4075183-1-ast@fb.com>
        <20170331044543.4075183-2-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60434 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750795AbdDAHOb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Apr 2017 03:14:31 -0400
In-Reply-To: <20170331044543.4075183-2-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Mar 2017 21:45:38 -0700
Alexei Starovoitov <ast@fb.com> wrote:

> static u32 bpf_test_run(struct bpf_prog *prog, void *ctx, u32 repeat, u32 *time)
> +{
> +	u64 time_start, time_spent = 0;
> +	u32 ret = 0, i;
> +
> +	if (!repeat)
> +		repeat = 1;
> +	time_start = ktime_get_ns();

I've found that is useful to record the CPU cycles, as it is more
useful for comparing between CPUs.  The nanosec time measurement varies
too much between CPUs and GHz.  I do use nanosec measurements myself a
lot, but that is mostly because it is easier to relate to pps rates.
For eBPF code execution I think it is more useful to get a cycles cost
count?

I've been using tsc[1] (rdtsc) to get the CPU cycles, I believe
get_cycles() the more generic call, which have arch specific impl. (but
can return 0 if no arch support).

The best solution would be to use the perf infrastructure and PMU
counter to get both PMU cycles and instructions, as that also tell you
about the pipeline efficiency like instructions per cycles.  I only got
this partly working in [1][2].

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/include/linux/time_bench.h
[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench.c


> +	for (i = 0; i < repeat; i++) {
> +		ret = bpf_test_run_one(prog, ctx);
> +		if (need_resched()) {
> +			if (signal_pending(current))
> +				break;
> +			time_spent += ktime_get_ns() - time_start;
> +			cond_resched();
> +			time_start = ktime_get_ns();
> +		}
> +	}
> +	time_spent += ktime_get_ns() - time_start;
> +	do_div(time_spent, repeat);
> +	*time = time_spent > U32_MAX ? U32_MAX : (u32)time_spent;
> +
> +	return ret;
> +}

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
