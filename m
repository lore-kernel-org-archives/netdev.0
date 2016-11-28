From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [[PATCH net-next RFC] 1/4] net: dsa: mv88e6xxx: Implement mv88e6390 tag remap
Date: Mon, 28 Nov 2016 15:35:08 -0500
Message-ID: <8760n7fimb.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1479944598-20372-1-git-send-email-andrew@lunn.ch> <1479944598-20372-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:42544 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753021AbcK1UfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:35:10 -0500
In-Reply-To: <1479944598-20372-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>  #define PORT_TAG_REGMAP_0123	0x18
>  #define PORT_TAG_REGMAP_4567	0x19
> +#define PORT_PRIO_MAP_TABLE	0x18    /* 6390 */
> +#define PORT_PRIO_MAP_TABLE_UPDATE		BIT(15)
> +#define PORT_PRIO_MAP_TABLE_INGRESS_PCP		(0x0 << 12)
> +#define PORT_PRIO_MAP_TABLE_EGRESS_GREEN_PCP	(0x1 << 12)
> +#define PORT_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP	(0x2 << 12)
> +#define PORT_PRIO_MAP_TABLE_EGRESS_AVB_PCP	(0x3 << 12)
> +#define PORT_PRIO_MAP_TABLE_EGRESS_GREEN_DSCP	(0x5 << 12)
> +#define PORT_PRIO_MAP_TABLE_EGRESS_YELLOW_DSCP	(0x6 << 12)
> +#define PORT_PRIO_MAP_TABLE_EGRESS_AVB_DSCP	(0x7 << 12)

0x17 is the "IP Priority Mapping Table" register, so I'd define 0x18 as
PORT_IEEE_PRIO_MAP_TABLE to avoid later confusion.

>  
>  #define GLOBAL_STATUS		0x00
>  #define GLOBAL_STATUS_PPU_STATE BIT(15) /* 6351 and 6171 */
> @@ -813,6 +822,7 @@ struct mv88e6xxx_ops {
>  	void (*stats_get_strings)(struct mv88e6xxx_chip *chip,  uint8_t *data);
>  	void (*stats_get_stats)(struct mv88e6xxx_chip *chip,  int port,
>  				uint64_t *data);
> +	int (*tag_remap)(struct mv88e6xxx_chip *chip, int port);

I would've prefered an op like .tag_remap(*chip, port, prio, new) and a
wrapper in chip.c which loops over priority 0-7, but that would make the
implementation unnecessarily complex, so let's keep it as is for now ;)

>  };
>  
>  #define STATS_TYPE_PORT		BIT(0)
> diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
> index af4772d86086..b7fab70f6cd7 100644
> --- a/drivers/net/dsa/mv88e6xxx/port.c
> +++ b/drivers/net/dsa/mv88e6xxx/port.c
> @@ -496,3 +496,60 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
>  
>  	return 0;
>  }

Please add an ordered comment:

/* Offset 0x18: Port IEEE Priority Remapping Registers [0-3]
 * Offset 0x19: Port IEEE Priority Remapping Registers [4-7]
 */

> +
> +int mv88e6095_tag_remap(struct mv88e6xxx_chip *chip, int port)
> +{
> +	int err;
> +
> +	/* Tag Remap: use an identity 802.1p prio -> switch prio
> +	 * mapping.
> +	 */
> +	err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_0123, 0x3210);
> +	if (err)
> +		return err;
> +
> +	/* Tag Remap 2: use an identity 802.1p prio -> switch
> +	 * prio mapping.
> +	 */

A single comment like this before the 2 writes will be enough:

    /* Use a direct priority mapping for all IEEE tagged frames */

> +	return mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_4567, 0x7654);
> +}

Functions of port.c implementing Port Registers features must be
prefixed mv88e6xxx_port_* (6xxx can be a model in case of conflict).
mv88e6xxx_port_tag_remap() seems fine.

> +
> +int mv88e6390_tag_remap(struct mv88e6xxx_chip *chip, int port)
> +{
> +	int err, reg, i;
> +
> +	for (i = 0; i <= 7; i++) {
> +		reg = i | (i << 4) |

The pointer offset is 9, not 4.

> +			PORT_PRIO_MAP_TABLE_INGRESS_PCP |
> +			PORT_PRIO_MAP_TABLE_UPDATE;
> +		err = mv88e6xxx_port_write(chip, port, PORT_PRIO_MAP_TABLE,
> +					   reg);
> +		if (err)
> +			return err;
> +
> +		reg = i | PORT_PRIO_MAP_TABLE_EGRESS_GREEN_PCP |
> +			PORT_PRIO_MAP_TABLE_UPDATE;
> +		err = mv88e6xxx_port_write(chip, port, PORT_PRIO_MAP_TABLE,
> +					   reg);
> +		if (err)
> +			return err;
> +
> +		reg = i |
> +			PORT_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP |
> +			PORT_PRIO_MAP_TABLE_UPDATE;
> +		err = mv88e6xxx_port_write(chip, port, PORT_PRIO_MAP_TABLE,
> +					   reg);
> +		if (err)
> +			return err;
> +
> +		reg = i |
> +			PORT_PRIO_MAP_TABLE_EGRESS_AVB_PCP |
> +			PORT_PRIO_MAP_TABLE_UPDATE;
> +		err = mv88e6xxx_port_write(chip, port, PORT_PRIO_MAP_TABLE,
> +					   reg);
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}

Please add a static helper first to write the table, e.g.

    /* Offset 0x18: Port IEEE Priority Mapping Table (88E6190) */

    static int mv88e6xxx_port_ieeepmt_write(struct mv88e6xxx_chip *chip,
                                            int port, u8 table,
                                            u8 pointer, u16 data)

And then provide

    int mv88e6xxx_port_ieeepmt_tag_remap(...)


Thanks,

        Vivien
