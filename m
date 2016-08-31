From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: add MDB support
Date: Wed, 31 Aug 2016 15:57:19 +0200
Message-ID: <20160831135719.GC15078@lunn.ch>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
 <20160829203246.18811-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160829203246.18811-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien

> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 93abfff..812cb47 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -2240,6 +2240,15 @@ static int mv88e6xxx_port_db_dump_one(struct mv88e6xxx_chip *chip,
>  				fdb->ndm_state = NUD_NOARP;
>  			else
>  				fdb->ndm_state = NUD_REACHABLE;
> +		} else {

Rather than else, i think it would be safer to do

		if (obj->id == SWITCHDEV_OBJ_ID_PORT_MDB) {
> +			struct switchdev_obj_port_mdb *mdb;
> +
> +			if (!is_multicast_ether_addr(addr.mac))
> +				continue;
> +
> +			mdb = SWITCHDEV_OBJ_PORT_MDB(obj);
> +			mdb->vid = vid;
> +			ether_addr_copy(mdb->addr, addr.mac);
>  		}

It should not happen, but the day it does, we get very confused...

> +static int mv88e6xxx_port_mdb_dump(struct dsa_switch *ds, int port,
> +				   struct switchdev_obj_port_mdb *mdb,
> +				   int (*cb)(struct switchdev_obj *obj))
> +{
> +	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
> +	int err;
> +
> +	mutex_lock(&chip->reg_lock);
> +	err = mv88e6xxx_port_db_dump(chip, port, &mdb->obj, cb);
> +	mutex_unlock(&chip->reg_lock);
> +
> +	return err;
> +}

Isn't this identical to mv88e6xxx_port_fdb_dump()? Maybe we should
just have one function, and register it twice?

     Andrew
