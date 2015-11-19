From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: tulip: turn compile-time warning into dev_warn()
Date: Thu, 19 Nov 2015 12:29:47 -0800
Message-ID: <564E313B.6000801@gmail.com>
References: <9720627.53btSdPcQU@wuerfel> <20151119122610.GF22786@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	ard.biesheuvel@linaro.org,
	Grant Grundler <grundler@parisc-linux.org>
To: Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34366 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161233AbbKSUas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 15:30:48 -0500
Received: by padhx2 with SMTP id hx2so91518489pad.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 12:30:48 -0800 (PST)
In-Reply-To: <20151119122610.GF22786@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/11/15 04:26, Will Deacon wrote:
> On Thu, Nov 19, 2015 at 11:42:26AM +0100, Arnd Bergmann wrote:
>> The tulip driver causes annoying build-time warnings for allmodconfig
>> builds for all recent architectures:
>>
>> dec/tulip/winbond-840.c:910:2: warning: #warning Processor architecture undefined
>> dec/tulip/tulip_core.c:101:2: warning: #warning Processor architecture undefined!
>>
>> This is the last remaining warning for arm64, and I'd like to get rid of
>> it. We don't really know the cache line size, architecturally it would
>> be at least 16 bytes, but all implementations I found have 64 or 128
>> bytes. Configuring tulip for 32-byte lines as we do on ARM32 seems to
>> be the safe but slow default, and nobody who cares about performance these
>> days would use a tulip chip anyway, so we can just use that.
>>
>> To save the next person the job of trying to find out what this is for
>> and picking a default for their architecture just to kill off the warning,
>> I'm now removing the preprocessor #warning and turning it into a pr_warn
>> or dev_warn that prints the equivalent information when the driver gets
>> loaded.
>>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>>
>> diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
>> index ed41559bae77..b553409e04ad 100644
>> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
>> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
>> @@ -98,8 +98,7 @@ static int csr0 = 0x01A00000 | 0x4800;
>>  #elif defined(__mips__)
>>  static int csr0 = 0x00200000 | 0x4000;
>>  #else
>> -#warning Processor architecture undefined!
>> -static int csr0 = 0x00A00000 | 0x4800;
>> +static int csr0;
>>  #endif
>>  
>>  /* Operational parameters that usually are not changed. */
>> @@ -1982,6 +1981,12 @@ static int __init tulip_init (void)
>>  	pr_info("%s", version);
>>  #endif
>>  
>> +	if (!csr0) {
>> +		pr_warn("tulip: unknown CPU architecture, using default csr0\n");
>> +		/* default to 8 longword cache line alignment */
>> +		csr0 = 0x00A00000 | 0x4800;
> 
> Maybe print "defaulting to 8 longword cache line alignment" instead of
> "default csr0"?
> 
>> diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
>> index 9beb3d34d4ba..3c0e4d5c5fef 100644
>> --- a/drivers/net/ethernet/dec/tulip/winbond-840.c
>> +++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
>> @@ -907,7 +907,7 @@ static void init_registers(struct net_device *dev)
>>  #elif defined(CONFIG_SPARC) || defined (CONFIG_PARISC) || defined(CONFIG_ARM)
>>  	i |= 0x4800;
>>  #else
>> -#warning Processor architecture undefined
>> +	dev_warn(&dev->dev, "unknown CPU architecture, using default csr0 setting\n");
>>  	i |= 0x4800;
> 
> Then we could print the default csr0 value here.
> 
> But, to be honest, this patch fixes a #warning on arm64 for a driver that
> I never expect to be used. So whatever you do to silence it:
> 
>   Acked-by: Will Deacon <will.deacon@arm.com>
> 
> /me waits for on-soc tulip integration.

FWIW, this already happened, the ADMtek/Infineon ADM8668 actually
integrated a Tulip chip. I have not submitted these patches below from
the OpenWrt tree because the chip is barely used nowadays, and it was
only mostly popular with the Linksys WRTU54G.

The patches could be made less intrusive if we did convert the pci_dma*
calls into regular DMA-API calls, which they are nowadays, oh well!

https://dev.openwrt.org/browser/trunk/target/linux/adm8668/patches-3.18/004-tulip_pci_split.patch
https://dev.openwrt.org/browser/trunk/target/linux/adm8668/patches-3.18/005-tulip_platform.patch
-- 
Florian
