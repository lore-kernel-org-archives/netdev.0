From: Florian Fainelli <f.fainelli@gmail.com>
Subject: CPU port VLAN configuration [Was: Re: [PATCH net] net: dsa: b53: Fix
 VLAN usage and how we treat CPU port]
Date: Tue, 15 Nov 2016 16:12:16 -0800
Message-ID: <b5a41c19-b0a4-e5f8-23db-211c2d754f74@gmail.com>
References: <20161115235815.25641-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, knaack.h@gmx.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33611 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752263AbcKPAMT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:12:19 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so13016512pgd.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 16:12:19 -0800 (PST)
In-Reply-To: <20161115235815.25641-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Vivien,

On 11/15/2016 03:58 PM, Florian Fainelli wrote:
> We currently have a fundamental problem in how we treat the CPU port and
> its VLAN membership. As soon as a second VLAN is configured to be
> untagged, the CPU automatically becomes untagged for that VLAN as well,
> and yet, we don't gracefully make sure that the CPU becomes tagged in
> the other VLANs it could be a member of. This results in only one VLAN
> being effectively usable from the CPU's perspective.
> 
> Instead of having some pretty complex logic which tries to maintain the
> CPU port's default VLAN and its untagged properties, just do something
> very simple which consists in neither altering the CPU port's PVID
> settings, nor its untagged settings:
> 
> - whenever a VLAN is added, the CPU is automatically a member of this
>   VLAN group, as a tagged member
> - PVID settings for downstream ports do not alter the CPU port's PVID
>   since it now is part of all VLANs in the system
> 
> This means that a typical example where e.g: LAN ports are in VLAN1, and
> WAN port is in VLAN2, now require having two VLAN interfaces for the
> host to properly terminate and send traffic from/to.

Do you know how mv88e6xxx deals with this case? In the use case
mentioned, what we have is this:

- Ports0-3 -> VLAN1 (LAN segment)
- Port4 -> WAN (WAN segment)

With OpenWrt/swconfig you would typically have eth0.1 and eth0.2
interfaces that would take care of terminating VLAN tags, this is the
behavior that I am bringing back here because it is the only way you can
have the downstream ports configured as untagged, and yet have proper
segregation appear from the CPU port's perspective (unless you use
Marvell/Broadcom/QCA tags, which we don't do yet here, but still).

A more general issue that I am still working on is having the ability to
control the CPU port's VLAN properties by configuring the master bridge
device, since it is inherently "a view" (if multiple bridges, multiple
views) of the CPU port of an Ethernet switch. The general idea would be
that if you do:

bridge vlan add vid 2 dev br0 self

this calls down into the switch driver to actually configure VLAN ID 2
on the CPU port to be tagged.

I have a prototype of this that nearly works [1], except upon the
initial bridge master device creation, since we have not had the ability
to enslave port members yet, we are not able to propagate the bridge's
default VLAN to the CPU port. More to come in the next weeks!

[1]: https://github.com/ffainelli/linux/commits/bridge-master
-- 
Florian
