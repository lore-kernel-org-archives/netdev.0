From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] of_mdio: Allow the DT to specify the phy ID and avoid autoprobing
Date: Fri, 31 Jan 2014 15:28:10 -0800
Message-ID: <CAGVrzcZwkHSLJxpVsVY_6-VnsuODs0vGKcrcvSBzMEq3GWxqLA@mail.gmail.com>
References: <1391205045-1751-1-git-send-email-jgunthorpe@obsidianresearch.com>
 <1391205045-1751-2-git-send-email-jgunthorpe@obsidianresearch.com>
 <CAGVrzcbVo-Zzm9kLhiptf-qWgPH9XSs29mW8g2=g=Bq=PCb0_w@mail.gmail.com> <20140131225513.GA2519@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140131225513.GA2519@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-01-31 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>:
> On Fri, Jan 31, 2014 at 02:24:52PM -0800, Florian Fainelli wrote:
>
>> > This is necessary to support phy's that cannot be autoprobed when
>> > of_mdiobus_register is called. Specifically, my case has the phy in reset at
>> > of_mdiobus_register, the reset is only released once the ethernet driver
>> > starts, before it attaches to the phy.
>>
>> Who is responsible for bringing the PHY out of reset, is it the
>> Ethernet/MDIO bus driver? Is the PHY put into reset using, e.g a GPIO
>> line or any sort of reset controller, if so, should not we have some
>> sort of reset handle node and handle that in a generic manner?
>
> The Phy Reset is connected to a GPIO, and the ethernet driver has code
> to switch the GPIO out of reset. The phy is kept in reset until the
> ethernet device is opened, and Linux is booted with the phy reset
> asserted.
>
>> Is your DTS or DTB hardcoding the PHY id, or are you having your
>> bootloader detect the exact PHY for you, then putting back the PHY
>> into reset to save power, until someone uses that PHY again?
>
> For our uses the Phy ID is hardcoded. There is only a single part that
> will fit on the board. So the bootloader doesn't touch the phy. If
> there were alternate parts we'd get the part kind from the EEPROM that
> stores the MAC address/etc.
>
>> > +       while (cplen > 0) {
>> > +               if (sscanf(cp, "ethernet-phy-id%4x.%4x", &upper, &lower) == 2) {
>>
>> You might want to guard against 0x0 and 0xffff just in case whoever
>> fills this information in the Device Tree was reading bogus data out
>> of the MDIO bus, otherwise, chances are that the "Generic PHY" driver
>> will be picked up, and it might still not be appropriate for driving
>> your PHY chip.
>
> Having the bootloader read the phy ID just to fill in this compatible
> string isn't really the point. In every normal case I think it makes
> sense to let Linux autoprobe the phy id. The use for this compatible
> string is to defeat the autoprobe for situations where it is not
> appropriate.

This is well understood, I just think there a few different ways to
proceed with your use case here:

- you allow for a compatible string to defeat auto-probing like you just did
- you tell of_mdiobus_register() to look for a reset phandle and have
a reset controller release the PHY from reset before it tries to probe
for it, because doing that could avoid doing the PHY out of reset
sequence in a few dozen Ethernet drivers

The auto-probing bypass logic looks simple enough, and it does not
require burying the reset logic behind a reset controller, which uses
regmap and a few dozens layers down the road to toggle a bit somewhere
in a register, although this might be the desired way to move forward
if we want that to be generalized.

Anyway:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
