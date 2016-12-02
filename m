From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 4/4] net: dsa: mv88e6xxx: Refactor CPU and DSA port setup
Date: Fri, 02 Dec 2016 16:02:48 -0500
Message-ID: <87h96mcadj.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch> <1480701779-30633-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:59778 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbcLBVCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 16:02:50 -0500
In-Reply-To: <1480701779-30633-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +static int mv88e6xxx_setup_port_dsa(struct mv88e6xxx_chip *chip, int port,
> +				    int upstream_port)
> +{
> +	int err;
> +
> +	err = chip->info->ops->port_set_frame_mode(
> +		chip, port, MV88E6XXX_FRAME_MODE_DSA);
> +	if (err)
> +		return err;
> +
> +	err = chip->info->ops->port_set_egress_unknowns(
> +		chip, port, port == upstream_port);
> +	if (err)
> +		return err;
> +
> +	if (chip->info->ops->port_set_ether_type)
> +		return chip->info->ops->port_set_ether_type(
> +			chip, port, ETH_P_EDSA);
> +
> +	return 0;
> +}
> +
> +static int mv88e6xxx_setup_port_cpu(struct mv88e6xxx_chip *chip, int port)
> +{
> +	int err;
> +
> +	switch (chip->info->tag_protocol) {
> +	case DSA_TAG_PROTO_EDSA:
> +		err = chip->info->ops->port_set_frame_mode(
> +			chip, port, MV88E6XXX_FRAME_MODE_ETHERTYPE);
> +		if (err)
> +			return err;
> +
> +		err = mv88e6xxx_port_set_egress_mode(
> +			chip, port, PORT_CONTROL_EGRESS_ADD_TAG);
> +		if (err)
> +			return err;
> +
> +		if (chip->info->ops->port_set_ether_type)
> +			err = chip->info->ops->port_set_ether_type(
> +				chip, port, ETH_P_EDSA);
> +		break;
> +
> +	case DSA_TAG_PROTO_DSA:
> +		err = chip->info->ops->port_set_frame_mode(
> +			chip, port, MV88E6XXX_FRAME_MODE_DSA);
> +		if (err)
> +			return err;
> +
> +		err = mv88e6xxx_port_set_egress_mode(
> +			chip, port, PORT_CONTROL_EGRESS_UNMODIFIED);
> +		break;
> +	default:
> +		err = -EINVAL;
> +	}
> +
> +	if (err)
> +		return err;
> +
> +	return chip->info->ops->port_set_egress_unknowns(chip, port, true);
> +}
> +
> +static int mv88e6xxx_setup_port_normal(struct mv88e6xxx_chip *chip, int port)
> +{
> +	int err;
> +
> +	err = chip->info->ops->port_set_frame_mode(
> +		chip, port, MV88E6XXX_FRAME_MODE_NORMAL);
> +	if (err)
> +		return err;
> +
> +	return chip->info->ops->port_set_egress_unknowns(chip, port, false);
> +}

The port's EgressMode, FrameMode and EtherType are really tied together
to compose the mode of the port. Could you add an helper in chip.c like:

    static int mv88e6xxx_set_port_mode(struct mv88e6xxx_chip *chip, int port,
                                       enum mv88e6xxx_frame_mode frame_mode,
                                       u16 egress_mode, bool egress_unknown,
                                       u16 ethertype)
    {
        int err;

        if (chip->info->ops->port_set_frame_mode) {
            err = chip->info->ops->port_set_frame_mode(chip, port, frame_mode);
            if (err)
                return err;
        }

        err = mv88e6xxx_port_set_egress_mode(chip, port, egress_mode);
        if (err)
            return err;
        
        if (chip->info->ops->port_set_egress_unknown) {
            err = chip->info->ops->port_set_egress_unknown(chip, port, egress_unknown);
            if (err)
                return err;
        }
        
        if (chip->info->ops->port_set_ether_type) {
            err = chip->info->ops->port_set_ether_type(chip, port, ethertype);
            if (err)
                return err;
        }

        return 0;
    }

So that we correctly check for ops before calling them, and make
mv88e6xxx_setup_port_{dsa,cpu,normal} a bit more concise.

> +
>  static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
>  {
>  	struct dsa_switch *ds = chip->ds;
> @@ -2473,44 +2542,25 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
>  	 * If this is the upstream port for this switch, enable
>  	 * forwarding of unknown unicasts and multicasts.
>  	 */
> -	reg = 0;
> -	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
> -	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
> -	    mv88e6xxx_6095_family(chip) || mv88e6xxx_6065_family(chip) ||
> -	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6320_family(chip))
> -		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
> +	reg = PORT_CONTROL_IGMP_MLD_SNOOP |
>  		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
>  		PORT_CONTROL_STATE_FORWARDING;
> +	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
> +	if (err)
> +		return err;
> +
>  	if (dsa_is_cpu_port(ds, port)) {
> -		if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA)
> -			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
> -				PORT_CONTROL_FORWARD_UNKNOWN_MC;
> -		else
> -			reg |= PORT_CONTROL_DSA_TAG;
> -		reg |= PORT_CONTROL_EGRESS_ADD_TAG |
> -			PORT_CONTROL_FORWARD_UNKNOWN;
> -	}
> -	if (dsa_is_dsa_port(ds, port)) {
> -		if (mv88e6xxx_6095_family(chip) ||
> -		    mv88e6xxx_6185_family(chip))
> -			reg |= PORT_CONTROL_DSA_TAG;
> -		if (mv88e6xxx_6352_family(chip) ||
> -		    mv88e6xxx_6351_family(chip) ||
> -		    mv88e6xxx_6165_family(chip) ||
> -		    mv88e6xxx_6097_family(chip) ||
> -		    mv88e6xxx_6320_family(chip)) {
> -			reg |= PORT_CONTROL_FRAME_MODE_DSA;
> +		err = mv88e6xxx_setup_port_cpu(chip, port);
> +	} else {
> +		if (dsa_is_dsa_port(ds, port)) {
> +			err = mv88e6xxx_setup_port_dsa(chip, port,
> +						       dsa_upstream_port(ds));
> +		} else {
> +			err = mv88e6xxx_setup_port_normal(chip, port);
>  		}
> -
> -		if (port == dsa_upstream_port(ds))
> -			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
> -				PORT_CONTROL_FORWARD_UNKNOWN_MC;
> -	}
> -	if (reg) {
> -		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
> -		if (err)
> -			return err;
>  	}

The statement is weird. Can you please do:

        if (dsa_is_cpu_port(ds, port)) {
            // CPU port setup
        } else if (dsa_is_dsa_port(ds, port)) {
            // DSA port setup
        } else {
            // Normal port setup
        }
> +	if (err)
> +		return err;

> +	int (*port_set_frame_mode)(struct mv88e6xxx_chip *chip, int port,
> +				   enum mv88e6xxx_frame_mode mode);
> +	int (*port_set_egress_unknowns)(struct mv88e6xxx_chip *chip, int port,
> +					bool on);

"unknowns" sounds odd. "floods" is what all datasheet (except 6185)
use. That'd be better I think. Or at least, s/unknowns/unknown/...

Thanks,

        Vivien
