From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] ARM: dmabounce: fix partial sync in dma_sync_single_*
	API
Date: Wed, 28 Apr 2010 07:50:07 +0900
Message-ID: <20100428075137J.fujita.tomonori@lab.ntt.co.jp>
References: <20100405123847C.fujita.tomonori@lab.ntt.co.jp>
	<20100412193536.GO3048@n2100.arm.linux.org.uk>
	<20100413142607V.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp
To: linux@arm.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100413142607V.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2010 14:27:04 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> On Mon, 12 Apr 2010 20:35:36 +0100
> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> 
> > On Mon, Apr 05, 2010 at 12:39:32PM +0900, FUJITA Tomonori wrote:
> > > I don't have arm hardware that uses dmabounce so I can't confirm the
> > > problem but seems that dmabounce doesn't work for some drivers...
> > 
> > Patch reviews fine, except for one niggle.  I too don't have hardware
> > I can test (well, I do except the kernel stopped supporting the UDA1341
> > audio codec on the SA1110 Neponset.)
> 
> Thanks for reviewing.
> 
> > > @@ -171,10 +172,17 @@ find_safe_buffer(struct dmabounce_device_info *device_info, dma_addr_t safe_dma_
> > >  	read_lock_irqsave(&device_info->lock, flags);
> > >  
> > >  	list_for_each_entry(b, &device_info->safe_buffers, node)
> > > -		if (b->safe_dma_addr == safe_dma_addr) {
> > > -			rb = b;
> > > -			break;
> > > -		}
> > > +		if (for_sync) {
> > > +			if (b->safe_dma_addr <= safe_dma_addr &&
> > > +			    safe_dma_addr < b->safe_dma_addr + b->size) {
> > > +				rb = b;
> > > +				break;
> > > +			}
> > > +		} else
> > > +			if (b->safe_dma_addr == safe_dma_addr) {
> > > +				rb = b;
> > > +				break;
> > > +			}
> > 
> > This is the niggle; I don't like this indentation style.  If you want to
> > indent this if () statement, then please format like this:
> > 
> > 		} else {
> > 			if (b->safe...) {
> > 				...
> > 			}
> > 		}
> > 
> > or format it as:
> > 
> > 		} else if (b->safe...) {
> > 			...
> > 		}
> 
> ok, here's the fixed patch.
> 
> =
> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH] ARM: dmabounce: fix partial sync in dma_sync_single_* API
> 
> Some network drivers do a partial sync with
> dma_sync_single_for_{device|cpu}. The dma_addr argument might not be
> the same as one as passed into the mapping API.
> 
> This adds some tricks to find_safe_buffer() for
> dma_sync_single_for_{device|cpu}.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> ---
>  arch/arm/common/dmabounce.c |   30 +++++++++++++++++++++---------
>  1 files changed, 21 insertions(+), 9 deletions(-)

Ping?

Is this going to be merged via the arm tree?
