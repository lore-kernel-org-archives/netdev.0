From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Simplify
 lan9303_xxx_packet_processing() usage
Date: Mon, 31 Jul 2017 16:32:21 +0200
Message-ID: <3207fcff-8318-9b17-c546-026ab1a1511b@egil-hjelmeland.no>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no>
 <20170731113355.4284-3-privat@egil-hjelmeland.no>
 <87379c4sfe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87379c4sfe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31. juli 2017 16:00, Vivien Didelot wrote:
> Hi Egil,
> 
> A few nitpicks below for lan9303_disable_processing.
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>>   static int lan9303_disable_processing(struct lan9303 *chip)
>>   {
>> -	int ret;
>> +	int p;
>>   
>> -	ret = lan9303_disable_packet_processing(chip, 0);
>> -	if (ret)
>> -		return ret;
>> -	ret = lan9303_disable_packet_processing(chip, 1);
>> -	if (ret)
>> -		return ret;
>> -	return lan9303_disable_packet_processing(chip, 2);
>> +	for (p = 0; p <= 2; p++) {
> 
> Exclusive limits are often prefer, i.e. 'p < 3'.
> 
OK, that can be nice when I later introduce LAN9303_NUM_PORTS = 3.

>> +		int ret;
>> +
>> +		ret = lan9303_disable_packet_processing(chip, p);
>> +		if (ret)
>> +			return ret;
> 
> When any non-zero return code means an error, we usually see 'err'
> instead of 'ret'.
> 

But 'ret' is used throughout the rest of the file. Is it not better to
be locally consistent?

>> +	}
> 
> blank line before return statments are appreciated.
> 
OK

>> +	return 0;
>>   }
>>   
>>   static int lan9303_check_device(struct lan9303 *chip)
>> @@ -760,7 +761,6 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
>>   	/* enable internal packet processing */
>>   	switch (port) {
>>   	case 1:
>> -		return lan9303_enable_packet_processing(chip, port);
> 
> Is this deletion intentional? The commit message does not explain this.
> 
> When possible, it is appreciated to separate functional from
> non-functional changes. For example one commit adding the loop in
> lan9303_disable_processing and another one to not enable/disable packet
> processing on port 1.
> 

Case fall through, the change is purely non-functional.

You are perhaps thinking of the patch in my first series where I removed
disable of port 0. I have put that on hold. Juergen says that the
mainline driver works out of the box for him. So I will investigate
that problem bit more.


>>   	case 2:
>>   		return lan9303_enable_packet_processing(chip, port);
>>   	default:
>> @@ -779,13 +779,9 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
>>   	/* disable internal packet processing */
>>   	switch (port) {
>>   	case 1:
>> -		lan9303_disable_packet_processing(chip, port);
>> -		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 1,
>> -				  MII_BMCR, BMCR_PDOWN);
>> -		break;
>>   	case 2:
>>   		lan9303_disable_packet_processing(chip, port);
>> -		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 2,
>> +		lan9303_phy_write(ds, chip->phy_addr_sel_strap + port,
>>   				  MII_BMCR, BMCR_PDOWN);
>>   		break;
> 
> Thanks,
> 
>          Vivien
> 
Egil
