From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for
 enic dynamic vnics
Date: Wed, 28 Apr 2010 15:38:51 -0700
Message-ID: <C7FE070B.2CA5C%scofeldm@cisco.com>
References: <201004282116.14601.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:57082 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108Ab0D1Wjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 18:39:45 -0400
In-Reply-To: <201004282116.14601.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/10 12:16 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Wednesday 28 April 2010, Scott Feldman wrote:

>>> Passing just the slave device however would not work in the general case, as
>>> I tried to point out in the mail you replied to. If the slave interface is
>>> owned by a guest using PCI passthrough, or it sits below a stack of nested
>>> interfaces (vlan, bridge, tap, vhost, ...), it's impossible to know what
>>> interface is responsible for setting up the slave.
>> 
>> For port-profile, we want to pass the device that is to be "plugged-in" to
>> the network based on port-profile association.  This is the device that
>> gives basic connectivity to the guest interface, regardless of how the guest
>> interface is wired to the device.  It could be direct PCI pass-thru, macvtap
>> stack, some yet-to-be-invented kernel-bypass stack, etc.
> 
> But if the device is already passed to the guest using pass-thru or
> containers, you would no longer to query or change the port profile,
> because it is no longer visible in the host, right?

Drats, I made a mistake here.  You're right, in the pass-thru case the host
lost control of the device, so we need another device to proxy the
port-profile for the pass-thru device.  I had this in the second patch
submission where I was trying to extend the SR-IOV if_link cmds to included
port-profile, but that got mired down in the VF discussions.
  
>>> Note that you cannot perform the association
>>> through the slave interface itself because the remote switch would discard
>>> any traffic originating from an unassociated interface.
>> 
>> That's not a limitation of our device/switch.
> 
> This seems to contradict what you write above, at least when you drop the
> assumption that the protocol is implemented in the NIC firmware.
> The switch obviously does not care about the interface name in Linux or
> any of its data structures. What it cares about instead is the traffic on
> the wire and which of its ports this takes place on.
> 
> When you create a new dynamic enic device or a macvtap port but not assoicate
> it, the switch cannot allow this device to send or receive any traffic itself,
> as you write above (not 'plugged in'). The application (or firmware, for that
> matter) therefore needs to talk to the switch over an interface that is
> already
> associated. With VDP, this is the base device that a VEPA port is created
> from,
> i.e. the one that talks LLDP to the switch, i.e. the one that comes up at boot
> time when you have no virtualization and plug into a dumb switch.
> 
> I assumed that this was a specific PF in your NIC,  but it now sounds like it
> could be an internal device that is only visible in your firmware and not
> exposed
> as a network interface in Linux, right?

Yes, that's right.  Without going into implementation details, assume any
enic has firmware with private mgmt channel to switch to do the equivalent
of your base device->LLDP->switch.

> Your firmware can obviously find out the right communication channel for
> a associating a dynamic interface with the switch, but when this is implemnted
> in software, we cannot generally know that and rely on getting access to the
> interface that lets us talk to the switch. The information which interface
> is getting associated however is completely useless to an implementation like
> this.

So we're kind of back to where we were with iovnl.  We need to specify both
devices, the base device that has access to the switch and the target device
to associate the port-profile with.  Something like:

   ip port_profile set DEVICE [ base DEVICE ] [ { pre_associate |
                                                  pre_associate_rr } ]
                              { name PORT-PROFILE | vsi MGR:VTID:VER }
                              mac LLADDR
                              [ vlan VID ]
                              [ host_uuid HOST_UUID ]
                              [ client_uuid CLIENT_UUID ]
                              [ client_name CLIENT_NAME ]
   ip port_profile del DEVICE [ base DEVICE ] [ mac LLADDR [ vlan VID ] ]
   ip port_profile show DEVICE [ base DEVICE ]

The netdev ops are (when netlink msg handled in kernel):

    ndo_set_port_profile(netdev *target, ...)
    ndo_get_port_profile(netdev *target, ...)
    ndo_del_port_profile(netdev *target, ...)

Base device is optional.  If base device is not given, then target device
gets netdev ops.  If base device is given, then base device gets netdev ops
and *target refers to target device.  This covers the following cases:

1. Current enic where base == target since target can communicate directly
with switch to associate port-profile.  This will not work for the enic
pass-thru case as noted earlier.  We get:

    ip port_profile set eth0 name joes-garage ...

And

    eth0:ndo_set_port_profile(NULL, ...)

2. Future enic for pass-thru case where base != target.  We get:

    ip port_profile set eth1 base eth0 name joes-garage ...

And

    eth0:ndi_set_port_profile(eth1, ...)

3. Future VEPA, we get:

    ip port_profile set eth11 base eth10 vsi 1:23456:7

And (here netlink msg handled in user-space):

    VDP msg sent on eth10 to set port-profile on eth11 using vis tuple
    

Does this work?  I want to get agreement before coding up patch attempt #4.

-scott


