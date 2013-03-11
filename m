From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is
 disabled
Date: Mon, 11 Mar 2013 21:31:10 +0000
Message-ID: <1363037470.2608.104.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
	 <1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130306.155323.344491888348815531.davem@davemloft.net>
	 <20130307102740.GB31105@redhat.com>
	 <1362671555.2936.10.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130307163537.GA21810@redhat.com>
	 <1362675261.2936.18.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130307183803.GB21810@redhat.com>
	 <1362683433.2936.41.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130311175809.GA22957@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<wfp5p@virginia.edu>, <jasowang@redhat.com>,
	<junchangwang@gmail.com>, <greearb@candelatech.com>,
	<ivecera@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38302 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab3CKVbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 17:31:14 -0400
In-Reply-To: <20130311175809.GA22957@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-11 at 18:58 +0100, Veaceslav Falico wrote:
[...]
> Anyway, you were right - the hardware does everything needed, and the
> driver also. The normal way (with autoneg on) would be for the driver to
> call mii_check_media() when it got the interrupt, which would verify if
> state/duplex has changed and report it.
> 
> However, with autoneg off, and thus mii->force_duplex == 1,
> mii_check_media() just returns 'nothing changed' back, without doing
> anything else. This way, any media change while in autoneg off (like
> up/down notifications) are completely hidden to the rest of the kernel.
> 
> I've modified the mii_check_media() to not verify for ->force_media and to
> get all the media settings from mii_ethtool_gset(), which would take care
> of whether autoneg is on or off and return the correct values. Tested,
> works ok - it sees when the cable is dis/connected, notifies bonding of
> speed/duplex changes, when enslaved.
> 
> Subject: [PATCH] mii: make mii_check_media() work with ->force_media == 1
> 
> mii_check_media() does nothing when ->force_media is set, and thus might
> miss media change events reported by the drivers if the autonegotiation is
> off.
> 
> Make mii_check_media() use mii_ethtool_gset() for getting media settings,
> which cleans the code a lot and works with both autoneg off and on. This
> allows us to catch link notifications even ->force_media on.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>   drivers/net/mii.c |   45 ++++++++++++---------------------------------
>   1 files changed, 12 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/net/mii.c b/drivers/net/mii.c
> index 4a99c39..2447487 100644
> --- a/drivers/net/mii.c
> +++ b/drivers/net/mii.c
> @@ -308,19 +308,14 @@ void mii_check_link (struct mii_if_info *mii)
>    * @init_media: OK to save duplex mode in @mii
>    *
>    * Returns 1 if the duplex mode changed, 0 if not.
> - * If the media type is forced, always returns 0.
>    */

Perhaps you could also correct the summary line and the description of
@init_media while you're doing this.

>   unsigned int mii_check_media (struct mii_if_info *mii,
>   			      unsigned int ok_to_print,
>   			      unsigned int init_media)
>   {
>   	unsigned int old_carrier, new_carrier;
> -	int advertise, lpa, media, duplex;
> -	int lpa2 = 0;
> -
> -	/* if forced media, go no further */
> -	if (mii->force_media)
> -		return 0; /* duplex did not change */
> +	int duplex;
> +	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
>   
>   	/* check current and old link status */
>   	old_carrier = netif_carrier_ok(mii->dev) ? 1 : 0;
> @@ -345,37 +340,21 @@ unsigned int mii_check_media (struct mii_if_info *mii,
>   	 */
>   	netif_carrier_on(mii->dev);
>   
> -	/* get MII advertise and LPA values */
> -	if ((!init_media) && (mii->advertising))
> -		advertise = mii->advertising;
> -	else {
> -		advertise = mii->mdio_read(mii->dev, mii->phy_id, MII_ADVERTISE);
> -		mii->advertising = advertise;

Now mii->advertising won't be initialised properly.

> -	}
> -	lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
> -	if (mii->supports_gmii)
> -		lpa2 = mii->mdio_read(mii->dev, mii->phy_id, MII_STAT1000);
> +	/*
> +	 * save the previous state of the duplex, mii_ethtool_gset()
> +	 * modifies it
> +	 */
> +	duplex = mii->full_duplex;
>   
> -	/* figure out media and duplex from advertise and LPA values */
> -	media = mii_nway_result(lpa & advertise);
> -	duplex = (media & ADVERTISE_FULL) ? 1 : 0;
> -	if (lpa2 & LPA_1000FULL)
> -		duplex = 1;
> +	mii_ethtool_gset(mii, &ecmd);
>   
>   	if (ok_to_print)
>   		netdev_info(mii->dev, "link up, %uMbps, %s-duplex, lpa 0x%04X\n",
> -			    lpa2 & (LPA_1000FULL | LPA_1000HALF) ? 1000 :
> -			    media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ?
> -			    100 : 10,
> -			    duplex ? "full" : "half",
> -			    lpa);
> -
> -	if ((init_media) || (mii->full_duplex != duplex)) {
> -		mii->full_duplex = duplex;
> -		return 1; /* duplex changed */
> -	}
> +			    ethtool_cmd_speed(&ecmd), 
> +			    ecmd.duplex == DUPLEX_FULL ? "full" : "half",
> +			    ecmd.lp_advertising);

This log message used to include the raw LPA register value, but you're
changing it to use ecmd.lp_advertising which has entirely different flag
values.  In order to get the raw LPA value out, I think you'll need to
delete mii_get_an() and split up mii_ethtool_gset() so you end up with:

static void __mii_check_media(struct mii_if_info *mii, struct ethtool_cmd *ecmd,
			      u16 *raw_lpa)
{
	*raw_lpa = 0;
	...
		mii->advertising = mii->mdio_read(mii, mii->phy_id, MII_ADVERTISE);
		ecmd->advertising |= mii_lpa_to_ethtool_lpa_t(mii->advertising);
	...
			*raw_lpa = mii->mdio_read(mii, mii->phy_id, MII_LPA);
			ecmd->lp_advertising =
				mii_lpa_to_ethtool_lpa_t(*raw_lpa);
	...
}

int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
{
	u16 raw_lpa;
	__mii_check_media(mii, ecmd, &raw_lpa);
	return 0;
}

unsigned int mii_check_media (struct mii_if_info *mii,
			      unsigned int ok_to_print,
			      unsigned int init_media)
{
	u16 raw_lpa;
	...
	__mii_check_media(mii, ecmd, &raw_lpa);
	...
	if (ok_to_print)
		netdev_info(mii->dev, "link up, %uMbps, %s-duplex, lpa 0x%04X\n",
			    ethtool_cmd_speed(&ecmd), 
			    ecmd.duplex == DUPLEX_FULL ? "full" : "half",
			    raw_lpa);
	...
}

> -	return 0; /* duplex did not change */
> +	return (init_media || (mii->full_duplex != duplex)) ? 1 : 0;
>   }
>   
>   /**

No need for parentheses or the ?: operator.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
