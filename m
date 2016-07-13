From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: Re: [PATCH v3] Marvell phy: add fiber status check and configuration
 for some phys
Date: Wed, 13 Jul 2016 11:14:21 +0200
Message-ID: <843ddd47-0394-88ee-39d9-f50bb7256225@nexvision.fr>
References: <20160404132552.GH21828@lunn.ch> <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
 <20160602145636.GA15379@lunn.ch>
 <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
 <20160712155739.GB31432@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5.mo3.mail-out.ovh.net ([87.98.178.36]:55748 "EHLO
	5.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcGMJXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 05:23:51 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id C71E21008795
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 11:14:24 +0200 (CEST)
In-Reply-To: <20160712155739.GB31432@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Le 12/07/2016 =E0 17:57, Andrew Lunn a =E9crit :
>> +#define LPA_FIBER_1000HALF	0x40
>> +#define LPA_FIBER_1000FULL	0x20
>> +
>> +#define LPA_PAUSE_FIBER		0x180
>> +#define LPA_PAUSE_ASYM_FIBER	0x100
>> +
>> +#define ADVERTISE_FIBER_1000HALF	0x40
>> +#define ADVERTISE_FIBER_1000FULL	0x20
>> +
>> +#define ADVERTISE_PAUSE_FIBER		0x180
>> +#define ADVERTISE_PAUSE_ASYM_FIBER	0x100
>=20
> Are these standardised anywhere? If they are following a standard,
> they should be put into include/uapi/linux/mii.h.

 [snip]

>> +	if (ethadv & ADVERTISED_1000baseT_Full)
>> +		result |=3D ADVERTISE_FIBER_1000FULL;
>> +
>> +	if ((ethadv & ADVERTISE_PAUSE_ASYM) && (ethadv & ADVERTISE_PAUSE_C=
AP))
>> +		result |=3D LPA_PAUSE_ASYM_FIBER;
>> +	else if (ethadv & ADVERTISE_PAUSE_CAP)
>> +		result |=3D (ADVERTISE_PAUSE_FIBER
>> +			   & (~ADVERTISE_PAUSE_ASYM_FIBER));
>> +
>> +	return result;
>> +}
>=20
> If these values are standardised, i think this function should be
> moved into the generic code. If however, this is Marvell specific,
> keep it here.
>=20

I don't find any standard about this, I think it should be Marvell spec=
ific.

>> +static inline u32 ethtool_adv_to_fiber_adv_t(u32 ethadv)
>> +{
>> +	u32 result =3D 0;
>> +
>> +	if (ethadv & ADVERTISED_1000baseT_Half)
>> +		result |=3D ADVERTISE_FIBER_1000HALF;
>=20
> Dumb question: Does 1000baseT_Half even make sense for fibre? Can you
> do half duplex?  Would that not mean you have a single fibre, both
> ends are using the same laser frequency, and you are doing some form
> of CSMA/CD?

It's strange, I agree, but the register about that exists in the datash=
eet and the value is not fixed.
In practice, I don't have a component to test this case correctly.
=20

>>   *
>>   * Generic status code does not detect Fiber correctly!
>> @@ -906,12 +1070,17 @@ static int marvell_read_status(struct phy_dev=
ice *phydev)
>>  	int lpa;
>>  	int lpagb;
>>  	int status =3D 0;
>> +	int page, fiber;
>> =20
>> -	/* Update the link, but return if there
>> +	/* Detect and update the link, but return if there
>>  	 * was an error */
>> -	err =3D genphy_update_link(phydev);
>> -	if (err)
>> -		return err;
>> +	page =3D phy_read(phydev, MII_MARVELL_PHY_PAGE);
>> +	if (page =3D=3D MII_M1111_FIBER)
>> +		fiber =3D 1;
>> +	else
>> +		fiber =3D 0;
>=20
> This read is expensive, since the MDIO bus is slow. It would be bette=
r
> just to pass fibre as a parameter.

But this function is used for other Marvell's phy, without fiber link f=
or example.
And this function should has only the struct phy_device as parameter.

I don't have idea to avoid that, without create a custom function for t=
hat which would be very similar to this function.
Or used a phy_device field for that? I think it's awful idea...

>> +/* marvell_read_fiber_status
>> + *
>> + * Some Marvell's phys have two modes: fiber and copper.
>> + * Both need status checked.
>> + * Description:
>> + *   First, check the fiber link and status.
>> + *   If the fiber link is down, check the copper link and status wh=
ich
>> + *   will be the default value if both link are down.
>> + */
>> +static int marvell_read_fiber_status(struct phy_device *phydev)
>=20
> The name is a bit confusing. I would probably use
> marvell_read_copper_fiber_status() making it clear it reads both.

You're right.

>> +
>> +	return marvell_read_status(phydev);
>> +
>> +error:
>> +	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
>> +	return err;
>> +}
>> +
>> +/* marvell_suspend_fiber
>> + *
>> + * Some Marvell's phys have two modes: fiber and copper.
>> + * Both need to be suspended
>> + */
>> +static int marvell_suspend_fiber(struct phy_device *phydev)
>> +{
>> +	int err;
>> +
>> +	/* Suspend the fiber mode first */
>> +	err =3D phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
>> +	if (err < 0)
>> +		goto error;
>> +
>> +	err =3D genphy_suspend(phydev);
>> +	if (err < 0)
>> +		goto error;
>> +
>> +	/* Then, the copper link */
>> +	err =3D phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
>> +	if (err < 0)
>> +		goto error;
>> +
>> +	return genphy_suspend(phydev);
>> +
>> +error:
>> +	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
>> +	return err;
>> +}
>=20
> I think it would be better to look for SUPPORTED_FIBRE in
> drv->features, rather than have two different functions.
>=20
> In fact, i would do that in general, rather than add your _fibre()
> functions.

So, you suggest to do that in genphy_* functions or create marvell_* fu=
nctions with this condition?
I'm agree with the second suggestion.

>> +
>> +/* marvell_resume_fiber
>> + *
>> + * Some Marvell's phys have two modes: fiber and copper.
>> + * Both need to be resumed
>> + */
>> +static int marvell_resume_fiber(struct phy_device *phydev)
>> +{
>> +	int err;
>> +
>> +	/* Resume the fiber mode first */
>> +	err =3D phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
>> +	if (err < 0)
>> +		goto error;
>> +
>> +	err =3D genphy_resume(phydev);
>> +	if (err < 0)
>> +		goto error;
>> +
>> +	/* Then, the copper link */
>> +	err =3D phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
>> +	if (err < 0)
>> +		goto error;
>> +
>> +	return genphy_resume(phydev);
>=20
> Should it be resumed twice? Or just once at the end?  Same question
> for suspend.

I don't understand your question.
Each interface are resumed / suspended once by these functions.

>=20
>> @@ -1130,6 +1416,11 @@ static u64 marvell_get_stat(struct phy_device=
 *phydev, int i)
>>  	int err, oldpage, val;
>>  	u64 ret;
>> =20
>> +	if (!(phydev->supported & SUPPORTED_FIBRE)) {
>> +		if (strstr(marvell_hw_stats[i].string, "fiber"))
>> +			return 0;
>=20
> I think a better solution is for marvell_get_sset_count() to return 2
> or 3 depending on phydev->supported & SUPPORTED_FIBRE.

Ok.

Thanks for all of your comments, I will fix that. However, I need some =
additional answers to do that entirely. :)

Regards.
Charles-Antoine Couret
