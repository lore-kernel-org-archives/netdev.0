From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH RFC] phylib: fix forced mode misbehaviour for aneg off case
Date: Fri, 22 Feb 2008 21:28:29 +0300
Message-ID: <20080222182829.GA7526@localhost.localdomain>
References: <20080222155524.GA6623@localhost.localdomain> <B1C15E4A-AA44-46E4-831A-698317E5F677@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:39762 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755073AbYBVS2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 13:28:31 -0500
Content-Disposition: inline
In-Reply-To: <B1C15E4A-AA44-46E4-831A-698317E5F677@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2008 at 11:40:04AM -0600, Andy Fleming wrote:
> 
> On Feb 22, 2008, at 09:55, Anton Vorontsov wrote:
> 
> >When user disabled autonegotiation via ethtool, and no link is  
> >detected,
> >phylib will place phy into forcing mode, and then will start calling
> >phy_force_reduction(). This will break user expectations. For example,
> >user asks for fixed speed 1000:
> >
> >ethtool -s eth0 autoneg off speed 1000
> >
> >Without link attached what will actually happen is:
> >
> >Trying 100/FULL
> >Trying 100/HALF
> >Trying 10/FULL
> >Trying 10/HALF
> >...
> 
> 
> The intent of phy_force_reduction() was to provide a fallback in case  
> the user unknowingly selects a speed that is not possible with the  
> current link partner.  For instance, if you try to select gigabit on  
> a 100MB link, it wouldn't work, but because of the way the code was  
> designed, the phylib will find a link configuration that works.

Yup, with this patch phylib will not able to find suitable speed for
PHYs without hw angeg capability. The question is: do we have such
hardware or this feature was actually unused and we'll not break
anything.

We can think out something for this case, but it will be still
incompatible with old behaviour. For example, for such setups
we might introduce kernel command line option, specifying
softaneg=eth0, that will force softaneg for PHYs without hw aneg
capability.

> However, I agree that it's not ideal to have the phylib spending a  
> lot of time looking for a link if there's not one there.  On the  
> other hand, why is the user trying to force the link to a certain  
> speed if there's no link?

To set up fixed speed for the link, thus to not re-setup it when link
is gone down... This is how all drivers [not using phylib] are
behaving.

> I'm not really opposed to it, though.
> 
> 
> >
> >This patch implements "software autonegotiation" that is equivalent to
> >current behaviour, but enabled only when hardware autonegotiation was
> >enabled and failed afterwards. With aneg disabled, phylib will not try
> >other link setups.
> >
> >Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> >---
> 
> 
> >
> >@@ -447,7 +451,8 @@ int phy_start_aneg(struct phy_device *phydev)
> > 			phydev->link_timeout = PHY_AN_TIMEOUT;
> > 		} else {
> > 			phydev->state = PHY_FORCING;
> >-			phydev->link_timeout = PHY_FORCE_TIMEOUT;
> >+			if (AUTONEG_SOFT == phydev->autoneg)
> >+				phydev->link_timeout = PHY_FORCE_TIMEOUT;
> > 		}
> > 	}
> 
> 
> I'm worried that phydev->link_timeout may end up being left in an  
> unknown state here.  Are you expecting it to be 0?  If so, I think it  
> would be best to set it to 0 in an if clause.

Um.. I though about it when I wrote this, and to me it seems we
really don't use link_timeout with AUTONEG_DISABLED...
We use it for PHY_AN, PHY_FORCING && AUTONEG_SOFT, and
PHY_RESUMING && AUTONEG_ENABLED.

But as a matter of safety, I probably indeed add link_timeout
zeroing...


Thanks,

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
