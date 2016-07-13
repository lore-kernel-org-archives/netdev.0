From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3] Marvell phy: add fiber status check and configuration
 for some phys
Date: Wed, 13 Jul 2016 15:26:32 +0200
Message-ID: <20160713132632.GA6667@lunn.ch>
References: <20160404132552.GH21828@lunn.ch>
 <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
 <20160602145636.GA15379@lunn.ch>
 <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
 <20160712155739.GB31432@lunn.ch>
 <843ddd47-0394-88ee-39d9-f50bb7256225@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41725 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040AbcGMN06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 09:26:58 -0400
Content-Disposition: inline
In-Reply-To: <843ddd47-0394-88ee-39d9-f50bb7256225@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 11:14:21AM +0200, Charles-Antoine Couret wrote:


Hi Charles-Antoine
 
> >> +#define LPA_FIBER_1000HALF	0x40
> >> +#define LPA_FIBER_1000FULL	0x20
> >> +
> >> +#define LPA_PAUSE_FIBER		0x180
> >> +#define LPA_PAUSE_ASYM_FIBER	0x100
> >> +
> >> +#define ADVERTISE_FIBER_1000HALF	0x40
> >> +#define ADVERTISE_FIBER_1000FULL	0x20
> >> +
> >> +#define ADVERTISE_PAUSE_FIBER		0x180
> >> +#define ADVERTISE_PAUSE_ASYM_FIBER	0x100
> > 
> > Are these standardised anywhere? If they are following a standard,
> > they should be put into include/uapi/linux/mii.h.

> I don't find any standard about this, I think it should be Marvell specific.

O.K.

> >> +static inline u32 ethtool_adv_to_fiber_adv_t(u32 ethadv)
> >> +{
> >> +	u32 result = 0;
> >> +
> >> +	if (ethadv & ADVERTISED_1000baseT_Half)
> >> +		result |= ADVERTISE_FIBER_1000HALF;
> > 
> > Dumb question: Does 1000baseT_Half even make sense for fibre? Can you
> > do half duplex?  Would that not mean you have a single fibre, both
> > ends are using the same laser frequency, and you are doing some form
> > of CSMA/CD?
> 
> It's strange, I agree, but the register about that exists in the datasheet and the value is not fixed.
> In practice, I don't have a component to test this case correctly.

O.K, just implement it according to the data sheet.
 
> >>   *
> >>   * Generic status code does not detect Fiber correctly!
> >> @@ -906,12 +1070,17 @@ static int marvell_read_status(struct phy_device *phydev)
> >>  	int lpa;
> >>  	int lpagb;
> >>  	int status = 0;
> >> +	int page, fiber;
> >>  
> >> -	/* Update the link, but return if there
> >> +	/* Detect and update the link, but return if there
> >>  	 * was an error */
> >> -	err = genphy_update_link(phydev);
> >> -	if (err)
> >> -		return err;
> >> +	page = phy_read(phydev, MII_MARVELL_PHY_PAGE);
> >> +	if (page == MII_M1111_FIBER)
> >> +		fiber = 1;
> >> +	else
> >> +		fiber = 0;
> > 
> > This read is expensive, since the MDIO bus is slow. It would be better
> > just to pass fibre as a parameter.
> 
> But this function is used for other Marvell's phy, without fiber link for example.
> And this function should has only the struct phy_device as parameter.
> 
> I don't have idea to avoid that, without create a custom function for that which would be very similar to this function.
> Or used a phy_device field for that? I think it's awful idea...

So i would have

static int marvell_read_status_page(struct phy_device *phydev, int page)
{}

basically doing what you have above, but without the read.

static int marvell_read_status(struct phy_device *phydev)
{
	if (phydev->supported & SUPPORTED_FIBRE) {
		marvell_read_status_page(phydev, MII_M1111_FIBER);
	   	if (phydev->link)
	      	return;

	return marvell_read_status_page(phydev, MII_M1111_COPPER);
}

> > I think it would be better to look for SUPPORTED_FIBRE in
> > drv->features, rather than have two different functions.
> > 
> > In fact, i would do that in general, rather than add your _fibre()
> > functions.
> 
> So, you suggest to do that in genphy_* functions or create marvell_* functions with this condition?
> I'm agree with the second suggestion.

The second.

> 
> >> +
> >> +/* marvell_resume_fiber
> >> + *
> >> + * Some Marvell's phys have two modes: fiber and copper.
> >> + * Both need to be resumed
> >> + */
> >> +static int marvell_resume_fiber(struct phy_device *phydev)
> >> +{
> >> +	int err;
> >> +
> >> +	/* Resume the fiber mode first */
> >> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
> >> +	if (err < 0)
> >> +		goto error;
> >> +
> >> +	err = genphy_resume(phydev);
> >> +	if (err < 0)
> >> +		goto error;
> >> +
> >> +	/* Then, the copper link */
> >> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> >> +	if (err < 0)
> >> +		goto error;
> >> +
> >> +	return genphy_resume(phydev);
> > 
> > Should it be resumed twice? Or just once at the end?  Same question
> > for suspend.
> 
> I don't understand your question.

You call genphy_resume(phydev) twice. Once is sufficient.

    Andrew
