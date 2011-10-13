From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH v3 1/3] phylib: Convert MDIO and PHY Lib drivers to support 10G
Date: Thu, 13 Oct 2011 10:59:09 -0500
Message-ID: <48DF651F-324E-415E-A1E1-49E6F7237D42@freescale.com>
References: <1318516660-25452-1-git-send-email-afleming@freescale.com> <1318516660-25452-2-git-send-email-afleming@freescale.com> <1318520760.2745.6.camel@bwh-desktop>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:26109
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752455Ab1JMP7P convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 11:59:15 -0400
In-Reply-To: <1318520760.2745.6.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 13, 2011, at 10:46 AM, Ben Hutchings wrote:

> On Thu, 2011-10-13 at 09:37 -0500, Andy Fleming wrote:
>> 10G MDIO is a totally different protocol (clause 45 of 802.3).
>> Supporting this new protocol requires a couple of changes:
>>=20
>> * Add a new parameter to the mdiobus_read functions to specify the
>>  "device address" inside the PHY.
>> * Add a phy45_read/write function which takes advantage of that
>>  new parameter
>> * Convert all of the existing drivers to use the new format
>>=20
>> I created a new clause-45-specific read/write functions because:
>> 1) phy_read and phy_write are highly overloaded functions, and
>>   finding every instance which is actually the PHY Lib version
>>   was quite difficult
>> 2) Most code which invokes phy_read/phy_write inside PHY Lib is
>>   Clause-22-specific. None of the phy_read/phy_write invocations
>>   were useable on 10G PHYs
> [...]
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>> index 3cbda08..00f5cfe 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -322,7 +322,8 @@ int phy_mii_ioctl(struct phy_device *phydev,
>>=20
>> 	case SIOCGMIIREG:
>> 		mii_data->val_out =3D mdiobus_read(phydev->bus, mii_data->phy_id,
>> -						 mii_data->reg_num);
>> +						MDIO_DEVAD_NONE,
>> +						mii_data->reg_num);
>> 		break;
>>=20
>> 	case SIOCSMIIREG:
>> @@ -354,7 +355,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
>> 		}
>>=20
>> 		mdiobus_write(phydev->bus, mii_data->phy_id,
>> -			      mii_data->reg_num, val);
>> +				MDIO_DEVAD_NONE, mii_data->reg_num, val);
>>=20
>> 		if (mii_data->reg_num =3D=3D MII_BMCR &&
>> 		    val & BMCR_RESET &&
>=20
> What about c45 support here?  It's not terribly difficult to do=85

Ok, I'll take a look at that.

>=20
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devi=
ce.c
>> index 83a5a5a..22281d4 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -4,9 +4,11 @@
>>  * Framework for finding and configuring PHYs.
>>  * Also contains generic PHY driver
>>  *
>> + * 10G PHY Driver support mostly appropriated from drivers/net/mdio=
=2Ec
>> + *
>=20
> If you're saying you copied a significant amount of code, shouldn't y=
ou
> add the copyright notice too?

Ah, yeah, I'll fix that.


>=20
> [...]
>> @@ -640,7 +660,6 @@ static int genphy_setup_forced(struct phy_device=
 *phydev)
>> 	return err;
>> }
>>=20
>> -
>> /**
>>  * genphy_restart_aneg - Enable and Restart Autonegotiation
>>  * @phydev: target phy_device struct
>> @@ -665,7 +684,6 @@ int genphy_restart_aneg(struct phy_device *phyde=
v)
>> }
>> EXPORT_SYMBOL(genphy_restart_aneg);
>>=20
>> -
>> /**
>>  * genphy_config_aneg - restart auto-negotiation or write BMCR
>>  * @phydev: target phy_device struct
>> @@ -882,6 +900,7 @@ static int genphy_config_init(struct phy_device =
*phydev)
>>=20
>> 	return 0;
>> }
>> +
>> int genphy_suspend(struct phy_device *phydev)
>> {
>> 	int value;
>> @@ -1022,7 +1041,7 @@ static struct phy_driver genphy_driver =3D {
>> 	.read_status	=3D genphy_read_status,
>> 	.suspend	=3D genphy_suspend,
>> 	.resume		=3D genphy_resume,
>> -	.driver		=3D {.owner=3D THIS_MODULE, },
>> +	.driver		=3D {.owner =3D THIS_MODULE, },
>> };
>>=20
>> static int __init phy_init(void)
>> @@ -1035,7 +1054,12 @@ static int __init phy_init(void)
>>=20
>> 	rc =3D phy_driver_register(&genphy_driver);
>> 	if (rc)
>> -		mdio_bus_exit();
>> +		goto genphy_register_failed;
>> +
>> +	return rc;
>> +
>> +genphy_register_failed:
>> +	mdio_bus_exit();
>>=20
>> 	return rc;
>> }
>=20
> These changes are unrelated to c45.


Ah, yeah, these are residual from the 10G generic code.  I'll go ahead =
and forward those changes into the gen10g patch


>=20
>> diff --git a/include/linux/phy.h b/include/linux/phy.h
>> index 54fc413..ae1fdd8 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
> [...]
>> @@ -65,6 +66,7 @@ typedef enum {
>> 	PHY_INTERFACE_MODE_RGMII_TXID,
>> 	PHY_INTERFACE_MODE_RTBI,
>> 	PHY_INTERFACE_MODE_SMII,
>> +	PHY_INTERFACE_MODE_XGMII
>> } phy_interface_t;
> [...]
>=20
> XAUI, XFI?
>=20
> (Maybe the distinction doesn't matter in this context.)


Yeah, I'm not quite sure. The term "interface" is meant to convey inter=
face information needed by the PHY driver (and possibly the ethernet co=
ntroller). My setup is:

MAC->XGMII->XAUI->XGMII->PHY

Right now it's being used somewhat sketchily to distinguish 10G from no=
n-10G. I'd be fine with adding XAUI and XFI, I just don't know yet whet=
her it's relevant. I'm currently working with a sample size of 1 for wh=
at I've done, plus information gleaned from the spec.

Andy
