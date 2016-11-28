From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [[PATCH net-next RFC] 4/4] net: dsa: mv88e6xxx: Refactor CPU and DSA port setup
Date: Mon, 28 Nov 2016 11:00:34 -0500
Message-ID: <87bmwzfvbx.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1479944598-20372-1-git-send-email-andrew@lunn.ch> <1479944598-20372-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45106 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932617AbcK1QAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 11:00:37 -0500
In-Reply-To: <1479944598-20372-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>  static const struct mv88e6xxx_ops mv88e6391_ops = {
> diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> index a0d0f79a7de8..b846a33c024c 100644
> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> @@ -123,6 +123,10 @@
>  #define PORT_CONTROL_USE_TAG		BIT(4)
>  #define PORT_CONTROL_FORWARD_UNKNOWN_MC	BIT(3)
>  #define PORT_CONTROL_FORWARD_UNKNOWN	BIT(2)
> +#define PORT_CONTROL_NOT_EGREES_UNKNOWN_DA		(0x0 << 2)
> +#define PORT_CONTROL_NOT_EGREES_UNKNOWN_MULTICAST_DA	(0x1 << 2)
> +#define PORT_CONTROL_NOT_EGREES_UNKNOWN_UNITCAST_DA	(0x2 << 2)

s/EGREES/EGRESS/.

> +#define PORT_CONTROL_EGREES_ALL_UNKNOWN_DA		(0x3 << 2)
>  #define PORT_CONTROL_STATE_MASK		0x03
>  #define PORT_CONTROL_STATE_DISABLED	0x00
>  #define PORT_CONTROL_STATE_BLOCKING	0x01
> @@ -821,6 +825,8 @@ struct mv88e6xxx_ops {
>  				uint64_t *data);
>  	int (*tag_remap)(struct mv88e6xxx_chip *chip, int port);
>  	int (*monitor_ctrl)(struct mv88e6xxx_chip *chip, int upstream_port);
> +	int (*cpu_port_config)(struct mv88e6xxx_chip *chip, int port);
> +	int (*dsa_port_config)(struct mv88e6xxx_chip *chip, int port);
>  };

Hum, I dislike having config wrappers in the library. The functions
stored in the mv88e6xxx_ops structure should reflect the features
exposed by the SMI device (Port, Global X, PHY, etc.) registers.

They should not handle configuration logic, we should see them as an
MV88E6XXX API used to implement a chip (usually wrapped in chip.c).

>  
>  #define STATS_TYPE_PORT		BIT(0)
> diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
> index b7fab70f6cd7..a37d7d72df47 100644
> --- a/drivers/net/dsa/mv88e6xxx/port.c
> +++ b/drivers/net/dsa/mv88e6xxx/port.c
> @@ -553,3 +553,78 @@ int mv88e6390_tag_remap(struct mv88e6xxx_chip *chip, int port)
>  
>  	return 0;
>  }
> +
> +int mv88e6095_cpu_port_config(struct mv88e6xxx_chip *chip, int port)
> +{
> +	u16 reg;
> +	int err;
> +
> +	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
> +	if (err)
> +		return err;
> +
> +	reg |= PORT_CONTROL_DSA_TAG |
> +		PORT_CONTROL_EGRESS_ADD_TAG |
> +		PORT_CONTROL_FORWARD_UNKNOWN;
> +
> +	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
> +}
> +
> +int mv88e6351_cpu_port_config(struct mv88e6xxx_chip *chip, int port)
> +{
> +	u16 reg;
> +	int err;
> +
> +	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
> +	if (err)
> +		return err;
> +
> +	if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA) {
> +		reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
> +			PORT_CONTROL_EGRESS_ADD_TAG;
> +
> +		/* Port Ethertype: use the Ethertype DSA Ethertype
> +		 * value.
> +		 */
> +		err = mv88e6xxx_port_write(chip, port, PORT_ETH_TYPE,
> +					   ETH_P_EDSA);
> +		if (err)
> +			return err;
> +	} else {
> +		reg |= PORT_CONTROL_FRAME_MODE_DSA;
> +	}
> +
> +	reg |= PORT_CONTROL_EGREES_ALL_UNKNOWN_DA;
> +
> +	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
> +}

The device (Port, Global X, etc.) functions should reflect and implement
the feature described in the register(s) they read from/write to.

Please provide generic functions to configure a port's Frame mode and
Egress mode under the comment /* Offset 0x04: Port Control Register */

mv88e6xxx_port_set_{frame,egress}_mode() would work. The Frame mode bits
changed between chips, but the Egress mode bits are the same since 6065.

A frame mode can be "Normal Network mode", "DSA mode", "Provider mode",
or "Ether Type DSA mode". Maybe use an enum, or switching on the u8
frame_mode value might be enough, as you wish.

Please also provide a generic function to set the Port EType under an
ordered comment:

/* Offset 0x0F: Port E Type */

int mv88e6xxx_port_set_etype(struct mv88e6xxx_chip *chip, int port,
                             u16 etype)
{
    return mv88e6xxx_port_write(chip, port, PORT_ETH_TYPE, etype);
}

Then, some nice wrappers in chip.c can use them depending on the chip's
tag_protocol to configure what net/dsa calls cpu, dsa, or user port.

Thanks,

        Vivien
