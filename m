From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: Re: [PATCH v3] Marvell phy: add fiber status check and configuration
 for some phys
Date: Wed, 13 Jul 2016 15:46:46 +0200
Message-ID: <cbe62b8d-3796-a514-9783-c1ddae5711a6@nexvision.fr>
References: <20160404132552.GH21828@lunn.ch> <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
 <20160602145636.GA15379@lunn.ch>
 <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
 <20160712155739.GB31432@lunn.ch>
 <843ddd47-0394-88ee-39d9-f50bb7256225@nexvision.fr>
 <20160713132632.GA6667@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 17.mo3.mail-out.ovh.net ([87.98.178.58]:38048 "EHLO
	17.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbcGMNrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 09:47:15 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 2C7A61024522
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 15:46:49 +0200 (CEST)
In-Reply-To: <20160713132632.GA6667@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Le 13/07/2016 =E0 15:26, Andrew Lunn a =E9crit :
>>>>   *
>>>>   * Generic status code does not detect Fiber correctly!
>>>> @@ -906,12 +1070,17 @@ static int marvell_read_status(struct phy_d=
evice *phydev)
>>>>  	int lpa;
>>>>  	int lpagb;
>>>>  	int status =3D 0;
>>>> +	int page, fiber;
>>>> =20
>>>> -	/* Update the link, but return if there
>>>> +	/* Detect and update the link, but return if there
>>>>  	 * was an error */
>>>> -	err =3D genphy_update_link(phydev);
>>>> -	if (err)
>>>> -		return err;
>>>> +	page =3D phy_read(phydev, MII_MARVELL_PHY_PAGE);
>>>> +	if (page =3D=3D MII_M1111_FIBER)
>>>> +		fiber =3D 1;
>>>> +	else
>>>> +		fiber =3D 0;
>>>
>>> This read is expensive, since the MDIO bus is slow. It would be bet=
ter
>>> just to pass fibre as a parameter.
>>
>> But this function is used for other Marvell's phy, without fiber lin=
k for example.
>> And this function should has only the struct phy_device as parameter=
=2E
>>
>> I don't have idea to avoid that, without create a custom function fo=
r that which would be very similar to this function.
>> Or used a phy_device field for that? I think it's awful idea...
>=20
> So i would have
>=20
> static int marvell_read_status_page(struct phy_device *phydev, int pa=
ge)
> {}
>=20
> basically doing what you have above, but without the read.
>=20
> static int marvell_read_status(struct phy_device *phydev)
> {
> 	if (phydev->supported & SUPPORTED_FIBRE) {
> 		marvell_read_status_page(phydev, MII_M1111_FIBER);
> 	   	if (phydev->link)
> 	      	return;
>=20
> 	return marvell_read_status_page(phydev, MII_M1111_COPPER);
> }

Oh I see. Thank you!

>=20
>>> I think it would be better to look for SUPPORTED_FIBRE in
>>> drv->features, rather than have two different functions.
>>>
>>> In fact, i would do that in general, rather than add your _fibre()
>>> functions.
>>
>> So, you suggest to do that in genphy_* functions or create marvell_*=
 functions with this condition?
>> I'm agree with the second suggestion.
>=20
> The second.

I'm working on this.
It's done for _resume and _suspend. It will be done for _status.

But, for aneg or ethtool concerned, I think adding these functions is b=
etter.

>>>> +
>>>> +/* marvell_resume_fiber
>>>> + *
>>>> + * Some Marvell's phys have two modes: fiber and copper.
>>>> + * Both need to be resumed
>>>> + */
>>>> +static int marvell_resume_fiber(struct phy_device *phydev)
>>>> +{
>>>> +	int err;
>>>> +
>>>> +	/* Resume the fiber mode first */
>>>> +	err =3D phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER)=
;
>>>> +	if (err < 0)
>>>> +		goto error;
>>>> +
>>>> +	err =3D genphy_resume(phydev);
>>>> +	if (err < 0)
>>>> +		goto error;
>>>> +
>>>> +	/* Then, the copper link */
>>>> +	err =3D phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER=
);
>>>> +	if (err < 0)
>>>> +		goto error;
>>>> +
>>>> +	return genphy_resume(phydev);
>>>
>>> Should it be resumed twice? Or just once at the end?  Same question
>>> for suspend.
>>
>> I don't understand your question.
>=20
> You call genphy_resume(phydev) twice. Once is sufficient.

Yes, but it's normal because each interface could be suspended or resum=
ed independently.
genphy_* functions use BMCR register which are identical between fiber =
and copper link. But each link has its own register to change.

Thank you.
Regards.

Charles-Antoine Couret
