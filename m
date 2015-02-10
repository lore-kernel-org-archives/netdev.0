From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Mon, 9 Feb 2015 22:10:45 -0800
Message-ID: <CAMEtUuztTca2jC9Su0YkTHEUHsD4p2PBRyukabrjGO0WfFzdfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 9, 2015 at 9:13 PM, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
>>                                                                       \
>> +     if (prog) {                                                     \
>> +             __maybe_unused const u64 z = 0;                         \
>> +             struct bpf_context __ctx = ((struct bpf_context) {      \
>> +                             __BPF_CAST6(args, z, z, z, z, z)        \
>
> Note, there is no guarantee that args is at most 6. For example, in
> drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_events.h, the
> trace_event brcms_txstatus has 8 args.
>
> But I guess that's OK if you do not need those last args, right?

yeah, some tracepoints pass a lot of things.
That's rare and in most of the cases they can be fetched
from parent structure.

> I'm nervous about showing args of tracepoints too, because we don't want
> that to become a strict ABI either.

One can argue that current TP_printk format is already an ABI,
because somebody might be parsing the text output.
so in some cases we cannot change tracepoints without
somebody complaining that his tool broke.
In other cases tracepoints are used for debugging only
and no one will notice when they change...
It was and still a grey area.
bpf doesn't change any of that.
It actually makes addition of new tracepoints easier.
In the future we might add a tracepoint and pass a single
pointer to interesting data struct to it. bpf programs will walk
data structures 'as safe modules' via bpf_fetch*() methods
without exposing it as ABI.
whereas today we pass a lot of fields to tracepoints and
make all of these fields immutable.

To me tracepoints are like gdb breakpoints.
and bpf programs like live debugger that examine things.

the next step is to be able to write bpf scripts on the fly
without leaving debugger. Something like perf probe +
editor + live execution. Truly like gdb for kernel.
while kernel is running.
