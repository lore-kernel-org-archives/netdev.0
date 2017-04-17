From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: phy: improve phylib correctness for
 non-autoneg settings
Date: Mon, 17 Apr 2017 13:25:29 -0400 (EDT)
Message-ID: <20170417.132529.470418098748897329.davem@davemloft.net>
References: <20170406100033.GA24671@n2100.armlinux.org.uk>
        <E1cygzj-0002rx-PW@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org
To: rmk+kernel@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752398AbdDQRZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:25:31 -0400
In-Reply-To: <E1cygzj-0002rx-PW@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>
Date: Thu, 13 Apr 2017 16:49:15 +0100

> phylib has some undesirable behaviour when forcing a link mode through
> ethtool.  phylib uses this code:
> 
> 	idx = phy_find_valid(phy_find_setting(phydev->speed, phydev->duplex),
> 			features);
> 
> to find an index in the settings table.  phy_find_setting() starts at
> index 0, and scans upwards looking for an exact speed and duplex match.
> When it doesn't find it, it returns MAX_NUM_SETTINGS - 1, which is
> 10baseT-Half duplex.
> 
> phy_find_valid() then scans from the point (and effectively only checks
> one entry) before bailing out, returning MAX_NUM_SETTINGS - 1.
> 
> phy_sanitize_settings() then sets ->speed to SPEED_10 and ->duplex to
> DUPLEX_HALF whether or not 10baseT-Half is supported or not.  This goes
> against all the comments against these functions, and 10baseT-Half may
> not even be supported by the hardware.
> 
> Rework these functions, introducing a new method of scanning the table.
> There are two modes of lookup that phylib wants: exact, and inexact.
> 
> - in exact mode, we return either an exact match or failure
> - in inexact mode, we return an exact match if it exists, a match at
>   the highest speed that is not greater than the requested speed
>   (ignoring duplex), or failing that, the lowest supported speed, or
>   failure.
> 
> The biggest difference is that we always check whether the entry is
> supported before further consideration, so all unsupported entries are
> not considered as candidates.
> 
> This results in arguably saner behaviour, better matches the comments,
> and is probably what users would expect.
> 
> This becomes important as ethernet speeds increase, PHYs exist which do
> not support the 10Mbit speeds, and half-duplex is likely to become
> obsolete - it's already not even an option on 10Gbit and faster links.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Applied to net-next
