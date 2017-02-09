From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 9 Feb 2017 09:02:42 +0100
Message-ID: <20170209080242.GA1698@localhost.localdomain>
References: <20170207140144.GA11233@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34066 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdBIIDA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 03:03:00 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so1617675wmi.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 00:02:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170207140144.GA11233@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 03:01:44PM +0100, Miroslav Lichvar wrote:
> 1) new rx_filter for NTP

This is an easy one.  No objections here.

>    Should be the current drivers of HW that can timestamp all packets
>    updated to fall back to HWTSTAMP_FILTER_ALL?

Yes, and the phyter, the only driver that can support this directly,
would need some work.
 
> 2) new SO_TIMESTAMPING option to receive from the error queue only
>    user data as was passed to sendmsg() instead of Ethernet frames
> 
>    Parsing Ethernet and IP headers (especially IPv6 options) is not
>    fun and SOF_TIMESTAMPING_OPT_ID is not always practical, e.g. in
>    applications which process messages from the error queue
>    asynchronously and don't bind/connect their sockets.

This doesn't seem justified to me.  From the application POV, it is
easier to hash the transmitted frames than to parse loop backed
packets.

> 3) target address in msg_name of messages from the error queue
> 
>    With 2) and unconnected sockets, there needs to be a way to get the
>    address to which the packet was sent. Is it ok to always fill
>    msg_name, or does it need to be a new option?

Again, a hash table cures this.

> 4) allow sockets to use both SW and HW TX timestamping at the same time
> 
>    When using a socket which is not bound to a specific interface, it
>    would be nice to get transmit SW timestamps when HW timestamps are
>    missing. I suspect it's difficult to predict if a HW timestamp will
>    be available.

Right.

>    Maybe it would be acceptable to get from the error
>    queue two messages per transmission if the interface supports both
>    SW and HW timestamping?

I like this idea better.

However, I doubt the utility of this.  If you provide SW time stamps
always and TX mostly, but not always, this forces the application to
keep two sets of filtered data or two servos, one designed for SW and
one for HW accuracy.
 
> 5) new SO_TIMESTAMPING options to get transposed RX timestamps
> 
>    PTP uses preamble RX timestamps, but NTP works with trailer RX
>    timestamps. This means NTP implementations currently need to
>    transpose HW RX timestamps. The calculation requires the link speed
>    and the length of the packet at layer 2. It seems this can be
>    reliably done only using raw sockets. It would be very nice if the
>    kernel could tranpose the timestamps automatically.

Impossible, because the link speed may change between the time when
the MAC receives the data the kernel gets around to calculating the
time stamp.
 
> 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
> 
>    With bridges, bonding and other things it's difficult to determine
>    which PHC timestamped the packet. It would be very useful if the
>    PHC index was provided with each HW timestamp.

Again, this only makes writing the application harder, as it would be
forced to sort packets by PHC index.  It is much easier to open
multiple sockets, each bound to one physical interface.
 
>    I'm not sure what would be the best place to put it. I guess the
>    second timespec in scm_timestamping could be reused for this, but
>    that sounds like a gross hack. Do we need to define a new struct?

Yes, I think so.

Thanks,
Richard
