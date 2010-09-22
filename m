From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp reports
Date: Wed, 22 Sep 2010 12:30:49 -0700
Message-ID: <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009221400010.32661-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org> wrote on 09/22/2010 12:01:28 PM:

> The earlier patch added an initial mininum latency and got us up to
> ~80ms. However, there are large networks that take longer to configure
> multicast paths.

        I feel your pain, but the protocol allows this to be 0 and all
of the unsolicited reports can be lost. I don't think adding a minimum
latency solves a general problem. Perhaps the device should queue some
packets if it isn't ready quickly? A querier is what makes these
reliable, but for the start-up in particular, I think it'd be better
to not initiate the send on devices that have this problem until the
device is actually ready to send-- why not put the delay in the device
driver on initialization?
 
> with this suggestion since the intervals can be very short. There is 
also
> no reason to randomize since the unsolicited reports are not a response 
to
> an igmp query but the result of a join request in the code.

        These are also staggered to prevent a storm by mass reboots, e.g.,
from a power outage, and the default groups are joined on interface
bring-up.


> The patch here establishes more fixed delays for sending unsolicited
> igmp reports after join. There is still a fuzz factor associated but the
> sending of the igmp reports follows more tightly a set of intervals and 
sends
> up to 7 igmp reports.
> 
> IGMP Report   Time delay
> ------------------------------------------------------------
> 0      3 ticks      "immediate" accordig to RFC.
> 1      40ms
> 2      200ms
> 3      1sec
> 4      5sec
> 5      10sec
> 6      60sec
> 
> So unsolicited reports are send for an interval of at least a minute
> (reports are aborted if igmp reports or other info is seen).

        This is outside the protocol spec, and the intervals are neither
random nor scaled based on any network performance metric.

1) I'm not sure there's a problem here to solve, other than for your
        particular hardware.
2) I think this would better be solved in the driver-- don't do the
        upper initialization and group joins until the sends can actually
        succeed.
3) I don't think it's a good idea to make up intervals, and especially
        non-randomized ones. The probability of getting all minimum 
intervals
        is very low (which goes back to #1) and sending fixed intervals 
may
        introduce a problem (packet storms) that isn't there per RFC. 
These
        fixed intervals can also be either way too long or way too short,
        depending on link characteristics they don't account for. Leaving
        the intervals randomized based on querier-supplied data seems much
        more appropriate to me.


                                                                +-DLS

 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
