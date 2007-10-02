From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 13:14:20 -0700
Message-ID: <20071002201420.GE29944@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <47028DEF.5070009@psc.edu> <20071002190742.GC29944@bitmover.com> <20071002193304.GA31611@bitmover.com> <4702A1B6.5020505@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lm@bitmover.com, Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43820 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752416AbXJBUOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 16:14:21 -0400
Content-Disposition: inline
In-Reply-To: <4702A1B6.5020505@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I think I'm still missing some basic data here (probably because this 
> thread did not originate on netdev).  Let me try to nail down some of 
> the basics.  You have a linux ia64 box (running 2.6.12 or 2.6.18?) that 
> sends slowly, and receives faster, but not quite a 1 Gbps?  And this is 
> true regardless of which peer it sends or receives from?  And the 
> behavior is different depending on which kernel?  How, and which kernel 
> versions?  Do you have other hardware running the same kernel that 
> behaves the same or differently?

just got off the phone with Linus and he thinks it is the side that does
the accept is the problem side, i.e., if you are the server, you do the
accept, and you send the data, you'll go slow.  But as I'm writing this
I realize he's wrong, because it is the combination of accept & send.
accept & recv goes fast.

A trivial way to see the problem is to take two linux boxes, on each
apt-get install rsh-client rsh-server
set up your .rhosts,
and then do

	dd if=/dev/zero count=100000 | rsh OTHER_BOX dd of=/dev/null
	rsh OTHER_BOX dd if=/dev/zero count=100000 | dd of=/dev/null

See if you get balanced results.  For me, I get 45MB/sec one way, and
15-19MB/sec the other way.

I've tried the same test linux - linux and linux - hpux.  Same results.
The test setup I have is

	work:	2ghz x 2 Athlons, e1000, 2.6.18
	ia64:	900mhz Itanium, e1000, 2.6.12
	hp-ia64:900mhz Itanium, e1000, hpux 11
	glibc*: 1-2ghz athlons running various linux releases

all connected through a netgear 724T 10/100/1000 switch (a linksys showed
identical results).

I tested 

	work <-> hp-ia64
	work <-> ia64
	ia64 <-> hp-ia64

and in all cases, one direction worked fast and the other didn't.

It would be good if people tried the same simple test.  You have to
use rsh, ssh will slow things down way too much.

Alternatively, take your favorite test programs, such as John's,
and make a second pair that reverses the direction the data is 
sent.  So one pair is server sends, the other is server receives,
try both.  That's where we started, BitKeeper, my stripped down test,
and John's test all exhibit the same behavior.  And the rsh test
is just a really simple way to demonstrate it.

Wayne, Linus asked for tcp dumps from just one side, with the first 100
packets and then wait 10 seconds or so for the window to open up, and then
a snap shot of the another 100 packets.  Do that for both directions
and send them to the list.  Can you do that?  I want to get lunch, I'm
starving.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
