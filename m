From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/6] net: dsa: mv88e6xxx: move ATU code in
 its own file
Date: Fri, 17 Feb 2017 22:35:18 +0100
Message-ID: <20170217213518.GH6096@lunn.ch>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
 <20170217150531.2181-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44076 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934415AbdBQVfV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 16:35:21 -0500
Content-Disposition: inline
In-Reply-To: <20170217150531.2181-3-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 10:05:27AM -0500, Vivien Didelot wrote:
> Move the Global (1) ATU related code in its own file, and export the
> necessary primitives.
> 
> Use that opportunity to provide a cleaner API for the ATU, by renaming a
> few underscore prefixed functions, and members of the
> mv88e6xxx_atu_entry structures.

>  static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
>  					const unsigned char *addr, u16 vid,
>  					u8 state)
>  {
> +	struct mv88e6xxx_atu_entry entry = { 0 };
>  	struct mv88e6xxx_vtu_entry vlan;
> -	struct mv88e6xxx_atu_entry entry;
>  	int err;
>  
>  	/* Null VLAN ID corresponds to the port private database */
> @@ -2107,21 +1918,32 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
>  	if (err)
>  		return err;
>  
> -	err = mv88e6xxx_atu_get(chip, vlan.fid, addr, &entry);
> +	entry.fid = vlan.fid;
> +	ether_addr_copy(entry.mac, addr);
> +	eth_addr_dec(entry.mac);
> +	err = mv88e6xxx_atu_getnext(chip, &entry);
>  	if (err)
>  		return err;
>  
> +	/* Initialize a fresh ATU entry if it isn't found */
> +	if (entry.state == GLOBAL_ATU_DATA_STATE_UNUSED ||
> +	    !ether_addr_equal(entry.mac, addr)) {
> +		memset(&entry, 0, sizeof(entry));
> +		ether_addr_copy(entry.mac, addr);
> +		entry.fid = vlan.fid;
> +	}
> +

This seems to be more than renaming a few functions. There looks to be
real changes here. I think these changes should be split out into a
separate patch with an explanation what is being changed. Keep this
patch for plain renames.

It would also be easier to review if the patch just moved the code, no
changes. Then have patches which clean up the API. It is hard to see
what is move and what is cleanup. Plain move needs little review,
cleanup needs more review. With the current patch, it is hard to see
which is which.

      Andrew
