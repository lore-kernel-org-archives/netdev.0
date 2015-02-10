From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 16:53:59 -0500
Message-ID: <20150210165359.34cc53d9@gandalf.local.home>
References: <CAMEtUuwAf4AFeWVEdJB4VQz_=2fWY=q8=rbkFg38rtVtNVCHxg@mail.gmail.com>
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
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuwAf4AFeWVEdJB4VQz_=2fWY=q8=rbkFg38rtVtNVCHxg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2015 11:53:22 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> On Tue, Feb 10, 2015 at 5:05 AM, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> > On Mon, 9 Feb 2015 22:10:45 -0800
> > Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> >
> >> One can argue that current TP_printk format is already an ABI,
> >> because somebody might be parsing the text output.
> >
> > If somebody does, then it is an ABI. Luckily, it's not that useful to
> > parse, thus it hasn't been an issue. As Linus has stated in the past,
> > it's not that we can't change ABI interfaces, its just that we can not
> > change them if there's a user space application that depends on it.
> 
> there are already tools that parse trace_pipe:
> https://github.com/brendangregg/perf-tools

Yep, and if this becomes a standard, then any change that makes
trace_pipe different will be reverted.

> 
> > and expect some events to have specific fields. Now we can add new
> > fields, or even remove fields that no user space tool is using. This is
> > because today, tools use libtraceevent to parse the event data.
> 
> not all tools use libtraceevent.
> gdb calls perf_event_open directly:
> https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=blob;f=gdb/nat/linux-btrace.c
> and parses PERF_RECORD_SAMPLE as a binary.
> In this case it's branch records, but I think we never said anywhere
> that PERF_SAMPLE_IP | PERF_SAMPLE_ADDR should come
> in this particular order.

What particular order? Note, that's a hardware event, not a software
one.

> 
> > This is why I'm nervous about exporting the parameters of the trace
> > event call. Right now, those parameters can always change, because the
> > only way to know they exist is by looking at the code. And currently,
> > there's no way to interact with those parameters. Once we have eBPF in
> > mainline, we now have a way to interact with the parameters and if
> > those parameters change, then the eBPF program will break, and if eBPF
> > can be part of a user space tool, that will break that tool and
> > whatever change in the trace point that caused this breakage would have
> > to be reverted. IOW, this can limit development in the kernel.
> 
> it can limit development unless we say that bpf programs
> that attach to tracepoints are not part of ABI.
> Easy enough to add large comment similar to perf_event.h

Again, it doesn't matter what we say. Linus made that very clear. He
stated if you provide an interface, and someone uses that interface for
a user space application, and they complain if it breaks, that is just
reason to revert whatever broke it.

> 
> > Al Viro currently does not let any tracepoint in VFS because he doesn't
> > want the internals of that code locked to an ABI. He's right to be
> > worried.
> 
> Same with networking bits. We don't want tracepoints to limit
> kernel development, but we want debuggability and kernel
> analytics.
> All existing tracepoints defined via DEFINE_EVENT should
> not be an ABI.

I agree, but that doesn't make it so :-/

> But some maintainers think of them as ABI, whereas others
> are using them freely. imo it's time to remove ambiguity.

I would love to, and have brought this up at Kernel Summit more than
once with no solution out of it.

> 
> The idea for new style of tracepoints is the following:
> introduce new macro: DEFINE_EVENT_USER
> and let programs attach to them.

We actually have that today. But it's TRACE_EVENT_FLAGS(), although
that should be cleaned up a bit. Frederic added it to label events that
are safe for perf non root. It seems to be used currently only for
syscalls.

> These tracepoint will receive one or two pointers to important
> structs only. They will not have TP_printk, assign and fields.
> The placement and arguments to these new tracepoints
> will be an ABI.
> All existing tracepoints are not.

TP_printk() is not really an issue.

> 
> The main reason to attach to tracepoint is that they are
> accessible without debug info (unlike kprobe)

That is, if you have a special bpf call to access variables, right? How
else do you access part of a data structure.

> Another reason is speed. tracepoints are much faster than
> optimized kprobes and for real-time analytics the speed
> is critical.
> 
> The position of new tracepoints and their arguments
> will be an ABI and the programs can be both.

You means "special tracepoints" one that does export the arguments?

Question is, how many maintainers will add these, knowing that they
will have to be forever maintained as is.

> If program is using bpf_fetch*() helpers it obviously
> wants to access internal data structures, so
> it's really nothing more, but 'safe kernel module'
> and kernel layout specific.
> Both old and new tracepoints + programs will be used
> for live kernel debugging.
> 
> If program is accessing user-ized data structures then

