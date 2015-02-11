From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Wed, 11 Feb 2015 11:15:21 +0100
Message-ID: <20150211101521.GP23123@twins.programming.kicks-ass.net>
References: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 04:22:50PM -0800, Alexei Starovoitov wrote:
> > It would need to do more that that. It may have to calculate the value
> > that it returns, as the internal value may be different with different
> > kernels.
> 
> back to 'prio'... the 'prio' accessible from the program
> should be the same 'prio' that we're storing inside task_struct.

Its not, task_struct::prio is an entirely different value than the one
used in sched_param::sched_priority / sched_attr::sched_priority.

And the 'problem' is, prio is only relevant to SCHED_RR/SCHED_FIFO
tasks, we have more classes.

> No extra conversions.

We're not going to add runtime/space overhead to the kernel just because
someone might maybe someday trace the kernel.

That leaves the option of either tracing the kernel internal value and
userspace will just have to deal with it, or making the tracepoint more
expensive by having it do the conversion.

Now the big question is, what do we do when we add/extend a scheduling
class and have more parameters? We cannot change the tracepoint because
userspace assumes format. And I simply refuse to add a second -- because
that will end up being a third and fourth etc.. -- tracepoint right next
to it with a different layout.

Note that we just did add a class, we grew SCHED_DEADLINE a few releases
ago, and that has 3 parameters (or 6 depending on how you look at it).
You currently cannot 'debug' that with the existing tracepoints.

In short, I loathe traceevents, they're more trouble than they're worth.

Now I do love the infrastructure, its very useful debugging, but that's
all with local hacks that will never see the light of day.
