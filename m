From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 13:26:00 +0200
Message-ID: <201004211326.00974.arnd@arndb.de>
References: <C7F354F4.29CC8%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:53646 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab0DUL0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 07:26:20 -0400
In-Reply-To: <C7F354F4.29CC8%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 April 2010, Scott Feldman wrote:
> On 4/20/10 6:48 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> 
> > On Monday 19 April 2010, Scott Feldman wrote:
> > 
> >> IOV netlink (IOVNL) adds I/O Virtualization control support to a master
> >> device (MD) netdev interface.  The MD (e.g. SR-IOV PF) will set/get
> >> control settings on behalf of a slave netdevice (e.g. SR-IOV VF).  The
> >> design allows for the case where master and slave are the
> >> same netdev interface.
> > 
> > What is the reason for controlling the slave device through the master,
> > rather than talking to the slave directly? The kernel always knows
> > the master for each slave, so it seems to me that this information
> > is redundant.
> 
> The interface would allow talking to the slave directly. In fact, that's the
> example with enic port-profile in patch 2/2.  But, it would be nice not to
> rule out the case where the master proxies slave control and the master is
> under exclusively controlled by hypervisor.

Not sure I understand. Do you mean the case where this code runs in
the hypervisor (e.g. KVM), or a different scerario with the setup being
done in a guest driver?

So far, I have assumed that we would always do the setup on the host
side, which always has access to both the master, and a slave proxy.
In particular, your interface requires access to the slave AFAICT,
because otherwise the VF IFNAME does not have any significance.

Take the case where you use network namespaces and put the VF into
a separate namespace. With your interface, the PF is still in the
root namespace, but passing both interface names in this interface
won't help you because they are never visible in the same namespace
(e.g. both might be named eth0 in their respective containers).

> > Is this new interface only for the case that you have a switch integrated
> > in the NIC, or also for the case where you do an LLDP and EDP exchange
> > with an adjacent bridge and put the device into VEPA mode?
> 
> All of the above.  Basing this on netlink give us flexibility to work with
> user-space mgmt tools or directly with kernel netdev as in the enic case.
> Not trying to make assumptions about where (user-space, kernel) and by which
> entity sources or sinks the netlink msg.

ok.

> > Did you consider making this code an extension to the DCB interface
> > instead of a separate one? What was the reason for your decision
> > to keep it separate?
> 
> Considered it but DCB interface is well defined for DCB and it didn't seem
> right gluing on interfaces not specified within DCB.  I agree that there is
> some overlap in the sense that both interface are used to configure a netdev
> with some properties interesting for the data center, but the DCB interface
> is for local setting of the properties on the host whereas iovnl is about
> pushing the setting of those properties to the network for policy-based
> control.
>
> > Also, do you expect your interface to be supported by dcbd/lldpad,
> > or is there a good reason to create a new tool for iovnl?
> 
> Lldpad supporting this interface would seem right, for those cases where
> lldpad is responsible for configuring the netdev.

I believe we meant different things here, because I misunderstood the
intention of the code. My question was whether lldpad would send the
netlink messages to iovnl, but from what you and Chris write, the
real idea was that both lldpad and kernel/iovnl can receive the
same messages, right?
 
> >> + * @IOV_ATTR_CLIENT_NAME: client name (NLA_NUL_STRING)
> >> + * @IOV_ATTR_HOST_UUID: host UUID (NLA_NUL_STRING)
> > 
> > Can you elaborate more on what these do? Who is the 'client' and the 'host'
> > in this case, and why do you need to identify them?
> 
> Those are optional and useful, for example, by the network mgmt tool for
> presenting a view such as:
> 
>     - blade 1/2                     // know by host uuid
>         - vm-rhel5-eth0             // client name
>             - port-profile: xyz
> 
> Something like that.

Hmm, but how do they get from the device driver to the the network
management tool then? Also, these are similar to the attributes
that are passed in the 802.1Qbg VDP protocol, but not compatible.
If the idea is use the same netlink protocol for both your internal
representation and for the standard based protocol, I think we should
make them compatible.

Instead of a string identifying the port profile, this needs to pass
a four byte field for a VSI type (3 bytes) and VSI manager ID (1 byte).

There is also a UUID in VDP, but it identifies the guest, not the host,
so this is really confusing.

VDP also needs a list of MAC addresses and VLAN IDs (normally only
one of each), but that would be separate from what you tell the adapter,
see below: 

> >> + * @IOV_ATTR_MAC_ADDR: device station MAC address (NLA_U8[6])
> > 
> > Just one mac address? What happens if we want to assign multiple mac
> > addresses to the VF later? Also, how is this defined specifically?
> > Will a SIOCSIFHWADDR with a different MAC address on the VF fail
> > later, or is this just the default value?
> 
> Depends on how the VF wants to handle this.  For our use-case with enic we
> only need the port-profile op so I'm not sure what the best design is for
> mac+vlan on a VF.  Looking for advise from folks like yourself.  If it's not
> needed, let's scratch it.

In order to make VEPA work, it's absolutely required to impose a hard limit
on what MAC+VLAN IDs are visible to the VF, because the switch identifies
the guest by those and forwards any frames to/from that address according
to the VSI type.

However, I feel that we should strictly separate the steps of configuring
the adapter from talking to the switch. When we do the VDP association
in user land, we still need to set up the VLAN and MAC configuration for
the VF through a kernel interface. If we ignore the port profile stuff
for a moment, your netlink interface looks like a good fit for that.

Since it seems what you really want to do is to do the exchange with the
switch from here, maybe the hardware configuration part should be moved
the DCB interface?

	Arnd
