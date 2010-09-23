From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
	reports
Date: Thu, 23 Sep 2010 11:46:14 -0600
Message-ID: <20100923174614.GN11157@obsidianresearch.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home> <20100922215052.GK11157@obsidianresearch.com> <alpine.DEB.2.00.1009231026510.32567@router.home> <20100923172603.GM11157@obsidianresearch.com> <alpine.DEB.2.00.1009231230100.2962@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009231230100.2962-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2010 at 12:37:28PM -0500, Christoph Lameter wrote:
> On Thu, 23 Sep 2010, Jason Gunthorpe wrote:
> 
> > On Thu, Sep 23, 2010 at 10:32:17AM -0500, Christoph Lameter wrote:
> >
> > > > Is the issue you are dropping IGMP packets because the 224.0.0.2 join
> > > > hasn't finished? Ideally you'd wait for the SA to reply before sending
> > > > a IGMP, but a simpler solution might just be to use the broadcast MLID
> > > > for packets addressed to a MGID that has not yet got a MLID. This
> > > > would bebe similar to the ethernet behaviour of flooding.
> > >
> > > IGMP reports are sent on the multicast group not on 224.0.0.2. 224.0.0.2
> > > is only used when leaving a multicast group.
> >
> > Hm, that is quite different than in IGMPv3.. How does this work at all
> > in IB? A message to the multicast group isn't going to make it to any
> > routers unless the routers use some other means to join the IB MGID.
> 
> IPoIB creates a infiniband multicast group via the IB calls for a IP
> multicast group. Then IGMP comes into play and the kernel sends the IP
> based igmp report. This igmp report must be received by an outside router
> (on an IP network) in order to for traffic to get forwarded into the IB
> fabric. You can end up with a IB multicast configuration that is all fine
> but with loss of the unsolicited packets due to fabric reconfiguration not
> being complete yet. The larger the fabric the worse the situation.

But my point is that IB has very limited multicast, if I create a IB
group and then send IGMP into that group *it will not reach a router*.

I have to send something to the all routers group or the all IGMPv3
group to get it to reach a router with any reliably.

The only way this kind of scheme could work is if an IGMPv2 IPoIB
router listens for IB MGID Create notices from the SA and
automatically joins all groups that are created, so it can get IGMPv2
membership reports. Which obviously adds more delay, lag, and risk.

I'm *guessing* that the change in IGMPv3 to send reports to 224.0.0.22
(all IGMPv3 multicast address) is related to this sort of problem, and
it seems like on IB IGMPv2 is not a good fit and should not be used if
v3 is available..

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
