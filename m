From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Add basic offloading of
 unicast traffic
Date: Fri, 22 Sep 2017 09:23:39 +0200
Message-ID: <194908d7-20ce-5779-0cb8-be656197d3ec@egil-hjelmeland.no>
References: <20170921094139.4250-1-privat@egil-hjelmeland.no>
 <20170921094139.4250-3-privat@egil-hjelmeland.no>
 <87k20sqg9d.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k20sqg9d.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Den 21. sep. 2017 16:26, skrev Vivien Didelot:
> Hi Egil,
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>> When both user ports are joined to the same bridge, the normal
>> HW MAC learning is enabled. This means that unicast traffic is forwarded
>> in HW.
>>
>> If one of the user ports leave the bridge,
>> the ports goes back to the initial separated operation.
>>
>> Port separation relies on disabled HW MAC learning. Hence the condition
>> that both ports must join same bridge.
>>
>> Add brigde methods port_bridge_join, port_bridge_leave and
>> port_stp_state_set.
>>
>> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
> 
> Styling nitpicks below, other than that, the patch LGTM:
> 
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
>>   #include <linux/mutex.h>
>>   #include <linux/mii.h>
>>   #include <linux/phy.h>
>> +#include <linux/if_bridge.h>
> 
> It's nice to order header inclusions alphabetically.
> 
>>   
>>   #include "lan9303.h"
>>   
>> @@ -146,6 +147,7 @@
>>   # define LAN9303_SWE_PORT_STATE_FORWARDING_PORT0 (0)
>>   # define LAN9303_SWE_PORT_STATE_LEARNING_PORT0 BIT(1)
>>   # define LAN9303_SWE_PORT_STATE_BLOCKING_PORT0 BIT(0)
>> +# define LAN9303_SWE_PORT_STATE_DISABLED_PORT0 (3)
>>   #define LAN9303_SWE_PORT_MIRROR 0x1846
>>   # define LAN9303_SWE_PORT_MIRROR_SNIFF_ALL BIT(8)
>>   # define LAN9303_SWE_PORT_MIRROR_SNIFFER_PORT2 BIT(7)
>> @@ -431,6 +433,20 @@ static int lan9303_read_switch_reg(struct lan9303 *chip, u16 regnum, u32 *val)
>>   	return ret;
>>   }
>>   
>> +static int lan9303_write_switch_reg_mask(
>> +	struct lan9303 *chip, u16 regnum, u32 val, u32 mask)
> 
> That is unlikely to respect the Kernel Coding Style. Please fill the
> line as much as possible and align with the opening parenthesis:
> 
>      static int lan9303_write_switch_reg_mask(struct lan9303 *chip, u16 regnum,
>                                               u32 val, u32 mask)
> 
OK. Probably this function will go away in v2 due to Andrews comment.

>> +{
>> +	int ret;
>> +	u32 reg;
>> +
>> +	ret = lan9303_read_switch_reg(chip, regnum, &reg);
>> +	if (ret)
>> +		return ret;
>> +	reg = (reg & ~mask) | val;
>> +
>> +	return lan9303_write_switch_reg(chip, regnum, reg);
>> +}
> 
> ...
> 
>> +
>> +	portmask = 0x3 << (port * 2);
>> +	portstate     <<= (port * 2);
> 
> Unnecessary alignment, please remove the extra space characters.
> 

I think the alignment makes the logic more clear.


>> +	lan9303_write_switch_reg_mask(chip, LAN9303_SWE_PORT_STATE,
>> +				      portstate, portmask);
>> +}
>> +
>>   static const struct dsa_switch_ops lan9303_switch_ops = {
>>   	.get_tag_protocol = lan9303_get_tag_protocol,
>>   	.setup = lan9303_setup,
>> @@ -855,6 +940,9 @@ static const struct dsa_switch_ops lan9303_switch_ops = {
>>   	.get_sset_count = lan9303_get_sset_count,
>>   	.port_enable = lan9303_port_enable,
>>   	.port_disable = lan9303_port_disable,
>> +	.port_bridge_join       = lan9303_port_bridge_join,
>> +	.port_bridge_leave      = lan9303_port_bridge_leave,
>> +	.port_stp_state_set     = lan9303_port_stp_state_set,
> 
> Same here, alignment unnecessary, especially since the rest of the
> structure does not do that.
> 
>>   };
>>   
>>   static int lan9303_register_switch(struct lan9303 *chip)
>> diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
>> index 4d8be555ff4d..5be246f05965 100644
>> --- a/drivers/net/dsa/lan9303.h
>> +++ b/drivers/net/dsa/lan9303.h
>> @@ -21,6 +21,7 @@ struct lan9303 {
>>   	struct dsa_switch *ds;
>>   	struct mutex indirect_mutex; /* protect indexed register access */
>>   	const struct lan9303_phy_ops *ops;
>> +	bool is_bridged; /* true if port 1 and 2 is bridged */
>>   };
>>   
>>   extern const struct regmap_access_table lan9303_register_set;
> 
> Please use the checkpatch.pl script to ensure your patch respects the
> kernel conventions before submitting, it can spot nice stuffs!

I have checked _every_ patch with checkpatch.pl and weeded all warnings
before I submitted them.

> 
> I use a Git alias(*) to check a commit which does basically this:
> 
>      git format-patch --stdout -1 | ./scripts/checkpatch.pl -
> 
> 
> (*) in details, especially convenient during interactive rebases:
> 
>      $ git config alias.checkcommit '!f () { git format-patch --stdout -1 ${1:-HEAD} | ./scripts/checkpatch.pl - ; }; f'
>      $ git checkcommit # i.e. current one
>      $ git checkcommit HEAD^^
>      $ git checkcommit d329ac88eb21
>      ...
> 
> 
> Thanks,
> 
>          Vivien
> 
