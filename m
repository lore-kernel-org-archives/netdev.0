From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: v2 of seccomp filter c/r patches
Date: Fri, 11 Sep 2015 09:30:52 -0700
Message-ID: <CALCETrVYtv1=g-xPjQ-LiX+5GK3xtB6a2hYbat0TuU-Bd4QA6Q@mail.gmail.com>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441930862-14347-1-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sep 10, 2015 5:22 PM, "Tycho Andersen" <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
>
> Hi all,
>
> Here is v2 of the seccomp filter c/r set. The patch notes have individual
> changes from the last series, but there are two points not noted:
>
> * The series still does not allow us to correctly restore state for programs
>   that will use SECCOMP_FILTER_FLAG_TSYNC in the future. Given that we want to
>   keep seccomp_filter's identity, I think something along the lines of another
>   seccomp command like SECCOMP_INHERIT_PARENT is needed (although I'm not sure
>   if this can even be done yet). In addition, we'll need a kcmp command for
>   figuring out if filters are the same, although this too needs to compare
>   seccomp_filter objects, so it's a little screwy. Any thoughts on how to do
>   this nicely are welcome.

Let's add a concept of a seccompfd.

For background of what I want to add: I want to be able to create a
seccomp monitor.  A seccomp monitor will be, logically, a pair of a
struct file that represents the monitor and a seccomp_filter that is
controlled by the monitor.  Depending on flags, whoever holds the
monitor fd could change the active filter, intercept syscalls, and
issue syscalls on behalf of a process that is trapped in an
intercepted syscall.

Seccomp filters would nest properly.

The interface would probably be (extremely pseudocoded):

monitor_fd, filter_fd = seccomp(CREATE_MONITOR, flags, ...);

Then, later:

seccomp(ATTACH_TO_FILTER, filter_fd);  /* now filtered */

read(monitor_fd, buf, size); /* returns an intercepted syscall */
write(monitor_fd, buf, size); /* issues a syscall or releases the
trapped task */

This can't be implemented on x86 without either going insane or
finishing the massive set of pending cleanups to the x86 entry code.
I favor the latter.

We could, however, add part of it right now: we could have a way to
create a filterfd, we could add kcmp support for it, and we could add
the ATTACH_TO_FILTER thing.  I think that would solve your problem.

One major open question: does a filter_fd know what its parent is and,
if so, will it just refuse to attach if the caller's parent is wrong?
Or will a filter_fd attach anywhere.

--Andy
