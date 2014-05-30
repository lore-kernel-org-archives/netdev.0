From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH net-next 5/7] net:fec: add support for dumping transmit
	ring on timeout
Date: Fri, 30 May 2014 01:51:17 +0000
Message-ID: <4358dcf50a204717a3517a22b8b35a33@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
 <1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
 <CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
 <CAHrpEqRZ1oyd6bXXqxznfw+1qwo5LVBW10mcrzLbbCHYowPetA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F70156E@AcuExch.aculab.com>
 <20140429143828.GB26756@n2100.arm.linux.org.uk>
 <51ca1e44e5e849ecbae40bf0beaa2028@BY2PR03MB377.namprd03.prod.outlook.com>
 <20140530000336.GM3693@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Laight <David.Laight@ACULAB.COM>,
	'Frank Li' <lznuaa@gmail.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0238.outbound.protection.outlook.com ([207.46.163.238]:4673
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751037AbaE3BvU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 21:51:20 -0400
In-Reply-To: <20140530000336.GM3693@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk> Data: Friday, May 30, 2014 8:04 AM
>To: Duan Fugang-B38611
>Cc: David Laight; 'Frank Li'; Li Frank-B20596; shawn.guo@linaro.org;
>davem@davemloft.net; netdev@vger.kernel.org
>Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping
>transmit ring on timeout
>
>On Thu, May 29, 2014 at 08:17:07AM +0000, fugang.duan@freescale.com wrote:
>> Hi, Russell,
>>
>> I see linux next and net "imx_v6_v7_defconfig" don't enable
>> "CONFIG_CMA", if you enable the feature,
>
>Sorry, telling people that CMA is required to avoid that is just not an
>acceptable "solution".
>
>With CMA not enabled, the DMA memory provided to the driver is still
>perfectly valid and should be no different from what CMA provides.
>
>I'd strongly suggest investigating why there is this difference, and what
>the difference is - I'd assume freescale have the ability to do that with
>their own devices much more than I have, and probably to a greater depth
>too - especially as there is no possibility what so ever of using any kind
>of hardware debug on the iMX6 platforms I have.
>
I accept your suggestion to inverstigate the difference. Thanks.
Can you take some time to glance over the attached document by previous mail, we indeed did some tests/analyze on the issue.
Because the DMA memory coherent issue happened at fec, usb, audio modules.

>From the CMA article: http://lwn.net/Articles/450286/:
If a region of low memory is turned into a DMA buffer with an uncached mapping, the system will have two conflicting mappings for the same memory and will have moved into "undefined behavior" territory.

For imx6 DMA memory mapping:
One physical mapping for lowmem map: cacheable with allocate
The physical another mapping for DMA zone remap: Non-cacheable bufferable (kernel with CONFIG_ARM_DMA_MEM_BUFFERABLE enable)

According to the PL301 L2 Cache Controller TRM, memory with normal memory type, shared, outer-non-cacheable attribute can be treated as cacheable memory:
    - Non-cacheable shared reads are treated as cacheable non-allocatable.
    - Non-cacheable shared writes are treated as cacheable write-through no write-allocate. 
Since the access is treated as non-allocate, if the memory is not cached in the L2, the read/write access will always go to the L3 memory. So most of the time, there is no issue with this feature. 

But when there are multiple virtual addresses mapping to same physical address, and if one of the virtual address has a real "cacheable" attribute, this feature would cause us trouble. 

Thanks,
Andy
