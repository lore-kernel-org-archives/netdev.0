From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c,
 take two
Date: Thu, 5 Apr 2012 09:24:43 -0400
Message-ID: <4F7D9D1B.3000801@windriver.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>	<4F4B2BB6.900@gmail.com>	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>	<CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>	<4F5A0679.1020604@windriver.com>	<4F7816B0.3090802@gmail.com>	<4F7CB31D.8060002@windriver.com> <CAMuHMdWSzG4npwjpJ=cwNFKhyBZjvgPn1sp6nZ2re6QsRWPpXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Schmitz <schmitzmic@googlemail.com>,
	<linux-m68k@vger.kernel.org>, <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49523 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab2DENYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 09:24:52 -0400
In-Reply-To: <CAMuHMdWSzG4npwjpJ=cwNFKhyBZjvgPn1sp6nZ2re6QsRWPpXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-04-05 05:28 AM, Geert Uytterhoeven wrote:
> On Wed, Apr 4, 2012 at 22:46, Paul Gortmaker
> <paul.gortmaker@windriver.com> wrote:
>> On 12-04-01 04:49 AM, Michael Schmitz wrote:
>>>> And on re-reading the comments in the other part of the patch, i.e.
>>>> "...emulates the card interrupt via a timer"  --perhaps the driver
>>>> should be just fixed to support generic netpoll, instead of adding
>>>> an arch specific thing that amounts to netpoll.  Then anyone can
>>>> attempt to limp along and use one of these ancient relics w/o IRQ.
>>>>
>>> Here's take two of my patch to convert the m68k Atari ROM port Ethernet
>>> driver to use mainstream ne.c, with minimal changes to the core NE2000
>>> code.
>>>
>>> In particular:
>>>
>>> Changes to core net code:
>>> * add a platform specific IRQ flag, so ne.c can share a hardware or
>>> timer interrupt with some other interrupt source.
>>>
>>> Changes to arch/m68k code:
>>> * register the 8390 platform device on Atari only if the hardware is present
>>> * retain the old driver (atari_ethernec.c in Geert's tree) under a
>>> different config option, to be removed soon.
>>>
>>> Regarding your suggestion that netpoll be used instead of a dedicated
>>> timer interrupt: no changes to ne.c or 8390p.c are required to use
>>> netpoll, it all works out of the box. All that is needed to use the
>>> driver with netpoll is setting the device interrupt to some source that
>>> can be registered, and enabling CONFIG_NETPOLL. Interrupt rate and hence
>>> throughput is lower with netpoll though, which is why I still prefer the
>>> dedicated timer option.
>>
>> How much lower?  Enough to matter?  Implicit in that question is
>> the assumption that this is largely a hobbyist platform and nobody
>> is using it in a closet to route gigabytes of traffic.
> 
> One other thing we could do is increase CONFIG_HZ to 250.
> 
>> Also, the only advantage to modifying ne.c is to allow dumping
>> the old driver.  What is the "remove soon" plan?  Any reason
>> for it to not be synchronous?  That would eliminate the Kconfig
>> churn and the introduction of the _OLD option.  Modifying ne.c
>> and then deciding to keep the old driver because it is "faster"
>> would make this change pointless.
> 
> From my point of view, "remove soon" means it will never hit mainline.

Can you clarify what "it" is?   It isn't clear to me if you
mean the _removal_ will never hit mainline, or the transient
renamed "old" driver will never hit mainline.

If the former, then there is no point pursuing this any further
as I said above.

If the latter, then the commit sent out for review should have
no instances of this "renaming to old" related changes.

Thanks,
Paul.

> 
>>> diff --git a/drivers/net/ethernet/8390/8390.h
>>> b/drivers/net/ethernet/8390/8390.h
>>> index ef325ff..9416245 100644
>>> --- a/drivers/net/ethernet/8390/8390.h
>>> +++ b/drivers/net/ethernet/8390/8390.h
>>> @@ -32,6 +32,14 @@ extern void ei_poll(struct net_device *dev);
>>>  extern void eip_poll(struct net_device *dev);
>>>  #endif
>>>
>>> +/* Some platforms may need special IRQ flags */
>>> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>>> +#  define EI_IRQ_FLAGS    IRQF_SHARED
>>> +#endif
>>> +
>>> +#ifndef EI_IRQ_FLAGS
>>> +#  define EI_IRQ_FLAGS    0
>>> +#endif
>>
>> This seems more klunky than it needs to be.  If we assume that anyone
>> building ne.c on atari is hence trying to drive an ethernec device
>> than it can just be
>>
>> #ifdef CONFIG_ATARI
>> #define EI_IRQ_FLAGS    IRQF_SHARED
>> #else
>> #define EI_IRQ_FLAGS    0
>> #endif
> 
> Indeed, with a small modification (keep multi-platform kernels in mind):
> 
> #ifdef CONFIG_ATARI
> #define EI_IRQ_FLAGS    (MACH_IS_ATARI ? IRQF_SHARED : 0)
> #else
> #define EI_IRQ_FLAGS    0
> #endif
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
