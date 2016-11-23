From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port configuration
Date: Wed, 23 Nov 2016 15:48:56 +0200
Message-ID: <20161123134856.cwk6sznnwa7p4xtq@splinter.mtl.com>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
 <20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
 <e9bbd22e-215f-a1fd-62ba-c0d33b255154@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@mellanox.com, idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35786 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S964835AbcKWNs7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 08:48:59 -0500
Content-Disposition: inline
In-Reply-To: <e9bbd22e-215f-a1fd-62ba-c0d33b255154@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Tue, Nov 22, 2016 at 09:56:30AM -0800, Florian Fainelli wrote:
> On 11/22/2016 09:41 AM, Ido Schimmel wrote:
> > Hi Florian,
> > 
> > On Mon, Nov 21, 2016 at 11:09:22AM -0800, Florian Fainelli wrote:
> >> Hi all,
> >>
> >> This patch series allows using the bridge master interface to configure
> >> an Ethernet switch port's CPU/management port with different VLAN attributes than
> >> those of the bridge downstream ports/members.
> >>
> >> Jiri, Ido, Andrew, Vivien, please review the impact on mlxsw and mv88e6xxx, I
> >> tested this with b53 and a mockup DSA driver.
> > 
> > We'll need to add a check in mlxsw and ignore any VLAN configuration for
> > the bridge device itself. Otherwise, any configuration done on br0 will
> > be propagated to all of its slaves, which is incorrect.
> > 
> >>
> >> Open questions:
> >>
> >> - if we have more than one bridge on top of a physical switch, the driver
> >>   should keep track of that and verify that we are not going to change
> >>   the CPU port VLAN attributes in a way that results in incompatible settings
> >>   to be applied
> >>
> >> - if the default behavior is to have all VLANs associated with the CPU port
> >>   be ingressing/egressing tagged to the CPU, is this really useful?
> > 
> > First of all, I want to be sure that when we say "CPU port", we're
> > talking about the same thing. In mlxsw, the CPU port is a pipe between
> > the device and the host, through which all packets trapped to the host
> > go through. So, when a packet is trapped, the driver reads its Rx
> > descriptor, checks through which port it ingressed, resolves its netdev,
> > sets skb->dev accordingly and injects it to the Rx path via
> > netif_receive_skb(). The CPU port itself isn't represented using a
> > netdev.
> 
> In the case of DSA, the CPU port is a normal Ethernet MAC driver, but in
> premise, this driver plus the DSA tag protocol hook do exactly the same
> things as you just describe.

Thanks for the detailed explanation! I also took the time to read
dsa.txt, however I still don't quite understand the motivation for
VLAN filtering on the CPU port. In which cases would you like to prevent
packets from going to the host due to their VLAN header? This change
would make sense to me if you only had a limited number of VLANs you
could enable on the CPU port, but from your response I understand that
this isn't the case.

FWIW, I don't have a problem with patches if they are useful for you,
I'm just trying to understand the use case. We can easily patch mlxsw to
ignore calls with orig_dev=br0.

Thanks!
