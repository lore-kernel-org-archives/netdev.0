From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 0/7] Fixing dma mask setting in various
	network drivers
Date: Tue, 11 Jun 2013 21:35:05 +0100
Message-ID: <20130611203505.GO18614@n2100.arm.linux.org.uk>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	<20130611111230.000062d2@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rasesh Mody <rmody@brocade.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20130611111230.000062d2@unknown>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Jun 11, 2013 at 11:12:30AM -0700, Jesse Brandeburg wrote:
> On Tue, 11 Jun 2013 00:08:49 +0100
> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> 
> > While looking at the way coherent DMA masks are handled (and the
> > fact many drivers write directly to the mask) I stumbled across
> > this set of oddities in various network drivers, which looks like
> > it's been cut'n'pasted.
> > 
> > I haven't yet tested these patches in any way, which is one reason
> > I'm sending them out as an RFC.  The other reason is to find out
> > if other people agree that these are indeed fixes.
> > 
> >  drivers/net/ethernet/brocade/bna/bnad.c           |    7 +++----
> >  drivers/net/ethernet/intel/e1000e/netdev.c        |   11 +++++------
> >  drivers/net/ethernet/intel/igb/igb_main.c         |   11 +++++------
> >  drivers/net/ethernet/intel/igbvf/netdev.c         |   11 +++++------
> >  drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    9 ++++-----
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   11 +++++------
> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++++------
> >  7 files changed, 32 insertions(+), 39 deletions(-)
> 
> Thanks Russell,
> 
> The intel driver changes seem valid (we are testing them now).
> According to DMA-API-HOWTO, the coherent mask will always succeed if
> the regular mask succeeded, so the code can be further simplified as
> well to basically match the example in DMA-API-HOWTO.
> 
> This is my proposed change to the intel drivers.  Comments?
> 
> +	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> +		pci_using_dac = true;
> +		/* coherent mask for the same size will always succeed if
> +		 * dma_set_mask does
> +		 */
> +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
> +	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
> +		pci_using_dac = false;
> +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> +	} else {
> +		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
> +			 __func__, err);
> +		err = -EIO;
> +		goto err_dma;
>  	}

Yep, other drivers do that too, and as you say, the documentation says
it's a valid "optimization", so I don't see a problem with it - if
there is, the documentation would need fixing!

As part of my review of all this stuff, I'm wondering whether a helper
to set both masks makes sense.  Something like:

static inline int dma_set_masks(struct device *dev, u64 mask)
{
	int ret = dma_set_mask(dev, mask);
	if (ret == 0)
		dma_set_coherent_mask(dev, mask);
	return ret;
}

"dma_set_masks()" is a little too close to dma_set_mask() though; and
such a function looks like it would be usable for 20 odd drivers
currently.  The plus point is that it may help to prevent this kind
of issue in the future...

Thoughts?

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
