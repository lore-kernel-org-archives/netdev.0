From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Mon, 20 Oct 2008 14:27:25 +0200
Message-ID: <1224505645.17450.299.camel@ecld0pohly>
References: <1224253423.17450.211.camel@ecld0pohly>
	 <200810182237.02373.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35288 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbYJTM3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2008 08:29:34 -0400
In-Reply-To: <200810182237.02373.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-10-18 at 13:37 -0600, Octavian Purdila wrote:
> From: Patrick Ohly <patrick.ohly@intel.com>
> Date:   Fri, 17 Oct 2008 16:23:43 +0200
> 
> > The only solution that I see is to use one bit as flag to distinguish
> > between hardware and software time stamps, as Octavian originally
> > suggested.
> 
> There is one more approach that I think it could work.
> 
> Once hardware times-tamping has been enabled, the driver will:
> a) compute the delta between the system time and the hardware time
> b) store in the skb the hardware timestamp + delta (thus effectively using an
> approximation of system time which I think it should be OK since system time
> is not that precise anyway)

In other words, skb::tstamp will always look like a system time stamp to
most of the kernel (basically everything above the driver), but those
parts which need to know can still detect true hardware time stamps.
Yes, that should work.

> This is the approach that Stephen used in his patch for sky2. But we need
> more, we need to get the "untainted" hardware timestamps to userspace.
> 
> And we can to that through a driver specific ioctl (or maybe via a new ethtool
> method?):
> 
> hwtimestamp htimestamp_ioctl(timestamp)
> {
>         return timestamp - delta;
> }

The problem here is correlating the hardware time stamp with the
hardware that generated it. Consider for example multiple NICs, or the
delay between receiving the time stamp and asking for the transformation
(there's a race condition).

I think it would be best to transform back to raw time stamps at the
socket level if requested by the application: SO_TIMESTAMPNS would
always return the transformed time stamp and a new SO_TIMESTAMP_HARDWARE
the corresponding hardware time stamp, if one exists. If that value is
not needed and computing it is considered to costly, a
SO_TIMESTAME_IS_HARDWARE could also be added.

> There are some corner cases with this approach:
> 
> 1. Reseting hardware timestamps. Our devices do that when the hardware
> timestamps are synchronized across different cards, in which case hardware
> timestamps are all reseted to zero.
> 
> We can easily detect this condition (current hardware timestamp < hardware
> timestamp at the moment at which we computed the delta) and update the delta.

My proposal is to implement as much of this in generic code. A specific
driver then only has to provide access to its clock and alert the
generic code of special circumstances (like reseting the clock). It can
also choose between an advanced method (see below) and a simple delta,
as needed.

> 2. When the hardware is unable to generate a hardware timestamps (Patrick
> mentioned that this may occur with certain hardware).
> 
> In that case the driver should generate a system time timestamp.

Agreed.

> The problem here is that we want to distinguish between system and hardware
> timestamps. A possible approach would be to use a slightly coarser precision
> (say Xns instead of 1ns) and then use the modulo X to encode state into the
> timestamp.
> 
> For example, we could say that hardware timestamp = (hwtimestamp/X)*X and
> software timestamp = ((system time/X)*X) +1

My expectation is that the lower bits of both software and hardware time
stamps are unused anyway. But I would reverse the logic and return the
more common software time stamps with the lower bits cleared, so that
ideally they are identical to time stamps without the additional
semantic.

Perhaps it would be acceptable to add a single bit flag to sk_buff
itself instead, but I'm not sure about that.

> Than, in the hwtimestamp_ioctl we can check if a received time is software or
> hardware, and we can let the application know.

As I said above, I think this should be done in recv_msg() as configured
by socket flags.

> We can even compute the delta periodically now, to maintain better system -
> hardware timestamps synchronization, as we can keep and multiple deltas (each
> one associated with a modulo number).

The transformation that I used was "system time = hardware time + delta
+ skew * time since last measurement". Perhaps this is overkill: the
last summand often was small (a few nanoseconds), but that depends on
the skew. Although it complicates the implementation, I would prefer to
implement that mapping function, just to be on the safe side.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

