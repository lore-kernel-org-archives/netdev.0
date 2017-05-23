From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Tue, 23 May 2017 11:33:49 -0500
Message-ID: <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210927.GR29447@lunn.ch>
 <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
 <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        f.fainelli@gmail.com, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40246 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933196AbdEWQdw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:33:52 -0400
In-Reply-To: <20170523160722.GC21169@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 11:07 AM, Andrew Lunn wrote:
>> > I will test that to see what happens, but I believe the real problem is that
>> > the at803x driver is lying when it says that the link is not okay.  I think
>> > the link is okay, and that's why I'm not getting any more interrupts.  I
>> > don't think I should have to drop interrupt support in my MAC driver because
>> > one specific PHY driver is broken.
> If it turns out the PHY hardware is broken, the phy driver itself can
> force it back to polling by setting phydev->irq to PHY_POLL in its
> probe() function.

I don't think the hardware is broken, I think the driver is broken.  The
patch that sets aneg_done to 0 should be reverted or restricted somehow.

Even the developer of the patch admits that if the warning message is
displayed, the link will appear to be up, but no packets will go through.
Perhaps that's because the driver is returning 0 instead of BMSR_ANEGCOMPLETE?

Would it be okay for the PHY driver to query a property from the device tree
directly (e.g. "qca,check-sgmii-link"), and if present, only then implement
the sgmii link check?  So in at803x_probe(), I would do something like this:

	if (device_property_read_bool(&phydev->mdio.dev,
					"qca,check-sgmii-link")
		priv->check_sgmii_link = true;

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
