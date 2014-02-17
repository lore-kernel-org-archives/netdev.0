From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Tue, 18 Feb 2014 01:08:23 +0300
Message-ID: <53028857.8050206@cogentembedded.com>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk> <1392642484-19938-2-git-send-email-ben.dooks@codethink.co.uk> <CAGVrzcYbw5xLj-gwcup5i0gBdKDDGdyy5wAaEBp7m2E7f2bytg@mail.gmail.com> <5302801F.6000903@cogentembedded.com> <CAGVrzcbZC3t0oexc5Aj-KyGj-qC8J9eYp8+rb8V-AqKtrSjyYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Mark Rutland <mark.rutland@arm.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcbZC3t0oexc5Aj-KyGj-qC8J9eYp8+rb8V-AqKtrSjyYw@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/17/2014 11:48 PM, Florian Fainelli wrote:

>>>> Add new init-regs field for of_phy nodes and make sure these
>>>> get applied when the phy is configured.

>>>> This allows any phy node in an fdt to initialise registers
>>>> that may not be set as standard by the driver at initialisation
>>>> time, such as LED controls.

>>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
[...]

>>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>>>> index 82514e7..6741cdb 100644
>>>> --- a/drivers/net/phy/phy_device.c
>>>> +++ b/drivers/net/phy/phy_device.c

>> [...]

>>>> @@ -532,6 +533,57 @@ static int phy_poll_reset(struct phy_device *phydev)
>>>>           return 0;
>>>>    }
>>>>
>>>> +#ifdef CONFIG_OF
>>>> +static int of_phy_configure(struct phy_device *phydev)
>>>> +{
>>>> +       struct device *dev = &phydev->dev;
>>>> +       struct device_node *of_node = dev->of_node;
>>>> +       struct property *prop;
>>>> +       const __be32 *ptr;
>>>> +       u32 reg, set, clear;
>>>> +       int len;
>>>> +       int val;

>>> This does not belong in the generic PHY code unless we are very clear
>>> on what we want to do, and how to do it, which I do not think we are
>>> yet. What exactly is needed here:

>>> - fixing up some design mistake?
>>> - accounting for a specific board design?

>>     Kind of both. This was invented to defy the necessity of having platform
>> fixup in the DT case (where there should be no board file to place it into).
>> I have already described that platform fixup necessary on the Renesas
>> Lager/Koelsch boards where the LED0 signat is connected to ETH_LINK signal
>> on the SoC and the PHY reset sets the LED control bits to default 0 which
>> means that LED0 will be LINK/ACTIVITY signal and thus blink on activity and
>> cause ETH_LINK to bounce off/on after each packet.

>>> In any case a PHY fixup would do the job for you.

>>     Not in any case. In case of DT we have no place for it, so should invent
>> something involving DT.

> How is DT different than any machine probing mechanism here?

    There supposed to be no board files. The purpose of DT is to get rid of 
the board files, at least on ARM.

> The way to involve DT is to do the following:

> if (of_machine_is_compatible("renesas,foo-board-with-broken-micrel-phy"))
>             phy_register_fixup(&foo_board_with_broken_micrel_phy);

    Where are you suggesting to place such code? arch/arm/mach-shmobile/setup-*.c?

> If your machine compatible string does not allow you to uniquely
> identify your machine, this is a DT problem, as this should really be
> the case. If you do not want to add this code to wherever this is
> relevant in arch/arm/mach-shmobile/board-*.c,

    There just should be no such file for DT case.

> neither is drivers/net/phy/phy_device.c this the place to add it.

    Hey, I wasn't arguing with that! :-)

> Dealing with quirks applying to industry standard blocks is to update
> the relevant driver, based on information provided by the specifically
> affected systems. Failure to identify either of those correctly is a
> problem that must not lead to a generic "let's override PHY registers
> from DT" type of solution.

> As usual, mechanism vs policy applies even more when DT is involved.

    Ah, so you're suggesting placing the fixup code in the driver itself?
That's a bit strange for the platform specific code, but would do I guess...

WBR, Sergei

