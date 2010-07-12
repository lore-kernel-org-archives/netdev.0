From: Brandon Philips <brandon@ifup.org>
Subject: Re: [PATCH] sky2: enable rx/tx in sky2_phy_reinit()
Date: Mon, 12 Jul 2010 04:04:10 -0700
Message-ID: <20100712110410.GA13679@chota.scz.novell.com>
References: <20100617022158.GA4135@jenkins.ifup.org>
 <AANLkTilzHA_URoZONtMf6A9-IRV4wA2ncr0b8Jff1ge9@mail.gmail.com>
 <20100623170008.GN14143@jenkins.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Mike McCormack <mikem@ring3k.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omnifario.us ([198.145.64.139]:58640 "EHLO ifup.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751793Ab0GLLNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jul 2010 07:13:53 -0400
Content-Disposition: inline
In-Reply-To: <20100623170008.GN14143@jenkins.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10:00 Wed 23 Jun 2010, Brandon Philips wrote:
> While testing this I just noticed that if I turn off speed autoneg the
> interface stops sending packets until I turn off pause autoneg too.
> 
> To illustrate start pinging some machine and run this:
> 
>  $ ethtool --change eth0 speed 100 duplex full autoneg off
>  # At this point the ping stops
> 
>  $ ethtool -A eth0 autoneg off
>  # Ping starts up again
> 
> When I tried capturing packets nothing was coming from the device.
> 
> 0ea065e52eb6a0f029b5fa5ed2f142be1b66a153 implemeneted the behaviour of
> having seperate pause and speed ethtool controls for sky2. Reverting
> this (see quick ugly revert below) obviously fixes the issue.
> 
> Any ideas on how to fix this in a proper way though?

Hello Stephen-

Any ideas on how to fix this properly?

Thanks,

	Brandon

> From 8de50faa1911933dc545f663a24f32d0caeea3b4 Mon Sep 17 00:00:00 2001
> From: Brandon Philips <brandon@ifup.org>
> Date: Wed, 23 Jun 2010 09:56:20 -0700
> Subject: [PATCH] sky2: revert "fix pause negotiation"
> 
> Revert 0ea065e52eb6a0f029b5fa5ed2f142be1b66a153
> ---
>  drivers/net/sky2.c |   31 ++++++++++++-------------------
>  drivers/net/sky2.h |    2 ++
>  2 files changed, 14 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 7985165..a638171 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -333,7 +333,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
>  	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
>  	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
>  
> -	if ( (sky2->flags & SKY2_FLAG_AUTO_SPEED) &&
> +	if (sky2->autoneg == AUTONEG_ENABLE &&
>  	    !(hw->flags & SKY2_HW_NEWER_PHY)) {
>  		u16 ectrl = gm_phy_read(hw, port, PHY_MARV_EXT_CTRL);
>  
> @@ -375,7 +375,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
>  			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO);
>  
>  			/* downshift on PHY 88E1112 and 88E1149 is changed */
> -			if ( (sky2->flags & SKY2_FLAG_AUTO_SPEED) &&
> +			if (sky2->autoneg == AUTONEG_ENABLE &&
>  			     (hw->flags & SKY2_HW_NEWER_PHY)) {
>  				/* set downshift counter to 3x and enable downshift */
>  				ctrl &= ~PHY_M_PC_DSC_MSK;
> @@ -420,7 +420,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
>  	adv = PHY_AN_CSMA;
>  	reg = 0;
>  
> -	if (sky2->flags & SKY2_FLAG_AUTO_SPEED) {
> +	if (sky2->autoneg == AUTONEG_ENABLE) {
>  		if (sky2_is_copper(hw)) {
>  			if (sky2->advertising & ADVERTISED_1000baseT_Full)
>  				ct1000 |= PHY_M_1000C_AFD;
> @@ -435,11 +435,14 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
>  			if (sky2->advertising & ADVERTISED_10baseT_Half)
>  				adv |= PHY_M_AN_10_HD;
>  
> +			adv |= copper_fc_adv[sky2->flow_mode];
>  		} else {	/* special defines for FIBER (88E1040S only) */
>  			if (sky2->advertising & ADVERTISED_1000baseT_Full)
>  				adv |= PHY_M_AN_1000X_AFD;
>  			if (sky2->advertising & ADVERTISED_1000baseT_Half)
>  				adv |= PHY_M_AN_1000X_AHD;
> +
> +			adv |= fiber_fc_adv[sky2->flow_mode];
>  		}
>  
>  		/* Restart Auto-negotiation */
> @@ -448,8 +451,8 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
>  		/* forced speed/duplex settings */
>  		ct1000 = PHY_M_1000C_MSE;
>  
> -		/* Disable auto update for duplex flow control and duplex */
> -		reg |= GM_GPCR_AU_DUP_DIS | GM_GPCR_AU_SPD_DIS;
> +		/* Disable auto update for duplex flow control and speed */
> +		reg |= GM_GPCR_AU_ALL_DIS;
>  
>  		switch (sky2->speed) {
>  		case SPEED_1000:
> @@ -467,15 +470,8 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
>  			ctrl |= PHY_CT_DUP_MD;
>  		} else if (sky2->speed < SPEED_1000)
>  			sky2->flow_mode = FC_NONE;
> -	}
>  
> -	if (sky2->flags & SKY2_FLAG_AUTO_PAUSE) {
> -		if (sky2_is_copper(hw))
> -			adv |= copper_fc_adv[sky2->flow_mode];
> -		else
> -			adv |= fiber_fc_adv[sky2->flow_mode];
> -	} else {
> -		reg |= GM_GPCR_AU_FCT_DIS;
> +
>   		reg |= gm_fc_disable[sky2->flow_mode];
>  
>  		/* Forward pause packets to GMAC? */
> @@ -620,8 +616,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
>  		/* no effect on Yukon-XL */
>  		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
>  
> -		if (!(sky2->flags & SKY2_FLAG_AUTO_SPEED) ||
> -		    sky2->speed == SPEED_100) {
> +		if (sky2->autoneg == AUTONEG_DISABLE || sky2->speed == SPEED_100) {
>  			/* turn on 100 Mbps LED (LED_LINK100) */
>  			ledover |= PHY_M_LED_MO_100(MO_LED_ON);
>  		}
> @@ -632,7 +627,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
>  	}
>  
>  	/* Enable phy interrupt on auto-negotiation complete (or link up) */
> -	if (sky2->flags & SKY2_FLAG_AUTO_SPEED)
> +	if (sky2->autoneg == AUTONEG_ENABLE)
>  		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_IS_AN_COMPL);
>  	else
>  		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
> @@ -688,9 +683,7 @@ static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
>  
>  	/* setup General Purpose Control Register */
>  	gma_write16(hw, port, GM_GP_CTRL,
> -		    GM_GPCR_FL_PASS | GM_GPCR_SPEED_100 |
> -		    GM_GPCR_AU_DUP_DIS | GM_GPCR_AU_FCT_DIS |
> -		    GM_GPCR_AU_SPD_DIS);
> +		    GM_GPCR_FL_PASS | GM_GPCR_SPEED_100 | GM_GPCR_AU_ALL_DIS);
>  
>  	if (hw->chip_id != CHIP_ID_YUKON_EC) {
>  		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
> diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
> index 084eff2..db0b2ad 100644
> --- a/drivers/net/sky2.h
> +++ b/drivers/net/sky2.h
> @@ -1755,6 +1755,7 @@ enum {
>  };
>  
>  #define GM_GPCR_SPEED_1000	(GM_GPCR_GIGS_ENA | GM_GPCR_SPEED_100)
> +#define GM_GPCR_AU_ALL_DIS	(GM_GPCR_AU_DUP_DIS | GM_GPCR_AU_FCT_DIS|GM_GPCR_AU_SPD_DIS)
>  
>  /*	GM_TX_CTRL			16 bit r/w	Transmit Control Register */
>  enum {
> @@ -2247,6 +2248,7 @@ struct sky2_port {
>  	u16		     speed;		/* SPEED_1000, SPEED_100, ... */
>  	u8		     wol;		/* WAKE_ bits */
>  	u8		     duplex;		/* DUPLEX_HALF, DUPLEX_FULL */
> +	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
>  	u16		     flags;
>  #define SKY2_FLAG_RX_CHECKSUM		0x0001
>  #define SKY2_FLAG_AUTO_SPEED		0x0002
> -- 
> 1.7.1
> 
