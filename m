From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fw: [Bug 8013] New: select for write hangs on a socket after write returned ECONNRESET
Date: Fri, 16 Feb 2007 18:54:50 +0300
Message-ID: <20070216155450.GC22020@2ka.mipt.ru>
References: <20070215160405.3bd30b05@localhost.localdomain> <20070216152557.GA20641@2ka.mipt.ru> <20070216152858.GA22020@2ka.mipt.ru> <20070216153957.GB22020@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40073 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945952AbXBPPzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 10:55:20 -0500
Content-Disposition: inline
In-Reply-To: <20070216153957.GB22020@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 06:39:58PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Fri, Feb 16, 2007 at 06:28:58PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > On Fri, Feb 16, 2007 at 06:25:57PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > On Thu, Feb 15, 2007 at 04:04:05PM -0800, Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> > > > Someone want to take a stab at fixing this??
> 
> Ok, I've fund a reason - select() only checks if valid output condition
> is 
> #define POLLOUT_SET (POLLWRBAND | POLLWRNORM | POLLOUT | POLLERR)
> 
> Linux never sets POLLERR on shutdown - only on socket error, on shutdown
> POLLHUP is setup instead, so reading always shows that:
> 
> #define POLLIN_SET (POLLRDNORM | POLLRDBAND | POLLIN | POLLHUP |
> POLLERR)
> 
> A 'fix' can be to add POLLHUP into POLLOUT_SET or workaround that in
> application to check both input and output events in select() or use
> poll and explicitly check returned mask.

Here is mask returned from poll() in the described case:

pollin
[ 2000.564000] do_select: 2076: mask: 104, i: 3/4, j: 3/32, ret: 0, in:

pollin/pollout
[ 2000.572000] do_select: 2076: mask: 145, i: 3/4, j: 3/32, ret: 1, in:
[ 2000.572000] do_select: 2076: mask: 145, i: 3/4, j: 3/32, ret: 1, in:

error is set! but only once since sock_error() replaces sk->sk_err with
zero. Also pollhup is set.
[ 2000.572000] do_select: 2076: mask: 2059, i: 3/4, j: 3/32, ret: 1, in:

Only pollhup is set without pollerr.
[ 2000.572000] do_select: 2076: mask: 2051, i: 3/4, j: 3/32, ret: 0, in:
[ 2014.400000] do_select: 2076: mask: 2051, i: 3/4, j: 3/32, ret: 0, in:

Above sock_error() is called through the following codepath:

write() -> tcp_sendmsg() -> disconnect detected -> sk_stream_error() ->
sock_error() ==> ends up with zero sk->sk_err.

select() -> tcp_poll() ==> check for sk->sk_err fails and thus poller is
not set and tcp_poll() does not return that bit, so select() fails to
say that file descriptor is ready for output.

-- 
	Evgeniy Polyakov
