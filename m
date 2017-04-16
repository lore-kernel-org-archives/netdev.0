From: Guy Harris <guy@alum.mit.edu>
Subject: Re: TPACKET_V3 timeout bug?
Date: Sat, 15 Apr 2017 19:38:29 -0700
Message-ID: <252F7ABD-C0F2-4B3B-8F11-740FA239F7CD@alum.mit.edu>
References: <20170415194042.GA5936@lunn.ch>
 <20170415224530.GA21010@oracle.com> <20170415234437.GA21836@lunn.ch>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:41054 "EHLO c.mail.sonic.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755274AbdDPCsy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Apr 2017 22:48:54 -0400
In-Reply-To: <20170415234437.GA21836@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Apr 15, 2017, at 4:44 PM, Andrew Lunn <andrew@lunn.ch> wrote:

> Yet i'm debugging an application which expects a timeout even when
> there are 0 packets.

Well, you've already found a bug - it expects a timeout where there are no packets.

To quote the pcap man page (this is the latest version, which calls it the "packet buffer timeout" rather than the "read timeout"):

       packet buffer timeout
              If,  when  capturing,  packets  are  delivered  as  soon as they
              arrive, the application capturing the packets will be  woken  up
              for  each  packet  as  it arrives, and might have to make one or
              more calls to the operating system to fetch each packet.

              If, instead, packets are not delivered as soon as  they  arrive,
              but  are  delivered after a short delay (called a "packet buffer
              timeout"), more than one packet can be  accumulated  before  the
              packets are delivered, so that a single wakeup would be done for
              multiple packets, and each set of calls made  to  the  operating
              system  would  supply  multiple  packets,  rather  than a single
              packet.  This reduces the per-packet CPU overhead if packets are
              arriving  at  a  high rate, increasing the number of packets per
              second that can be captured.

              The packet buffer timeout is required  so  that  an  application
              won't  wait for the operating system's capture buffer to fill up
              before packets are delivered; if packets  are  arriving  slowly,
              that wait could take an arbitrarily long period of time.

              Not  all platforms support a packet buffer timeout; on platforms
              that don't, the packet buffer timeout is ignored.  A zero  value
              for the timeout, on platforms that support a packet buffer time-
              out, will cause a read to wait forever to allow  enough  packets
              to arrive, with no timeout.

              NOTE:  the  packet  buffer timeout cannot be used to cause calls
              that read packets to return within a  limited  period  of  time,
              because, on some platforms, the packet buffer timeout isn't sup-
              ported, and, on other platforms, the timer doesn't  start  until
              at  least one packet arrives.  This means that the packet buffer
              timeout should NOT be  used,  for  example,  in  an  interactive
              application  to  allow  the  packet capture loop to ``poll'' for
              user input periodically, as there's no  guarantee  that  a  call
              reading packets will return after the timeout expires even if no
              packets have arrived.

              The packet buffer timeout is set with pcap_set_timeout().

Note especially the next-to-last paragraph - which was put in there long before TPACKET_V3, to cover, for example, Solaris.

The purpose of the timeout is to make sure packets don't stay stuck in the kernel buffer for an indefinite period of time (if they're not arriving at a sufficient rate to fill up the buffer in a reasonably-short period of time); it's *not* to make sure the application doesn't remain blocked for an indefinite period of time.
