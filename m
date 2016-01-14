From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 5/9] bpf: syscall: add percpu version of lookup/update elem
Date: Thu, 14 Jan 2016 10:42:44 +0800
Message-ID: <CACVXFVMEQhg_n=jZfqJ6YDMbcu+amg=_Tvam6aMbMPXO3ff0Vw@mail.gmail.com>
References: <20160111190248.GA26495@ast-mbp.thefacebook.com>
	<CACVXFVM7B6diKgrGoXdMkYW94SeY9yRxbv8bJ+J0K=TBGxDBQQ@mail.gmail.com>
	<20160112054928.GA31180@ast-mbp.thefacebook.com>
	<CACVXFVOyAm-X7WdC-OCau_tZCAmSJoHFh2p6do16SzFDD8EkUg@mail.gmail.com>
	<20160112191051.GA67436@kafai-mba.local>
	<CACVXFVOKRpPfVzAkeFq6vLkRG+JsK+GnmT5_YUBb4hZg3KjM1w@mail.gmail.com>
	<20160113022204.GA25270@kafai-mba.dhcp.thefacebook.com>
	<CACVXFVPK+1yKbOs2A73413bamssyNXFEq+j9LTs_vZxfTsxzGA@mail.gmail.com>
	<20160113053009.GC37858@ast-mbp.thefacebook.com>
	<CACVXFVPO4iN_oSce6J9uiSybZy2GV-x3h6TCca+zLP-sZn6sbA@mail.gmail.com>
	<20160114011953.GA43324@ast-mbp.thefacebook.com>
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
In-Reply-To: <20160114011953.GA43324@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2016 at 9:19 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Wed, Jan 13, 2016 at 10:56:38PM +0800, Ming Lei wrote:
>> On Wed, Jan 13, 2016 at 1:30 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Wed, Jan 13, 2016 at 11:17:23AM +0800, Ming Lei wrote:
>> >> On Wed, Jan 13, 2016 at 10:22 AM, Martin KaFai Lau <kafai@fb.com> wrote:
>> >> > On Wed, Jan 13, 2016 at 08:38:18AM +0800, Ming Lei wrote:
>> >> >> > The userspace usually only aggregates value across all cpu every X seconds.
>> >> >>
>> >> >> That is just in your case, and Alexei worried the issue of data stale.
>> >> > I believe we are talking about validity of a value.  How to
>> >> > make use of a less-stale but invalid data?
>> >>
>> >> About the 'invalidity' thing, it should be same between using
>> >> smp_call(run in IPI irq handler) and simple memcpy().
>> >>
>> >> When smp_call_function_single() is used to request to lookup element in
>> >> the specific CPU, the value of the element may be in updating in that CPU
>> >> and not completed yet in eBPF prog, then IPI comes and half updated
>> >> data is still returned to syscall.
>> >
>> > hmm. I'm not following. bpf programs are executing with preempt disabled,
>> > so smp_call_function_single suppose to execute when bpf is not running.
>>
>> Preempt disabled doesn't mean irq disabled, does it?  So when bpf prog is
>> running, the IPI irq for smp_call still may come on that CPU.
>
> In case of kprobes irqs are disabled, but yeah for sockets smp_call won't help.

>From 'Documentation/kprobes.txt', looks irqs aren't disabled always, see blow:

    Probe handlers are run with preemption disabled.  Depending on the
    architecture and optimization state, handlers may also run with
    interrupts disabled (e.g., kretprobe handlers and optimized kprobe
    handlers run without interrupt disabled on x86/x86-64).

> Can probably use schedule_work_on(), but that's too heavy.
> I guess we need bpf_map_lookup_and_delete_elem() syscall command, so we can
> delete single pointer out of per-cpu hash map and in call_rcu() copy precise
> counters.

The partial update is one generic issue, not only on percpu map.

>
>> Also in current non-percpu hash, the situation exists too between
>> lookup elem syscall and updating value of element from bpf prog in
>> SMP.
>
> looks like regular bpf_map_lookup_elem() syscall will return inaccurate data
> even for per-cpu hash. hmm. we need to brain storm more on it.

That is the reason I don't like smp_call now, since the issue is generic
and not only on percpu map.

But any generic protection might introduce some cost in updating path
from eBPF prog, which we don't like too.

The partial update only exists when one element holds more than one
counter, or one element holds one 64bit counter on 32bit machine(which
can be thought as double counter too).

1) single counter case

- if the counter in the element may be updated concurrently, the counter
has to be updated with atomic operation in prog, and that is perpcu map's
value to avoid the atomic operation

- now no protection is needed since the updating on the element is atomic

2) multiple counter case

- lots of protection can be used, such per-element rw-spin, percpu lock,
srcu, ..., but each each one may introduce cost in update path of prog.

- prog code can choose if they want precise counting with the extra cost.

- the lock mechanism can be provided by bpf helpers


Thanks,
Ming Lei
