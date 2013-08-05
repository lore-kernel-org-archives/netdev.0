From: Jay Fenlason <fenlason@redhat.com>
Subject: Re: BUG cxgb3: Check and handle the dma mapping errors
Date: Mon, 5 Aug 2013 14:41:08 -0400
Message-ID: <20130805184107.GA2998@redhat.com>
References: <51FF14F8.7000204@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Santosh Rastapur <santosh@chelsio.com>,
	Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51FF14F8.7000204@ozlabs.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 05, 2013 at 12:59:04PM +1000, Alexey Kardashevskiy wrote:
> Hi!
> 
> Recently I started getting multiple errors like this:
> 
> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
> c000001fbdaaa882 npages 1
> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
> c000001fbdaaa882 npages 1
> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
> c000001fbdaaa882 npages 1
> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
> c000001fbdaaa882 npages 1
> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
> c000001fbdaaa882 npages 1
> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
> c000001fbdaaa882 npages 1
> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
> c000001fbdaaa882 npages 1
> ... and so on
> 
> This is all happening on a PPC64 "powernv" platform machine. To trigger the
> error state, it is enough to _flood_ ping CXGB3 card from another machine
> (which has Emulex 10Gb NIC + Cisco switch). Just do "ping -f 172.20.1.2"
> and wait 10-15 seconds.
> 
> 
> The messages are coming from arch/powerpc/kernel/iommu.c and basically
> mean that the driver requested more pages than the DMA window has which is
> normally 1GB (there could be another possible source of errors -
> ppc_md.tce_build callback - but on powernv platform it always succeeds).
> 
> 
> The patch after which it broke is:
> commit f83331bab149e29fa2c49cf102c0cd8c3f1ce9f9
> Author: Santosh Rastapur <santosh@chelsio.com>
> Date:   Tue May 21 04:21:29 2013 +0000
> cxgb3: Check and handle the dma mapping errors
> 
> Any quick ideas? Thanks!

That patch adds error checking to detect failed dma mapping requests.
Before it, the code always assumed that dma mapping requests succeded,
whether they actually do or not, so the fact that the older kernel
does not log errors only means that the failures are being ignored,
and any appearance of working is through pure luck.  The machine could
have just crashed at that point.

What is the observed behavior of the system by the machine initiating
the ping flood?  Do the older and newer kernels differ in the
percentage of pings that do not receive replies?  O the newer kernel,
when the mapping errors are detected, the packet that it is trying to
transmit is dropped, but I'm not at all sure what happens on the older
kernel after the dma mapping fails.  As I mentioned earlier, I'm
surprised it does not crash.  Perhaps the folks from Chelsio have a
better idea what happens after a dma mapping error is ignored?

		-- JF
