From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 5/9] bpf: syscall: add percpu version of lookup/update
 elem
Date: Wed, 13 Jan 2016 21:08:59 -0800
Message-ID: <20160114050857.GA44861@ast-mbp.thefacebook.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVXFVMEQhg_n=jZfqJ6YDMbcu+amg=_Tvam6aMbMPXO3ff0Vw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2016 at 10:42:44AM +0800, Ming Lei wrote:
> >
> > In case of kprobes irqs are disabled, but yeah for sockets smp_call won't help.
> 
> From 'Documentation/kprobes.txt', looks irqs aren't disabled always, see blow:
> 
>     Probe handlers are run with preemption disabled.  Depending on the
>     architecture and optimization state, handlers may also run with
>     interrupts disabled (e.g., kretprobe handlers and optimized kprobe
>     handlers run without interrupt disabled on x86/x86-64).

bpf tracing progs go through ftrace that disables irqs even for
optimized kprobes on x64.
but yeah, there could be an arch that doesn't do it
and long term we probably want to do something about it on x64 as well.
tracepoints+bpf will be with irqs on as well.

> 2) multiple counter case
> 
> - lots of protection can be used, such per-element rw-spin, percpu lock,
> srcu, ..., but each each one may introduce cost in update path of prog.
> - the lock mechanism can be provided by bpf helpers

The above techniques cannot be easily used with bpf progs, since it would
require very significant additions to verifier.
Say we introduce a helper that takes some hidden lock and increments
the counter which is part of map element value. What will you pass into it?
An address of the counter? How verifier can statically check it?
Theoretically it's doable, it's quite complex and run-time performance
would be bad if we have to do lock,++,unlock for every counter.
Existing bpf_xadd insn is likely going to be faster despite cache line 
bouncing comparing to per-cpu lock,++,unlock

from your other email:
> 3) if we use syscall to implement Ri(i=1...3), the period between T(i)
> and T(i+1)
> can become quite big, for example dozens of seconds, so the accumulated value
> in A4 can't represent the actual/correct value(counter) at any time between T0
> and T4, and the value is wrong actually, and all events in above diagram
> (E0(0)~E0(2M), E1(0)~E1(1M),  E2(0) .... E2(10K), ...) aren't counted at all,
> and the missed number can be quite huge.
> So does the value got by A4 make sense for user?

yes it does. In your example it's number of packets received.
Regardless how slow or fast the per-cpu loop is the aggreate value is still valid.
The kernel is full of loops like:
 for_each_possible_cpu(cpu) {
   struct stats *pcpu = per_cpu_ptr(stats, cpu);
   sum1 += pcpu->cnt1;
   sum2 += pcpu->cnt2;
 }
and they compute valid values.
It doesn't matter how slow or fast that loop is.
Obviously the faster it is the more accurate the aggragtes will be,
but one can add mdelay() after each iteration and it's still valid.

Anyway, me and Martin had a discussion offline about this. To summarize:
. smp_call() is not a good approach, since it works only kprobe+bpf
. disable irqs for socket-style bpf programs is not an options either, since
  pushf/popf adds unnecessary overhead and having irqs off for the life of
  the program is bad
. optional irq off for bpf progs that use per-cpu maps is just as bad
. we can do bpf_map_lookup_and_delete() technique for per-cpu hash maps:
  delete elem and do for_each_possible_cpu() { copy values into buffer }
  from call_rcu() callback, but it needs extra sync wait logic in syscall,
  so complexity is probably not worth the gain, though nice that
  it's generic and works on all archs
. we can do for_each_possible_cpu() {atomic_long_memcpy of values} in
  bpf_map_lookup() syscall. since we know that hash map values are always
  8 byte aligned, atomic_long_memcpy() will be a loop of explicit
  4-byte or 8-byte copies on 32-bit and 64-bit archs respectively.
  User space would need to provide value_size*max_cpus buffer, which will
  be partially filled by kernel due to holes in possible_cpus mask.
  For #1 'counter' use case the userspace can bzero() the buffer
  and aggregate all slots ignoring possible holes, since they're zero.
  Doing syscall for each cpu is slower, since for 40+ cpus the cost adds up.
. bpf_map_update() becomes similar with atomic_long_memcpy
  The most appealing to me is that no new helpers needed and no new
  syscall commands. For per-cpu maps bpf_map_lookup/update() from kernel
  operates only on this_cpu() and bpf_map_lookup/update() from syscall
  use value_size*num_cpus buffer.
