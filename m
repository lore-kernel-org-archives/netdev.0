From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Thu, 09 Apr 2015 16:38:43 +0200
Message-ID: <55268EF3.7050301@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Daniel Mack <daniel@zonque.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:24602 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754150AbbDIOiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 10:38:50 -0400
In-Reply-To: <5526806E.5020309@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 09/04/2015 15:36, Daniel Mack wrote:
> On 04/09/2015 01:44 PM, Mason wrote:
>> Florian Fainelli wrote:
>>> So one possibility could be that the bootloader initializes the PHY in a
>>> certain way, typically by applying workarounds, and your config_init()
>>> callback is not restoring any of theses, which is why, after
>>> phy_init_hw(), which does a software reset of the PHY, all of these
>>> workarounds are wiped out, and your PHY behaves funky.
>>>
>>> The reason why config_init() needs to put the PHY back into a fully
>>> functional state is because the PHY library should be able to software
>>> reset the PHY when it needs to, but also be able to deal with deep sleep
>>> modes etc.. where the PHY could loose its settings, yet the kernel
>>> should be able to bring you back in a good state.
>>>
>>> An easy way to bypass that is to provide a soft_reset callback which does
>>> nothing, and see if calling either at803x_config_init(), or
>>> genphy_config_init() is sufficient to preserve the PHY settings.
>>> Although the real solution is to look at what the bootloader does on
>>> that front and replicate it in the config_init() callback.
>>
>> Here is the data sheet for the AR8035:
>> http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf
>>
>> It seems the problem comes from the fact that the PHY treats
>> HW reset and SW reset differently:
>>
>>       HW reset: registers are set to specific values
>>       SW reset: some bits are retained across reset
>>
>> Case in point: the control register (BMCR)
>> HW reset: BMCR = 0x3100
>> SW reset: retain bits[6,8,12,13] / other bits = 0
>>
>> (0x3100 means bit_6=0, bit_8=bit_12=bit_13=1)
>>
>> When we execute this line from genphy_soft_reset()
>>
>>       phy_write(phydev, MII_BMCR, BMCR_RESET);
>>
>> we reset the bits in BMCR, and SW reset does not restore them.
>>
>> It seems to me (please tell me if I am wrong) that it should
>> be safe for all PHYs to write old_val | BMCR_RESET, instead of
>> just BMCR_RESET. Thus...
>>
>> On chips that REALLY reset, the old_val bits will be discarded;
>> while on chips that retain some bits, we do want to keep them.
>>
>> So the patch would go something like below. What do you think?
>
> I don't think that'll work, because writing a 1 into the RESET bit of
> the register causes the PHY to enter its software reset routine
> immediately. The other bits should hence be reset to their defaults,
> regardless of what you set them to at the same time.

I'm confused by your answer, because it seems to be ignoring the
whole "some bits retain their value across SW reset" issue?

This can be settled quickly by an execution trace.
(Note, I'm using kernel 3.14)

I have instrumented phy_init_hw thus:
(I've also added a printk after phy_poll_reset)

	printk("BMCR = 0x%x\n", (unsigned)phy_read (phydev, MII_BMCR));
#if 0
	val = phy_read (phydev, MII_BMCR);
	ret = phy_write(phydev, MII_BMCR, val | BMCR_RESET);
#else
	ret = phy_write(phydev, MII_BMCR, BMCR_RESET);
#endif
	printk("BMCR = 0x%x\n", (unsigned)phy_read (phydev, MII_BMCR));


Running the #else branch outputs:
[    0.623188] BMCR = 0x3100
[    0.625957] BMCR = 0x0
[    0.686817] BMCR = 0x0

Running the #if branch outputs:
[    0.623151] BMCR = 0x3100
[    0.625979] BMCR = 0x3100
[    0.686817] BMCR = 0x3100

As you can see, writing val | BMCR_RESET is required on this PHY.

> My suggestion is to dump the entire register set when
> at803x_config_init() is entered and again when it's left. Then try to
> find the differences and see if you can bring the PHY into the needed
> mode through the existing configuration hooks in the kernel.

Good idea.

[    0.685330] IDX= 1 796d != 7949
[    0.688490] IDX= 5 c1e1 != 0000
[    0.691647] IDX= 6 000f != 0004
[    0.694803] IDX=10 3800 != 0000
[    0.697960] IDX=17 bc10 != 0012
[    0.701115] IDX=19 7400 != 0000
[    0.704271] IDX=27 060e != 0600

Hmmm, didn't expect so many differences. I'll have to take a closer look.

> Note that it really should be possible for the kernel to bring the PHY
> into the mode needed for your board. Relying on the bootloader to do the
> magic is fragile, and as Florian said, this will break once a suspend
> mode switches off the power domain that feeds the PHY.

Uboot dev boards, uboot runs (and uboot speaks Ethernet). I don't know if
uboot tweaks the PHY. But on production boards, there is no uboot, and the
early bootloaders don't touch the PHY.

Regards.
