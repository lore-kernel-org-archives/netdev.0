From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Correct way to access MDIO bus - phy.c seems buggy
Date: Mon, 24 Aug 2015 17:15:42 -0700
Message-ID: <55DBB3AE.1000603@gmail.com>
References: <20150825000934.GK7557@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33122 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbHYASK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 20:18:10 -0400
Received: by pacti10 with SMTP id ti10so35345841pac.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 17:18:10 -0700 (PDT)
In-Reply-To: <20150825000934.GK7557@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/08/15 17:09, Russell King - ARM Linux wrote:
> Hi,
> 
> While trying to track down instability in the FEC driver, I've come
> across this question: what is the correct way to access the MDIO bus?
> 
> Is it via:
> 
> 	bus->write()
> 
> where 'bus' is a struct mii_bus, or should it be via mdiobus_write()?
> 
> What I'm seeing in the FEC driver is two thread trying to access the
> MDIO bus simultaneously - one thread trying to do a read, and another
> trying to do a write.  The result is far from pretty with the current
> mainline code, because we can end up re-initialising a spinlock while
> it's held by the fec interrupt handler.
> 
> I think the correct answer is that mdiobus_write() should be used,
> which makes drivers/net/phy/phy.c horribly buggy, as it bypasses the
> locking at the mdiobus level by doing this:

Right the correct way is to use mdiobus_write() which takes the bus mutex.

> 
> mmd_phy_indirect()
> {
> 	bus->write(bus, addr, MII_MMD_CTRL, devad);
> 	bus->write(bus, addr, MII_MMD_DATA, prtad);
> 	bus->write(bus, addr, MII_MMD_CTRL, (devad | MII_MMD_CTRL_NOINCR));
> }
> 
> However, it's not as simple as that, because the whole set of writes
> need to be done atomically.  The mdio bus lock needs to be taken around
> the internals of phy_read_mmd_indirect() and phy_write_mmd_indirect().

Well, yes, the bus lock should be grabbed at the beginning and released
at the end of this function at the very least, good catch.

> 
> This bug can be provoked by running an ethtool command which accesses
> the phy in a tight loop on a SMP platform.  For example:
> 
> 	while :; do ethtool --show-eee eth0; done
> 
> Patch will follow tomorrow.

Good thing is it looks like you have isolated the only cases where we do
not grab the MDIO bus mutexm the rest of the code, except
phy_mmd_{read,write}_indirect() looks correct.
-- 
Florian
