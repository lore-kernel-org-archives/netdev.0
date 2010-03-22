From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 22 Mar 2010 19:53:10 +0100
Message-ID: <20100322185310.GA20695@one.firstfloor.org>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org> <alpine.DEB.2.00.1003221146260.17230@router.home> <877hp4i76d.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003221300180.17230@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43138 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab0CVSxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 14:53:14 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003221300180.17230@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 22, 2010 at 01:07:37PM -0500, Christoph Lameter wrote:
> > >         B. PGM over UDP
> > >
> > >                 fd = socket(AF_INET, SOCK_RDM, IPPROTO_UDP)
> > >
> > >         C. PGM over SHM (?)
> > >
> > >                 fd = socket(AF_UNIX, SOCK_RDM, 0)
> >
> > Not sure how that should work.
> 
> Multiple processes would communicate via shm segments. Maybe defer to the
> future but its an important operation mode as the systems grow bigger and bigger.
> SHM segment would have to contain some sort of ring buffer that the
> receivers could tap into. But that mode has not really been thought
> through.

AF_UNIX is not SHM today.

The only point is to avoid one copy? (user1 -> kernel -> user2  to user1 -> user2) 
Not sure if that is really worth it. Don't you need another copy to the reliability
buffer anyways?

Letting kernel parse a data structure in user defined memory is also
always somewhat tricky.

But in principle AF_INET over localhost should not be that less efficient
than AF_UNIX, so you can probably drop it for now (unless you need special AF_UNIX
features like credentials)

> > >
> > >         Packet sizes are determined by the number of  packets in a single sendmsg() unless
> >
> > Number of bytes surely?
> 
> Sorry yes you are right.
> 
> > >         overridden by the RM_SET_MESSAGE_BOUNDARY socket option.
> >
> > That's unusual to have such a option (except the MTU). What is it good for?
> 
> No idea why it was implemented. It can be used to use send() for portions
> of a message. Triggers the send() only when all bytes have been provided.
> Probably necessary if one wants to have very long (megabytes) messages.

Those could be a problem in kernel memory consumption. One would need
to be very careful to have a good memory management scheme for the socket
in place.

> > >
> > >         A. Setting the window size / rate.
> > >
> > >                 struct pgm_send_window x;
> > >                 x.RateKbitsPerSec = 56;
> > >                 x.WindowSizeInMsecs = 60000;
> > >                 x.WindowSizeinBytes = 10000000;
> > >
> > >                 setsockopt(fd, SOCK_RDM, RM_RATE_WINDOW_SIZE, &x, sizeof(x));
> > >
> > >                 Default is sending at 56Kbps with a buffer of 10 Megabytes and buffering for a minute.
> >
> > That's a very large buffer for a socket. It would be better to use the usual
> > auto shrinking/increasing mechanisms.
> 
> Reliable multicast protocols have a defined time period / "reliabilty
> buffer" so that they can resend a message that was missed for a time
> period. It is customary to either specify a time period or define the size
> of the "reliability buffer".

One problem is memory management then. What happens when a process opens 100 of those
sockets and fills them all?

I guess you would still need a suitable global limit like TCP has.

> Never used it. I'd rather skip for now. Maybe later.
> 
> >
> > > /* Socket API structures (established by M$DN) */
> > > struct pgm_receiver_stats {
> > >         u64     NumODataPacketsReceived;        /* Number of ODATA (original) sequences */
> >
> > It's difficult to maintain 64 bit counters on 32bit hosts on all targets.
> > But I guess it would be ok to only fill in 32bit in this case.
> 
> 32 bit counters have the awful habit of overflowing.

There's just no portable atomic64_t. Ok maybe you can use the socket lock
to synchronize all the counts if they are only per socket.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
