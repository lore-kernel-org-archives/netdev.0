From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH] mdio_bus: Fix MDIO bus scanning in __mdiobus_register()
Date: Fri, 29 Apr 2016 04:10:49 +0200
Message-ID: <5722C2A9.7090308@denx.de>
References: <1461892155-10524-1-git-send-email-marex@denx.de> <5722BDBB.40606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S . Miller" <davem@davemloft.net>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:36325 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbcD2CKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 22:10:52 -0400
In-Reply-To: <5722BDBB.40606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2016 03:49 AM, Florian Fainelli wrote:
> Le 28/04/2016 18:09, Marek Vasut a =C3=A9crit :
>> Since commit b74766a0a0feeef5c779709cc5d109451c0d5b17 in linux-next,
>> ( phylib: don't return NULL from get_phy_device() ), phy_get_device(=
)
>> will return ERR_PTR(-ENODEV) instead of NULL if the PHY device ID is
>> all ones.
>>
>> This causes problem with stmmac driver and likely some other drivers
>> which call mdiobus_register(). I triggered this bug on SoCFPGA MCVEV=
K
>> board with linux-next 20160427 and 20160428. In case of the stmmac, =
if
>> there is no PHY node specified in the DT for the stmmac block, the s=
tmmac
>> driver ( drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c function
>> stmmac_mdio_register() ) will call mdiobus_register() , which will
>> register the MDIO bus and probe for the PHY.
>>
>> The mdiobus_register() resp. __mdiobus_register() iterates over all =
of
>> the addresses on the MDIO bus and calls mdiobus_scan() for each of t=
hem,
>> which invokes get_phy_device(). Before the aforementioned patch, the
>> mdiobus_scan() would return NULL if no PHY was found on a given addr=
ess
>> and mdiobus_register() would continue and try the next PHY address. =
Now,
>> mdiobus_scan() returns ERR_PTR(-ENODEV), which is caught by the
>> 'if (IS_ERR(phydev))' condition and the loop exits immediatelly if t=
he
>> PHY address does not contain PHY.
>>
>> Repair this by explicitly checking for the ERR_PTR(-ENODEV) and if t=
his
>> error comes around, continue with the next PHY address.
>>
>> Signed-off-by: Marek Vasut <marex@denx.de>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Dinh Nguyen <dinguyen@opensource.altera.com>
>> Cc: Florian Fainelli <f.fainelli@gmail.com>
>> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
>=20
> I had an exact same patch posted yesterday but not formally like you
> did, thanks!

Ah, my google-fu must be weak tonight. Thanks!

>> ---
>>  drivers/net/phy/mdio_bus.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> NOTE: I don't quite like this explicit check , but I don't have bett=
er idea now.
>>
>> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
>> index 499003ee..388f992 100644
>> --- a/drivers/net/phy/mdio_bus.c
>> +++ b/drivers/net/phy/mdio_bus.c
>> @@ -333,7 +333,7 @@ int __mdiobus_register(struct mii_bus *bus, stru=
ct module *owner)
>>  			struct phy_device *phydev;
>> =20
>>  			phydev =3D mdiobus_scan(bus, i);
>> -			if (IS_ERR(phydev)) {
>> +			if (IS_ERR(phydev) && (PTR_ERR(phydev) !=3D -ENODEV)) {
>>  				err =3D PTR_ERR(phydev);
>>  				goto error;
>>  			}
>>
>=20
>=20


--=20
Best regards,
Marek Vasut
