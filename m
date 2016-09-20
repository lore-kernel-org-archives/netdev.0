From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: DSA: Suspicious RCU usage (via rtnl_bridge_getlink)
Date: Tue, 20 Sep 2016 15:28:58 +0100
Message-ID: <20160920142858.GP1041@n2100.armlinux.org.uk>
References: <20160920102611.GO1041@n2100.armlinux.org.uk>
 <20160920133833.GD20638@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Andrew Lunn <andrew@lunn.ch>, Dave Miller <davem@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:45049 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752927AbcITO3K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:29:10 -0400
Content-Disposition: inline
In-Reply-To: <20160920133833.GD20638@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 03:38:33PM +0200, Andrew Lunn wrote:
> On Tue, Sep 20, 2016 at 11:26:12AM +0100, Russell King - ARM Linux wrote:
> > Issuing "bridge vlan show" on clearfog provokes a "suspicious RCU usage"
> > warning from the kernel (see below).
> > 
> > As it's illegal to schedule while holding the RCU read lock, there's the
> > possibility for this happening much earlier in the call sequence -
> > mv88e6xxx_port_vlan_dump() takes a mutex, and if that mutex were already
> > held, we'd schedule at that point.  The RCU read lock was taken by
> > rtnl_bridge_getlink().
> > 
> > It looks horrible to fix - mvmdio.c as well as DSA locking are involved.
> 
> Hi Russell
> 
> I would say this needs fixing higher up, in the bridge code. DSA has
> to be able to sleep, since the switch can be on any arbitrary bus,
> MDIO, SPI, etc. This will affect pure switchdev devices as well, since
> they often need to send a request to the switch and wait for a reply.

Hmm, okay, so looking around, other rtnl operations in there just
use for_each_netdev() or for_each_netdev_safe() without taking
any locks, apart from the rtnl mutex which we can see was already
taken.

Why does rtnl_bridge_getlink use RCU?  Can we drop the RCU read lock
and switch to using for_each_netdev() here?  Adding Dave and Eric,
as I guess they're more knowledgeable of the core rtnl code.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
