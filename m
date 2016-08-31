From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/3] net: dsa: mv88e6xxx: make switchdev DB ops generic
Date: Wed, 31 Aug 2016 10:39:15 -0400
Message-ID: <87shtlvw8c.fsf@ketchup.mtl.sfl>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com> <20160829203246.18811-3-vivien.didelot@savoirfairelinux.com> <20160831134943.GB15078@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49644 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934860AbcHaOja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 10:39:30 -0400
In-Reply-To: <20160831134943.GB15078@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Hi Vivien
>
>> -static int _mv88e6xxx_port_fdb_dump_one(struct mv88e6xxx_chip *chip,
>> -					u16 fid, u16 vid, int port,
>> -					struct switchdev_obj_port_fdb *fdb,
>> -					int (*cb)(struct switchdev_obj *obj))
>> +static int mv88e6xxx_port_db_dump_one(struct mv88e6xxx_chip *chip,
>> +				      u16 fid, u16 vid, int port,
>> +				      struct switchdev_obj *obj,
>> +				      int (*cb)(struct switchdev_obj *obj))
>>  {
>>  	struct mv88e6xxx_atu_entry addr = {
>>  		.mac = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
>> @@ -2222,72 +2219,87 @@ static int _mv88e6xxx_port_fdb_dump_one(struct mv88e6xxx_chip *chip,
>>  	do {
>>  		err = _mv88e6xxx_atu_getnext(chip, fid, &addr);
>>  		if (err)
>> -			break;
>> +			return err;
>>  
>>  		if (addr.state == GLOBAL_ATU_DATA_STATE_UNUSED)
>>  			break;
>>  
>> -		if (!addr.trunk && addr.portv_trunkid & BIT(port)) {
>> -			bool is_static = addr.state ==
>> -				(is_multicast_ether_addr(addr.mac) ?
>> -				 GLOBAL_ATU_DATA_STATE_MC_STATIC :
>> -				 GLOBAL_ATU_DATA_STATE_UC_STATIC);
>> +		if (addr.trunk || (addr.portv_trunkid & BIT(port)) == 0)
>> +			continue;
>> +
>> +		if (obj->id == SWITCHDEV_OBJ_ID_PORT_FDB) {
>> +			struct switchdev_obj_port_fdb *fdb;
>>  
>> +			if (!is_unicast_ether_addr(addr.mac))
>> +				continue;
>> +
>> +			fdb = SWITCHDEV_OBJ_PORT_FDB(obj);
>>  			fdb->vid = vid;
>>  			ether_addr_copy(fdb->addr, addr.mac);
>> -			fdb->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
>> -
>> -			err = cb(&fdb->obj);
>> -			if (err)
>> -				break;
>> +			if (addr.state == GLOBAL_ATU_DATA_STATE_UC_STATIC)
>> +				fdb->ndm_state = NUD_NOARP;
>> +			else
>> +				fdb->ndm_state = NUD_REACHABLE;
>>  		}
>> +
>> +		err = cb(obj);
>> +		if (err)
>> +			return err;
>>  	} while (!is_broadcast_ether_addr(addr.mac));
>
> Humm, maybe i'm reading this patch wrong....
>
> This function is called mv88e6xxx_port_db_dump_one(). But i don't see
> a way out of the while loop, after dumping one. It seems to dump the
> whole table until it reaches the end marker, which is the MAC
> broadcast address.
>
> Should we rename this function, drop the _one?

No. mv88e6xxx_port_db_dump already exists, this is the function called
mv88e6xxx_port_db_dump_one multiple time. Here, _one refers to an FID
(forwarding database). 88E6352 have 4096 FIDs.

The way to dump a single FID is to run the ATU GetNext operation
starting with ff:ff:ff:ff:ff:ff, until that same address is reached
again. This is what mv88e6xxx_port_db_dump_one does.

mv88e6xxx_port_db_dump first dump the port's assigned FID (i.e. VID 0),
then iterate on active VLANs to get and dump their FIDs.

Thanks,

        Vivien
