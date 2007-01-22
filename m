From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 3/4] atl1: Main C file for Attansic L1 driver
Date: Mon, 22 Jan 2007 09:22:36 +0100
Message-ID: <1169454156.3055.1256.camel@laptopd505.fenrus.org>
References: <20070121210655.GD2702@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, shemminger@osdl.org, csnook@redhat.com,
	hch@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38216 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbXAVIXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 03:23:22 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
In-Reply-To: <20070121210655.GD2702@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-01-21 at 15:06 -0600, Jay Cliburn wrote:
> +
> +	/* PCI config space info */
> +	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
> +	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);

I'm highly suspicious of drivers that use the PCI_COMMAND word...
thankfully this seems to be a write only variable in this driver :)

> +	if (adapter->pci_using_64) {	
> +		/* test whether HIDWORD dma buffer is not cross boundary */
> +		if (unlikely(((ring_header->dma & 0xffffffff00000000ULL) >> 32)
> +		    != (((ring_header->dma + size) & 0xffffffff00000000ULL) >>


this is not needed; this is never ever supposed to happen..
what is more, you allocated consistent DMA memory, without setting the
consistent DMA mask to anything other than 32 bit... so you'll never
even go outside of the 32 bit region..

> +	if (tpd_ring->buffer_info)
> +		kfree(tpd_ring->buffer_info);

no need for the if(), kfree(NULL) is perfectly fine


> +static void atl1_clear_phy_int(struct atl1_adapter *adapter)
> +{
> +	u16 phy_data;
> +	spin_lock(&adapter->lock);
> +	atl1_read_phy_reg(&adapter->hw, 19, &phy_data);
> +	spin_unlock(&adapter->lock);

are you sure this lock doesn't need to be irq safe?


> +/**
> + * atl1_irq_disable - Mask off interrupt generation on the NIC
> + * @adapter: board private structure
> + **/
> +void atl1_irq_disable(struct atl1_adapter *adapter)
> +{
> +	atomic_inc(&adapter->irq_sem);
> +	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
> +	synchronize_irq(adapter->pdev->irq);
> +}

doesn't this want a PCI posting flush?
I'm also a bit sceptical about irq_sem ...


> +/**
> + * When ACPI resume on some VIA MotherBoard, the Interrupt Disable bit/0x400
> + * on PCI Command register is disable.
> + * The function enable this bit.
> + * Brackett, 2006/03/15
> + */
> +static void atl1_via_workaround(struct atl1_adapter *adapter)
> +{
> +	unsigned long value;
> +
> +	value = ioread16(adapter->hw.hw_addr + PCI_COMMAND);
> +	if (value & PCI_COMMAND_INTX_DISABLE)
> +		value &= ~PCI_COMMAND_INTX_DISABLE;
> +	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
> +}

hmm I wonder if this shouldn't be a more generic PCI level quirk, not so
much a driver level quirk...




