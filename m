From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 11/14] tracing: allow eBPF programs to be
 attached to events
Date: Tue, 1 Jul 2014 23:14:43 -0700
Message-ID: <CAMEtUuzHakFzJYRR0WgwRBnsQL24KGsNax5DTfRNMJrGhvfQMA@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-12-git-send-email-ast@plumgrid.com>
	<87tx70496q.fsf@sejong.aot.lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87tx70496q.fsf-vfBCOVm4yAnB69T4xOojN9BPR1lH4CV8@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 1, 2014 at 10:32 PM, Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Fri, 27 Jun 2014 17:06:03 -0700, Alexei Starovoitov wrote:
>> User interface:
>> cat bpf_123 > /sys/kernel/debug/tracing/__event__/filter
>>
>> where 123 is an id of the eBPF program priorly loaded.
>> __event__ is static tracepoint event.
>> (kprobe events will be supported in the future patches)
>>
>> eBPF programs can call in-kernel helper functions to:
>> - lookup/update/delete elements in maps
>> - memcmp
>> - trace_printk
>
> ISTR Steve doesn't like to use trace_printk() (at least for production
> kernels) anymore.  And I'm not sure it'd work if there's no existing
> trace_printk() on a system.

yes. I saw big warning that trace_printk_init_buffers() emits.
The idea here is to use eBPF programs for live kernel debugging.
Instead of adding printk() and recompiling, just write a program,
attach it to some event, and printk whatever is interesting.
My only concern about printk() was that it dumps things into trace
buffers (which is still better than dumping stuff to syslog), but now
(since Andy almost convinced me to switch to 'fd' based interface)
we can have seq_printk-like that prints into special buffer. So that
user space does 'read(ufd)' and receives whatever program has
printed. I think that would be much cleaner.

>> +     if (unlikely(ftrace_file->flags & FTRACE_EVENT_FL_FILTERED) &&  \
>> +         unlikely(ftrace_file->event_call->flags & TRACE_EVENT_FL_BPF)) { \
>> +             struct bpf_context __ctx;                               \
>> +                                                                     \
>> +             populate_bpf_context(&__ctx, args, 0, 0, 0, 0, 0);      \
>> +             trace_filter_call_bpf(ftrace_file->filter, &__ctx);     \
>> +             return;                                                 \
>> +     }                                                               \
>> +                                                                     \
>
> Hmm..  But it seems the eBPF prog is not a filter - it'd always drop the
> event.  And I think it's better to use a recorded entry rather then args
> as a bpf_context so that tools like perf can manipulate it at compile
> time based on the event format.

Can manipulate what at compile time? Entry records of tracepoints are
hard coded based on the event. For verifier it's easier to treat all
tracepoint events as they received the same 'struct bpf_context'
of N arguments then the same program can be attached to multiple
tracepoint events at the same time.
I thought about making verifier specific for _every_ tracepoint event,
but it complicates the user interface, since 'bpf_context' is now different
for every program. I think args are much easier to deal with from C
programming point of view, since program can go a fetch the same
fields that tracepoint 'fast_assign' macro does.
Also skipping buffer allocation and fast_assign gives very sizable
performance boost, since the program will access only what it needs to.

The return value of eBPF program is ignored, since I couldn't think
of use case for it. We can change it to be more 'filter' like and interpret
return value as true/false, whether to record this event or not. Thoughts?