Technically, the TP_struct__entry is a user-ized structure.

> it is portable and will run on any kernel.
> In uapi header we can define:
> struct task_struct_user {
>   int pid;
>   int prio;

Here's a perfect example of something that looks stable to show to
user space, but is really a pimple that is hiding cancer.

Lets start with pid. We have name spaces. What pid will be put there?
We have to show the pid of the name space it is under.

Then we have prio. What is prio in the DEADLINE scheduler. It is rather
meaningless. Also, it is meaningless in SCHED_OTHER.

Also note that even for SCHED_FIFO, the prio is used differently in the
kernel than it is in userspace. For the kernel, lower is higher.

> };
> and let bpf programs access it via real 'struct task_struct *'
> pointer passed into tracepoint.
> bpf loader will translate offsets and sizes used inside
> the program into real task_struct's offsets and loads.

It would need to do more that that. It may have to calculate the value
that it returns, as the internal value may be different with different
kernels.

> (all structs are read-only of course)
> programs will be fast and kernel independent.
> They will be used for analytics (latency, etc)
> 
> >> so in some cases we cannot change tracepoints without
> >> somebody complaining that his tool broke.
> >> In other cases tracepoints are used for debugging only
> >> and no one will notice when they change...
> >> It was and still a grey area.
> >
> > Not really. If a tool uses the tracepoint, it can lock that tracepoint
> > down. This is exactly what latencytop did. It happened, it's not a
> > hypothetical situation.
> 
> correct.
> 
> >> bpf doesn't change any of that.
> >> It actually makes addition of new tracepoints easier.
> >
> > I totally disagree. It adds more ways to see inside the kernel, and if
> > user space depends on this, it adds more ways the kernel can not change.
> >
> > It comes down to how robust eBPF is with the internals of the kernel
> > changing. If we limit eBPF to system call tracepoints only, that's
> > fine because those have the same ABI as the system call itself. I'm
> > worried about the internal tracepoints for scheduling, irqs, file
> > systems, etc.
> 
> agree. we need to make it clear that existing tracepoints
> + programs is not ABI.

The question is, how do we do that. Linus pointed out that comments and
documentation is not enough. We need to have an interface that users
would use before they use one that we do not like them to use.

> 
> >> In the future we might add a tracepoint and pass a single
> >> pointer to interesting data struct to it. bpf programs will walk
> >> data structures 'as safe modules' via bpf_fetch*() methods
> >> without exposing it as ABI.
> >
> > Will this work if that structure changes? When the field we are looking
> > for no longer exists?
> 
> bpf_fetch*() is the same mechanism as perf probe.
> If there is a mistake by user space tools, the program
> will be reading some junk, but it won't be crashing.

But what if the userspace tool depends on that value returning
something meaningful. If it was meaningful in the past, it will have to
be meaningful in the future, even if the internals of the kernel make
it otherwise.

> To be able to debug live kernel we need to see everywhere.
> Same way as systemtap loads kernel modules to walk
> things inside kernel, bpf programs walk pointers with
> bpf_fetch*().

I would agree here too. But again, we really need to be careful about
the interface we expose.

> I'm saying that if program is using bpf_fetch*()
> it wants to see kernel internals and obviously depends
> on particular kernel layout.

Right, but if there's something specific in that kernel layout that it
can decide to do something with, otherwise it breaks, then we need to
worry about it.

eBPF is very flexible, which means it is bound to have someone use it
in a way you never dreamed of, and that will be what bites you in the
end (pun intended).

> 
> >> whereas today we pass a lot of fields to tracepoints and
> >> make all of these fields immutable.
> >
> > The parameters passed to the tracepoint are not shown to userspace and
> > can change at will. Now, we present the final parsing of the parameters
> > that convert to fields. As all currently known tools uses
> > libtraceevent.a, and parse the format files, those fields can move
> > around and even change in size. The structures are not immutable. The
> > fields are locked down if user space relies on them. But they can move
> > about within the tracepoint, because the parsing allows for it.
> >
> > Remember, these are processed fields. The result of TP_fast_assign()
> > and what gets put into the ring buffer. Now what is passed to the
> > actual tracepoint is not visible by userspace, and in lots of cases, it
> > is just a pointer to some structure. What eBPF brings to the table is a
> > way to access this structure from user space. What keeps a structured
> > passed to a tracepoint from becoming immutable if there's a eBPF
> > program that expects it to have a specific field?
> 
> agree. that's fair.
> I'm proposing to treat bpf programs that attach to existing
> tracepoints as kernel modules that carry no ABI claims.

Yeah, we may need to find a way to guarantee that.

