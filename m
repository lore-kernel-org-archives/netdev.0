From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: v2 of seccomp filter c/r patches
Date: Mon, 14 Sep 2015 10:52:46 -0700
Message-ID: <CALCETrWH0vLZwkOV6JCnC-pLaHe0dboXs5-ETkXFCR9X-aq7qw@mail.gmail.com>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <CALCETrVYtv1=g-xPjQ-LiX+5GK3xtB6a2hYbat0TuU-Bd4QA6Q@mail.gmail.com>
 <CALCETrWxLMSgdsdT9gTL80LSovONmCcTYjzqrHqF-WdJ4BN1Uw@mail.gmail.com> <20150911172806.GA7244@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150911172806.GA7244@smitten>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sep 11, 2015 10:28 AM, "Tycho Andersen" <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
>
> On Fri, Sep 11, 2015 at 10:00:22AM -0700, Andy Lutomirski wrote:
> > On Fri, Sep 11, 2015 at 9:30 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> > > On Sep 10, 2015 5:22 PM, "Tycho Andersen" <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> > >>
> > >> Hi all,
> > >>
> > >> Here is v2 of the seccomp filter c/r set. The patch notes have individual
> > >> changes from the last series, but there are two points not noted:
> > >>
> > >> * The series still does not allow us to correctly restore state for programs
> > >>   that will use SECCOMP_FILTER_FLAG_TSYNC in the future. Given that we want to
> > >>   keep seccomp_filter's identity, I think something along the lines of another
> > >>   seccomp command like SECCOMP_INHERIT_PARENT is needed (although I'm not sure
> > >>   if this can even be done yet). In addition, we'll need a kcmp command for
> > >>   figuring out if filters are the same, although this too needs to compare
> > >>   seccomp_filter objects, so it's a little screwy. Any thoughts on how to do
> > >>   this nicely are welcome.
> > >
> > > Let's add a concept of a seccompfd.
> > >
> > > For background of what I want to add: I want to be able to create a
> > > seccomp monitor.  A seccomp monitor will be, logically, a pair of a
> > > struct file that represents the monitor and a seccomp_filter that is
> > > controlled by the monitor.  Depending on flags, whoever holds the
> > > monitor fd could change the active filter, intercept syscalls, and
> > > issue syscalls on behalf of a process that is trapped in an
> > > intercepted syscall.
> > >
> > > Seccomp filters would nest properly.
> > >
> > > The interface would probably be (extremely pseudocoded):
> > >
> > > monitor_fd, filter_fd = seccomp(CREATE_MONITOR, flags, ...);
> > >
> > > Then, later:
> > >
> > > seccomp(ATTACH_TO_FILTER, filter_fd);  /* now filtered */
> > >
> > > read(monitor_fd, buf, size); /* returns an intercepted syscall */
> > > write(monitor_fd, buf, size); /* issues a syscall or releases the
> > > trapped task */
> > >
> > > This can't be implemented on x86 without either going insane or
> > > finishing the massive set of pending cleanups to the x86 entry code.
> > > I favor the latter.
> > >
> > > We could, however, add part of it right now: we could have a way to
> > > create a filterfd, we could add kcmp support for it, and we could add
> > > the ATTACH_TO_FILTER thing.  I think that would solve your problem.
> > >
> > > One major open question: does a filter_fd know what its parent is and,
> > > if so, will it just refuse to attach if the caller's parent is wrong?
> > > Or will a filter_fd attach anywhere.
> > >
> >
> > Let me add one more thought:
> >
> > Currently, struct seccomp_filter encodes a strict tree hierarchy: it
> > knows what its parent is.  This only matters as an implementation
> > detail and because TSYNC checks for seccomp_filter equality.
> >
> > We could change this without user-visible effects.  We could say that,
> > for TSYNC purposes, two filter states match if they contain exactly
> > the same layers in the same order where a layer does *not* encode a
> > concept of parent.  We could then say that attaching a classic bpf
> > filter creates a branch new layer that is not equal to any other layer
> > that's been created.
> >
> > This has no effect whatsoever.  The difference would be that we could
> > declare that attaching the same ebpf program twice creates the *same*
> > layer so that, if you fork and both children attach the same ebpf
> > program, then they match for TSYNC purposes.
>
> Would you keep struct seccomp_filter identity here (meaning that you'd
> reach over and grab the seccomp_filter from a sibling thread if it
> existed)? Would it only work for the last filter attached to siblings,
> or for all the filters? This does make my life easier, but I like the
> idea of just using seccompfd directly below as it seems somewhat
> easier (for me at least) to understand,
>

If we did that, it would just be an internal optimization.

> > Similarly, attaching the
> > same hypothetical filterfd would create the same layer.
>
> If we change the api of my current set to have the ptrace commands
> iterate over seccomp fds, it looks something like:
>
> seccompfd = ptrace(GET_FILTER_FD, pid);
> while (ptrace(NEXT_FD, pid, seccompfd) == 0) {
>         if (seccomp(CHECK_INHERITED, seccompfd))
>                 break;
>
>         bpffd = seccomp(GET_BPF_FD, seccompfd);
>         err = buf(BPF_PROG_DUMP, bpffd, &attr);
>         /* save the bpf prog */
> }
>
> then restore can look like:
>
> while (have_noninherited_filters()) {
>         filter = load_filter();
>         bpffd = bpf(BPF_PROG_LOAD, filter);
>         seccompfd = seccomp(SECCOMP_FD_CREATE, bpffd);
>
>         filters[n_filters++] = seccompfd;
> }
>
> /* fork any children as necessary and do the rest of the restore */
>
> for (i = 0; i < n_filters; i++) {
>         seccomp(SECCOMP_FD_INSTALL, filters[i]);
> }
>
> then the only question is how to implement the CHECK_INHERITED command
> on dump.

I don't think it would be a well defined operation.  I think you'd
have to ask "for this pid, give me the nth thing in the stack", since
an fd identifying a layer without reference to its parent would no
longer even be guaranteed to be unique in the filter stack for a given
task.

I'm not sure I entirely like this solution...

>
> If we support the above API, we don't need to think about the concept
> of layers at all, or do any extra work on filter install to preserve
> struct seccomp_filter identity, it just comes naturally.
>
> Tycho
>
> > Thoughts?
> >
> > --Andy
