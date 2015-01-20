From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: Re: Re: Re: [PATCH tip 0/9] tracing: attach eBPF programs to tracepoints/syscalls/kprobe
Date: Tue, 20 Jan 2015 20:57:18 +0900
Message-ID: <54BE429E.9020108@hitachi.com>
References: <CAMEtUuwrpqRG4a=Hqnj3JBKuLbC4yV+trVAZhevKLbCsm_6U4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"zhangwei(Jovi)" <jovi.zhangwei@huawei.com>,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuwrpqRG4a=Hqnj3JBKuLbC4yV+trVAZhevKLbCsm_6U4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2015/01/20 12:55), Alexei Starovoitov wrote:
> On Mon, Jan 19, 2015 at 6:58 PM, Masami Hiramatsu
> <masami.hiramatsu.pt@hitachi.com> wrote:
>>>
>>> it's done already... one can do the same skb->dev->name logic
>>> in kprobe attached program... so from bpf program point of view,
>>> tracepoints and kprobes feature-wise are exactly the same.
>>> Only input is different.
>>
>> No, I meant that the input should also be same, at least for the first step.
>> I guess it is easy to hook the ring buffer committing and fetch arguments
>> from the event entry.
> 
> No. That would be very slow. See my comment to Steven
> and more detailed numbers below.

Thank you for measuring the performance differences.
Indeed, the ring buffer looks slow.

> Allocating ring buffer takes too much time.
> 
>> And what I expected scenario was
>>
>> 1. setup kprobe traceevent with fd, buf, count by using perf-probe.
>> 2. load bpf module
>> 3. the module processes given event arguments.
> 
> from ring buffer? that's too slow.

Ok, BTW, would you think is it possible to use a reusable small scratchpad
memory for passing arguments? (just a thought)

> It's not usable for high frequency events which
> need this in-kernel aggregation.
> If events are rare, then just dumping everything
> into trace buffer is just fine. No in-kernel program is needed.

Hmm, let me ensure your point, the performance number is the reason why
we need to do it in the kernel, right? Not mainly for the flexibility but speed.

>> Hmm, it sounds making another systemtap on top of tracepoint and kprobes.
>> Why don't you just reuse the existing facilities (perftools and ftrace)
>> instead of co-exist?
> 
> hmm. I don't think we're on the same page yet...
> ring buffer and tracing interface is fully reused.
> programs are run as soon as event triggers.
> They can return non-zero and kernel will allocate ring
> buffer which user space will consume.
> Please take a look at tracex1

I see, this code itself is not a destructive change.

>>> Just look how ktap scripts look alike for kprobes and tracepoints.
>>
>> Ktap is a good example, it provides only a language parser and a runtime engine.
>> Actually, currently it lacks a feature to execute "perf-probe" helper from
>> script, but it is easy to add such feature.
> ...
>> For this usecase, I've made --output option for perf probe
>> https://lkml.org/lkml/2014/10/31/210
> 
> you're proposing to call perf binary from ktap binary?

Yes, that's right :)

> I think packaging headaches and error conditions
> will make such approach very hard to use.

No, I don't think so. perf can be a "buffer" from the kernel API
and command-line API. If you need to get clearer error, you also
can join the upstream development.

> it would be much cleaner to have ktap as part of perf
> generating bpf on the fly and feeding into kernel.
> 'perf probe' parsing and functions don't belong in kernel
> when userspace can generate them in more efficient way.

No, perf probe still be needed to users who don't choose "injecting
binary blob" tracing. Efficiency is NOT only one index.

- perf probe and kprobe-event gives us a complete understandable
 interface for what will be recorded at where.
 (we can see the event definitions via kprobe_events interface,
  without any tools)
- kprobe-event gives a completely same interface as other tracepoint
  events.
- it also doesn't require any build-binary parts :) nor special tools.
  We can play with ftrace on just a small busybox.

However, this does NOT interfere your patch upstreaming. I just said current
ftrace method is also meaningful for some reasons :)


By the way, I concern about that bpf compiler can become another systemtap,
especially if you build it on llvm. Would you plan to develop it on kernel
tree? or apart from the kernel-side development?
I think it is hard to sync the development if you do it out-of-tree.


Thank you,



-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com
