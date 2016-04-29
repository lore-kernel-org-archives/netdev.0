From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Fri, 29 Apr 2016 14:40:53 +0200
Message-ID: <57235655.3030104@atmel.com>
References: <57222FCE.8050407@atmel.com>
 <20160428155556.GA8333@nathan3500-linux-VM> <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM> <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM> <20160428185932.GU29024@lunn.ch>
 <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
 <20160428212315.GC12753@lunn.ch>
 <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
 <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nathan Sullivan <nathan.sullivan@ni.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Josh Cartwright <joshc@ni.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 29/04/2016 14:25, Josh Cartwright a =E9crit :
> On Thu, Apr 28, 2016 at 07:34:59PM -0500, Josh Cartwright wrote:
>> On Thu, Apr 28, 2016 at 11:23:15PM +0200, Andrew Lunn wrote:
>>> On Thu, Apr 28, 2016 at 04:03:57PM -0500, Josh Cartwright wrote:
>>>> On Thu, Apr 28, 2016 at 08:59:32PM +0200, Andrew Lunn wrote:
>>>>> On Thu, Apr 28, 2016 at 01:55:27PM -0500, Nathan Sullivan wrote:
>>>>>> On Thu, Apr 28, 2016 at 08:43:03PM +0200, Andrew Lunn wrote:
>>>>>>>> I agree that is a valid fix for AT91, however it won't solve o=
ur problem, since
>>>>>>>> we have no children on the second ethernet MAC in our devices'=
 device trees. I'm
>>>>>>>> starting to feel like our second MAC shouldn't even really reg=
ister the MDIO bus
>>>>>>>> since it isn't being used - maybe adding a DT property to not =
have a bus is a
>>>>>>>> better option?
>>>>>>>
>>>>>>> status =3D "disabled"
>>>>>>>
>>>>>>> would be the unusual way.
>>>>>>>
>>>>>>>       Andrew
>>>>>>
>>>>>> Oh, sorry, I meant we use both MACs on Zynq, however the PHYs ar=
e on the MDIO
>>>>>> bus of the first MAC.  So, the second MAC is used for ethernet b=
ut not for MDIO,
>>>>>> and so it does not have any PHYs under its DT node.  It would be=
 nice if there
