From: Pavel Fedin <p.fedin@samsung.com>
Subject: PING: [PATCH] net: smsc911x: Reset PHY during initialization
Date: Tue, 10 Nov 2015 09:36:24 +0300
Message-ID: <006801d11b82$1f5704b0$5e050e10$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	steve.glendinning@shawell.net
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.w1.samsung.com ([210.118.77.14]:42639 "EHLO
	mailout4.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbKJGg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 01:36:29 -0500
Content-language: ru
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hello! So, what should we do with this?

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Pavel
> Fedin
> Sent: Monday, November 02, 2015 10:19 AM
> To: 'David Miller'
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; steve.glendinning@shawell.net
> Subject: RE: [PATCH] net: smsc911x: Reset PHY during initialization
> 
>  Hello!
> 
> > > On certain hardware after software reboot the chip may get stuck and fail
> > > to reinitialize during reset. This can be fixed by ensuring that PHY is
> > > reset too.
> > >
> > > Old PHY resetting method required operational MDIO interface, therefore
> > > the chip should have been already set up. In order to be able to function
> > > during probe, it is changed to use PMT_CTRL register.
> > >
> > > The problem could be observed on SMDK5410 board.
> > >
> > > Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
> >
> > I'm pretty sure this is going to break the PHY loopback test.
> 
>  It's not (at least in normal situation), because first we do the test, and only then, if it
> fails, we reset the PHY. So, during
> normal operation of the driver, when loopback test succeeds at first attempt, we never attempt
> to reset the PHY. And, by the way, at
> least on my board this PHY reset did nothing useful, because after it loopback test still
> failed, all 100 times.
>  And, we don't use PHY reset anywhere outside of loopback test.
> 
> > This is such a tricky and fragile area to get right, therefore I
> > want you to specifically guard any change in how PHY reset is
> > done with tests against the specific chips that have the problem.
> 
>  Well, i could do one (or some combination) of the following, if you really want to:
>  a) Leave PHY reset inside loopback test as it is, but add a second routine and call it only
> before smsc911x_soft_reset().
>  b) Reset PHY only conditionally, using the following algorithm:
>     if smsc911x_soft_reset() {
>         /* NIC reset failed, kick the PHY and retry */
>         smsc911x_phy_reset()
>         if (smsc_911x_soft_reset())
>             return -ENODEV;
>     }
>  c) Do extra PHY reset only if some hint in device tree is specified (or the machine is known
> to have the problem)
> 
>  But, i dislike approach (a) for code duplication, because datasheet says that both reset
> methods are equivalent; i dislike approach
> (b) for actually being a hack; and i dislike (c) for adding extra stuff which seems to be not
> necessary. After all, what is wrong
> with just extra PHY reset before attempting to program anything? By the way, i test my patch
> with both software reboot and hardware
> reboot, and even powercycle. Everything is quite stable.
>  Well, it's up to you to decide. But i'd like to get the fix upstreamed somehow because from
> time to time we use these boards for
> tests, and it's quite annoiying to be unable to reboot them properly.
> 
> > Furthermore, I want you to test whether this has any negative
> > effects on the PHY loopback test.
> 
>  I did. I never disabled loopback test, so i actually discovered a problem (even two) with it.
> First, the problem was chip reset
> timeout. By increasing it to 300ms this problem seemed to be fixed, but loopback test started
> to fail. This was how i found and
> fixed crash with missing phy_disconnect(). I examined the code and discovered that upon
> loopback test failure we reset the PHY and
> retry. But in my case this PHY reset never did the right thing, and all loopback attempts
> (10x10 IIRC) were failing.
>  Some comments in the code gave me a clue that the main NIC can misbehave on reset if e.g. PHY
> is in powerdown state. I printed
> value of its control register and discovered that it was not the case. But then i discovered
> that we actually never try to reset the
> PHY before doing anything. Also, while studying the datasheed i discovered that there is a
> shorthand for resetting PHY without MDIO
> bus set up, but our driver doesn't use it, preferring MDIO method instead, which already
> requires operational NIC.
>  So, i suggested that PHY is just not being reset when board is rebooted by software. I wrote
> the patch and it worked. I verified it
> by reverting my previous NIC reset timeout increase, and it continued to work. After this
> loopback test on my board passes at first
> attempt.
> 
> Kind regards,
> Pavel Fedin
> Expert Engineer
> Samsung Electronics Research center Russia
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
