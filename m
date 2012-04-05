From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c,
 take two
Date: Thu, 5 Apr 2012 11:28:25 +0200
Message-ID: <CAMuHMdWSzG4npwjpJ=cwNFKhyBZjvgPn1sp6nZ2re6QsRWPpXg@mail.gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>
	<4F4B2BB6.900@gmail.com>
	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>
	<CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>
	<4F5A0679.1020604@windriver.com>
	<4F7816B0.3090802@gmail.com>
	<4F7CB31D.8060002@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Schmitz <schmitzmic@googlemail.com>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4F7CB31D.8060002@windriver.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 4, 2012 at 22:46, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> On 12-04-01 04:49 AM, Michael Schmitz wrote:
>>> And on re-reading the comments in the other part of the patch, i.e.
>>> "...emulates the card interrupt via a timer" =C2=A0--perhaps the dr=
iver
>>> should be just fixed to support generic netpoll, instead of adding
>>> an arch specific thing that amounts to netpoll. =C2=A0Then anyone c=
an
>>> attempt to limp along and use one of these ancient relics w/o IRQ.
>>>
>> Here's take two of my patch to convert the m68k Atari ROM port Ether=
net
>> driver to use mainstream ne.c, with minimal changes to the core NE20=
00
>> code.
>>
>> In particular:
>>
>> Changes to core net code:
>> * add a platform specific IRQ flag, so ne.c can share a hardware or
>> timer interrupt with some other interrupt source.
>>
>> Changes to arch/m68k code:
>> * register the 8390 platform device on Atari only if the hardware is=
 present
>> * retain the old driver (atari_ethernec.c in Geert's tree) under a
>> different config option, to be removed soon.
>>
>> Regarding your suggestion that netpoll be used instead of a dedicate=
d
>> timer interrupt: no changes to ne.c or 8390p.c are required to use
>> netpoll, it all works out of the box. All that is needed to use the
>> driver with netpoll is setting the device interrupt to some source t=
hat
>> can be registered, and enabling CONFIG_NETPOLL. Interrupt rate and h=
ence
>> throughput is lower with netpoll though, which is why I still prefer=
 the
>> dedicated timer option.
>
> How much lower? =C2=A0Enough to matter? =C2=A0Implicit in that questi=
on is
> the assumption that this is largely a hobbyist platform and nobody
> is using it in a closet to route gigabytes of traffic.

One other thing we could do is increase CONFIG_HZ to 250.

> Also, the only advantage to modifying ne.c is to allow dumping
> the old driver. =C2=A0What is the "remove soon" plan? =C2=A0Any reaso=
n
> for it to not be synchronous? =C2=A0That would eliminate the Kconfig
> churn and the introduction of the _OLD option. =C2=A0Modifying ne.c
> and then deciding to keep the old driver because it is "faster"
> would make this change pointless.

=46rom my point of view, "remove soon" means it will never hit mainline=
=2E

>> diff --git a/drivers/net/ethernet/8390/8390.h
>> b/drivers/net/ethernet/8390/8390.h
>> index ef325ff..9416245 100644
>> --- a/drivers/net/ethernet/8390/8390.h
>> +++ b/drivers/net/ethernet/8390/8390.h
>> @@ -32,6 +32,14 @@ extern void ei_poll(struct net_device *dev);
>> =C2=A0extern void eip_poll(struct net_device *dev);
>> =C2=A0#endif
>>
>> +/* Some platforms may need special IRQ flags */
>> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>> +# =C2=A0define EI_IRQ_FLAGS =C2=A0 =C2=A0IRQF_SHARED
>> +#endif
>> +
>> +#ifndef EI_IRQ_FLAGS
>> +# =C2=A0define EI_IRQ_FLAGS =C2=A0 =C2=A00
>> +#endif
>
> This seems more klunky than it needs to be. =C2=A0If we assume that a=
nyone
> building ne.c on atari is hence trying to drive an ethernec device
> than it can just be
>
> #ifdef CONFIG_ATARI
> #define EI_IRQ_FLAGS =C2=A0 =C2=A0IRQF_SHARED
> #else
> #define EI_IRQ_FLAGS =C2=A0 =C2=A00
> #endif

Indeed, with a small modification (keep multi-platform kernels in mind)=
:

#ifdef CONFIG_ATARI
#define EI_IRQ_FLAGS =C2=A0 =C2=A0(MACH_IS_ATARI ? IRQF_SHARED : 0)
#else
#define EI_IRQ_FLAGS =C2=A0 =C2=A00
#endif

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
