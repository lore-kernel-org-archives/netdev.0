From: Matthias May <matthias.may@neratec.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: debug ATU Age Time
Date: Tue, 14 Mar 2017 12:12:45 +0100
Message-ID: <535be006-e384-aca3-ee8b-4ed36b66b97a@neratec.com>
References: <20170313192043.12478-1-vivien.didelot@savoirfairelinux.com>
 <20170313223932.GC14183@lunn.ch>
 <b7d0e92f-45cb-929d-a724-2a582621f8e1@gmail.com>
 <20170313225845.GE14183@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cobham <jcobham@questertangent.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170313225845.GE14183@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/03/17 23:58, Andrew Lunn wrote:
> On Mon, Mar 13, 2017 at 03:42:36PM -0700, Florian Fainelli wrote:
>> On 03/13/2017 03:39 PM, Andrew Lunn wrote:
>>> On Mon, Mar 13, 2017 at 03:20:43PM -0400, Vivien Didelot wrote:
>>>> The ATU ageing time value programmed in the switch is rounded up to the
>>>> nearest multiple of its coefficient (variable depending on the model.)
>>>>
>>>> Add a debug message to inform the user about the exact programmed value.
>>>>
>>>> On 6352, "brctl setageing br0 18" gives "AgeTime set to 0x01 (15000 ms)"
>>>> while on 6390 we get "AgeTime set to 0x05 (18750 ms)".
>>>>
>>>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>>>> ---
>>>>  drivers/net/dsa/mv88e6xxx/global1_atu.c | 9 ++++++++-
>>>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
>>>> index f6cd3c939da4..bac34737b096 100644
>>>> --- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
>>>> +++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
>>>> @@ -65,7 +65,14 @@ int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
>>>>  	val &= ~0xff0;
>>>>  	val |= age_time << 4;
>>>>  
>>>> -	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
>>>> +	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
>>>> +	if (err)
>>>> +		return err;
>>>> +
>>>> +	dev_dbg(chip->dev, "AgeTime set to 0x%02x (%d ms)\n", age_time,
>>>> +		age_time * coeff);
>>>> +
>>>
>>> Hi Vivien
>>>
>>> You could put the dev_dbg before the mv88e6xxx_g1_write(), to keep the
>>> code simpler. If this write fails, we expect a lot of other things to
>>> go horribly wrong, so having one debug message being not quite accurate
>>> is not important.
>>
>> The debug message would not be printed in case mv88e6xxx_g1_write()
>> fails, also, having the message printed after the write occurred is a
>> good way to make sure the write did make it through. Did I miss
>> something in what you are suggesting here?
> 
> We never, ever see a read or a write failure on the MDIO bus. If it
> ever does, i expect the switch is dead, gone, never to be heard from
> again until the power is reset. We are going to have lots of
> failures. So it seems simpler to have:
> 
> 	dev_dbg(chip->dev, "Setting AgeTime to 0x%02x (%d ms)\n", age_time,
> 		age_time * coeff);
> 
> 	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
> 
> and accept that if for some unlikely reason the write does fail, the
> debug message is probably not accurate.
> 
>       Andrew
> 

Hi
The never ever seeing R/W failure on MDIO bus is not exactly accurate.
We had with art (atheros calibration tool) the problem that interrupts
were being disabled which lead to MDIO operations running into
timout/failing.
For normal phys this usually results in calling phy_error in
.../net/phy/phy.c which puts the phy into a defined state (PHY_HALTED).
Granted this is a problem produced by art2 but couldn't the same be
applied here? Put the device in a defined state?

BR
Matthias
