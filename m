From: Feng Tang <feng.tang@intel.com>
Subject: Re: [PATCH] net: alx: use custom skb allocator
Date: Wed, 25 May 2016 13:37:10 +0800
Message-ID: <20160525053710.GA25034@shbuild888>
References: <1463722863-31241-1-git-send-email-feng.tang@intel.com>
 <20160520075623.GA14140@shbuild888>
 <20160520182657.GF35402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160520182657.GF35402@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarod,

On Fri, May 20, 2016 at 02:26:57PM -0400, Jarod Wilson wrote:
> On Fri, May 20, 2016 at 03:56:23PM +0800, Feng Tang wrote:
> > Hi,
> > 
> > Please ignore this patch. 
> > 
> > I found the problem and made the patch with kernel 4.4 with Ubuntu 12.04
> > on Lenovo Y580. 
> > 
> > After submitting the patch, I tried to google the datasheet for
> > Atheros 8161 dev, and found there was already a kernel bugzilla 
> > https://bugzilla.kernel.org/show_bug.cgi?id=70761
> > that had a fix from Jarod Wilson which get merged in v4.5 (commit c406700cd) 
> > 
> > Per my test, the new 4.6.0 kernel works fine with Jarod's patch. 
> 
> Might not hurt to get this some testing by people for whom my patch didn't
> fix things. It seems to help for a fair number of people, but not
> everyone, so perhaps this would be of use as well.

Thanks for the suggestion, and you are right. Some users whose AR8161 can't be
cured by your path report the device is working with my patch, though one 
reported the TX is slower while RX is not (which can't be reproduced on
my Lenovo Y580).
https://bugzilla.kernel.org/show_bug.cgi?id=70761

So I think this patch is better to be merged, and I will send out a v2

I did some more debug, it looks very likely to be related with the RX
DMA address, specifically 0x...f80, if RX buffer get 0x...f80 several
times, their will be RX overflow error and card will stop working.

For kernel 4.5.0 which merged Jarod's patch and works fine with my
AR8161/Lennov Y580, if I made some change to the
	__netdev_alloc_skb
		--> __alloc_page_frag()
to make the allocated buffer can get an address with 0x...f80, then the
same error happens. If I make it to 0x...f40 or 0x....fc0, every thing
is still fine. So I tend to believe that the 0x..f80 address cause the
silicon to behave abnormally.

Thanks,
Feng

> 
> Personally, my own alx-driven hardware didn't have a problem to begin
> with, so I'm not able to do more than make sure things don't regress
> w/already functioning hardware.
> 
> 
> > On Fri, May 20, 2016 at 01:41:03PM +0800, Feng Tang wrote:
> > > This patch follows Eric Dumazet's commit 7b70176421 to fix one
> > > exactly same bug in alx driver, that the network link will
> > > be lost in 1-5 minutes after the device is up.
> > > 
> > > Following is a git log from Eric's 7b70176421:
> > > 
> > > "We had reports ( https://bugzilla.kernel.org/show_bug.cgi?id=54021 )
> > > that using high order pages for skb allocations is problematic for atl1c
> > > 
> > > We do not know exactly what the problem is, but we suspect that crossing
> > > 4K pages is not well supported by this hardware.
> > > 
> > > Use a custom allocator, using page allocator and 2K fragments for
> > > optimal stack behavior. We might make this allocator generic
> > >  in future kernels."
> > > 
> > > And my debug shows the same suspect, most of the errors happen
> > > when there is a RX buffer address with 0x......f80, hopefully
> > > this will get noticed and fixed from silicon side.
> > > 
> > > My victim is a Lenovo Y580 Laptop with Atheros ALX AR8161 etherenet
> > > device(PCI ID 1969:1091), with this patch the ethernet dev
> > > works just fine
> > > 
> > > Signed-off-by: Feng Tang <feng.tang@intel.com>
