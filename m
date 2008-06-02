From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 2 Jun 2008 14:30:19 -0500
Message-ID: <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org> <48442239.7090906@garzik.org>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40327 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756756AbYFBTae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 15:30:34 -0400
In-Reply-To: <48442239.7090906@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 2, 2008, at 11:39 AM, Jeff Garzik wrote:

> Kumar Gala wrote:
>> On Jun 2, 2008, at 11:03 AM, Jeff Garzik wrote:
>>> Kumar Gala wrote:
>>>> The core portions of the phylib aren't capable of being used as
>>>> a module.  This isn't really any different than something like i2c
>>>> in that the bus driver and core need to be built into the kernel.
>>>> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
>>>> ---
>>>> Jeff, please consider this for 2.6.26 as w/o it we get build issues
>>>> if phylib is config'd as a module on ppc.
>>>> drivers/net/phy/Kconfig |    2 +-
>>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>>>> index 6eb2d31..ab04cc7 100644
>>>> --- a/drivers/net/phy/Kconfig
>>>> +++ b/drivers/net/phy/Kconfig
>>>> @@ -3,7 +3,7 @@
>>>> #
>>>> menuconfig PHYLIB
>>>> -    tristate "PHY Device support and infrastructure"
>>>> +    bool "PHY Device support and infrastructure"
>>>>    depends on !S390
>>>>    depends on NET_ETHERNET
>>>
>>> What are the issues?
>>>
>>> The core _should_ be able to be built as a module.
>> The core provides functions like phy_read/phy_write.  Andy has  
>> recently introduced board level workaround/fixups.  The problem is  
>> these workarounds tend to use phy_read/phy_write and the board/ 
>> platform code is not built as modules.
>> So we get errors like:
>> arch/powerpc/platforms/built-in.o: In function  
>> `mpc8568_mds_phy_fixups':
>> /home/galak/git/master/powerpc/arch/powerpc/platforms/85xx/ 
>> mpc85xx_mds.c:99: undefined reference to `phy_write'
>> /home/galak/git/master/powerpc/arch/powerpc/platforms/85xx/ 
>> mpc85xx_mds.c:104: undefined reference to `phy_read'
>
> The whole world isn't embedded ppc, we use this stuff elsewhere too.
>
> You guys need to figure out something that doesn't require phylib be  
> built-in on ALL platforms, but only the platforms that require it.
>
> Or, update the platform to not require built-in -- convert the board  
> code to function pointers, and execute them later on somehow, for  
> example.

If you really think the core of the phylib should be able to be built  
as a module than we could possibly add function pointers to phy_dev to  
do the real phy_read()/phy_write() and change phy_read/_write to look  
like:

int phy_read(struct phy_device *phydev, u16 regnum) {
	return phydev->read(phydev, regnum);
}

int phy_write(struct phy_device *phydev, u16 regnum, u16 val) {
	return phydev->write(phydev, regnum, val);
}

- k