>>>>>> were a way to tell macb not to bother with MDIO for the second M=
AC, since that's
>>>>>> handled by the first MAC.
>>>>>
>>>>> Yes, exactly, add support for status =3D "disabled" in the mdio n=
ode.
>>>>
>>>> Unfortunately, the 'macb' doesn't have a "mdio node", or alternati=
vely:
>>>> the node representing the mdio bus is the same node which represen=
ts the
>>>> macb instance itself.  Setting 'status =3D "disabled"' on this nod=
e will
>>>> just prevent the probing of the macb instance.
>>>
>>> :-(
>>>
>>> It is very common to have an mdio node within the MAC node, for exa=
mple imx6sx-sdb.dtsi
>>
>> Okay, I think that makes sense.  I think, then, perhaps the solution=
 to
>> our problem is to:
>>
>>   1. Modify the macb driver to support an 'mdio' node. (And adjust t=
he
>>      binding document accordingly).  If the node is found, it's used=
 for
>>      of_mdiobus_register() w/o any of the manual scan madness.
>>   2. For backwards compatibility, in the case where an 'mdio' node d=
oes
>>      not exist, leave the existing behavior the way it is now
>>      (of_mdiobus_register() followed by manual scan) [perhaps warn o=
f
>>      deprecation as well?]
>>   3. Update binding docs to reflect the above.
>>
>> In this way, for our usecase, the 'status =3D "disabled"' in the new=
ly
>> created 'mdio' node isn't necessary.  It's sufficient for the node t=
o
>> exist and be empty.
>=20
> Here's a (only build tested) attempt at implementing a part of this. =
 I
> macb_mii_init() was getting complicated enough that I lifted out two
> helper functions for the dt/no-dt case.  Sweeping the in-tree
> devicetrees to update them to place phys under an 'mdio' node is stil=
l
> to be done.
>=20
>   Josh
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index eec3200..d843bc9 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -419,11 +419,62 @@ static int macb_mii_probe(struct net_device *de=
v)
>  	return 0;
>  }
> =20
> +static int macb_mii_of_init(struct macb *bp, struct device_node *np)
> +{
> +	struct device_node *mdio;
> +	int err, i;
> +
> +	mdio =3D of_get_child_by_name(np, "mdio");
> +	if (mdio)
> +		return of_mdiobus_register(bp->mii_bus, mdio);
> +
> +	dev_warn(&bp->pdev->dev,
> +		 "using deprecated PHY probing mechanism.  Please update device tr=
ee.");

Do we need to warn here?

Too bad I was not aware of that earlier, I even updated some of my DTs
recently with only a phy node without the "mdio" one as parents :-\


> +	/* try dt phy registration */
> +	err =3D of_mdiobus_register(bp->mii_bus, np);
> +	if (err)
> +		return err;
> +
> +	/* fallback to standard phy registration if no phy were
> +	 * found during dt phy registration
> +	 */
> +	if (!phy_find_first(bp->mii_bus)) {
> +		for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> +			struct phy_device *phydev;
> +
> +			phydev =3D mdiobus_scan(bp->mii_bus, i);
> +			if (IS_ERR(phydev)) {
> +				err =3D PTR_ERR(phydev);
> +				break;
> +			}
> +		}
> +
> +		if (err)
> +			goto err_out_unregister_bus;
> +	}
> +
> +	return err;
> +
> +err_out_unregister_bus:
> +	mdiobus_unregister(bp->mii_bus);
> +	return err;
> +}
> +
> +static int macb_mii_pdata_init(struct macb *bp,
> +			       struct macb_platform_data *pdata)
> +{
> +	if (pdata)
> +		bp->mii_bus->phy_mask =3D pdata->phy_mask;
> +
> +	return mdiobus_register(bp->mii_bus);
> +}
> +
>  static int macb_mii_init(struct macb *bp)
>  {
>  	struct macb_platform_data *pdata;
>  	struct device_node *np;
> -	int err =3D -ENXIO, i;
> +	int err =3D -ENXIO;
> =20
>  	/* Enable management port */
>  	macb_writel(bp, NCR, MACB_BIT(MPE));
> @@ -446,33 +497,10 @@ static int macb_mii_init(struct macb *bp)
>  	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
> =20
>  	np =3D bp->pdev->dev.of_node;
> -	if (np) {
> -		/* try dt phy registration */
> -		err =3D of_mdiobus_register(bp->mii_bus, np);
> -
> -		/* fallback to standard phy registration if no phy were
> -		 * found during dt phy registration
> -		 */
> -		if (!err && !phy_find_first(bp->mii_bus)) {
> -			for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> -				struct phy_device *phydev;
> -
> -				phydev =3D mdiobus_scan(bp->mii_bus, i);
> -				if (IS_ERR(phydev)) {
> -					err =3D PTR_ERR(phydev);
> -					break;
> -				}
> -			}
> -
> -			if (err)
> -				goto err_out_unregister_bus;
> -		}
> -	} else {
> -		if (pdata)
> -			bp->mii_bus->phy_mask =3D pdata->phy_mask;
> -
> -		err =3D mdiobus_register(bp->mii_bus);
> -	}
> +	if (np)
> +		err =3D macb_mii_of_init(bp, np);
> +	else
> +		err =3D macb_mii_pdata_init(bp, pdata);
> =20
>  	if (err)
>  		goto err_out_free_mdiobus;

I'm okay with this. Thanks for having taken the initiative to implement=
 it.

Bye,
--=20
Nicolas Ferre
