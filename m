From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 9 Feb 2017 12:09:41 +0100
Message-ID: <20170209110941.GA1449@localhost>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50880 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751924AbdBILJs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 06:09:48 -0500
Content-Disposition: inline
In-Reply-To: <20170209080242.GA1698@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 09:02:42AM +0100, Richard Cochran wrote:
> On Tue, Feb 07, 2017 at 03:01:44PM +0100, Miroslav Lichvar wrote:
> > 2) new SO_TIMESTAMPING option to receive from the error queue only
> >    user data as was passed to sendmsg() instead of Ethernet frames
> > 
> >    Parsing Ethernet and IP headers (especially IPv6 options) is not
> >    fun and SOF_TIMESTAMPING_OPT_ID is not always practical, e.g. in
> >    applications which process messages from the error queue
> >    asynchronously and don't bind/connect their sockets.
> 
> This doesn't seem justified to me.  From the application POV, it is
> easier to hash the transmitted frames than to parse loop backed
> packets.

At least in the case of the NTP implementation I'm working on that
would not be easier. I'm not saving transmitted packets. I think that
would be a waste of memory, complicating the code, and duplicating
work that the kernel is already doing. A public NTP server can handle
hundreds of thousands of requests per second, but not all of them may
get a SW/HW transmit timestamp. How would I know which will actually
get it and how long should I wait for it?

If the packet contains all data needed to process the TX timestamp,
it's much easier for me to use data from the kernel queue. If the
kernel drops it, it's not a problem. If the kernel loops it back, I
have everything I need.

> > 3) target address in msg_name of messages from the error queue
> > 
> >    With 2) and unconnected sockets, there needs to be a way to get the
> >    address to which the packet was sent. Is it ok to always fill
> >    msg_name, or does it need to be a new option?
> 
> Again, a hash table cures this.

It does, but I'm not sure it's always the best option.

> >    Maybe it would be acceptable to get from the error
> >    queue two messages per transmission if the interface supports both
> >    SW and HW timestamping?
> 
> I like this idea better.
> 
> However, I doubt the utility of this.  If you provide SW time stamps
> always and TX mostly, but not always, this forces the application to
> keep two sets of filtered data or two servos, one designed for SW and
> one for HW accuracy.

I think that depends on how is the application designed. In my case
each sample is using the best timestamps that were available (any
combination of daemon/SW/HW timestamps is possible) and they are all
mixed together. The NTP filtering algorithms then drop samples based
on their delay, not the timestamping source. Samples using SW
timestamps have larger delay than samples using HW timestamp, so they
will be dropped unless HW timestamps are missing for long time. In my
testing, and from what others have reported, this work well. An
occasional missing HW timestamp is not a problem. 

> > 5) new SO_TIMESTAMPING options to get transposed RX timestamps
> > 
> >    PTP uses preamble RX timestamps, but NTP works with trailer RX
> >    timestamps. This means NTP implementations currently need to
> >    transpose HW RX timestamps. The calculation requires the link speed
> >    and the length of the packet at layer 2. It seems this can be
> >    reliably done only using raw sockets. It would be very nice if the
> >    kernel could tranpose the timestamps automatically.
> 
> Impossible, because the link speed may change between the time when
> the MAC receives the data the kernel gets around to calculating the
> time stamp.

I think that would be an acceptable limitation. The application
certainly couldn't do a better job than the kernel and it won't have
to use raw sockets.

> > 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
> > 
> >    With bridges, bonding and other things it's difficult to determine
> >    which PHC timestamped the packet. It would be very useful if the
> >    PHC index was provided with each HW timestamp.
> 
> Again, this only makes writing the application harder, as it would be
> forced to sort packets by PHC index.  It is much easier to open
> multiple sockets, each bound to one physical interface.

With multiple sockets I'd have to know which packet belongs to which
socket and track routing changes. I'm not sure if that's even possible
with bonding. One socket for everything seems much easier to me. I
don't care about interfaces, I just need to know which clock
timestamped the packet.

-- 
Miroslav Lichvar
