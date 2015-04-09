From: Daniel Mack <daniel@zonque.org>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is commented
 out
Date: Thu, 09 Apr 2015 15:36:46 +0200
Message-ID: <5526806E.5020309@zonque.org>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Mason <slash.tmp@free.fr>, Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:43141 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752833AbbDINgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 09:36:50 -0400
In-Reply-To: <5526662C.8010509@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 04/09/2015 01:44 PM, Mason wrote:
> Florian Fainelli wrote:
>> So one possibility could be that the bootloader initializes the PHY in a
>> certain way, typically by applying workarounds, and your config_init()
>> callback is not restoring any of theses, which is why, after
>> phy_init_hw(), which does a software reset of the PHY, all of these
>> workarounds are wiped out, and your PHY behaves funky.
>>
>> The reason why config_init() needs to put the PHY back into a fully
>> functional state is because the PHY library should be able to software
>> reset the PHY when it needs to, but also be able to deal with deep sleep
>> modes etc.. where the PHY could loose its settings, yet the kernel
>> should be able to bring you back in a good state.
>>
>> An easy way to bypass that is to provide a soft_reset callback which does
>> nothing, and see if calling either at803x_config_init(), or
>> genphy_config_init() is sufficient to preserve the PHY settings.
>> Although the real solution is to look at what the bootloader does on
>> that front and replicate it in the config_init() callback.
> 
> Here is the data sheet for the AR8035:
> http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf
> 
> It seems the problem comes from the fact that the PHY treats
> HW reset and SW reset differently:
> 
>      HW reset: registers are set to specific values
>      SW reset: some bits are retained across reset
> 
> Case in point: the control register (BMCR)
> HW reset: BMCR = 0x3100
> SW reset: retain bits[6,8,12,13] / other bits = 0
> 
> (0x3100 means bit_6=0, bit_8=bit_12=bit_13=1)
> 
> When we execute this line from genphy_soft_reset()
> 
>      phy_write(phydev, MII_BMCR, BMCR_RESET);
> 
> we reset the bits in BMCR, and SW reset does not restore them.
> 
> It seems to me (please tell me if I am wrong) that it should
> be safe for all PHYs to write old_val | BMCR_RESET, instead of
> just BMCR_RESET. Thus...
> 
> On chips that REALLY reset, the old_val bits will be discarded;
> while on chips that retain some bits, we do want to keep them.
> 
> So the patch would go something like below. What do you think?

I don't think that'll work, because writing a 1 into the RESET bit of
the register causes the PHY to enter its software reset routine
immediately. The other bits should hence be reset to their defaults,
regardless of what you set them to at the same time.

My suggestion is to dump the entire register set when
at803x_config_init() is entered and again when it's left. Then try to
find the differences and see if you can bring the PHY into the needed
mode through the exisiting configuration hooks in the kernel.

Note that it really should be possible for the kernel to bring the PHY
into the mode needed for your board. Relying on the bootloader to do the
magic is fragile, and as Florian said, this will break once a suspend
mode switches off the power domain that feeds the PHY.


Thanks,
Daniel
