From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v2 07/11] IB/cm: Add network namespace support
Date: Tue, 21 Apr 2015 09:54:02 -0600
Message-ID: <20150421155402.GA26088@obsidianresearch.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
 <1429520622-10303-8-git-send-email-haggaie@mellanox.com>
 <20150420170659.GD7676@obsidianresearch.com>
 <20150420233520.GC1409@phlsvsds.ph.intel.com>
 <55363D93.10706@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <55363D93.10706-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2015 at 03:07:47PM +0300, Haggai Eran wrote:

> Namespace is needed for RoCE address resolution, in cases where the
> driver doesn't report the MAC as part of the ib_wc.

This patch explicitly says it doesn't deal with RoCE, so why are we
adding namespaces to support RoCE paths in this series? Especially
since we have no idea how that should fit into verbs.

Frankly, that stuff is the most objectionable part of this series.

I suggest:
 1) Focus only on the RDMA-CM, and only on IB support, as the title
    says
 2) Drop all changes to verbs and cm and otherwise that are not
    directly related to IB
 3) Very, very, strongly justify why the remaining layer violations are
    necessary, and think very carefully about doing something else.

For IB, it is very clear to me that only the RDMA-CM can possibly have
the knoweldge to find the namespace, so only the RDMA-CM should be
touching it.

If the interface between the RDMA-CM and IB-CM layers is preventing
something, then extend the interface, don't drop RDMA-CM code into
IB-CM.

>From that point, with working IB, we can revisit what is needed to
make iWarp and RoCE work at the verbs layer and ultimately at the CM
layer, in steps.

Your other questions:

> Using the GID alone is not enough to distinguish between namespaces,
> because you can have multiple IPoIB interfaces, all using the GID (and
> possibly the same P_Key), and each belonging to a different namespace.

Exactly, this is why IB GID layers can't possibly need to touch the net
namespace.

> The listener rbtree's key is currently the service ID, for
> instance. Now with namespaces, you can have multiple listeners
> listening on the same service ID, so we need to use (service ID,
> namespace) as the key.

CM doesn't care, a service ID is registered by RDMA-CM and RDMA-CM can
demux the (service ID,IP) tuple to the right namespace. Having CM
snoop private data is a huge layering violation!

> looks at it's private data and demuxes it to a net namespace.
> I don't see it there. The code seem to fetch the GID from the GRH.
> Because the IP address in the source GID can be the same for different
> namespaces, this is not enough to pick the right namespace.

For IB, ib_init_ah_from_wc does not need a namespace.

For RoCEE, the GID *MUST* be enough to find the namespace because each
namespace will create a unique GID table entry.

RoCEE and IB are going to be totally different in how this
implemented...

I expect RoCEE to have namespace constraints at the verbs QP level,
while IB cannot - that feels like a huge journey...

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
