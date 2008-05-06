From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 00/18] flag parameters
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7AF004035@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933043AbYEFVSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an update for the previous series which should address the
comments Andrew had.  The controversial function Davide wrote is gone.
There is no flag conversion anymore.  We still introduce new names for
the constants but the values are the same as the O_* constants.

This leads to some strange-looking code where we in one moment check
for, say, SOCK_CLOEXEC, and in the next for O_CLOEXEC.  But I added
in a separate, new patch code which checks for the consistency of the
constants.

I modified the headers in <linux/*> to define the new values by
include <linux/fcntl.h> and then simply define the new constants
based on the O_* constants.  That's the safest a nd least troublesome
way.  Otherwise we would have to create arch-specific headers.  None
of the modified headers should be used by userlevel code.  Therefore
the namespace pollution is no issue.

For those who just turn in, these patches add flags to various functions
so that new file descriptors can be created with atomically setting the
close-on-exec flag.  This is critical, in multi-threaded apps we otherwise
can have file descriptor leakage or worse.  Since it is so either and
often needed, I also added code to create new file descriptors with
O_NONBLOCK set.

In future there will be other uses.  Like a O_* flag to enable the use
of non-sequential descriptors.

Some interfaces are not exported at userlevel with enough flexibility
to allow extending them.  For those we need new userlevel interface.
This is the case for:

 - paccept
 - epoll_create2
 - dup3
 - pipe2
 - inotify_init1

We do /not/ need new interfaces for

 - signalfd4
 - eventfd2
 - timerfd_create
 - socket
 - socketpair

These either have flags parameters in the interface exported by glibc
or (in case of the socket functions) overload a parameter with a bitset.

Each semantic change has a test program.  For archs other than x86 and
x86-64 you'll have to add the appropriate syscall number.

The patches all apply individually in sequence and the source tree
remains compilable and runnable.
