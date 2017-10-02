From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 0/5] net: dsa: LAG support
Date: Mon, 2 Oct 2017 09:50:23 +0300
Message-ID: <20171002065023.GA11832@shredder.mtl.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        idosch@mellanox.com, Woojung.Huh@microchip.com, john@phrozen.org,
        sean.wang@mediatek.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:37265 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750869AbdJBGuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 02:50:25 -0400
Content-Disposition: inline
In-Reply-To: <20171001194639.8647-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Sun, Oct 01, 2017 at 12:46:34PM -0700, Florian Fainelli wrote:
> Hi all,
> 
> This patch series is sent as RFC since I have only been able to test LAG
> with dsa-loop and not with real HW yet (that should be tomorrow). I also
> looked at how the Marvell DSDT API is defined for adding ports to "trunk"
> groups and the API proposed here should work there too. Can't speak about
> QCA, Mediatek or KSZ switches though.

Thanks for working on this. I've yet to look at the patches, but I
thought I'll mention a few issues we bumped into with LAG devices:

1) It is possible for users to stack devices on top of the LAG and only
then enslave your port. This means that the underlying driver might not
be aware of all the necessary configuration. It's quite a complicated
problem to solve properly, so we currently forbid enslavements to
devices that already have uppers.

There's also an issue with IP addresses and routes configured on top of
the LAG, but I hope to fix that soon. I don't think you support L3 in
DSA yet, so it shouldn't be a problem for you.

2) Similarly, you're no longer guaranteed to have the bridge do proper
clean up in case you pull a port out of a bridged LAG, so you'll need to
handle that. Any context you store for the bridge port needs to be
destroyed upon the removal of the last port from the LAG.

> Few open questions that may need solving now or later:
> 
> - on Broadcom switches, we should allow enslaving a port as a LAG group
>   member if its speed does not match that of the other members of the group
> 
> - not sure what to do with a switch fabric, naively, if adding two ports
>   of two distinct switches as a LAG group, we may have to propagate that
>   to "dsa" cross-chip interfaces as well

At least in mlxsw case, enslaving switch and non-switch ports to the
same LAG doesn't make sense. Any traffic routed by the switch will only
be load-balanced between the switch ports. One way to solve that is to
forbid such enslavements during NETDEV_PRECHANGEUPPER in case the lower
devices in the adjacency list of the LAG don't belong to the same
switch.

Note that such configurations are bound to fail anyway, as the
non-switch ports will not have `switchdev_ops` configured and thus fail
during __switchdev_port_obj_add() / __switchdev_port_attr_set().
