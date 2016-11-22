From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port configuration
Date: Tue, 22 Nov 2016 19:41:40 +0200
Message-ID: <20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@mellanox.com, idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35032 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755492AbcKVRvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 12:51:44 -0500
Content-Disposition: inline
In-Reply-To: <20161121190925.14530-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Nov 21, 2016 at 11:09:22AM -0800, Florian Fainelli wrote:
> Hi all,
> 
> This patch series allows using the bridge master interface to configure
> an Ethernet switch port's CPU/management port with different VLAN attributes than
> those of the bridge downstream ports/members.
> 
> Jiri, Ido, Andrew, Vivien, please review the impact on mlxsw and mv88e6xxx, I
> tested this with b53 and a mockup DSA driver.

We'll need to add a check in mlxsw and ignore any VLAN configuration for
the bridge device itself. Otherwise, any configuration done on br0 will
be propagated to all of its slaves, which is incorrect.

> 
> Open questions:
> 
> - if we have more than one bridge on top of a physical switch, the driver
>   should keep track of that and verify that we are not going to change
>   the CPU port VLAN attributes in a way that results in incompatible settings
>   to be applied
> 
> - if the default behavior is to have all VLANs associated with the CPU port
>   be ingressing/egressing tagged to the CPU, is this really useful?

First of all, I want to be sure that when we say "CPU port", we're
talking about the same thing. In mlxsw, the CPU port is a pipe between
the device and the host, through which all packets trapped to the host
go through. So, when a packet is trapped, the driver reads its Rx
descriptor, checks through which port it ingressed, resolves its netdev,
sets skb->dev accordingly and injects it to the Rx path via
netif_receive_skb(). The CPU port itself isn't represented using a
netdev.

Given the above, having VLAN filters (or STP) on the CPU port itself
isn't really helpful (we do have them for physical ports of course...).
So, mlxsw will not benefit from this patchset and if we've the same
concept of "CPU port", then I'm not sure why you don't just enable all
the VLANs on it?

Also, how are you going to set the VLAN filters for the CPU port when
you don't offload a bridge, but instead vlan devices between which you
route packets? You lose your abstraction of CPU port...

Thanks!
