From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Fri, 2 Jun 2017 15:04:28 +0100
Message-ID: <20170602140427.GP22219@n2100.armlinux.org.uk>
References: <20170601122350.GA9282@lunn.ch>
 <20170601125132.GY22219@n2100.armlinux.org.uk>
 <20170601130527.GG9282@lunn.ch>
 <20170601130900.GA22219@n2100.armlinux.org.uk>
 <20170601131955.GH9282@lunn.ch>
 <20170601154735.GB22219@n2100.armlinux.org.uk>
 <20170601162417.GA14541@n2100.armlinux.org.uk>
 <23c238e0-2af8-3171-9986-af02e9c19129@gmail.com>
 <20170602124339.GO22219@n2100.armlinux.org.uk>
 <20170602134632.GI12261@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43978 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdFBOEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 10:04:50 -0400
Content-Disposition: inline
In-Reply-To: <20170602134632.GI12261@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 02, 2017 at 03:46:32PM +0200, Andrew Lunn wrote:
> On Fri, Jun 02, 2017 at 01:43:39PM +0100, Russell King - ARM Linux wrote:
> > We don't mark drivers as being C22 or C45, we rely on them matching
> > the IDs and/or the probe function making that decision, so it's a
> > tad difficult to make that decision at driver registration time.
> > 
> > We could reject an attempt to probe a C45 phy with a driver that
> > does not provide an aneg_done() pointer.
> 
> Just an idea.
> 
> We could make phy_read/phy_write look to see if the is_c45 flag is
> set. If so, return -EINVAL if the register being accessed does not
> have MII_ADDR_C45.
> 
> That should catch all these sort of problems.

I'm not so sure we want to do that.  Clause 45 PHYs are allowed to
respond to Clause 22 accesses, and MMD 29 contain a set of Clause 22
extension registers.

It seems it's possible for a PHY to support Clause 22 accesses along
with Clause 45 and MMD29 to extend the features beyond those supported
by the Clause 22 definition without providing the other MMDs.

Note that the Clause 45 definitions omit the 1000baseT registers
(MII_CTRL1000 / MII_STAT1000, or even registers that give the equivalent
information) from the 802.3 definition - this is why I've ended up
having to use the Marvell vendor specific 0xa016 register to determine
the PHY operating mode.  So, a conventional 10/100/1G PHY but with C45
support would still want to access C22 registers.

Hence, I don't think we can block C22 accesses in the way you're
suggesting.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
