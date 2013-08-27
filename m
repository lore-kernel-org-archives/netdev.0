From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 2/2] sh_eth: remove 'register_type' field from 'struct sh_eth_plat_data'
Date: Tue, 27 Aug 2013 08:41:48 +0200
Message-ID: <9844233.YJQHWPv5fc@avalon>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com> <2054715.7J5PzTuKLW@avalon> <521BC8DA.3010308@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perceval.ideasonboard.com ([95.142.166.194]:37937 "EHLO
	perceval.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349Ab3H0Gk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 02:40:28 -0400
In-Reply-To: <521BC8DA.3010308@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Tuesday 27 August 2013 01:30:02 Sergei Shtylyov wrote:
> On 08/21/2013 04:58 PM, Laurent Pinchart wrote:
> 
> Sorry for the belated reply.

No worries.

> >>>>>>>>> Now that the 'register_type' field of the 'sh_eth' driver's
> >>>>>>>>> platform
> >>>>>>>>> data is not used by the driver anymore, it's time to remove it and
> >>>>>>>>> its initializers from the SH platform code. Also  move *enum*
> >>>>>>>>> declaring values for this  field from <linux/sh_eth.h>  to  the
> >>>>>>>>> local driver's header file as they're only needed by the driver
> >>>>>>>>> itself now...
> >>>>>>>>> 
> >>>>>>>>> Signed-off-by: Sergei Shtylyov
> >>>>>>>>> <sergei.shtylyov@cogentembedded.com>
> >>>>>> 
> >>>>>> [...]
> >>>>>> 
> >>>>>>>>>      /* Driver's parameters */
> >>>>>>>>>      #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
> >>>>>>>>>      #define SH4_SKB_RX_ALIGN    32
> >>>>>>>>> 
> >>>>>>>>> Index: net-next/include/linux/sh_eth.h
> >>>>>>>>> ==================================================================
> >>>>>>>>> =
> >>>>>>>>> --- net-next.orig/include/linux/sh_eth.h
> >>>>>>>>> +++ net-next/include/linux/sh_eth.h
> >>>>>>>>> @@ -5,17 +5,10 @@
> >>>>>>>>> 
> >>>>>>>>>      #include <linux/if_ether.h>
> >>>>>>>>>      
> >>>>>>>>>      enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
> >>>>>>>>> 
> >>>>>>>>> -enum {
> >>>>>>>>> -    SH_ETH_REG_GIGABIT,
> >>>>>>>>> -    SH_ETH_REG_FAST_RCAR,
> >>>>>>>>> -    SH_ETH_REG_FAST_SH4,
> >>>>>>>>> -    SH_ETH_REG_FAST_SH3_SH2
> >>>>>>>>> -};
> >>>>>>>>> 
> >>>>>>>>>      struct sh_eth_plat_data {
> >>>>>>>>>      
> >>>>>>>>>          int phy;
> >>>>>>>>>          int edmac_endian;
> >>>>>>>> 
> >>>>>>>> Wouldn't it make sense to move the edmac_endian field to
> >>>>>>>> sh_eth_cpu_data as well ?
> >>>>>>> 
> >>>>>>> No, it depends on the SoC endianness which is determined by power-on
> >>>>>>> pin strapping -- which is board specific.
> >>>>> 
> >>>>> Does SoC endianness affect the ARM core endianness, the ethernet
> >>>>> registers endianness, or both ?
> >>>> 
> >>>> Both, AFAIK.
> >>>> 
> >>>>> If it affects the ARM core endianness only, the kernel needs to be
> >>>>> compiled in little-endian or big-endian mode anyway, and the sh_eth
> >>>>> driver should use cpu_to_le32() unconditionally. If it affects both
> >>>>> the ARM core and the ethernet controller there's not need to care
> >>>>> about the endianness, as it will always be good.
> >>>> 
> >>>> No, it won't unless you're using __raw_{readl|writel}() accessors. The
> >>>> driver doesn't do it. {readl|writel}() and io{read|write}32() that use
> >>>> them always assume LE ordering of memory.
> >>>> 
> >>>>> We only need to care about it if it affects the ethernet controller
> >>>>> registers only, which would seem weird to me.
> >>>> 
> >>>> Unfortunately, you are wrong.
> >>> 
> >>> Care to explain *why* ? There might be bugs in the driver (such as using
> >>> the wrong I/O accessors), but I don't see why we need to configure the
> >>> endianness through platform data.
> >> 
> >> Re-read my reply about the power-on pin strapping please. The SoC
> >> endianness setting gets read from the external source to the SoC, i.e.
> >> it's determined by the board.
> > 
> > Unless that pin doesn't affect the CPU core (in which case I wonder what
> > it's used for),
> 
> The thing is I don't have the necessary information about SH SoCs for which
> the 'edmac_endian' field was first added. I'm basing my assumptions on the
> R-Car manuals which claim that both register and DMA descriptor endianness
> depend on the SoC endianness (which is selected by the MD8 pin at power-on).
> So I don't even understand why it's called 'edmac_endian' based on this
> info, as it apparently determines only DMA descriptor endianness.

Neither do I. Reading the documentation I just had doubts, hence my questions. 
I doubt that the MD8 pin modifies the endianness of all registers, as that 
would probably be very costly from a silicon point of view, but everything is 
possible.

> > the kernel will need to be compiled for the specified endianness
> > anyway. Endianness conversion can thus be performed with cpu_to_* (if the
> > registers endianness is fixed) or skipped completely (if the registers
> > endianness is also configured by the bootstrap pin) by using raw I/O
> > accessors.
> 
> Unfortunately, the raw accessors also miss the barriers which might be
> necessary.

But it would be pretty trivial if needed to create and use in the driver 
accessors with barriers based on the raw accessors.

> > Modifications will be need in the sh_eth driver, but I don't see
> > why the driver would need to receive endianness information from platform
> > data or DT.
> 
> So you suggest that we use __LITTLE_ENDIAN/__BIG_ENDIAN pre-defined macros
> as when we're programing the EDMR.EL bit to enable automatic data swapping
> feature (it doesn't swap register or descriptors, only the raw data)?

Based on my understanding, I believe that we either

- don't need different register access codes paths for little and big endian 
(for a variety of reasons, as explained in the previous e-mails in this 
thread)

- need different code paths, but can make the decision at compile time instead 
of runtime because the CPU core endianness changes as well, which forces a 
recompilation anyway

I would thus suggest to use the right combination of cpu_to_[bl]e*, raw 
accessors (with added barriers), #ifdef __LITTLE_ENDIAN/__BIG_ENDIAN and 
EDMR.EL settings to remove the edmac_endian field.

What the right combination is isn't know yet, we can experiment later when 
we'll get a big-endian system. I'm fine with keeping the field in the platform 
data structure for reference until then, but let's not add it to the DT 
bindings.

-- 
Regards,

Laurent Pinchart
