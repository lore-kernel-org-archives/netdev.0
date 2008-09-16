From: Michael Kerrisk <mtk.manpages@googlemail.com>
Subject: sys_paccept: disable paccept() until API design is resolved
Date: Tue, 16 Sep 2008 14:05:33 +0200
Message-ID: <48CFA10D.2010106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Davide Libenzi <davidel@xmailserver.org>,
	Alan Cox <alan@redhat.com>,
	Ulrich Drepper <drepper@redhat.com>,
	Jakub Jelinek <jakub@redhat.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Roland McGrath <roland@redhat.com>,
	Oleg Nesterov <oleg@tv-sign.ru>, Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:33896 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbYIPMF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 08:05:58 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2659904rvb.1
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 05:05:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

The patch below disables the new sys_paccept() for now.  Please
apply for 2.6.27-rc, so that we do not release this API into
the wild before a conclusion has been reached about its design.

The reasons for disabling paccept() are as follows:

* The API is more complex than needed.  There is AFAICS no demonstrated
   use case that the sigset argument of this syscall serves that
   couldn't equally be served by the use of pselect/ppoll/epoll_pwait +
   traditional accept().  Roland seems to concur with this opinion
   (http://thread.gmane.org/gmane.linux.kernel/723953/focus=732255).
   I have (more than once) asked Ulrich to explain otherwise
   (http://thread.gmane.org/gmane.linux.kernel/723952/focus=731018),
   but he does not respond, so one is left to assume that he doesn't
   know of such a case.

* The use of a sigset argument is not consistent with other I/O APIs
   that can block on a single file descriptor (e.g., read(), recv(),
   connect()).

* The behavior of paccept() when interrupted by a signal is IMO
   strange: the kernel restarts the system call if SA_RESTART was set
   for the handler.  I think that it should not do this -- that it
   should behave consistently with paccept()/ppoll()/epoll_pwait(),
   which never restart, regardless of SA_RESTART.  The reasoning here
   is that the very purpose of paccept() is to wait for a connection
   or a signal, and that restarting in the latter case is probably
   never useful.  (Note: Roland disagrees on this point, believing
   that rather paccept() should be consistent with accept() in its
   behavior wrt EINTR
   (http://thread.gmane.org/gmane.linux.kernel/723953/focus=732255).)

I believe that instead, a simpler API, consistent with Ulrich's
other recent additions, is preferable:

accept4(int fd, struct sockaddr *sa, socklen_t *salen, ind flags);

(This simpler API was originally proposed by Ulrich:
http://thread.gmane.org/gmane.linux.network/92072)

If this simpler API is added, then if we later decide that the sigset
argument really is required, then a suitable bit in 'flags' could
be added to indicate the presence of the sigset argument.

At this point, I am hoping we either will get a counter-argument
from Ulrich about why we really do need paccept()'s sigset argument,
or that he will resubmit the original accept4() patch.

Cheers,

Michael

Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>


--- linux-2.6.27-rc6/net/socket.c.orig	2008-09-16 12:38:15.000000000 +0200
+++ linux-2.6.27-rc6/net/socket.c	2008-09-16 13:07:51.000000000 +0200
@@ -1511,6 +1511,7 @@
  	goto out_put;
  }

+#if 0
  #ifdef HAVE_SET_RESTORE_SIGMASK
  asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
  			    int __user *upeer_addrlen,
@@ -1564,6 +1565,7 @@
  	return do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
  }
  #endif
+#endif

  asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
  			   int __user *upeer_addrlen)
