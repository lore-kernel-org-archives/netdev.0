From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH v2 4/5] seccomp: add a way to access filters via bpf fds
Date: Fri, 11 Sep 2015 10:44:44 -0600
Message-ID: <20150911164444.GQ27574@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <1441930862-14347-5-git-send-email-tycho.andersen@canonical.com>
 <CALCETrUD0JAAwThT8tTQ50q-+ZOKjLCxUW3=VDG8=dmLYDtW3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Kees Cook <keescook@chromium.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Oleg Nesterov <oleg@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux API <linux-api@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrUD0JAAwThT8tTQ50q-+ZOKjLCxUW3=VDG8=dmLYDtW3w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 09:20:55AM -0700, Andy Lutomirski wrote:
> On Sep 10, 2015 5:22 PM, "Tycho Andersen" <tycho.andersen@canonical.com> wrote:
> >
> > This patch adds a way for a process that is "real root" to access the
> > seccomp filters of another process. The process first does a
> > PTRACE_SECCOMP_GET_FILTER_FD to get an fd with that process' seccomp filter
> > attached, and then iterates on this with PTRACE_SECCOMP_NEXT_FILTER using
> > bpf(BPF_PROG_DUMP) to dump the actual program at each step.
> >
> 
> > +
> > +       fd = bpf_new_fd(filter->prog, O_RDONLY);
> > +       if (fd > 0)
> > +               atomic_inc(&filter->prog->aux->refcnt);
> 
> Why isn't this folded into bpf_new_fd?

No reason it can't be as far as I can see. I'll make the change for
the next version.

> > +
> > +       return fd;
> > +}
> > +
> > +long seccomp_next_filter(struct task_struct *child, u32 fd)
> > +{
> > +       struct seccomp_filter *cur;
> > +       struct bpf_prog *prog;
> > +       long ret = -ESRCH;
> > +
> > +       if (!capable(CAP_SYS_ADMIN))
> > +               return -EACCES;
> > +
> > +       if (child->seccomp.mode != SECCOMP_MODE_FILTER)
> > +               return -EINVAL;
> > +
> > +       prog = bpf_prog_get(fd);
> > +       if (IS_ERR(prog)) {
> > +               ret = PTR_ERR(prog);
> > +               goto out;
> > +       }
> > +
> > +       for (cur = child->seccomp.filter; cur; cur = cur->prev) {
> > +               if (cur->prog == prog) {
> > +                       if (!cur->prev)
> > +                               ret = -ENOENT;
> > +                       else
> > +                               ret = bpf_prog_set(fd, cur->prev->prog);
> 
> This lets you take an fd pointing to one prog and point it elsewhere.
> I'm not sure that's a good idea.

That's how the interface was designed (calling ptrace(NEXT_FILTER, fd) and
then doing bpf(DUMP, fd)). I suppose we could have NEXT_FILTER return
a new fd instead if that seems better to you.

Tycho
