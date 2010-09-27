From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 09:34:43 +0200
Message-ID: <20100927073443.GR12373@1wt.eu>
References: <20100926232530.GK12373@1wt.eu> <20100926.181202.28824153.davem@davemloft.net> <20100927053901.GL12373@1wt.eu> <20100926.234202.241938788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45720 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483Ab0I0Heq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 03:34:46 -0400
Content-Disposition: inline
In-Reply-To: <20100926.234202.241938788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 26, 2010 at 11:42:02PM -0700, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Mon, 27 Sep 2010 07:39:01 +0200
> 
> > On Sun, Sep 26, 2010 at 06:12:02PM -0700, David Miller wrote:
> >> From: Willy Tarreau <w@1wt.eu>
> >> Date: Mon, 27 Sep 2010 01:25:30 +0200
> >> 
> >> > Agreed. But that's not a reason for killing outgoing data that is
> >> > being sent when there are some data left in the rcv buffer.
> >> 
> >> What alternative notification to the peer do you suggest other than a
> >> reset, then?  TCP gives us no other.
> > 
> > I know, and I agree to send the reset, but after the data are correctly
> > transferred. This reset's purpose is only to inform the other side that
> > the data it sent were destroyed. It is not a requirement to tell it they
> > were destroyed earlier or later. What matters is that it's informed they
> > were destroyed.
> 
> So you want us to hold onto to the full connection state for however
> long it takes to send the pending data

Not for however long it takes, just as we do right now with orphans, nothing
more, nothing less.

> just because your application
> doesn't want to wait around to sink a pending newline character?

it's not that it *doesn't want* to wait for the pending newline character,
it's that this character has no reason to be there and cannot be predicted,
and even when you find it, nothing tells the application that it's the last
one.

> Is that what this boils down to?

No, it's the opposite in fact, the goal is to ensure we can reliably
release the whole connection ASAP instead of being forced to sink any
possible data that may come from it and that will not be consumed nor
will lead to a reset. Look :

case A (current one) :
   we send the response to the client from an orphaned connection.
   Most of the times, the client won't have any issue and will get the
   response. In some rare circumstances, some data sent by the client
   after the response causes an RST to be emitted, which may destroy
   in flight data. But those issues are extremely rare, still they
   happen.

case B (my proposal, and was the case before the RFC2525 fix) :
   we send the response to the client.
   it acks it
   we send an RST. End of the transfer. Total time: 50ms (avg RTT over ADSL).

case C (alternative) :
   we send the response to the client.
   the application can't know it has acked it, and must maintain the
   connection open for however long is necessary to get the only form
   of ACK the application can detect: the FIN from the client, which
   is 6 minutes on my ADSL line for 10 meg.

In case C, not only the state remains *a lot* longer, but the bandwidth
usage is much worse, and in the end the client does not even get the reset
that we're trying to ensure it gets to indicate that the data were dropped.

So while case C is a reliable workaround, it's the least efficient method
and the most expensive one in terms of memory, CPU, network bandwidth,
socket usage, file descriptor usage and perceived time.

You see, I'm not trying to make dirty dangerous things to save a few
lines of code. I'm even OK to have a lot of linux-specific code to make
use of the features the linux stack provides that makes it more efficient
than other implementations. I'm just seeking reliability.

Willy

