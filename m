From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: phy: keep track of the PHY suspend state
Date: Mon, 26 Jan 2015 21:55:46 -0800
Message-ID: <CAGVrzcb=VnA16NUjrmviGOR_Hgu=srUhng+295Wn_Dy6OGY_0Q@mail.gmail.com>
References: <1422318673-9418-1-git-send-email-f.fainelli@gmail.com>
 <1422318673-9418-4-git-send-email-f.fainelli@gmail.com> <BLUPR03MB3730BDE319193713AC9EA27F5320@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:44804 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbbA0F40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 00:56:26 -0500
Received: by mail-oi0-f46.google.com with SMTP id a141so10919929oig.5
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 21:56:26 -0800 (PST)
In-Reply-To: <BLUPR03MB3730BDE319193713AC9EA27F5320@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-01-26 18:43 GMT-08:00 fugang.duan@freescale.com
<fugang.duan@freescale.com>:
> From: Florian Fainelli <f.fainelli@gmail.com> Sent: Tuesday, January 27, 2015 8:31 AM
>> To: netdev@vger.kernel.org
>> Cc: davem@davemloft.net; s.hauer@pengutronix.de; Duan Fugang-B38611;
>> Florian Fainelli
>> Subject: [PATCH net-next 3/4] net: phy: keep track of the PHY suspend
>> state
>>
>> In order to avoid double calls to phydev->drv->suspend and resume, keep
>> track of whether the PHY has already been suspended as a consequence of a
>> successful call to phy_suspend(). We will use this in our MDIO bus
>> suspend/resume hooks to avoid a double suspend call.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/phy/phy_device.c | 22 ++++++++++++++++++----
>>  include/linux/phy.h          |  2 ++
>>  2 files changed, 20 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index 3fc91e89f5a5..c90cecc0fe15 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -699,6 +699,7 @@ int phy_suspend(struct phy_device *phydev)  {
>>       struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
>>       struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
>> +     int ret = 0;
>>
>>       /* If the device has WOL enabled, we cannot suspend the PHY */
>>       phy_ethtool_get_wol(phydev, &wol);
>> @@ -706,18 +707,31 @@ int phy_suspend(struct phy_device *phydev)
>>               return -EBUSY;
>>
>>       if (phydrv->suspend)
>> -             return phydrv->suspend(phydev);
>> -     return 0;
>> +             ret = phydrv->suspend(phydev);
>> +
>> +     if (ret)
>> +             return ret;
>> +
>> +     phydev->suspended = true;
>> +
>> +     return ret;
>>  }
>>  EXPORT_SYMBOL(phy_suspend);
>>
>>  int phy_resume(struct phy_device *phydev)  {
>>       struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
>> +     int ret;
>
> => int ret = 0;

Good catch, let me re-submit with your tags, thanks for testing!
-- 
Florian
