From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: sys_paccept: disable paccept() until API design is resolved
Date: Tue, 16 Sep 2008 17:04:38 +0400
Message-ID: <20080916130438.GA261@tv-sign.ru>
References: <48CFA10D.2010106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Davide Libenzi <davidel@xmailserver.org>,
	Alan Cox <alan@redhat.com>,
	Ulrich Drepper <drepper@redhat.com>,
	Jakub Jelinek <jakub@redhat.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Roland McGrath <roland@redhat.com>,
	Christoph Hellwig <hch@lst.de>
To: Michael Kerrisk <mtk.manpages@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754893AbYIPM7a@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48CFA10D.2010106@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/16, Michael Kerrisk wrote:
>
> * The behavior of paccept() when interrupted by a signal is IMO
>   strange: the kernel restarts the system call if SA_RESTART was set
>   for the handler.  I think that it should not do this -- that it
>   should behave consistently with paccept()/ppoll()/epoll_pwait(),
>   which never restart, regardless of SA_RESTART.  The reasoning here
>   is that the very purpose of paccept() is to wait for a connection
>   or a signal, and that restarting in the latter case is probably
>   never useful.  (Note: Roland disagrees on this point, believing
>   that rather paccept() should be consistent with accept() in its
>   behavior wrt EINTR
>   (http://thread.gmane.org/gmane.linux.kernel/723953/focus=732255).)

Also, the implementation of sys_paccept() is not "perfect", imho.

	sys_paccept:

		ret = do_accept(...);

		if (ret < 0 && signal_pending()) {
			set_restore_sigmask();
			return ret;
		}

It doesn't check that ret == ERESTARTSYS/EINTR. I can't say this
is bug, but let's suppose that do_accept() returns (say) -EINVAL,
and then the task is interrupted by the signal.

Now, if the signal comes after sys_paccept() checks signal_pending(),
we return -EINVAL, and the signal handler runs with the original
current->blocked mask, as expected.

However, if the signal happens in the window before signal_pending(),
we still return -EINVAL, but the signal handler runs with
->blocked == sigmask. A bit odd, but probably harmless.


Note also that unless I misread the code, do_paccept() returns
ERESTARTSYS or EINTR depending on ->sk_rcvtimeo. Yes, it is very
clear why sock_intr_errno() does this, but this doesn't make the
behaviour of paccept() more understandable.

Oleg.
