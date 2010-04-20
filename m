From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Tue, 20 Apr 2010 07:34:33 -0700
Message-ID: <20100420143433.GF11712@x200.localdomain>
References: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
 <201004201548.26609.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754488Ab0DTOei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 10:34:38 -0400
Content-Disposition: inline
In-Reply-To: <201004201548.26609.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann (arnd@arndb.de) wrote:
> On Monday 19 April 2010, Scott Feldman wrote:
> 
> > IOV netlink (IOVNL) adds I/O Virtualization control support to a master
> > device (MD) netdev interface.  The MD (e.g. SR-IOV PF) will set/get
> > control settings on behalf of a slave netdevice (e.g. SR-IOV VF).  The
> > design allows for the case where master and slave are the
> > same netdev interface.
> 
> What is the reason for controlling the slave device through the master,
> rather than talking to the slave directly? The kernel always knows
> the master for each slave, so it seems to me that this information
> is redundant.

Not all devices have this relationship explicit (i.e. not all are pure
sr-iov devices).  If there's always a way to discover the master from
the device, then I agree we only need the slave.

> Is this new interface only for the case that you have a switch integrated
> in the NIC, or also for the case where you do an LLDP and EDP exchange
> with an adjacent bridge and put the device into VEPA mode?

It should be useful for both.  That's part of the reason for using
netlink, a userspace daemon running the VDP state machine (like lldpad)
can listen for these messages and see a set_port_profile request when
the user starts up a VM.

> > One control setting example is MAC/VLAN settings for a VF.  Another
> > example control setting is a port-profile for a VF.  A port-profile is an
> > identifier that defines policy-based settings on the network port
> > backing the VF.  The network port settings examples are VLAN membership,
> > QoS settings, and L2 security settings, typical of a data center network.
> > 
> > This patch adds the iovnl interface definitions and an iovnl module.
> 
> How does this relate to the existing DCB netlink interface? My feeling
> is that there is some overlap in how it would get used, and some parts
> that are very distinct. In particular, I'd guess that you'd want to
> be able to set DCB parameters for each VF, but not all DCB adapters
> would support SR-IOV.
> 
> Did you consider making this code an extension to the DCB interface
> instead of a separate one? What was the reason for your decision
> to keep it separate?

Well, aside from the fact that DCB and VDP have some low level
similarities in the PDU and they are both communication between
the host and the switch, they are doing different things.

> Also, do you expect your interface to be supported by dcbd/lldpad,
> or is there a good reason to create a new tool for iovnl?

lldpad would listen, I don't see why iproute2 couldn't send, and libvirt
will send as well.

> > + * @IOV_ATTR_IFNAME: interface name of master (PF) net device (NLA_NUL_STRING)
> > + * @IOV_ATTR_VF_IFNAME: interface name of target VF device (NLA_NUL_STRING)
> 
> As mentioned above, why not drop one of these, and just pass the VF's IFNAME?
> 
> > + * @IOV_ATTR_PORT_PROFILE: port-profile name to assign to device
> > + *   (NLA_NUL_STRING)
> 
> How does the definition of the port profile get into the NIC's switch?
> Is there any way to list the available port profiles?

The port profile is a concept external to the NIC's switch.  It's a value
that exists in the external physical layer 2 switching infrastructure.
So an admin knows this value and is informing the adjacent switch that a
new virutal interface is coming up and needs some particular port profile.

> > + * @IOV_ATTR_CLIENT_NAME: client name (NLA_NUL_STRING)
> > + * @IOV_ATTR_HOST_UUID: host UUID (NLA_NUL_STRING)
> 
> Can you elaborate more on what these do? Who is the 'client' and the 'host'
> in this case, and why do you need to identify them?
> 
> > + * @IOV_ATTR_MAC_ADDR: device station MAC address (NLA_U8[6])
> 
> Just one mac address? What happens if we want to assign multiple mac
> addresses to the VF later? Also, how is this defined specifically?
> Will a SIOCSIFHWADDR with a different MAC address on the VF fail
> later, or is this just the default value?
> 
> > + * @IOV_ATTR_VLAN: device 8021q VLAN ID (NLA_U16)
> 
> Same here: Should you be able to set multiple MAC addresses, or
> trunk mode? Can the VF override it?
> Also, for the new multi-channel VEPA, I'd guess that you also need
> to supply an 802.1ad S-VLAN ID.

Something like set_port_profile() would initiate the negotiation for the
s-vlan id for a particular channel, not sure it's needed as part of the
netlink interface or not.

thanks,
-chris
