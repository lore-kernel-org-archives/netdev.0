From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Keystone 2 boards boot failure
Date: Thu, 04 Feb 2016 14:07:28 +0100
Message-ID: <3707703.8KjeGIMijU@wuerfel>
References: <56B0DE61.2000704@ti.com> <1935541.nO0q7ZEBnd@wuerfel> <56B341EA.4020507@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Franklin S Cooper Jr." <fcooper@ti.com>, m-karicheri2@ti.com,
	netdev@vger.kernel.org, w-kwok2@ti.com, davem@davemloft.net,
	Santosh Shilimkar <ssantosh@kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:61656 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932465AbcBDNHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 08:07:49 -0500
In-Reply-To: <56B341EA.4020507@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 February 2016 14:19:54 Grygorii Strashko wrote:
> On 02/03/2016 10:40 PM, Arnd Bergmann wrote:
> > On Wednesday 03 February 2016 18:31:00 Grygorii Strashko wrote:
> >> On 02/03/2016 06:20 PM, Arnd Bergmann wrote:
> >>> On Wednesday 03 February 2016 16:21:05 Grygorii Strashko wrote:
> >>>> On 02/03/2016 04:11 PM, Franklin S Cooper Jr. wrote:
> >>>>> On 02/02/2016 07:19 PM, Franklin S Cooper Jr. wrote:
> >> config:
> >>
> >> CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
> >> CONFIG_PHYS_ADDR_T_64BIT=y
> >>
> >> and
> >>
> >> #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT <--- should not be defined for KS2
> >> typedef u64 dma_addr_t;
> >> #else
> >> typedef u32 dma_addr_t;
> >> #endif
> >>
> >> Above is valid configuration for Keystone 2 with LPAE=y
> > 
> > Ok, but what do you mean with "should not be defined"? It clearly is
> > defined in any multiplatform configuration that enables another platform
> > needing 64-bit dma_addr_t.
> > 
> 
> Then we probably have bigger problem :) KS2 will not work as is with
> such configuration and not only KS2 - LPAE is enabled for TI DRA7 also.
> 
> Problem here is that dma_addr_t is used to fill DMA controllers data or can be 
> written directly to register, so all drivers need to be revised which was initially
> created for 32-bit HW and with assumption that dma_addr_t is 32-bits.

Almost everything should work fine. What all other drivers tend to do is
something like

	writel(dma_addr, reg_base + REG_OFFSET);

which works for 64-bit dma_addr_t as long as the upper 32 bits are
always zero, and that should be the case on keystone.

The part that does not work and that originally triggered the
warning I was fixing is

void f(u32 *data)
{
	writel(*data, reg_base + reg_offset);
}

...

	f((u32 *)&dma_addr);

as this driver does. I have not seen the same warning for any
other driver in the kernel, so it is clearly something that
rarely happens, and it still works by chance on little-endian
kernels, just not on big-endian.

> Also, I'm not sure that it will be possible to support both LE/BE in such case.
> 
> Actually, I've tried current multi_v7_defconfig and can see:
> # CONFIG_ARCH_PHYS_ADDR_T_64BIT is not set
> # CONFIG_PHYS_ADDR_T_64BIT is not set
> # CONFIG_ARM_LPAE is not set
> What is your "multiplatform configuration" ??

kernelci is testing multi_v7_defconfig with LPAE and KVM enabled on top.
This breaks all pre-Cortex-A15 platforms (A5, A8 and A9 don't have LPAE)
but should work on any A7/A15/A17 machine.
 
> So I propose to fix this regression first (as we both did - revert changes in 
> get/set_pad_info()) and have KS2 working again with current version of
> defconfig files (keystone_defconfig & multi_v7_defconfig) while this
> discussion is continuing. 

Could you please at least test the last patch I sent? It really shouldn't
be too hard to find the line that was wrong in my patch.

	Arnd
