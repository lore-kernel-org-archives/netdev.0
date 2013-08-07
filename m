From: Divy Le ray <divy@chelsio.com>
Subject: Re: BUG cxgb3: Check and handle the dma mapping errors
Date: Wed, 07 Aug 2013 09:55:11 -0700
Message-ID: <52027BEF.5040602@chelsio.com>
References: <51FF14F8.7000204@ozlabs.ru> <20130805184107.GA2998@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
	Santosh Rastapur <santosh@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jay Fenlason <fenlason@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130805184107.GA2998@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/05/2013 11:41 AM, Jay Fenlason wrote:
> On Mon, Aug 05, 2013 at 12:59:04PM +1000, Alexey Kardashevskiy wrote:
>> Hi!
>>
>> Recently I started getting multiple errors like this:
>>
>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>> c000001fbdaaa882 npages 1
>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>> c000001fbdaaa882 npages 1
>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>> c000001fbdaaa882 npages 1
>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>> c000001fbdaaa882 npages 1
>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>> c000001fbdaaa882 npages 1
>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>> c000001fbdaaa882 npages 1
>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>> c000001fbdaaa882 npages 1
>> ... and so on
>>
>> This is all happening on a PPC64 "powernv" platform machine. To trigger the
>> error state, it is enough to _flood_ ping CXGB3 card from another machine
>> (which has Emulex 10Gb NIC + Cisco switch). Just do "ping -f 172.20.1.2"
>> and wait 10-15 seconds.
>>
>>
>> The messages are coming from arch/powerpc/kernel/iommu.c and basically
>> mean that the driver requested more pages than the DMA window has which is
>> normally 1GB (there could be another possible source of errors -
>> ppc_md.tce_build callback - but on powernv platform it always succeeds).
>>
>>
>> The patch after which it broke is:
>> commit f83331bab149e29fa2c49cf102c0cd8c3f1ce9f9
>> Author: Santosh Rastapur <santosh@chelsio.com>
>> Date:   Tue May 21 04:21:29 2013 +0000
>> cxgb3: Check and handle the dma mapping errors
>>
>> Any quick ideas? Thanks!
> That patch adds error checking to detect failed dma mapping requests.
> Before it, the code always assumed that dma mapping requests succeded,
> whether they actually do or not, so the fact that the older kernel
> does not log errors only means that the failures are being ignored,
> and any appearance of working is through pure luck.  The machine could
> have just crashed at that point.
>
> What is the observed behavior of the system by the machine initiating
> the ping flood?  Do the older and newer kernels differ in the
> percentage of pings that do not receive replies?  O the newer kernel,
> when the mapping errors are detected, the packet that it is trying to
> transmit is dropped, but I'm not at all sure what happens on the older
> kernel after the dma mapping fails.  As I mentioned earlier, I'm
> surprised it does not crash.  Perhaps the folks from Chelsio have a
> better idea what happens after a dma mapping error is ignored?

Hi,

It should definitely not be ignored. It should not happen this reliably 
either.
I wonder if we are not hitting a leak of iommu entries.

Cheers,
Divy
