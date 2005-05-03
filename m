From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Mystery packet killing tg3
Date: Tue, 3 May 2005 15:53:55 -0700
Message-ID: <20050503155355.6ac3f4a6.davem@davemloft.net>
References: <20050502162405.65dfb4a9@localhost.localdomain>
	<20050502200251.38271b61.davem@davemloft.net>
	<20050503140528.1bd2ac74@dxpl.pdx.osdl.net>
	<20050503141314.441c9d75.davem@davemloft.net>
	<1115152907.15156.26.camel@rh4>
	<20050503150333.1ac1c159.davem@davemloft.net>
	<1115155690.15156.32.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1115155690.15156.32.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 May 2005 14:28:10 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> On Tue, 2005-05-03 at 15:03 -0700, David S. Miller wrote:
> 
> > Michael, there were no master/target abort bits set in the PCI status
> > register from his dump.  If one of the DMA units locks up on the tg3,
> > will it still be able to update the PCI_STATUS register appropriately
> > when it encounters a DMA transaction error (ie. master or target abort)
> 
> I believe so. Also, the DMA read and write status registers showed all
> zeros, meaning there were no DMA related errors:
> 
> DEBUG: RDMAC_MODE[000003fc] RDMAC_STATUS[00000000]
> DEBUG: WDMAC_MODE[000003fc] WDMAC_STATUS[00000000]

Right, I noticed that too.

Stephen says that trying to force enable the mailbox write
reordering workaround doesn't solve the problem either.

I wonder exactly how it would show up if the x86_64 port
unmapped a DMA address in the IOMMU and tg3 (or a bridge
in the middle) tried to fetch that address again.

I remember some issue not too long ago where PCI bridges
could still prefetch a DMA address even after a device
was done with it.  Because of this, they added code to
the x86_64 IOMMU driver that kept a read-only dummy mapping
around all the time so that this would not cause faults.
I even added similar code to the PCI IOMMU handling on sparc64.

Indeed, if you look in arch/x86_64/kernel/pci-gart.c they use
a scratch mapping when the unmap DMA translations.

I can't think of what else could be wedging the tg3.  Michael,
any ideas?  There are some 5703 specific programming to consider:

1) Setting of PCIX_CAPS_BURST_MASK in PCI_X_CAPS register.
   Currently tg3 sets it to "PCIX_CAPS_MAX_BURST_CPIOB" which
   is 2 (shifted up PCIX_CAPS_BURST_SHIFT of course).

2) On Fibre, we force a write of 0x616000 to MAC_SERDES_CFG for
   5703 chips.

   Because the PCS synced indication is on in his dumps, I
   am assuming he is on a Fibre link, so this is relevant.

3) When the low 5 bits of TG3PCI_CLOCK_CTRL are 0x6 or 0x7
   we set DMA_RWCTL_ONE_DMA in the DMA R/W control register.
   On all 5703 we also set bit 23 to enable some hw bug workaround.

4) On 5703 (and 5704), we always clear the low 4 bits of DMA R/W
   control.

A quick perusal shows that these same exact things get done in
the bcm5700 driver too.
