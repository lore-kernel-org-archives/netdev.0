From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Add helper for accessing port registers
Date: Mon, 19 Sep 2016 18:53:12 -0400
Message-ID: <874m5bbixz.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1474323521-5088-1-git-send-email-andrew@lunn.ch> <1474323521-5088-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36707 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751169AbcISWxR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 18:53:17 -0400
In-Reply-To: <1474323521-5088-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> @@ -41,6 +41,11 @@ static void assert_reg_lock(struct mv88e6xxx_chip *chip)
>  	}
>  }
>  
> +static int mv88e6xxx_reg_port(struct mv88e6xxx_chip *chip, int port)
> +{
> +	return chip->info->port_base_addr + port;
> +}
> +

If we really want such helper, can you call it mv88e6xxx_port_addr()
instead, so that we respect an implicit mv88e6xxx_port_ namespace, and
use the correct "addr" term instead of erroneous "reg" one.

>  /* The switch ADDR[4:1] configuration pins define the chip SMI device address
>   * (ADDR[0] is always zero, thus only even SMI addresses can be strapped).
>   *
> @@ -216,6 +221,42 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
>  	return 0;
>  }
>  
> +int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
> +			u16 *val)
> +{
> +	int addr = mv88e6xxx_reg_port(chip, port);
> +	int err;
> +
> +	assert_reg_lock(chip);
> +
> +	err = mv88e6xxx_smi_read(chip, addr, reg, val);
> +	if (err)
> +		return err;
> +
> +	dev_dbg(chip->dev, "<- port: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
> +		port, reg, *val);
> +
> +	return 0;
> +}
> +
> +int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
> +			 u16 val)
> +{
> +	int addr = mv88e6xxx_reg_port(chip, port);
> +	int err;
> +
> +	assert_reg_lock(chip);
> +
> +	err = mv88e6xxx_smi_write(chip, addr, reg, val);
> +	if (err)
> +		return err;
> +
> +	dev_dbg(chip->dev, "-> port: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
> +		port, reg, val);
> +
> +	return 0;
> +}
> +

mv88e6xxx_{read,write} are already doing this (wrapping the assert, smi
op and debug message). Plus, we could access the port registers through
a different interface, like remote management frames.

So please don't duplicate and use the following, as the previous
mv88e6xxx_port_read() function was doing:

    static int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip,
                                   int port, int reg, u16 *val)
    {
            int addr = chip->info->port_base_addr + port;

            return mv88e6xxx_read(chip, addr, reg, val);
    }

    static int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip,
                                    int port, int reg, u16 val)
    {
            int addr = chip->info->port_base_addr + port;

            return mv88e6xxx_write(chip, addr, reg, val);
    }

Note: I don't really see a need for the mv88e6xxx_port_addr helper in
fact, the above code is quite clear. I'd suggest to drop it unless we
need a port address somewhere else than in mv88e6xxx_port_{read,write}.

>  static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
>  			      int reg, u16 *val)
>  {
> @@ -585,19 +626,19 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
>  				  struct phy_device *phydev)
>  {
>  	struct mv88e6xxx_chip *chip = ds->priv;
> -	u32 reg;
> -	int ret;
> +	u16 reg;
> +	int err;
>  
>  	if (!phy_is_pseudo_fixed_link(phydev))
>  		return;
>  
>  	mutex_lock(&chip->reg_lock);
>  
> -	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_PCS_CTRL);
> -	if (ret < 0)
> +	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
> +	if (err < 0)
>  		goto out;

Can you please get rid of the < 0 condition at the same time, if (err)
is enough.

(same for the rest of this patch).

Thanks,

        Vivien
