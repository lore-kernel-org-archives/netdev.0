From: Glenn Fowler <gsf@research.att.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 13:24:36 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307231724.NAA90957@raptor.research.att.com>
References: <200307231428.KAA15254@raptor.research.att.com>  <20030723074615.25eea776.davem@redhat.com>  <200307231656.MAA69129@raptor.research.att.com> <20030723100043.18d5b025.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dgk@research.att.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, gsf@research.att.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 23 Jul 2003 10:00:43 -0700 David S. Miller wrote:
> On Wed, 23 Jul 2003 12:56:12 -0400 (EDT)
> Glenn Fowler <gsf@research.att.com> wrote:

> > the problem is that linux took an implementation shortcut by symlinking
> > 	/dev/fd/N -> /proc/self/fd/N
> > and by the time the kernel sees /proc/self/fd/N the "self"-ness is apparently
> > lost, and it is forced to do the security checks

> None of this is true.  If you open /proc/self/fd/N directly the problem
> is still there.

you missed the point that the original open() call is on /dev/fd/N,
not /proc/PID/fd/N; /proc/PID/fd/N only comes into play because the
linux implementation foists it on the user

> > if the /proc fd open code has access to the original /proc/PID/fd/N path
> > then it can do dup(atoi(N)) when the PID is the current process without
> > affecting security

> If we're talking about the current process, there is no use in using
> /proc/*/fd/N to open a file descriptor in the first place, you can
> simply call open(N,...)

no, in the notation above N is the fd number "so you could simply call dup(N)"

here is one reason why /dev/fd/N is useful:

/dev/fd/N is the underlying mechanism for implementing the bash and ksh

	cmd-1 <(cmd-2 ...) ... <(cmd-n ...)

each <(cmd-i ...) is converted to a pipe() with the write side getting the
output of cmd-i (and marked close on exec) and the read side *not* marked
close on exec; cmd-1 is then executed as

	cmd-1 /dev/fd/PIPE-READ-2 ... /dev/fd/PIPE-READ-n

where PIPE-READ-i is the fd number of the read side of the pipe for cmd-i
