From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 22 May 2017 14:50:37 -0700
Message-ID: <3b3184e6-78bf-6edd-af30-c7c4bce8da51@gmail.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210215.GQ29447@lunn.ch>
 <0528e1fa-2924-1286-578d-060419bfee49@gmail.com>
 <c57adeeb-b51c-5ac8-776e-1ead474f7b48@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32819 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934097AbdEVVul (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:50:41 -0400
Received: by mail-pf0-f180.google.com with SMTP id e193so94275572pfh.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:50:41 -0700 (PDT)
In-Reply-To: <c57adeeb-b51c-5ac8-776e-1ead474f7b48@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 02:19 PM, Timur Tabi wrote:
> On 05/22/2017 04:10 PM, Florian Fainelli wrote:
>> Even a module argument would be rejected. If you need platform/SoC
>> specific behavior propagated down to the PHY driver, several options exist:
>>
>> - pass an agreed upon value for phy_flags to of_phy_connect() see
>> drivers/net/ethernet/broadcom/tg3.c and
>> drivers/net/ethernet/broadcom/genet/bcmgenet.c for instance and update
>> the driver to act on that "flags" see drivers/net/phy/broadcom.c and
>> drivers/net/phy/bcm7xxx.c
> 
> Will this work on ACPI systems as well?

Provided you get a reference on the PHY dvice first, yes.

>  I call phy_connect_direct() instead
> of of_phy_connect().  I see some drivers set phydev->dev_flags before
> calling phy_connect_direct().

Setting phydev->dev_flags before calling phy_connect_direct() is okay
and will work here. The key thing is that you will need to get a PHY
device reference before, which would already be populated in your MDIO
bus's mdio_map array, see e.g: mdiobus_get_phy().

You can also set phydev->dev_flags *after* calling phy_connect_direct().
The only reason why it should be done before, is to guarantee that
phydrv::config_init would *see* the correct value there. If you need it
at a later time, like in config_aneg() or aneg_done(), setting it later
*might work*, but you'd have to trigger a auto-negotiation restart to
avoid races between phy_connect_direct() returning, and
phydrv::config_aneg() being called.

> 
> My concern is that this problem occurs only on an at8031 chip, so having my
> network driver passing an at8031-specific flag seems out of place.  What
> happens if, on some other board, a different PHY is used, and that flag
> means something else?

There needs to be an agreement on what the flags bits mean, and this
needs to be in a shared header file that other network drivers can
reference and where they can allocate their own bits if existing
functionality is not covered. The allocation of such flags is centered
around the perspective of the PHY driver.

Of course, this only works if you have a strict mapping between the
Ethernet MAC and the PHY, and if your MAC only uses the same PHY device
driver. If that's not the case, you need to make sure you don't pass a
phy_flags with bits set that could influence the behavior of another PHY
driver that would also try to do something with these phy_flags. Fairly
positive you can figure this out from your Ethernet MAC driver.

> 
>> - register a PHY fixup which is specific to the board/SoC, and have the
>> PHY fixup do whatever is necessary for your platform (like setting
>> specific registers)
> 
> Do you have an example of that?

You could have grepped for phy_register_fixup() but the best example I
can come up with is:

drivers/net/usb/lan78xx.c

and there are a lot more in arch/{arm,powerpc}/:

arch/arm/mach-davinci/board-dm644x-evm.c:
phy_register_fixup_for_uid(LXT971_PHY_ID, LXT971_PHY_MASK,
arch/arm/mach-imx/mach-imx6q.c:
phy_register_fixup_for_uid(PHY_ID_KSZ9021, MICREL_PHY_ID_MASK,
arch/arm/mach-imx/mach-imx6q.c:
phy_register_fixup_for_uid(PHY_ID_KSZ9031, MICREL_PHY_ID_MASK,
arch/arm/mach-imx/mach-imx6q.c:
phy_register_fixup_for_uid(PHY_ID_AR8031, 0xffffffef,
arch/arm/mach-imx/mach-imx6q.c:
phy_register_fixup_for_uid(PHY_ID_AR8035, 0xffffffef,
arch/arm/mach-imx/mach-imx6sx.c:
phy_register_fixup_for_uid(PHY_ID_AR8031, 0xffffffff,
arch/arm/mach-imx/mach-imx6ul.c:
phy_register_fixup_for_uid(PHY_ID_KSZ8081, MICREL_PHY_ID_MASK,
arch/arm/mach-imx/mach-imx7d.c:
phy_register_fixup_for_uid(PHY_ID_AR8031, 0xffffffff,
arch/arm/mach-imx/mach-imx7d.c:
phy_register_fixup_for_uid(PHY_ID_BCM54220, 0xffffffff,
arch/arm/mach-mxs/mach-mxs.c:
phy_register_fixup_for_uid(PHY_ID_KSZ8051, MICREL_PHY_ID_MASK,
arch/arm/mach-orion5x/dns323-setup.c:
phy_register_fixup_for_uid(MARVELL_PHY_ID_88E1118,
arch/powerpc/platforms/85xx/mpc85xx_mds.c:
phy_register_fixup_for_id(phy_id, mpc8568_fixup_125_clock);
arch/powerpc/platforms/85xx/mpc85xx_mds.c:
phy_register_fixup_for_id(phy_id, mpc8568_mds_phy_fixups);
arch/powerpc/platforms/85xx/mpc85xx_mds.c:
phy_register_fixup_for_id(phy_id, mpc8568_mds_phy_fixups);
-- 
Florian
