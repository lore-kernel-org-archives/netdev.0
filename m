From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: add MDB support
Date: Wed, 31 Aug 2016 10:46:14 -0400
Message-ID: <874m618095.fsf@ketchup.mtl.sfl>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com> <20160829203246.18811-4-vivien.didelot@savoirfairelinux.com> <20160831135719.GC15078@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831135719.GC15078@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Hi Vivien
>
>> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
>> index 93abfff..812cb47 100644
>> --- a/drivers/net/dsa/mv88e6xxx/chip.c
>> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
>> @@ -2240,6 +2240,15 @@ static int mv88e6xxx_port_db_dump_one(struct mv88e6xxx_chip *chip,
>>  				fdb->ndm_state = NUD_NOARP;
>>  			else
>>  				fdb->ndm_state = NUD_REACHABLE;
>> +		} else {
>
> Rather than else, i think it would be safer to do
>
> 		if (obj->id == SWITCHDEV_OBJ_ID_PORT_MDB) {
>> +			struct switchdev_obj_port_mdb *mdb;
>> +
>> +			if (!is_multicast_ether_addr(addr.mac))
>> +				continue;
>> +
>> +			mdb = SWITCHDEV_OBJ_PORT_MDB(obj);
>> +			mdb->vid = vid;
>> +			ether_addr_copy(mdb->addr, addr.mac);
>>  		}
>
> It should not happen, but the day it does, we get very confused...

Do you mean the something like this?

    if (obj->id == SWITCHDEV_OBJ_ID_PORT_FDB) {
        ...
    } else if (obj->id == SWITCHDEV_OBJ_ID_PORT_MDB) {
        ...
    } else {
        return -EOPNOTSUPP;
    }

I'm OK with that if you think it is better.

>> +static int mv88e6xxx_port_mdb_dump(struct dsa_switch *ds, int port,
>> +				   struct switchdev_obj_port_mdb *mdb,
>> +				   int (*cb)(struct switchdev_obj *obj))
>> +{
>> +	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
>> +	int err;
>> +
>> +	mutex_lock(&chip->reg_lock);
>> +	err = mv88e6xxx_port_db_dump(chip, port, &mdb->obj, cb);
>> +	mutex_unlock(&chip->reg_lock);
>> +
>> +	return err;
>> +}
>
> Isn't this identical to mv88e6xxx_port_fdb_dump()? Maybe we should
> just have one function, and register it twice?

No the signatures are differentes. See _fdb vs. _mdb. They are basically
the same thing (at least, from the switch driver's point of view).

We can abstract the FDB (unicast and multicast) related operations
directly in the DSA layer, but I think it is better to map directly the
switchdev obj operations for the moment...

What do you guys think?

Thanks,

        Vivien
