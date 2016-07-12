From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3] Marvell phy: add fiber status check and configuration
 for some phys
Date: Tue, 12 Jul 2016 17:57:39 +0200
Message-ID: <20160712155739.GB31432@lunn.ch>
References: <20160404132552.GH21828@lunn.ch>
 <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
 <20160602145636.GA15379@lunn.ch>
 <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40990 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819AbcGLP5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 11:57:42 -0400
Content-Disposition: inline
In-Reply-To: <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define LPA_FIBER_1000HALF	0x40
> +#define LPA_FIBER_1000FULL	0x20
> +
> +#define LPA_PAUSE_FIBER		0x180
> +#define LPA_PAUSE_ASYM_FIBER	0x100
> +
> +#define ADVERTISE_FIBER_1000HALF	0x40
> +#define ADVERTISE_FIBER_1000FULL	0x20
> +
> +#define ADVERTISE_PAUSE_FIBER		0x180
> +#define ADVERTISE_PAUSE_ASYM_FIBER	0x100

Are these standardised anywhere? If they are following a standard,
they should be put into include/uapi/linux/mii.h.

> +static inline u32 ethtool_adv_to_fiber_adv_t(u32 ethadv)
> +{
> +	u32 result = 0;
> +
> +	if (ethadv & ADVERTISED_1000baseT_Half)
> +		result |= ADVERTISE_FIBER_1000HALF;

Dumb question: Does 1000baseT_Half even make sense for fibre? Can you
do half duplex?  Would that not mean you have a single fibre, both
ends are using the same laser frequency, and you are doing some form
of CSMA/CD?

> +	if (ethadv & ADVERTISED_1000baseT_Full)
> +		result |= ADVERTISE_FIBER_1000FULL;
> +
> +	if ((ethadv & ADVERTISE_PAUSE_ASYM) && (ethadv & ADVERTISE_PAUSE_CAP))
> +		result |= LPA_PAUSE_ASYM_FIBER;
> +	else if (ethadv & ADVERTISE_PAUSE_CAP)
> +		result |= (ADVERTISE_PAUSE_FIBER
> +			   & (~ADVERTISE_PAUSE_ASYM_FIBER));
> +
> +	return result;
> +}

If these values are standardised, i think this function should be
moved into the generic code. If however, this is Marvell specific,
keep it here.

>   *
>   * Generic status code does not detect Fiber correctly!
> @@ -906,12 +1070,17 @@ static int marvell_read_status(struct phy_device *phydev)
>  	int lpa;
>  	int lpagb;
>  	int status = 0;
> +	int page, fiber;
>  
> -	/* Update the link, but return if there
> +	/* Detect and update the link, but return if there
>  	 * was an error */
> -	err = genphy_update_link(phydev);
> -	if (err)
> -		return err;
> +	page = phy_read(phydev, MII_MARVELL_PHY_PAGE);
> +	if (page == MII_M1111_FIBER)
> +		fiber = 1;
> +	else
> +		fiber = 0;

This read is expensive, since the MDIO bus is slow. It would be better
just to pass fibre as a parameter.

> +/* marvell_read_fiber_status
> + *
> + * Some Marvell's phys have two modes: fiber and copper.
> + * Both need status checked.
> + * Description:
> + *   First, check the fiber link and status.
> + *   If the fiber link is down, check the copper link and status which
> + *   will be the default value if both link are down.
> + */
> +static int marvell_read_fiber_status(struct phy_device *phydev)

The name is a bit confusing. I would probably use
marvell_read_copper_fiber_status() making it clear it reads both.

> +{
> +	int err;
> +
> +	/* Check the fiber mode first */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
> +	if (err < 0)
> +		goto error;
> +
> +	err = marvell_read_status(phydev);
> +	if (err < 0)
> +		goto error;
> +
> +	if (phydev->link) {
> +		phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +		return 0;
> +	}
> +
> +	/* If fiber link is down, check and save copper mode state */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +	if (err < 0)
> +		goto error;

There should be a big fat comment somewhere that after this function
the copper or fibre page is left selected, depending on which has
link.  There is a danger somebody misses this assumption and breaks
the code by unconditionally restoring to copper.

> +
> +	return marvell_read_status(phydev);
> +
> +error:
> +	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +	return err;
> +}
> +
> +/* marvell_suspend_fiber
> + *
> + * Some Marvell's phys have two modes: fiber and copper.
> + * Both need to be suspended
> + */
> +static int marvell_suspend_fiber(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	/* Suspend the fiber mode first */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
> +	if (err < 0)
> +		goto error;
> +
> +	err = genphy_suspend(phydev);
> +	if (err < 0)
> +		goto error;
> +
> +	/* Then, the copper link */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +	if (err < 0)
> +		goto error;
> +
> +	return genphy_suspend(phydev);
> +
> +error:
> +	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +	return err;
> +}

I think it would be better to look for SUPPORTED_FIBRE in
drv->features, rather than have two different functions.

In fact, i would do that in general, rather than add your _fibre()
functions.

> +
> +/* marvell_resume_fiber
> + *
> + * Some Marvell's phys have two modes: fiber and copper.
> + * Both need to be resumed
> + */
> +static int marvell_resume_fiber(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	/* Resume the fiber mode first */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
> +	if (err < 0)
> +		goto error;
> +
> +	err = genphy_resume(phydev);
> +	if (err < 0)
> +		goto error;
> +
> +	/* Then, the copper link */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +	if (err < 0)
> +		goto error;
> +
> +	return genphy_resume(phydev);

Should it be resumed twice? Or just once at the end?  Same question
for suspend.

> @@ -1130,6 +1416,11 @@ static u64 marvell_get_stat(struct phy_device *phydev, int i)
>  	int err, oldpage, val;
>  	u64 ret;
>  
> +	if (!(phydev->supported & SUPPORTED_FIBRE)) {
> +		if (strstr(marvell_hw_stats[i].string, "fiber"))
> +			return 0;

I think a better solution is for marvell_get_sset_count() to return 2
or 3 depending on phydev->supported & SUPPORTED_FIBRE.

   Andrew
