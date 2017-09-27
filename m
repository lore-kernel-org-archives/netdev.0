From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames
 in hardware
Date: Wed, 27 Sep 2017 11:37:54 -0700
Message-ID: <9733da02-0b69-33f0-de8a-63bc5cae6bb4@gmail.com>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
 <1506464764-12699-7-git-send-email-andrew@lunn.ch>
 <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38504 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdI0Sh7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 14:37:59 -0400
Received: by mail-wr0-f196.google.com with SMTP id p37so5999323wrb.5
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 11:37:59 -0700 (PDT)
In-Reply-To: <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2017 11:24 AM, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
>> +static int mv88e6xxx_port_add_broadcast(struct mv88e6xxx_chip *chip, int port,
>> +					u16 vid)
>> +{
>> +	const char broadcast[6] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
>> +
>> +	return mv88e6xxx_port_db_load_purge(
>> +		chip, port, broadcast, vid,
>> +		MV88E6XXX_G1_ATU_DATA_STATE_MC_STATIC);
> 
> Please don't do this. This is not a valid coding style and has already
> shown to be a bad example for other DSA drivers copying mv88e6xxx.
> 
> Simply declare u8 state = MV88E6XXX_G1_ATU_DATA_STATE_MC_STATIC above...
> 
>> +}
>> +
>> +static int mv88e6xxx_broadcast_setup(struct mv88e6xxx_chip *chip, u16 vid)
>> +{
>> +	int port;
>> +	int err;
>> +
>> +	for (port = 0; port < mv88e6xxx_num_ports(chip); ++port) {
>> +		err = mv88e6xxx_port_add_broadcast(chip, port, vid);
>> +		if (err)
>> +			return err;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>>  static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
>>  				    u16 vid, u8 member)
>>  {
>> @@ -1247,7 +1271,11 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
>>  
>>  	vlan.member[port] = member;
>>  
>> -	return mv88e6xxx_vtu_loadpurge(chip, &vlan);
>> +	err = mv88e6xxx_vtu_loadpurge(chip, &vlan);
>> +	if (err)
>> +		return err;
>> +
>> +	return mv88e6xxx_broadcast_setup(chip, vid);
>>  }
>>  
>>  static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
>> @@ -2025,6 +2053,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
>>  	if (err)
>>  		goto unlock;
>>  
>> +	err = mv88e6xxx_broadcast_setup(chip, 0);
>> +	if (err)
>> +		goto unlock;
>> +
>>  	err = mv88e6xxx_pot_setup(chip);
>>  	if (err)
>>  		goto unlock;
> 
> 
> Adding the broadcast address to an Ethernet switch's FDB is pretty
> generic and mv88e6xxx mustn't be the only driver doing this.

I have not had time to test Andrew's IGMP patch set on bcm_sf2/b53, but
while I agree that adding a broadcast address using a FDB entry is
generic in premise, we don't know yet whether other switch drivers need
that or not, so until we do, it seems like Andrew's approach is
appropriate here by keeping this local to mv88e6xxx.

> 
> They do not have to care about the broadcast address, this is just a
> standard MDB entry for them. This must be moved up to the DSA layer.
> 
> Adding the broadcast address in dsa_port_vlan_add and dsa_port_enable
> like this should be enough: http://ix.io/AmS
> 

What if I don't have CONFIG_BRIDGE_VLAN_FILTERING enabled, what happens
in that case, would not this result in not programming the broadcast
address?
-- 
Florian
