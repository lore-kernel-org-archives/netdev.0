From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH tip 0/9] tracing: attach eBPF programs to tracepoints/syscalls/kprobe
Date: Fri, 16 Jan 2015 10:57:15 -0800
Message-ID: <CAMEtUuxhjef+9QaFccfSyA3DbVJ3H6qP=eu-uZCkku1rVWViSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 16, 2015 at 7:02 AM, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> On Thu, 15 Jan 2015 20:16:01 -0800
> Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>
>> Hi Ingo, Steven,
>>
>> This patch set is based on tip/master.
>
> Note, the tracing code isn't maintained in tip/master, but perf code is.

I know. I can rebase against linux-trace tree, but wanted to go
through tip to get advantage of tip-bot ;)

> Do you have a git repo somewhere that I can look at? It makes it easier
> than loading in 9 patches ;-)

https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/

> For syscalls this is fine as the parameters are usually set. But
> there's a lot of tracepoints that we need to know the result of the
> copied data to decide to filter or not, where the result happens at the
> TP_fast_assign() part which requires allocating the buffers.
...
> Again, for syscalls it may not be a problem, but for other tracepoints,
> I'm not sure we can do that. How do you handle sched_switch for
> example? The tracepoint only gets two pointers to task structs, you
> need to then dereference them to get the pid, prio, state and other
> data.

exactly. In this patch set the user can use bpf_fetch_*()
helpers to dereference task_struct to get to pid, prio, anything.
The user is not limited by what tracepoints hard coded as
part of TP_fast_assign.
In the future when generic type/field infra is ready,
the bpf program will have faster way to access such fields
without going through bpf_fetch_*() helpers.

In other words the program is a superset of existing
TP_fast_assign + TP_print + filters + triggers + stack dumps.
All are done from the program on demand.
Some programs may just count number of events
without accessing arguments at all.

> Maybe we should have a way to do the program before and/or after the
> buffering depending on what to filter on. There's no way to know what
> the parameters of the tracepoint are without looking at the source.

right now most of the tracepoints copy as much as possible
fields as part of TP_fast_assign, since there is no way to
know what will be needed later.
And despite copying a lot, often it's not enough for analytics.
With program is attached before the copy, the overhead
is much lower. The program will look at whatever fields
necessary, may do some operations on them and even
store these fields into maps for further processing.

>> - dump_stack
>> - trace_printk
>> The last two are mainly to debug the programs and to print data for user
>> space consumptions.
>
> I have to look at the code, but currently trace_printk() isn't made to
> be used in production systems.

other than allocating a bunch of per_cpu pages.
what concerns do you have?
Some printk-like facility from the program is needed.
I'd rather fix whatever necessary in trace_printk instead
of inventing another way of printing.
Anyway, I think I will drop these two helpers for now.

> One last thing. If the ebpf is used for anything but filtering, it
> should go into the trigger file. The filtering is only a way to say if
> the event should be recorded or not. But the trigger could do something
> else (a printk, a stacktrace, etc).

it does way more than just filtering, but
invoking program as a trigger is too slow.
When program is called as soon as tracepoint fires,
it can fetch other fields, evaluate them, printk some of them,
optionally dump stack, aggregate into maps.
We can let it call triggers too, so that user program will
be able to enable/disable other events.
I'm not against invoking programs as a trigger, but I don't
see a use case for it. It's just too slow for production
analytics that needs to act on huge number of events
per second.
We must minimize the overhead between tracepoint
firing and program executing, so that programs can
be used on events like packet receive which will be
in millions per second. Every nsec counts.
For example:
- raw dd if=/dev/zero of=/dev/null
  does 760 MB/s (on my debug kernel)
- echo 1 > events/syscalls/sys_enter_write/enable
  drops it to 400 MB/s
- echo "echo "count == 123 " > events/syscalls/sys_enter_write/filter
  drops it even further down to 388 MB/s
This slowdown is too high for this to be used on a live system.
- tracex4 that computes histogram of sys_write sizes
  and stores log2(count) into a map does 580 MB/s
  This is still not great, but this slowdown is now usable
  and we can work further on minimizing the overhead.
