From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Date: Fri, 10 Apr 2015 10:15:51 -0600
Message-ID: <20150410161551.GA26419@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523D098.3020007@profitbricks.com>
 <1428517786.2980.180.camel@redhat.com>
 <20150408201015.GB28666@obsidianresearch.com>
 <20150410061610.GA26288@phlsvsds.ph.intel.com>
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
In-Reply-To: <20150410061610.GA26288-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2015 at 02:16:11AM -0400, ira.weiny wrote:

> >         IB ROCEE OPA
> > SMI     Y  N     Y    (though the OPA smi looked a bit different)
> 
> Yes OPA is different but it is based on the class version of the individual
> MADs not any particular device/port support.

> > OPA SMP N  N     Y
> 
> How is this different from the SMI?

Any code that generates SMPs and SMIs is going to need to know what
format to generate them in. It seems we have a sort of weird world
where IB SMPs are supported on OPA but not the IB SMI.

Not sure any users exist though..

> > Maybe the above set would make a lot more sense as:
> >   cap_ib_qp0
> >   cap_ib_qp1
> >   cap_opa_qp0
> 
> I disagree.
> 
> All we need right now is is cap_qp0.  All devices currently support QP1.

I didn't list iWarp in the table because everything is no, but it
doesn't support QP1.

> > ib_sa means the IBA SA protocol is supported (Y Y Y)
> 
> I think this should be (Y N Y)
> 
> IBoE has no SA.  The IBoE code "fabricates" a Path Record it does not need to
> interact with the SA.

I was wondering why there are so many checks in the SA code, I know
RoCEE doesn't use it, but why are there there?
 
> > ib_mcast true if the IBA SA protocol is used for multicast GIDs (Y N
> > Y)
> 
> Given the above why can't we just have the "ib_sa" flag?

Maybe I got it wrong, but yes, if it really means 'IBA SA protocol for
multicast then it can just be cap_sa.

But there is also the idea that some devices can't do multicast at all
(iWarp), we must care about that at some point?

> However, I think checking the link layer is more appropriate here.
> It does not make sense to do IP over IB over Eth.  Even though the
> IBoE can do the "IB" protocol.

Yes, it is ugly.

I think if we look closely we'll find that IPoIB today has a hard
requirement on cap_sa being true, so lets use that?

In fact any ULP that unconditionally uses the SA can use that.

> > I actually really prefer cap_mandatory_grh - that is what is going on
> > here. ie based on that name (as a reviewer) I'd expect to see the mad
> > layer check that the mandatory GRH is always present, or blow up.
> 
> While GRH mandatory (for the GMP) is what this is.  The function
> ib_init_ah_from_path generically is really handling an "IBoE address" to send
> to and therefore we need to force the GRH in the AH.

This make sense to me.

It appears we have at least rocee, rocee v2 (udp?), tcp, ib and opa
address and AH formats? opa would support ib addresses too I guess.

A 
 bool rdma_port_addr_is_XXX()

along with a

  enum AddrType rdma_port_addr_type()

Might be the thing? The latter should only be used with switch()

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
