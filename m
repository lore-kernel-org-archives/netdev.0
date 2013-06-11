From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [RFC 0/7] Fixing dma mask setting in various network drivers
Date: Tue, 11 Jun 2013 11:12:30 -0700
Message-ID: <20130611111230.000062d2@unknown>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Don Skidmore" <donald.c.skidmore@intel.com>,
	<e1000-devel@lists.sourceforge.net>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	<netdev@vger.kernel.org>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	Rasesh Mody <rmody@brocade.com>,
	Tushar Dave <tushar.n.dave@intel.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43837 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755370Ab3FKSMb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 14:12:31 -0400
In-Reply-To: <20130610230849.GF18614@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Jun 2013 00:08:49 +0100
Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> While looking at the way coherent DMA masks are handled (and the
> fact many drivers write directly to the mask) I stumbled across
> this set of oddities in various network drivers, which looks like
> it's been cut'n'pasted.
> 
> I haven't yet tested these patches in any way, which is one reason
> I'm sending them out as an RFC.  The other reason is to find out
> if other people agree that these are indeed fixes.
> 
>  drivers/net/ethernet/brocade/bna/bnad.c           |    7 +++----
>  drivers/net/ethernet/intel/e1000e/netdev.c        |   11 +++++------
>  drivers/net/ethernet/intel/igb/igb_main.c         |   11 +++++------
>  drivers/net/ethernet/intel/igbvf/netdev.c         |   11 +++++------
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    9 ++++-----
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   11 +++++------
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++++------
>  7 files changed, 32 insertions(+), 39 deletions(-)

Thanks Russell,

The intel driver changes seem valid (we are testing them now).
According to DMA-API-HOWTO, the coherent mask will always succeed if
the regular mask succeeded, so the code can be further simplified as
well to basically match the example in DMA-API-HOWTO.

This is my proposed change to the intel drivers.  Comments?

+	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
+		pci_using_dac = true;
+		/* coherent mask for the same size will always succeed if
+		 * dma_set_mask does
+		 */
+		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
+	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
+		pci_using_dac = false;
+		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
+	} else {
+		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
+			 __func__, err);
+		err = -EIO;
+		goto err_dma;
 	}
