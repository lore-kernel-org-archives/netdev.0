From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Fri, 6 Apr 2012 14:05:03 -0700
Message-ID: <20120406140503.10b75c5b.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
	<20120406132330.457a05cf.akpm@linux-foundation.org>
	<CAGXu5jJVDLzCOyCo-q6+pF-_3v4Ws8jBzYXwac419uv2QQS0mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, jmorris@namei.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jJVDLzCOyCo-q6+pF-_3v4Ws8jBzYXwac419uv2QQS0mA@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 6 Apr 2012 13:44:43 -0700
Kees Cook <keescook@chromium.org> wrote:

> On Fri, Apr 6, 2012 at 1:23 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 29 Mar 2012 15:01:53 -0500
> > Will Drewry <wad@chromium.org> wrote:
> >
> >> [This patch depends on luto@mit.edu's no_new_privs patch:
> >>    https://lkml.org/lkml/2012/1/30/264
> >>  included in this series for ease of consumption.
> >> ]
> >>
> >> This patch adds support for seccomp mode 2.  Mode 2 introduces the
> >> ability for unprivileged processes to install system call filtering
> >> policy expressed in terms of a Berkeley Packet Filter (BPF) program.
> >> This program will be evaluated in the kernel for each system call
> >> the task makes and computes a result based on data in the format
> >> of struct seccomp_data.
> >> ...
> >> +static void seccomp_filter_log_failure(int syscall)
> >> +{
> >> +     int compat = 0;
> >> +#ifdef CONFIG_COMPAT
> >> +     compat = is_compat_task();
> >> +#endif
> >
> > hm, I'm surprised that we don't have a zero-returning implementation of
> > is_compat_task() when CONFIG_COMPAT=n.  Seems silly.  Blames Arnd.
> 
> There is

I can't find it.  The definition in include/linux/compat.h is inside
#ifdef CONFIG_COMPAT.

> >> +static long seccomp_attach_filter(struct sock_fprog *fprog)
> >> +{
> >> +     struct seccomp_filter *filter;
> >> +     unsigned long fp_size = fprog->len * sizeof(struct sock_filter);
> >> +     unsigned long total_insns = fprog->len;
> >> +     long ret;
> >> +
> >> +     if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
> >> +             return -EINVAL;
> >> +
> >> +     for (filter = current->seccomp.filter; filter; filter = filter->prev)
> >> +             total_insns += filter->len + 4;  /* include a 4 instr penalty */
> >
> > So tasks don't share filters?  We copy them by value at fork?  Do we do
> > this at vfork() too?
> 
> The filter chain is shared (and refcounted).

So what's the locking rule for accessing and modifying that
singly-linked list?

> ...
> >> +/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
> >> +void put_seccomp_filter(struct task_struct *tsk)
> >> +{
> >> +     struct seccomp_filter *orig = tsk->seccomp.filter;
> >> +     /* Clean up single-reference branches iteratively. */
> >> +     while (orig && atomic_dec_and_test(&orig->usage)) {
> >> +             struct seccomp_filter *freeme = orig;
> >> +             orig = orig->prev;
> >> +             kfree(freeme);
> >> +     }
> >> +}
> >
> > So if one of the filters in the list has an elevated refcount, we bail
> > out on the remainder of the list.  Seems odd.
> 
> This so that every filter in the list doesn't need to have their
> refcount raised. As long as the counting up matching the counting
> down, it's fine. This allows for process trees branching the filter
> list at different times still being safe. IIUC, this code was based on
> how namespace refcounting is handled. I spent some time proving to
> myself that it was correctly refcounted a while back. More eyes is
> better, of course. :)

Please ensure that future readers of this code have a description of
how it is supposed to work.
