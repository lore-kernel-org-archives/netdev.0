From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Tue, 18 Feb 2014 00:33:19 +0300
Message-ID: <5302801F.6000903@cogentembedded.com>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk> <1392642484-19938-2-git-send-email-ben.dooks@codethink.co.uk> <CAGVrzcYbw5xLj-gwcup5i0gBdKDDGdyy5wAaEBp7m2E7f2bytg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcYbw5xLj-gwcup5i0gBdKDDGdyy5wAaEBp7m2E7f2bytg@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/17/2014 08:33 PM, Florian Fainelli wrote:

>> Add new init-regs field for of_phy nodes and make sure these
>> get applied when the phy is configured.

>> This allows any phy node in an fdt to initialise registers
>> that may not be set as standard by the driver at initialisation
>> time, such as LED controls.

>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>> ---
>>   Documentation/devicetree/bindings/net/phy.txt | 12 ++++++
>>   drivers/net/phy/phy_device.c                  | 59 ++++++++++++++++++++++++++-
>>   2 files changed, 70 insertions(+), 1 deletion(-)

>> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
>> index 58307d0..48d8ded 100644
>> --- a/Documentation/devicetree/bindings/net/phy.txt
>> +++ b/Documentation/devicetree/bindings/net/phy.txt
>> @@ -20,6 +20,8 @@ Optional Properties:
>>     assume clause 22. The compatible list may also contain other
>>     elements.
>>   - max-speed: Maximum PHY supported speed (10, 100, 1000...)
>> +- init-regs: Set of registers to modify at initialisation as a
>> +    a set of <register set clear>

> Should be:

> "micrel,led-control-init-val" or something like that.

> first cell is the register address, according to the IEEE 802.3 clause 22
> second cell is the set bitmask to apply to the register address
> specified in the first cell
> third cell is the clear bitmask to apply to the register address
> specified in the second cell

> I would rather see this as a specific PHY node DT property for setting
> the LED control register, because this is totally non-standard and you
> are touching a proprietary register here.

    Yes, I agree.

>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index 82514e7..6741cdb 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
[...]
>> @@ -532,6 +533,57 @@ static int phy_poll_reset(struct phy_device *phydev)
>>          return 0;
>>   }
>>
>> +#ifdef CONFIG_OF
>> +static int of_phy_configure(struct phy_device *phydev)
>> +{
>> +       struct device *dev = &phydev->dev;
>> +       struct device_node *of_node = dev->of_node;
>> +       struct property *prop;
>> +       const __be32 *ptr;
>> +       u32 reg, set, clear;
>> +       int len;
>> +       int val;

> This does not belong in the generic PHY code unless we are very clear
> on what we want to do, and how to do it, which I do not think we are
> yet. What exactly is needed here:

> - fixing up some design mistake?
> - accounting for a specific board design?

    Kind of both. This was invented to defy the necessity of having platform 
fixup in the DT case (where there should be no board file to place it into).
I have already described that platform fixup necessary on the Renesas 
Lager/Koelsch boards where the LED0 signat is connected to ETH_LINK signal on 
the SoC and the PHY reset sets the LED control bits to default 0 which means 
that LED0 will be LINK/ACTIVITY signal and thus blink on activity and cause 
ETH_LINK to bounce off/on after each packet.

> In any case a PHY fixup would do the job for you.

    Not in any case. In case of DT we have no place for it, so should invent 
something involving DT.

WBR, Sergei

