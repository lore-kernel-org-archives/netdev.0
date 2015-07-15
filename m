From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v1 08/12] IB/cma: Add net_dev and private data checks to
 RDMA CM
Date: Wed, 15 Jul 2015 12:49:34 -0600
Message-ID: <20150715184934.GD23588@obsidianresearch.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-9-git-send-email-haggaie@mellanox.com>
 <20150713181414.GJ23832@obsidianresearch.com>
 <55A63CAC.60603@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:48124 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313AbbGOStg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 14:49:36 -0400
Content-Disposition: inline
In-Reply-To: <55A63CAC.60603@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 01:57:48PM +0300, Haggai Eran wrote:
> On 13/07/2015 21:14, Jason Gunthorpe wrote:
> > On Mon, Jun 22, 2015 at 03:42:37PM +0300, Haggai Eran wrote:
> >> +	switch (ib_event->event) {
> >> +	case IB_CM_REQ_RECEIVED:
> >> +		req->device	= req_param->listen_id->device;
> >> +		req->port	= req_param->port;
> >> +		req->local_gid	= &req_param->primary_path->sgid;
> >> +		req->service_id	= req_param->primary_path->service_id;
> >> +		req->pkey	= be16_to_cpu(req_param->primary_path->pkey);
> > 
> > I feel pretty strongly that we should be using the pkey from the work
> > completion, not the pkey in the message.
> > 
> > The reason, if someone is using pkey like vlan, and expecting a
> > container to never receive packets outside the assigned pkey, then we
> > need to check each and every packet for the correct pkey before
> > associating it with that container.
> 
> The way I see it is that you have one RDMA CM agent in the system, and
> the header parameters address it. This agent allows addressing several
> namespaces, and they are de-muxed according to the parameters in the
> payload.

That doesn't address my argument at all.

A container should never, ever, process a packet on a pkey that is not
associated with it.

So, it doesn't matter one bit how you decide to demux. After the demux
is done all three pkeys needs to be checked to be compatible with the
container: GMP, Primary Path, Alternate Path.

If any are not compatible the packet *MUST* be dropped.

If you do the above check, you may as well start with the wc's pkey,
since it reflects the logical 'netdevice' that received the packet.

> So a container never receives a packet outside of its assigned pkeys,
> but the pkey you look at (as well as the GID, and possibly the IP
> address) all come from the payload.

That isn't entirey true, at a minimum the above scheme allows an
attacking pkey to create an unbounded number of REQs delivered to
userspace on a victim container, without needing to be part of the
victim's pkey.

> > When doing the namespace patches you should probably also look at
> > other CM GMPs than just the REQ and how the paths are setup and
> > consider what to do with the pkey. I'd probably suggest that the pkey
> > should be forced throughout the entire process to ensure it always
> > matches the ip device - at least for containers that is the right
> > thing.. I probably wouldn't turn it on for the root namespace though..
> 
> Once a connection has been established, following GMPs use a unique ID
> to address this connection, so no more de-muxing is needed.

I think there are open issues here about pkey correctness. Ie the
unique ID is not locked to a pkey, so an attacking pkey can guess the
unique ID and then issue GMPs that will be accepted.

Once locked to a container the unique ID absolutely needs to drop all
packets that are outside the container's pkey space. IMHO this would
be part of the namespace patches.

Basically, pkey in a container should work exactly the same as pkey on
a HCA, packets are dropped before they ever reach the container. This
means every single resource associated with a container much check the
pkey of any packet targeted at that resource.

> What is really missing here I guess is a mechanism that would
> enforce containers to only use certain pkeys - perhaps with
> something like an RDMA cgroup.  It could force containers to only
> use approved pkeys not only with RDMA CM, but through uverbs, and
> other user-space interfaces.

Ideally yes. Without that it just means you can't use pkey
meaningfully with containers..

Jason
