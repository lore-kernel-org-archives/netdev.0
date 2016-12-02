From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 1/4] net: dsa: mv88e6xxx: Implement mv88e6390 tag remap
Date: Fri, 02 Dec 2016 14:15:37 -0500
Message-ID: <87polacfc6.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch> <1480701779-30633-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51218 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbcLBTQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 14:16:55 -0500
In-Reply-To: <1480701779-30633-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +/* Offset 0x18: Port IEEE Priority Remapping Registers [0-3]
> + * Offset 0x19: Port IEEE Priority Remapping Registers [4-7]
> + */
> +
> +int mv88e6095_port_tag_remap(struct mv88e6xxx_chip *chip, int port)
> +{
> +	int err;
> +
> +	/* Use a direct priority mapping for all IEEE tagged frames */
> +	err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_0123, 0x3210);
> +	if (err)
> +		return err;
> +
> +	return mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_4567, 0x7654);
> +}
> +
> +static int mv88e6xxx_port_ieeepmt_write(struct mv88e6xxx_chip *chip,
> +					int port, u16 table,
> +					u8 pointer, u16 data)
> +{
> +	u16 reg;
> +
> +	reg = PORT_IEEE_PRIO_MAP_TABLE_UPDATE |
> +		table |
> +		(pointer << PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT) |
> +		data;
> +
> +	return mv88e6xxx_port_write(chip, port, PORT_IEEE_PRIO_MAP_TABLE, reg);
> +}
> +

I'll send a delta patch to introduce mv88e6xxx_port_update() so we'll
benefit from the free wait on update bit 15.

> +int mv88e6390_port_tag_remap(struct mv88e6xxx_chip *chip, int port)
> +{
> +	int err, i;
> +
> +	for (i = 0; i <= 7; i++) {
> +		err = mv88e6xxx_port_ieeepmt_write(
> +			chip, port, PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP,
> +			i, (i | i << 4));

So here you are also mapping the frame's IEEE QPRI (offset 4), this is a
bit inconsistent compared to mv88e6095_port_tag_remap, which doesn't.

But it seems like these functions are only used at the moment to write
the default values, so I guess it doesn't really matter right now...

> +		if (err)
> +			return err;
> +
> +		err = mv88e6xxx_port_ieeepmt_write(
> +			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_PCP,
> +			i, i);
> +		if (err)
> +			return err;
> +
> +		err = mv88e6xxx_port_ieeepmt_write(
> +			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP,
> +			i, i);
> +		if (err)
> +			return err;
> +
> +		err = mv88e6xxx_port_ieeepmt_write(
> +			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_PCP,
> +			i, i);
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
