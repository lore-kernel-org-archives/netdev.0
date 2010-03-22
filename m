From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 22 Mar 2010 13:07:37 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1003221300180.17230@router.home>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org> <alpine.DEB.2.00.1003221146260.17230@router.home>
 <877hp4i76d.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:54656 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab0CVSHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 14:07:45 -0400
In-Reply-To: <877hp4i76d.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Mar 2010, Andi Kleen wrote:

> > What I have right now is:
> >
> > 1. Opening a socket
>
> >
> >         A. Native PGM
> >
> >                 fd = socket(AF_INET, SOCK_RDM, IPPROTO_PGM)
>
> RDM = Reliable ? Multicast ?

RDM is Reliable Datagram Multicast I believe. I'd rather have SOCK_PGM if
I could choose.

>
> >         B. PGM over UDP
> >
> >                 fd = socket(AF_INET, SOCK_RDM, IPPROTO_UDP)
> >
> >         C. PGM over SHM (?)
> >
> >                 fd = socket(AF_UNIX, SOCK_RDM, 0)
>
> Not sure how that should work.

Multiple processes would communicate via shm segments. Maybe defer to the
future but its an important operation mode as the systems grow bigger and bigger.
SHM segment would have to contain some sort of ring buffer that the
receivers could tap into. But that mode has not really been thought
through.

> > 3. Sending and receiving
> >
> >         Use the usual socket read and write operations and the various flavors of waiting
> >         for a packet via select, poll, epoll etc.
> >
> >         Packet sizes are determined by the number of  packets in a single sendmsg() unless
>
> Number of bytes surely?

Sorry yes you are right.

> >         overridden by the RM_SET_MESSAGE_BOUNDARY socket option.
>
> That's unusual to have such a option (except the MTU). What is it good for?

No idea why it was implemented. It can be used to use send() for portions
of a message. Triggers the send() only when all bytes have been provided.
Probably necessary if one wants to have very long (megabytes) messages.
Esoteric and likely not going to be in a first release.

> > 4.      Transmitter Socket Options
> >
> >
> >         A. Setting the window size / rate.
> >
> >                 struct pgm_send_window x;
> >                 x.RateKbitsPerSec = 56;
> >                 x.WindowSizeInMsecs = 60000;
> >                 x.WindowSizeinBytes = 10000000;
> >
> >                 setsockopt(fd, SOCK_RDM, RM_RATE_WINDOW_SIZE, &x, sizeof(x));
> >
> >                 Default is sending at 56Kbps with a buffer of 10 Megabytes and buffering for a minute.
>
> That's a very large buffer for a socket. It would be better to use the usual
> auto shrinking/increasing mechanisms.

Reliable multicast protocols have a defined time period / "reliabilty
buffer" so that they can resend a message that was missed for a time
period. It is customary to either specify a time period or define the size
of the "reliability buffer".

> >         B. FEC mode
> >
> >                 struct pgm_fec_info x;
> >
> >                 x.FECBlocksize = 255;
> >                 x.FECProActivePackets = 0;
> >                 x.FECGroupSize = 0;
> >                 x.fFECOnDemandParityEnabled = 1;
> >
> >                 setsockopt(fd, SOCK_RDM, RM_FEC_MODE, &x, sizeof(x));
>
> Is that mode really needed?

Never used it. I'd rather skip for now. Maybe later.

>
> > /* Socket API structures (established by M$DN) */
> > struct pgm_receiver_stats {
> >         u64     NumODataPacketsReceived;        /* Number of ODATA (original) sequences */
>
> It's difficult to maintain 64 bit counters on 32bit hosts on all targets.
> But I guess it would be ok to only fill in 32bit in this case.

32 bit counters have the awful habit of overflowing.
