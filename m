From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: TX time stamping
Date: Thu, 26 Mar 2009 16:30:10 +0100
Message-ID: <1238081410.19066.125.camel@ecld0pohly>
References: <1236105081.4653.68.camel@pohly-MOBL>
	 <20090319.140509.152824531.davem@davemloft.net>
	 <20090320021050.GA7021@gondor.apana.org.au>
	 <1237964924.26966.310.camel@pohly-MOBL>
	 <20090326144835.GA19592@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32118 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbZCZPaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 11:30:16 -0400
In-Reply-To: <20090326144835.GA19592@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-03-26 at 14:48 +0000, Herbert Xu wrote:
> On Wed, Mar 25, 2009 at 08:08:44AM +0100, Patrick Ohly wrote:
> >
> > I suggest to make it so that the sender gets the packet back once per
> > interface, with different time stamps and information about the
> > interface.
> 
> That could be awkward.  What if the second or subsequent instance
> of the packet is held up indefinitely?

The sender must be prepared for packet loss anyway (for example, during
stress tests I have seen that packets were dropped between socket layer
and device driver).

Getting a TX time stamp only for some, but not all expected interfaces,
or getting some results much later isn't that different.

After a certain timeout the sender must assume that the packet was lost
and resend. An unexpected response for a packet that was supposed to be
lost must be ignored.

> > > As to the problem of skb->sk, I don't think that's even needed
> > > as we can simply use the skb shared area as the communication
> > > medium.
> > 
> > Can you elaborate on that?
> 
> I was thinking of the sender keeping hold of the sent skb and
> using its shared area to retrieve the time stamp(s).

The sender is in user space, at least in the case of PTP. Given the
current user space APIs it seems complicated to tie the sender to a
particular skb :-/

> > The drawback is the more costly socket lookup. For PTP this isn't an
> > issue due to the low packet rate, so a very simple solution would be
> > good enough. But for other use cases it might be problematic. I also
> > have no idea how the locking for the socket lookup can be done safely.
> 
> Could you give the main usage scenarios for timestamps, including
> what the user-space app does with the info?

The main usage scenario right now is a hardware assisted implementation
of the Precision Time Protocol (PTP, IEEE 1588). "main usage" as in "the
one I worked on"; others have expressed interest in this hardware
assisted time stamping for other purposes, including detailed network
monitoring.

With PTP, the user space daemons exchange multicast messages with a rate
of less than one per second. Sender and receiver record send and receive
time stamps of each packet. This is done in both directions. These two
delays are used to determine clock drift between two nodes. Filters are
used to remove noise in the input data as much as possible, but it is
much better to avoid the noise in the first place.

Noise in this context are varying delays of the packets. It's okay if
the delay is large, as long as it is constant. But when the delay
increases by a value of x compared to the previous measurement, then PTP
cannot tell whether this particular packet just was transmitted more
slowly or the clocks have drifted apart.

Hardware time stamping removes the varying packet delays inside the
kernel's IP stack because the send/receive time stamps are generated
directly when the packet hits the wire. I found that hardware assistance
is essential for good accuracy [1].

It's also important to remove the varying delays inside the network
switches from the equation. PTP v2 has support for that and equipment
manufacturers are starting to support it.

[1] http://www.linuxclustersinstitute.org/conferences/archive/2008/PDF/Ohly_92221.pdf

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

