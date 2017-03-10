From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 02/14] net: dsa: mv88e6xxx: move ATU ageing time
 setter
Date: Fri, 10 Mar 2017 01:45:09 +0100
Message-ID: <20170310004509.GF22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42800 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750781AbdCJApN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 19:45:13 -0500
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-3-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 09, 2017 at 06:33:12PM -0500, Vivien Didelot wrote:
> Move the ATU ageing time setter code in the new global1_atu.c file, and
> add an mv88e6xxx_atu_setup helper to configure and initialize the ATU.

I would of done this as two patches. Currently, it is not clear why
you are adding the helper. Putting that change in a patch of its own,
with a good explanation, would help make the why clearer.

The change log messages should be about the why, and less about the
what.

So please at least extend this to extend this why they helper is being
added.

Thanks
	Andrew


> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/Makefile      |  1 +
>  drivers/net/dsa/mv88e6xxx/chip.c        | 42 ++++++++------------------------
>  drivers/net/dsa/mv88e6xxx/global1.h     |  3 +++
>  drivers/net/dsa/mv88e6xxx/global1_atu.c | 43 +++++++++++++++++++++++++++++++++
>  4 files changed, 57 insertions(+), 32 deletions(-)
>  create mode 100644 drivers/net/dsa/mv88e6xxx/global1_atu.c
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
> index c36be318de1a..31d37a90cec7 100644
> --- a/drivers/net/dsa/mv88e6xxx/Makefile
> +++ b/drivers/net/dsa/mv88e6xxx/Makefile
> @@ -1,5 +1,6 @@
>  obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
>  mv88e6xxx-objs := chip.o
>  mv88e6xxx-objs += global1.o
> +mv88e6xxx-objs += global1_atu.o
>  mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
>  mv88e6xxx-objs += port.o
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 03dc886ed3d6..0ad8200f3321 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -1306,6 +1306,11 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
>  		netdev_err(ds->ports[port].netdev, "failed to update state\n");
>  }
>  
> +static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
> +{
> +	return mv88e6xxx_g1_atu_set_age_time(chip, 300000);
> +}
> +
>  static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
>  {
>  	struct mv88e6xxx_chip *chip = ds->priv;
> @@ -2697,33 +2702,6 @@ static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
>  	return 0;
>  }
>  
> -static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
> -				     unsigned int msecs)
> -{
> -	const unsigned int coeff = chip->info->age_time_coeff;
> -	const unsigned int min = 0x01 * coeff;
> -	const unsigned int max = 0xff * coeff;
> -	u8 age_time;
> -	u16 val;
> -	int err;
> -
> -	if (msecs < min || msecs > max)
> -		return -ERANGE;
> -
> -	/* Round to nearest multiple of coeff */
> -	age_time = (msecs + coeff / 2) / coeff;
> -
> -	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
> -	if (err)
> -		return err;
> -
> -	/* AgeTime is 11:4 bits */
> -	val &= ~0xff0;
> -	val |= age_time << 4;
> -
> -	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
> -}
> -
>  static int mv88e6xxx_set_ageing_time(struct dsa_switch *ds,
>  				     unsigned int ageing_time)
>  {
> @@ -2731,7 +2709,7 @@ static int mv88e6xxx_set_ageing_time(struct dsa_switch *ds,
>  	int err;
>  
>  	mutex_lock(&chip->reg_lock);
> -	err = mv88e6xxx_g1_set_age_time(chip, ageing_time);
> +	err = mv88e6xxx_g1_atu_set_age_time(chip, ageing_time);
>  	mutex_unlock(&chip->reg_lock);
>  
>  	return err;
> @@ -2783,10 +2761,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
>  	if (err)
>  		return err;
>  
> -	err = mv88e6xxx_g1_set_age_time(chip, 300000);
> -	if (err)
> -		return err;
> -
>  	/* Clear all ATU entries */
>  	err = _mv88e6xxx_atu_flush(chip, 0, true);
>  	if (err)
> @@ -2872,6 +2846,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
>  			goto unlock;
>  	}
>  
> +	err = mv88e6xxx_atu_setup(chip);
> +	if (err)
> +		goto unlock;
> +
>  	/* Some generations have the configuration of sending reserved
>  	 * management frames to the CPU in global2, others in
>  	 * global1. Hence it does not fit the two setup functions
> diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
> index 1aec7382c02d..b8d0fb519bab 100644
> --- a/drivers/net/dsa/mv88e6xxx/global1.h
> +++ b/drivers/net/dsa/mv88e6xxx/global1.h
> @@ -38,4 +38,7 @@ int mv88e6095_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
>  int mv88e6390_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
>  int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
>  
> +int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
> +				  unsigned int msecs);
> +
>  #endif /* _MV88E6XXX_GLOBAL1_H */
> diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
> new file mode 100644
> index 000000000000..4d0ada9efc6d
> --- /dev/null
> +++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
> @@ -0,0 +1,43 @@
> +/*
> + * Marvell 88E6xxx Address Translation Unit (ATU) support
> + *
> + * Copyright (c) 2008 Marvell Semiconductor
> + * Copyright (c) 2017 Savoir-faire Linux, Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include "mv88e6xxx.h"
> +#include "global1.h"
> +
> +/* Offset 0x0A: ATU Control Register */
> +
> +int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
> +				  unsigned int msecs)
> +{
> +	const unsigned int coeff = chip->info->age_time_coeff;
> +	const unsigned int min = 0x01 * coeff;
> +	const unsigned int max = 0xff * coeff;
> +	u8 age_time;
> +	u16 val;
> +	int err;
> +
> +	if (msecs < min || msecs > max)
> +		return -ERANGE;
> +
> +	/* Round to nearest multiple of coeff */
> +	age_time = (msecs + coeff / 2) / coeff;
> +
> +	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
> +	if (err)
> +		return err;
> +
> +	/* AgeTime is 11:4 bits */
> +	val &= ~0xff0;
> +	val |= age_time << 4;
> +
> +	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
> +}
> -- 
> 2.12.0
> 
