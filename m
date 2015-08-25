From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Correct way to access MDIO bus - phy.c seems buggy
Date: Tue, 25 Aug 2015 01:09:34 +0100
Message-ID: <20150825000934.GK7557@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:54047 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177AbbHYAJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 20:09:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While trying to track down instability in the FEC driver, I've come
across this question: what is the correct way to access the MDIO bus?

Is it via:

	bus->write()

where 'bus' is a struct mii_bus, or should it be via mdiobus_write()?

What I'm seeing in the FEC driver is two thread trying to access the
MDIO bus simultaneously - one thread trying to do a read, and another
trying to do a write.  The result is far from pretty with the current
mainline code, because we can end up re-initialising a spinlock while
it's held by the fec interrupt handler.

I think the correct answer is that mdiobus_write() should be used,
which makes drivers/net/phy/phy.c horribly buggy, as it bypasses the
locking at the mdiobus level by doing this:

mmd_phy_indirect()
{
	bus->write(bus, addr, MII_MMD_CTRL, devad);
	bus->write(bus, addr, MII_MMD_DATA, prtad);
	bus->write(bus, addr, MII_MMD_CTRL, (devad | MII_MMD_CTRL_NOINCR));
}

However, it's not as simple as that, because the whole set of writes
need to be done atomically.  The mdio bus lock needs to be taken around
the internals of phy_read_mmd_indirect() and phy_write_mmd_indirect().

This bug can be provoked by running an ethtool command which accesses
the phy in a tight loop on a SMP platform.  For example:

	while :; do ethtool --show-eee eth0; done

Patch will follow tomorrow.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
