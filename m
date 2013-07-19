From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: buggy check in netlink_mmap_sendmsg()
Date: Fri, 19 Jul 2013 16:52:09 +0100
Message-ID: <20130719155209.GG4165@ZenIV.linux.org.uk>
References: <20130714093619.GH4165@ZenIV.linux.org.uk>
 <20130718111358.GA27488@macbook.localnet>
 <20130719153846.GB14764@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54556 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760776Ab3GSPwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 11:52:10 -0400
Content-Disposition: inline
In-Reply-To: <20130719153846.GB14764@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 19, 2013 at 05:38:46PM +0200, Patrick McHardy wrote:
> On Thu, Jul 18, 2013 at 01:13:58PM +0200, Patrick McHardy wrote:
> > On Sun, Jul 14, 2013 at 10:36:19AM +0100, Al Viro wrote:
> > > This
> > >         /* Netlink messages are validated by the receiver before processing.
> > >          * In order to avoid userspace changing the contents of the message
> > >          * after validation, the socket and the ring may only be used by a
> > >          * single process, otherwise we fall back to copying.
> > >          */
> > >         if (atomic_long_read(&sk->sk_socket->file->f_count) > 2 ||  
> > >             atomic_read(&nlk->mapped) > 1)
> > >                 excl = false;
> > > looks very odd.  For one thing, descriptor table may be shared, with
> > > one thread calling sendmsg() (which gives f_count equal to 2), while
> > > another calls mmap() just as the first one gets past that check.
> > 
> > Another thread calling mmap() should be fine since validation, processing
> > and mmap() all happen under the pg_vec_lock mutex.

Sorry, no.  Thread A: calls sendmsg(), gets past the check, loses CPU1 on
e.g. preempt.  Thread B on CPU2 calls mmap(2), returns to userland (having
dropped the mutex, of course) and proceeds to play with the mapped area.
Thread A regains CPU and moves on past that if (....), excl still being true.
See the problem?
