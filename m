From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 5/9] bpf: syscall: add percpu version of lookup/update elem
Date: Thu, 14 Jan 2016 15:16:13 +0800
Message-ID: <CACVXFVPqU=5RtbuKpJY6ya5mwocrFEB2LXhT5znp5++hig2zLw@mail.gmail.com>
References: <20160112054928.GA31180@ast-mbp.thefacebook.com>
	<CACVXFVOyAm-X7WdC-OCau_tZCAmSJoHFh2p6do16SzFDD8EkUg@mail.gmail.com>
	<20160112191051.GA67436@kafai-mba.local>
	<CACVXFVOKRpPfVzAkeFq6vLkRG+JsK+GnmT5_YUBb4hZg3KjM1w@mail.gmail.com>
	<20160113022204.GA25270@kafai-mba.dhcp.thefacebook.com>
	<CACVXFVPK+1yKbOs2A73413bamssyNXFEq+j9LTs_vZxfTsxzGA@mail.gmail.com>
	<20160113053009.GC37858@ast-mbp.thefacebook.com>
	<CACVXFVPO4iN_oSce6J9uiSybZy2GV-x3h6TCca+zLP-sZn6sbA@mail.gmail.com>
	<20160114011953.GA43324@ast-mbp.thefacebook.com>
	<CACVXFVMEQhg_n=jZfqJ6YDMbcu+amg=_Tvam6aMbMPXO3ff0Vw@mail.gmail.com>
	<20160114050857.GA44861@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160114050857.GA44861@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2016 at 1:08 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Jan 14, 2016 at 10:42:44AM +0800, Ming Lei wrote:
>> >
>> > In case of kprobes irqs are disabled, but yeah for sockets smp_call won't help.
>>
>> From 'Documentation/kprobes.txt', looks irqs aren't disabled always, see blow:
>>
>>     Probe handlers are run with preemption disabled.  Depending on the
>>     architecture and optimization state, handlers may also run with
>>     interrupts disabled (e.g., kretprobe handlers and optimized kprobe
>>     handlers run without interrupt disabled on x86/x86-64).
>
> bpf tracing progs go through ftrace that disables irqs even for
> optimized kprobes on x64.
> but yeah, there could be an arch that doesn't do it
> and long term we probably want to do something about it on x64 as well.
> tracepoints+bpf will be with irqs on as well.
>
>> 2) multiple counter case
>>
>> - lots of protection can be used, such per-element rw-spin, percpu lock,
>> srcu, ..., but each each one may introduce cost in update path of prog.
>> - the lock mechanism can be provided by bpf helpers
>
> The above techniques cannot be easily used with bpf progs, since it would
> require very significant additions to verifier.
> Say we introduce a helper that takes some hidden lock and increments
> the counter which is part of map element value. What will you pass into it?
> An address of the counter? How verifier can statically check it?
> Theoretically it's doable, it's quite complex and run-time performance
> would be bad if we have to do lock,++,unlock for every counter.
> Existing bpf_xadd insn is likely going to be faster despite cache line
> bouncing comparing to per-cpu lock,++,unlock

There are two simple approaches I thought of:

1) introduce two helpers of lookup_and_lock_element(map, key) &&
unlock_element(map, key)
- the disadvantage is that unlock_element() need one extra lookup
- verifier needn't any change

2) embedded one lock at the head of returned value
- looks a bit ugly
- it is tricky to obtain the lock in kernel(syscall path)
- still needn't verifier's change

Or other ideas?

>
> from your other email:
>> 3) if we use syscall to implement Ri(i=1...3), the period between T(i)
>> and T(i+1)
>> can become quite big, for example dozens of seconds, so the accumulated value
>> in A4 can't represent the actual/correct value(counter) at any time between T0
>> and T4, and the value is wrong actually, and all events in above diagram
>> (E0(0)~E0(2M), E1(0)~E1(1M),  E2(0) .... E2(10K), ...) aren't counted at all,
>> and the missed number can be quite huge.
>> So does the value got by A4 make sense for user?
>
> yes it does. In your example it's number of packets received.
> Regardless how slow or fast the per-cpu loop is the aggreate value is still valid.
> The kernel is full of loops like:
>  for_each_possible_cpu(cpu) {
>    struct stats *pcpu = per_cpu_ptr(stats, cpu);
>    sum1 += pcpu->cnt1;
>    sum2 += pcpu->cnt2;
>  }

Yes, that is the way I suggest to use instead of using nr_cpu syscall to
aggreate perpcu value, which kind of usage I never see before.

> and they compute valid values.
> It doesn't matter how slow or fast that loop is.

I don't think so, quantity breeds quality. In syscall path, there are
lots of possible and long delay(schedule out, memory allocation,
page in, ...) especially when system is in high loading. In the above
loop kernel is using, no all these possible delay.

> Obviously the faster it is the more accurate the aggragtes will be,
> but one can add mdelay() after each iteration and it's still valid.

It might be valid, but the aggragtes can deviate too much from the
correct value, and it becomes useless, then it doesn't matter about
the validity, does it?

If you don't object, I will try to figure out one patch to support
implementing the aggragate function from bpf prog and we can use
the kernel way to aggragate percpu value, then one single syscall
is enough. Looks one new prog type is needed, but it is very similar
with the sock filter usage.

> Anyway, me and Martin had a discussion offline about this. To summarize:
> . smp_call() is not a good approach, since it works only kprobe+bpf

Yes.

> . disable irqs for socket-style bpf programs is not an options either, since
>   pushf/popf adds unnecessary overhead and having irqs off for the life of
>   the program is bad

Agree.

> . optional irq off for bpf progs that use per-cpu maps is just as bad

Yes.

> . we can do bpf_map_lookup_and_delete() technique for per-cpu hash maps:
>   delete elem and do for_each_possible_cpu() { copy values into buffer }
>   from call_rcu() callback, but it needs extra sync wait logic in syscall,

call_rcu() callback often takes long time.

>   so complexity is probably not worth the gain, though nice that
>   it's generic and works on all archs

I suggest to not consider for percpu only, since it is a generic issue,
and the approach should cover current array/hash map.

> . we can do for_each_possible_cpu() {atomic_long_memcpy of values} in
>   bpf_map_lookup() syscall. since we know that hash map values are always
>   8 byte aligned, atomic_long_memcpy() will be a loop of explicit
>   4-byte or 8-byte copies on 32-bit and 64-bit archs respectively.
>   User space would need to provide value_size*max_cpus buffer, which will
>   be partially filled by kernel due to holes in possible_cpus mask.
>   For #1 'counter' use case the userspace can bzero() the buffer
>   and aggregate all slots ignoring possible holes, since they're zero.
>   Doing syscall for each cpu is slower, since for 40+ cpus the cost adds up.

Exactly, that is why I think it is good to define the aggregate function into
bpf prog code, then we can get the total value in single syscall.

> . bpf_map_update() becomes similar with atomic_long_memcpy
>   The most appealing to me is that no new helpers needed and no new

I agree with you about no new helpers.

>   syscall commands. For per-cpu maps bpf_map_lookup/update() from kernel

No new syscall means we have to aggregate the value from kernel via
bpf prog.

>   operates only on this_cpu() and bpf_map_lookup/update() from syscall
>   use value_size*num_cpus buffer.


Thanks,
Ming Lei
