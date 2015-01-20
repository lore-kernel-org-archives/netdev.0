From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: Re: Re: [PATCH tip 0/9] tracing: attach eBPF programs to tracepoints/syscalls/kprobe
Date: Tue, 20 Jan 2015 12:33:03 -0800
Message-ID: <CAMEtUuxGxCHc0ifdEeKXr=aq-znwGZ2g22+RdJ9SzWmYeSEnuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 20, 2015 at 3:57 AM, Masami Hiramatsu
<masami.hiramatsu.pt@hitachi.com> wrote:
>
> Ok, BTW, would you think is it possible to use a reusable small scratchpad
> memory for passing arguments? (just a thought)

sure. doable, but what's the use case?

>> It's not usable for high frequency events which
>> need this in-kernel aggregation.
>> If events are rare, then just dumping everything
>> into trace buffer is just fine. No in-kernel program is needed.
>
> Hmm, let me ensure your point, the performance number is the reason why
> we need to do it in the kernel, right? Not mainly for the flexibility but speed.

if user space can do X at the same speed as kernel,
then user space is a better choice and more flexible.
In case of bpf programs two things user space cannot do:
- fast aggregation without adding penalty to things being traced
- access to in-kernel data structures
And often both used together.
Say, we want to monitor amount of network traffic per user.
So we'd use trace_net_dev_xmit() tracepoint and do
map[current_uid()] += skb_len
as part of the program.
Overhead will be tiny and users won't notice any slowdown.
Trying to do the same in user space by enabling
this tracepoint has two problems:
high overhead and events are hard to aggregate
per user, since trace has 'pid', but short lived
processes will have dead pids in trace output.

> - perf probe and kprobe-event gives us a complete understandable
>  interface for what will be recorded at where.
>  (we can see the event definitions via kprobe_events interface,
>   without any tools)
> - kprobe-event gives a completely same interface as other tracepoint
>   events.
> - it also doesn't require any build-binary parts :) nor special tools.
>   We can play with ftrace on just a small busybox.

yeah, when debugging in busybox is the goal
and 'cat' and 'echo' are your only tools, then
debugfs interface is the only choice :)

> However, this does NOT interfere your patch upstreaming. I just said current
> ftrace method is also meaningful for some reasons :)

of course :)
To emphasize the point I was trying to make with tracex1:
The program is a filter/aggregator. The bpf maps
are not suitable for streaming the events. That's the job
of ring buffer/trace_pipe. The program may choose
to aggregate some events and discard them (by
returning 0 from the program), and the rest of
the events will be streamed to user space via
ring buffer in the format statically defined by tracepoint
or by kprobe arguments.
The tracex1 example loads the program and then
reads /sys/kernel/debugfs/tracing/trace_pipe...

That part I was trying to improve with bpf_trace_printk:
to give ability to programs to stream data in a format
different from the one statically defined by tracepoints.
But trace_printk has its disadvantages, so probably
something cleaner is needed.
Like in my earlier example of trace_net_dev_xmit,
if the program could add printing of uid to arguments
already printed, it would have helped user space.

> By the way, I concern about that bpf compiler can become another systemtap,
> especially if you build it on llvm.
> Would you plan to develop it on kernel
> tree? or apart from the kernel-side development?

I'm not sure I completely understand the concern.
perf is using a bunch of out-of-tree libraries.
mcjit of llvm or libgccjit are another libraries.
Or may be eventually eBPF can be generated
by something like libpcap.

Ideally I would like to see 'perf run script.txt'
where script.txt is a program in a language suited
for tracing. The tracing language not necessary
will fit networking use cases. Currently I'm
using C for both and it's the most convenient,
but some folks complained that 'restricted'
nature of this C is hard to grasp, so I can only
encourage Jovi to do ktap language to bpf
translator. If it generates bpf directly that's great,
if it uses gcc or llvm backend that's fine too.

> I think it is hard to sync the development if you do it out-of-tree.

I think some pieces would have to be out of tree.
I've kept standalone llvm backend across 3.2, 3.3 and 3.4
but it gets polluted with ifdefs and not really a long term
solution, so now I'm working on upstreaming it
and feedback/codereviews I got, definitely improved
the quality of the bpf backend.
In case of backends the only bit to sync is instruction
set itself, which is stable. New instructions may be
added, but that's not a concern.
llvm backend doesn't care what language is
used in front-end or how programs are attached
to tracepoints or what set of bpf helper
functions is available.
All such bits and the main interface for
dynamic tracer, imo, should be in perf binary.
What it does underneath and how
many times it calls into llvm/gcc lib, won't be visible.
In case of systemtap compile time, for whatever
reason, is slow to the point of being annoying,
but here it should be instant.
