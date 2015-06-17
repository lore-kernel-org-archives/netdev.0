From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH 04/11] IB/cm: Expose DGID in SIDR request events
Date: Wed, 17 Jun 2015 11:06:12 -0600
Message-ID: <20150617170612.GB27232@obsidianresearch.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-5-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FF5A3F@ORSMSX109.amr.corp.intel.com>
 <20150615220852.GB4384@obsidianresearch.com>
 <55800793.4040103@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Hefty, Sean" <sean.hefty@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:36471 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753584AbbFQRGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 13:06:17 -0400
Content-Disposition: inline
In-Reply-To: <55800793.4040103@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2015 at 02:25:07PM +0300, Haggai Eran wrote:

> > But how is that going to work? How is the sender to know it should be
> > sending a GRH with the CM message?
> 
> If the admin wants to use SIDR with alias GIDs, they will need to
> configure the system to enable GRH for such GMPs. (This series doesn't
> include such a patch).

Gross.

> Regarding APM, currently the ib_cm code always sends the GMP to the
> primary path anyway, right? And in any case, one would expect the
> primary path's GID to have a valid net_device and local routing rules,
> so I think for the purpose of demuxing and validating the request using
> the primary path should be fine.

The current code works that way, but it is not what I'd expect
generally.

For instance, future APM support will be able to drive dual-rail and
policy will decide which rail is the current best rail for data
transfer. So the GMP may be directed to the IPoIB device with port 1,
but the data transfer may happen on the RDMA port 2. [Note, I already
have very rough patches that do this de-coupling]

> Why do you think the GMP's net_device should be used over the one of the
> future RDMA channel?

The code needs to match the incoming GMP with the logical netdev that
rx's *that GMP*. The fact that goes on to setup an RDMA channel is not
relevant, the nature of the future RDMA channel should not impact how
the GMP is recieved.

> So far we can work without GRH for CM requests, and also without GRH for
> SIDR requests if we rely on layer 3 for the interface resolution. I'm
> not against adding a LLADDR to the protocol somehow, but I don't think
> we should abandon all these use cases and the interoperability with
> existing software.

Well, there is a middle ground. Lets say we get the LLADDR in the GMP
somehow, then we get 100% correct operation when it is present.

For degraded operation we have the (device,port,pkey) and possibly
(device,port,pkey,gid) if there was a GRH. We also have the IP address
hack.

So, I'd say, search in this sequence:
 - If the LLADDR is present, just find the right netdev
 - Otherwise search for (device,port,pkey) / (device,port,pkey,gid)
   If there is only one match then that is unambiguously the correct
   device to use.
 - Repeat the above search, but add the IP address. This is the hack
   we perform for compatibility.

There is no reason to hackily look at the GMP path parameters if we are
relying on #3 above as the hack to save us in the legacy ambiguous case.

.. and to answer your question in the other email, I think we should
keep the hack clearly distinct from the proper operation (in fact,
perhaps it should be user configurable). So #3 should be a distinct
step taken when all else fails, not integrated into earlier steps.

So, this series as it stands just needs to do #2/#3 above and you guys
can figure out the LLADDR business later.

Jason
