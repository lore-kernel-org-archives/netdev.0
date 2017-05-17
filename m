From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/3] dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable
Date: Wed, 17 May 2017 16:44:03 -0400
Message-ID: <87a86b8b8s.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495051512-13554-1-git-send-email-andrew@lunn.ch> <1495051512-13554-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, nikita.yoush@cogentembedded.com,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49646 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdEQUp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 16:45:57 -0400
In-Reply-To: <1495051512-13554-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Good patchset overall, some comments below.

Andrew Lunn <andrew@lunn.ch> writes:

> @@ -2168,7 +2165,44 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
>  	/* Default VLAN ID and priority: don't set a default VLAN
>  	 * ID, and set the default packet priority to zero.
>  	 */
> -	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
> +	err = mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
> +	if (err)
> +		return err;
> +
> +	/* Enable the SERDES interface for DSA and CPU ports. Normal
> +	 * ports SERDES are enabled when the port is enabled, thus
> +	 * saving a bit of power.
> +	 */
> +	if ((dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) &&
> +	    chip->info->ops->serdes_power)
> +		err = chip->info->ops->serdes_power(chip, port, true);

Please provide a wrapper like this in chip.c in patch 1/3:

    static int mv88e6xxx_serdes_power()
    {
        if (chip->info->ops->serdes_power)
            return chip->info->ops->serdes_power();

        return 0;
    }

So that we don't check chip->info->ops that many times.

> +
> +	return err;
> +}
> +
> +static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
> +				 struct phy_device *phydev)
> +{
> +	struct mv88e6xxx_chip *chip = ds->priv;
> +	int err = 0;
> +
> +	mutex_lock(&chip->reg_lock);
> +	if (chip->info->ops->serdes_power)
> +		err = chip->info->ops->serdes_power(chip, port, true);
> +	mutex_unlock(&chip->reg_lock);
> +
> +	return err;
> +}
> +
> +static void mv88e6xxx_port_disable(struct dsa_switch *ds, int port,
> +				   struct phy_device *phydev)
> +{
> +	struct mv88e6xxx_chip *chip = ds->priv;
> +
> +	mutex_lock(&chip->reg_lock);
> +	if (chip->info->ops->serdes_power)
> +		chip->info->ops->serdes_power(chip, port, false);
> +	mutex_unlock(&chip->reg_lock);
>  }

Also please split this in 2 patchs, one which setups serdes with the
port, one which implements port_enable/disable DSA ops.

Thanks,

        Vivien
