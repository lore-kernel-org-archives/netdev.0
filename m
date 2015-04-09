From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Thu, 09 Apr 2015 13:44:44 +0200
Message-ID: <5526662C.8010509@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>,
	Daniel Mack <zonque@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:27492 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755219AbbDILox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:44:53 -0400
In-Reply-To: <5525658D.7000709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Problem with Atheros AR8035 PHY reset ]

Florian Fainelli wrote:

> Mason wrote:
>
>> I have a weird problem, that I've only started investigating, and I'd be
>> grateful if anyone can help me along.
>>
>> I have an ARM-based SoC that provides (AFAIU) an Atheros 8035 PHY.
>>
>> If I enable the driver in my kernel (CONFIG_AT803X_PHY) then something
>> goes wrong, and the system cannot load the nfsroot. Bizarrely, DHCP
>> seems to work (so there is limited connectivity) but then the NFS
>> server just times out.
>>
>> However, if I just comment this line:
>>      //.config_init = at803x_config_init,
>> in at803x_driver[0]
>> then everything seems to work. (At least, the system sets the PHY
>> to Gbit, and manages to download the nfsroot.)
>>
>> If I'm reading the code right (big "if"), when config_init is NULL,
>> then phy_init_hw() turns into a NOP?
>>
>> So either at803x_config_init() or something called from phy_init_hw()
>> seems to be hosing this system's networking?
>>
>> Sprinkling printk over phy_init_hw shows no errors (no premature exit)
>> and phydev->drv->config_init(phydev) returns 0.
>>
>> Maybe I didn't set something up correctly, and phy_write() is scribbling
>> over the wrong register?
>>
>> Does anyone see something I missed?
>
> So one possibility could be that the bootloader initializes the PHY in a
> certain way, typically by applying workarounds, and your config_init()
> callback is not restoring any of theses, which is why, after
> phy_init_hw(), which does a software reset of the PHY, all of these
> workarounds are wiped out, and your PHY behaves funky.
>
> The reason why config_init() needs to put the PHY back into a fully
> functional state is because the PHY library should be able to software
> reset the PHY when it needs to, but also be able to deal with deep sleep
> modes etc.. where the PHY could loose its settings, yet the kernel
> should be able to bring you back in a good state.
>
> An easy way to bypass that is to provide a soft_reset callback which does
> nothing, and see if calling either at803x_config_init(), or
> genphy_config_init() is sufficient to preserve the PHY settings.
> Although the real solution is to look at what the bootloader does on
> that front and replicate it in the config_init() callback.

Here is the data sheet for the AR8035:
http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf

It seems the problem comes from the fact that the PHY treats
HW reset and SW reset differently:

     HW reset: registers are set to specific values
     SW reset: some bits are retained across reset

Case in point: the control register (BMCR)
HW reset: BMCR = 0x3100
SW reset: retain bits[6,8,12,13] / other bits = 0

(0x3100 means bit_6=0, bit_8=bit_12=bit_13=1)

When we execute this line from genphy_soft_reset()

     phy_write(phydev, MII_BMCR, BMCR_RESET);

we reset the bits in BMCR, and SW reset does not restore them.

It seems to me (please tell me if I am wrong) that it should
be safe for all PHYs to write old_val | BMCR_RESET, instead of
just BMCR_RESET. Thus...

On chips that REALLY reset, the old_val bits will be discarded;
while on chips that retain some bits, we do want to keep them.

So the patch would go something like below. What do you think?

Regards


diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bdfe51f..4bcbde3 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1087,9 +1087,10 @@ static int gen10g_read_status(struct phy_device *phydev)
   */
  int genphy_soft_reset(struct phy_device *phydev)
  {
-       int ret;
+       int ret, val;
  
-       ret = phy_write(phydev, MII_BMCR, BMCR_RESET);
+       val = phy_read (phydev, MII_BMCR);
+       ret = phy_write(phydev, MII_BMCR, val | BMCR_RESET);
         if (ret < 0)
                 return ret;
  
