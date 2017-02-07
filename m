From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Extending socket timestamping API for NTP
Date: Tue, 7 Feb 2017 15:01:44 +0100
Message-ID: <20170207140144.GA11233@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33994 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753497AbdBGOBr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 09:01:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd like to propose some changes and new options for the timestamping
interface that I think would be useful for NTP implementations and
maybe also other applications. Before I or someone else tries to
implement them, do you think they would actually make sense and fit
well in the current code?

1) new rx_filter for NTP

   Some NICs can't timestamp all received packets and are currently
   unusable for NTP with HW timestamping. The new filter would allow
   NTP support in new NICs and adding support to existing NICs with
   firmware/driver updates. The filter would apply to IPv4 and IPv6
   UDP packets received from or sent to the port number 123.

   Should be the current drivers of HW that can timestamp all packets
   updated to fall back to HWTSTAMP_FILTER_ALL?

2) new SO_TIMESTAMPING option to receive from the error queue only
   user data as was passed to sendmsg() instead of Ethernet frames

   Parsing Ethernet and IP headers (especially IPv6 options) is not
   fun and SOF_TIMESTAMPING_OPT_ID is not always practical, e.g. in
   applications which process messages from the error queue
   asynchronously and don't bind/connect their sockets.

3) target address in msg_name of messages from the error queue

   With 2) and unconnected sockets, there needs to be a way to get the
   address to which the packet was sent. Is it ok to always fill
   msg_name, or does it need to be a new option?

4) allow sockets to use both SW and HW TX timestamping at the same time

   When using a socket which is not bound to a specific interface, it
   would be nice to get transmit SW timestamps when HW timestamps are
   missing. I suspect it's difficult to predict if a HW timestamp will
   be available. Maybe it would be acceptable to get from the error
   queue two messages per transmission if the interface supports both
   SW and HW timestamping?

5) new SO_TIMESTAMPING options to get transposed RX timestamps

   PTP uses preamble RX timestamps, but NTP works with trailer RX
   timestamps. This means NTP implementations currently need to
   transpose HW RX timestamps. The calculation requires the link speed
   and the length of the packet at layer 2. It seems this can be
   reliably done only using raw sockets. It would be very nice if the
   kernel could tranpose the timestamps automatically.

   The existing SOF_TIMESTAMPING_RX_HARDWARE flag could be aliased to
   SOF_TIMESTAMPING_RX_HARDWARE_PREAMBLE and the new flag could be
   SOF_TIMESTAMPING_RX_HARDWARE_TRAILER.

   PTP has a similar problem with SW RX timestamps, which are closer
   to the trailer timestamps rather than preamble timestamps. A new
   SOF_TIMESTAMPING_RX_SOFTWARE_PREAMBLE flag could be added for PTP
   implementations to get transposed timestamps in order to improve
   accuracy.

6) new SO_TIMESTAMPING option to get PHC index with HW timestamps

   With bridges, bonding and other things it's difficult to determine
   which PHC timestamped the packet. It would be very useful if the
   PHC index was provided with each HW timestamp.

   I'm not sure what would be the best place to put it. I guess the
   second timespec in scm_timestamping could be reused for this, but
   that sounds like a gross hack. Do we need to define a new struct?

Thoughts?

-- 
Miroslav Lichvar
