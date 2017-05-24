From: Matthias May <matthias.may@neratec.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 09:18:52 +0200
Message-ID: <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210927.GR29447@lunn.ch>
 <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
 <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        f.fainelli@gmail.com, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:57172 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932549AbdEXHYp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 03:24:45 -0400
In-Reply-To: <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/05/17 18:33, Timur Tabi wrote:
> On 05/23/2017 11:07 AM, Andrew Lunn wrote:
>>>> I will test that to see what happens, but I believe the real problem is that
>>>> the at803x driver is lying when it says that the link is not okay.  I think
>>>> the link is okay, and that's why I'm not getting any more interrupts.  I
>>>> don't think I should have to drop interrupt support in my MAC driver because
>>>> one specific PHY driver is broken.
>> If it turns out the PHY hardware is broken, the phy driver itself can
>> force it back to polling by setting phydev->irq to PHY_POLL in its
>> probe() function.
> 
> I don't think the hardware is broken, I think the driver is broken.  The
> patch that sets aneg_done to 0 should be reverted or restricted somehow.
> 
> Even the developer of the patch admits that if the warning message is
> displayed, the link will appear to be up, but no packets will go through.
> Perhaps that's because the driver is returning 0 instead of BMSR_ANEGCOMPLETE?
> 
> Would it be okay for the PHY driver to query a property from the device tree
> directly (e.g. "qca,check-sgmii-link"), and if present, only then implement
> the sgmii link check?  So in at803x_probe(), I would do something like this:
> 
> 	if (device_property_read_bool(&phydev->mdio.dev,
> 					"qca,check-sgmii-link")
> 		priv->check_sgmii_link = true;
> 

Zefir is currently on holiday and will probably get these emails when he gets back around 1. June

I think you missunderstand what "the link appears up but no packets go through means".
There are 2 pages which each reflect a side of the PHY:
* copper side
* SGMII side
Until the patch only the copper side was ever considered when reporting the state of the link.
This lead to the situation that the copper side was up (and the link reported up), but the SGMII side didn't come up.
It could well be a bad combination of CPU and the AR8031/33.
We know of at least 1 CPU (Freescale P1010) which has erratas for certain revisions regarding this.
If the SGMII side doesn't come, well no packets can go through.

With the patch: When the copper side is seen as up, it also checks if aneg of the SGMII link is done.
As far as i know SGMII can not be run without aneg, since it is always Gbit with aneg mandatory.
If SGMII aneg is not done, then, well aneg is not done and thus 0 is returned.

Internally we have this patch extended so we don't only report that aneg is not done but also reset the link.
Eventually aneg on the SGMII side can be completed and the link comes up.


Why do you think that frames are able to go through when aneg is reported as not done by the PHY?
Since aneg is mandatory for SGMII this can as well be seen as "link not up", not?

BR
Matthias
