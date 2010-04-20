From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Tue, 20 Apr 2010 08:22:06 -0700
Message-ID: <20100420152206.GA24942@x200.localdomain>
References: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
 <201004201548.26609.arnd@arndb.de>
 <20100420143433.GF11712@x200.localdomain>
 <201004201657.02873.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@redhat.com>,
	Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360Ab0DTPWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 11:22:12 -0400
Content-Disposition: inline
In-Reply-To: <201004201657.02873.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann (arnd@arndb.de) wrote:
> On Tuesday 20 April 2010, Chris Wright wrote:
> > * Arnd Bergmann (arnd@arndb.de) wrote:
> > > On Monday 19 April 2010, Scott Feldman wrote:
> > > 
> > > What is the reason for controlling the slave device through the master,
> > > rather than talking to the slave directly? The kernel always knows
> > > the master for each slave, so it seems to me that this information
> > > is redundant.
> > 
> > Not all devices have this relationship explicit (i.e. not all are pure
> > sr-iov devices).  If there's always a way to discover the master from
> > the device, then I agree we only need the slave.
> 
> Hmm, is there an actual example of a card where the relationship is not
> known to the kernel?
> 
> > > Is this new interface only for the case that you have a switch integrated
> > > in the NIC, or also for the case where you do an LLDP and EDP exchange
> > > with an adjacent bridge and put the device into VEPA mode?
> > 
> > It should be useful for both.  That's part of the reason for using
> > netlink, a userspace daemon running the VDP state machine (like lldpad)
> > can listen for these messages and see a set_port_profile request when
> > the user starts up a VM.
> 
> After thinking some more about this case, I now believe we should do
> it the other way around, and have lldpad in control of this interface
> from the user space side, and letting user programs (lldptool, libvirt,
> ...) talk to lldpad in order to set it up.

lldpad won't be involved in all cases, yet a mgmt tool like libvirt will.
so this seems backwards.

> > > Also, do you expect your interface to be supported by dcbd/lldpad,
> > > or is there a good reason to create a new tool for iovnl?
> > 
> > lldpad would listen, I don't see why iproute2 couldn't send, and libvirt
> > will send as well.
> 
> Not sure. We need lldpad to do this exchange for the case of VEPA with
> VDP, so always using lldpad would let us unify the user interface for
> both cases. We can of course have iproute2 talk to lldpad, in the
> same way that libvirt does.
> 
> > > > + * @IOV_ATTR_PORT_PROFILE: port-profile name to assign to device
> > > > + *   (NLA_NUL_STRING)
> > > 
> > > How does the definition of the port profile get into the NIC's switch?
> > > Is there any way to list the available port profiles?
> > 
> > The port profile is a concept external to the NIC's switch.  It's a value
> > that exists in the external physical layer 2 switching infrastructure.
> > So an admin knows this value and is informing the adjacent switch that a
> > new virutal interface is coming up and needs some particular port profile.
> 
> But that's only the case if the NIC itself is in VEPA mode. If that
> were the case, there would be no need for a kernel interface at all,
> because then we could just drive the port profile selection from user
> space.
> 
> The proposed interface only seems to make sense if you use it to
> configure the NIC itself! Why should it care about the port profile
> otherwise?

In the case of devices that can do adjacent switch negotiations directly.

> > > Same here: Should you be able to set multiple MAC addresses, or
> > > trunk mode? Can the VF override it?
> > > Also, for the new multi-channel VEPA, I'd guess that you also need
> > > to supply an 802.1ad S-VLAN ID.
> > 
> > Something like set_port_profile() would initiate the negotiation for the
> > s-vlan id for a particular channel, not sure it's needed as part of the
> > netlink interface or not.
> 
> Well, you have to set up the s-vlan ID in order to have something to
> set the port profile in.

Right, depends if the use the port profile to establish the channel and
negotiate the s-vlan ID.  I don't recall the order there.

thanks,
-chris
