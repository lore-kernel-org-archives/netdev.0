From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for enic dynamic vnics
Date: Thu, 29 Apr 2010 14:27:31 +0200
Message-ID: <201004291427.31540.arnd@arndb.de>
References: <C7FE070B.2CA5C%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:65336 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933199Ab0D3RWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:22:54 -0400
In-Reply-To: <C7FE070B.2CA5C%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 April 2010, Scott Feldman wrote:
> On 4/28/10 12:16 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> > On Wednesday 28 April 2010, Scott Feldman wrote:
> > 
> > But if the device is already passed to the guest using pass-thru or
> > containers, you would no longer to query or change the port profile,
> > because it is no longer visible in the host, right?
> 
> Drats, I made a mistake here.  You're right, in the pass-thru case the host
> lost control of the device, so we need another device to proxy the
> port-profile for the pass-thru device.  I had this in the second patch
> submission where I was trying to extend the SR-IOV if_link cmds to included
> port-profile, but that got mired down in the VF discussions.

ok
 
> > I assumed that this was a specific PF in your NIC,  but it now sounds like it
> > could be an internal device that is only visible in your firmware and not
> > exposed
> > as a network interface in Linux, right?
> 
> Yes, that's right.  Without going into implementation details, assume any
> enic has firmware with private mgmt channel to switch to do the equivalent
> of your base device->LLDP->switch.

Ok, now it all makes a *lot* more sense, thanks for the clarification!

For my curiosity, can you point to any documentation about what's actually
going on on the wire? Is it possible or planned to implement the same
protocol in Linux so you can do it with Cisco switches and cheap non-IOV
NICs?

> > Your firmware can obviously find out the right communication channel for
> > a associating a dynamic interface with the switch, but when this is implemnted
> > in software, we cannot generally know that and rely on getting access to the
> > interface that lets us talk to the switch. The information which interface
> > is getting associated however is completely useless to an implementation like
> > this.
> 
> So we're kind of back to where we were with iovnl.  We need to specify both
> devices, the base device that has access to the switch and the target device
> to associate the port-profile with.  Something like:
> 
>    ip port_profile set DEVICE [ base DEVICE ] [ { pre_associate |
>                                                   pre_associate_rr } ]
>                               { name PORT-PROFILE | vsi MGR:VTID:VER }
>                               mac LLADDR
>                               [ vlan VID ]
>                               [ host_uuid HOST_UUID ]
>                               [ client_uuid CLIENT_UUID ]
>                               [ client_name CLIENT_NAME ]
>    ip port_profile del DEVICE [ base DEVICE ] [ mac LLADDR [ vlan VID ] ]
>    ip port_profile show DEVICE [ base DEVICE ]
> 
> The netdev ops are (when netlink msg handled in kernel):
> 
>     ndo_set_port_profile(netdev *target, ...)
>     ndo_get_port_profile(netdev *target, ...)
>     ndo_del_port_profile(netdev *target, ...)
> 
> Base device is optional.  If base device is not given, then target device
> gets netdev ops.  If base device is given, then base device gets netdev ops
> and *target refers to target device.  This covers the following cases:

A bit more complicated than I had hoped for, but it sounds like the only
option that covers all corner cases so far.

> 1. Current enic where base == target since target can communicate directly
> with switch to associate port-profile.  This will not work for the enic
> pass-thru case as noted earlier.  We get:
> 
>     ip port_profile set eth0 name joes-garage ...
>
> And
> 
>     eth0:ndo_set_port_profile(NULL, ...)

Yes.
 
> 2. Future enic for pass-thru case where base != target.  We get:
> 
>     ip port_profile set eth1 base eth0 name joes-garage ...
> 
> And
> 
>     eth0:ndi_set_port_profile(eth1, ...)

Is eth1 the static device and eth0 the dynamic device in this scenario
or the other way round?

Wouldn't you still require access to both devices from the host root
network namespace here or do you just ignore the identifier for the
dynamic device here?
 
> 3. Future VEPA, we get:
> 
>     ip port_profile set eth11 base eth10 vsi 1:23456:7
> 
> And (here netlink msg handled in user-space):
> 
>     VDP msg sent on eth10 to set port-profile on eth11 using vis tuple
     
Yes. I'd prefer still requiring to pass the mac and vlan addresses in this
case, but seems workable.

> Does this work?  I want to get agreement before coding up patch attempt #4.

Seems ok for all I can see at this point, other than the complexity
that results from doing two network protocols through a single netlink
protocol. Maybe Jens and Chris can comment some more on this.

	Arnd
