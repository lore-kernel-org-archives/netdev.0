From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next 1/6] bpf: introduce BPF_PROG_TEST_RUN
 command
Date: Sat, 1 Apr 2017 22:42:55 +0200
Message-ID: <20170401224255.4f8780f1@redhat.com>
References: <20170331044543.4075183-1-ast@fb.com>
        <20170331044543.4075183-2-ast@fb.com>
        <20170401091423.4ce1ef3b@redhat.com>
        <4085f538-2a92-0373-d81c-5f9396ba0d84@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>, brouer@redhat.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49978 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751526AbdDAUnC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Apr 2017 16:43:02 -0400
In-Reply-To: <4085f538-2a92-0373-d81c-5f9396ba0d84@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1 Apr 2017 08:45:01 -0700
Alexei Starovoitov <ast@fb.com> wrote:

> On 4/1/17 12:14 AM, Jesper Dangaard Brouer wrote:
> > On Thu, 30 Mar 2017 21:45:38 -0700
> > Alexei Starovoitov <ast@fb.com> wrote:
> >  
> >> static u32 bpf_test_run(struct bpf_prog *prog, void *ctx, u32 repeat, u32 *time)
> >> +{
> >> +	u64 time_start, time_spent = 0;
> >> +	u32 ret = 0, i;
> >> +
> >> +	if (!repeat)
> >> +		repeat = 1;
> >> +	time_start = ktime_get_ns();  
> >
> > I've found that is useful to record the CPU cycles, as it is more
> > useful for comparing between CPUs.  The nanosec time measurement varies
> > too much between CPUs and GHz.  I do use nanosec measurements myself a
> > lot, but that is mostly because it is easier to relate to pps rates.
> > For eBPF code execution I think it is more useful to get a cycles cost
> > count?  
> 
> for micro-benchmarking of an instruction or small primitives
> like spin_lock and irq_save/restore, yes. Cycles are more interesting
> to look at. Here it's the whole program which in case of networking
> likely does at least a few map lookups.
> Also this duration field is more of sanity test then actual metric.

Okay, if it was only a sanity metric.

> > I've been using tsc[1] (rdtsc) to get the CPU cycles, I believe
> > get_cycles() the more generic call, which have arch specific impl. (but
> > can return 0 if no arch support).
> >
> > The best solution would be to use the perf infrastructure and PMU
> > counter to get both PMU cycles and instructions, as that also tell you
> > about the pipeline efficiency like instructions per cycles.  I only got
> > this partly working in [1][2].  
> 
> to use get_cycles() or perf_event_create_kernel_counter() the current
> simple loop would become kthread pinned to cpu and so on.
> imo it's an overkill.
> The only reason 'duration' being reported is a sanity test with user
> space measurements.
> What this command allows to do is:
> $ time ./my_bpf_benchmark
> The reported time should match the kernel reported 'duration'.
> The tiny difference will come from resched. That's sanity part.
> Now we can also do
> $ perf record ./my_bpf_benchmark

Make perfect sense, to handle it this way.

> and get all perf goodness for free without adding any kernel code.
> I want this test_run command to stay execution only. All pmu and
> performance metrics should stay on perf side.
> In case of performance optimization of bpf programs we're trying
> to improve perf by changing the way program is written, hence
> we need perf to point out which line of C code is costly.
> Second is improving performance by changing JIT, map implementations
> and so on. Here we also want full perf tool power.
>
> Unfortunately there is an issue with perf today, since as soon as
> my_bpf_benchmark exits, bpf prog is unloaded and ksym is gone, so
> 'perf report' cannot associate addresses back to source code.
> We discussed a solution with Arnaldo. So that's orthogonal work in
> progress which is needed regardless of this test_run command.

Yes, that is rather unfortunate. Good to hear there is work in this area.

I've started using:
  sysctl net/core/bpf_jit_kallsyms=1
and adding --kallsyms=/proc/kallsyms to perf report, which is helpful.
 
> User space can also pin itself to cpu instead of asking kernel to
> do it and run the same program on multiple cpus in parallel testing
> interaction between concurrent map accesses and so on.
> So by keeping test_run command as execution only primitive we allow
> user space to do all the fancy tricks and measurements.

Sound good to me! :-)

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
