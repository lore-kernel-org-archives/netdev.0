From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Wed, 28 Jan 2015 20:40:11 -0800
Message-ID: <CAMEtUuz+N52ms4ZFh8+fSGhg1UaXpBdk9RVPU_zBDCjaZ4bj4A@mail.gmail.com>
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
To: Namhyung Kim <namhyung@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:45185 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbbA2Ekc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 23:40:32 -0500
Received: by mail-qg0-f43.google.com with SMTP id e89so23706822qgf.2
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 20:40:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2015 at 4:46 PM, Namhyung Kim <namhyung@kernel.org> wrote:
>>
>> +static int event_filter_release(struct inode *inode, struct file *filp)
>> +{
>> +     struct ftrace_event_file *file;
>> +     char buf[2] = "0";
>> +
>> +     mutex_lock(&event_mutex);
>> +     file = event_file_data(filp);
>> +     if (file) {
>> +             if (file->flags & TRACE_EVENT_FL_BPF) {
>> +                     /* auto-disable the filter */
>> +                     ftrace_event_enable_disable(file, 0);
>
> Hmm.. what if user already enabled an event, attached a bpf filter and
> then detached the filter - I'm not sure we can always auto-disable
> it..

why not?
I think it makes sense auto enable/disable, since that
is cleaner user experience.
Otherwise Ctrl-C of the user process will have bpf program dangling.
not good. If we auto-unload bpf program only, it's equally bad.
Since Ctrl-C of the process will auto-onload only
and will keep tracepoint enabled which will be spamming
the trace buffer.

>> +unsigned int trace_filter_call_bpf(struct event_filter *filter, void *ctx)
>> +{
>> +     unsigned int ret;
>> +
>> +     if (in_nmi()) /* not supported yet */
>> +             return 0;
>
> But doesn't this mean to auto-disable all attached events during NMI
> as returning 0 will prevent the event going to ring buffer?

well, it means that if tracepoint fired during nmi the program
won't be called and event won't be sent to trace buffer.
The program might be broken (like divide by zero) and
it will self-terminate with 'return 0'
so zero should be the safest return value that
causes minimum disturbance to the whole system overall.

> I think it'd be better to keep an attached event in a soft-disabled
> state like event trigger and give control of enabling to users..

I think it suffers from the same Ctrl-C issue.
Say, attaching bpf program activates tracepoint and keeps
it in soft-disabled. Then user space clears soft-disabled.
Then user Ctrl-C it. Now bpf program must auto-detach
and unload, since prog_fd is closing.
If we don't completely deactivate tracepoint, then
Ctrl-C will leave the state of the system in the state
different from it was before user process started running.
I think we must avoid such situation.
'kill pid' should be completely cleaning all resources
that user process was using.
Yes. It's different from typical usage of /sys/.../tracing
that has all global knobs, but, imo, it's cleaner this way.
