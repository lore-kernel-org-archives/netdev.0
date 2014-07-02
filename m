From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH RFC net-next 11/14] tracing: allow eBPF programs to be
 attached to events
Date: Wed, 2 Jul 2014 15:39:18 +0900
Message-ID: <CAM9d7cisUq9nJbSXZMtD+nQ_g+ZCKSsu_ghRDZY9vvkq51oiKQ@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
 <1403913966-4927-12-git-send-email-ast@plumgrid.com> <87tx70496q.fsf@sejong.aot.lge.com>
 <CAMEtUuzHakFzJYRR0WgwRBnsQL24KGsNax5DTfRNMJrGhvfQMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:42984 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754508AbaGBGjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 02:39:39 -0400
In-Reply-To: <CAMEtUuzHakFzJYRR0WgwRBnsQL24KGsNax5DTfRNMJrGhvfQMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 2, 2014 at 3:14 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Tue, Jul 1, 2014 at 10:32 PM, Namhyung Kim <namhyung@gmail.com> wrote:
>> On Fri, 27 Jun 2014 17:06:03 -0700, Alexei Starovoitov wrote:
>>> User interface:
>>> cat bpf_123 > /sys/kernel/debug/tracing/__event__/filter
>>>
>>> where 123 is an id of the eBPF program priorly loaded.
>>> __event__ is static tracepoint event.
>>> (kprobe events will be supported in the future patches)
>>>
>>> eBPF programs can call in-kernel helper functions to:
>>> - lookup/update/delete elements in maps
>>> - memcmp
>>> - trace_printk
>>
>> ISTR Steve doesn't like to use trace_printk() (at least for production
>> kernels) anymore.  And I'm not sure it'd work if there's no existing
>> trace_printk() on a system.
>
> yes. I saw big warning that trace_printk_init_buffers() emits.
> The idea here is to use eBPF programs for live kernel debugging.
> Instead of adding printk() and recompiling, just write a program,
> attach it to some event, and printk whatever is interesting.
> My only concern about printk() was that it dumps things into trace
> buffers (which is still better than dumping stuff to syslog), but now
> (since Andy almost convinced me to switch to 'fd' based interface)
> we can have seq_printk-like that prints into special buffer. So that
> user space does 'read(ufd)' and receives whatever program has
> printed. I think that would be much cleaner.
>
>>> +     if (unlikely(ftrace_file->flags & FTRACE_EVENT_FL_FILTERED) &&  \
>>> +         unlikely(ftrace_file->event_call->flags & TRACE_EVENT_FL_BPF)) { \
>>> +             struct bpf_context __ctx;                               \
>>> +                                                                     \
>>> +             populate_bpf_context(&__ctx, args, 0, 0, 0, 0, 0);      \
>>> +             trace_filter_call_bpf(ftrace_file->filter, &__ctx);     \
>>> +             return;                                                 \
>>> +     }                                                               \
>>> +                                                                     \
>>
>> Hmm..  But it seems the eBPF prog is not a filter - it'd always drop the
>> event.  And I think it's better to use a recorded entry rather then args
>> as a bpf_context so that tools like perf can manipulate it at compile
>> time based on the event format.
>
> Can manipulate what at compile time? Entry records of tracepoints are
> hard coded based on the event. For verifier it's easier to treat all
> tracepoint events as they received the same 'struct bpf_context'
> of N arguments then the same program can be attached to multiple
> tracepoint events at the same time.

I was thinking about perf creates a bpf program for filtering some
events like recording kfree_skb if protocol == xx.  So perf can
calculate the offset and size of the protocol field and make
appropriate insns for the filter.

Maybe it needs to pass the event format to the verifier somehow then.


> I thought about making verifier specific for _every_ tracepoint event,
> but it complicates the user interface, since 'bpf_context' is now different
> for every program. I think args are much easier to deal with from C
> programming point of view, since program can go a fetch the same
> fields that tracepoint 'fast_assign' macro does.
> Also skipping buffer allocation and fast_assign gives very sizable
> performance boost, since the program will access only what it needs to.
>
> The return value of eBPF program is ignored, since I couldn't think
> of use case for it. We can change it to be more 'filter' like and interpret
> return value as true/false, whether to record this event or not. Thoughts?

Your scenario looks like just calling a bpf program when it hits a
event.  It could use event triggering for that purpose IMHO.

But for filtering, it needs to add checking of the return value.

Thanks,
Namhyung
