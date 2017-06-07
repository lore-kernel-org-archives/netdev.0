From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/5] net: dsa: mv88e6xxx: do not purge a VTU entry
Date: Wed, 07 Jun 2017 15:59:15 -0400
Message-ID: <87shjbfu24.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com> <20170606205631.22880-6-vivien.didelot@savoirfairelinux.com> <ae09e920-fcea-ac29-3b2d-51275e0fec56@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ae09e920-fcea-ac29-3b2d-51275e0fec56@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 06/06/2017 01:56 PM, Vivien Didelot wrote:
>> The mv88e6xxx driver currently tries to be smart and remove by itself a
>> VLAN entry from the VTU when the driven switch sees no user ports as
>> members of the VLAN.
>> 
>> This is bad in a multi-chip switch fabric, since a chip in between
>> others may have no bridge port members, but still needs to be aware of
>> the VID in order to correctly pass frames in the data path.
>> 
>> Remove the code purging a VTU entry when updating a port membership.
>
> In that case the switch sitting between two other chips and passing
> traffic would still have at least two of its DSA ports be part of a VTU
> entry, right?

That is correct.

>
> So could not we just do ....
>
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>  drivers/net/dsa/mv88e6xxx/chip.c | 15 +--------------
>>  1 file changed, 1 insertion(+), 14 deletions(-)
>> 
>> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
>> index 522f023bb17e..64c0f88f9e79 100644
>> --- a/drivers/net/dsa/mv88e6xxx/chip.c
>> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
>> @@ -1325,9 +1325,8 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
>>  static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
>>  				    int port, u16 vid)
>>  {
>> -	struct dsa_switch *ds = chip->ds;
>>  	struct mv88e6xxx_vtu_entry vlan;
>> -	int i, err;
>> +	int err;
>>  
>>  	err = mv88e6xxx_vtu_get(chip, vid, &vlan, false);
>>  	if (err)
>> @@ -1339,18 +1338,6 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
>>  
>>  	vlan.member[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
>>  
>> -	/* keep the VLAN unless all ports are excluded */
>> -	vlan.valid = false;
>> -	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
>> -		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
>> -			continue;
>
> ... break the loop here?

I can remove only the dsa_is_{cpu,dsa}_port condition above, this will
make the code ready for when the DSA core will remove VLAN on DSA ports.

Thanks!

        Vivien