> 
> >> and bpf programs like live debugger that examine things.
> >
> > If bpf programs only dealt with kprobes, I may agree. But tracepoints
> > have already been proven to be a type of ABI. If we open another window
> > into the kernel, this can screw us later. It's better to solve this now
> > than when we are fighting with Linus over user space breakage.
> 
> I'm not sure what's more needed other than adding
> large comments into documentation, man pages and sample
> code that bpf+existing tracepoint is not an ABI.

Making it break as soon as a config or kernel version changes ;-)

That may be the only way to guarantee that users do not rely on it.

> 
> > What we need is to know if eBPF programs are modules or a user space
> > interface. If they are a user interface then we need to be extremely
> > careful here. If they are treated the same as modules, then it would
> > not add any API. But that hasn't been settled yet, even if we have a
> > comment in the kernel.
> >
> > Maybe what we should do is to make eBPF pass the kernel version it was
> > made for (with all the mod version checks). If it doesn't match, fail
> > to load it. Perhaps the more eBPF is limited like modules are, the
> > better chance we have that no eBPF program creates a new ABI.
> 
> it's easy to add kernel version check and it will be equally
> easy for user space to hack it.

Well, if the bpf program says it is built for kernel 3.19, but the
user tool fudges it to say it was built for kernel 3.20, but it breaks,
than how can they complain about a regression? The tool itself says it
was built for 3.20 but doesn't work. You need to show that same program
worked on 3.19, but it wont because 3.20 wont work there.

> imo comments in documentation and samples is good enough.

Again, your and my opinion do not matter. It comes down to what Linus
thinks. And if we expose an interface that applications decide to use,
and it breaks when a design in the kernel changes, Linus may revert
that change. The author of that change will not be too happy with us.

> 
> also not all bpf programs are equal.
> bpf+existing tracepoint is not ABI

Why not?

> bpf+new tracepoint is ABI if programs are not using bpf_fetch

How is this different?

> bpf+syscall is ABI if programs are not using bpf_fetch

Well, this is easy. As syscalls are ABI, and the tracepoints for them
match the ABI, it by default becomes an ABI.

> bpf+kprobe is not ABI

Right.

> bpf+sockets is ABI

Right, because sockets themselves are ABI.

> At the end we want most of the programs to be written
> without assuming anything about kernel internals.
> But for live kernel debugging we will write programs
> very specific to given kernel layout.

And here lies the trick. How do we differentiate applications for
everyday use from debugging tools? There's been times when debugging
tools have shown themselves as being so useful they become everyday
use tools.

> 
> We can categorize the above in non-ambigous via
> bpf program type.
> Programs with:
> BPF_PROG_TYPE_TRACEPOINT - not ABI
> BPF_PROG_TYPE_KPROBE - not ABI
> BPF_PROG_TYPE_SOCKET_FILTER - ABI

Again, what enforces this? (hint, it's Linus)


> 
> for my proposed 'new tracepoints' we can add type:
> BPF_PROG_TYPE_TRACEPOINT_USER - ABI
> and disallow calls to bpf_fetch*() for them.
> To make it more strict we can do kernel version check
> for all prog types that are 'not ABI', but is it really necessary?

If we have something that makes it difficult for a tool to work from
one kernel to the next, or ever with different configs, where that tool
will never become a standard, then that should be good enough to keep
it from dictating user ABI.

To give you an example, we thought about scrambling the trace event
field locations from boot to boot to keep tools from hard coding the
event layout. This may sound crazy, but developers out there are crazy.
And if you want to keep them from abusing interfaces, you just need to
be a bit more crazy than they are.


> 
> To summarize and consolidate other threads:
> - I will remove reading of PERF_SAMPLE_RAW in tracex1 example.
> it's really orthogonal to this whole discussion.

Or yous libtraceevent ;-) We really need to finish that and package it
up for distros.

> - will add more comments through out that just because
> programs can read tracepoint arguments, they shouldn't
> make any assumptions that args stays as-is from version to version

We may need to find a way to actually keep it from being as is from
version to version even if the users do not change.

> - will work on a patch to demonstrate how few in-kernel
> structures can be user-ized and how programs can access
> them in version-indepedent way

It will be interesting to see what kernel structures can be user-ized
that are not already used by system calls.

> 
> btw the concept of user-ized data structures already exists
> with classic bpf, since 'A = load -0x1000' is translated into
> 'A = skb->protocol'. I'm thinking of something similar
> but more generic and less obscure.

I have to try to wrap my head around understanding the classic bpf, and
how "load -0x1000" translates to "skb->protocol". Is that documented
somewhere?

-- Steve
