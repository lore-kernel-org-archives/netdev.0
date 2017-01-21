From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/8] net: dsa: mv88e6xxx: Implement external MDIO bus on mv88e6390
Date: Fri, 20 Jan 2017 19:04:35 -0500
Message-ID: <878tq5ffcc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch> <1484955062-26718-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57120 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752000AbdAUAFE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:05:04 -0500
In-Reply-To: <1484955062-26718-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The mv88e6390 has two MDIO busses. The internal MDIO bus is used for
> the internal PHYs. The external MDIO can be used for external PHYs.
> The external MDIO bus will be instantiated if there is an
> "mdio-external" node in the device tree.

Thanks for pushing the 88E6390 support. Some comments below.

> +static int mv88e6xxx_read_phy(struct mv88e6xxx_chip *chip, int addr, int reg,
> +static int mv88e6xxx_write_phy(struct mv88e6xxx_chip *chip, int addr, int reg,
>  static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
>  static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,

Adding mv88e6xxx_read/write_phy() in addition to existing
mv88e6xxx_phy_read/write() feels really confusing and hard to
maintain. Can that be done the other way around maybe?

> +static int mv88e6xxx_external_mdio_register(struct mv88e6xxx_chip *chip,
> +					    struct device_node *np)
> +static void mv88e6xxx_external_mdio_unregister(struct mv88e6xxx_chip *chip)
>  static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
>  				   struct device_node *np)

We already have mv88e6xxx_mdio_register/unregister(). Isn't it possible
to tweak them to take a struct mv88e6xxx_mdio_bus instance and use them
twice for both internal and external MDIO busses?

> +	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_EXTERNAL_MDIO)) {
> +		err = mv88e6xxx_external_mdio_register(chip, np);
> +		if (err)
> +			goto out_mdio;
> +	}

We are trying to get rid of the flags and family checks... Please don't
add new ones. If the external MDIO bus is a new feature of switches like
88E6390, isn't it better to add new external_phy_read/write ops and
register the bus if they are provided?

    if (chip->info->ops->external_phy_read) {
        struct mv88e6xxx_mdio_bus *external_mdio_bus;
        ...
        err = mv88e6xxx_mdio_register(external_mdio_bus);
        if (err)
            ...
    }

Thanks,

        Vivien
