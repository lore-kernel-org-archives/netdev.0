From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames in hardware
Date: Wed, 27 Sep 2017 14:24:45 -0400
Message-ID: <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch> <1506464764-12699-7-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39610 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751692AbdI0S2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 14:28:25 -0400
In-Reply-To: <1506464764-12699-7-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +static int mv88e6xxx_port_add_broadcast(struct mv88e6xxx_chip *chip, int port,
> +					u16 vid)
> +{
> +	const char broadcast[6] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
> +
> +	return mv88e6xxx_port_db_load_purge(
> +		chip, port, broadcast, vid,
> +		MV88E6XXX_G1_ATU_DATA_STATE_MC_STATIC);

Please don't do this. This is not a valid coding style and has already
shown to be a bad example for other DSA drivers copying mv88e6xxx.

Simply declare u8 state = MV88E6XXX_G1_ATU_DATA_STATE_MC_STATIC above...

> +}
> +
> +static int mv88e6xxx_broadcast_setup(struct mv88e6xxx_chip *chip, u16 vid)
> +{
> +	int port;
> +	int err;
> +
> +	for (port = 0; port < mv88e6xxx_num_ports(chip); ++port) {
> +		err = mv88e6xxx_port_add_broadcast(chip, port, vid);
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}
> +
>  static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
>  				    u16 vid, u8 member)
>  {
> @@ -1247,7 +1271,11 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
>  
>  	vlan.member[port] = member;
>  
> -	return mv88e6xxx_vtu_loadpurge(chip, &vlan);
> +	err = mv88e6xxx_vtu_loadpurge(chip, &vlan);
> +	if (err)
> +		return err;
> +
> +	return mv88e6xxx_broadcast_setup(chip, vid);
>  }
>  
>  static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
> @@ -2025,6 +2053,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
>  	if (err)
>  		goto unlock;
>  
> +	err = mv88e6xxx_broadcast_setup(chip, 0);
> +	if (err)
> +		goto unlock;
> +
>  	err = mv88e6xxx_pot_setup(chip);
>  	if (err)
>  		goto unlock;


Adding the broadcast address to an Ethernet switch's FDB is pretty
generic and mv88e6xxx mustn't be the only driver doing this.

They do not have to care about the broadcast address, this is just a
standard MDB entry for them. This must be moved up to the DSA layer.

Adding the broadcast address in dsa_port_vlan_add and dsa_port_enable
like this should be enough: http://ix.io/AmS


Thanks,

        Vivien
