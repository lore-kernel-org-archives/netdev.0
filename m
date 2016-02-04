From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: Keystone 2 boards boot failure
Date: Thu, 4 Feb 2016 14:19:54 +0200
Message-ID: <56B341EA.4020507@ti.com>
References: <56B0DE61.2000704@ti.com> <1888105.8DsfvU3cAo@wuerfel>
 <56B22B44.9050802@ti.com> <1935541.nO0q7ZEBnd@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "Franklin S Cooper Jr." <fcooper@ti.com>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <w-kwok2@ti.com>, <davem@davemloft.net>,
	Santosh Shilimkar <ssantosh@kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:35891 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137AbcBDMUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 07:20:05 -0500
In-Reply-To: <1935541.nO0q7ZEBnd@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On 02/03/2016 10:40 PM, Arnd Bergmann wrote:
> On Wednesday 03 February 2016 18:31:00 Grygorii Strashko wrote:
>> On 02/03/2016 06:20 PM, Arnd Bergmann wrote:
>>> On Wednesday 03 February 2016 16:21:05 Grygorii Strashko wrote:
>>>> On 02/03/2016 04:11 PM, Franklin S Cooper Jr. wrote:
>>>>> On 02/02/2016 07:19 PM, Franklin S Cooper Jr. wrote:
>>>
>>> This looks wrong: I was getting the build warnings originally
>>> because of 64-bit dma_addr_t, and that should be the only way that
>>> this driver can operate, because in some configurations on keystone
>>> there is no memory below 4GB, and there is no dma-ranges property
>>> in the DT that shifts around the start of the DMA addresses.
>>
>> see keystone.dtsi:
>> 	soc {
>> 		#address-cells = <1>;
>> 		#size-cells = <1>;
>> 		compatible = "ti,keystone","simple-bus";
>> 		interrupt-parent = <&gic>;
>> 		ranges = <0x0 0x0 0x0 0xc0000000>;
>> 		dma-ranges = <0x80000000 0x8 0x00000000 0x80000000>;
>> 		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> You are right, I totally missed it when I looked again. I thought it
> was correct but then couldn't find it in the dts.
> 
>> config:
>>
>> CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
>> CONFIG_PHYS_ADDR_T_64BIT=y
>>
>> and
>>
>> #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT <--- should not be defined for KS2
>> typedef u64 dma_addr_t;
>> #else
>> typedef u32 dma_addr_t;
>> #endif
>>
>> Above is valid configuration for Keystone 2 with LPAE=y
> 
> Ok, but what do you mean with "should not be defined"? It clearly is
> defined in any multiplatform configuration that enables another platform
> needing 64-bit dma_addr_t.
> 

Then we probably have bigger problem :) KS2 will not work as is with
such configuration and not only KS2 - LPAE is enabled for TI DRA7 also.

Problem here is that dma_addr_t is used to fill DMA controllers data or can be 
written directly to register, so all drivers need to be revised which was initially
created for 32-bit HW and with assumption that dma_addr_t is 32-bits.

Also, I'm not sure that it will be possible to support both LE/BE in such case.

Actually, I've tried current multi_v7_defconfig and can see:
# CONFIG_ARCH_PHYS_ADDR_T_64BIT is not set
# CONFIG_PHYS_ADDR_T_64BIT is not set
# CONFIG_ARM_LPAE is not set
What is your "multiplatform configuration" ??

So I propose to fix this regression first (as we both did - revert changes in 
get/set_pad_info()) and have KS2 working again with current version of
defconfig files (keystone_defconfig & multi_v7_defconfig) while this discussion is continuing. 

-- 
regards,
-grygorii
