From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Mon, 23 Jan 2012 07:07:32 +0100
Message-ID: <201201230707.33761.hans.schillstrom@ericsson.com>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net> <201201201251.25032.hans.schillstrom@ericsson.com> <m1r4yurt4w.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	"equinox@diac24.net" <equinox@diac24.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:42758 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab2AWGHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 01:07:37 -0500
In-Reply-To: <m1r4yurt4w.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 January 2012 21:55:27 Eric W. Biederman wrote:
> Hans Schillstrom <hans.schillstrom@ericsson.com> writes:
> 
> > On Friday 20 January 2012 11:08:37 Eric W. Biederman wrote:
> >> Hans Schillstrom <hans.schillstrom@ericsson.com> writes:
> >> 
> >> > On Thursday 19 January 2012 22:40:53 Hagen Paul Pfeifer wrote:
> >> >> * Eric W. Biederman | 2012-01-19 13:24:13 [-0800]:
> >> >> 
> >> >> >This thread is a fascinating disconnect from reality all of the way
> >> >> >around.
> >> >> >
> >> >> >- inet_twsk_purge already implements throwing out of timewait sockets
> >> >> >  when a network namespaces is being cleaned up.  So the RFC is nonsense.
> >> >> 
> >> >> This is how it is implemented, not how it should be. TIME_WAIT is not the
> >> >> problem, it is there to keep the stack from sending wrong RST messages. Maybe
> >> >> the 2*MSL could be fixed by a more accurate 2*RTT.
> >> >> 
> >> >
> >> > I was only refering to my printk's i.e. the last sockets leaving the namespace was
> >> > from tcp_timer() with state 7, 2 minutes after free_nsproxy() was called.
> >> > (and assumed that was the time_wait)
> >> 
> >> Which kernel are you running?  
> >
> >  3.2.0 
> >
> >> I can't find a mention of a function
> >> named tcp_timer() anywhere in the kernel since 2.6.16 when the kernel
> >> was put into git.
> >
> > Sorry, it was tcp_write_timer() in tcp_timer.c
> 
> Now that is different.  It sounds like your socket is flushing pending
> writes that haven't made it to the network and is having trouble.   I
> can't imagine an argument for not writing everything in the socket
> buffers to the network if at all possible.
> 
> > We had a number of procs. with tcp connections open, and kill proc 1 (lxc-init)
> > i.e. all procs. in the ns got killed within a few ms. 
> > (or at least no visible traces left)
> 
> My current hypothesis is that the namespace actually didn't get freed
> until the tcp socket finished closing.  You can check by looking at when
> __put_net and then cleanup_net are called.

__put_net() is called just after tcp_write_timer() fires and then cleanup_net()

> 
> > We started with 2.6.32 but the cleanup process didn't work we always end up
> > with ref-counts on loopback
> 
> Yeah a bunch of references get transfered to the loopback device so any
> reference count buglets in the ip stack show up that way.
> 
> I have been wondering if there is a good way to guarantee network
> device ref counts are balanced.  Because those problems are a royal pain
> to track down.
> 

I made some traceback functions/macros for put_net/get_net with a linked list so you can
trace which ones are left at exit.
There was also a primitive "call stack" trace that more or less ends up in the same point :-)

Maybe we should have som kind of DEBUG/TRACE options at compile time for it...
-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
