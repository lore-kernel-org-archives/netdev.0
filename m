From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH tip 0/9] tracing: attach eBPF programs to tracepoints/syscalls/kprobe
Date: Wed, 21 Jan 2015 17:49:08 -0800
Message-ID: <CAMEtUux8v2LDtLcgpT9hCvJgnrCwT2fkzsSvAPFSuEUx+itxyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 21, 2015 at 5:03 PM, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> AFAIK a trigger can be fired before allocating a ring buffer if it
> doesn't use the event record (i.e. has filter) or ->post_trigger bit
> set (stacktrace).  Please see ftrace_trigger_soft_disabled().

yes, but such trigger has no arguments, so I would have to hack
ftrace_trigger_soft_disabled() to pass 'ctx' further down
and through all pointer dereferences and list walking.
Also there is no return value, so I have to add it as well
similar to post-triggers.
that's quite a bit of overhead that I would like to avoid.

Actually now I'm thinking to move condition
if (ftrace_file->flags & TRACE_EVENT_FL_BPF)
before ftrace_trigger_soft_disabled() check.
So programs always run first and if they return non-zero
then all standard processing will follow.
May be return value from the program can influence triggers.
That will nicely replace bpf_dump_stack()...the program
will return ETT_STACKTRACE constant to trigger dump.

> This also makes it keeping events in the soft-disabled state.

I was never able to figure out the use case for soft-disabled state.
Probably historical before static_key was done.
