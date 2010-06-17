From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] PCI: MSI: Remove unsafe and unnecessary hardware
 access
Date: Thu, 17 Jun 2010 16:58:57 -0700
Message-ID: <1276819137.9345.14.camel@HP1>
References: <1276564403.19104.28.camel@HP1>
 <1276802196.2083.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jesse Barnes" <jbarnes@virtuousgeek.org>,
	"Matthew Wilcox" <matthew@wil.cx>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4636 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760887Ab0FQX71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 19:59:27 -0400
In-Reply-To: <1276802196.2083.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2010-06-17 at 12:16 -0700, Ben Hutchings wrote:
> During suspend on an SMP system, {read,write}_msi_msg_desc() may be
> called to mask and unmask interrupts on a device that is already in a
> reduced power state.  At this point memory-mapped registers including
> MSI-X tables are not accessible, and config space may not be fully
> functional either.
> 
> While a device is in a reduced power state its interrupts are
> effectively masked and its MSI(-X) state will be restored when it is
> brought back to D0.  Therefore these functions can simply read and
> write msi_desc::msg for devices not in D0.
> 
> Further, read_msi_msg_desc() should only ever be used to update a
> previously written message, so it can always read msi_desc::msg
> and never needs to touch the hardware.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

This works for me too.  Thanks Ben.

> ---
> On Mon, 2010-06-14 at 18:13 -0700, Michael Chan wrote: 
> > I'm debugging the bnx2 driver which doesn't work after suspend/resume if
> > it is running in MSI-X mode.  The problem is that during suspend, the
> > MSI-X vectors are disabled by the following sequence on x86:
> > 
> > take_cpu_down() -> cpu_disable_common() -> fixup_irqs()
> >
> > The MSI-X address/data used to disable the vectors are remembered in the
> > above sequence. During resume, these address/data are then programmed
> > back to the device during pci_restore_state(), causing all the vectors
> > to remain disabled.
> 
> That's not quite what I see.  What I see is that the message is read
> back from the table *after* the driver's suspend method has been called.
> At this point the device is already in D3 and memory-mapped registers
> are not accessible, so we get random bits as the message.  At least,
> that's what I see happening with the sfc driver.
> 
> > Some drivers call free_irq() during suspend and request_irq() during
> > resume, and that should avoid the problem.  bnx2 and some other drivers
> > do not do that.  These drivers rely on pci_restore_state() to restore
> > the MSI-X vectors to the same working state before suspend.
> > 
> > What's the right way to fix this?  Thanks.
> 
> This is my attempt, which works for sfc.  See if it works for bnx2.
> 
> Ben.
> 
>  drivers/pci/msi.c |   34 +++++++++++-----------------------
>  1 files changed, 11 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> index 77b68ea..03f04dc 100644
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -196,30 +196,15 @@ void unmask_msi_irq(unsigned int irq)
>  void read_msi_msg_desc(struct irq_desc *desc, struct msi_msg *msg)
>  {
>  	struct msi_desc *entry = get_irq_desc_msi(desc);
> -	if (entry->msi_attrib.is_msix) {
> -		void __iomem *base = entry->mask_base +
> -			entry->msi_attrib.entry_nr * PCI_MSIX_ENTRY_SIZE;
>  
> -		msg->address_lo = readl(base + PCI_MSIX_ENTRY_LOWER_ADDR);
> -		msg->address_hi = readl(base + PCI_MSIX_ENTRY_UPPER_ADDR);
> -		msg->data = readl(base + PCI_MSIX_ENTRY_DATA);
> -	} else {
> -		struct pci_dev *dev = entry->dev;
> -		int pos = entry->msi_attrib.pos;
> -		u16 data;
> +	/* We do not touch the hardware (which may not even be
> +	 * accessible at the moment) but return the last message
> +	 * written.  Assert that this is valid, assuming that
> +	 * valid messages are not all-zeroes. */
> +	BUG_ON(!(entry->msg.address_hi | entry->msg.address_lo |
> +		 entry->msg.data));
>  
> -		pci_read_config_dword(dev, msi_lower_address_reg(pos),
> -					&msg->address_lo);
> -		if (entry->msi_attrib.is_64) {
> -			pci_read_config_dword(dev, msi_upper_address_reg(pos),
> -						&msg->address_hi);
> -			pci_read_config_word(dev, msi_data_reg(pos, 1), &data);
> -		} else {
> -			msg->address_hi = 0;
> -			pci_read_config_word(dev, msi_data_reg(pos, 0), &data);
> -		}
> -		msg->data = data;
> -	}
> +	*msg = entry->msg;
>  }
>  
>  void read_msi_msg(unsigned int irq, struct msi_msg *msg)
> @@ -232,7 +217,10 @@ void read_msi_msg(unsigned int irq, struct msi_msg *msg)
>  void write_msi_msg_desc(struct irq_desc *desc, struct msi_msg *msg)
>  {
>  	struct msi_desc *entry = get_irq_desc_msi(desc);
> -	if (entry->msi_attrib.is_msix) {
> +
> +	if (entry->dev->current_state != PCI_D0) {
> +		/* Don't touch the hardware now */
> +	} else if (entry->msi_attrib.is_msix) {
>  		void __iomem *base;
>  		base = entry->mask_base +
>  			entry->msi_attrib.entry_nr * PCI_MSIX_ENTRY_SIZE;
> -- 
> 1.6.2.5
> 
> 


