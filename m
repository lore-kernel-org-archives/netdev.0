From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: remove 'register_type' field from 'struct
 sh_eth_plat_data'
Date: Tue, 27 Aug 2013 01:30:02 +0400
Message-ID: <521BC8DA.3010308@cogentembedded.com>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com> <20555348.Y63SQY2deS@avalon> <5214B770.5000807@cogentembedded.com> <2054715.7J5PzTuKLW@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:48635 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796Ab3HZVaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 17:30:08 -0400
Received: by mail-la0-f50.google.com with SMTP id es20so2793293lab.9
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 14:30:06 -0700 (PDT)
In-Reply-To: <2054715.7J5PzTuKLW@avalon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/21/2013 04:58 PM, Laurent Pinchart wrote:

    Sorry for the belated reply.

>>>>>>>>> Now that the 'register_type' field of the 'sh_eth' driver's platform
>>>>>>>>> data is not used by the driver anymore, it's time to remove it and
>>>>>>>>> its initializers from the SH platform code. Also  move *enum*
>>>>>>>>> declaring values for this  field from <linux/sh_eth.h>  to  the
>>>>>>>>> local driver's header file as they're only needed by the driver
>>>>>>>>> itself now...

>>>>>>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>>>>>> [...]

>>>>>>>>>      /* Driver's parameters */
>>>>>>>>>      #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
>>>>>>>>>      #define SH4_SKB_RX_ALIGN    32
>>>>>>>>>
>>>>>>>>> Index: net-next/include/linux/sh_eth.h
>>>>>>>>> ===================================================================
>>>>>>>>> --- net-next.orig/include/linux/sh_eth.h
>>>>>>>>> +++ net-next/include/linux/sh_eth.h
>>>>>>>>> @@ -5,17 +5,10 @@
>>>>>>>>>
>>>>>>>>>      #include <linux/if_ether.h>
>>>>>>>>>
>>>>>>>>>      enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
>>>>>>>>>
>>>>>>>>> -enum {
>>>>>>>>> -    SH_ETH_REG_GIGABIT,
>>>>>>>>> -    SH_ETH_REG_FAST_RCAR,
>>>>>>>>> -    SH_ETH_REG_FAST_SH4,
>>>>>>>>> -    SH_ETH_REG_FAST_SH3_SH2
>>>>>>>>> -};
>>>>>>>>>
>>>>>>>>>      struct sh_eth_plat_data {
>>>>>>>>>
>>>>>>>>>          int phy;
>>>>>>>>>          int edmac_endian;

>>>>>>>> Wouldn't it make sense to move the edmac_endian field to
>>>>>>>> sh_eth_cpu_data as well ?

>>>>>>> No, it depends on the SoC endianness which is determined by power-on
>>>>>>> pin strapping -- which is board specific.

>>>>> Does SoC endianness affect the ARM core endianness, the ethernet
>>>>> registers endianness, or both ?

>>>> Both, AFAIK.

>>>>> If it affects the ARM core endianness only, the kernel needs to be
>>>>> compiled in little-endian or big-endian mode anyway, and the sh_eth
>>>>> driver should use cpu_to_le32() unconditionally. If it affects both the
>>>>> ARM core and the ethernet controller there's not need to care about the
>>>>> endianness, as it will always be good.

>>>> No, it won't unless you're using __raw_{readl|writel}() accessors. The
>>>> driver doesn't do it. {readl|writel}() and io{read|write}32() that use
>>>> them always assume LE ordering of memory.

>>>>> We only need to care about it if it affects the ethernet controller
>>>>> registers only, which would seem weird to me.

>>>> Unfortunately, you are wrong.

>>> Care to explain *why* ? There might be bugs in the driver (such as using
>>> the wrong I/O accessors), but I don't see why we need to configure the
>>> endianness through platform data.

>> Re-read my reply about the power-on pin strapping please. The SoC endianness
>> setting gets read from the external source to the SoC, i.e. it's determined
>> by the board.

> Unless that pin doesn't affect the CPU core (in which case I wonder what it's
> used for),

    The thing is I don't have the necessary information about SH SoCs for 
which the 'edmac_endian' field was first added. I'm basing my assumptions on 
the R-Car manuals which claim that both register and DMA descriptor endianness 
depend on the SoC endianness (which is selected by the MD8 pin at power-on). 
So I don't even understand why it's called 'edmac_endian' based on this info, 
as it apparently determines only DMA descriptor endianness.

> the kernel will need to be compiled for the specified endianness
> anyway. Endianness conversion can thus be performed with cpu_to_* (if the
> registers endianness is fixed) or skipped completely (if the registers
> endianness is also configured by the bootstrap pin) by using raw I/O
> accessors.

    Unfortunately, the raw accessors also miss the barriers which might be 
necessary.

> Modifications will be need in the sh_eth driver, but I don't see
> why the driver would need to receive endianness information from platform data
> or DT.

    So you suggest that we use __LITTLE_ENDIAN/__BIG_ENDIAN pre-defined macros 
as when we're programing the EDMR.EL bit to enable automatic data swapping 
feature (it doesn't swap register or descriptors, only the raw data)?

WBR, Sergei
