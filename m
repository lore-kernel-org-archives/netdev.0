From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net] net: phy: marvell: Limit errata to 88m1101
Date: Tue, 23 May 2017 11:55:22 -0700
Message-ID: <499064b3-3157-2a3e-ef74-b49b6a5bd168@gmail.com>
References: <1495554553-21118-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32775 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763775AbdEWSz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 14:55:28 -0400
Received: by mail-wm0-f65.google.com with SMTP id b84so25766763wmh.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 11:55:27 -0700 (PDT)
In-Reply-To: <1495554553-21118-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 08:49 AM, Andrew Lunn wrote:
> The 88m1101 has an errata when configuring autoneg. However, it was
> being applied to many other Marvell PHYs as well. Limit its scope to
> just the 88m1101.
> 
> Fixes: 76884679c644 ("phylib: Add support for Marvell 88e1111S and 88e1145")
> Reported-by: Daniel Walker <danielwa@cisco.com>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Acked-by: Harini Katakam <harinik@xilinx.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

it would be great to be put proper defines (at least for the registers)
for what this work around accomplishes, anyone with the datasheet?

> ---
> 
> v3: Rebase onto net.
> 
> drivers/net/phy/marvell.c | 66 ++++++++++++++++++++++++++---------------------
>  1 file changed, 37 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 272b051a0199..9097e42bec2e 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -255,34 +255,6 @@ static int marvell_config_aneg(struct phy_device *phydev)
>  {
>  	int err;
>  
> -	/* The Marvell PHY has an errata which requires
> -	 * that certain registers get written in order
> -	 * to restart autonegotiation */
> -	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
> -
> -	if (err < 0)
> -		return err;
> -
> -	err = phy_write(phydev, 0x1d, 0x1f);
> -	if (err < 0)
> -		return err;
> -
> -	err = phy_write(phydev, 0x1e, 0x200c);
> -	if (err < 0)
> -		return err;
> -
> -	err = phy_write(phydev, 0x1d, 0x5);
> -	if (err < 0)
> -		return err;
> -
> -	err = phy_write(phydev, 0x1e, 0);
> -	if (err < 0)
> -		return err;
> -
> -	err = phy_write(phydev, 0x1e, 0x100);
> -	if (err < 0)
> -		return err;
> -
>  	err = marvell_set_polarity(phydev, phydev->mdix_ctrl);
>  	if (err < 0)
>  		return err;
> @@ -316,6 +288,42 @@ static int marvell_config_aneg(struct phy_device *phydev)
>  	return 0;
>  }
>  
> +static int m88e1101_config_aneg(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	/* This Marvell PHY has an errata which requires
> +	 * that certain registers get written in order
> +	 * to restart autonegotiation
> +	 */
> +	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
> +
> +	if (err < 0)
> +		return err;
> +
> +	err = phy_write(phydev, 0x1d, 0x1f);
> +	if (err < 0)
> +		return err;
> +
> +	err = phy_write(phydev, 0x1e, 0x200c);
> +	if (err < 0)
> +		return err;
> +
> +	err = phy_write(phydev, 0x1d, 0x5);
> +	if (err < 0)
> +		return err;
> +
> +	err = phy_write(phydev, 0x1e, 0);
> +	if (err < 0)
> +		return err;
> +
> +	err = phy_write(phydev, 0x1e, 0x100);
> +	if (err < 0)
> +		return err;
> +
> +	return marvell_config_aneg(phydev);
> +}
> +
>  static int m88e1111_config_aneg(struct phy_device *phydev)
>  {
>  	int err;
> @@ -1892,7 +1900,7 @@ static struct phy_driver marvell_drivers[] = {
>  		.flags = PHY_HAS_INTERRUPT,
>  		.probe = marvell_probe,
>  		.config_init = &marvell_config_init,
> -		.config_aneg = &marvell_config_aneg,
> +		.config_aneg = &m88e1101_config_aneg,
>  		.read_status = &genphy_read_status,
>  		.ack_interrupt = &marvell_ack_interrupt,
>  		.config_intr = &marvell_config_intr,
> 


-- 
Florian
