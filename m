From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next 5/5] dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable
Date: Thu, 25 May 2017 19:31:44 -0400
Message-ID: <87o9ugecnz.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495753404-29943-1-git-send-email-andrew@lunn.ch> <1495753404-29943-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40756 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965610AbdEYXdr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 19:33:47 -0400
In-Reply-To: <1495753404-29943-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>  static int mv88e6xxx_serdes_power(struct mv88e6xxx_chip *chip, int port,
>  				  bool on)
>  {
> -	if (chip->info->ops->serdes_power)
> -		return chip->info->ops->serdes_power(chip, port, on);
> +	int err = 0;
>  
> -	return 0;
> +	if (chip->info->ops->serdes_power) {
> +		err = chip->info->ops->serdes_power(chip, port, on);
> +		if (err)
> +			dev_err(chip->dev,
> +				"Failed to change SERDES power: %d\n", err);
> +	}
> +
> +	return err;
>  }

This is not necessary, please keep mv88e6xxx_serdes_power as it is.

>  static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
> @@ -1862,12 +1868,15 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
>  	if (err)
>  		return err;
>  
> -	/* If this port is connected to a SerDes, make sure the SerDes is
> -	 * powered up.
> +	/* Enable the SERDES interface for DSA and CPU ports. Normal
> +	 * ports SERDES are enabled when the port is enabled, thus
> +	 * saving a bit of power.
>  	 */
> -	err = mv88e6xxx_serdes_power(chip, port, true);
> -	if (err)
> -		return err;
> +	if ((dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))) {
> +		err = mv88e6xxx_serdes_power(chip, port, true);
> +		if (err)
> +			return err;
> +	}

This is OK.

>  
>  	/* Port Control 2: don't force a good FCS, set the maximum frame size to
>  	 * 10240 bytes, disable 802.1q tags checking, don't discard tagged or
> @@ -1969,6 +1978,29 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
>  	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
>  }
>  
> +static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
> +				 struct phy_device *phydev)
> +{
> +	struct mv88e6xxx_chip *chip = ds->priv;
> +	int err = 0;
> +
> +	mutex_lock(&chip->reg_lock);
> +	mv88e6xxx_serdes_power(chip, port, true);
> +	mutex_unlock(&chip->reg_lock);

Please return the error as usual:

    int err;

    mutex_lock(&chip->reg_lock);
    err = mv88e6xxx_serdes_power(chip, port, true);
    mutex_unlock(&chip->reg_lock);
    
    return err;

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
> +	mv88e6xxx_serdes_power(chip, port, false);
> +	mutex_unlock(&chip->reg_lock);

And add the message here, since this is that specific function returning
void which skips errors:

    mutex_lock(&chip->reg_lock);
    if (mv88e6xxx_serdes_power(chip, port, false))
        dev_err(chip->dev, "Failed to change SERDES power: %d\n", err);
    mutex_unlock(&chip->reg_lock);


Thanks,

        Vivien
