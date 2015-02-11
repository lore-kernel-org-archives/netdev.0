From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 19:50:29 -0500
Message-ID: <20150210195029.2092bdd6@grimm.local.home>
References: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA@mail.gmail.com>
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
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2015 16:22:50 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> > Yep, and if this becomes a standard, then any change that makes
> > trace_pipe different will be reverted.
> 
> I think reading of trace_pipe is widespread.

I've heard of a few, but nothing that has broken when something changed.

Is it scripts or actual C code?

Again, it matters if people complain about the change.


> >> But some maintainers think of them as ABI, whereas others
> >> are using them freely. imo it's time to remove ambiguity.
> >
> > I would love to, and have brought this up at Kernel Summit more than
> > once with no solution out of it.
> 
> let's try it again at plumbers in august?

Well, we need a statement from Linus. And it would be nice if we could
also get Ingo involved in the discussion, but he seldom comes to
anything but Kernel Summit.

> 
> For now I'm going to drop bpf+tracepoints, since it's so controversial
> and go with bpf+syscall and bpf+kprobe only.

Probably the safest bet.

> 
> Hopefully by august it will be clear what bpf+kprobes can do
> and why I'm excited about bpf+tracepoints in the future.

BTW, I wonder if I could make a simple compiler in the kernel that
would translate the current ftrace filters into a BPF program, where it
could use the program and not use the current filter logic.


> >> These tracepoint will receive one or two pointers to important
> >> structs only. They will not have TP_printk, assign and fields.
> >> The placement and arguments to these new tracepoints
> >> will be an ABI.
> >> All existing tracepoints are not.
> >
> > TP_printk() is not really an issue.
> 
> I think it is. The way things are printed is the most
> visible part of tracepoints and I suspect maintainers don't
> want to add new ones, because internal fields are printed
> and users do parse trace_pipe.
> Recent discussion about tcp instrumentation was
> about adding new tracepoints and a module to print them.
> As soon as something like this is in, the next question
> 'what we're going to do when more arguments need
> to be printed'...

I should rephrase that. It's not that it's not an issue, it's just that
it hasn't been an issue. the trace_pipe code is slow. The
raw_trace_pipe is much faster. Any tool would benefit from using it.

I really need to get a library out to help users do such a thing.


> 
> imo the solution is DEFINE_EVENT_BPF that doesn't
> print anything and a bpf program to process it.

You mean to be completely invisible to ftrace? And the debugfs/tracefs
directory?


> >
> >> it is portable and will run on any kernel.
> >> In uapi header we can define:
> >> struct task_struct_user {
> >>   int pid;
> >>   int prio;
> >
> > Here's a perfect example of something that looks stable to show to
> > user space, but is really a pimple that is hiding cancer.
> >
> > Lets start with pid. We have name spaces. What pid will be put there?
> > We have to show the pid of the name space it is under.
> >
> > Then we have prio. What is prio in the DEADLINE scheduler. It is rather
> > meaningless. Also, it is meaningless in SCHED_OTHER.
> >
> > Also note that even for SCHED_FIFO, the prio is used differently in the
> > kernel than it is in userspace. For the kernel, lower is higher.
> 
> well, ->prio and ->pid are already printed by sched tracepoints
> and their meaning depends on scheduler. So users taking that
> into account.

I know, and Peter hates this.

> I'm not suggesting to preserve the meaning of 'pid' semantically
> in all cases. That's not what users would want anyway.
> I want to allow programs to access important fields and print
> them in more generic way than current TP_printk does.
> Then exposed ABI of such tracepoint_bpf is smaller than
> with current tracepoints.

Again, this would mean they become invisible to ftrace, and even
ftrace_dump_on_oops.

I'm not fully understanding what is to be exported by this new ABI. If
the fields available, will always be available, then why can't the
appear in a TP_printk()?


> > eBPF is very flexible, which means it is bound to have someone use it
> > in a way you never dreamed of, and that will be what bites you in the
> > end (pun intended).
> 
> understood :)
> let's start slow then with bpf+syscall and bpf+kprobe only.

I'm fine with that.

> 
> >> also not all bpf programs are equal.
> >> bpf+existing tracepoint is not ABI
> >
> > Why not?
> 
> well, because we want to see more tracepoints in the kernel.
> We're already struggling to add more.

Still, the question is, even with a new "tracepoint" that limits what
it shows, there still needs to be something that is guaranteed to
always be there. I still don't see how this is different than the
current tracepoints.

> 
> >> bpf+new tracepoint is ABI if programs are not using bpf_fetch
> >
> > How is this different?
> 
> the new ones will be explicit by definition.

Who monitors this?



> > To give you an example, we thought about scrambling the trace event
> > field locations from boot to boot to keep tools from hard coding the
> > event layout. This may sound crazy, but developers out there are crazy.
> > And if you want to keep them from abusing interfaces, you just need to
> > be a bit more crazy than they are.
> 
> that is indeed crazy. the point is understood.
> 
> right now I cannot think of a solid way to prevent abuse
> of bpf+tracepoint, so just going to drop it for now.

Welcome to our world ;-)

> Cool things can be done with bpf+kprobe/syscall already.

True.

-- Steve
