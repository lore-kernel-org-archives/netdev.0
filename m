From: Feng Tang <feng.tang@intel.com>
Subject: Re: [PATCH v2] net: alx: use custom skb allocator
Date: Mon, 30 May 2016 14:57:33 +0800
Message-ID: <20160530065733.GA17507@shbuild888>
References: <1464158994-7725-1-git-send-email-feng.tang@intel.com>
 <20160525.195341.342679643310465817.davem@davemloft.net>
 <20160526084155.GB11823@shbuild888>
 <1464268102.5939.88.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	johannes@sipsolutions.net, jarod@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464268102.5939.88.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Thu, May 26, 2016 at 06:08:22AM -0700, Eric Dumazet wrote:
> On Thu, 2016-05-26 at 16:41 +0800, Feng Tang wrote:
> > On Wed, May 25, 2016 at 07:53:41PM -0400, David Miller wrote:
> 
> > > 
> > > But now that we have at least two instances of this code we really
> > > need to put a common version somewhere. :-/
> > 
> > I agree, and furthermore I noticed there are some similar routines
> > in the 4 individual Atheros drivers atlx/alx/atl1c/atl1e, which may
> > be unified by a simple framework for them all. Maybe the driver
> > maintainer from Atheros could take a look, as they can reach all
> > the real HWs :)
> 
> Note that you could also use the napi_get_frags() API that other drivers
> use, and you attach page frags to the skb.
> 
> (Ie use small skb->head allocations where the stack will pull the
> headers, but use your own page based allocations for the frames)
> 
> This might allow you to use the page reuse trick that some Intel drivers
> use.
> 
> Look for igb_can_reuse_rx_page() for an example.

Thanks for the detail hints.

When working on unifying the 2 same fixes in atl1c and alx driver, I gave
the problem a second thought. As the problem is due to a HW problem
(most likely), which is just about the DMA RX address, that if the addr is
close to the page boundary: 0x...f80(raw skb->data, and actual DMA
addr set to HW is 0x...fc0), the dma will fail with RX overflow error. And
this is really not the fault of current skb allocation APIs.

Maybe we can simply drop the skb with 0x...f80 address, and re-apply a new
one. This is a workaroun of HW issue of some Atheros devices, and it has
some advantages:
1. We don't need to create a custom skb allocator.
2. The performance effect is small. First the 0x..f80 skb only happens with
some MTU. Secondly even for where the 0x..f80 could happen, it will only get
about 1/16 chance, as the __netdev_alloc_dev will make 16 2KB skb for each
32KB batch buffer allocation

This workaround works fine on my Y580, and I will send it to bugzlla for
others' try.

Thanks,
Feng
