From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: bug fix patch lost: git problem or just incorrect merge?
Date: Fri, 21 May 2010 12:23:23 -0500
Message-ID: <1274462603.9022.30.camel@mulgrave.site>
References: <1274456515.9022.14.camel@mulgrave.site>
	 <alpine.LFD.2.00.1005210931010.4243@i5.linux-foundation.org>
	 <alpine.LFD.2.00.1005210947440.4243@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:51334 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934303Ab0EURX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 May 2010 13:23:29 -0400
In-Reply-To: <alpine.LFD.2.00.1005210947440.4243@i5.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-05-21 at 10:04 -0700, Linus Torvalds wrote:
> 
> On Fri, 21 May 2010, Linus Torvalds wrote:
> > 
> > > Either way, of course, we need the patch back ...
> > 
> > I'll fix it up.
> 
> Hmm. Pushed that out as appended, since that is the correct resolve.

Thanks!

> HOWEVER - the code still doesn't actually make any sense. It does
> 
> 	if (sk_sleep(sock->sk)) {
> 
> and that sk_sleep() today is an inline function that just does
> 
> 	return &sk->sk_wq->wait;
> 
> and testing the result of an address-of operation for NULL is almost 
> certainly totally non-sensical. Sure, it _might_ work (maybe 'wait' is the 
> first element in the 'sk_wq' data structure, and sk_wq is NULL), but that 
> kind of code is always total and utterl crap regardless.
> 
> So I pushed it out because I had done the resolve already, and it's no 
> worse than it was before, but it's still a steaming buggy pile of shit.

Yes, the problem was caused by this patch

commit 43815482370c510c569fd18edb57afcb0fa8cab6
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Apr 29 11:01:49 2010 +0000

    net: sock_def_readable() and friends RCU conversion

Which moved sk_sleep() from returning the pointer to the waitqueue,
which may or may not be assigned to returning a pointer to an internal
waitqueue in the socket, which, obviously, can never be null.

I suspect what iscsi should be doing is always sending the wakeup ... in
which case with your resolution, the code is operating correctly even if
the form is suboptimal.

> It being iscsi, I can't bring myself to care. But somebody who does, 
> should really look at it. The most likely resolution is to remove the test 
> entirely, since I don't think it's ever valid to have a socket that 
> doesn't have a sk_wq (there's a _lot_ of unconditional use of sk_sleep()).

I'll have Mike look at it, but I think just removing the if() will be
the correct resolution.

James


