From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH v2 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Thu, 29 Jan 2015 15:41:00 +0900
Message-ID: <CAM9d7chduHyJhcEaxT0yt-J2dvdu9umcygHOea+W+TONC6YuaA@mail.gmail.com>
References: <CAMEtUuz+N52ms4ZFh8+fSGhg1UaXpBdk9RVPU_zBDCjaZ4bj4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuz+N52ms4ZFh8+fSGhg1UaXpBdk9RVPU_zBDCjaZ4bj4A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 29, 2015 at 1:40 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Wed, Jan 28, 2015 at 4:46 PM, Namhyung Kim <namhyung@kernel.org> wrote:
>>>
>>> +static int event_filter_release(struct inode *inode, struct file *filp)
>>> +{
>>> +     struct ftrace_event_file *file;
>>> +     char buf[2] = "0";
>>> +
>>> +     mutex_lock(&event_mutex);
>>> +     file = event_file_data(filp);
>>> +     if (file) {
>>> +             if (file->flags & TRACE_EVENT_FL_BPF) {
>>> +                     /* auto-disable the filter */
>>> +                     ftrace_event_enable_disable(file, 0);
>>
>> Hmm.. what if user already enabled an event, attached a bpf filter and
>> then detached the filter - I'm not sure we can always auto-disable
>> it..
>
> why not?
> I think it makes sense auto enable/disable, since that
> is cleaner user experience.
> Otherwise Ctrl-C of the user process will have bpf program dangling.
> not good. If we auto-unload bpf program only, it's equally bad.
> Since Ctrl-C of the process will auto-onload only
> and will keep tracepoint enabled which will be spamming
> the trace buffer.

I think it's not a problem of bpf.  An user process can be killed
anytime while it enabed events without bpf.  The only thing it should
care is the auto-unload IMHO.


>
>>> +unsigned int trace_filter_call_bpf(struct event_filter *filter, void *ctx)
>>> +{
>>> +     unsigned int ret;
>>> +
>>> +     if (in_nmi()) /* not supported yet */
>>> +             return 0;
>>
>> But doesn't this mean to auto-disable all attached events during NMI
>> as returning 0 will prevent the event going to ring buffer?
>
> well, it means that if tracepoint fired during nmi the program
> won't be called and event won't be sent to trace buffer.
> The program might be broken (like divide by zero) and
> it will self-terminate with 'return 0'
> so zero should be the safest return value that
> causes minimum disturbance to the whole system overall.

I'm okay for not calling bpf program in NMI but not for disabling events.

Suppose an user was collecting an event (including in NMI) and then
[s]he also wanted to run a bpf program.  So [s]he wrote a program
always return 1.  But after attaching the program, it didn't record
the event in NMI..  Isn't that a problem?


>
>> I think it'd be better to keep an attached event in a soft-disabled
>> state like event trigger and give control of enabling to users..
>
> I think it suffers from the same Ctrl-C issue.
> Say, attaching bpf program activates tracepoint and keeps
> it in soft-disabled. Then user space clears soft-disabled.
> Then user Ctrl-C it. Now bpf program must auto-detach
> and unload, since prog_fd is closing.
> If we don't completely deactivate tracepoint, then
> Ctrl-C will leave the state of the system in the state
> different from it was before user process started running.
> I think we must avoid such situation.
> 'kill pid' should be completely cleaning all resources
> that user process was using.
> Yes. It's different from typical usage of /sys/.../tracing
> that has all global knobs, but, imo, it's cleaner this way.

Right.  I think bpf programs belong to a user process but events are
global resource.  Maybe you also need to consider attaching bpf
program via perf (ioctl?) interface..

Thanks,
Namhyung
