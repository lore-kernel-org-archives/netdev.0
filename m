From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Mon, 20 Oct 2008 16:07:04 +0300
Message-ID: <200810201607.05758.opurdila@ixiacom.com>
References: <1224253423.17450.211.camel@ecld0pohly> <200810182237.02373.opurdila@ixiacom.com> <1224505645.17450.299.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:5034 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752062AbYJTN0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 09:26:10 -0400
In-Reply-To: <1224505645.17450.299.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Mon, 20 Oct 2008 14:27:25 +0200

> I think it would be best to transform back to raw time stamps at the
> socket level if requested by the application: SO_TIMESTAMPNS would
> always return the transformed time stamp and a new SO_TIMESTAMP_HARDWARE
> the corresponding hardware time stamp, if one exists. 

This is better, indeed. 

> If that value is
> not needed and computing it is considered to costly, a
> SO_TIMESTAME_IS_HARDWARE could also be added.

I didn't get this part.

> My proposal is to implement as much of this in generic code. A specific
> driver then only has to provide access to its clock and alert the
> generic code of special circumstances (like reseting the clock). It can
> also choose between an advanced method (see below) and a simple delta,
> as needed.

Agreed.

> > The problem here is that we want to distinguish between system and
> > hardware timestamps. A possible approach would be to use a slightly
> > coarser precision (say Xns instead of 1ns) and then use the modulo X to
> > encode state into the timestamp.
> >
> > For example, we could say that hardware timestamp = (hwtimestamp/X)*X and
> > software timestamp = ((system time/X)*X) +1
>
> My expectation is that the lower bits of both software and hardware time
> stamps are unused anyway. But I would reverse the logic and return the
> more common software time stamps with the lower bits cleared, so that
> ideally they are identical to time stamps without the additional
> semantic.
>

Right, its better this way.

> Perhaps it would be acceptable to add a single bit flag to sk_buff
> itself instead, but I'm not sure about that.
>

Last time I've checked, sk_buff didn't had any holes, thus adding one bit will 
enlarge it. And I think that this approach gives use more room for any 
enhancements we may need in the future.

> > Than, in the hwtimestamp_ioctl we can check if a received time is
> > software or hardware, and we can let the application know.
>
> As I said above, I think this should be done in recv_msg() as configured
> by socket flags.
>

Agreed.

> > We can even compute the delta periodically now, to maintain better system
> > - hardware timestamps synchronization, as we can keep and multiple deltas
> > (each one associated with a modulo number).
>
> The transformation that I used was "system time = hardware time + delta
> + skew * time since last measurement". Perhaps this is overkill: the
> last summand often was small (a few nanoseconds), but that depends on
> the skew. Although it complicates the implementation, I would prefer to
> implement that mapping function, just to be on the safe side.

Sure, we can use multiple sync methods as you've said, one being the simple 
delta and then this one as the more advanced method. 


Thanks,
tavi

