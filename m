From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Wed, 16 Nov 2011 17:16:04 -0800
Message-ID: <20111117011604.GA8683@mcarlson.broadcom.com>
References: <1321394453-21076-1-git-send-email-mcarlson@broadcom.com>
 <1321490078.2709.86.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3239 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754905Ab1KQBPX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 20:15:23 -0500
In-Reply-To: <1321490078.2709.86.camel@bwh-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2011 at 04:34:37PM -0800, Ben Hutchings wrote:
> On Tue, 2011-11-15 at 14:00 -0800, Matt Carlson wrote:
> > Translating between ethtool advertisement settings and MII
> > advertisements are common operations for ethernet drivers.  This patch
> > adds a set of helper functions that implements the conversion.  The
> > patch then modifies a couple of the drivers to use the new functions.
> 
> I like this, but:
> 
> [....]
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> [...]
> > @@ -4903,23 +4880,19 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
> >  	    (tp->phy_flags & TG3_PHYFLG_PARALLEL_DETECT)) {
> >  		/* do nothing, just check for link up at the end */
> >  	} else if (tp->link_config.autoneg == AUTONEG_ENABLE) {
> > -		u32 adv, new_adv;
> > +		u32 adv, newadv;
> >  
> >  		err |= tg3_readphy(tp, MII_ADVERTISE, &adv);
> > -		new_adv = adv & ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF |
> > -				  ADVERTISE_1000XPAUSE |
> > -				  ADVERTISE_1000XPSE_ASYM |
> > -				  ADVERTISE_SLCT);
> > -
> > -		new_adv |= tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
> > +		newadv = adv & ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF |
> > +				 ADVERTISE_1000XPAUSE |
> > +				 ADVERTISE_1000XPSE_ASYM |
> > +				 ADVERTISE_SLCT);
> 
> Not sure why you're renaming the variable here.

80 column character violations.  By eliminating the underscore, I can
*just* make it fit.

> > -		if (tp->link_config.advertising & ADVERTISED_1000baseT_Half)
> > -			new_adv |= ADVERTISE_1000XHALF;
> > -		if (tp->link_config.advertising & ADVERTISED_1000baseT_Full)
> > -			new_adv |= ADVERTISE_1000XFULL;
> > +		newadv |= tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
> > +		newadv |= ethtool_adv_to_mii_1000X(tp->link_config.advertising);
> 
> Doesn't this generate flow control advertising flags twice?  Can the
> link_config.flowctrl and link_config.advertising fields get out of
> synch?

The tg3 driver doesn't store flow control settings through the advertising
field.  I thought about changing the driver in that direction and
eliminating the tp->link_config.flowctrl field.  That would be a
separate patch though.

> [...]
> > --- a/include/linux/mii.h
> > +++ b/include/linux/mii.h
> > @@ -240,6 +240,171 @@ static inline unsigned int mii_duplex (unsigned int duplex_lock,
> >  }
> >  
> >  /**
> > + * ethtool_adv_to_mii_100bt
> > + * @ethadv: the ethtool advertisement settings
> > + *
> > + * A small helper function that translates ethtool advertisement
> > + * settings to phy autonegotiation advertisements for the
> > + * MII_ADVERTISE register.
> > + */
> > +static inline u32 ethtool_adv_to_mii_100bt(u32 ethadv)
> [...]
> > +static inline u32 mii_adv_to_ethtool_100bt(u32 adv)
> [...]
> > +static inline u32 ethtool_adv_to_mii_1000T(u32 ethadv)
> [...]
> > +static inline u32 mii_adv_to_ethtool_1000T(u32 adv)
> [...]
> > +#define mii_lpa_to_ethtool_100bt(lpa)	mii_adv_to_ethtool_100bt(lpa)
> 
> Shouldn't this additionally translate LPA_LPACK into ADVERTISED_Autoneg?

You mean, like this?

static inline u32 mii_lpa_to_ethtool_100bt(u32 lpa)
{
	u32 result = 0;

	if (lpa & LPA_LPACK)
		result |= ADVERTISED_Autoneg;

	return result | mii_adv_to_ethtool_100bt(lpa);
}

Yes, that looks like a better implementation.

> [...]
> > +static inline u32 mii_lpa_to_ethtool_1000T(u32 lpa)
> [...]
> > +static inline u32 ethtool_adv_to_mii_1000X(u32 ethadv)
> [...]
> > +static inline u32 mii_adv_to_ethtool_1000X(u32 adv)
> [...]
> 
> I'm not convinced about the naming convention for these.  Would it not
> make more sense to name them consistently by register name and signal
> type:
> 
> ethtool_adv_to_mii_adv_t
> mii_adv_to_ethtool_adv_t
> ethtool_adv_to_mii_ctrl1000_t
> mii_ctrl1000_to_ethtool_adv_t
> mii_lpa_to_ethtool_lpa_t
> mii_stat1000_to_ethtool_lpa_t
> ethtool_adv_to_mii_adv_x
> mii_adv_to_ethtool_adv_x

I don't have a strong preference either way.  I'll post the change along
with the above modification.

> Shouldn't there be mii_lpa_to_ethtool_1000X (or
> mii_lpa_to_ethtool_lpa_x)?

Yes.  You're right.  Should it just be a preprocessor definition that
points to mii_adv_to_ethtool_1000X()?

> Finally, do these need to be inline?

I don't have a strong preference here either.  Phy code tends to be
slower, so there isn't really a strong performance argument.  The
implementations don't seem to be so large to argue against it though.
Would you prefer they not be inlined?
