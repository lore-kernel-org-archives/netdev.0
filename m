From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Date: Fri, 10 Apr 2015 12:04:55 -0600
Message-ID: <20150410180455.GA1277@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523D098.3020007@profitbricks.com>
 <1428517786.2980.180.camel@redhat.com>
 <20150408201015.GB28666@obsidianresearch.com>
 <20150410061610.GA26288@phlsvsds.ph.intel.com>
 <20150410161551.GA26419@obsidianresearch.com>
 <20150410173836.GE10675@phlsvsds.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Mike Marciniszyn <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morg
To: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150410173836.GE10675-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2015 at 01:38:38PM -0400, ira.weiny wrote:
 
> Isn't ocrdma an iWarp device?

No, it is RoCEE

> > I was wondering why there are so many checks in the SA code, I know
> > RoCEE doesn't use it, but why are there there?
> 
> Which checks are you referring to?  I think there are separate calls to query
> the SA when running on IB for both the Route resolution and the Multicast join
> operations.  The choice of those calls could be made by a "cap_sa()" helper.

I will point them out next time I look through the patches

> > I think if we look closely we'll find that IPoIB today has a hard
> > requirement on cap_sa being true, so lets use that?
> 
> I don't think that is appropriate.  You have been advocating that the checks
> be clear as to what support we need. 

Right, but this is narrow, and we are not hiding meaning.

Look at the IPoIB ULP, and look at the hard requiments of the code,
then translate those back to our new cap scheme. We see today's IPoIB
will not run without:
 - UD support
 - IB addressing
 - IB multicast
 - IB SA
 - CM (optional)

It seems perfectly correct for a ULP to say at the very start, I need
all these caps, or I will not run (how could it run?). This is true of
any ULP that has a hard need to use those APIs.

That would seem to be the very essance of the cap scheme. Declare what
you need, not what standard you think you need.

Hiding meaning is to say 'only run on IB or OPA': WHY are we limited
to those two?

> While currently the IPoIB layer does (for IB and OPA) require an SA
> I think those checks are only appropriate when it is attempting an
> SA query.

That doesn't make any sense unless someone also adds support for
handling the !SA case.

> > It appears we have at least rocee, rocee v2 (udp?), tcp, ib and opa
> > address and AH formats?
> 
> Seems that way.  But has the rocee v2 been accepted?

Don't know much about it yet, patches exist, it seems to have a
slightly different addressing format.

> > opa would support ib addresses too I guess.
> 
> Yes opa address == ib addresses.  So there is no need to distinguish them.

The patches you sent showed a different LRH format for OPA (eg 32 bit
LID), so someday we will need to know that the full 32 bit LID is
available.

We can see how this might work in future, lets say OPAv2 *requires* the
32 bit LID, for that case cap_ib_address = 0 cap_opa_address = 1. If
we don't update IPoIB and it uses the tests from above then it
immediately, and correctly, stops running on those OPAv2 devices.

Once patched to support cap_op_address then it will begin working
again. That seems very sane..

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
