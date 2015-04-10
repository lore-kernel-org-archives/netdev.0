From: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport() for each HW
Date: Fri, 10 Apr 2015 17:06:40 -0400
Message-ID: <20150410210639.GB19907@phlsvsds.ph.intel.com>
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com> <20150410061610.GA26288@phlsvsds.ph.intel.com> <20150410161551.GA26419@obsidianresearch.com> <20150410173836.GE10675@phlsvsds.ph.intel.com> <20150410180455.GA1277@obsidianresearch.com> <1428690266.2980.381.camel@redhat.com> <20150410191723.GC1277@obsidianresearch.com>
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
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150410191723.GC1277-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2015 at 01:17:23PM -0600, Jason Gunthorpe wrote:
> On Fri, Apr 10, 2015 at 02:24:26PM -0400, Doug Ledford wrote:
> 
> > IPoIB is more than just an ULP.  It's a spec.  And it's very IB
> > specific.  It will only work with OPA because OPA is imitating IB.
> > To run it on another fabric, you would need more than just to make
> > it work.  If the new fabric doesn't have a broadcast group, or has
> > multicast registration like IB does, you need the equivalent of
> > IBTA, whatever that may be for this new fabric, buy in on the
> > pre-defined multicast groups and you might need firmware support in
> > the switches.
> 
> It feels like the 'cap_ib_addressing' or whatever we call it captures
> this very well. The IPoIB RFC is very much concerned with GID's and
> MGID's and broadly requires the IBA addressing
> scheme. cap_ib_addressing asserts the port uses that scheme. 
> 
> We wouldn't accept patches to IPoIB to add a new addressing scheme
> without seeing proper diligence to the standards work.
> 
> Looking away from the stadards, using cap_XX seems very sane: We are
> building a well defined system of invarients, You can't call into the
> sa functions if cap_sa is not set, you can't call into the mcast
> functions if cap_mcast is not set, you can't form a AH from IB
> GIDs/MGID/LID without cap_ib_addressing.

Yep.

> 
> I makes so much sense for the ULP to directly require the needed cap's
> for the kernel APIs it intends to call, or not use the RDMA port at
> all.

Yes.

So trying to sum up.

Have we settled on the following "capabilities"?  Helper function names aside.

/* legacy to communicate to userspace */
RDMA_LINK_LAYER_IB       = 0x0000000000000001,
RDMA_LINK_LAYER_ETH      = 0x0000000000000002,
RDMA_LINK_LAYER_MASK     = 0x000000000000000f, /* more bits? */
	/* I'm hoping we don't need more bits here */


/* legacy to communicate to userspace */
RDMA_TRANSPORT_IB        = 0x0000000000000010,
RDMA_TRANSPORT_IWARP     = 0x0000000000000020,
RDMA_TRANSPORT_USNIC     = 0x0000000000000040,
RDMA_TRANSPORT_USNIC_UDP = 0x0000000000000080,
RDMA_TRANSPORT_MASK      = 0x00000000000000f0, /* more bits? */
	/* I'm hoping we don't need more bits here */


/* New flags */

RDMA_MGMT_IB_MAD         = 0x0000000000000100, /* ib_mad module support */
RDMA_MGMT_QP0            = 0x0000000000000200, /* ib_mad QP0 support */
RDMA_MGMT_IB_SA          = 0x0000000000000400, /* ib_sa module support */
					       /* NOTE includes IB Mcast */
RDMA_MGMT_IB_CM          = 0x0000000000000800, /* ib_cm module support */
RDMA_MGMT_OPA_MAD        = 0x0000000000001000, /* ib_mad OPA MAD support */
RDMA_MGMT_MASK           = 0x00000000000fff00,

RDMA_ADDR_IB             = 0x0000000000100000, /* Port does IB AH, PR, Pkey */
RDMA_ADDR_IBoE           = 0x0000000000200000, /* Port does IBoE AH, PR, Pkey */
/* Do we need iWarp (TCP) here? */
RDMA_ADDR_IB_MASK        = 0x000000000ff00000,


RDMA_SEPARATE_READ_SGE   = 0x0000000010000000,
RDMA_QUIRKS_MASK         = 0x000000fff0000000


> 
> > > We can see how this might work in future, lets say OPAv2 *requires* the
> > > 32 bit LID, for that case cap_ib_address = 0 cap_opa_address = 1. If
> > > we don't update IPoIB and it uses the tests from above then it
> > > immediately, and correctly, stops running on those OPAv2 devices.
> > > 
> > > Once patched to support cap_op_address then it will begin working
> > > again. That seems very sane..
> > 
> > It is very sane from an implementation standpoint, but from the larger
> > interoperability standpoint, you need that spec to be extended to the
> > new fabric simultaneously.
> 
> I liked the OPAv2 hypothetical because it doesn't actually touch the
> IPoIB spec. IPoIB spec has little to say about LIDs or LRHs it works
> entirely at the GID/MGID/GRH level.

Agreed.

Ira

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
