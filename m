From: Michael Schmitz <schmitzmic@googlemail.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c
Date: Fri, 09 Mar 2012 17:58:36 +1300
Message-ID: <4F598DFC.70507@gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>	<4F4B2BB6.900@gmail.com> <CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Schmitz <schmitzmic@googlemail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Gortmaker wrote:
>
>> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
>> index f92ea2a..28b8781 100644
>> --- a/drivers/net/ethernet/8390/ne.c
>> +++ b/drivers/net/ethernet/8390/ne.c
>> @@ -55,6 +55,9 @@ static const char version2[] =
>>
>>  #include <asm/system.h>
>>  #include <asm/io.h>
>> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>> +#include <asm/atariints.h>
>> +#endif
>>     
>
> Do you really need the #if here?  Should be avoidable.
>
>   
Looks like that one's unneeded.
>>  #include "8390.h"
>>
>> @@ -165,7 +168,8 @@ bad_clone_list[] __initdata = {
>>  #if defined(CONFIG_PLAT_MAPPI)
>>  #  define DCR_VAL 0x4b
>>  #elif defined(CONFIG_PLAT_OAKS32R)  || \
>> -   defined(CONFIG_MACH_TX49XX)
>> +   defined(CONFIG_MACH_TX49XX) || \
>> +   IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>>  #  define DCR_VAL 0x48        /* 8-bit mode */
>>  #else
>>  #  define DCR_VAL 0x49
>> @@ -492,7 +496,16 @@ static int __init ne_probe1(struct net_device *dev,
>> unsigned long ioaddr)
>>
>>     /* Snarf the interrupt now.  There's no point in waiting since we cannot
>>        share and the board will usually be enabled. */
>> -    ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
>> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>> +    if (MACH_IS_ATARI) {
>> +        /* Atari EtherNEC emulates the card interrupt via a timer -
>> +           this needs to be shared with the smc91C111 driver and with
>> +           a dummy handler to catch unhandled interrupts ! */
>> +        ret = request_irq(dev->irq, eip_interrupt, IRQF_SHARED, name, dev);
>> +    } else
>> +#endif
>> +        ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
>> +
>>     
>
> There has to be a cleaner way than this.  Something as simple as creating
> a platform specific 8380_IRQ_FLAGS would get rid of this ifdef'ery in
> the driver and that is with only 20s of thought invested.
>   
That would have been the alternative - would you prefer to have this 
added in 8390.h or ne.c?

Thanks,

  Michael
