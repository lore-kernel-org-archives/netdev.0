From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 4/6] seccomp: add a way to access filters via bpf fds
Date: Fri, 4 Sep 2015 14:58:41 -0600
Message-ID: <20150904205841.GP26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-5-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5j+B_ENy7txG4nndpeOh_z_3d7bBxeJD-WS_yPBZiuZ7rg@mail.gmail.com>
 <20150904202946.GC1842@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150904202946.GC1842@Alexeis-MacBook-Pro-2.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 01:29:49PM -0700, Alexei Starovoitov wrote:
> On Fri, Sep 04, 2015 at 01:26:42PM -0700, Kees Cook wrote:
> > On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
> > <tycho.andersen@canonical.com> wrote:
> > > This patch adds a way for a process that is "real root" to access the
> > > seccomp filters of another process. The process first does a
> > > PTRACE_SECCOMP_GET_FILTER_FD to get an fd with that process' seccomp filter
> > > attached, and then iterates on this with PTRACE_SECCOMP_NEXT_FILTER using
> > > bpf(BPF_PROG_DUMP) to dump the actual program at each step.
> > 
> > Why is this a new ptrace interface instead of a new seccomp interface?
> > I would expect this to only be valid for "current", otherwise we could
> > run into races as the ptracee adds filters.

The task has to be in the stopped state in order for the filters to be
inspected, so I think this isn't a problem.

> > i.e. it is not safe to
> > examine seccomp filters from tasks other than current.
> 
> same question.
> I thought we discussed to add a command to seccomp() syscall for that?

We did initially, although at the end Andy posted about not allowing
tasks to see some filters that had been installed:

On Mon, 10 Aug 2015 14:36:09 -0700 Andy Lutomirski
<luto@amacapital.net> wrote:
> On Mon, Aug 10, 2015 at 2:31 PM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> > On Mon, Aug 10, 2015 at 02:18:29PM -0700, Kees Cook wrote:
> >> On Sun, Aug 9, 2015 at 7:20 PM, Andy Lutomirski
> >> <luto@amacapital.net> wrote:
> >> > On Fri, Aug 7, 2015 at 10:59 AM, Tycho Andersen
> >> > <tycho.andersen@canonical.com> wrote:
> >> >> On Fri, Aug 07, 2015 at 10:36:02AM -0700, Andy Lutomirski wrote:
> >> >>> On Fri, Aug 7, 2015 at 8:45 AM, Tycho Andersen
> >> >>> <tycho.andersen@canonical.com> wrote:
> >> >>> >
> >> >>> > fd = seccomp(SECCOMP_GET_FILTER_FD);
> >> >>>
> >> >>>
> >> >
> >> > Let me propose something crazy.  First, some scenarios:
> >> >
> >> > Scenario A: A program runs in a sandbox.  It tries to interrogate
> >> > its
> >> > seccomp filter.  I think it would be fine, and maybe even
> >> > beneficial,
> >> > if this didn't work (or pretended there was no filter).
> >> >
> >> > Scenario B: A shell runs in a sandbox.  The user fires up some
> >> > program
> >> > in that shell and then, *still in that shell*, checkpoints it
> >> > with
> >> > CRIU.  I think CRIU shouldn't see the seccomp filter.
> >> >
> >> > Scenario C: A program runs in a sandbox.  CRIU, *in a different
> >> > sandbox*, tries to checkpoint that program.  IMO this is doomed
> >> > to
> >> > eventual failure no matter what the kernel does: restoring the
> >> > program
> >> > isn't going to work as expected.
> >> >
> >> > Scenario D: A shell runs in a sandbox.  Someone fires up a
> >> > seccomp-using program (with in inner filter) under that shell and
> >> > then
> >> > separately checkpoints it from inside the shell.  I think CRIU
> >> > should
> >> > see the inner filter but not the outer filter.
> >> >
> >> > So here's my crazy proposal: If process A tries to read process
> >> > B's
> >> > seccomp state, the kernel could check whether B's seccomp state
> >> > is a
> >> > descendent of A's.  If so, then the attempt to read B's seccomp
> >> > state
> >> > should see only the part that stricly descends from A's state.
> >> > (If
> >> > B's and A's states are the same under a referential equality
> >> > test,
> >> > then this means A should see no seccomp state at all).  If, on
> >> > the
> >> > other hand, B's state is not a descendent of A's state, then the
> >> > read
> >> > call should fail.
> >> >
> >> > Thoughts?
> >> >
> >> > At the very least, this means that no one ever needs to worry
> >> > about
> >> > preventing seccomp state reads in their seccomp filter program,
> >> > since
> >> > the filter is invisible from inside the sandbox using that
> >> > filter.
> >>
> >> I don't oppose this idea, but I think our first pass at CRIU can
> >> just
> >> be to work from the init namespace. I don't mind rejecting
> >> filter-reading requests when CAP_SYS_ADMIN is missing or something
> >> like that.
> >
> > The problem is that we can't do a CAP_SYS_ADMIN check, at least with
> > the proposed interface, since the seccomp() syscall will only tell
> > the
> > process about it's own filters. I was going to just have the
> > PT_SUSPEND_SECCOMP flag we use also affect whether seccomp() would
> > allow a task to inspect its own filters.
> >
> > If we do that, the result is that without PT_SUSPEND_SECCOMP, a task
> > always gets EACCES (or an empty list, whichever is better), and with
> > PT_SUSPEND_SECCOMP it always gets the real filters.
> 
> Hmm.  IMO this interface has the downside that we can't really
> implement my crazy proposal on top of it.  Why do we need the task to
> be able to read its own filters at all?  Wouldn't it be easier if the
> ptracer could read the tracee's filters directly?  (Even if it
> required that the tracee be stopped?)

Which is how we ended up with the proposed ptrace() interface. We
could proxy this through seccomp instead, but give that it is an
external process inspecting the filters, it fits better in ptrace IMO.
If we go back to a process asking for its own filters, then we could
do it via seccomp().

Tycho
