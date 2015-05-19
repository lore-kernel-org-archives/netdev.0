From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Tue, 19 May 2015 17:46:54 -0600
Message-ID: <20150519234654.GA26634@obsidianresearch.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com>
 <5551A2CB.1010407@mellanox.com>
 <20150512185447.GA3503@obsidianresearch.com>
 <55532566.9040105@mellanox.com>
 <20150513165823.GA20343@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDC0C3@ORSMSX109.amr.corp.intel.com>
 <20150519192353.GA23612@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDD412@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FDD412-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 10:52:59PM +0000, Hefty, Sean wrote:
> > I find Haggai's argument compelling, it is a very small amount of code
> > and data to add a sharing count, and a very large amount to duplicate
> > the whole service id map into cma.c.
> 
> I get wanting to share the listen list, but we end up with this:
> 
> > drivers/infiniband/core/cm.c                       | 129 +++++-
> 
> that's more code than what the ib_cm module uses to track listens,
> and the result is a solution that ends up being split in a weird
> fashion between the ib_cm, iw_cm (TBD), and rdma_cm.

I was mostly thinking about data overheads with a second rbtree, but I
do wonder if the overhead is already in the rdma_cm between the
listen_list, bind_list, etc. So maybe that should be used instead..

> I wonder if the existing ib_cm interface is even what we want.
> Currently, the rdma_cm pushes the private data (i.e. IP address)
> comparison into the ib_cm.  This is only used by the rdma_cm.
> Should that instead be moved out of the ib_cm and handled in the
> rdma_cm?  And then update the ib_cm to support multiple listens on
> the same service id.

Well, that really is the problem here, the private data compare
doesn't really do enough because rdma cm wildcard's the IP address and
does it's own check anyhow. So I see all of this as different
proposals on how to fix that. rdma_cm basically already does most of
the private data compare itself.

It is hard to make the private data compare more fancy and still
provide EBUSY semantics..

On one hand, we don't really need the cm to maintain a list of
listeners and iterate over them for the rdma cm, that state is already
kept and tracked in rdma_cm when it goes to find the device the IP is
associated with..

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
