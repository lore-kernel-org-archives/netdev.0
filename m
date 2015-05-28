From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 for-next 04/12] IB/ipoib: Return IPoIB devices
 matching connection parameters
Date: Thu, 28 May 2015 09:45:01 -0600
Message-ID: <20150528154501.GA2962@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-5-git-send-email-haggaie@mellanox.com>
 <20150519235502.GB26634@obsidianresearch.com>
 <555D6E41.10606@mellanox.com>
 <20150521174336.GA6771@obsidianresearch.com>
 <55670157.8090000@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	"Hefty, Sean" <sean.hefty@intel.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:58264 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753518AbbE1PpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 11:45:07 -0400
Content-Disposition: inline
In-Reply-To: <55670157.8090000@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 02:51:51PM +0300, Haggai Eran wrote:

> > But RDMA CM doesn't provide the QPN. So when RDMA CM searches the
> > netdevs for an address it cannot *uniquely* map to a IPoIB interface.

> This is technically true, but if someone configures their system that
> way, they will also have ARP conflicts in addition. I don't see why we
> should support such a configuration.

Based on the dicussion in the other thread about this, the feeling is
we should not support same-GUID, same-PKey child interfaces at all. It
breaks too much stuff (DHCP,NetworkManager,IPv6,RDMA-CM)

> No, this is exactly what would happen in the Ethernet world. If you
> create a conflicting configuration between two containers on the same
> Ethernet segment, then one of them could get the traffic that was
> intended for the other.

It is not exactly the same. In Ethernet there is an ARP collision at
L3, but the traffic is properly addressed at L2 and unambiguously
directed into only one container. There are ways to deal with ARP
collisions, but those are only effective if the full LLADDR is
consistently used for routing to containers.

With RDMA-CM it is an L3 collsion, so our anti-ARP collision stuff
doesn't help.

Like I said, I don't from a security perspective what to make of this,
but it isn't exactly the same of ethernet.

> >  1) Locate the netdev associated with the ingress of the packet,
> >     in a sane world this is done by only checking the
> >     unique (Device,Port,Pkey,QPN) tuple.
> >     If we keep our brokeness, we'd do this based on
> >     (Device,Port,Pkey,IP) - if there are IP collisions then randomly
> >     select a netdev (similar to how ARP collision is handled).
> That's what ib_get_net_dev_by_port_pkey_ip intends to do.

Right, almost there.

ib_get_net_dev_by_port_pkey_ip needs to work in a very specific
way: If there is only one netdev with the (Device,Port,GUID,Pkey)
match then that is the answer.
(guid comes from the CM_REQ, if we add alias GUID support to IPoIB as
 Or suggested then it is needed)

The IP search should *only* be done if there are two children with
identical (Pkey,GUID), and as above, perhaps we should de-support that.

> >  2) Then we do the ip_route_input_noref step, this will set skb_dst to
> >     the netdev that will handle the packet, or tell us to drop it.
> >     This is not always the same as the netdev that accepts the
> >     packet!!!
> > 
> >     NOTE: This route step is missing today, it does critical things
> >     like check that the node is actually listening on the dest IP!
> 
> Isn't this a little over-engineered? If all you want is to make sure the
> net dev is up, can't we use something like netif_running()?

The routing check is not to see if the netdev is up, it is doing all
sorts of subtle userspace visible things. Like checking there is no
blackhole route configured for the packet, checking that the IP is
present in the system, netdevs are up, etc etc.

We don't get to pick and choose what netdev behaviors we implement
when doing this kind of stuff. Copy the netstack, don't make stuff up.

Understand the two layer separation, first with pick a netdev without
looking at L3 info, then we feed the netdev and L3 info into routing
to complete the process.

> Also, this sounds like a major change in behavior even for applications
> that do not use containers. I think today RDMA CM will accept
> connections even if the ipoib interface is down.

Yes, it is a change in behavior, things move closer to alignment with
how netdev works. We did a similar change to the output side years ago
as well. I guess the input side was missed.

Unless I'm missing something this isn't 'major', these are corner case
conditions/bugs that nobody sane should rely on.

> >  3) Now we can use skb_dst to iterate over the set of all RDMA CM listens:
> >      1) Bound to the skb_dst netdev
> >      2) Unbound in the same namespace as skb_dst netdev
> >     The first to match the dst IP + port is the listen that will accept the
> >     connection, now we go into the cma_new_conn_id path, and we don't
> >     need rdma_translate_ip because we already have the handling netdev.
> You shouldn't be able to bind one listener to a netdev in a namespace
> and also have a different listener listening for any netdev on that same
> namespace. (That is what cma_check_port verifies, right?) So when
> looking for a listener in a namespace there should be only one match.

You know, I don't remember off hand the exact semantics of sockets,
whatever sockets does :)

> > The backwards operation of the current code is part of why this is all
> > so strange looking, and I think is strongly connected to the private
> > data compare issues Sean is talking about. It is very much the wrong
> > flow to look for the RDMA CM listen first, and then try to work
> > backwards to the netdev.

> That's not what the code does. It first finds the netdev and decides on
> the namespace based on that. It then finds the RDMA CM listener in that
> namespace.

I was talking about the current code, but even with the patch set, the
behavior is still backwards:

 1) Find the netdev
 2) Get the namespace, throw away the netdev
 3) Find a CM_ID without a netdev
 4) Find a netdev from the CM_ID

Instead:
 1) Find the netdev
 2) Find a CM_ID compatible with that netdev

> I think I can refactor the series this way, but I don't think we need
> step 2. It seems like an overly complicated way of checking whether a
> netdev is up or not. It doesn't seem to provide any new information over
> what ib_get_net_dev_by_port_pkey_ip does.

If it is hard to do then leave a FIXME comment and go on, if it is
easy, it is the right step.

It does provide more information because
ib_get_net_dev_by_port_pkey_ip should not check the IP.

> For RoCE, you could still have multiple macvlan interfaces using the
> same VLAN, with different IP address. So the unique tuple is
> (Device,Port,VLAN,IP). With Matan adding a netdev to each GID entry in
> the RoCE GID table, I think it would be simpler to find the netdev in RoCE.

That isn't how I understand macvlan, the tuple will be
(Device,Port,MAC,VLAN)

You should never search for an IP, that is not how netdev works.

Jason
