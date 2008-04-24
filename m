From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 14:34:27 +0200
Message-ID: <517f3f820804240534r3bbbdc52s52a6dfe3f2d14b7f@mail.gmail.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	 <20080424112514.055d8071@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ulrich Drepper" <drepper@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Michael Kerrisk" <mtk.manpages@gmail.com>,
	michael.kerrisk@gmail.com, linux-man@vger.kernel.org
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:55846 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758406AbYDXMea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 08:34:30 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3057840fgb.17
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 05:34:28 -0700 (PDT)
In-Reply-To: <20080424112514.055d8071@the-village.bc.nu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/08, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > - I decided against using the O_* flags here.  Most are not useful and
>  >   we might need the bits for something else at some time.  Hence the
>  >   new SOCKFL_* flag.  The intend is to define SOCKFL_CLOEXEC and
>  >   O_CLOEXEC to the same value.  In this case there is zero overhead.
>
>
> Given we will never have 2^32 socket types, and in a sense this is part
>  of the type why not just use
>
>         socket(PF_INET, SOCK_STREAM|SOCK_CLOEXEC, ...)
>
>  that would be far far cleaner, no new syscalls on the socket side at all.

That''s not quite true.  There is still the problem of accept().

It's worth trying to summarize all of the syscalls that create file
descriptors to get a handle on how many new syscalls might really be
required.  AFAIK, the list below is all of the syscalls that create
FDs on Linux.

The following system calls all have a flags argument that either
already has a O_CLOEXEC functionality, or to which that functionality
could be added:

* open()
* openat()
* fcntl(F_DUPFD)
* timerfd_create()
* mq_open() (on Linux MQ descriptors are really just file descriptors)

For the following system calls, we could overload another argument for
the purpose:
* socket() (using the 'type' argument, as per Alan's suggestion)

The following syscalls don't have a flags argument, but does it
matter?  For each of them there is an alternative API that can be used
instead, if the functionality is required.

* dup2() -- use fcntl(F_DUPFD) instead
* dup() -- use fcntl(F_DUPFD) instead
* creat() -- use open() instead

The following system call doesn't have a flags argument, but we could
conceivably overload the existing 'fd' argument.  When creating a new
file descriptor, the 'fd' argument must be -1.  We could say that to
create a new fd, the argument must be say NEW_SIGNALFD, defined as
-MAXINT, ORed with the desired flags.

* signalfd()  (glibc API supplies a flags argument, but the syscall
doesn't have one)

The following system calls don't have a flags argument, and the only
way to solve the problem is a new syscall, or sys_indirect().

* eventfd()  (glibc API supplies a flags argument, but the syscall
doesn't have one)
* accept()
* pipe()
* inotify_init()
* epoll_create()

So the alternative to sys_indirect(), at least for the purpose of
O_CLOEXEC and similar, would be to create 5 new system calls (or six,
if one finds the signalfd() hack too ugly, which perhaps it is; or 7
if one doesn't like Alan's suggestion for socket() -- if one went the
route of new syscalls, then I'd suggest creating a new socket()-type
syscall with a flags argument).

Cheers,

Michael


-- 
I'll likely only see replies if they are CCed to mtk.manpages at gmail dot com
