From: Michael Schmitz <schmitzmic@gmail.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - ethernet support (ne),>
Date: Wed, 13 Aug 2014 09:40:20 +1200
Message-ID: <CAOmrzk+m7b58Xb=zFv6Kf=_HgGR4FzwpwRvsh08uGMkg0xPLWA@mail.gmail.com>
References: <1407636153-24864-1-git-send-email-schmitzmic@gmail.com>
	<53EA2AF2.3040709@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Linux/m68k" <linux-m68k@vger.kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	debian m68k <debian-68k@lists.debian.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:51395 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbaHLVqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 17:46:19 -0400
In-Reply-To: <53EA2AF2.3040709@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

On Wed, Aug 13, 2014 at 2:55 AM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> [Subject added from patch]

Thanks - that was me botching git-send-email --annotate. My sincere
apology for this.

>> From 224ce049f71577d6ec380aeb94a4d25c3c4016a7 Mon Sep 17 00:00:00 2001
>> From: Michael Schmitz <schmitzmic@gmail.com>
>> Date: Sat, 6 Apr 2013 13:26:42 +1300
>> Subject: [PATCH] m68k/atari: EtherNEC - ethernet support (ne)
>>
>> Support for Atari EtherNEC ROM port adapters in ne.c
>
> Is that all there is to say about these?  Nothing about which platforms
> might have it, or what it was tested on or ... ?

All Atari computers have the ROM port. As such, the driver could be
used on MegaST/E, TT or Falcon variants (these having MMU support so
can run m68k linux).

The ne.c driver is also used on the Q40, a m68k platfrem which
includes the ISA bus. Hence the runtime check for whether the driver
runs on Atari, or some other m68k platform below.

>
>>
>> Signed-off-by: Michael Schmitz <schmitz@debian.org>
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> ---
>>  drivers/net/ethernet/8390/Kconfig |    3 ++-
>>  drivers/net/ethernet/8390/ne.c    |    2 ++
>>  2 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
>> index 0988811..2d89bd0 100644
>> --- a/drivers/net/ethernet/8390/Kconfig
>> +++ b/drivers/net/ethernet/8390/Kconfig
>> @@ -91,7 +91,8 @@ config MCF8390
>>
>>  config NE2000
>>       tristate "NE2000/NE1000 support"
>> -     depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX)
>> +     depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX || \
>> +                 ATARI_ETHERNEC)
>>       select CRC32
>>       ---help---
>>         If you have a network (Ethernet) card of this type, say Y and read
>> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
>> index 58eaa8f..de566fb 100644
>> --- a/drivers/net/ethernet/8390/ne.c
>> +++ b/drivers/net/ethernet/8390/ne.c
>> @@ -169,6 +169,8 @@ bad_clone_list[] __initdata = {
>>  #elif defined(CONFIG_PLAT_OAKS32R)  || \
>>     defined(CONFIG_MACH_TX49XX)
>>  #  define DCR_VAL 0x48               /* 8-bit mode */
>> +#elif defined(CONFIG_ATARI)  /* 8-bit mode on Atari, normal on Q40 */
>> +#  define DCR_VAL (MACH_IS_ATARI ? 0x48 : 0x49)
>
> This doesn't make sense.  Is not MACH_IS_ATARI set when CONFIG_ATARI

As Geert pointed out, MACH_IS_ATARI is a runtime test on multiplatform
kernels (which are the norm these days, even with m68k).

Would you be OK if I expanded the comment like this?

/* ne.c is used on m68k Atari and Q40 computers - the Atari ROM-port
adapter is 8-bit, Q40 uses ISA */

> is set?  And even if it isn't then just set 48 for MACH_IS_ATARI and
> let the default of 49 below take the ATARI=y and IS_ATARI=n case,
> without the need for the ?: operator at all.  On top of that, why

This would limit the runtime test to the case where it is actually
needed (untested):

#elif defined(CONFIG_ATARI) && defined(CONFIG_Q40)
/* multiplatform m68k kernel - the Atari ROM-port adapter is 8-bit,
Q40 uses ISA */
#  define DCR_VAL (MACH_IS_ATARI ? 0x48 : 0x49)
#elif defined(CONFIG_ATARI) /* no Q40 support - 8-bit mode on Atari ROM port */
#  define DCR_VAL 0x48
#else
#  define DCR_VAL 0x49
#endif

Are there any other m68k platforms that use the ne.c driver, Geert?
apne, hydra and zorro8390 all have their own separate drivers - any
others?

> aren't you using the ATARI_ETHERNEC option here for your 48 trigger,
> instead of the much higher arch/mach level triggers at all?

Fair enough - I can do that. I though using the mach level one made it
clearer this is about multiplatform issues.

We still need the runtime test on kernels configured for both Atari
and Q40 though. Which variant do you prefer?

Thanks,

  Michael


>
> P.
> --
>
>>  #else
>>  #  define DCR_VAL 0x49
>>  #endif
>>
