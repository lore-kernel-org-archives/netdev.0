From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for
 enic dynamic vnics
Date: Thu, 29 Apr 2010 07:32:26 -0700
Message-ID: <C7FEE68A.2CBEF%scofeldm@cisco.com>
References: <201004291427.31540.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>, Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:42641 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932867Ab0D3ROv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:14:51 -0400
In-Reply-To: <201004291427.31540.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/10 5:27 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Thursday 29 April 2010, Scott Feldman wrote:
>> Yes, that's right.  Without going into implementation details, assume any
>> enic has firmware with private mgmt channel to switch to do the equivalent
>> of your base device->LLDP->switch.
> 
> Ok, now it all makes a *lot* more sense, thanks for the clarification!
> 
> For my curiosity, can you point to any documentation about what's actually
> going on on the wire?

I don't believe those links are available at this time.

> Is it possible or planned to implement the same protocol in Linux so you
> can do it with Cisco switches and cheap non-IOV NICs?

That seems very possible from a technical standpoint.  I don't think the
port-profile netlink API we're specing out excludes that option.
 
>>    ip port_profile set DEVICE [ base DEVICE ] [ { pre_associate |
>>                                                   pre_associate_rr } ]
>>                               { name PORT-PROFILE | vsi MGR:VTID:VER }

BTW, I was meaning to ask: is there a way to role the vsi tuple and the
flags up into a single identifier, say a string like PORT-PROFILE?  I'm
asking because it seems awkward from an admin's perspective to know how to
construct a vsi tuple or to know what pre_associate_rr means. I have to
admit I didn't fully grok what pre_associate_rr means myself.  Even if there
was a simple local database to map named port-profiles to the underlying
{vsi tuple, flags}, that would bring us closer to a more consistent user
interface.  Is this possible?

>> 2. Future enic for pass-thru case where base != target.  We get:
>> 
>>     ip port_profile set eth1 base eth0 name joes-garage ...
>> 
>> And
>> 
>>     eth0:ndi_set_port_profile(eth1, ...)
> 
> Is eth1 the static device and eth0 the dynamic device in this scenario
> or the other way round?

eth0 is the static and eth1 is the dynamic.  So eth0 is the base device.
(The PF in SR-IOV parlance).
 
> Wouldn't you still require access to both devices from the host root
> network namespace here or do you just ignore the identifier for the
> dynamic device here?

The dynamic device is the one to apply the port-profile to (we'll, I should
say to apply to the dynamic's devices switch port).  So we need the dynamic
device identified.
  
>> 3. Future VEPA, we get:
>> 
>>     ip port_profile set eth11 base eth10 vsi 1:23456:7
>> 
>> And (here netlink msg handled in user-space):
>> 
>>     VDP msg sent on eth10 to set port-profile on eth11 using vis tuple
>      
> Yes. I'd prefer still requiring to pass the mac and vlan addresses in this
> case, but seems workable.

Sorry, I forgot the "..." in this use-case.  I didn't mean to exclude the
other params in the example cmd line.
 
>> Does this work?  I want to get agreement before coding up patch attempt #4.
> 
> Seems ok for all I can see at this point, other than the complexity
> that results from doing two network protocols through a single netlink
> protocol. Maybe Jens and Chris can comment some more on this.

Ok, thanks Arnd.  I'll start coding this up now, hedging that the design is
set before hearing back from Jens/Chris.

-scott

