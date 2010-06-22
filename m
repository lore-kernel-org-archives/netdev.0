From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Tue, 22 Jun 2010 12:26:04 -0500
Message-ID: <1277227564.9374.7.camel@mulgrave.site>
References: <20100617.073653.193708702.davem@davemloft.net>
	 <20100617234520S.fujita.tomonori@lab.ntt.co.jp>
	 <20100617153051.GB8964@linux-sh.org>
	 <20100622152823R.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lethal@linux-sh.org, davem@davemloft.net, mchan@broadcom.com,
	vapier@gentoo.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20100622152823R.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-06-22 at 15:30 +0900, FUJITA Tomonori wrote:
> On Fri, 18 Jun 2010 00:30:51 +0900
> Paul Mundt <lethal@linux-sh.org> wrote:
> 
> > On Thu, Jun 17, 2010 at 11:50:35PM +0900, FUJITA Tomonori wrote:
> > > On Thu, 17 Jun 2010 07:36:53 -0700 (PDT)
> > > David Miller <davem@davemloft.net> wrote:
> > > 
> > > > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > > > Date: Thu, 17 Jun 2010 21:21:13 +0900
> > > > 
> > > > > On Wed, 16 Jun 2010 23:24:44 -0700
> > > > > "Michael Chan" <mchan@broadcom.com> wrote:
> > > > > 
> > > > >> David, why is dma_is_consistent() always returning 1 on sparc?  The
> > > > >> streaming DMA is not consistent.
> > > > > 
> > > > > I think that there are some confusion about dma_is_consistent(). Some
> > > > > architectures think that dma_is_consistent() is supposed to return 1
> > > > > if they can allocate coherent memory (note that some architectures
> > > > > can't allocate coherent memory).
> > > > 
> > > > Right, and that's why it's defined this way.
> > > > 
> > > > If the desired meaning is different, just me know and I'll fix the
> > > > sparc definition.
> > > 
> > > I think that there are some other architectures do the same. We need
> > > to make sure that all the architectures define dma_is_consistent() in
> > > the same meaning if drivers need it. However, I'm not sure we really
> > > need dma_is_consistent(). There is only one user of it (and I think we
> > > could remove it).
> > > 
> > > In the bnx2 case, we can simply prefetch on all the archs (or just
> > > remove the optimization).
> > 
> > I think its worthwhile keeping, especially since the consistency can vary
> > on a per struct device level. If there's a benefit with these sorts of
> > prefetch micro-optimizations in drivers when it doesn't cost us that much
> > to provide the hint, I don't really see the harm. If dma_is_consistent()
> > is suddenly supposed to take on other meanings, or it's supposed to mean
> > something entirely different, then this is something we should deal with
> > separately.
> > 
> > I don't see any harm in letting drivers know whether we can support
> > consistent DMA allocs for a given struct device or not though, even if
> > the micro-optimization is marginal at best.
> 
> I'm happier with exporting less DMA APIs to drivers because looks like
> new original ways to use the APIs wrongly can be always invented.
> 
> 
> > At least I've conditionalized the definition on SH, and it seems other
> > archictures have done so too. It's not clear what we'd gain from throwing
> 
> >From a quick look, except for SH and POWERPC (and always-coherent
> architectures), everyone does differently?
> 
> There are architectures that need to turn off the CPU cache for
> coherent memory, I can't find none of them that see if an address is
> coherent or not in dma_is_consistent().

Yes, I fear ... parisc.  We have a class of machines where this is the
only way (and we also have a class of machines where the cache disable
doesn't work properly and we can't manufacture coherent memory at all).
All our pa2.0 systems are fully integrated between the iommu cache and
the CPU cache, so they can manufacture coherent memory properly, but the
pa1.0 systems are a mixed bag of dirty tricks.

> As I wrote, there is only one user of this API and we can remove it
> easily. Then I'm not sure it's worth fixing dma_is_consistent() in
> many architectures. I prefer to add this to
> feature-removal-schedule.txt to see if driver writers oppose.

Let me check our two drivers: lasi and 53c700; they're the only ones we
support on the architecture that can't do any coherence.  I think we
don't need to tell because the dma_sync_cache calls which replace
coherent memory handling are indirected on the platform so we don't need
a global dma_is_coherent() flag.

James


