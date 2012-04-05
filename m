From: Michael Schmitz <schmitzmic@googlemail.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c,
 take two
Date: Thu, 05 Apr 2012 21:44:14 +1200
Message-ID: <4F7D696E.8010301@gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>	<4F4B2BB6.900@gmail.com>	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com> <CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com> <4F5A0679.1020604@windriver.com> <4F7816B0.3090802@gmail.com> <4F7CB31D.8060002@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4F7CB31D.8060002@windriver.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

(Apologies to all for botching the patch format ...)

>> Regarding your suggestion that netpoll be used instead of a dedicated 
>> timer interrupt: no changes to ne.c or 8390p.c are required to use 
>> netpoll, it all works out of the box. All that is needed to use the 
>> driver with netpoll is setting the device interrupt to some source that  
>> can be registered, and enabling CONFIG_NETPOLL. Interrupt rate and hence 
>> throughput is lower with netpoll though, which is why I still prefer the 
>> dedicated timer option.
>>     
>
> How much lower?  Enough to matter?  Implicit in that question is
> the assumption that this is largely a hobbyist platform and nobody
> is using it in a closet to route gigabytes of traffic.
>   
I'd say about at least double latency. I can try and measure bulk data 
rates if it matters. My gut feeling is latency limits data rates even 
when say behind a DSL modem for downloads. It sure did when my Falcon 
was still hooked up to a university network, uploading and downloading 
source and binary packages for Debian/68k.

Of course you're not routing gigabytes of traffic with this (where to - 
a PPP connection? :). Whoever wants minimum latency better reach for the 
soldering iron and wire up the interrupt line to some suitable input.
> Also, the only advantage to modifying ne.c is to allow dumping
> the old driver.  What is the "remove soon" plan?  Any reason
> for it to not be synchronous?  That would eliminate the Kconfig
> churn and the introduction of the _OLD option.  Modifying ne.c
> and then deciding to keep the old driver because it is "faster"
> would make this change pointless.
>   
As soon as eventual changes to ne.c get accepted. If you want us to drop 
the old driver in the same patch, fine by me.
>> diff --git a/drivers/net/ethernet/8390/8390.h 
>> b/drivers/net/ethernet/8390/8390.h
>> index ef325ff..9416245 100644
>> --- a/drivers/net/ethernet/8390/8390.h
>> +++ b/drivers/net/ethernet/8390/8390.h
>> @@ -32,6 +32,14 @@ extern void ei_poll(struct net_device *dev);
>>  extern void eip_poll(struct net_device *dev);
>>  #endif
>>  
>> +/* Some platforms may need special IRQ flags */
>> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>> +#  define EI_IRQ_FLAGS    IRQF_SHARED
>> +#endif
>> +
>> +#ifndef EI_IRQ_FLAGS
>> +#  define EI_IRQ_FLAGS    0
>> +#endif
>>     
>
> This seems more klunky than it needs to be.  If we assume that anyone
> building ne.c on atari is hence trying to drive an ethernec device
> than it can just be
>
> #ifdef CONFIG_ATARI
> #define EI_IRQ_FLAGS	IRQF_SHARED
> #else
> #define EI_IRQ_FLAGS	0
> #endif
>
>   
Pretty safe assumption - if we further assume no other arch has reason 
to resort to such a kludge, we can simplify it this way.
>> --- a/drivers/net/ethernet/8390/ne.c
>> +++ b/drivers/net/ethernet/8390/ne.c
>> @@ -165,7 +165,8 @@ bad_clone_list[] __initdata = {
>>  #if defined(CONFIG_PLAT_MAPPI)
>>  #  define DCR_VAL 0x4b
>>  #elif defined(CONFIG_PLAT_OAKS32R)  || \
>> -   defined(CONFIG_MACH_TX49XX)
>> +   defined(CONFIG_MACH_TX49XX) || \
>> +   IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>>     
>
> Rather than use IS_ENABLED on a driver setting, you can follow
> the surrounding context and use defined(CONFIG_ATARI) -- i.e.
> work off a platform setting.
>   
True as well, point taken. Is the patch acceptable with these changes? 
If so, would you be OK with this going through Geert's tree?

Cheers,

  Michael
