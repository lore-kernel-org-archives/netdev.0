From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v8 2/3] net: hisilicon: new hip04 MDIO driver
Date: Tue, 22 Apr 2014 16:30:07 +0200
Message-ID: <201404221630.07865.arnd@arndb.de>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org> <10652983.rXrAGMo8Yn@wuerfel> <535679A6.4020103@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, xuwei5@hisilicon.com,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>
To: zhangfei <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.131]:51570 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbaDVOaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 10:30:17 -0400
In-Reply-To: <535679A6.4020103@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 April 2014, zhangfei wrote:
> On 04/22/2014 04:22 PM, Arnd Bergmann wrote:
> 
> >> It's private register of the phy marvell 88e1512.
> >> To make it clearer using define instead.
> >> #define MII_MARVELL_PHY_PAGE    22
> >>
> >> The registers has been grouped into several pages, access register need
> >> choose which page first.
> >
> > You shouldn't touch the PHY private registers in the main driver though,
> > this should be purely handled by drivers/net/phy/marvell.c.
> >
> > I don't see support for 88e1512 there, only 88e1510 and lots of older
> > ones, but I assume it isn't hard to add.
> >
> 
> 88e1512 driver is already supported, same as 88e1510.
> #define MARVELL_PHY_ID_MASK             0xfffffff0
> So it should support 88e151x.
> 
> Reset is required here for get_phy_id, otherwise only 0 can be get.
> phy_device_create will not be called, and can not match any driver.
> 
> However in the experiment, it is found BMCR_RESET is not required in fact.
> Only hip04_mdio_write(bus, i, MII_MARVELL_PHY_PAGE, 0) has to be set.
> 88e151x registers are divided into pages.
> Generic MII registers is in page 0, including MII_PHYSID1 and MII_PHYSID2.
> Unfortunately the default page is not 0, so get_phy_id will fail.
> 
> So bus->reset still required to set the page to 0, prepared for get_phy_id.

But it means that the hip04_mdio driver potentially won't work if connected
to something other than a Marvell PHY.

I noticed that the marvell_of_reg_init() does this at init time:

saved_page = phy_read(phydev, MII_MARVELL_PHY_PAGE);
... /* perform init */
if (page_changed)
	phy_write(phydev, MII_MARVELL_PHY_PAGE, saved_page);

Is this a bug? Maybe it should always set page 0 when leaving
this function.

	Arnd
