From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 2/2] net: ethernet: nb8800: Fix RGMII TX clock delay setup
Date: Wed, 19 Jul 2017 18:17:03 +0100
Message-ID: <yw1xzic0qrcg.fsf@mansr.com>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
        <61b71d12-4e3a-edbe-1d69-c66e7cf46d8e@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:59144 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754121AbdGSRRH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 13:17:07 -0400
In-Reply-To: <61b71d12-4e3a-edbe-1d69-c66e7cf46d8e@sigmadesigns.com> (Marc
        Gonzalez's message of "Wed, 19 Jul 2017 17:33:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Gonzalez <marc_gonzalez@sigmadesigns.com> writes:

> According to commit e5f3a4a56ce2a707b2fb8ce37e4414dcac89c672
> ("Documentation: devicetree: clarify usage of the RGMII phy-modes")
> there are 4 RGMII phy-modes to handle:
>
> "rgmii" (RX and TX delays are added by the MAC when required)
> "rgmii-id" (RGMII with internal RX and TX delays provided by the PHY,
> 	the MAC should not add the RX or TX delays in this case)
> "rgmii-rxid" (RGMII with internal RX delay provided by the PHY,
> 	the MAC should not add an RX delay in this case)
> "rgmii-txid" (RGMII with internal TX delay provided by the PHY,
> 	the MAC should not add an TX delay in this case)
>
> Let the MAC handle TX clock delay for rgmii and rgmii-rxid.
>
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> ---
>  drivers/net/ethernet/aurora/nb8800.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index 041cfb7952f8..f3ed320eb4ad 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -609,7 +609,7 @@ static void nb8800_mac_config(struct net_device *dev)
>  		mac_mode |= HALF_DUPLEX;
>
>  	if (gigabit) {
> -		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
> +		if (phy_interface_is_rgmii(dev->phydev))
>  			mac_mode |= RGMII_MODE;
>
>  		mac_mode |= GMAC_MODE;

This is a separate issue, and the change is obviously correct.

> @@ -1268,11 +1268,13 @@ static int nb8800_tangox_init(struct net_device *dev)
>  		break;
>
>  	case PHY_INTERFACE_MODE_RGMII:
> -		pad_mode = PAD_MODE_RGMII;
> +	case PHY_INTERFACE_MODE_RGMII_RXID:
> +		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>  		break;
>
> +	case PHY_INTERFACE_MODE_RGMII_ID:
>  	case PHY_INTERFACE_MODE_RGMII_TXID:
> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
> +		pad_mode = PAD_MODE_RGMII;
>  		break;

Won't this just make it break in a different set of circumstances?

I think the only sane solution to this mess is to never configure the
MAC delay based on the existing phy-connection-type property.  If some
board requires this delay (because the PHY can't do it), a new property
should probably be introduced for that.

-- 
Måns Rullgård
