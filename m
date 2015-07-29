From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Export __netdev_alloc_frag() to allow gfp_mask
 flags
Date: Wed, 29 Jul 2015 22:37:55 +0200
Message-ID: <1438202275.20182.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438182653-2136-1-git-send-email-w-kwok2@ti.com>
	 <1438187516.20182.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55B93611.7070506@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: WingMan Kwok <w-kwok2@ti.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B93611.7070506@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-29 at 16:22 -0400, Murali Karicheri wrote:
> Eric,
> 
> On 07/29/2015 12:31 PM, Eric Dumazet wrote:
> > On Wed, 2015-07-29 at 11:10 -0400, WingMan Kwok wrote:
> >> This patch makes the function __netdev_alloc_frag() non-static and
> >> exports it so that drivers that need to specify additional flags,
> >> such as __GFP_DMA, can use it. The currently exported function,
> >> netdev_alloc_frag() doesn't allow passing in gfp_mask flags.
> >>
> >> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
> >> Signed-off-by: Reece R. Pollack <x0183204@ti.com>
> >> ---
> >>   include/linux/skbuff.h |    1 +
> >>   net/core/skbuff.c      |    3 ++-
> >>   2 files changed, 3 insertions(+), 1 deletion(-)
> >
> > You can not do this.
> >
> > __napi_alloc_frag() uses __alloc_page_frag() using a per cpu reserve.
> >
> Thanks for your response.
> 
> I assume you mean to say __netdev_alloc_frag() which is what the patch 
> affects. Right?
> 
> > This per cpu reserve would be shared by regular GFP_ATOMIC and your
> > __GFP_DMA allocations.
> 
> I am trying to understand the issue here. Is there any issue in sharing 
> this per CPU reserve between DMA and ATOMIC allocations. Without this 
> flag, the assumption is this function can return memory which is not 
> DMA-able and this flag assures it is allocated from DMA zone.

First caller __netdev_alloc_frag() uses GFP_ATOMIC.

A big page (32 KB) is allocated and stored into cache. Part of it given
to caller. (like 1536 bytes or so)

Then your driver calls with __GFP_DMA.

We find a prior page on percpu cache with enough room in it to allocate
a fragment.

Your driver getd a fragment from the prior GFP_ATOMIC allocation, with
no DMA guarantee.

Therefore, your patch is not working in all cases.
