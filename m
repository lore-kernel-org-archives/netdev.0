From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 08:05:26 -0500
Message-ID: <20150210080526.1d8a119e@grimm.local.home>
References: <CAMEtUuztTca2jC9Su0YkTHEUHsD4p2PBRyukabrjGO0WfFzdfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuztTca2jC9Su0YkTHEUHsD4p2PBRyukabrjGO0WfFzdfA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2015 22:10:45 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> One can argue that current TP_printk format is already an ABI,
> because somebody might be parsing the text output.

If somebody does, then it is an ABI. Luckily, it's not that useful to
parse, thus it hasn't been an issue. As Linus has stated in the past,
it's not that we can't change ABI interfaces, its just that we can not
change them if there's a user space application that depends on it.

The harder we make it for interface changes to break user space, the
better. The field layouts is a user interface. In fact, some of those
fields must always be there. This is because tools do parse the layout
and expect some events to have specific fields. Now we can add new
fields, or even remove fields that no user space tool is using. This is
because today, tools use libtraceevent to parse the event data.

This is why I'm nervous about exporting the parameters of the trace
event call. Right now, those parameters can always change, because the
only way to know they exist is by looking at the code. And currently,
there's no way to interact with those parameters. Once we have eBPF in
mainline, we now have a way to interact with the parameters and if
those parameters change, then the eBPF program will break, and if eBPF
can be part of a user space tool, that will break that tool and
whatever change in the trace point that caused this breakage would have
to be reverted. IOW, this can limit development in the kernel.

Al Viro currently does not let any tracepoint in VFS because he doesn't
want the internals of that code locked to an ABI. He's right to be
worried.

> so in some cases we cannot change tracepoints without
> somebody complaining that his tool broke.
> In other cases tracepoints are used for debugging only
> and no one will notice when they change...
> It was and still a grey area.

Not really. If a tool uses the tracepoint, it can lock that tracepoint
down. This is exactly what latencytop did. It happened, it's not a
hypothetical situation.

> bpf doesn't change any of that.
> It actually makes addition of new tracepoints easier.

I totally disagree. It adds more ways to see inside the kernel, and if
user space depends on this, it adds more ways the kernel can not change.

It comes down to how robust eBPF is with the internals of the kernel
changing. If we limit eBPF to system call tracepoints only, that's
fine because those have the same ABI as the system call itself. I'm
worried about the internal tracepoints for scheduling, irqs, file
systems, etc.


> In the future we might add a tracepoint and pass a single
> pointer to interesting data struct to it. bpf programs will walk
> data structures 'as safe modules' via bpf_fetch*() methods
> without exposing it as ABI.

Will this work if that structure changes? When the field we are looking
for no longer exists?

> whereas today we pass a lot of fields to tracepoints and
> make all of these fields immutable.

The parameters passed to the tracepoint are not shown to userspace and
can change at will. Now, we present the final parsing of the parameters
that convert to fields. As all currently known tools uses
libtraceevent.a, and parse the format files, those fields can move
around and even change in size. The structures are not immutable. The
fields are locked down if user space relies on them. But they can move
about within the tracepoint, because the parsing allows for it.

Remember, these are processed fields. The result of TP_fast_assign()
and what gets put into the ring buffer. Now what is passed to the
actual tracepoint is not visible by userspace, and in lots of cases, it
is just a pointer to some structure. What eBPF brings to the table is a
way to access this structure from user space. What keeps a structured
passed to a tracepoint from becoming immutable if there's a eBPF
program that expects it to have a specific field?


> 
> To me tracepoints are like gdb breakpoints.

Unfortunately, it doesn't matter what you think they are. It doesn't
matter what I think they are. What matters is what Linus thinks they
are and if user space depends on it and Linus decides to revert what
ever change broke that user space program, no matter what we think, we
just screwed ourselves.

I'm being stubborn on this because this is exactly what happened in the
past, which caused every trace point to hold 4 bytes of padding. 4
bytes may not sound like a lot, but when you have 1 million
tracepoints, that's 4 megs of wasted space.

> and bpf programs like live debugger that examine things.

If bpf programs only dealt with kprobes, I may agree. But tracepoints
have already been proven to be a type of ABI. If we open another window
into the kernel, this can screw us later. It's better to solve this now
than when we are fighting with Linus over user space breakage.

> 
> the next step is to be able to write bpf scripts on the fly
> without leaving debugger. Something like perf probe +
> editor + live execution. Truly like gdb for kernel.
> while kernel is running.

What we need is to know if eBPF programs are modules or a user space
interface. If they are a user interface then we need to be extremely
careful here. If they are treated the same as modules, then it would
not add any API. But that hasn't been settled yet, even if we have a
comment in the kernel.

Maybe what we should do is to make eBPF pass the kernel version it was
made for (with all the mod version checks). If it doesn't match, fail
to load it. Perhaps the more eBPF is limited like modules are, the
better chance we have that no eBPF program creates a new ABI.

-- Steve
