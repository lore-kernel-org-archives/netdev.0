From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Fwd: micrel: ksz8051 badly detected as ksz8031
Date: Tue, 14 Oct 2014 13:56:28 -0700
Message-ID: <543D8DFC.7010308@gmail.com>
References: <543C2954.5010609@gmail.com> <543D5C5B.9010703@gmail.com> <543D7507.3060008@gmail.com> <543D7A84.4030202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Angelo Dureghello <angelo70@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:54952 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755228AbaJNU4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:56:42 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so8411372pab.23
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 13:56:41 -0700 (PDT)
In-Reply-To: <543D7A84.4030202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2014 12:33 PM, Angelo Dureghello wrote:
> Hi Florian,
> 
>> On 10/14/2014 10:24 AM, Angelo Dureghello wrote:
>>> Dear,
>>>
>>> have to apologize for the confusion, previous patch is not the proper
>>> fix,
>>> since it is not solving completely the issue.
>>>
>>> And also, i mainly misunderstood the issue.
>>>
>>> The issue i am experiencing is :
>>>
>>> https://lkml.org/lkml/2013/9/18/259
>>>
>>> Mainly, i have Micrel chip marked KSZ8051(RNL), but the product Id in
>>> the
>>> silicon is KSZ8031 and linux detects it as KSZ8031.
>>> The attmept to mdio boot override register kill the Micrel
>>> functionality.
>> Ok, so basically your bootloader does something that Linux does, and
>> once Linux boots, it will reset the PHY to put it in a known state. If
>> you can snoop the MDIO read/writes done in your bootloader environment,
>> that might help narrow down the issue.
>>
> Bootloader is u-boot and seems it uses generic PHY setup, and so it works.
> 
> Linux at boot detects the phy and does a soft_reset. If the detection
> sets the
> driver as for KSZ8031, ethernet/link will not work, becouse micrel.c uses
> the incorrect config_init function, attempts to write to the bootstrap
> override register, that can't be written for KSZ8051, and so puts the
> micrel
> chip in a broken state.
> 
> The guy in this link (https://lkml.org/lkml/2013/9/18/259) seems are
> discussing a
> better solution.
> 
> I patched my linux as below, but this is a fast fixup for me:

You could register a PHY fixup in your board code that does exactly what
you are you doing here, except that you would match 0x00221556,
something along those lines:

static int micrel_ipam390_phy_fixup(struct phy_device *dev)
{
       if (dev->phy_id == 0x00221556)
		dev->phy_id = 0x00221550;

        return 0;
}

int __init micrel_ipam390_phy_fixup_register(void)
{
        return phy_register_fixup_for_id(PHY_ANY_ID, micrel_ipam390);
}

> 
> diff -rupN drivers/net/phy/phy_device.c
> ../linux-3.17/drivers/net/phy/phy_device.c
> --- drivers/net/phy/phy_device.c        2014-10-14 21:05:56.191117190 +0200
> +++ ../linux-3.17/drivers/net/phy/phy_device.c  2014-10-05
> 21:23:04.000000000 +0200
> @@ -310,19 +310,6 @@ static int get_phy_id(struct mii_bus *bu
> 
>         *phy_id |= (phy_reg & 0xffff);
> 
> -       /*
> -        * Angelo - Barix
> -        * Micrel produced chips marked KSZ8051 but with KSZ8031 id code
> -        * in the silicon. After getting crazy to understand why in
> recent kernel
> -        * the ethenret was not workeing, i find it out.
> -        *
> -        * From the schematic, we assume to use KSZ8051
> -        * I hardcode the fix here for ipam390.
> -        */
> -#if CONFIG_MACH_BARIX_IPAM390
> -       if (*phy_id == 0x00221556) *phy_id = 0x00221550;
> -#endif
> -
>         return 0;
>  }
> 
> Regards
> angelo
> 
