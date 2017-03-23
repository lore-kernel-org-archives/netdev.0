From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 23 Mar 2017 17:21:45 +0100
Message-ID: <20170323162145.GB8192@localhost>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55918 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751274AbdCWQVs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 12:21:48 -0400
Content-Disposition: inline
In-Reply-To: <20170209110941.GA1449@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 12:09:41PM +0100, Miroslav Lichvar wrote:
> On Thu, Feb 09, 2017 at 09:02:42AM +0100, Richard Cochran wrote:
> > On Tue, Feb 07, 2017 at 03:01:44PM +0100, Miroslav Lichvar wrote:
> > > 5) new SO_TIMESTAMPING options to get transposed RX timestamps
> > > 
> > >    PTP uses preamble RX timestamps, but NTP works with trailer RX
> > >    timestamps. This means NTP implementations currently need to
> > >    transpose HW RX timestamps. The calculation requires the link speed
> > >    and the length of the packet at layer 2. It seems this can be
> > >    reliably done only using raw sockets. It would be very nice if the
> > >    kernel could tranpose the timestamps automatically.
> > 
> > Impossible, because the link speed may change between the time when
> > the MAC receives the data the kernel gets around to calculating the
> > time stamp.
> 
> I think that would be an acceptable limitation. The application
> certainly couldn't do a better job than the kernel and it won't have
> to use raw sockets.

After becoming a bit more familiar with the code I don't think this is
a good idea anymore :). I suspect there would be a noticeable
performance impact if each timestamped packet could trigger reading of
the current link speed. If the value had to be cached it would make
more sense to do it in the application.

With no option to get transposed timestamps the point 6 can be
scratched too.

A better approach might be a control message that would provide the
original interface index together with the length of the packet, so
the application could transpose the HW timestamp and map the HW
interface to the PHC.

The two values could be saved in the skb_shared_info structure. Now
my question is if they could be useful also for other things than
timestamping and if it should be a new socket option which would work
on any socket independently from timestamping, or if it should rather
be a new flag for the SO_TIMESTAMPING option. If the latter, would it
make sense to put them in the skb_shared_hwtstamps structure and
modify all drivers to set the values when a HW timestamp is captured
instead of adding more code to __netif_receive_skb_core() or similar?

What do you think?

> > > 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
> > > 
> > >    With bridges, bonding and other things it's difficult to determine
> > >    which PHC timestamped the packet. It would be very useful if the
> > >    PHC index was provided with each HW timestamp.

-- 
Miroslav Lichvar
