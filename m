From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Wed, 25 Jan 2017 18:27:46 +0100
Message-ID: <87sho7123x.fsf@free-electrons.com>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
        <1485309314-23942-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34309 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751567AbdAYR1s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 12:27:48 -0500
In-Reply-To: <1485309314-23942-2-git-send-email-andrew@lunn.ch> (Andrew Lunn's
        message of "Wed, 25 Jan 2017 02:55:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,
 
 On mer., janv. 25 2017, Andrew Lunn <andrew@lunn.ch> wrote:

> The internal PHYs of the mv88e6390 do not have a model ID. Trap any
> calls to the ID register, and if it is zero, return the ID for the
> mv88e6390. The Marvell PHY driver can then bind to this ID.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/dsa/mv88e6xxx/global2.c | 16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
> index 353e26bea3c3..521a5511bd5f 100644
> --- a/drivers/net/dsa/mv88e6xxx/global2.c
> +++ b/drivers/net/dsa/mv88e6xxx/global2.c
> @@ -520,7 +520,21 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
>  	if (err)
>  		return err;
>  
> -	return mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
> +	err = mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
> +	if (err)
> +		return err;
> +
> +	if (reg == MII_PHYSID2) {
> +		/* The mv88e6390 internal PHYS don't have a model number.
> +		 * Use the switch family model number instead.
> +		 */
> +		if (!(*val & 0x3ff)) {

I tested this series on the Topaz switch but it failed because while I
said we read 0x1410C00 actually we read 0x01410C01. With the
MARVELL_PHY_ID_MASK we mask the 4 lower bits so that's why in my patch
"phy: marvell: Add support for the PHY embedded in the topaz switch" I
used the 0x01410C00 value for MARVELL_PHY_ID_88E6141.

However with the mask you use it doesn't work.

So this mask should be changed to 0x3f0 for the Topaz. Actually 0x3fe
would be enough but it seems more logical to use the same mask that for
MARVELL_PHY_ID_MASK.

We could either use the same mask for both family and still use 6390 as
they seem compatible or we use two different families based on the lower
bit.

Gregory

> +			if (chip->info->family == MV88E6XXX_FAMILY_6390)
> +				*val |= PORT_SWITCH_ID_PROD_NUM_6390;
> +		}
> +	}
> +
> +	return 0;
>  }
>  
>  int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
> -- 
> 2.11.0
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
