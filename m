From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] IP_RECVERRC
Date: Fri, 10 Aug 2007 18:26:43 +0200
Message-ID: <20070810162643.GA11892@one.firstfloor.org>
References: <1186752912.5188.12.camel@localhost> <20070810140214.GA10331@one.firstfloor.org> <1186756212.5163.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40016 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765624AbXHJQ0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 12:26:45 -0400
Content-Disposition: inline
In-Reply-To: <1186756212.5163.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 10:30:12AM -0400, jamal wrote:
> On Fri, 2007-10-08 at 16:02 +0200, Andi Kleen wrote:
> > On Fri, Aug 10, 2007 at 09:35:12AM -0400, jamal wrote:
> 
> > 
> > Affected in what way? 
> > 
> 
> They dont get errors back and they just keep sending even in the
> presence of errors - take a look at ip_push_pending_frames. I have been
> struggling initially to unconditionally mod that part, but it may break
> certain apps expectations.

Are we talking about TCP or UDP/RAW?

The reason why IP_RECVERR was invented was that for non connected 
DGRAM sockets there was no way to figure out for which target host
the error was. So they were dropped. With IP_RECVERR you can get them
together with the original target address.

If you connect the DGRAM socket and don't set IP_RECVERR you will just get 
errnos -- that might be what you want.

If you're talking about TCP: IP_RECVERR never made too much sense here.

Normally TCP only reports errors after a major timeout.
At some point Alexey added an extension that if IP_RECVERR is set
you won't need to wait on the timeout, but get the error immediately
delivered using MSG_ERRQUEUE. That actually breaks TCP because it 
is not resistent to shifting routes etc. anymore so it's a pretty bad idea.

If for TCP you just want the error delivery without MSG_ERRQUEUE
you could just decrease the max timeouts. Then major timeouts
will happen sooner and you'll get the errnos sooner too.
Of course TCP will be far more unreliable than it is. But it might
be ok for some few applications who really know what they're doing
(but more likely it is just programmer hybris who think
they know all about the networks the app will ever be deployed on) 

Anyways, it might make sense to set these timeouts per socket (right now
it is only global sysctl), but on the other hand that would bloat
the already bloated tcp_sock even more.

-Andi
