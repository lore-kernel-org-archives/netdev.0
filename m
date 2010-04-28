From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for enic dynamic vnics
Date: Wed, 28 Apr 2010 21:16:14 +0200
Message-ID: <201004282116.14601.arnd@arndb.de>
References: <C7FDCED5.2C841%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:61797 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263Ab0D1TQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:16:45 -0400
In-Reply-To: <C7FDCED5.2C841%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 April 2010, Scott Feldman wrote:
> > I thought you had meant that we can do the association of attached interfaces
> > through any interface, rather than tying it to the slave interface. While I'm
> > not sure I read your code correctly, it seems like you now only talk to the
> > slave interface, not to the master at all!
> > 
> > At least the check above should be 'if (enic_is_dynamic(enic)) return
> > -EOPNOTSUPP', not the other way round.
> > Moreover, if the netdev is the master here, you only allow a single slave,
> > which is not enough for larger setups (n > 1), though that could be a
> > limitation of your first version.
> 
> The code is correct.  I probably confused you with earlier patches trying to
> accommodate master/slave devices and you might have assumed enic was such a
> device.  But it's not.  For enic, there are two device IDs, let's call one
> "static" and the other "dynamic".  The only difference between the two is
> static enics load up fully ready to go just like a normal nic, whereas
> dynamic enics load up but can't yet pass traffic because they're not
> "plugged in" to the network.  To plug them in, you need to associate a
> port-profile.  The physical analogy is this: server admin tells network
> admin: plug my nic into a switch port with these characteristics.  Here, the
> port-profile describes those switch port characteristics.  Now, there is no
> master/slave relationship between static and dynamic enics.  There could be
> with a simple firmware update, but it's not there today.  Also, I want to
> point out that a single phys Cisco nic can be provisioned to expose many
> static and/or many dynamic enics to the host.  On the order of 100s.  The
> code above is to block port-profile association on static enics.  Static
> enics where already provisioned on the network when created so there is no
> need for a port-profile push from the host.

Ok, I see. I had asked this before, but never got a definite reply on this.

> > Passing just the slave device however would not work in the general case, as I
> > tried to point out in the mail you replied to. If the slave interface is owned
> > by a guest using PCI passthrough, or it sits below a stack of nested
> > interfaces
> > (vlan, bridge, tap, vhost, ...), it's impossible to know what interface is
> > responsible for setting up the slave.
> 
> For port-profile, we want to pass the device that is to be "plugged-in" to
> the network based on port-profile association.  This is the device that
> gives basic connectivity to the guest interface, regardless of how the guest
> interface is wired to the device.  It could be direct PCI pass-thru, macvtap
> stack, some yet-to-be-invented kernel-bypass stack, etc.

But if the device is already passed to the guest using pass-thru or containers,
you would no longer to query or change the port profile, because it is no
longer visible in the host, right?
 
> > Note that you cannot perform the association
> > through the slave interface itself because the remote switch would discard any
> > traffic originating from an unassociated interface.
> 
> That's not a limitation of our device/switch.

This seems to contradict what you write above, at least when you drop the
assumption that the protocol is implemented in the NIC firmware.
The switch obviously does not care about the interface name in Linux or
any of its data structures. What it cares about instead is the traffic on
the wire and which of its ports this takes place on.

When you create a new dynamic enic device or a macvtap port but not assoicate
it, the switch cannot allow this device to send or receive any traffic itself,
as you write above (not 'plugged in'). The application (or firmware, for that
matter) therefore needs to talk to the switch over an interface that is already
associated. With VDP, this is the base device that a VEPA port is created from,
i.e. the one that talks LLDP to the switch, i.e. the one that comes up at boot
time when you have no virtualization and plug into a dumb switch.

I assumed that this was a specific PF in your NIC,  but it now sounds like it
could be an internal device that is only visible in your firmware and not exposed
as a network interface in Linux, right?

Your firmware can obviously find out the right communication channel for
a associating a dynamic interface with the switch, but when this is implemnted
in software, we cannot generally know that and rely on getting access to the
interface that lets us talk to the switch. The information which interface
is getting associated however is completely useless to an implementation like
this.

	Arnd
