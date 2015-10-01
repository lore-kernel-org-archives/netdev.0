From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v3 4/5] kcmp: add KCMP_FILE_PRIVATE_DATA
Date: Thu, 1 Oct 2015 10:45:51 -0600
Message-ID: <20151001164551.GF23065@smitten>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
 <1443636820-17083-5-git-send-email-tycho.andersen@canonical.com>
 <CALCETrUosV+ND1BC-qH3xZMaLwnex50SvMhaSa3FQ19oy1MBVg@mail.gmail.com>
 <20150930184129.GB23065@smitten>
 <CALCETrWjLGLAnf5_tCZohKYtTDi5Jo=bk_BkchTgXi8Bzz9YDA@mail.gmail.com>
 <20150930185504.GC23065@smitten>
 <CALCETrWx_yCF7o6ZnbeoDqw-Fxa3GzARX30SZWeg40FMGqR25Q@mail.gmail.com>
 <20150930213909.GD23065@smitten>
 <CALCETrW9-bpUd+quFF7fBjbBLS84VDT4dmBS=-cVe6+9S-DenA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrW9-bpUd+quFF7fBjbBLS84VDT4dmBS=-cVe6+9S-DenA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 02:48:47PM -0700, Andy Lutomirski wrote:
> On Wed, Sep 30, 2015 at 2:39 PM, Tycho Andersen
> <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> > On Wed, Sep 30, 2015 at 11:56:25AM -0700, Andy Lutomirski wrote:
> >> On Wed, Sep 30, 2015 at 11:55 AM, Tycho Andersen
> >> <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> >> > On Wed, Sep 30, 2015 at 11:47:05AM -0700, Andy Lutomirski wrote:
> >> >> On Wed, Sep 30, 2015 at 11:41 AM, Tycho Andersen
> >> >> <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> >> >> > On Wed, Sep 30, 2015 at 11:25:41AM -0700, Andy Lutomirski wrote:
> >> >> >> On Wed, Sep 30, 2015 at 11:13 AM, Tycho Andersen
> >> >> >> <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> >> >> >> > This command allows comparing the underling private data of two fds. This
> >> >> >> > is useful e.g. to find out if a seccomp filter is inherited, since struct
> >> >> >> > seccomp_filter are unique across tasks and are the private_data seccomp
> >> >> >> > fds.
> >> >> >>
> >> >> >> This is very implementation-specific and may have nasty ABI
> >> >> >> consequences far outside seccomp.  Let's do something specific to
> >> >> >> seccomp and/or eBPF.
> >> >> >
> >> >> > We could change the name to a less generic KCMP_SECCOMP_FD or
> >> >> > something, but without some sort of GUID on each struct
> >> >> > seccomp_filter, the implementation would be effectively the same as it
> >> >> > is today. Is that enough, or do we need a GUID?
> >> >> >
> >> >>
> >> >> I don't care about the GUID.  I think we should name it
> >> >> KCMP_SECCOMP_FD and make it only work on seccomp fds.
> >> >
> >> > Ok, I can do that.
> >> >
> >> >> Alternatively, we could figure out why KCMP_FILE doesn't do the trick
> >> >> and consider fixing it.  IMO it's really too bad that struct file is
> >> >> so heavyweight that we can't really just embed one in all kinds of
> >> >> structures.
> >> >
> >> > The problem is that KCMP_FILE compares the file objects themselves,
> >> > instead of the underlying data. If I ask for a seccomp fd for filter 0
> >> > twice, I'll have two different file objects and they won't be equal. I
> >> > suppose we could add some special logic inside KCMP_FILE to compare
> >> > the underlying data in special cases (seccomp, ebpf, others?), but it
> >> > seems cleaner to have a separate command as you described above.
> >> >
> >>
> >> What I meant was that maybe we could get the two requests to actually
> >> produce the same struct file.  But that could get very messy
> >> memory-wise.
> >
> > I see. The attached patch seems to work with KCMP_FILE and doesn't
> > look too bad if you don't mind the circular references. What do you
> > think?
> >
> 
> Could be reasonable.  I'm not that well versed on what fd_release
> does.  Are we guaranteed that it's called when the last fd goes away
> even if the struct file is pinned by the struct seccomp filter but is
> otherwise unreferenced?

After thinking about the patch a bit more, I think it's not safe.
There is a race where the last referenced is closed at the same time
someone else asks for the strcut file via ptrace(). I thought the lock
would fix this, but it doesn't. I'll see if I can find another way.

Tycho
