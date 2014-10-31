From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: DMA allocations from CMA and fatal_signal_pending check
Date: Fri, 31 Oct 2014 17:28:18 +0900
Message-ID: <20141031082818.GB14642@js1304-P5Q-DELUXE>
References: <544FE9BE.6040503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org,
	Brian Norris <computersforpeace@gmail.com>,
	Gregory Fong <gregory.0xf0@gmail.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	lauraa@codeaurora.org, gioh.kim@lge.com,
	aneesh.kumar@linux.vnet.ibm.com, mina86@mina86.com,
	m.szyprowski@samsung.com, akpm@linux-foundation.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <544FE9BE.6040503@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 28, 2014 at 12:08:46PM -0700, Florian Fainelli wrote:
> Hello,
> 
> While debugging why some dma_alloc_coherent() allocations where
> returning NULL on our brcmstb platform, specifically with
> drivers/net/ethernet/broadcom/bcmcsysport.c, I came across the
> fatal_signal_pending() check in mm/page_alloc.c which is there.
> 
> This driver calls dma_alloc_coherent(, GFP_KERNEL) which ends up making
> a coherent allocation from a CMA region on our platform. Since that
> allocation is allowed to sleep, and because we are in bcm_syport_open(),
> executed from process context, a pending signal makes
> dma_alloc_coherent() return NULL.

Hello, Florian.

fatal_signal_pending means that there is SIGKILL on that process.
I guess that caller of dma_alloc_coherent() will die soon.
In this case, why CMA should be succeed?

> 
> There are two ways I could fix this:
> 
> - use a GFP_ATOMIC allocation, which would avoid this sensitivity to a
> pending signal being fatal (we suffer from the same issue in
> bcm_sysport_resume)
> 
> - move the DMA coherent allocation before bcm_sysport_open(), in the
> driver's probe function, but if the network interface is never used, we
> would be waisting precious DMA coherent memory for nothing (it is only 4
> bytes times 32 but still

I guess that it is okay that bcm_sysport_open() return -EINTR?

Thanks.
