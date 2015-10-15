From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] bcm63xx_enet: check 1000BASE-T advertisement configuration
Date: Thu, 15 Oct 2015 13:01:29 -0700
Message-ID: <56200619.3080801@gmail.com>
References: <562005D6.30204@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Simon Arlott <simon@fire.lp0.eu>, netdev <netdev@vger.kernel.org>,
	jogo@openwrt.org, mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34532 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbbJOUCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 16:02:01 -0400
Received: by payp3 with SMTP id p3so48872807pay.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 13:02:01 -0700 (PDT)
In-Reply-To: <562005D6.30204@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a few people,

On 15/10/15 13:00, Simon Arlott wrote:
> If a gigabit ethernet PHY is connected to a fast ethernet MAC,
> then it can detect 1000 support from the partner but not use it.
> 
> This results in a forced speed of 1000 and RX/TX failure.
> 
> Check for 1000BASE-T support and then check the advertisement
> configuration before setting the MAC speed to 1000mbit.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
> 
> ---
> The BCM63168 has a gigabit ethernet PHY for one of the ports but only
> a fast ethernet MAC as part of the enetsw interface.
> 
> The BCM63268 includes a configurable gigabit ethernet MAC with a
> different interface "gmac" (this is a MIPS chip and it's not the same
> interface as the ARM version).
> 
>  drivers/net/ethernet/broadcom/bcm63xx_enet.c | 33 ++++++++++++++++------------
>  1 file changed, 19 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> index a7f2cc3..4183c2a 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -2049,7 +2049,7 @@ static void swphy_poll_timer(unsigned long data)
>  
>  	for (i = 0; i < priv->num_ports; i++) {
>  		struct bcm63xx_enetsw_port *port;
> -		int val, j, up, advertise, lpa, lpa2, speed, duplex, media;
> +		int val, j, up, advertise, lpa, speed, duplex, media;
>  		int external_phy = bcm_enet_port_is_rgmii(i);
>  		u8 override;
>  
> @@ -2092,22 +2092,27 @@ static void swphy_poll_timer(unsigned long data)
>  		lpa = bcmenet_sw_mdio_read(priv, external_phy, port->phy_id,
>  					   MII_LPA);
>  
> -		lpa2 = bcmenet_sw_mdio_read(priv, external_phy, port->phy_id,
> -					    MII_STAT1000);
> -
>  		/* figure out media and duplex from advertise and LPA values */
>  		media = mii_nway_result(lpa & advertise);
>  		duplex = (media & ADVERTISE_FULL) ? 1 : 0;
> -		if (lpa2 & LPA_1000FULL)
> -			duplex = 1;
> -
> -		if (lpa2 & (LPA_1000FULL | LPA_1000HALF))
> -			speed = 1000;
> -		else {
> -			if (media & (ADVERTISE_100FULL | ADVERTISE_100HALF))
> -				speed = 100;
> -			else
> -				speed = 10;
> +
> +		if (media & (ADVERTISE_100FULL | ADVERTISE_100HALF))
> +			speed = 100;
> +		else
> +			speed = 10;
> +
> +		if (val & BMSR_ESTATEN) {
> +			advertise = bcmenet_sw_mdio_read(priv, external_phy,
> +						port->phy_id, MII_CTRL1000);
> +
> +			lpa = bcmenet_sw_mdio_read(priv, external_phy,
> +						port->phy_id, MII_STAT1000);
> +
> +			if (advertise & (ADVERTISE_1000FULL | ADVERTISE_1000HALF)
> +					&& lpa & (LPA_1000FULL | LPA_1000HALF)) {
> +				speed = 1000;
> +				duplex = (lpa & LPA_1000FULL);
> +			}
>  		}
>  
>  		dev_info(&priv->pdev->dev,
> 


-- 
Florian
