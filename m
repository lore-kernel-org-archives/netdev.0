From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: CPU port VLAN configuration [Was: Re: [PATCH net] net: dsa: b53: Fix VLAN usage and how we treat CPU port]
Date: Thu, 17 Nov 2016 14:51:41 +1100
Message-ID: <87inrmzrua.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161115235815.25641-1-f.fainelli@gmail.com> <b5a41c19-b0a4-e5f8-23db-211c2d754f74@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch, knaack.h@gmx.de
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57098 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753260AbcKQDvs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 22:51:48 -0500
In-Reply-To: <b5a41c19-b0a4-e5f8-23db-211c2d754f74@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

>> We currently have a fundamental problem in how we treat the CPU port and
>> its VLAN membership. As soon as a second VLAN is configured to be
>> untagged, the CPU automatically becomes untagged for that VLAN as well,
>> and yet, we don't gracefully make sure that the CPU becomes tagged in
>> the other VLANs it could be a member of. This results in only one VLAN
>> being effectively usable from the CPU's perspective.
>> 
>> Instead of having some pretty complex logic which tries to maintain the
>> CPU port's default VLAN and its untagged properties, just do something
>> very simple which consists in neither altering the CPU port's PVID
>> settings, nor its untagged settings:
>> 
>> - whenever a VLAN is added, the CPU is automatically a member of this
>>   VLAN group, as a tagged member

mv88e6xxx currently does that.

>> - PVID settings for downstream ports do not alter the CPU port's PVID
>>   since it now is part of all VLANs in the system

If I'm not mistaken, the CPU port's PVID defaults to 0, since no other
value really makes sense...

>> This means that a typical example where e.g: LAN ports are in VLAN1, and
>> WAN port is in VLAN2, now require having two VLAN interfaces for the
>> host to properly terminate and send traffic from/to.
>
> Do you know how mv88e6xxx deals with this case? In the use case
> mentioned, what we have is this:
>
> - Ports0-3 -> VLAN1 (LAN segment)
> - Port4 -> WAN (WAN segment)
>
> With OpenWrt/swconfig you would typically have eth0.1 and eth0.2
> interfaces that would take care of terminating VLAN tags, this is the
> behavior that I am bringing back here because it is the only way you can
> have the downstream ports configured as untagged, and yet have proper
> segregation appear from the CPU port's perspective (unless you use
> Marvell/Broadcom/QCA tags, which we don't do yet here, but still).
>
> A more general issue that I am still working on is having the ability to
> control the CPU port's VLAN properties by configuring the master bridge
> device, since it is inherently "a view" (if multiple bridges, multiple
> views) of the CPU port of an Ethernet switch. The general idea would be
> that if you do:
>
> bridge vlan add vid 2 dev br0 self
>
> this calls down into the switch driver to actually configure VLAN ID 2
> on the CPU port to be tagged.

This is the good approach IMO.

As a side note, a good first thing to do here would be to fix the actual
behavior of switchdev calls from iproute2 commands. It doesn't respect
what the bridge's manpage describes in the VLAN section:

       self   the vlan is configured on the specified physical device.
              Required if the device is the bridge device.

       master the vlan is configured on the software bridge (default).

If I'm not mistaken, "bridge vlan add vid 2 dev lan2 [master]" currently
programs the hardware.

> I have a prototype of this that nearly works [1], except upon the
> initial bridge master device creation, since we have not had the ability
> to enslave port members yet, we are not able to propagate the bridge's
> default VLAN to the CPU port. More to come in the next weeks!

For this case, maybe the way to go would be to let DSA query the bridge
VLAN membership when enslaving a port and configure the CPU port
accordingly if needed.

Thanks,

        Vivien
