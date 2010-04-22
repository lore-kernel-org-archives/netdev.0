From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 10:47:29 -0700
Message-ID: <20100422174729.GK28829@x200.localdomain>
References: <C7F4AD4F.2A34D%scofeldm@cisco.com>
 <201004212313.05060.arnd@arndb.de>
 <20100421224802.GF28829@x200.localdomain>
 <201004220851.05756.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@redhat.com>,
	Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Mitch Williams <mitch.a.williams@intel.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755072Ab0DVRrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 13:47:37 -0400
Content-Disposition: inline
In-Reply-To: <201004220851.05756.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann (arnd@arndb.de) wrote:
> On Thursday 22 April 2010, Chris Wright wrote:
> > > 
> > > ip link add link eth0 type macvlan    # for a container
> > > ip link add link eth0 type macvtap    # for qemu/vhost
> > > ip link add link eth0 type vf         # for device assignment
> > 
> > BTW, what do you mean by device assignment?
> 
> I mean giving an SR-IOV VF to the guest as a native PCI device
> rather than having qemu or vhost present a virtio-net to the
> guest.

OK, wasn't clear if you meant that or simply 100% dedicating the interface
via something like virtio.  The add_vf() idea, while neat, doesn't really
match how VF's are allocated.

> > > There are obviously significant differences between these three, but
> > > they also share enough of their properties to let us treat them
> > > in similar ways.
> > > 
> > > If we integrate the iovnl client into iproute2, the sequence for setting
> > > up an enic VF and associating it to the port profile could be
> > > 
> > > # create vf0, pass mac and vlan id to HW, no association yet
> > > ip link add link eth0 name vf0 type vf mac fe:dc:ba:12:34:56 vlan 78
> > 
> > Just to clarify...right now, the normal SR-IOV VF is already there.
> > And, or course, can have its mac addr/vlan set already.
> 
> I don't have an SR-IOV card available for testing yet. How is this
> configured now?

The device shows up in the host as a normal network device, so mgmt tools
currently treat it as if it's no different from a PF.  So that's just
plain old:

SIOCSIFHWADDR or RTM_SETLINK (i.e. normal ->ndo_set_mac_addr)

There's also the possiblity of configuring through the PF (although
this isn't really widely used ATM, and has the disadvantage of exposing
the VF number to userspace in a way that's difficult to use).  This is
also done via RTM_SETLINK (on the PF this time), and will result in
->ndo_set_vf_mac().

> > > # associate vf with port profile, mac address must match the one assigned
> > > #  to the interface before.
> > > ip iov assoc eth0 port-profile "general" host-uuid "dcf2a873-f5ee-41dd-a7ad-802a544e48c2" \
> > >        mac fe:dc:ba:12:34:56
> > 
> > At that point you could just do s/mac fe:.*/link vf0/
> 
> My point was that this information should be irrelevant to the code doing the
> association with the switch. It sort of makes sense when the receiver is enic,
> but when we send the same data to lldpad, it doesn't care about the slave device
> name but only about the mac address. Especially since the slave device might not
> be in the root name space any more, meaning we have no way to find it.

Yeah, w/ namespace I think you'd normally do all setup before handing
into a new namespace.

thanks,
-chris
