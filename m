From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY
 ID on mv88e6390
Date: Wed, 25 Jan 2017 09:51:57 -0800
Message-ID: <f5bd0144-5053-77ad-a507-2ca3ea1df486@gmail.com>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
 <1485309314-23942-2-git-send-email-andrew@lunn.ch>
 <87sho7123x.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33701 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751960AbdAYRwO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 12:52:14 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so14776114pfg.0
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 09:52:09 -0800 (PST)
In-Reply-To: <87sho7123x.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2017 09:27 AM, Gregory CLEMENT wrote:
> Hi Andrew,
>  
>  On mer., janv. 25 2017, Andrew Lunn <andrew@lunn.ch> wrote:
> 
>> The internal PHYs of the mv88e6390 do not have a model ID. Trap any
>> calls to the ID register, and if it is zero, return the ID for the
>> mv88e6390. The Marvell PHY driver can then bind to this ID.
>>
>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/dsa/mv88e6xxx/global2.c | 16 +++++++++++++++-
>>  1 file changed, 15 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
>> index 353e26bea3c3..521a5511bd5f 100644
>> --- a/drivers/net/dsa/mv88e6xxx/global2.c
>> +++ b/drivers/net/dsa/mv88e6xxx/global2.c
>> @@ -520,7 +520,21 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
>>  	if (err)
>>  		return err;
>>  
>> -	return mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
>> +	err = mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
>> +	if (err)
>> +		return err;
>> +
>> +	if (reg == MII_PHYSID2) {
>> +		/* The mv88e6390 internal PHYS don't have a model number.
>> +		 * Use the switch family model number instead.
>> +		 */
>> +		if (!(*val & 0x3ff)) {
> 
> I tested this series on the Topaz switch but it failed because while I
> said we read 0x1410C00 actually we read 0x01410C01. With the
> MARVELL_PHY_ID_MASK we mask the 4 lower bits so that's why in my patch
> "phy: marvell: Add support for the PHY embedded in the topaz switch" I
> used the 0x01410C00 value for MARVELL_PHY_ID_88E6141.
> 
> However with the mask you use it doesn't work.
> 
> So this mask should be changed to 0x3f0 for the Topaz. Actually 0x3fe
> would be enough but it seems more logical to use the same mask that for
> MARVELL_PHY_ID_MASK.
> 
> We could either use the same mask for both family and still use 6390 as
> they seem compatible or we use two different families based on the lower
> bit.

By convention, the lower 4 bits are used to carry revision information,
which is why most drivers use 0xxxxx_fff0, can you try to use that here
for the PHY mask value?
-- 
Florian
