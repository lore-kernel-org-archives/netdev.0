From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Fri, 24 Mar 2017 10:45:30 +0100
Message-ID: <20170324094530.GE8192@localhost>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
 <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Denny Page <dennypage@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751618AbdCXJpe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 05:45:34 -0400
Content-Disposition: inline
In-Reply-To: <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 10:08:00AM -0700, Denny Page wrote:
> > On Mar 23, 2017, at 09:21, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > 
> > After becoming a bit more familiar with the code I don't think this is
> > a good idea anymore :). I suspect there would be a noticeable
> > performance impact if each timestamped packet could trigger reading of
> > the current link speed. If the value had to be cached it would make
> > more sense to do it in the application.
> 
> I am very surprised at this. The application caching approach requires the application retrieve the value via a system call. The system call overhead is huge in comparison to everything else. More importantly, the application cached value may be wrong. If the application takes a sample every 5 seconds, there are 5 seconds of timestamps that can be wildly wrong.

I'm just trying to be practical and minimize the performance impact
and the amount of code that needs to be written, reviewed and
maintained.

How common is to have link speed changing in normal operation on LAN?

There are other problems with changing link speed. It does not affect
only the transposition.

- If the change happens during a measurement, anywhere on the path
  between the server and client, the measured offset will have an
  error due to the asymmetry in the network delay. An NTP measurement
  in the basic mode is short (it's just the rount-trip time), so it's
  not very likely to be hit by a link speed change, but in the
  interleaved mode the probability is exactly the opposite.

- Even if the measurement is not hit and the measured offset is
  accurate, the change in the measured delay may confuse the NTP
  client (e.g. temporarily disrupt its sample filtering).

- The TX/RX compensation values depend on the link speed. If the
  application doesn't reliably know link speed for each packet, the
  compensation cannot be reliable either.

It seems to me for best timekeeping with NTP it is necessary to make
sure the link speed in the network is constant, even if the
transposition was always accurate.

-- 
Miroslav Lichvar
